#!/usr/bin/env ruby

require 'bundler'
Bundler.require(:default)

# TODO: remove
require 'pry'

require 'open3'

path = File.expand_path('../../src', __FILE__)

$LOAD_PATH.unshift path


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
