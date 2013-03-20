#--
# Rote filter for Haml
# (c)2013 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
#++

require 'haml'
require 'rote/filters/base'

module Rote
  module Filters
    #####
    ## Page filter that converts HAML to HTML.
    class Haml < TextFilter
    
      # Create a new filter instance.
      def initialize(haml_opts = {}, &block)
        @haml_opts = haml_opts
        @block = block
        super()  
      end      
      
      def handler(text,page)
        rc = ::Haml::Engine.new(text, @haml_opts)
        rc.to_html(page, &@block)
      end      
    end 
  end
end
    
