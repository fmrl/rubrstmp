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
      perform_recursion("update")
   end

   desc "erase keyword fields in text files."
   task :clean do
      keywords = 
         KEYWORDS.keys.reduce({}) do |accum, keyword|
            accum[keyword] = ''
            accum
         end
      update(keywords)
      perform_recursion("clean")
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
   
   def exclude(*globs)
      globs.each do |s|
         if !s.is_a?(String) then
            raise ArgumentError,
               "i expected a string but encountered a #{v.class}."
         else
            EXCLUDE << s
         end
      end
   end
   
   def recurse(*dirs)
      dirs.each do |s|
         if !s.is_a?(String) then
            raise ArgumentError,
               "i expected a string but encountered a #{v.class}."
         elsif  !File.directory?(s) then
            raise ArgumentError,
               "i expected \"#{s}\" to describe a directory."
         elsif  !File.exists?(File.expand_path("Rakefile", s)) then
            raise ArgumentError,
               "i expected \"#{s}\" to contain a Rakefile."
         else
            RECURSE << s
            EXCLUDE << File.expand_path("**", s)
         end
      end
   end
   
   private
   
   RUBRSTMP = ENV['RUBRSTMP'] || 'bin/rubrstmp'
   EXCLUDE = ['.git/**', 'etc/rubrstmp/*', 'Gemfile.lock', '*~', '*.bak']
   RECURSE = []
   KEYWORDS = {}
   FEEDBACK = RubrStmp::Feedback.new(
      :name => 'rubrstmp',
      :output => $stdout,
      :verbosity =>
         if RakeFileUtils.verbose then
            :verbose
         else
            :normal
         end)

   # [mlr][todo] this should be implemented as an extension to File.
   def excluded?(fn, globs)
      # [mlr] some patterns won't be matched correctly without an
      # absolute pathname.
      fn = File.expand_path(fn)
      globs.reduce(nil) do |matched, glob|
         if matched.nil? then
            if File.fnmatch?(File.expand_path(glob), fn) then
               #puts "+++ File.fnmatch?(#{File.expand_path(glob)}, #{fn}) => true"
               glob
            else
               #puts "+++ File.fnmatch?(#{File.expand_path(glob)}, #{fn}) => false"
               nil
            end
         else
            matched
         end
      end
   end
   
   def update(keywords)
      Dir.glob('**/*').sort.each do |fn|
         if not File.directory?(fn) then
            glob = excluded?(fn, EXCLUDE)
            if glob then
               #FEEDBACK.say(:verbose) { "#{fn} excluded (#{glob})."}
               nil
            elsif File.binary?(fn) then
               FEEDBACK.say(:verbose) do
                  "#{fn} skipped (binary)."
               end
            else
               result = nil
               begin
                  result =
                     RubrStmp.update(fn, keywords,
                        :overwrite => true,
                        :feedback => FEEDBACK)
               rescue Exception => e
                  FEEDBACK.say(:error) do
                     "#{fn} abandoned due to exception: "\
                        "\"#{e.message}\""
                  end
               else
                  if result == :unchanged then
                     #FEEDBACK.say(:verbose) {"#{fn} unchanged."}
                     nil
                  elsif result == 0 then
                     FEEDBACK.say {"#{fn} updated."}
                  else
                     FEEDBACK.say(:error) do
                        "#{fn} abandoned due to #{result} warning(s)."
                     end
                  end
               end
            end
         end
      end      
   end
   
   def perform_recursion(task_name)
      RECURSE.each do |dirn|
         success = false
         if File.exists?(File.expand_path("Gemfile", dirn)) then
            success = 
               sh "cd #{dirn} && bundle exec rake rubrstmp:#{task_name}"
         else
            success = sh "cd #{dirn} && rake rubrstmp:#{task_name}"
         end
         if !success then
            raise RuntimeError,
               "recursion into #{dirn} failed; returned error code #{$?}."
         end
         FEEDBACK.say {"#{dirn} #{task_name} complete."}
      end
   end

end

# $vim:23: vim:set sts=3 sw=3 et:,$
