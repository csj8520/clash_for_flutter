class Connect {
  Connect({
    required this.downloadTotal,
    required this.uploadTotal,
    required this.connections,
  });
  late int downloadTotal;
  late int uploadTotal;
  late List<ConnectConnection> connections;

  Connect.fromJson(Map<String, dynamic> json) {
    downloadTotal = json['downloadTotal'];
    uploadTotal = json['uploadTotal'];
    connections = List.from(json['connections']).map((e) => ConnectConnection.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['downloadTotal'] = downloadTotal;
    _data['uploadTotal'] = uploadTotal;
    _data['connections'] = connections.map((e) => e.toJson()).toList();
    return _data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class ConnectConnection {
  ConnectConnection({
    required this.id,
    required this.speed,
    required this.metadata,
    required this.upload,
    required this.download,
    required this.start,
    required this.chains,
    required this.rule,
    required this.rulePayload,
  });
  late String id;
  late ConnectConnectionSpeed speed;
  late ConnectConnectionMetadata metadata;
  late int upload;
  late int download;
  late String start;
  late List<String> chains;
  late String rule;
  late String rulePayload;

  ConnectConnection.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    speed = ConnectConnectionSpeed.fromJson(json['speed']);
    metadata = ConnectConnectionMetadata.fromJson(json['metadata']);
    upload = json['upload'];
    download = json['download'];
    start = json['start'];
    chains = List.castFrom<dynamic, String>(json['chains']);
    rule = json['rule'];
    rulePayload = json['rulePayload'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['speed'] = speed.toJson();
    _data['metadata'] = metadata.toJson();
    _data['upload'] = upload;
    _data['download'] = download;
    _data['start'] = start;
    _data['chains'] = chains;
    _data['rule'] = rule;
    _data['rulePayload'] = rulePayload;
    return _data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class ConnectConnectionSpeed {
  ConnectConnectionSpeed({
    required this.download,
    required this.upload,
  });
  late int download;
  late int upload;

  ConnectConnectionSpeed.fromJson(Map<String, dynamic>? json) {
    download = json?['download'] ?? 0;
    upload = json?['upload'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['download'] = download;
    _data['upload'] = upload;
    return _data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class ConnectConnectionMetadata {
  ConnectConnectionMetadata({
    required this.network,
    required this.type,
    required this.sourceIP,
    required this.destinationIP,
    required this.sourcePort,
    required this.destinationPort,
    required this.host,
    required this.dnsMode,
    required this.processPath,
  });
  late String network;
  late String type;
  late String sourceIP;
  late String destinationIP;
  late String sourcePort;
  late String destinationPort;
  late String host;
  late String dnsMode;
  late String processPath;

  ConnectConnectionMetadata.fromJson(Map<String, dynamic> json) {
    network = json['network'];
    type = json['type'];
    sourceIP = json['sourceIP'];
    destinationIP = json['destinationIP'];
    sourcePort = json['sourcePort'];
    destinationPort = json['destinationPort'];
    host = json['host'];
    dnsMode = json['dnsMode'];
    processPath = json['processPath'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['network'] = network;
    _data['type'] = type;
    _data['sourceIP'] = sourceIP;
    _data['destinationIP'] = destinationIP;
    _data['sourcePort'] = sourcePort;
    _data['destinationPort'] = destinationPort;
    _data['host'] = host;
    _data['dnsMode'] = dnsMode;
    _data['processPath'] = processPath;
    return _data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
