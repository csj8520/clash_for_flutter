class ClashServiceInfo {
  ClashServiceInfo({
    required this.code,
    required this.mode,
    required this.status,
    required this.version,
  });
  late int code;
  late String mode;
  late String status;
  late String version;

  ClashServiceInfo.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    mode = json['mode'];
    status = json['status'];
    version = json['version'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['code'] = code;
    _data['mode'] = mode;
    _data['status'] = status;
    _data['version'] = version;
    return _data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
