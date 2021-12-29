import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';
import 'package:path/path.dart' as path;
import 'package:styled_widget/styled_widget.dart';

import 'package:clashf_pro/utils/utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Widget> _logs = [];
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  bool _lockScroll = true;
  bool _notHandleScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_notHandleScroll) return;
      _lockScroll = _scrollController.position.maxScrollExtent - _scrollController.offset < 20;
    });
    log.on(onLog: (event) {
      setState(() {
        _logs.add(Text(event));
      });
      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 16), () {
        if (!_lockScroll) return;
        _notHandleScroll = true;
        _scrollController.position.moveTo(_scrollController.position.maxScrollExtent);
        _notHandleScroll = false;
      });
    });
  }

  void _handleCick() async {
    // https://clash.razord.top/?host=127.0.0.1&port=3328#/proxies

    String clashName = Platform.isWindows
        ? 'clash-windows-amd64.exe'
        : Platform.isMacOS
            ? 'clash-darwin-arm64'
            : '';

    Directory configDir = Directory(path.join(userHomePath, '.config', 'clash-pro'));
    Directory binDir = Directory(path.join(configDir.path, 'bin'));
    File configFile = File(path.join(configDir.path, '.config.yaml'));
    File binFile = File(path.join(binDir.path, clashName));

    if (!await binDir.exists()) {
      log.info('Creater Dir', binDir);
      await binDir.create(recursive: true);
    }

    if (!(await binFile.exists())) {
      log.info('Copy File From assets/bin/$clashName, to ${binFile.path}');
      final bin = await rootBundle.load('assets/bin/$clashName');
      await binFile.writeAsBytes(bin.buffer.asUint8List(bin.offsetInBytes, bin.lengthInBytes));
      // TODO: -fix Permission denied, operation not permitted
      if (Platform.isMacOS) await Process.run('chmod', ['755', binFile.path]);
    }

    log.debug(binFile);

    // String config = await configFile.readAsString();
    // log.info(config);

    log.time('exec time');
    final out = await Process.run(binFile.path, ['-v'], runInShell: false);
    log.info(out.stdout.toString().trim());
    log.timeEnd('exec time');

    final calsh = await Process.start(
        binFile.path,
        [
          '-d',
          configDir.path,
          '-f',
          path.join(configDir.path, 'clash.yaml'),
        ],
        runInShell: false);

    calsh.stdout.listen((event) {
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

    Future.delayed(const Duration(seconds: 5), () {
      log.info('clash is killed:', calsh.kill());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
        itemBuilder: (context, index) => _logs[index],
        itemCount: _logs.length,
        controller: _scrollController,
      ),
      floatingActionButton: [
        FloatingActionButton(
          onPressed: _handleCick,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
        FloatingActionButton(
          onPressed: () {
            log.debug(_scrollController.offset);
            log.debug(_scrollController.position.maxScrollExtent);
          },
          tooltip: 'Increment',
          child: const Icon(Icons.ac_unit),
        )
      ].toColumn(),
    );
  }
}
