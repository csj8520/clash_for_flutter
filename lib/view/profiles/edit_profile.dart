import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class EditProfile extends StatelessWidget {
  EditProfile({Key? key, this.title, this.name, this.url, required this.onEnter}) : super(key: key) {
    _addProfileNameInputController.text = name ?? '';
    _addProfileUrlInputController.text = url ?? '';
  }
  final String? title;
  final String? name;
  final String? url;
  final TextEditingController _addProfileNameInputController = TextEditingController();
  final TextEditingController _addProfileUrlInputController = TextEditingController();
  final Function(String name, String url, VoidCallback close) onEnter;

  @override
  Widget build(BuildContext context) {
    void _close() => Navigator.pop(context);

    return AlertDialog(
      title: Text(title ?? '编辑'),
      content: Column(
        children: [
          Row(
            children: [
              const Text('文件名').fontSize(12).textColor(Colors.grey.shade700).alignment(Alignment.centerRight).padding(right: 5).width(50),
              TextField(
                controller: _addProfileNameInputController,
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
                controller: _addProfileUrlInputController,
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
      ).height(94),
      actions: [
        TextButton(
            onPressed: () => onEnter(_addProfileNameInputController.text, _addProfileUrlInputController.text, _close), child: const Text('确定')),
        TextButton(onPressed: _close, child: const Text('取消')),
      ],
    );
  }
}
