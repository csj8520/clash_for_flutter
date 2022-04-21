import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
    setState(() {
      _isloaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Text(_isloaded ? context.watch<StoreConfig>().config.selected : 'loading'),
    );
  }
}
