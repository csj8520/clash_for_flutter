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
    final _data = <String, dynamic>{};
    _data['selected'] = selected;
    _data['updateInterval'] = updateInterval;
    _data['updateSubsAtStart'] = updateSubsAtStart;
    _data['setSystemProxy'] = setSystemProxy;
    _data['startAtLogin'] = startAtLogin;
    _data['breakConnections'] = breakConnections;
    _data['language'] = language;
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