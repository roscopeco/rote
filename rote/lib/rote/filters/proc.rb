module Rote
  module Filters
    
    class Proc
        
      class << self
        alias :with :new
      end
      
      def initialize(&block)
        raise ArgumentError, "No block given" unless block
        @block = block      
        
        # TODO can we check arg count ?
      end
      
      def filter(text, page)
        @block.call(text, page)
      end    
    end
  
  end
end
