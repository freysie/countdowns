import SwiftUI

extension ButtonStyle where Self == CircularButtonStyle {
  static func circular(_ color: Color = .buttonBackground) -> Self { .init(color: color) }
}

struct CircularButtonStyle: ButtonStyle {
  var color: Color

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.body.weight(.black))
      .frame(width: 34, height: 34)
      .scaleEffect(configuration.isPressed ? 0.9 : 1)
      .foregroundColor(color == .buttonBackground ? .primary : color)
      .background { Circle().fill(color.opacity(color == .buttonBackground ? 1 : 0.3)) }
  }
}

extension Color {
  static let buttonBackground = Color(white: 0.103)
}
