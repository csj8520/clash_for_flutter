import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:window_manager/window_manager.dart';

import 'package:clash_pro_for_flutter/types/index.dart';
import 'package:clash_pro_for_flutter/utils/index.dart';
import 'package:clash_pro_for_flutter/store/index.dart';
import 'package:clash_pro_for_flutter/mixins/index.dart';

import 'package:clash_pro_for_flutter/view/sidebar/index.dart';
import 'package:clash_pro_for_flutter/view/proxies/index.dart';
import 'package:clash_pro_for_flutter/view/logs/index.dart';
import 'package:clash_pro_for_flutter/view/rules/index.dart';
import 'package:clash_pro_for_flutter/view/connections/index.dart';
import 'package:clash_pro_for_flutter/view/settings/index.dart';
import 'package:clash_pro_for_flutter/view/profiles/index.dart';

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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TrayListener, WindowListener, TrayMixin, WindowMixin {
  int _index = 1;
  final PageController _pageController = PageController(initialPage: 1);

  final _menus = [
    SideBarMenu('代理', 'proxies'),
    SideBarMenu('日志', 'logs'),
    SideBarMenu('规则', 'rules'),
    SideBarMenu('连接', 'connections'),
    SideBarMenu('配置', 'profiles'),
    SideBarMenu('设置', 'settings'),
  ];

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() async {
    initTray();
    await globalStore.init();
    initWindow();
    if (!globalStore.inited) return;
    // _pageController.jumpTo(0);
    // setState(() => _index = 0);
  }

  dynamic _onChange(SideBarMenu menu, int index) {
    if (!globalStore.inited && !['logs', 'profiles'].contains(menu.type)) return BotToast.showText(text: '请等待初始化！');
    setState(() => {_index = index});
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Observer(builder: (_) => ViewSideBar(menus: _menus, index: _index, onChange: _onChange, clashVersion: globalStore.clashVersion)),
          PageView(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const PageProxies(),
              const PageLogs(),
              PageRules(),
              const PageConnections(),
              const PageProfiles(),
              const PageSettings(),
            ],
          ).expanded()
        ],
      ).height(double.infinity).backgroundColor(const Color(0xfff4f5f6)),
    );
  }

  @override
  void dispose() async {
    windowManager.removeListener(this);
    TrayManager.instance.removeListener(this);
    await TrayManager.instance.destroy();
    super.dispose();
  }
}
