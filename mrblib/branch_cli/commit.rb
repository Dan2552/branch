class Commit
  attr_accessor :message,
                :sha

  def initialize(message, sha)
    self.message = message.clear_quotes
    self.sha = sha.clear_quotes
  end

  def self.get_current_head
    Commit.from(identifier: 'HEAD')
  end

  def self.from(identifier)
    Commit.new(
      message: message(forIdentifier: identifier),
      sha: sha(forIdentifier: identifier)
    )
  end

  def commits_leading(commit)
    run = run_command("git rev-list #{sha}..#{commit.sha} --reverse").stdout
    var commits = [] # [Commit]
    shas = run.components(separatedBy: "\n")
    shas.each do |sha|
      commits.append(Commit.from(identifier: sha))
    end
    commits
  end

  def most_recent_common_ancestor(commit)
    mergeBase = run_command("git merge-base #{sha} #{commit.sha}").stdout
    Commit.from(identifier: mergeBase)
  end

  def printable_format(format)
    command = run_command('git', ['log', '-n1', sha, "--format=#{format}"])
    command.stdout.gsub("\n", "")
  end

  private

  def self.sha(identifier)
    run_command("git log -1 #{identifier} --format=\"%H\"").stdout
  end

  def self.message(identifier)
    run_command("git log -1 #{identifier} --format=\"%s\"").stdout
  end
end
