import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:clashf_pro/fetch/index.dart';
import 'package:path/path.dart' as path;

import 'package:mobx/mobx.dart';

import 'package:clashf_pro/utils/index.dart';

import 'index.dart';

// Include generated file
part 'local_config.g.dart';

// This is the class used by rest of your codebase
class LocalConfigStore = _LocalConfigStore with _$LocalConfigStore;

// class LocalConfigSub {
//   String name;
//   int? updateTime;
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
    'updateSubsAtStart': false,
    'autoSetProxy': false,
    'startAtLogin': false,
    'subs': [],
  };

  String get selected => _config['selected'];

  int get updateInterval => _config['updateInterval'];

  bool get updateSubsAtStart => _config['updateSubsAtStart'];

  bool get autoSetProxy => _config['autoSetProxy'];

  bool get startAtLogin => _config['startAtLogin'];

  List<dynamic> get subs => _config['subs'];

  final configNameTest = RegExp(r'^[^.].*\.ya?ml$');
  late File clashConfigFile;

  @observable
  String clashApiAddress = '127.0.0.1:9090';
  @observable
  String clashApiSecret = '';

  Timer? _regularlyUpdateSubsTimer;

  @action
  Future<void> readLocalConfig() async {
    if (await CONST.configFile.exists()) {
      final localConfig = json.decode(await CONST.configFile.readAsString());
      _config = {..._config, ...localConfig};
    }
    await _fixConfig();
    await _setClashConfigFile();
  }

  Future<void> _fixConfig() async {
    if (!(await CONST.configDir.exists())) await CONST.configDir.create(recursive: true);
    final geoip = File(path.join(CONST.configDir.path, 'Country.mmdb'));
    if (!(await geoip.exists())) {
      await File(path.join(CONST.assetsDir.path, 'geoip', 'Country.mmdb')).copy(geoip.path);
    }
    final configDirFileList = await CONST.configDir.list().toList();
    final localDirConfigs = configDirFileList.map((it) => path.basename(it.uri.path)).where((it) => configNameTest.hasMatch(it)).toList();
    List<dynamic> currentNames = subs.map((it) => it['name']).toList();
    final removedConfigIdxs = currentNames.asMap().keys.where((it) => !localDirConfigs.contains(currentNames[it])).toList();
    for (var idx in removedConfigIdxs.reversed) {
      currentNames.removeAt(idx);
      subs.removeAt(idx);
    }
    final localDirAddConfigs = localDirConfigs.where((it) => !currentNames.contains(it)).toList();
    for (var name in localDirAddConfigs) {
      currentNames.add(name);
      subs.add({'name': name});
    }

    if (currentNames.isEmpty) {
      final defExample = File(path.join(CONST.assetsDir.path, 'example', 'example.yaml'));
      await defExample.copy(path.join(CONST.configDir.path, 'example.yaml'));
      currentNames.add('example.yaml');
      subs.add({'name': 'example.yaml'});
    }

    if (!currentNames.contains(selected)) _config['selected'] = subs[0]['name'];
  }

  Future<void> _setClashConfigFile() async {
    clashConfigFile = File(path.join(CONST.configDir.path, _config['selected']));
    final config = await clashConfigFile.readAsString();
    // https://github.com/dart-lang/yaml/issues/53
    // clashConfig = loadYaml(config, recover: true);
    final _extControl = RegExp(r'''[^#]\s+?external-controller:\s+['"]?([^'"]+?)['"]?\n''').firstMatch(config)?.group(1);
    final _secret = RegExp(r'''[^#]\s+?secret:\s+['"]?([^'"]+?)['"]?\n''').firstMatch(config)?.group(1);
    clashApiAddress = (_extControl ?? '127.0.0.1:9090').replaceAll('0.0.0.0', '127.0.0.1');
    clashApiSecret = _secret ?? '';
  }

  @action
  Future<void> saveLocalConfig() async {
    await CONST.configFile.writeAsString(json.encode(_config));
  }

  @action
  Future<void> setStartAtLogin(bool value) async {
    _config['startAtLogin'] = value;
    _config = _config;
    await saveLocalConfig();
  }

  @action
  Future<void> setAutoSetProxy(bool value) async {
    await globalStore.setProxy(value);
    _config['autoSetProxy'] = value;
    _config = _config;
    await saveLocalConfig();
  }

  @action
  Future<void> setSelected(String value) async {
    _config['selected'] = value;
    _config = _config;
    await saveLocalConfig();
  }

  @action
  Future<void> setUpdateInterval(int value) async {
    _config['updateInterval'] = value;
    _config = _config;
    await saveLocalConfig();
    regularlyUpdateSubs();
  }

  @action
  Future<void> setUpdateSubsAtStart(bool value) async {
    _config['updateSubsAtStart'] = value;
    _config = _config;
    await saveLocalConfig();
  }

  @action
  Future<void> setSub(String subName, Map<String, dynamic> value) async {
    final idx = (_config['subs'] as List<dynamic>).indexWhere((it) => it['name'] == subName);
    _config['subs'][idx] = value;
    _config = _config;
    if (subName != value['name']) {
      final file = File(path.join(CONST.configDir.path, subName));
      await file.rename(path.join(CONST.configDir.path, value['name']));
    }
    await saveLocalConfig();
  }

  @action
  Future<void> updateSub(Map<String, dynamic> sub) async {
    final String? url = sub['url'];
    if (url == null) return;
    log.info('Start Update Sub: ${sub['name']}');
    log.time('Update Sub Success');
    final res = await dio.get(url);
    final file = File(path.join(CONST.configDir.path, sub['name']));
    await file.writeAsString(res.data);
    sub['updateTime'] = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await setSub(sub['name'], sub);
    log.timeEnd('Update Sub Success');
  }

  @action
  Future<void> addSub(Map<String, dynamic> sub) async {
    final file = File(path.join(CONST.configDir.path, sub['name']));
    if (!(await file.exists())) await file.create();
    _config['subs'].add(sub);
    _config = _config;
    await saveLocalConfig();
  }

  @action
  Future<void> removeSub(Map<String, dynamic> sub) async {
    (_config['subs'] as List<dynamic>).removeWhere((it) => it['name'] == sub['name']);
    final file = File(path.join(CONST.configDir.path, sub['name']));
    await file.delete();
    _config = _config;
    await saveLocalConfig();
  }

  @action
  void regularlyUpdateSubs() {
    _regularlyUpdateSubsTimer?.cancel();
    _regularlyUpdateSubsTimer = Timer.periodic(Duration(seconds: updateInterval), (_) async {
      for (var it in subs) {
        if (it['url'] == null) continue;
        await updateSub(it);
        if (localConfigStore.selected == it['name']) {
          BotToast.showText(text: '正在重启 Clash ……');
          await globalStore.restartClash();
          BotToast.showText(text: '重启成功');
        }
      }
    });
  }

  @action
  Future<void> updateSubs() async {
    for (var it in subs) {
      await updateSub(it);
    }
  }
}
