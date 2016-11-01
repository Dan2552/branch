import Foundation

let options = Options.sharedInstance
options.loadOptions(fromArguments: CommandLine.arguments)

if options.isShowVersion {
  print("branch 0.3.0")
  exit(0)
}

if options.isShowList {
  printRecentBranches()
  exit(0)
}

if options.isHelp {
  print("usage: branch BRANCH-NAME [ARGS]")
  print("")
  print("--version | -v \t\tShows the current version")
  print("--verbose \t\tPrints all the git commands as they run")
  print("--list | -l \t\tPrints the most recently updated branches")
  print("--prefer=PREFERENCE \tWhere PREFERENCE is local or remote, will use the set preference rather than ask")
  print("--help | help \t\tShows this help")
  exit(0)
}

addAll()

if options.isBranchSupplied {
  setCurrentBranch(Branch(name: options.suppliedBranch!))
} else {
  printCurrentBranch()
  printGitStatus(preceedingNewline: true)
}

if options.isTestRebase {
  let rebase = Rebase(
    newBase: Commit.from(identifier: "develop"),
    oldHead: Commit.getCurrentHead()
  )

  rebase.apply()
}
