import UserNotifications

enum NotificationCategoryIdentifier: String { case countdownCompleted }
enum NotificationActionIdentifier: String { case stop }

// TODO: add/update/remove requests when adding/editing/deleting countdowns
extension UNUserNotificationCenter {
  class func configure() {
    Task.detached {
      do {
        try await current().requestAuthorization(options: [.badge, .sound, .alert])
      } catch {
        print(error)
      }
      
      var actions = [
        UNNotificationAction(
          identifier: NotificationActionIdentifier.stop.rawValue,
          title: "Stop",
          options: []
        )
      ]
      
#if os(watchOS)
      actions.removeFirst()
#endif
      
      current().setNotificationCategories([
        .init(
          identifier: NotificationCategoryIdentifier.countdownCompleted.rawValue,
          actions: actions,
          intentIdentifiers: [],
          options: []
          // options: [.customDismissAction]
        )
      ])
      
      current().removeAllPendingNotificationRequests()
      
      let countdowns = try! PersistenceController.shared.container.viewContext.fetch(Countdown.fetchRequest())
      for countdown in countdowns {
        try! await current().addRequest(for: countdown)
      }
    }
  }

  func addRequest(for countdown: Countdown) async throws {
    guard countdown.target!.timeIntervalSinceNow > 0 else { return }

    let content = UNMutableNotificationContent()
    content.categoryIdentifier = NotificationCategoryIdentifier.countdownCompleted.rawValue
    content.interruptionLevel = .timeSensitive
    content.userInfo = ["countdownID": countdown.uuidString]

#if os(watchOS)
    if let label = countdown.label { content.title = label }
#else
    content.title = NSLocalizedString("Countdown", comment: "")
    if let label = countdown.label { content.body = label }
#endif

#if canImport(AudioServices)
    content.tone = Tone.drums.notificationSound
#endif

    // TODO: use `UNCalendarNotificationTrigger` instead
    let trigger = UNTimeIntervalNotificationTrigger(
      timeInterval: countdown.target!.timeIntervalSinceNow - 1,
      repeats: false
    )

    let request = UNNotificationRequest(
      identifier: countdown.uuidString,
      content: content,
      trigger: trigger
    )

    try await add(request)
  }

  func addRequest(for countdown: _Countdown) async throws {
    guard countdown.target.timeIntervalSinceNow > 0 else { return }

    let content = UNMutableNotificationContent()
    content.categoryIdentifier = NotificationCategoryIdentifier.countdownCompleted.rawValue
    content.interruptionLevel = .timeSensitive
    content.userInfo = ["countdownID": countdown.id.uuidString]

#if os(watchOS)
    if let label = countdown.label.nilIfEmpty { content.title = label }
#else
    content.title = NSLocalizedString("Countdown", comment: "")
    if let label = countdown.label.nilIfEmpty { content.body = label }
#endif

#if canImport(AudioServices)
    content.tone = Tone.drums.notificationSound
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

    try await add(request)
  }
}
