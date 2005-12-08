begin
  require 'rubygems'
rescue LoadError
  nil
end

require 'test/unit'
require 'rote/page'
require 'rote/filters/redcloth'
require 'rote/filters/rdoc'
require 'rote/filters/proc'

module Rote
  class TestHtmlPage < Test::Unit::TestCase
    ############## filters/redcloth #################    
    def test_render_default     # textile
      t = Filters::RedCloth.new.filter('*Textile* _Test_', nil)
      assert_equal '<p><strong>Textile</strong> <em>Test</em></p>', t
    end

    def test_render_textile
      t = Filters::RedCloth.new(:textile).filter('*Textile* _Test_', nil)
      assert_equal '<p><strong>Textile</strong> <em>Test</em></p>', t
    end

    def test_render_markdown
      t = Filters::RedCloth.new(:markdown).filter("*this* is a _test_\n==================", nil)
      assert_equal '<h1>*this* is a _test_</h1>', t
    end

    ############## filters/rdoc #################
    # FIXME Fails under Gem install, but passes when run normally (???)
    # unless defined?(TEST_FROM_GEM)
      def test_render_rdoc
        t = Filters::RDoc.new.filter("== RDoc\n=== Markup",nil)
        assert_equal "<h2>RDoc</h2>\n<h3>Markup</h3>\n", t
      end
    # end
    
    ############## filters/proc #################
    # FIXME Fails under Gem install, but passes when run normally (???)
    def test_proc_no_block
      begin
        Filters::Proc.new
      rescue ArgumentError => ex
        assert_equal 'No block given', ex.message
      end      
    end
    
    def test_render_with_proc
      f = Filters::Proc.new { |text, page| text + page }
      assert_equal f.filter('some text ', 'fake page'), 'some text fake page'      

      # equivalent
      f = Filters::Proc.with do |text, page| 
        text + page 
      end      
      assert_equal f.filter('some text ', 'fake page'), 'some text fake page'      
    end
  end
end    
  