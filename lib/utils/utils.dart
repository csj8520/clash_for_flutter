import 'dart:math' as math;

import 'package:flutter/services.dart';

String bytesToSize(int bytes) {
  if (bytes == 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  final i = (math.log(bytes) / math.log(k)).floor();
  return (bytes / math.pow(k, i)).toStringAsFixed(2) + ' ' + sizes[i];
}

Future<void> copyCommandLineProxy(String type, {String? http, String? https}) async {
  final Map<String, Map<String, String>> types = {
    'cmd': {'prefix': 'set ', 'quot': '', 'join': '&&'},
    'bash': {'prefix': 'export ', 'quot': '"', 'join': ' && '},
    'powershell': {'prefix': '\$env:', 'quot': '"', 'join': ';'},
  };
  final _types = types[type];
  if (_types == null) return;
  final prefix = _types['prefix']!;
  final quot = _types['quot']!;
  final join = _types['join']!;
  List<String> commands = [];
  if (http != null) commands.add('${prefix}http_proxy=${quot}http://$http$quot');
  if (https != null) commands.add('${prefix}https_proxy=${quot}http://$https$quot');

  if (commands.isNotEmpty) await Clipboard.setData(ClipboardData(text: commands.join(join)));
}
