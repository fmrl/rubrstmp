#!/usr/bin/env ruby

# $vimopts:45:ex: set softtabstop=3 shiftwidth=3 expandtab:,$

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

def encode_netstring(s)
   "%d:%s," % [s.length, s]
end

options = {}
OptionParser.new do |opts|
   opts.banner = "usage: #{opts.program_name} [options]"
   opts.on("-f FILE", String,
      "specifies the input file.") do |v|
         options[:input] = v
      end
   opts.on("-v", "--[no-]verbose",
      "i will provide verbose feedback.") do |v|
         options[:verbose] = v
      end
end.parse!

keywords = {}
ARGV.each do |s|
   if not s =~ /^(\w+)=(.*)$/ then
      raise "i don't recognize the association \"#{s}\"."
   elsif keywords.has_key?($1) then
      raise "you cannot specify an association for \"#{$1}\" twice."
   elsif $2.length > 1 and $2[0..0] == '@' then
      filen = $2[1..-1]
      if options[:verbose] then
         $stderr.puts "#{$1} => #{filen}"
      end
      File.open(filen, "r") do |f|
         # [mlr] if the file contains a single line, then we can do an
         # inline substitution. we represent this by converting the array
         # to a string and dropping the EOL, if there is one.
         x = f.readlines
         if x.length == 1 then
            keywords[$1] = f.readlines[0].chomp
         else
            keywords[$1] = x
         end
      end
   else
      if options[:verbose] then
         $stderr.puts "#{$1} => #{$2.inspect}"
      end
      keywords[$1] = $2
   end
end

def xyzzy(prefix, keyword, value)
   if value.is_a?(String) then
      "#{prefix}$#{keyword}:#{encode_netstring(value)}$"
   elsif value.is_a?(Array) then
      s = "\n#{prefix}\n"
      value.each do |line|
         s << "#{prefix}#{line}"
      end
      # [mlr] if the last character in the file is an EOL, then we'll
      # need another prefix before we put the suffix on.
      if value[-1].chomp == value[-1] then
         s << "\n"
      end
      s << "#{prefix}\n#{prefix}"
      "#{prefix}$#{keyword}:#{encode_netstring(s)}$"
   else
      raise "i encountered an unexpected type #{value.class}."
   end
end

text = nil
output = ''
f = File.open(options[:input], "r") do |f|
   input = f.readlines(nil)[0]
   prefix = ''
   j = 0
   line_no = 1
   for i in 0...input.length
      # [mlr] if this character is a $, then it's possible that it's a keyword
      # field.
      if i >= j then
         c = input[i]
         if c == ?$ and
               input[i..-1] =~ /\A\$(\w+)(\$|:([0-9]+):)/ then
            keyword = $1
            is_short_form = ($2[0] == ?$)
            value = keywords[keyword]
            if is_short_form then
               output << xyzzy(prefix, keyword, value)
               prefix = ''
               j = i + keyword.length + 2
            else
               n = Integer($3)
               m = (i + $~.end(3) + 2 + n) - 1
               if input[m..(m + 1)] == ',$' then
                  output << xyzzy(prefix, keyword, value)
                  prefix = ''
                  j = i + n + keyword.length + 2 + $3.length
               else
                  $stderr.puts("warning!")
                  prefix << c
               end
            end
         elsif c == ?\n then
            output << prefix
            prefix = ''
            output << c
            line_no += 1
         else
            prefix << c
         end
      end
   end
end

puts output
