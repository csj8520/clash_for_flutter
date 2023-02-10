import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import 'package:clash_for_flutter/controllers/controllers.dart';

class WindowController extends GetxController with WindowListener {
  /// focus blur minimize maximize unmaximize restore resized close move moved...
  var event = ''.obs;
  var isVisible = false.obs;

  void initWindow() async {
    // windowManager.addListener(this);
    // isVisible.value = await windowManager.isVisible();
  }

  @override
  void onWindowClose() async {
    await windowManager.hide();
  }

  @override
  void onWindowEvent(String eventName) async {
    if (controllers.tray.show.value) return;
    event.value = eventName;
    if (['focus', 'restore'].contains(eventName)) {
      isVisible.value = true;
    } else if (['close', 'minimize'].contains(eventName)) {
      isVisible.value = false;
    }
  }

  Future<void> closeWindow() async {
    await windowManager.close();
  }

  Future<void> showWindow() async {
    await windowManager.show();
    isVisible.value = true;
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }
}
