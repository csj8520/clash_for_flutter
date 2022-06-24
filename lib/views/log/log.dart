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
    "debug": Color(0xff14b8a6),
    "info": Color(0xff0ea5e9),
    "warning": Color(0xffec4899),
    "error": Color(0xfff43f5e),
  };

  late StreamSubscription<RunningState> _coreStatusSub;
  late StreamSubscription<bool> _windowStatusSub;

  @override
  void initState() {
    _handleStateChange();
    _coreStatusSub = controllers.service.coreStatus.stream.listen(_handleStateChange);
    _windowStatusSub = controllers.window.isVisible.stream.listen(_handleStateChange);
    super.initState();
  }

  void _handleStateChange([dynamic _]) async {
    final coreStatus = controllers.service.coreStatus.value;
    final isVisible = controllers.window.isVisible.value;

    if (coreStatus == RunningState.running && isVisible) {
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
        // child: Obx(
        //   () => ListView.builder(
        //     padding: const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
        //     itemBuilder: (context, index) {
        //       final it = controllers.pageLog.logs[controllers.pageLog.logs.length - index - 1];
        //       // TODO: 跨行复制
        //       return SelectableText.rich(
        //         TextSpan(
        //           style: const TextStyle(height: 1.5, fontSize: 13, color: Color(0xff73808f)),
        //           children: [
        //             TextSpan(text: it.time).textColor(const Color(0xfffb923c)),
        //             TextSpan(text: '  [${it.type.toUpperCase()}]  ').textColor(levelColors[it.type] ?? Colors.black),
        //             TextSpan(text: it.msg),
        //           ],
        //         ),
        //       );
        //     },
        //     itemCount: controllers.pageLog.logs.length,
        //     controller: _scrollController,
        //     reverse: true,
        //   ).backgroundColor(const Color(0xfff3f6f9)).clipRRect(all: 4).padding(all: 15),
        // ),
        // TODO: 效果太差
        child: SingleChildScrollView(
            controller: _scrollController,
            reverse: true,
            child: Obx(
              () => SelectableText.rich(
                TextSpan(
                  style: const TextStyle(height: 1.5, fontSize: 13, color: Color(0xff73808f)),
                  children: controllers.pageLog.logs
                      .map((it) => TextSpan(children: [
                            TextSpan(text: it.time).textColor(const Color(0xfffb923c)),
                            TextSpan(text: '  [${it.type.toUpperCase()}]  ').textColor(levelColors[it.type] ?? Colors.black),
                            TextSpan(text: '${it.msg}\n'),
                          ]))
                      .toList(),
                ),
              ),
            )),
      ).expanded()
    ]).padding(top: 5, right: 20, bottom: 10);
  }

  @override
  void dispose() {
    _coreStatusSub.cancel();
    _windowStatusSub.cancel();
    controllers.pageLog.clear();
    _scrollController.dispose();
    super.dispose();
  }
}
