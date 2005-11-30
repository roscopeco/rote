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
    attr_reader :res
    
    # If +show_page_tasks+ is +true+, then the file tasks created for each
    # source page will be shown in the Rake task listing from the command line.
    attr_accessor :show_page_tasks         
    alias :show_page_tasks? :show_page_tasks
    
    # Create a new DocTask, using the supplied block for configuration,
    # and define tasks with the specified base-name within Rake.
    def initialize(name = :site) # :yield: self if block_given?
      @name = name
      @output_dir = '.'      
      @pages = FilePatterns.new('.')
      @res = FilePatterns.new('.')
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
    
    def define_res_tasks
      res_fl = res.to_filelist
      
      desc "Copy documentation resources"
      task "#{name}-res" do
        res_fl.each { |fn|           
          unless File.directory?(fn)    # make dirs only as needed
            tfn = fn.sub(/#{res.dir}/, output_dir)
            dn = File.dirname(tfn)
            mkdir_p dn unless File.exists?(dn)            
            cp fn, tfn
          end        
        }
      end #task
    end

    def define_page_tasks
      # make file list
      pages_fl = pages.to_filelist
    
      # define a task for each page
      realpages = FileList[]
      pages_fl.each { |fn| 
        unless File.directory?(fn)    # make dirs only as needed
          realpages << fn
          tfn = fn.sub(/^#{pages.dir}/, output_dir)
          
          desc "#{fn} => #{tfn}" if show_page_tasks?
          file tfn => [fn] do
            dn = File.dirname(tfn)
            mkdir_p dn unless File.exists?(dn)
            File.open(tfn, 'w+') { |f|
              puts "tr #{fn} => #{tfn}"
              f << Page.new(fn,layout_dir).render
            }
          end
        end
      }
      
      # this is pretty convenient ;]
      desc "Render all documentation pages"
      task "#{name}-pages" => realpages.sub(/#{pages.dir}/, output_dir)
    end
    
    def define_main_tasks
      desc "Build the documentation"
      task name => ["#{name}-pages", "#{name}-res"]
    end
    
  end #class  
  
end #module