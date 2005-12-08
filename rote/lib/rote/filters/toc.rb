module Rote
  module Filters
  
    class TOC
      def initialize(tags_re = /h\d+/)
        @tags_re = tags_re
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
          %Q[<a href='##{anchor}'>#{title}</a>]
        end
      end
   
      def filter(text, page)
        # find headings
        text.scan(%r[<(#{@tags_re})>(.*?)</\1>]) do
          anchor = title_to_anchor($2)
          @index << [$1,anchor,$2]
          %Q[<a name='#{anchor}'></a>#{$&}]
        end
        
        # return original
        text
      end
   
      private
      # Create an anchor by converting the content to a simple
      # text string.
      def title_to_anchor(title)
        title.downcase.gsub(/[^a-z]/,'_').squeeze('_')
      end
    end
    
  end
end