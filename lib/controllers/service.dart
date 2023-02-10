import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:sentry_dio/sentry_dio.dart';
import 'package:web_socket_channel/io.dart';

import 'package:clash_for_flutter/utils/utils.dart';
import 'package:clash_for_flutter/const/const.dart';
import 'package:clash_for_flutter/utils/shell.dart';
import 'package:clash_for_flutter/utils/logger.dart';
import 'package:clash_for_flutter/utils/system_dns.dart';
import 'package:clash_for_flutter/utils/system_proxy.dart';
import 'package:clash_for_flutter/types/clash_service.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';

final headers = {"User-Agent": "clash-for-flutter/0.0.1"};

class ServiceController extends GetxController {
  final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:9089', headers: headers));

  var serviceMode = false.obs;

  var coreStatus = RunningState.stoped.obs;
  var serviceStatus = RunningState.stoped.obs;

  Process? clashServiceProcess;

  bool get isRunning => serviceStatus.value == RunningState.running && coreStatus.value == RunningState.running;
  bool get isCanOperationService =>
      ![RunningState.starting, RunningState.stopping].contains(serviceStatus.value) &&
      ![RunningState.starting, RunningState.stopping].contains(coreStatus.value);
  bool get isCanOperationCore =>
      serviceStatus.value == RunningState.running && ![RunningState.starting, RunningState.stopping].contains(coreStatus.value);

  ServiceController() {
    dio.addSentry(captureFailedRequests: true);
  }

  Future<void> startService() async {
    serviceStatus.value = RunningState.starting;
    if (Platform.isLinux) {
      await fixBinaryExecutePermissions(Files.assetsClashService);
      await fixBinaryExecutePermissions(Files.assetsClashCore);
    }
    try {
      final data = await fetchInfo();
      serviceMode.value = data.mode == 'service-mode';
    } catch (e) {
      await startUserModeService();
      if (serviceStatus.value == RunningState.error) return;
    }
    serviceStatus.value = RunningState.running;
  }

  Future<void> fixBinaryExecutePermissions(File file) async {
    final stat = await file.stat();
    // 0b001000000
    final has = (stat.mode & 64) == 64;
    if (has) return;
    await Process.run('chmod', ['+x', file.path]);
  }

  Future<void> startUserModeService() async {
    serviceMode.value = false;
    try {
      int? exitCode;
      clashServiceProcess = await Process.start(Files.assetsClashService.path, ['user-mode'], mode: ProcessStartMode.inheritStdio);
      clashServiceProcess!.exitCode.then((code) => exitCode = code);

      while (true) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (exitCode == 101) {
          BotToast.showText(text: 'clash-service exit with code: $exitCode,After 10 seconds, try to restart');
          log.error('After 10 seconds, try to restart');
          await Future.delayed(const Duration(seconds: 10));
          await startUserModeService();
          break;
        } else if (exitCode != null) {
          serviceStatus.value = RunningState.error;
          break;
        }
        try {
          await dio.post('/info');
          break;
        } catch (_) {}
      }
    } catch (e) {
      serviceStatus.value = RunningState.error;
      BotToast.showText(text: e.toString());
    }
  }

  Future<void> stopService() async {
    serviceStatus.value = RunningState.stopping;
    if (coreStatus.value == RunningState.running) await stopClashCore();
    if (!serviceMode.value) {
      if (clashServiceProcess != null) {
        clashServiceProcess!.kill();
        clashServiceProcess = null;
      } else if (kDebugMode) {
        await killProcess(path.basename(Files.assetsClashService.path));
      }
    }
    serviceStatus.value = RunningState.stoped;
  }

  // for macos
  Future<void> waitServiceStart() async {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 100));
      try {
        await dio.post('/info');
        break;
      } catch (_) {}
    }
  }

  // for windows
  Future<void> waitServiceStop() async {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 100));
      try {
        await dio.post('/info');
      } catch (e) {
        break;
      }
    }
  }

  Future<ClashServiceInfo> fetchInfo() async {
    final res = await dio.post('/info');
    return ClashServiceInfo.fromJson(res.data);
  }

  IOWebSocketChannel fetchLogWs() {
    return IOWebSocketChannel.connect(Uri.parse('ws://127.0.0.1:9089/logs'), headers: headers);
  }

  Future<void> fetchStart(String name) async {
    await fetchStop();
    final res = await dio.post<String>('/start', data: {
      "args": ['-d', Paths.config.path, '-f', path.join(Paths.config.path, name)]
    });
    if (json.decode(res.data!)["code"] != 0) throw json.decode(res.data!)["msg"];
  }

  Future<void> fetchStop() async {
    await dio.post('/stop');
  }

  Future<void> install() async {
    final res = await runAsAdmin(Files.assetsClashService.path, ["stop", "uninstall", "install", "start"]);
    log.debug('install', res.stdout, res.stderr);
    if (res.exitCode != 0) throw res.stderr;
    await waitServiceStart();
  }

  Future<void> uninstall() async {
    final res = await runAsAdmin(Files.assetsClashService.path, ["stop", "uninstall"]);
    log.debug('uninstall', res.stdout, res.stderr);
    if (res.exitCode != 0) throw res.stderr;
    await waitServiceStop();
  }

  Future<void> serviceModeSwitch(bool open) async {
    if (serviceStatus.value == RunningState.running) await stopService();
    try {
      open ? await install() : await uninstall();
    } catch (e) {
      BotToast.showText(text: e.toString());
    }
    await startService();
    await startClashCore();
  }

  Future<void> startClashCore() async {
    try {
      coreStatus.value = RunningState.starting;
      await fetchStart(controllers.config.config.value.selected);
      controllers.core.setApi(controllers.config.clashCoreApiAddress.value, controllers.config.clashCoreApiSecret.value);
      while (true) {
        await Future.delayed(const Duration(milliseconds: 200));
        final info = await fetchInfo();
        if (info.status == 'running') {
          try {
            await controllers.core.fetchHello();
            break;
          } catch (_) {}
        } else {
          throw 'clash-core start error';
        }
      }
      await controllers.core.updateConfig();
      if (Platform.isMacOS &&
          controllers.service.serviceMode.value &&
          controllers.config.clashCoreTunEnable.value &&
          controllers.config.clashCoreDns.isNotEmpty) {
        await MacSystemDns.instance.set([controllers.config.clashCoreDns.value]);
      }
      if (controllers.config.config.value.setSystemProxy) await SystemProxy.instance.set(controllers.core.proxyConfig);
      coreStatus.value = RunningState.running;
    } catch (e) {
      log.error(e);
      BotToast.showText(text: e.toString());
      coreStatus.value = RunningState.error;
    }
  }

  Future<void> stopClashCore() async {
    coreStatus.value = RunningState.stopping;
    if (Platform.isMacOS &&
        controllers.service.serviceMode.value &&
        controllers.config.clashCoreTunEnable.value &&
        controllers.config.clashCoreDns.isNotEmpty) {
      await MacSystemDns.instance.set([]);
    }
    if (controllers.config.config.value.setSystemProxy) await SystemProxy.instance.set(SystemProxyConfig());
    await fetchStop();
    coreStatus.value = RunningState.stoped;
  }

  Future<void> reloadClashCore() async {
    BotToast.showText(text: '正在重启 Clash Core ……');
    await stopClashCore();
    await controllers.config.readClashCoreApi();
    await startClashCore();
    if (coreStatus.value == RunningState.error) {
      BotToast.showText(text: '重启失败');
    } else {
      await controllers.core.updateVersion();
      BotToast.showText(text: '重启成功');
    }
  }
}
