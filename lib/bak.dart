import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:styled_widget/styled_widget.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:system_tray/system_tray.dart';

import 'package:clashf_pro/utils/utils.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final List<Widget> _logs = [];
  final ScrollController _scrollController = ScrollController();
  final SystemTray _systemTray = SystemTray();

  Timer? _timer;
  bool _lockScrollToBottom = true;
  bool _notHandleScroll = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_notHandleScroll) return;
      _lockScrollToBottom = _scrollController.position.maxScrollExtent - _scrollController.offset < 20;
    });
    log.on(onLog: (event) {
      setState(() {
        _logs.add(Text(event));
      });
      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 16), () {
        if (!_lockScrollToBottom) return;
        _notHandleScroll = true;
        _scrollController.position.moveTo(_scrollController.position.maxScrollExtent);
        _notHandleScroll = false;
      });
    });

    configDir.watch(events: FileSystemEvent.modify).listen((event) {
      log.debug(event.path);
    });

    // https://github.com/antler119/system_tray/blob/master/example/lib/main.dart
    final menu = [
      MenuItem(label: 'Show', onClicked: appWindow.show),
      MenuItem(label: 'Hide', onClicked: appWindow.hide),
      MenuItem(label: 'Exit', onClicked: appWindow.close),
    ];

    _systemTray.initSystemTray(title: 'Tray', iconPath: 'assets/bitbug_favicon.ico').then((value) {
      _systemTray.setContextMenu(menu);
    });

    log.debug(Platform.version);
    log.debug(Platform.resolvedExecutable);
    log.debug(assetsDir);
    log.debug(clashFile);
    log.debug(configDir);
    log.debug(configFile);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      log.debug("app进入前台");
    } else if (state == AppLifecycleState.inactive) {
      log.debug("app在前台但不响应事件，比如电话，touch id等");
    } else if (state == AppLifecycleState.paused) {
      log.debug("app进入后台");
    } else if (state == AppLifecycleState.detached) {
      log.debug("没有宿主视图但是flutter引擎仍然有效");
    } else {
      log.debug('state', state);
    }
  }

  @override
  void dispose() {
    super.dispose();
    log.debug('exit');
  }

  void _handleCick() async {
    // https://clash.razord.top/?host=127.0.0.1&port=3328#/proxies

    // String config = await configFile.readAsString();
    // log.info(config);

    log.time('exec time');
    final out = await Process.run(clashFile.path, ['-v']);
    log.info(out.stdout.toString().trim());
    log.timeEnd('exec time');

    final calsh = await Process.start(clashFile.path, ['-d', configDir.path, '-f', path.join(configDir.path, 'clash.yaml')]);

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
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: ListView.builder(
        padding: const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
        itemBuilder: (context, index) => _logs[index],
        itemCount: _logs.length,
        controller: _scrollController,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
        ),
        FloatingActionButton(
          onPressed: () {
            exit(0);
          },
          child: const Icon(Icons.exit_to_app),
        )
      ].toRow(mainAxisAlignment: MainAxisAlignment.center).padding(bottom: 20),
    );
  }
}
