import CoreData
import MediaPlayer

#if os(iOS)

extension Countdown {
  var song: MPMediaItem? {
    get {
      guard let songID = songID else { return nil }
      
      let query = MPMediaQuery()
      query.addFilterPredicate(MPMediaPropertyPredicate(
        value: songID,
        forProperty: MPMediaItemPropertyAlbumPersistentID,
        comparisonType: .equalTo
      ))
      
      return query.items?.first
    }
    
    set {
      if let newValue = newValue {
        songID = newValue.persistentID as NSNumber
      } else {
        songID = nil
      }
    }
  }
}

#endif
