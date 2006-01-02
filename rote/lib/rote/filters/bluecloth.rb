#--
# Rote filter for BlueCloth
# (c)2005 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
#++

require 'bluecloth'
require 'rote/filters/base'

module Rote
  module Filters
    #####
    ## Page filter that converts markdown formatting to HTML using 
    ## BlueCloth.
    class BlueCloth < TextFilter
    
      # Create a new filter instance. The supplied restrictions (if any)
      # are passed directly to BlueCloth. See BlueCloth docs for 
      # details of supported restrictions.
      #
      # If a block is supplied, it will be passed the BlueCloth string
      # at render time, along with the page being rendered. It is 
      # expected to return the rendered content.
      # If no block is supplied, to_html is called implicitly.
      def initialize(*restrictions, &blk)
        super()  
        @restrictions = restrictions
        @blk = blk || lambda { |bc, page| bc.to_html }
      end      
      
      def handler(text,page)
        bc = ::BlueCloth.new(text)
        @blk.call(bc, page)
      end      
    end    
  end
end
    
