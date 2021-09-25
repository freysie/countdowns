import SwiftUI

struct CountdownListItem: View {
  var countdown: Countdown
  
  var body: some View {
    TimelineView(.countdown) { schedule in
      VStack(alignment: .leading) {
        Text(CountdownFormatter.string(for: countdown, relativeTo: schedule.date))
          .font(.title2)
          .monospacedDigit()
          .lineLimit(1)
          .minimumScaleFactor(0.5)
          .foregroundStyle(countdown.timeRemaining(relativeTo: schedule.date) > 1 ? .primary : .tertiary)
        
        Text(countdown.label ?? NSLocalizedString("Countdown", comment: ""))
          .foregroundColor(countdown.timeRemaining(relativeTo: schedule.date) > 1 ? .secondary : .accentColor)
      }
    }
  }
}
