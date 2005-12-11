#--
# Rote filter with block / proc
# (c)2005 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
#++

require 'rote/filters/base'

module Rote
  module Filters
    
    #####
    ## Page filter that allows a supplied block to be invoked
    ## as a +text filter+. The block should take two arguments:
    ##
    ##   { |text, page| "replacement" }
    class Proc < TextFilter
      #--
      # Alias didn't show in the rdoc?      
      #++
      # _Alias_ _for_ +new+
      def Proc.with(&block)
        new(&block)
      end
            
      # Create a new Proc filter with the specified block.
      def initialize(&block)
        raise ArgumentError, "No block given" unless block
        super(&block)
      end      
    end
  
  end
end
