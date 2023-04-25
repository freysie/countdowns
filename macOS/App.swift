import SwiftUI
import UserNotifications
import Introspect

@main
struct App: SwiftUI.App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegateAdaptor
  @StateObject private var store = Store()

  var body: some Scene {
    WindowGroup {
      NavigationView {
        CountdownList()
        EmptyView()
      }
      .frame(minWidth: 500, minHeight: 500)
      .environmentObject(store)
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
    [.sound, .banner]
  }
}

extension View {
  func introspectSplitView(customize: @escaping (NSSplitView) -> ()) -> some View {
    introspect(selector: TargetViewSelector.siblingContaining, customize: customize)
  }
}
