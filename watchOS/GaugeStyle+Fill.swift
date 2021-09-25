import SwiftUI

extension GaugeStyle where Self == FillGaugeStyle {
  static var fill: Self { .init() }
}

struct FillGaugeStyle: GaugeStyle {
  func makeBody(configuration: Configuration) -> some View {
    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        RoundedRectangle(cornerRadius: 6)
          .frame(height: 12)
          .foregroundColor(.accentColor)
          .opacity(0.35)
        
        RoundedRectangle(cornerRadius: 6)
          .frame(height: 12)
          .frame(width: configuration.value * geometry.size.width)
          .foregroundColor(.accentColor)
      }
    }
  }
}
