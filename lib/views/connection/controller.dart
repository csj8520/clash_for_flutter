import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:day/day.dart';
import 'package:easy_table/easy_table.dart';
import 'package:day/plugins/relative_time.dart';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:bot_toast/bot_toast.dart';
import 'package:web_socket_channel/io.dart';

import 'package:clash_for_flutter/utils/utils.dart';
import 'package:clash_for_flutter/utils/logger.dart';
import 'package:clash_for_flutter/types/connect.dart';
import 'package:clash_for_flutter/widgets/dialogs.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';

class PageConnectionController extends GetxController {
  var connect = Connect(downloadTotal: 0, uploadTotal: 0, connections: []).obs;

  var detail = Rx<ConnectConnection?>(null);
  var detailClosed = true.obs;

  final EasyTableModel<ConnectConnection> model = EasyTableModel<ConnectConnection>(rows: [], columns: []);

  String filter = '';

  IOWebSocketChannel? connectionsWsChannel;
  StreamSubscription<dynamic>? _connectionsWsChannelSub;
  Map<String, ConnectConnection> _connectionsCache = {};

  Future<void> init() async {
    log.debug('controller.connection.init()');
    model
      ..removeColumns()
      ..addColumns([
        EasyTableColumn(
          name: 'connection_columns_host'.tr,
          width: 260,
          // pinned: true,
          cellAlignment: Alignment.centerLeft,
          stringValue: (c) => '${c.metadata.host.isNotEmpty ? c.metadata.host : c.metadata.destinationIP}:${c.metadata.destinationPort}',
        ),
        EasyTableColumn(
          name: 'connection_columns_network'.tr,
          width: 80,
          stringValue: (c) => c.metadata.network,
        ),
        EasyTableColumn(
          name: 'connection_columns_type'.tr,
          width: 120,
          stringValue: (c) => c.metadata.type,
        ),
        EasyTableColumn(
          name: 'connection_columns_chains'.tr,
          width: 200,
          cellAlignment: Alignment.centerLeft,
          stringValue: (c) => c.chains.reversed.join('/'),
        ),
        EasyTableColumn(
          name: 'connection_columns_rule'.tr,
          width: 140,
          stringValue: (c) => '${c.rule}(${c.rulePayload})',
        ),
        EasyTableColumn(
          name: 'connection_columns_process'.tr,
          width: 100,
          stringValue: (c) => path.basename(c.metadata.processPath),
        ),
        EasyTableColumn(
          name: 'connection_columns_speed'.tr,
          width: 200,
          stringValue: (c) {
            final download = c.speed.download;
            final upload = c.speed.upload;
            if (upload == 0 && download == 0) return '-';
            if (upload == 0) return '↓ ${bytesToSize(download)}/s';
            if (download == 0) return '↑ ${bytesToSize(upload)}/s';
            return '↑ ${bytesToSize(upload)}/s ↓ ${bytesToSize(download)}/s';
          },
          sort: (a, b) => (a.speed.download + a.speed.upload) - (b.speed.download + b.speed.upload),
        ),
        EasyTableColumn(
          name: 'connection_columns_upload'.tr,
          width: 100,
          stringValue: (c) => bytesToSize(c.upload),
          sort: (a, b) => a.upload - b.upload,
        ),
        EasyTableColumn(
          name: 'connection_columns_download'.tr,
          width: 100,
          stringValue: (c) => bytesToSize(c.download),
          sort: (a, b) => a.download - b.download,
        ),
        EasyTableColumn(
          name: 'connection_columns_source_ip'.tr,
          width: 140,
          stringValue: (c) => c.metadata.sourceIP,
        ),
        EasyTableColumn(
          name: 'connection_columns_time'.tr,
          width: 120,
          stringValue: (c) => Day().from(Day.fromString(c.start)),
          sort: (a, b) => a.start.compareTo(b.start),
        ),
      ]);

    connectionsWsChannel = controllers.core.fetchConnectionsWs();
    _connectionsWsChannelSub = connectionsWsChannel!.stream.listen(_handleStream, onDone: _handleOnDone, onError: (_) => _handleOnDone());
  }

