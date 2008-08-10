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

.PHONY: all build clean

ENGINE=../../engine
include $(ENGINE)/vars.mak

PACKAGE_DIST=../dist
PACKAGE_TITLE=POPFile-addssl
PACKAGE_VERSION=$(POPFILE_MAJOR_VERSION).$(POPFILE_MINOR_VERSION).$(POPFILE_REVISION)
PACKAGE_VERSION_RC=$(RC)

PACKAGE_NAME=$(PACKAGE_TITLE)-$(PACKAGE_VERSION)$(PACKAGE_VERSION_RC)
PACKAGE_ROOT=./Package_Root
PACKAGE_ID=org.getpopfile

RESOURCES=./Resources

PACKAGE=$(PACKAGE_DIST)/$(PACKAGE_NAME).pkg

LIB_ROOT = $(PACKAGE_ROOT)/Library/POPFile/lib

VOLUME_NAME=$(PACKAGE_NAME)
IMAGE=$(VOLUME_NAME).dmg
IMAGE_TMP=$(VOLUME_NAME)_tmp.dmg
ARCHIVE=$(VOLUME_NAME).dmg.gz

PACKAGE_MAKER = /Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker


all: build
build: ssl_installer

clean:
	rm -rf $(PACKAGE)
	rm -rf $(LIB_ROOT)/*
	rm -rf $(RESOURCES)/License.txt $(RESOURCES)/English.lproj/ReadMe.txt $(RESOURCES)/Japanese.lproj/ReadMe.txt

ssl_installer: documents
ssl_installer: $(LIB_ROOT)/auto/Net/SSLeay/*.* $(LIB_ROOT)/IO/Socket/SSL.pm $(LIB_ROOT)/Net/SSLeay.pm $(LIB_ROOT)/Net/SSLeay/Handle.pm
	@echo "Cleaning up .DS_Store's ..."
	find $(PACKAGE_ROOT) -name .DS_Store -delete
	
	@echo "...done"

	@echo "Applying recommended permissions..."

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

documents: $(ENGINE)/license $(ENGINE)/v$(POPFILE_VERSION).change $(ENGINE)/v$(POPFILE_VERSION).change.nihongo
	cp $(ENGINE)/license $(RESOURCES)/License.txt
	if test ! -d $(RESOURCES)/English.lproj; then mkdir $(RESOURCES)/English.lproj ; fi
	if test ! -d $(RESOURCES)/Japanese.lproj; then mkdir $(RESOURCES)/Japanese.lproj ; fi
	cp $(ENGINE)/v$(POPFILE_VERSION).change $(RESOURCES)/English.lproj/ReadMe.txt
	cp $(ENGINE)/v$(POPFILE_VERSION).change.nihongo $(RESOURCES)/Japanese.lproj/ReadMe.txt


