import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:day/day.dart';
import 'package:day/plugins/relative_time.dart';

import 'package:clash_for_flutter/utils/utils.dart';
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

class PageProxieGroupTabItem {
  final String name;
  final String? type;
  final int? delay;
  PageProxieGroupTabItem({required this.name, required this.type, required this.delay});
}

class PageProxieGroup extends StatefulWidget {
  const PageProxieGroup({Key? key, required this.title, required this.type, this.now, this.tabs, this.onChange}) : super(key: key);
  final String title;
  final String type;
  final String? now;
  final List<PageProxieGroupTabItem>? tabs;
  final void Function(String name)? onChange;

  @override
  State<PageProxieGroup> createState() => _PageProxieGroupState();
}

class _PageProxieGroupState extends State<PageProxieGroup> {
  bool overflow = false;
  bool expand = false;
  double cacheWidth = 0;
  bool init = false;
  List<Widget> children = [];

  final EdgeInsets itemPadding = const EdgeInsets.only(left: 10, right: 10);
  final double padding = 15;
  final double titleWidth = 190;
  final double expandWidth = 65;
  final double spacing = 6;

  final textPainter = TextPainter(textDirection: TextDirection.ltr);

  void _buildTab() {
    children = [];
    if (widget.tabs == null) return;
    final maxWidth = (context.findRenderObject() as RenderBox).size.width - padding * 2 - titleWidth - expandWidth;
    double currentWidth = 0;
    for (final it in widget.tabs!) {
      final active = widget.now == it.name;
      final span = TextSpan(
        style: TextStyle(fontSize: 12, color: active ? Colors.white : const Color(0xff54759a)),
        children: [
          TextSpan(text: it.name),
          // WidgetSpan(child: Text('ii').constrained(width: 50, height: 24)),
          if (it.type != null) TextSpan(text: ' ${it.type}').fontSize(8),
          if (it.delay != null && it.delay! > 0) TextSpan(text: ' ${it.delay}ms').fontSize(8).textColor(getColor(it.delay!)),
        ],
      );
      textPainter
        ..text = span
        ..layout();
      currentWidth += (textPainter.width + spacing + itemPadding.left + itemPadding.right);
      if ((currentWidth - spacing) > maxWidth && !expand && children.isNotEmpty) break;

      children.add(TextButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all(itemPadding),
          minimumSize: MaterialStateProperty.all(Size.zero),
          fixedSize: MaterialStateProperty.all(const Size.fromHeight(24)),
        ),
        onPressed: widget.onChange?.bindOne(it.name),
        child: RichText(text: span, overflow: TextOverflow.ellipsis),
      ).decorated(
        color: active ? Theme.of(context).primaryColor : Colors.transparent,
        border: Border.all(width: 1, color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(12),
      ));
    }
    overflow = (currentWidth - spacing) > maxWidth;
    setState(() {});
  }

  void setExpand() {
    setState(() {
      expand = !expand;
      _buildTab();
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buildTab();
      cacheWidth = MediaQuery.of(context).size.width;
      init = true;
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PageProxieGroup oldWidget) {
    _buildTab();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (init) {
      final width = MediaQuery.of(context).size.width;
      if (width != cacheWidth) {
        cacheWidth = width;
        _buildTab();
      }
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(widget.title, overflow: TextOverflow.ellipsis).width(80),
          Tag(widget.type).padding(left: 10),
        ]).width(titleWidth),
        Wrap(spacing: spacing, runSpacing: 6, children: children).constrained(maxHeight: expand ? double.infinity : 24).clipRect().expanded(),
        if (overflow)
          TextButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all(EdgeInsets.zero),
              minimumSize: MaterialStateProperty.all(Size.zero),
              fixedSize: MaterialStateProperty.all(Size(expandWidth, 24)),
            ),
            onPressed: setExpand,
            child: Text(expand ? 'proxie_collapse'.tr : 'proxie_expand'.tr).fontSize(14).textColor(const Color(0xff546b87)),
          )
      ],
    ).paddingAll(padding).border(bottom: 1, color: const Color(0xffd8dee2));
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
