import 'dart:io';

import 'package:clash_for_flutter/utils/utils.dart';
import 'package:flutter/widgets.dart' hide MenuItem;

import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';
import 'package:clash_for_flutter/utils/base_page_controller.dart';

class PageMainController extends BasePageController {
  late BuildContext context;

  Future<void> init(BuildContext context) async {
    this.context = context;
    watchExit();

    // init plugins
    await controllers.tray.initTray();
    controllers.window.initWindow();
    controllers.protocol.initProtocol();

    // init config
    await controllers.config.initConfig();
    final language = controllers.config.config.value.language.split('_');
    await controllers.pageSetting.applyLanguage(Locale(language[0], language[1]));

    // init service
    await controllers.service.startService();
    if (controllers.service.serviceStatus.value != RunningState.running) return;

    // init clash core
    await controllers.service.startClashCore();
    if (controllers.service.coreStatus.value != RunningState.running) return;
    await controllers.core.updateVersion();
    // await controllers.pageProxie.updateDate();

    initRegularlyUpdate();
  }

  void watchExit() {
    // watch process kill
    // ref https://github.com/dart-lang/sdk/issues/12170
    if (Platform.isMacOS) {
      // windows not support https://github.com/dart-lang/sdk/issues/28603
      // for macos 任务管理器退出进程
      ProcessSignal.sigterm.watch().listen((_) {
        stdout.writeln('exit: sigterm');
        handleExit();
      });
    }
    // for macos, windows ctrl+c
    ProcessSignal.sigint.watch().listen((_) {
      stdout.writeln('exit: sigint');
      handleExit();
    });
  }

  void initRegularlyUpdate() {
    Future.delayed(const Duration(minutes: 5)).then((_) async {
      for (final it in controllers.config.config.value.subs) {
        try {
          if (it.url == null || it.url!.isEmpty) continue;
          if (((DateTime.now().millisecondsSinceEpoch ~/ 1000) - (it.updateTime ?? 0)) < controllers.config.config.value.updateInterval) continue;
          final chenged = await controllers.config.updateSub(it);
          if (!chenged) continue;
          if (it.name != controllers.config.config.value.selected) continue;
          // restart clash core
          await controllers.service.reloadClashCore();
          await Future.delayed(const Duration(seconds: 20));
        } catch (_) {}
      }
      initRegularlyUpdate();
    });
  }

  Future<void> handleExit() async {
    await controllers.service.stopService();
    await trayManager.destroy();
    await windowManager.destroy();
    // exit(0);
  }

  @override
  void dispose() {
    controllers.tray.dispose();
    controllers.window.dispose();
    controllers.protocol.dispose();
    super.dispose();
  }
}
