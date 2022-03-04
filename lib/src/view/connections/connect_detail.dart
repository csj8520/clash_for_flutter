import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_for_flutter/src/store/index.dart';
import 'package:clash_for_flutter/src/utils/index.dart';

class ConnectDetail extends StatefulWidget {
  const ConnectDetail({Key? key}) : super(key: key);

  @override
  State<ConnectDetail> createState() => _ConnectDetailState();
}

class _ConnectDetailState extends State<ConnectDetail> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      final d = connectionsStore.connectDetail;
      if (d == null) return Container();
      final m = d['metadata'];
      final closed = d['closed'] ?? false;
      return Positioned.fill(
        child: Row(
          children: [
            InkWell(onTap: connectionsStore.handleHideDetail).expanded(),
            SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              controller: _scrollController,
              child: Column(
                children: [
                  const Text('连接信息').fontSize(16).fontWeight(FontWeight.w700).padding(left: 12).alignment(Alignment.centerLeft).height(32),
                  Column(
                    children: [
                      _DetailItem(title: 'ID', content: d['id']),
                      Row(children: [
                        _DetailItem(title: '网络', content: m['network']).expanded(),
                        _DetailItem(title: '入口', content: m['type']).expanded(),
                      ]),
                      _DetailItem(title: '域名', content: (m['host'] as String).isEmpty ? '空' : '${m['host']}:${m['destinationPort']}'),
                      _DetailItem(
                          title: 'IP', content: (m['destinationIP'] as String).isEmpty ? '空' : '${m['destinationIP']}:${m['destinationPort']}'),
                      _DetailItem(title: '来源', content: '${m['sourceIP']}:${m['sourcePort']}'),
                      _DetailItem(title: '规则', content: '${d['rule']}(${d['rulePayload']})'),
                      _DetailItem(title: '代理', content: d['chains'].reversed.join(' / ')),
                      Row(children: [
                        _DetailItem(title: '上传', content: bytesToSize(d['upload'])).expanded(),
                        _DetailItem(title: '下载', content: bytesToSize(d['download'])).expanded(),
                      ]),
                      _DetailItem(title: '状态', content: closed ? '已关闭' : '连接中', contentColor: Color(closed ? 0xfff56c6c : 0xff67c23a)),
                      Row(
                        children: [
                          Container().expanded(),
                          TextButton(
                            child: const Text('关闭连接').textColor(closed ? Colors.grey.shade400 : Colors.white),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.resolveWith(
                                  (states) => states.contains(MaterialState.disabled) ? Colors.grey.shade200 : Colors.red),
                              shape: MaterialStateProperty.all(const StadiumBorder()),
                              padding: MaterialStateProperty.all(const EdgeInsets.all(15)),
                            ),
                            onPressed: closed ? null : () => connectionsStore.closeConnection(d['id']),
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
    });
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
