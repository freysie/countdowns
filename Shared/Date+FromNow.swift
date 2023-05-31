import Foundation

fileprivate let calendar = Calendar.autoupdatingCurrent

extension Date {
  static var oneHourFromNow: Self {
    calendar.date(bySetting: .nanosecond, value: 0, of: calendar.date(byAdding: .hour, value: 1, to: .now)!)!
  }

  static var oneMinuteFromNow: Self {
    calendar.date(bySetting: .nanosecond, value: 0, of: calendar.date(byAdding: .minute, value: 1, to: .now)!)!
  }

  static var twoSecondsFromNow: Self {
    calendar.date(bySetting: .nanosecond, value: 0, of: calendar.date(byAdding: .second, value: 2, to: .now)!)!
  }

  static var fiveSecondsFromNow: Self {
    calendar.date(bySetting: .nanosecond, value: 0, of: calendar.date(byAdding: .second, value: 5, to: .now)!)!
  }
}
