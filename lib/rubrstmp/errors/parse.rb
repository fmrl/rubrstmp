class RubrStmp::ParseError < RuntimeError

   attr_reader :line, :column

   def initialize(line, column)
      @line = line
      @column = column
      super "i failed to parse the text at #{@line}, column #{@column}."
   end

end
