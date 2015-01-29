# -*- encoding: utf-8 -*-
require File.expand_path('../lib/melissa/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Svetlana Marinskaya"]
  gem.email         = ["svetlana.marinskaya@gmail.com"]
  gem.description   = %q{Write a gem description}
  gem.summary       = %q{Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "melissa"
  gem.require_paths = ["lib"]
  gem.version       = Melissa::VERSION

  gem.add_dependency 'activesupport' # added to support underscore method.
  gem.add_dependency 'minitest'      # added as a dependency of activesupport and for testing.
  gem.add_dependency 'ffi'           #used for converting c libraries to ruby
end
