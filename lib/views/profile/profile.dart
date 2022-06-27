import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_for_flutter/widgets/card_view.dart';
import 'package:clash_for_flutter/widgets/card_head.dart';

import 'package:clash_for_flutter/const/const.dart';
import 'package:clash_for_flutter/views/profile/setting.dart';
import 'package:clash_for_flutter/views/profile/widgets.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';

final dio = Dio();

class PageProfile extends StatefulWidget {
  const PageProfile({Key? key}) : super(key: key);

  @override
  State<PageProfile> createState() => _PageProfileState();
}

class _PageProfileState extends State<PageProfile> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Obx(() => Column(
            children: [
              CardHead(title: 'profile_title'.tr),
              const PageProfileSetting(),
              CardView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('profile_columens_config_name'.tr).textColor(Colors.grey.shade600).fontSize(14).expanded(),
                        Text('profile_columens_url'.tr).textColor(Colors.grey.shade600).fontSize(14).expanded(),
                        Text('profile_columens_update_time'.tr).textColor(Colors.grey.shade600).fontSize(14).width(100),
                        Text('profile_columens_traffic'.tr).textColor(Colors.grey.shade600).fontSize(14).width(80),
                        Text('profile_columens_expire'.tr).textColor(Colors.grey.shade600).fontSize(14).width(80),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              iconSize: 20,
                              tooltip: 'profile_columens_open_config_folder'.tr,
                              icon: const Icon(Icons.folder_open),
                              padding: const EdgeInsets.all(0),
                              color: Theme.of(context).primaryColor,
                              constraints: const BoxConstraints(minHeight: 30, minWidth: 30),
                              onPressed: () => launchUrl(Uri.parse('file:${Paths.config.path}')),
                            ),
                            IconButton(
                              iconSize: 20,
                              tooltip: 'profile_columens_add_config'.tr,
                              icon: const Icon(Icons.add),
                              padding: const EdgeInsets.all(0),
                              color: Theme.of(context).primaryColor,
                              constraints: const BoxConstraints(minHeight: 30, minWidth: 30),
                              onPressed: () => controllers.pageProfile.showAddSubPopup(context, null),
                            ).paddingDirectional(start: 15, end: 3)
                          ],
                        ).padding(right: 10).width(160),
                      ],
                    ).padding(all: 5, left: 15, right: 15).alignment(Alignment.center).backgroundColor(Colors.grey.shade100),
                    ...controllers.config.config.value.subs
                        .map((e) => PageProfileSubItem(
                              sub: e,
                              value: controllers.config.config.value.selected,
                              onEdit: (sub) => controllers.pageProfile.showEditSubPopup(context, sub),
                              onSelect: controllers.pageProfile.handleSelectSub,
                              onDelete: (sub) => controllers.pageProfile.handleDeleteSub(context, sub),
                              onUpdate: controllers.pageProfile.handleUpdateSub,
                            ))
                        .toList()
                  ],
                ),
              ),
            ],
          ).padding(top: 5, right: 20, bottom: 20)),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
