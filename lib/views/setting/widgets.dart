import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:clash_for_flutter/widgets/card_view.dart';

class SettingBlock extends StatelessWidget {
  const SettingBlock({Key? key, required this.children}) : super(key: key);
  final List<List<Widget>> children;

  @override
  Widget build(BuildContext context) {
    return CardView(
      child: children
          .map((it) => it.map((e) => e.padding(left: 32, right: 32).height(46).expanded()).toList().toRow())
          .toList()
          .toColumn()
          .padding(top: 12, bottom: 12),
    );
  }
}

class SettingItem extends StatelessWidget {
  const SettingItem({Key? key, this.title, this.child}) : super(key: key);
  final String? title;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (title == null && child == null) return const Row();
    return [
      Text(title ?? '').fontSize(14).textColor(const Color(0xff54859a)).expanded(),
      child ?? Container().expanded(),
    ].toRow();
  }
}

class SettingPort extends StatelessWidget {
  const SettingPort({Key? key, required this.text}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text)
        .textColor(Colors.grey.shade800)
        .fontSize(14)
        .alignment(Alignment.center)
        .padding(all: 5)
        .decorated(border: Border.all(width: 1, color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4))
        .constrained(width: 100, height: 30);
  }
}
