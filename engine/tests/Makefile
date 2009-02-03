# POPFile Makefile
#
# This Makefile is used for the creation of POPFile packages
# and for testing
#
# Copyright (c) 2003-2009 John Graham-Cumming
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

error:
	$(error This needs to be called by the parent Makefile)

export POPFILE_ROOT=../
export POPFILE_USER=../tests/

runtest:
	@perl -I ../ $(DEBUGARGS) $(COVERARGS) ../tests.pl $(TESTARGS)
ifdef DEBUGARGS
	@perl ../coverage.pl
endif
ifdef COVERARGS
	cover -report html cover_db
endif
	@rm -rf corpus
	@rm -rf messages

TEST_FILES := $(wildcard *.tst)

eachtest:
	@for mod in $(TEST_FILES); do \
		$(MAKE) runtest TESTARGS=$$mod; \
	done;


