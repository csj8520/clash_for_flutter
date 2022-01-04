import 'package:clashf_pro/utils/utils.dart';
import 'package:flutter/material.dart';

class ViewProxies extends StatefulWidget {
  const ViewProxies({Key? key, this.show = false}) : super(key: key);
  final bool show;

  @override
  _ViewProxiesState createState() => _ViewProxiesState();
}

class _ViewProxiesState extends State<ViewProxies> {
  @override
  void didUpdateWidget(covariant ViewProxies oldWidget) {
    if (!oldWidget.show && widget.show) {
      super.didUpdateWidget(oldWidget);
      // update data
      log.debug('-----show');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(widget.show ? 'ViewProxies-show' : 'ViewProxies-hide'),
    );
  }
}
