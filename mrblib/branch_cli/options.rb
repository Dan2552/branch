class Options
  attr_accessor :is_verbose,
                :is_show_version,
                :supplied_branch,
                :is_help,
                :is_test_rebase,
                :is_show_list,
                :is_choice,
                :prefer_local,
                :prefer_remote,
                :prefer_discard,
                :prefer_keep

  def self.shared_instance
    @shared_instance ||= Options.new
  end

  def self.reset
    @shared_instance = nil
  end

  def is_branch_supplied
    !supplied_branch.nil?
  end

  def load_options(arguments)
    arguments = arguments.to_a

    if arguments.include?('help') || arguments.include?('--help')
      self.is_help = true
    end

    self.is_verbose = true if arguments.include?('--verbose')

    if arguments.include?('-v') || arguments.include?('--version')
      self.is_show_version = true
    end

    self.is_test_rebase = true if arguments.include?('--test-rebase')

    if arguments.include?('--list') || arguments.include?('-l')
      self.is_show_list = true
    end

    if arguments.include?('--choice') || arguments.include?('-c')
      self.is_choice = true
    end

    self.prefer_local = true if arguments.include?('--prefer=local')
    self.prefer_remote = true if arguments.include?('--prefer=remote')
    self.prefer_discard = true if arguments.include?('--discard=true')
    self.prefer_keep = true if arguments.include?('--discard=false')

    if arguments.count > 0
      self.supplied_branch = arguments[0] unless arguments[0].start_with?('-')
    end
  end
end
