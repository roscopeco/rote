#--
# Rote filter that passes body to an external command
# (c)2005, 2006 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id: syntax.rb 135 2005-12-12 15:01:07 +0000 (Mon, 12 Dec 2005) roscopeco $
#++
  
require 'rote/filters/base'

module Rote
  module Filters
    
    #####
    ## Page filter that runs it's body through the specified
    ## command, and captures the output. E.g.:
    ##
    ##   #:exec#python#
    ##     print "Hello, World!"
    ##   #:exec#
    ## 
    ## Although this filter can be used to execute Ruby code,
    ## you must bear in mind that this will happen in a separate
    ## interpreter process, so no variables or requires from the
    ## current environment will be available.
    ## If you wish to evaluate Ruby code in your pages, you should
    ## use either ERB (evaluated at the beginning of the render),
    ## or the Eval filter (evaluated near the end).
    class Exec < MacroFilter
      def initialize(macro_re = MACRO_RE)
        super([],macro_re)
      end      
      
      def macro_exec(cmd,body,raw)
        res = IO.popen(cmd, 'w+') do |io|
          Thread.new { io.write body; io.close_write }
          io.read
        end
      end      
    end      
  end 
end