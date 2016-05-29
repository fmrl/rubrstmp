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

require 'case'
require 'ptools'

require 'rubrstmp/feedback'
require 'rubrstmp/io'

module RubrStmp
end

class RubrStmp::Parser

   attr_reader :warnings

   def initialize(io, options = {})
      @options = options
      @feedback = options.fetch(:feedback, RubrStmp::Feedback.new(:name => 'rubrstmp'))
      @io = io
   end

   def parse(input, keywords)
      reset(keywords)
      for i in 0...input.length
         # [mlr] if this character is a $, then it's possible that it's a
         # keyword field.
         if i >= @index then
            c = input[i]
            if c == ?$ and input[i..-1] =~ /\A\$([\w-]+)(\$|:([0-9]+):)/ then
               keyword = $1
               is_short_form = ($2[0] == ?$)
               @feedback.say(:verbose) do
                  msg = "keyword '#{keyword}' identified."
                  if is_short_form then
                     "#{coordinate_to_s} short form #{msg}"
                  else
                     "#{coordinate_to_s} #{msg}"
                  end
               end
               value = expand(keyword)
               if value then
                  if is_short_form then
                     emit(keyword, value)
                     @index = i + keyword.length + 2
                  else
                     n = Integer($3)
                     m = (i + $~.end(3) + 2 + n) - 1
                     if input[m..(m + 1)] == ',$' then
                        emit(keyword, value)
                        @index = i + n + keyword.length + 5 + $3.length
                     else
                        warn(
                           "corrupt field detected; edit manually to "\
                              "correct.")
                        echo(c)
                     end
                  end
               else
                  echo(c)
               end
            else
               echo(c)
            end
         end
      end

      @output
   end

   private

   def reset(keywords)
      @output = ''
      @prefix = ''
      @index = 0
      @line = 1
      @column = 1
      @warnings = 0
      @keywords = keywords
      @cache = {}
   end

   def echo(char)
      if char == ?\n then
         @output << @prefix
         @prefix = ''
         @output << char
         @line += 1
         @column = 1
      else
         @prefix << char
         @column += 1
      end
   end

   def encode_header(s)
      "%d:%s," % [s.length, s]
   end

   def emit(keyword, value)
      if value == '' then
         # [mlr] we'll encode empty strings with the short form, for asthetic
         # reasons.
         @output << "#{@prefix}$#{keyword}$"
         @prefix = ''
         nil
      elsif value.is_a?(String) then
         @output << "#{@prefix}$#{keyword}:#{encode_header(value)}$"
         @prefix = ''
         nil
      elsif value.is_a?(Array) then
         s = "\n#{@prefix}\n"
         value.each do |line|
            s << "#{@prefix}#{line}"
         end
         # [mlr] if the last character in the file is an EOL, then we'll
         # need another prefix before we put the suffix on.
         if value[-1].chomp == value[-1] then
            s << "\n"
         end
         s << "#{@prefix}\n#{@prefix}"
         @output << "#{@prefix}$#{keyword}:#{encode_header(s)}$"
         @prefix = ''
         nil
      else
         raise "i encountered an unexpected type #{value.class}."
      end
   end

   def warn(reason)
      @feedback.say(:error) do
         "#{coordinate_to_s} #{reason}"
      end
      @warnings += 1
   end

   def coordinate_to_s
      return "(at line #{@line}, column #{@column})"
   end

   def load(keyword, filen)
      if File.binary?(filen) then
         raise ArgumentError,
            "i don't support binary files (`#{filen}`)."
      else
         @feedback.say(:verbose) { "i am reading `#{filen}` so that i can expand uses of `$#{keyword}$`." }
         s = @io.read(filen).lines
         # [mlr] if the file contains a single line, then we can do an
         # inline substitution. we represent this by converting the array
         # to a string and dropping the EOL, if there is one.
         if s.length == 1 then
            {keyword => s[0].chomp}
         else
            {keyword => s}
         end
      end
   end

   def expand(keyword)
      cached = @cache[keyword]
      if cached then
         cached
      else
         value = @keywords[keyword]
         case value
         when nil
            s = nil
         when Case[:path_name, String]
            s = load(keyword, value[1])[keyword]
         else
            if value.class == String then
               s = value
            else
               raise ArgumentError,
                  "i don't recognize the following association specification: "\
                     "#{keyword.inspect} => #{tuple.inspect}."
            end
         end
         @cache[keyword] = s
      end
   end

end

# $vim:23: vim:set sts=3 sw=3 et:,$
