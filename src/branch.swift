import Swiftline
import Foundation

struct Branch {
  let name: String

  func origin() -> String {
    return "origin/\(name)"
  }
}

func getCurrentBranch() -> Branch? {
  let result = runCommand("git symbolic-ref HEAD")
  let matches = result.stdout.matchesForRegex("heads\\/(.*)")
  if matches.count == 0 {
    return nil
  } else {
    return Branch(name: matches[0])
  }
}

func setCurrentBranch(branch: Branch) {
  print("Switching to branch \(branch.name.s.Bold)...")
  fetch()
  detectChanges()
  resetLocal()
  switchBranch(branch)
  detectAhead()
  resetToOrigin()
}

func detectChanges() {
  let status = gitStatus()
  if status.containsString("to be committed") ||
      status.containsString("for commit:") ||
      status.containsString("Untracked files:") {
    uncommitedChanges()
  }
}

func resetLocal() {
  runCommand("git reset --hard")
}

func switchBranch(branch: Branch) {
  runCommand("git checkout \(branch.name)")

  if getCurrentBranch()!.name != branch.name {
    runCommand("git checkout -b \(branch.name)")
  }

  runCommand("git branch --set-upstream-to=origin/\(branch.name)")

  if getCurrentBranch()!.name != branch.name {
    print("🤔  Failed to switch branch".f.Red)
    exit(1)
  }
}

func detectAhead() {
  let status = gitStatus()
  if status.containsString("can be fast-forwarded.") ||
      status.containsString("is ahead of 'origin") ||
      status.containsString(" have diverged") {
    branchesDiverged()
  }
}

// On branch master
// Your branch and 'origin/master' have diverged,
// and have 1 and 1 different commit each, respectively.
//   (use "git pull" to merge the remote branch into yours)
// nothing to commit, working directory clean
//
// On branch master
// Your branch is behind 'origin/master' by 1 commit, and can be fast-forwarded.
//   (use "git pull" to update your local branch)
// nothing to commit, working directory clean
//
// On branch master
// Your branch is ahead of 'origin/master' by 1 commit.
//   (use "git push" to publish your local commits)
// nothing to commit, working directory clean
func branchesDiverged() {
  print("\n😱  You appear to have a diverged branch:".f.Red)
  let matches = gitStatus().matchesForRegex("(Your branch .*\\s*.*)\\s*\\(")
  for match in matches { print(match) }

  promptKeepLocal()
}

func resetToOrigin() {
  let origin = getCurrentBranch()!.origin()
  let reset = runCommand("git reset --hard \(origin)")

  if reset.exitStatus == 0 {
    print("Using remote branch".f.Green)
  } else {
    print("Using local branch (no origin branch found)".f.Green)
  }
}

func printCurrentBranch() {
  let branchName = getCurrentBranch()?.name ?? "no branch"
  print("On branch \(branchName.s.Bold)")
}

func printRecentBranches() {
  let command = runCommand("git for-each-ref --sort=-committerdate --format=\"%(refname)\" --count=30 refs/heads/ refs/remotes")
  let references = command.stdout.componentsSeparatedByString("\n")

  let commits: [Commit] = references.map {
    Commit(message: "", sha: $0.clearQuotes())
  }

  let strings = commits.map {
    $0.printableFormat("%Cgreen%cr%Creset %C(yellow)%d%Creset %C(bold blue)<%an>%Creset%n")
  }

  var lastStr = ""
  for str in strings {
    if str != lastStr { print(str) } // avoid dups
    lastStr = str
  }
}

func uncommitedChanges() {
  print("\n😱  You appear to have uncommited changes:".f.Red)
  printGitStatus()
  promptContinueAnyway()
}

func gitStatus() -> NSString {
  return runCommand("git status").stdout
}

func printGitStatus(preceedingNewline: Bool = false) {
  let diff = gitStatus().matchesForRegex("\t([a-z ]*:.*)")
  if diff.count > 0 && preceedingNewline {
    print("")
  }
  for line in diff {
    print("\t\(line)".f.Green)
  }
}

func promptContinueAnyway() {
  if !agree("\nContinue anyway? Changes will be lost\n>") {
    exit(1)
  }
}

func promptKeepLocal() {
  let choice: String

  if options.preferLocal {
    choice = "local"
  } else if options.preferRemote {
    choice = "remote"
  } else {
    choice = choose("Keep remote or local copy?\n>", type: String.self) { settings in
      settings.addChoice("remote") { "remote" }
      settings.addChoice("local") { "local" }
    }
  }
  
  if choice != "remote" {
    print("Using local branch (user specified)")
    exit(0)
  }
}

func addAll() {
  runCommand("git add . -A")
}

func fetch() {
  let fetch = runCommand("git fetch")
  let error = fetch.stderr
  if (error as NSString).containsString("No remote repository specified") {
    print("\n⚠️  No remote repository is setup\n".f.Yellow)
    return
  }
  if fetch.exitStatus != 0 {
    print("\n🤔  Failed to fetch. How's your internet connection?".f.Red)
    exit(1)
  }
}
