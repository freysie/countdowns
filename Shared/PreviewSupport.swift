import Foundation

#if !targetEnvironment(simulator)
let isTakingScreenshots = false
#else
let isTakingScreenshots = false
#endif

let previewDate = try! Date("2021-09-19T22:45:48Z", strategy: .iso8601)

let supportedLocaleIdentifiers = [
  "ar",
  "da",
  "de",
  "el",
  "en",
  "es",
  "fi",
  "fr",
  "he",
  "hi",
  "hu",
  "id",
  "it",
  "ja",
  "ko",
  "nl",
  "no",
  "pl",
  "pt",
  "ro",
  "ru",
  "sv",
  "th",
  "tr",
  "zh",
]

#if os(watchOS)

import ClockKit
import SwiftUI

let previewDevices = [
  PreviewDevice(rawValue: "Apple Watch Series 6 - 40mm"),
  PreviewDevice(rawValue: "Apple Watch Series 7 - 41mm"),
  PreviewDevice(rawValue: "Apple Watch Series 6 - 44mm"),
  PreviewDevice(rawValue: "Apple Watch Series 7 - 45mm")
]

let previewFaceColors = [
  CLKComplicationTemplate.PreviewFaceColor.multicolor,
  CLKComplicationTemplate.PreviewFaceColor.pink,
]

extension PreviewDevice: Identifiable {
  public var id: String { rawValue }
}

extension Countdown {
  static var complicationPreview: Countdown {
    let fetchRequest = Countdown.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Countdown.target, ascending: true)]
    let countdowns = try! PersistenceController.preview.container.viewContext.fetch(fetchRequest)
    return countdowns[1]
  }
}

#endif
