class Object
  def let(*args)
  end

  def var(*args)
  end
end

class SwiftObject
  def self.let(*args)
    bind = binding.of_caller(1)
    bind.local_variables.each do |v|
      attr_reader(v)

      variable_defaults[v] = bind.local_variable_get(v)
    end
  end

  def self.var(*args)
    bind = binding.of_caller(1)
    bind.local_variables.each do |v|
      attr_reader(v)
      attr_writer(v)

      variable_defaults[v] = bind.local_variable_get(v)
    end
  end

  def self.variable_defaults
    @variable_defaults ||= {}
  end

  def initialize
    params = self.class.variable_defaults

    params.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end
end

class SwiftStruct < SwiftObject
  def initialize(params = {})
    params = self.class.variable_defaults.merge!(params)

    params.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
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
end
