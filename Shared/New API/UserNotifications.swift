import Foundation
import UserNotifications
import Combine

class UserNotifications: ObservableObject {
  enum Category { static let countdownCompleted = "countdownCompleted" }
  enum Action { static let stop = "stop" }

  static let shared = UserNotifications()

  // let shared = UserNotifications()

  private let center = UNUserNotificationCenter.current()
  private var subscriptions = Set<AnyCancellable>()

  init() {
    requestAuthorization()
    setCategories()

    center.removeAllPendingNotificationRequests()

    CountdownStore.shared.countdownsLoaded
      .sink { countdowns in
        for countdown in countdowns.filter({ $0.target.timeIntervalSinceNow > 0 }) {
          Task { await self.addRequest(for: countdown) }
        }
      }
      .store(in: &subscriptions)

    CountdownStore.shared.countdownAdded
      .sink { countdown in Task { await self.addRequest(for: countdown) } }
      .store(in: &subscriptions)

    CountdownStore.shared.countdownUpdated
      .sink { countdown in Task { await self.removeRequest(for: countdown); await self.addRequest(for: countdown) } }
      .store(in: &subscriptions)

    CountdownStore.shared.countdownDeleted
      .sink { countdown in Task { await self.removeRequest(for: countdown) } }
      .store(in: &subscriptions)
  }

  private func requestAuthorization() {
    Task {
      do {
        try await center.requestAuthorization(options: [.badge, .sound, .alert])
      } catch {
        print(error)
      }
    }
  }

  private func setCategories() {
#if !os(watchOS)
    let actions = [UNNotificationAction(identifier: Action.stop, title: "Stop", options: [])]
#else
    let actions: [UNNotificationAction] = []
#endif

    center.setNotificationCategories([
      .init(identifier: Category.countdownCompleted, actions: actions, intentIdentifiers: [], options: [])
    ])
  }

  // MARK: - Adding & Removing Requests

  private func addRequest(for countdown: _Countdown) async {
    guard countdown.target.timeIntervalSinceNow > 0 else { return }

    let content = UNMutableNotificationContent()
    content.categoryIdentifier = Category.countdownCompleted
    content.interruptionLevel = .timeSensitive
    content.userInfo = ["countdownID": countdown.id.uuidString]
    //content.userInfo = ["countdownID": countdown.id as NSUUID]

#if os(watchOS)
    if let label = countdown.label.nilIfEmpty { content.title = label }
#else
    content.title = NSLocalizedString("Countdown", comment: "")
    if let label = countdown.label.nilIfEmpty { content.body = label }
#endif

#if canImport(AudioToolbox)
    // TODO: find out why this stopped working on macOS
    content.sound = countdown.tone.notificationSound
#endif

    // TODO: use `UNCalendarNotificationTrigger` instead
    let trigger = UNTimeIntervalNotificationTrigger(
      timeInterval: countdown.target.timeIntervalSinceNow - 1,
      repeats: false
    )

    let request = UNNotificationRequest(
      identifier: countdown.id.uuidString,
      content: content,
      trigger: trigger
    )

    do {
      try await center.add(request)
      //print(await center.pendingNotificationRequests())
    } catch {
      print(error)
    }
  }

  private func removeRequest(for countdown: _Countdown) async {
    center.removePendingNotificationRequests(withIdentifiers: [countdown.id.uuidString])
  }

  // MARK: - Center Delegate

  // func userNotificationCenter(
  //   _ center: UNUserNotificationCenter,
  //   willPresent notification: UNNotification
  // ) async -> UNNotificationPresentationOptions {
  //   [.sound, .banner]
  // }
}
