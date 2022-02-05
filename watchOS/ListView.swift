import SwiftUI

struct ListView: View {
  @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Countdown.target, ascending: true)])
  private var countdowns: FetchedResults<Countdown>
  
  @AppStorage("selectedCountdown") private var selectedCountdown: String?
  @AppStorage("addSheetIsPresented") private var addSheetIsPresented = false
  @AppStorage("allowsDeleteInListView") private var allowsDelete = false
  
  var body: some View {
    List(countdowns) { countdown in
      NavigationLink(destination: DetailsView(countdown: countdown)) {
        CountdownListItem(countdown: countdown)
      }
    }
    .navigationTitle("Countdowns")
    .overlay {
      ForEach(countdowns) { countdown in
        NavigationLink(tag: countdown.uuidString, selection: $selectedCountdown) {
          DetailsView(countdown: countdown)
        } label: {
          EmptyView()
        }
      }
      .opacity(0)
    }
    .toolbar {
      Button(action: { addSheetIsPresented = true }) {
        Text("Add Countdown")
          .font(.body.weight(.semibold))
          .foregroundColor(.black)
      }
      .padding(.bottom, 15)
    }
    .sheet(isPresented: $addSheetIsPresented) {
      // PersistenceController.shared.container.newBackgroundContext() ?
      EditForm(countdown: Countdown(entity: Countdown.entity(), insertInto: nil))
    }
  }
}
