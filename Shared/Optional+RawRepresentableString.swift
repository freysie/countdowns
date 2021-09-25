extension Optional: RawRepresentable where Wrapped == String {
  public init?(rawValue: String) {
    guard !rawValue.isEmpty else { return nil }
    self = rawValue
  }
  
  public var rawValue: String {
    self ?? ""
  }
}
