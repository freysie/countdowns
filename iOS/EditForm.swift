import SwiftUI
import Introspect

// TODO: use nested managed object contexts?
struct EditForm: View {
  @ObservedObject var countdown: Countdown
  
//  @FocusState private var labelIsFocused
  @State private var deleteConfirmationIsPresented = false
  @State private var labelTextField: UITextField?
  
  @Environment(\.dismiss) private var dismiss
  @Environment(\.managedObjectContext) private var viewContext
  
  var body: some View {
    print(Self._printChanges())
    return Form {
      TextField("", text: .init($countdown.label)!, prompt: Text("Label"))
      // FIXME:
        .padding(.trailing, -5)
      // .padding(.trailing, -9)
      // .focused($labelIsFocused)
      // .onAppear { labelIsFocused = true }
        .onSubmit { countdown.objectWillChange.send() }
        .introspectTextField {
          guard labelTextField == nil else { return }
          labelTextField = $0
          
          $0.clearButtonMode = .whileEditing
          if countdown.managedObjectContext == nil {
            $0.becomeFirstResponder()
          }
        }
      
      Section {
        Group {
          DatePicker("Target", selection: .init($countdown.target)!)
            .onSubmit { countdown.objectWillChange.send() }
          
          NavigationLink(destination: RepeatModePicker(countdown: countdown)) {
            ValueListItem("Repeat", value: LocalizedStringKey(countdown.repeat.rawValue.capitalized))
          }
          
          NavigationLink(destination: SoundPicker(countdown: countdown)) {
            ValueListItem("Sound", value: LocalizedStringKey(countdown.tone.rawValue.titleCased))
          }
        }
        // FIXME:
        .padding(.trailing, -4)
        // .padding(.horizontal, -4)
        // .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
      }
      
      if countdown.managedObjectContext != nil {
        Section {
          Button("Delete Countdown", role: .destructive, action: { deleteConfirmationIsPresented = true })
            .frame(maxWidth: .infinity, alignment: .center)
        }
      }
    }
    .introspectViewController { $0.navigationItem.backButtonTitle = NSLocalizedString("Back", comment: "") }
    .navigationTitle(countdown.managedObjectContext == nil ? "Add Countdown" : "Edit Countdown")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItemGroup(placement: .cancellationAction) {
        Button("Cancel", role: .cancel, action: cancel)
      }
      
      ToolbarItemGroup(placement: .confirmationAction) {
        Button("Save", action: save)
          .disabled(countdown.managedObjectContext != nil && !countdown.isUpdated)
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

  private func delete() {
    viewContext.delete(countdown)
    dismiss()
  }
}

//extension Binding {
//  static func forPicker<SelectionValue: Hashable>(_ selection: Binding<SelectionValue>, _ option: SelectionValue) {
//    return Binding { selection == option } set: { _ in selection = option }
//  }
//}
