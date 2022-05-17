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
    log.debug('call: onWindowFocus');
    await handleUpdateData();
  }

  @override
  void onWindowClose() async {
    log.debug('call: onWindowClose');
    await handleWindowHide();
  }

  @override
  void onWindowMinimize() async {
    log.debug('call: onWindowMinimize');
    await handleWindowHide();
  }

  @override
  void onWindowRestore() async {
    log.debug('call: onWindowRestore');
    await handleWindowShow();
  }

  Future<void> handleWindowShow() async {
    log.debug('call: handleWindowShow');
    await controllers.pageMain.initDate();
    await controllers.pageProxie.initDate();
    await controllers.pageLog.initDate();
    await controllers.pageRule.initDate();
    await controllers.pageConnection.initDate();
    await controllers.pageProfile.initDate();
    await controllers.pageSetting.initDate();
  }

  Future<void> handleUpdateData() async {
    log.debug('call: handleUpdateData');
    await controllers.pageMain.updateDate();
    await controllers.pageProxie.updateDate();
    await controllers.pageLog.updateDate();
    await controllers.pageRule.updateDate();
    await controllers.pageConnection.updateDate();
    await controllers.pageProfile.updateDate();
    await controllers.pageSetting.updateDate();
  }

  Future<void> handleWindowHide() async {
    log.debug('call: handleWindowHide');
    await controllers.pageMain.clearDate();
    await controllers.pageProxie.clearDate();
    await controllers.pageLog.clearDate();
    await controllers.pageRule.clearDate();
    await controllers.pageConnection.clearDate();
    await controllers.pageProfile.clearDate();
    await controllers.pageSetting.clearDate();
  }

  Future<void> closeWindow() async {
    log.debug('call: closeWindow');
    await windowManager.close();
  }

  Future<void> showWindow() async {
    log.debug('call: showWindow');
    await windowManager.show();
    await handleWindowShow();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }
}
