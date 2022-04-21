import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:clash_for_flutter/types/clash_core.dart';

final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:9090'));

class StoreClashCore with ChangeNotifier {
  Future waitStart() async {
    while (true) {
      final hello = await fetchHello();
      if (hello) return;
    }
  }

  setApi(String address, String secret) {
    dio.options.baseUrl = 'http://$address';
    if (secret.isNotEmpty) dio.options.headers['Authorization'] = 'Bearer $secret';
  }

  Future<bool> fetchHello() async {
    try {
      final res = await dio.get('/');
      return res.data['hello'] == 'clash';
    } catch (e) {
      return false;
    }
  }

  Future<ClashCoreVersion> fetchVersion() async {
    final res = await dio.get('/version');
    return ClashCoreVersion.fromJson(res.data);
  }
}
