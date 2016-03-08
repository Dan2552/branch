import Foundation
import Swiftline

struct Commit {
  var message: String
  var sha: String

  init(message: String, sha: String) {
    self.message = message.clearQuotes()
    self.sha = sha.clearQuotes()
  }

  static func getCurrentHead() -> Commit {
    return Commit.fromIdentifier("HEAD")
  }

  static func fromIdentifier(identifier: String) -> Commit {
    return Commit(
      message: messageFor(identifier),
      sha: shaFor(identifier)
    )
  }

  func commitsLeadingTo(commit: Commit) -> [Commit] {
    let run = runCommand("git rev-list \(sha)..\(commit.sha) --reverse").stdout
    var commits = [Commit]()
    let shas = run.componentsSeparatedByString("\n")
    for sha in shas {
      commits.append(Commit.fromIdentifier(sha))
    }
    return commits
  }

  func mostRecentCommonAncestorTo(commit: Commit) -> Commit {
    let mergeBase = runCommand("git merge-base \(sha) \(commit.sha)").stdout
    return Commit.fromIdentifier(mergeBase)
  }

  private static func shaFor(identifier: String) -> String {
    return runCommand("git log -1 \(identifier) --format=\"%H\"").stdout
  }

  private static func messageFor(identifier: String) -> String {
    return runCommand("git log -1 \(identifier) --format=\"%s\"").stdout
  }
}
