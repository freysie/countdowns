import CoreData

extension Countdown {
  func progress(relativeTo date: Date) -> Double {
    guard let effectiveSource = effectiveSource, let target = target else { return 0 }
    
    let relativeDate = isTakingScreenshots ? previewDate : date
    guard target > relativeDate else { return 1 }
    
    // TODO: fix off-by-one error
    let span = effectiveSource.distance(to: target) - 1
    return abs(effectiveSource.timeIntervalSince(relativeDate)) / span
  }
}
