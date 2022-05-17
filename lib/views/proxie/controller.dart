import 'package:bot_toast/bot_toast.dart';

import 'package:clash_for_flutter/types/proxie.dart';
import 'package:clash_for_flutter/utils/logger.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';
import 'package:clash_for_flutter/utils/base_page_controller.dart';

class PageProxieController extends BasePageController {
  @override
  Future<void> updateDate() async {
    if (!controllers.service.coreIsRuning.value) return;
    if (controllers.pageHome.pageController.page != 0) return;
    log.debug('call: updateDate in page-proxie');

    await controllers.core.updateProxie();
    await controllers.core.updateProxieProvider();
    await controllers.core.updateConfig();
  }

  Future<void> handleSetProxieGroup(ProxieProxiesItem proxie, String value) async {
    if (proxie.now == value) return;
    await controllers.core.fetchSetProxieGroup(proxie.name, value);
    await controllers.core.updateProxie();
    if (controllers.config.config.value.breakConnections) {
      final conn = await controllers.core.fetchConnection();
      for (final it in conn.connections) {
        if (it.chains.contains(proxie.name)) controllers.core.fetchCloseConnections(it.id);
      }
    }
  }

  Future<void> handleUpdateProvider(ProxieProviderItem provider) async {
    try {
      await controllers.core.fetchProxieProviderUpdate(provider.name);
      await controllers.core.updateProxieProvider();
      await controllers.core.updateProxie();
    } catch (e) {
      BotToast.showText(text: 'Updata Error');
    }
  }

  Future<void> handleHealthCheckProvider(ProxieProviderItem provider) async {
    try {
      await controllers.core.fetchProxieProviderHealthCheck(provider.name);
      await controllers.core.updateProxieProvider();
      await controllers.core.updateProxie();
    } catch (e) {
      BotToast.showText(text: 'Health Check Error');
    }
  }
}
