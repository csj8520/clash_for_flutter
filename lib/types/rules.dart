class Rule {
  String behavior;
  String name;
  int ruleCount;
  String type;
  String updatedAt;
  String vehicleType;
  Rule({
    required this.behavior,
    required this.name,
    required this.ruleCount,
    required this.type,
    required this.updatedAt,
    required this.vehicleType,
  });

  static Rule buildFromJson(Map<String, dynamic> json) {
    return Rule(
      behavior: json['behavior'],
      name: json['name'],
      ruleCount: json['ruleCount'],
      type: json['type'],
      updatedAt: json['updatedAt'],
      vehicleType: json['vehicleType'],
    );
  }

  @override
  String toString() {
    return '{"behavior": "$behavior", "name": "$name", "ruleCount": $ruleCount, "type": "$type", "updatedAt": "$updatedAt", "vehicleType": "$vehicleType"}';
  }
}

class RuleRule {
  String payload;
  String proxy;
  String type;
  RuleRule({required this.payload, required this.proxy, required this.type});

  static RuleRule buildFromJson(Map<String, dynamic> json) {
    return RuleRule(payload: json['payload'], proxy: json['proxy'], type: json['type']);
  }
}
