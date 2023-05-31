import AppKit
import SwiftUI
import Combine

class MenuExtraCoordinator: ObservableObject {
//  func toggleDisplayOfCountdownInMenuBar(_ countdown: _Countdown) {
//#if os(macOS)
//    if countdown.shownInMenuBar {
//      NSStatusBar.system.addStatusItem(for: countdown)
//    } else {
//      NSStatusBar.system.removeStatusItem(for: countdown)
//    }
//#endif
//  }

  private let statusBar = NSStatusBar.system
  private var statusItems = [_Countdown.ID: NSStatusItem]()
  private var subscriptions = Set<AnyCancellable>()

  init() {
    subscribeToStoreChanges()
  }

  private func subscribeToStoreChanges() {
    NotificationCenter.default.publisher(for: CountdownStore.didLoadCountdownsNotification)
      .receive(on: DispatchQueue.main)
      .sink { notification in
        guard let countdowns = notification.userInfo?["countdowns"] as? [_Countdown] else { return }
        for countdown in countdowns.filter({ $0.shownInMenuBar }) {
          self.addStatusItem(for: countdown)
        }
      }
      .store(in: &subscriptions)

    NotificationCenter.default.publisher(for: CountdownStore.didAddCountdownNotification)
      .receive(on: DispatchQueue.main)
      .sink { notification in
        guard let countdown = notification.userInfo?["countdown"] as? _Countdown else { return }
        if countdown.shownInMenuBar {
          self.addStatusItem(for: countdown)
        }
      }
      .store(in: &subscriptions)

    NotificationCenter.default.publisher(for: CountdownStore.didUpdateCountdownNotification)
      .receive(on: DispatchQueue.main)
      .sink { notification in
        guard let countdown = notification.userInfo?["countdown"] as? _Countdown else { return }
        if countdown.shownInMenuBar {
          self.addStatusItem(for: countdown)
        } else {
          self.removeStatusItem(for: countdown)
        }
      }
      .store(in: &subscriptions)

    NotificationCenter.default.publisher(for: CountdownStore.didRemoveCountdownNotification)
      .receive(on: DispatchQueue.main)
      .sink { notification in
        guard let countdown = notification.userInfo?["countdown"] as? _Countdown else { return }
        self.removeStatusItem(for: countdown)
      }
      .store(in: &subscriptions)
  }

  @discardableResult private func addStatusItem(for countdown: _Countdown) -> NSStatusItem {
    let item = statusItem(for: countdown)
    statusItems[countdown.id] = item

    //item.publisher(for: \.isVisible)
    //  .sink {  }

    return item
  }

  private func removeStatusItem(for countdown: _Countdown) {
    guard let statusItem = statusItems[countdown.id] else { return }
    statusBar.removeStatusItem(statusItem)
    statusItems.removeValue(forKey: countdown.id)
  }

  private func statusItem(for countdown: _Countdown) -> NSStatusItem {
    if let statusItem = statusItems[countdown.id] { return statusItem }

    let view = NSHostingView(rootView: _CountdownProgressView(countdown: countdown).padding())
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

    let statusItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
    statusItem.menu = menu
    //statusItem.behavior = .removalAllowed // TODO: readd this
    statusItem.button!.font = NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
    statusItem.button!.title = CountdownFormatter.string(for: countdown, relativeTo: Date())

    let timer = Timer(timeInterval: 1, repeats: true) { _ in
      statusItem.button!.appearsDisabled = countdown.progress(relativeTo: .now) >= 1
      statusItem.button!.title = CountdownFormatter.string(for: countdown, relativeTo: Date())
    }

    RunLoop.main.add(timer, forMode: .common)

    return statusItem
  }
}
