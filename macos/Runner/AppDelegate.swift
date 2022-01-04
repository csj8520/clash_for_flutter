import Cocoa
import FlutterMacOS
// import window_manager

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }
  // override func applicationWillUnhide(_ notification: Notification) {
  //   NSApplication.shared.setActivationPolicy(NSApplication.ActivationPolicy.accessory);
  // }
  // override func applicationDidHide(_ notification: Notification) {
  //   // super.applicationDidHide(notification)
  //   // WindowManager.setSkipTaskbar(["isSkipTaskbar": true]);
  //   print("==========");
  //   NSApplication.shared.setActivationPolicy(NSApplication.ActivationPolicy.accessory);
  // }

}
