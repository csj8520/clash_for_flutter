import 'dart:async';

import 'package:clashf_pro/utils/utils.dart';
import 'package:flutter/material.dart';

class Logs extends StatefulWidget {
  const Logs({Key? key}) : super(key: key);

  @override
  _LogsState createState() => _LogsState();
}

class _LogsState extends State<Logs> {
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
    return ListView.builder(
      padding: const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
      itemBuilder: (context, index) => _logs[index],
      itemCount: _logs.length,
      controller: _scrollController,
    );
  }
}
