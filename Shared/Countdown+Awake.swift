import CoreData

extension Countdown {
  convenience init() {
    self.init(entity: Self.entity(), insertInto: nil)
    target = Calendar.current.date(byAdding: .hour, value: 1, to: Date())
    target = Calendar.current.date(bySetting: .nanosecond, value: 0, of: target!)!
  }

  public override func awakeFromInsert() {
    id = id ?? UUID()
    source = source ?? (isTakingScreenshots ? previewDate : Date())
    target = target ?? source!.advanced(by: 600)
  }
  
  public override func awakeFromFetch() {
    target = Calendar.current.date(bySetting: .nanosecond, value: 0, of: target!)!
  }
}
