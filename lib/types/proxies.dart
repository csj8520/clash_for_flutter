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

// enum ProxiesGroupType { selector, urltest, fallback, loadbalance, direct, reject }

// extension ListExtension on List {
//   List toString() => this;
// }

class ProxiesGroupType {
  static String selector = 'Selector';
  static String urltest = 'URLTest';
  static String fallback = 'Fallback';
  static String loadbalance = 'LoadBalance';
  static String direct = 'Direct';
  static String reject = 'Reject';
}

class ProxiesGroup {
  String name;
  String type;
  String? now;
  bool udp;
  List<String> all;
  List<ProxiesGroupHistory> history;
  ProxiesGroup({required this.name, required this.type, this.now, required this.udp, required this.all, required this.history});

  // static Map<String, ProxiesGroupType> stringToType = {
  //   'Selector': ProxiesGroupType.selector,
  //   'URLTest': ProxiesGroupType.urltest,
  //   'Fallback': ProxiesGroupType.fallback,
  //   'LoadBalance': ProxiesGroupType.loadbalance,
  //   'Direct': ProxiesGroupType.direct,
  //   'Reject': ProxiesGroupType.reject,
  // };

  // static Map<ProxiesGroupType, String> typeToString = {
  //   ProxiesGroupType.selector: 'Selector',
  //   ProxiesGroupType.urltest: 'URLTest',
  //   ProxiesGroupType.fallback: 'Fallback',
  //   ProxiesGroupType.loadbalance: 'LoadBalance',
  //   ProxiesGroupType.direct: 'Direct',
  //   ProxiesGroupType.reject: 'Reject',
  // };

  static ProxiesGroup buildFromJson(Map<String, dynamic> json) {
    return ProxiesGroup(
      name: json['name'],
      type: json['type'],
      now: json['now'],
      udp: json['udp'],
      all: (json['all'] as List<dynamic>).whereType<String>().toList(),
      history: (json['history'] as List<dynamic>).map((e) => ProxiesGroupHistory.buildFromJson(e)).toList(),
    );
  }

  @override
  String toString() {
    return '{"name": "$name", "type": "$type", "now": "$now", "udp": $udp, "all": $all, "history": $history}';
  }
}

class ProxiesProxy {
  List<ProxiesGroupHistory> history;
  String name;
  String type;
  bool udp;
  ProxiesProxy({required this.history, required this.name, required this.type, required this.udp});

  static ProxiesProxy buildFromJson(Map<String, dynamic> json) {
    return ProxiesProxy(
      name: json['name'],
      type: json['type'],
      udp: json['udp'],
      history: (json['history'] as List<dynamic>).map((e) => ProxiesGroupHistory.buildFromJson(e)).toList(),
    );
  }

  @override
  String toString() {
    return '{"history": "$history", "name": "$name", "type": "$type", "udp": $udp}';
  }
}

class ProxiesProviders {
  String name;
  List<ProxiesProxy> proxies;
  String type;
  String updatedAt;
  String vehicleType;
  ProxiesProviders({required this.name, required this.proxies, required this.type, required this.updatedAt, required this.vehicleType});
  static ProxiesProviders buildFromJson(Map<String, dynamic> json) {
    return ProxiesProviders(
      name: json['name'],
      proxies: (json['proxies'] as List<dynamic>).map((e) => ProxiesProxy.buildFromJson(e)).toList(),
      type: json['type'],
      updatedAt: json['updatedAt'],
      vehicleType: json['vehicleType'],
    );
  }

  @override
  String toString() {
    return '{"name": "$name", "proxies": $proxies, "type": "$type", "updatedAt": "$updatedAt", "vehicleType": "$vehicleType"}';
  }
}

class Proxies {
  ProxiesGroup global;
  List<ProxiesGroup> groups;
  List<ProxiesProviders> providers;
  List<ProxiesProxy> proxies;
  Map<String, ProxiesProxy> allProxies;
  late List<String> timeoutProxies;
  Proxies({required this.global, required this.groups, required this.providers, required this.proxies, required this.allProxies}) {
    timeoutProxies = allProxies.values.where((value) => value.history.isNotEmpty && value.history.last.delay == 0).map((e) => e.name).toList();
  }

  static List<String> groupNames = [ProxiesGroupType.selector, ProxiesGroupType.urltest, ProxiesGroupType.fallback, ProxiesGroupType.loadbalance];
  static List<String> excludeNames = ['DIRECT', 'REJECT', 'GLOBAL'];

  static updateGroup() {}

  static Proxies buildFromJson(Map<String, dynamic> json, Map<String, dynamic> json2) {
    final global = ProxiesGroup.buildFromJson(json['GLOBAL']!);
    final groups = global.all
        .where((it) => !excludeNames.contains(it) && groupNames.contains(json[it]['type']))
        .map((e) => ProxiesGroup.buildFromJson(json[e]!))
        .toList();

    final proxies = global.all
        .where((it) => !excludeNames.contains(it) && !groupNames.contains(json[it]['type']))
        .map((e) => ProxiesProxy.buildFromJson(json[e]!))
        .toList();

    final providers = json2.values.where((it) => it['vehicleType'] != 'Compatible').map((it) => ProxiesProviders.buildFromJson(it)).toList();
    Map<String, ProxiesProxy> allProxies = {};
    for (var it in providers) {
      for (var el in it.proxies) {
        allProxies[el.name] = el;
      }
    }
    for (var it in proxies) {
      allProxies[it.name] = it;
    }
    return Proxies(global: global, groups: groups, providers: providers, proxies: proxies, allProxies: allProxies);
  }

  @override
  String toString() {
    return '{"global": $global, "groups": $groups, "providers": $providers}';
  }
}
