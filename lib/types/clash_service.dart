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

class ClashServiceLog {
  ClashServiceLog({
    required this.time,
    required this.type,
    required this.msg,
  });
  late String time;
  late String type;
  late String msg;

  ClashServiceLog.fromJson(Map<String, dynamic> json) {
    time = json['time'];
    type = json['type'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['time'] = time;
    _data['type'] = type;
    _data['msg'] = msg;
    return _data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
