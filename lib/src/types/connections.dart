class ConnectionsConnectionMeta {
  String network;
  String type;
  String sourceIP;
  String destinationIP;
  String sourcePort;
  String destinationPort;
  String host;
  String dnsMode;
  ConnectionsConnectionMeta({
    required this.network,
    required this.type,
    required this.sourceIP,
    required this.destinationIP,
    required this.sourcePort,
    required this.destinationPort,
    required this.host,
    required this.dnsMode,
  });

  static ConnectionsConnectionMeta buildFromJson(Map<String, dynamic> json) {
    return ConnectionsConnectionMeta(
      network: json['network'],
      type: json['type'],
      sourceIP: json['sourceIP'],
      destinationIP: json['destinationIP'],
      sourcePort: json['sourcePort'],
      destinationPort: json['destinationPort'],
      host: json['host'],
      dnsMode: json['dnsMode'],
    );
  }
}

class ConnectionsConnection {
  String id;
  int upload;
  int download;
  String start;
  List<String> chains;
  String rule;
  String rulePayload;
  ConnectionsConnectionMeta metadata;
  ConnectionsConnection({
    required this.id,
    required this.upload,
    required this.download,
    required this.start,
    required this.chains,
    required this.rule,
    required this.rulePayload,
    required this.metadata,
  });

  static ConnectionsConnection buildFromJson(Map<String, dynamic> json) {
    return ConnectionsConnection(
      id: json['id'],
      upload: json['upload'],
      download: json['download'],
      start: json['start'],
      chains: (json['chains'] as List<dynamic>).whereType<String>().toList(),
      rule: json['rule'],
      rulePayload: json['rulePayload'],
      metadata: ConnectionsConnectionMeta.buildFromJson(json['metadata']),
    );
  }
}

class Connections {
  int downloadTotal;
  int uploadTotal;
  List<ConnectionsConnection> connections;
  Connections({required this.downloadTotal, required this.uploadTotal, required this.connections});

  static Connections get def {
    return Connections(downloadTotal: 0, uploadTotal: 0, connections: []);
  }

  static Connections buildFromJson(Map<String, dynamic> json) {
    return Connections(
      downloadTotal: json['downloadTotal'],
      uploadTotal: json['uploadTotal'],
      connections: (json['connections'] as List<dynamic>).map((e) => ConnectionsConnection.buildFromJson(e)).toList(),
    );
  }
}
