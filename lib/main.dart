import 'dart:io';
import 'package:clashf_pro/containers/logs/logs.dart';
import 'package:clashf_pro/utils/clash.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:system_tray/system_tray.dart';

import 'package:clashf_pro/utils/utils.dart';
import 'package:clashf_pro/containers/sidebar/sidebar.dart';

// int count = 0;
final count = {"count": 0};

void main() {
  runApp(const MyApp());
  log.time('start time');
  count['count'] = count['count']! + 1;
  log.debug('count', count['count']);
  doWhenWindowReady(() {
    const initialSize = Size(950, 600);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = "How to use system tray with Flutter";
    appWindow.show();
    log.timeEnd('start time');
  });
  ProcessSignal.sigint.watch().listen((event) {
    print('-----exit');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final SystemTray _systemTray = SystemTray();
  String _selected = 'agent';
  Logs logs = const Logs();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    log.debug('-----didChangeAppLifecycleState', state);
  }

  @override
  void reassemble() {
    super.reassemble();
    log.debug('-----reassemble');
  }

  void reassembleApplication() {
    log.debug('-----reassembleApplication');
  }

  @override
  void activate() {
    super.activate();
    log.debug('-----activate');
  }

  @override
  void deactivate() {
    super.deactivate();
    log.debug('-----deactivate');
  }

  @override
  void dispose() {
    super.dispose();
    log.debug('-----dispose');
  }

  @override
  void didUpdateWidget(covariant MyHomePage oldWidget) {
    print('-----didUpdateWidget');
    super.didUpdateWidget(oldWidget);
    log.debug('-----didUpdateWidget');
  }

  @override
  void initState() {
    super.initState();
    startClash();

    final menu = [
      MenuItem(label: '显示', onClicked: appWindow.show),
      MenuItem(label: '隐藏', onClicked: appWindow.hide),
      MenuItem(label: '退出', onClicked: () => exit(0)),
    ];
    _systemTray.registerSystemTrayEventHandler((eventName) {
      log.debug(eventName);
      if (eventName == 'leftMouseUp') {
        log.debug(appWindow.isVisible);
        if (appWindow.isVisible) {
          appWindow.restore();
        } else {
          return appWindow.show();
        }
      }
    });
    _systemTray.initSystemTray(title: 'Tray', iconPath: 'assets/logo.ico').then((value) {
      _systemTray.setContextMenu(menu);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SideBar(
          selected: _selected,
          onChange: (menu) {
            setState(() => _selected = menu.type);
            log.debug('Menu Changed: ', menu.label);
          },
        ),
        Expanded(child: logs)
      ],
    ).height(double.infinity).backgroundColor(const Color(0xfff4f5f6)));
  }
}
