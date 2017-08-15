class Branch < SwiftStruct
  let name = nil

  def origin
    return "origin/#{name}"
  end
end

def get_current_branch
  let result = runCommand("git symbolic-ref HEAD")
  let matches = result.stdout.matches(forRegex: "heads\\/(.*)")
  if matches.count == 0
    return nil
  else
    return Branch.new(name: matches[0])
  end
end

def setCurrentBranch(branch)
  prettyPrint("Switching to branch #{branch.name.s.Bold}...")
  fetch
  detectChanges
  resetLocal
  switchBranch(branch)
  detectAhead
  resetToOrigin
end

def detectChanges
  let status = Git.status
  if status.contains("to be committed") || status.contains("for commit:") || status.contains("Untracked files:")
    uncommitedChanges
  end
end

def resetLocal
  runCommand("git reset --hard")
end

def switchBranch(branch)
  runCommand("git checkout #{branch.name}")

  if get_current_branch.name != branch.name
    runCommand("git checkout -b #{branch.name}")
  end

  runCommand("git branch --set-upstream-to=origin/#{branch.name}")

  if get_current_branch.name != branch.name
    prettyPrint("🤔  Failed to switch branch".f.Red)
    exit(1)
  end
end

def detectAhead
  let status = Git.status
  if status.contains("can be fast-forwarded.") || status.contains("is ahead of 'origin") || status.contains(" have diverged")
    branchesDiverged
  end
end

# On branch master
# Your branch and 'origin/master' have diverged,
# and have 1 and 1 different commit each, respectively.
#   (use "git pull" to merge the remote branch into yours)
# nothing to commit, working directory clean
#
# On branch master
# Your branch is behind 'origin/master' by 1 commit, and can be fast-forwarded.
#   (use "git pull" to update your local branch)
# nothing to commit, working directory clean
#
# On branch master
# Your branch is ahead of 'origin/master' by 1 commit.
#   (use "git push" to publish your local commits)
# nothing to commit, working directory clean
def branchesDiverged
  prettyPrint("\n😱  You appear to have a diverged branch:".f.Red)
  let matches = Git.status.matches(forRegex: "(Your branch .*\\s*.*)")

  matches.each do |match|
    prettyPrint(match)
  end

  promptKeepLocal
end

def resetToOrigin
  let origin = get_current_branch.origin
  let reset = runCommand("git reset --hard #{origin}")

  if reset.exitStatus == 0
    prettyPrint("Using remote branch".f.Green)
  else
    prettyPrint("Using local branch (no origin branch found)".f.Green)
  end
end

def print_current_branch
  let branchName = (get_current_branch && get_current_branch.name) || "no branch"
  prettyPrint("On branch #{branchName.s.Bold}")
end

def printRecentBranches
  let command = runCommand("git for-each-ref --sort=-committerdate --format=\"%(refname)\" --count=30 refs/heads/ refs/remotes")
  let references = command.stdout.components(separatedBy: "\n")

  commits = references.map do |r|
    Commit.new(message: "", sha: r.clearQuotes)
  end

  strings = commits.map do |c|
    c.printableFormat("%Cgreen%cr%Creset %C(yellow)%d%Creset %C(bold blue)<%an>%Creset%n")
  end
  var lastStr = ""
  strings.each do |str|
    if str != lastStr
      prettyPrint(str) # avoid dups
    end
    lastStr = str
  end
end

def choose_branch
  let command = runCommand("git for-each-ref --sort=-committerdate --format=\"%(refname)\" --count=30 refs/heads/ refs/remotes")
  let references = command.stdout.components(separatedBy: "\n")

  commits = references.map { |r| Commit.new(message: "", sha: r.clearQuotes) }

  branches = commits.map do |c|
    c.printableFormat("%D")
     .gsub("origin/HEAD", "")
     .gsub(/HEAD -> (.*)/, '\1')
     .split(",")
     .map(&:split)
     .select { |str| (str.send(:length) || 0) > 0 }
     .join(", ")
  end

  branches_and_commits = {}
  commits.each.with_index do |c, i|
    let branch = branches[i].gsub("origin/", "")
    let commit = c.printableFormat("%Cgreen%cr%Creset %C(yellow)%d%Creset %C(bold blue)<%an>%Creset%n")

    branches_and_commits[branch] ||= []
    branches_and_commits[branch] << commit
  end

  branch_options = []
  max_key = branches_and_commits.keys.map(&:length).max
  options = branches_and_commits.keys.map do |branch|
    branch_options << branch
    commits = branches_and_commits[branch]

    spacing = ' ' * (max_key - branch.length + 2)
    "#{branch}#{spacing}#{commits.uniq.join("\n  #{' ' * branch.length}#{spacing}")}"
  end

  begin
    response = Ask.list "Choose a branch", options
  rescue Interrupt
    exit(1)
  end

  chosen_branch = branch_options[response]
    .split(", ")
    .sort_by { |str| str.start_with?("origin/") ? 0 : 1 }
    .first
    .gsub("origin/", "")

  prettyPrint("")
  setCurrentBranch(Branch.new(name: chosen_branch))
end

def uncommitedChanges
  prettyPrint("\n😱  You appear to have uncommited changes:".f.Red)
  print_uncommited_files
  promptContinueAnyway
end

def print_branch_status
  print_current_branch
  print_commits_behind_and_ahead_of_origin
  print_uncommited_files
end

def print_commits_behind_and_ahead_of_origin
  let branch = get_current_branch

  let behind = Git.log("--oneline HEAD..#{branch.origin}").split("\n")
  if behind.count > 0
    prettyPrint("")
    prettyPrint("#{behind.count} commits behind origin")
    behind.each do |commit|
      prettyPrint("  #{commit}".f.Purple)
    end
  end

  let ahead = Git.log("--oneline #{branch.origin}..HEAD").split("\n")
  if ahead.count > 0
    prettyPrint("")
    prettyPrint("#{ahead.count} commits ahead of origin")
    ahead.each do |commit|
      prettyPrint("  #{commit}".f.Blue)
    end
  end
end

def print_uncommited_files
  let diff = Git.status.matches(forRegex: "\t([a-z ]*:.*)")

  if diff.count > 0
    prettyPrint("")
    prettyPrint("#{diff.count} uncommited changed files")
    diff.each do |line|
      prettyPrint("  #{line}".f.Green)
    end
  end
end

def promptContinueAnyway
  prettyPrint("")

  response = Ask.list "Continue anyway? Changes will be lost", [
    "Stop",
    "Continue"
  ]

  exit(1) if response == 0
end

def promptKeepLocal
  let choice: String
  let options = Options.sharedInstance

  if options.preferLocal
    choice = "local"
  elsif options.preferRemote
    choice = "remote"
  else
    puts ""
    response = Ask.list "Keep remote or local copy?", [
      "Remote",
      "Local"
    ]

    choice = "remote" if response == 0
    choice = "local" if response == 1
  end

  if choice != "remote"
    prettyPrint("Using local branch (user specified)")
    exit(0)
  end
end

def addAll
  Git.reset_mixed
  Git.add_all
end

def fetch
  let fetch = runCommand("git fetch")
  let error = fetch.stderr
  if error.contains("No remote repository specified")
    prettyPrint("\n⚠️  No remote repository is setup\n".f.Yellow)
    return
  end
  if fetch.exitStatus != 0
    prettyPrint("\n🤔  Failed to fetch.".f.Red)
    exit(1)
  end
end
