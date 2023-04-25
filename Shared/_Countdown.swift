#if os(macOS)
import AppKit
#endif
import UserNotifications

extension Date {
  var oneHourFromNow: Self {
    Calendar.current.date(bySetting: .nanosecond, value: 0, of: Calendar.current.date(byAdding: .hour, value: 1, to: .now)!)!
  }
}

struct _Countdown: Identifiable, Codable {
  var id = UUID()
  var label: String
  var source = Date()
  var target = Calendar.current.date(byAdding: .hour, value: 1, to: .now)!
  var `repeat` = RepeatMode.never
  var tone = Tone.none
  var songID: Int64?
  var shownInMenuBar = false

  var timeRemaining: TimeInterval { timeRemaining(relativeTo: .now) }

  func timeRemaining(relativeTo date: Date) -> TimeInterval {
    target.timeIntervalSince(isTakingScreenshots ? previewDate : date)
  }

  func progress(relativeTo date: Date) -> Double {
    let effectiveSource = source // FIXME

    let relativeDate = isTakingScreenshots ? previewDate : date
    guard target > relativeDate else { return 1 }

    // TODO: fix off-by-one error
    let span = effectiveSource.distance(to: target) - 1
    return abs(effectiveSource.timeIntervalSince(relativeDate)) / span
  }
}

extension _Countdown: CustomStringConvertible {
  var description: String {
    "\(Self.self)(\(CountdownFormatter.string(from: timeRemaining)) - \(label))"
  }
}

class Store: ObservableObject {
  @Published var countdowns = [_Countdown]()

  private static func fileURL() throws -> URL {
    //FileManager.default.url(forUbiquityContainerIdentifier: nil)!.appendingPathComponent("Documents")
    try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
      .appendingPathComponent("countdowns.json")
  }

  init() {
    // countdowns.append(_Countdown(label: "yaaaaas"))
    // Task { try! await save() }
    Task { try! await load() }
  }

  @MainActor func load() async throws {
    print(try Self.fileURL())

    let task = Task<[_Countdown], Error> {
      guard let data = try? Data(contentsOf: try Self.fileURL()) else { return [] }
      return try JSONDecoder().decode([_Countdown].self, from: data)
    }

    countdowns = try await task.value
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

  func add(countdown: _Countdown) {
    countdowns.append(countdown)
    Task { try! await save() }
    Task { try! await UNUserNotificationCenter.current().addRequest(for: countdown) }
  }

  func update(countdownWithID id: UUID, withContentsOf countdown: _Countdown) {
    guard let index = countdowns.firstIndex(where: { $0.id == id }) else { return }
    countdowns[index] = countdown
    countdowns[index].id = id
    Task { try! await save() }
  }

  func delete(countdownWithID id: UUID) {
    guard let index = countdowns.firstIndex(where: { $0.id == id }) else { return }
    countdowns.remove(at: index)
    Task { try! await save() }
    //Task { try! await UNUserNotificationCenter.current().removeRequest(forCountdownWithID: id) }
  }

  func toggleDisplayOfCountdownInMenuBar(_ countdown: _Countdown) {
//#if os(macOS)
//    if countdown.shownInMenuBar {
//      NSStatusBar.system.addStatusItem(for: countdown)
//    } else {
//      NSStatusBar.system.removeStatusItem(for: countdown)
//    }
//#endif
  }
}
