MRuby::Gem::Specification.new('branch') do |spec|
  spec.license = 'MIT'
  spec.author  = 'Daniel Inkpen'
  spec.summary = 'branch'
  spec.bins    = ['branch']

  spec.add_dependency 'mruby-print' #, :core => 'mruby-print'
  spec.add_dependency 'mruby-enumerator', :core => 'mruby-enumerator'
  spec.add_dependency 'mruby-array-ext', :core => 'mruby-array-ext'

  spec.add_dependency 'mruby-open3', :mgem => 'mruby-open3'
  spec.add_dependency 'mruby-regexp-pcre', :mgem => 'mruby-regexp-pcre'


  spec.add_dependency 'mruby-mtest', :mgem => 'mruby-mtest'

  spec.add_dependency 'mruby-io-console', :mgem => 'mruby-io-console'

  # spec.add_dependency 'mruby-print', :core => 'mruby-print'
  # spec.add_dependency 'mruby-hash-ext'
  # spec.add_test_dependency 'mruby-print', :core => 'mruby-print'
  # spec.add_test_dependency 'mruby-mtest', :core => 'mruby-mte'
  # spec.add_dependency 'mruby-tty-screen', :mgem => 'mruby-tty-screen'
end
