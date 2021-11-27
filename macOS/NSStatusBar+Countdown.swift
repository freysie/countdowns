import AppKit
import SwiftUI

fileprivate var statusItems = [Countdown: NSStatusItem]()

extension NSStatusBar {
  @discardableResult func addStatusItem(for countdown: Countdown) -> NSStatusItem {
    statusItems[countdown] = statusItem(for: countdown)
    return statusItems[countdown]!
  }
  
  func removeStatusItem(for countdown: Countdown) {
    guard let statusItem = statusItems[countdown] else { return }
    removeStatusItem(statusItem)
  }
  
  func statusItem(for countdown: Countdown) -> NSStatusItem {
    if let statusItem = statusItems[countdown] { return statusItem }
    
    let view = NSHostingView(rootView: CountdownProgressView(countdown: countdown).padding())
    view.frame = NSRect(x: 0, y: 0, width: 300, height: 300)
    
    let menuItem = NSMenuItem()
    menuItem.view = view
    
    let menu = NSMenu()
    menu.addItem(menuItem)

//    menu.addItem(.separator())
    
//    let showItem = menu.addItem(
//      withTitle: NSLocalizedString("Show Countdowns in Dock", comment: ""),
//      action: nil,
//      keyEquivalent: ""
//    )
//    showItem.state = .on
//    showItem.isEnabled = true
    
    let statusItem = statusItem(withLength: NSStatusItem.variableLength)
    statusItem.menu = menu
    statusItem.behavior = .removalAllowed
    statusItem.button!.font = NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
    
    statusItem.button!.title = CountdownFormatter.string(for: countdown, relativeTo: Date())
    
    let timer = Timer(timeInterval: 1, repeats: true) { _ in
      statusItem.button!.title = CountdownFormatter.string(for: countdown, relativeTo: Date())
    }
    
    RunLoop.main.add(timer, forMode: .common)
    
    return statusItem
  }
}
