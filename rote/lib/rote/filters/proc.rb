#--
# Rote filter with block / proc
# (c)2005 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
#++

module Rote
  module Filters
    
    #####
    ## Page filter that allows a supplied block to be invoked
    ## as a +filter+ method.
    class Proc

      #--
      # Alias didn't show in the rdoc?      
      #++
      # _Alias_ _for_ +new+
      def Proc.with(&block)
        new(&block)
      end
            
      # Create a new Proc filter with the specified block.
      # The block must accept two arguments (the source text, and the
      # enclosing +Page+ instance) and return the filtered output.
      def initialize(&block)
        raise ArgumentError, "No block given" unless block
        @block = block      
      end
      
      def filter(text, page)
        @block.call(text, page)
      end    
    end
  
  end
end
