#--
# Rote filter for Sassy CSS (Sass)
# (c)2013 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
#++

module Rote
  module Filters  
  
    #####
    ## Post filter that runs Sass on the laid-out page to compile CSS from
    ## either SCSS (the default) or SASS syntax.
    ##
    ## Note that this filter requires the 'sass' command, and should be 
    ## added to the +post_filters+ array, in contrast to most of the 
    ## other filters which are page filters.
    ##
    ## If 'sass' isn't in your path you'll need to specify it here or
    ## via a SASSCMD environment variable.
    class Sass
    
      # Create a new filter instance, using the specified output format,
      # and optionally a custom 'tidy' command and options.    
      def initialize(format = :scss, sasscmd = ENV['SASSCMD'], sassopts = '') 
        @sasscmd = sasscmd || (RUBY_PLATFORM =~ /mswin/ ? 'sass.bat' : 'sass')
          # TODO windows 'sass.bat' correct?
          
        @sassopts = sassopts
        @format = format
      end
      
      attr_accessor :format, :sassopts, :sasscmd
      
      def filter(text, page)
        # TODO need to properly capture and log warnings here
        result = IO.popen("#{@sasscmd} #{self.sassopts} #{'--scss' if @format.eql? :scss} --stdin","r+") do |fp|
           Thread.new { fp.write(text); fp.close_write }
           fp.read
        end
        
        if $?.exitstatus < 2
          result
        else
          warn 'sass command failed (exitstatus: $?)'
          text
        end
      end
      
    end
  end
end
  
