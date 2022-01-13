import 'dart:math' as math;

import 'logger.dart';

export 'logger.dart';
export 'const.dart';
export 'them.dart';
export 'events.dart';
export 'event.dart';
export 'clash.dart';
export 'config.dart';
export 'system_proxy.dart';

Logger log = Logger();

String bytesToSize(int bytes) {
  if (bytes == 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  final i = (math.log(bytes) / math.log(k)).floor();
  return (bytes / math.pow(k, i)).toStringAsFixed(2) + ' ' + sizes[i];
}
