def execute(args)
  @original = Dir.pwd
  Dir.chdir "/tmp/branch-cli-test"
  main(args)
rescue SystemExit
end

def create_test_repo
  `mkdir /tmp/branch-cli-test`
  `cd /tmp/branch-cli-test && git init`
end

def teardown_test_repo
  `rm -rf /tmp/branch-cli-test`
  Dir.chdir "/tmp"
end

def clone_remote_repo
  teardown_test_repo
  `cd /tmp && git clone https://github.com/Dan2552/branch.git branch-cli-test`
end

def git_reset(args)
  `cd /tmp/branch-cli-test && git reset #{args}`
end

RSpec.configure do |config|
  config.before(:each) { teardown_test_repo; create_test_repo }
  config.after(:each) { teardown_test_repo }
end

def expect_output(out)
  expect { subject }.to output(out).to_stdout
end

def expect_to_not_output(out)
  expect { subject }.to_not output(out).to_stdout
end

def expect_branch(branch)
  expect(`cd /tmp/branch-cli-test && git status`).to match(/On branch #{branch}/)
end

def touch(filename)
  `cd /tmp/branch-cli-test && touch #{filename}`
end

def commit(name = "test")
   `cd /tmp/branch-cli-test && git add . -A && git commit -m "#{name}"`
end
