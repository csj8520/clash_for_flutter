import 'package:clashf_pro/components/index.dart';
import 'package:clashf_pro/utils/utils.dart';
import 'package:flutter/material.dart';

class StrategyGroup extends StatelessWidget {
  const StrategyGroup({Key? key, required this.proxies}) : super(key: key);
  final Proxies proxies;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: proxies.groups.map((e) => StrategyGroupItem(group: e, timeoutProxys: proxies.timeoutProxies)).toList(),
    ).width(double.infinity);
  }
}

class StrategyGroupItem extends StatefulWidget {
  const StrategyGroupItem({Key? key, required this.group, required this.timeoutProxys}) : super(key: key);
  final ProxiesGroup group;
  final List<String> timeoutProxys;

  @override
  _StrategyGroupItemState createState() => _StrategyGroupItemState();
}

class _StrategyGroupItemState extends State<StrategyGroupItem> {
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
          children: widget.group.all
              .map((e) => StrategyGroupItemTab(
                    text: e,
                    fail: widget.timeoutProxys.contains(e),
                    value: widget.group.now == e,
                    disabled: widget.group.type != ProxiesGroupType.selector,
                    onClick: () => _handleSelect(e),
                  ))
              .toList(),
        ).constrained(maxHeight: _expand ? double.infinity : 24).clipRect().expanded(),
        TextButton(
          child: Text(_expand ? '收起' : '展开').fontSize(14).textColor(const Color(0xff546b87)),
          onPressed: () => setState(() => _expand = !_expand),
        )
      ],
    ).padding(all: 15).border(bottom: 1, color: const Color(0xffd8dee2));
  }
}

class StrategyGroupItemTab extends StatelessWidget {
  const StrategyGroupItemTab({Key? key, required this.text, this.fail = false, this.value = false, this.disabled = false, this.onClick})
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
                ? themColorRed
                : value
                    ? themColorBlue
                    : Colors.transparent)
        .decorated(border: Border.all(width: 1, color: themColorBlue), borderRadius: BorderRadius.circular(12))
        .clipRRect(all: 12);
  }
}
