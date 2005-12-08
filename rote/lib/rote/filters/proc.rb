module Rote
  module Filters
    
    class Proc
      def initialize(&block)
        @block = block      
        
        # TODO can we check arg count ?
      end
      
      def filter(text, page)
        @block.call(text, page)
      end    
    end
  
  end
end
