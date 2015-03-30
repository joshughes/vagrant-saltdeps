lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-Saltdeps/version'

Gem::Specification.new do |s|
  s.name          = "vagrant-saltdeps"
  s.version       = VagrantPlugins::Saltdeps::VERSION
  s.platform      = Gem::Platform::RUBY
  s.license       = "MIT"
  s.authors       = "Joseph Hughes"
  s.email         = "jhughes@itriagehealth.com"
  s.homepage      = "https://github.com/joshughes/vagrant-Saltdeps"
  s.summary       = "Enables Vagrant to manage salt formula dependencies."
  s.description   = "Enables Vagrant to manage salt formula dependencies."

  s.files         = `git ls-files`.split($/)
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.add_runtime_dependency "git", "~> 1.2"
  s.add_runtime_dependency "pry", '~> 0.10'

  s.add_development_dependency "rake", '~> 10.4'
  s.add_development_dependency "rspec", "~> 3.2"

end
