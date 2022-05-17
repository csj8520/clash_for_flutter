import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Obx(() => Column(children: [
            if (controllers.core.proxieGroups.isNotEmpty)
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
                      children: controllers.core.proxieGroups
                          .map((it) => PageProxieGroupItem(proxie: it, onChange: controllers.pageProxie.handleSetProxieGroup))
                          .toList(),
                    ),
                  ),
                ],
              ),
            if (controllers.core.proxieProviders.isNotEmpty)
              Column(
                children: [
                  CardHead(title: 'proxie_provider_title'.tr),
                  ...controllers.core.proxieProviders
                      .map((it) => PageProxieProvider(
                          provider: it,
                          onUpdate: controllers.pageProxie.handleUpdateProvider,
                          onHealthCheck: controllers.pageProxie.handleHealthCheckProvider))
                      .toList(),
                ],
              ),
            if (controllers.core.proxieProxies.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardHead(
                    title: 'proxie_title'.tr,
                    suffix: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.speed, size: 20, color: Theme.of(context).primaryColor),
                        onPressed: controllers.core.updateProxieDelay,
                      ),
                    ).expanded(),
                  ),
                  Wrap(spacing: 10, runSpacing: 10, children: controllers.core.proxieProxies.map((it) => PageProxieItem(proxie: it)).toList()),
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
