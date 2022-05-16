import 'package:get/get.dart';

import 'package:clash_for_flutter/controllers/tray.dart';
import 'package:clash_for_flutter/controllers/window.dart';
import 'package:clash_for_flutter/controllers/protocol.dart';

import 'package:clash_for_flutter/controllers/core.dart';
import 'package:clash_for_flutter/controllers/config.dart';
import 'package:clash_for_flutter/controllers/service.dart';

import 'package:clash_for_flutter/controller.dart';
import 'package:clash_for_flutter/views/home/controller.dart';
import 'package:clash_for_flutter/views/proxie/controller.dart';
import 'package:clash_for_flutter/views/profile/controller.dart';
import 'package:clash_for_flutter/views/setting/controller.dart';
import 'package:clash_for_flutter/views/connection/controller.dart';

class Controllers {
  late final TrayController tray;
  late final WindowController window;
  late final ProtocolController protocol;

  late final CoreController core;
  late final ConfigController config;
  late final ServiceController service;

  late final PageMainController pageMain;
  late final PageHomeController pageHome;
  late final PageProxieController pageProxie;
  late final PageProfileController pageProfile;
  late final PageSettingController pageSetting;
  late final PageConnectionController pageConnection;

  void init() {
    tray = Get.find();
    window = Get.find();
    protocol = Get.find();

    core = Get.find();
    config = Get.find();
    service = Get.find();

    pageMain = Get.find();
    pageHome = Get.find();
    pageProxie = Get.find();
    pageProfile = Get.find();
    pageSetting = Get.find();
    pageConnection = Get.find();
  }
}

final controllers = Controllers();
