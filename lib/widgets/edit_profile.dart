import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class EditProfile extends StatelessWidget {
  EditProfile({Key? key, this.name, this.url}) : super(key: key) {
    nameInputController.text = name ?? '';
    urlInputController.text = url ?? '';
  }
  final String? name;
  final String? url;

  final TextEditingController nameInputController = TextEditingController();
  final TextEditingController urlInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Text('文件名').fontSize(12).textColor(Colors.grey.shade700).alignment(Alignment.centerRight).padding(right: 5).width(50),
            TextField(
              controller: nameInputController,
              style: const TextStyle(fontSize: 12),
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                hintText: 'config.yaml',
                isCollapsed: true,
                contentPadding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                border: InputBorder.none,
              ),
            ).width(200).decorated(border: Border.all(width: 1, color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
          ],
        ),
        Row(
          children: [
            const Text('地址').fontSize(12).textColor(Colors.grey.shade700).alignment(Alignment.centerRight).padding(right: 5).width(50),
            TextField(
              controller: urlInputController,
              style: const TextStyle(fontSize: 12),
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                hintText: '本地配置可留空',
                isCollapsed: true,
                contentPadding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                border: InputBorder.none,
              ),
            ).width(200).decorated(border: Border.all(width: 1, color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
          ],
        ).padding(top: 10),
      ],
    ).height(94);
  }
}
