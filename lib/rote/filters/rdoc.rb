#--
# Rote page class
# (c)2005 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
#++

require 'rote/filters/base'
require 'rdoc/markup'
require 'rdoc/markup/to_html'

module Rote
  module Filters
  
    #####
    ## Page filter supporting RDoc markup.     
    class RDoc < TextFilter
      def initialize(markup = ::RDoc::Markup::ToHtml.new)
        @markup = markup
        self.handler_blk = proc { |text,page| @markup.convert(text) }
      end      
    end
  end
end 