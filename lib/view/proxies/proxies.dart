import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_pro_for_flutter/fetch/index.dart';
import 'package:clash_pro_for_flutter/types/index.dart';
import 'package:clash_pro_for_flutter/components/index.dart';

import 'components/proxie.dart';

class PageProxiesProxies extends StatefulWidget {
  const PageProxiesProxies({Key? key, required this.proxies}) : super(key: key);
  final List<ProxiesProxie> proxies;

  @override
  _PageProxiesProxiesState createState() => _PageProxiesProxiesState();
}

class _PageProxiesProxiesState extends State<PageProxiesProxies> {
  _speedTest() async {
    for (var it in widget.proxies) {
      fetchProxyDelay(it.name).then((value) {
        setState(() => it.delay = value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CardHead(
            title: '代理',
            suffix: Align(
              alignment: Alignment.centerRight,
              child: IconButton(icon: Icon(Icons.speed, size: 20, color: Theme.of(context).primaryColor), onPressed: _speedTest),
            ).expanded()),
        Wrap(spacing: 10, runSpacing: 10, children: widget.proxies.map((it) => BlockProxie(proxie: it)).toList()),
      ],
    );
  }
}
