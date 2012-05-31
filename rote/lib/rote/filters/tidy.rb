#--
# Rote filter for HTML Tidy
# (c)2005 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
#++

module Rote
  module Filters  
  
    #####
    ## Post filter that runs HTML Tidy on the laid-out page to correct and
    ## clean up HTML in the output. This filter can be used with any of
    ## the _asXXXX_ formats supported by Tidy. 
    ##
    ## Note that this filter requires the 'tidy' command, and should be 
    ## added to the +post_filters+ array, in contrast to most of the 
    ## other filters which are page filters.
    ##
    ## If 'tidy' isn't in your path you'll need to specify it here or
    ## via a TIDYCMD environment variable.
    class Tidy
    
      # Create a new filter instance, using the specified output format,
      # and optionally a custom 'tidy' command and options.    
      def initialize(format = :xhtml, tidycmd = nil, tidyopts = '-q') 
        @tidycmd = tidycmd || ENV['TIDYCMD'] || (RUBY_PLATFORM =~ /mswin/ ? 'tidy.exe' : 'tidy')
          # TODO windows 'tidy.exe' correct?
          
        @tidyopts = tidyopts
        @format = format
      end
      
      attr_accessor :format, :tidyopts, :tidycmd
      
      def filter(text, page)
        # TODO need to properly capture and log warnings here
        result = IO.popen("#{@tidycmd} #{self.tidyopts} -f tidy.log -as#{self.format}","r+") do |fp|
           Thread.new { fp.write(text); fp.close_write }
           fp.read
        end
        
        if $?.exitstatus < 2
          result
        else
          warn 'Tidy command failed (exitstatus: $?)'
          text
        end
      end
      
    end
  end
end
  
