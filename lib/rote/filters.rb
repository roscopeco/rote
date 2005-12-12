#--
# Require all filters
# (c)2005 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
#++

# will require 'base' but it'd get required anyway...
Dir[File.join(File.dirname(__FILE__), 'filters/*.rb')].each { |f| require f }
