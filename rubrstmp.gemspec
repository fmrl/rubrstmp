# -*- encoding: utf-8 -*-
# $legal:1570:
# 
# Copyright (c) 2012, Michael Lowell Roberts.
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
# 
#   - Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
# 
#   - Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
# 
#   - Neither the name of the copyright holder nor the names of
#   contributors may be used to endorse or promote products derived
#   from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
# OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
# ,$
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

# $vim:23: vim:set sts=3 sw=3 et:,$
