import 'package:clash_for_flutter/src/fetch/service.dart';
import 'package:clash_for_flutter/src/utils/service.dart';
import 'package:mobx/mobx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:bot_toast/bot_toast.dart';

import 'package:clash_for_flutter/src/types/index.dart';
import 'package:clash_for_flutter/src/utils/index.dart';
import 'package:clash_for_flutter/src/fetch/index.dart';

import 'index.dart';

// Include generated file
part 'global.g.dart';

// This is the class used by rest of your codebase
class GlobalStore = _GlobalStore with _$GlobalStore;

// The store-class
abstract class _GlobalStore with Store {
  @observable
  bool inited = false;

  @observable
  bool serviceMode = false;

  @observable
  ClashVersion? clashVersion;

  @action
  Future<void> init() async {
    try {
      await initConfig();
      if (localConfigStore.updateSubsAtStart) await localConfigStore.updateSubs();
      await initClash();
      if (localConfigStore.autoSetProxy) await setProxy(true);
      localConfigStore.regularlyUpdateSubs();
      inited = true;
    } catch (e) {
      BotToast.showNotification(
        title: (_) => const Text('Error'),
        leading: (_) => const Icon(Icons.error_outline, color: Colors.red),
        trailing: (cancel) => IconButton(icon: const Icon(Icons.cancel), onPressed: cancel),
        subtitle: (_) => Text(e.toString()),
        duration: null,
      );
    }
  }

  @action
  Future<void> restartClash() async {
    try {
      inited = false;
      await initConfig();
      await initClash();
      if (localConfigStore.autoSetProxy) await setProxy(true);
      inited = true;
    } catch (e) {
      BotToast.showNotification(
        title: (_) => const Text('Error'),
        leading: (_) => const Icon(Icons.error_outline, color: Colors.red),
        trailing: (cancel) => IconButton(icon: const Icon(Icons.cancel), onPressed: cancel),
        subtitle: (_) => Text(e.toString()),
        duration: null,
      );
    }
  }

  @action
  Future<void> initConfig() async {
    await localConfigStore.readLocalConfig();
    print(localConfigStore.clashApiAddress);
    clashDio.options.baseUrl = 'http://${localConfigStore.clashApiAddress}';
    if (localConfigStore.clashApiSecret.isNotEmpty) clashDio.options.headers['Authorization'] = 'Bearer ${localConfigStore.clashApiSecret}';
  }

  @action
  Future<void> initClash() async {
    clash?.kill();
    try {
      final status = await fetchClashServiceStatus();
      if (status["status"] == 'running') await fetchClashServiceStop();
      await fetchClashServiceStart({
        "args": ['-d', CONST.configDir.path, '-f', localConfigStore.clashConfigFile.path]
      });
      while (true) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (await fetchClashHello()) break;
        final s = await fetchClashServiceStatus();
        if (s["status"] == 'stopped') throw "Start Clash Failed";
      }
      serviceMode = true;
    } catch (e) {
      serviceMode = false;
      if (kDebugMode) await killProcess(CONST.clashBinName);
      await startClash();
    }
    clashVersion = await fetchClashVersion();
    await clashApiConfigStore.updateConfig();
  }

  SystemProxyConfig get proxyConfig {
    final mixedPort = clashApiConfigStore.mixedPort == 0 ? null : clashApiConfigStore.mixedPort;
    final httpPort = mixedPort ?? clashApiConfigStore.port;
    final httpsPort = mixedPort ?? clashApiConfigStore.port;
    final socksPort = mixedPort ?? clashApiConfigStore.socksPort;
    return SystemProxyConfig(
      http: httpPort == null ? null : SystemProxyState(enable: true, server: '127.0.0.1:$httpPort'),
      https: httpsPort == null ? null : SystemProxyState(enable: true, server: '127.0.0.1:$httpsPort'),
      socks: socksPort == null ? null : SystemProxyState(enable: true, server: '127.0.0.1:$socksPort'),
    );
  }

  @action
  Future<void> setProxy(bool value) async {
    if (value) {
      await SystemProxy.instance.setProxy(proxyConfig);
    } else {
      await SystemProxy.instance.setProxy(SystemProxyConfig());
    }
  }

  @action
  Future<void> setServiceMode(bool value) async {
    if (value) {
      await installService();
    } else {
      await unInstallService();
    }
    await Future.delayed(Duration(seconds: 1));
    await restartClash();
  }
}
