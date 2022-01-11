import 'package:clashf_pro/utils/utils.dart';
import 'package:clashf_pro/view/rules/providers.dart';
import 'package:clashf_pro/view/rules/rules.dart';
import 'package:flutter/widgets.dart';

class PageRules extends StatefulWidget {
  const PageRules({Key? key, required this.pageVisibleEvent}) : super(key: key);
  final PageVisibleEvent pageVisibleEvent;

  @override
  _PageRulesState createState() => _PageRulesState();
}

class _PageRulesState extends State<PageRules> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.pageVisibleEvent.onVisible('rules', (show) {
      log.debug('rules', show);
    });
    widget.pageVisibleEvent.onVisible('rules', (show) {
      log.debug('rules', show);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageRulesProviders(pageVisibleEvent: widget.pageVisibleEvent),
          PageRulesRules(pageVisibleEvent: widget.pageVisibleEvent),
        ],
      ).padding(top: 5, right: 20, bottom: 20),
    );
  }
}
