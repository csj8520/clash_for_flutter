import 'dart:io';

import 'package:clash_for_flutter/store/clash_core.dart';
import 'package:clash_for_flutter/store/clash_service.dart';
import 'package:clash_for_flutter/store/config.dart';
import 'package:clash_for_flutter/utils/system_proxy.dart';
import 'package:clash_for_flutter/utils/utils.dart';
import 'package:get/get.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class StoreTray extends GetxController with TrayListener {
  Future<void> init() async {
    await TrayManager.instance.setIcon('assets/logo/logo.ico');
    List<MenuItem> items = [
      MenuItem(
        key: 'show',
        title: '显示',
      ),
      MenuItem(
        key: 'hide',
        title: '隐藏',
      ),
      MenuItem.separator,
      MenuItem(
        key: 'restart-clash-core',
        title: '重启 Clash Core',
      ),
      MenuItem(
        title: '复制命令行代理',
        items: [
          MenuItem(key: 'copy-command-line', title: 'bash'),
          MenuItem(key: 'copy-command-line', title: 'cmd'),
          MenuItem(key: 'copy-command-line', title: 'powershell'),
        ],
      ),
      MenuItem(
        key: 'exit',
        title: '退出',
      ),
    ];
    await TrayManager.instance.setContextMenu(items);
    TrayManager.instance.addListener(this);
  }

  @override
  void onTrayIconMouseDown() {
    if (Platform.isWindows) {
      WindowManager.instance.show();
    } else {
      onTrayIconRightMouseDown();
    }
  }

  @override
  void onTrayIconRightMouseDown() {
    TrayManager.instance.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    final StoreClashService storeClashService = Get.find();
    final StoreConfig storeConfig = Get.find();
    final StoreClashCore storeClashCore = Get.find();

    super.onTrayMenuItemClick(menuItem);
    if (menuItem.key == 'show') {
      await WindowManager.instance.show();
      storeConfig.config.refresh();
    } else if (menuItem.key == 'hide') {
      await WindowManager.instance.hide();
    } else if (menuItem.key == 'restart-clash-core') {
      await storeClashService.fetchStop();
      await storeClashService.fetchStart(storeConfig.config.value.selected);
    } else if (menuItem.key == 'copy-command-line') {
      final proxyConfig = storeClashCore.proxyConfig;
      await copyCommandLineProxy(menuItem.title!, http: proxyConfig.http, https: proxyConfig.https);
    } else if (menuItem.key == 'exit') {
      await storeClashService.exit();
      await SystemProxy.instance.set(SystemProxyConfig());
      // TODO: mac unset dns
      exit(0);
    }
  }
}
