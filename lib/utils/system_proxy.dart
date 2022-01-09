import 'dart:io';

import 'package:clashf_pro/utils/utils.dart';
import 'package:process_run/shell.dart';

final Shell shell = Shell();

class SystemProxyState {
  bool enable;
  String? server;

  String? get host {
    return server?.split(':')[0];
  }

  String? get port {
    return server?.split(':')[1];
  }

  SystemProxyState({this.enable = false, this.server});
}

class SystemProxyConfig {
  SystemProxyState? http;
  SystemProxyState? https;
  SystemProxyState? socks;
  SystemProxyConfig({this.http, this.https, this.socks});
}

class SystemProxyStates {
  SystemProxyState? http;
  SystemProxyState? https;
  SystemProxyState? socks;
  SystemProxyStates({this.http, this.https, this.socks});
}

abstract class _SystemProxy {
  static Future<void> setProxy(SystemProxyConfig conf) async {
    throw UnimplementedError();
  }

  static Future<SystemProxyState> getProxyState() async {
    throw UnimplementedError();
  }
}

class MacSystemProxy implements _SystemProxy {
  // return (await execAsync('networksetup -listallnetworkservices')).split('\n').slice(1);
  static Future<List<String>> getNetworks() async {
    log.time('getNetworks');
    final result = await Process.run('networksetup', ['-listallnetworkservices']);
    log.timeEnd('getNetworks');
    return result.stdout.toString().trim().split('\n').sublist(1);
  }

  static Future<void> setProxy(SystemProxyConfig conf) async {
    final networks = await getNetworks();
    log.debug(networks);
    log.time('setProxy');
    String command = '';
    for (var network in networks) {
      if (conf.http != null) {
        if (conf.http!.enable) {
          if (conf.http!.server != null) command += 'networksetup -setwebproxy "$network" "${conf.http!.host}" "${conf.http!.port}"\n';
        } else {
          command += 'networksetup -setwebproxy "$network" "" ""\n';
          command += 'networksetup -setwebproxystate "$network" off\n';
        }
      }
      if (conf.https != null) {
        if (conf.https!.enable) {
          if (conf.http!.server != null) command += 'networksetup -setsecurewebproxy "$network" "${conf.https!.host}" "${conf.https!.port}"\n';
        } else {
          command += 'networksetup -setsecurewebproxy "$network" "" ""\n';
          command += 'networksetup -setsecurewebproxystate "$network" off\n';
        }
      }
      if (conf.socks != null) {
        if (conf.socks!.enable) {
          if (conf.http!.server != null) command += 'networksetup -setsocksfirewallproxy "$network" "${conf.socks!.host}" "${conf.socks!.port}"\n';
        } else {
          command += 'networksetup -setsocksfirewallproxy "$network" "" ""\n';
          command += 'networksetup -setsocksfirewallproxystate "$network" off\n';
        }
      }
    }

    log.debug(command);
    await shell.run(command);
    // print((await Process.run('ls', ['-la'])).exitCode);
    // print((await Process.run('ls', ['-la'])).exitCode);
    // print((await Process.run('ls', ['-la'])).exitCode);
    // print((await Process.run('ls', ['-la'])).exitCode);
    // print((await Process.run('ls', ['-la'])).exitCode);
    // print((await Process.run('ls', ['-la'])).exitCode);
    // print((await Process.run('ls', ['-la'])).exitCode);
    // print((await Process.run('ls', ['-la'])).exitCode);
    // print((await Process.run('ls', ['-la'])).exitCode);
    // print((await Process.run('ls', ['-la'])).exitCode);
    // print((await Process.run('ls', ['-la'])).exitCode);
    // print((await Process.run('ls', ['-la'])).exitCode);
    // print((await Process.run('ls', ['-la'])).exitCode);
    // print((await Process.run('ls', ['-la'])).exitCode);
    // print((await Process.run('ls', ['-la'])).exitCode);
    // print((await Process.run('ls', ['-la'])).exitCode);
    // print((await Process.run('ls', ['-la'])).exitCode);
    // print((await Process.run('ls', ['-la'])).exitCode);
    log.timeEnd('setProxy');
  }
  // static Future<ProxyState> getProxyState() async {}
}

main() {
  // MacSystemProxy.setProxy(conf);
}



  // for (var network in networks) {
  //     if (conf.http != null) {
  //       if (conf.http!.enable) {
  //         if (conf.http != null) await Process.run('networksetup', ['-setwebproxy', network, conf.http!.host!, conf.http!.port!]);
  //       } else {
  //         await Process.run('networksetup', ['-setwebproxy', network, '', '']);
  //         await Process.run('networksetup', ['-setwebproxystate', network, 'off']);
  //       }
  //     }
  //     if (conf.https != null) {
  //       if (conf.https!.enable) {
  //         if (conf.https != null) await Process.run('networksetup', ['-setsecurewebproxy', network, conf.https!.host!, conf.https!.port!]);
  //       } else {
  //         await Process.run('networksetup', ['-setsecurewebproxy', network, '', '']);
  //         await Process.run('networksetup', ['-setsecurewebproxystate', network, 'off']);
  //       }
  //     }
  //     if (conf.socks != null) {
  //       if (conf.socks!.enable) {
  //         if (conf.socks != null) await Process.run('networksetup', ['-setsocksfirewallproxy', network, conf.socks!.host!, conf.socks!.port!]);
  //       } else {
  //         await Process.run('networksetup', ['-setsocksfirewallproxy', network, '', '']);
  //         await Process.run('networksetup', ['-setsocksfirewallproxystate', network, 'off']);
  //       }
  //     }
  //   }