// TODO: finish the repeat functionality, i.e. move target date on every completion
import Foundation

enum RepeatMode: String, CaseIterable, Identifiable, Codable {
  case never
  case daily
  case weekly
  case biweekly
  case monthly
  case yearly
  
  var id: String { rawValue }

  var dateComponents: DateComponents {
    DateComponents(
      year: self == .yearly ? -1 : 0,
      month: self == .monthly ? -1 : 0,
      day: self == .daily ? -1 : 0,
      weekOfMonth: self == .weekly ? -1 : self == .biweekly ? -2 : 0
    )
  }
}

extension Countdown {
  var `repeat`: RepeatMode {
    get { RepeatMode(rawValue: repeatValue!)! }
    set { repeatValue = newValue.rawValue }
  }
}
