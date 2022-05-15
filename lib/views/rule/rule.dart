import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_for_flutter/widgets/card_head.dart';
import 'package:clash_for_flutter/widgets/card_view.dart';
import 'package:clash_for_flutter/views/rule/widgets.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';

class PageRule extends StatefulWidget {
  const PageRule({Key? key}) : super(key: key);

  @override
  State<PageRule> createState() => _PageRuleState();
}

class _PageRuleState extends State<PageRule> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollController2 = ScrollController();

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    await controllers.core.fetchRuleProvider();
    await controllers.core.fetchRule();
  }

  Future<void> _handleRuleProviderUpdate(String name) async {
    try {
      await controllers.core.fetchRuleProviderUpdate(name);
      await controllers.core.fetchRuleProvider();
    } catch (e) {
      BotToast.showText(text: 'Update Rule: $name Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controllers.core.ruleProvider.value.providers.isNotEmpty) const CardHead(title: '规则集'),
              if (controllers.core.ruleProvider.value.providers.isNotEmpty)
                CardView(
                  child: controllers.core.ruleProvider.value.providers.values
                      .map((it) => RuleProviderItem(rule: it, onUpdate: _handleRuleProviderUpdate))
                      .toList()
                      .toColumn(),
                ),
              const CardHead(title: '规则'),
              CardView(
                child: ListView.builder(
                  controller: _scrollController2,
                  itemCount: controllers.core.rule.value.rules.length,
                  itemBuilder: (_, idx) => RuleItem(rule: controllers.core.rule.value.rules[idx]),
                ).height(480),
              )
            ],
          ).padding(top: 5, right: 20, bottom: 20)),
    );
  }
}
