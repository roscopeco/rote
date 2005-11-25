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
    
    # this is testing also that layouts can be specified in the template itself    
    def test_custom_layout_ext
      p = new_test_page('custext')
      
      # Should have no layout yet (until render)
      assert_nil p.layout_text
      
      # Render will load layout, it'll be available after
      assert_equal "layout \nsome other text for a change.", p.render.chomp

      assert_equal 'layout <%= @content_for_layout %> for a change.', p.layout_text.chomp
    end

    def test_format_opts
      p = new_test_page('justtext')
      assert p.format_opts.empty?
      
      # alter array
      p = new_test_page('textile')
      assert_equal [:textile], p.format_opts
      p.format_opts -= [:textile]
      assert p.format_opts.empty?
      
      # replace array with single sym
      p = new_test_page('textile')
      assert_equal [:textile], p.format_opts
      p.format_opts = [:markdown]
      assert_equal [:markdown], p.format_opts
      p.format_opts = :textile
      # should create array for one sim
      assert_equal [:textile], p.format_opts
      
    end
    
    ############## render #################
    def test_render_text    
      t = new_test_page('justtext').render.chomp
      assert_equal 'Just some text', t
    end    
    
    def test_render_textile
      t = new_test_page('textile').render.chomp
      assert_equal '<p><strong>This</strong> is a <em>simple</em> test of <a href="http://www.textism.org/tools/textile">Textile</a> formatting.</p>', t
    end
    
    def test_render_markdown
      t = new_test_page('markdown').render.chomp
      assert_equal '<h1>*this* is a _test_</h1>', t
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

