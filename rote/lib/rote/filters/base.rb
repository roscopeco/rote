#--
# Baseclass for Rote filters
# (c)2005 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
#++
module Rote
  module Filters
  
    # Match/extract #:code#args# on it's own line => :code, args
    MACRO_RE = /^\s*\#\:([a-z]+)(?:\#([a-z]*))?\#\s*^(.*?)$\s*\#\:\1\#(?:\2\#)?\s*$/m
    
    #####
    ## Baseclass from which Rote filters can be derived if
    ## you want some help with macro replacement.
    class Filter
    
      # An array of macro names supported by this filter.
      attr_accessor :macros
      
      # Block that will be called for each supported macro
      # in the filtered text. Like:
      #
      #   { |macro, args, body| "replacement" }      
      attr_accessor :handler
      
      def initialize(macros = [], code_re = MACRO_RE, &handler)
        @handler = handler
        @macros = macros  
        @code_re = code_re
      end      
           
      def filter(text,page)
        # Just go through, subbing with block if this is
        # our macro, or with the original match if not.
        text.gsub(@code_re) do
          if handler && macros.detect { |it| it.to_s == $1 }
            handler[$1,$2,$3]
          else
            $&
          end        
        end
      end
    end
  end
end
      