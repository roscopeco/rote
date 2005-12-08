require 'redcloth'

module Rote
  module Filters
    
    # Filter that applies Redcloth formatting
    class RedCloth
      def initialize(*redcloth_opts)
        @redcloth_opts = redcloth_opts
        raise "RedCloth is not available" unless defined?(RedCloth)
      end
      
      def filter(text, page)
        rc = ::RedCloth.new(text)        
        # FIXME  hack around a RedCloth warning
        rc.instance_eval { @lite_mode = false }  
         
        rc.to_html(*@redcloth_opts) 
      end
    end
    
  end
end
    
