import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';
import 'package:sentry_dio/sentry_dio.dart';

import 'package:clash_for_flutter/types/rule.dart';
import 'package:clash_for_flutter/types/proxie.dart';
import 'package:clash_for_flutter/types/connect.dart';
import 'package:clash_for_flutter/types/clash_core.dart';
import 'package:clash_for_flutter/utils/system_proxy.dart';

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

  CoreController() {
    dio.addSentry(captureFailedRequests: true);
  }

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

  setApi(String apiAddress, String apiSecret) {
    address.value = apiAddress;
    secret.value = apiSecret;
    dio.options.baseUrl = 'http://${address.value}';
    dio.options.headers['Authorization'] = 'Bearer ${secret.value}';
  }

  Future<dynamic> fetchHello() async {
    return await dio.get('/');
  }

  Future<void> updateVersion() async {
    final res = await dio.get('/version');
    version.value = ClashCoreVersion.fromJson(res.data);
  }

  Future<void> updateConfig() async {
    final res = await dio.get('/configs');
    config.value = ClashCoreConfig.fromJson(res.data);
  }

  Future<void> fetchConfigUpdate(Map<String, dynamic> config) async {
    await dio.patch('/configs', data: config);
    await updateConfig();
  }

  // type updateConfigRequest struct {
  // 	Path    string `json:"path"`
  // 	Payload string `json:"payload"`
  // }
  // https://github.com/Dreamacro/clash/blob/c231fd14666d6ea05d6a75eaba6db69f9eee5ae9/hub/route/configs.go#L95
  Future<void> fetchReloadConfig(Map<String, String> config) async {
    await dio.put('/configs', data: config);
  }

  Future<void> fetchCloseConnections(String id) async {
    await dio.delete('/connections/${Uri.encodeComponent(id)}');
  }

  IOWebSocketChannel fetchConnectionsWs() {
    return IOWebSocketChannel.connect(
      Uri.parse('ws://${address.value}/connections'),
      headers: {"Authorization": dio.options.headers["Authorization"]},
    );
  }

  Future updateRuleProvider() async {
    final res = await dio.get('/providers/rules');
    ruleProvider.value = RuleProvider.fromJson(res.data);
    ruleProvider.refresh();
  }

  Future updateRule() async {
    final res = await dio.get('/rules');
    rule.value = Rule.fromJson(res.data);
    rule.refresh();
  }

  Future<void> fetchRuleProviderUpdate(String name) async {
    await dio.put('/providers/rules/${Uri.encodeComponent(name)}');
  }

  Future<Proxie> fetchProxie() async {
    final res = await dio.get('/proxies');
    return Proxie.fromJson(res.data);
  }

  Future<ProxieProvider> fetchProxieProvider() async {
    final res = await dio.get('/providers/proxies');
    return ProxieProvider.fromJson(res.data);
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

  Future<int> fetchProxieDelay(String name) async {
    final query = {'timeout': 5000, 'url': 'http://www.gstatic.com/generate_204'};
    final res = await dio.get('/proxies/${Uri.encodeComponent(name)}/delay', queryParameters: query);
    return res.data['delay'] ?? 0;
  }

  Future<Connect> fetchConnection() async {
    final res = await dio.get('/connections');
    return Connect.fromJson(res.data);
  }
}
