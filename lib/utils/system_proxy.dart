import 'dart:io';

import 'package:clashf_pro/utils/index.dart';

class SystemProxyState {
  bool enable;
  String? server;

  String? get host {
    return server?.split(':')[0];
  }

  String? get port {
    return server?.split(':')[1];
  }

  SystemProxyState({required this.enable, this.server}) : assert(!enable || (enable && server != null));

  @override
  String toString() {
    return '{"enable": $enable, "server": "$server"}';
  }
}

class SystemProxyConfig {
  late SystemProxyState http;
  late SystemProxyState https;
  late SystemProxyState socks;
  SystemProxyConfig({SystemProxyState? http, SystemProxyState? https, SystemProxyState? socks}) {
    this.http = http ?? SystemProxyState(enable: false);
    this.https = https ?? SystemProxyState(enable: false);
    this.socks = socks ?? SystemProxyState(enable: false);
  }

  @override
  String toString() {
    return '{"http": $http, "https": $https, "socks": $socks}';
  }
}

class SystemProxyPlatform {
  Future<void> setProxy(SystemProxyConfig conf) async {
    throw UnimplementedError();
  }

  Future<SystemProxyConfig> getProxyState() async {
    throw UnimplementedError();
  }
}

class MacSystemProxy extends SystemProxyPlatform {
  static MacSystemProxy instance = MacSystemProxy();

  Future<List<String>> getNetworks() async {
    final result = await Process.run('networksetup', ['-listallnetworkservices']);
    return result.stdout.toString().trim().split('\n').sublist(1);
  }

  @override
  Future<void> setProxy(SystemProxyConfig conf) async {
    final networks = await getNetworks();
    List<String> commands = [];
    for (var network in networks) {
      if (conf.http.enable) {
        commands.add('networksetup -setwebproxy "$network" "${conf.http.host}" "${conf.http.port}"');
      } else {
        commands.add('networksetup -setwebproxy "$network" "" ""');
        commands.add('networksetup -setwebproxystate "$network" off');
      }
      if (conf.https.enable) {
        commands.add('networksetup -setsecurewebproxy "$network" "${conf.https.host}" "${conf.https.port}"');
      } else {
        commands.add('networksetup -setsecurewebproxy "$network" "" ""');
        commands.add('networksetup -setsecurewebproxystate "$network" off');
      }
      if (conf.socks.enable) {
        commands.add('networksetup -setsocksfirewallproxy "$network" "${conf.socks.host}" "${conf.socks.port}"');
      } else {
        commands.add('networksetup -setsocksfirewallproxy "$network" "" ""');
        commands.add('networksetup -setsocksfirewallproxystate "$network" off');
      }
    }

    log.debug(commands);
    await Process.run('bash', ['-c', commands.join(' && ')]);
  }

  @override
  Future<SystemProxyConfig> getProxyState() async {
    final out = (await Process.run('scutil', ['--proxy'])).stdout.toString().trim();
    final states = ['HTTP', 'HTTPS', 'SOCKS'].map((it) {
      final _enable = RegExp('(?<=${it}Enable\\s*:\\s*)([^\\s]+)').firstMatch(out);
      final _host = RegExp('(?<=${it}Proxy\\s*:\\s*)([^\\s]+)').firstMatch(out);
      final _port = RegExp('(?<=${it}Port\\s*:\\s*)([^\\s]+)').firstMatch(out);
      final enable = _enable?.group(1);
      final host = _host?.group(1);
      final port = _port?.group(1);
      if (enable == null || enable == '0' || host == null || port == null) return SystemProxyState(enable: false);
      return SystemProxyState(enable: true, server: '$host:$port');
    }).toList();
    return SystemProxyConfig(http: states[0], https: states[1], socks: states[2]);
  }
}

class WinSystemProxy extends SystemProxyPlatform {
  static String regPath = 'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings';
  static WinSystemProxy instance = WinSystemProxy();

  @override
  Future<void> setProxy(SystemProxyConfig conf) async {
    if (conf.https.enable || conf.http.enable) {
      String server = conf.https.enable ? conf.https.server! : conf.http.server!;
      await Process.run('reg', ['add', regPath, '/v', 'ProxyEnable', '/t', 'REG_DWORD', '/d', '1', '/f']);
      await Process.run('reg', ['add', regPath, '/v', 'ProxyServer', '/t', 'REG_SZ', '/d', ' http://$server', '/f']);
    } else if (conf.socks.enable) {
      await Process.run('reg', ['add', regPath, '/v', 'ProxyEnable', '/t', 'REG_DWORD', '/d', '1', '/f']);
      await Process.run('reg', ['add', regPath, '/v', 'ProxyServer', '/t', 'REG_SZ', '/d', 'socks=${conf.socks.server}', '/f']);
    } else {
      await Process.run('reg', ['add', regPath, '/v', 'ProxyEnable', '/t', 'REG_DWORD', '/d', '0', '/f']);
      await Process.run('reg', ['add', regPath, '/v', 'ProxyServer', '/t', 'REG_SZ', '/d', '', '/f']);
    }
  }

  @override
  Future<SystemProxyConfig> getProxyState() async {
    final enable = (await Process.run('reg', ['query', regPath, '/v', 'ProxyEnable'])).stdout.toString().contains('0x1');
    final out = await Process.run('reg', ['query', regPath, '/v', 'ProxyServer']);
    final res = RegExp(r'(?<=ProxyServer\s+REG_SZ\s+)(?!\s)((?:http\:\/\/)|(?:socks=))?(.+)').firstMatch(out.stdout.toString().trim());
    if (res == null) return SystemProxyConfig();
    final group = res.groups([1, 2]);
    String protocol = group[0] ?? 'http://';
    String? host = group[1];
    if (host == null) return SystemProxyConfig();
    if (protocol == 'http://') {
      return SystemProxyConfig(http: SystemProxyState(enable: enable, server: host), https: SystemProxyState(enable: enable, server: host));
    } else if (protocol == 'socks=') {
      return SystemProxyConfig(socks: SystemProxyState(enable: enable, server: host));
    }
    return SystemProxyConfig();
  }
}

class SystemProxy extends SystemProxyPlatform {
  static SystemProxy instance = SystemProxy();

  @override
  Future<void> setProxy(SystemProxyConfig conf) async {
    try {
      log.time('setProxy');
      if (Platform.isWindows) {
        return WinSystemProxy.instance.setProxy(conf);
      } else if (Platform.isMacOS) {
        return MacSystemProxy.instance.setProxy(conf);
      } else {
        throw UnimplementedError();
      }
    } catch (e) {
      print(e);
      rethrow;
    } finally {
      log.timeEnd('setProxy');
    }
  }

  @override
  Future<SystemProxyConfig> getProxyState() async {
    try {
      log.time('getProxyState');
      if (Platform.isWindows) {
        return WinSystemProxy.instance.getProxyState();
      } else if (Platform.isMacOS) {
        return MacSystemProxy.instance.getProxyState();
      } else {
        throw UnimplementedError();
      }
    } finally {
      log.timeEnd('getProxyState');
    }
  }
}
