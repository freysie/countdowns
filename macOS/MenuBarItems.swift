import AppKit
import SwiftUI
import Combine

fileprivate let compactStatusItems = false

class MenuBarItems: ObservableObject {
  static let shared = MenuBarItems()

  private let statusBar = NSStatusBar.system
  private var statusItems = [_Countdown.ID: NSStatusItem]()
  private var subscriptions = Set<AnyCancellable>()

  init() {
    CountdownStore.shared.countdownsLoaded
      .receive(on: DispatchQueue.main)
      .sink { countdowns in
        for countdown in countdowns.filter({ $0.shownInMenuBar }) {
          self.addStatusItem(for: countdown)
        }
      }
      .store(in: &subscriptions)

    CountdownStore.shared.countdownAdded
      .receive(on: DispatchQueue.main)
      .sink { countdown in if countdown.shownInMenuBar { self.addStatusItem(for: countdown) } }
      .store(in: &subscriptions)

    CountdownStore.shared.countdownUpdated
      .receive(on: DispatchQueue.main)
      .sink { countdown in
        if countdown.shownInMenuBar {
          self.addStatusItem(for: countdown)
        } else {
          self.removeStatusItem(for: countdown)
        }
      }
      .store(in: &subscriptions)

    CountdownStore.shared.countdownDeleted
      .receive(on: DispatchQueue.main)
      .sink { countdown in self.removeStatusItem(for: countdown) }
      .store(in: &subscriptions)
  }

  // MARK: - Adding & Removing Items

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

    let view = NSHostingView(rootView: MenuBarItemView(countdownID: countdown.id))
    view.frame = NSRect(x: 0, y: 0, width: 360, height: 360)

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
    //statusItem.behavior = .removalAllowed // TODO: re-add this

    if compactStatusItems {
      statusItem.button!.font = NSFont.monospacedDigitSystemFont(ofSize: NSFont.smallSystemFontSize, weight: .regular)
      statusItem.button!.image = NSImage(named: "countdown")
    } else {
      statusItem.button!.font = NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
    }

    func updateButton() {
      guard let countdown = CountdownStore.shared.countdown(withID: countdown.id) else { return }
      statusItem.button!.appearsDisabled = countdown.progress(relativeTo: .now) >= 1
      statusItem.button!.title = CountdownFormatter.string(for: countdown, relativeTo: Date())
    }

    //let currentTime = CFAbsoluteTimeGetCurrent()
    //let deltaTime = currentTime - currentTime.rounded(.down)
    //print(deltaTime)

    //DispatchQueue.main.asyncAfter(deadline: .now() + deltaTime) {
      // TODO: start on 0 ns
      let timer = Timer(timeInterval: 1, repeats: true) { _ in updateButton() }
      RunLoop.main.add(timer, forMode: .common)
    //}

    updateButton()

    return statusItem
  }
}

// MARK: -

struct MenuBarItemView: View {
  var countdownID: _Countdown.ID
  var countdown: _Countdown? { CountdownStore.shared.countdown(withID: countdownID) }

  var body: some View {
    if let countdown {
      _CountdownProgressView(countdown: countdown, trackColor: Color(white: 0.1))
        .padding(20)
        //.background(Color(white: 0.12))
        //.padding(-5)
        .tint(Color(.controlAccentColor))
        //.tint(Color.accentColor)
    }
  }
}

// class CountdownBox {
//   var countdown: _Countdown
//   init(_ countdown: _Countdown) { self.countdown = countdown }
// }
