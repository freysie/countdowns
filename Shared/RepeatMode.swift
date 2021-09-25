// TODO: finish the repeat functionality, i.e. move target date on every completion

enum RepeatMode: String, CaseIterable, Identifiable {
  case never
  case daily
  case weekly
  case biweekly
  case monthly
  case yearly
  
  var id: String { rawValue }
}

extension Countdown {
  var `repeat`: RepeatMode {
    get { RepeatMode(rawValue: repeatValue!)! }
    set { repeatValue = newValue.rawValue }
  }
}
