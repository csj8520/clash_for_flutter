import 'dart:convert';
// import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clashf_pro/utils/utils.dart';
import 'package:flutter/material.dart';
// import 'package:process_run/process_run.dart';
import 'package:process_run/shell.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

import 'package:webview_flutter/webview_flutter.dart';

// import 'package:desktop_webview_window/desktop_webview_window.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();

  // Add this your main method.
  // used to show a webview title bar.
  // if (runWebViewTitleBarWidget(['1234'])) {
  //   return;
  // }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final List<String> _logs = [];

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    log.on(onLog: (event) {
      setState(() {
        _logs.add(event);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(_logs.join('')).scrollable().constrained(height: 200),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            TextButton(
                onPressed: () async {
                  // Log.log(
                  //     (await WebviewWindow.isWebviewAvailable()).toString());
                  // final webview = await WebviewWindow.create();
                  // webview.launch(
                  //     'https://clash.razord.top/?host=127.0.0.1&port=3328#/proxies');

                  // (await rootBundle.load('assets/clash-windows-amd64.exe')).;

                  String config = await File(path.join(
                          userHomePath, '.config/clash-pro/.config.yaml'))
                      .readAsString();

                  log.log(config);
                  // log.log(path.('basename'));
                  log.log(path.absolute('absolute'));
                  log.log('getApplicationDocumentsDirectory: ',
                      (await getApplicationDocumentsDirectory()));

                  log.log(userAppDataPath);
                  log.log(userHomePath);
                  log.log(path.join(userHomePath, '.config/clash-pro'));

                  log.time('exec time');
                  final out =
                      await Process.run(getPath(), ['-v'], runInShell: false);
                  log.log(out.stdout.toString());
                  log.timeEnd('exec time');

                  log.time('reg');
                  final reg = await Process.run(
                      'reg',
                      [
                        'query',
                        'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings',
                        '/v',
                        'ProxyServer'
                      ],
                      runInShell: false);
                  log.timeEnd('reg');
                  log.log(reg);
                  log.log(reg.stdout);
                  log.log(reg.stderr);

                  // final calsh = await Process.start(
                  //     getPath(),
                  //     [
                  //       '-d',
                  //       path.join(userHomePath, '.config/clash-pro'),
                  //       '-f',
                  //       path.join(userHomePath, '.config/clash-pro/clash.yaml'),
                  //     ],
                  //     runInShell: false);
                  // calsh.stdout.listen((event) async {
                  //   stdout.add(event);
                  //   setState(() {
                  //     _logs.add(utf8.decode(event));
                  //   });
                  // });

                  // Future.delayed(const Duration(seconds: 10), () {
                  //   log.log('clash is killed:', calsh.kill());
                  // });

                  log.log(getPath());
                },
                child: const Text('132'))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
