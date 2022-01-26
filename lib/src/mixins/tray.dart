import 'dart:io';

import 'package:clash_pro_for_flutter/src/store/index.dart';
import 'package:clash_pro_for_flutter/src/utils/index.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

mixin TrayMixin on TrayListener {
  Future<void> initTray() async {
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
    log.debug('Tray Click: onTrayIconMouseDown');
    super.onTrayIconMouseDown();
    if (Platform.isWindows) {
      WindowManager.instance.show();
    } else {
      onTrayIconRightMouseDown();
    }
  }

  @override
  void onTrayIconRightMouseDown() {
    log.debug('Tray Click: onTrayIconRightMouseDown');
    super.onTrayIconRightMouseDown();
    TrayManager.instance.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    log.debug('Menu Item Click: ', menuItem.title, menuItem.key);
    super.onTrayMenuItemClick(menuItem);
    if (menuItem.key == 'show') {
      WindowManager.instance.show();
      // if (Platform.isMacOS) await windowManager.setSkipTaskbar(false);
    } else if (menuItem.key == 'hide') {
      WindowManager.instance.hide();
      // if (Platform.isMacOS) await windowManager.setSkipTaskbar(true);
    } else if (menuItem.key == 'restart-clash-core') {
      await globalStore.restartClash();
    } else if (menuItem.key == 'copy-command-line') {
      final proxyConfig = globalStore.proxyConfig;
      await copyCommandLineProxy(menuItem.title!, http: proxyConfig.http.server, https: proxyConfig.https.server);
    } else if (menuItem.key == 'exit') {
      await globalStore.setProxy(false);
      clash?.kill();
      exit(0);
    }
  }
}
