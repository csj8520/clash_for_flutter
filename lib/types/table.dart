import 'package:flutter/widgets.dart';

class TableItem<T> {
  String head;
  double width;
  Alignment align;
  bool tooltip;
  String Function(T connect) getLabel;
  int Function(T a, T b)? sort;
  TableItem({
    required this.head,
    required this.width,
    required this.align,
    required this.getLabel,
    this.tooltip = false,
    this.sort,
  });
}
