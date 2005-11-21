# Rakefile - Umm, the Rakefile, I guess...
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

require 'rake'
require 'rake/clean'
require 'yaml'
require 'erb'

require 'rote'
include Rote

PAGES = FileList['site/pages/**/*.rhtml']
TARGETS = define_file_targets(PAGES)
RES_INCLUDE = ['*.png','*.css','*.gif','*.jpg','*.jpeg','*.txt','*.groovy','*.tar.gz','*.zip']
CLEAN[CLEAN.length] = 'target'
RES = FileList.new { |fl| 
  RES_INCLUDE.each { |it| fl.include 'site/res/**/' + it }
}

#######################################
## Load config
if (File.exists?('config.rb'))
  eval(File.read('config.rb'), binding)
else
  puts "Warning: config.rb not found"  
end

#######################################
## 
## STATIC TASKS
##
## Default to doing the index
task :default => [:site]

## Build all targets
desc 'Transform all pages, and copy resources'
task :site => TARGETS + [:resources]

if (defined?(@ftp_host) && defined?(@ftp_user))
  @ftp_pass = nil unless defined?(@ftp_pass)
  
  desc 'Upload (FTP)'
  task :upload => :site do
    ftp_putdir('target', @ftp_host, @ftp_user, @ftp_pass, @ftp_root)
  end
end

## Copy the resources
desc 'Copy resources to the target'
task :resources do
  RES.each { |src|
    dest = target_res_fn(src)
    mkdir_p(File.dirname(dest))    
    cp_r(src,dest)            
  }  
end
