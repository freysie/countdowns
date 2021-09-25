import SwiftUI

extension ButtonStyle where Self == BuyButtonStyle {
  static var buy: Self { .init() }
}

struct BuyButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.subheadline.weight(.semibold))
      .padding(.horizontal, 12)
      .padding(.vertical, 5)
//      .cornerRadius(5)
//      .border(.tint, width: max(1, UIScreen.main.scale / 2))
      .border(.tint)
      .foregroundColor(configuration.isPressed ? Color(.systemBackground) : .accentColor)
      .background(configuration.isPressed ? Color.accentColor : Color.clear)
      .buttonBorderShape(.capsule)
//      .cornerRadius(5)
//      .clipped()
  }
}
