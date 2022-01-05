import 'package:clashf_pro/components/page_head.dart';
import 'package:clashf_pro/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class ViewProxies extends StatefulWidget {
  const ViewProxies({Key? key, this.show = false, this.inited = false}) : super(key: key);
  final bool show;
  final bool inited;

  @override
  _ViewProxiesState createState() => _ViewProxiesState();
}

class _ViewProxiesState extends State<ViewProxies> {
  ProxiesGroups? _proxiesGroups;

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

  _update() async {
    _proxiesGroups = await fetchClashProxies();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHead(title: '策略组'),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: (_proxiesGroups?.groups.map((e) => Text(e.name)).toList() ?? [])..add(Text('data')),
          ).width(double.infinity),
          Text(widget.show ? 'ViewProxies-show' : 'ViewProxies-hide'),
          const PageHead(title: '代理集'),
        ],
      ),
    );
  }
}
