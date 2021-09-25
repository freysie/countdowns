import SwiftUI
import MusicKit
import MediaPlayer

public extension View {
  func mediaPicker(
    isPresented: Binding<Bool>,
    mediaTypes: MPMediaType,
    onCompletion: @escaping (MPMediaItemCollection) -> Void
  ) -> some View {
    fullScreenCover(isPresented: isPresented) {
      MediaPickerRepresentable(
        isPresented: isPresented,
        mediaTypes: mediaTypes,
        onCompletion: onCompletion
      )
    }
  }
}

struct MediaPickerRepresentable: UIViewControllerRepresentable {
  @Binding var isPresented: Bool
  var mediaTypes: MPMediaType
  var onCompletion: (MPMediaItemCollection) -> Void
  
  func makeUIViewController(context: Context) -> MPMediaPickerController {
    let controller = MPMediaPickerController(mediaTypes: mediaTypes)
    controller.delegate = context.coordinator
    return controller
  }
  
  func updateUIViewController(_ controller: MPMediaPickerController, context: Context) {}
  
  func makeCoordinator() -> Coordinator { .init(self) }
  
  class Coordinator: NSObject, MPMediaPickerControllerDelegate {
    let parent: MediaPickerRepresentable
    
    init(_ parent: MediaPickerRepresentable) {
      self.parent = parent
    }
    
    func mediaPicker(
      _ mediaPicker: MPMediaPickerController,
      didPickMediaItems mediaItemCollection: MPMediaItemCollection
    ) {
      parent.onCompletion(mediaItemCollection)
      parent.isPresented = false
    }
  }
}
