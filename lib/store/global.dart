import 'package:clashf_pro/types/index.dart';
import 'package:clashf_pro/utils/index.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

import 'package:clashf_pro/fetch/index.dart';

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
  ClashVersion? clashVersion;

  @action
  Future<void> init() async {
    await initConfig();
    if (localConfigStore.updateSubsAtStart) await localConfigStore.updateSubs();
    localConfigStore.regularlyUpdateSubs();
    await initClash();
    if (localConfigStore.autoSetProxy) await setProxy(true);
    inited = true;
  }

  @action
  Future<void> restartClash() async {
    inited = false;
    await initConfig();
    await initClash();
    if (localConfigStore.autoSetProxy) await setProxy(true);
    inited = true;
  }

  @action
  Future<void> initConfig() async {
    await localConfigStore.readLocalConfig();
    clashDio.options.baseUrl = 'http://${localConfigStore.clashApiAddress}';
    if (localConfigStore.clashApiSecret.isNotEmpty) clashDio.options.headers['Authorization'] = 'Bearer ${localConfigStore.clashApiSecret}';
  }

  @action
  Future<void> initClash() async {
    if (kDebugMode) await forceKillClash();
    await startClash();
    clashVersion = await fetchClashVersion();
    await clashApiConfigStore.updateConfig();
  }

  @action
  Future<void> setProxy(bool value) async {
    if (value) {
      final httpPort = clashApiConfigStore.mixedPort ?? clashApiConfigStore.port;
      final httpsPort = clashApiConfigStore.mixedPort ?? clashApiConfigStore.port;
      final socksPort = clashApiConfigStore.mixedPort ?? clashApiConfigStore.socksPort;
      await SystemProxy.instance.setProxy(SystemProxyConfig(
        http: httpPort == null ? null : SystemProxyState(enable: true, server: '127.0.0.1:$httpPort'),
        https: httpsPort == null ? null : SystemProxyState(enable: true, server: '127.0.0.1:$httpsPort'),
        socks: socksPort == null ? null : SystemProxyState(enable: true, server: '127.0.0.1:$socksPort'),
      ));
    } else {
      await SystemProxy.instance.setProxy(SystemProxyConfig());
    }
  }
}
