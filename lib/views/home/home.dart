import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_for_flutter/views/log/log.dart';
import 'package:clash_for_flutter/views/rule/rule.dart';
import 'package:clash_for_flutter/views/home/sidebar.dart';
import 'package:clash_for_flutter/views/proxie/proxie.dart';
import 'package:clash_for_flutter/views/profile/profile.dart';
import 'package:clash_for_flutter/views/setting/setting.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';
import 'package:clash_for_flutter/views/connection/connection.dart';

class PageHome extends StatelessWidget {
  const PageHome({Key? key}) : super(key: key);

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
            controller: controllers.pageHome.pageController,
          ),
          PageView(
            scrollDirection: Axis.vertical,
            controller: controllers.pageHome.pageController,
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
