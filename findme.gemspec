# -*- encoding: utf-8 -*-
require File.expand_path('../lib/findme/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["c2h2"]
  gem.email         = ["yiling.cao@gmail.com"]
  gem.description   = "find neighborhood host and services with avahi / avahi-daemon. run this for the first time to allow normal user to register services `sudo chmod a+w /etc/avahi/services/`"
  gem.summary       = "find neighborhood host and services with avahi / avahi-daemon."
  gem.homepage      = "https://github.com/c2h2/findme"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "findme"
  gem.require_paths = ["lib"]
  gem.version       = Findme::VERSION
end
