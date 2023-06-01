import Foundation

struct _Countdown: Identifiable, Codable {
  var id = UUID()
  var label: String
  var source = Date()
  var target = Date.oneHourFromNow
  var `repeat` = RepeatMode.never
  var tone = Tone.none
  var songID: Int64?
  var shownInMenuBar = false

  var effectiveLabel: String {
    label.nilIfEmpty ?? NSLocalizedString("Countdown", comment: "")
  }

  var effectiveSource: Date? {
    guard `repeat` != .never else { return source }
    return Calendar.current.date(byAdding: `repeat`.dateComponents, to: target)
  }

  var timeRemaining: TimeInterval { timeRemaining(relativeTo: .now) }

  func timeRemaining(relativeTo date: Date) -> TimeInterval {
    target.timeIntervalSince(isTakingScreenshots ? previewDate : date)
  }

  func progress(relativeTo date: Date) -> Double {
    let effectiveSource = effectiveSource ?? source

    let relativeDate = isTakingScreenshots ? previewDate : date
    guard target > relativeDate else { return 1 }

    // TODO: fix off-by-one error
    let span = effectiveSource.distance(to: target) - 1
    return abs(effectiveSource.timeIntervalSince(relativeDate)) / span
  }
}

extension _Countdown: CustomStringConvertible {
  var description: String {
    "\(Self.self)(\(CountdownFormatter.string(from: timeRemaining, showsSign: true)) - \(effectiveLabel))"
  }
}


#if !os(macOS)
import MediaPlayer
extension _Countdown {
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
