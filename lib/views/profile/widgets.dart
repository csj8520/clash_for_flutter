import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:day/day.dart';
import 'package:day/i18n/zh_cn.dart';
import 'package:day/plugins/relative_time.dart';

import 'package:clash_for_flutter/types/config.dart';
import 'package:clash_for_flutter/widgets/loading.dart';

class PageProfileSubItem extends StatefulWidget {
  const PageProfileSubItem({
    Key? key,
    required this.sub,
    required this.value,
    required this.onEdit,
    required this.onSelect,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  final ConfigSub sub;
  final String value;
  final void Function(ConfigSub) onEdit;
  final void Function(ConfigSub) onSelect;
  final void Function(ConfigSub) onDelete;
  final Future<void> Function(ConfigSub) onUpdate;

  @override
  State<PageProfileSubItem> createState() => _PageProfileSubItemState();
}

class _PageProfileSubItemState extends State<PageProfileSubItem> {
  final LoadingController _loadingController = LoadingController();

  Future<void> _onUpdate() async {
    _loadingController.show();
    await widget.onUpdate(widget.sub);
    _loadingController.hide();
  }

  @override
  Widget build(BuildContext context) {
    return Loading(
        controller: _loadingController,
        child: Row(
          children: [
            Text(widget.sub.name).padding(right: 5).expanded(),
            Text(widget.sub.url ?? '-').padding(right: 5).expanded(),
            Text(widget.sub.updateTime == null ? '-' : Day().useLocale(locale).from(Day.fromUnix(widget.sub.updateTime! * 1000)))
                .padding(right: 5)
                .expanded(),
            Row(
              children: [
                IconButton(
                  tooltip: 'Refresh',
                  color: Theme.of(context).primaryColor,
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: (widget.sub.url ?? '').isEmpty ? null : _onUpdate,
                ),
                IconButton(
                  tooltip: 'Edit',
                  color: Theme.of(context).primaryColor,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => widget.onEdit(widget.sub),
                ),
                IconButton(
                  tooltip: 'Delete',
                  color: Theme.of(context).primaryColor,
                  icon: const Icon(Icons.delete_forever, size: 20),
                  onPressed: widget.value == widget.sub.name ? null : () => widget.onDelete(widget.sub),
                ),
                Radio(
                  value: widget.sub.name,
                  groupValue: widget.value,
                  onChanged: (v) => widget.onSelect(widget.sub),
                )
              ],
            ).width(160),
          ],
        ).padding(left: 15, right: 15, all: 5).border(bottom: 1, color: Colors.grey.shade200));
  }
}

class PageProfileEditProfile extends StatelessWidget {
  PageProfileEditProfile({Key? key, this.title, this.name, this.url, required this.onEnter}) : super(key: key) {
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
