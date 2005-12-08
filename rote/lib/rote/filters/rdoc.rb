require 'rdoc/markup/simple_markup'
require 'rdoc/markup/simple_markup/to_html'

module Rote
  module Filters
    class RDoc
      def initialize(markup = SM::SimpleMarkup.new, output = SM::ToHtml.new)
        @markup = markup
        @output = output
      end
      
      def filter(text, page)      
        markup.convert(result, output)                      
      end
    end
  end
end 