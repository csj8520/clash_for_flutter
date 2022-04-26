import 'package:get/get.dart';
import 'package:flutter/material.dart';
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

class _PageConnectionState extends State<PageConnection> with AutomaticKeepAliveClientMixin {
  final StoreClashCore storeClashCore = Get.find();
  TableItem<ConnectConnection>? sortBy = tableItems.last;
  bool sortAscend = false;

  ConnectConnection? connectionDetail;
  bool connectionDetailClosed = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    storeClashCore.connect.listen((p0) {
      _handleSort();
      if (connectionDetail != null && !connectionDetailClosed) {
        final n = p0.connections.firstWhereOrNull((it) => it.id == connectionDetail!.id);
        if (n == null) {
          connectionDetailClosed = true;
        } else {
          connectionDetail = n;
        }
        setState(() {});
      }
    });
  }

  void setSortItem(TableItem<ConnectConnection> item) {
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
    setState(() {});
  }

  void _handleSort() {
    if (sortBy == null) return;
    final _sort = sortBy!.sort;
    storeClashCore.connect.value.connections.sort((a, b) {
      final va = sortAscend ? a : b;
      final vb = sortAscend ? b : a;

      if (_sort != null) {
        return _sort(va, vb);
      } else {
        return sortBy!.getLabel(va).compareTo(sortBy!.getLabel(vb));
      }
    });
  }

  void handleShowConnectionDetail(ConnectConnection? connection) {
    setState(() {
      connectionDetail = connection;
      connectionDetailClosed = false;
    });
  }

  void closeAllConnections() async {
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
              for (final it in storeClashCore.connect.value.connections) {
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
        '${e.head}${e == sortBy ? sortAscend ? ' ↑' : ' ↓' : ''}',
        overflow: TextOverflow.ellipsis,
      ).textColor(const Color(0xff909399)).fontSize(14).alignment(Alignment.center),
      onPressed: () => setSortItem(e),
    ).width(e.width);
  }

  Widget _buildTableRow(ConnectConnection it) {
    return TextButton(
      style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
      child: Row(
        children: tableItems.map((e) {
          String label = '';
          label = e.getLabel(it);
          final text = Text(label, overflow: TextOverflow.ellipsis)
              .textColor(const Color(0xff54759a))
              .fontSize(14)
              .alignment(e.align)
              .padding(left: 5, right: 5)
              .width(e.width);
          return e.tooltip ? Tooltip(child: text, message: label) : text;
        }).toList(),
      ),
      onPressed: () => handleShowConnectionDetail(it),
    ).height(36);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return [
      CardHead(
        title: '连接',
        suffix: Row(
          children: [
            Obx(() => Text(
                    '(总量: 上传 ${bytesToSize(storeClashCore.connect.value.uploadTotal)} 下载 ${bytesToSize(storeClashCore.connect.value.downloadTotal)})')
                .textColor(Theme.of(context).primaryColor)
                .fontSize(14)
                .padding(left: 10)
                .expanded()),
            IconButton(
              icon: const Icon(Icons.close),
              color: Colors.red,
              iconSize: 20,
              tooltip: 'Close All Connections',
              onPressed: closeAllConnections,
              constraints: const BoxConstraints(minHeight: 30, minWidth: 30),
              padding: EdgeInsets.zero,
            )
          ],
        ).expanded(),
      ),
      CardView(
        child: Stack(
          children: [
            Obx(() => _ConnectionsTable(
                  tableHeaders: tableItems.map(_buildHeader).toList(),
                  tableRows: storeClashCore.connect.value.connections.map(_buildTableRow).toList(),
                )),
            if (connectionDetail != null)
              ConnectDetail(connection: connectionDetail!, closed: connectionDetailClosed, onClose: () => handleShowConnectionDetail(null)),
          ],
        ),
      ).expanded()
    ].toColumn();
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
