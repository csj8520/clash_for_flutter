import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import 'package:clash_for_flutter/utils/logger.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';

class WindowController extends GetxController with WindowListener {
  void initWindow() {
    windowManager.addListener(this);
  }

  @override
  Future<void> onWindowFocus() async {
    log.debug('onWindowFocus');
    await controllers.core.fetchConfig();
    await controllers.pageProxie.updateProxie();
  }

  @override
  Future<void> onWindowClose() async {
    log.debug('onWindowClose');
    controllers.service.closeLog();
    controllers.service.logs.clear();
    controllers.pageConnection.closeWs();
    // await controllers.tray.updateTray();
  }

  Future<void> onWindowShow() async {
    log.debug('onWindowShow');
    if (controllers.service.wsChannelLogs == null) controllers.service.initLog();
    if (controllers.pageHome.pageController.page == 3 && controllers.pageConnection.connectChannel == null) {
      controllers.pageConnection.initWs();
    }
    // await controllers.tray.updateTray();
  }

  Future<void> closeWindow() async {
    log.debug('closeWindow');
    await windowManager.close();
  }

  Future<void> showWindow() async {
    log.debug('showWindow');
    await windowManager.show();
    await onWindowShow();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }
}
