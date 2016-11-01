// For testing run:
// ruby -e "5.times { |n| `touch a#{n}; git add --all; git commit -m "abc#{n}"`; puts n }"

import Foundation
import Swiftline

class Rebase {
  let newBase: Commit
  let oldHead: Commit

  private let commits: [Commit]
  private let commitsApplyingOn: [Commit]
  private let commonAncestor: Commit
  private var progress = 0

  init(newBase: Commit, oldHead: Commit) {
    self.newBase = newBase
    self.oldHead = oldHead

    commonAncestor = oldHead.mostRecentCommonAncestor(toCommit: newBase)
    commits = commonAncestor.commitsLeading(toCommit: oldHead)
    commitsApplyingOn = commonAncestor.commitsLeading(toCommit: newBase)
  }

  func apply() {
    print("↩ Rewinding...")
    _ = runCommand("git reset --hard \(commonAncestor.sha)")
    applyNextCommit()
  }

  private func applyNextCommit() {
    if commits.count == 0 {
      print("Nothing to do.")
      return
    }

    if progress > commits.count - 1 {
      print("Done!")
      return
    }

    printProgress()

    let commit = commits[progress]
    _ = runCommand("git cherry-pick \(commit.sha)")

    progress += 1
    applyNextCommit()
  }

  private func printProgress() {
    let commit = commits[progress]
    print("applying: \(commit.message) (\(commit.sha))...")

    printOnLine("  ")

    for i in 0..<commitsApplyingOn.count {
      printOnLine("⊙".f.Black)
      if i != commitsApplyingOn.count - 1 {
        printOnLine("-".f.Black)
      }
    }

    printOnLine("-".f.Blue)

    for i in 0..<commits.count {
      if i == progress {
        printOnLine("⊕".f.Magenta.s.Bold)
      } else {
        printOnLine("⊙".f.Blue)
      }

      if i != commits.count - 1 {
        printOnLine("-".f.Blue)
      }
    }

    print("")
  }

}
