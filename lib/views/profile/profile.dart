import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_for_flutter/widgets/card_view.dart';
import 'package:clash_for_flutter/widgets/card_head.dart';

import 'package:clash_for_flutter/store/config.dart';
import 'package:clash_for_flutter/store/clash_core.dart';
import 'package:clash_for_flutter/store/clash_service.dart';

import 'package:clash_for_flutter/const/const.dart';
import 'package:clash_for_flutter/types/config.dart';
import 'package:clash_for_flutter/utils/system_dns.dart';
import 'package:clash_for_flutter/utils/system_proxy.dart';
import 'package:clash_for_flutter/views/profile/setting.dart';
import 'package:clash_for_flutter/views/profile/widgets.dart';

final dio = Dio();

class PageProfile extends StatefulWidget {
  const PageProfile({Key? key}) : super(key: key);

  @override
  _PageProfileState createState() => _PageProfileState();
}

class _PageProfileState extends State<PageProfile> {
  final StoreConfig storeConfig = Get.find();
  final StoreClashService storeClashService = Get.find();
  final StoreClashCore storeClashCore = Get.find();

  final ScrollController _scrollController = ScrollController();

  void addSub() {
    showDialog(context: context, builder: (_) => PageProfileEditProfile(title: '添加', onEnter: _addSub));
  }

  void editSub(ConfigSub sub) {
    showDialog(context: context, builder: (_) => PageProfileEditProfile(name: sub.name, url: sub.url, onEnter: (n, u, c) => _editSub(sub, n, u, c)));
  }

  Future<dynamic> _addSub(String name, String url, VoidCallback close) async {
    if (!RegExp(r'^[^.].*\.ya?ml$').hasMatch(name)) return BotToast.showText(text: '请确保文件后缀名为.yaml');
    final has = storeConfig.config.value.subs.firstWhereOrNull((it) => it.name == name);
    if (has != null) return BotToast.showText(text: "$name 已存在");
    final ConfigSub sub = ConfigSub(name: name, url: url.isEmpty ? null : url);
    await storeConfig.addSub(sub);
    close();
  }

  Future<dynamic> _editSub(ConfigSub oldSub, String name, String url, VoidCallback close) async {
    if (!RegExp(r'^[^.].*\.ya?ml$').hasMatch(name)) return BotToast.showText(text: '请确保文件后缀名为.yaml');
    final _sub = storeConfig.config.value.subs.firstWhere((it) => it.name == oldSub.name);
    final ConfigSub sub = ConfigSub(name: name, url: url.isEmpty ? null : url, updateTime: oldSub.updateTime);
    await storeConfig.setSub(_sub.name, sub);
    close();
  }

  Future<dynamic> updateSub(ConfigSub sub) async {
    try {
      final changed = await storeConfig.updateSub(sub);
      if (!changed) return BotToast.showText(text: '配置无变化');
      if (storeConfig.config.value.selected == sub.name) {
        BotToast.showText(text: '正在重启 Clash Core ……');
        await reloadClashCore();
        BotToast.showText(text: '重启成功');
      }
    } catch (e) {
      BotToast.showText(text: 'Update Sub: ${sub.name} Error');
    }
  }

  dynamic deleteSub(ConfigSub sub) {
    if (storeConfig.config.value.subs.length <= 1) return BotToast.showText(text: '请至少保留一个配置文件');
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('确定'),
        content: Text('删除 ${sub.name} 配置，磁盘内文件会同时删除。'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(c);
              await storeConfig.deleteSub(sub.name);
            },
            child: const Text('删除'),
          ),
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('取消')),
        ],
      ),
    );
  }

  Future<void> reloadClashCore() async {
    await storeClashService.fetchStop();
    await storeClashService.fetchStart(storeConfig.config.value.selected);
    await storeConfig.readClashCoreApi();
    storeClashCore.setApi(storeConfig.clashCoreApiAddress.value, storeConfig.clashCoreApiSecret.value);
    await storeClashCore.waitCoreStart();
    if (Platform.isMacOS) {
      if (storeConfig.clashCoreDns.isNotEmpty) {
        await MacSystemDns.instance.set([storeConfig.clashCoreDns.value]);
      } else {
        await MacSystemDns.instance.set([]);
      }
    }
    if (storeConfig.config.value.setSystemProxy) await SystemProxy.instance.set(storeClashCore.proxyConfig);
  }

  Future<void> selectSub(ConfigSub sub) async {
    await storeConfig.setSelectd(sub.name);
    BotToast.showText(text: '正在重启 Clash Core ……');
    await reloadClashCore();
    BotToast.showText(text: '重启成功');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Obx(() => Column(
            children: [
              const CardHead(title: '配置'),
              const PageProfileSetting(),
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
                              onPressed: () => launchUrl(Uri.parse('file:${Paths.config.path}')),
                            ),
                            IconButton(
                              iconSize: 20,
                              tooltip: 'Add Config',
                              icon: const Icon(Icons.add),
                              padding: const EdgeInsets.all(0),
                              color: Theme.of(context).primaryColor,
                              constraints: const BoxConstraints(minHeight: 30, minWidth: 30),
                              onPressed: addSub,
                            ).paddingDirectional(start: 15, end: 3)
                          ],
                        ).padding(right: 10).width(160),
                      ],
                    ).padding(all: 5, left: 15, right: 15).alignment(Alignment.center).backgroundColor(Colors.grey.shade100),
                    ...storeConfig.config.value.subs
                        .map((e) => PageProfileSubItem(
                              sub: e,
                              value: storeConfig.config.value.selected,
                              onEdit: editSub,
                              onSelect: selectSub,
                              onDelete: deleteSub,
                              onUpdate: updateSub,
                            ))
                        .toList()
                  ],
                ),
              ),
            ],
          ).padding(top: 5, right: 20, bottom: 20)),
    );
  }
}
