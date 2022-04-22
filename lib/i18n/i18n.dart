import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

// 大部分翻译来自：
// https://github.com/Dreamacro/clash-dashboard/blob/master/src/i18n/en_US.ts

class I18n extends Translations {
  static const List<Locale> locales = [
    Locale('zh', 'CN'),
    Locale('en', 'US'),
  ];

  static const List<String> localeSwitchs = [
    "中文",
    "English",
  ];

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          "clash_core_version": "Clash Core Version",
          // sidebar
          "sidebar_proxies": "Proxies",
          "sidebar_profiles": "Profiles",
          "sidebar_logs": "Logs",
          "sidebar_rules": "Rules",
          "sidebar_settings": "Setting",
          "sidebar_connections": "Connections",
          "sidebar_version": "Version",
          // setting
          "setting_title": "Settings",
          "setting_start_at_login": "Start at login",
          "setting_language": "Language",
          "setting_set_as_system_proxy": "Set as system proxy",
          "setting_allow_connect_from_lan": "Allow connect from Lan",
          "setting_proxy_mode": "Mode",
          "setting_socks5_proxy_port": "Socks5 proxy port",
          "setting_http_proxy_port": "HTTP proxy port",
          "setting_mixed_proxy_port": "Mixed proxy port",
          "setting_external_controller": "External controller",
          "setting_service_open": "Open Service",
        },
        'zh_CN': {
          "clash_core_version": "Clash 内核 版本",
          // sidebar
          "sidebar_proxies": "代理",
          "sidebar_profiles": "配置",
          "sidebar_logs": "日志",
          "sidebar_rules": "规则",
          "sidebar_settings": "设置",
          "sidebar_connections": "连接",
          // setting
          "setting_title": "设置",
          "setting_start_at_login": "开机时启动",
          "setting_language": "语言",
          "setting_set_as_system_proxy": "设置为系统代理",
          "setting_allow_connect_from_lan": "允许来自局域网的连接",
          "setting_proxy_mode": "代理模式",
          "setting_socks5_proxy_port": "Socks5 代理端口",
          "setting_http_proxy_port": "HTTP 代理端口",
          "setting_mixed_proxy_port": "混合代理端口",
          "setting_external_controller": "外部控制设置",
          "setting_service_open": "开启服务",
        }
      };
}
