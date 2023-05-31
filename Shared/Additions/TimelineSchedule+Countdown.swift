import SwiftUI

extension TimelineSchedule where Self == PeriodicTimelineSchedule {
  static var countdown: PeriodicTimelineSchedule {
    PeriodicTimelineSchedule(from: isTakingScreenshots ? previewDate : Date(), by: 1)
  }
}
