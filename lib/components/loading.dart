import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
    return Builder(
      builder: (context) => StreamBuilder<Map<String, dynamic>>(
        stream: widget.controller.stream,
        initialData: const <String, dynamic>{
          'show': false,
          'size': Size(100, 100),
        },
        builder: (_, snapshot) {
          final bool show = snapshot.data?['show'] ?? false;
          final Size size = snapshot.data?['size'] ?? const Size(100, 100);
          final double laodingSize = min(min(size.width, size.height) / 2, 80);

          return Stack(
            children: [
              widget.child,
              show
                  ? Center(
                      child: SpinKitPulse(color: Theme.of(context).primaryColor, size: laodingSize),
                    ).backgroundColor(const Color(0x66000000)).constrained(width: size.width, height: size.height)
                  : const SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }
}

class LoadingController {
  final StreamController<Map<String, dynamic>> _controller = StreamController();

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  void show(Size? size) {
    _controller.add({'show': true, 'size': size});
  }

  void hide() {
    _controller.add({'show': false});
  }

  void dispose() {
    _controller.close();
  }
}

// extension LoadingExtension on BuildContext {
//   Loading? get loading => findAncestorWidgetOfExactType<Loading>();
// }
