import ClockKit
import SwiftUI

extension CLKComplicationTemplate {
  static func utilitarianSmall(_ countdown: Countdown, _ date: Date) -> CLKComplicationTemplate {
    CLKComplicationTemplateUtilitarianSmallFlat(
      textProvider: .countdown(countdown, date),
      imageProvider: .smallSemiboldCountdownSymbol
    )
  }
}

struct UtilitarianSmall_Previews: PreviewProvider {
  static var previews: some View {
    ForEach(previewDevices) { device in
      CLKComplicationTemplate.utilitarianSmall(.complicationPreview, previewDate)
        .previewContext()
        .previewDevice(device)
        .previewLayout(.sizeThatFits)
    }
  }
}
