class Config {
  Config({
    required this.selected,
    required this.updateInterval,
    required this.updateSubsAtStart,
    required this.setSystemProxy,
    required this.startAtLogin,
    required this.breakConnections,
    required this.subs,
    required this.language,
  });
  late String selected;
  late int updateInterval;
  late bool updateSubsAtStart;
  late bool setSystemProxy;
  late bool startAtLogin;
  late bool breakConnections;
  late String language;
  late List<ConfigSub> subs;

  Config.fromJson(Map<String, dynamic> json) {
    selected = json['selected'];
    updateInterval = json['updateInterval'];
    updateSubsAtStart = json['updateSubsAtStart'];
    setSystemProxy = json['setSystemProxy'];
    startAtLogin = json['startAtLogin'];
    breakConnections = json['breakConnections'];
    language = json['language'];
    subs = List.from(json['subs']).map((e) => ConfigSub.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['selected'] = selected;
    data['updateInterval'] = updateInterval;
    data['updateSubsAtStart'] = updateSubsAtStart;
    data['setSystemProxy'] = setSystemProxy;
    data['startAtLogin'] = startAtLogin;
    data['breakConnections'] = breakConnections;
    data['language'] = language;
    data['subs'] = subs.map((e) => e.toJson()).toList();
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class ConfigSub {
  ConfigSub({
    required this.name,
    this.url,
    this.updateTime,
  });
  late String name;
  String? url;
  int? updateTime;

  ConfigSub.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    url = json['url'];
    updateTime = json['updateTime'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['url'] = url;
    data['updateTime'] = updateTime;
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
