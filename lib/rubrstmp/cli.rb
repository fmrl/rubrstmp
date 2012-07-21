# $vimode:46: vi: set softtabstop=3 shiftwidth=3 expandtab:,$

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

      keywords = {}
      argv.each do |s|
         if not s =~ /^([\w-]+)=(.*)$/ then
            raise "i don't recognize the association \"#{s}\"."
         elsif keywords.has_key?($1) then
            raise "you cannot specify an association for \"#{$1}\" twice."
         elsif $2.length > 1 and $2[0..0] == '@' then
            filen = $2[1..-1]
            say(:verbose) {"#{$1} => #{filen}"}
            File.open(filen, "r") do |f|
               # [mlr] if the file contains a single line, then we can do an
               # inline substitution. we represent this by converting the array
               # to a string and dropping the EOL, if there is one.
               x = f.readlines
               if x.length == 1 then
                  keywords[$1] = x[0].chomp
               else
                  keywords[$1] = x
               end
            end
         else
            say(:verbose) {"#{$1} => #{$2.inspect}"}
            keywords[$1] = $2
         end
      end

      # [mlr][todo] what does File#open return when a block is provided?
      # how should i refactor the code to take advantage of it?
      emit(
         File.open(@input_filen, "r") do |f|
            p = RubrStmp::Parser.new(:verbose => (@verbosity == :verbose))
            # [mlr][todo] at some point, it might be worthwhile to stream
            # the output to a file.
            s = p.parse(f.readlines(nil)[0], keywords)
            @warnings += p.warnings
            s
         end)

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

      if options.fetch(:verbose, false) then
         @verbosity = :verbose
      else
         @verbosity = :normal
      end

      @input_filen = options[:input]
      if @input_filen.nil? then
         raise RubrStmp::UsageError,
            'please specify an input file.'
      end

      @overwrite = options.fetch(:overwrite, false)

      argv
   end

   def say(channel = :normal)
      case channel
      when :normal
         if @verbosity != :quiet then
            $stderr.puts "#{@name}: #{yield}"
         end
      when :verbose
         if @verbosity == :verbose then
            $stderr.puts "#{@name}: #{yield}"
         end
      when :error
         $stderr.puts "#{@name}: #{yield}"
      end
   end

   def emit(s)
      if @overwrite then
         File.open(@input_filen, 'w') do |f|
            f.write(s)
         end
      else
         puts s
      end
   end

   def finish(options = {})
      say {"i have finished with #{@warnings} warnings."}
      exit @warnings == 0
   end

end

