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
    final data = <String, dynamic>{};
    data['code'] = code;
    data['mode'] = mode;
    data['status'] = status;
    data['version'] = version;
    return data;
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
    final data = <String, dynamic>{};
    data['time'] = time;
    data['type'] = type;
    data['msg'] = msg;
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
