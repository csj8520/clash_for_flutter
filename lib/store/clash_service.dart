import 'dart:io';

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

final headers = {"User-Agent": "clash-for-flutter/0.0.1"};

final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:9089', headers: headers));

class StoreClashService extends GetxController {
  var serviceMode = false.obs;
  Process? clashServiceProcess;

  IOWebSocketChannel? wsChannelLogs;
  RxList<ClashServiceLog> logs = <ClashServiceLog>[].obs;

  Future init() async {
    try {
      final data = await fetchInfo();
      serviceMode.value = data.mode == 'service-mode';
    } catch (e) {
      await startService();
    }
    initLog();
  }

  initLog() {
    wsChannelLogs = IOWebSocketChannel.connect(Uri.parse('ws://127.0.0.1:9089/logs'), headers: headers);
    wsChannelLogs!.stream.listen((event) {
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

  Future _startService() async {
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

  Future startService() async {
    serviceMode.value = false;
    await _startService();
    await _waitServiceStart();
  }

  // for macos
  Future _waitServiceStart() async {
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
  Future _waitServiceStop() async {
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

  Future fetchStart(String name) async {
    final data = await fetchInfo();
    if (data.status == 'running') await fetchStop();
    await dio.post('/start', data: {
      "args": ['-d', Paths.config.path, '-f', path.join(Paths.config.path, name)]
    });
  }

  Future fetchStop() async {
    await dio.post('/stop');
  }

  Future exit() async {
    wsChannelLogs?.sink.close();
    wsChannelLogs = null;
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

  Future install() async {
    await exit();
    final res = await runAsAdmin(Files.assetsClashService.path, ["install", "start"]);
    log.debug('install', res.stdout);
    await _waitServiceStart();
  }

  Future uninstall() async {
    await exit();
    final res = await runAsAdmin(Files.assetsClashService.path, ["stop", "uninstall"]);
    log.debug('uninstall', res.stdout);
    await _waitServiceStop();
  }
}
