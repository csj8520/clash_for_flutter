import 'package:clashf_pro/utils/utils.dart';
import 'package:dio/dio.dart';

Dio dio = Dio();

Future<ClashVersion> fetchClashVersion() async {
  final res = await dio.get('http://127.0.0.1:9090/version');
  return ClashVersion(premium: res.data['premium'], version: res.data['version']);
}
