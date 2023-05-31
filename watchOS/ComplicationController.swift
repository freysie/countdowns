import ClockKit
import SwiftUI

enum UserActivityType: String {
  case viewing = "local.freyaalminde.countdowns.viewing"
}

enum ComplicationDescriptorIdentifier: String {
  case upNext
}

class ComplicationController: NSObject, CLKComplicationDataSource {
  // MARK: - Complication Configuration
  
  func complicationDescriptors() async -> [CLKComplicationDescriptor] {
    let fetchRequest = Countdown.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Countdown.target, ascending: true)]
    let countdowns = try! PersistenceController.shared.container.viewContext.fetch(fetchRequest)
    
    let staticDescriptors = [
      CLKComplicationDescriptor(
        identifier: ComplicationDescriptorIdentifier.upNext.rawValue,
        displayName: "Up Next",
        supportedFamilies: CLKComplicationFamily.allCases
      )
    ]
    
    let countdownDescriptors = countdowns.map { countdown in
      CLKComplicationDescriptor(
        identifier: countdown.objectID.uriRepresentation().absoluteString,
        displayName: countdown.label.nilIfEmpty ?? NSLocalizedString("Countdown", comment: ""),
        // TODO: decide exactly which complication families to support
        supportedFamilies: CLKComplicationFamily.allCases,
        userActivity: {
          let activity = NSUserActivity(activityType: UserActivityType.viewing.rawValue)
          activity.title = countdown.label.nilIfEmpty ?? NSLocalizedString("Countdown", comment: "")
          activity.userInfo = [
            "countdownID": countdown.uuidString,
            "_countdownID": countdown.id!,
            "countdownObjectID": countdown.objectID.uriRepresentation().absoluteString,
          ]
          return activity
        }()
      )
    }
    
    return staticDescriptors + countdownDescriptors
  }
  
  func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
    // TODO: do any necessary work to support these newly shared complication descriptors
  }
  
  // MARK: - Timeline Configuration
  
  func timelineEndDate(for complication: CLKComplication) async -> Date? {
    .distantFuture
  }
  
  func privacyBehavior(for complication: CLKComplication) async -> CLKComplicationPrivacyBehavior {
    .showOnLockScreen
  }
  
  func alwaysOnTemplate(for complication: CLKComplication) async -> CLKComplicationTemplate? {
    timelineEntry(for: complication, date: .thisMinute, alwaysOn: true)?.complicationTemplate
  }
  
  // MARK: - Timeline Population
  
  private func timelineEntry(for complication: CLKComplication, date: Date, alwaysOn: Bool = false) -> CLKComplicationTimelineEntry? {
    guard let userInfo = complication.userActivity?.userInfo,
          let idString = userInfo["countdownID"] as? String,
          let id = UUID(uuidString: idString),
          let countdown = try? Countdown.fetch(id: id) else { return nil }
    
    switch complication.family {
    case .circularSmall:
      return .init(date: date, complicationTemplate: .circularSmall(countdown, date))
    case .graphicBezel:
      return .init(date: date, complicationTemplate: .graphicBezel(countdown, date))
    case .graphicCircular:
      return .init(date: date, complicationTemplate: .graphicCircular(countdown, date))
    case .graphicCorner:
      return .init(date: date, complicationTemplate: .graphicCorner(countdown, date))
    case .graphicExtraLarge:
      return .init(date: date, complicationTemplate: .graphicExtraLarge(countdown, date))
    case .graphicRectangular:
      return .init(date: date, complicationTemplate: .graphicRectangular(countdown, date, .stopwatch))
    case .utilitarianLarge:
      return .init(date: date, complicationTemplate: .utilitarianLarge(countdown, date, alwaysOn: alwaysOn))
    case .utilitarianSmall:
      return .init(date: date, complicationTemplate: .utilitarianSmall(countdown, date))
    default:
      return nil
    }
  }
  
  func currentTimelineEntry(for complication: CLKComplication) async -> CLKComplicationTimelineEntry? {
    timelineEntry(for: complication, date: .thisMinute)
  }
  
  /// In order to have correct zero padding, we have a timeline entry for every minute.
  /// This could perhaps be optimized to only create entries for cases with zero padding changes, but is it worth it?
  func timelineEntries(for complication: CLKComplication, after date: Date, limit: Int) async -> [CLKComplicationTimelineEntry]? {
    // print((date.timeIntervalSinceReferenceDate, limit))

    let entries = (1..<limit).compactMap { index in
      timelineEntry(for: complication, date: date.advanced(by: TimeInterval(index * 60)))
    }

    // print(entries)
    return entries
  }
  
  // MARK: - Sample Templates
  
  func localizableSampleTemplate(for complication: CLKComplication) async -> CLKComplicationTemplate? {
    timelineEntry(for: complication, date: .thisMinute)?.complicationTemplate
  }
}

extension Date {
  static var thisMinute: Self {
    var now = Date()
    now = Calendar.current.date(bySetting: .nanosecond, value: 0, of: now)!
    now = Calendar.current.date(bySetting: .second, value: 0, of: now)!
    return now
  }
}
