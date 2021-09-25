import SwiftUI
import StoreKit
import MediaPlayer
//import AVFoundation

let toneStoreIsEnabled = false
let songSelectionIsEnabled = false

struct SoundPicker: View {
  @ObservedObject var countdown: Countdown
  
  @State private var recentSongs = [MPMediaItem]()
  
  @State private var toneStoreIsPresented = false
  @State private var mediaPickerIsPresented = false
  
//  @State private var songPlayer: AVPlayer!
//  @State private var songPlayer: MPMediaPlayer
  
  var body: some View {
    List {
      if toneStoreIsEnabled {
        Section(LocalizedStringKey("Store")) {
          Button("Tone Store", action: { toneStoreIsPresented = true })
            .onAppear {
              print(SKPaymentQueue.canMakePayments())
            }
        }
      }
      
      if toneStoreIsEnabled || songSelectionIsEnabled {
        Section(LocalizedStringKey("Tones")) {
          tones
        }
      } else {
        tones
      }
      
      if songSelectionIsEnabled {
        Section {
          songs
          chooseASong
        } header: {
          Text("Songs")
        } footer: {
          Text("The song will play when Countdowns is in the foreground.")
            .opacity(countdown.song != nil ? 1 : 0)
        }
      }
    }
    .navigationTitle("Sound")
    .onChange(of: countdown.tone) { $0.playPreview() }
    .onDisappear { Tone.stopPreview() }
    .fullScreenCover(isPresented: $toneStoreIsPresented) {
      NavigationView { ToneStoreView() }
    }
    .mediaPicker(isPresented: $mediaPickerIsPresented, mediaTypes: .music) { collection in
      print(collection)
      if let item = collection.representativeItem {
//        item.isCloudItem
        print(item)
        print(item.title as Any)
        print(item.artist as Any)
        recentSongs.append(item)
        countdown.song = item
        
        let player = MPMusicPlayerController.applicationMusicPlayer
        
        player.nowPlayingItem = item
        player.prepareToPlay { error in
          print(error as Any)
          if error == nil { player.play() }
        }
        
//        songPlayer = AVPlayer(url: assetURL)
//        songPlayer.play()
      }
    }
  }
  
  func binding(for tone: Tone) -> Binding<Bool> {
    Binding {
      countdown.tone == tone
    } set: { _ in
      countdown.objectWillChange.send()
      countdown.tone = tone
    }
  }
  
  var tones: some View {
    ForEach(Tone.allCases) { tone in
      Text(LocalizedStringKey(tone.rawValue.titleCased))
        .listItemChecked(
          binding(for: tone),
          edge: songSelectionIsEnabled ? .leading : .trailing
        )
    }
  }
  
  func binding(for song: MPMediaItem?) -> Binding<Bool> {
    Binding {
      countdown.song == song
    } set: { _ in
      countdown.objectWillChange.send()
      countdown.song = song
    }
  }
  
  @ViewBuilder var songs: some View {
    Text("None")
      .listItemChecked(binding(for: nil), edge: .leading)
    
    if let song = countdown.song {
      Text(song.title ?? "")
        .listItemChecked(binding(for: song), edge: .leading)
    }
  }
  
  var chooseASong: some View {
    HStack {
      Text("Choose a Song")
#if targetEnvironment(simulator)
        .foregroundStyle(.tertiary)
#endif
      
      Spacer()
      NavigationLink.empty
    }
    .listItemChecked(Binding { false } set: { _ in mediaPickerIsPresented = true }, edge: .leading)
#if targetEnvironment(simulator)
    .disabled(true)
#endif
  }
}
