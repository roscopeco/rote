ROTE - A static website build tool for Ruby
===========================================

What is this?
-------------

Rote is a simple page-based template system that was written to make it
easier to author and maintain non-dynamic websites and offline documentation. 
Rote provides a simple commandline or [Rake](http://rake.rubyforge.org) based
build for your pages, with page rendering (optionally supporting Textile, RDoc, 
Markdown, and embedded Ruby code with [RedCloth](http://redcloth.rubyforge.org/)
and [ERB](http://www.ruby-doc.org/stdlib/libdoc/erb/rdoc/classes/ERB.html)), 
layout, and general documentation / website build tasks.

Prerequisites
-------------

Rote requires the following (versions are as per my development environment,
you may find you can use older versions, you may not).
	
* Ruby 1.9.3 (http://ruby-lang.org/)
* Rake 0.9.9.2 ('gem install rake')

The following optional dependencies will be used if present:

* RubyGems 1.8.16 (http://rubygems.rubyforge.org/) 
* RedCloth 4.2.9 ('gem install RedCloth') (*Only required if Textile formatting is used*)
* BlueCloth 1.0.1 ('gem install BlueCloth') (*Only required if Markdown or formatting is used*)
* Syntax 1.0.0 ('gem install syntax') (*Only required if syntax highlighting formatting is used*)
* HTMLTidy (http://tidy.sourceforge.net/) (*Only required if Tidy filter is used*)

[RubyGems](http://rubygems.org) is **highly recommended**,
and makes for not only an easier install but a cleaner library path.
Rote is tested with Gems 2.0.3.

Please note that Rote is written and tested on Linux - I have no facilities
to test with, e.g. Windows, and would like very much to hear about any issues 
that affect usage with other OSes.

Installation ... 
-----------------

### ... with RubyGems?

If you have RubyGems, you can install Rote by simply issuing the command:
```
	gem install -r rote 
```	
Which should download the latest version and install it, including
the 'rote' wrapper script and man pages.	If you experience problems,
or wish to perform an offline installation, then simply download the 
.gem file from the FRS, and execute the gem command from within the same
directory.

*Note* that the gem install currently doesn't install the man pages.
You will need to copy them to the appropriate location manually if using
this method.

### ... with install.rb?

If you don't have RubyGems, you can install from one of the tarball or zip
packages found on [our RubyForge page](http://http://rubyforge.org/frs/?group_id=1120)
, using the following command:
```
	ruby install.rb
```	
from the unpacked root directory. This will copy the libaries to the 
appropriate	place, and set up the rote wrapper script, manpages, and so on.

### ... in my own way?

If you're one of those people who just has to be different, then you'll be
pleased to know you can carry on that tradition, and place the files
pretty much where you like. Simply point an environment variable, 
ROTE_LIB, at the top-level lib directory (where rote.rb is found), and
ensure rote (or a symlink) is visible in your path. 

### Did it work?

With that done, you should be able to run 

	rote --version
	
to verify that the command-line wrapper is working. You should of course see
the version number of your Rote installation.

**NOTE** Windows users - you may experience problems at this point, with Rote
complaining that 'rake' is an invalid command. To fix this, simply set an
environment variable, RAKE_CMD, with the command to execute for rake
(e.g. rake.bat).

How do I use it?
----------------

Please see the user guide for usage information. The latest version can be
found online at http://github.com/roscopeco/rote , and documentation source for
a specific release is included in the release package. 

See above for instructions on building the documentation set.

A note about version numbers
----------------------------

Rote uses odd/even numbers for development/release versions. When the final
version component is odd, the package is an 'unofficial' build - generally
this means built manually from source, during development. These will never
be distributed, and there's no guarantee that any two packages with the same
development version will actually be the same. These packages will have no
corresponding CVS tag.

Even numbers always denote 'official' releases, which are released on 
RubyForge and tagged as such in CVS. These packages can be trusted to exhibit
version consistency.

If you are bundling Rote with your product, please ensure you use an official
release version whenever possible. If you must use a developmental version,
please modify the package version to reflect the fact that it is a custom
build (e.g. 0.1.3-mycompany-20121021) to prevent inconsistent development
packages from escaping into the wild.

Further information
-------------------

Rote is developed by Ross Bamford (roscopeco at gmail dot com), with help from
the developers listed in CONTRIBUTORS. Any bugs are probably down to Ross, 
though, so flame him if it breaks your day ;P

* Homepage - http://github.com/roscopeco/rote
* Issues - https://github.com/roscopeco/rote/issues
* Lists - rote-users@rubyforge.org, rote-devel@rubyforge.org (http://rubyforge.org/mail/?group_id=1120)

Thanks
------

As you may have guessed, Rote's hosting and development services are provided
by a combination of [GitHub](http://github.com) and [Rubyforge](http://rubyforge.org).

The people who have been instrumental in making Rote a better piece of 
software, without direct involvement in the development process. Without the
ideas, suggestions, bug reports and guidance from these people, rote would 
probably be totally useless to anyone but me. Keeping a list like this 
accurate and up to date is a recipe for disaster, so I'll take the safe 
option and say 'thanks, everyone' :)

Thanks also to Yukihiro Matsumoto for a remarkable platform, and all those
who write and contribute to the libraries Rote depends on.
