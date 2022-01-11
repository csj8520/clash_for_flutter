import 'package:clashf_pro/utils/utils.dart';
import 'package:flutter/material.dart';

class PageConnections extends StatefulWidget {
  const PageConnections({Key? key, required this.pageVisibleEvent}) : super(key: key);
  final PageVisibleEvent pageVisibleEvent;

  @override
  _PageConnectionsState createState() => _PageConnectionsState();
}

class _PageConnectionsState extends State<PageConnections> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('ViewConnections'),
    );
  }
}
