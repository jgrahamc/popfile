# POPFile Makefile
#
# This Makefile is used for the creation of POPFile packages
# and for testing
#
# Copyright (c) 2003 John Graham-Cumming

.PHONY: test package windows core manual skins

error:
	@echo Must specify one of test, package or windows

# test runs the POPFile unit test suite

test:    ; @perl tests.pl

# windows builds the Windows installer

windows: ; @$(MAKE) -C ../windows

# build a ZIPped up package of POPFile

BUILD_ZIP=wzzip -r -P popfile.zip -a $^
popfile.zip: core manual skins

core: popfile.pl pix.gif black.gif insert.pl Classifier/*.pm POPFile/Configuration.pm POPFile/Logger.pm Proxy/POP3.pm
	rm -f popfile.zip
	$(BUILD_ZIP)

manual: manual/*.gif manual/en/*.html languages/*.msg
	$(BUILD_ZIP)

skins: skins/*.css skins/*.gif  skins/*/*.gif
	$(BUILD_ZIP)
	
# package builds a zip file containing the POPFile package and the windows
# installer

package: popfile.zip windows

	
	

	
	