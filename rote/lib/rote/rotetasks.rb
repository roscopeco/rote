require 'rake'
require 'rake/tasklib'

require 'rote/page'

module Rote

  # Just a temporary holder for a set of patterns that are used
  # to construct a relative +FileList+ for pages and resources.
  class FilePatterns
    def initialize(basedir = '.')
      @dir = basedir    
      @includes, @excludes = [], []
    end
    
    # Access the pattern arrays
    attr_reader :includes
    attr_reader :excludes
    
    # Access the base dir for these patterns
    attr_accessor :dir
    
    # Specify glob patterns to include
    def include(*patterns)
      patterns.each { |it| 
        @includes << it
      }
    end  
    
    # Specify glob patterns or regexps to exclude 
    def exclude(*patterns)
      patterns.each { |it|         
        @excludes << it
      }
    end  

    # Create a +FileList+ with these patterns    
    def to_filelist
      fl = FileList.new
      fl.include(*includes.map { |it| "#{dir}/#{it}"} ) unless includes.empty?

      # excludes may be regexp too
      fl.exclude(*excludes.map { |it| it.is_a?(String) ? "#{dir}/#{it}" : it } ) unless excludes.empty?
      
      # don't allow dir to be changed anymore. 
      freeze
         
      fl    
    end
  end

  #####
  ## Rake task library that provides a set of tasks to transform documentation
  ## using Rote. To use, create a new instance of this class in your Rakefile,
  ## performing appropriate configuration in a block supplied to +new+. 
  ## This will automatically register a set of tasks with names based on the
  ## name you supply. The tasks defined are:
  ##
  ##   #{name}         - Transform all documentation, copy resources.
  ##   #{name}-pages   - Transform all pages
  ##   #{name}-res     - Copy resources
  ##
  class DocTask < Rake::TaskLib
    # Default exclusion patterns for the page sources. These are
    # applied along with the defaults from +FileList+. 
    DEFAULT_SRC_EXCLUDES = [ /\.rb$/ ]
    
    # The base-name for tasks created by this instance, supplied at 
    # instantiation.
    attr_reader :name
    
    # Base directories used by the task.
    attr_accessor :output_dir, :layout_dir
    
    # Globs for the +FileList+ that supplies the pages to transform. You 
    # should configure the +pages_dir+ and +include+ at least one entry
    # here. (you may add +exclude+ strings or regexps, too).
    # Patterns added are made relative to the +pages_dir+ and
    # added to a FileList once init is complete.
    attr_reader :pages
    
    # Globs for the +FileList+ that supplies the resources to copy. You 
    # should configure the +layout_dir+ and +include+ at least one entry
    # here (you may add +exclude+ strings or regexps, too).
    #
    # This is *not* a +FileList+ - the patterns supplied to this are used
    # with the base-directory specified to construct an appropriate
    # +FileList+.
    attr_reader :res
    
    # If +show_page_tasks+ is +true+, then the file tasks created for each
    # source page will be shown in the Rake task listing from the command line.
    attr_accessor :show_file_tasks         
    alias :show_file_tasks? :show_file_tasks
    
    # This is a *deprecated* alias for +show_file_tasks+. It will be removed.
    alias :show_page_tasks? :show_file_tasks      # vv0.3.0 v-0.5
    alias :show_page_tasks= :show_file_tasks=
    
    # The approximate number of seconds between update checks when running
    # monitor mode (Default: 1)
    attr_accessor :monitor_interval    
    
    # Create a new DocTask, using the supplied block for configuration,
    # and define tasks with the specified base-name within Rake.
    def initialize(name = :site) # :yield: self if block_given?
      @name = name
      @output_dir = '.'      
      @pages = FilePatterns.new('.')
      @res = FilePatterns.new('.')
      @monitor_interval = 1
      DEFAULT_SRC_EXCLUDES.each { |excl| @pages.exclude(excl) }
      
      @show_page_tasks = false
      
      yield self if block_given?
            
      define
    end    
    
    private
    
    def define
      define_res_tasks
      define_page_tasks
      define_main_tasks
      nil
    end
    
    # define a task for each resource, and 'all resources' task
    def define_res_tasks
      res_fl = res.to_filelist
      tasks = res_fl.select { |fn| not File.directory?(fn) }.map do |fn|
        tfn = fn.sub(/^#{res.dir}/, output_dir)
        desc "#{fn} => #{tfn}" if show_file_tasks?
        file tfn => [fn] do
          dn = File.dirname(tfn)
          mkdir_p dn unless File.exists?(dn)
          cp fn, tfn
        end
        tfn
      end
      
      task "#{name}-res" => tasks     
    end

    # define a task for each page, and 'all pages' task
    def define_page_tasks
      pages_fl = pages.to_filelist    
      tasks = pages_fl.select { |fn| not File.directory?(fn) }.map do |fn| 
        tfn = fn.sub(/^#{pages.dir}/, output_dir)          
        desc "#{fn} => #{tfn}" if show_file_tasks?
        file tfn => [fn] do
          dn = File.dirname(tfn)
          mkdir_p dn unless File.exists?(dn)
          File.open(tfn, 'w+') do |f|
            puts "tr #{fn} => #{tfn}"
            f << Page.new(fn,layout_dir).render
          end          
        end
        tfn
      end
      
      desc "Render all documentation pages"
      task "#{name}-pages" => tasks
    end
    
    def define_main_tasks
      desc "Build the documentation"
      task name => ["#{name}-pages", "#{name}-res"]

      desc "Remove the generated documentation"
      task :clean => [ "#{name}-clean" ]
      task "#{name}-clean" do
        rm_rf output_dir
      end    
      
      # thanks to Jonathan Paisley for this :)    
      # Relies on Rake mods made below.
      desc "Monitor and automatically rebuild the documentation"
      task "#{name}-monitor" do
        loop do
          Rake::Task::tasks.each { |t| t.reset }
          Rake::Task[name].invoke
          if Rake::Task::tasks.grep(Rake::FileTask).detect { |t| t.executed? } then
            Rake::Task["#{name}-refresh"].invoke if Rake::Task.task_defined?("#{name}-refresh")
          end
          sleep monitor_interval
        end
      end        
      
    end
    
  end #class  
  
end #module

## The -run task requires a few mods to Rake to let us fire
## and reset task invocations in a loop.
module Rake
  class Task
    def reset
      @already_invoked = false
      @executed = false
    end
    def executed?
      @executed
    end
    alias :pre_rote_execute :execute
    def execute
      @executed = true
      pre_rote_execute
    end
  end
end       
