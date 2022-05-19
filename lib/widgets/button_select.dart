import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_for_flutter/utils/utils.dart';

class ButtonSelect extends StatelessWidget {
  const ButtonSelect({Key? key, required this.labels, this.value = 0, this.onSelect}) : super(key: key);
  final List<String> labels;
  final int value;
  final void Function(int idx)? onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        labels.length,
        ((idx) => TextButton(
              onPressed: onSelect?.bindOne(idx),
              child: Text(labels[idx]).textColor(value == idx ? Colors.white : const Color(0xff54759a)).fontSize(12),
            ).decorated(
              color: idx == value ? Theme.of(context).primaryColor : Colors.white,
              border: idx == value ? null : Border.all(color: const Color(0xffe4eaef), width: 1),
              borderRadius: BorderRadius.horizontal(
                left: idx == 0 ? const Radius.circular(4) : Radius.zero,
                right: idx == labels.length - 1 ? const Radius.circular(4) : Radius.zero,
              ),
            )),
      ),
    );
  }
}
