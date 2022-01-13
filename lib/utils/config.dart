import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';
import 'package:path/path.dart' as path;

import 'index.dart';

const String _defConfig = '''
selected: example.yaml
updateInterval: 86400
autoSetProxy: true
startAtLogin: false
list:
  - name: example.yaml
    updateTime: 0
    sub:
''';

class Config {
  static Config instance = Config();

  late File clashConfigFile;
  late dynamic clashConfig;
  late dynamic _config;
  late YamlEditor _configEdit;

  Future<void> _loadConfig() async {
    final String config = await CONST.configFile.readAsString();
    _config = loadYaml(config);
    _configEdit = YamlEditor(config);
    // yamlEditor.update(['startAtLogin'], false);
    // yamlEditor.update(['list', 0, 'name'], '21346');
  }

  Future<void> _fixConfig() async {
    final fileList = await CONST.configDir.list().toList();
    final test = RegExp(r'^[^.].*\.ya?ml$');
    final localConfigs = fileList.map((it) => path.basename(it.uri.path)).where((it) => test.hasMatch(it)).toList();
    final List<dynamic> list = _config['list'] ?? [];
    List<dynamic> names = list.map((it) => it['name']).toList();

    final removeConfigs = names.asMap().keys.where((it) => !localConfigs.contains(names[it])).toList();
    for (var idx in removeConfigs) {
      names.removeAt(idx);
      removeList(idx);
    }

    final locals = localConfigs.where((it) => !names.contains(it)).toList();
    for (var it in locals) {
      names.add(it);
      addList({'name': it, 'updateTime': 0, 'sub': ''});
    }
    final unselected = !names.contains(_config['selected']);
    if (unselected) updateSelected(names[0]);
    if (removeConfigs.isNotEmpty || locals.isNotEmpty || unselected) await saveConfig();
  }

  void _updateConfig() {
    _config = loadYaml(_configEdit.toString());
  }

  Future<void> _setClashConfigFile() async {
    clashConfigFile = File(path.join(CONST.configDir.path, _config['selected']));
    final config = await clashConfigFile.readAsString();
    // clashConfig = loadYaml(config, recover: true);
    final extControl = RegExp(r'''external-controller:\s*['"]?(.+?)['"]?\n''').firstMatch(config)?.group(1);
    final secret = RegExp(r'''secret:\s*['"]?(.+?)['"]?\n''').firstMatch(config)?.group(1);
    clashConfig = {'external-controller': extControl, 'secret': secret};
  }

  Future<void> init() async {
    if (!(await CONST.configFile.exists())) {
      await CONST.configFile.writeAsString(_defConfig);
      final example = File(path.join(CONST.configDir.path, 'example.yaml'));
      if (!example.existsSync()) {
        final defExample = await File(path.join(CONST.assetsDir.path, 'example.yaml')).readAsString();
        await example.writeAsString(defExample);
      }
    }

    await _loadConfig();
    await _fixConfig();
    await _setClashConfigFile();
  }

  Future<void> saveConfig() async {
    await CONST.configFile.writeAsString(_configEdit.toString());
  }

  void removeList(int idx) {
    _configEdit.remove(['list', idx]);
    _updateConfig();
  }

  void addList(Object value) {
    if (_config['list'] == null) {
      _configEdit.update(['list'], [value]);
    } else {
      _configEdit.insertIntoList(['list'], _config['list'].length ?? 0, value);
    }
    _updateConfig();
  }

  void editList(int idx, Object value) {
    _configEdit.update(['list', idx], value);
  }

  void updateSelected(String name) {
    _configEdit.update(['selected'], name);
    _updateConfig();
  }

  bool get startAtLogin => _config['startAtLogin'] ?? false;
  set startAtLogin(bool value) {
    _configEdit.update(['startAtLogin'], value);
    _updateConfig();
  }

  bool get autoSetProxy => _config['autoSetProxy'] ?? false;
  set autoSetProxy(bool value) {
    _configEdit.update(['autoSetProxy'], value);
    _updateConfig();
  }

  List<dynamic> get list => _config['list'] ?? [];
}
