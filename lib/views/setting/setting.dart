import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_for_flutter/i18n/i18n.dart';
import 'package:clash_for_flutter/store/config.dart';
import 'package:clash_for_flutter/store/clash_core.dart';
import 'package:clash_for_flutter/widgets/card_head.dart';
import 'package:clash_for_flutter/widgets/card_view.dart';
import 'package:clash_for_flutter/store/clash_service.dart';
import 'package:clash_for_flutter/widgets/button_select.dart';

class PageSetting extends StatefulWidget {
  const PageSetting({Key? key}) : super(key: key);

  @override
  _PageSettingState createState() => _PageSettingState();
}

class _PageSettingState extends State<PageSetting> with AutomaticKeepAliveClientMixin {
  final StoreConfig storeConfig = Get.find();
  final StoreClashService storeClashService = Get.find();
  final StoreClashCore storeClashCore = Get.find();

  final ScrollController _scrollController = ScrollController();
  final List<String> _modes = ['global', 'rule', 'direct', 'script'];

  bool _serviceSwitching = false;

  @override
  bool get wantKeepAlive => true;

  void launchWebGui() {
    final address = storeConfig.clashCoreApiAddress.value.split(':');
    final host = address[0];
    final port = address[1];
    launch('http${host == '127.0.0.1' ? 's' : ''}://clash.razord.top/?host=$host&port=$port&secret=${storeConfig.clashCoreApiSecret.value}');
  }

  Future clashServiceSwitch(bool open) async {
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

  Future languageSwitch(int idx) async {
    Get.updateLocale(I18n.locales[idx]);
    storeConfig.setLanguage(I18n.locales[idx].toString());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      controller: _scrollController,
      child: Obx(() => Column(
            children: [
              CardHead(title: 'setting_title'.tr),
              _SettingBlock(
                children: [
                  _SettingLine(
                    children: [
                      _SettingItem(
                        title: 'setting_start_at_login'.tr,
                        child: Switch(value: storeConfig.config.value.startAtLogin, onChanged: (v) => {}),
                      ),
                      _SettingItem(
                        title: 'setting_language'.tr,
                        child: ButtonSelect(
                          value: I18n.locales.indexWhere((it) => '${it.languageCode}_${it.countryCode}' == storeConfig.config.value.language),
                          labels: I18n.localeSwitchs,
                          onSelect: languageSwitch,
                        ),
                      ),
                    ],
                  ),
                  _SettingLine(
                    children: [
                      _SettingItem(
                        title: 'setting_set_as_system_proxy'.tr,
                        child: Switch(value: storeConfig.config.value.autoSetProxy, onChanged: (v) => {}),
                      ),
                      _SettingItem(
                        title: 'setting_allow_connect_from_lan'.tr,
                        // child: Switch(value: clashApiConfigStore.allowLan, onChanged: clashApiConfigStore.setAllowLan)
                      ),
                    ],
                  ),
                  _SettingLine(
                    children: [
                      _SettingItem(
                        title: 'setting_service_open'.tr,
                        child: Switch(
                          value: storeClashService.serviceMode.value,
                          onChanged: _serviceSwitching ? null : clashServiceSwitch,
                        ),
                      ),
                      const _SettingItem(),
                    ],
                  ),
                ],
              ),
              _SettingBlock(
                children: [
                  _SettingLine(
                    children: [
                      _SettingItem(
                        title: 'setting_proxy_mode'.tr,
                        // child: ButtonSelect(
                        //     labels: const ['全局', '规则', '直连', '脚本'],
                        //     value: _modes.indexOf(clashApiConfigStore.mode),
                        //     onSelect: (idx) => clashApiConfigStore.setMode(_modes[idx])),
                      ),
                      _SettingItem(
                        title: 'setting_socks5_proxy_port'.tr,
                        // child: Text(clashApiConfigStore.socksPort.toString())
                        //     .textColor(Colors.grey.shade800)
                        //     .alignment(Alignment.center)
                        //     .padding(all: 5)
                        //     .decorated(border: Border.all(width: 1, color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4))
                        //     .constrained(width: 100, height: 30),
                      ),
                    ],
                  ),
                  _SettingLine(
                    children: [
                      _SettingItem(
                        title: 'setting_http_proxy_port'.tr,
                        // child: Text(clashApiConfigStore.port.toString())
                        //     .textColor(Colors.grey.shade800)
                        //     .alignment(Alignment.center)
                        //     .padding(all: 5)
                        //     .decorated(border: Border.all(width: 1, color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4))
                        //     .constrained(width: 100, height: 30),
                      ),
                      _SettingItem(
                        title: 'setting_mixed_proxy_port'.tr,
                        // child: Text(clashApiConfigStore.mixedPort.toString())
                        //     .textColor(Colors.grey.shade800)
                        //     .alignment(Alignment.center)
                        //     .padding(all: 5)
                        //     .decorated(border: Border.all(width: 1, color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4))
                        //     .constrained(width: 100, height: 30),
                      ),
                    ],
                  ),
                  _SettingLine(
                    children: [
                      _SettingItem(
                        title: 'setting_external_controller'.tr,
                        child: TextButton(child: Text(storeConfig.clashCoreApiAddress.value), onPressed: launchWebGui),
                      ),
                      const _SettingItem()
                    ],
                  ),
                ],
              ),
            ],
          ).padding(top: 5, right: 20, bottom: 20)),
    );
  }
}

class _SettingBlock extends StatelessWidget {
  const _SettingBlock({Key? key, required this.children}) : super(key: key);
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return CardView(
      child: Column(
        children: children,
      ).padding(top: 12, bottom: 12),
    );
  }
}

class _SettingLine extends StatelessWidget {
  const _SettingLine({Key? key, required this.children}) : super(key: key);
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children.map((e) => e.padding(left: 32, right: 32).height(46).expanded()).toList(),
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem({Key? key, this.title, this.child}) : super(key: key);
  final String? title;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: title == null
          ? []
          : [
              Text(title!).fontSize(14).textColor(const Color(0xff54859a)).expanded(),
              child ?? Container().expanded(),
            ],
    );
  }
}
