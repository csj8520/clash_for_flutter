import 'package:clashf_pro/components/index.dart';
import 'package:clashf_pro/utils/utils.dart';
import 'package:clashf_pro/view/proxies/components/proxie.dart';
import 'package:flutter/material.dart';

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
        CardHead(title: '代理', suffix: IconButton(icon: Icon(Icons.speed, size: 20, color: Theme.of(context).primaryColor), onPressed: _speedTest)),
        Wrap(spacing: 10, runSpacing: 10, children: widget.proxies.map((it) => BlockProxie(proxie: it)).toList()),
      ],
    );
  }
}
