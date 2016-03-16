import Swiftline

func runCommand(command: String) -> RunResults {
  if Options.sharedInstance.isVerbose { print(command.f.Blue) }
  return run(command)
}

func runCommand(command: String, args: [String]) -> RunResults {
  if Options.sharedInstance.isVerbose { print("\(command) \(args)".f.Blue) }
  return run(command, args: args)
}
