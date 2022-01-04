import 'package:flutter/material.dart';

class ViewSettings extends StatefulWidget {
  const ViewSettings({Key? key, this.show = false}) : super(key: key);
  final bool show;

  @override
  _ViewSettingsState createState() => _ViewSettingsState();
}

class _ViewSettingsState extends State<ViewSettings> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('ViewSettings'),
    );
  }
}
