import 'dart:math' as math;

import 'package:flutter/services.dart';

String bytesToSize(int bytes) {
  if (bytes == 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  final i = (math.log(bytes) / math.log(k)).floor();
  return '${(bytes / math.pow(k, i)).toStringAsFixed(2)} ${sizes[i]}';
}

final Map<String, Map<String, String>> _copyCommandLineProxyTypes = {
  'cmd': {'prefix': 'set ', 'quot': '', 'join': '&&'},
  'bash': {'prefix': 'export ', 'quot': '"', 'join': ' && '},
  'powershell': {'prefix': '\$env:', 'quot': '"', 'join': ';'},
};

Future<void> copyCommandLineProxy(String type, {String? http, String? https}) async {
  final types = _copyCommandLineProxyTypes[type];
  if (types == null) return;
  final prefix = types['prefix']!;
  final quot = types['quot']!;
  final join = types['join']!;
  List<String> commands = [];
  if (http != null) commands.add('${prefix}http_proxy=${quot}http://$http$quot');
  if (https != null) commands.add('${prefix}https_proxy=${quot}http://$https$quot');

  if (commands.isNotEmpty) await Clipboard.setData(ClipboardData(text: commands.join(join)));
}

extension OrNull<T> on T {
  T? orNull(bool a) {
    return a ? this : null;
  }
}

extension BindOne<T, R> on R Function(T a) {
  R Function() bindOne(T a) {
    return () => this(a);
  }
}

extension BindFirst<T, T2, R> on R Function(T a, T2 b) {
  R Function(T2 b) bindFirst(T a) {
    return (T2 b) => this(a, b);
  }
}

extension MapIndex<T> on List<T> {
  List<R> mapIndex<R>(R Function(int index, T item) fn) {
    final List<R> list = [];
    for (int idx = 0; idx < length; idx++) {
      list.add(fn(idx, this[idx]));
    }
    return list;
  }
}
