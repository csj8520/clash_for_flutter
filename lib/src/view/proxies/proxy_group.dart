import 'dart:math';

import 'package:clash_pro_for_flutter/src/store/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_pro_for_flutter/src/types/index.dart';
import 'package:clash_pro_for_flutter/src/components/index.dart';

class PageProxiesProxyGroup extends StatelessWidget {
  const PageProxiesProxyGroup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const CardHead(title: '策略组'),
      Observer(builder: (_) {
        final children = clashApiConfigStore.mode == 'global' && proxiesStore.global != null
            ? [_ProxyGroupItem(group: proxiesStore.global!, onChange: (v) => proxiesStore.setProxieGroup(proxiesStore.global!.name, v))]
            : proxiesStore.groups.map((e) => _ProxyGroupItem(group: e, onChange: (v) => proxiesStore.setProxieGroup(e.name, v))).toList();
        return CardView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ).width(double.infinity),
        );
      })
    ]);
  }
}

class _ProxyGroupItem extends StatefulWidget {
  const _ProxyGroupItem({Key? key, required this.group, required this.onChange}) : super(key: key);
  final ProxiesProxyGroup group;
  final Function(String value) onChange;

  @override
  _ProxyGroupItemState createState() => _ProxyGroupItemState();
}

class _ProxyGroupItemState extends State<_ProxyGroupItem> {
  bool _expand = false;

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    // TODO: 临时解决卡顿问题
    final tags = group.all.sublist(0, _expand ? group.all.length : min(group.all.length, 10));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(group.name, overflow: TextOverflow.ellipsis).width(80),
            Tag(group.type).padding(left: 10),
          ],
        ).width(190),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: tags
              .map((e) => _ProxyGroupItemTab(
                    text: e,
                    fail: proxiesStore.timeoutProxies.contains(e),
                    value: group.now == e,
                    disabled: group.type != ProxiesProxyGroupType.selector,
                    onClick: () => widget.onChange(e),
                  ))
              .toList(),
        ).constrained(maxHeight: _expand ? double.infinity : 24).clipRect().expanded(),
        // TODO: 无更多时不显示
        TextButton(
          child: Text(_expand ? '收起' : '展开').fontSize(14).textColor(const Color(0xff546b87)),
          onPressed: () => setState(() => _expand = !_expand),
        )
      ],
    ).padding(all: 15).border(bottom: 1, color: const Color(0xffd8dee2));
  }
}

class _ProxyGroupItemTab extends StatelessWidget {
  const _ProxyGroupItemTab({Key? key, required this.text, this.fail = false, this.value = false, this.disabled = false, this.onClick})
      : super(key: key);
  final String text;
  final bool fail;
  final bool value;
  final bool disabled;
  final Function()? onClick;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text(text, overflow: TextOverflow.ellipsis).fontSize(12).textColor((fail || value) ? Colors.white : const Color(0xff54759a)),
      onPressed: disabled ? null : onClick,
    )
        .height(24)
        .backgroundColor((fail && value)
            ? const Color(0xff8f7bb3)
            : fail
                ? Theme.of(context).errorColor
                : value
                    ? Theme.of(context).primaryColor
                    : Colors.transparent)
        .decorated(border: Border.all(width: 1, color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(12))
        .clipRRect(all: 12);
  }
}
