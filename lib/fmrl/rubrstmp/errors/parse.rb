module RubrStmp	
end

class RubrStmp::ParseError < RuntimeError

   attr_reader :line, :column

   def initialize(line, column)
      @line = line
      @column = column
      super "i failed to (#{@line}, column #{@column})."
      else
         super "the parser reported an error: #{parser.failure_reason}."
     end
   end

end
