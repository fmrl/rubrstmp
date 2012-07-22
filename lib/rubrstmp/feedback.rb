module RubrStmp
end

class RubrStmp::Feedback

   attr_reader :verbosity

   def initialize(options = {})
      @name = options.fetch(:name, nil)
      @verbosity = options.fetch(:verbosity, :normal)
   end

   def say(channel = :normal)
      case channel
      when :normal
         if @verbosity != :quiet then
            $stderr.puts "#{prefix}#{yield}"
         end
      when :verbose
         if @verbosity == :verbose then
            $stderr.puts "#{prefix}#{yield}"
         end
      when :error
         $stderr.puts "#{prefix}#{yield}"
      else
         raise ArgumentError,
            "i don't recognize the #{channel} channel."
      end
   end

   private

   def prefix
      if @name.nil? or @name == '' then
         ''
      else
         "#{@name}: "
      end
   end

end
