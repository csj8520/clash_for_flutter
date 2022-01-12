import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clashf_pro/fetch/index.dart';
import 'package:clashf_pro/types/index.dart';
import 'package:clashf_pro/utils/index.dart';
import 'package:clashf_pro/components/index.dart';

class PageRulesRules extends StatefulWidget {
  const PageRulesRules({Key? key, required this.pageVisibleEvent}) : super(key: key);
  final PageVisibleEvent pageVisibleEvent;

  @override
  _PageRulesRulesState createState() => _PageRulesRulesState();
}

class _PageRulesRulesState extends State<PageRulesRules> {
  final ScrollController _scrollController = ScrollController();
  List<RuleRule> _rules = [];

  @override
  void initState() {
    super.initState();
    widget.pageVisibleEvent.onVisible('rules', (show) {
      if (show) _update();
    });
  }

  Future<void> _update() async {
    _rules = await fetchClashRules();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CardHead(title: '规则'),
        CardView(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _rules.length,
            itemBuilder: (_, idx) => _RulesRulesItem(rule: _rules[idx]),
          ).height(480),
        ),
      ],
    );
  }
}

class _RulesRulesItem extends StatelessWidget {
  const _RulesRulesItem({Key? key, required this.rule}) : super(key: key);
  final RuleRule rule;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(rule.type).fontSize(14).textColor(const Color(0xff54759a)).alignment(Alignment.center).width(160),
        Text(rule.payload).fontSize(14).textColor(const Color(0xff54759a)).alignment(Alignment.center).expanded(),
        Text(rule.proxy).fontSize(14).textColor(const Color(0xff54759a)).alignment(Alignment.center).width(160),
      ],
    ).padding(all: 15).border(bottom: 1, color: const Color(0xffe5e7eb));
  }
}
