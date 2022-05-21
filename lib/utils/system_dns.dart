import 'dart:io';

import 'package:clash_for_flutter/utils/logger.dart';

class SystemDnsPlatform {
  Future<void> set(List<String> dns) async {
    throw UnimplementedError();
  }

  Future<List<String>> get() async {
    throw UnimplementedError();
  }
}

class MacSystemDns extends SystemDnsPlatform {
  static MacSystemDns instance = MacSystemDns();

  Future<List<String>> getNetworks() async {
    final result = await Process.run('networksetup', ['-listallnetworkservices']);
    return result.stdout.toString().trim().split('\n').sublist(1);
  }

  @override
  Future<void> set(List<String> dns) async {
    final networks = await getNetworks();
    final List<String> commands = [];
    for (var network in networks) {
      if (dns.isEmpty) {
        commands.add('networksetup -setdnsservers "$network" "empty"');
      } else {
        commands.add('networksetup -setdnsservers "$network" "${dns.join('" "')}"');
      }
    }
    log.debug('MacSystemDns.set:', commands);
    await Process.run('bash', ['-c', commands.join(' && ')]);
  }

  @override
  Future<List<String>> get() async {
    final out = (await Process.run('scutil', ['--dns'])).stdout.toString().trim().split('\n\n').last;
    final res = RegExp(r'nameserver\[\d\]\s*:\s*(.+)').allMatches(out);
    return res.map((e) => e.group(1)).whereType<String>().toList();
  }
}
