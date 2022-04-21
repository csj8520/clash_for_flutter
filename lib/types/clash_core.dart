class ClashCoreVersion {
  ClashCoreVersion({
    required this.premium,
    required this.version,
  });
  late bool premium;
  late String version;

  ClashCoreVersion.fromJson(Map<String, dynamic> json) {
    premium = json['premium'];
    version = json['version'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['premium'] = premium;
    _data['version'] = version;
    return _data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
