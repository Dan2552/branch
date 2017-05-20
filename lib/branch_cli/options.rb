class Options < Swifty
  def self.sharedInstance
    @sharedInstance ||= Options.new
  end

  def self.reset
    @sharedInstance = nil
  end

  var isVerbose = false
  var isShowVersion = false
  var suppliedBranch = nil
  var isHelp = false
  var isTestRebase = false
  var isShowList = false
  var preferLocal = false
  var preferRemote = false

  swift self, binding

  def isBranchSupplied
    return suppliedBranch != nil
  end

  def loadOptions(arguments:)
    if arguments.contains("help") || arguments.contains("--help")
      self.isHelp = true
    end

    if arguments.contains("--verbose")
      self.isVerbose = true
    end

    if arguments.contains("-v") || arguments.contains("--version")
      self.isShowVersion = true
    end

    if arguments.contains("--test-rebase")
      self.isTestRebase = true
    end

    if arguments.contains("--list") || arguments.contains("-l")
      self.isShowList = true
    end

    if arguments.contains("--prefer=local")
      self.preferLocal = true
    end

    if arguments.contains("--prefer=remote")
      self.preferRemote = true
    end

    if arguments.count > 0
      if !arguments[0].hasPrefix("-")
        self.suppliedBranch = arguments[0]
      end
    end
  end
end
