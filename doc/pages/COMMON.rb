# Common code for every page.
#
# Instead of being executed once (as you might expect), this is evaluated
# for each Page's binding as the instance is created.
@site_title = 'Rote'
@base_url = 'http://rote.rubyforge.org/'

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
