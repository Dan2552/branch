import Foundation

extension String {
  func matchesForRegex(regex: String) -> [String] {
    let re = try! NSRegularExpression(pattern: regex, options: [.CaseInsensitive])
    let matches = re.matchesInString(self, options: [], range: NSRange(location: 0, length: self.utf16.count))
    var results = [String]()

    for match in matches as [NSTextCheckingResult] {
      // range at index 0: full match
      // range at index 1: first capture group
      let substring = (self as NSString).substringWithRange(match.rangeAtIndex(1))
      results.append(substring)
    }

    return results
  }

  func clearQuotes() -> String {
    return stringByReplacingOccurrencesOfString("\"",
      withString: "",
      options: NSStringCompareOptions.LiteralSearch,
      range: nil)
  }
}

extension NSString {
  func matchesForRegex(regex: String) -> [String] {
    return (self as String).matchesForRegex(regex)
  }
}
