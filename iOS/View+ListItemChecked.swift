import SwiftUI
import Introspect

public extension View {
  func listItemChecked(_ checked: Binding<Bool>, edge: ListItemChecked.Edge = .trailing) -> some View {
    modifier(ListItemChecked(checked: checked, edge: edge))
  }
}

public struct ListItemChecked: ViewModifier {
  public enum Edge { case leading, trailing }
  
  @Binding public var checked: Bool
  public var edge: Edge
  
  public func body(content: Content) -> some View {
    return CheckmarkListItem(isChecked: $checked, edge: edge) { content }
  }
}

struct CheckmarkListItem<Title: View>: View {
  static var leadingCheckmarkWidth: Double { 36 }
  
  @Binding var isChecked: Bool
  var edge: ListItemChecked.Edge
  @ViewBuilder var title: Title
  
  @State private var tableView: UITableView?
  
  var body: some View {
    Button(action: { isChecked.toggle(); setListRowSeparatorInsets() }) {
      HStack {
        if edge == .leading {
          Image(systemName: "checkmark")
            .font(.body.weight(.semibold))
            .opacity(isChecked ? 1 : 0)
            .frame(width: Self.leadingCheckmarkWidth)
            .padding(.leading, -Self.leadingCheckmarkWidth / 3)
        }
        
        title.foregroundColor(.primary)
        
        if edge == .trailing && isChecked {
          Spacer()
          Image(systemName: "checkmark")
        }
      }
    }
    .listRowInsets(.init(
      top: 0,
      leading: edge == .leading ? Self.leadingCheckmarkWidth * 2 / 3 : 20,
      bottom: 0,
      trailing: 20
    ))
    .introspectTableView { tableView = $0; setListRowSeparatorInsets() }
    .onAppear { setListRowSeparatorInsets() }
  }
  
  func setListRowSeparatorInsets() {
    for cell in tableView?.visibleCells ?? [] {
      cell.separatorInset = .init(
        top: 0,
        left: edge == .leading ? Self.leadingCheckmarkWidth : 0,
        bottom: 0,
        right: 0
      )
    }
  }
}
