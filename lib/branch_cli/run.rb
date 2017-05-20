class RunResult < Swifty
  let stdout = nil
  let stderr = nil
  let exitStatus = nil

  swift self, binding
end

def runCommand(command, args: [])
  command_with_args = "#{command} #{args.join(" ")}"

  if Options.sharedInstance.isVerbose
    prettyPrint(command_with_args.f.Blue)
  end

  Open3.popen3(command_with_args) do |stdin, stdout, stderr, wait_thr|
    RunResult.new(stdout: stdout.read,
                  stderr: stderr.read,
                  exitStatus: wait_thr.value.to_i)
  end
end