import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';

import 'package:clash_for_flutter/types/config.dart';
import 'package:clash_for_flutter/widgets/dialogs.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';

class PageProfileController extends GetxController {
  bool validatorSub(ConfigSub newSub, ConfigSub? oldSub) {
    if (!RegExp(r'^[^.].*\.ya?ml$').hasMatch(newSub.name)) {
      BotToast.showText(text: '请确保文件后缀名为.yaml');
      return false;
    }
    if (newSub.name == oldSub?.name) return true;
    final has = controllers.config.config.value.subs.any((it) => it.name == newSub.name);
    if (has) BotToast.showText(text: "${newSub.name} 已存在");
    return !has;
  }

  Future<void> showAddSubPopup(BuildContext context, ConfigSub? sub) async {
    final subDate = await showEditProfileDialog(context, sub: sub, title: '添加', validator: (n) => validatorSub(n, null));
    if (subDate == null) return;
    await controllers.config.addSub(subDate);
  }

  Future<void> showEditSubPopup(BuildContext context, ConfigSub sub) async {
    final subDate = await showEditProfileDialog(context, sub: sub, title: '编辑', validator: (n) => validatorSub(n, sub));
    if (subDate == null) return;
    if (subDate.name == sub.name && subDate.url == sub.url) return;
    await controllers.config.setSub(sub.name, subDate);
  }

  Future<dynamic> handleUpdateSub(ConfigSub sub) async {
    try {
      final changed = await controllers.config.updateSub(sub);
      if (!changed) return BotToast.showText(text: '配置无变化');
      if (controllers.config.config.value.selected == sub.name) {
        await controllers.shortcuts.reloadClashCore();
      }
    } catch (e) {
      BotToast.showText(text: 'Update Sub: ${sub.name} Error');
    }
  }

  dynamic handleDeleteSub(BuildContext context, ConfigSub sub) async {
    if (controllers.config.config.value.subs.length <= 1) return BotToast.showText(text: '请至少保留一个配置文件');
    final del = await showNormalDialog(context, title: "警告", content: '删除 ${sub.name} 配置，磁盘内文件会同时删除。', enterText: '删 除', cancelText: "取消");
    if (del != true) return;
    await controllers.config.deleteSub(sub.name);
  }

  Future<void> handleSelectSub(ConfigSub sub) async {
    await controllers.config.setSelectd(sub.name);
    await controllers.shortcuts.reloadClashCore();
  }
}
