import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_for_flutter/views/log/log.dart';
import 'package:clash_for_flutter/views/rule/rule.dart';
import 'package:clash_for_flutter/views/home/sidebar.dart';
import 'package:clash_for_flutter/views/proxie/proxie.dart';
import 'package:clash_for_flutter/views/profile/profile.dart';
import 'package:clash_for_flutter/views/setting/setting.dart';
import 'package:clash_for_flutter/views/connection/connection.dart';

class PageHome extends StatefulWidget {
  const PageHome({Key? key, required this.pageController}) : super(key: key);
  final PageController pageController;

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
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
            controller: widget.pageController,
          ),
          PageView(
            scrollDirection: Axis.vertical,
            controller: widget.pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              PageProxie(),
              PageLog(),
              PageRule(),
              PageConnection(),
              PageProfile(),
              PageSetting(),
            ],
          ).expanded()
        ],
      ).height(double.infinity).backgroundColor(const Color(0xfff4f5f6)),
    );
  }
}
