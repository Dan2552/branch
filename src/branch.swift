import Swiftline
import Foundation

struct Branch {
  let name: String

  func origin() -> String {
    return "origin/\(name)"
  }
}

func getCurrentBranch() -> Branch? {
  let result = run("git symbolic-ref HEAD")
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
  run("git reset --hard")
}

func switchBranch(branch: Branch) {
  let checkout = run("git checkout \(branch.name)")
  if checkout.exitStatus != 0 {
    run("git checkout -b \(branch.name)")
    run("git branch --set-upstream-to=origin/\(branch.name)")
  }

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
  let reset = run("git reset --hard \(origin)")

  if reset.exitStatus == 0 {
    print("Using remote branch")
  } else {
    print("Using local branch (no origin branch found)")
  }
}

func printCurrentBranch() {
  let branchName = getCurrentBranch()?.name ?? "no branch"
  print("On branch \(branchName.s.Bold)")
}

func uncommitedChanges() {
  print("\n😱  You appear to have uncommited changes:".f.Red)
  printGitStatus()
  promptContinueAnyway()
}

func gitStatus() -> NSString {
  return run("git status").stdout
}

func printGitStatus() {
  let diff = gitStatus().matchesForRegex("\t([a-z ]*:.*)")

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
  let choice = choose("Keep remote or local copy?\n>", type: String.self) { settings in
    settings.addChoice("remote") { "remote" }
    settings.addChoice("local") { "local" }
  }

  if choice != "remote" {
    print("Using local branch (user specified)")
    exit(0)
  }
}

func addAll() {
  run("git add . -A")
}

func fetch() {
  let fetch = run("git fetch")
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
