import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clashf_pro/utils/index.dart';
import 'package:clashf_pro/components/index.dart';
import 'package:clashf_pro/store/index.dart';

class PageSettings extends StatefulWidget {
  const PageSettings({Key? key}) : super(key: key);

  @override
  _PageSettingsState createState() => _PageSettingsState();
}

class _PageSettingsState extends State<PageSettings> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _modes = ['global', 'rule', 'direct', 'script'];

  void _launchWebGui() {
    final address = Config.instance.externalController.split(':');
    launch('https://clash.razord.top/?host=${address[0]}&port=${address[1]}&secret=${Config.instance.secret}');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Observer(
          builder: (_) => Column(
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
                                Switch(value: localConfigStore.startAtLogin, onChanged: localConfigStore.setStartAtLogin),
                              ],
                            ).padding(left: 32, right: 32).height(46).height(40).expanded(),
                            Row(
                              children: [
                                const Text('语言').fontSize(14).textColor(const Color(0xff54859a)).expanded(),
                                const ButtonSelect(value: 0, labels: ['中文', 'English']),
                              ],
                            ).padding(left: 32, right: 32).height(46).expanded(),
                          ],
                        ),
                        Row(
                          children: [
                            Row(
                              children: [
                                const Text('设置为系统代理').fontSize(14).textColor(const Color(0xff54859a)).expanded(),
                                Switch(value: localConfigStore.autoSetProxy, onChanged: localConfigStore.setAutoSetProxy)
                              ],
                            ).padding(left: 32, right: 32).height(46).expanded(),
                            Row(
                              children: [
                                const Text('允许来自局域网的连接').fontSize(14).textColor(const Color(0xff54859a)).expanded(),
                                Switch(value: clashConfigStore.allowLan, onChanged: clashConfigStore.setAllowLan)
                              ],
                            ).padding(left: 32, right: 32).height(46).expanded(),
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
                                ButtonSelect(
                                    labels: const ['全局', '规则', '直连', '脚本'],
                                    value: _modes.indexOf(clashConfigStore.mode),
                                    onSelect: (idx) => clashConfigStore.setMode(_modes[idx])),
                              ],
                            ).padding(left: 32, right: 32).height(46).expanded(),
                            Row(
                              children: [
                                const Text('Socks5 代理端口').fontSize(14).textColor(const Color(0xff54859a)).expanded(),
                                Text(clashConfigStore.socksPort.toString())
                                    .textColor(Colors.grey.shade800)
                                    .alignment(Alignment.center)
                                    .padding(all: 5)
                                    .decorated(border: Border.all(width: 1, color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4))
                                    .constrained(width: 100, height: 30),
                              ],
                            ).padding(left: 32, right: 32).height(46).expanded(),
                          ],
                        ),
                        Row(
                          children: [
                            Row(
                              children: [
                                const Text('HTTP 代理端口').fontSize(14).textColor(const Color(0xff54859a)).expanded(),
                                Text(clashConfigStore.port.toString())
                                    .textColor(Colors.grey.shade800)
                                    .alignment(Alignment.center)
                                    .padding(all: 5)
                                    .decorated(border: Border.all(width: 1, color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4))
                                    .constrained(width: 100, height: 30),
                              ],
                            ).padding(left: 32, right: 32).height(46).expanded(),
                            Row(
                              children: [
                                const Text('混合代理端口').fontSize(14).textColor(const Color(0xff54859a)).expanded(),
                                Text(clashConfigStore.mixedPort.toString())
                                    .textColor(Colors.grey.shade800)
                                    .alignment(Alignment.center)
                                    .padding(all: 5)
                                    .decorated(border: Border.all(width: 1, color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4))
                                    .constrained(width: 100, height: 30),
                              ],
                            ).padding(left: 32, right: 32).height(46).expanded(),
                          ],
                        ),
                        Row(
                          children: [
                            Row(
                              children: [
                                const Text('外部控制端口').fontSize(14).textColor(const Color(0xff54859a)).expanded(),
                                TextButton(child: Text(Config.instance.externalController), onPressed: _launchWebGui)
                              ],
                            ).padding(left: 32, right: 32).height(46).expanded(),
                            Container().expanded()
                          ],
                        ),
                      ],
                    ).padding(top: 12, bottom: 12),
                  ),
                ],
              ).padding(top: 5, right: 20, bottom: 20)),
    );
  }
}
