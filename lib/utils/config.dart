import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
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
  late dynamic _config;
  late YamlEditor _configEdit;

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

    clashConfigFile = File(path.join(CONST.configDir.path, _config['selected']));
  }

  Future<void> _loadConfig() async {
    final String config = await CONST.configFile.readAsString();
    _config = loadYaml(config);
    _configEdit = YamlEditor(config);
    // yamlEditor.update(['startAtLogin'], false);
    // yamlEditor.update(['list', 0, 'name'], '21346');
  }

  Future<void> _saveConfig() async {
    await CONST.configFile.writeAsString(_configEdit.toString());
    _config = loadYaml(_configEdit.toString());
  }

  void removeList(int idx) {
    _configEdit.remove(['list', idx]);
  }

  void addList(Object value) {
    _configEdit.insertIntoList(['list'], _config['list'].length, value);
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

    _config = loadYaml(_configEdit.toString());

    final locals = localConfigs.where((it) => !names.contains(it));
    for (var it in locals) {
      addList({'name': it, 'updateTime': 0, 'sub': ''});
    }
    await _saveConfig();
  }
}
