# -*- encoding: utf-8 -*-
require File.expand_path('../lib/melissa/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Brad Pardee', 'Svetlana Marinskaya']
  gem.email         = ['bradpardee@gmail.com', 'svetlana.marinskaya@gmail.com']
  gem.description   = %q{Configurable interface to Melissa Data Address and GeoPoint objects}
  gem.summary       = %q{Melissa allows you to use ruby wrappers for Melissa Data's AddrObj and GeoPoint objects or use the mock objects depending on configuration.}
  gem.homepage      = "https://github.com/smarinskaya/Melissa"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "melissa"
  gem.require_paths = ["lib"]
  gem.version       = Melissa::VERSION

  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'minitest'

  gem.add_runtime_dependency 'activesupport'
  gem.add_runtime_dependency 'ffi'
  gem.add_runtime_dependency 'thread_safe'
  gem.add_runtime_dependency 'rest-client'
  gem.add_runtime_dependency 'nokogiri'
end
