import 'package:dio/dio.dart';

import 'package:clash_pro_for_flutter/types/index.dart';
import 'package:clash_pro_for_flutter/utils/index.dart';

Dio clashDio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:9090'));
Dio dio = Dio();

Future<bool> fetchClashHello() async {
  try {
    final res = await clashDio.get('/');
    log.debug(res.data);
    return res.data['hello'] == 'clash';
  } catch (e) {
    return false;
  }
}

Future<ClashVersion> fetchClashVersion() async {
  final res = await clashDio.get('/version');
  return ClashVersion.buildFromJson(res.data);
}

Future<dynamic> fetchClashProxies() async {
  final res = await clashDio.get('/proxies');
  return res.data;
}

Future<dynamic> fetchClashProvidersProxies() async {
  final res = await clashDio.get('/providers/proxies');
  return res.data;
}

Future<void> fetchClashProviderHealthCheck(String provider) async {
  await clashDio.get('/providers/proxies/${Uri.encodeComponent(provider)}/healthcheck');
}

// https://github.com/Dreamacro/clash/blob/cb95326aca85b89da6182d0f72ee215354f59cc2/hub/route/proxies.go#L41
// 仅支持 /proxies 接口返回的 proxy
Future<int> fetchProxyDelay(String name) async {
  try {
    final res = await clashDio.get('/proxies/${Uri.encodeComponent(name)}/delay', queryParameters: {
      'timeout': 5000,
      'url': 'http://www.gstatic.com/generate_204',
    });
    return res.data['delay'];
  } catch (e) {
    return 0;
  }
}

Future<void> fetchClashProxieSwitch({required String group, required String value}) async {
  await clashDio.put('/proxies/${Uri.encodeComponent(group)}', data: {'name': value});
}

Future<void> fetchClashProviderProxiesUpdate(String name) async {
  await clashDio.put('/providers/proxies/${Uri.encodeComponent(name)}');
}

Future<void> fetchClashProviderProxiesHealthCheck(String name) async {
  await clashDio.get('/providers/proxies/${Uri.encodeComponent(name)}/healthcheck');
}

Future<List<Rule>> fetchClashProviderRules() async {
  final res = await clashDio.get('/providers/rules');
  return (res.data['providers'] as Map<String, dynamic>).values.map((e) => Rule.buildFromJson(e)).toList();
}

Future<void> fetchClashProviderRulesUpdate(String name) async {
  await clashDio.put('/providers/rules/${Uri.encodeComponent(name)}');
}

Future<List<RuleRule>> fetchClashRules() async {
  final res = await clashDio.get('/rules');
  return (res.data['rules'] as List<dynamic>).map((e) => RuleRule.buildFromJson(e)).toList();
}

Future<Map<String, dynamic>> fetchClashConfig() async {
  return (await clashDio.get('/configs')).data;
}

Future<void> fetchClashConfigUpdate(Map<String, dynamic> config) async {
  await clashDio.patch('/configs', data: config);
}

Future<Map<String, dynamic>> fetchClashConnections() async {
  return (await clashDio.get('/connections')).data;
}

Future<void> fetchClashCloseConnection(String id) async {
  await clashDio.delete('/connections/${Uri.encodeComponent(id)}');
}
