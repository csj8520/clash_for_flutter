import 'dart:ui';

import 'package:day/day.dart';
import 'package:day/i18n/en.dart' as day_locale_en;
import 'package:day/i18n/zh_cn.dart' as day_locale_zh;
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:clash_for_flutter/i18n/i18n.dart';
import 'package:clash_for_flutter/utils/system_proxy.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';

class PageSettingController extends GetxController {
  final List<String> modes = ['global', 'rule', 'direct', 'script'];

  var systemProxySwitchIng = false.obs;

  void launchWebGui() {
    final address = controllers.config.clashCoreApiAddress.value.split(':');
    final host = address[0];
    final port = address[1];
    final url =
        'http${host == '127.0.0.1' ? 's' : ''}://clash.razord.top/#/proxies?host=$host&port=$port&secret=${controllers.config.clashCoreApiSecret.value}';
    launchUrl(Uri.parse(url));
  }

  Future<void> languageSwitch(int idx) async {
    await applyLanguage(I18n.locales[idx]);
    controllers.config.setLanguage(I18n.locales[idx].toString());
  }

  Future<void> applyLanguage(Locale locale) async {
    await Get.updateLocale(locale);
    Day.locale = locale.languageCode == 'en' ? day_locale_en.locale : day_locale_zh.locale;
  }

  Future<void> systemProxySwitch(bool open) async {
    systemProxySwitchIng.value = true;

    await SystemProxy.instance.set(open ? controllers.core.proxyConfig : SystemProxyConfig());
    await controllers.config.setSystemProxy(open);
    systemProxySwitchIng.value = false;
  }
}
