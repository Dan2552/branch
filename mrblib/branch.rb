module BranchCli
  def self.root
    File.dirname __dir__
  end

  VERSION = '0.8.0'.freeze
end

def __main__(argv)
  Options.reset
  options = Options.shared_instance
  options.load_options(argv[1..-1] || [])

  if options.is_show_version
    pretty_print("branch cli #{BranchCli::VERSION}")
    exit(0)
  end

  if options.is_choice
    choose_branch
    exit(0)
  end

  if options.is_show_list
    print_recent_branches
    exit(0)
  end

  if options.is_help
    pretty_print('usage: branch BRANCH-NAME [ARGS]')
    pretty_print('')
    pretty_print("--version | -v\t\tShows the current version")
    pretty_print("--verbose \t\tPrints all the git commands as they run")
    pretty_print("--list | -l \t\tPrints the most recently updated branches")
    pretty_print("--choice | -c \t\t(Interactable) Switch to an existing branch from a list")
    pretty_print("--prefer=PREFERENCE \tWhere PREFERENCE is local or remote, will use the set preference rather than ask")
    pretty_print("--discard=PREFERENCE \tWhere PREFERENCE is true or false, will use the set preference rather than ask")
    pretty_print("--help | help \t\tShows this help")
    exit(0)
  end

  add_all

  if options.is_branch_supplied
    set_current_branch(Git::Branch.new(options.supplied_branch))
  else
    fetch
    print_branch_status
  end

  nil
end
