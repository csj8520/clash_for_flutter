import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class PageHead extends StatefulWidget {
  const PageHead({Key? key, required this.title, this.headPrefix, this.headSuffix}) : super(key: key);
  final String title;
  final Widget? headPrefix;
  final Widget? headSuffix;

  @override
  _PageHeadState createState() => _PageHeadState();
}

class _PageHeadState extends State<PageHead> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        widget.headPrefix,
        Text(widget.title)
            .textColor(const Color(0xff2c8af8))
            .fontSize(24)
            .textShadow(color: const Color(0x662c8af8), blurRadius: 6, offset: const Offset(0, 2))
            .expanded(),
        widget.headPrefix,
      ].whereType<Widget>().toList(),
    ).padding(top: 12, bottom: 12);
  }
}
