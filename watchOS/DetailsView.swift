import SwiftUI

struct DetailsView: View {
  var countdown: Countdown
  
  @State private var editSheetIsPresented = false
  
  var body: some View {
    zStack(progressViewVisible: true, controlsVisible: true)
//    TabView {
//      zStack(progressViewVisible: false, controlsVisible: true)
//      zStack(progressViewVisible: false, controlsVisible: false)
//    }
//    .tabViewStyle(.page(indexDisplayMode: .never))
//    .overlay {
//      zStack(progressViewVisible: true, controlsVisible: false)
//        .allowsHitTesting(false)
//    }
    .sheet(isPresented: $editSheetIsPresented) {
      EditForm(countdown: countdown)
    }
  }
  
  func zStack(progressViewVisible: Bool, controlsVisible: Bool) -> some View {
    ZStack(alignment: .bottom) {
      CountdownProgressView(countdown: countdown)
        .opacity(progressViewVisible ? 1 : 0)
      
      HStack {
        Button(action: { editSheetIsPresented = true }) {
          Image(systemName: "pencil")
        }
        .buttonStyle(.circular())
        
        Spacer()
      }
      .padding(.bottom, -18)
      .padding(.horizontal, 9)
      .opacity(controlsVisible ? 1 : 0)
    }
//    .toolbar {
//      ToolbarItem(placement: .confirmationAction) {
//        //        if !controlsVisible {
//        Button("", action: {})
//          .foregroundColor(.clear)
//        //        }
//      }
//    }
  }
}
