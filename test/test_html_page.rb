$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__),'../lib'))

require 'test/unit'
require 'rote/page'
require 'rote/format/html'

module Rote
  class TestHtmlPage < Test::Unit::TestCase
    include Format::HTML
    
    # pretend to be a page
    attr_reader :template_name 
    
  end
end  
