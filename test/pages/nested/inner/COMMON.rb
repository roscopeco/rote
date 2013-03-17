# This should *override* the layout specified by the preceeding
# COMMON.rb, i.e. nested layout CANNOT be specified from COMMON,
# This is intentional - COMMON.rb code always overrides the
# COMMON.rb code from above. Nested layout only happens when 
# 'layout' is called from page or layout code.

# Obviously we can specify a layout here that uses nesting, since
# the actual nesting doesn't happen until layout is run. If the 
# page goes on to specify a layout, however, it will override
# this one (as with this test).
layout 'simple'