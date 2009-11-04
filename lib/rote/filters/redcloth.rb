#--
# Rote filter for RedCloth
# (c)2005, 2006 Ross Bamford (and contributors)
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
    
    # Redcloth filter that adds a table of contents at the top of the given text 
    # and sufficent hyperlinks to access the various headings in the text. This
    # can be used instead of the standard TOC filter to get TOC capabilities 
    # during page (rather than layout) rendering.
    # 
    # Contributed by Suraj Kurapati.
    class RedCloth_WithToc < RedCloth
      Heading = Struct.new(:depth, :anchor, :title) unless const_defined?(:Heading)
 
      def handler text, *args
        # determine structure of content and insert anchors where necessary
          headings = []
 
          text = text.gsub(/^(\s*h(\d))(.*?)(\.(.*))$/) do
          target = $~.dup
 
           if target[3] =~ /#([^#]+)\)/
             anchor = $1
             result = target.to_s
           else
             anchor = headings.length
             result = "#{target[1]}#{target[3]}(##{anchor})#{target[4]}"
           end
 
           headings << Heading.new( target[2].to_i, anchor, target[5] )
           result
         end
 
         # add table of contents at top of text
         toc = headings.map do |h|
           %{#{'*' * h.depth} "#{h.title}":##{h.anchor}}
         end.join("\n")
 
         text.insert 0, "\n\n\n"
         text.insert 0, toc
 
         super text, *args
       end
     end    
  end
end
    
