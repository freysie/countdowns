import SwiftUI
import WatchDatePicker

struct EditForm: View {
  @ObservedObject var countdown: Countdown
  
  @State private var deleteConfirmationIsPresented = false
  
  @Environment(\.dismiss) private var dismiss
  @Environment(\.managedObjectContext) private var viewContext
  
  var body: some View {
    NavigationView {
      Form {
        Section {
          TextField("Label", text: .init($countdown.label)!)
        }

        Section {
          DatePicker(LocalizedStringKey("Target"), selection: Binding { countdown.target ?? Date() } set: { countdown.target = $0 }, in: Date()...)
          
          // FIXME: why is this `objectWillChange.send()` needed?!
          Picker("Repeat", selection: Binding { countdown.repeat } set: { countdown.objectWillChange.send(); countdown.repeat = $0 }) {
            ForEach(RepeatMode.allCases) {
              Text(LocalizedStringKey($0.rawValue.capitalized))
                .tag($0)
            }
          }
          
          // TODO: reenable this when sync works:
          // Picker("Sound", selection: $countdown.tone) {
          //   ForEach(Tone.allCases) {
          //     Text(LocalizedStringKey($0.rawValue.titleCased))
          //       .tag($0)
          //   }
          // }
        // } footer: {
          // if countdown.tone != .none {
          //   Text("Sound will be played on iPhone.")
          //     .padding(.top, 1)
          // }
        }
        
        if countdown.managedObjectContext != nil {
          Section { EmptyView() }
          
          Section {
            Button(role: .destructive, action: { deleteConfirmationIsPresented = true }) {
              Text("Delete")
                .frame(maxWidth: .infinity)
            }
          }
        }
      }
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel", action: cancel)
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save", action: save)
        }
      }
    }
    .confirmationDialog(
      "Are you sure you want to delete this countdown?",
      isPresented: $deleteConfirmationIsPresented,
      titleVisibility: .visible
    ) {
      Button("Delete Countdown", role: .destructive, action: delete)
      Button("Cancel", role: .cancel, action: { deleteConfirmationIsPresented = false })
    }
  }
  
  private func delete() {
    viewContext.delete(countdown)
    dismiss()
  }
  
  private func cancel() {
    viewContext.rollback()
    dismiss()
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

struct EditForm_Previews: PreviewProvider {
  static var previews: some View {
    ForEach(previewDevices) { device in
      NavigationView {
        EditForm(countdown: Countdown())
      }
      .previewDevice(device)
      .previewDisplayName(device.rawValue.components(separatedBy: " - ").last!)
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
