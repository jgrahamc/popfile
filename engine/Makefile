# POPFile Makefile
#
# This Makefile is used for the creation of POPFile packages
# and for testing
#
# Copyright (c) 2003 John Graham-Cumming

include vars.mak

.PHONY: test package windows core manual skins coverage macosx

error:
	@echo Must specify one of coverage, test, package or windows
	@echo 
	@echo "coverage - Run POPFile test suite with coverage information"
	@echo "test     - Run POPFile test suite"
	@echo "           (test and coverage pass the TESTARGS variable to the test suite)"
	@echo
	@echo "windows  - Build Windows executables and installer" 
	@echo "macosx   - Build Mac OS X package installer"
	@echo "xplat    - Build the cross-platform ZIP"
	@echo "package  - Build Windows installer, and create"
	@echo "           ZIP files for Windows and cross-platform"
	@echo "           version"
	@echo "rc       - After doing package moves the ZIP files to be RC zip files"
	@echo "           The RC number is set with the RC parameter so do" 
	@echo "           make rc RC=RC6 for example."

# test runs the POPFile unit test suite

coverage:
	@echo Running test suite with code coverage
ifdef TESTARGS
	@echo with arguments '$(TESTARGS)'
endif
	@$(MAKE) --no-print-directory -C tests runtest TESTARGS=$(TESTARGS) DEBUGARGS=-d:TestCoverage

test:     
	@echo Running test suite
ifdef TESTARGS
	@echo with arguments '$(TESTARGS)'
endif
	@$(MAKE) --no-print-directory -C tests runtest TESTARGS=$(TESTARGS) DEBUGARGS=

# Mac OS X is built in the Mac OS X directory

macosx: ; @$(MAKE) -C ../macosx

# Builds the tray application using PerlTray

winexe: popfile.exe popfileb.exe popfilef.exe popfileib.exe popfileif.exe trayicon.ico ../windows/POPFileIcon/popfile.ico

TRAY_OPTIONS = --exe $@ --force --clean --dependent --xclude --icon ../windows/POPFileIcon/popfile.ico --icon trayicon.ico --script $< --info CompanyName="The POPFile Project" --info LegalCopyright="Copyright (c) 2003 John Graham-Cumming" --info ProductName=POPFile --info ProductVersion=$(POPFILE_VERSION).0 --info FileDescription=POPFile --info FileVersion=$(POPFILE_VERSION).0 
ifeq ($(TRAY_DEBUG),1)
TRAY_OPTIONS += --debug
endif

popfile.exe: popfile-windows.pl
	perlapp --gui $(TRAY_OPTIONS)

popfileif.exe: popfile-tray.pl POPFile/Loader.pm $(POPFILE_VERSION_FILE)
	perltray --nogui $(TRAY_OPTIONS)

popfileib.exe: popfile-tray.pl POPFile/Loader.pm $(POPFILE_VERSION_FILE)
	perltray $(TRAY_OPTIONS)

popfilef.exe: popfile.pl POPFile/Loader.pm $(POPFILE_VERSION_FILE)
	perlapp $(TRAY_OPTIONS)

popfileb.exe: popfile.pl POPFile/Loader.pm $(POPFILE_VERSION_FILE)
	perlapp --gui $(TRAY_OPTIONS)

# windows builds the Windows installer

windows: winexe; @$(MAKE) -C ../windows

# build a ZIPped up package of POPFile

BUILD_ZIP=wzzip -P $(POPFILE_ZIP) -a $^
xplat: $(POPFILE_ZIP)
$(POPFILE_ZIP): core manual skins POPFile/popfile_version

core: popfile.pl otto.gif pix.gif black.gif bayes.pl pipe.pl insert.pl Classifier/*.pm POPFile/*.pm Proxy/POP3.pm Proxy/Proxy.pm UI/HT??.pm v$(POPFILE_VERSION).change license stopwords favicon.ico $(POPFILE_VERSION_FILE)
	rm -f $(POPFILE_ZIP)
	$(BUILD_ZIP)

manual: manual/*.gif manual/en/*.html languages/*.msg
	$(BUILD_ZIP)

skins: skins/*.css skins/*.gif  skins/*/*.gif
	$(BUILD_ZIP)

# package builds a zip file containing the POPFile package and the windows
# installer

package: $(POPFILE_ZIP) windows

# Used to convert the ZIP files to RC ZIP files and 
# upload to SourceForge

rc: RELEASE_FILES := $(POPFILE_ZIP) ../windows/$(POPFILE_WINDOWS_ZIP) 
rc: 
	chmod go+r $(RELEASE_FILES)
	scp -p $(RELEASE_FILES) jgrahamc@popfile.sourceforge.net:/home/groups/p/po/popfile/htdocs

# The POPFile version number is stored in a file called POPFile/popfile_version 
# which we always write if vars.mak has changed

$(POPFILE_VERSION_FILE): vars.mak
	@echo $(POPFILE_MAJOR_VERSION) > $@
	@echo $(POPFILE_MINOR_VERSION) >> $@
	@echo $(POPFILE_REVISION) >> $@
