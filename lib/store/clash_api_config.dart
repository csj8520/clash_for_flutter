import 'package:clash_pro_for_flutter/fetch/index.dart';
import 'package:mobx/mobx.dart';

// Include generated file
part 'clash_api_config.g.dart';

// This is the class used by rest of your codebase
class ClashApiConfigStore = _ClashApiConfigStore with _$ClashApiConfigStore;

// The store-class
abstract class _ClashApiConfigStore with Store {
  @observable
  Map<String, dynamic> config = {};

  bool get allowLan => config['allow-lan'];
  String get mode => config['mode'];
  int? get port => config['port'];
  int? get socksPort => config['socks-port'];
  int? get mixedPort => config['mixed-port'];

  @action
  Future<void> updateConfig() async {
    config = await fetchClashConfig();
  }

  @action
  Future<void> setAllowLan(bool value) async {
    await fetchClashConfigUpdate({'allow-lan': value});
    await updateConfig();
  }

  @action
  Future<void> setMode(String value) async {
    await fetchClashConfigUpdate({'mode': value});
    await updateConfig();
  }
}
