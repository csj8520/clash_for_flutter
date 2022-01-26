// TEST:

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

// https://www.wintun.net/
// https://github.com/winsw/winsw
// https://www.cnblogs.com/wangcl-8645/p/11978319.html

Process? clash;

void main(List<String?> arguments) async {
  print(arguments);
  final port = int.parse(arguments[0] ?? '5099');
  print(InternetAddress.loopbackIPv4);
  ProcessSignal.sigint.watch().listen((event) {
    print('exit');
    clash?.kill();
    exit(0);
  });

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  server.listen((req) async {
    print(req.uri.path);
    if (req.uri.path == '/start') {
      final d = req.uri.queryParameters['d'];
      final f = req.uri.queryParameters['f'];
      print(d);
      print(f);
      if (d == null || f == null) {
        req.response.statusCode = 500;
      } else {
        await startClash(d, f);
        req.response.write(req.uri.path);
      }
    } else if (req.uri.path == '/status') {
      if (clash == null) {
        req.response.write('stopped');
      } else {
        req.response.write('running');
      }
    } else if (req.uri.path == '/stop') {
      clash?.kill();
    } else if (req.uri.path == '/log') {
    } else {
      req.response.statusCode = 404;
      req.response.write('404');
    }
    req.response.close();
  });
}

Future<void> startClash(String d, String f) async {
  clash?.kill();
  clash = await Process.start(path.normalize(path.absolute('../../bin/clash-windows-amd64.exe')), ['-d', d, '-f', f]);
  clash!.stdout.listen(printLog);
  clash!.stderr.listen(printLog);
  clash!.exitCode.then((value) {
    clash = null;
  });
}

printLog(List<int> log) {
  print(utf8.decode(log));
}


// dart compile exe ./lib/service/service.dart -o ./assets/service/windows/clash-pro-for-flutter-service.exe