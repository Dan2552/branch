module Git
  def self.reset_mixed
    runCommand("git reset --mixed").stdout
  end

  def self.add_all
    runCommand("git add . -A").stdout
  end

  def self.status
    runCommand("git status").stdout
  end

  def self.log(options)
    runCommand("git log #{options}").stdout
  end
end
