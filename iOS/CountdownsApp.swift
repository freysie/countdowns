import SwiftUI
import MusicKit
import UserNotifications
import WatchConnectivity
import Introspect

// TODO: test this with multiple window scenes on iPad
var tabBarController: UITabBarController?

@main
struct CountdownsApp: App {
  @UIApplicationDelegateAdaptor(DelegateAdaptor.self) private var delegateAdaptor
  
  @AppStorage("upNextIsEnabled") private var upNextIsEnabled = true
  // @AppStorage("statusBarIsHidden") private var statusBarIsHidden = false
  
  enum Tab: String { case list, upNext }
  @AppStorage("selectedTab") private var selectedTab = Tab.list
  
  var body: some Scene {
    WindowGroup {
      Group {
        if upNextIsEnabled {
          TabView(selection: $selectedTab) {
            NavigationView(content: { ListView() })
              .tag(Tab.list)
              .tabItem {
                Label("Countdowns", image: "countdown")
                  .imageScale(.large)
              }
            
            UpNextView()
              .tag(Tab.upNext)
              .tabItem {
                Label("Up Next", systemImage: "deskclock")
              }
          }
          .introspectTabBarController {
            tabBarController = $0
          }
        } else {
          NavigationView { ListView() }
        }
      }
#if targetEnvironment(simulator)
      .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
#else
      .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
#endif
      // .statusBar(hidden: statusBarIsHidden)
      .navigationViewStyle(.stack)
    }
  }
  
  class DelegateAdaptor: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, WCSessionDelegate {
    func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
      UIView.appearance().tintColor = UIColor(named: "AccentColor")
      
      UNUserNotificationCenter.current().delegate = self
      UNUserNotificationCenter.configure()
      
//      Task.detached {
//        print(MusicAuthorization.currentStatus)
//        _ = await MusicAuthorization.request()
//      }
      
      if WCSession.isSupported() {
        WCSession.default.delegate = self
        WCSession.default.activate()
      }
      
      return true
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
      guard let countdownID = response.notification.request.content.userInfo["countdownID"] as? String else { return }
      
      // TODO: only the `selectedUpNextPage` transition should animate, not the countdown progress view
      // withAnimation {
      UserDefaults.standard.set(countdownID, forKey: "selectedUpNextPage")
      UserDefaults.standard.set(Tab.upNext.rawValue, forKey: "selectedTab")
      // }
    }
    
    func session(
      _ session: WCSession,
      activationDidCompleteWith activationState: WCSessionActivationState,
      error: Error?
    ) {
//      print("activationDidCompleteWith \(activationState.rawValue), error: \(error as Any)")
      
//      let countdowns = try! PersistenceController.preview.container.viewContext.fetch(Countdown.fetchRequest())
//      for countdown in countdowns {
//        session.sendMessage(
//          ["countdown": countdown.dictionaryWithValues(
//            forKeys: ["label", "target", "repeatValue", "toneValue"]
//          )],
//          replyHandler: nil,
//          errorHandler: nil
//        )
//      }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
      
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
      
    }
  }
}
