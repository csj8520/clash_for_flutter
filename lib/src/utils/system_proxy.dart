import 'dart:io';

import 'package:clash_for_flutter/src/utils/index.dart';

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
    // socks 会丢失域名信息 导致规则失效
    // http://127.0.0.1:7893;https=127.0.0.1:7890;socks=127.0.0.1:7891; chrome use http; firefox use https
    // http://127.0.0.1:7893;https=127.0.0.1:7890;                      chrome use http; firefox use https
    // https=127.0.0.1:7890;socks=127.0.0.1:7891;                       chrome, firefox use https
    // http://127.0.0.1:7893;socks=127.0.0.1:7891;                      chrome, firefox use http
    // socks=127.0.0.1:7891;                                            chrome, firefox use socks4
    // http=127.0.0.1:7893;                                             chrome, firefox not use
    String servers = "";
    if (conf.http.enable) servers += "http://${conf.http.server};";
    if (conf.https.enable) servers += "https=${conf.https.server};";
    if (conf.socks.enable) servers += "socks=${conf.socks.server};";
    if (servers.isNotEmpty) {
      await Process.run('reg', ['add', regPath, '/v', 'ProxyEnable', '/t', 'REG_DWORD', '/d', '1', '/f']);
      await Process.run('reg', ['add', regPath, '/v', 'ProxyServer', '/t', 'REG_SZ', '/d', servers, '/f']);
    } else {
      await Process.run('reg', ['add', regPath, '/v', 'ProxyEnable', '/t', 'REG_DWORD', '/d', '0', '/f']);
      await Process.run('reg', ['add', regPath, '/v', 'ProxyServer', '/t', 'REG_SZ', '/d', '', '/f']);
    }
  }

  @override
  Future<SystemProxyConfig> getProxyState() async {
    final enable = (await Process.run('reg', ['query', regPath, '/v', 'ProxyEnable'])).stdout.toString().contains('0x1');
    final out = await Process.run('reg', ['query', regPath, '/v', 'ProxyServer']);
    final outStr = out.stdout.toString().trim();
    final serversStr = RegExp(r'(?<=ProxyServer\s+REG_SZ\s+)(?!\s+).+').firstMatch(outStr)?.group(0);
    final result = SystemProxyConfig();
    if (serversStr != null) {
      final serverReg = RegExp(r"((?:https?)|(?:socks))(?:(?:\:\/\/)|(?:=))(\d+\.\d+\.\d+\.\d+\:\d+)");
      final results = serversStr.split(";").where((it) => it.isNotEmpty).map((it) => serverReg.firstMatch(it)?.groups([1, 2])).whereType<List>();
      for (var it in results) {
        final state = SystemProxyState(enable: enable, server: it[1]);
        switch (it[0]) {
          case 'http':
            result.http = state;
            break;
          case 'https':
            result.https = state;
            break;
          case 'socks':
            result.socks = state;
            break;
        }
      }
    }
    return result;
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
