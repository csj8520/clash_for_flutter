import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';

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
          "setting_mode_global": "Global",
          "setting_mode_rules": "Rules",
          "setting_mode_direct": "Direct",
          "setting_mode_script": "Script",
          // proxie
          "proxie_group_title": "Policy Group",
          // tray
          "tray_restart_clash_core": "Restart Clash Core",
          "tray_show": "Show",
          "tray_copy_command_line_proxy": "Copy command line proxy",
          "tray_about": "About",
          "tray_exit": "Exit",
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
          "setting_mode_global": "全局",
          "setting_mode_rules": "规则",
          "setting_mode_direct": "直连",
          "setting_mode_script": "脚本",
          // proxie
          "proxie_group_title": "策略组",
          // tray
          "tray_restart_clash_core": "重启 Clash Core",
          "tray_show": "显示",
          "tray_copy_command_line_proxy": "复制命令行代理",
          "tray_about": "关于",
          "tray_exit": "退出",
        }
      };
}
