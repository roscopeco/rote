require 'rote/filters/toc'

append_filter @toc = Filters::TOC.new(/h3/)
 
def section_anchor(name)
  name.downcase.gsub(/\s/,'_')
end

def section_link(name, text = name)
  %Q{"#{text}":\##{section_anchor(name)}}
end

def section(level, name, toplink = true)
%Q{
#{"[#{section_link('Top')}]" if toplink}
<a name='#{section_anchor(name)}'></a>
h#{level}. #{name}
}
end
