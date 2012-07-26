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

require 'optparse'

require 'rubrstmp'
require 'rubrstmp/errors/usage'

module RubrStmp

   def self.cli(argv)
      RubrStmp::Cli.new(argv)
   end

end

class RubrStmp::Cli

   def initialize(argv)
      @warnings = 0

      parse_opts!(argv)

      @warnings +=
         RubrStmp.update(
            @input_filen,
            @keywords,
            :feedback => @feedback,
            :overwrite => @overwrite)

      finish
   end

   private

   def parse_opts!(argv)

      options = {}
      OptionParser.new do |opts|
         @name = opts.program_name
         opts.banner = "usage: #{opts.program_name} [options]"
         opts.on("-f FILE", String,
            "specifies the input file.") do |v|
               options[:input] = v
            end
         opts.on("-v", "--[no-]verbose",
            "i will provide verbose feedback.") do |v|
               options[:verbose] = v
            end
         opts.on("-O", "--[no-]overwrite",
            "i will replace the input file with my output instead of "\
            "writing it to stdout.") do |v|
               options[:overwrite] = v
            end
      end.parse! argv

      @feedback =
         RubrStmp::Feedback.new(
            :name => @name,
            :verbosity =>
               (if options.fetch(:verbose, false) then
                  :verbose
               else
                  :normal
               end))

      @input_filen = options[:input]
      if @input_filen.nil? then
         raise RubrStmp::UsageError,
            'please specify an input file.'
      end

      @overwrite = options.fetch(:overwrite, false)

      @keywords = {}
      argv.each do |s|
         if not s =~ /^([\w-]+)=(.*)$/ then
            raise "i don't recognize the association \"#{s}\"."
         elsif @keywords.has_key?($1) then
            raise "you cannot specify an association for \"#{$1}\" twice."
         elsif $2.length > 1 and $2[0..0] == '@' then
            pathn = $2[1..-1]
            @feedback.say(:verbose) {"#{$1} => [:path_name, #{pathn}]"}
            @keywords[$1] = [:path_name, pathn]
         else
            @feedback.say(:verbose) {"#{$1} => #{$2.inspect}"}
            @keywords[$1] = $2
         end
      end

      nil
   end

   def finish(options = {})
      @feedback.say {"i have finished with #{@warnings} warnings."}
      exit @warnings == 0
   end

end

# $vim:23: vim:set sts=3 sw=3 et:,$
