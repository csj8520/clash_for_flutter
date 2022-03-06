import 'package:clash_for_flutter/src/utils/index.dart';
import 'package:dio/dio.dart';

Dio clashServiceDio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:9089', headers: {"User-Agent": "clash-for-flutter/0.0.1"}));

Future<Map<String, dynamic>> fetchClashServiceStatus() async {
  return (await clashServiceDio.post('/status')).data;
}

Future<dynamic> fetchClashServiceStart(Map<String, dynamic> data) async {
  log.debug(data);
  return (await clashServiceDio.post('/start', data: data)).data;
}

Future<dynamic> fetchClashServiceStop() async {
  return (await clashServiceDio.post('/stop')).data;
}
