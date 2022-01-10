import 'package:clashf_pro/components/card_head.dart';
import 'package:clashf_pro/components/index.dart';
import 'package:clashf_pro/utils/utils.dart';
import 'package:clashf_pro/view/proxies/provider.dart';
import 'package:clashf_pro/view/proxies/strategy_group.dart';
import 'package:flutter/material.dart';

class ViewProxies extends StatefulWidget {
  const ViewProxies({Key? key, this.show = false, this.inited = false}) : super(key: key);
  final bool show;
  final bool inited;

  @override
  _ViewProxiesState createState() => _ViewProxiesState();
}

class _ViewProxiesState extends State<ViewProxies> {
  Proxies? _proxies;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(covariant ViewProxies oldWidget) {
    if (!oldWidget.inited && widget.inited) {
      super.didUpdateWidget(oldWidget);
      _init();
    } else if (!oldWidget.show && widget.show) {
      super.didUpdateWidget(oldWidget);
      _update();
    }
  }

  _init() async {
    if (!widget.inited) return;
    _update();
  }

  Future<void> _update() async {
    _proxies = await fetchClashProxies();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHead(title: '策略组'),
          _proxies == null ? null : CardView(child: StrategyGroup(proxies: _proxies!)),
          _proxies?.providers.isNotEmpty ?? false ? const CardHead(title: '代理集') : null,
          ...((_proxies?.providers ?? []).map((it) => CardView(child: Provider(provider: it, onUpdate: _update)))),
          _proxies?.proxies.isNotEmpty ?? false ? const CardHead(title: '代理') : null,
          ...((_proxies?.proxies ?? []).map((it) => ProviderProxies(proxie: it, clickable: true))),
        ].whereType<Widget>().toList(),
      ).padding(top: 5, right: 20, bottom: 20),
    );
  }
}
