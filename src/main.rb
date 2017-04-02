let options = Options.sharedInstance
options.loadOptions(arguments: ARGV)

if options.isShowVersion
  prettyPrint("branch 0.4.0")
  exit(0)
end

if options.isShowList
  printRecentBranches
  exit(0)
end

if options.isHelp
  prettyPrint("usage: branch BRANCH-NAME [ARGS]")
  prettyPrint("")
  prettyPrint("--version | -v \tShows the current version")
  prettyPrint("--verbose \t\tPrints all the git commands as they run")
  prettyPrint("--list | -l \t\tPrints the most recently updated branches")
  prettyPrint("--prefer=PREFERENCE \tWhere PREFERENCE is local or remote, will use the set preference rather than ask")
  prettyPrint("--help | help \tShows this help")
  exit(0)
end

addAll

if options.isBranchSupplied
  setCurrentBranch(Branch.new(name: options.suppliedBranch))
else
  printCurrentBranch
  printGitStatus(preceedingNewline: true)
end
