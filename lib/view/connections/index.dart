import 'dart:convert';

import 'package:clash_pro_for_flutter/store/index.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:web_socket_channel/io.dart';

import 'package:day/day.dart';
import 'package:day/i18n/zh_cn.dart';
import 'package:day/plugins/relative_time.dart';

import 'package:clash_pro_for_flutter/types/index.dart';
import 'package:clash_pro_for_flutter/utils/index.dart';
import 'package:clash_pro_for_flutter/components/index.dart';

class TableItem {
  String head;
  double width;
  Alignment align;
  bool tooltip;
  String Function(ConnectionsConnection connect) getLabel;
  TableItem({required this.head, required this.width, required this.align, this.tooltip = false, required this.getLabel});
}

final List<TableItem> tableItems = [
  TableItem(
      head: '域名',
      width: 260,
      align: Alignment.centerLeft,
      getLabel: (c) => '${c.metadata.host.isNotEmpty ? c.metadata.host : c.metadata.sourceIP}:${c.metadata.destinationPort}'),
  TableItem(head: '网络', width: 80, align: Alignment.center, getLabel: (c) => c.metadata.network),
  TableItem(head: '类型', width: 120, align: Alignment.center, getLabel: (c) => c.metadata.type),
  TableItem(head: '节点链', width: 200, align: Alignment.centerLeft, tooltip: true, getLabel: (c) => c.chains.reversed.join('/')),
  TableItem(head: '规则', width: 140, align: Alignment.center, getLabel: (c) => '${c.rule}(${c.rulePayload})'),
  TableItem(head: '速率', width: 100, align: Alignment.center, getLabel: (c) => '-'),
  TableItem(head: '上传', width: 200, align: Alignment.center, getLabel: (c) => bytesToSize(c.upload)),
  TableItem(head: '下载', width: 100, align: Alignment.center, getLabel: (c) => bytesToSize(c.download)),
  TableItem(head: '来源IP', width: 140, align: Alignment.center, getLabel: (c) => c.metadata.sourceIP),
  TableItem(head: '连接时间', width: 120, align: Alignment.center, getLabel: (c) => Day().useLocale(locale).from(Day.fromString(c.start))),
];

class PageConnections extends StatefulWidget {
  const PageConnections({Key? key}) : super(key: key);

  @override
  _PageConnectionsState createState() => _PageConnectionsState();
}

class _PageConnectionsState extends State<PageConnections> {
  IOWebSocketChannel? _channel;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _openChannel();
  }

  _openChannel() async {
    _channel = IOWebSocketChannel.connect(Uri.parse('ws://${localConfigStore.clashApiAddress}/connections?token=${localConfigStore.clashApiSecret}'));
  }

  @override
  Widget build(BuildContext context) {
    if (_channel == null) return Container();
    return StreamBuilder(
      stream: _channel!.stream,
      builder: (context, snapshot) {
        final data = snapshot.hasData ? Connections.buildFromJson(json.decode(snapshot.data as String)) : Connections.def;

        return Column(
          children: [
            CardHead(
              title: '连接',
              suffix: Row(
                children: [
                  Text('(总量: 上传 ${bytesToSize(data.uploadTotal)} 下载 ${bytesToSize(data.downloadTotal)})')
                      .textColor(Theme.of(context).primaryColor)
                      .fontSize(14)
                      .padding(left: 10)
                      .expanded()
                ],
              ).expanded(),
            ),
            CardView(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: _verticalScrollController,
                child: SingleChildScrollView(
                  // TODO-FIX: 水平滚动条不显示
                  scrollDirection: Axis.horizontal,
                  controller: _horizontalScrollController,
                  child: Column(
                    children: [
                      Row(
                        children: tableItems
                            .map((e) => Text(e.head, overflow: TextOverflow.ellipsis)
                                .textColor(const Color(0xff909399))
                                .fontSize(14)
                                .alignment(Alignment.center)
                                .width(e.width))
                            .toList(),
                      ).height(30).backgroundColor(const Color(0xfff3f6f9)),
                      ...data.connections.map((it) => _ConnectingItem(connection: it)).toList(),
                    ],
                  ),
                ),
              ),
            ).expanded(),
          ],
        ).padding(top: 5, right: 20, bottom: 10);
      },
    );
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _channel?.sink.close();
    super.dispose();
  }
}

class _ConnectingItem extends StatelessWidget {
  const _ConnectingItem({Key? key, required this.connection}) : super(key: key);
  final ConnectionsConnection connection;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: tableItems.map((e) {
        final label = e.getLabel(connection);
        final text = Text(
          label,
          overflow: TextOverflow.ellipsis,
        ).textColor(const Color(0xff54759a)).fontSize(14).alignment(e.align).padding(left: 5, right: 5).width(e.width);
        return e.tooltip ? Tooltip(child: text, message: label) : text;
      }).toList(),
    ).height(36);
  }
}
