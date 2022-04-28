import 'dart:async';

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// 若使用 Obx 必须在 StatefulWidget 下使用，否则 hide 会失效
class Loading extends StatefulWidget {
  const Loading({Key? key, required this.controller, required this.child}) : super(key: key);
  final Widget child;
  final LoadingController controller;

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: widget.controller.stream,
      initialData: false,
      builder: (_, snapshot) {
        final bool show = snapshot.data ?? false;

        return Stack(
          children: [
            widget.child,
            show
                ? Positioned.fill(
                    child: Center(
                      child: SpinKitPulse(
                        color: Theme.of(context).primaryColor,
                        size: 100,
                      ).constrained(maxHeight: 100, maxWidth: 100).padding(all: 5),
                    ).backgroundColor(const Color(0x66000000)),
                  )
                : const SizedBox.shrink(),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }
}

class LoadingController {
  final StreamController<bool> _controller = StreamController();

  Stream<bool> get stream => _controller.stream;

  void show() {
    _controller.add(true);
  }

  void hide() {
    _controller.add(false);
  }

  void dispose() {
    _controller.close();
  }
}
