import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:day/day.dart';
import 'package:day/plugins/relative_time.dart';

import 'package:clash_for_flutter/types/rule.dart';
import 'package:clash_for_flutter/widgets/tag.dart';
import 'package:clash_for_flutter/widgets/loading.dart';

class RuleProviderItem extends StatefulWidget {
  const RuleProviderItem({Key? key, required this.rule, this.onUpdate}) : super(key: key);
  final RuleProvidersProvidersItem rule;
  final Future<void> Function(String name)? onUpdate;

  @override
  State<RuleProviderItem> createState() => _RuleProviderItemState();
}

class _RuleProviderItemState extends State<RuleProviderItem> {
  final LoadingController _loadingController = LoadingController();

  void _update() async {
    _loadingController.show();
    await widget.onUpdate!(widget.rule.name);
    _loadingController.hide();
  }

  @override
  Widget build(BuildContext context) {
    return Loading(
      controller: _loadingController,
      child: Row(
        children: [
          Text(widget.rule.name, overflow: TextOverflow.ellipsis).textColor(const Color(0xff546b87)).fontSize(16).width(115),
          Tag(widget.rule.vehicleType, width: 50).padding(left: 5),
          Tag(widget.rule.behavior, bgcolor: Theme.of(context).primaryColor, color: Colors.white, width: 55).padding(left: 12),
          Text('${'rule_rule_count'.tr}：${widget.rule.ruleCount}').textColor(const Color(0xff546b87)).fontSize(14).padding(left: 15).expanded(),
          Text('${'rule_provider_update_time'.tr}：${Day().from(Day.fromString(widget.rule.updatedAt))}')
              .textColor(const Color(0xff546b87))
              .fontSize(14)
              .padding(right: 5),
          IconButton(icon: Icon(Icons.refresh, color: Theme.of(context).primaryColor, size: 20), onPressed: widget.onUpdate == null ? null : _update),
        ],
      ).padding(all: 15).border(bottom: 1, color: const Color(0xffe5e7eb)),
    );
  }
}

class RuleItem extends StatelessWidget {
  const RuleItem({Key? key, required this.rule}) : super(key: key);
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
