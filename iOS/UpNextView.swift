import SwiftUI

struct UpNextView: View {
  @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Countdown.target, ascending: true)])
  private var countdowns: FetchedResults<Countdown>
  
  @AppStorage("selectedUpNextPage") private var selectedPage: String?
  // @AppStorage("statusBarIsHidden") private var statusBarIsHidden = false
  
  var body: some View {
    if countdowns.isEmpty {
      Circle()
        .stroke(Color(white: 0.1), lineWidth: CountdownProgressView.defaultLineWidth)
        .padding()
        .padding(.bottom, 100)
    } else {
      TabView(selection: $selectedPage) {
        ForEach(countdowns) {
          CountdownProgressView(countdown: $0)
            .tag($0.uuidString)
        }
      }
      .tabViewStyle(.page(indexDisplayMode: .never))
      .background(.background)
      // .statusBar(hidden: tabBarController?.isTabBarHidden ?? false)
      .onTapGesture {
        guard !countdowns.isEmpty, let tabBarController = tabBarController else { return }
        // tabBarController.prefersStatusBarHidden = true
        // UIApplication.shared.isStatusBarHidden.toggle()
        // tabBarController.tabBar.window?.windowScene?.statusBarManager?
        tabBarController.setTabBarHidden(!tabBarController.isTabBarHidden, animated: true)
        // statusBarIsHidden = tabBarController.isTabBarHidden
        UIApplication.shared.isIdleTimerDisabled = tabBarController.isTabBarHidden
      }
    }
  }
}
