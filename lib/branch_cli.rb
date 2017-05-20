#!/usr/bin/env ruby
module BranchCli
  def self.root
    File.dirname __dir__
  end
end

require 'open3'

path = File.expand_path('../../lib/branch_cli', __FILE__)
$LOAD_PATH.unshift path

require 'formatador'
require 'inquirer'

require 'swift_compatibility'

require 'branch'
require 'commit'
require 'options'
require 'print'
require 'run'
require 'string'

begin
  require 'main'
rescue Interrupt
  exit 1
end
