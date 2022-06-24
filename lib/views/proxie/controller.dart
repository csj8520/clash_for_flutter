import 'dart:async';

import 'package:get/get.dart';
import 'package:bot_toast/bot_toast.dart';

import 'package:clash_for_flutter/types/proxie.dart';
import 'package:clash_for_flutter/utils/logger.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';

class PageProxieController extends GetxController {
  // 策略组
  var proxieGroups = <ProxieProxiesItem>[].obs;
  // 代理集
  var proxieProviders = <ProxieProviderItem>[].obs;
  // 代理
  var proxieProxies = <ProxieProxiesItem>[].obs;
  // 所有节点
  var allProxies = <String, ProxieProxiesItem>{}.obs;

  final List<String> groupInternalTypes = ['DIRECT', 'REJECT', 'GLOBAL'];
  final List<String> groupTypes = [
    ProxieProxieType.selector,
    ProxieProxieType.urltest,
    ProxieProxieType.fallback,
    ProxieProxieType.loadbalance,
  ];

  Future<void> updateDate() async {
    log.debug('controller.proxie.updateDate()');

    await controllers.core.updateConfig();
    await _updateProxie();
    await _updateProxieProvider();
    allProxies.clear();
    for (final provide in proxieProviders) {
      for (final it in provide.proxies) {
        allProxies[it.name] = it;
      }
    }
    for (final it in proxieProxies) {
      allProxies[it.name] = it;
    }
    for (final it in proxieGroups) {
      allProxies[it.name] = it;
    }
    proxieGroups.refresh();
    proxieProxies.refresh();
    proxieProviders.refresh();
    allProxies.refresh();
  }

  Future<dynamic> _updateProxie() async {
    final proxie = await controllers.core.fetchProxie();
    final global = proxie.proxies["GLOBAL"]!;
    proxieGroups.value = global.all!
        .where((it) => !groupInternalTypes.contains(it) && groupTypes.contains(proxie.proxies[it]!.type))
        .map((it) => proxie.proxies[it]!)
        .toList();
    proxieProxies.value = global.all!
        .where((it) => !groupInternalTypes.contains(it) && !groupTypes.contains(proxie.proxies[it]!.type))
        .map((it) => proxie.proxies[it]!)
        .toList();
    if (controllers.core.config.value.mode == 'global') proxieGroups.insert(0, global);
  }

  Future<dynamic> _updateProxieProvider() async {
    proxieProviders.value = (await controllers.core.fetchProxieProvider()).providers.values.where((it) => it.vehicleType != 'Compatible').toList();
    for (final it in proxieProviders) {
      it.proxies.sort((a, b) {
        if (a.delay == 0) return 1;
        if (b.delay == 0) return -1;
        return a.delay - b.delay;
      });
    }
  }

  Future<void> updateProxieDelay() async {
    try {
      await Future.wait(proxieProxies.map((it) async {
        final delay = await controllers.core.fetchProxieDelay(it.name);
        it.history.add(ProxieProxiesItemHistory(delay: delay, time: DateTime.now().toString()));
        proxieProxies.refresh();
      }));
      await updateDate();
    } catch (_) {}
  }

  Future<void> handleSetProxieGroup(ProxieProxiesItem proxie, String value) async {
    if (proxie.now == value) return;
    await controllers.core.fetchSetProxieGroup(proxie.name, value);
    await updateDate();
    if (controllers.config.config.value.breakConnections) {
      final conn = await controllers.core.fetchConnection();
      for (final it in conn.connections) {
        if (it.chains.contains(proxie.name)) controllers.core.fetchCloseConnections(it.id);
      }
    }
  }

  Future<void> handleUpdateProvider(ProxieProviderItem provider) async {
    try {
      await controllers.core.fetchProxieProviderUpdate(provider.name);
      await updateDate();
    } catch (e) {
      BotToast.showText(text: 'Updata Error');
    }
  }

  Future<void> handleHealthCheckProvider(ProxieProviderItem provider) async {
    final timer = Timer.periodic(const Duration(seconds: 2), (_) => updateDate());
    try {
      await controllers.core.fetchProxieProviderHealthCheck(provider.name);
      await updateDate();
    } catch (e) {
      BotToast.showText(text: 'Health Check Error');
    }
    timer.cancel();
  }
}
