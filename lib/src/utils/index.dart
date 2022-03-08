import 'dart:io';
import 'dart:math' as math;
import 'package:path/path.dart' as p;

import 'package:flutter/services.dart';
import 'package:process_run/shell.dart';

import 'const.dart';
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

Future<void> killProcess(String name) async {
  log.debug("kill: ", name);
  if (Platform.isWindows) {
    await Process.run('taskkill', ["/F", "/FI", "IMAGENAME eq $name"]);
  } else {
    await Process.run('bash', ["-c", "ps -ef | grep $name | grep -v grep | awk '{print \$2}' | xargs kill -9"]);
  }
}

Future<ProcessResult> runAsAdmin(String executable, List<String> arguments) async {
  String path = shellArgument(executable).replaceAll(' ', r'\\ ');
  path = path.substring(1, path.length - 1);
  if (Platform.isMacOS) {
    return await Process.run(
      'osascript',
      [
        '-e',
        shellArguments(['do', 'shell', 'script', '$path ${shellArguments(arguments)}', 'with', 'administrator', 'privileges']),
      ],
      runInShell: false,
    );
  } else if (Platform.isWindows) {
    return await Process.run(
      p.join(CONST.assetsDir.path, 'bin', "run-as-admin.bat"),
      [executable, ...arguments],
      runInShell: false,
    );
  } else {
    UnimplementedError();
    return await Process.run("", []);
  }
}
