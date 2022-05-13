class Proxie {
  Proxie({
    required this.proxies,
  });
  late Map<String, ProxieProxiesItem> proxies;

  Proxie.fromJson(Map<String, dynamic> json) {
    proxies = (json['proxies'] as Map<String, dynamic>).map((key, value) => MapEntry(key, ProxieProxiesItem.fromJson(value)));
  }

  // Map<String, dynamic> toJson() {
  //   final _data = <String, dynamic>{};
  //   _data['proxies'] = proxies.toJson();
  //   return _data;
  // }

  // @override
  // String toString() {
  //   return toJson().toString();
  // }
}

class ProxieProxiesItem {
  ProxieProxiesItem({
    this.all,
    required this.history,
    required this.name,
    this.now,
    required this.type,
    required this.udp,
  });
  late List<String>? all;
  late List<ProxieProxiesItemHistory> history;
  late String name;
  late String? now;
  late String type;
  late bool udp;

  ProxieProxiesItem.fromJson(Map<String, dynamic> json) {
    all = json['all'] == null ? null : List.castFrom<dynamic, String>(json['all']);
    history = List.from(json['history']).map((e) => ProxieProxiesItemHistory.fromJson(e)).toList();
    name = json['name'];
    now = json['now'];
    type = json['type'];
    udp = json['udp'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['all'] = all;
    data['history'] = history.map((e) => e.toJson()).toList();
    data['name'] = name;
    data['now'] = now;
    data['type'] = type;
    data['udp'] = udp;
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class ProxieProxiesItemHistory {
  ProxieProxiesItemHistory({
    required this.time,
    required this.delay,
  });
  late String time;
  late int delay;

  ProxieProxiesItemHistory.fromJson(Map<String, dynamic> json) {
    time = json['time'];
    delay = json['delay'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['time'] = time;
    data['delay'] = delay;
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class ProxieProvider {
  ProxieProvider({
    required this.providers,
  });
  late Map<String, ProxieProviderItem> providers;

  ProxieProvider.fromJson(Map<String, dynamic> json) {
    providers = (json['providers'] as Map<String, dynamic>).map((key, value) => MapEntry(key, ProxieProviderItem.fromJson(value)));
  }

  // Map<String, dynamic> toJson() {
  //   final _data = <String, dynamic>{};
  //   _data['providers'] = providers.toJson();
  //   return _data;
  // }

  // @override
  // String toString() {
  //   return toJson().toString();
  // }
}

class ProxieProviderItem {
  ProxieProviderItem({
    required this.name,
    required this.proxies,
    required this.type,
    required this.vehicleType,
    this.updatedAt,
  });
  late String name;
  late List<ProxieProxiesItem> proxies;
  late String type;
  late String vehicleType;
  late String? updatedAt;

  ProxieProviderItem.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    proxies = List.from(json['proxies']).map((e) => ProxieProxiesItem.fromJson(e)).toList();
    type = json['type'];
    vehicleType = json['vehicleType'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['proxies'] = proxies.map((e) => e.toJson()).toList();
    data['type'] = type;
    data['vehicleType'] = vehicleType;
    data['updatedAt'] = updatedAt;
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class ProxieProxieType {
  static String selector = 'Selector';
  static String urltest = 'URLTest';
  static String fallback = 'Fallback';
  static String loadbalance = 'LoadBalance';
  static String direct = 'Direct';
  static String reject = 'Reject';
}
