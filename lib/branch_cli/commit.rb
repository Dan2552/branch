
class Commit < Swifty
  var message = nil
  var sha = nil

  swift self, binding

  def initialize(message: String, sha: String)
    self.message = message.clearQuotes
    self.sha = sha.clearQuotes
  end

  def self.getCurrentHead
    return Commit.from(identifier: "HEAD")
  end

  def self.from(identifier: String)
    return Commit.new(
      message: message(forIdentifier: identifier),
      sha: sha(forIdentifier: identifier)
    )
  end

  def commitsLeading(commit: Commit)
    let run = runCommand("git rev-list #{sha}..#{commit.sha} --reverse").stdout
    var commits = [] # [Commit]
    let shas = run.components(separatedBy: "\n")
    shas.each do |sha|
      commits.append(Commit.from(identifier: sha))
    end
    return commits
  end

  def mostRecentCommonAncestor(commit: Commit)
    let mergeBase = runCommand("git merge-base #{sha} #{commit.sha}").stdout
    return Commit.from(identifier: mergeBase)
  end

  def printableFormat(format)
    let command = runCommand("git", args: [
      "log",
      "-n1",
      sha,
      "--format=\"#{format}\""
    ])
    return command.stdout.gsub("\n", "")
  end

  private

  def self.sha(identifier: String)
    return runCommand("git log -1 #{identifier} --format=\"%H\"").stdout
  end

  def self.message(identifier: String)
    return runCommand("git log -1 #{identifier} --format=\"%s\"").stdout
  end
end
