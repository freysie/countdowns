import CoreData

extension Countdown {
  func timeRemaining(relativeTo date: Date) -> TimeInterval {
    target?.timeIntervalSince(isTakingScreenshots ? previewDate : date) ?? 0
  }
}
