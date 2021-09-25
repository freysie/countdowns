import ClockKit
import SwiftUI

extension CLKComplicationTemplate {
  static func graphicBezel(_ countdown: Countdown, _ date: Date) -> CLKComplicationTemplate {
    CLKComplicationTemplateGraphicBezelCircularText(
      circularTemplate: CLKComplicationTemplateGraphicCircularClosedGaugeText(
        gaugeProvider: .countdownRing(countdown, date),
        centerTextProvider: .countdownProgress(countdown, date)
      ),
      textProvider: .countdown(countdown, date)
    )
  }
}

struct GraphicBezel_Previews: PreviewProvider {
  static var previews: some View {
    ForEach(previewDevices) { device in
      CLKComplicationTemplate.graphicBezel(.complicationPreview, previewDate)
        .previewContext()
        .previewDevice(device)
        .previewLayout(.sizeThatFits)
    }
  }
}
