import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

import 'package:clash_for_flutter/const/const.dart';
import 'package:clash_for_flutter/types/config.dart';

const Map<String, dynamic> _defaultConfig = {
  'selected': 'example.yaml',
  'updateInterval': 86400,
  'updateSubsAtStart': false,
  'autoSetProxy': false,
  'startAtLogin': false,
  'breakConnections': false,
  'subs': [],
};

class StoreConfig with ChangeNotifier {
  late Config config;

  late String clashCoreApiAddress;
  late String clashCoreApiSecret;

  Future init() async {
    if (!await Paths.config.exists()) await Paths.config.create(recursive: true);
    if (!await Files.configCountryMmdb.exists()) await Files.assetsCountryMmdb.copy(Files.configCountryMmdb.path);
    if (!await Files.configWintun.exists()) await Files.assetsWintun.copy(Files.configWintun.path);

    if (await Files.configConfig.exists()) {
      final local = json.decode(await Files.configConfig.readAsString());
      config = Config.fromJson({..._defaultConfig, ...local});
    } else {
      config = Config.fromJson(_defaultConfig);
    }
    if (config.subs.isEmpty) {
      if (!await Files.configExample.exists()) await Files.assetsExample.copy(Files.configExample.path);
      config.subs.add(ConfigSub(name: 'example.yaml', url: '', updateTime: 0));
      config.selected = 'example.yaml';
    }
    await readClashCoreApi();
    notifyListeners();
  }

  Future save() async {
    await Files.configConfig.writeAsString(json.encode(config.toJson()));
  }

  Future readClashCoreApi() async {
    final _config = await File(path.join(Paths.config.path, config.selected)).readAsString();
    // https://github.com/dart-lang/yaml/issues/53
    final _extControl = RegExp(r'''(?<!#\s*)external-controller:\s+['"]?([^'"]+?)['"]?\s''').firstMatch(_config)?.group(1);
    final _secret = RegExp(r'''(?<!#\s*)secret:\s+['"]?([^'"]+?)['"]?\s''').firstMatch(_config)?.group(1);
    clashCoreApiAddress = (_extControl ?? '127.0.0.1:9090').replaceAll('0.0.0.0', '127.0.0.1');
    clashCoreApiSecret = _secret ?? '';
  }
}
