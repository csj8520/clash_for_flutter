import 'dart:io';

import 'package:clashf_pro/utils/index.dart';

class Logger {
  final Map<String, int> _timeMap = {};
  final Event _event = Event();

  _join([Object? text1, Object? text2, Object? text3, Object? text4, Object? text5, Object? text6, Object? text7, Object? text8]) {
    return [text1, text2, text3, text4, text5, text6, text7, text8].whereType<Object>().join(' ');
  }

  log(Object text, {String level = 'info'}) {
    String log = 'time="${DateTime.now().toString()}" level=$level msg="$text"';
    stdout.writeln(log);
    _event.emit('log', log);
  }

  info(Object? text, [Object? text2, Object? text3, Object? text4, Object? text5, Object? text6, Object? text7, Object? text8]) {
    log(_join(text, text2, text3, text4, text5, text6, text7, text8), level: 'info');
  }

  warning(Object? text, [Object? text2, Object? text3, Object? text4, Object? text5, Object? text6, Object? text7, Object? text8]) {
    log(_join(text, text2, text3, text4, text5, text6, text7, text8), level: 'warning');
  }

  error(Object? text, [Object? text2, Object? text3, Object? text4, Object? text5, Object? text6, Object? text7, Object? text8]) {
    log(_join(text, text2, text3, text4, text5, text6, text7, text8), level: 'error');
  }

  debug(Object? text, [Object? text2, Object? text3, Object? text4, Object? text5, Object? text6, Object? text7, Object? text8]) {
    log(_join(text, text2, text3, text4, text5, text6, text7, text8), level: 'debug');
  }

  time(String text) {
    _timeMap[text] = DateTime.now().microsecondsSinceEpoch;
  }

  timeEnd(String text) {
    final startTime = _timeMap[text];
    if (startTime == null) return warning("Timer '$text' does not exist");
    int now = DateTime.now().microsecondsSinceEpoch;
    _timeMap.remove(text);
    debug('$text: ${(now - startTime) / 1000} ms');
  }

  on({void Function(String event)? onLog}) {
    if (onLog != null) _event.on('log', onLog);
  }

  off({void Function(String event)? onLog}) {
    if (onLog != null) _event.off('log', onLog);
  }
}
