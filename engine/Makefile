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

ZIPUP = wzzip -a $(POPFILEZIP) 
POPFILEZIP=popfile.zip

package: 
	@$(ZIPUP) popfile.pl pix.gif black.gif
	@$(ZIPUP) Classifier/*.pm POPFile/*.pm Proxy/*.pm UI/*.pm
	@$(ZIPUP) manual/*.gif manual/*.html
	

	
	