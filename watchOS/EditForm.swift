import SwiftUI

struct EditForm: View {
  @ObservedObject var countdown: Countdown
  
  @State private var deleteConfirmationIsPresented = false
  
  @Environment(\.dismiss) private var dismiss
  @Environment(\.managedObjectContext) private var viewContext
  
  var body: some View {
    Form {
      Section {
        TextField("Label", text: .init($countdown.label)!)
        
        // TODO: implement watchOS date picker
        Button(action: {}) {
          Text("Target")
          Text("1/1/21, 12:00 AM")
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        
        Picker("Repeat", selection: $countdown.repeat) {
          ForEach(RepeatMode.allCases) {
            Text(LocalizedStringKey($0.rawValue.capitalized))
              .tag($0)
          }
        }
        
        Picker("Sound", selection: $countdown.tone) {
          ForEach(Tone.allCases) {
            Text(LocalizedStringKey($0.rawValue.titleCased))
              .tag($0)
          }
        }
      } footer: {
        if countdown.tone != .none {
          Text("Sound will be played on iPhone.")
            .padding(.top, 1)
        }
      }
      
      Section { EmptyView() }
      
      Section {
        Button(role: .destructive, action: { deleteConfirmationIsPresented = true }) {
          Text("Delete")
            .frame(maxWidth: .infinity)
        }
      }
    }
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button("Save", action: save)
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
