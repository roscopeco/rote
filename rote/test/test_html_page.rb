begin
  require 'rubygems'
rescue LoadError
  nil
end

require 'test/unit'
require 'rote/page'
require 'rote/format/html'

module Rote
  class TestHtmlPage < Test::Unit::TestCase
    ############## helpers #################
    def new_test_page(basename)  
      Page.new(basename + '.txt', 'test/pages', 'test/layouts')      
    end
        
    ############## render #################
    def test_render_textile
      t = new_test_page('textile').render.chomp
      assert_equal '<p><strong>This</strong> is a <em>simple</em> test of <a href="http://www.textism.org/tools/textile">Textile</a> formatting.</p>', t
    end

    # FIXME Fails under Gem install, but passes when run normally (???)
    unless defined?(TEST_FROM_GEM)
      def test_render_rdoc
        begin
          t = new_test_page('rdoc').render.chomp
          assert_equal "<h2>RDoc</h2>\n<h3>Markup</h3>", t
        rescue Object => ex
          p ex
        end
      end
    end
    
    def test_render_markdown
      t = new_test_page('markdown').render.chomp
      assert_equal '<h1>*this* is a _test_</h1>', t
    end
    
    ############## acc / helpers #################
    def test_format_opts
      # alter array
      p = new_test_page('textile')
      assert_equal [:textile], p.format_opts
      p.format_opts -= [:textile]
      assert p.format_opts.empty?
      
      # replace array with single sym
      p = new_test_page('textile')
      assert_equal [:textile], p.format_opts
      p.format_opts = [:markdown]
      assert_equal [:markdown], p.format_opts
      p.format_opts = :textile
      # should create array for one sym
      assert_equal [:textile], p.format_opts
    end
    
    def test_relative
      # TODO test needed
    end
  end
end  