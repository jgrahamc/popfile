# POPFile Makefile
#
# This Makefile is used for the creation of POPFile packages
# and for testing
#
# Copyright (c) 2003 John Graham-Cumming

export POPFILE_VERSION=0.19.0

.PHONY: test package windows core manual skins

error:
	@echo Must specify one of test, package or windows

# test runs the POPFile unit test suite

test:    ; @perl tests.pl

# windows builds the Windows installer

windows: ; @$(MAKE) -C ../windows

# build a ZIPped up package of POPFile

POPFILE_ZIP := popfile-$(POPFILE_VERSION).zip
BUILD_ZIP=wzzip -P $(POPFILE_ZIP) -a $^
$(POPFILE_ZIP): core manual skins

core: popfile.pl pix.gif black.gif insert.pl Classifier/*.pm POPFile/*.pm Proxy/POP3.pm Proxy/Proxy.pm UI/HT??.pm *.change license
	rm -f $(POPFILE_ZIP)
	$(BUILD_ZIP)

manual: manual/*.gif manual/en/*.html languages/*.msg
	$(BUILD_ZIP)

skins: skins/*.css skins/*.gif  skins/*/*.gif
	$(BUILD_ZIP)

# package builds a zip file containing the POPFile package and the windows
# installer

package: $(POPFILE_ZIP) windows