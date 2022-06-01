import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';
import 'package:clash_for_flutter/types/clash_service.dart';
import 'package:clash_for_flutter/utils/base_page_controller.dart';
import 'package:clash_for_flutter/utils/logger.dart';
import 'package:clash_for_flutter/utils/utils.dart';
import 'package:day/day.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';

class PageLogController extends BasePageController {
  IOWebSocketChannel? logWsChannel;
  StreamSubscription<dynamic>? logWsChannelSub;
  RxList<ClashServiceLog> logs = <ClashServiceLog>[].obs;

  void initLogWs() {
    logWsChannel = controllers.service.fetchLogWs();
    logWsChannelSub = logWsChannel!.stream.listen(_handleLog, onDone: _handleOnDone, onError: (_) => _handleOnDone());
  }

  void _handleLog(dynamic event) {
    for (final it in (event as String).split('\n')) {
      final matchs = RegExp(r'^time="([\d-T:+]+)" level=(\w+) msg="(.+)"$').firstMatch(it.trim());

      final res = matchs?.groups([1, 2, 3]);
      final time = res?[0] ?? '1970-01-01T00:00:00+00:00';
      final type = res?[1] ?? 'debug';
      final msg = res?[2] ?? it;

      logs.add(ClashServiceLog(time: Day.fromString(time).format('YYYY-MM-DD HH:mm:ss'), type: type, msg: msg));
      if (logs.length > 1000) logs.removeAt(0);
    }
  }

  void _handleOnDone() {
    if (logWsChannel?.closeCode != WebSocketStatus.goingAway) {
      BotToast.showText(text: "连接异常断开");
    } else {}
    logWsChannelSub = null;
    logWsChannel = null;
  }

  @override
  Future<void> initDate() async {
    if (controllers.service.serviceStatus.value != RunningState.running) return;
    if (controllers.pageHome.pageController.page != 1) return;
    if (logWsChannel != null) return;
    log.debug('call: initDate in page-log');

    initLogWs();
  }

  @override
  Future<void> clearDate() async {
    if (logWsChannel == null && logWsChannelSub == null) return;
    log.debug('call: clearDate in page-log');
    await logWsChannelSub?.cancel();
    logWsChannelSub = null;
    await logWsChannel?.sink.close(WebSocketStatus.goingAway);
    logWsChannel = null;
    logs.clear();
  }
}
