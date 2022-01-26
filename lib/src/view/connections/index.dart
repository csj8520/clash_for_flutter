import 'package:bot_toast/bot_toast.dart';
import 'package:clash_pro_for_flutter/src/store/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_pro_for_flutter/src/utils/index.dart';
import 'package:clash_pro_for_flutter/src/components/index.dart';

class PageConnections extends StatefulWidget {
  const PageConnections({Key? key}) : super(key: key);

  @override
  _PageConnectionsState createState() => _PageConnectionsState();
}

class _PageConnectionsState extends State<PageConnections> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  bool _showDetail = false;

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

  @override
  Widget build(BuildContext context) {
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
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    controller: _verticalScrollController,
                    child: SingleChildScrollView(
                        // TODO-FIX: 水平滚动条不显示
                        scrollDirection: Axis.horizontal,
                        controller: _horizontalScrollController,
                        child: Column(
                          children: [
                            Row(
                              children: connectionsStore.tableItems
                                  .map((e) => TextButton(
                                        child: Text(
                                                '${e.head}${e == connectionsStore.sortBy ? connectionsStore.sortAscend ? ' ↑' : ' ↓' : ''}',
                                                overflow: TextOverflow.ellipsis)
                                            .textColor(const Color(0xff909399))
                                            .fontSize(14)
                                            .alignment(Alignment.center),
                                        onPressed: () => connectionsStore.setSortItem(e),
                                      ).width(e.width))
                                  .toList(),
                            ).height(30).backgroundColor(const Color(0xfff3f6f9)),
                            ...connectionsStore.connections.map((it) => _ConnectingItem(connection: it)).toList(),
                          ],
                        )),
                  ),
                  _showDetail
                      ? Positioned.directional(
                          textDirection: TextDirection.ltr,
                          top: 0,
                          bottom: 0,
                          end: 0,
                          width: 450,
                          child: Column(
                            children: [Text('data')],
                          ).decorated(
                            color: Colors.white,
                            boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )
                      : Container()
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
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    connectionsStore.close();
    super.dispose();
  }
}

class _ConnectingItem extends StatelessWidget {
  const _ConnectingItem({Key? key, required this.connection}) : super(key: key);
  final Map<String, dynamic> connection;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: connectionsStore.tableItems.map((e) {
        String label = '';
        if (e.getLabel != null) {
          label = e.getLabel!(connection.get(e.key)).toString();
        } else {
          label = connection.get(e.key).toString();
        }
        final text = Text(
          label,
          overflow: TextOverflow.ellipsis,
        ).textColor(const Color(0xff54759a)).fontSize(14).alignment(e.align).padding(left: 5, right: 5).width(e.width);
        return e.tooltip ? Tooltip(child: text, message: label) : text;
      }).toList(),
    ).height(36);
  }
}
