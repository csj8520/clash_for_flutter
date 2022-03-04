import 'package:clash_for_flutter/src/store/index.dart';
import 'package:window_manager/window_manager.dart';

mixin WindowMixin on WindowListener {
  void initWindow() {
    windowManager.addListener(this);
  }

  @override
  void onWindowFocus() {
    clashApiConfigStore.updateConfig();
    proxiesStore.update();
  }
}
