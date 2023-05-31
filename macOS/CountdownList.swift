import SwiftUI
import CoreData

extension UUID: RawRepresentable {
  public var rawValue: String { uuidString }
  public init?(rawValue: String) { self.init(uuidString: rawValue) }
}

struct CountdownList: View {
  //@Environment(\.managedObjectContext) private var viewContext
  @EnvironmentObject private var countdownStore: CountdownStore

  //@FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Countdown.target, ascending: true)])
  //private var countdowns: FetchedResults<Countdown>
    
  @State private var selection: _Countdown.ID?
  @AppStorage("addSheetIsPresented") private var addSheetIsPresented = false
  @AppStorage("allowsDeleteInListView") private var allowsDelete = false
  
  var body: some View {
    List(selection: $selection) {
      if allowsDelete {
        ForEach(countdownStore.countdowns) { CountdownListItem(countdown: $0) }
          .onDelete(perform: deleteItems)
      } else {
        ForEach(countdownStore.countdowns) { CountdownListItem(countdown: $0) }
      }
    }
    .frame(minWidth: 200)
    .toolbar {
      Spacer()
      Button(action: { addSheetIsPresented = true }) {
        Label("Add Countdown", systemImage: "plus")
          .imageScale(.large)
      }
    }
    .sheet(isPresented: $addSheetIsPresented) {
      CountdownEditForm(countdown: _Countdown(label: "")) {
        countdownStore.add($0)
      }
    }
//    if @available(macOS 13, *) {
//      .contextMenu(forSelectionType: Any.self) { _ in EmptyView() } primaryAction: { print($0) }
//    }
  }
  
  private func deleteItems(offsets: IndexSet) {
    //countdownStore.delete(countdownWithID: <#T##UUID#>)
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
