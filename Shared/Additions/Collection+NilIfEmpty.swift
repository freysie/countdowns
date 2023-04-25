extension Collection {
  var nilIfEmpty: Self? { isEmpty ? nil : self }
}

extension Optional where Wrapped: Collection {
  var nilIfEmpty: Wrapped? {
    guard let value = self else { return nil }
    return value.isEmpty ? nil : value
  }
}
