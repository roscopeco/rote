# Rake tasklib for Rote
# (c)2005 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
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
  
  # Special type of Hash that allows Regexp and String keys. When searching for
  # a string, the first match (of either kind) is used. Allows backreferences
  # from the key match to be used in the value with $1..$n notation in val str.
  class RxHash < Hash
    def [](key)
      md = nil
      if v = self.detect { |k,v| md = /^#{k}$/.match(key) }
        v[1].gsub(/\$(\d)/) { md[$1.to_i] }
      end
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
  ##   #{name}_pages   - Transform all pages
  ##   #{name}_res     - Copy resources
  ##   #{name}_monitor - Start watching for changes
  ##   #clobber_{name} - Remove output
  ##
  class DocTask < Rake::TaskLib
    # Default exclusion patterns for the page sources. These are
    # applied along with the defaults from +FileList+. 
    DEFAULT_SRC_EXCLUDES = [ /\.rb$/, /\.rf$/ ]
    DEFAULT_EXT_MAPPINGS = { /[rx]html/ => 'html', /(.*)/ => '$1' }
    
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
    
    # Hash (an +RxHash+ by default) that supplies mappings between input
    # and output file extensions. Alternatively, you may supply a single-arg
    # +Proc+ that will return extension mappings.
    attr_accessor :ext_mappings
    
    # Convenience method that passes the supplied block to +ext_mappings+.
    # Just allows you to make the usual call rather than having to create
    # a proc. *This* *will* *remove* *any* *configured* *mappings*. 
    def ext_map_proc(&block)
      @ext_mappings = block or RxHash.new
    end    
    
    # If +show_page_tasks+ is +true+, then the file tasks created for each
    # source page will be shown in the Rake task listing from the command line.
    attr_accessor :show_file_tasks         
    alias :show_file_tasks? :show_file_tasks
    alias :show_file_tasks= :show_file_tasks=
    
    # *Deprecated* alias for +show_file_tasks+. vv0.2.2 v-0.5
    alias :show_page_tasks? :show_file_tasks      
    alias :show_page_tasks= :show_file_tasks=
    
    # The approximate number of seconds between update checks when running
    # monitor mode (Default: 1)
    attr_accessor :monitor_interval    
    
    # Create a new DocTask, using the supplied block for configuration,
    # and define tasks with the specified base-name within Rake.
    def initialize(name = :doc) # :yield: self if block_given?
      @name = name
      @output_dir = '.'      
      @pages = FilePatterns.new('.')
      @res = FilePatterns.new('.')
      @monitor_interval = 1
      @ext_mappings = RxHash[DEFAULT_EXT_MAPPINGS]
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
    
    # Get a target filename for a source filename. The dir_rx must
    # match the portion of the directory that will be replaced 
    # with the target directory. The extension is mapped through
    # ext_mappings
    def target_fn(dir_rx, fn)
      tfn = fn.sub(dir_rx, output_dir)      
      ext = File.extname(tfn)
      ext['.'] = ''  # strip leading dot
            
      new_ext = case em = ext_mappings
        when Proc
          em.call(ext)
        else
          em[ext]
      end
      
      new_ext ? tfn.sub(/#{ext}$/,new_ext) : nil
    end
    
    # define a task for each resource, and 'all resources' task
    def define_res_tasks
      res_fl = res.to_filelist
      tasks = res_fl.select { |fn| not File.directory?(fn) }.map do |fn|
        # skip any files we don't have a mapping for
        unless tfn = target_fn(/^#{res.dir}/, fn)
          announce "No extension mapping for #{fn}; skipping..."
          next
        end
        
        desc "#{fn} => #{tfn}" #if show_file_tasks?
        file tfn => [fn] do
          dn = File.dirname(tfn)
          mkdir_p dn unless File.exists?(dn)
          cp fn, tfn
        end
        tfn
      end
      
      desc "Copy new/changed resources"
      task "#{name}_res" => tasks     
    end

    # define a task for each page, and 'all pages' task
    def define_page_tasks
      pages_fl = pages.to_filelist    
      tasks = pages_fl.select { |fn| not File.directory?(fn) }.map do |fn| 
        # skip any files we don't have a mapping for
        unless tfn = target_fn(/^#{pages.dir}/, fn) 
          announce "No extension mapping for #{fn}; skipping..."
          next
        end        
                 
        desc "#{fn} => #{tfn}" #if show_file_tasks?
        file tfn => [fn] do
          dn = File.dirname(tfn)
          mkdir_p dn unless File.exists?(dn)
          puts "tr #{fn} => #{tfn}"
          begin
            File.open(tfn, 'w+') do |f|
              f << Page.new(fn,pages.dir,layout_dir).render
            end
          rescue => e
            # Oops... Unlink file and dump backtrace
            File.unlink(tfn)
            bt = e.backtrace
            end_idx = bt.each_with_index do |entry, idx|
              break idx if entry =~ /^#{File.dirname(__FILE__)}/
            end
            puts bt[0...end_idx]
            raise
          end
        end
        
        # Each page depends properly on source and common - thx again
        # Jonathan :)
        src_rb = Page::page_ruby_filename(fn)
        if File.exists?(src_rb)
          file tfn => [src_rb]
        end
        
        common_rbs = Page::resolve_common_rubys(File.dirname(fn))
        file tfn => common_rbs unless common_rbs.empty?
        
        tfn
      end
      
      desc "Render new/changed documentation pages"
      task "#{name}_pages" => tasks
    end
    
    def define_main_tasks
      desc "Build the documentation"
      task name => ["#{name}_pages", "#{name}_res"]

      task :clobber => [ "clobber_#{name}" ]
      desc "Remove the generated documentation"
      task "clobber_#{name}" do
        rm_rf output_dir
      end    
      
      # thanks to Jonathan Paisley for this :)    
      # Relies on Rake mods made below.
      desc "Monitor and automatically rebuild the documentation"
      task "#{name}_monitor" do
        loop do
          Rake::Task::tasks.each { |t| t.reset }
          Rake::Task[name].invoke
          if Rake::Task::tasks.grep(Rake::FileTask).detect { |t| t.executed? } then
            Rake::Task["#{name}_refresh"].invoke if Rake::Task.task_defined?("#{name}_refresh")
          end
          sleep monitor_interval
        end
      end        
      
    end
    
  end #class  
  
end #module

## The +monitor+ task requires a few mods to Rake to let us fire
## and reset task invocations in a loop.
module Rake # :nodoc: all
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
