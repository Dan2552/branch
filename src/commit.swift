import Swiftline

struct Commit {
  let message: String
  let sha: String

  static func getCurrentHead() -> Commit {
    return Commit.fromSha(nameFor("HEAD"))
  }

  static func fromSha(sha: String) -> Commit {
    let message = runCommand("git log -1 \(sha) --format=\"%s\"").stdout
    return Commit(
      message: message,
      sha: sha
    )
  }

  func commitsLeadingTo(commit: Commit) -> [Commit] {
    let shas = runCommand("git rev-list \(sha)..\(commit.sha) --reverse")
    var commits = [Commit]()

    return commits
  }

  func mostRecentCommonAncestorTo(commit: Commit) -> Commit {
    let mergeBase = runCommand("git merge-base \(sha) \(commit.sha)").stdout
    return Commit.fromSha(mergeBase)
  }

  private static func nameFor(sha: String) -> String {
    return runCommand("git log -1 \(sha) --format=\"%H\"").stdout
  }
}
