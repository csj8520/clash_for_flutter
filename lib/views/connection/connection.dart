import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:web_socket_channel/io.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_for_flutter/utils/utils.dart';
import 'package:clash_for_flutter/types/table.dart';
import 'package:clash_for_flutter/types/connect.dart';
import 'package:clash_for_flutter/store/clash_core.dart';
import 'package:clash_for_flutter/widgets/card_view.dart';
import 'package:clash_for_flutter/widgets/card_head.dart';
import 'package:clash_for_flutter/views/connection/table_config.dart';
import 'package:clash_for_flutter/views/connection/connect_detail.dart';

class PageConnection extends StatefulWidget {
  const PageConnection({Key? key}) : super(key: key);

  @override
  State<PageConnection> createState() => _PageConnectionState();
}

class _PageConnectionState extends State<PageConnection> {
  late IOWebSocketChannel _connectChannel;
  late StreamSubscription<dynamic> _listenStreamSub;

  final StoreClashCore storeClashCore = Get.find();
  TableItem<ConnectConnection>? _sortBy = tableItems.last;

  Connect _connect = Connect(downloadTotal: 0, uploadTotal: 0, connections: []);
  Map<String, ConnectConnection> _connectionsCache = {};

  bool _sortAscend = false;
  ConnectConnection? _detail;
  bool _detailClosed = true;

  @override
  void initState() {
    _connectChannel = storeClashCore.fetchConnectionsWs();
    _listenStreamSub = _connectChannel.stream.listen(_handleStream, onDone: _handleOnDone);
    super.initState();
  }

  void _handleStream(dynamic event) {
    _connect = Connect.fromJson(json.decode(event));
    final cache = _connectionsCache;
    _connectionsCache = {};
    // handle speed
    for (var it in _connect.connections) {
      final pre = cache[it.id];
      _connectionsCache[it.id] = it;
      if (pre == null) continue;
      it.speed.download = it.download - pre.speed.download;
      it.speed.upload = it.upload - pre.speed.upload;
    }
    // update detail
    if (_detail != null && !_detailClosed) {
      final n = _connectionsCache[_detail!.id];
      if (n == null) {
        _detailClosed = true;
      } else {
        _detail = n;
      }
    }
    _handleSort();
    setState(() {});
  }

  void _handleOnDone() {
    if (_connectChannel.closeCode != WebSocketStatus.goingAway) {
      BotToast.showText(text: "连接异常断开");
    } else {}
  }

  void _handleSetSort(TableItem<ConnectConnection> item) {
    if (_sortBy == item) {
      if (_sortAscend) {
        _sortBy = null;
      } else {
        _sortAscend = true;
      }
    } else {
      _sortBy = item;
      _sortAscend = false;
    }
    _handleSort();
    setState(() {});
  }

  void _handleSort() {
    if (_sortBy == null) return;
    final _sort = _sortBy!.sort;
    _connect.connections.sort((a, b) {
      final va = _sortAscend ? a : b;
      final vb = _sortAscend ? b : a;

      if (_sort != null) {
        return _sort(va, vb);
      } else {
        return _sortBy!.getLabel(va).compareTo(_sortBy!.getLabel(vb));
      }
    });
  }

  void _handleShowDetail(ConnectConnection? connection) {
    _detail = connection;
    _detailClosed = false;
    setState(() {});
  }

  void _hanldeCloseAllConnections() async {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('警告'),
        content: const Text('将会关闭所有连接'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(c);
              for (final it in _connect.connections) {
                await storeClashCore.fetchCloseConnection(it.id);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(TableItem<ConnectConnection> e) {
    return TextButton(
      child: Text(
        '${e.head}${e == _sortBy ? _sortAscend ? ' ↑' : ' ↓' : ''}',
        overflow: TextOverflow.ellipsis,
      ).textColor(const Color(0xff909399)).fontSize(14).alignment(Alignment.center),
      onPressed: () => _handleSetSort(e),
    ).width(e.width);
  }

  Widget _buildTableRow(ConnectConnection it) {
    return TextButton(
      style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
      child: tableItems
          .map((e) {
            String label = e.getLabel(it);
            final text = Text(label, overflow: TextOverflow.ellipsis)
                .textColor(const Color(0xff54759a))
                .fontSize(14)
                .alignment(e.align)
                .padding(left: 5, right: 5)
                .width(e.width);
            return e.tooltip ? Tooltip(child: text, message: label) : text;
          })
          .toList()
          .toRow(),
      onPressed: () => _handleShowDetail(it),
    ).height(36);
  }

  @override
  Widget build(BuildContext context) {
    return [
      CardHead(
        title: '连接',
        suffix: Row(
          children: [
            Text('(总量: 上传 ${bytesToSize(_connect.uploadTotal)} 下载 ${bytesToSize(_connect.downloadTotal)})')
                .textColor(Theme.of(context).primaryColor)
                .fontSize(14)
                .padding(left: 10)
                .expanded(),
            IconButton(
              icon: const Icon(Icons.close),
              color: Colors.red,
              iconSize: 20,
              tooltip: 'Close All Connections',
              onPressed: _hanldeCloseAllConnections,
              constraints: const BoxConstraints(minHeight: 30, minWidth: 30),
              padding: EdgeInsets.zero,
            ),
          ],
        ).expanded(),
      ),
      CardView(
        child: Stack(
          children: [
            _ConnectionsTable(
              tableHeaders: tableItems.map(_buildHeader).toList(),
              tableRows: _connect.connections.map(_buildTableRow).toList(),
            ),
            if (_detail != null) ConnectDetail(connection: _detail!, closed: _detailClosed, onClose: () => _handleShowDetail(null)),
          ],
        ),
      ).expanded()
    ].toColumn();
  }

  @override
  void dispose() {
    _listenStreamSub.cancel();
    _connectChannel.sink.close(WebSocketStatus.goingAway);
    super.dispose();
  }
}

class _ConnectionsTable extends StatefulWidget {
  const _ConnectionsTable({Key? key, required this.tableHeaders, required this.tableRows}) : super(key: key);
  final List<Widget> tableHeaders;
  final List<Widget> tableRows;

  @override
  State<_ConnectionsTable> createState() => _ConnectionsTableState();
}

class _ConnectionsTableState extends State<_ConnectionsTable> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _horizontalScrollController,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _horizontalScrollController,
        child: Column(
          children: [
            Row(children: widget.tableHeaders).height(30).backgroundColor(const Color(0xfff3f6f9)),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: _verticalScrollController,
              child: Column(children: widget.tableRows),
            ).expanded(),
          ],
        ),
      ),
    );
  }
}
