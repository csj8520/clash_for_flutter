import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_pro_for_flutter/src/store/connections.dart';
import 'package:clash_pro_for_flutter/src/store/index.dart';
import 'package:clash_pro_for_flutter/src/utils/index.dart';
import 'package:clash_pro_for_flutter/src/components/index.dart';

import 'connect_detail.dart';

class PageConnections extends StatefulWidget {
  const PageConnections({Key? key}) : super(key: key);

  @override
  _PageConnectionsState createState() => _PageConnectionsState();
}

class _PageConnectionsState extends State<PageConnections> {
  @override
  void initState() {
    super.initState();
    connectionsStore.open();
  }

  void _closeAllConnections() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('警告'),
        content: const Text('将会关闭所有连接'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await connectionsStore.closeAllConnections();
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(TableItem e) {
    return TextButton(
      child: Text(
        '${e.head}${e == connectionsStore.sortBy ? connectionsStore.sortAscend ? ' ↑' : ' ↓' : ''}',
        overflow: TextOverflow.ellipsis,
      ).textColor(const Color(0xff909399)).fontSize(14).alignment(Alignment.center),
      onPressed: () => connectionsStore.setSortItem(e),
    ).width(e.width);
  }

  Widget _buildTableRow(Map<String, dynamic> it) {
    return TextButton(
      style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
      child: Row(
        children: connectionsStore.tableItems.map((e) {
          String label = '';
          if (e.getLabel != null) {
            label = e.getLabel!(it.get(e.key)).toString();
          } else {
            label = it.get(e.key).toString();
          }
          final text = Text(
            label,
            overflow: TextOverflow.ellipsis,
          ).textColor(const Color(0xff54759a)).fontSize(14).alignment(e.align).padding(left: 5, right: 5).width(e.width);
          return e.tooltip ? Tooltip(child: text, message: label) : text;
        }).toList(),
      ),
      onPressed: () => connectionsStore.handleShowDetail(it),
    ).height(36);
  }

  @override
  Widget build(BuildContext context) {
    final Map<int, FixedColumnWidth> widths = {};
    connectionsStore.tableItems.asMap().keys.forEach((key) {
      widths[key] = FixedColumnWidth(connectionsStore.tableItems[key].width);
    });
    return Observer(
      builder: (_) {
        return Column(
          children: [
            CardHead(
              title: '连接',
              suffix: Row(
                children: [
                  Text('(总量: 上传 ${bytesToSize(connectionsStore.uploadTotal)} 下载 ${bytesToSize(connectionsStore.downloadTotal)})')
                      .textColor(Theme.of(context).primaryColor)
                      .fontSize(14)
                      .padding(left: 10)
                      .expanded(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.red,
                    iconSize: 20,
                    tooltip: 'Close All Connections',
                    onPressed: _closeAllConnections,
                    constraints: const BoxConstraints(minHeight: 30, minWidth: 30),
                    padding: EdgeInsets.zero,
                  )
                ],
              ).expanded(),
            ),
            CardView(
              child: Stack(
                children: [
                  _ConnectionsTable(
                    tableHeaders: connectionsStore.tableItems.map(_buildHeader).toList(),
                    tableRows: connectionsStore.connections.map(_buildTableRow).toList(),
                  ),
                  const ConnectDetail(),
                ],
              ),
            ).expanded(),
          ],
        ).padding(top: 5, right: 20, bottom: 10);
      },
    );
  }

  @override
  void dispose() {
    connectionsStore.close();
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
