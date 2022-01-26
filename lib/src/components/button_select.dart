import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class ButtonSelect extends StatelessWidget {
  const ButtonSelect({Key? key, required this.labels, this.value = 0, this.onSelect}) : super(key: key);
  final List<String> labels;
  final int value;
  final Function(int idx)? onSelect;

  final _border = const BorderSide(color: Color(0xffe4eaef), width: 1);
  final _radius = const Radius.circular(4);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: labels
          .asMap()
          .keys
          .map((idx) => TextButton(
                  child: Text(labels[idx]).textColor(value == idx ? Colors.white : const Color(0xff54759a)).fontSize(12),
                  onPressed: onSelect == null ? null : () => onSelect!(idx))
              .decorated(
                color: value == idx ? Theme.of(context).primaryColor : Colors.white,
                // TODO-FIX: 边框重合
                border: value == idx ? null : Border(left: _border, right: _border, top: _border, bottom: _border),
                borderRadius: idx == 0
                    ? BorderRadius.only(topLeft: _radius, bottomLeft: _radius)
                    : idx == labels.length - 1
                        ? BorderRadius.only(topRight: _radius, bottomRight: _radius)
                        : null,
              )
              .borderRadius()
              .border())
          .toList(),
    );
  }
}
