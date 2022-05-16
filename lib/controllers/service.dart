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
import 'package:clash_for_flutter/types/clash_service.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';

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
  }

  initLog() {
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

  closeLog() {
    listenLogsSub?.cancel();
    listenLogsSub = null;
    wsChannelLogs?.sink.close();
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
    closeLog();
    final info = await fetchInfo();
    if (info.status == 'running') await fetchStop();
    if (info.mode == 'service-mode') return;

    if (clashServiceProcess != null) {
      clashServiceProcess!.kill();
      clashServiceProcess = null;
    } else if (kDebugMode) {
      await killProcess(path.basename(Files.assetsClashService.path));
    }
    await _waitServiceStop();
  }

  Future<void> install() async {
    await exit();
    final res = await runAsAdmin(Files.assetsClashService.path, ["install", "start"]);
    log.debug('install', res.stdout);
    if (res.exitCode == 0) await _waitServiceStart();
  }

  Future<void> uninstall() async {
    await exit();
    final res = await runAsAdmin(Files.assetsClashService.path, ["stop", "uninstall"]);
    log.debug('uninstall', res.stdout);
    if (res.exitCode == 0) await _waitServiceStop();
  }

  Future<void> restartClashCore() async {
    log.debug('restartClashCore');
    restartClashCoreIng.value = true;
    // await controllers.tray.updateTray();
    await fetchStop();
    await fetchStart(controllers.config.config.value.selected);
    restartClashCoreIng.value = false;
    // await controllers.tray.updateTray();
  }

  Future<void> serviceModeSwitch(bool open) async {
    serviceModeSwitching.value = true;
    // await controllers.tray.updateTray();
    if (open) {
      await install();
    } else {
      await uninstall();
    }
    await initService();
    await fetchStart(controllers.config.config.value.selected);
    await controllers.core.waitCoreStart();
    serviceModeSwitching.value = false;
    // await controllers.tray.updateTray();
  }
}
