import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';

import 'package:clash_for_flutter/types/config.dart';
import 'package:clash_for_flutter/widgets/dialogs.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';

class PageProfileController extends GetxController {
  bool validatorSub(ConfigSub newSub, ConfigSub? oldSub) {
    if (!RegExp(r'^[^.].*\.ya?ml$').hasMatch(newSub.name)) {
      BotToast.showText(text: 'profile_config_ext_error'.tr);
      return false;
    }
    if (newSub.name == oldSub?.name) return true;
    final has = controllers.config.config.value.subs.any((it) => it.name == newSub.name);
    if (has) BotToast.showText(text: 'profile_config_already_exists'.trParams({"name": newSub.name}));
    return !has;
  }

  Future<void> showAddSubPopup(BuildContext context, ConfigSub? sub) async {
    final subDate = await showEditProfileDialog(context, sub: sub, title: 'profile_config_add'.tr, validator: (n) => validatorSub(n, null));
    if (subDate == null) return;
    await controllers.config.addSub(subDate);
  }

  Future<void> showEditSubPopup(BuildContext context, ConfigSub sub) async {
    final subDate = await showEditProfileDialog(context, sub: sub, title: 'profile_config_edit'.tr, validator: (n) => validatorSub(n, sub));
    if (subDate == null) return;
    if (subDate.name == sub.name && subDate.url == sub.url) return;
    await controllers.config.setSub(sub.name, subDate);
  }

  Future<dynamic> handleUpdateSub(ConfigSub sub) async {
    try {
      final changed = await controllers.config.updateSub(sub);
      if (!changed) return BotToast.showText(text: 'profile_config_no_change'.tr);
      if (controllers.config.config.value.selected == sub.name) {
        await controllers.service.reloadClashCore();
      }
    } catch (e) {
      BotToast.showText(text: 'profile_config_update_error'.trParams({"name": sub.name}));
    }
  }

  dynamic handleDeleteSub(BuildContext context, ConfigSub sub) async {
    if (controllers.config.config.value.subs.length <= 1) return BotToast.showText(text: 'profile_config_keep_one'.tr);
    final del = await showNormalDialog(context,
        title: "profile_config_mode_title".tr,
        content: 'profile_config_mode_content'.trParams({"name": sub.name}),
        enterText: 'model_delete'.tr,
        cancelText: "model_cancel".tr);
    if (del != true) return;
    await controllers.config.deleteSub(sub.name);
  }

  Future<void> handleSelectSub(ConfigSub sub) async {
    await controllers.config.setSelectd(sub.name);
    await controllers.service.reloadClashCore();
  }
}
