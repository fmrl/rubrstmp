# $legal:1562:
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
#,$

require 'rubrstmp/io'
require 'rubrstmp/parser'
require 'rubrstmp/platform'

module RubrStmp

   def self.update(filen, keywords, options = {})

      io = RubrStmp::IO.new(options)
      p = RubrStmp::Parser.new(io, options)
      feedback = options.fetch(:feedback, RubrStmp::Feedback.new(:name => 'rubrstmp'))

      input = io.read(filen)
      # [mlr][todo] at some point, it might be worthwhile to stream
      # the output to a file.
      output = p.parse(input, keywords)
      if p.warnings != 0 then
         return p.warnings
      end
      if input == output then
         feedback.say(:verbose) { "input is already up-to-date." }
      end
      io.write(filen, output)
      return 0
   end

end

# $vim:23: vim:set sts=3 sw=3 et:,$
