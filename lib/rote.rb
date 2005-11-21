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
require 'rake'
require 'page'

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
## See LICENSE.txt for details.
module Rote
  ## Gets target filename for a resource
  def target_res_fn(fn)
    fn.sub(/^site\/res/,'target')
  end
  
  def target_page_fn(fn)
    Rote::Page.target_fn(fn)
  end
  
  ## Build up our file tasks for pages
  def define_file_targets(pages)
    targs = FileList.new
      
    pages.each { |fn|
      htm = Rote.target_page_fn(fn)
              
      # define task to transform this file
      desc "<< #{fn}"
      file htm => [fn] do
        transform(fn, htm)
      end
        
      # Add to TARGETS array
      targs += [htm]
    }
        
    return targs
  end
  
  ## Transforms a single document
  def transform(src, dest)
    puts "Transforming #{src} to #{dest}"  
    
    # assure directory exists
    mkdir_p(File.dirname(dest))
    
    # do it
    File.open(dest, 'w+') { |f|
      f << Page.new(src).to_html  
    }  
  end
  
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