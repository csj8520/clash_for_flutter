import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';

import 'package:clash_for_flutter/types/rule.dart';
import 'package:clash_for_flutter/types/proxie.dart';
import 'package:clash_for_flutter/types/connect.dart';
import 'package:clash_for_flutter/types/clash_core.dart';
import 'package:clash_for_flutter/utils/system_proxy.dart';

final List<String> _groupExcludeNames = ['DIRECT', 'REJECT', 'GLOBAL'];
final List<String> _groupNames = [
  ProxieProxieType.selector,
  ProxieProxieType.urltest,
  ProxieProxieType.fallback,
  ProxieProxieType.loadbalance,
];

class CoreController extends GetxController {
  final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:9090'));
  var version = ClashCoreVersion(premium: true, version: '').obs;
  var address = ''.obs;
  var secret = ''.obs;
  var config = ClashCoreConfig(
    port: 0,
    socksPort: 0,
    redirPort: 0,
    tproxyPort: 0,
    mixedPort: 0,
    authentication: [],
    allowLan: false,
    bindAddress: '',
    mode: '',
    logLevel: '',
    ipv6: false,
  ).obs;

  var ruleProvider = RuleProvider(providers: {}).obs;
  var rule = Rule(rules: []).obs;
  // var proxie = Proxie(proxies: {}).obs;
  var proxieProviders = <ProxieProviderItem>[].obs;
  var proxieGroups = <ProxieProxiesItem>[].obs;
  var proxieProxies = <ProxieProxiesItem>[].obs;

  SystemProxyConfig get proxyConfig {
    final mixedPort = config.value.mixedPort == 0 ? null : config.value.mixedPort;
    final httpPort = mixedPort ?? config.value.port;
    final httpsPort = mixedPort ?? config.value.port;
    final socksPort = mixedPort ?? config.value.socksPort;
    return SystemProxyConfig(
      http: httpPort == 0 ? null : '127.0.0.1:$httpPort',
      https: httpsPort == 0 ? null : '127.0.0.1:$httpsPort',
      socks: socksPort == 0 ? null : '127.0.0.1:$socksPort',
    );
  }

  Future<void> waitCoreStart() async {
    while (true) {
      final hello = await fetchHello();
      if (hello) return;
    }
  }

  setApi(String apiAddress, String apiSecret) {
    address.value = apiAddress;
    secret.value = apiSecret;
    dio.options.baseUrl = 'http://$apiAddress';
    if (apiSecret.isNotEmpty) dio.options.headers['Authorization'] = 'Bearer $apiSecret';
  }

  Future<bool> fetchHello() async {
    try {
      final res = await dio.get('/');
      return res.data['hello'] == 'clash';
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchVersion() async {
    final res = await dio.get('/version');
    version.value = ClashCoreVersion.fromJson(res.data);
  }

  Future<void> fetchConfig() async {
    final res = await dio.get('/configs');
    config.value = ClashCoreConfig.fromJson(res.data);
  }

  Future<void> fetchConfigUpdate(Map<String, dynamic> config) async {
    await dio.patch('/configs', data: config);
    await fetchConfig();
  }

  Future<void> fetchCloseConnection(String id) async {
    await dio.delete('/connections/${Uri.encodeComponent(id)}');
  }

  IOWebSocketChannel fetchConnectionWs() {
    return IOWebSocketChannel.connect(Uri.parse('ws://${address.value}/connections?token=${secret.value}'));
  }

  Future fetchRuleProvider() async {
    final res = await dio.get('/providers/rules');
    ruleProvider.value = RuleProvider.fromJson(res.data);
    ruleProvider.refresh();
  }

  Future fetchRule() async {
    final res = await dio.get('/rules');
    rule.value = Rule.fromJson(res.data);
    rule.refresh();
  }

  Future<void> fetchRuleProviderUpdate(String name) async {
    await dio.put('/providers/rules/${Uri.encodeComponent(name)}');
  }

  Future<dynamic> fetchProxie() async {
    final res = await dio.get('/proxies');
    final proxie = Proxie.fromJson(res.data);
    final global = proxie.proxies["GLOBAL"]!;
    proxieGroups.value = global.all!
        .where((it) => !_groupExcludeNames.contains(it) && _groupNames.contains(proxie.proxies[it]!.type))
        .map((it) => proxie.proxies[it]!)
        .toList();
    proxieProxies.value = global.all!
        .where((it) => !_groupExcludeNames.contains(it) && !_groupNames.contains(proxie.proxies[it]!.type))
        .map((it) => proxie.proxies[it]!)
        .toList();
    if (config.value.mode == 'global') proxieGroups.insert(0, global);
    proxieGroups.refresh();
    proxieProxies.refresh();
  }

  Future<dynamic> fetchProxieProvider() async {
    final res = await dio.get('/providers/proxies');
    proxieProviders.value = ProxieProvider.fromJson(res.data).providers.values.where((it) => it.vehicleType != 'Compatible').toList();
    for (final it in proxieProviders) {
      it.proxies.sort((a, b) {
        if (a.delay == 0) return 1;
        if (b.delay == 0) return -1;
        return a.delay - b.delay;
      });
    }
    proxieProviders.refresh();
  }

  Future<void> fetchProxieProviderHealthCheck(String provider) async {
    await dio.get('/providers/proxies/${Uri.encodeComponent(provider)}/healthcheck');
  }

  Future<void> fetchSetProxieGroup(String group, String value) async {
    await dio.put('/proxies/${Uri.encodeComponent(group)}', data: {'name': value});
  }

  Future<void> fetchProxieProviderUpdate(String name) async {
    await dio.put('/providers/proxies/${Uri.encodeComponent(name)}');
  }

  Future<void> fetchProxieDelay() async {
    try {
      await Future.wait(proxieProxies.map((it) async {
        final res = await dio.get(
          '/proxies/${Uri.encodeComponent(it.name)}/delay',
          queryParameters: {'timeout': 5000, 'url': 'http://www.gstatic.com/generate_204'},
        );
        it.history.add(ProxieProxiesItemHistory(delay: res.data['delay'] ?? 0, time: DateTime.now().toString()));
        proxieProxies.refresh();
      }));
    } catch (_) {}
  }

  Future<Connect> fetchConnection() async {
    final res = await dio.get('/connections');
    return Connect.fromJson(res.data);
  }
}
