require 'syntax'
require 'syntax/convertors/html'

module Rote
  module Filters
  
    class Syntax
      CODE_RE = /\{code(?:\:?(\w+))?\}(.*?)\{\/?code\}/m
      
      def filter(text, page)        
        text.gsub(CODE_RE) do
          converter = ::Syntax::Convertors::HTML.for_syntax($1)
          "<pre><code>#{converter.convert($2,false)}</code></pre>"
        end
      end    
    end
    
  end 
end