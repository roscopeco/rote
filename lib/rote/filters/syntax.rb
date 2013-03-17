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
    ## Page filter that supports syntax highlighting for Ruby code,
    ## XML and YAML via the (extensible) Syntax (http://syntax.rubyforge.org/)
    ## library. Code is expected to be enclosed by the +code+ macro:
    ##
    ##   #:code#ruby#
    ##     def amethod(arg)
    ##       puts arg
    ##     end
    ##   #:code#
    ##
    ## Where the macro argument may be 'ruby', 'xml', 'yaml', or a
    ## custom identifier registered (with Syntax) for a custom highlighter.
    ## 
    ## The macro output will resemble:
    ##
    ##   <pre class='#{lang}'><code class=#{lang}'>
    ##     ...
    ##   </code></pre>
    ##
    ## Syntax uses <span> tags for highlighting, with CSS classes used to apply
    ## formatting. See http://syntax.rubyforge.org/chapter-2.html for a list
    ## of recognised classes.
    ##
    class Syntax < MacroFilter
      def initialize(macro_re = MACRO_RE)
        super([],macro_re)
      end      
      
      # Implementation of the +code+ macro.
      def macro_code(lang,body,raw)
        converter = ::Syntax::Convertors::HTML.for_syntax(lang)
        "<pre class='#{lang}'><code class='#{lang}'>#{converter.convert(body,false)}</code></pre>"
      end      
    end      
  end 
end