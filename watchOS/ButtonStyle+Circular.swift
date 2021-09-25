import SwiftUI

extension ButtonStyle where Self == CircularButtonStyle {
  static var circular: Self { .init() }
}

struct CircularButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.body.weight(.black))
      .frame(width: 34, height: 34)
      .scaleEffect(configuration.isPressed ? 0.9 : 1)
      .background { Circle().fill(Color.buttonBackground) }
  }
}

extension Color {
  static var buttonBackground: Self { .init(white: 0.103) }
}
