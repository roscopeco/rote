$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__),'../lib'))

require 'test/unit'
require 'rote/page'
require 'rote/filters/haml'
require 'rote/format/html'

module Rote
  class TestHtmlPage < Test::Unit::TestCase
    include Format::HTML
    
    # pretend to be a page
    attr_reader :template_name

    def test_html_format_plays_nice_with_haml
      s = Rote::Filters::Haml.new.filter("%h1= a.my_class('Click me!', :href => '#')", self)
      assert_equal("<h1><a class='my-class' href='#'>Click me!</a></h1>\n", s)
    end
  end
end  
