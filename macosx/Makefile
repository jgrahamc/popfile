# ---------------------------------------------------------------------------
#
# Copyright (c) John Graham-Cumming
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify it
#   under the terms of version 2 of the GNU General Public License as
#   published by the Free Software Foundation.
#
#   POPFile is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with POPFile; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
# ---------------------------------------------------------------------------

.PHONY: all build clean

ENGINE=../engine
include $(ENGINE)/vars.mak

PACKAGE_DIST=./dist
PACKAGE_TITLE=POPFile
PACKAGE_VERSION=$(POPFILE_MAJOR_VERSION).$(POPFILE_MINOR_VERSION).$(POPFILE_REVISION)
PACKAGE_VERSION_RC=$(RC)

PACKAGE_NAME=$(PACKAGE_TITLE)-$(PACKAGE_VERSION)$(PACKAGE_VERSION_RC)
PACKAGE_ROOT=./Package_Root
PACKAGE_ID=org.getpopfile.macosx

RESOURCES=./Resources

UTILITIES=./utilities

PACKAGE=$(PACKAGE_DIST)/$(PACKAGE_NAME).pkg

POPFILE_ROOT=$(PACKAGE_ROOT)/Library/POPFile

VOLUME_NAME=$(PACKAGE_NAME)
IMAGE=$(VOLUME_NAME).dmg
IMAGE_TMP=$(VOLUME_NAME)_tmp.dmg
ARCHIVE=$(VOLUME_NAME)-macosx.dmg.gz

PACKAGE_MAKER = /Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker


all: build
build: $(ARCHIVE)
$(ARCHIVE): $(IMAGE)
	@rm -f $@
	@echo "Compressing disk image ..."
	
	gzip -c $(IMAGE) > $(ARCHIVE)
	
	@echo "...done"
$(IMAGE): installer utility_scripts
	@rm -f $@
	
	@echo "Creating disk image ..."
	
	hdiutil create -megabytes 8 $(IMAGE) -layout NONE
	disk=`hdid -nomount $(IMAGE)` ; \
	newfs_hfs -v $(VOLUME_NAME) $$disk ; \
	hdiutil eject $$disk ; \
	hdid $(IMAGE) ; \
	ditto -v $(PACKAGE_DIST) /Volumes/$(VOLUME_NAME) ; \
	hdiutil eject $$disk

	hdiutil convert $(IMAGE) -format UDZO -o $(IMAGE_TMP)
	mv $(IMAGE_TMP) $(IMAGE)
	
	@echo "...done"

clean:
	rm -f $(ARCHIVE) $(IMAGE)
	rm -rf $(PACKAGE_DIST)
	rm -rf $(POPFILE_ROOT)/*.pl $(POPFILE_ROOT)/*.png $(POPFILE_ROOT)/*.gif $(POPFILE_ROOT)/*.pck $(POPFILE_ROOT)/POPFile $(POPFILE_ROOT)/Classifier $(POPFILE_ROOT)/Proxy $(POPFILE_ROOT)/Services $(POPFILE_ROOT)/UI $(POPFILE_ROOT)/languages $(POPFILE_ROOT)/skins $(POPFILE_ROOT)/stopwords $(POPFILE_ROOT)/license $(POPFILE_ROOT)/favicon.ico $(POPFILE_ROOT)/v*.change*
	rm -rf $(RESOURCES)/License.txt $(RESOURCES)/English.lproj/ReadMe.txt $(RESOURCES)/Japanese.lproj/ReadMe.txt

	$(MAKE) -C ./modules clean

engine = $(ENGINE)/*.pl $(ENGINE)/POPFile/*.pm $(ENGINE)/Classifier/*.pm $(ENGINE)/Proxy/*.pm $(ENGINE)/UI/*.pm $(ENGINE)/Services/IMAP.pm $(ENGINE)/Services/IMAP/Client.pm $(ENGINE)/skins/*/*.css $(ENGINE)/skins/*/*.gif $(ENGINE)/skins/*/*.thtml $(ENGINE)/stopwords $(ENGINE)/license $(ENGINE)/favicon.ico $(ENGINE)/v$(POPFILE_VERSION).change $(ENGINE)/v$(POPFILE_VERSION).change.nihongo

