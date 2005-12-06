# Rote format helper for HTML
# (c)2005 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
require 'erb'

module Rote
  module Format
  
    # HTML Formatting module for Rote. This module may be mixed in to any Page
    # instance to provide support for plain-text formatting amd various HTML 
    # helpers (including those from ERB::Util).
    #
    # To use this module for a given page, simply place the following code
    # somewhere applicable to that page:
    #
    #   extend Format::HTML
    #
    # Note that *include* cannot be used since the page code is run via
    # +instance_eval+.
    module HTML
      include ERB::Util
      
      ###################################################################
      ## FORMATTING    
      
      # Get current formatting options for this page. If none have been
      # set, the default ([], which means 'No formatting') is returned.
      # This setting does not affect ERB rendering (which is always 
      # performed, before any formatting).
      def format_opts
        @format_opts ||= []
      end
      
      # Set Formatting options for this page. This is an array of the
      # option symbols, as defined by RedCloth, with a further *rdoc*
      # symbol that selects RDoc formatting. The most common are 
      # :textile. :markdown, and :rdoc, but additional options are
      # supported by RedCloth - see it's documentation for full details
      # of supported option symbols and their effect.
      def format_opts=(opts)
        if !opts.nil? && opts.respond_to?(:to_ary)
          @format_opts = opts
        else
          @format_opts = [opts]
        end
      end
      
      # HTML-supporting 'render_fmt'. Page calls this method to do
      # any format-specific rendering, after ERB and before layout.
      # Here we support the plaintext markup.
      def render_fmt(text)
        result = text
      
        # need to get opts to a known state (array), and copy it
        # so we can modify it.
        if format_opts && ((format_opts.respond_to?(:to_ary) && (!format_opts.empty?)) || format_opts.is_a?(Symbol)) 
          opts = format_opts.respond_to?(:to_ary) ? format_opts.dup : [format_opts] 
            
          # Remove :rdoc opts from array (RedCloth doesn't do 'em) 
          # and remember for after first rendering...
          #
          # Cope with multiple occurences of :rdoc
          unless (rdoc_opt = opts.grep(:rdoc)).empty?
            opts -= rdoc_opt
          end
            
          # Render out RedCloth / markdown
          unless opts.empty?
            if defined?(RedCloth)
              rc = RedCloth.new(result)
              rc.instance_eval { @lite_mode = false }   # hack around a warning
              result = rc.to_html(*opts) 
            else
              puts "WARN: RedCloth options specified but no RedCloth installed"
            end
          end
            
          # Render out Rdoc
          #
          # TODO could support alternative output formats by having the user supply
          #      the formatter class (ToHtml etc).         
          unless rdoc_opt.empty?
            p = SM::SimpleMarkup.new
            h = SM::ToHtml.new
            result = p.convert(result, h)                      
          end
        end
        
        result
      end
      
      ###################################################################
      ## HELPERS
      
      # Make the given output-root-relative path relative to the
      # current page's path. This is handy when you do both local
      # preview from some deep directory, and remote deployment
      # to a root
      def relative(href)
        thr = href
        
        if thr.is_a?(String) && href[0,1] == '/'    # only interested in absolute        
          dtfn = File.dirname(template_fn) + '/'
          
          count = dtfn == './' ? 0 : dtfn.split('/').length
          thr = ('../' * count) + href[1..href.length]
        end
        
        thr
      end
          
      alias :link_rel :relative    # Alias 'link_rel' is deprecated, vv0.2.99 v-0.4
    end # HTML
  end # Format
end # Rote
