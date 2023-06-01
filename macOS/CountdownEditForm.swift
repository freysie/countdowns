import SwiftUI
import Introspect

// TODO: use nested managed object contexts
struct CountdownEditForm: View {
  @State var countdown: _Countdown
  var onComplete: (_Countdown) -> ()
  
//  init(countdown: Countdown) {
//    self.countdown = countdown
//    editContext.parent = viewContext
//  }
//
//  private var editContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
  @Environment(\.dismiss) private var dismiss
  //@Environment(\.managedObjectContext) private var viewContext

  var body: some View {
    Form {
      Section {
        //TextField("\(Text("Label")):", text: .init($countdown.label)!, prompt: Text("Label"))
        TextField("\(Text("Label")):", text: $countdown.label, prompt: Text(""))
        // FIXME:
        // .focused($labelIsFocused)
        // .onAppear { labelIsFocused = true }
        DatePicker("\(Text("Target")):", selection: $countdown.target)
      }
      
      Section {
        Picker("\(Text("Repeat")):", selection: $countdown.repeat) {
          ForEach(RepeatMode.allCases) {
            Text(LocalizedStringKey($0.rawValue.capitalized))
              .tag($0)
          }
        }

        Picker("\(Text("Sound")):", selection: $countdown.tone) {
          ForEach(Tone.allCases) {
            Text(LocalizedStringKey($0.rawValue.titleCased))
              .tag($0)
          }
        }
        .onChange(of: countdown.tone) {
          $0.playPreview()
        }
      }
    }
    .padding(20)
    .fixedSize()
    //.navigationTitle(countdown.managedObjectContext == nil ? "Add Countdown" : "Edit Countdown")
    .toolbar {
      ToolbarItemGroup(placement: .cancellationAction) {
        Button("Cancel", role: .cancel, action: cancel)
      }
      
      ToolbarItemGroup(placement: .confirmationAction) {
        Button("Save", action: save)
          //.disabled(countdown.managedObjectContext != nil && !countdown.isUpdated)
      }
    }
    .onDisappear {
      Tone.stopPreview()
    }
  }
  
  private func cancel() {
    dismiss()
  }
  
  private func save() {
    onComplete(countdown)
    dismiss()
  }
}
