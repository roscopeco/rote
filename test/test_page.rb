$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__),'../lib'))

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
    
    def test_base_layout_name
      p = new_test_page('justtext')
      assert_nil p.base_layout_name
                    
      p = new_test_page('withcode')
      assert_equal 'simple.txt', p.base_layout_name            
    end
    
    def test_layout_names
      # no layout
      p = new_test_page('justtext')      
      assert p.layout_names.empty?      
                 
      # with page code   
      p = new_test_page('withcode')
      assert_equal ['simple.txt'], p.layout_names            

      # nested
      p = new_test_page('nestedlayout')
      assert_equal ['nestme.txt'], p.layout_names
      
      # Rendering loads the layout code, which adds the
      # rest of the layouts
      p.render      
      assert_equal ['nestme.txt', 'simple.txt'], p.layout_names
    end      
    
    def test_template_filename
      p = new_test_page('justtext')
      assert_equal 'test/pages/justtext.txt', p.template_filename
    end
    
    def test_base_layout_filename
      p = new_test_page('justtext')
      assert_nil p.base_layout_filename
                    
      p = new_test_page('withcode')
      assert_equal 'test/layouts/simple.txt', p.base_layout_filename

      # nested layout is ignored
      p = new_test_page('nestedlayout')
      assert_equal 'test/layouts/nestme.txt', p.base_layout_filename
      
      # even after rendering
      p.render
      assert_equal 'test/layouts/nestme.txt', p.base_layout_filename
    end
    
    def test_ruby_filename
      p = new_test_page('justtext')
      assert_nil p.ruby_filename
                    
      p = new_test_page('withcode')
      assert_equal 'test/pages/withcode.rb', p.ruby_filename              
    end

    ############## relative ###############

    def test_relative
      p = new_test_page('justtext')
      p.instance_eval do 
        self.extend Test::Unit::Assertions

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
    
    ############## layout code #################
    def test_layout_code
      (p = new_test_page('withcode')).render
      assert_equal 'test/layouts/simple.txt', p.base_layout_filename
      assert p.instance_eval { @layout_code_works }            
    end
    
    
    ############## edges #################
    def test_default_layout_params
      (p = Page.new('samedir.txt','test/pages/')).render        
      assert_equal '<%= @global %>', p.template_text.chomp
      assert_equal ['baselayout.txt'], p.layout_names
    end      
    
    # this is testing also that layouts can be specified in the template itself    
    def test_custom_layout_ext
      p = new_test_page('custext')
      
      # Should have no layout yet (until render)
      assert_empty p.layout_names
      
      # Render will load layout, it'll be available after
      assert_equal "layout \nsome other text for a change.", p.render.chomp

      assert_equal ['withext.ext'], p.layout_names
    end
    
    ############## filters ################
    def test_page_filter
      p = new_test_page('justtext')      
      assert p.page_filters.empty?
      
      # test with nil
      p.page_filter(nil)
      assert p.page_filters.empty?
      
      # test with filter
      p.page_filter("filter")
      assert_equal ["filter"], p.page_filters
      
      # test with block
      p.page_filter { "filter" }
      assert_instance_of Rote::Filters::TextFilter, p.page_filters[1]      
    end

    def test_post_filter
      p = new_test_page('justtext')      
      assert p.post_filters.empty?
      
      # test with nil
      p.post_filter(nil)
      assert p.post_filters.empty?
      
      # test with filter
      p.post_filter("filter")
      assert_equal ["filter"], p.post_filters
      
      # test with block
      p.post_filter { "filter" }
      assert_instance_of Rote::Filters::TextFilter, p.post_filters[1]      
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
    
    def test_render_layout_nested  
      t = new_test_page('nestedlayout').render.chomp
      assert_equal "layout with nested: 'some text and some other text' for a change.", t

    end    
    
    # Make sure that layout nesting applies only in layout code,
    # not common or page code. See comments in nested/COMMON.rb(s) and
    # nested/inner/nested-override.txt
    def test_layout_overrides_in_common_rb  
      t = new_test_page('nested/inner/nested-override').render.chomp
      assert_equal "layout with nested: '\n\nSome text\n' for a change.", t
    end    
    
    ############## broken render #################
    def test_render_switch_layout_freeze
      p = new_test_page('withcode')
      
      # It has a layout, but since it's not rendered it's not loaded yet
      assert_equal ['simple.txt'], p.layout_names

      assert_equal 'layout some text and some other text for a change.', p.render.chomp      
      assert p.instance_eval { @layout_code_works }      
      
      begin
        p.layout('simple')        
      rescue TypeError  # frozen
        assert true
      end
    end    
    
    def test_render_switch_to_bad_layout
      (p = new_test_page('withcode')).render
      assert_equal ['simple.txt'], p.layout_names

      begin      
        p.layout('nonexistent')
      rescue
        assert true
      end        
    end
        
  end
end

