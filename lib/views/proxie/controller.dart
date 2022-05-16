import 'package:clash_for_flutter/utils/logger.dart';
import 'package:get/get.dart';
import 'package:bot_toast/bot_toast.dart';

import 'package:clash_for_flutter/types/proxie.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';

class PageProxieController extends GetxController {
  Future<void> updateProxie() async {
    log.debug('updateProxie');
    await controllers.core.fetchProxie();
    await controllers.core.fetchProxieProvider();
    // await controllers.tray.updateTray();
  }

  Future<void> handleSetProxieGroup(ProxieProxiesItem proxie, String value) async {
    if (proxie.now == value) return;
    await controllers.core.fetchSetProxieGroup(proxie.name, value);
    await controllers.core.fetchProxie();
    if (controllers.config.config.value.breakConnections) {
      final conn = await controllers.core.fetchConnection();
      for (final it in conn.connections) {
        if (it.chains.contains(proxie.name)) controllers.core.fetchCloseConnection(it.id);
      }
    }
    // await controllers.tray.updateTray();
  }

  Future<void> handleUpdateProvider(ProxieProviderItem provider) async {
    try {
      await controllers.core.fetchProxieProviderUpdate(provider.name);
      await controllers.core.fetchProxieProvider();
      await controllers.core.fetchProxie();
      // await controllers.tray.updateTray();
    } catch (e) {
      BotToast.showText(text: 'Updata Error');
    }
  }

  Future<void> handleHealthCheckProvider(ProxieProviderItem provider) async {
    try {
      await controllers.core.fetchProxieProviderHealthCheck(provider.name);
      await controllers.core.fetchProxieProvider();
      await controllers.core.fetchProxie();
      // await controllers.tray.updateTray();
    } catch (e) {
      BotToast.showText(text: 'Health Check Error');
    }
  }
}
