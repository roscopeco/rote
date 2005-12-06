begin
  require 'rubygems'
rescue LoadError
  nil
end

require 'test/unit'
require 'rote/page'

module Rote
  class TestPage < Test::Unit::TestCase
    ############## helpers #################
    def new_test_page(basename)  
      Page.new(basename + '.txt', 'test/pages', 'test/layouts')      
    end
    
    ############## Clz methods ################
    def test_page_ruby_filename
      assert_equal 'test/file.rb', Page::page_ruby_filename('test/file.txt')
      assert_equal '/home/me/test/file.rb', Page::page_ruby_filename('/home/me/test/file.txt')
      assert_equal 'file.rb', Page::page_ruby_filename('file.txt')
      assert_equal 'txt.rb', Page::page_ruby_filename('txt')    
      assert_equal '', Page::page_ruby_filename('')    
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
      assert true
    end
       
    ############## accessors #################
    def test_template_text
      p = new_test_page('justtext')
      assert_equal 'Just some text', p.template_text.chomp
    end
            
    def test_layout_text
      p = new_test_page('justtext')
      assert_nil p.layout_text
      
      p = new_test_page('withcode')
      assert_equal 'layout <%= @content_for_layout %> for a change.', p.layout_text.chomp
    end
    
    def test_base_path
      p = new_test_page('justtext')
      assert_equal 'test/pages', p.base_path
    end
    
    def test_layout_path
      p = new_test_page('justtext')
      assert_equal 'test/layouts', p.layout_path
    end
    
    def test_template_name
      p = new_test_page('justtext')
      assert_equal 'justtext.txt', p.template_name
    end
    
    def test_layout_name
      p = new_test_page('justtext')
      assert_nil p.layout_name
                    
      p = new_test_page('withcode')
      assert_equal 'simple.txt', p.layout_name            
    end
    
    def test_template_filename
      p = new_test_page('justtext')
      assert_equal 'test/pages/justtext.txt', p.template_filename
    end
    
    def test_layout_filename
      p = new_test_page('justtext')
      assert_nil p.layout_filename
                    
      p = new_test_page('withcode')
      assert_equal 'test/layouts/simple.txt', p.layout_filename              
    end
    
    def test_ruby_filename
      p = new_test_page('justtext')
      assert_nil p.ruby_filename
                    
      p = new_test_page('withcode')
      assert_equal 'test/pages/withcode.rb', p.ruby_filename              
    end
    
    ############## edges #################
    def test_default_layout_params
      p = Page.new('samedir.txt','test/pages/')
      assert_equal '<%= @global %>', p.template_text.chomp
      assert_equal 'Lay <%= @content_for_layout %> out.', p.layout_text.chomp
    end      
    
    # this is testing also that layouts can be specified in the template itself    
    def test_custom_layout_ext
      p = new_test_page('custext')
      
      # Should have no layout yet (until render)
      assert_nil p.layout_text
      
      # Render will load layout, it'll be available after
      assert_equal "layout \nsome other text for a change.", p.render.chomp

      assert_equal 'layout <%= @content_for_layout %> for a change.', p.layout_text.chomp
    end
    
    ############## render #################
    def test_render_text    
      t = new_test_page('justtext').render.chomp
      assert_equal 'Just some text', t
    end    
    
    def test_render_layout_code  
      t = new_test_page('withcode').render.chomp
      assert_equal 'layout some text and some other text for a change.', t
    end    
    
    ############## broken render #################
    def test_render_switch_layout_freeze
      p = new_test_page('withcode')
      assert_equal 'layout <%= @content_for_layout %> for a change.', p.layout_text.chomp

      p.layout(nil)
      assert_nil p.layout_text      
            
      assert_equal 'some text and some other text', p.render.chomp
      
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

