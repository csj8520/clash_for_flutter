import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'package:clash_for_flutter/i18n/i18n.dart';
import 'package:clash_for_flutter/utils/utils.dart';
import 'package:clash_for_flutter/store/config.dart';
import 'package:clash_for_flutter/views/home/home.dart';
import 'package:clash_for_flutter/store/clash_core.dart';
import 'package:clash_for_flutter/utils/system_dns.dart';
import 'package:clash_for_flutter/utils/system_proxy.dart';
import 'package:clash_for_flutter/store/clash_service.dart';

void main() async {
  // init windowManager
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow();
  if (Platform.isMacOS) await windowManager.setSkipTaskbar(true);
  await windowManager.setSize(const Size(950, 600));
  await windowManager.center();
  await windowManager.setMinimumSize(const Size(500, 400));
  windowManager.show();
  // init store
  Get.put(StoreConfig());
  Get.put(StoreClashService());
  Get.put(StoreClashCore());
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

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    windowManager.addListener(this);
    await initTray();
    await storeConfig.init();
    await storeClashService.init();
    await storeClashService.fetchStart(storeConfig.config.value.selected);
    storeClashCore.setApi(storeConfig.clashCoreApiAddress.value, storeConfig.clashCoreApiSecret.value);
    await storeClashCore.waitCoreStart();
    await storeClashCore.fetchVersion();
    await storeClashCore.fetchConfig();
    final language = storeConfig.config.value.language.split('_');
    await Get.updateLocale(Locale(language[0], language[1]));
    if (Platform.isMacOS && storeConfig.clashCoreDns.isNotEmpty) await MacSystemDns.instance.set([storeConfig.clashCoreDns.value]);
    if (storeConfig.config.value.setSystemProxy) await SystemProxy.instance.set(storeClashCore.proxyConfig);
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
      MenuItem(key: 'exit', title: '退出'),
    ];
    await TrayManager.instance.setContextMenu(items);
    TrayManager.instance.addListener(this);
  }

  void initRegularlyUpdate() {
    Future.delayed(const Duration(minutes: 5)).then((_) async {
      initRegularlyUpdate();
      for (final it in storeConfig.config.value.subs) {
        try {
          if (it.url == null || it.url!.isEmpty) continue;
          if (((DateTime.now().millisecondsSinceEpoch ~/ 1000) - (it.updateTime ?? 0)) < storeConfig.config.value.updateInterval) continue;
          final chenged = await storeConfig.updateSub(it);
          if (!chenged) continue;
          if (it.name != storeConfig.config.value.selected) continue;
          // restart clash core
          await storeClashService.fetchStop();
          await storeClashService.fetchStart(storeConfig.config.value.selected);
          await storeConfig.readClashCoreApi();
          storeClashCore.setApi(storeConfig.clashCoreApiAddress.value, storeConfig.clashCoreApiSecret.value);
          await storeClashCore.waitCoreStart();
          if (Platform.isMacOS) {
            if (storeConfig.clashCoreDns.isNotEmpty) {
              await MacSystemDns.instance.set([storeConfig.clashCoreDns.value]);
            } else {
              await MacSystemDns.instance.set([]);
            }
          }
          if (storeConfig.config.value.setSystemProxy) await SystemProxy.instance.set(storeClashCore.proxyConfig);
          await Future.delayed(const Duration(seconds: 20));
        } catch (_) {}
      }
    });
  }

  @override
  void onTrayIconMouseDown() {
    if (Platform.isWindows) {
      WindowManager.instance.show();
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
    if (menuItem.key == 'show') {
      await WindowManager.instance.show();
      storeConfig.config.refresh();
    } else if (menuItem.key == 'hide') {
      await WindowManager.instance.hide();
    } else if (menuItem.key == 'restart-clash-core') {
      await storeClashService.fetchStop();
      await storeClashService.fetchStart(storeConfig.config.value.selected);
    } else if (menuItem.key == 'copy-command-line') {
      final proxyConfig = storeClashCore.proxyConfig;
      await copyCommandLineProxy(menuItem.title!, http: proxyConfig.http, https: proxyConfig.https);
    } else if (menuItem.key == 'exit') {
      await storeClashService.exit();
      if (Platform.isMacOS && storeConfig.clashCoreDns.isNotEmpty) await MacSystemDns.instance.set([]);
      if (storeConfig.config.value.setSystemProxy) await SystemProxy.instance.set(SystemProxyConfig());
      exit(0);
    }
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
      ),
      builder: BotToastInit(),
      home: const PageHome(),
    );
  }
}
