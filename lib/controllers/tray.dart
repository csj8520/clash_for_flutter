import 'package:get/get.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

import 'package:clash_for_flutter/utils/utils.dart';
import 'package:clash_for_flutter/types/proxie.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';

class TrayController extends GetxController with TrayListener {
  late Menu trayMenu;

  var show = false.obs;

  Future<void> initTray() async {
    await trayManager.setIcon('assets/logo/logo.ico');
    // await trayManager.setTitle('Clash For Flutter');
    updateTray();
    trayManager.addListener(this);
  }

  Future<void> updateTray() async {
    final visible = await windowManager.isVisible();
    final disabled = !controllers.service.isRunning;

    trayMenu = Menu(items: [
      MenuItem.checkbox(label: 'tray_show'.tr, checked: visible, onClick: handleClickShow),
      MenuItem.separator(),
      MenuItem.submenu(
        label: 'proxie_group_title'.tr,
        disabled: disabled,
        submenu: Menu(
            items: controllers.pageProxie.proxieGroups
                .map((it) => MenuItem.submenu(
                      label: it.name,
                      submenu: Menu(
                        items: (it.all ?? [])
                            .map((t) => MenuItem.checkbox(
                                  label: t,
                                  checked: t == it.now,
                                  disabled: it.type != 'Selector',
                                  onClick: (m) => handleClickProxieItem(it, m),
                                ))
                            .toList(),
                      ),
                    ))
                .toList()),
      ),
      MenuItem(
        label: 'tray_restart_clash_core'.tr,
        disabled: !controllers.service.isCanOperationCore,
        onClick: handleClickRestartClashCore,
      ),
      MenuItem.checkbox(
        label: 'setting_set_as_system_proxy'.tr,
        checked: controllers.config.config.value.setSystemProxy,
        disabled: disabled || controllers.pageSetting.systemProxySwitchIng.value,
        onClick: handleClickSetAsSystemProxy,
      ),
      MenuItem.checkbox(
        label: 'setting_service_open'.tr,
        checked: controllers.service.serviceMode.value,
        disabled: !controllers.service.isCanOperationService,
        onClick: handleClickServiceModeSwitch,
      ),
      MenuItem.submenu(
          label: 'tray_copy_command_line_proxy'.tr,
          disabled: disabled,
          submenu: Menu(items: [
            MenuItem(label: 'bash', onClick: handleClickCopyCommandLineProxy),
            MenuItem(label: 'cmd', onClick: handleClickCopyCommandLineProxy),
            MenuItem(label: 'powershell', onClick: handleClickCopyCommandLineProxy),
          ])),
      MenuItem.separator(),
      MenuItem(label: 'tray_about'.tr, onClick: handleClickAbout),
      MenuItem(label: 'tray_exit'.tr, onClick: handleClickExit),
    ]);
    await trayManager.setContextMenu(trayMenu);
  }

  @override
  void onTrayIconMouseDown() async {
    await controllers.window.showWindow();
  }

  @override
  void onTrayIconRightMouseDown() async {
    show.value = true;
    await updateTray();
    await trayManager.popUpContextMenu();
    show.value = false;
  }

  Future<void> handleClickShow(MenuItem menuItem) async {
    show.value = false;
    if (menuItem.checked == true) {
      await controllers.window.closeWindow();
    } else {
      await controllers.window.showWindow();
    }
  }

  Future<void> handleClickProxieItem(ProxieProxiesItem proxie, MenuItem menuItem) async {
    await controllers.pageProxie.handleSetProxieGroup(proxie, menuItem.label!);
  }

  Future<void> handleClickSetAsSystemProxy(MenuItem menuItem) async {
    await controllers.pageSetting.systemProxySwitch(menuItem.checked != true);
  }

  Future<void> handleClickCopyCommandLineProxy(MenuItem menuItem) async {
    final title = menuItem.label!;
    final proxyConfig = controllers.core.proxyConfig;
    await copyCommandLineProxy(title, http: proxyConfig.http, https: proxyConfig.https);
  }

  Future<void> handleClickAbout(MenuItem menuItem) async {
    await launchUrl(Uri.parse('https://github.com/csj8520/clash_for_flutter'));
  }

  Future<void> handleClickExit(MenuItem menuItem) async {
    await controllers.pageMain.handleExit();
  }

  Future<void> handleClickRestartClashCore(MenuItem menuItem) async {
    await controllers.service.reloadClashCore();
  }

  Future<void> handleClickServiceModeSwitch(MenuItem menuItem) async {
    await controllers.service.serviceModeSwitch(menuItem.checked != true);
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    super.dispose();
  }
}
