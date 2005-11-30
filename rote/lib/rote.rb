# rote.rb - main Rote module  
# Copyright (c) 2005 Ross Bamford (and contributors)
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

require 'net/ftp'
require 'rake'

# Master Rote version. Manage this from the Rake release support.
ROTEVERSION = '0.1.7'

#####
## *Rote* is a Rake (http://rake.rubyforge.org) based build tool for page-based
## static websites that enables layout, textile formatting, and ERB to be used
## to automatically generate your site, and can handle uploading the site 
## to your (host's) server.
##
## Rote was created for my personal site, but is general enough to be applied
## to many different types of website, including basic blog-plus sites,
## slower-moving news and information sites, and software documentation.
##
## See +README+ for general usage information. +Rote::DocTask+ documents the
## Rake task integration, while +Rote::Page+ has information useful to template
## writers.
##
## Rote is (c)2005 Ross Bamford. See +LICENSE+ for details.
module Rote

  # this space intentionally left blank

end 
