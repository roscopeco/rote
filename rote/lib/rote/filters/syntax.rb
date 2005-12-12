#--
# Rote filter with syntax highlighting
# (c)2005 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
#++
  
require 'syntax'
require 'syntax/convertors/html'
require 'rote/filters/base'

module Rote
  module Filters
    
    #####
    ## Page filter that supports syntax highlighting for Ruby code
    ## via the +Syntax+ library. Code is expected to be in the 
    ## following format:
    ##
    ##   #:code#ruby#
    ##     def amethod(arg)
    ##       puts arg
    ##     end
    ##   #:code#
    ##  
    class Syntax < MacroFilter
      def initialize(macro_re = MACRO_RE)
        super([],macro_re)
      end      
      
      def macro_code(lang,body,raw)
        converter = ::Syntax::Convertors::HTML.for_syntax(lang)
        "<pre class='#{lang}'><code>#{converter.convert(body,false)}</code></pre>"
      end      
    end      
  end 
end