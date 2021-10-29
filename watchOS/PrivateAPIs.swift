import SwiftUI
import Dynamic

public extension WKInterfaceDevice {
  func setStatusBarTimeHidden(_ hidden: Bool, animated: Bool = false, completion: (() -> Void)? = nil) {
    guard permitsUsageOfPrivateAPIs else { return }
    
    Dynamic.PUICApplication.sharedPUICApplication()
      ._setStatusBarTimeHidden(hidden, animated: animated, completion: completion)
  }
}

public extension View {
  func statusBarTime(hidden: Bool) -> some View {
    modifier(StatusBarTime(hidden: hidden))
  }
  
  func previewStatusBarTime(hidden: Bool) -> some View {
    statusBarTime(hidden: hidden)
  }
}

public struct StatusBarTime: ViewModifier {
  public var hidden: Bool
  
  public func body(content: Content) -> some View {
    content
      .onAppear { WKInterfaceDevice.current().setStatusBarTimeHidden(hidden) }
  }
}
