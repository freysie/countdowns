import SwiftUI
import Introspect

// TODO: use nested managed object contexts
struct EditForm: View {
  @ObservedObject var countdown: Countdown
  
//  init(countdown: Countdown) {
//    self.countdown = countdown
//    editContext.parent = viewContext
//  }
//
//  private var editContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
  @Environment(\.dismiss) private var dismiss
  @Environment(\.managedObjectContext) private var viewContext

  var body: some View {
    Form {
      TextField("\(Text("Label")):", text: .init($countdown.label)!, prompt: Text("Label"))
      // FIXME:
      // .focused($labelIsFocused)
      // .onAppear { labelIsFocused = true }
        .onSubmit { countdown.objectWillChange.send() }
      
      Section {
        Group {
          DatePicker("\(Text("Target")):", selection: .init($countdown.target)!)
            .onSubmit { countdown.objectWillChange.send() }
          
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
    }
    .padding()
    //.navigationTitle(countdown.managedObjectContext == nil ? "Add Countdown" : "Edit Countdown")
    .toolbar {
      ToolbarItemGroup(placement: .cancellationAction) {
        Button("Cancel", role: .cancel, action: { dismiss() })
      }
      
      ToolbarItemGroup(placement: .confirmationAction) {
        Button("Save", action: save)
          .disabled(countdown.managedObjectContext != nil && !countdown.isUpdated)
      }
    }
    .onDisappear {
      Tone.stopPreview()
    }
  }
  
  private func save() {
    countdown.objectWillChange.send()
    
    if countdown.managedObjectContext == nil {
      viewContext.insert(countdown)
    }
    
    do {
      try viewContext.save()
      dismiss()
    } catch {
      let nsError = error as NSError
      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
  }
}
