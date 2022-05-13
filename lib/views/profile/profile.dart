import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_for_flutter/widgets/card_view.dart';
import 'package:clash_for_flutter/widgets/card_head.dart';

import 'package:clash_for_flutter/store/config.dart';
import 'package:clash_for_flutter/store/profile.dart';

import 'package:clash_for_flutter/const/const.dart';
import 'package:clash_for_flutter/views/profile/setting.dart';
import 'package:clash_for_flutter/views/profile/widgets.dart';

final dio = Dio();

class PageProfile extends StatefulWidget {
  const PageProfile({Key? key}) : super(key: key);

  @override
  State<PageProfile> createState() => _PageProfileState();
}

class _PageProfileState extends State<PageProfile> {
  final StoreConfig storeConfig = Get.find();
  final StoreProfile storeProfile = Get.find();

  final ScrollController _scrollController = ScrollController();

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
                              onPressed: () => storeProfile.showAddSubPopup(context, null),
                            ).paddingDirectional(start: 15, end: 3)
                          ],
                        ).padding(right: 10).width(160),
                      ],
                    ).padding(all: 5, left: 15, right: 15).alignment(Alignment.center).backgroundColor(Colors.grey.shade100),
                    ...storeConfig.config.value.subs
                        .map((e) => PageProfileSubItem(
                              sub: e,
                              value: storeConfig.config.value.selected,
                              onEdit: (sub) => storeProfile.showEditSubPopup(context, sub),
                              onSelect: storeProfile.handleSelectSub,
                              onDelete: (sub) => storeProfile.handleDeleteSub(context, sub),
                              onUpdate: storeProfile.handleUpdateSub,
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
