import ClockKit
import SwiftUI

extension CLKComplicationTemplate {
  enum CountdownGraphicRectangularStyle { case timer, stopwatch }
  
  static func graphicRectangular(
    _ countdown: Countdown,
    _ date: Date,
    _ style: CountdownGraphicRectangularStyle
  ) -> CLKComplicationTemplate {
    CLKComplicationTemplateGraphicRectangularFullView(
      VStack(alignment: .leading) {
        Group {
          Label {
            Text(countdown.label.nilIfEmpty ?? NSLocalizedString("Countdown", comment: ""))
              .font(.system(.title3, design: .rounded).weight(.bold).monospacedDigit())
            // .font(.system(size: 18, weight: .bold, design: .rounded).monospacedDigit())
            // .kerning(-0.1)
              .complicationForeground()
          } icon: {
            Image(decorative: "countdown")
              .font(.body.weight(.semibold))
              .imageScale(.small)
              .padding(.leading, -2)
            // .padding(.horizontal, -2)
              .padding(.top, -2)
          }
          .foregroundColor(.accentColor)
          
          switch style {
          case .timer:
            Group {
              Text(CountdownFormatter.string(for: countdown, relativeTo: date))
                .font(.system(size: 17.5, weight: .medium, design: .rounded).monospacedDigit())
              
              Gauge(value: countdown.progress(relativeTo: date)) {
                Text("Time Remaining")
              }
              .tint(.orange)
              .gaugeStyle(.fill)
              .padding(.bottom, 10)
            }
          case .stopwatch:
            Text(CountdownFormatter.string(for: countdown, relativeTo: date))
              .font(.system(size: 42.5, weight: .semibold, design: .rounded).monospacedDigit())
              .padding(.horizontal, -1)
              .minimumScaleFactor(0.5)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)
      }
    )
  }
}

struct GraphicRectangular_Previews: PreviewProvider {
  static var previews: some View {
    ForEach(previewDevices) { device in
      Group {
        CLKComplicationTemplate.graphicRectangular(.complicationPreview, previewDate, .timer).previewContext()
        CLKComplicationTemplate.graphicRectangular(.complicationPreview, previewDate, .stopwatch).previewContext()
      }
      .previewDevice(device)
      .previewLayout(.sizeThatFits)
    }
  }
}

//    case .graphicRectangular:
//      return .init(date: date, complicationTemplate: CLKComplicationTemplateGraphicRectangularTextGaugeView(
//        headerLabel: Label {
//          Text("ddddddd")
////          Text(countdown.label.nilIfEmpty ?? NSLocalizedString("Countdown", comment: ""))
////            .monospacedDigit()
////            .fontWeight(.semibold)
////            .foregroundColor(.accentColor)
//            .complicationForeground()
//        } icon: {
//          Image(decorative: "countdown")
//            .font(.body.weight(.semibold))
//            .imageScale(.small)
//            .symbolRenderingMode(.multicolor)
//        }
//          .foregroundColor(.accentColor),
//        headerTextProvider: CLKSimpleTextProvider(text: countdown.label.nilIfEmpty ?? NSLocalizedString("Countdown", comment: "")),
//        bodyTextProvider: CLKSimpleTextProvider(text: CountdownFormatter.string(for: countdown, relativeTo: date)),
//        gaugeProvider: CLKSimpleGaugeProvider(
//          style: .fill,
//          gaugeColor: .orange,
//          fillFraction: 1 - Float(countdown.progress(relativeTo: date))
//        )
//      ))
      
//      return .init(date: date, complicationTemplate: CLKComplicationTemplateGraphicExtraLargeCircularClosedGaugeText(
//        gaugeProvider: CLKSimpleGaugeProvider(
//          style: .fill,
//          gaugeColor: .orange,
//          fillFraction: 1 - Float(countdown.progress(relativeTo: date))
//        ),
//        centerTextProvider: CLKSimpleTextProvider(text: NumberFormatter.localizedString(
//          from: countdown.progress(relativeTo: date) * 100 as NSNumber,
//          number: .none
//        ))
//      ))
