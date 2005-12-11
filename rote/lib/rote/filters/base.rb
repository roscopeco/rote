#--
# Baseclass for Rote filters
# (c)2005 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
#++
module Rote
  module Filters
  
    # Match/extract 
    #
    #   #:code#args# 
    #   ... body ... 
    #   #code# 
    #
    # to :code, args, body
    MACRO_RE = /^\s*\#\:([a-z]+)(?:\#([a-z]*))?\#\s*^(.*?)$\s*\#\:\1\#(?:\2\#)?\s*$/m
    
    #####
    ## Baseclass from which Rote filters can be derived if
    ## they want to process text without macros. This class
    ## replaces macro tags/bodies with simple placeholders,
    ## containing only characters [a-z0-9] before passing
    ## it the text to the block. On return, macro markers 
    ## are replaced with the corresponding (numbered) original
    ## macro body. 
    class TextFilter
      attr_accessor :handler_blk, :macro_data
      
      # Create a new TextFilter. The supplied block will be called
      # with the text to be rendered, with all macros replaced
      # by plain-text macro markers:
      #
      #   { |text, page| "replacement" }
      def initialize(&handler)
        raise ArgumentError, "No block given" unless handler
        @handler_blk = handler
        @macro_data = []
      end
    
      def filter(text, page)
        # we need to remove any macros to stop them being touched
        n = -1        
        tmp = text.gsub(MACRO_RE) do
          macro_data << $&
          # we need make the marker a 'paragraph'
          "\nxmxmxmacro#{n += 1}orcamxmxmx\n"
        end
        
        tmp = handler_blk[tmp,page]
      
        # Match the placeholder, including any (and greedily all) markup that's
        # been placed before or after it, and put the macro text back.
        tmp.gsub(/(?:<.*>)?xmxmxmacro(\d+)orcamxmxmx(?:<.*>)?/) { @macro_data[$1.to_i] }      
      end    
    end
    
    #####
    ## Baseclass from which Rote filters can be derived if
    ## you want some help with macro replacement.
    class MacroFilter
    
      # An array of macro names supported by this filter.
      attr_accessor :macros
      
      # Block that will be called for each supported macro
      # in the filtered text. Like:
      #
      #   { |macro, args, body| "replacement" }      
      attr_accessor :handler_blk
      
      # Create a new macro filter. The supplied three-arg block
      # will be called for each macro with a name that exists
      # in the +macros+ array.
      def initialize(macros = [], code_re = MACRO_RE, &handler_blk)
        raise ArgumentError, "No block given" unless handler_blk
        @handler_blk = handler_blk
        @macros = macros  
        @code_re = code_re
      end      
           
      def filter(text,page)
        # Just go through, subbing with block if this is
        # our macro, or with the original match if not.
        text.gsub(@code_re) do
          if handler_blk && macros.detect { |it| it.to_s == $1 }
            handler_blk[$1,$2,$3]
          else
            $&
          end        
        end
      end
    end
  end
end
      