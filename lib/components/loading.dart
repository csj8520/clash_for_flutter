import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:styled_widget/styled_widget.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key, required this.child, required this.controller}) : super(key: key);
  final Widget child;
  final LoadingController controller;

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void dispose() {
    widget.controller.controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => StreamBuilder<Map<String, dynamic>>(
        stream: widget.controller.controller.stream,
        initialData: const <String, dynamic>{
          'show': false,
          'size': Size(100, 100),
        },
        builder: (_, snapshot) {
          final bool show = snapshot.data?['show'] ?? false;
          final Size size = snapshot.data?['size'] ?? const Size(100, 100);
          final double laodingSize = min(min(size.width, size.height) / 3, 80);

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
}

class LoadingController {
  StreamController<Map<String, dynamic>> controller = StreamController();
  show(Size? size) {
    controller.add({'show': true, 'size': size});
  }

  hide() {
    controller.add({'show': false});
  }
}

// extension LoadingExtension on BuildContext {
//   Loading? get loading => findAncestorWidgetOfExactType<Loading>();
// }
