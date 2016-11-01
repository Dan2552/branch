import Foundation

extension String {
  func matches(forRegex regex: String) -> [String] {
    let re = try! NSRegularExpression(pattern: regex, options: [.caseInsensitive])
    let range = NSRange(location: 0, length: self.utf16.count)
    let matches = re.matches(in: self, options: [], range: range)
    var results = [String]()

    for match in matches as [NSTextCheckingResult] {
      // range at index 0: full match
      // range at index 1: first capture group
      let firstCaptureGroup = match.rangeAt(1)
      let sub = (self as NSString).substring(with: firstCaptureGroup)
      results.append(sub)
    }

    return results
  }

  func clearQuotes() -> String {
    return replacingOccurrences(of: "\"",
                                with: "",
                                options: .literal,
                                range: nil)
  }
}
