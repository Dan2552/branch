import Foundation

class Rebase {
  let newBase: Commit
  let oldHead: Commit

  private let commits: [Commit]
  private var progress = 0

  init(newBase: Commit, oldHead: Commit) {
    self.newBase = newBase
    self.oldHead = oldHead

    let commonAncestor = oldHead.mostRecentCommonAncestorTo(newBase)
    commits = commonAncestor.commitsLeadingTo(oldHead)
  }

  func apply() {
    if commits.count == 0 {
      print("Nothing to do.")
      return
    }

    if progress > commits.count {
      print("Done!")
      return
    }

    printProgress()
    progress += 1
    apply()
  }

  private func printProgress() {
    let commit = commits[progress]
    print("applying: \(commit.message) (\(commit.sha))...")

    printOnLine("  ")
    for i in 0..<commits.count {
      if i == progress {
        printOnLine("o".f.Cyan)
      } else {
        printOnLine("o".f.Blue)
      }

      if i != commits.count - 1 {
        printOnLine("-".f.Blue)
      }
    }

    print("")
  }

}
