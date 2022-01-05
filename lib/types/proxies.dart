import 'package:clashf_pro/utils/utils.dart';

enum ProxiesGroupType { selector, urltest, fallback }

class ProxiesGroupHistory {
  String time;
  int delay;
  ProxiesGroupHistory({required this.time, required this.delay});

  static ProxiesGroupHistory buildFromJson(Map<String, dynamic> json) {
    return ProxiesGroupHistory(time: json['time'], delay: json['delay']);
  }

  @override
  String toString() {
    return '{"time": "$time", "delay": "$delay"}';
  }
}

class ProxiesGroup {
  String name;
  ProxiesGroupType type;
  String now;
  List<String> all;
  List<ProxiesGroupHistory> history;
  ProxiesGroup({required this.name, required this.type, required this.now, required this.all, required this.history});

  static ProxiesGroup buildFromJson(Map<String, dynamic> json) {
    // type: 'Selector' | 'URLTest' | 'Fallback'
    final type = json['type'] == 'Selector'
        ? ProxiesGroupType.selector
        : json['type'] == 'URLTest'
            ? ProxiesGroupType.urltest
            : ProxiesGroupType.fallback;

    // (json['all'] as List<dynamic>).whereType<String>()
    return ProxiesGroup(name: json['name'], type: type, now: json['now'], all: [], history: []);
  }

  @override
  String toString() {
    return '{"name": "$name", "type": "$type", "now": "$now", "all": "$all", "history": "$history"}';
  }
}

class ProxiesGroups {
  List<ProxiesGroup> groups;
  ProxiesGroups(this.groups);

  static ProxiesGroups buildFromJson(Map<String, dynamic> json) {
    // for (var it in (json['GLOBAL']['all'] as List<dynamic>)) {
    //   log.debug(it);
    // }
    final global = ProxiesGroup.buildFromJson(json['GLOBAL']);
    log.debug(global);

    return ProxiesGroups([]);
  }
}
