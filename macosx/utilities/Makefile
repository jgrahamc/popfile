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
.SUFFIXES: .applescript .app

PACKAGE_ROOT=../Package_Root
POPFILE_ROOT=$(PACKAGE_ROOT)/Library/POPFile

OSACOMPILE = osacompile

SCRIPTS = start-popfile.applescript stop-popfile.applescript open-popfile-ui.applescript start-popfile-with-console.applescript custom-data-folder.applescript uninstall-popfile.applescript
APPS = $(SCRIPTS:.applescript=.app)

all: build
build: $(SCRIPTS) $(APPS)

clean:
	rm -rf $(APPS)

.applescript.app:
	$(OSACOMPILE) -o $@ $<
