import Cocoa
import FlutterMacOS
// import bitsdojo_window_macos
import window_manager

class MainFlutterWindow: NSWindow {
// class MainFlutterWindow: BitsdojoWindow {
  // override func bitsdojo_window_configure() -> UInt {
  //   return BDW_HIDE_ON_STARTUP
  // }

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }

  override public func order(_ place: NSWindow.OrderingMode, relativeTo otherWin: Int) {
      super.order(place, relativeTo: otherWin)
      hiddenWindowAtLaunch()
  }
}
