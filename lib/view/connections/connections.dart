import 'package:flutter/material.dart';

class ViewConnections extends StatefulWidget {
  const ViewConnections({Key? key, this.show = false}) : super(key: key);
  final bool show;

  @override
  _ViewConnectionsState createState() => _ViewConnectionsState();
}

class _ViewConnectionsState extends State<ViewConnections> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('ViewConnections'),
    );
  }
}
