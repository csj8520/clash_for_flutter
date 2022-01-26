import 'package:clash_pro_for_flutter/src/fetch/index.dart';
import 'package:clash_pro_for_flutter/src/types/index.dart';
import 'package:mobx/mobx.dart';

part 'proxies.g.dart';

class ProxiesStore = _ProxiesStore with _$ProxiesStore;

abstract class _ProxiesStore with Store {
  @observable
  ProxiesProxyGroup? global;
  @observable
  List<ProxiesProxyGroup> groups = [];
  @observable
  List<ProxiesProxie> proxies = [];

  @observable
  List<ProxiesProviders> providers = [];

  @computed
  Map<String, ProxiesProxie> get allProxies {
    Map<String, ProxiesProxie> allProxies = {};
    for (var it in providers) {
      for (var el in it.proxies) {
        allProxies[el.name] = el;
      }
    }
    for (var it in proxies) {
      allProxies[it.name] = it;
    }
    return allProxies;
  }

  @computed
  List<String> get timeoutProxies => allProxies.values.where((value) => value.delay == 0).map((e) => e.name).toList();

  final List<String> _groupNames = [
    ProxiesProxyGroupType.selector,
    ProxiesProxyGroupType.urltest,
    ProxiesProxyGroupType.fallback,
    ProxiesProxyGroupType.loadbalance,
  ];
  final List<String> _excludeNames = ['DIRECT', 'REJECT', 'GLOBAL'];

  @action
  Future<void> update() async {
    await updateGroup();
    await updateProviders();
  }

  @action
  Future<void> updateGroup() async {
    final data = await fetchClashProxies();
    final list = data['proxies'];
    global = ProxiesProxyGroup.buildFromJson(list['GLOBAL']!);
    groups = global!.all
        .where((it) => !_excludeNames.contains(it) && _groupNames.contains(list[it]['type']))
        .map((e) => ProxiesProxyGroup.buildFromJson(list[e]!))
        .toList();
    proxies = global!.all
        .where((it) => !_excludeNames.contains(it) && !_groupNames.contains(list[it]['type']))
        .map((e) => ProxiesProxie.buildFromJson(list[e]!))
        .toList();
  }

  @action
  Future<void> updateProviders() async {
    final data = await fetchClashProvidersProxies();
    final list = data['providers'];
    providers = (list as Map<String, dynamic>)
        .values
        .where((it) => it['vehicleType'] != 'Compatible')
        .map((it) => ProxiesProviders.buildFromJson(it).sortProxies())
        .toList();
  }

  @action
  Future<void> setProxieGroup(String group, String value) async {
    await fetchClashProxieSwitch(group: group, value: value);
    await updateGroup();
  }
}
