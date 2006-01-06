begin
  require 'rubygems'
rescue LoadError
  nil
end

# make sure we're testing this version, not an installed Gem!
$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__),'../lib'))

require 'test/unit'
require 'rote/page'
require 'rote/filters/redcloth'
require 'rote/filters/bluecloth'
require 'rote/filters/rdoc'
require 'rote/filters/toc'
require 'rote/filters/syntax'
require 'rote/filters/exec'
require 'rote/filters/eval'

SYNTEST = <<-EOM  
  <p>Non-code</p>
  #:code#ruby#
  def amethod(arg)
    puts arg
  end
  #:code#
  <p>More non-code</p>
  #:code#ruby#
  def amethod_too(arg)
    puts arg
  end
  #:code#

EOM

EXECTEST = <<-EOM  
  <p>Non-eval</p>
  #:exec#ruby#
  def amethod(arg)
    puts arg
  end
  
  amethod('Hello, World')  
  #:exec#
  <p>More non-code</p>
  #:exec#ruby#
  puts "Hello again!"  
  #:exec#

EOM

EVALTEST = <<-EOM  
  <p>Non-eval</p>
  #:eval#one#
  def amethod(arg)
    puts arg
  end
  
  amethod('Hello, World')  
  #:eval#
  <p>More non-code</p>
  #:eval#one#
  puts "Hello again!"  
  #:eval#

EOM

SYNEXPECT = <<-EOM
  <p>Non-code</p>
<pre class='ruby'><code class='ruby'>  <span class=\"keyword\">def </span><span class=\"method\">amethod</span><span class=\"punct\">(</span><span class=\"ident\">arg</span><span class=\"punct\">)</span>
    <span class=\"ident\">puts</span> <span class=\"ident\">arg</span>
  <span class=\"keyword\">end</span></code></pre>
  <p>More non-code</p>
<pre class='ruby'><code class='ruby'>  <span class=\"keyword\">def </span><span class=\"method\">amethod_too</span><span class=\"punct\">(</span><span class=\"ident\">arg</span><span class=\"punct\">)</span>
    <span class=\"ident\">puts</span> <span class=\"ident\">arg</span>
  <span class=\"keyword\">end</span></code></pre>
EOM

EXECEXPECT = "  <p>Non-eval</p>\nHello, World\n\n  <p>More non-code</p>\nHello again!\n"

EVALEXPECT = "  <p>Non-eval</p>\nHello, World\n\n  <p>More non-code</p>\nHello again!\n"

TOCTEST = <<-EOM
  <h2>Section One</h2>
  <p>This is section one</p>  
  <h3>Section Two</h3>
  <p>This is section two</p>  
EOM

TOCEXPECTH2 = <<-EOM
  <a name='section_one'></a><h2>Section One</h2>
  <p>This is section one</p>  
  <h3>Section Two</h3>
  <p>This is section two</p>  
EOM

TOCEXPECTALL = <<-EOM
  <a name='section_one'></a><h2>Section One</h2>
  <p>This is section one</p>  
  <a name='section_two'></a><h3>Section Two</h3>
  <p>This is section two</p>  
EOM

module Rote  
  class TestFilters < Test::Unit::TestCase
    
    ############## filters/redcloth #################    
    def test_render_default     # textile
      t = Filters::RedCloth.new.filter('*Textile* _Test_', nil)
      assert_equal '<p><strong>Textile</strong> <em>Test</em></p>', t
    end

    def test_render_textile
      t = Filters::RedCloth.new.filter('*Textile* _Test_', nil)
      assert_equal '<p><strong>Textile</strong> <em>Test</em></p>', t

      t = Filters::RedCloth.new(:textile).filter('*Textile* _Test_', nil)
      assert_equal '<p><strong>Textile</strong> <em>Test</em></p>', t
    end

    def test_render_markdown
      t = Filters::BlueCloth.new.filter("__this__ is a _test_\n==================", nil)
      assert_equal '<h1><strong>this</strong> is a <em>test</em></h1>', t
    end

    def test_render_markdown_custom
      f = Filters::BlueCloth.new do |bluecloth, page| 
        assert_not_nil bluecloth
        assert_nil page           # we pass in nil below

        bluecloth.to_html
      end
      
      t = f.filter("__this__ is a _test_\n==================", nil)
      assert_equal '<h1><strong>this</strong> is a <em>test</em></h1>', t
    end

    ############## filters/rdoc #################
    # FIXME Fails under Gem install, but passes when run normally (???)
    unless defined?(TEST_FROM_GEM)
      def test_render_rdoc
        t = Filters::RDoc.new.filter("== RDoc\n=== Markup",nil)
        assert_equal "<h2>RDoc</h2>\n<h3>Markup</h3>\n", t
      end
    end
    
    ############## filters #################
    
    def test_toc_filter
      # default RE
      toc = Filters::TOC::new
      assert_equal '<p>Has no sections</p>', toc.filter('<p>Has no sections</p>', nil)
      assert toc.links.empty?

      assert_equal TOCEXPECTALL, toc.filter(TOCTEST, nil)
      assert_equal "<a href='#section_one'>Section One</a> - <a href='#section_two'>Section Two</a>", toc.links.join(' - ')

      # custom RE
      toc = Filters::TOC::new(/h2/)
      assert_equal TOCEXPECTH2, toc.filter(TOCTEST, nil)
      assert_equal "<a href='#section_one'>Section One</a>", toc.links.join(' - ')
    end
    
    def test_syntax_filter
      # bad
      assert_equal '', Filters::Syntax.new.filter('',nil)    
      assert_equal 'Has no source', Filters::Syntax.new.filter('Has no source',nil)    
      
      # good
      assert_equal SYNEXPECT.chomp, Filters::Syntax.new.filter(SYNTEST,nil)    
    end
    
    def test_exec_filter
      # bad
      assert_equal '', Filters::Exec.new.filter('',nil)    
      assert_equal 'Has no source', Filters::Exec.new.filter('Has no source',nil)    
      
      # good
      assert_equal EXECEXPECT, Filters::Exec.new.filter(EXECTEST,nil)    
    end
    
    def test_eval_filter
      # bad
      assert_equal '', Filters::Eval.new.filter('',nil)    
      assert_equal 'Has no source', Filters::Eval.new.filter('Has no source',nil)    
      
      # good
      assert_equal EVALEXPECT, Filters::Eval.new.filter(EVALTEST,nil)  
      
      # Make sure Stdout was returned to normal
      assert $stdout.class != StringIO
    end
  end
  
  
end    
  