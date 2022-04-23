import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:path/path.dart' as path;

import 'package:clash_for_flutter/const/const.dart';
import 'package:clash_for_flutter/utils/logger.dart';

Future<void> killProcess(String name) async {
  log.debug("kill: ", name);
  if (Platform.isWindows) {
    await Process.run('taskkill', ["/F", "/FI", "IMAGENAME eq $name"]);
  } else {
    await Process.run('bash', ["-c", "ps -ef | grep $name | grep -v grep | awk '{print \$2}' | xargs kill -9"]);
  }
}

Future<ProcessResult> runAsAdmin(String executable, List<String> arguments) async {
  String _path = shellArgument(executable).replaceAll(' ', r'\\ ');
  _path = _path.substring(1, _path.length - 1);
  if (Platform.isMacOS) {
    return await Process.run(
      'osascript',
      [
        '-e',
        shellArguments(['do', 'shell', 'script', '$_path ${shellArguments(arguments)}', 'with', 'administrator', 'privileges']),
      ],
    );
  } else if (Platform.isWindows) {
    return await Process.run(
      path.join(Paths.assetsBin.path, "run-as-admin.bat"),
      [executable, ...arguments],
    );
  } else {
    UnimplementedError();
    return await Process.run("", []);
  }
}
