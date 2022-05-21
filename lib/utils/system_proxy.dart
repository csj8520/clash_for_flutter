import 'dart:io';

import 'package:clash_for_flutter/utils/logger.dart';

class SystemProxyServer {
  String server;

  String get host {
    return server.split(':')[0];
  }

  String get port {
    return server.split(':')[1];
  }

  SystemProxyServer(this.server);
}

class SystemProxyConfig {
  String? http;
  String? https;
  String? socks;
  SystemProxyConfig({this.http, this.https, this.socks});
}

class SystemProxyPlatform {
  Future<void> set(SystemProxyConfig conf) async {
    throw UnimplementedError();
  }

  Future<SystemProxyConfig> get() async {
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
  Future<void> set(SystemProxyConfig conf) async {
    final networks = await getNetworks();
    List<String> commands = [];
    for (var network in networks) {
      if (conf.http != null) {
        final http = SystemProxyServer(conf.http!);
        commands.add('networksetup -setwebproxy "$network" "${http.host}" "${http.port}"');
      } else {
        commands.add('networksetup -setwebproxy "$network" "" ""');
        commands.add('networksetup -setwebproxystate "$network" off');
      }
      if (conf.https != null) {
        final https = SystemProxyServer(conf.https!);
        commands.add('networksetup -setsecurewebproxy "$network" "${https.host}" "${https.port}"');
      } else {
        commands.add('networksetup -setsecurewebproxy "$network" "" ""');
        commands.add('networksetup -setsecurewebproxystate "$network" off');
      }
      if (conf.socks != null) {
        final socks = SystemProxyServer(conf.socks!);
        commands.add('networksetup -setsocksfirewallproxy "$network" "${socks.host}" "${socks.port}"');
      } else {
        commands.add('networksetup -setsocksfirewallproxy "$network" "" ""');
        commands.add('networksetup -setsocksfirewallproxystate "$network" off');
      }
    }

    log.debug('MacSystemProxy.set:', commands);
    await Process.run('bash', ['-c', commands.join(' && ')]);
  }

  @override
  Future<SystemProxyConfig> get() async {
    final out = (await Process.run('scutil', ['--proxy'])).stdout.toString().trim();
    final states = ['HTTP', 'HTTPS', 'SOCKS'].map((it) {
      final enableReg = RegExp('(?<=${it}Enable\\s*:\\s*)([^\\s]+)').firstMatch(out);
      final hostReg = RegExp('(?<=${it}Proxy\\s*:\\s*)([^\\s]+)').firstMatch(out);
      final portReg = RegExp('(?<=${it}Port\\s*:\\s*)([^\\s]+)').firstMatch(out);
      final enable = enableReg?.group(1);
      final host = hostReg?.group(1);
      final port = portReg?.group(1);
      if (enable == null || enable == '0' || host == null || port == null) return null;
      return '$host:$port';
    }).toList();
    return SystemProxyConfig(http: states[0], https: states[1], socks: states[2]);
  }
}

class WinSystemProxy extends SystemProxyPlatform {
  static String regPath = 'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings';
  static WinSystemProxy instance = WinSystemProxy();

  @override
  Future<void> set(SystemProxyConfig conf) async {
    // socks 会丢失域名信息 导致规则失效
    // http=127.0.0.1:7893;https=127.0.0.1:7890;socks=127.0.0.1:7891;   chrome, firefox use https
    // http://127.0.0.1:7893;https=127.0.0.1:7890;socks=127.0.0.1:7891; chrome use http; firefox use https
    // http://127.0.0.1:7893;https=127.0.0.1:7890;                      chrome use http; firefox use https
    // https=127.0.0.1:7890;socks=127.0.0.1:7891;                       chrome, firefox use https
    // http://127.0.0.1:7893;socks=127.0.0.1:7891;                      chrome, firefox use http
    // http=127.0.0.1:7893;socks=127.0.0.1:7891;                        chrome use socks, firefox not use
    // socks=127.0.0.1:7891;                                            chrome, firefox use socks4
    // http=127.0.0.1:7893;                                             chrome, firefox not use
    // http=xxx 不建议使用
    String servers = "";
    if (conf.http != null) servers += "http://${conf.http};";
    if (conf.https != null) servers += "https=${conf.https};";
    if (conf.socks != null) servers += "socks=${conf.socks};";
    if (servers.isNotEmpty) {
      await Process.run('reg', ['add', regPath, '/v', 'ProxyEnable', '/t', 'REG_DWORD', '/d', '1', '/f']);
      await Process.run('reg', ['add', regPath, '/v', 'ProxyServer', '/t', 'REG_SZ', '/d', servers, '/f']);
    } else {
      await Process.run('reg', ['add', regPath, '/v', 'ProxyEnable', '/t', 'REG_DWORD', '/d', '0', '/f']);
      await Process.run('reg', ['add', regPath, '/v', 'ProxyServer', '/t', 'REG_SZ', '/d', '', '/f']);
    }
  }

  @override
  Future<SystemProxyConfig> get() async {
    final enable = (await Process.run('reg', ['query', regPath, '/v', 'ProxyEnable'])).stdout.toString().contains('0x1');
    final result = SystemProxyConfig();
    if (!enable) return result;
    final out = await Process.run('reg', ['query', regPath, '/v', 'ProxyServer']);
    final outStr = out.stdout.toString().trim();
    final serversStr = RegExp(r'(?<=ProxyServer\s+REG_SZ\s+)(?!\s+).+').firstMatch(outStr)?.group(0);
    if (serversStr != null) {
      final serverReg = RegExp(r"((?:https?)|(?:socks))(?:(?:\:\/\/)|(?:=))(\d+\.\d+\.\d+\.\d+\:\d+)");
      final results = serversStr.split(";").where((it) => it.isNotEmpty).map((it) => serverReg.firstMatch(it)?.groups([1, 2])).whereType<List>();
      for (var it in results) {
        final state = it[1];
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
  Future<void> set(SystemProxyConfig conf) async {
    try {
      log.time('setProxy');
      if (Platform.isWindows) {
        return WinSystemProxy.instance.set(conf);
      } else if (Platform.isMacOS) {
        return MacSystemProxy.instance.set(conf);
      } else {
        throw UnimplementedError();
      }
    } catch (e) {
      rethrow;
    } finally {
      log.timeEnd('setProxy');
    }
  }

  @override
  Future<SystemProxyConfig> get() async {
    try {
      log.time('getProxyState');
      if (Platform.isWindows) {
        return WinSystemProxy.instance.get();
      } else if (Platform.isMacOS) {
        return MacSystemProxy.instance.get();
      } else {
        throw UnimplementedError();
      }
    } finally {
      log.timeEnd('getProxyState');
    }
  }
}
