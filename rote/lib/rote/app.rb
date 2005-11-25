require 'getoptlong'

module Rote

  # Command-line launcher for Rote.
  class Application
    attr_accessor :rote_bin
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
    def initialize(rote_bin, rote_lib) # :yield: self if block_given?
      # init vars
      @rote_bin = rote_bin
      @rote_lib = rote_lib || rote_bin
      @debug = false
      @tasks = false
      @trace = false
      @usage = false
      @version = false    
      
      @rakefile = File.exists?('Rakefile') ? 'Rakefile' : "#{rote_lib}/builtin.rf"
      @rakeopts = ENV['RAKE_OPTS'] || ''
      @rake = ENV['RAKE_CMD'] || 'rake'
      
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
    
    # Display help text
    def show_usage
      print <<-EOM
      Usage: rote [options] [task1] .. [taskN]
    
      Where [taskN] is a valid task or target name for the current project. 
      Rite generates targets for each page source, and also defines a number
      of top-level tasks for various things. Use the '--tasks' option to get
      a list of valid tasks.
    
      Recognised options are:
    
        --tasks     -T     Display a list of tasks in this project.
        --debug     -d     Enable debugging information.
        --trace     -t     Enables verbose debugging information.    
        --usage     -u     Display this help message and quit
        --help      -h     Synonym for --usage
        --version   -v     Display Rote's version and quit
    
      The 'rote' command is implemented as a wrapper around Rake, and 
      requires the 'rake' command be in your path. You can circumvent this
      by setting the RAKE_CMD environment variable appropriately.
      Additional options can be passed to Rake via the RAKE_OPTS variable.
      
      Depending on your environment, you may need to set ROTE_HOME to point
      to the installation directory. 
      EOM
    end
    
    # Process commandline
    def process_args
      GetoptLong.new(
        [ "--debug",   "-d", GetoptLong::NO_ARGUMENT ],
        [ "--tasks",   "-T", GetoptLong::NO_ARGUMENT ],
        [ "--trace",   "-x", GetoptLong::NO_ARGUMENT ],
        [ "--usage",   "-u", GetoptLong::NO_ARGUMENT ],
        [ "--help",    "-h", GetoptLong::NO_ARGUMENT ],
        [ "--version", "-v", GetoptLong::NO_ARGUMENT ]
      ).each { |opt,arg|
        @debug = true if opt == '--debug'
        @trace = true if opt == '--trace'
        @tasks = true if opt == '--tasks'
        @usage = true if opt == '--usage' || opt == '--help'
        @version = true if opt == '--version'
      }    
    end
    
  end # Application
end # Rote
