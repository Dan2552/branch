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
    return Commit.from(identifier: "HEAD")
  }

  static func from(identifier: String) -> Commit {
    return Commit(
      message: message(forIdentifier: identifier),
      sha: sha(forIdentifier: identifier)
    )
  }

  func commitsLeading(toCommit commit: Commit) -> [Commit] {
    let run = runCommand("git rev-list \(sha)..\(commit.sha) --reverse").stdout
    var commits = [Commit]()
    let shas = run.components(separatedBy: "\n")
    for sha in shas {
      commits.append(Commit.from(identifier: sha))
    }
    return commits
  }

  func mostRecentCommonAncestor(toCommit commit: Commit) -> Commit {
    let mergeBase = runCommand("git merge-base \(sha) \(commit.sha)").stdout
    return Commit.from(identifier: mergeBase)
  }

  func printableFormat(_ format: String) -> String {
    let command = runCommand("git", args: [
      "log",
      "-n1",
      sha,
      "--format=\(format)"
    ])
    return command.stdout
  }

  private static func sha(forIdentifier identifier: String) -> String {
    return runCommand("git log -1 \(identifier) --format=\"%H\"").stdout
  }

  private static func message(forIdentifier identifier: String) -> String {
    return runCommand("git log -1 \(identifier) --format=\"%s\"").stdout
  }
}
