import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_for_flutter/utils/utils.dart';
import 'package:clash_for_flutter/types/proxie.dart';
import 'package:clash_for_flutter/widgets/card_head.dart';
import 'package:clash_for_flutter/widgets/card_view.dart';
import 'package:clash_for_flutter/views/proxie/widgets.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';

class PageProxie extends StatefulWidget {
  const PageProxie({Key? key}) : super(key: key);

  @override
  State<PageProxie> createState() => _PageProxieState();
}

class _PageProxieState extends State<PageProxie> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    controllers.pageProxie.updateDate();
    super.initState();
  }

  static const groups = [
    ProxieProxieType.selector,
    ProxieProxieType.urltest,
    ProxieProxieType.fallback,
  ];

  int getDelay(ProxieProxiesItem? proxie) {
    final delay = proxie?.delay ?? 0;
    if (delay > 0) return delay;
    if (proxie != null && groups.contains(proxie.type)) {
      return getDelay(controllers.pageProxie.allProxies[proxie.now]);
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Obx(() => Column(children: [
            if (controllers.pageProxie.proxieGroups.isNotEmpty)
              Column(
                children: [
                  CardHead(
                    title: 'proxie_group_title'.tr,
                    suffix: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Checkbox(
                            value: controllers.config.config.value.breakConnections, onChanged: (v) => controllers.config.setBreakConnections(v!)),
                        Text('proxie_break_connections'.tr).textColor(Theme.of(context).primaryColor)
                      ],
                    ).expanded(),
                  ),
                  CardView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: controllers.pageProxie.proxieGroups
                          .map((it) => PageProxieGroup(
                              title: it.name,
                              type: it.type,
                              now: it.now,
                              onChange: controllers.pageProxie.handleSetProxieGroup.orNull(it.type == ProxieProxieType.selector)?.bindFirst(it),
                              tabs: it.all
                                  ?.map((it) => PageProxieGroupTabItem(
                                        name: it,
                                        type: controllers.pageProxie.allProxies[it]?.type,
                                        delay: getDelay(controllers.pageProxie.allProxies[it]),
                                      ))
                                  .toList()))
                          .toList(),
                    ),
                  ),
                ],
              ),
            if (controllers.pageProxie.proxieProviders.isNotEmpty)
              Column(
                children: [
                  CardHead(title: 'proxie_provider_title'.tr),
                  ...controllers.pageProxie.proxieProviders
                      .map((it) => PageProxieProvider(
                          provider: it,
                          onUpdate: controllers.pageProxie.handleUpdateProvider,
                          onHealthCheck: controllers.pageProxie.handleHealthCheckProvider))
                      .toList(),
                ],
              ),
            if (controllers.pageProxie.proxieProxies.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardHead(
                    title: 'proxie_title'.tr,
                    suffix: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.speed, size: 20, color: Theme.of(context).primaryColor),
                        onPressed: controllers.pageProxie.updateProxieDelay,
                      ),
                    ).expanded(),
                  ),
                  Wrap(spacing: 10, runSpacing: 10, children: controllers.pageProxie.proxieProxies.map((it) => PageProxieItem(proxie: it)).toList()),
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
