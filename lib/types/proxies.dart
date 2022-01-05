import 'package:clashf_pro/utils/utils.dart';

class ProxiesGroupHistory {
  String time;
  int delay;
  ProxiesGroupHistory({required this.time, required this.delay});

  static ProxiesGroupHistory buildFromJson(Map<String, dynamic> json) {
    return ProxiesGroupHistory(time: json['time'], delay: json['delay']);
  }

  @override
  String toString() {
    return '{"time": "$time", "delay": $delay}';
  }
}

enum ProxiesGroupType { selector, urltest, fallback, loadbalance, direct, reject }

class ProxiesGroup {
  String name;
  ProxiesGroupType type;
  String? now;
  bool udp;
  List<String> all;
  List<ProxiesGroupHistory> history;
  ProxiesGroup({required this.name, required this.type, this.now, required this.udp, required this.all, required this.history});

  static Map<String, ProxiesGroupType> stringToType = {
    'Selector': ProxiesGroupType.selector,
    'URLTest': ProxiesGroupType.urltest,
    'Fallback': ProxiesGroupType.fallback,
    'LoadBalance': ProxiesGroupType.loadbalance,
    'Direct': ProxiesGroupType.direct,
    'Reject': ProxiesGroupType.reject,
  };

  static Map<ProxiesGroupType, String> typeToString = {
    ProxiesGroupType.selector: 'Selector',
    ProxiesGroupType.urltest: 'URLTest',
    ProxiesGroupType.fallback: 'Fallback',
    ProxiesGroupType.loadbalance: 'LoadBalance',
    ProxiesGroupType.direct: 'Direct',
    ProxiesGroupType.reject: 'Reject',
  };

  static ProxiesGroup buildFromJson(Map<String, dynamic> json) {
    return ProxiesGroup(
      name: json['name'],
      type: stringToType[json['type']]!,
      now: json['now'],
      udp: json['udp'],
      all: (json['all'] as List<dynamic>).whereType<String>().toList(),
      history: (json['history'] as List<dynamic>).map((e) => ProxiesGroupHistory.buildFromJson(e)).toList(),
    );
  }

  @override
  String toString() {
    return '{"name": "$name", "type": "$type", "now": "$now", "udp": $udp, "all": "$all", "history": "$history"}';
  }
}

class ProxiesGroups {
  List<ProxiesGroup> groups;
  ProxiesGroup global;
  ProxiesGroups({required this.groups, required this.global});

  static List<ProxiesGroupType> includeType = [
    ProxiesGroupType.selector,
    ProxiesGroupType.urltest,
    ProxiesGroupType.fallback,
    ProxiesGroupType.loadbalance
  ];
  static List<String> excludeName = ['DIRECT', 'REJECT', 'GLOBAL'];

  static ProxiesGroups buildFromJson(Map<String, dynamic> json) {
    final global = ProxiesGroup.buildFromJson(json['GLOBAL']);
    final groups = global.all
        .where((it) => !excludeName.contains(it))
        .map((e) => ProxiesGroup.buildFromJson(json[e]))
        .where((it) => includeType.contains(it.type))
        .toList();

    return ProxiesGroups(groups: groups, global: global);
  }
}
