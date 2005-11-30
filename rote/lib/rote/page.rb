require 'erb'
require 'rdoc/markup/simple_markup'
require 'rdoc/markup/simple_markup/to_html'

begin
  require 'redcloth'
rescue LoadError
  # optional dep
  NOREDCLOTH = true
end

module Rote

  #####
  ## A +Page+ object represents an individual page, taking input from a
  ## template and (optionally) some ruby code, and producing rendered
  ## ('merged') output as a +String+.
  ## When a page is created, ruby source will be found alongside the 
  ## file, with same basename and an '.rb' extension. If found it will
  ## run through +instance_eval+. That source can call methods
  ## and set any instance variables, for use later in the template.
  ##
  ## Rendering happens only once for a given page object, when the 
  ## +render+ method is first called. Once a page has been rendered
  ## it is frozen.
  class Page  
    # The text of the template to use for this page.
    attr_reader :template_text

    # The text of the layout to use for this page. This is read in
    # when (if) the page source calls layout(basename).
    attr_reader :layout_text
    
    # Formatting options passed to RedCloth. This is an array of the
    # option symbols defined by RedCloth.
    # The most common are :textile and :markdown. See RedCloth
    # documentation for full details of supported options.
    # 
    # The default is [], which means 'No formatting'. This setting
    # does not affect ERB rendering (which is always performed, before
    # any formatting).
    attr_reader :format_opts
    def format_opts=(opts)
      if !opts.nil? && opts.respond_to?(:to_ary)
        @format_opts = opts
      else
        @format_opts = [opts]
      end
    end
    
    # Reads the template, and evaluates the global and page scripts, if 
    # available, using the current binding. You may define any instance
    # variables or methods you like in that code for use in the template,
    # as well as accessing the predefined @template and @template_text
    # variables.
    #
    # If specified, the layout path will be used to find layouts referenced
    # from templates. 
    #
    # If a block is supplied, it is executed _after_ the global / page
    # code, so you can locally override variables and so on. 
    def initialize(template_fn, 
                   layout_path = File.dirname(template_fn), 
                   default_layout_ext = File.extname(template_fn)) # :yield: self if block_given?    
      @template_text = nil
      @layout_text = nil
      @content_for_layout = nil
      @result = nil
      @format_opts = []
      @layout_defext = default_layout_ext
      @layout_path = layout_path
      @fixme_dir = File.dirname(template_fn)
      
      # read in the template. Layout _may_ get configured later in page code
      read_template(template_fn)
      
      # get script filenames, and eval them if found
      src_rb = template_fn.sub(/\..*$/,'') + '.rb'            
      section_rb = @fixme_dir + '/COMMON.rb'
      instance_eval(File.read(section_rb)) if File.exists?(section_rb)     
      instance_eval(File.read(src_rb)) if File.exists?(src_rb)    
      
      # Allow block to have the final say
      yield self if block_given?  
    end
            
    # Sets the layout from the specified file, or disables layout if
    # +nil+ is passed in. The specified basename should be the name
    # of the layout file relative to the +layout_dir+, with no extension.
    #
    # The layout is read by this method. An exception is
    # thrown if the layout doesn't exist.
    #
    # This can only be called before the first call to +render+. After 
    # that the instance is frozen.
    def layout(basename)
      if basename
        fn = layout_fn(basename)
        raise "Layout #{fn} not found" unless File.exists?(fn)
        @layout_text = File.read(fn)
      else
        @layout_text = nil
      end
    end    
    
    # Render this page's textile and ERB, and apply layout.
    # This is only done once - after that, it's cached for next time. You can
    # also circumvent rendering by setting @result yourself in your page's ruby.
    def render
      @result or do_render!   # sets up result for next time...
    end
    
    alias to_s render
    
    private
        
    # Sets the template from the specified file, or clears the template if
    # +nil+ is passed in. The specified basename should be the name
    # of the layout file relative to the +layout_dir+, with no extension.
    def read_template(fn)
      if fn
        raise "Template #{fn} not found" unless File.exists?(fn)
        @template_text = File.read(fn)
      else
        @template_text = nil
      end
    end  
    
    def render_fmt(text)
      result = text
    
      # need to get opts to a known state (array), and copy it
      # so we can modify it.
      if @format_opts && ((@format_opts.respond_to?(:to_ary) && (!@format_opts.empty?)) || @format_opts.is_a?(Symbol)) 
        opts = @format_opts.respond_to?(:to_ary) ? @format_opts.dup : [@format_opts] 
          
        # Remove :rdoc opts from array (RedCloth doesn't do 'em) 
        # and remember for after first rendering...
        #
        # Cope with multiple occurences of :rdoc
        unless (rdoc_opt = opts.grep(:rdoc)).empty?
          opts -= rdoc_opt
        end
          
        # Render out RedCloth / markdown
        unless opts.empty?
          unless defined?(NOREDCLOTH)
            result = RedCloth.new(result).to_html(*opts) 
          else
            puts "WARN: RedCloth options specified but no RedCloth installed"
          end
        end
          
        # Render out Rdoc
        #
        # TODO could support alternative output formats by having the user supply
        #      the formatter class (ToHtml etc).         
        unless rdoc_opt.empty?
          p = SM::SimpleMarkup.new
          h = SM::ToHtml.new
          result = p.convert(result, h)                      
        end
      end
      
      result
    end
    
    
    # render, set up @result for next time. Return result too.    
    def do_render!
      # Render the page content into the @content_for_layout
      unless @template_text.nil?
        @content_for_layout = render_fmt( ERB.new(@template_text).result(binding) )
      end
      
      # render into the layout if supplied.
      @result = if !@layout_text.nil?
        ERB.new(@layout_text).result(binding)   
      else 
        @content_for_layout
      end 
      
      freeze
      
      @result 
    end
        
    # Get a full layout filename from a basename. If the basename has no extension,
    # the default extension is added.
    def layout_fn(basename) 
      ext = File.extname(basename)
      "#{@layout_path}/#{basename}#{@layout_defext if ext.empty?}"    
    end
    
    # FIXME NASTY HACK: Allow templates to inherit COMMON.rb. This should be replaced
    # with a proper search for inherited in Page.new. Call from your COMMON.rb to 
    # inherit the COMMON.rb immediately above this. If none exists there, this doesn't go
    # looking beyond that - it just returns false
    def inherit_common
      inh = "#{@fixme_dir}/../COMMON.rb"
      if File.exists?(inh)
        instance_eval(File.read(inh))
        true              
      else
        false
      end
    end
    
    # FIXME NASTY HACK II: relative links (doesn't work)
    def link_rel(href) 
      thr = href
      if thr.is_a?(String) && href[0,1] == '/'
        thr = href[1..href.length]     
        count = @fixme_dir.split('/').length - 2
        if count > 0 then count.times {
          thr = '../' + thr
        } end      
      end
      thr
    end
    
  end #class  
end #module