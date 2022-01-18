import 'package:clash_pro_for_flutter/store/index.dart';
import 'package:window_manager/window_manager.dart';

mixin WindowMixin on WindowListener {
  void initWindow() {
    windowManager.addListener(this);
  }

  @override
  void onWindowFocus() {
    clashApiConfigStore.updateConfig();
  }
}
