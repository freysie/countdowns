import SwiftUI
import CoreData

struct ListView: View {
  @Environment(\.managedObjectContext) private var viewContext
  
  @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Countdown.target, ascending: true)])
  private var countdowns: FetchedResults<Countdown>
    
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
    .frame(minWidth: 200)
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button(action: { addSheetIsPresented = true }) {
          Label("Add Countdown", systemImage: "plus")
            .imageScale(.large)
        }
      }
    }
    .sheet(isPresented: $addSheetIsPresented) {
      EditForm(countdown: Countdown())
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
