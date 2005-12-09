#--
# Rote filter with syntax highlighting
# (c)2005 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
#++
  
require 'syntax'
require 'syntax/convertors/html'

module Rote
  module Filters
    
    #####
    ## Page filter that supports syntax highlighting for Ruby code
    ## via the +Syntax+ library. Code is expected to be in the 
    ## following format:
    ##
    ##   {code:ruby}
    ##     def amethod(arg)
    ##       puts arg
    ##     end
    ##   {code}
    ##  
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