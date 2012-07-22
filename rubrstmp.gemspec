# -*- encoding: utf-8 -*-
# $legal$
require File.expand_path('../lib/rubrstmp/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["michael lowell roberts"]
  gem.email         = ["mlr@fmrl.org"]
  gem.description   = "specify text to be substituted into source files, similar to the manner in which RCS keywords function"
  gem.summary       = "rubrstmp is a tool that is intended to allow the programmer to specify text to be substituted into source files, similar to the manner in which RCS keywords function.\n\nrubrstmp preserves comment decorations and the substituted text is encoded as a netstring."
  gem.homepage      = "https://github.com/fmrl/rubrstmp"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rubrstmp"
  gem.require_paths = ["lib"]
  gem.version       = RubrStmp::VERSION
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'minitest'
  gem.add_dependency 'case'
  gem.add_dependency 'ptools'
end

# $vim-rb$
