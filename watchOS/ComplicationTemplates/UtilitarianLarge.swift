import ClockKit
import SwiftUI

extension CLKComplicationTemplate {
  static func utilitarianLarge(_ countdown: Countdown, _ date: Date, alwaysOn: Bool) -> CLKComplicationTemplate {
    CLKComplicationTemplateUtilitarianLargeFlat(
      textProvider: .countdown(countdown, date, alwaysOn),
      imageProvider: .smallSemiboldCountdownSymbol
    )
  }
}

struct UtilitarianLarge_Previews: PreviewProvider {
  static var previews: some View {
    ForEach(previewDevices) { device in
      CLKComplicationTemplate.utilitarianLarge(.complicationPreview, previewDate, alwaysOn: false)
        .previewContext()
        .previewDevice(device)
        .previewLayout(.sizeThatFits)
    }
  }
}
