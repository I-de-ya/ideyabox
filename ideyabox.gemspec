# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ideyabox/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Max Rydkin", "veskakoff"]
  gem.email         = ["maks.rydkin@gmail.com", "veskakov@gmail.com"]
  gem.description   = %q{Write a gem description}
  gem.summary       = %q{Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ideyabox"
  gem.require_paths = ["lib", "app"]
  gem.version       = Ideyabox::VERSION

  gem.add_dependency "russian"
  gem.add_dependency "redactor-rails"
  gem.add_dependency "kaminari"
  gem.add_dependency "haml", ">= 3.1.6"
  gem.add_dependency "devise"
  gem.add_dependency "jquery-fileupload-rails"
  gem.add_dependency "mini_magick"
  gem.add_dependency "sexy_validators", ">=0.0.5"
  gem.add_development_dependency "haml-rails", ">= 0.3.4"
  gem.add_development_dependency "capistrano"

end
