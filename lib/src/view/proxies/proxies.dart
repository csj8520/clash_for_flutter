import 'package:clash_pro_for_flutter/src/store/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_pro_for_flutter/src/fetch/index.dart';
import 'package:clash_pro_for_flutter/src/components/index.dart';

import 'components/proxie.dart';

class PageProxiesProxies extends StatefulWidget {
  const PageProxiesProxies({Key? key}) : super(key: key);

  @override
  _PageProxiesProxiesState createState() => _PageProxiesProxiesState();
}

class _PageProxiesProxiesState extends State<PageProxiesProxies> {
  _speedTest() async {
    for (var it in proxiesStore.proxies) {
      fetchProxyDelay(it.name).then((value) {
        setState(() => it.delay = value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHead(
            title: '代理',
            suffix: Align(
              alignment: Alignment.centerRight,
              child: IconButton(icon: Icon(Icons.speed, size: 20, color: Theme.of(context).primaryColor), onPressed: _speedTest),
            ).expanded(),
          ),
          Wrap(spacing: 10, runSpacing: 10, children: proxiesStore.proxies.map((it) => BlockProxie(proxie: it)).toList()),
        ],
      );
    });
  }
}
