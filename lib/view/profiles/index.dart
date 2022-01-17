import 'package:clash_pro_for_flutter/utils/index.dart';
import 'package:clash_pro_for_flutter/view/profiles/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:day/day.dart';
import 'package:day/i18n/zh_cn.dart';
import 'package:day/plugins/relative_time.dart';

import 'package:clash_pro_for_flutter/components/index.dart';
import 'package:clash_pro_for_flutter/store/index.dart';

const double _opWidth = 160;

class PageProfiles extends StatefulWidget {
  const PageProfiles({Key? key}) : super(key: key);

  @override
  _PageProfilesState createState() => _PageProfilesState();
}

class _PageProfilesState extends State<PageProfiles> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _updateIntervalInputController = TextEditingController();
  final FocusNode _updateIntervalInputfocusNode = FocusNode();

  @override
  void initState() {
    _updateIntervalInputController.text = (localConfigStore.updateInterval / 60 / 60).toString();
    _updateIntervalInputfocusNode.addListener(_updateIntervalInputEvent);
    super.initState();
  }

  Future<void> _updateIntervalInputEvent() async {
    if (!_updateIntervalInputfocusNode.hasFocus) {
      try {
        final time = (double.parse(_updateIntervalInputController.text) * 60 * 60).toInt();
        if (time == localConfigStore.updateInterval) return;
        if (time < 60) {
          BotToast.showText(text: '时间不可小于一分钟！');
          return;
        }
        await localConfigStore.setUpdateInterval(time);
      } catch (e) {
        BotToast.showText(text: '请输入正确的时间！');
      }
    }
  }

  void _showAddProfileAlert() {
    showDialog(context: context, builder: (_) => EditProfile(title: '添加', onEnter: _addProfile));
  }

  Future<dynamic> _addProfile(String name, String url, VoidCallback close) async {
    if (!localConfigStore.configNameTest.hasMatch(name)) return BotToast.showText(text: '请确保文件后缀名为.yaml');
    final Map<String, dynamic> sub = {'name': name, 'url': url.isEmpty ? null : url};
    await localConfigStore.addSub(sub);
    if (url.isNotEmpty) await localConfigStore.updateSub(sub);
    close();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Observer(
          builder: (_) => Column(
                children: [
                  const CardHead(title: '配置'),
                  CardView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Row(
                              children: [
                                const Text('更新间隔').expanded(),
                                TextField(
                                  controller: _updateIntervalInputController,
                                  focusNode: _updateIntervalInputfocusNode,
                                  style: const TextStyle(fontSize: 14),
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: '小时',
                                    labelStyle: TextStyle(fontSize: 12),
                                    floatingLabelStyle: TextStyle(fontSize: 10),
                                    contentPadding: EdgeInsets.fromLTRB(5, 3, 5, 18),
                                    border: InputBorder.none,
                                  ),
                                )
                                    .constrained(width: 90, height: 30)
                                    .decorated(border: Border.all(width: 1, color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
                              ],
                            ).padding(left: 15, right: 15).expanded(),
                            Row(
                              children: [
                                const Text('启动时更新订阅').expanded(),
                                Switch(value: localConfigStore.updateSubsAtStart, onChanged: localConfigStore.setUpdateSubsAtStart),
                              ],
                            ).padding(left: 15, right: 15).expanded(),
                          ],
                        ).padding(top: 10, bottom: 10),
                      ],
                    ).padding(top: 10, bottom: 10),
                  ),
                  CardView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text('配置文件名称').textColor(Colors.grey.shade600).expanded(),
                            const Text('链接').textColor(Colors.grey.shade600).expanded(),
                            const Text('更新时间').textColor(Colors.grey.shade600).expanded(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  iconSize: 20,
                                  tooltip: 'Open Config Folder',
                                  icon: const Icon(Icons.folder_open),
                                  padding: const EdgeInsets.all(0),
                                  color: Theme.of(context).primaryColor,
                                  constraints: const BoxConstraints(minHeight: 30, minWidth: 30),
                                  onPressed: () => showItemInFolder(CONST.configDir.path),
                                ),
                                IconButton(
                                  iconSize: 20,
                                  tooltip: 'Add Config',
                                  icon: const Icon(Icons.add),
                                  padding: const EdgeInsets.all(0),
                                  color: Theme.of(context).primaryColor,
                                  constraints: const BoxConstraints(minHeight: 30, minWidth: 30),
                                  onPressed: _showAddProfileAlert,
                                ).paddingDirectional(start: 15, end: 3)
                              ],
                            ).padding(right: 10).width(_opWidth),
                          ],
                        ).padding(all: 5, left: 15, right: 15).alignment(Alignment.center).backgroundColor(Colors.grey.shade100),
                        ...localConfigStore.subs.map((e) => _Sub(sub: e)).toList()
                      ],
                    ),
                  ),
                ],
              ).padding(top: 5, right: 20, bottom: 20)),
    );
  }
}

