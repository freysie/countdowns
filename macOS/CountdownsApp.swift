import SwiftUI
import UserNotifications
import Introspect

extension View {
  func introspectSplitView(customize: @escaping (NSSplitView) -> ()) -> some View {
    introspect(selector: TargetViewSelector.siblingContaining, customize: customize)
  }
}

@main
struct CountdownsApp: App {
  @NSApplicationDelegateAdaptor(DelegateAdaptor.self) private var delegateAdaptor
  
  var body: some Scene {
    WindowGroup {
      NavigationView {
        ListView()
        EmptyView()
      }
      .frame(minWidth: 500, minHeight: 500)
      .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
      .introspectSplitView {
        $0.window?.titlebarAppearsTransparent = true
        //($0.delegate as? NSSplitViewController)?.splitViewItems.last?.titlebarSeparatorStyle = .none
      }
    }
    .windowToolbarStyle(.unifiedCompact(showsTitle: false))
    .commands {
      SidebarCommands()
    }
  }
  
  class DelegateAdaptor: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
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
}
