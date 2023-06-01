import Foundation
import Combine

class CountdownStore: ObservableObject {
  static let shared = CountdownStore()

  private static func fileURL() throws -> URL {
    //FileManager.default.url(forUbiquityContainerIdentifier: nil)!.appendingPathComponent("Documents")
    try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
      .appendingPathComponent("countdowns.json")
  }

  @Published var countdowns = [_Countdown]()

  let countdownsLoaded = PassthroughSubject<[_Countdown], Never>()
  let countdownAdded = PassthroughSubject<_Countdown, Never>()
  let countdownUpdated = PassthroughSubject<_Countdown, Never>()
  let countdownDeleted = PassthroughSubject<_Countdown, Never>()

  init() {
    Task {
      try! await load()
      //await addCountdown(_Countdown(label: "yaaaaas", target: .twoSecondsFromNow, tone: .drums, shownInMenuBar: true))
      //await addCountdown(_Countdown(label: "yaaaaas", target: .fiveSecondsFromNow))
    }
  }

  @MainActor func load() async throws {
    print(try Self.fileURL())

    let task = Task<[_Countdown], Error> {
      guard let data = try? Data(contentsOf: try Self.fileURL()) else { return [] }
      return try JSONDecoder().decode([_Countdown].self, from: data)
    }

    countdowns = try await task.value
    countdownsLoaded.send(countdowns)
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

  @MainActor func addCountdown(_ countdown: _Countdown) {
    countdowns.append(countdown)
    countdownAdded.send(countdown)
    Task { try! await save() }
  }

  @MainActor func updateCountdown(withID id: UUID, withContentsOf countdown: _Countdown) {
    guard let index = countdowns.firstIndex(where: { $0.id == id }) else { return }
    countdowns[index] = countdown
    countdowns[index].id = id
    countdownUpdated.send(countdowns[index])
    Task { try! await save() }
  }

  @MainActor func deleteCountdown(withID id: UUID) {
    guard let index = countdowns.firstIndex(where: { $0.id == id }) else { return }
    let countdown = countdowns[index]
    countdowns.remove(at: index)
    countdownDeleted.send(countdown)
    Task { try! await save() }
  }
}
