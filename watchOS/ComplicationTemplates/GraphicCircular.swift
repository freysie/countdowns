import ClockKit
import SwiftUI

extension CLKComplicationTemplate {
  static func graphicCircular(_ countdown: Countdown, _ date: Date) -> CLKComplicationTemplate {
    CLKComplicationTemplateGraphicCircularClosedGaugeText(
      gaugeProvider: .countdownRing(countdown, date),
      centerTextProvider: .countdownProgress(countdown, date)
    )
  }
}

struct GraphicCircular_Previews: PreviewProvider {
  static var previews: some View {
    ForEach(previewDevices) { device in
      CLKComplicationTemplate.graphicCircular(.complicationPreview, previewDate)
        .previewContext()
        .previewDevice(device)
        .previewLayout(.sizeThatFits)
    }
  }
}
