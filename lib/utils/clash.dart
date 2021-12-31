import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:clashf_pro/utils/utils.dart';

Process? clash;

Future<Process> startClash() async {
  log.debug(clash);
  if (clash != null) clash!.kill();

  clash = await Process.start(clashFile.path, ['-d', configDir.path, '-f', path.join(configDir.path, 'clash.yaml')], runInShell: true);
  clash!.stdout.listen((event) {
    List<String> strs = utf8.decode(event).trim().split('\n');
    for (var it in strs) {
      final matchs = RegExp(r'^time="([\d-T:+]+)" level=(\w+) msg="(.+)"$').firstMatch(it.trim());
      if (matchs == null) continue;
      final res = matchs.groups([1, 2, 3]);
      final msg = res[2];
      if (msg == null) continue;
      log.log(msg, level: res[1] ?? 'info');
    }
  });
  return clash!;
}
