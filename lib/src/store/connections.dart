import 'dart:convert';
import 'package:mobx/mobx.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

import 'package:day/day.dart';
import 'package:day/i18n/zh_cn.dart';
import 'package:day/plugins/relative_time.dart';

import 'package:clash_for_flutter/src/fetch/index.dart';
import 'package:clash_for_flutter/src/utils/index.dart';

import 'index.dart';

part 'connections.g.dart';

class ConnectionsStore = _ConnectionsStore with _$ConnectionsStore;

class TableItem {
  String head;
  double width;
  String? key;
  Alignment align;
  bool tooltip;
  String Function(dynamic connect)? getLabel;
  int Function(dynamic a, dynamic b)? sort;
  TableItem({
    required this.head,
    required this.width,
    this.key,
    required this.align,
    this.tooltip = false,
    this.getLabel,
    this.sort,
  });
}

abstract class _ConnectionsStore with Store {
  IOWebSocketChannel? _channel;
  Map<String, Map<String, dynamic>> _preConnections = {};

  final List<TableItem> tableItems = [
    TableItem(
      head: '域名',
      width: 260,
      key: 'metadata',
      align: Alignment.centerLeft,
      getLabel: (m) => '${m['host'].isNotEmpty ? m['host'] : m['destinationIP']}:${m['destinationPort']}',
    ),
    TableItem(head: '网络', width: 80, key: 'metadata.network', align: Alignment.center),
    TableItem(head: '类型', width: 120, key: 'metadata.type', align: Alignment.center),
    TableItem(head: '节点链', width: 200, key: 'chains', align: Alignment.centerLeft, tooltip: true, getLabel: (c) => c.reversed.join('/')),
    TableItem(head: '规则', width: 140, align: Alignment.center, getLabel: (c) => '${c['rule']}(${c['rulePayload']})'),
    TableItem(
      head: '速率',
      width: 200,
      key: 'speed',
      align: Alignment.center,
      getLabel: (c) {
        final download = c['download'];
        final upload = c['upload'];
        if (upload == 0 && download == 0) return '-';
        if (upload == 0) return '↓ ${bytesToSize(download)}/s';
        if (download == 0) return '↑ ${bytesToSize(upload)}/s';
        return '↑ ${bytesToSize(upload)}/s ↓ ${bytesToSize(download)}/s';
      },
      sort: (a, b) => (a['download'] + a['upload']) - (b['download'] + b['upload']),
    ),
    TableItem(
      head: '上传',
      width: 100,
      key: 'upload',
      align: Alignment.center,
      getLabel: (c) => bytesToSize(c),
      sort: (a, b) => a - b,
    ),
    TableItem(
      head: '下载',
      width: 100,
      key: 'download',
      align: Alignment.center,
      getLabel: (c) => bytesToSize(c),
      sort: (a, b) => a - b,
    ),
    TableItem(head: '来源IP', width: 140, key: 'metadata.sourceIP', align: Alignment.center),
    TableItem(
      head: '连接时间',
      width: 120,
      key: 'start',
      align: Alignment.center,
      getLabel: (c) => Day().useLocale(locale).from(Day.fromString(c)),
      sort: (a, b) => b.toString().compareTo(a.toString()),
    ),
  ];

  @observable
  TableItem? sortBy;
  @observable
  bool sortAscend = false;

  @observable
  int downloadTotal = 0;
  @observable
  int uploadTotal = 0;
  @observable
  List<Map<String, dynamic>> connections = [];

  @observable
  Map<String, dynamic>? connectDetail;

  @action
  Future<void> open() async {
    _channel = IOWebSocketChannel.connect(Uri.parse('ws://${localConfigStore.clashApiAddress}/connections?token=${localConfigStore.clashApiSecret}'));
    _channel!.stream.listen(_handleStream);
    sortBy = tableItems.last;
  }

  @action
  Future<void> close() async {
    _channel?.sink.close();
  }

  @action
  setSortItem(TableItem item) {
    if (sortBy == item) {
      if (sortAscend) {
        sortBy = null;
      } else {
        sortAscend = true;
      }
    } else {
      sortBy = item;
      sortAscend = false;
    }
    _handleSort();
  }

  @action
  Future<void> closeAllConnections() async {
    final data = await fetchClashConnections();
    final List<dynamic> connections = data['connections'];
    for (var it in connections) {
      await closeConnection(it['id']);
    }
  }

  @action
  Future<void> closeConnection(String id) async {
    await fetchClashCloseConnection(id);
  }

  @action
  Future<void> closeConnectionWith(bool Function(Map<String, dynamic>) test) async {
    final data = await fetchClashConnections();
    final List<dynamic> connections = data['connections'];
    for (var it in connections) {
      if (test(it)) await closeConnection(it['id']);
    }
  }

  void _handleSort() {
    if (sortBy == null) return;
    final _sort = sortBy!.sort;
    connections.sort((a, b) {
      final va = sortAscend ? a.get(sortBy!.key) : b.get(sortBy!.key);
      final vb = sortAscend ? b.get(sortBy!.key) : a.get(sortBy!.key);
      if (_sort != null) {
        return _sort(va, vb);
      } else if (sortBy!.getLabel != null) {
        return sortBy!.getLabel!(va).compareTo(sortBy!.getLabel!(vb));
      } else {
        return va.toString().compareTo(vb.toString());
      }
    });
  }

  void _handleStream(dynamic event) {
    final data = json.decode(event);
    downloadTotal = data['downloadTotal'];
    uploadTotal = data['uploadTotal'];
    final preConnections = _preConnections;
    _preConnections = {};
    connections = (data['connections'] as List<dynamic>).map((it) {
      final pre = preConnections[it['id']] ?? it;
      final download = it['download'] - pre['download'];
      final upload = it['upload'] - pre['upload'];
      final Map<String, dynamic> connect = {
        ...it,
        'speed': {'download': download, 'upload': upload}
      };
      _preConnections[it['id']] = connect;
      return connect;
    }).toList();
    _handleSort();
    if (connectDetail != null) {
      connectDetail = connections.firstWhere((it) => it['id'] == connectDetail!['id'], orElse: () => ({...connectDetail!, 'closed': true}));
    }
  }

  @action
  void handleShowDetail(Map<String, dynamic> connect) {
    connectDetail = connect;
  }

  @action
  void handleHideDetail() {
    connectDetail = null;
  }
}
