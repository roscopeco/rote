# rote.rb - main Rote module  
# Copyright (c) 2005 Ross Bamford (and contributors)
# $Id$
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in 
# the Software without restriction, including without limitation the rights to 
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# See Rote for full documentation

# require these before gems, because we want to use them from
# lib/ , or from normal install, if that's how Rote was started.
# 
# If rote has been loaded through Gems, this will automatically
# come from the right lib directory...

require 'rote/rotetasks'
require 'rote/page'

# Everything else should come first from Gems, if installed.
begin
  require 'rubygems'
rescue LoadError
  nil   # just try without then...
end  

require 'rake'

# Master Rote version. Manage this from the Rake release support.
ROTEVERSION = '0.2.999'

#####
## *Rote* is a Rake (http://rake.rubyforge.org) based build tool for static
## page-based documentation, websites, and general textual templates.
## It enables embedded Ruby code, layout, and optionally plain-text formatting
## (HTML-only at present) to be used to automatically generate output in any
## (textual) format from a directory tree containing template files.
##
## Rote was created for my personal website, but has become a fairly flexible
## tool, general enough to be applied to many different types of templating.
## Rote can handle your software documentation, blog-plus sites,
## and even (slower-moving) news and information sites.
##
## Rote can be used from the command-line, or in your own +Rakefile+. It
## supports both manual and automatic rendering of modified resources, and
## can be configured to monitor your source tree for changes.
##
## See +README+ for general usage information. Rote::DocTask documents the
## Rake task integration, while Rote::Page has information useful to template
## writers.
##
## Rote is (c)2005 Ross Bamford (and contributors). See +LICENSE+ for details.
## This documentation refers to Rote version #{ROTEVERSION}
module Rote

  # this space intentionally left blank

end 
