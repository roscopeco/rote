#--
# Rote filter with syntax highlighting
# (c)2005 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id: syntax.rb 135 2005-12-12 15:01:07 +0000 (Mon, 12 Dec 2005) roscopeco $
#++
  
require 'syntax'
require 'syntax/convertors/html'
require 'rote/filters/base'

module Rote
  module Filters
    
    #####
    ## Page filter that runs it's body through the specified
    ## command, and captures the output. This was originally
    ## intended to support delayed excution of Ruby code
    ## as follows:
    ##
    ##   #:eval#ruby#
    ##     puts "Hello, World!"
    ##   #:eval#
    ## 
    ## But it can also be used with any external command:
    ##
    ##   #:eval#python#
    ##     print "Hello, World!"
    ##   #:eval#
    ## 
    ## ===== Why use 'eval' with Ruby code?
    ##
    ## Obviously you can place Ruby code directly in your pages,
    ## using ERB, and for many cases that is the route you should
    ## take. There is a (somewhat) subtle difference between the
    ## to alternatives however: ERB is always evaluated right 
    ## at the start of rendering, before any Text Filters are
    ## run, whereas #:eval# code is executed during the page filter
    ## stage, which happens after ERB and text filtering, but
    ## before layout is applied.
    ## 
    class Eval < MacroFilter
      def initialize(macro_re = MACRO_RE)
        super([],macro_re)
      end      
      
      def macro_eval(cmd,body,raw)
        res = IO.popen(cmd, 'w+') do |io|
          Thread.new { io.write body; io.close_write }
          io.read
        end
      end      
    end      
  end 
end