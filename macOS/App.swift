import SwiftUI
import UserNotifications
import Introspect

@main
struct App: SwiftUI.App {
  @StateObject private var userNotifications = UserNotifications()
  @StateObject private var menuExtraCoordinator = MenuExtraCoordinator()
  @StateObject private var countdownStore = CountdownStore()
  @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegateAdaptor

  var body: some Scene {
    WindowGroup {
      NavigationView {
        CountdownList()
        Text("No Selection").font(.title2).foregroundStyle(.secondary)
      }
      .frame(minWidth: 500, minHeight: 500)
      .environmentObject(countdownStore)
      //.environmentObject(userNotifications)
      //.environmentObject(menuExtraCoordinator)
      .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
      .introspectSplitView { $0.window?.titlebarAppearsTransparent = true }
    }
    .windowToolbarStyle(.unifiedCompact(showsTitle: false))
    .commands { SidebarCommands() }
  }
}

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
    UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.configure()

    // NSApp.setActivationPolicy(.accessory)
    // NSApp.presentationOptions = .
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification
  ) async -> UNNotificationPresentationOptions {
    return [.sound, .banner]
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse
  ) async {
    guard let idString = response.notification.request.content.userInfo["countdownID"] as? String else { return }
    print(UUID(uuidString: idString) as Any)
    //UserDefaults.standard.set(id, forKey: "selectedCountdown")
  }
}
