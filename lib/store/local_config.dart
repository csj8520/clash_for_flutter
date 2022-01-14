import 'dart:convert';

import 'package:clashf_pro/utils/index.dart';
import 'package:mobx/mobx.dart';

import 'index.dart';

// Include generated file
part 'local_config.g.dart';

// This is the class used by rest of your codebase
class LocalConfigStore = _LocalConfigStore with _$LocalConfigStore;

// class LocalConfigSub {
//   String name;
//   int updateTime;
//   String? url;
//   LocalConfigSub({required this.name, required this.updateTime, this.url});
//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'updateTime': updateTime,
//       'url': url,
//     };
//   }
// }

// The store-class
abstract class _LocalConfigStore with Store {
  @observable
  Map<String, dynamic> _config = {
    'selected': 'example.yaml',
    'updateInterval': 86400,
    'autoSetProxy': false,
    'startAtLogin': false,
    'subs': [],
  };

  String get selected => _config['selected'];

  int get updateInterval => _config['updateInterval'];

  bool get autoSetProxy => _config['autoSetProxy'];

  bool get startAtLogin => _config['startAtLogin'];

  List<dynamic> get subs => _config['subs'];

  @action
  Future<void> readLocalConfig() async {
    if (await CONST.configFileJson.exists()) {
      final localConfig = json.decode(await CONST.configFileJson.readAsString());
      _config = {..._config, ...localConfig};
    }
  }

  @action
  Future<void> saveLocalConfig() async {
    await CONST.configFileJson.writeAsString(json.encode(_config));
  }

  @action
  void setStartAtLogin(bool value) {
    _config['startAtLogin'] = value;
    _config = _config;
    saveLocalConfig();
  }

  @action
  Future<void> setAutoSetProxy(bool value) async {
    if (value) {
      final httpPort = clashConfigStore.config['mixed-port'] ?? clashConfigStore.config['port'];
      final httpsPort = clashConfigStore.config['mixed-port'] ?? clashConfigStore.config['port'];
      final socksPort = clashConfigStore.config['mixed-port'] ?? clashConfigStore.config['socks-port'];
      await SystemProxy.instance.setProxy(SystemProxyConfig(
        http: SystemProxyState(enable: true, server: '127.0.0.1:$httpPort'),
        https: SystemProxyState(enable: true, server: '127.0.0.1:$httpsPort'),
        socks: SystemProxyState(enable: true, server: '127.0.0.1:$socksPort'),
      ));
    } else {
      await SystemProxy.instance.setProxy(SystemProxyConfig());
    }
    _config['autoSetProxy'] = value;
    _config = _config;
    saveLocalConfig();
  }
}
