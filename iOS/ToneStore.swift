import SwiftUI
import StoreKit
import Introspect

struct ToneStoreProduct: Identifiable {
  let id = UUID()
  var title: String
  var artist: String
  var price: Double
}

struct ToneStoreProductListItem: View {
  let index: Int
  let product: ToneStoreProduct
  
  @State var isBuying = false
  
  var body: some View {
    NavigationLink(destination: ToneStoreProductView(product: product)) {
      HStack {
        Text(String(index + 1))
          .font(.title)
          .frame(width: 22, alignment: .center)
        
        Text("")
          .frame(width: 44, height: 44)
          .border(.mint)
          .padding(.horizontal )
        
        VStack(alignment: .leading) {
          Text(product.title)
            .font(.headline)
          
          Text(product.artist)
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        
        if isBuying {
          Spacer()
          ToneStoreProgressView()
        } else {
          Spacer()
          Button("10,00 kr", action: { isBuying = true })
            .buttonStyle(.buy)
        }
      }
    }
    .padding(.vertical, 5)
    .padding(.trailing, 8)
    .menuIndicator(.hidden)
    .foregroundStyle(.primary)
    .listRowBackground(Color.clear)
    .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: -16))
//    .introspectTableViewCell {
//      $0.
//    }
  }
}

struct ToneStoreProgressView: View {
  var body: some View {
    Circle()
      .trim(from: 0, to: 0.9)
//      .size(width: 26, height: 26)
      .stroke(Color.accentColor, lineWidth: 2)
      .rotationEffect(.degrees(360))
//      .animation(Animation.linear.repeatForever(autoreverses: false))
      .animation(.linear.repeatForever(autoreverses: false), value: 360)
      .frame(width: 26, height: 26)
  }
}

struct ToneStoreProductView: View {
  let product: ToneStoreProduct
  
  var body: some View {
    List {
      Text("…")
    }
    .listStyle(.plain)
    
    .safeAreaInset(edge: .top) {
      VStack(alignment: .leading) {
        Text(product.title)
          .font(.title)
        
        Text(product.artist)
          .font(.title2)
          .foregroundStyle(.secondary)
        
        Spacer()
        
        HStack {
          Group {
            Image(systemName: "star.fill")
            Image(systemName: "star.fill")
            Image(systemName: "star.fill")
            Image(systemName: "star.fill")
            Image(systemName: "star")
          }
          .padding(.horizontal, -5)
          .foregroundColor(.orange)
          
          Text("(5)")
            .foregroundStyle(.secondary)
        }
        .font(.footnote)
//        .symbolRenderingMode(.multicolor)
      }
      .frame(maxWidth: .infinity, maxHeight: 120)
      .padding(15)
    }
  }
}

struct ToneStoreView: View {
  let products = [
    ToneStoreProduct(title: "Xmas", artist: "free-mobi.org", price: 10.00),
    ToneStoreProduct(title: "River Meditation", artist: "Jason Shaw", price: 10.00),
  ]
  
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    List {
      ForEach(0..<products.count, id: \.self) { index in
        ToneStoreProductListItem(index: index, product: products[index])
      }
    }
    .listStyle(.plain)
    .accentColor(.blue)
    .tint(.accentColor)
    .navigationTitle("Tone Store")
    .navigationBarTitleDisplayMode(.inline)
    .introspectViewController { $0.navigationItem.backButtonTitle = NSLocalizedString("Back", comment: "") }
    .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done", action: { dismiss() }) } }
  }
}

struct ToneStoreView_Previews: PreviewProvider {
  static var previews: some View {
    ToneStoreView()
  }
}
