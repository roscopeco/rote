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
        # we need to remove any macros to stop them being touched
        macros = []
        n = -1
        
        tmp = text.gsub(MACRO_RE) do
          macros << $&
          "xmxmxmacro#{n += 1}orcamxmxmx"
        end
        
        rc = ::RedCloth.new(tmp)        
        # hack around a RedCloth warning
        rc.instance_eval { @lite_mode = false }  
        tmp = rc.to_html(*@redcloth_opts) 
        tmp.gsub(/xmxmxmacro[0-9]+orcamxmxmx/) { macros[$1.to_i] }
      end
    end
    
  end
end
    
