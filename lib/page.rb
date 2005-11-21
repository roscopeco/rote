require 'erb'
require 'rubygems'
require 'pagehelpers'

require_gem('RedCloth')

GLOBAL_RB = 'site/global.rb' if File.exists?('site/global.rb')

module Rote

  #####
  ## A page object is created for each page as it's processed.
  ## The supplied filename indicates the template - ruby source will be
  ## found alongside the file, with the '.rb' extension, and if found
  ## it will eval'd in the Page's binding. That source can call methods
  ## and set any instance variables, for use later in the template.
  ##
  ## Rendering happens only once, when the to_html method is
  ## first called. The files are read (and .rb evaluated) 
  ## during initialize.
  class Page  
    include PageHelpers
    
    ####
    # Reads the template, and evaluates the global and page scripts, if 
    # available, using the current binding. You may define any instance
    # variables or methods you like in that code for use in the template,
    # as well as accessing the predefined +@template+ and +@template_text+
    # variables.
    def initialize(template_erb_fn)
      # read in the template and layout (default if not configured by the page code)
      template(template_erb_fn)
      layout(nil)                                   # may get set later in page
      
      # get script filename and check exists
      src_rb = template_erb_fn.ext('rb')
      src_rb = nil unless File.exists?(src_rb)  
      
      # eval the global and page ruby associated with it using our
      # binding, allowing vars to be set.
      eval(File.read(GLOBAL_RB), binding) if defined?(GLOBAL_RB)      
      eval(File.read(src_rb), binding) if src_rb && File.exists?(src_rb)    
    end
    
    ####
    # Convert this page to HTML, rendering the markup and ERB and applying layout.
    # This is only done once - after that, it's cached for next time. You can
    # also circumvent rendering by setting @html yourself in your page's ruby.
    def to_html
      do_render if !defined?(@html)
      @html
    end
    
    ####
    # Gets target filename for a given page filename
    def self.target_fn(fn)
      fn.sub(/^site\/pages/,'target').sub(/\.[^.]*$/, '.html')
    end
    
    ####
    ## Gets this page's target filename
    def target_fn
      Page::target_fn(@template)
    end
    
    ############################ ATTRIBUTE ACCESSORS ############################
  
    private
    
    ###
    # Called if @html is undefined. 
    def do_render    
      # Render the page content into the @content_for_layout var, parsing out
      # textile.
      if !defined?(@content_for_layout) && !@template_text.nil?
        @content_for_layout = RedCloth.new( ERB.new(@template_text).result(binding) ).to_html(:textile) 
      end
      
      # render into the layout if supplied.
      @html = if !@layout_text.nil?
        ERB.new(@layout_text).result(binding)   
      else 
        @content_for_layout
      end  
    end
    
    ####
    # Template helper. This is private, but can still be called from 
    # the ruby source if they want to replace the text.
    # This will cause it to be reread.
    def template(fn)
      @template = fn
      @template_text = fn == nil ? nil : File.read(fn)
    end  
    
  end #class  
end #module