class ClashServiceInfo {
  ClashServiceInfo({
    required this.code,
    required this.mode,
    required this.status,
  });
  late int code;
  late String mode;
  late String status;

  ClashServiceInfo.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    mode = json['mode'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['code'] = code;
    _data['mode'] = mode;
    _data['status'] = status;
    return _data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
