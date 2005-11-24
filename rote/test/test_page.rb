require 'test/unit'
require 'rote/page'

module Rote
  class TestPage < Test::Unit::TestCase
    ############## helpers #################
    def new_test_page(basename)  
      Page.new('test/pages/' + basename + '.txt', 'test/layouts')      
    end
    
    ############## initialize #################
    def test_initialize_with_bad_file
      begin
        new_test_page('NONEXISTENT')
      rescue
        assert true
      end
    end
  
    def test_initialize_with_bad_layout 
      begin
        p = new_test_page('badlayout')
      rescue
        assert true
      end
    end  
    
    def test_initialize_ok
      new_test_page('justtext')    
    end
       
    ############## accessors #################
    def test_template_accessors
      p = new_test_page('justtext')
      assert_equal 'Just some text', p.template_text.chomp
    end
            
    def test_layout_accessors
      p = new_test_page('justtext')
      assert_nil p.layout_text
      
      p = new_test_page('withcode')
      assert_equal 'layout <%= @content_for_layout %> for a change.', p.layout_text.chomp
    end
    
    def test_default_layout_params
      p = Page.new('test/pages/samedir.txt')
      assert_equal '<%= @global %>', p.template_text.chomp
      assert_equal 'Lay <%= @content_for_layout %> out.', p.layout_text.chomp
    end      
    
    def test_custom_layout_ext
      p = new_test_page('custext')
      assert_equal 'layout <%= @content_for_layout %> for a change.', p.layout_text.chomp
    end
    
    ############## render #################
    def test_render_text    
      t = new_test_page('justtext').render.chomp
      assert_equal '<p>Just some text</p>', t
    end    
    
    def test_render_textile
      t = new_test_page('textile').render.chomp
      assert_equal '<p><strong>This</strong> is a <em>simple</em> test of <a href="http://www.textism.org/tools/textile">Textile</a> formatting.</p>', t
    end
    
    def test_render_layout_code  
      t = new_test_page('withcode').render.chomp
      assert_equal 'layout <p>some text and some other text</p> for a change.', t
    end    
    
    ############## broken render #################
    def test_render_switch_layout_freeze
      p = new_test_page('withcode')
      assert_equal 'layout <%= @content_for_layout %> for a change.', p.layout_text.chomp

      p.layout(nil)
      assert_nil p.layout_text      
            
      assert_equal '<p>some text and some other text</p>', p.render.chomp
      
      begin
        p.layout('simple')        
      rescue TypeError  # frozen
        assert true
      end
    end    
    
    def test_render_switch_to_bad_layout
      p = new_test_page('withcode')
      assert_equal 'layout <%= @content_for_layout %> for a change.', p.layout_text.chomp

      begin      
        p.layout('nonexistent')
      rescue
        assert true
      end        
    end
        
  end
end

