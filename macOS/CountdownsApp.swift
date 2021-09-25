import SwiftUI
import UserNotifications

@main
struct CountdownsApp: App {
  @NSApplicationDelegateAdapator(DelegateAdaptor.self) private var delegateAdaptor
  
  var body: some Scene {
    WindowGroup {
      NavigationView {
        EmptyView()
      }
      .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
  }
  
  class DelegateAdaptor: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
      UNUserNotificationCenter.current().delegate = self
      UNUserNotificationCenter.configure()
    }
    
    func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      willPresent notification: UNNotification,
      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
      completionHandler([.sound, .banner])
    }
  }
}
