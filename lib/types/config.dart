class Config {
  Config({
    required this.selected,
    required this.updateInterval,
    required this.updateSubsAtStart,
    required this.autoSetProxy,
    required this.startAtLogin,
    required this.breakConnections,
    required this.subs,
  });
  late String selected;
  late int updateInterval;
  late bool updateSubsAtStart;
  late bool autoSetProxy;
  late bool startAtLogin;
  late bool breakConnections;
  late List<ConfigSub> subs;

  Config.fromJson(Map<String, dynamic> json) {
    selected = json['selected'];
    updateInterval = json['updateInterval'];
    updateSubsAtStart = json['updateSubsAtStart'];
    autoSetProxy = json['autoSetProxy'];
    startAtLogin = json['startAtLogin'];
    breakConnections = json['breakConnections'];
    subs = List.from(json['subs']).map((e) => ConfigSub.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['selected'] = selected;
    _data['updateInterval'] = updateInterval;
    _data['updateSubsAtStart'] = updateSubsAtStart;
    _data['autoSetProxy'] = autoSetProxy;
    _data['startAtLogin'] = startAtLogin;
    _data['breakConnections'] = breakConnections;
    _data['subs'] = subs.map((e) => e.toJson()).toList();
    return _data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class ConfigSub {
  ConfigSub({
    required this.name,
    required this.url,
    required this.updateTime,
  });
  late String name;
  late String url;
  late int updateTime;

  ConfigSub.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    url = json['url'];
    updateTime = json['updateTime'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    _data['url'] = url;
    _data['updateTime'] = updateTime;
    return _data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
