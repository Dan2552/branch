class Object
  def self.let(*args)
  end

  def self.var(*args)
  end

  def let(*args)
  end

  def var(*args)
  end

  def agree(message)
    puts ""
    idx = Ask.list message, [
      "Continue",
      "Do not continue",
    ]
    binding.pry
    # puts ""
    # cli = HighLine.new
    # cli.choose do |menu|
    #   menu.prompt = message
    #   menu.choice(:yes, :y) { return true }
    #   menu.choice(:no, :n) { return false }
    # end
  end
end

class Swifty
  def self.swift(s, b)
    b.local_variables.each do |v|
      s.send(:attr_reader, v)
      s.send(:attr_writer, v)

      variable_defaults[v] = b.local_variable_get(v)
    end
  end

  def self.variable_defaults
    @variable_defaults ||= {}
  end

  def initialize(params = {})
    params = self.class.variable_defaults.merge!(params)
    params.each { |key, value| send "#{key}=", value }
  end
end

class Array
  def contains(*args)
    include?(*args)
  end
end

class String
  def contains(*args)
    include?(*args)
  end

  def hasPrefix(str)
    start_with?(str)
  end

  def components(separatedBy:)
    split(separatedBy)
  end

  def s
    self
  end

  def Bold
    "[bold]#{self}[/]"
  end

  def f
    self
  end

  def Green
    "[green]#{self}[/]"
  end

  def Blue
    "[blue]#{self}[/]"
  end

  def Red
    "[red]#{self}[/]"
  end
end
