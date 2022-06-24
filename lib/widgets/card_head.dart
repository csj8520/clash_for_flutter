import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class CardHead extends StatefulWidget {
  const CardHead({Key? key, required this.title, this.prefix, this.suffix}) : super(key: key);
  final String title;
  final Widget? prefix;
  final Widget? suffix;

  @override
  State<CardHead> createState() => _CardHeadState();
}

class _CardHeadState extends State<CardHead> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        widget.prefix,
        Text(widget.title)
            .textColor(Theme.of(context).primaryColor)
            .fontSize(24)
            .textShadow(color: const Color(0x662c8af8), blurRadius: 6, offset: const Offset(0, 2)),
        widget.suffix,
      ].whereType<Widget>().toList(),
    ).height(50);
  }
}
