import SwiftUI

struct DetailsView: View {
  var countdown: Countdown
  
  @State private var editSheetIsPresented = false
  
  var body: some View {
    ZStack(alignment: .bottom) {
      CountdownProgressView(countdown: countdown)
      
      HStack {
        Button(action: { editSheetIsPresented = true }) {
          Image(systemName: "pencil")
        }
        .buttonStyle(.circular())
        
        Spacer()
      }
      .padding(.bottom, -18)
      .padding(.horizontal, 9)
    }
    .sheet(isPresented: $editSheetIsPresented) {
      NavigationView {
        EditForm(countdown: countdown)
      }
    }
  }
}
