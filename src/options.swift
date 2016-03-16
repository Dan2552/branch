class Options {
  static let sharedInstance = Options()

  var isVerbose = false
  var isShowVersion = false
  var suppliedBranch: String?
  var isBranchSupplied: Bool { return suppliedBranch != nil }
  var isHelp = false
  var isTestRebase = false
  var isShowList = false

  func loadOptionsFrom(arguments: [String]) {
    if arguments.contains("help") || arguments.contains("--help") {
      isHelp = true
    }

    if arguments.contains("--verbose") {
      isVerbose = true
    }

    if arguments.contains("-v") || arguments.contains("--version") {
      isShowVersion = true
    }

    if arguments.contains("--test-rebase") {
      isTestRebase = true
    }

    if arguments.contains("--list") || arguments.contains("-l") {
      isShowList = true
    }

    if arguments.count > 1 {
      if !arguments[1].hasPrefix("-") {
        suppliedBranch = arguments[1]
      }
    }
  }
}
