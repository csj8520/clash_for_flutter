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

class ClashCoreConfig {
  ClashCoreConfig({
    required this.port,
    required this.socksPort,
    required this.redirPort,
    required this.tproxyPort,
    required this.mixedPort,
    required this.authentication,
    required this.allowLan,
    required this.bindAddress,
    required this.mode,
    required this.logLevel,
    required this.ipv6,
  });
  late int port;
  late int socksPort;
  late int redirPort;
  late int tproxyPort;
  late int mixedPort;
  late List<String> authentication;
  late bool allowLan;
  late String bindAddress;
  late String mode;
  late String logLevel;
  late bool ipv6;

  ClashCoreConfig.fromJson(Map<String, dynamic> json) {
    port = json['port'];
    socksPort = json['socks-port'];
    redirPort = json['redir-port'];
    tproxyPort = json['tproxy-port'];
    mixedPort = json['mixed-port'];
    authentication = List.castFrom<dynamic, String>(json['authentication']);
    allowLan = json['allow-lan'];
    bindAddress = json['bind-address'];
    mode = json['mode'];
    logLevel = json['log-level'];
    ipv6 = json['ipv6'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['port'] = port;
    _data['socks-port'] = socksPort;
    _data['redir-port'] = redirPort;
    _data['tproxy-port'] = tproxyPort;
    _data['mixed-port'] = mixedPort;
    _data['authentication'] = authentication;
    _data['allow-lan'] = allowLan;
    _data['bind-address'] = bindAddress;
    _data['mode'] = mode;
    _data['log-level'] = logLevel;
    _data['ipv6'] = ipv6;
    return _data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
