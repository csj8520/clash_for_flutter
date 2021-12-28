import 'dart:io';

import 'package:process_run/process_run.dart' as run;
import 'package:path/path.dart' as path;

String getPath() {
  return path.canonicalize(path.absolute('assets/clash-windows-amd64.exe'));
}

class Event {
  final Map<String, List<Function>> _events = {};

  _on(String key, Function handle) {
    final handles = _events[key] ??= [];
    if (!handles.contains(handle)) handles.add(handle);
  }

  _emit(String key, dynamic arg) {
    final handles = _events[key];
    handles?.forEach((it) => it(arg));
  }

  _off(String key, Function handle) {
    final handles = _events[key];
    if (handles == null) return;
    handles.remove(handle);
    if (handles.isEmpty) _events.remove(key);
  }
}

class Logger extends Event {
  final Map<String, int> _timeMap = {};

  log(Object text,
      [Object? text2,
      Object? text3,
      Object? text4,
      Object? text5,
      Object? text6,
      Object? text7,
      Object? text8]) {
    String str = [text, text2, text3, text4, text5, text6, text7, text8]
        .where((e) => e != null)
        .join(' ');
    String log = '${DateTime.now().toString()} $str\n';
    stdout.write(log);
    _emit('log', log);
  }

  time(String text) {
    _timeMap[text] = DateTime.now().microsecondsSinceEpoch;
  }

  timeEnd(String text) {
    int now = DateTime.now().microsecondsSinceEpoch;
    int startTime = _timeMap[text] ?? now;
    _timeMap.remove(text);
    log('$text: ${(now - startTime) / 1000} ms');
  }

  on({void Function(String event)? onLog}) {
    if (onLog != null) _on('log', onLog);
  }

  off({void Function(String event)? onLog}) {
    if (onLog != null) _off('log', onLog);
  }
}

Logger log = Logger();
