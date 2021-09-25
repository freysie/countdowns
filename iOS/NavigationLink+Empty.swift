import SwiftUI

public extension NavigationLink where Label == EmptyView, Destination == EmptyView {
  static var empty: some View {
    Self(destination: EmptyView()) { EmptyView() }.frame(width: 16)
  }
}
