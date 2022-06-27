import 'dart:io';
import 'dart:async';

import 'package:day/day.dart';
import 'package:get/get.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:web_socket_channel/io.dart';

import 'package:clash_for_flutter/utils/logger.dart';
import 'package:clash_for_flutter/types/clash_service.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';

class PageLogController extends GetxController {
  IOWebSocketChannel? logWsChannel;
  StreamSubscription<dynamic>? logWsChannelSub;
  RxList<ClashServiceLog> logs = <ClashServiceLog>[].obs;

  void _handleLog(dynamic event) {
    for (final it in (event as String).split('\n')) {
      final matchs = RegExp(r'^time="([\d-T:+]+)" level=(\w+) msg="(.+)"$').firstMatch(it.trim());

      final res = matchs?.groups([1, 2, 3]);
      final time = res?[0] ?? '1970-01-01T00:00:00+00:00';
      final type = res?[1] ?? 'debug';
      final msg = res?[2] ?? it;

      logs.add(ClashServiceLog(time: Day.fromString(time).toLocal().format('YYYY-MM-DD HH:mm:ss'), type: type, msg: msg));
      if (logs.length > 500) logs.removeRange(0, 200);
    }
  }

  void _handleOnDone() {
    if (logWsChannel?.closeCode != WebSocketStatus.goingAway) {
      BotToast.showText(text: "连接异常断开");
    } else {}
    logWsChannelSub = null;
    logWsChannel = null;
  }

  Future<void> init() async {
    // if (controllers.service.serviceStatus.value != RunningState.running) return;
    // if (controllers.pageHome.pageController.page != 1) return;
    // if (logWsChannel != null) return;
    log.debug('controller.log.init()');

    logWsChannel = controllers.service.fetchLogWs();
    logWsChannelSub = logWsChannel!.stream.listen(_handleLog, onDone: _handleOnDone, onError: (_) => _handleOnDone());
  }

  Future<void> clear() async {
    log.debug('controller.log.clear()');
    await logWsChannelSub?.cancel();
    logWsChannelSub = null;
    await logWsChannel?.sink.close(WebSocketStatus.goingAway);
    logWsChannel = null;
    logs.clear();
  }
}
