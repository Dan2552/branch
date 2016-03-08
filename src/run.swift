import Swiftline

func runCommand(command: String) -> RunResults {
  if Options.sharedInstance.isVerbose {
    print(command.f.Blue)
  }
  return run(command)
}
