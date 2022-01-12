import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clashf_pro/utils/index.dart';

import 'rules.dart';
import 'providers.dart';

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
