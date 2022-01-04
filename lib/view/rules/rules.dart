import 'package:flutter/widgets.dart';

class ViewRules extends StatefulWidget {
  const ViewRules({Key? key, this.show = false}) : super(key: key);
  final bool show;

  @override
  _ViewRulesState createState() => _ViewRulesState();
}

class _ViewRulesState extends State<ViewRules> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('ViewRules'),
    );
  }
}
