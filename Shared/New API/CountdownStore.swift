import Foundation
import UserNotifications

class CountdownStore: ObservableObject {
  @Published var countdowns = [_Countdown]()

  private static func fileURL() throws -> URL {
    //FileManager.default.url(forUbiquityContainerIdentifier: nil)!.appendingPathComponent("Documents")
    try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
      .appendingPathComponent("countdowns.json")
  }

  init() {
//    add(_Countdown(label: "yaaaaas", target: .fiveSecondsFromNow))

    Task { try! await load() }
    add(_Countdown(label: "yaaaaas", target: .twoSecondsFromNow, tone: .drums, shownInMenuBar: true))
  }

  @MainActor func load() async throws {
    print(try Self.fileURL())

    let task = Task<[_Countdown], Error> {
      guard let data = try? Data(contentsOf: try Self.fileURL()) else { return [] }
      return try JSONDecoder().decode([_Countdown].self, from: data)
    }

    countdowns = try await task.value

    NotificationCenter.default.post(name: Self.didLoadCountdownsNotification, object: self, userInfo: [
      "countdowns": countdowns
    ])
  }

  func save() async throws {
    let task = Task {
      let encoder = JSONEncoder()
      encoder.outputFormatting = .prettyPrinted
      let data = try encoder.encode(countdowns)
      try data.write(to: try Self.fileURL())
    }

    _ = try await task.value
  }

  func countdown(withID id: UUID) -> _Countdown? {
    countdowns.first { $0.id == id }
  }

  func add(_ countdown: _Countdown) {
    countdowns.append(countdown)
    Task { try! await save() }
    NotificationCenter.default.post(name: Self.didAddCountdownNotification, object: self, userInfo: [
      "countdown": countdown
    ])
  }

  func update(countdownWithID id: UUID, withContentsOf countdown: _Countdown) {
    guard let index = countdowns.firstIndex(where: { $0.id == id }) else { return }
    countdowns[index] = countdown
    countdowns[index].id = id
    Task { try! await save() }
    NotificationCenter.default.post(name: Self.didUpdateCountdownNotification, object: self, userInfo: [
      "countdown": countdowns[index]
    ])
  }

  func delete(countdownWithID id: UUID) {
    guard let index = countdowns.firstIndex(where: { $0.id == id }) else { return }
    let countdown = countdowns[index]
    countdowns.remove(at: index)
    Task { try! await save() }
    NotificationCenter.default.post(name: Self.didRemoveCountdownNotification, object: self, userInfo: [
      "countdown": countdown
    ])
  }
}

extension CountdownStore {
  static let didLoadCountdownsNotification = Notification.Name("CountdownStoreDidLoadCountdowns")
  static let didAddCountdownNotification = Notification.Name("CountdownStoreDidAddCountdown")
  static let didUpdateCountdownNotification = Notification.Name("CountdownStoreDidUpdateCountdown")
  static let didRemoveCountdownNotification = Notification.Name("CountdownStoreDidRemoveCountdown")

  // enum NotificationUserInfoKey {
  //   static let countdown = "Countdown"
  //   static let countdowns = "Countdowns"
  // }
}
