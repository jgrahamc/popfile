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

.PHONY: all build clean

ENGINE=../engine
include $(ENGINE)/vars.mak

MAKENSIS_VERSION_STRING:=/DC_POPFILE_MAJOR_VERSION=$(POPFILE_MAJOR_VERSION) /DC_POPFILE_MINOR_VERSION=$(POPFILE_MINOR_VERSION) /DC_POPFILE_REVISION=$(POPFILE_REVISION) /DC_POPFILE_RC=$(RC)

MAKENSIS=echo Making $@ ; makensis.exe $(MAKENSIS_VERSION_STRING) /V2 /O$(patsubst %.exe,%.log,$@) $<
BUILD_ZIP=wzzip -P $(POPFILE_WINDOWS_ZIP) -a $^

SETUP:=setup$(RC).exe
RUNPOPFILE=runpopfile.exe
ADDUSER=adduser.exe
MONITORCC=monitorcc.exe
STOP_PF=stop_pf.exe
MSGCAPTURE=msgcapture.exe
RUNSQLITE=runsqlite.exe

ALLEXES := $(SETUP) $(RUNPOPFILE) $(ADDUSER)     \
           $(MONITORCC) $(STOP_PF) $(MSGCAPTURE) \
           $(RUNSQLITE) $(POPFILE_WINDOWS_ZIP)

all: build
build: $(POPFILE_WINDOWS_ZIP)
$(POPFILE_WINDOWS_ZIP): $(SETUP) addssl.zip
	rm -f $@
	$(BUILD_ZIP)
clean:
	@rm -f $(ALLEXES)

.SUFFIXES:
%.exe : %.nsi pfi-library.nsh ; @$(MAKENSIS)

$(STOP_PF) : stop_popfile.nsi
	@$(MAKENSIS)

test/pfidiag.exe: test/pfidiag.nsi test/pfinfo.ico
test/pfidiag.exe: hdr-common.bmp UI/pfi_headerbmpr.exe
test/pfidiag.exe: UI/pfi_modern.exe
test/pfidiag.exe:
	@cd $(dir $@) ; makensis /v2 $(notdir $<)

$(SETUP): installer.nsi ; @$(MAKENSIS)
$(SETUP): $(ENGINE)/*.pl $(ENGINE)/POPFile/*.pm $(ENGINE)/Classifier/*.pm $(ENGINE)/Proxy/*.pm $(ENGINE)/UI/*.pm $(ENGINE)/Platform/MSWin32.pm $(ENGINE)/skins/*/*.css $(ENGINE)/skins/*/*.gif $(ENGINE)/skins/*/*.thtml $(ENGINE)/v$(POPFILE_VERSION).change
$(SETUP): $(STOP_PF) $(ENGINE)/popfile.exe $(ENGINE)/popfileb.exe $(ENGINE)/popfileib.exe $(ENGINE)/popfilef.exe $(ENGINE)/popfileif.exe $(ENGINE)/popfile-service.exe
$(SETUP): $(RUNPOPFILE) $(ADDUSER) $(MONITORCC) $(STOP_PF) $(MSGCAPTURE)
$(SETUP): ioG.ini WriteEnvStr.nsh
$(SETUP): languages/*-pfi.nsh hdr-common.bmp special.bmp remove.ico
$(SETUP): UI/pfi_headerbmpr.exe UI/pfi_modern.exe
$(SETUP): test/pfidiag.exe $(RUNSQLITE)

$(RUNPOPFILE): $(patsubst %.exe,%.nsi,$(RUNPOPFILE))
$(RUNPOPFILE): languages/English-pfi.nsh

$(MONITORCC): $(patsubst %.exe,%.nsi,$(MONITORCC))
$(MONITORCC): WriteEnvStr.nsh pfi-languages.nsh
$(MONITORCC): languages/*-pfi.nsh hdr-common.bmp
$(MONITORCC): UI/pfi_headerbmpr.exe UI/pfi_modern.exe

$(ADDUSER): $(patsubst %.exe,%.nsi,$(ADDUSER))
$(ADDUSER): $(MONITORCC) ioA.ini ioB.ini ioC.ini ioE.ini ioF.ini
$(ADDUSER): WriteEnvStr.nsh pfi-languages.nsh
$(ADDUSER): languages/*-pfi.nsh hdr-common.bmp special.bmp remove.ico
$(ADDUSER): UI/pfi_headerbmpr.exe UI/pfi_modern.exe

$(MSGCAPTURE): $(patsubst %.exe,%.nsi,$(MSGCAPTURE))
$(MSGCAPTURE): hdr-common.bmp
$(MSGCAPTURE): UI/pfi_headerbmpr.exe UI/pfi_modern.exe
