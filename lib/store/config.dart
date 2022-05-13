import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_emoji/flutter_emoji.dart';

import 'package:clash_for_flutter/const/const.dart';
import 'package:clash_for_flutter/types/config.dart';

final Map<String, dynamic> _defaultConfig = {
  'selected': 'example.yaml',
  'updateInterval': 86400,
  'updateSubsAtStart': false,
  'setSystemProxy': false,
  'startAtLogin': false,
  'breakConnections': false,
  'language': 'zh_CN',
  'subs': [],
};

class StoreConfig extends GetxController {
  final dio = Dio();
  var config = Config.fromJson(_defaultConfig).obs;

  var clashCoreApiAddress = '127.0.0.1:9090'.obs;
  var clashCoreApiSecret = ''.obs;
  var clashCoreDns = ''.obs;

  Future<void> init() async {
    if (!await Paths.config.exists()) await Paths.config.create(recursive: true);
    if (!await Files.configCountryMmdb.exists()) await Files.assetsCountryMmdb.copy(Files.configCountryMmdb.path);
    if (Platform.isWindows && !await Files.configWintun.exists()) await Files.assetsWintun.copy(Files.configWintun.path);
    final locale = Get.deviceLocale!;
    _defaultConfig['language'] = '${locale.languageCode}_${locale.countryCode}';

    if (await Files.configConfig.exists()) {
      final local = json.decode(await Files.configConfig.readAsString());
      config.value = Config.fromJson({..._defaultConfig, ...local});
    } else {
      config.value = Config.fromJson(_defaultConfig);
    }
    if (config.value.subs.isEmpty) {
      if (!await Files.configExample.exists()) await Files.assetsExample.copy(Files.configExample.path);
      config.value.subs.add(ConfigSub(name: 'example.yaml', url: '', updateTime: 0));
      config.value.selected = 'example.yaml';
    }
    await readClashCoreApi();
  }

  Future<void> save() async {
    await Files.configConfig.writeAsString(json.encode(config.toJson()));
  }

  Future<void> readClashCoreApi() async {
    final configStr = await File(path.join(Paths.config.path, config.value.selected)).readAsString();
    // final emoji = EmojiParser();
    // final b = emoji.unemojify(_config);
    final configJson = loadYaml(configStr.replaceAll(EmojiParser.REGEX_EMOJI, 'emoji'));
    // print(_json["external-controller"]);
    // https://github.com/dart-lang/yaml/issues/53
    // final _extControl = RegExp(r'''(?<!#\s*)external-controller:\s+['"]?([^'"]+?)['"]?\s''').firstMatch(_config)?.group(1);
    // final _secret = RegExp(r'''(?<!#\s*)secret:\s+['"]?([^'"]+?)['"]?\s''').firstMatch(_config)?.group(1);
    clashCoreApiAddress.value = (configJson["external-controller"] ?? '127.0.0.1:9090').replaceAll('0.0.0.0', '127.0.0.1');
    clashCoreApiSecret.value = (configJson["secret"] ?? '');
    clashCoreDns.value = '';
    if (configJson["dns"]?["enable"] == true && (configJson["dns"]["listen"] ?? '').isNotEmpty) {
      final dns = (configJson["dns"]["listen"] as String).split(":");
      final ip = dns[0];
      final port = dns[1];
      if (port == '53') {
        clashCoreDns.value = ip == '0.0.0.0' ? '127.0.0.1' : ip;
      }
    }
  }

  Future<void> setLanguage(String language) async {
    config.value.language = language;
    await save();
    config.refresh();
  }

  Future<void> setSystemProxy(bool open) async {
    config.value.setSystemProxy = open;
    await save();
    config.refresh();
  }

  Future<void> setUpdateInterval(int value) async {
    config.value.updateInterval = value;
    await save();
    config.refresh();
  }

  Future<void> setUpdateSubsAtStart(bool value) async {
    config.value.updateSubsAtStart = value;
    await save();
    config.refresh();
  }

  Future<void> setSelectd(String selected) async {
    config.value.selected = selected;
    await save();
    config.refresh();
  }

  Future<bool> updateSub(ConfigSub sub) async {
    if ((sub.url ?? '').isEmpty) return false;
    final res = await dio.get(sub.url!);
    final file = File(path.join(Paths.config.path, sub.name));
    final oldConfig = await file.exists() ? await file.readAsString() : '';
    final changed = oldConfig != res.data;
    if (changed) await file.writeAsString(res.data);
    sub.updateTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await setSub(sub.name, sub);
    return changed;
  }

  Future<void> setSub(String subName, ConfigSub sub) async {
    final idx = config.value.subs.indexWhere((it) => it.name == subName);
    config.value.subs[idx] = sub;
    if (subName != sub.name) {
      final file = File(path.join(Paths.config.path, subName));
      if (await file.exists()) await file.rename(path.join(Paths.config.path, sub.name));
    }
    await save();
    config.refresh();
  }

  Future<void> addSub(ConfigSub sub) async {
    config.value.subs.add(sub);
    final file = File(path.join(Paths.config.path, sub.name));
    if (!await file.exists()) await file.create();
    await save();
    config.refresh();
  }

  Future<void> deleteSub(String subName) async {
    final file = File(path.join(Paths.config.path, subName));
    if (await file.exists()) await file.delete();
    config.value.subs.removeWhere((it) => it.name == subName);
    await save();
    config.refresh();
  }

  Future<void> setBreakConnections(bool value) async {
    config.value.breakConnections = value;
    await save();
    config.refresh();
  }
}
