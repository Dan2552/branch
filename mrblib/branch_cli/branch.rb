module Git
  class Branch
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def origin
      "origin/#{name}"
    end
  end
end

def get_current_branch
  result = run_command("git symbolic-ref HEAD")
  matches = result.stdout.matches("heads\\/(.*)")

  if matches.count == 0
    return nil
  else
    return Git::Branch.new(matches[0])
  end
end

def set_current_branch(branch)
  pretty_print("Switching to branch #{branch.name.bold}...")
  fetch
  detect_changes
  reset_local
  switch_branch(branch)
  detect_ahead
  reset_to_origin
end

def detect_changes
  status = Git.status
  if status.include?("to be committed") || status.include?("for commit:") || status.include?("Untracked files:")
    uncommited_changes
  end
end

def reset_local
  run_command('git reset --hard')
end

def switch_branch(branch)
  run_command("git checkout #{branch.name}")

  if get_current_branch.name != branch.name
    run_command("git checkout -b #{branch.name}")
  end

  run_command("git branch --set-upstream-to=origin/#{branch.name}")

  if get_current_branch.name != branch.name
    pretty_print('🤔  Failed to switch branch'.red)
    exit(1)
  end
end

def detect_ahead
  status = Git.status
  if status.include?('can be fast-forwarded.') || status.include?("is ahead of 'origin") || status.include?(' have diverged')
    branches_diverged
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
def branches_diverged
  pretty_print("\n😱  You appear to have a diverged branch:".red)
  matches = Git.status.matches('(Your branch .*\\s*.*)')

  matches.each do |match|
    pretty_print(match)
  end

  prompt_keep_local
end

def reset_to_origin
  origin = get_current_branch.origin
  reset = run_command("git reset --hard #{origin}")

  if reset.exit_status == 0
    pretty_print('Using remote branch'.green)
  else
    pretty_print('Using local branch (no origin branch found)'.green)
  end
end

def print_current_branch
  branchName = (get_current_branch && get_current_branch.name) || 'no branch'
  pretty_print("On branch #{branchName.bold}")
end

def print_recent_branches
  command = run_command('git for-each-ref --sort=-committerdate --format="%(refname)" --count=30 refs/heads/ refs/remotes')
  references = command.stdout.split("\n")

  commits = references.map do |r|
    Commit.new('', r.clear_quotes)
  end

  strings = commits.map do |c|
    c.printable_format('%Cgreen%cr%Creset %C(yellow)%d%Creset %C(bold blue)<%an>%Creset%n')
  end

  lastStr = ''
  strings.each do |str|
    if str != lastStr
      pretty_print(str) # avoid dups
    end
    lastStr = str
  end
end

def choose_branch
  command = run_command('git for-each-ref --sort=-committerdate --format="%(refname)" --count=30 refs/heads/ refs/remotes')
  references = command.stdout.split("\n")
  commits = references.map { |r| Commit.new('', r.clear_quotes) }
  branches = commits.map do |c|
    c.printable_format("%D")
     .gsub("origin/HEAD", "")
     .gsub(/HEAD -> (.*)/, '\1')
     .split(",")
     .map { |e| e.split }
     .select { |a| (a.send(:length) || 0) > 0 }
     .map { |a| a.map { |str| str.gsub("origin/", "") } }
     .uniq
     .join(", ")
  end

  branches_and_commits = {}
  commits.each.with_index do |c, i|
    branch = branches[i]
    commit = c.printable_format('%Cgreen%cr%Creset %C(yellow)%d%Creset %C(bold blue)<%an>%Creset%n')

    branches_and_commits[branch] ||= []
    branches_and_commits[branch] << commit
  end
  branch_options = []
  max_key = branches_and_commits.keys.map { |e| e.length }.max
  options = branches_and_commits.keys.map do |branch|
    branch_options << branch
    commits = branches_and_commits[branch]

    spacing = ' ' * (max_key - branch.length + 2)
    "#{branch}#{spacing}#{commits.uniq.join("\n  #{' ' * branch.length}#{spacing}")}"
  end
  response = Ask.list('Choose a branch', options)

  chosen_branch = branch_options[response]
                    .split(', ')
                    .min_by { |str| str.start_with?('origin/') ? 0 : 1 }
                    .gsub('origin/', '')

  pretty_print('')
  set_current_branch(Git::Branch.new(chosen_branch))
end

def uncommited_changes
  pretty_print("\n😱  You appear to have uncommited changes:".red)
  print_uncommited_files
  promptContinueAnyway
end

def print_branch_status
  print_current_branch
  print_commits_behind_and_ahead_of_origin
  print_uncommited_files
end

def print_commits_behind_and_ahead_of_origin
  branch = get_current_branch

  behind = Git.log("--oneline HEAD..#{branch.origin}").split("\n")
  if behind.count > 0
    pretty_print('')
    pretty_print("#{behind.count} commits behind origin")
    behind.each do |commit|
      pretty_print("  #{commit}".Purple)
    end
  end

  ahead = Git.log("--oneline #{branch.origin}..HEAD").split("\n")
  if ahead.count > 0
    pretty_print('')
    pretty_print("#{ahead.count} commits ahead of origin")
    ahead.each do |commit|
      pretty_print("  #{commit}".blue)
    end
  end
end

def print_uncommited_files
  diff = Git.status.matches("\t([a-z ]*:.*)")

  if diff.count > 0
    pretty_print('')
    pretty_print("#{diff.count} uncommited changed files")
    diff.each do |line|
      pretty_print("  #{line}".green)
    end
  end
end

def promptContinueAnyway
  pretty_print('')

  options = Options.shared_instance

  if options.prefer_keep
    response = 0
  elsif options.prefer_discard
    response = 1
  else
    begin
      response = Ask.list 'Continue anyway? Changes will be lost', [
        'Stop',
        'Continue'
      ]
    rescue RuntimeError
      pretty_print("You must specify `--discard=true` or `--discard=false` or run interactively".red)
      exit 1
    end
  end

  if response == 0
    pretty_print("Aborted (user specified)".red)
    exit(1)
  end
end

def prompt_keep_local
  options = Options.shared_instance

  if options.prefer_local
    choice = 'local'
  elsif options.prefer_remote
    choice = 'remote'
  else
    puts ''
    begin
    response = Ask.list 'Keep remote or local copy?', [
      'Remote',
      'Local'
    ]
    rescue RuntimeError
      pretty_print("You must specify `--prefer=local` or `--prefer=remote` or run interactively".red)
      exit 1
    end

    choice = 'remote' if response == 0
    choice = 'local' if response == 1
  end

  if choice != 'remote'
    pretty_print('Using local branch (user specified)')
    exit(0)
  end
end

def add_all
  Git.reset_mixed
  Git.add_all
end

def fetch
  fetch = run_command('git fetch')
  error = fetch.stderr
  if error.include?('No remote repository specified')
    pretty_print("\n⚠️  No remote repository is setup\n".yellow)
    return
  end
  if fetch.exit_status != 0
    pretty_print("\n🤔 Failed to fetch.".red)
    pretty_print(error.red)
    exit(1)
  end
end
