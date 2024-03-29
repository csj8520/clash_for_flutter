import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_for_flutter/utils/utils.dart';
import 'package:clash_for_flutter/widgets/card_head.dart';
import 'package:clash_for_flutter/widgets/card_view.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';

class PageLog extends StatefulWidget {
  const PageLog({Key? key}) : super(key: key);

  @override
  State<PageLog> createState() => _PageLogState();
}

class _PageLogState extends State<PageLog> {
  final ScrollController _scrollController = ScrollController();

  final Map<String, Color> levelColors = const {
    "DBG": Color(0xff14b8a6),
    "INF": Color(0xff0ea5e9),
    "WRN": Color(0xffec4899),
    "ERR": Color(0xfff43f5e),
  };

  late StreamSubscription<RunningState> _serviceStatusSub;
  late StreamSubscription<bool> _windowStatusSub;

  @override
  void initState() {
    _handleStateChange();
    _serviceStatusSub = controllers.service.serviceStatus.stream.listen(_handleStateChange);
    _windowStatusSub = controllers.window.isVisible.stream.listen(_handleStateChange);
    super.initState();
  }

  void _handleStateChange([dynamic _]) async {
    final serviceStatus = controllers.service.serviceStatus.value;
    final isVisible = controllers.window.isVisible.value;

    if (serviceStatus == RunningState.running && isVisible) {
      await controllers.pageLog.init();
    } else {
      await controllers.pageLog.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CardHead(title: 'sidebar_logs'.tr),
      CardView(
        child: Obx(
          () => ListView.builder(
            padding: const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
            itemBuilder: (context, index) {
              final it = controllers.pageLog.logs[controllers.pageLog.logs.length - index - 1];
              // TODO: 跨行复制
              // return SelectableText.rich(
              return Text.rich(
                TextSpan(
                  style: const TextStyle(height: 1.5, fontSize: 13, color: Color(0xff73808f)),
                  children: [
                    TextSpan(text: '[${it.time}]').textColor(const Color(0xfffb923c)),
                    TextSpan(text: '  [${it.type.toUpperCase()}]  ').textColor(levelColors[it.type] ?? Colors.black),
                    TextSpan(text: it.msg),
                  ],
                ),
              );
            },
            itemCount: controllers.pageLog.logs.length,
            controller: _scrollController,
            reverse: true,
          ).backgroundColor(const Color(0xfff3f6f9)).clipRRect(all: 4).padding(all: 15),
        ),
        // TODO: 效果太差
        // child: SingleChildScrollView(
        //     controller: _scrollController,
        //     reverse: true,
        //     child: Obx(
        //       () => SelectableText.rich(
        //         TextSpan(
        //           style: const TextStyle(height: 1.5, fontSize: 13, color: Color(0xff73808f)),
        //           children: controllers.pageLog.logs
        //               .map((it) => TextSpan(children: [
        //                     TextSpan(text: it.time).textColor(const Color(0xfffb923c)),
        //                     TextSpan(text: '  [${it.type.toUpperCase()}]  ').textColor(levelColors[it.type] ?? Colors.black),
        //                     TextSpan(text: '${it.msg}\n'),
        //                   ]))
        //               .toList(),
        //         ),
        //       ),
        //     )),
      ).expanded()
    ]).padding(top: 5, right: 20, bottom: 10);
  }

  @override
  void dispose() {
    _serviceStatusSub.cancel();
    _windowStatusSub.cancel();
    controllers.pageLog.clear();
    _scrollController.dispose();
    super.dispose();
  }
}
