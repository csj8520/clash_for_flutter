import 'package:day/day.dart';
import 'package:get/get.dart';
import 'package:protocol_handler/protocol_handler.dart';

import 'package:clash_for_flutter/types/config.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';

class ProtocolController extends GetxController with ProtocolListener {
  void initProtocol() {
    protocolHandler.addListener(this);
  }

  @override
  void onProtocolUrlReceived(String url) async {
    // ref https://github.com/biyidev/biyi/blob/37aa84ec063fcbac717ace26acd361764ab9a2c5/lib/pages/desktop_popup/desktop_popup.dart#L829
    // clash://install-config?url=xxxx
    final uri = Uri.parse(url);
    if (uri.scheme != 'clash') return;
    if (uri.authority == 'install-config') {
      final paths = Uri.parse(uri.queryParameters['url']!).pathSegments;
      String name = paths.isNotEmpty ? paths.last : Day().format('YYYYMMDD_HHmmss');
      name = name.replaceFirst(RegExp(r'(\.\w*)?$'), '.yaml');
      controllers.pageProfile.showAddSubPopup(controllers.pageMain.context, ConfigSub(name: name, url: uri.queryParameters['url']));
    } else {
      return;
    }
    await controllers.window.showWindow();
  }

  @override
  void dispose() {
    protocolHandler.removeListener(this);
    super.dispose();
  }
}
