# POPFile Makefile
#
# This Makefile is used for the creation of POPFile packages
# and for testing
#
# Copyright (c) 2003 John Graham-Cumming

.PHONY: test package windows

# test runs the POPFile unit test suite

test:    ; @perl tests.pl

# windows builds the Windows installer

windows: ; @$(MAKE) -C ../windows

# build a ZIPped up package of POPFile

popfile.zip: popfile.pl pix.gif black.gif insert.pl Classifier/*.pm POPFile/*.pm Proxy/*.pm manual/*.gif manual/*/*.html languages/*.msg skins/*.css skins/*.gif
	rm -f $@
	wzzip -r -P $@ -a $^

# package builds a zip file containing the POPFile package and the windows
# installer

package: popfile.zip windows

	
	

	
	