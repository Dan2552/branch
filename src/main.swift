import Foundation

let options = Options.sharedInstance
options.loadOptionsFrom(Process.arguments)

if options.isShowVersion {
  print("branch 0.2.0")
  exit(0)
}

if options.isHelp {
  print("usage: branch BRANCH-NAME [ARGS]")
  print("")
  print("--version | -v \t\tShows the current version")
  print("--help | help \t\tShows this help")
  exit(0)
}

addAll()

if options.isBranchSupplied {
  setCurrentBranch(Branch(name: options.suppliedBranch!))
} else {
  printCurrentBranch()
  printGitStatus(true)
}

if options.isTestRebase {
  let rebase = Rebase(
    newBase: Commit.fromIdentifier("develop"),
    oldHead: Commit.getCurrentHead()
  )

  rebase.apply()
}
