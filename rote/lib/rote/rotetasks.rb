#--
# Rake tasklib for Rote
# (c)2005 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
#++
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
  
  # Special type of Hash that uses Regexp keys and maintains insertion order.
  # When searching for a string, the first match (of either kind) is used. 
  # Allows backreferences from the key match to be used in the value with $1..$n 
  # notation in val str.
  #
  # Entries are kept in insertion order. Searches/insertion are slow, iteration
  # is constant time. It's basically an unbucketed hash.
  class ExtHash
    class << self
      alias :[] :new
    end
        
    # Create a new RxHash, copying the supplied
    # map (in random order).
    def initialize(map = nil)
      @data = []
      map.each { |k,v| self[k] = v } if map
    end
  
    # Insert the given regex key unless it already exists.
    # You may use string representations for the keys, but
    # they are converted as-is to regexps.    
    #
    # Returns the value that was inserted, or nil.
    def []=(key,value)
      @data << [key,value] unless member?(key)      
    end
    
    # Fetch the first matching data.
    def [](key)
      md = nil
      if v = @data.detect { |it| md = /^#{it[0]}$/.match(key.to_s) }
        v[1][0].gsub!(/\$(\d)/) { md[$1.to_i] }
        v[1]
      end
    end
    
    # Fetch a single entry based on key equality.
    def fetch_entry(key)
      @data.detect { |it| it[0] == key }
    end
    
    # Determine membership based on key equality.
    def member?(key)
      true if fetch_entry(key)
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
    
    # The base-name for tasks created by this instance, supplied at 
    # instantiation.
    attr_reader :name
    
    # Base directories used by the task.
    attr_accessor :default_output_dir, :layout_dir
    
    alias :output_dir :default_output_dir 
    alias :output_dir= :default_output_dir=
    
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
    
    # Ordered +ExtHash+ that supplies mappings between input and output 
    # file extensions. Keys are regexps that are matched in order 
    # against the search key.
    #
    # The values are [extension, ({ |page| ...}), out_dir] . If a mapping 
    # has a block, it is executed when pages with a matching extension are,
    # instantiated (before common and page code). It can be used to apply
    # filters, for example, on a per-extension basis. 
    attr_reader :ext_mappings
    
    # Define an extension mapping for the specified regex, which will 
    # be replaced with the specified extension. If a block is supplied
    # it will be called with each matching +Page+ as it's created.
    # 
    # Extension mappings also allow the output directory to be specified
    # on a per-extension basis. If no output directory is specified, the
    # default output directory is used.
    def ext_mapping(match, extension, output_dir = self.default_output_dir, &block)
      @ext_mappings[match] = [extension,block,output_dir]      
    end
    
    # If +show_page_tasks+ is +true+, then the file tasks created for each
    # output file will be shown in the Rake task listing from the command line.
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
      @ext_mappings = ExtHash.new
      @show_page_tasks = false
      
      DEFAULT_SRC_EXCLUDES.each { |excl| @pages.exclude(excl) }
      
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
    # ext_mappings. If a block is configured for this extension,
    # it is returned too.
    #
    # Returns [target_fn, ({ |page| ...})]
    def target_fn(dir_rx, fn)
      ext = File.extname(fn).sub(/^\./,'') # strip leading dot                  
      new_ext, blk, output_dir = ext_mappings[ext] || [ext,nil,self.default_output_dir]               
      tfn = fn.sub(dir_rx, output_dir)      
      [tfn.sub(/#{ext}$/,new_ext),blk]
    end
    
    # define a task for each resource, and 'all resources' task
    def define_res_tasks
      res_fl = res.to_filelist
      tasks = res_fl.select { |fn| not File.directory?(fn) }.map do |fn|
        tfn, = target_fn(/^#{res.dir}/, fn)
        
        desc "#{fn} => #{tfn}" if show_file_tasks?
        file tfn => [fn] do
          dn = File.dirname(tfn)
          mkdir_p dn unless File.exists?(dn)
          cp fn, tfn, :preserve => true        
        end
        tfn
      end
      
      desc "Copy new/changed resources"
      task "#{name}_res" => tasks     
    end

    # define a task for each page, and 'all pages' task
    def define_page_tasks
      pages_fl = pages.to_filelist    

      gen_files = pages_fl.select { |fn| not File.directory?(fn) }.map do |fn|
        tfn, blk = target_fn(/^#{pages.dir}/, fn) 
                 
        desc "#{fn} => #{tfn}" if show_file_tasks?
        file tfn => [fn] do
          dn = File.dirname(tfn)
          mkdir_p dn unless File.exists?(dn)
          puts "tr #{fn} => #{tfn}"
          begin
            File.open(tfn, 'w+') do |f|
              # new page, run extension block, render out, throw away
              f << Page.new(fn,pages.dir,layout_dir,&blk).render
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
      task "#{name}_pages" => gen_files
      task "clobber_#{name}_pages" do
        gen_files.each do |f|
          rm_f f
        end
      end    
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

#####
## Rote adds the following methods to the Rake module.
## All this cool stuff was contributed by Jonathan Paisley (<jp-www at dcs gla ac uk>)
module Rake

  #####
  ## Rote adds the following methods to the Rake::Task class.
  class Task
    # Reset the _executed_ and _invoked_ flags on this task. 
    # Used by the +monitor+ task.
    def reset
      @already_invoked = false
      @executed = false
    end
    
    # Determine whether this task has been executed in this cycle.
    # Used by the +monitor+ task.
    def executed?
      @executed
    end
    
    alias :pre_rote_execute :execute
    # Execute the task, setting the _executed_ flag.
    # Used by the +monitor+ task.
    def execute(args)
      @executed = true
      pre_rote_execute
    end
  end
end       
