import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

import 'package:clash_for_flutter/const/const.dart';
import 'package:clash_for_flutter/utils/shell.dart';
import 'package:clash_for_flutter/types/clash_service.dart';

final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:9089', headers: {"User-Agent": "clash-for-flutter/0.0.1"}));

class StoreClashService with ChangeNotifier {
  bool serviceMode = false;
  Process? clashServiceProcess;

  Future init() async {
    try {
      final data = await fetchInfo();
      if (data.code == 0) {
        serviceMode = data.mode == 'service-mode';
      }
    } catch (e) {
      serviceMode = false;
      clashServiceProcess = await Process.start(Files.assetsClashService.path, ['user-mode']);
    }
    notifyListeners();
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

  Future install() async {
    final info = await fetchInfo();
    if (info.status == 'running') await fetchStop();
    if (clashServiceProcess != null) {
      clashServiceProcess?.kill();
      clashServiceProcess = null;
    } else if (kDebugMode) {
      await killProcess(path.basename(Files.assetsClashService.path));
    }
    await runAsAdmin(Files.assetsClashService.path, ["install", "start"]);
    await init();
  }

  Future uninstall() async {
    final info = await fetchInfo();
    if (info.status == 'running') await fetchStop();
    await runAsAdmin(Files.assetsClashService.path, ["stop", "uninstall"]);
    await init();
  }
}
