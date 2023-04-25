import SwiftUI
import CoreData

struct CountdownList: View {
  @Environment(\.managedObjectContext) private var viewContext
  
  @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Countdown.target, ascending: true)])
  private var countdowns: FetchedResults<Countdown>
    
  @State private var editedCountdown: Countdown?
  @AppStorage("addSheetIsPresented") private var addSheetIsPresented = false
  @AppStorage("allowsDeleteInListView") private var allowsDelete = false
  
  var body: some View {
    List {
      if allowsDelete {
        ForEach(countdowns) { CountdownListItem(countdown: $0) }
          .onDelete(perform: deleteItems)
      } else {
        ForEach(countdowns) { CountdownListItem(countdown: $0) }
      }
    }
    .listStyle(.plain)
    .navigationTitle("Countdowns")
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        if allowsDelete { EditButton() }
      }
      
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: { addSheetIsPresented = true }) {
          Label("Add Countdown", systemImage: "plus")
        }
      }
    }
    .sheet(item: $editedCountdown) { countdown in
      NavigationView { CountdownEditForm(countdown: countdown) }
    }
    .sheet(isPresented: $addSheetIsPresented) {
      NavigationView { CountdownEditForm(countdown: Countdown()) }
    }
  }
  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      offsets.map { countdowns[$0] }.forEach(viewContext.delete)
      
      do {
        try viewContext.save()
      } catch {
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
      }
    }
  }
}
