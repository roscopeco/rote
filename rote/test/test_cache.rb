begin
  require 'rubygems'
rescue LoadError
  nil
end

$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__),'../lib'))

require 'rake'
require 'rote/cache'

Rake.cache_enabled = false

module Rote  
  class TestCache < Test::Unit::TestCase

    def test_rake_cache_dir
      assert_equal '.rake_cache', Rake.cache_dir
      Rake.cache_dir = './.cache'
      assert_equal './.cache', Rake.cache_dir
      Rake.cache_dir = nil
      assert_equal '.rake_cache', Rake.cache_dir
    end

    def test_rake_dependencies_file
      assert_equal '.rake_cache/dependencies.yaml', Rake.dependencies_file
      Rake.cache_dir = './.cache'
      assert_equal './.cache/dependencies.yaml', Rake.dependencies_file
      Rake.cache_dir = nil
      assert_equal '.rake_cache/dependencies.yaml', Rake.dependencies_file
    end
    
    def test_rake_task_stack
      assert_equal [], Rake.task_stack             
      
      outertask = task :outertask do        
        assert_equal 'outertask', Rake.task_stack[-1].name        
        
        innertask = task :innertask do          
          assert_equal 'outertask', Rake.task_stack[-2].name        
          assert_equal 'innertask', Rake.task_stack[-1].name        
        end
        innertask.invoke
        
        assert_equal 'outertask', Rake.task_stack[-1].name        
      end    
      
      outertask.invoke
      assert_equal [], Rake.task_stack       
    end
    
    def test_rake_register_dep_cached_deps      
      assert_equal({}, Rake.cached_dependencies)
      
      # should fail here, return nil, do nothing. 
      # there's no current task
      assert_nil Rake.register_dependency('dep')
      assert_equal({}, Rake.cached_dependencies)
      
      testtask = task :test_register_dep do
        assert_equal(['dep'], Rake.register_dependency('dep'))
      end
      
      testtask.invoke
      
      assert_equal({'test_register_dep' => ['dep']}, Rake.cached_dependencies)
    end
    
    # TODO need to test load / save
    
  end
end
