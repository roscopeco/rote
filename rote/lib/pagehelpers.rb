module Rote
  #####
  ## Defines helper methods that are mixed in to Page for use in page source and
  ## template ERB.
  module PageHelpers
  
    ####
    # Makes absolute hrefs (starting with /) into ones relative to this page,
    # by very simply prefixing with a few '..'s. This is pretty inefficient,
    # and a dumb way to do it, but it works for now.
    def link_rel(href)
      hrs = href.to_s.dup  # maybe already a string, to_s returns self
      return href unless hrs[0,1] == '/'    
      
      # strip '[/]target/' 
      begin
        pagepath = /^\/?target\/(.*)$/.match(target_fn).captures[0]
      rescue 
        # not proper target filename on page
        return href
      end
      
      # strip '/' prefix 
      hrs[0,1] = ''
      bits = pagepath.split('/')
      
      return ('../' * (bits.length - 1)) + hrs    
    end
    
    ####
    # Layout helper. Call this with the basename of your layout, without path
    # or extension, to set the layout for a page.
    # 
    # *Note*: This doesn't follow the usual '=' convention, instead it's (a bit)
    # like the equivalent in rails.
    def layout(basename)
      @layout = basename
      @layout_text = basename == nil ? nil : File.read('site/layouts/' + basename + ".rhtml")
    end          
    
  end # PageHelpers
end # Rote
