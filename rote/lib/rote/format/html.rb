#--
# Rote format helper for HTML
# (c)2005 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
#++
require 'erb'

module Rote
  module Format
  
    # HTML Formatting module for Rote. This module may be mixed in to any Page
    # instance to provide various HTML helpers (including those from ERB::Util).
    #
    # To use this module for a given page, simply place the following code
    # somewhere applicable to that page:
    #
    #   extend Format::HTML
    #
    # Note that +include+ cannot be used since the page code is run via
    # +instance_eval+.
    module HTML
      include ERB::Util
      
      ###################################################################
      ## HELPERS
      
      # Make the given output-root-relative path relative to the
      # current page's path. This is handy when you do both local
      # preview from some deep directory, and remote deployment
      # to a root
      def relative(href)
        thr = href
        
        if thr.is_a?(String) && href[0,1] == '/'    # only interested in absolute        
          dtfn = File.dirname(template_name) + '/'
          
          count = dtfn == './' ? 0 : dtfn.split('/').length
          thr = ('../' * count) + href[1..href.length]
        end
        
        thr
      end
          
      alias :link_rel :relative    # Alias 'link_rel' is deprecated, vv0.2.99 v-0.4
    end # HTML
  end # Format
end # Rote
