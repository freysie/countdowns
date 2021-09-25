import ClockKit
import SwiftUI

extension CLKComplicationTemplate {
  static func circularSmall(_ countdown: Countdown, _ date: Date) -> CLKComplicationTemplate {
    CLKComplicationTemplateCircularSmallRingText(
      textProvider: .countdownProgress(countdown, date),
      fillFraction: 1 - Float(countdown.progress(relativeTo: date)),
      ringStyle: .closed
    )
  }
}

struct CircularSmall_Previews: PreviewProvider {
  static var previews: some View {
    ForEach(previewDevices) { device in
      CLKComplicationTemplate.circularSmall(.complicationPreview, previewDate)
        .previewContext()
        .previewDevice(device)
        .previewLayout(.sizeThatFits)
    }
  }
}
