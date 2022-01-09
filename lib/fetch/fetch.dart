import 'package:clashf_pro/utils/utils.dart';
import 'package:dio/dio.dart';

Dio dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:9090'));

Future<bool> fetchClashHello() async {
  log.debug('fetchClashHello');
  try {
    final res = await dio.get('/');
    log.debug(res.data);
    return res.data['hello'] == 'clash';
  } catch (e) {
    return false;
  }
}

Future<ClashVersion> fetchClashVersion() async {
  final res = await dio.get('/version');
  return ClashVersion.buildFromJson(res.data);
}

Future<Proxies> fetchClashProxies() async {
  final groups = await dio.get('/proxies');
  final providers = await dio.get('/providers/proxies');
  return Proxies.buildFromJson(groups.data['proxies'], providers.data['providers']);
}

Future<void> fetchClashProviderHealthCheck(String provider) async {
  await dio.get('/providers/proxies/${Uri.encodeComponent(provider)}/healthcheck');
}

// https://github.com/Dreamacro/clash/blob/cb95326aca85b89da6182d0f72ee215354f59cc2/hub/route/proxies.go#L41
// 仅支持 /proxies 接口返回的 proxy
Future<int> fetchProxyDelay(String name) async {
  try {
    final res = await dio.get('/proxies/${Uri.encodeComponent(name)}/delay', queryParameters: {
      'timeout': 5000,
      'url': 'http://www.gstatic.com/generate_204',
    });
    return res.data['delay'];
  } catch (e) {
    return 0;
  }
}

// http://127.0.0.1:9090/proxies/🔰 节点选择

Future<void> fetchClashProxieSwitch({required String group, required String value}) async {
  await dio.put('/proxies/${Uri.encodeComponent(group)}', data: {'name': value});
}
