# POPFile Makefile
#
# This Makefile is used for the creation of POPFile packages
# and for testing
#
# Copyright (c) 2003 John Graham-Cummin

error:
	$(error This needs to be called by the parent Makefile)

runtest:
	@perl -I ../ $(DEBUGARGS) ../tests.pl $(TESTARGS)
ifdef DEBUGARGS
	@perl ../coverage.pl
endif
