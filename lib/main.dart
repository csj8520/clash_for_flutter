import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

import 'package:clash_for_flutter/i18n/i18n.dart';
import 'package:clash_for_flutter/utils/utils.dart';
import 'package:clash_for_flutter/store/config.dart';
import 'package:clash_for_flutter/store/shortcuts.dart';
import 'package:clash_for_flutter/views/home/home.dart';
import 'package:clash_for_flutter/store/clash_core.dart';
import 'package:clash_for_flutter/utils/system_dns.dart';
import 'package:clash_for_flutter/utils/system_proxy.dart';
import 'package:clash_for_flutter/store/clash_service.dart';

void main() async {
  // init windowManager
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = WindowOptions(
    size: const Size(950, 600),
    minimumSize: const Size(500, 400),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: Platform.isMacOS,
    // titleBarStyle: Platform.isMacOS ? TitleBarStyle.hidden : TitleBarStyle.normal,
  );
  await windowManager.waitUntilReadyToShow(windowOptions);
  await windowManager.show();
  // init store
  Get.put(StoreConfig());
  Get.put(StoreClashService());
  Get.put(StoreClashCore());
  Get.put(StoreSortcuts());
  runApp(GetMaterialApp(
    translations: I18n(),
    locale: Get.deviceLocale,
    home: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TrayListener, WindowListener {
  final StoreConfig storeConfig = Get.find();
  final StoreClashService storeClashService = Get.find();
  final StoreClashCore storeClashCore = Get.find();
  final StoreSortcuts storeSortcuts = Get.find();

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    // watch process kill
    // ref https://github.com/dart-lang/sdk/issues/12170
    // TODO: test windows
    // for macos 任务管理器退出进程
    ProcessSignal.sigterm.watch().listen((_) {
      stdout.writeln('exit: sigterm');
      handleExit();
    });
    // for macos ctrl+c
    ProcessSignal.sigint.watch().listen((_) {
      stdout.writeln('exit: sigint');
      handleExit();
    });

    windowManager.addListener(this);
    await initTray();
    await storeConfig.init();
    await storeClashService.init();
    storeSortcuts.init();
    await storeSortcuts.startClashCore(autoSetDns: storeConfig.clashCoreDns.isNotEmpty, autoSetProxy: true);
    await storeClashCore.fetchVersion();
    final language = storeConfig.config.value.language.split('_');
    await Get.updateLocale(Locale(language[0], language[1]));
    initRegularlyUpdate();
  }

  Future<void> initTray() async {
    await TrayManager.instance.setIcon('assets/logo/logo.ico');
    List<MenuItem> items = [
      MenuItem(key: 'show', title: '显示'),
      MenuItem(key: 'hide', title: '隐藏'),
      MenuItem.separator,
      MenuItem(key: 'restart-clash-core', title: '重启 Clash Core'),
      MenuItem(title: '复制命令行代理', items: [
        MenuItem(key: 'copy-command-line', title: 'bash'),
        MenuItem(key: 'copy-command-line', title: 'cmd'),
        MenuItem(key: 'copy-command-line', title: 'powershell'),
      ]),
      MenuItem(key: 'about', title: '关于'),
      MenuItem(key: 'exit', title: '退出'),
    ];
    await TrayManager.instance.setContextMenu(items);
    TrayManager.instance.addListener(this);
  }

  void initRegularlyUpdate() {
    Future.delayed(const Duration(minutes: 1)).then((_) async {
      initRegularlyUpdate();
      for (final it in storeConfig.config.value.subs) {
        try {
          if (it.url == null || it.url!.isEmpty) continue;
          if (((DateTime.now().millisecondsSinceEpoch ~/ 1000) - (it.updateTime ?? 0)) < storeConfig.config.value.updateInterval) continue;
          final chenged = await storeConfig.updateSub(it);
          if (!chenged) continue;
          if (it.name != storeConfig.config.value.selected) continue;
          // restart clash core
          await storeSortcuts.reloadClashCore();
          await Future.delayed(const Duration(seconds: 20));
        } catch (_) {}
      }
    });
  }

  @override
  void onTrayIconMouseDown() {
    if (Platform.isWindows) {
      windowManager.show();
    } else {
      onTrayIconRightMouseDown();
    }
  }

  @override
  void onTrayIconRightMouseDown() {
    TrayManager.instance.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    super.onTrayMenuItemClick(menuItem);
    final key = menuItem.key;
    final title = menuItem.title!;
    if (key == 'show') {
      await windowManager.show();
      storeConfig.config.refresh();
    } else if (key == 'hide') {
      await windowManager.hide();
    } else if (key == 'restart-clash-core') {
      await storeClashService.fetchStop();
      await storeClashService.fetchStart(storeConfig.config.value.selected);
    } else if (key == 'copy-command-line') {
      final proxyConfig = storeClashCore.proxyConfig;
      await copyCommandLineProxy(title, http: proxyConfig.http, https: proxyConfig.https);
    } else if (key == 'about') {
      await launchUrl(Uri.parse('https://github.com/csj8520/clash_for_flutter'));
    } else if (key == 'exit') {
      await handleExit();
    }
  }

  Future<void> handleExit() async {
    await storeClashService.exit();
    if (Platform.isMacOS && storeConfig.clashCoreDns.isNotEmpty) await MacSystemDns.instance.set([]);
    if (storeConfig.config.value.setSystemProxy) await SystemProxy.instance.set(SystemProxyConfig());
    exit(0);
  }

  @override
  Future<void> onWindowFocus() async {
    await storeClashCore.fetchConfig();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clash For Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xff2c8af8),
        errorColor: const Color(0xfff56c6c),
      ),
      builder: BotToastInit(),
      home: const PageHome(),
    );
  }
}