installer: documents engine build_modules
installer: $(engine) ./Readme.txt ./Readme-SnowLeopard.txt ./Readme-Lion.txt
	rm -rf $(PACKAGE_DIST)
	mkdir $(PACKAGE_DIST)

	@echo "Cleaning up .DS_Store's ..."
	find $(PACKAGE_ROOT) -name .DS_Store -delete
	
	@echo "...done"

	@echo "Applying recommended permissions..."

	chmod 744 $(PACKAGE_ROOT)/Library/StartupItems/POPFile/POPFile
	chmod 644 $(PACKAGE_ROOT)/Library/StartupItems/POPFile/StartupParameters.plist

	sudo chown -R root:wheel $(PACKAGE_ROOT)/Library/StartupItems
	#sudo chown -R root:admin $(PACKAGE_ROOT)/Library/POPFile

	@echo "...done"

	@echo "Building installer packages ..."

	$(PACKAGE_MAKER) \
		--root $(PACKAGE_ROOT) \
		--id $(PACKAGE_ID) \
		--out $(PACKAGE) \
		--root-volume-only \
		--discard-forks \
		--target 10.3 \
		--resources $(RESOURCES) \
		--scripts $(RESOURCES) \
		--title $(PACKAGE_TITLE) \
		--version $(PACKAGE_VERSION) \
		--filter CVS \
		--filter .svn \
		--verbose

	@echo "...done"

	@echo "Restoring permissions ..."

	user=`whoami` ; \
	sudo chown -R $$user:staff $(PACKAGE_ROOT)/Library

	@echo "...done"

	PERL510=`perl -e 'print $$] ge qw{5.010000};'`; \
	PERL512=`perl -e 'print $$] ge qw{5.012000};'`; \
	if test "$$PERL512" == "1"; \
	then \
		cp ./Readme-Lion.txt $(PACKAGE_DIST); \
	else \
		if test "$$PERL510" == "1"; \
		then \
			cp ./Readme-SnowLeopard.txt $(PACKAGE_DIST); \
		else \
			cp ./Readme.txt $(PACKAGE_DIST); \
		fi; \
	fi;

