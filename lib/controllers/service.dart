import 'dart:io';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:day/day.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:web_socket_channel/io.dart';

import 'package:clash_for_flutter/const/const.dart';
import 'package:clash_for_flutter/utils/shell.dart';
import 'package:clash_for_flutter/utils/logger.dart';
import 'package:clash_for_flutter/utils/system_dns.dart';
import 'package:clash_for_flutter/utils/system_proxy.dart';
import 'package:clash_for_flutter/types/clash_service.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';
import 'package:window_manager/window_manager.dart';

final headers = {"User-Agent": "clash-for-flutter/0.0.1"};

class ServiceController extends GetxController {
  final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:9089', headers: headers));

  var serviceMode = false.obs;
  var restartClashCoreIng = false.obs;
  var serviceModeSwitching = false.obs;

  Process? clashServiceProcess;

  IOWebSocketChannel? wsChannelLogs;
  StreamSubscription<dynamic>? listenLogsSub;
  RxList<ClashServiceLog> logs = <ClashServiceLog>[].obs;

  Future<void> initService() async {
    try {
      final data = await fetchInfo();
      serviceMode.value = data.mode == 'service-mode';
    } catch (e) {
      await startService();
    }
    final visible = await windowManager.isVisible();
    if (visible) initLog();
  }

  void initLog() {
    wsChannelLogs = IOWebSocketChannel.connect(Uri.parse('ws://127.0.0.1:9089/logs'), headers: headers);
    listenLogsSub = wsChannelLogs!.stream.listen((event) {
      for (final it in (event as String).split('\n')) {
        final matchs = RegExp(r'^time="([\d-T:+]+)" level=(\w+) msg="(.+)"$').firstMatch(it.trim());

        final res = matchs?.groups([1, 2, 3]);
        final time = res?[0] ?? '1970-01-01T00:00:00+00:00';
        final type = res?[1] ?? 'debug';
        final msg = res?[2] ?? it;

        logs.add(ClashServiceLog(time: Day.fromString(time).format('YYYY-MM-DD HH:mm:ss'), type: type, msg: msg));
        if (logs.length > 1000) logs.removeAt(0);
      }
    });
  }

  Future<void> closeLog() async {
    await listenLogsSub?.cancel();
    listenLogsSub = null;
    await wsChannelLogs?.sink.close();
    wsChannelLogs = null;
  }

  Future<void> _startService() async {
    clashServiceProcess = await Process.start(Files.assetsClashService.path, ['user-mode'], mode: ProcessStartMode.inheritStdio);
    clashServiceProcess?.exitCode.then((code) async {
      log.error('clash-service exit with code: $code');
      // for macos
      if (code == 101) {
        BotToast.showText(text: 'clash-service exit with code: $code,After 5 seconds, try to restart');
        log.error('After 5 seconds, try to restart');
        await Future.delayed(const Duration(seconds: 5));
        await _startService();
      }
    });
  }

  Future<void> startService() async {
    serviceMode.value = false;
    await _startService();
    await _waitServiceStart();
  }

  // for macos
  Future<void> _waitServiceStart() async {
    while (true) {
      try {
        await fetchInfo();
        return;
      } catch (e) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  // for windows
  Future<void> _waitServiceStop() async {
    while (true) {
      try {
        await fetchInfo();
        await Future.delayed(const Duration(milliseconds: 50));
      } catch (e) {
        return;
      }
    }
  }

  Future<ClashServiceInfo> fetchInfo() async {
    final res = await dio.post('/info');
    return ClashServiceInfo.fromJson(res.data);
  }

  Future<void> fetchStart(String name) async {
    final data = await fetchInfo();
    if (data.status == 'running') await fetchStop();
    await dio.post('/start', data: {
      "args": ['-d', Paths.config.path, '-f', path.join(Paths.config.path, name)]
    });
  }

  Future<void> fetchStop() async {
    await dio.post('/stop');
  }

  Future<void> exit() async {
    await closeLog();
    await stopClashCore();
    if (clashServiceProcess != null) {
      clashServiceProcess!.kill();
      clashServiceProcess = null;
    } else if (kDebugMode) {
      await killProcess(path.basename(Files.assetsClashService.path));
    }
  }

  Future<void> install() async {
    final res = await runAsAdmin(Files.assetsClashService.path, ["install", "start"]);
    log.debug('install', res.stdout);
    if (res.exitCode == 0) await _waitServiceStart();
  }

  Future<void> uninstall() async {
    final res = await runAsAdmin(Files.assetsClashService.path, ["stop", "uninstall"]);
    log.debug('uninstall', res.stdout);
    if (res.exitCode == 0) await _waitServiceStop();
  }

  Future<void> serviceModeSwitch(bool open) async {
    serviceModeSwitching.value = true;
    await exit();
    open ? await install() : await uninstall();
    await initService();
    await startClashCore();
    serviceModeSwitching.value = false;
  }

  Future<void> stopClashCore() async {
    if (Platform.isMacOS &&
        controllers.service.serviceMode.value &&
        controllers.config.clashCoreTunEnable.value &&
        controllers.config.clashCoreDns.isNotEmpty) {
      await MacSystemDns.instance.set([]);
    }
    if (controllers.config.config.value.setSystemProxy) await SystemProxy.instance.set(SystemProxyConfig());
    await fetchStop();
  }

  Future<void> startClashCore() async {
    await fetchStart(controllers.config.config.value.selected);
    controllers.core.setApi(controllers.config.clashCoreApiAddress.value, controllers.config.clashCoreApiSecret.value);
    await controllers.core.waitCoreStart();
    if (Platform.isMacOS &&
        controllers.service.serviceMode.value &&
        controllers.config.clashCoreTunEnable.value &&
        controllers.config.clashCoreDns.isNotEmpty) {
      await MacSystemDns.instance.set([controllers.config.clashCoreDns.value]);
    }
    if (controllers.config.config.value.setSystemProxy) await SystemProxy.instance.set(controllers.core.proxyConfig);
    await controllers.core.fetchConfig();
  }

  Future<void> reloadClashCore() async {
    restartClashCoreIng.value = true;
    BotToast.showText(text: '正在重启 Clash Core ……');
    await stopClashCore();
    await controllers.config.readClashCoreApi();
    await startClashCore();
    BotToast.showText(text: '重启成功');
    restartClashCoreIng.value = false;
  }
}
