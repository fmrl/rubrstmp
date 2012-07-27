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

require 'ptools'
require 'rubrstmp'

namespace :rubrstmp do
   

   desc "update keyword fields in text files."
   task :update do
      update(KEYWORDS)
   end

   desc "erase keyword fields in text files."
   task :clean do
      keywords = 
         KEYWORDS.keys.reduce({}) do |accum, keyword|
            accum[keyword] = ''
            accum
         end
      update(keywords)
   end
   
   def string_keywords(tab)
      tab.each do |k, v|
         if v.class == String then
            KEYWORDS[k] = v
         else
            raise ArgumentError,
               "i expected a string but encountered a #{v.class}."
         end
      end
   end
   
   def file_keywords(tab)
      tab.each do |k, v|
         if v.class == String then
            KEYWORDS[k] = [:path_name, v]
         else
            raise ArgumentError,
               "i expected a string but encountered a #{v.class}."
         end
      end
   end
   
   def exclude(globs)
      globs.each do |s|
         if v.class == String then
            EXCLUDE << s
         else
            raise ArgumentError,
               "i expected a string but encountered a #{v.class}."
         end
      end
   end
   
   private
   
   RUBRSTMP = ENV['RUBRSTMP'] || 'bin/rubrstmp'
   EXCLUDE = ['.git/**', '*.md', 'etc/rubrstmp/*', 'Gemfile.lock']
   KEYWORDS = {}

   # [mlr][todo] this should be implemented as an extension to File.
   def exclude_globs(filens, globs)
      filens.select do |fn|
         not globs.reduce(false) do |matched, pattern|
            matched or File.fnmatch?(pattern, fn)
         end
      end
   end
   
   def update(keywords)
      fb = RubrStmp::Feedback.new(
         :name => 'rubrstmp',
         :output => $stdout,
         :verbosity =>
            if RakeFileUtils.verbose then
               :verbose
            else
               :normal
            end)
      filens = exclude_globs(Dir.glob('**/*'), EXCLUDE)
      filens.each do |fn|
         if not File.directory?(fn) then
            if File.binary?(fn) then
               fb.say(:verbose) do
                  "#{fn} skipped (binary)."
               end
            else
               result = nil
               begin
                  result =
                     RubrStmp.update(fn, keywords,
                        :overwrite => true,
                        :feedback => fb)
               rescue Exception => e
                  fb.say(:error) do
                     "#{fn} abandoned due to exception: "
                        "\"#{e.message}\""
                  end
               end
               if result == :unchanged then
                  fb.say {"#{fn} unchanged."}
               elsif result == 0 then
                  fb.say {"#{fn} updated."}
               else
                  fb.say(:error) do
                     "#{fn} abandoned due to #{result} warning(s)."
                  end
               end
            end
         end
      end
   end

end

# $vim:23: vim:set sts=3 sw=3 et:,$
