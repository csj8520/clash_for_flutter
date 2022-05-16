import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_for_flutter/utils/utils.dart';
import 'package:clash_for_flutter/types/connect.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';

class ConnectDetail extends StatefulWidget {
  const ConnectDetail({Key? key, required this.connection, required this.closed, required this.onClose}) : super(key: key);
  final ConnectConnection connection;
  final bool closed;
  final void Function() onClose;

  @override
  State<ConnectDetail> createState() => _ConnectDetailState();
}

class _ConnectDetailState extends State<ConnectDetail> {
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
                Text('connection_info_title'.tr)
                    .fontSize(16)
                    .fontWeight(FontWeight.w700)
                    .padding(left: 12)
                    .alignment(Alignment.centerLeft)
                    .height(32),
                Column(
                  children: [
                    _DetailItem(title: 'connection_info_id'.tr, content: d.id),
                    Row(children: [
                      _DetailItem(title: 'connection_info_network'.tr, content: m.network).expanded(),
                      _DetailItem(title: 'connection_info_inbound'.tr, content: m.type).expanded(),
                    ]),
                    _DetailItem(
                        title: 'connection_info_host'.tr, content: m.host.isEmpty ? 'connection_info_empty'.tr : '${m.host}:${m.destinationPort}'),
                    _DetailItem(
                        title: 'connection_info_dst_ip'.tr,
                        content: m.destinationIP.isEmpty ? 'connection_info_empty'.tr : '${m.destinationIP}:${m.destinationPort}'),
                    _DetailItem(title: 'connection_info_src_ip'.tr, content: '${m.sourceIP}:${m.sourcePort}'),
                    _DetailItem(
                        title: 'connection_info_process'.tr,
                        content: m.processPath.isEmpty ? 'connection_info_empty'.tr : path.basename(m.processPath)),
                    _DetailItem(
                        title: 'connection_info_process_path'.tr, content: m.processPath.isEmpty ? 'connection_info_empty'.tr : m.processPath),
                    _DetailItem(title: 'connection_info_rule'.tr, content: '${d.rule}(${d.rulePayload})'),
                    _DetailItem(title: 'connection_info_chains'.tr, content: d.chains.reversed.join(' / ')),
                    Row(children: [
                      _DetailItem(title: 'connection_info_upload'.tr, content: bytesToSize(d.upload)).expanded(),
                      _DetailItem(title: 'connection_info_download'.tr, content: bytesToSize(d.download)).expanded(),
                    ]),
                    _DetailItem(
                        title: 'connection_info_status'.tr,
                        content: widget.closed ? 'connection_info_closed'.tr : 'connection_info_opening'.tr,
                        contentColor: Color(widget.closed ? 0xfff56c6c : 0xff67c23a)),
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
                          onPressed: widget.closed ? null : () => controllers.core.fetchCloseConnection(widget.connection.id),
                          child: Text('connection_info_close_connection'.tr).textColor(widget.closed ? Colors.grey.shade400 : Colors.white),
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
        Text(title).fontWeight(FontWeight.w700).width(65),
        Text(content).textColor(contentColor).expanded(),
      ],
    ).padding(top: 10, bottom: 10);
  }
}
