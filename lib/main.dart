import 'dart:io';
import 'package:clashf_pro/containers/logs/logs.dart';
import 'package:clashf_pro/utils/clash.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
// import 'package:bitsdojo_window/bitsdojo_window.dart';
// import 'package:system_tray/system_tray.dart';

import 'package:clashf_pro/utils/utils.dart';
import 'package:clashf_pro/containers/sidebar/sidebar.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  log.time('Start Window Time');
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  windowManager.waitUntilReadyToShow().then((_) async {
    // await windowManager.setAsFrameless();
    await windowManager.setSize(const Size(950, 600));
    await windowManager.setMinimumSize(const Size(500, 400));
    // await windowManager.setPosition(Offset.zero);
    windowManager.show();
    log.timeEnd('Start Window Time');
  });

  runApp(const MyApp());
  // doWhenWindowReady(() {
  //   const initialSize = Size(950, 600);
  //   appWindow.minSize = initialSize;
  //   appWindow.size = initialSize;
  //   appWindow.alignment = Alignment.center;
  //   appWindow.title = "How to use system tray with Flutter";
  //   appWindow.show();
  // });
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

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver, TrayListener, WindowListener {
  // final SystemTray _systemTray = SystemTray();
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
    _initTray();
    windowManager.addListener(this);
    startClash();

    // final menu = [
    //   MenuItem(label: '显示', onClicked: windowManager.show),
    //   MenuItem(label: '隐藏', onClicked: windowManager.hide),
    //   MenuItem(label: '退出', onClicked: () => exit(0)),
    // ];
    // _systemTray.registerSystemTrayEventHandler((eventName) {
    //   log.debug(eventName);
    //   if (eventName == 'leftMouseUp') {
    //     windowManager.show();
    //   }
    // });
    // _systemTray.initSystemTray(title: 'Tray', iconPath: 'assets/logo.ico').then((value) {
    //   _systemTray.setContextMenu(menu);
    // });
  }

  void _initTray() async {
    await TrayManager.instance.setIcon('assets/logo.ico');
    List<MenuItem> items = [
      MenuItem(
        key: 'show',
        title: '显示',
      ),
      MenuItem(
        key: 'hide',
        title: '隐藏',
      ),
      MenuItem.separator,
      MenuItem(
        key: 'exit',
        title: '退出',
      ),
    ];
    await TrayManager.instance.setContextMenu(items);
    TrayManager.instance.addListener(this);
  }

  @override
  void onWindowEvent(String eventName) {
    super.onWindowEvent(eventName);
    log.debug('onWindowEvent: ', eventName);
  }

  @override
  void onTrayIconMouseDown() {
    log.debug('Tray Click: onTrayIconMouseDown');
    super.onTrayIconMouseDown();
    if (Platform.isWindows) {
      WindowManager.instance.show();
    } else {
      onTrayIconRightMouseDown();
      // TrayManager.instance.popUpContextMenu();
    }
  }

  @override
  void onTrayIconRightMouseDown() {
    log.debug('Tray Click: onTrayIconRightMouseDown');
    super.onTrayIconRightMouseDown();
    TrayManager.instance.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    log.debug('Menu Item Click: ', menuItem.title);
    super.onTrayMenuItemClick(menuItem);
    if (menuItem.key == 'show') {
      WindowManager.instance.show();
      await windowManager.setSkipTaskbar(false);
    } else if (menuItem.key == 'hide') {
      WindowManager.instance.hide();
      await windowManager.setSkipTaskbar(true);
    } else if (menuItem.key == 'exit') {
      clash?.kill();
      exit(0);
    }
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
      ).height(double.infinity).backgroundColor(const Color(0xfff4f5f6)),
      floatingActionButton: FloatingActionButton(
        tooltip: '关闭Clash主进程',
        onPressed: () {
          clash?.kill();
        },
        child: const Icon(Icons.close),
      ),
    );
  }
}
