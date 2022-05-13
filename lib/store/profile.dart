import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';

import 'package:clash_for_flutter/types/config.dart';
import 'package:clash_for_flutter/store/config.dart';
import 'package:clash_for_flutter/store/shortcuts.dart';
import 'package:clash_for_flutter/widgets/dialogs.dart';
import 'package:clash_for_flutter/store/clash_core.dart';
import 'package:clash_for_flutter/store/clash_service.dart';

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

  bool validatorSub(ConfigSub newSub, ConfigSub? oldSub) {
    if (!RegExp(r'^[^.].*\.ya?ml$').hasMatch(newSub.name)) {
      BotToast.showText(text: '请确保文件后缀名为.yaml');
      return false;
    }
    if (newSub.name == oldSub?.name) return true;
    final has = storeConfig.config.value.subs.any((it) => it.name == newSub.name);
    if (has) BotToast.showText(text: "${newSub.name} 已存在");
    return !has;
  }

  Future<void> showAddSubPopup(BuildContext context, ConfigSub? sub) async {
    final subDate = await showEditProfileDialog(context, sub: sub, title: '添加', validator: (n) => validatorSub(n, null));
    if (subDate == null) return;
    await storeConfig.addSub(subDate);
  }

  Future<void> showEditSubPopup(BuildContext context, ConfigSub sub) async {
    final subDate = await showEditProfileDialog(context, sub: sub, title: '编辑', validator: (n) => validatorSub(n, sub));
    if (subDate == null) return;
    if (subDate.name == sub.name && subDate.url == sub.url) return;
    await storeConfig.setSub(sub.name, subDate);
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

  dynamic handleDeleteSub(BuildContext context, ConfigSub sub) async {
    if (storeConfig.config.value.subs.length <= 1) return BotToast.showText(text: '请至少保留一个配置文件');
    final del = await showNormalDialog(context, title: "警告", content: '删除 ${sub.name} 配置，磁盘内文件会同时删除。', enterText: '删 除', cancelText: "取消");
    if (del != true) return;
    await storeConfig.deleteSub(sub.name);
  }

  Future<void> handleSelectSub(ConfigSub sub) async {
    await storeConfig.setSelectd(sub.name);
    await storeSortcuts.reloadClashCore();
  }
}
