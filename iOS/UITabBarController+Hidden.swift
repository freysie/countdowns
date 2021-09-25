import UIKit

extension UITabBarController {
  var isTabBarHidden: Bool {
    tabBar.frame.minY >= view.frame.maxY
  }
  
  func setTabBarHidden(_ hidden: Bool, animated: Bool) {
    guard isTabBarHidden != hidden else { return }
    
    UIView.animate(withDuration: animated ? 0.3 : 0) { [self] in
      if hidden {
        tabBar.frame.origin.y = view.frame.height
      } else {
        tabBar.frame.origin.y = view.frame.height - tabBar.frame.height
      }
    }
  }
}
