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
    include Format::HTML
    
    # pretend to be a page
    attr_reader :template_name 
    
    def test_relative
      @template_name = "three.rhtml" 
      assert_equal '', relative('')
      assert_equal 'not-absolute.html', relative('not-absolute.html')
      assert_equal 'doc/not-absolute.html', relative('doc/not-absolute.html')
      assert_equal 'doc/absolute.html', relative('/doc/absolute.html')
      assert_equal 'doc/files/deep/other.html', relative('/doc/files/deep/other.html')
      
      @template_name = "one/two/three.rhtml" 
      assert_equal 'not-absolute.html', relative('not-absolute.html')
      assert_equal 'doc/not-absolute.html', relative('doc/not-absolute.html')
      assert_equal '../../doc/absolute.html', relative('/doc/absolute.html')
      assert_equal '../../doc/files/deep/other.html', relative('/doc/files/deep/other.html')
    end
  end
end  