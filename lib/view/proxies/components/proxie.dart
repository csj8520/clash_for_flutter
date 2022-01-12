import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clashf_pro/types/index.dart';

final _colors = {
  const Color(0xff909399): 0,
  const Color(0xff00c520): 260,
  const Color(0xffff9a28): 600,
  const Color(0xffff3e5e): double.infinity,
};

class BlockProxie extends StatelessWidget {
  const BlockProxie({Key? key, required this.proxie}) : super(key: key);
  final ProxiesProxie proxie;

  @override
  Widget build(BuildContext context) {
    final delay = proxie.delay;
    final name = proxie.name;
    Color color = _colors.keys.firstWhere((it) => (delay <= _colors[it]!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(proxie.type).textColor(Colors.white).fontSize(10).padding(left: 5, right: 5, top: 2, bottom: 2).backgroundColor(color).clipRRect(all: 2),
        Text(name, overflow: TextOverflow.ellipsis, maxLines: 2).textColor(const Color(0xff54759a)).fontSize(10),
        Text(delay == 0 ? '-' : '${delay}ms').textColor(const Color(0xcc54759a)).fontSize(10),
      ],
    ).padding(left: 10, right: 10, top: 15, bottom: 15).constrained(width: 90, height: 100).decorated(
      color: Colors.white,
      borderRadius: BorderRadius.circular(5),
      boxShadow: [const BoxShadow(color: Color(0x332c8af8), blurRadius: 24)],
    );
  }
}
