import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_for_flutter/i18n/i18n.dart';
import 'package:clash_for_flutter/store/config.dart';
import 'package:clash_for_flutter/store/clash_core.dart';
import 'package:clash_for_flutter/widgets/card_head.dart';
import 'package:clash_for_flutter/utils/system_proxy.dart';
import 'package:clash_for_flutter/store/clash_service.dart';
import 'package:clash_for_flutter/widgets/button_select.dart';
import 'package:clash_for_flutter/views/setting/widgets.dart';

class PageSetting extends StatefulWidget {
  const PageSetting({Key? key}) : super(key: key);

  @override
  _PageSettingState createState() => _PageSettingState();
}

class _PageSettingState extends State<PageSetting> {
  final StoreConfig storeConfig = Get.find();
  final StoreClashService storeClashService = Get.find();
  final StoreClashCore storeClashCore = Get.find();

  final ScrollController _scrollController = ScrollController();
  final List<String> _modes = ['global', 'rule', 'direct', 'script'];

  bool _serviceSwitching = false;

  void launchWebGui() {
    final address = storeConfig.clashCoreApiAddress.value.split(':');
    final host = address[0];
    final port = address[1];
    final url = 'http${host == '127.0.0.1' ? 's' : ''}://clash.razord.top/?host=$host&port=$port&secret=${storeConfig.clashCoreApiSecret.value}';
    launchUrl(Uri.parse(url));
  }

  Future<void> clashServiceSwitch(bool open) async {
    setState(() {
      _serviceSwitching = true;
    });
    if (open) {
      await storeClashService.install();
    } else {
      await storeClashService.uninstall();
    }
    await storeClashService.init();
    await storeClashService.fetchStart(storeConfig.config.value.selected);
    await storeClashCore.waitCoreStart();
    setState(() {
      _serviceSwitching = false;
    });
  }

  Future<void> languageSwitch(int idx) async {
    Get.updateLocale(I18n.locales[idx]);
    storeConfig.setLanguage(I18n.locales[idx].toString());
  }

  Future<void> systemProxySwitch(bool open) async {
    await SystemProxy.instance.set(open ? storeClashCore.proxyConfig : SystemProxyConfig());
    await storeConfig.setSystemProxy(open);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Obx(() => Column(
            children: [
              CardHead(title: 'setting_title'.tr),
              SettingBlock(
                children: [
                  [
                    SettingItem(
                      title: 'setting_start_at_login'.tr,
                      child: Switch(value: storeConfig.config.value.startAtLogin, onChanged: (v) => {}),
                    ),
                    SettingItem(
                      title: 'setting_language'.tr,
                      child: ButtonSelect(
                        value: I18n.locales.indexWhere((it) => '${it.languageCode}_${it.countryCode}' == storeConfig.config.value.language),
                        labels: I18n.localeSwitchs,
                        onSelect: languageSwitch,
                      ),
                    ),
                  ],
                  [
                    SettingItem(
                      title: 'setting_set_as_system_proxy'.tr,
                      child: Switch(
                        value: storeConfig.config.value.setSystemProxy,
                        onChanged: systemProxySwitch,
                      ),
                    ),
                    SettingItem(
                      title: 'setting_allow_connect_from_lan'.tr,
                      child: Switch(
                        value: storeClashCore.config.value.allowLan,
                        onChanged: (v) => storeClashCore.fetchConfigUpdate({'allow-lan': v}),
                      ),
                    ),
                  ],
                  [
                    SettingItem(
                      title: 'setting_service_open'.tr,
                      child: Switch(
                        value: storeClashService.serviceMode.value,
                        onChanged: _serviceSwitching ? null : clashServiceSwitch,
                      ),
                    ),
                    const SettingItem(),
                  ],
                ],
              ),
              SettingBlock(
                children: [
                  [
                    SettingItem(
                      title: 'setting_proxy_mode'.tr,
                      child: ButtonSelect(
                        labels: ['setting_mode_global'.tr, 'setting_mode_rules'.tr, 'setting_mode_direct'.tr, 'setting_mode_script'.tr],
                        value: _modes.indexOf(storeClashCore.config.value.mode),
                        onSelect: (idx) => storeClashCore.fetchConfigUpdate({'mode': _modes[idx]}),
                      ),
                    ),
                    SettingItem(
                      title: 'setting_socks5_proxy_port'.tr,
                      child: SettingPort(text: storeClashCore.config.value.socksPort.toString()),
                    ),
                  ],
                  [
                    SettingItem(
                      title: 'setting_http_proxy_port'.tr,
                      child: SettingPort(text: storeClashCore.config.value.port.toString()),
                    ),
                    SettingItem(
                      title: 'setting_mixed_proxy_port'.tr,
                      child: SettingPort(text: storeClashCore.config.value.mixedPort.toString()),
                    ),
                  ],
                  [
                    SettingItem(
                      title: 'setting_external_controller'.tr,
                      child: TextButton(child: Text(storeConfig.clashCoreApiAddress.value), onPressed: launchWebGui),
                    ),
                    const SettingItem()
                  ],
                ],
              ),
            ],
          ).padding(top: 5, right: 20, bottom: 20)),
    );
  }
}
