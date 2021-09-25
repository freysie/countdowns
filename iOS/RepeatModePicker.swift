import SwiftUI

struct RepeatModePicker: View {
//  @Binding var selection: RepeatMode
  @ObservedObject var countdown: Countdown

  @Environment(\.dismiss) private var dismiss
  
  func pickerBindingFor(_ option: RepeatMode) -> Binding<Bool> {
    Binding {
      countdown.repeat == option
    } set: { _ in
      countdown.objectWillChange.send()
      countdown.repeat = option
    }
  }
  
  var body: some View {
    List(RepeatMode.allCases) { mode in
      Text(LocalizedStringKey(mode.rawValue.capitalized))
        .listItemChecked(pickerBindingFor(mode))
    }
    .navigationTitle("Repeat")
    .onChange(of: countdown.repeat) { _ in dismiss() }
  }
}
