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
    class Syntax < Filter
      # Create a new syntax highlight filter that uses the specified regular
      # expression to recognise and process code blocks. See +Base+ for 
      # the regex requirements.
      def initialize(code_re = MACRO_RE)
        super([:code],code_re) do |name,lang,body|
          converter = ::Syntax::Convertors::HTML.for_syntax(lang)
          "<div class='#{lang}'><pre><code>#{converter.convert(body,false)}</code></pre></div>"
        end
      end
    end      
  end 
end