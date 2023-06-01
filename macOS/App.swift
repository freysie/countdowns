import SwiftUI
import UserNotifications
import Introspect

@main
struct App: SwiftUI.App {
  @ObservedObject private var countdownStore = CountdownStore.shared
  @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegateAdaptor

  init() {
    _ = UserNotifications.shared
    _ = MenuBarItems.shared
  }

  var body: some Scene {
    WindowGroup {
      NavigationView {
        CountdownList()
        PlaceholderView()
      }
      .background(Color(white: 0.12))
      .frame(minWidth: 500, minHeight: 500)
      .environmentObject(countdownStore)
      //.environmentObject(userNotifications)
      //.environmentObject(menuBarExtras)
      .preferredColorScheme(.dark)
      .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
      .introspectSplitView { $0.window?.titlebarAppearsTransparent = true }
    }
    .windowToolbarStyle(.unifiedCompact(showsTitle: false))
    .commands { SidebarCommands() }
  }

  struct PlaceholderView: View {
    var body: some View {
      Text("No Selection")
        .font(.title2)
        .foregroundStyle(.secondary)
        .offset(x: 0, y: -38/2)
    }
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
