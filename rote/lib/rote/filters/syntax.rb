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
      DEFAULT_CODE_RE = /\{code(?:\:?(\w+))?\}(.*?)\{\/?code\}/m
      
      # Create a new syntax highlight filter that uses the specified regular
      # expression to recognise and process code blocks.
      # The expression supplied must have two capturing groups, the
      # first returning the code language (i.e. 'ruby') and the second
      # returning the actual code.
      def initialize(code_re = DEFAULT_CODE_RE)
        @code_re = code_re
      end
      
      def filter(text, page)        
        text.gsub(@code_re) do
          converter = ::Syntax::Convertors::HTML.for_syntax($1)
          "<pre><code>#{converter.convert($2,false)}</code></pre>"
        end
      end    
    end
    
  end 
end