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

module RubrStmp
end

class RubrStmp::IO

   def initialize(options = {})
      @options = options
      @feedback = options.fetch(:feedback, RubrStmp::Feedback.new(:name => 'rubrstmp'))
      @dry_run = options.fetch(:dry_run, true)
      @overwrite = options.fetch(:overwrite, false)
      @eol = options.fetch(:eol, :auto)
   end

   def read(filen)
      s = IO.binread(filen)
      return s.encode(s.encoding, :universal_newline => true)
   end

   def write(filen, s)
      if @overwrite then
         if @dry_run then
            @feedback.say(:normal) { "`#{filen}` would be modified (eol is #{@eol.to_s})." }
         else
            @feedback.say(:verbose) { "modifying `#{filen}` (eol is #{@eol.to_s})." }
            encode_options = make_encode_options(@eol)
            output = s.encode(s.encoding, encode_options)
            IO.binwrite(filen, output)
         end
      else
         @feedback.say(:verbose) { "the result of the keyword expansion follows..." }
         puts s
      end
   end

   private

   def default_eol
      case RubrStmp::Platform.name
      when :windows
         :crlf
      else
         :lf
      end
   end

   def make_encode_options(eol, options = {})
      case eol
      when :crlf
         options[:crlf_newline] = true
      when :cr
         options[:cr_newline] = true
      when :lf
         options[:universal_newline] = true
      when :auto
         make_encode_options(default_eol, options)
      else
         raise "i don't recognize the eol encoding #{@eol.to_s}"
      end
      return options
   end
end
