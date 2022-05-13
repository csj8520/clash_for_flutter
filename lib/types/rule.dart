class RuleProvider {
  RuleProvider({
    required this.providers,
  });
  late Map<String, RuleProvidersProvidersItem> providers;

  RuleProvider.fromJson(Map<String, dynamic> json) {
    providers = (json['providers'] as Map<String, dynamic>).map((key, value) => MapEntry(key, RuleProvidersProvidersItem.fromJson(value)));
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

class RuleProvidersProvidersItem {
  RuleProvidersProvidersItem({
    required this.behavior,
    required this.name,
    required this.ruleCount,
    required this.type,
    required this.updatedAt,
    required this.vehicleType,
  });
  late String behavior;
  late String name;
  late int ruleCount;
  late String type;
  late String updatedAt;
  late String vehicleType;

  RuleProvidersProvidersItem.fromJson(Map<String, dynamic> json) {
    behavior = json['behavior'];
    name = json['name'];
    ruleCount = json['ruleCount'];
    type = json['type'];
    updatedAt = json['updatedAt'];
    vehicleType = json['vehicleType'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['behavior'] = behavior;
    data['name'] = name;
    data['ruleCount'] = ruleCount;
    data['type'] = type;
    data['updatedAt'] = updatedAt;
    data['vehicleType'] = vehicleType;
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class Rule {
  Rule({
    required this.rules,
  });
  late List<RuleRule> rules;

  Rule.fromJson(Map<String, dynamic> json) {
    rules = List.from(json['rules']).map((e) => RuleRule.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['rules'] = rules.map((e) => e.toJson()).toList();
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class RuleRule {
  RuleRule({
    required this.type,
    required this.payload,
    required this.proxy,
  });
  late String type;
  late String payload;
  late String proxy;

  RuleRule.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    payload = json['payload'];
    proxy = json['proxy'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['type'] = type;
    data['payload'] = payload;
    data['proxy'] = proxy;
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
