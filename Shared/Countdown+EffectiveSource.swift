import CoreData

extension Countdown {
  var effectiveSource: Date? {
    guard let target = target else { return nil }
    guard `repeat` != .never else { return source }
    
    let components = DateComponents(
      year: `repeat` == .yearly ? -1 : 0,
      month: `repeat` == .monthly ? -1 : 0,
      day: `repeat` == .daily ? -1 : 0,
      weekOfMonth: `repeat` == .weekly ? -1 : `repeat` == .biweekly ? -2 : 0
    )
    
    return Calendar.current.date(byAdding: components, to: target)
  }
}
