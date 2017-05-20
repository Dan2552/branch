lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = 'branch_cli'
  gem.version       = '0.6.0'
  gem.authors       = ['Daniel Inkpen']
  gem.email         = ['dan2552@gmail.com']
  gem.description   = %q{Faster, safer git branching.}
  gem.summary       = %q{Branch aims to simplify a developer's daily workflow of Git. It is in no means supposed to replace Git, but provide a quicker and easier way to do some more common functions (with more memorable commands). Branch is pretty opinionated in the way it does things (i.e. I don't care about staging/unstaging files, I just want all of my current changes in a single bucket). It also makes the assumption that you use a single remote (origin) and your local "my-branch" is always going to have the upstream as "origin/my-branch" (i.e. it fits with the most common of workflows).}
  gem.homepage      = 'https://github.com/Dan2552/branch'
  gem.license       = 'MIT'

  gem.add_dependency "formatador"
  gem.add_dependency "inquirer"
  gem.add_dependency "binding_of_caller"

  gem.add_development_dependency 'rspec', '~> 3.5.0'
  gem.add_development_dependency 'pry', '> 0'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
end