class _Sub extends StatefulWidget {
  const _Sub({Key? key, required this.sub}) : super(key: key);
  final Map<String, dynamic> sub;

  @override
  _SubState createState() => _SubState();
}

class _SubState extends State<_Sub> {
  final LoadingController _loadingController = LoadingController();

  Future<dynamic> _delSub() async {
    if (localConfigStore.subs.length <= 1) return BotToast.showText(text: '请至少保留一个配置文件');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('确定'),
        content: Text('删除 ${widget.sub['name']} 配置，磁盘内文件会同时删除。'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await localConfigStore.removeSub(widget.sub);
            },
            child: const Text('删除'),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
        ],
      ),
    );
  }

  Future<void> _updateSub() async {
    _loadingController.show(context.size);
    await localConfigStore.updateSub(widget.sub);
    _loadingController.hide();
    if (localConfigStore.selected == widget.sub['name']) {
      BotToast.showText(text: '正在重启 Clash ……');
      await globalStore.restartClash();
      BotToast.showText(text: '重启成功');
    }
  }

  Future<void> _switchConfig(String? value) async {
    if (value == null) return;
    await localConfigStore.setSelected(value);
    BotToast.showText(text: '正在重启 Clash ……');
    await globalStore.restartClash();
    BotToast.showText(text: '重启成功');
  }

  void _showAddProfileAlert() {
    showDialog(context: context, builder: (_) => EditProfile(name: widget.sub['name'], url: widget.sub['url'], onEnter: _addProfile));
  }

  Future<dynamic> _addProfile(String name, String url, VoidCallback close) async {
    if (!localConfigStore.configNameTest.hasMatch(name)) return BotToast.showText(text: '请确保文件后缀名为.yaml');
    final Map<String, dynamic> sub = {...widget.sub, 'name': name, 'url': url.isEmpty ? null : url};
    await localConfigStore.setSub(widget.sub['name'], sub);
    close();
  }

  @override
  Widget build(BuildContext context) {
    final sub = widget.sub;

    return Loading(
        controller: _loadingController,
        child: Row(
          children: [
            Text(sub['name']).padding(right: 5).expanded(),
            Text(sub['url'] ?? '-').padding(right: 5).expanded(),
            Text(sub['updateTime'] == null ? '-' : Day().useLocale(locale).from(Day.fromUnix(sub['updateTime'] * 1000))).padding(right: 5).expanded(),
            Row(
              children: [
                IconButton(
                  tooltip: 'Refresh',
                  color: Theme.of(context).primaryColor,
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: sub['url'] == null || (sub['url'] as String).isEmpty ? null : _updateSub,
                ),
                IconButton(
                  tooltip: 'Edit',
                  color: Theme.of(context).primaryColor,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: _showAddProfileAlert,
                ),
                IconButton(
                  tooltip: 'Delete',
                  color: Theme.of(context).primaryColor,
                  icon: const Icon(Icons.delete_forever, size: 20),
                  onPressed: localConfigStore.selected == sub['name'] ? null : _delSub,
                ),
                Radio(
                  value: sub['name'] as String,
                  groupValue: localConfigStore.selected,
                  onChanged: _switchConfig,
                )
              ],
            ).width(_opWidth),
          ],
        ).padding(left: 15, right: 15, all: 5).border(bottom: 1, color: Colors.grey.shade200));
  }
}
