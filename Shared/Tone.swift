enum Tone: String, CaseIterable, Identifiable {
  case none 
  case beeps
  case bells
  case drums
  case guitar
  case rock
  case xmas
  
  var id: String { rawValue }
}

extension Countdown {
  var tone: Tone {
    get { Tone(rawValue: toneValue!)! }
    set { toneValue = newValue.rawValue }
  }
}

#if canImport(AudioToolbox)

import AudioToolbox
import UserNotifications

var previewSoundID: SystemSoundID = 0

extension Tone {
  static func stopPreview() {
    guard previewSoundID != 0 else { return }
    AudioServicesDisposeSystemSoundID(previewSoundID)
  }
  
  func playPreview() {
    Self.stopPreview()
    
    if self != .none, let url = Bundle.main.url(forResource: rawValue.capitalized, withExtension: "caf") {
      AudioServicesCreateSystemSoundID(url as CFURL, &previewSoundID)
      AudioServicesPlayAlertSound(previewSoundID)
    }
  }
}

extension Tone {
  var notificationSound: UNNotificationSound {
    .init(named: .init(rawValue.capitalized + ".caf"))
  }
}

#endif
