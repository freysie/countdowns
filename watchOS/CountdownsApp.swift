import SwiftUI
import ClockKit
import UserNotifications

let permitsUsageOfPrivateAPIs = true

@main
struct CountdownsApp: App {
  @WKExtensionDelegateAdaptor(DelegateAdaptor.self) private var delegateAdaptor
  
  var body: some Scene {
    WindowGroup {
      NavigationView {
        ListView()
      }
//#if targetEnvironment(simulator) || DEBUG
//      .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//#else
      .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
//#endif
    }
  }
  
  class DelegateAdaptor: NSObject, WKExtensionDelegate, UNUserNotificationCenterDelegate {
    func applicationDidFinishLaunching() {
      // print(CLKComplicationServer.sharedInstance().activeComplications as Any)
      
      UNUserNotificationCenter.current().delegate = self
      UNUserNotificationCenter.configure()
    }
    
    func handle(_ userActivity: NSUserActivity) {
      guard userActivity.activityType == UserActivityType.viewing.rawValue else { return }
      guard let countdownID = userActivity.userInfo?["countdownID"] as? String else { return }
      UserDefaults.standard.set(countdownID, forKey: "selectedCountdown")
    }
    
    func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
      [.sound, .banner]
    }
    
    func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      didReceive response: UNNotificationResponse
    ) async {
      guard let countdownID = response.notification.request.content.userInfo["countdownID"] as? String else { return }
      UserDefaults.standard.set(countdownID, forKey: "selectedCountdown")
    }
  }
}
