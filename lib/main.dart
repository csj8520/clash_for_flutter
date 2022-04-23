import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:window_manager/window_manager.dart';

import 'package:clash_for_flutter/i18n/i18n.dart';
import 'package:clash_for_flutter/store/config.dart';
import 'package:clash_for_flutter/views/home/home.dart';
import 'package:clash_for_flutter/store/clash_core.dart';
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

class _MyAppState extends State<MyApp> {
  final StoreConfig storeConfig = Get.find();
  final StoreClashService storeClashService = Get.find();
  final StoreClashCore storeClashCore = Get.find();

  @override
  void initState() {
    init();
    super.initState();
  }

  Future init() async {
    await storeConfig.init();
    await storeClashService.init();
    await storeClashService.fetchStart(storeConfig.config.value.selected);
    storeClashCore.setApi(storeConfig.clashCoreApiAddress.value, storeConfig.clashCoreApiSecret.value);
    await storeClashCore.waitCoreStart();
    await storeClashCore.fetchVersion();
    final language = storeConfig.config.value.language.split('_');
    Get.updateLocale(Locale(language[0], language[1]));
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
