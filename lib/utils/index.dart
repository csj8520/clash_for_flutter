import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';

import 'logger.dart';

export 'logger.dart';
export 'const.dart';
export 'them.dart';
export 'events.dart';
export 'event.dart';
export 'clash.dart';
export 'system_proxy.dart';

Logger log = Logger();

String bytesToSize(int bytes) {
  if (bytes == 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  final i = (math.log(bytes) / math.log(k)).floor();
  return (bytes / math.pow(k, i)).toStringAsFixed(2) + ' ' + sizes[i];
}

Future<void> showItemInFolder(String path) async {
  if (Platform.isWindows) {
    await Process.run('explorer.exe', [path]);
  } else if (Platform.isMacOS) {
    await Process.run('open', [path]);
  } else {
    // TODO
  }
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
  if (http != null) commands.add('${prefix}http_proxy=${quot}http://$http${quot}');
  if (https != null) commands.add('${prefix}https_proxy=${quot}http://$https${quot}');

  if (commands.isNotEmpty) await Clipboard.setData(ClipboardData(text: commands.join(join)));
}

dynamic getValue(Map<String, dynamic> json, String? key) {
  if (key == null) return json;
  if (key.isEmpty) return json;
  final List<dynamic> keys = key.split('.');
  return [json, ...keys].reduce((value, key) => value[key]);
}

extension Get on Map {
  dynamic get(String? key) {
    if (key == null) return this;
    if (key.isEmpty) return this;
    final List<dynamic> keys = key.split('.');
    return [this, ...keys].reduce((value, key) => value[key]);
  }
}
