import 'package:bot_toast/bot_toast.dart';

import 'package:clash_for_flutter/utils/logger.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';
import 'package:clash_for_flutter/utils/base_page_controller.dart';

class PageRuleController extends BasePageController {
  @override
  Future<void> updateDate() async {
    if (!controllers.service.coreIsRuning.value) return;
    if (controllers.pageHome.pageController.page != 2) return;
    log.debug('call: updateDate in page-rule');

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