  Future<void> clear() async {
    log.debug('controller.connection.clear()');
    await _connectionsWsChannelSub?.cancel();
    _connectionsWsChannelSub = null;
    await connectionsWsChannel?.sink.close(WebSocketStatus.goingAway);
    connectionsWsChannel = null;
    _connectionsCache.clear();
    connect.value.connections.clear();
    connect.refresh();
    model.replaceRows(connect.value.connections);
  }

  void handleShowDetail(ConnectConnection? connection) {
    detail.value = connection;
    detailClosed.value = false;
  }

  void hanldeCloseAllConnections(BuildContext context) async {
    final res = await showNormalDialog(context,
        title: "connection_close_all_title".tr, content: 'connection_close_all_content'.tr, enterText: "model_ok".tr, cancelText: "model_cancel".tr);
    if (res != true) return;
    for (final it in connect.value.connections) {
      await controllers.core.fetchCloseConnections(it.id);
    }
  }

  void _handleStream(dynamic event) {
    connect.value = Connect.fromJson(json.decode(event));
    final cache = _connectionsCache;
    _connectionsCache = {};
    // handle speed
    for (var it in connect.value.connections) {
      final pre = cache[it.id];
      _connectionsCache[it.id] = it;
      if (pre == null) continue;
      it.speed.download = it.download - pre.download;
      it.speed.upload = it.upload - pre.upload;
    }
    // update detail
    if (detail.value != null && !detailClosed.value) {
      final n = _connectionsCache[detail.value!.id];
      if (n == null) {
        detailClosed.value = true;
      } else {
        detail.value = n;
      }
    }
    _handleFilter();
    model.replaceRows(connect.value.connections);
  }

  void _handleOnDone() {
    if (connectionsWsChannel?.closeCode != WebSocketStatus.goingAway) {
      BotToast.showText(text: "连接异常断开");
    } else {}
    _connectionsWsChannelSub = null;
    connectionsWsChannel = null;
    connect.value.connections.clear();
    connect.refresh();
  }

  bool _handleFilterExpression(String exp, List<String> strings) {
    if (exp.isEmpty) return true;
    exp = exp.replaceAll('!!', '');
    final l = exp.indexOf('(');
    if (l > -1) {
      final r = exp.lastIndexOf(')');
      if (r > -1) {
        final left = exp.substring(0, l).trim();
        final center = exp.substring(l + 1, r);
        final right = exp.substring(r + 1);
        return _handleFilterExpression('$left${_handleFilterExpression(center, strings)}$right', strings);
      } else {
        return false;
      }
    } else {
      final filtters =
          exp.split('|').map((e) => e.trim()).where((e) => e.isNotEmpty).map((e) => e.split('&').map((e) => e.trim()).where((e) => e.isNotEmpty));
      // print(filtters.map((e) => e.toList()).toList());
      return filtters.any((f) => f.every((t) => t[0] == '!'
          ? !strings.any((s) => t.substring(1) == 'true' || (t.substring(1) == 'false' ? false : s.contains(t.substring(1))))
          : strings.any((s) => t == 'true' || (t == 'false' ? false : s.contains(t)))));
    }
  }

  void _handleFilter() {
    if (filter.isNotEmpty) {
      // final filtters = filter
      //     .toLowerCase()
      //     .split('|')
      //     .map((e) => e.trim())
      //     .where((e) => e.isNotEmpty)
      //     .map((e) => e.split('&').map((e) => e.trim()).where((e) => e.isNotEmpty));

      connect.value.connections = connect.value.connections.where((it) {
        final List<String> strings = [];
        for (var i = 0; i < model.columnsLength; i++) {
          final column = model.columnAt(i);
          if (column.stringValueMapper == null) continue;
          final str = column.stringValueMapper!(it);
          if (str == null || str.isEmpty || str == '-') continue;
          strings.add(str.toLowerCase());
        }
        if (strings.isEmpty) return false;
        return _handleFilterExpression(filter.toLowerCase(), strings);
        // return filtters.any((f) => f.every((t) => t[0] == '!' ? !strings.any((s) => s.contains(t.substring(1))) : strings.any((s) => s.contains(t))));
      }).toList();
    }
  }
}
