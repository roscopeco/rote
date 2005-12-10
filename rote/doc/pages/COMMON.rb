# Common code for every page.
#
# Instead of being executed once (as you might expect), this is evaluated
# for each Page's binding as the instance is created.
require 'rote/filters/redcloth'
require 'rote/filters/syntax'
require 'rote/filters/tidy'

# Let's use the HTML stuff everywhere ...
extend Format::HTML

@site_title = 'Rote'
@base_url = 'http://rote.rubyforge.org/'

# default to 'page' layout, textile formatting, ruby syntax, Tidy to xhtml
layout 'page'
append_page_filter Filters::RedCloth.new(:textile)
append_page_filter Filters::Syntax.new
append_post_filter Filters::Tidy.new

# this is used to construct the navbar and frontpage. Note that we use absolute
# (root-relative) URLs here, and fix them from each page with 'link_rel'.
@navigation = [
					{:title => 'Home',
					 :url => '/index.html'},
					{:title => 'Download',
					 :url => 'http://rubyforge.org/frs/?group_id=1120'},					 
					{:title => 'User guide',
					 :url => '/guide/'},					 
					{:title => 'RDoc',
					 :url => '/rdoc/'},
					{:title => 'Issue tracker',
					 :url => 'http://rubyforge.org/tracker/?group_id=1120'},
					{:title => 'Project home',
					 :url => 'http://rubyforge.org/projects/rote'},					 
					{:title => 'Browse CVS',
					 :url => 'http://rubyforge.org/cgi-bin/viewcvs.cgi/?cvsroot=rote'},
					{:title => 'Licence',
					 :url => '/license.html'}					 
					]
