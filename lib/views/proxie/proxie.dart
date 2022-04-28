import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_for_flutter/types/proxie.dart';
import 'package:clash_for_flutter/store/config.dart';
import 'package:clash_for_flutter/store/clash_core.dart';
import 'package:clash_for_flutter/widgets/card_head.dart';
import 'package:clash_for_flutter/widgets/card_view.dart';
import 'package:clash_for_flutter/views/proxie/widgets.dart';

class PageProxie extends StatefulWidget {
  const PageProxie({Key? key}) : super(key: key);

  @override
  State<PageProxie> createState() => _PageProxieState();
}

class _PageProxieState extends State<PageProxie> {
  final StoreClashCore storeClashCore = Get.find();
  final StoreConfig storeConfig = Get.find();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    await storeClashCore.fetchProxie();
    await storeClashCore.fetchProxieProvider();
  }

  Future<void> _handleSetProxieGroup(ProxieProxiesItem proxie, String value) async {
    if (proxie.now == value) return;
    await storeClashCore.fetchSetProxieGroup(proxie.name, value);
    await storeClashCore.fetchProxie();
    if (storeConfig.config.value.breakConnections) {
      final conn = await storeClashCore.fetchConnection();
      for (final it in conn.connections) {
        if (it.chains.contains(proxie.name)) storeClashCore.fetchCloseConnection(it.id);
      }
    }
  }

  Future<void> _handleUpdateProvider(ProxieProviderItem provider) async {
    try {
      await storeClashCore.fetchProxieProviderUpdate(provider.name);
      await storeClashCore.fetchProxieProvider();
      await storeClashCore.fetchProxie();
    } catch (e) {
      BotToast.showText(text: 'Updata Error');
    }
  }

  Future<void> _handleHealthCheckProvider(ProxieProviderItem provider) async {
    try {
      await storeClashCore.fetchProxieProviderHealthCheck(provider.name);
      await storeClashCore.fetchProxieProvider();
      await storeClashCore.fetchProxie();
    } catch (e) {
      BotToast.showText(text: 'Health Check Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Obx(() => Column(children: [
            if (storeClashCore.proxieGroups.isNotEmpty)
              Column(
                children: [
                  CardHead(
                    title: '策略组',
                    suffix: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Checkbox(value: storeConfig.config.value.breakConnections, onChanged: (v) => storeConfig.setBreakConnections(v!)),
                        const Text('切换时打断包含策略组的连接').textColor(Theme.of(context).primaryColor)
                      ],
                    ).expanded(),
                  ),
                  CardView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: storeClashCore.proxieGroups.map((it) => PageProxieGroupItem(proxie: it, onChange: _handleSetProxieGroup)).toList(),
                    ),
                  ),
                ],
              ),
            if (storeClashCore.proxieProviders.isNotEmpty)
              Column(
                children: [
                  const CardHead(title: '代理集'),
                  ...storeClashCore.proxieProviders
                      .map((it) => PageProxieProvider(provider: it, onUpdate: _handleUpdateProvider, onHealthCheck: _handleHealthCheckProvider))
                      .toList(),
                ],
              ),
            if (storeClashCore.proxieProxies.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardHead(
                    title: '代理',
                    suffix: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.speed, size: 20, color: Theme.of(context).primaryColor),
                        onPressed: storeClashCore.fetchProxieDelay,
                      ),
                    ).expanded(),
                  ),
                  Wrap(spacing: 10, runSpacing: 10, children: storeClashCore.proxieProxies.map((it) => PageProxieItem(proxie: it)).toList()),
                ],
              )
          ]).padding(top: 5, right: 20, bottom: 20)),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
