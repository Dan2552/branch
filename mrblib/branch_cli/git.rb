module Git
  def self.reset_mixed
    run_command('git reset --mixed').stdout
  end

  def self.add_all
    run_command('git add . -A').stdout
  end

  def self.status
    run_command('git status').stdout
  end

  def self.log(options)
    run_command("git log #{options}").stdout
  end
end
