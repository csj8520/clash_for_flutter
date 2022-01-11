import 'package:clashf_pro/utils/system_proxy.dart';
import 'package:clashf_pro/utils/utils.dart';
import 'package:flutter/material.dart';

class PageSettings extends StatefulWidget {
  const PageSettings({Key? key, required this.pageVisibleEvent}) : super(key: key);
  final PageVisibleEvent pageVisibleEvent;

  @override
  _PageSettingsState createState() => _PageSettingsState();
}

class _PageSettingsState extends State<PageSettings> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          child: const Text('Open System Proxy'),
          onPressed: () {
            SystemProxy.instance.setProxy(SystemProxyConfig(
              http: SystemProxyState(enable: true, server: '127.0.0.1:7893'),
              https: SystemProxyState(enable: true, server: '127.0.0.1:7893'),
              socks: SystemProxyState(enable: true, server: '127.0.0.1:7893'),
            ));
          },
        ),
        TextButton(
          child: const Text('Clear System Proxy'),
          onPressed: () {
            SystemProxy.instance.setProxy(SystemProxyConfig());
          },
        ),
        TextButton(
          child: const Text('Get System Proxy'),
          onPressed: () async {
            final s = await SystemProxy.instance.getProxyState();
            log.debug(s);
          },
        )
      ],
    );
  }
}
