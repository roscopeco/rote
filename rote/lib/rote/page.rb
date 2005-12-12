#--
# Rote page class
# (c)2005 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
#++

require 'erb'

# Don't want user to have to require these in their pagecode.
require 'rote/format/html'

module Rote
  STRIP_SLASHES = /^\/?(.*?)\/?$/
  FILE_EXT = /\..*$/
  
  #####
  ## A +Page+ object represents an individual template source file, taking
  ## input from that file and (optionally) some ruby code, and producing 
  ## rendered (or 'merged') output as a +String+. All user-supplied code
  ## (COMMON.rb or page code, for example) is executed in the binding
  ## of an instance of this class. 
  ##
  ## When a page is created, ruby source will be sought alongside the 
  ## file, with same basename and an '.rb' extension. If found it will
  ## run through +instance_eval+. That source can call methods
  ## and set any instance variables, for use later in the template.
  ## Such variables or methods may also be defined in a COMMON.rb file
  ## in or above the page's directory, in code associated with the 
  ## +layout+ applied to a page, or (less often) in a block supplied to
  ## +new+.
  ##
  ## Rendering happens only once for a given page object, when the 
  ## +render+ method is first called. Once a page has been rendered
  ## it is frozen.
  class Page  
  
    class << self
      # Helper that returns a page-code filename given a template filename.
      # This does not check that the source exists - use the +ruby_filename+
      # instance method to get the actual filename (if any) of source
      # associated with a given page instance.
      def page_ruby_filename(template_fn)
        fn = nil
        if (template_fn) 
          if (fn = template_fn.dup) =~ FILE_EXT
            fn[FILE_EXT] = '.rb'
          else
            fn << '.rb' unless fn.empty?
          end            
        end        
        fn
      end
      
      # Find all COMMON.rb files from given dir up to FS root.
      def resolve_common_rubys(dir, arr = [])
        # defer to parent dir first
        parent = File.expand_path(File.join(dir, '..'))
        resolve_common_rubys(parent,arr) unless parent == dir # at root    
        fn = File.join(dir,'COMMON.rb')    
        arr << fn if (File.exists?(fn) && File.readable?(fn))
      end  
    end
    
    # The text of the template to use for this page.
    attr_reader :template_text

    # The text of the layout to use for this page. This is read in
    # when (if) the page source calls layout(basename).
    attr_reader :layout_text
    
    # The names from which this page's template and layout (if any) 
    # were read, relative to the +base_path+.
    attr_reader :template_name, :layout_name    
    
    # The base paths for this page's template and layout. These point
    # to the directories configured in the Rake tasks.
    attr_reader :base_path, :layout_path
    
    # The array of page filters (applied to this page output *before* 
    # layout is applied) and post filters (three gueses). 
    # You can use +append_page_filter+ and +append_post_filter+ to add 
    # new filters, which gives implicit block => Filters::Proc conversion 
    # and checks for nil.
    attr_reader :page_filters, :post_filters   
    
    # Reads the template, and evaluates the global and page scripts, if 
    # available, using the current binding. You may define any instance
    # variables or methods you like in that code for use in the template,
    # as well as accessing the predefined @template and @template_text
    # variables.
    #
    # If specified, the layout path will be used to find layouts referenced
    # from templates. 
    #
    # If a block is supplied, it is executed _before_ the global / page
    # code. This will be the block supplied by the file-extension mapping.
    def initialize(template_name, pages_dir = '.', layout_dir = pages_dir, &blk) 
      @template_text = nil
      @template_name = nil
      @layout_text = nil
      @layout_name = nil
      @content_for_layout = nil
      @result = nil
      @layout_defext = File.extname(template_name)
      @layout_path = layout_dir[STRIP_SLASHES,1]
      @base_path = pages_dir[STRIP_SLASHES,1]
      
      @page_filters, @post_filters = [], []

      # read in the template. Layout _may_ get configured later in page code
      # We only add the pages_dir if it's not already there, because it's
      # easier to pass the whole relative fn from rake...
      # template_name always needs with no prefix.
      tfn = template_name
      read_template(tfn)
      
      blk[self] if blk
      
      # Eval COMMON.rb's
      eval_common_rubys
      
      # get script filenames, and eval them if found
      tfn = ruby_filename # nil if no file      
      instance_eval(File.read(tfn),tfn) if tfn      
    end
            
    # Returns the full filename of this Page's template. This is obtained by
    # joining the base path with template name.
    def template_filename
      template_name ? File.join(base_path,template_name) : nil
    end
    
    # Returns the full filename of this Page's template. This is obtained by
    # joining the base path with template name.
    def layout_filename
      layout_name ? File.join(layout_path,layout_name) : nil
    end
    
    # Returns the full filename of this Page's ruby source. If no source is
    # found for this page (not including common source) this returns +nil+.
    def ruby_filename
      fn = Page::page_ruby_filename(template_filename) 
      File.exists?(fn) ? fn : nil
    end

    # Append +filter+ to this page's page-filter chain, or create 
    # a new Rote::Filters::TextFilter with the supplied block.
    # This method should be preferred over direct manipulation of
    # the +filters+ array if you are simply building a chain.
    def page_filter(filter = nil, &block)
      if filter
        page_filters << filter
      else
        if block
          page_filters << Filters::Proc.new(block)
        end
      end
    end    
    
    # Append +filter+ to this page's post-filter chain.
    # Behaviour is much the same as +append_page_filter+.
    def post_filter(filter = nil, &block)
      if filter
        post_filters << filter
      else
        if block
          post_filters << Filters::Proc.new(block)
        end
      end
    end    
    
    # Render this page's textile and ERB, and apply layout.
    # This is only done once - after that, it's cached for next time. You can
    # also circumvent rendering by setting @result yourself in your page's ruby.
    def render
      @result or do_render!   # sets up result for next time...
    end
    
    alias to_s render
    
    # Sets the layout from the specified file, or disables layout if
    # +nil+ is passed in. The specified basename should be the name
    # of the layout file relative to the +layout_dir+, with no extension.
    #
    # *The* *layout* *is* *not* *read* *by* *this* *method*. It, and 
    # it's source, are loaded only at rendering time. This prevents
    # multiple calls by various scoped COMMON code, for example, from
    # making a mess in the Page binding.
    #
    # This can only be called before the first call to +render+. After 
    # that the instance is frozen.
    def layout(basename)
      if basename
        # layout text
        @layout_name = "#{basename}#{@layout_defext if File.extname(basename).empty?}"
      else
        @layout_name = nil
      end
    end    
    
    private        
        
    # Sets the template from the specified file, or clears the template if
    # +nil+ is passed in. The specified basename should be the name
    # of the layout file relative to the +layout_dir+, with no extension.
    def read_template(fn)    
      if fn
        # if it's already a path that includes the pages path, strip
        # that to get the name.
        if fn =~ /#{base_path}/
          @template_name = fn[/^#{base_path}\/(.*)/,1]
        else
          @template_name = fn
        end
        
        raise "Template #{fn} not found" unless File.exists?(template_filename)
        @template_text = File.read(template_filename)
      else
        @template_name = nil
        @template_text = nil
      end
    end  
    
    def load_layout
      if fn = layout_filename
        raise "Layout #{fn} not found" unless File.exists?(fn)      
        @layout_text = File.read(fn)
        
        # layout code     
        cfn = Page::page_ruby_filename(fn)
        instance_eval(File.read(cfn), cfn) if File.exists?(cfn)        
      end
    end
    
    
    def render_page_filters(text)
      page_filters.inject(text) { |s, f| f.filter(s, self) }      
    end    
        
    def render_post_filters(text)
      post_filters.inject(text) { |s, f| f.filter(s, self) }      
    end    
        
    # render, set up @result for next time. Return result too.    
    def do_render!
      # Render the page content into the @content_for_layout
      unless @template_text.nil?
        # default render_fmt does nothing - different page formats may redefine it.
        erb = ERB.new(@template_text)
        erb.filename = template_filename
        @content_for_layout = render_page_filters( erb.result(binding) )
      end
      
      # Load layout _after_ page eval, allowing page to override layout.
      load_layout
      
      # render into the layout if supplied.
      @result = if !@layout_text.nil?
        erb = ERB.new(@layout_text)
        erb.filename = layout_filename
        erb.result(binding)   
      else 
        @content_for_layout
      end 
      
      @result = render_post_filters(@result)      
      freeze
      
      @result 
    end
        
    def inherit_common    # inherit_common is implicit now    vv0.2.99  v-0.5
      warn "Warning: inherit_common is deprecated (inheritance is now implicit)"
    end
        
    # Find and evaluate all COMMON.rb files from page dir up to FS root.
    def eval_common_rubys
      common_rbs = Page::resolve_common_rubys(File.expand_path(File.dirname(template_filename)))            
      common_rbs.each { |fn| instance_eval(File.read(fn),fn) }
            
      true
    end # method
          
  end #class  
end #module
