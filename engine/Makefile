# POPFile Makefile
#
# This Makefile is used for the creation of POPFile packages
# and for testing
#
# Copyright (c) 2003 John Graham-Cumming

include vars.mak

.PHONY: test package windows core manual skins

error:
	@echo Must specify one of coverage, test, package or windows
	@echo 
	@echo "coverage - Run POPFile test suite with coverage information"
	@echo "test     - Run POPFile test suite"
	@echo "           (test and coverage pass the TESTARGS variable to the test suite)"
	@echo
	@echo "windows  - Build Windows installer" 
	@echo "package  - Build Windows installer, and create"
	@echo "           ZIP files for Windows and cross-platform"
	@echo "           version"

# test runs the POPFile unit test suite

coverage:
	@echo Running test suite with code coverage
ifdef TESTARGS
	@echo with arguments '$(TESTARGS)'
endif
	@perl -d:TestCoverage tests.pl $(TESTARGS)

test:     
	@echo Running test suite
ifdef TESTARGS
	@echo with arguments '$(TESTARGS)'
endif
	@perl tests.pl $(TESTARGS)

# windows builds the Windows installer

windows: ; @$(MAKE) -C ../windows

# build a ZIPped up package of POPFile

POPFILE_ZIP := popfile-$(POPFILE_VERSION).zip
BUILD_ZIP=wzzip -P $(POPFILE_ZIP) -a $^
$(POPFILE_ZIP): core manual skins

core: popfile.pl otto.gif pix.gif black.gif bayes.pl pipe.pl insert.pl Classifier/*.pm POPFile/*.pm Proxy/POP3.pm Proxy/Proxy.pm UI/HT??.pm *.change license
	rm -f $(POPFILE_ZIP)
	$(BUILD_ZIP)

manual: manual/*.gif manual/en/*.html languages/*.msg
	$(BUILD_ZIP)

skins: skins/*.css skins/*.gif  skins/*/*.gif
	$(BUILD_ZIP)

# package builds a zip file containing the POPFile package and the windows
# installer

package: $(POPFILE_ZIP) windows