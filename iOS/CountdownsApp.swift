import SwiftUI
import UserNotifications
import Introspect
import Intents

// TODO: test this with multiple window scenes on iPad
var tabBarController: UITabBarController?

@main
struct CountdownsApp: App {
  @UIApplicationDelegateAdaptor(DelegateAdaptor.self) private var delegateAdaptor
  
  @AppStorage("upNextIsEnabled") private var upNextIsEnabled = true
  @AppStorage("statusBarIsHidden") private var statusBarIsHidden = false
  
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
//#if targetEnvironment(simulator)
//      .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//#else
      .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
//#endif
      .navigationViewStyle(.stack)
      .statusBar(hidden: statusBarIsHidden)
    }
  }
  
  class DelegateAdaptor: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
      UIView.appearance().tintColor = UIColor(named: "AccentColor")
      
//      INPreferences.requestSiriAuthorization {
//        print($0)
//      }
      
      UNUserNotificationCenter.current().delegate = self
      UNUserNotificationCenter.configure()
      
      return true
    }
    
    // func application(_ application: UIApplication, handlerFor intent: INIntent) -> Any? {
    //   switch intent {
    //   case is SetCountdownIntent:
    //     return nil
    //   default:
    //     return nil
    //   }
    // }

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

      // TODO: only the `selectedUpNextPage` transition should animate, not the countdown progress view
      // withAnimation {
      UserDefaults.standard.set(countdownID, forKey: "selectedUpNextPage")
      UserDefaults.standard.set(Tab.upNext.rawValue, forKey: "selectedTab")
      // }
    }
  }
}
