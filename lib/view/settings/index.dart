import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clashf_pro/utils/index.dart';
import 'package:clashf_pro/components/index.dart';

class PageSettings extends StatefulWidget {
  const PageSettings({Key? key, required this.pageVisibleEvent}) : super(key: key);
  final PageVisibleEvent pageVisibleEvent;

  @override
  _PageSettingsState createState() => _PageSettingsState();
}

class _PageSettingsState extends State<PageSettings> {
  final ScrollController _scrollController = ScrollController();
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          const CardHead(title: '设置'),
          CardView(
            child: Column(
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        const Text('开机启动').fontSize(14).textColor(const Color(0xff54859a)).expanded(),
                        Switch(value: false, onChanged: (v) {})
                      ],
                    ).padding(left: 32, right: 32).expanded(),
                    Row(
                      children: [
                        const Text('语言').fontSize(14).textColor(const Color(0xff54859a)).expanded(),
                        ButtonSelect(
                          value: _selected,
                          labels: const ['中文', 'English'],
                          onSelect: (idx) {
                            setState(() {
                              _selected = idx;
                            });
                          },
                        ),
                      ],
                    ).padding(left: 32, right: 32).expanded(),
                  ],
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        const Text('设置为系统代理').fontSize(14).textColor(const Color(0xff54859a)).expanded(),
                        Switch(value: false, onChanged: (v) {})
                      ],
                    ).padding(left: 32, right: 32).expanded(),
                    Row(
                      children: [
                        const Text('允许来自局域网的连接').fontSize(14).textColor(const Color(0xff54859a)).expanded(),
                        Switch(value: false, onChanged: (v) {})
                      ],
                    ).padding(left: 32, right: 32).expanded(),
                  ],
                ),
              ],
            ).padding(top: 12, bottom: 12),
          ),
          CardView(
            child: Column(
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        const Text('代理模式').fontSize(14).textColor(const Color(0xff54859a)).expanded(),
                        const ButtonSelect(labels: ['全局', '规则', '直连', '脚本']),
                      ],
                    ).padding(left: 32, right: 32).expanded(),
                    Row(
                      children: [
                        const Text('Socks5 代理端口').fontSize(14).textColor(const Color(0xff54859a)).expanded(),
                        Switch(value: false, onChanged: (v) {})
                      ],
                    ).padding(left: 32, right: 32).expanded(),
                  ],
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        const Text('HTTP 代理端口').fontSize(14).textColor(const Color(0xff54859a)).expanded(),
                        Switch(value: false, onChanged: (v) {})
                      ],
                    ).padding(left: 32, right: 32).expanded(),
                    Row(
                      children: [
                        const Text('混合代理端口').fontSize(14).textColor(const Color(0xff54859a)).expanded(),
                        Switch(value: false, onChanged: (v) {})
                      ],
                    ).padding(left: 32, right: 32).expanded(),
                  ],
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        const Text('外部控制设置').fontSize(14).textColor(const Color(0xff54859a)).expanded(),
                        Switch(value: false, onChanged: (v) {})
                      ],
                    ).padding(left: 32, right: 32).expanded(),
                    Container().expanded()
                  ],
                ),
              ],
            ).padding(top: 12, bottom: 12),
          ),
        ],
      ).padding(top: 5, right: 20, bottom: 20),
    );
  }
}



// TextButton(
//           child: const Text('Open System Proxy'),
//           onPressed: () {
//             SystemProxy.instance.setProxy(SystemProxyConfig(
//               http: SystemProxyState(enable: true, server: '127.0.0.1:7893'),
//               https: SystemProxyState(enable: true, server: '127.0.0.1:7893'),
//               socks: SystemProxyState(enable: true, server: '127.0.0.1:7893'),
//             ));
//           },
//         ),
//         TextButton(
//           child: const Text('Clear System Proxy'),
//           onPressed: () {
//             SystemProxy.instance.setProxy(SystemProxyConfig());
//           },
//         ),
//         TextButton(
//           child: const Text('Get System Proxy'),
//           onPressed: () async {
//             final s = await SystemProxy.instance.getProxyState();
//             log.debug(s);
//           },
//         )
