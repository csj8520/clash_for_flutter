import 'dart:math';

import 'package:clash_for_flutter/controllers/controllers.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:day/day.dart';
import 'package:day/plugins/relative_time.dart';

import 'package:clash_for_flutter/widgets/tag.dart';
import 'package:clash_for_flutter/types/proxie.dart';
import 'package:clash_for_flutter/widgets/loading.dart';
import 'package:clash_for_flutter/widgets/card_view.dart';

final _colors = {
  const Color(0xff909399): 0,
  const Color(0xff00c520): 260,
  const Color(0xffff9a28): 600,
  const Color(0xffff3e5e): double.infinity,
};

Color getColor(int delay) {
  return _colors.keys.firstWhere((it) => (delay <= _colors[it]!));
}

class PageProxieGroupItem extends StatefulWidget {
  const PageProxieGroupItem({Key? key, required this.proxie, required this.onChange}) : super(key: key);
  final ProxieProxiesItem proxie;
  final Function(ProxieProxiesItem proxie, String value) onChange;

  @override
  State<PageProxieGroupItem> createState() => _PageProxieGroupItemState();
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
                    name: e,
                    value: group.now == e,
                    disabled: group.type != ProxieProxieType.selector,
                    onClick: () => widget.onChange(widget.proxie, e),
                  ))
              .toList(),
        ).constrained(maxHeight: _expand ? double.infinity : 24).clipRect().expanded(),
        // TODO: 无更多时不显示
        TextButton(
          child: Text(_expand ? 'proxie_collapse'.tr : 'proxie_expand'.tr).fontSize(14).textColor(const Color(0xff546b87)),
          onPressed: () => setState(() => _expand = !_expand),
        )
      ],
    ).padding(all: 15).border(bottom: 1, color: const Color(0xffd8dee2));
  }
}

class PageProxieGroupItemTab extends StatelessWidget {
  const PageProxieGroupItemTab({Key? key, required this.name, this.value = false, this.disabled = false, this.onClick}) : super(key: key);
  final String name;
  final bool value;
  final bool disabled;
  final Function()? onClick;

  static const groups = [
    ProxieProxieType.selector,
    ProxieProxieType.urltest,
    ProxieProxieType.fallback,
  ];

  int getDelay(ProxieProxiesItem? proxie) {
    final delay = proxie?.delay ?? 0;
    if (delay > 0) return delay;
    if (proxie != null && groups.contains(proxie.type)) {
      return getDelay(controllers.pageProxie.allProxies[proxie.now]);
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    ProxieProxiesItem? proxie = controllers.pageProxie.allProxies[name];
    final delay = getDelay(proxie);

    return TextButton(
            onPressed: disabled ? null : onClick,
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(fontSize: 12, color: value ? Colors.white : const Color(0xff54759a)),
                children: [
                  TextSpan(text: name),
                  if (proxie != null) TextSpan(text: ' ${proxie.type}').fontSize(8),
                  if (delay > 0) TextSpan(text: ' ${delay}ms').fontSize(8).textColor(getColor(delay)),
                ],
              ),
            ))
        .height(24)
        .backgroundColor(value ? Theme.of(context).primaryColor : Colors.transparent)
        .decorated(border: Border.all(width: 1, color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(12))
        .clipRRect(all: 12);
  }
}

class PageProxieItem extends StatelessWidget {
  const PageProxieItem({Key? key, required this.proxie}) : super(key: key);
  final ProxieProxiesItem proxie;

  @override
  Widget build(BuildContext context) {
    final delay = proxie.delay;
    final name = proxie.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(proxie.type)
            .textColor(Colors.white)
            .fontSize(10)
            .padding(left: 5, right: 5, top: 2, bottom: 2)
            .backgroundColor(getColor(delay))
            .clipRRect(all: 2),
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
  State<PageProxieProvider> createState() => _PageProxieProviderState();
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
                Text(provider.updatedAt == null ? '' : '${'proxie_provider_update_time'.tr}：${Day().from(Day.fromString(provider.updatedAt!))}'),
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
