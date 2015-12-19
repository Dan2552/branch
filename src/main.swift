import Foundation

addAll()

if Process.arguments.count < 2 {
  printCurrentBranch()
  print("")
  printGitStatus()
  exit(0)
}

let argument = Process.arguments[1]
if argument == "--version" {
  print("branch 0.2.0")
  exit(0)
}

setCurrentBranch(Branch(name: argument))
