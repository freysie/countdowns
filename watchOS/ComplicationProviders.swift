import ClockKit
import Dynamic

extension CLKTextProvider {
  class func countdown(_ countdown: Countdown, _ date: Date, _ alwaysOn: Bool = false) -> CLKTextProvider {
    let relativeDate = isTakingScreenshots ? previewDate : nil
    if alwaysOn {
      return CLKRelativeDateTextProvider(
        date: countdown.target!,
        relativeTo: relativeDate,
        style: .timer,
        units: [.hour, .minute, .second]
      )
    } else {
      let wantsSubseconds = false
      let relativeTimeInterval = countdown.target!.timeIntervalSince(relativeDate ?? Date())
      let targetDays = Int(relativeTimeInterval / (60 * 60 * 24))
      let targetDate = Calendar.current.date(byAdding: .day, value: -targetDays, to: countdown.target!)!
      let relativeDateTextProvider = CLKRelativeDateTextProvider(
        date: targetDate,
        relativeTo: relativeDate,
        style: .timer,
        units: [.hour, .minute, .second]
      )
      if permitsUsageOfPrivateAPIs {
        Dynamic(relativeDateTextProvider).wantsSubseconds = wantsSubseconds
      }
      let remainderHours = abs((relativeTimeInterval / (60 * 60)).remainder(dividingBy: 24))
      let hourZeroPadding = remainderHours < 10 && !wantsSubseconds ? "0" : ""
      print("remainderHours = \(remainderHours)")
      let timeSeparator = DateComponentsFormatter()
        .string(from: DateComponents(minute: 10, second: 10))!
        .replacingOccurrences(of: "10", with: "")
      let textProvider = CLKSimpleTextProvider(
        format: "\(targetDays)\(timeSeparator)\(hourZeroPadding)%@",
        relativeDateTextProvider
      )
      textProvider.tintColor = .init(.accentColor)
      textProvider.tintColor = .init(.pink)
      return textProvider
    }
  }
  
  class func countdownProgress(_ countdown: Countdown, _ date: Date) -> CLKSimpleTextProvider {
    .init(text: NumberFormatter.localizedString(
      from: countdown.progress(relativeTo: date) * 100 as NSNumber,
      number: .none
    ))
  }
  
  class func countdownProgressPercent(_ countdown: Countdown, _ date: Date) -> CLKSimpleTextProvider {
    .init(text: NumberFormatter.localizedString(
      from: countdown.progress(relativeTo: date) as NSNumber,
      number: .percent
    ))
  }
}

extension CLKGaugeProvider {
  class func countdownRing(_ countdown: Countdown, _ date: Date) -> CLKSimpleGaugeProvider {
    .init(
      style: .fill,
      gaugeColor: .init(.accentColor),
      fillFraction: 1 - Float(countdown.progress(relativeTo: date))
    )
  }
}

extension CLKImageProvider {
  class var smallSemiboldCountdownSymbol: CLKImageProvider {
    let image = UIImage(named: "countdown")!
      .applyingSymbolConfiguration(.init(pointSize: 0, weight: .semibold, scale: .small))!
    
    let imageProvider = CLKImageProvider(onePieceImage: image)
    imageProvider.tintColor = .init(.accentColor)
    return imageProvider
  }
  
  class var mediumCountdownSymbol: CLKImageProvider {
    let image = UIImage(named: "countdown")!
      .applyingSymbolConfiguration(.init(pointSize: 0, weight: .regular, scale: .medium))!
    
    let imageProvider = CLKImageProvider(onePieceImage: image)
    imageProvider.tintColor = .init(.accentColor)
    return imageProvider
  }
}

extension CLKFullColorImageProvider {
  class var mediumCountdownSymbol: CLKFullColorImageProvider {
    let image = UIImage(named: "countdown")!
      .applyingSymbolConfiguration(.init(pointSize: 0, weight: .regular, scale: .medium))!
      .applyingSymbolConfiguration(.init(paletteColors: [.init(.accentColor)]))!
    
    return CLKFullColorImageProvider(fullColorImage: image, tintedImageProvider: .mediumCountdownSymbol)
  }
}
