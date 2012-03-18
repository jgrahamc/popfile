# POPFile Makefile
#
# This Makefile is used for the creation of POPFile packages
# and for testing
#
# Copyright (c) 2003-2012 John Graham-Cumming

export POPFILE_BUILD_YEAR=2012

export POPFILE_MAJOR_VERSION=2
export POPFILE_MINOR_VERSION=0
export POPFILE_REVISION=0
export POPFILE_VERSION:=$(POPFILE_MAJOR_VERSION).$(POPFILE_MINOR_VERSION).$(POPFILE_REVISION)
ABSOLUTE_ENGINE_PATH := C:/Develop/POPFile/2.x/engine
POPFILE_VERSION_FILE=POPFile/popfile_version
POPFILE_ZIP := popfile-$(POPFILE_VERSION)$(RC).zip
POPFILE_WINDOWS_ZIP := popfile-$(POPFILE_VERSION)$(RC)-windows.zip


