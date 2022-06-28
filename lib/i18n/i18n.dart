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
          // tray
          "tray_restart_clash_core": "Restart Clash Core",
          "tray_show": "Show",
          "tray_copy_command_line_proxy": "Copy command line proxy",
          "tray_about": "About",
          "tray_exit": "Exit",
          // modal
          "model_ok": "Ok",
          "model_cancel": "Cancel",
          "model_delete": "Delete",
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
          "proxie_title": 'Proxies',
          "proxie_group_title": "Policy Group",
          "proxie_provider_title": "Providers",
          "proxie_provider_update_time": "Last updated at",
          "proxie_expand": "Expand",
          "proxie_collapse": "Collapse",
          "proxie_speed_test": "Speed Test",
          "proxie_break_connections": "Close connections which include the group",
          // rule
          "rule_title": "Rules",
          "rule_provider_title": "Providers",
          "rule_provider_update_time": "Last updated at",
          "rule_rule_count": "Rule count",
          // connection
          "connection_title": "Connections",
          "connection_keep_closed": "Keep closed connections",
          "connection_total": "(total: upload @upload download @download)",
          "connection_filter": "filter",
          "connection_close_all_title": "Warning",
          "connection_close_all_content": "This would close all connections",
          "connection_columns_host": "Host",
          "connection_columns_network": "Network",
          "connection_columns_process": "Type",
          "connection_columns_type": "Chains",
          "connection_columns_chains": "Process",
          "connection_columns_rule": "Rule",
          "connection_columns_time": "Time",
          "connection_columns_speed": "Speed",
          "connection_columns_upload": "Upload",
          "connection_columns_download": "Download",
          "connection_columns_source_ip": "Source IP",
          "connection_info_title": "Connection",
          "connection_info_id": "ID",
          "connection_info_host": "Host",
          "connection_info_empty": "Empty",
          "connection_info_dst_ip": "IP",
          "connection_info_src_ip": "Source",
          "connection_info_upload": "Upload",
          "connection_info_download": "Download",
          "connection_info_network": "Network",
          "connection_info_process": "Process",
          "connection_info_process_path": "Path",
          "connection_info_inbound": "Inbound",
          "connection_info_rule": "Rule",
          "connection_info_chains": "Chains",
          "connection_info_status": "Status",
          "connection_info_opening": "Open",
          "connection_info_closed": "Closed",
          "connection_info_close_connection": "Close",
          // profile
          "profile_title": "Profiles",
          "profile_update_interval": "Update interval",
          "profile_update_interval_min": "Not less than one minute!",
          "profile_update_interval_error": "Please enter the correct time!",
          "profile_hour": "Hour",
          "profile_columens_config_name": "Config name",
          "profile_columens_url": "URL",
          "profile_columens_update_time": "Update time",
          "profile_columens_traffic": "Used/Total",
          "profile_columens_expire": "Expiration",
          "profile_columens_open_config_folder": "Open config folder",
          "profile_columens_add_config": "Add config",
          "profile_config_add": "Add",
          "profile_config_edit": "Edit",
          "profile_config_ext_error": "Make sure the file suffix is .yaml",
          "profile_config_already_exists": "Config: @name already exists",
          "profile_config_no_change": "Config no change",
          "profile_config_update_error": "Update config: @name Error\nMsg: @msg",
          "profile_config_keep_one": "Keep at least one config file",
          "profile_config_mode_title": "Warning",
          "profile_config_mode_content": "Delete: @name config, disk files will be deleted!",
          "profile_config_mode_file_name": "name",
          "profile_config_mode_file_name_hint": "config.yaml",
          "profile_config_mode_url": "url",
          "profile_config_mode_url_hint": "The local config can be left blank",
        },
        'zh_CN': {
          "clash_core_version": "Clash 内核 版本",
          // tray
          "tray_restart_clash_core": "重启 Clash Core",
          "tray_show": "显示",
          "tray_copy_command_line_proxy": "复制命令行代理",
          "tray_about": "关于",
          "tray_exit": "退出",
          // modal
          "model_ok": "确 定",
          "model_cancel": "取 消",
          "model_delete": "删 除",
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
          "proxie_title": '代理',
          "proxie_group_title": "策略组",
          "proxie_provider_title": "代理集",
          "proxie_provider_update_time": "最后更新于",
          "proxie_expand": "展开",
          "proxie_collapse": "收起",
          "proxie_speed_test": "测速",
          "proxie_break_connections": "切换时打断包含策略组的连接",
          // rule
          "rule_title": "规则",
          "rule_provider_title": "规则集",
          "rule_provider_update_time": "最后更新于",
          "rule_rule_count": "规则条数",
          // connection
          "connection_title": "连接",
          "connection_keep_closed": "保留关闭连接",
          "connection_total": "(总量：上传 @upload 下载 @download)",
          "connection_filter": "过滤",
          "connection_close_all_title": "警告",
          "connection_close_all_content": "将会关闭所有连接",
          "connection_columns_host": "域名",
          "connection_columns_network": "网络",
          "connection_columns_process": "进程",
          "connection_columns_type": "类型",
          "connection_columns_chains": "节点链",
          "connection_columns_rule": "规则",
          "connection_columns_time": "连接时间",
          "connection_columns_speed": "速率",
          "connection_columns_upload": "上传",
          "connection_columns_download": "下载",
          "connection_columns_source_ip": "来源 IP",
          "connection_info_title": "连接信息",
          "connection_info_id": "ID",
          "connection_info_host": "域名",
          "connection_info_empty": "空",
          "connection_info_dst_ip": "IP",
          "connection_info_src_ip": "来源",
          "connection_info_upload": "上传",
          "connection_info_download": "下载",
          "connection_info_network": "网络",
          "connection_info_process": "进程",
          "connection_info_process_path": "路径",
          "connection_info_inbound": "入口",
          "connection_info_rule": "规则",
          "connection_info_chains": "代理",
          "connection_info_status": "状态",
          "connection_info_opening": "连接中",
          "connection_info_closed": "已关闭",
          "connection_info_close_connection": "关闭连接",
          // profile
          "profile_title": "配置",
          "profile_update_interval": "更新间隔",
          "profile_update_interval_min": "时间不可小于一分钟！",
          "profile_update_interval_error": "请输入正确的时间！",
          "profile_hour": "小时",
          "profile_columens_config_name": "配置文件名称",
          "profile_columens_url": "链接",
          "profile_columens_update_time": "更新时间",
          "profile_columens_traffic": "已用/总量",
          "profile_columens_expire": "过期时间",
          "profile_columens_open_config_folder": "打开配置文件夹",
          "profile_columens_add_config": "添加配置",
          "profile_config_add": "添加",
          "profile_config_edit": "编辑",
          "profile_config_ext_error": "请确保文件后缀名为.yaml",
          "profile_config_already_exists": "配置文件：@name 已存在",
          "profile_config_no_change": "配置无变化",
          "profile_config_update_error": "更新配置：@name 失败\nMsg: @msg",
          "profile_config_keep_one": "请至少保留一个配置文件",
          "profile_config_mode_title": "警告",
          "profile_config_mode_content": "删除：@name 配置，磁盘内文件会同时删除！",
          "profile_config_mode_file_name": "文件名",
          "profile_config_mode_file_name_hint": "config.yaml",
          "profile_config_mode_url": "地址",
          "profile_config_mode_url_hint": "本地配置可留空",
        }
      };
}
