import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:clash_for_flutter/utils/logger.dart';
import 'package:day/day.dart';
import 'package:day/plugins/relative_time.dart';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:bot_toast/bot_toast.dart';
import 'package:web_socket_channel/io.dart';

import 'package:clash_for_flutter/types/table.dart';
import 'package:clash_for_flutter/utils/utils.dart';
import 'package:clash_for_flutter/types/connect.dart';
import 'package:clash_for_flutter/widgets/dialogs.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';
import 'package:clash_for_flutter/utils/base_page_controller.dart';

class PageConnectionController extends BasePageController {
  List<TableItem<ConnectConnection>> get tableItems {
    return [
      TableItem(
        head: 'connection_columns_host'.tr,
        width: 260,
        align: Alignment.centerLeft,
        getLabel: (c) => '${c.metadata.host.isNotEmpty ? c.metadata.host : c.metadata.destinationIP}:${c.metadata.destinationPort}',
      ),
      TableItem(head: 'connection_columns_network'.tr, width: 80, align: Alignment.center, getLabel: (c) => c.metadata.network),
      TableItem(head: 'connection_columns_type'.tr, width: 120, align: Alignment.center, getLabel: (c) => c.metadata.type),
      TableItem(
          head: 'connection_columns_chains'.tr, width: 200, align: Alignment.centerLeft, tooltip: true, getLabel: (c) => c.chains.reversed.join('/')),
      TableItem(head: 'connection_columns_rule'.tr, width: 140, align: Alignment.center, getLabel: (c) => '${c.rule}(${c.rulePayload})'),
      TableItem(head: 'connection_columns_process'.tr, width: 100, align: Alignment.center, getLabel: (c) => path.basename(c.metadata.processPath)),
      TableItem(
        head: 'connection_columns_speed'.tr,
        width: 200,
        align: Alignment.center,
        getLabel: (c) {
          final download = c.speed.download;
          final upload = c.speed.upload;
          if (upload == 0 && download == 0) return '-';
          if (upload == 0) return '↓ ${bytesToSize(download)}/s';
          if (download == 0) return '↑ ${bytesToSize(upload)}/s';
          return '↑ ${bytesToSize(upload)}/s ↓ ${bytesToSize(download)}/s';
        },
        sort: (a, b) => (a.speed.download + a.speed.upload) - (b.speed.download + b.speed.upload),
      ),
      TableItem(
        head: 'connection_columns_upload'.tr,
        width: 100,
        align: Alignment.center,
        getLabel: (c) => bytesToSize(c.upload),
        sort: (a, b) => a.upload - b.upload,
      ),
      TableItem(
        head: 'connection_columns_download'.tr,
        width: 100,
        align: Alignment.center,
        getLabel: (c) => bytesToSize(c.download),
        sort: (a, b) => a.download - b.download,
      ),
      TableItem(head: 'connection_columns_source_ip'.tr, width: 140, align: Alignment.center, getLabel: (c) => c.metadata.sourceIP),
      TableItem(
        head: 'connection_columns_time'.tr,
        width: 120,
        align: Alignment.center,
        getLabel: (c) => Day().from(Day.fromString(c.start)),
        sort: (a, b) => a.start.compareTo(b.start),
      ),
    ];
  }

  var connect = Connect(downloadTotal: 0, uploadTotal: 0, connections: []).obs;
  var sortBy = Rx<TableItem<ConnectConnection>?>(null);
  var sortAscend = false.obs;

  var detail = Rx<ConnectConnection?>(null);
  var detailClosed = true.obs;

  String filter = '';

  IOWebSocketChannel? connectionsWsChannel;
  StreamSubscription<dynamic>? _connectionsWsChannelSub;
  Map<String, ConnectConnection> _connectionsCache = {};

  @override
  Future<void> initDate() async {
    if (!controllers.service.coreIsRuning.value) return;
    if (controllers.pageHome.pageController.page != 3) return;
    if (controllers.pageConnection.connectionsWsChannel != null) return;
    log.debug('call: initDate in page-connection');

    sortBy.value = tableItems.last;
    connectionsWsChannel = controllers.core.fetchConnectionsWs();
    _connectionsWsChannelSub = connectionsWsChannel!.stream.listen(_handleStream, onDone: _handleOnDone, onError: (_) => _handleOnDone());
  }

  @override
  Future<void> clearDate() async {
    if (connectionsWsChannel == null && _connectionsWsChannelSub == null) return;
    log.debug('call: clearDate in page-connection');
    await _connectionsWsChannelSub?.cancel();
    _connectionsWsChannelSub = null;
    await connectionsWsChannel?.sink.close(WebSocketStatus.goingAway);
    connectionsWsChannel = null;
    connect.value.connections.clear();
    connect.refresh();
  }

  void handleSetSort(TableItem<ConnectConnection> item) {
    if (sortBy.value == item) {
      if (sortAscend.value) {
        sortBy.value = null;
      } else {
        sortAscend.value = true;
      }
    } else {
      sortBy.value = item;
      sortAscend.value = false;
    }
    _handleSort();
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
    _handleSort();
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

  void _handleFilter() {
    if (filter.isNotEmpty) {
      connect.value.connections = connect.value.connections.where((it) {
        final str = ('${it.metadata.host.isEmpty ? it.metadata.destinationIP : it.metadata.host}:${it.metadata.destinationPort}'
                '|${it.metadata.sourceIP}|${it.metadata.processPath}|${it.metadata.network}|${it.metadata.type}'
                '|${it.rule}(${it.rulePayload})|${it.chains.join('/')}')
            .toLowerCase();
        return filter.toLowerCase().split('|').any((f) => f.split('&').every((t) => str.contains(t.trim())));
      }).toList();
    }
  }

  void _handleSort() {
    if (sortBy.value == null) return;
    final sort = sortBy.value!.sort;
    connect.value.connections.sort((a, b) {
      final va = sortAscend.value ? a : b;
      final vb = sortAscend.value ? b : a;

      if (sort != null) {
        return sort(va, vb);
      } else {
        return sortBy.value!.getLabel(va).compareTo(sortBy.value!.getLabel(vb));
      }
    });
  }
}
