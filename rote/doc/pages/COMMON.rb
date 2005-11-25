@site_title = 'Rote'
@base_url = 'http://rote.rubyforge.org/'

# default to 'page' layout and textile formatting
layout 'page'
format_opts << :textile

# this is used to construct the navbar and frontpage.
@navigation = [
					{:title => 'Home',
					 :url => '/index.html'},
					{:title => 'RDoc',
					 :url => 'rdoc/'},					 
					{:title => 'Project home',
					 :url => 'http://rubyforge.org/projects/rote'},					 
					{:title => 'Browse CVS',
					 :url => 'http://rubyforge.org/cgi-bin/viewcvs.cgi/?cvsroot=rote'}
					]
