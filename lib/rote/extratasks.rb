#--
# Extra bonus Rake tasklibs for Rote and elsewhere
# (c)2005, 2006, 2012 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
#++
require 'rake'

module Rote
  #####
  ## Rake task library that allows code-coverage reports to be 
  ## generated using RCov (http://eigenclass.org/hiki.rb?rcov).
  class RCovTask < Rake::TaskLib
    # The base name for the generated task [:rcov]
    attr_reader :taskname
    
    # The command that runs RCov ['rcov']
    attr_accessor :rcov_cmd
    
    # A +Rake::FileList+ holding unit-test filenames and globs.
    # RCov will execute these to generate the report.
    attr_accessor :test_files
    
    # A +Rake::FileList+ holding Ruby source filenames that are
    # included in the coverage report. This is *optional* - RCov
    # finds sources by running them. However, if you do specify
    # your files here then the coverage report will only be 
    # generated when they change.
    attr_accessor :source_files
    
    # The path to which RCov should generate output [./coverage]
    attr_accessor :output_dir
    
    # Extra load-paths that should be appended to $: when running
    # the test cases. [none]
    attr_accessor :load_paths
    
    # If true, RCov will generate colorblind-safe output. [false]
    attr_accessor :no_color
    
    # Set of glob patterns that should be excluded from the test
    # run. [none]
    attr_accessor :excludes
    
    # Determines whether bogo-profiling is enabled [false]
    attr_accessor :profile
    
    # The color scale range for profiling output (dB) [not used]
    attr_accessor :range
    
    # If +false+, the task will emit a warning rather than failing when Rcov command fails. [true]
    attr_accessor :failonerror
    
    # Create a new RCovTask, using the supplied block for configuration,
    # and define tasks with the specified base-name within Rake.
    #
    # Note that the named task just invokes a file task for the output
    # directory, which is dependent on test (and source, if specified)
    # file changes.
    def initialize(name = :rcov, failonerror = true) # :yield: self if block_given?      
      @taskname = name
      @rcov_cmd = 'rcov'
      @test_files = Rake::FileList.new
      @source_files = Rake::FileList.new
      @load_paths = []
      @excludes = []      
      @output_dir = './coverage'
      @failonerror = true
      
      yield self if block_given?

      define(name)
    end

    private 
    
    def define(name)
      unless @test_files.empty?
        if defined? CLOBBER
          CLOBBER.include @output_dir 
        elsif defined? CLEAN
          CLEAN.include @output_dir
        end
        
        (@test_files + @source_files).each { |fn| file fn }        
        
        file @output_dir => (@test_files + @source_files) do
          cmd = "#{rcov_cmd}" <<
                "#{" -o #{@output_dir}" if @output_dir}" <<
                "#{" -I #{@load_paths.join(':')}" unless @load_paths.empty?}" << 
                "#{" -n" if @no_color}" << 
                "#{" -x #{@excludes.join(':')}" unless @excludes.empty?}" << 
                "#{" -p" if @profile}" << 
                "#{" -r #{@range}" if @range}" <<
                " " << @test_files.join(' ')

          puts cmd
          unless system(cmd)
            if failonerror
              fail "RCov command '#{rcov_cmd}' failed (status #{$?.exitstatus})" 
            else 
              warn "RCov command '#{rcov_cmd}' failed (status #{$?.exitstatus})" 
            end
          end
        end
        
        task name => @output_dir
      end
    end
  end
end

