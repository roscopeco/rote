#--
# Rote format helper for HTML
# (c)2005 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
#++
require 'erb'

module Rote
  module Format
  
    # HTML Formatting module for Rote. This module may be mixed in to any Page
    # instance to provide various HTML helpers (including those from ERB::Util).
    #
    # To use this module for a given page, simply place the following code
    # somewhere applicable to that page:
    #
    #   extend Format::HTML
    #
    # Note that +include+ cannot be used since the page code is run via
    # +instance_eval+.
    module HTML
      include ERB::Util
      
      ###################################################################
      ## HELPERS
      
    end # HTML
  end # Format
end # Rote
