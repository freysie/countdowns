#if !os(macOS)

import MediaPlayer

extension _Countdown {
  var song: MPMediaItem? {
    get {
      guard let songID else { return nil }
      
      let query = MPMediaQuery()
      query.addFilterPredicate(MPMediaPropertyPredicate(
        value: songID,
        forProperty: MPMediaItemPropertyAlbumPersistentID,
        comparisonType: .equalTo
      ))
      
      return query.items?.first
    }
    
    set {
      if let newValue {
        songID = newValue.persistentID
      } else {
        songID = nil
      }
    }
  }
}

#endif
