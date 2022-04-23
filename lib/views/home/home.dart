import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_for_flutter/views/log/log.dart';
import 'package:clash_for_flutter/views/home/sidebar.dart';
import 'package:clash_for_flutter/views/setting/setting.dart';

class PageHome extends StatefulWidget {
  const PageHome({Key? key}) : super(key: key);

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  final PageController _pageController = PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SideBar(
            menus: [
              'sidebar_proxies'.tr,
              'sidebar_logs'.tr,
              'sidebar_rules'.tr,
              'sidebar_connections'.tr,
              'sidebar_profiles'.tr,
              'sidebar_settings'.tr
            ],
            controller: _pageController,
          ),
          PageView(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              Text('coding'),
              PageLog(),
              Text('coding'),
              Text('coding'),
              Text('coding'),
              PageSetting(),
            ],
          ).expanded()
        ],
      ).height(double.infinity).backgroundColor(const Color(0xfff4f5f6)),
    );
  }
}
