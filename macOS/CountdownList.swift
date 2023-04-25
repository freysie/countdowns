import SwiftUI
import CoreData

struct CountdownList: View {
  @Environment(\.managedObjectContext) private var viewContext
  @EnvironmentObject private var store: Store

  @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Countdown.target, ascending: true)])
  private var countdowns: FetchedResults<Countdown>
    
  @AppStorage("addSheetIsPresented") private var addSheetIsPresented = false
  @AppStorage("allowsDeleteInListView") private var allowsDelete = false
  
  var body: some View {
    List {
      if allowsDelete {
        ForEach(store.countdowns) { CountdownListItem(countdown: $0) }
        .onDelete(perform: deleteItems)
      } else {
        ForEach(store.countdowns) { CountdownListItem(countdown: $0) }
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
      CountdownEditForm(countdown: _Countdown(label: "")) {
        store.add(countdown: $0)
      }
    }
//    if @available(macOS 13, *) {
//      .contextMenu(forSelectionType: Any.self) { _ in EmptyView() } primaryAction: { print($0) }
//    }
  }
  
  private func deleteItems(offsets: IndexSet) {
//    withAnimation {
//      offsets.map { store.countdowns[$0] }.forEach(viewContext.delete)
//
//      do {
//        try viewContext.save()
//      } catch {
//        let nsError = error as NSError
//        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//      }
//    }
  }
}
