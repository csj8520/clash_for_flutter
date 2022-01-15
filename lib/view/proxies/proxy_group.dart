import 'dart:math';

import 'package:clashf_pro/store/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clashf_pro/fetch/index.dart';
import 'package:clashf_pro/types/index.dart';
import 'package:clashf_pro/components/index.dart';

class PageProxiesProxyGroup extends StatelessWidget {
  const PageProxiesProxyGroup({Key? key, required this.proxies}) : super(key: key);
  final Proxies proxies;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const CardHead(title: '策略组'),
      Observer(
          builder: (_) => CardView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: clashApiConfigStore.mode == 'global'
                    ? [_ProxyGroupItem(group: proxies.global, timeoutProxys: proxies.timeoutProxies)]
                    : proxies.groups.map((e) => _ProxyGroupItem(group: e, timeoutProxys: proxies.timeoutProxies)).toList(),
              ).width(double.infinity)))
    ]);
  }
}

class _ProxyGroupItem extends StatefulWidget {
  const _ProxyGroupItem({Key? key, required this.group, required this.timeoutProxys}) : super(key: key);
  final ProxiesProxyGroup group;
  final List<String> timeoutProxys;

  @override
  _ProxyGroupItemState createState() => _ProxyGroupItemState();
}

class _ProxyGroupItemState extends State<_ProxyGroupItem> {
  bool _expand = false;
  // final GlobalKey _globalKey = GlobalKey();

  // @override
  // void didUpdateWidget(covariant _Group oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   print(_globalKey.currentContext?.findRenderObject()?.semanticBounds.size);
  //   // print(_globalKey.currentContext?.findRenderObject()?.paintBounds);
  // }

  _handleSelect(String label) async {
    await fetchClashProxieSwitch(group: widget.group.name, value: label);
    setState(() => widget.group.now = label);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: 临时解决卡顿问题
    final tags = widget.group.all.sublist(0, _expand ? widget.group.all.length : min(widget.group.all.length, 10));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.group.name, overflow: TextOverflow.ellipsis).width(80),
            Tag(widget.group.type).padding(left: 10),
          ],
        ).width(190),
        Wrap(
          // key: _globalKey,
          spacing: 6,
          runSpacing: 6,
          children: tags
              .map((e) => _ProxyGroupItemTab(
                    text: e,
                    fail: widget.timeoutProxys.contains(e),
                    value: widget.group.now == e,
                    disabled: widget.group.type != ProxiesProxyGroupType.selector,
                    onClick: () => _handleSelect(e),
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
