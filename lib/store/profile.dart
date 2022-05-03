import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';

import 'package:clash_for_flutter/types/config.dart';
import 'package:clash_for_flutter/store/config.dart';
import 'package:clash_for_flutter/store/shortcuts.dart';
import 'package:clash_for_flutter/store/clash_core.dart';
import 'package:clash_for_flutter/store/clash_service.dart';
import 'package:clash_for_flutter/widgets/edit_profile.dart';

class StoreProfile extends GetxController {
  late StoreConfig storeConfig;
  late StoreClashService storeClashService;
  late StoreClashCore storeClashCore;
  late StoreSortcuts storeSortcuts;

  void init() {
    storeConfig = Get.find();
    storeClashService = Get.find();
    storeClashCore = Get.find();
    storeSortcuts = Get.find();
  }

  void showAddSubPopup(BuildContext context, ConfigSub? sub) {
    showDialog(context: context, builder: (_) => PageProfileEditProfile(title: '添加', name: sub?.name, url: sub?.url, onEnter: handleAddSub));
  }

  void showEditSubPopup(BuildContext context, ConfigSub sub) {
    showDialog(
        context: context, builder: (_) => PageProfileEditProfile(name: sub.name, url: sub.url, onEnter: (n, u, c) => handleEditSub(sub, n, u, c)));
  }

  Future<dynamic> handleAddSub(String name, String url, VoidCallback close) async {
    if (!RegExp(r'^[^.].*\.ya?ml$').hasMatch(name)) return BotToast.showText(text: '请确保文件后缀名为.yaml');
    final has = storeConfig.config.value.subs.firstWhereOrNull((it) => it.name == name);
    if (has != null) return BotToast.showText(text: "$name 已存在");
    final ConfigSub sub = ConfigSub(name: name, url: url.isEmpty ? null : url);
    await storeConfig.addSub(sub);
    close();
  }

  Future<dynamic> handleEditSub(ConfigSub oldSub, String name, String url, VoidCallback close) async {
    if (!RegExp(r'^[^.].*\.ya?ml$').hasMatch(name)) return BotToast.showText(text: '请确保文件后缀名为.yaml');
    final _sub = storeConfig.config.value.subs.firstWhere((it) => it.name == oldSub.name);
    final ConfigSub sub = ConfigSub(name: name, url: url.isEmpty ? null : url, updateTime: oldSub.updateTime);
    await storeConfig.setSub(_sub.name, sub);
    close();
  }

  Future<dynamic> handleUpdateSub(ConfigSub sub) async {
    try {
      final changed = await storeConfig.updateSub(sub);
      if (!changed) return BotToast.showText(text: '配置无变化');
      if (storeConfig.config.value.selected == sub.name) {
        await storeSortcuts.reloadClashCore();
      }
    } catch (e) {
      BotToast.showText(text: 'Update Sub: ${sub.name} Error');
    }
  }

  dynamic handleDeleteSub(BuildContext context, ConfigSub sub) {
    if (storeConfig.config.value.subs.length <= 1) return BotToast.showText(text: '请至少保留一个配置文件');
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('确定'),
        content: Text('删除 ${sub.name} 配置，磁盘内文件会同时删除。'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(c);
              await storeConfig.deleteSub(sub.name);
            },
            child: const Text('删除'),
          ),
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('取消')),
        ],
      ),
    );
  }

  Future<void> handleSelectSub(ConfigSub sub) async {
    await storeConfig.setSelectd(sub.name);
    await storeSortcuts.reloadClashCore();
  }
}
