import 'package:clash_for_flutter/src/store/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:styled_widget/styled_widget.dart';

import 'proxies.dart';
import 'proxy_group.dart';
import 'providers.dart';

class PageProxies extends StatefulWidget {
  const PageProxies({Key? key}) : super(key: key);

  @override
  _PageProxiesState createState() => _PageProxiesState();
}

class _PageProxiesState extends State<PageProxies> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _update();
  }

  Future<void> _update() async {
    await proxiesStore.update();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Observer(builder: (_) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            proxiesStore.groups.isEmpty ? null : const PageProxiesProxyGroup(),
            proxiesStore.providers.isEmpty ? null : const PageProxiesProviders(),
            proxiesStore.proxies.isEmpty ? null : const PageProxiesProxies(),
          ].whereType<Widget>().toList(),
        ).padding(top: 5, right: 20, bottom: 20);
      }),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
