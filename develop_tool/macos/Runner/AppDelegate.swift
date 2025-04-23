import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    override func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.setContentSize(NSSize(width: 1000, height: 800)) // 设置窗口大小
            window.minSize = NSSize(width: 800, height: 600)        // 最小尺寸（可选）
        }
        super.applicationDidFinishLaunching(notification)
    }
}
