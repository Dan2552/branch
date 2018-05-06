class RunResult
  attr_reader :stdout,
              :stderr,
              :exit_status

  def initialize(stdout, stderr, exit_status)
    @stdout = stdout
    @stderr = stderr
    @exit_status = exit_status
  end
end

def run_command(command, args = [])
  command_with_args = "#{command} #{args.join(' ')}"

  pretty_print(command_with_args.cyan) if Options.shared_instance.is_verbose

  # Open3.popen3(command_with_args) do |_stdin, stdout, stderr, wait_thr|
  #   RunResult.new(stdout: stdout.read,
  #                 stderr: stderr.read,
  #                 exitStatus: wait_thr.value.to_i)
  # end
  stdout, stderr, status = Open3.capture3(*([command.split(" "), args].flatten))
  # puts "done: [#{stdout}] [#{stderr}] [#{status.exitstatus}]"
  RunResult.new(stdout || "", stderr || "", status.exitstatus)
end
