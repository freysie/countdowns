import SwiftUI

struct ValueListItem<Title: View, Value: View>: View {
  @ViewBuilder var title: Title
  @ViewBuilder var value: Value
  
  var body: some View {
    HStack {
      title
      
      Spacer()
      
      value
        .foregroundStyle(.secondary)
    }
  }
}

extension ValueListItem where Title == Text {
//  init(_ title: String, value: () -> Value) {
//    self.init { Text(title) } value: { value() }
//  }
  
  init(_ title: LocalizedStringKey, value: () -> Value) {
    self.init { Text(title) } value: { value() }
  }
}

extension ValueListItem where Title == Text, Value == Text {
//  init(_ title: String, value: String) {
//    self.init { Text(title) } value: { Text(value) }
//  }
//
//  init(_ title: String, value: LocalizedStringKey) {
//    self.init { Text(title) } value: { Text(value) }
//  }
  
//  init(_ title: LocalizedStringKey, value: String) {
//    self.init { Text(title) } value: { Text(value) }
//  }
  
  init(_ title: LocalizedStringKey, value: LocalizedStringKey) {
    self.init { Text(title) } value: { Text(value) }
  }
}

struct ValueListItem_Previews: PreviewProvider {
  static var previews: some View {
    List {
      ValueListItem("Repeat", value: "Daily")
      
      ValueListItem("Repeat") {
        Label("Daily", systemImage: "cloud.sun.rain.fill")
      }
      
      ValueListItem {
        Label("Repeat", systemImage: "repeat")
      } value: {
        Label("Daily", systemImage: "cloud.sun.rain.fill")
          .symbolRenderingMode(.multicolor)
      }
    }
  }
}
