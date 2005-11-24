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

require 'net/ftp'
require 'rubygems'
require_gem 'rake'

require 'rote/rotetasks'

# Master Rote version. Manage this from the Rake release support.
ROTEVERSION = 0.1

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
## Rote is (c)2005 Ross Bamford, and is licensed under an MIT license. 
## See LICENSE for details.
module Rote

  private

  ####################################################
  ## WILL BE REMOVED...                             ##
  ##                   ...I SAID, "WILL BE REMOVED" ##
  ####################################################
  
  def ftp_putdir(dir, ftp_host, ftp_user, ftp_pass = nil, ftp_root = '/')  
    f = Net::FTP.new(ftp_host, ftp_user, ftp_pass)
    f.passive = true
    
    Dir[dir + '/**/*'].sort.each { |fn|    
      # pretty f*cking trick - it's replacing the local 'target' or whatever prefix 
      # with remote root ;)
      rfn = fn.dup
      rfn[dir] = ftp_root
      
      if File.directory?(fn) 
        puts "Creating remote directory #{rfn}"
        begin
          f.mkdir(rfn)
        rescue
          # forget it then, already exists prob'ly
          # TODO maybe should raise if $! != FTP 550?
        end
      else

        # TODO continue on error perhaps
        puts "Uploading #{fn} => #{rfn}"
        f.put(fn,rfn)        
      end
    }
    
    f.close   
  end 
end 
