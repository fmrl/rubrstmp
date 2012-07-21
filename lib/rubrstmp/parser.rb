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

module RubrStmp
end

class RubrStmp::Parser

   attr_reader :warnings

   def initialize(options = {})
      @verbose = options.fetch(:verbose, false)
   end

   def parse(input, keywords)
      reset
      for i in 0...input.length
         # [mlr] if this character is a $, then it's possible that it's a
         # keyword field.
         if i >= @index then
            c = input[i]
            if c == ?$ and
                  input[i..-1] =~ /\A\$([\w-]+)(\$|:([0-9]+):)/ then
               keyword = $1
               is_short_form = ($2[0] == ?$)
               value = keywords[keyword]
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
                        warn("corrupt field detected.")
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

   def reset
      @output = ''
      @prefix = ''
      @index = 0
      @line = 1
      @column = 1
      @warnings = 0
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

   def encode_netstring(s)
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
         @output << "#{@prefix}$#{keyword}:#{encode_netstring(value)}$"
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
         @output << "#{@prefix}$#{keyword}:#{encode_netstring(s)}$"
         @prefix = ''
         nil
      else
         raise "i encountered an unexpected type #{value.class}."
      end
   end

   def warn(reason)
      $stderr.puts "warning at line #{@line}, column #{@column}: #{reason}"
      @warnings += 1
   end

end

