#--
# Rote filter that runs macro body as code.
# (c)2005, 2006 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id: syntax.rb 135 2005-12-12 15:01:07 +0000 (Mon, 12 Dec 2005) roscopeco $
#++

require 'stringio'
require 'rote/filters/base'

module Rote
  module Filters
    
    #####
    ## Page filter that evaluates Ruby code in it's body in the
    ## current interpreter. The code is directly evaluated, and
    ## anything it writes to standard out becomes the macro
    ## replacement.
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
        # no need to fiddle with $SAFE here is there?
        
        # FIXME this is a hack.
        
        # Utility is still limited I guess, since current Page isn't
        # readily available to the macro code. We can probably fix
        # that though.
        
        # If thread safety becomes an issue, this'll probably need 
        # to be critical sectioned.
        
        begin
          oldsio, $stdout = $stdout, StringIO.new
          eval body        
          $stdout.rewind
          $stdout.read
        ensure
          $stdout = oldsio
        end
      end      
    end      
  end 
end