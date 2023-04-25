extension String {
  var titleCased: String {
    replacingOccurrences(of: "([A-Z])", with: " $1", options: .regularExpression)
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .capitalized
  }
}
