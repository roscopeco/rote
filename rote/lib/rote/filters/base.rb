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
    MACRO_RE = /^\s*\#\:([a-z]+)(?:\#([a-z]*))?\#\s*?\n?(.*?)\s*\#\:\1\#(?:\2\#)?\s*$/m
    PLACEHOLDER_RE = /(?:<[^>]*>)?xmxmxmacro(\d+)orcamxmxmx(?:<[^>]*>)?/
    
    #####
    ## Baseclass from which Rote filters can be derived if
    ## they want to process text without macros. This class
    ## replaces macro tags/bodies with simple placeholders,
    ## containing only characters [a-z0-9] before passing
    ## it the text to the block. On return, macro markers 
    ## are replaced with the corresponding (numbered) original
    ## macro body. 
    class TextFilter
      attr_accessor :handler_blk, :macros
      
      # Create a new TextFilter. The supplied block will be called
      # with the text to be rendered, with all macros replaced
      # by plain-text macro markers:
      #
      #   { |text, page| "replacement" }
      def initialize(&handler)
        @handler_blk = handler
        @macros = []
      end
    
      def filter(text, page)
        # we need to remove any macros to stop them being touched
        n = -1        
        tmp = text.gsub(MACRO_RE) do
          macros << $&
          # we need make the marker a 'paragraph'
          "\nxmxmxmacro#{n += 1}orcamxmxmx\n"
        end
        
        tmp = handler(tmp,page)
      
        # Match the placeholder, including any (and greedily all) markup that's
        # been placed before or after it, and put the macro text back.
        tmp.gsub(PLACEHOLDER_RE) { macros[$1.to_i] }      
      end  
      
      protected
            
      # Calls the handler block. Subclasses may override this rather
      # than use a block.
      def handler(tmp,page)
        handler_blk[tmp,page] if handler_blk
      end  
    end
    
    #####
    ## Baseclass from which Rote filters can be derived if
    ## you want some help with macro replacement.
    ##
    ## There are three ways to make a macro filter:
    ##
    ## * Subclass this class, and provide +macro_name+ 
    ##   methods where +name+ is the macro name. These
    ##   methods receive args (args, body, raw_macro)    
    ##
    ## * Create an instance of this class with a block
    ##   taking up to four arguments
    ##   (name,args,body,raw_macro)
    ##
    ## * Subclass this class and override the +handler+
    ##   method to process all macros.
    ##
    class MacroFilter
    
      # An array of macro names supported by this filter.
      # This can be used to selectively disable individual
      # macro support.
      attr_accessor :names
      
      # Block that will be called for each supported macro
      # in the filtered text. Like:
      #
      #   { |macro, args, body, raw_macro| "replacement" }
      #
      # The presence of a block precludes the use of any
      # +macro_xxxx+ methods on the subclass.      
      attr_accessor :handler_blk
      
      # Create a new macro filter. If a three-arg block is passed,
      # it will be called for each macro with a name that exists
      # in the +macros+ array. Otherwise, macros will be sought
      # as methods (e.g. +macro_code+). If an array of names isn't
      # passed, a search such methods will be used to populate
      # the names array.
      def initialize(names = [], code_re = MACRO_RE, &block)
        @names = (names || []).map { |n| n.to_s }
        @block = block
        @code_re = code_re
      end
     
      def filter(text,page)
        text.gsub(@code_re) { handler($1,$2,$3,$&) || $& }
      end
      
      # You may override this method if you want to completely
      # override the standard macro dispatch.      
      def handler(macro,args,body,all)
        if @names.include?(macro) then
          @block[macro,args,body,all]
        elsif respond_to?(meth = "macro_#{macro}") then
          self.send(meth,args,body,all)
        else
          nil
        end
      end
    end
  end
end
      