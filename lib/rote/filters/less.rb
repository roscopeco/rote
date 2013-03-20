#--
# Rote filter for LESS CSS
# (c)2013 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
#++

module Rote
  module Filters  
  
    #####
    ## Post filter that runs lessc on the laid-out page to compile CSS from
    ## LESS syntax.
    ##
    ## Note that this filter requires the 'lessc' command, and should be 
    ## added to the +post_filters+ array.
    ##
    ## If 'lessc' isn't in your path you'll need to specify it here or
    ## via a LESSCMD environment variable.
    class Less
    
      # Create a new filter instance, using the specified output format,
      # and optionally a custom 'tidy' command and options.    
      def initialize(lessopts = '', lesscmd = ENV['LESSCMD']) 
        @lesscmd = lesscmd || (RUBY_PLATFORM =~ /mswin/ ? 'lessc.bat' : 'lessc')
          # TODO windows 'lessc.bat' correct?
          
        @lessopts = lessopts
      end
      
      attr_accessor :format, :lessopts, :lesscmd
      
      def filter(text, page)
        # TODO need to properly capture and log warnings here
        result = IO.popen("#{@lesscmd} #{self.lessopts} - 2>&1","r+") do |fp|
           Thread.new { fp.write(text); fp.close_write }
           fp.read
        end
        
        if $?.exitstatus == 0
          result
        else
          fail "less command failed (exitstatus: #$?): #{result}"
        end
      end
      
    end
  end
end
  
