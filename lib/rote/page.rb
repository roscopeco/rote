#--
# Rote page class
# (c)2005, 2006, 2012 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
#++

require 'erb'
require 'rote/cache'
require 'rote/filters'

module Rote
  STRIP_SLASHES = /^\/?(.*?)\/?$/
  FILE_EXT = /\..*$/
  
  #####
  ## A +Page+ object represents an individual page in the final 
  ## documentation set, bringing together a source template, 
  ## optional _page_ _code_ (in Ruby) obtained from 
  ## various sources (see below), and an optional layout template
  ## (with it's own code) to produce rendered output as a +String+. 
  ## Specifically, Page provides the following capabilities:
  ##
  ## * Read _template_ _files_ containing ERB code and render them
  ##   to create output.
  ## * Locate and evaluate all _common_ _and_ _page_ _code_ in the binding
  ##   of the Page instance itself.
  ## * Apply _layout_ to rendered content using multiple render
  ##   passes.
  ## * Apply user-supplied _filters_ to the output to allow 
  ##   transformations and additional processing. 
  ##
  ## In normal use the instantiation and initialization of Pages
  ## will be handled internally by Rote. From the user point of 
  ## view most interaction with Rote from user code takes place
  ## via the instance methods of this class.
  ##
  ## == Template lookup and evaluation
  ##
  ## Each +Page+ instance is provided at instantiation with base paths
  ## from which it should resolve both template and layout files when
  ## required. Usually these paths are supplied by the Rake task 
  ## configuration. The attributes that provide information on template
  ## and layout paths (e.g. +template_name+, +base_layout_name+, and
  ## so on) give those paths relative to the +base_path+ and +layout_path+
  ## as appropriate.
  ##
  ## === Common, page and layout code evaluation
  ## 
  ## Code applied to a given page is found and evaluated in the following
  ## order:
  ##
  ## * A block supplied to the <%= section_link 'extension mappings', 'extension mapping' %>
  ##   that matched this page (if any).
  ## * Any COMMON.rb files from the filesystem root down to this directory.
  ## * This page's ruby code, _basename_.rb.
  ## * In the template itself (via ERB).
  ## 
  ## When a +Page+ instance is created, Rote looks for these, and if found evaluates
  ## them, in order, in the +Page+ instance binding.
  ## 
  ## Additionally, when layout is used the following evaluation takes place 
  ## *after rendering the template text* and can be used to make variables 
  ## available for the layout pass(es), and apply nested layout:
  ## 
  ## * This layout's ruby code, _layout_basename_.rb.
  ## * In the layout itself (again, with ERB).
  ##
  ## As mentioned, +Page+ instances serve as the context for page code 
  ## execution - All user-supplied code (COMMON.rb, page and layout code, and
  ## ERB in the templates themselves) is executed in the binding of an instance
  ## of this class.
  ##
  ## == Layout
  ##
  ## All pages support layout, which allow common template to be applied across
  ## several pages. This is handled via multiple render passes, with each layout
  ## responsible for including the previously rendered content (via ERB).
  ##
  ## Layout templates include the content rendered by the page (or previous layout,
  ## see below) render pass using the instance variable @content_for_layout. 
  ## This should be a familar pattern for those familiar with the Rails framework.
  ##
  ## To apply layout to a page, the +layout+ method should be called, passing
  ## in the base-name (with extension if different from the page template).
  ## When issued from common or page code, multiple calls to this method will
  ## override any previous setting. It may be called again from layout code,
  ## however, in which case the output of the currently-rendering layout will
  ## be passed (via the @content_to_layout instance variable) to the specified
  ## layout. In this way, Rote allows layouts to be nested to any level.
  ##
  ## == Filtering
  ##
  ## The +page_filter+ and +post_filter+ methods allow _filters_ to be applied
  ## to a page. Filters can be used to support any kind of textual transformation,
  ## macro expansion (page filters), or post-render processing (post filters).
  ## Rote includes a number of filters as standard, supporting plain-text markup,
  ## syntax highlighting, HTMLTidy postprocessing, and more.
  ##
  ## See +Rote::Filters+ for details of standard filters and their individual use.
  ##
  ## Filters are written in Ruby, and Rote provides base-classes from which filters
  ## can be derived with just a few lines of code (See Rote::Filters::TextFilter
  ## and Rote::Filters::MacroFilter). Additionally, the page and post filter
  ## methods allow text filters to be created from a supplied block.
  ##
  ## == Rendering
  ##
  ## Rendering occurs only once for a given page object, when the +render+ method 
  ## is first called. Once a page has been rendered, the instance it is frozen
  ## to prevent further modification, and the rendered output is cached. Future
  ## calls to +render+ will return the cached output.
  ##
  class Page  
  
    class << self
      # Helper that returns a page-code filename given a template filename.
      # This does not check that the source exists - use the +ruby_filename+
      # instance method to get the actual filename (if any) of source
      # associated with a given page instance.
      def page_ruby_filename(template_fn) # :nodoc:
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
      def resolve_common_rubys(dir, arr = []) # :nodoc:
        # defer to parent dir first
        parent = File.expand_path(File.join(dir, '..'))
        resolve_common_rubys(parent,arr) unless parent == dir # at root    
        fn = File.join(dir,'COMMON.rb')    
        arr << fn if (File.exists?(fn) && File.readable?(fn))
        arr
      end  
    end
    
    # The text of the template to use for this page.
    attr_reader :template_text

    # The text of the layout to use for this page. This is read in
    # when (if) the page source calls layout(basename).
    #
    # *Deprecated* This has no knowledge of nested layout,
    # and operates only on the innermost layout.
    attr_reader :layout_text    # layout_text is deprecated (doesn't work with nested layout) vv0.3.2 v-0.4    
    
    # The basename from which this page's template was read, 
    # relative to the +base_path+.
    attr_reader :template_name
    
    attr_reader :layout_names   # :nodoc:    
    
    # The filename of the innermost layout, usually specified by the page
    # itself, relative to the +layout_path+. This method should not be used 
    # from COMMON.rb since its behaviour is undefined until all page code is
    # evaluated and the final base_layout is known.
    def base_layout_name; layout_names.first; end       
    alias :layout_name :base_layout_name    # Compat alias, please migrate  vv0.3.3 v-0.4
    
    # The base path for template resolution.
    attr_reader :base_path
    
    # The base path for layout resolution
    attr_reader :layout_path
    
    # The array of page filters (applied to this page during the first render 
    # pass, *before* layout is applied). You can use +page_filter+ to 
    # add new page filters, which gives implicit block => Filters::TextFilter conversion 
    # and checks for nil.
    attr_reader :page_filters

    # The array of post filters (applied to this page output *after* 
    # layout is applied). You can use +post_filter+ to add 
    # new post filters, which gives implicit block => Filters::TextFilter conversion 
    # and checks for nil.
    attr_reader :post_filters   
    
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
    def initialize(template_name, pages_dir = '.', layout_dir = pages_dir) 
      @template_text = nil
      @template_name = nil
      @layout_names = []
      @content_for_layout = nil
      @result = nil
      @layout_defext = File.extname(template_name)
      @layout_path = layout_dir[STRIP_SLASHES,1]
      @layout_text = nil
      @base_path = pages_dir[STRIP_SLASHES,1]
      
      @page_filters, @post_filters = [], []

      # read in the template. Layout _may_ get configured later in page code
      # We only add the pages_dir if it's not already there, because it's
      # easier to pass the whole relative fn from rake...
      # template_name always needs with no prefix.
      tfn = template_name
      read_template(tfn)
      
      # Yield to the (extension mapping) block
      yield self if block_given?
      
      # Eval COMMON.rb's
      eval_common_rubys
      
      # get script filenames, and eval them if found
      tfn = ruby_filename # nil if no file      
      instance_eval(File.read(tfn),tfn) if tfn         
    end
            
    # Returns the full filename of this Page's template. This is obtained by
    # joining the base path with template name.
    def template_filename
      File.join(base_path,template_name) if template_name
    end
    
    # Returns the full filename of the first queued layout. This is
    # the innermost layout, usually specified by the page itself.
    def base_layout_filename
      layout_fn(layout_name)
    end
    alias :layout_filename :base_layout_filename    # Compat alias, please migrate  vv0.3.3 v-0.4
    
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
          page_filters << Filters::TextFilter.new(&block)
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
          post_filters << Filters::TextFilter.new(&block)
        end
      end
    end    
    
    # Render this page's textile and ERB, and apply layout.
    # This is only done once - after that, it's cached for next time. You can
    # also circumvent rendering by setting @result yourself in your page's ruby.
    def render
      @result or do_render!   # sets up result for next time...
    end
    
    alias :to_s :render
    
    # Sets the page's base-layout as specified, or applies _nested_ _layout_ 
    # if called during a layout render pass. The specified
    # basename should be the name of the layout file relative to the 
    # +layout_path+. If the layout has the same extension as the page source
    # template, it may be omitted.
    #
    # *The* *layout* *is* *not* *read* *by* *this* *method*. It, and 
    # it's source, are loaded only at rendering time. This prevents
    # multiple calls by various scoped COMMON code, for example, from
    # making a mess in the Page binding.
    #
    # This can only be called before the first call to +render+ returns it's
    # result. After that the Page instance is frozen.
    def layout(basename)
      if basename
        self.layout_names << "#{basename}#{@layout_defext if File.extname(basename).empty?}"
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
    
    def layout_fn(fn)
      File.join(layout_path,fn) if fn
    end
    
    # Loads the layout. This method evaluates the layout code 
    # and returns it's text. The layout (and code if found)
    # are also registered as cached deps.
    def load_layout(fn)
      if fn = layout_fn(fn)
        raise "Layout #{fn} not found" unless File.exists?(fn)
        
        # layout code     
        cfn = Page::page_ruby_filename(fn)
        if File.exists?(cfn)
          instance_eval(File.read(cfn), cfn) 
          Rake.register_dependency(cfn)  
        end

        Rake.register_dependency(fn)
        File.read(fn)                    
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
      
      # FIXME: Quick fix for incorrect COMMON.rb layout nesting.
      # All we do here is reset the layout to be the last layout
      # added. 
      #
      # If it turns out that the ability to nest from COMMON/page
      # really is useless, we should remove the layout queue entirely,
      # and then just have the render layout loop run until
      # layout at end == layout at start.
      @layout_names = [@layout_names.last] unless layout_names.empty?
      
      # Do layout _after_ page eval. As we go through this, the layouts
      # we load may add to the end of the layout names array, so nested
      # layout is supported by just chasing the end of the array until
      # it's empty. The process is basically
      #
      #    Page is loaded, calls 'layout' with it's layout.
      #    During render, that fn is taken, and loaded. Layout code
      #      again calls 'layout'.
      #    On next loop iteration, that new filename is loaded, and it's
      #    code is executed ... and so on.
      #
      #    Each loop puts the result into @content_for_layout, so that
      #    nested layouts can work just the same as regular.
      @layout_names.each do |fn|
        txt = load_layout(fn)
        
        @layout_text ||= txt    # layout_text legacy support    vv0.3.2 v-0.4
        
        # render into the layout if supplied.
        if txt
          erb = ERB.new(txt)
          erb.filename = fn
          @content_for_layout = erb.result(binding)   
        end
      end
      
      @result = render_post_filters(@content_for_layout)      
      freeze
      
      @result 
    end
        
    def inherit_common    # inherit_common is implicit now    vv0.2.99  v-0.4
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
