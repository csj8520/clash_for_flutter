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

  Future<void> startClashCore({bool? autoSetDns, bool? autoSetProxy}) async {
    await storeClashService.fetchStart(storeConfig.config.value.selected);
    // await storeConfig.readClashCoreApi();
    storeClashCore.setApi(storeConfig.clashCoreApiAddress.value, storeConfig.clashCoreApiSecret.value);
    await storeClashCore.waitCoreStart();
    if (Platform.isMacOS && autoSetDns != false) {
      if (storeConfig.clashCoreDns.isNotEmpty) {
        await MacSystemDns.instance.set([storeConfig.clashCoreDns.value]);
      } else {
        await MacSystemDns.instance.set([]);
      }
    }
    if (storeConfig.config.value.setSystemProxy && autoSetProxy != false) await SystemProxy.instance.set(storeClashCore.proxyConfig);
    await storeClashCore.fetchConfig();
  }

  Future<void> reloadClashCore() async {
    BotToast.showText(text: '正在重启 Clash Core ……');
    final oldDns = storeConfig.clashCoreDns.value;
    final oldProxy = storeClashCore.proxyConfig;
    await storeClashService.fetchStop();
    await storeConfig.readClashCoreApi();
    final newProxy = storeClashCore.proxyConfig;
    final autoSetDns = oldDns != storeConfig.clashCoreDns.value;
    final autoSetProxy = oldProxy.http != newProxy.http || oldProxy.https != newProxy.https || oldProxy.socks != newProxy.socks;
    await startClashCore(autoSetDns: autoSetDns, autoSetProxy: autoSetProxy);
    BotToast.showText(text: '重启成功');
  }
}
