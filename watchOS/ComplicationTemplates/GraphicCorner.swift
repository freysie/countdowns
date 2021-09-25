import ClockKit
import SwiftUI

extension CLKComplicationTemplate {
  static func graphicCorner(_ countdown: Countdown, _ date: Date) -> CLKComplicationTemplate {
    CLKComplicationTemplateGraphicCornerGaugeImage(
      gaugeProvider: .countdownRing(countdown, date),
      leadingTextProvider: .countdown(countdown, date),
      trailingTextProvider: nil,
      imageProvider: .mediumCountdownSymbol
    )
  }
}

struct GraphicCorner_Previews: PreviewProvider {
  static var previews: some View {
    ForEach(previewDevices) { device in
      ForEach(previewFaceColors) { color in
        CLKComplicationTemplate.graphicCorner(.complicationPreview, previewDate)
          .previewContext(faceColor: color)
          .previewDevice(device)
          .previewLayout(.sizeThatFits)
      }
    }
  }
}
