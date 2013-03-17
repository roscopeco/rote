#--
# Require all formats
# (c)2005 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
#++

Dir[File.join(File.dirname(__FILE__), 'format/*.rb')].each { |f| require f }
