import 'dart:io';
import 'dart:convert';

import 'package:clashf_pro/store/index.dart';
import 'package:clashf_pro/utils/index.dart';
import 'package:clashf_pro/fetch/index.dart';

Process? clash;

Future<Process> startClash() async {
  log.debug(clash);
  clash?.kill();

  log.time('Start Clash Time');

  clash = await Process.start(CONST.clashBinFile.path, ['-d', CONST.configDir.path, '-f', localConfigStore.clashConfigFile.path], runInShell: false);
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
  clash?.exitCode.then((value) => log.debug('Clash Is Exit($value)'));

  while (true) {
    if (await fetchClashHello()) break;
    await Future.delayed(const Duration(milliseconds: 100));
  }

  log.timeEnd('Start Clash Time');
  return clash!;
}

Future<void> forceKillClash() async {
  if (Platform.isWindows) {
    await Process.run('taskkill', ["/F", "/FI", "IMAGENAME eq ${CONST.clashBinName}"]);
  } else {
    await Process.run('bash', ["-c", "ps -ef | grep ${CONST.clashBinName} | grep -v grep | awk '{print \$2}' | xargs kill -9"]);
  }
}
