import ClockKit
import SwiftUI

extension CLKComplicationTemplate {
  static func graphicExtraLarge(_ countdown: Countdown, _ date: Date) -> CLKComplicationTemplate {
    CLKComplicationTemplateGraphicExtraLargeCircularView(
      CountdownProgressView(countdown: countdown, style: .complication)
    )
  }
}

struct GraphicExtraLarge_Previews: PreviewProvider {
  static var previews: some View {
    ForEach(previewDevices) { device in
      CLKComplicationTemplate.graphicExtraLarge(.complicationPreview, previewDate)
        .previewContext()
        .previewDevice(device)
        .previewLayout(.sizeThatFits)
    }
  }
}
