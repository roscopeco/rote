require 'rote/filters/toc'

page_filter @toc = Filters::TOC.new

# Some helpers for writing out links and sections within
# the text
def section_anchor(name)
  name.downcase.gsub(/\s/,'_')
end

def section_link(name, text = name)
  %Q{"#{text}":\##{section_anchor(name)}}
end

def section(level, name, toplink = true)
%Q{
#{"[#{section_link('Top')}]" if toplink}
h#{level}. #{name}
}
end
