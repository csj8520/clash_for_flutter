import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:clashf_pro/view/connections/index.dart';
import 'package:clashf_pro/view/logs/index.dart';
import 'package:clashf_pro/utils/clash.dart';
import 'package:clashf_pro/view/proxies/index.dart';
import 'package:clashf_pro/view/rules/index.dart';
import 'package:clashf_pro/view/settings/index.dart';
import 'package:flutter/material.dart';

import 'package:clashf_pro/utils/utils.dart';
import 'package:clashf_pro/view/sidebar/index.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  log.time('Start Window Time');
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  windowManager.waitUntilReadyToShow().then((_) async {
    // await windowManager.setAsFrameless();
    if (Platform.isMacOS) await windowManager.setSkipTaskbar(true);
    await windowManager.setSize(const Size(950, 600));
    await windowManager.setMinimumSize(const Size(500, 400));
    // await windowManager.setPosition(Offset.zero);
    windowManager.show();
    log.timeEnd('Start Window Time');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xff2c8af8),
        errorColor: const Color(0xfff56c6c),
      ),
      builder: BotToastInit(),
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

class _MyHomePageState extends State<MyHomePage> with TrayListener, WindowListener {
  int _index = 0;
  bool _inited = false;
  ClashVersion? _clashVersion;
  final PageVisibleEvent _pageVisibleEvent = PageVisibleEvent();

  final _menus = [
    SideBarMenu('代理', 'proxies'),
    SideBarMenu('日志', 'logs'),
    SideBarMenu('规则', 'rules'),
    SideBarMenu('连接', 'connections'),
    SideBarMenu('设置', 'settings'),
  ];

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    _initTray();
    windowManager.addListener(this);
    await startClash();
    _clashVersion = await fetchClashVersion();
    _inited = true;
    _pageVisibleEvent.show('proxies');
    setState(() {});
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

  _onChange(SideBarMenu menu, int index) {
    if (!_inited) return BotToast.showText(text: '请等待初始化！');
    setState(() => {_index = index});
    log.debug('Menu Changed: ', menu.label);
    _pageVisibleEvent.show(menu.type);
  }

  // @override
  // void onWindowEvent(String eventName) {
  //   super.onWindowEvent(eventName);
  //   log.debug('onWindowEvent: ', eventName);
  // }

  @override
  void onTrayIconMouseDown() {
    log.debug('Tray Click: onTrayIconMouseDown');
    super.onTrayIconMouseDown();
    if (Platform.isWindows) {
      WindowManager.instance.show();
    } else {
      onTrayIconRightMouseDown();
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
      // if (Platform.isMacOS) await windowManager.setSkipTaskbar(false);
    } else if (menuItem.key == 'hide') {
      WindowManager.instance.hide();
      // if (Platform.isMacOS) await windowManager.setSkipTaskbar(true);
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
          ViewSideBar(menus: _menus, index: _index, onChange: _onChange, clashVersion: _clashVersion),
          Expanded(
            child: IndexedStack(
              children: [
                PageProxies(pageVisibleEvent: _pageVisibleEvent),
                PageLogs(pageVisibleEvent: _pageVisibleEvent),
                PageRules(pageVisibleEvent: _pageVisibleEvent),
                PageConnections(pageVisibleEvent: _pageVisibleEvent),
                PageSettings(pageVisibleEvent: _pageVisibleEvent),
              ],
              index: _index,
            ),
          ),
        ],
      ).height(double.infinity).backgroundColor(const Color(0xfff4f5f6)),
      floatingActionButton: FloatingActionButton(
        tooltip: '关闭Clash主进程',
        onPressed: clash?.kill,
        child: const Icon(Icons.close),
      ),
    );
  }
}
