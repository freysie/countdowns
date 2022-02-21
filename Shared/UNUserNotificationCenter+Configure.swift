import UserNotifications

enum NotificationCategoryIdentifier: String { case countdownCompleted }
enum NotificationActionIdentifier: String { case stop, stopAndDelete }

extension UNUserNotificationCenter {
  func configure() {
    Task.detached { [self] in
      do {
        try await requestAuthorization(options: [.badge, .sound, .alert])
      } catch {
        print(error)
      }
      
      var actions = [
        UNNotificationAction(
          identifier: NotificationActionIdentifier.stop.rawValue,
          title: "Stop",
          options: []
        ),
//        UNNotificationAction(
//          identifier: NotificationActionIdentifier.stopAndDelete.rawValue,
//          title: "Stop and Delete",
//          options: [.destructive],
//          icon: .init(systemImageName: "trash")
//        )
      ]
      
#if os(watchOS)
      actions.removeFirst()
#endif
      
      setNotificationCategories([
        .init(
          identifier: NotificationCategoryIdentifier.countdownCompleted.rawValue,
          actions: actions,
          intentIdentifiers: [],
          options: []
          // options: [.customDismissAction]
        )
      ])
      
      removeAllPendingNotificationRequests()
      
      let countdowns = try! PersistenceController.shared.container.viewContext.fetch(Countdown.fetchRequest())
      
      for countdown in countdowns {
        try! await addRequest(for: countdown)
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
    if countdown.tone != .none {
      content.tone = countdown.tone.notificationSound
    }
#endif

    // TODO: use `UNCalendarNotificationTrigger` instead
    
    // UNCalendarNotificationTrigger(
    //   dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: countdown.target!),
    //   repeats: false
    // )
    
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
}
