import SwiftUI

private let fractionDigits = 0
private let showsNegativeSign = false
private let animatesFractionSecondsInScreenshots = true

// TODO: rework this to support custom display styles
class CountdownFormatter {
  class func string(for countdown: Countdown, relativeTo date: Date, maximumUnitCount: Int? = nil) -> String {
    let relativeDate = isTakingScreenshots ? previewDate : date
    return string(from: countdown.target?.timeIntervalSince(relativeDate) ?? 0, maximumUnitCount: maximumUnitCount)
  }

  class func string(for countdown: _Countdown, relativeTo date: Date, maximumUnitCount: Int? = nil) -> String {
    let relativeDate = isTakingScreenshots ? previewDate : date
    return string(from: countdown.target.timeIntervalSince(relativeDate), maximumUnitCount: maximumUnitCount)
  }

  class func string(from ti: TimeInterval, maximumUnitCount: Int? = nil, locale: Locale? = nil) -> String {
    let componentsFormatter = DateComponentsFormatter()
    componentsFormatter.calendar!.locale = locale
    componentsFormatter.unitsStyle = .positional
    
    let daySymbol = componentsFormatter
      .string(from: DateComponents(day: 1))!
      .replacingOccurrences(of: "1", with: "")
      .trimmingCharacters(in: .whitespaces)
    
    let daysSymbol = componentsFormatter
      .string(from: DateComponents(day: 2))!
      .replacingOccurrences(of: "2", with: "")
      .trimmingCharacters(in: .whitespaces)
    
    let timeSeparator = componentsFormatter
      .string(from: DateComponents(minute: 10, second: 10))!
      .replacingOccurrences(of: "10", with: "")
    
    let fractionSeparator = timeSeparator == ":" ? "." : "′"
    
    let formatter = DateComponentsFormatter()
    formatter.calendar!.locale = locale
    formatter.unitsStyle = .positional
    formatter.allowedUnits = [.day, .hour, .minute, .second]
//    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.maximumUnitCount = maximumUnitCount ?? 4
    // formatter.collapsesLargestUnit = false
    formatter.zeroFormattingBehavior = .pad
    
    let fractionFormatter = NumberFormatter()
    fractionFormatter.minimumIntegerDigits = fractionDigits
    fractionFormatter.maximumFractionDigits = 0
    
    let fti = isTakingScreenshots && animatesFractionSecondsInScreenshots ? Date().timeIntervalSince1970 : ti
    
    var fractionSeconds = (abs(fti).remainder(dividingBy: 1) * pow(10, Double(fractionDigits))).rounded(.down)
    if fractionSeconds < 0 { fractionSeconds += pow(10, Double(fractionDigits)) }
    let formattedFraction = fractionFormatter.string(from: fractionSeconds as NSNumber)!
    
    return (ti < 0 && showsNegativeSign ? "-" : "") + formatter
      .string(from: ti)!
      .replacingOccurrences(of: "\(daySymbol) ", with: timeSeparator)
      .replacingOccurrences(of: "\(daysSymbol) ", with: timeSeparator)
      .replacingOccurrences(of: " \(timeSeparator)", with: timeSeparator)
      .replacingOccurrences(of: "\(timeSeparator)-", with: timeSeparator)
      .appending(fractionDigits == 0 ? "" : "\(fractionSeparator)\(formattedFraction)")
  }
}

struct CountdownFormatter_Previews: PreviewProvider {
  static var previews: some View {
    VStack(alignment: .leading) {
      ForEach(supportedLocaleIdentifiers, id: \.self) {
        Text("\($0): " + CountdownFormatter.string(from: 1031624.55, locale: Locale(identifier: $0)))
      }
    }
    .font(.body.monospaced())
  }
}
