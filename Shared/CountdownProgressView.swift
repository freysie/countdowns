import SwiftUI

// FIXME: consider breaking this out into three distinct structs, one for each platform
struct CountdownProgressView: View {
#if os(iOS) || os(macOS)
  static var defaultLineWidth: Double { 8 }
#elseif os(watchOS)
  static var defaultLineWidth: Double { 4 }
#endif

  static var complicationLineWidth: Double { 13 }

  enum Style { case `default`, complication }
  
  var countdown: Countdown
  var style = Style.default
  
  var lineWidth: Double {
    switch style {
    case .`default`: return Self.defaultLineWidth
    case .complication: return Self.complicationLineWidth
    }
  }
  
  var trackColor: Color {
    switch style {
    case .`default`: return Color(white: 0.1)
    case .complication: return Color.orange.opacity(0.5)
//    case .complication: return Color(uiColor: .orange.withAlphaComponent(0.5))
    }
  }
  
  var body: some View {
    TimelineView(.countdown) { schedule in
      ZStack {
        Circle()
          .stroke(trackColor, lineWidth: lineWidth)
        
        Circle()
          .trim(from: 0, to: 1 - countdown.progress(relativeTo: schedule.date))
          .stroke(Color.orange, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
      }
      .rotationEffect(.degrees(-90))
      .overlay {
#if os(iOS) || os(macOS)
        VStack(spacing: 10) {
          timeRemaining(relativeTo: schedule.date)
          label(relativeTo: schedule.date)
        }
        .padding(.horizontal, 20)
#elseif os(watchOS)
        VStack(spacing: 0) {
          label(relativeTo: schedule.date)
          timeRemaining(relativeTo: schedule.date)
        }
        .padding(.horizontal, 30)
#endif
      }
    }
#if os(iOS)
    .padding()
    .padding(.bottom, 100)
#elseif os(watchOS)
    .padding(.vertical, 5)
#endif
  }
  
  func timeRemaining(relativeTo date: Date) -> some View {
    Text(CountdownFormatter.string(for: countdown, relativeTo: date))
#if os(iOS) || os(macOS)
      .font(.system(size: 64, weight: .thin))
#elseif os(watchOS)
      .font(style == .complication ? .body : .system(size: 24, weight: .medium))
#endif
      .monospacedDigit()
      .lineLimit(1)
      .minimumScaleFactor(0.5)
      .foregroundStyle(countdown.timeRemaining(relativeTo: date) > 1 ? .primary : .tertiary)
  }
  
  func label(relativeTo date: Date) -> some View {
    Text(countdown.label ?? NSLocalizedString("Countdown", comment: ""))
//    Text("\(countdown.progress.relativeTo(date))")
#if os(iOS) || os(macOS)
      .font(.system(size: 21))
      .lineLimit(3)
#elseif os(watchOS)
      .font(style == .complication ? .caption : .body)
      .lineLimit(style == .complication ? 1 : 2)
      .minimumScaleFactor(0.25)
#endif
      .foregroundColor(countdown.timeRemaining(relativeTo: date) > 1 ? .secondary : .accentColor)
      .multilineTextAlignment(.center)
  }
}
