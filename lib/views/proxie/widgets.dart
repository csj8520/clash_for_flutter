import 'dart:math';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:day/day.dart';
import 'package:day/i18n/zh_cn.dart';
import 'package:day/plugins/relative_time.dart';

import 'package:clash_for_flutter/widgets/tag.dart';
import 'package:clash_for_flutter/types/proxie.dart';
import 'package:clash_for_flutter/widgets/loading.dart';
import 'package:clash_for_flutter/widgets/card_view.dart';

class PageProxieGroupItem extends StatefulWidget {
  const PageProxieGroupItem({Key? key, required this.proxie, required this.onChange}) : super(key: key);
  final ProxieProxiesItem proxie;
  final Function(ProxieProxiesItem proxie, String value) onChange;

  @override
  _PageProxieGroupItemState createState() => _PageProxieGroupItemState();
}

class _PageProxieGroupItemState extends State<PageProxieGroupItem> {
  bool _expand = false;

  @override
  Widget build(BuildContext context) {
    final group = widget.proxie;
    // TODO: 临时解决卡顿问题
    final tags = group.all!.sublist(0, _expand ? group.all!.length : min(group.all!.length, 10));

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
              .map((e) => PageProxieGroupItemTab(
                    text: e,
                    // fail: proxiesStore.timeoutProxies.contains(e),
                    value: group.now == e,
                    disabled: group.type != ProxieProxieType.selector,
                    onClick: () => widget.onChange(widget.proxie, e),
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

class PageProxieGroupItemTab extends StatelessWidget {
  const PageProxieGroupItemTab({Key? key, required this.text, this.fail = false, this.value = false, this.disabled = false, this.onClick})
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

class PageProxieItem extends StatelessWidget {
  PageProxieItem({Key? key, required this.proxie}) : super(key: key);
  final ProxieProxiesItem proxie;

  final _colors = {
    const Color(0xff909399): 0,
    const Color(0xff00c520): 260,
    const Color(0xffff9a28): 600,
    const Color(0xffff3e5e): double.infinity,
  };

  @override
  Widget build(BuildContext context) {
    final delay = proxie.history.isEmpty ? 0 : proxie.history.last.delay;
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

class PageProxieProvider extends StatefulWidget {
  const PageProxieProvider({Key? key, required this.provider, required this.onUpdate, required this.onHealthCheck}) : super(key: key);
  final ProxieProviderItem provider;
  final Future<void> Function(ProxieProviderItem provider) onUpdate;
  final Future<void> Function(ProxieProviderItem provider) onHealthCheck;

  @override
  _PageProxieProviderState createState() => _PageProxieProviderState();
}

class _PageProxieProviderState extends State<PageProxieProvider> {
  final LoadingController _loadingController = LoadingController();

  _handleOnHealthCheck() async {
    _loadingController.show();
    await widget.onHealthCheck(widget.provider);
    _loadingController.hide();
  }

  _handleOnUpdate() async {
    _loadingController.show();
    await widget.onUpdate(widget.provider);
    _loadingController.hide();
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    return Loading(
      controller: _loadingController,
      child: CardView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Row(children: [Text(provider.name), Tag(provider.vehicleType).padding(left: 10)]).expanded(),
                Text(provider.updatedAt == null ? '' : '最后更新于：${Day().useLocale(locale).from(Day.fromString(provider.updatedAt!))}'),
                IconButton(icon: Icon(Icons.network_check, size: 20, color: Theme.of(context).primaryColor), onPressed: _handleOnHealthCheck),
                IconButton(icon: Icon(Icons.refresh, size: 20, color: Theme.of(context).primaryColor), onPressed: _handleOnUpdate)
              ],
            ).height(40),
            Wrap(spacing: 10, runSpacing: 10, children: provider.proxies.map((e) => PageProxieItem(proxie: e)).toList()).padding(top: 20)
          ],
        ).width(double.infinity).padding(all: 15),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
