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
    ## from your *layout*. This filter searches for tags matching the 
    ## specified regular expression(s) (H tags by default), and stores them
    ## to be used for TOC generation in the layout. HTML Named-anchors are
    ## created based on the headings found.
    ##
    ## Additional attributes for the A tags can be passed via the +attrs+
    ## parameter.
    class TOC
    
      # An individual Heading in the +links+ array.
      class Heading
        class << self
          alias :[] :new
        end
        
        def initialize(tag, title, attrs = {})
          @tag = tag
          @title = title   
          @attrs = attrs               
        end        
        
        # The information held by this link
        attr_accessor :tag, :title, :attrs
        
        def anchor
          title.downcase.gsub(/[^a-z]+/,'_')
        end
        
        def to_s
          %Q[<a #{"#{(attrs.collect { |k,v| "#{k}='#{v}'" }).join(' ')} " unless attrs.empty?}href='##{anchor}'>#{title}</a>]        
        end
      end

      def initialize(tags_re = /h\d+/, attrs = {})
        @tags_re = tags_re
        @attrs = attrs
        @headings = []
      end
      
      # Array of heading links with the
      # heading title as the link text. Suitable
      # for joining and outputting:
      #
      #   <%= links.join(" - ") %>
      #
      # *Note* that this isn't populated until after
      # the filter is run.
      attr_reader :headings
      alias :links :headings
      alias :index :headings      # Compat alias  vv0.2.999 v-0.3
   
      def filter(text, page)
        # find headings *and insert named anchors*
        text.gsub(%r[<(#{@tags_re})>(.*?)</\1>]) do
          headings << (h = Heading[$1,$2])
          %Q[<a name='#{h.anchor}'></a>#{$&}]
        end        
      end   
    end
    
  end
end