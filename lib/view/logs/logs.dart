import 'dart:async';

import 'package:clashf_pro/components/page_head.dart';
import 'package:clashf_pro/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class ViewLogs extends StatefulWidget {
  const ViewLogs({Key? key, this.show = false}) : super(key: key);
  final bool show;

  @override
  _ViewLogsState createState() => _ViewLogsState();
}

class _ViewLogsState extends State<ViewLogs> {
  final List<Widget> _logs = [];
  final ScrollController _scrollController = ScrollController();

  Timer? _timer;
  bool _lockScrollToBottom = true;
  bool _notHandleScroll = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_notHandleScroll) return;
      _lockScrollToBottom = _scrollController.position.maxScrollExtent - _scrollController.offset < 20;
    });
    log.on(onLog: (event) {
      setState(() {
        _logs.add(Text(event));
        if (_logs.length > 1000) _logs.removeAt(0);
      });
      _timer?.cancel();
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        if (!_lockScrollToBottom) return;
        _notHandleScroll = true;
        _scrollController.position.moveTo(_scrollController.position.maxScrollExtent);
        _notHandleScroll = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const PageHead(title: '日志'),
      ListView.builder(
        padding: const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
        itemBuilder: (context, index) => _logs[index],
        itemCount: _logs.length,
        controller: _scrollController,
      )
          .backgroundColor(const Color(0xfff3f6f9))
          .clipRRect(all: 4)
          .padding(all: 15)
          .backgroundColor(const Color(0xffffffff))
          .clipRRect(all: 4)
          .boxShadow(color: const Color(0x2e2c8af8), offset: const Offset(2, 5), blurRadius: 20, spreadRadius: -3)
          .padding(bottom: 20)
          .expanded()
    ]);
  }
}
