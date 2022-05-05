import 'dart:io';
import 'package:get/get.dart';
import 'package:bot_toast/bot_toast.dart';

import 'package:clash_for_flutter/store/config.dart';
import 'package:clash_for_flutter/utils/system_dns.dart';
import 'package:clash_for_flutter/store/clash_core.dart';
import 'package:clash_for_flutter/utils/system_proxy.dart';
import 'package:clash_for_flutter/store/clash_service.dart';

class StoreSortcuts extends GetxController {
  late StoreConfig storeConfig;
  late StoreClashService storeClashService;
  late StoreClashCore storeClashCore;
  void init() {
    storeConfig = Get.find();
    storeClashService = Get.find();
    storeClashCore = Get.find();
  }

  Future<void> startClashCore() async {
    await storeClashService.fetchStart(storeConfig.config.value.selected);
    storeClashCore.setApi(storeConfig.clashCoreApiAddress.value, storeConfig.clashCoreApiSecret.value);
    await storeClashCore.waitCoreStart();
    if (Platform.isMacOS && storeConfig.clashCoreDns.isNotEmpty) await MacSystemDns.instance.set([storeConfig.clashCoreDns.value]);
    if (storeConfig.config.value.setSystemProxy) await SystemProxy.instance.set(storeClashCore.proxyConfig);
    await storeClashCore.fetchConfig();
  }

  Future<void> stopClashCore() async {
    if (Platform.isMacOS && storeConfig.clashCoreDns.isNotEmpty) await MacSystemDns.instance.set([]);
    if (storeConfig.config.value.setSystemProxy) await SystemProxy.instance.set(SystemProxyConfig());
    await storeClashService.fetchStop();
  }

  Future<void> reloadClashCore() async {
    BotToast.showText(text: '正在重启 Clash Core ……');
    await stopClashCore();
    await storeConfig.readClashCoreApi();
    await startClashCore();
    BotToast.showText(text: '重启成功');
  }
}
