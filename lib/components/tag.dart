import 'package:clashf_pro/utils/utils.dart';
import 'package:flutter/widgets.dart';

class Tag extends StatelessWidget {
  const Tag(this.text, {Key? key}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text)
        .fontSize(12)
        .textColor(themColorBlue)
        .alignment(Alignment.center)
        .height(24)
        .padding(left: 10, right: 10)
        .decorated(border: Border.all(width: 2, color: themColorBlue), borderRadius: BorderRadius.circular(12));
  }
}
