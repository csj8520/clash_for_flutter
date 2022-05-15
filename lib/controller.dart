import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/widgets.dart' hide MenuItem;

import 'package:clash_for_flutter/controllers/controllers.dart';
import 'package:window_manager/window_manager.dart';

class PageMainController extends GetxController {
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
    await controllers.service.initService();
    final visible = await windowManager.isVisible();
    if (visible) controllers.service.initLog();

    // init clash core
    await controllers.shortcuts.startClashCore();
    await controllers.core.fetchVersion();
    await controllers.pageProxie.updateProxie();

    initRegularlyUpdate();
  }

  void watchExit() {
    // watch process kill
    // ref https://github.com/dart-lang/sdk/issues/12170
    // TODO: test windows
    // for macos 任务管理器退出进程
    ProcessSignal.sigterm.watch().listen((_) {
      stdout.writeln('exit: sigterm');
      controllers.shortcuts.handleExit();
    });
    // for macos ctrl+c
    ProcessSignal.sigint.watch().listen((_) {
      stdout.writeln('exit: sigint');
      controllers.shortcuts.handleExit();
    });
  }

  void initRegularlyUpdate() {
    Future.delayed(const Duration(minutes: 5)).then((_) async {
      initRegularlyUpdate();
      for (final it in controllers.config.config.value.subs) {
        try {
          if (it.url == null || it.url!.isEmpty) continue;
          if (((DateTime.now().millisecondsSinceEpoch ~/ 1000) - (it.updateTime ?? 0)) < controllers.config.config.value.updateInterval) continue;
          final chenged = await controllers.config.updateSub(it);
          if (!chenged) continue;
          if (it.name != controllers.config.config.value.selected) continue;
          // restart clash core
          await controllers.shortcuts.reloadClashCore();
          await Future.delayed(const Duration(seconds: 20));
        } catch (_) {}
      }
    });
  }

  @override
  void dispose() {
    controllers.tray.dispose();
    controllers.window.dispose();
    controllers.protocol.dispose();
    super.dispose();
  }
}
