# POPFile Makefile
#
# This Makefile is used for the creation of POPFile packages
# and for testing
#
# Copyright (c) 2003 John Graham-Cumming

.PHONY: test package windows

# test runs the POPFile unit test suite

test:    ; @perl tests.pl

# windows build the Windows installer

windows: ; @$(MAKE) -C ../windows

# package builds a zip file containing the POPFile package

ZIPUP = wzzip -P $(POPFILEZIP) -a
POPFILEZIP=popfile.zip

package: 
	rm -f $(POPFILEZIP)
	@$(ZIPUP) popfile.pl pix.gif black.gif insert.pl
	@$(ZIPUP) Classifier/*.pm POPFile/*.pm Proxy/*.pm
	@$(ZIPUP) UI/HTML.pm
	@$(ZIPUP) manual/*.gif manual/*.html -r
	@$(ZIPUP) languages/*.msg
	@$(ZIPUP) skins/*.css skins/*.gif
	
	

	
	