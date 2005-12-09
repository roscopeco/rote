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
require 'rote/filters/toc'
require 'rote/filters/syntax'

SYNTEST = <<-EOM  
  <p>Non-code</p>
  {code:ruby}
  def amethod(arg)
    puts arg
  end
  {code}
  <p>More non-code</p>
  {code}
    Just gets preformatted
  {code}
  <p>Yet more non-code</p>
  {code:ruby}
  def amethod_too(arg)
    puts arg
  end
  {code}
EOM

SYNEXPECT = <<-EOM
  <p>Non-code</p>
  <pre><code>
  <span class=\"keyword\">def </span><span class=\"method\">amethod</span><span class=\"punct\">(</span><span class=\"ident\">arg</span><span class=\"punct\">)</span>
    <span class=\"ident\">puts</span> <span class=\"ident\">arg</span>
  <span class=\"keyword\">end</span>
  </code></pre>
  <p>More non-code</p>
  <pre><code>
    Just gets preformatted
  </code></pre>
  <p>Yet more non-code</p>
  <pre><code>
  <span class=\"keyword\">def </span><span class=\"method\">amethod_too</span><span class=\"punct\">(</span><span class=\"ident\">arg</span><span class=\"punct\">)</span>
    <span class=\"ident\">puts</span> <span class=\"ident\">arg</span>
  <span class=\"keyword\">end</span>
  </code></pre>
EOM

TOCTEST = <<-EOM
  <h2>Section One</h2>
  <p>This is section one</p>  
  <h3>Section Two</h3>
  <p>This is section two</p>  
EOM

module Rote  
  class TestFormatting < Test::Unit::TestCase
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
    unless defined?(TEST_FROM_GEM)
      def test_render_rdoc
        t = Filters::RDoc.new.filter("== RDoc\n=== Markup",nil)
        assert_equal "<h2>RDoc</h2>\n<h3>Markup</h3>\n", t
      end
    end
    
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
    
    # Toc filter is a non-output filter - it's used to get a list of links in 
    # the page, from layout code. It should output it's input directly, so
    # that it doesn't matter where in the chain it is.
    def test_toc_filter
      # default RE
      toc = Filters::TOC::new
      assert_equal '<p>Has no sections</p>', toc.filter('<p>Has no sections</p>', nil)
      assert toc.links.empty?

      assert_equal TOCTEST, toc.filter(TOCTEST, nil)
      assert_equal "<a href='#section_one'>Section One</a> - <a href='#section_two'>Section Two</a>", toc.links.join(' - ')

      # custom RE
      toc = Filters::TOC::new(/h2/)
      assert_equal TOCTEST, toc.filter(TOCTEST, nil)
      assert_equal "<a href='#section_one'>Section One</a>", toc.links.join(' - ')
    end
    
    def test_syntax_filter
      # bad
      assert_equal '', Filters::Syntax.new.filter('', nil)    
      assert_equal 'Has no source', Filters::Syntax.new.filter('Has no source', nil)    
      
      # good
      assert_equal SYNEXPECT, Filters::Syntax.new.filter(SYNTEST, nil)    
    end
  end
end    
  