import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clashf_pro/fetch/index.dart';
import 'package:clashf_pro/types/index.dart';
// import 'package:clashf_pro/utils/index.dart';

import 'proxies.dart';
import 'proxy_group.dart';
import 'providers.dart';

class PageProxies extends StatefulWidget {
  const PageProxies({Key? key}) : super(key: key);
  // const PageProxies({Key? key, required this.pageVisibleEvent}) : super(key: key);
  // final PageVisibleEvent pageVisibleEvent;

  @override
  _PageProxiesState createState() => _PageProxiesState();
}

class _PageProxiesState extends State<PageProxies> {
  Proxies? _proxies;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // widget.pageVisibleEvent.onVisible('proxies', (show) {
    //   if (show) _update();
    // });
    _update();
  }

  Future<void> _update() async {
    _proxies = await fetchClashProxies();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];
    if (_proxies != null) children.add(PageProxiesProxyGroup(proxies: _proxies!));
    if (_proxies?.providers.isNotEmpty ?? false) children.add(PageProxiesProviders(providers: _proxies!.providers, onUpdate: _update));
    if (_proxies?.proxies.isNotEmpty ?? false) children.add(PageProxiesProxies(proxies: _proxies!.proxies));

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ).padding(top: 5, right: 20, bottom: 20),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
