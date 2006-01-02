#--
# Rote filter for RedCloth
# (c)2005 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
#++

require 'redcloth'
require 'rote/filters/base'

module Rote
  module Filters
    #####
    ## Page filter that converts Textile formatting to HTML using 
    ## RedCloth. 
    ##
    ## *Note* that, although RedCloth provides partial Markdown
    ## support, it is *highly recommended* that the BlueCloth
    ## filter be applied to markdown pages instead of this one.
    class RedCloth < TextFilter
    
      # Create a new filter instance. The supplied options are passed
      # directly to RedCloth. See RedCloth docs for a full list.
      #
      # If no options are supplied, full textile support is 
      # provided.
      def initialize(*redcloth_opts)
        super()  
        @redcloth_opts = redcloth_opts
      end      
      
      def handler(text,page)
        rc = ::RedCloth.new(text)        
        # hack around a RedCloth warning
        rc.instance_eval { @lite_mode = false }  
        rc.to_html(*@redcloth_opts) 
      end      
    end    
  end
end
    