utility_scripts: build-utilities
	if test ! -d $(PACKAGE_DIST)/utilities; then mkdir $(PACKAGE_DIST)/utilities ; fi
	cp -r $(UTILITIES)/*.app $(PACKAGE_DIST)/utilities
	cp $(UTILITIES)/Readme.rtf $(PACKAGE_DIST)/utilities

build-utilities:
	$(MAKE) -C ./utilities

mecab:
	$(MAKE) -C ./mecab

build_modules:
	$(MAKE) -C ./modules

documents: $(ENGINE)/license $(ENGINE)/v$(POPFILE_VERSION).change $(ENGINE)/v$(POPFILE_VERSION).change.nihongo InstallationCheck InstallationCheck-SnowLeopard InstallationCheck-Lion
	cp $(ENGINE)/license $(RESOURCES)/License.txt
	if test ! -d $(RESOURCES)/English.lproj; then mkdir $(RESOURCES)/English.lproj ; fi
	if test ! -d $(RESOURCES)/Japanese.lproj; then mkdir $(RESOURCES)/Japanese.lproj ; fi
	perl -e '$$_=join(qw(),<>);s/(?<!\n)\n(?![\n ])/ /g;print;' < $(ENGINE)/v$(POPFILE_VERSION).change > $(RESOURCES)/English.lproj/ReadMe.txt
	SWVER=`sw_vers -productVersion | awk -F "." '{print $$2}'`; \
	if test "$$SWVER" == "6"; \
	then \
		cp InstallationCheck-SnowLeopard $(RESOURCES)/InstallationCheck; \
		perl -e '$$_=join(qw(),<>);s/(?<!\n)\n(?![\n ])/ /g;print;' <  $(ENGINE)/v$(POPFILE_VERSION).change.nihongo > $(RESOURCES)/Japanese.lproj/ReadMe.txt; \
	else \
		if test "$$SWVER" == "7"; \
		then \
			perl -MEncode -e '$$_=join(qw(),<>);s/(?<!\n)\n(?![\n ])/ /g;Encode::from_to($$_,"shift_jis","utf8");print;' <  $(ENGINE)/v$(POPFILE_VERSION).change.nihongo > $(RESOURCES)/Japanese.lproj/ReadMe.txt; \
			cp InstallationCheck-Lion $(RESOURCES)/InstallationCheck; \
		else \
			perl -e '$$_=join(qw(),<>);s/(?<!\n)\n(?![\n ])/ /g;print;' <  $(ENGINE)/v$(POPFILE_VERSION).change.nihongo > $(RESOURCES)/Japanese.lproj/ReadMe.txt; \
			cp InstallationCheck $(RESOURCES)/InstallationCheck; \
		fi; \
	fi;

engine: $(engine)
	rm -rf $(POPFILE_ROOT)/*.pl $(POPFILE_ROOT)/*.png $(POPFILE_ROOT)/*.gif $(POPFILE_ROOT)/*.pck $(POPFILE_ROOT)/POPFile $(POPFILE_ROOT)/Classifier $(POPFILE_ROOT)/Proxy $(POPFILE_ROOT)/Services $(POPFILE_ROOT)/UI $(POPFILE_ROOT)/languages $(POPFILE_ROOT)/skins $(POPFILE_ROOT)/stopwords $(POPFILE_ROOT)/license $(POPFILE_ROOT)/v*.change*
	if test ! -d $(POPFILE_ROOT); then mkdir $(POPFILE_ROOT) ; fi

	cp $(ENGINE)/popfile.pl $(POPFILE_ROOT)
	cp $(ENGINE)/popfile.pck $(POPFILE_ROOT)
	cp $(ENGINE)/import.pl $(POPFILE_ROOT)
	cp $(ENGINE)/insert.pl $(POPFILE_ROOT)
	cp $(ENGINE)/bayes.pl $(POPFILE_ROOT)
	cp $(ENGINE)/pipe.pl $(POPFILE_ROOT)

	cp $(ENGINE)/favicon.ico $(POPFILE_ROOT)

#	cp $(ENGINE)/pix.gif $(POPFILE_ROOT)
#	cp $(ENGINE)/otto.gif $(POPFILE_ROOT)
#	cp $(ENGINE)/otto.png $(POPFILE_ROOT)

	mkdir $(POPFILE_ROOT)/Classifier
	cp $(ENGINE)/Classifier/*.pm $(POPFILE_ROOT)/Classifier
	cp $(ENGINE)/Classifier/popfile.sql $(POPFILE_ROOT)/Classifier

	mkdir $(POPFILE_ROOT)/POPFile
	cp $(ENGINE)/POPFile/*.pm $(POPFILE_ROOT)/POPFile
	cp $(ENGINE)/POPFile/popfile_version $(POPFILE_ROOT)/POPFile
	
	mkdir $(POPFILE_ROOT)/Proxy
	cp $(ENGINE)/Proxy/*.pm $(POPFILE_ROOT)/Proxy

	mkdir $(POPFILE_ROOT)/Services
	mkdir $(POPFILE_ROOT)/Services/IMAP
	cp $(ENGINE)/Services/IMAP.pm $(POPFILE_ROOT)/Services
	cp $(ENGINE)/Services/IMAP/Client.pm $(POPFILE_ROOT)/Services/IMAP

	mkdir $(POPFILE_ROOT)/UI
	cp $(ENGINE)/UI/*.pm $(POPFILE_ROOT)/UI

	mkdir $(POPFILE_ROOT)/languages
	cp $(ENGINE)/languages/*.msg $(POPFILE_ROOT)/languages

	cp -r $(ENGINE)/skins $(POPFILE_ROOT)
	find $(POPFILE_ROOT) -name CVS -print0 | xargs -0 rm -r

	cp $(ENGINE)/stopwords $(POPFILE_ROOT)

	cp $(ENGINE)/license $(POPFILE_ROOT)
	cp $(ENGINE)/v$(POPFILE_VERSION).change $(POPFILE_ROOT)
	cp $(ENGINE)/v$(POPFILE_VERSION).change.nihongo $(POPFILE_ROOT)

