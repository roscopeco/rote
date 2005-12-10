#--
# Rote filter for TOC generation
# (c)2005 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
#++

module Rote
  module Filters
  
    #####
    ## Page filter that supports easy construction of a Table Of Contents
    ## from your *layout*. This filter does not modify the text - instead
    ## it searches for tags matching the specified regular expression(s)
    ## (H tags by default), and stores them to be used for TOC generation
    ## in the layout.
    ##
    ## Additional attributes for the A tags can be passed via the +attrs+
    ## parameter.
    class TOC
      def initialize(tags_re = /h\d+/, attrs = {})
        @tags_re = tags_re
        @attrs = attrs
        @index = []
      end
   
      # Array of headings matching the tags regular expression.
      # Each entry is [tag,anchor,content].
      attr_reader :index
   
      # Returns an array of hyper link tags with the
      # heading title as the link text. Suitable
      # for joining and outputting:
      #
      #   <%= links.join(" - ") %>
      def links
        index.map do |tag,anchor,title|
          %Q[<a #{"#{(@attrs.collect { |k,v| "#{k}='#{v}'" }).join(' ')} " unless @attrs.empty?}href='##{anchor}'>#{title}</a>]
        end
      end
   
      def filter(text, page)
        # find headings *and insert named anchors*
        text.gsub(%r[<(#{@tags_re})>(.*?)</\1>]) do
          anchor = title_to_anchor($2)
          @index << [$1,anchor,$2]
          %Q[<a name='#{anchor}'></a>#{$&}]
        end        
      end
   
      private
      # Create an anchor by converting the content to a simple
      # text string.
      def title_to_anchor(title)
        title.downcase.gsub(/[^a-z]+/,'_')
      end
    end
    
  end
end