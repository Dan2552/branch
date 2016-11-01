import Swiftline

func runCommand(_ command: String) -> RunResults {
  if Options.sharedInstance.isVerbose { print(command.f.Blue) }
  return run(command)
}

func runCommand(_ command: String, args: [String]) -> RunResults {
  if Options.sharedInstance.isVerbose { print("\(command) \(args)".f.Blue) }
  return run(command, args: args)
}
