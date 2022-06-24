import 'package:get/get.dart';
import 'package:bot_toast/bot_toast.dart';

import 'package:clash_for_flutter/utils/logger.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';

class PageRuleController extends GetxController {
  Future<void> updateDate() async {
    log.debug('controller.rule.updateDate()');
    await controllers.core.updateRuleProvider();
    await controllers.core.updateRule();
  }

  Future<void> handleRuleProviderUpdate(String name) async {
    try {
      await controllers.core.fetchRuleProviderUpdate(name);
      await controllers.core.updateRuleProvider();
    } catch (e) {
      BotToast.showText(text: 'Update Rule: $name Error');
    }
  }
}
