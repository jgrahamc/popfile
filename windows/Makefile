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

MAKENSIS_VERSION_STRING:=/DC_POPFILE_MAJOR_VERSION=$(POPFILE_MAJOR_VERSION) /DC_POPFILE_MINOR_VERSION=$(POPFILE_MINOR_VERSION) /DC_POPFILE_REVISION=$(POPFILE_REVISION) /DC_POPFILE_RC=$(RC)

MAKENSIS=makensis.exe $(MAKENSIS_VERSION_STRING) /V2 $<
BUILD_ZIP=wzzip -P $(POPFILE_WINDOWS_ZIP) -a $^

all: build
build: $(POPFILE_WINDOWS_ZIP)
$(POPFILE_WINDOWS_ZIP): setup.exe
	rm -f $@
	$(BUILD_ZIP)

setup.exe: installer.nsi ../engine/*.pl ../engine/POPFile/*.pm ../engine/Classifier/*.pm ../engine/Proxy/*.pm ../engine/UI/*.pm ../engine/Platform/MSWin32.pm ../engine/skins/*/*.css ../engine/skins/*/*.gif ../engine/skins/*/*.thtml ../engine/v$(POPFILE_VERSION).change
setup.exe: stop_pf.exe ../engine/popfile.exe ../engine/popfileb.exe ../engine/popfileib.exe ../engine/popfilef.exe ../engine/popfileif.exe ../engine/popfile-service.exe
setup.exe: runpopfile.exe adduser.exe monitorcc.exe stop_pf.exe msgcapture.exe
setup.exe: ioG.ini pfi-library.nsh WriteEnvStr.nsh
setup.exe: languages/*-pfi.nsh hdr-common.bmp special.bmp remove.ico
setup.exe: UI/pfi_headerbmpr.exe UI/pfi_modern.exe POPFileIcon/popfile.ico
setup.exe: test/pfidiag.exe
setup.exe:
	@$(MAKENSIS)

stop_pf.exe: stop_popfile.nsi pfi-library.nsh shutdown.ico
	@$(MAKENSIS)

runpopfile.exe: runpopfile.nsi pfi-library.nsh languages/English-pfi.nsh
runpopfile.exe: POPFileIcon/popfile.ico
runpopfile.exe:
	@makensis.exe $<

monitorcc.exe: MonitorCC.nsi
monitorcc.exe: WriteEnvStr.nsh pfi-languages.nsh
monitorcc.exe: languages/*-pfi.nsh hdr-common.bmp
monitorcc.exe: UI/pfi_headerbmpr.exe UI/pfi_modern.exe POPFileIcon/popfile.ico
monitorcc.exe:
	@makensis.exe $<

adduser.exe: adduser.nsi monitorcc.exe ioA.ini ioB.ini ioC.ini ioE.ini ioF.ini
adduser.exe: pfi-library.nsh WriteEnvStr.nsh pfi-languages.nsh
adduser.exe: languages/*-pfi.nsh hdr-common.bmp special.bmp remove.ico
adduser.exe: UI/pfi_headerbmpr.exe UI/pfi_modern.exe POPFileIcon/popfile.ico
adduser.exe:
	@makensis.exe $<

msgcapture.exe: msgcapture.nsi pfi-library.nsh hdr-common.bmp
msgcapture.exe: UI/pfi_headerbmpr.exe UI/pfi_modern.exe POPFileIcon/popfile.ico
msgcapture.exe:
	@makensis.exe $<

test/pfidiag.exe: test/pfidiag.nsi test/pfinfo.ico
test/pfidiag.exe: pfi-library.nsh hdr-common.bmp UI/pfi_headerbmpr.exe
test/pfidiag.exe: UI/pfi_modern.exe
test/pfidiag.exe:
	@makensis.exe $<
