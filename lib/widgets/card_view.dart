import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class CardView extends StatefulWidget {
  const CardView({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  State<CardView> createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  @override
  Widget build(BuildContext context) {
    return widget.child
        .backgroundColor(const Color(0xffffffff))
        .clipRRect(all: 4)
        .boxShadow(color: const Color(0x2e2c8af8), offset: const Offset(2, 5), blurRadius: 20, spreadRadius: -3)
        .padding(top: 5, bottom: 5);
  }
}
