# Copyright (c) John Graham-Cumming
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
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
.PHONY: all build

include ..\engine\vars.mak

POPFILE_WINDOWS_ZIP := popfile-$(POPFILE_VERSION)-windows.zip
BUILD_ZIP=../engine/wzzip -P $(POPFILE_WINDOWS_ZIP) -a $^

all: build
build: $(POPFILE_WINDOWS_ZIP)
$(POPFILE_WINDOWS_ZIP): setup.exe
	rm -f $@
	$(BUILD_ZIP)

setup.exe: ../engine/*.pl ../engine/Classifier/*.pm ../engine/skins/*.css ../engine/skins/*.gif ../engine/v$(POPFILE_VERSION).change
setup.exe: stop_pf.exe ../engine/popfile.exe ../engine/popfileb.exe ../engine/popfileib.exe ../engine/popfilef.exe ../engine/popfileif.exe
setup.exe: installer.nsi ioA.ini ioB.ini CBP.nsh
	@../NSIS/makensis.exe /V4 $<

stop_pf.exe: stop_popfile.nsi
	@../NSIS/makensis.exe /V4 $<
