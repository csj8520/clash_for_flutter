import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_for_flutter/utils/utils.dart';
import 'package:clash_for_flutter/types/table.dart';
import 'package:clash_for_flutter/types/connect.dart';
import 'package:clash_for_flutter/store/connection.dart';
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
  final StoreConnection storeConnection = Get.find();
  final TextEditingController _filterTextEditingController = TextEditingController();

  @override
  void initState() {
    storeConnection.initWs();
    _filterTextEditingController.addListener(() {
      storeConnection.filter = _filterTextEditingController.text;
    });
    super.initState();
  }

  Widget _buildHeader(TableItem<ConnectConnection> e) {
    return TextButton(
      child: Text(
        '${e.head}${e == storeConnection.sortBy.value ? storeConnection.sortAscend.value ? ' ↑' : ' ↓' : ''}',
        overflow: TextOverflow.ellipsis,
      ).textColor(const Color(0xff909399)).fontSize(14).alignment(Alignment.center),
      onPressed: () => storeConnection.handleSetSort(e),
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
            return e.tooltip ? Tooltip(message: label, child: text) : text;
          })
          .toList()
          .toRow(),
      onPressed: () => storeConnection.handleShowDetail(it),
    ).height(36);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => [
          CardHead(
            title: '连接',
            suffix: Row(
              children: [
                Text('(总量: 上传 ${bytesToSize(storeConnection.connect.value.uploadTotal)} 下载 ${bytesToSize(storeConnection.connect.value.downloadTotal)})')
                    .textColor(Theme.of(context).primaryColor)
                    .fontSize(14)
                    .padding(left: 10)
                    .width(300),
                Row(
                  children: [
                    const Text("过滤").textColor(Colors.grey.shade700).padding(right: 10),
                    TextField(
                      controller: _filterTextEditingController,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'google | github & TUN',
                        isCollapsed: true,
                        contentPadding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                      ),
                    ).width(150).decorated(border: Border.all(width: 1, color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
                  ],
                ).expanded(),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.red,
                  iconSize: 20,
                  tooltip: 'Close All Connections',
                  onPressed: () => storeConnection.hanldeCloseAllConnections(context),
                  constraints: const BoxConstraints(minHeight: 30, minWidth: 30),
                  padding: EdgeInsets.zero,
                ),
              ],
            ).padding(right: 10).expanded(),
          ),
          CardView(
            child: Stack(
              children: [
                _ConnectionsTable(
                  tableHeaders: tableItems.map(_buildHeader).toList(),
                  tableRows: storeConnection.connect.value.connections.map(_buildTableRow).toList(),
                ),
                if (storeConnection.detail.value != null)
                  ConnectDetail(
                      connection: storeConnection.detail.value!,
                      closed: storeConnection.detailClosed.value,
                      onClose: () => storeConnection.handleShowDetail(null)),
              ],
            ),
          ).expanded()
        ].toColumn());
  }

  @override
  void dispose() {
    storeConnection.closeWs();
    _filterTextEditingController.dispose();
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
