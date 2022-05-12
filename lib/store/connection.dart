import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:day/day.dart';
import 'package:day/i18n/zh_cn.dart';
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
import 'package:clash_for_flutter/store/clash_core.dart';

class StoreConnection extends GetxController {
  final List<TableItem<ConnectConnection>> tableItems = [
    TableItem(
      head: '域名',
      width: 260,
      align: Alignment.centerLeft,
      getLabel: (c) => '${c.metadata.host.isNotEmpty ? c.metadata.host : c.metadata.destinationIP}:${c.metadata.destinationPort}',
    ),
    TableItem(head: '网络', width: 80, align: Alignment.center, getLabel: (c) => c.metadata.network),
    TableItem(head: '类型', width: 120, align: Alignment.center, getLabel: (c) => c.metadata.type),
    TableItem(head: '节点链', width: 200, align: Alignment.centerLeft, tooltip: true, getLabel: (c) => c.chains.reversed.join('/')),
    TableItem(head: '规则', width: 140, align: Alignment.center, getLabel: (c) => '${c.rule}(${c.rulePayload})'),
    TableItem(head: '进程', width: 100, align: Alignment.center, getLabel: (c) => path.basename(c.metadata.processPath)),
    TableItem(
      head: '速率',
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
      head: '上传',
      width: 100,
      align: Alignment.center,
      getLabel: (c) => bytesToSize(c.upload),
      sort: (a, b) => a.upload - b.upload,
    ),
    TableItem(
      head: '下载',
      width: 100,
      align: Alignment.center,
      getLabel: (c) => bytesToSize(c.download),
      sort: (a, b) => a.download - b.download,
    ),
    TableItem(head: '来源IP', width: 140, align: Alignment.center, getLabel: (c) => c.metadata.sourceIP),
    TableItem(
      head: '连接时间',
      width: 120,
      align: Alignment.center,
      getLabel: (c) => Day().useLocale(locale).from(Day.fromString(c.start)),
      sort: (a, b) => a.start.compareTo(b.start),
    ),
  ];

  var connect = Connect(downloadTotal: 0, uploadTotal: 0, connections: []).obs;
  var sortBy = Rx<TableItem<ConnectConnection>?>(null);
  var sortAscend = false.obs;

  var detail = Rx<ConnectConnection?>(null);
  var detailClosed = true.obs;

  String filter = '';

  IOWebSocketChannel? connectChannel;
  StreamSubscription<dynamic>? _listenStreamSub;
  Map<String, ConnectConnection> _connectionsCache = {};

  initWs() {
    sortBy.value = tableItems.last;
    final StoreClashCore storeClashCore = Get.find();
    connectChannel = storeClashCore.fetchConnectionWs();
    _listenStreamSub = connectChannel!.stream.listen(_handleStream, onDone: _handleOnDone);
  }

  closeWs() {
    _listenStreamSub?.cancel();
    connectChannel?.sink.close(WebSocketStatus.goingAway);
    _listenStreamSub = null;
    connectChannel = null;
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
    final res = await showNormalDialog(context, title: "警告", content: '将会关闭所有连接', enterText: "确 定", cancelText: "取 消");
    if (res != true) return;
    final StoreClashCore storeClashCore = Get.find();
    for (final it in connect.value.connections) {
      await storeClashCore.fetchCloseConnection(it.id);
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
    if (connectChannel?.closeCode != WebSocketStatus.goingAway) {
      BotToast.showText(text: "连接异常断开");
    } else {}
  }

  void _handleFilter() {
    if (filter.isNotEmpty) {
      connect.value.connections = connect.value.connections.where((it) {
        final str = ('${it.metadata.host}|${it.metadata.destinationPort}|${it.metadata.destinationIP}'
                '|${it.metadata.sourceIP}|${it.metadata.processPath}|${it.metadata.network}|${it.metadata.type}'
                '|${it.rule}|${it.rulePayload}|${it.chains.join('|')}')
            .toLowerCase();
        return filter.toLowerCase().split('|').any((f) => f.split('&').every((t) => str.contains(t.trim())));
      }).toList();
    }
  }

  void _handleSort() {
    if (sortBy.value == null) return;
    final _sort = sortBy.value!.sort;
    connect.value.connections.sort((a, b) {
      final va = sortAscend.value ? a : b;
      final vb = sortAscend.value ? b : a;

      if (_sort != null) {
        return _sort(va, vb);
      } else {
        return sortBy.value!.getLabel(va).compareTo(sortBy.value!.getLabel(vb));
      }
    });
  }
}
