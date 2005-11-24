require 'rake'
require 'rake/tasklib'

require 'rote/page'
require 'rote/dirfilelist'

module Rote
  class SiteTask < Rake::TaskLib
    # Default exclusion patterns for the page sources. These are
    # applied along with the defaults from +FileList+. 
    DEFAULT_SRC_EXCLUDES = [ /\.rb$/ ]
    
    attr_reader :name
    
    attr_accessor :site_dir
    
    attr_accessor :layout_dir
    
    attr_reader :pages
    
    attr_reader :res
    
    attr_writer :show_page_tasks
    def show_page_tasks?
      @show_page_tasks
    end
  
    def initialize(name = :site)
      @name = name
      @site_dir = '.'      
      @layout_dir = '.'   # layouts are looked up as needed
      
      @pages = DirectoryFileList.new
      @res = DirectoryFileList.new      
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
      define_ext_tasks
      nil
    end
    
    def define_res_tasks
      desc "Copy documentation resources"
      task "#{name}_res" do
        res.each { |fn|           
          unless File.directory?(fn)    # make dirs only as needed
            tfn = fn.sub(/#{res.dir}/, site_dir)
            dn = File.dirname(tfn)
            mkdir_p dn unless File.exists?(dn)            
            cp fn, tfn
          end        
        }
      end #task
    end

    def define_page_tasks
    
      # define a task for each page
      pages.each { |fn| 
        unless File.directory?(fn)    # make dirs only as needed
          tfn = fn.sub(/#{pages.dir}/, site_dir)
          
          desc "#{fn} => #{tfn}" if show_page_tasks?
          file tfn => [fn] do
            dn = File.dirname(tfn)
            mkdir_p dn unless File.exists?(dn)
            File.open(tfn, 'w+') { |f|
              f << Page.new(fn,layout_dir).render
            }
          end
        end
      }
      
      # this is pretty convenient ;]
      desc "Render all documentation pages"
      task "#{name}_pages" => pages.sub(/#{pages.dir}/, site_dir)
    end
    
    def define_ext_tasks      
      # define an 'extension point' task to generate new pages
      task "#{name}_generate_pages"
      
      # define an 'extension point' task to generate reports
      task "#{name}_reports"
    end
    
    def define_main_tasks
      desc "Build the documentation"
      task name => ["#{name}_generate_pages", "#{name}_pages", "#{name}_res", "#{name}_reports"]
    end
    
  end #class  
  
end #module