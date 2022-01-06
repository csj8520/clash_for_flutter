import 'package:clashf_pro/utils/utils.dart';
import 'package:dio/dio.dart';

Dio dio = Dio();

Future<bool> fetchClashHello() async {
  log.debug('fetchClashHello');
  try {
    final res = await dio.get('http://127.0.0.1:9090/');
    log.debug(res.data);
    return res.data['hello'] == 'clash';
  } catch (e) {
    return false;
  }
}

Future<ClashVersion> fetchClashVersion() async {
  final res = await dio.get('http://127.0.0.1:9090/version');
  return ClashVersion.buildFromJson(res.data);
}

Future<Proxies> fetchClashProxies() async {
  final groups = await dio.get('http://127.0.0.1:9090/proxies');
  final providers = await dio.get('http://127.0.0.1:9090/providers/proxies');
  return Proxies.buildFromJson(groups.data['proxies'], providers.data['providers']);
}
