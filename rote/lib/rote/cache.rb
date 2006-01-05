# Dependency caching / memoize to disk for Rake / Rote
# Contributed by Jonathan Paisley (very slightly modified)
#--
# (c)2005, 2006 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
#++
# This file adds dynamic dependency tracking and caching for 
# incremental builds, by adding methods to the Rake module 
# and Task class. The primary intention is to allow pages
# to register layout files, and other dynamic dependencies
# to allow them to be checked on the next incremental build.
# To use, simply require this in your Rakefile, and call 
# Rake.register_dependency from your page (e.g. when applying
# layout). 
#
# Eventually this registration may become implicit with layout.

require 'md5'
require 'yaml'
require 'pathname'
require 'rake'

module Rake
  class << self
    # Directory for storing Rake dependency cache
    def cache_dir=(val); @cache_dir = val; end
    def cache_dir; @cache_dir ||= ".rake_cache"; end
    def dependencies_file; File.join(cache_dir,"dependencies.yaml"); end
    # Hash of current cached dependencies
    def cached_dependencies; @cached_dependencies ||= {}; end
    # Array representing current tasks being executed
    def task_stack; @tasks ||= []; end
    # Reference to current task being executed
    def current_task; task_stack.last; end

    # Use this method to dynamically register one or more files
    # as dependencies of the currently executing task.
    def register_dependency(deps, t = nil)
      t = (current_task.name if current_task) unless t
      if t then
        file t => deps
        (cached_dependencies[t] ||= []) << deps
      end
    end
  end
  
  class Task
    alias :pre_autodep_invoke :invoke
    
    # Invoke the task, loading cached dependencies if not already
    # loaded, and handling the task stack. The argument controls
    # whether or not cached dependencies are loaded and should not
    # be set false except in testing.
    def invoke(do_cache = true)
      # Invoke patched to record task stack and
      # load cached dependencies on first go.
      Rake.load_cached_dependencies if do_cache && !$CACHEDEPS_LOADED
      
      begin
        Rake.task_stack << self
        
        # TODO what's going on here?
        # Rake.cached_dependencies[name] = [] if Rake.cached_dependencies[name] 
        
        pre_autodep_invoke
      ensure
        Rake.task_stack.pop
      end
    end

    # Memoize the result of the block with respect to the 
    # file-based dependencies. Specify a description and
    # dependencies like a Task:
    #
    #   Rake::Task.memoize :task_name => [fn1,fn2] { ... }
    #
    # If the cached result is up-to-date with respect to the
    # dependencies then the block will not be executed. Instead,
    # the result will be unmarshalled from disk.
    def self.memoize(args, &block)
      task_name, deps = resolve_args(args)
      fn = File.join(Rake.cache_dir, MD5.new(deps.inspect).to_s + "." + task_name)
      Rake.register_dependency(deps)
      
      result = nil
      # This file task isn't ever used other than manually below with t.invoke
      t = file fn => deps do
        result = block.call
        mkdir_p Rake.cache_dir unless File.exists?(Rake.cache_dir)
        File.open(fn,"w") { |fp| Marshal.dump(result,fp) }
      end
      if t.needed? then
        t.invoke
        result
      else
        Marshal.load(File.read(fn))
      end
    end
  end
  
  protected
  
  # Load cached dependencies, unless they're already
  # loaded. This method is called during task invocation,
  # with the effect that cached deps are loaded from yaml
  # on the first invoke.
  #
  # An at_exit handler is installed to save the dependencies
  # when rake exits.
  def self.load_cached_dependencies
    at_exit { self.save_cached_dependencies }

    return unless File.exists?(dependencies_file)
    YAML.load(File.read(dependencies_file)).each do |task,deps|
      deps.each do |dep|
        register_dependency(dep, task)
      end
    end
    
    $CACHEDEPS_LOADED = true
  end
  
  def self.save_cached_dependencies
    return if cached_dependencies.empty?
    mkdir_p cache_dir unless File.exists?(cache_dir)
    deps = {}
    cached_dependencies.each do |k,v|
      deps[k] = v.flatten.uniq
    end
    File.open(dependencies_file,"w") { |fp| fp.write YAML.dump(deps) }
  end
end
  
task :clean => :clean_cached_dependencies
task :clean_cached_dependencies do
  
  # careful now...
  rm_rf Rake.cache_dir unless Rake.cache_dir == '.'
  
  Rake.cached_dependencies.clear
end
