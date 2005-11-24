module Rote

  # An extension to the Rake +FileList+ class that allows a root
  # directory to be specified.
  class DirectoryFileList < FileList  
  
    # Create a +DirectoryFileList+ with optional root directory and
    # patterns. You may also pass a block to perform additional
    # configuration (e.g. if you have a lot of includes/excludes
    # or just don't like arguments for whatever reason).
    def initialize(basedir = '.', *patterns)
      dir=(basedir)
      super(*patterns)
    end
  
    # The root directory from which this filelist matches. All patterns
    # are considered relative to this directory.
    attr_accessor :dir        
    def dir=(newdir)
      newdir = newdir.sub(/\/$/,'')
      sub!(/^#{@dir}/,newdir)
      @dir = newdir    
    end
   
    # Adds the specified *shell glob* pattern(s) to the list of includes
    # for this file list. The base directory is implied.
    def include(*patterns)
      super(*patterns.map { |it| "#{dir}/#{it}"})
    end  

    # Adds the specified *regexp or shell glob* pattern(s) to the list of
    # excludes for this file list. The base directory is implied on 
    # non-+Regexp+.arguments.
    def exclude(*patterns)
      # exclude takes regexps too, which we should leave alone.
      super(*patterns.map { |it| 
        it.is_a?(String) ? "#{dir}/#{it}" : it
      })
    end  
  end
  
end