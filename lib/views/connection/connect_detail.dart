import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_for_flutter/utils/utils.dart';
import 'package:clash_for_flutter/types/connect.dart';
import 'package:clash_for_flutter/store/clash_core.dart';

class ConnectDetail extends StatefulWidget {
  const ConnectDetail({Key? key, required this.connection, required this.closed, required this.onClose}) : super(key: key);
  final ConnectConnection connection;
  final bool closed;
  final void Function() onClose;

  @override
  State<ConnectDetail> createState() => _ConnectDetailState();
}

class _ConnectDetailState extends State<ConnectDetail> {
  final StoreClashCore storeClashCore = Get.find();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final d = widget.connection;
    final m = d.metadata;
    return Positioned.fill(
      child: Row(
        children: [
          InkWell(onTap: widget.onClose).expanded(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            controller: _scrollController,
            child: Column(
              children: [
                const Text('连接信息').fontSize(16).fontWeight(FontWeight.w700).padding(left: 12).alignment(Alignment.centerLeft).height(32),
                Column(
                  children: [
                    _DetailItem(title: 'ID', content: d.id),
                    Row(children: [
                      _DetailItem(title: '网络', content: m.network).expanded(),
                      _DetailItem(title: '入口', content: m.type).expanded(),
                    ]),
                    _DetailItem(title: '域名', content: m.host.isEmpty ? '空' : '${m.host}:${m.destinationPort}'),
                    _DetailItem(title: 'IP', content: m.destinationIP.isEmpty ? '空' : '${m.destinationIP}:${m.destinationPort}'),
                    _DetailItem(title: '来源', content: '${m.sourceIP}:${m.sourcePort}'),
                    _DetailItem(title: '进程', content: m.processPath.isEmpty ? '空' : path.basename(m.processPath)),
                    _DetailItem(title: '路径', content: m.processPath.isEmpty ? '空' : m.processPath),
                    _DetailItem(title: '规则', content: '${d.rule}(${d.rulePayload})'),
                    _DetailItem(title: '代理', content: d.chains.reversed.join(' / ')),
                    Row(children: [
                      _DetailItem(title: '上传', content: bytesToSize(d.upload)).expanded(),
                      _DetailItem(title: '下载', content: bytesToSize(d.download)).expanded(),
                    ]),
                    _DetailItem(title: '状态', content: widget.closed ? '已关闭' : '连接中', contentColor: Color(widget.closed ? 0xfff56c6c : 0xff67c23a)),
                    Row(
                      children: [
                        Container().expanded(),
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith(
                                (states) => states.contains(MaterialState.disabled) ? Colors.grey.shade200 : Colors.red),
                            shape: MaterialStateProperty.all(const StadiumBorder()),
                            padding: MaterialStateProperty.all(const EdgeInsets.all(15)),
                          ),
                          onPressed: widget.closed ? null : () => storeClashCore.fetchCloseConnection(widget.connection.id),
                          child: const Text('关闭连接').textColor(widget.closed ? Colors.grey.shade400 : Colors.white),
                        ),
                      ],
                    ),
                  ],
                ).padding(left: 20)
              ],
            ),
          ).constrained(width: 450, height: double.infinity).decorated(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
                borderRadius: BorderRadius.circular(4),
              ),
        ],
      ).backgroundColor(Colors.black.withAlpha((0xff * 0.2).toInt())),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({Key? key, required this.title, required this.content, this.contentColor}) : super(key: key);
  final String title;
  final String content;
  final Color? contentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title).fontWeight(FontWeight.w700).width(60),
        Text(content).textColor(contentColor).expanded(),
      ],
    ).padding(top: 10, bottom: 10);
  }
}
