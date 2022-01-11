import 'package:bot_toast/bot_toast.dart';
import 'package:clashf_pro/components/index.dart';
import 'package:clashf_pro/components/loading.dart';
import 'package:clashf_pro/utils/utils.dart';
import 'package:day/day.dart';
import 'package:day/i18n/zh_cn.dart';
import 'package:day/plugins/relative_time.dart';
import 'package:flutter/material.dart';

class PageRulesProviders extends StatefulWidget {
  const PageRulesProviders({Key? key, required this.pageVisibleEvent}) : super(key: key);
  final PageVisibleEvent pageVisibleEvent;

  @override
  _PageRulesProvidersState createState() => _PageRulesProvidersState();
}

class _PageRulesProvidersState extends State<PageRulesProviders> {
  List<Rule> _rules = [];

  @override
  void initState() {
    super.initState();
    widget.pageVisibleEvent.onVisible('rules', (show) {
      log.debug('rules', show);
      if (show) _update();
    });
  }

  Future<void> _update() async {
    _rules = await fetchClashProviderRules();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CardHead(title: '规则集'),
        CardView(
          child: Column(
            children: _rules.map((e) => RulesProvidersItem(rule: e, onUpdate: _update)).toList(),
          ),
        ),
      ],
    );
  }
}

class RulesProvidersItem extends StatefulWidget {
  const RulesProvidersItem({Key? key, required this.rule, required this.onUpdate}) : super(key: key);
  final Rule rule;
  final FutureFunc onUpdate;

  @override
  _RulesProvidersItemState createState() => _RulesProvidersItemState();
}

class _RulesProvidersItemState extends State<RulesProvidersItem> {
  final LoadingController _loadingController = LoadingController();

  _update() async {
    _loadingController.show(context.size);
    try {
      await fetchClashProviderRulesUpdate(widget.rule.name);
      await widget.onUpdate();
    } catch (e) {
      BotToast.showText(text: 'Update Rule Error');
    }
    _loadingController.hide();
  }

  @override
  Widget build(BuildContext context) {
    final rule = widget.rule;
    final updatedAt = Day().useLocale(locale).from(Day.fromString(rule.updatedAt));

    return Loading(
      controller: _loadingController,
      child: Row(
        children: [
          Text(rule.name, overflow: TextOverflow.ellipsis).textColor(const Color(0xff546b87)).fontSize(16).width(115),
          Tag(rule.vehicleType, width: 50).padding(left: 5),
          Tag(rule.behavior, bgcolor: Theme.of(context).primaryColor, color: Colors.white, width: 55).padding(left: 12),
          Text('规则条数：${rule.ruleCount}').textColor(const Color(0xff546b87)).fontSize(14).padding(left: 15).expanded(),
          Text('最后更新于：$updatedAt').textColor(const Color(0xff546b87)).fontSize(14).padding(right: 5),
          IconButton(icon: Icon(Icons.refresh, color: Theme.of(context).primaryColor, size: 20), onPressed: _update),
        ],
      ).padding(all: 20).border(bottom: 1, color: const Color(0xffe5e7eb)),
    );
  }
}
