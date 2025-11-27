import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
  
  // Handle URL callbacks for Google Sign In
  // FlutterAppDelegate automatically handles URL callbacks for plugins
  // This method ensures URLs are logged and forwarded correctly
  @MainActor
  override func application(_ application: NSApplication, open urls: [URL]) {
    print("🔗 [AppDelegate] Received URLs: \(urls)")
    for url in urls {
      print("🔗 [AppDelegate] Processing URL: \(url.absoluteString)")
    }
    // Call super to forward URLs to Flutter plugins
    super.application(application, open: urls)
  }
}
