#--
# Rote filter for RedCloth
# (c)2005 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
#++

require 'redcloth'

module Rote
  module Filters
    
    #####
    ## Page filter that converts plain-text formatting to HTML using 
    ## RedCloth. This allows both Textile and Markdown formatting
    ## to be used with any page.
    class RedCloth
    
      # Create a new filter instance. The supplied options are passed
      # directly to RedCloth. The most common are :textile and
      # :markdown - See RedCloth docs for a full list.
      #
      # If no options are supplied, :textile is assumed.
      def initialize(*redcloth_opts)
        @redcloth_opts = redcloth_opts
        raise "RedCloth is not available" unless defined?(RedCloth)
      end
      
      def filter(text, page)
        rc = ::RedCloth.new(text)        
        # hack around a RedCloth warning
        rc.instance_eval { @lite_mode = false }  
         
        rc.to_html(*@redcloth_opts) 
      end
    end
    
  end
end
    
