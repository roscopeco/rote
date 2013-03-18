# Rote application class
# (c)2005, 2012 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
require 'getoptlong'

module Rote

  # Command-line launcher for Rote.
  class Application
    attr_accessor :rote_lib
    attr_accessor :debug
    attr_accessor :tasks
    attr_accessor :trace
    attr_accessor :usage
    attr_accessor :version
    attr_accessor :rake
    attr_accessor :rakefile
    attr_accessor :rakeopts
    
    # Create a new Application instance, processing command-line arguments,
    # optionally passing +self+ to the supplied block for further 
    # configuration.
    def initialize(rote_lib) # :yield: self if block_given?
      # init vars
      @rote_lib = rote_lib
      @debug = false
      @tasks = false
      @trace = false
      @usage = false
      @version = false    
      
      @rakefile = "#{rote_lib}/rote/builtin.rf"
      raise "Missing builtin.rf (expected at '#{@rakefile}')!" unless File.exists?(@rakefile)
      
      @rakeopts = ENV['RAKE_OPTS'] || ''
      @rake = ENV['RAKE_CMD'] || (RUBY_PLATFORM =~ /mswin/ ? 'rake.cmd' : 'rake')
      
      process_args
      
      yield self if block_given?
    end
      
    # Run the application with the current options.
    def run    
      if @version
        print "rote, version #{ROTEVERSION}\n"
       
      elsif @tasks
        print `#{rake} --rakefile=#{rakefile} --libdir=#{rote_lib} --tasks`.gsub(/^rake /,'rote ')
      
      elsif @usage
        show_usage()
      
      else
        if @trace
          rakeopts << ' --trace'
        elsif @debug
          rakeopts << '--verbose'
        end
      
        exec("#{rake} --rakefile=#{rakefile} --libdir=#{rote_lib} #{rakeopts} #{$*.join(' ')}")
      end
    end
    
    private
    
    # Process commandline
    def process_args
      GetoptLong.new(
        [ "--verbose", "-v", GetoptLong::NO_ARGUMENT ],
        [ "--tasks",   "-T", GetoptLong::NO_ARGUMENT ],
        [ "--trace",   "-t", GetoptLong::NO_ARGUMENT ],
        [ "--usage",   "-u", GetoptLong::NO_ARGUMENT ],
        [ "--help",    "-h", GetoptLong::NO_ARGUMENT ],
        [ "--version", "-V", GetoptLong::NO_ARGUMENT ]
      ).each { |opt,arg|
        @debug = true if opt == '--verbose'
        @trace = true if opt == '--trace'
        @tasks = true if opt == '--tasks'
        @usage = true if opt == '--usage' || opt == '--help'
        @version = true if opt == '--version'
      }    
    end
    
    # Display help text
    def show_usage
      print <<-EOM
Usage: rote [options] [task1] .. [taskN]

Where [taskN] is a valid task or target name for the current project. 
Rote generates targets for each page source, and also defines a number
of top-level tasks for various things. Use the '--tasks' option to get
a list of valid tasks.

Recognised options are:

  --tasks     -T     Display a list of tasks in this project.
  --verbose   -v     Enable verbose output.
  --trace     -t     Enables trace-level output (debugging).
  --usage     -u     Display this help message and quit
  --help      -h     Synonym for --usage
  --version   -V     Display Rote's version and quit

In addition to the standard doc_XXX tasks and those provided by any
local configuration, the following 'special' tasks are recognised:

  create <project>   Create a blank project from the built-in template.
   
Note that these 'special' tasks are implemented as part of the command-
line wrapper for Rote, and will not be available from custom Rakefiles.

In non-standard environments, it may be necessary to set the ROTE_LIB 
variable to point to the location of Rote's libraries.
  
EOM
    end
        
  end # Application
end # Rote
