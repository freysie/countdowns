import Foundation
import UserNotifications
import Combine

class UserNotifications: ObservableObject {
  enum Category { static let countdownCompleted = "countdownCompleted" }
  enum Action { static let stop = "stop" }
  //
  //  let shared = UserNotifications()

  private let center = UNUserNotificationCenter.current()
  private var subscriptions = Set<AnyCancellable>()

  init() {
    requestAuthorization()
    setCategories()
    subscribeToStoreChanges()

    center.removeAllPendingNotificationRequests()
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

    // options: [.customDismissAction]??
    center.setNotificationCategories([
      .init(identifier: Category.countdownCompleted, actions: actions, intentIdentifiers: [], options: [])
    ])
  }

  private func subscribeToStoreChanges() {
    NotificationCenter.default.publisher(for: CountdownStore.didLoadCountdownsNotification)
      .sink { notification in
        guard let countdowns = notification.userInfo?["countdowns"] as? [_Countdown] else { return }
        for countdown in countdowns.filter({ $0.target.timeIntervalSinceNow > 0 }) {
          Task { await self.addRequest(for: countdown) }
        }
      }
      .store(in: &subscriptions)

    NotificationCenter.default.publisher(for: CountdownStore.didAddCountdownNotification)
      .sink { notification in
        guard let countdown = notification.userInfo?["countdown"] as? _Countdown else { return }
        Task { await self.addRequest(for: countdown) }
      }
      .store(in: &subscriptions)

    NotificationCenter.default.publisher(for: CountdownStore.didUpdateCountdownNotification)
      .sink { notification in
        guard let countdown = notification.userInfo?["countdown"] as? _Countdown else { return }
        Task { await self.removeRequest(for: countdown); await self.addRequest(for: countdown) }
      }
      .store(in: &subscriptions)

    NotificationCenter.default.publisher(for: CountdownStore.didRemoveCountdownNotification)
      .sink { notification in
        guard let countdown = notification.userInfo?["countdown"] as? _Countdown else { return }
        Task { await self.removeRequest(for: countdown) }
      }
      .store(in: &subscriptions)
  }

  // MARK: - Adding & Removing Requests

  private func addRequest(for countdown: _Countdown) async {
    guard countdown.target.timeIntervalSinceNow > 0 else { return }

    let content = UNMutableNotificationContent()
    content.categoryIdentifier = Category.countdownCompleted
    content.interruptionLevel = .timeSensitive
    content.userInfo = ["countdownID": countdown.id.uuidString]
    //content.userInfo = ["countdownID": countdown.id]

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
      print(await center.pendingNotificationRequests())
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
