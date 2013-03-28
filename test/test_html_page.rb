$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__),'../lib'))

require 'test/unit'
require 'rote/page'
require 'rote/format/html'

module Rote
  class TestHtmlPage < Test::Unit::TestCase
    include Format::HTML
    
    # pretend to be a page
    attr_reader :template_name

    def test_tag
      assert_equal "<a></a>", tag("a").to_s
      assert_equal "<a one='two'></a>", tag("a", :one => 'two').to_s
      assert_equal "<a one='1' two='2'></a>", tag("a", :one => '1', :two => '2').to_s

      assert_equal "<a data-one='1'></a>", tag("a", :data_one => '1').to_s

      assert_equal "<a>Something</a>", tag("a") { "Something" }.to_s
      assert_equal "<a one='1'>Something</a>", tag("a", :one => 1) { "Something" }.to_s
      
      assert_equal "<a>Something</a>", tag("a", "Something").to_s
      assert_equal "<a one='1'>Something</a>", tag("a", "Something", :one => 1).to_s
      assert_equal "<a one='1'>Something</a>", tag("a", {:one => 1}, "Something").to_s
      
    end

    def test_method_missing
      assert_equal "<a></a>", a.to_s
      assert_equal "<a one='two'></a>", a(:one => 'two').to_s
      assert_equal "<a one='1'>Something</a>", a(:one => 1) { "Something" }.to_s
    end

    def test_with_class
      assert_equal "<a class='aclass'></a>", a.aclass.to_s
      assert_equal "<a class='aclass' one='1'></a>", a.aclass(:one => 1).to_s
      assert_equal "<a class='aclass' one='1'>Something</a>", a.aclass(:one => 1) { "Something" }.to_s
      assert_equal "<a class='aclass' one='1'>Something</a>", a.aclass("Something", :one => 1).to_s
      assert_equal "<a class='aclass' one='1'>SomethingElse</a>", a { "Something" }.aclass(:one => 1) { "Else" }.to_s
      assert_equal "<a class='aclass' one='1'>SomethingElse</a>", a { "Something" }.aclass("Else", :one => 1).to_s
      assert_equal "<li class='aclass also this'></li>", li.aclass(:class => 'also this').to_s
      assert_equal "<ol class='aclass also this'></ol>", ol.aclass.also(:class => 'this').to_s
      assert_equal "<a class='aclass and also this'></a>", a.aclass(:class => 'and').also(:class => 'this').to_s
      assert_equal "<ul class='aclass bclass' one='1 2'></ul>", ul.aclass(:one => 1).bclass(:one => 2).to_s

      assert_equal "<div class='my-class'></div>", div.my_class.to_s
    end
  end
end  
