import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_for_flutter/i18n/i18n.dart';
import 'package:clash_for_flutter/utils/utils.dart';
import 'package:clash_for_flutter/widgets/card_head.dart';
import 'package:clash_for_flutter/widgets/button_select.dart';
import 'package:clash_for_flutter/views/setting/widgets.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';

class PageSetting extends StatefulWidget {
  const PageSetting({Key? key}) : super(key: key);

  @override
  State<PageSetting> createState() => _PageSettingState();
}

class _PageSettingState extends State<PageSetting> {
  final ScrollController _scrollController = ScrollController();

  late StreamSubscription<RunningState> _coreStatusSub;
  late StreamSubscription<bool> _windowStatusSub;
  late StreamSubscription<String> _windowEventSub;

  @override
  void initState() {
    _handleStateChange();
    _coreStatusSub = controllers.service.coreStatus.stream.listen(_handleStateChange);
    _windowStatusSub = controllers.window.isVisible.stream.listen(_handleStateChange);
    _windowEventSub = controllers.window.event.stream.listen((e) {
      if (e == 'focus') _handleStateChange();
    });
    super.initState();
  }

  void _handleStateChange([dynamic _]) async {
    final coreStatus = controllers.service.coreStatus.value;
    final isVisible = controllers.window.isVisible.value;

    if (coreStatus == RunningState.running && isVisible) {
      await controllers.pageSetting.updateDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Obx(() {
        final disabled = !controllers.service.isRunning;

        return Column(
          children: [
            CardHead(title: 'setting_title'.tr),
            SettingBlock(
              children: [
                [
                  SettingItem(
                    title: 'setting_start_at_login'.tr,
                    child: Switch(value: controllers.config.config.value.startAtLogin, onChanged: (v) => {}),
                  ),
                  SettingItem(
                    title: 'setting_language'.tr,
                    child: ButtonSelect(
                      value: I18n.locales.indexWhere((it) => '${it.languageCode}_${it.countryCode}' == controllers.config.config.value.language),
                      labels: I18n.localeSwitchs,
                      onSelect: controllers.pageSetting.languageSwitch,
                    ),
                  ),
                ],
                [
                  SettingItem(
                    title: 'setting_set_as_system_proxy'.tr,
                    child: Switch(
                      value: controllers.config.config.value.setSystemProxy,
                      onChanged: (disabled || controllers.pageSetting.systemProxySwitchIng.value) ? null : controllers.pageSetting.systemProxySwitch,
                    ),
                  ),
                  SettingItem(
                    title: 'setting_allow_connect_from_lan'.tr,
                    child: Switch(
                      value: controllers.core.config.value.allowLan,
                      onChanged: disabled ? null : (v) => controllers.core.fetchConfigUpdate({'allow-lan': v}),
                    ),
                  ),
                ],
                [
                  SettingItem(
                    title: 'setting_service_open'.tr,
                    child: Switch(
                      value: controllers.service.serviceMode.value,
                      onChanged: !controllers.service.isCanOperationService ? null : controllers.service.serviceModeSwitch,
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
                      value: controllers.pageSetting.modes.indexOf(controllers.core.config.value.mode),
                      onSelect: disabled ? null : (idx) => controllers.core.fetchConfigUpdate({'mode': controllers.pageSetting.modes[idx]}),
                    ),
                  ),
                  SettingItem(
                    title: 'setting_socks5_proxy_port'.tr,
                    child: SettingPort(text: controllers.core.config.value.socksPort.toString()),
                  ),
                ],
                [
                  SettingItem(
                    title: 'setting_http_proxy_port'.tr,
                    child: SettingPort(text: controllers.core.config.value.port.toString()),
                  ),
                  SettingItem(
                    title: 'setting_mixed_proxy_port'.tr,
                    child: SettingPort(text: controllers.core.config.value.mixedPort.toString()),
                  ),
                ],
                [
                  SettingItem(
                    title: 'setting_external_controller'.tr,
                    child: TextButton(
                      onPressed: disabled ? null : controllers.pageSetting.launchWebGui,
                      child: Text(controllers.config.clashCoreApiAddress.value).fontSize(14),
                    ),
                  ),
                  const SettingItem()
                ],
              ],
            ),
          ],
        ).padding(top: 5, right: 20, bottom: 20);
      }),
    );
  }

  @override
  void dispose() {
    _coreStatusSub.cancel();
    _windowStatusSub.cancel();
    _windowEventSub.cancel();
    _scrollController.dispose();
    super.dispose();
  }
}
