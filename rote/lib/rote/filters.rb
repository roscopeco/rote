#--
# Require all filters
# (c)2005, 2006 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
#++

# This now requires conservatively, ignoring any filters that
# throw a LoadError. This allows a simple 'require filters' to
# be used to load all filters _for which dependencies are
# available_.

# will require 'base' but it'd get required anyway...
Dir[File.join(File.dirname(__FILE__), 'filters/*.rb')].each do |fn|
  begin
    require fn
  rescue LoadError

    # ignore, different filters require different library
    # support.

  end
end
