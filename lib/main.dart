import 'package:clash_for_flutter/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:clash_for_flutter/store/config.dart';
import 'package:clash_for_flutter/store/clash_core.dart';
import 'package:clash_for_flutter/store/clash_service.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => StoreConfig()),
      ChangeNotifierProvider(create: (_) => StoreClashCore()),
      ChangeNotifierProvider(create: (_) => StoreClashService()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clash For Flutter',
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('zh', 'CN'),
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isloaded = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  Future init() async {
    final storeConfig = context.read<StoreConfig>();
    final storeClashCore = context.read<StoreClashCore>();
    final storeClashService = context.read<StoreClashService>();

    await storeConfig.init();
    await storeClashService.init();
    await storeClashService.fetchStart(storeConfig.config.selected);
    storeClashCore.setApi(storeConfig.clashCoreApiAddress, storeConfig.clashCoreApiSecret);
    await storeClashCore.waitStart();

    final version = await storeClashCore.fetchVersion();
    print(version);
    // await AppLocalizations.delegate.load(Locale('en', 'US'));
    // S.load(Locale('en', ''));
    // print(S.delegate.supportedLocales);

    setState(() {
      _isloaded = true;
    });
  }

  Future clashServiceSwitch() async {
    final storeConfig = context.read<StoreConfig>();
    final storeClashCore = context.read<StoreClashCore>();
    final storeClashService = context.read<StoreClashService>();

    storeClashService.serviceMode ? await storeClashService.uninstall() : await storeClashService.install();
    await storeClashService.init();
    await storeClashService.fetchStart(storeConfig.config.selected);
    await storeClashCore.waitStart();
  }

  Future languageSwitch() async {
    Intl.withLocale('en', () => null);
    // Localizations.override(context: context, locale: Locale('en', 'US'));
    Locale myLocale = Localizations.localeOf(context);
    print(myLocale);
    // if (Intl.defaultLocale == 'zh_CN') {
    //   await S.load(const Locale('en', 'US'));
    // } else {
    //   await S.load(const Locale('zh', 'CN'));
    // }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _isloaded
        ? Column(
            children: [
              Text(context.select((StoreConfig s) => s.config.selected)),
              TextButton(
                child: Text(
                  S.of(context).service_open,
                  style: TextStyle(color: context.select((StoreClashService s) => s.serviceMode) ? Colors.red : Colors.green),
                ),
                onPressed: clashServiceSwitch,
              ),
              TextButton(
                child: Text(S.of(context).language),
                onPressed: languageSwitch,
              )
            ],
          )
        : const Text('loading');
  }
}
