import 'dart:io';
import 'package:get/get.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'package:clash_for_flutter/utils/system_dns.dart';
import 'package:clash_for_flutter/utils/system_proxy.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';

class ShortcutsController extends GetxController {
  Future<void> startClashCore() async {
    await controllers.service.fetchStart(controllers.config.config.value.selected);
    controllers.core.setApi(controllers.config.clashCoreApiAddress.value, controllers.config.clashCoreApiSecret.value);
    await controllers.core.waitCoreStart();
    if (Platform.isMacOS && controllers.config.clashCoreDns.isNotEmpty) {
      await MacSystemDns.instance.set([controllers.config.clashCoreDns.value]);
    }
    if (controllers.config.config.value.setSystemProxy) await SystemProxy.instance.set(controllers.core.proxyConfig);
    await controllers.core.fetchConfig();
  }

  Future<void> stopClashCore() async {
    if (Platform.isMacOS && controllers.config.clashCoreDns.isNotEmpty) await MacSystemDns.instance.set([]);
    if (controllers.config.config.value.setSystemProxy) await SystemProxy.instance.set(SystemProxyConfig());
    await controllers.service.fetchStop();
  }

  Future<void> reloadClashCore() async {
    BotToast.showText(text: '正在重启 Clash Core ……');
    await stopClashCore();
    await controllers.config.readClashCoreApi();
    await startClashCore();
    BotToast.showText(text: '重启成功');
  }

  Future<void> handleExit() async {
    await controllers.service.exit();
    if (Platform.isMacOS && controllers.config.clashCoreDns.isNotEmpty) await MacSystemDns.instance.set([]);
    if (controllers.config.config.value.setSystemProxy) await SystemProxy.instance.set(SystemProxyConfig());
    trayManager.destroy();
    windowManager.destroy();
    exit(0);
  }
}
