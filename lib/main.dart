import 'dart:io';
import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
  if (!Platform.isLinux) await protocolHandler.register('clash');
  WindowOptions windowOptions = WindowOptions(
    size: const Size(950, 600),
    minimumSize: const Size(500, 400),
    // TODO: fix it
    center: !Platform.isLinux,
    // backgroundColor: Colors.transparent, // https://github.com/leanflutter/window_manager/issues/293
    // skipTaskbar: Platform.isMacOS,
    // titleBarStyle: Platform.isMacOS ? TitleBarStyle.hidden : TitleBarStyle.normal,
  );
  await windowManager.waitUntilReadyToShow(windowOptions);
  await windowManager.setPreventClose(true);
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

  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://cf8215f2f40b4197ac87161b5694a7f3@o305870.ingest.sentry.io/4504115594657792';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(
      DefaultAssetBundle(
        bundle: SentryAssetBundle(),
        child: GetMaterialApp(
          title: 'Clash For Flutter',
          translations: I18n(),
          locale: Get.deviceLocale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: I18n.locales,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: const Color(0xff2c8af8),
            errorColor: const Color(0xfff56c6c),
          ),
          builder: BotToastInit(),
          navigatorObservers: [BotToastNavigatorObserver(), SentryNavigatorObserver()],
          home: const MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<bool> listenShow;

  @override
  void initState() {
    controllers.init();
    controllers.pageMain.init(context);
    listenShow = controllers.window.isVisible.stream.listen((event) async {
      if (!event) return;
      await Future.delayed(const Duration(milliseconds: 100));
      await Get.forceAppUpdate();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const PageHome();
  }

  @override
  void dispose() {
    controllers.pageMain.dispose();
    listenShow.cancel();
    super.dispose();
  }
}
