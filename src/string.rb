class String
  # def matches(forRegex regex: String)
  #   let re = try! NSRegularExpression.new(pattern: regex, options: [.caseInsensitive])
  #   let range = NSRange.new(location: 0, length: self.utf16.count)
  #   let matches = re.matches(in: self, options: [], range: range)
  #   var results = [] # [String]

  #   for match in matches as [NSTextCheckingResult] {
  #     # range at index 0: full match
  #     # range at index 1: first capture group
  #     let firstCaptureGroup = match.rangeAt(1)
  #     let sub = (self as NSString).substring(with: firstCaptureGroup)
  #     results.append(sub)
  #   end

  #   return results
  # end

  def matches(forRegex:)
    lines = split("\n")
    lines.map { |l| l.match(forRegex)&.captures }.flatten.compact
  end

  def clearQuotes
    gsub("\"", with: "")
  end
end
