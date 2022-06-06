import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:window_manager/window_manager.dart';
import 'package:protocol_handler/protocol_handler.dart';

import 'package:clash_for_flutter/i18n/i18n.dart';

import 'package:clash_for_flutter/controllers/tray.dart';
import 'package:clash_for_flutter/controllers/window.dart';
import 'package:clash_for_flutter/controllers/protocol.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';

import 'package:clash_for_flutter/controllers/core.dart';
import 'package:clash_for_flutter/controllers/config.dart';
import 'package:clash_for_flutter/controllers/service.dart';

import 'package:clash_for_flutter/controller.dart';
import 'package:clash_for_flutter/views/home/home.dart';
import 'package:clash_for_flutter/views/log/controller.dart';
import 'package:clash_for_flutter/views/home/controller.dart';
import 'package:clash_for_flutter/views/rule/controller.dart';
import 'package:clash_for_flutter/views/proxie/controller.dart';
import 'package:clash_for_flutter/views/setting/controller.dart';
import 'package:clash_for_flutter/views/profile/controller.dart';
import 'package:clash_for_flutter/views/connection/controller.dart';

void main() async {
  // init windowManager
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await protocolHandler.register('clash');
  WindowOptions windowOptions = const WindowOptions(
    size: Size(950, 600),
    minimumSize: Size(500, 400),
    center: true,
    backgroundColor: Colors.transparent,
    // skipTaskbar: Platform.isMacOS,
    // titleBarStyle: Platform.isMacOS ? TitleBarStyle.hidden : TitleBarStyle.normal,
  );
  await windowManager.waitUntilReadyToShow(windowOptions);
  // await windowManager.show();

  // init controllers
  Get.put(TrayController());
  Get.put(WindowController());
  Get.put(ProtocolController());

  Get.put(CoreController());
  Get.put(ConfigController());
  Get.put(ServiceController());

  Get.put(PageLogController());
  Get.put(PageMainController());
  Get.put(PageHomeController());
  Get.put(PageRuleController());
  Get.put(PageProxieController());
  Get.put(PageSettingController());
  Get.put(PageProfileController());
  Get.put(PageConnectionController());

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
  @override
  void initState() {
    controllers.init();
    controllers.pageMain.init(context);
    super.initState();
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
      navigatorObservers: [BotToastNavigatorObserver()],
      home: const PageHome(),
    );
  }

  @override
  void dispose() {
    controllers.pageMain.dispose();
    super.dispose();
  }
}
