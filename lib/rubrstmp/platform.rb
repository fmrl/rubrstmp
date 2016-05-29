require 'rbconfig'

module RubrStmp::Platform

   module_function
   def name
      @name ||= (
         host_os = RbConfig::CONFIG['host_os']
         case host_os
         when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
           :windows
         when /cygwin/
           :cygwin
         when /darwin|mac os/
           :macosx
         when /linux/
           :linux
         when /solaris|bsd/
           :unix
         else
           raise "i don't recognize the platform: #{host_os.inspect}"
         end
         )
   end

end
