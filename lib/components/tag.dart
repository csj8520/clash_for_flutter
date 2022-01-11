import 'package:clashf_pro/utils/utils.dart';
import 'package:flutter/material.dart';

class Tag extends StatelessWidget {
  const Tag(this.text, {Key? key, this.bgcolor = Colors.transparent, this.color, this.width}) : super(key: key);
  final String text;
  final Color bgcolor;
  final Color? color;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Text(text)
        .fontSize(12)
        .textColor(color ?? Theme.of(context).primaryColor)
        .alignment(Alignment.center)
        .constrained(height: 24, width: width)
        .padding(left: 10, right: 10)
        .decorated(border: Border.all(width: 2, color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(12), color: bgcolor);
  }
}
