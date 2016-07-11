# -*- encoding: utf-8 -*-
require File.expand_path('../lib/melissa/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors     = ['Brad Pardee', 'Svetlana Marinskaya']
  gem.email       = ['bradpardee@gmail.com', 'svetlana.marinskaya@gmail.com']
  gem.description = %q{Configurable interface to Melissa Data Address and GeoPoint objects}
  gem.summary     = %q{Melissa allows you to use ruby wrappers for Melissa Data's AddrObj and GeoPoint objects or use the mock objects depending on configuration.}
  gem.homepage    = "https://github.com/smarinskaya/Melissa"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "melissa"
  gem.require_paths = ["lib"]
  gem.version       = Melissa::VERSION

  gem.add_dependency 'activesupport'              # added to support underscore method.
  gem.add_dependency 'minitest'                   # added as a dependency of activesupport and for testing.
  gem.add_dependency 'ffi'                        # used for converting c libraries to ruby
  gem.add_dependency 'concurrent-ruby'            # added to support concurrent callbacks
  gem.add_dependency 'sync_attr'                  # added to safely create lazy loaded class variables
end
