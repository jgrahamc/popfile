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

PACKAGE_ROOT=../Package_Root
POPFILE_ROOT=$(PACKAGE_ROOT)/Library/POPFile
LIB_ROOT = $(POPFILE_ROOT)/lib

KAKASI_DIC_ROOT = $(POPFILE_ROOT)/kakasi

SSLPACKAGE_ROOT = ../addssl/Package_Root
SSLPACKAGE_LIBRARY_ROOT = $(SSLPACKAGE_ROOT)/Library
SSLPOPFILE_ROOT = $(SSLPACKAGE_LIBRARY_ROOT)/POPFile
SSLLIB_ROOT = $(SSLPOPFILE_ROOT)/lib

FAKECONFIG = ExtUtils-FakeConfig-0.11
FAKECONFIG_ARCHIVE = $(FAKECONFIG).zip
FAKECONFIG_URL = http://search.cpan.org/CPAN/authors/id/M/MB/MBARBON/$(FAKECONFIG_ARCHIVE)

DBI = DBI-1.604
DBI_ARCHIVE = $(DBI).tar.gz
DBI_URL = http://search.cpan.org/CPAN/authors/id/T/TI/TIMB/$(DBI_ARCHIVE)

SQLITE = DBD-SQLite-1.14
SQLITE_ARCHIVE = $(SQLITE).tar.gz
SQLITE_URL = http://search.cpan.org/CPAN/authors/id/M/MS/MSERGEANT/$(SQLITE_ARCHIVE)

SQLITE2 = DBD-SQLite2-0.33
SQLITE2_ARCHIVE = $(SQLITE2).tar.gz
SQLITE2_URL = http://search.cpan.org/CPAN/authors/id/M/MS/MSERGEANT/$(SQLITE2_ARCHIVE)

TAGSET = HTML-Tagset-3.20
TAGSET_ARCHIVE = $(TAGSET).tar.gz
TAGSET_URL = http://search.cpan.org/CPAN/authors/id/P/PE/PETDANCE/$(TAGSET_ARCHIVE)

TEMPLATE = HTML-Template-2.9
TEMPLATE_ARCHIVE = $(TEMPLATE).tar.gz
TEMPLATE_URL = http://search.cpan.org/CPAN/authors/id/S/SA/SAMTREGAR/$(TEMPLATE_ARCHIVE)

TIMEDATE = TimeDate-1.16
TIMEDATE_ARCHIVE = $(TIMEDATE).tar.gz
TIMEDATE_URL = http://search.cpan.org/CPAN/authors/id/G/GB/GBARR/$(TIMEDATE_ARCHIVE)

# XMLRCP Support

SOAPLITE = SOAP-Lite-0.710.05
SOAPLITE_ARCHIVE = $(SOAPLITE).tar.gz
SOAPLITE_URL = http://search.cpan.org/CPAN/authors/id/M/MK/MKUTTER/$(SOAPLITE_ARCHIVE)

VERSION_MODULE = version-0.74
VERSION_ARCHIVE = $(VERSION_MODULE).tar.gz
VERSION_URL = http://search.cpan.org/CPAN/authors/id/J/JP/JPEACOCK/$(VERSION_ARCHIVE)

# Japanese support

KAKASI = kakasi-2.3.4
KAKASI_ARCHIVE = $(KAKASI).tar.gz
KAKASI_URL = http://kakasi.namazu.org/stable/$(KAKASI_ARCHIVE)

TEXTKAKASI = Text-Kakasi-2.04
TEXTKAKASI_ARCHIVE = $(TEXTKAKASI).tar.gz
TEXTKAKASI_URL = http://search.cpan.org/CPAN/authors/id/D/DA/DANKOGAI/$(TEXTKAKASI_ARCHIVE)

# SSL support

NETSSLEAY = Net-SSLeay-1.32
NETSSLEAY_ARCHIVE = $(NETSSLEAY).tar.gz
NETSSLEAY_URL = http://search.cpan.org/CPAN/authors/id/F/FL/FLORA/$(NETSSLEAY_ARCHIVE)

IOSOCKETSSL = IO-Socket-SSL-1.13
IOSOCKETSSL_ARCHIVE = $(IOSOCKETSSL).tar.gz
IOSOCKETSSL_URL = http://search.cpan.org/CPAN/authors/id/S/SU/SULLR/$(IOSOCKETSSL_ARCHIVE)


CORE_ARCHIVES = $(DBI_ARCHIVE) $(SQLITE_ARCHIVE) $(SQLITE2_ARCHIVE) $(TAGSET_ARCHIVE) $(TEMPLATE_ARCHIVE) $(TIMEDATE_ARCHIVE)
CORE_MODULES = $(DBI) $(SQLITE) $(SQLITE2) $(TAGSET) $(TEMPLATE) $(TIMEDATE)

JAPANESESUPPORT_ARCHIVES = $(KAKASI_ARCHIVE) $(TEXTKAKASI_ARCHIVE)
JAPANESESUPPORT_MODULES = $(KAKASI) $(TEXTKAKASI)

XMLRPC_ARCHIVES = $(SOAPLITE_ARCHIVE) $(VERSION_ARCHIVE)
XMLRPC_MODULES = $(SOAPLITE) $(VERSION_MODULE)

SSL_ARCHIVES = $(NETSSLEAY_ARCHIVE) $(IOSOCKETSSL_ARCHIVE)
SSL_MODULES = $(NETSSLEAY) $(IOSOCKETSSL)

all: build
build: core_modules japanese_modules xmlrpc_modules ssl_modules kakasi_dictionary

clean:
	rm -rf $(CORE_ARCHIVES) $(JAPANESESUPPORT_ARCHIVES) $(XMLRPC_ARCHIVES) $(SSL_ARCHIVES)
	rm -rf $(CORE_MODULES) $(JAPANESESUPPORT_MODULES) $(XMLRPC_MODULES) $(SSL_MODULES)
	rm -rf $(LIB_ROOT)/*
	rm -rf $(SSLLIB_ROOT)/*
	rm -rf $(KAKASI_DIC_ROOT)/*

core_modules:core_modules_build $(CORE_MODULES)
	if test ! -d $(LIB_ROOT); then mkdir $(LIB_ROOT) ; fi

	cp -rf $(DBI)/blib/arch/auto $(LIB_ROOT)
	cp -rf $(DBI)/blib/lib/* $(LIB_ROOT)

	cp -rf $(SQLITE)/blib/arch/auto $(LIB_ROOT)
	cp -rf $(SQLITE)/blib/lib/* $(LIB_ROOT)

	cp -rf $(SQLITE2)/blib/arch/auto $(LIB_ROOT)
	cp -rf $(SQLITE2)/blib/lib/* $(LIB_ROOT)

	cp -rf $(TAGSET)/blib/arch/auto $(LIB_ROOT)
	cp -rf $(TAGSET)/blib/lib/* $(LIB_ROOT)

	cp -rf $(TEMPLATE)/blib/arch/auto $(LIB_ROOT)
	cp -rf $(TEMPLATE)/blib/lib/* $(LIB_ROOT)

	cp -rf $(TIMEDATE)/blib/arch/auto $(LIB_ROOT)
	cp -rf $(TIMEDATE)/blib/lib/* $(LIB_ROOT)

xmlrpc_modules: xmlrpc_modules_build
	if test ! -d $(LIB_ROOT); then mkdir $(LIB_ROOT) ; fi

	cp -rf $(SOAPLITE)/lib/* $(LIB_ROOT)

	cp -rf $(VERSION_MODULE)/blib/arch/auto $(LIB_ROOT)
	cp -rf $(VERSION_MODULE)/blib/lib/* $(LIB_ROOT)

japanese_modules: japanese_modules_build
	if test ! -d $(LIB_ROOT); then mkdir $(LIB_ROOT) ; fi

	cp -rf $(TEXTKAKASI)/blib/arch/auto $(LIB_ROOT)
	cp -rf $(TEXTKAKASI)/blib/lib/* $(LIB_ROOT)

ssl_modules: ssl_modules_build
	if test ! -d $(SSLPACKAGE_ROOT); then mkdir $(SSLPACKAGE_ROOT) ; fi
	if test ! -d $(SSLPACKAGE_LIBRARY_ROOT); then mkdir $(SSLPACKAGE_LIBRARY_ROOT) ; fi
	if test ! -d $(SSLPOPFILE_ROOT); then mkdir $(SSLPOPFILE_ROOT) ; fi
	if test ! -d $(SSLLIB_ROOT); then mkdir $(SSLLIB_ROOT) ; fi

	cp -rf $(NETSSLEAY)/blib/arch/auto $(SSLLIB_ROOT)
	cp -rf $(NETSSLEAY)/blib/lib/* $(SSLLIB_ROOT)

	cp -rf $(IOSOCKETSSL)/blib/arch/auto $(SSLLIB_ROOT)
	cp -rf $(IOSOCKETSSL)/blib/lib/* $(SSLLIB_ROOT)


core_modules_build: $(CORE_ARCHIVES)
core_modules_build: fakeconfig
	if test ! -d $(DBI); then tar xzf $(DBI_ARCHIVE); fi
	cd $(DBI) ; \
	if test ! -e Makefile; then perl -I.. -MConfig_ub Makefile.PL ; fi ;\
	make

	if test ! -d $(SQLITE); then tar xzf $(SQLITE_ARCHIVE); fi
	cd $(SQLITE) ; \
	if test ! -e Makefile; then perl -I.. -MConfig_ub Makefile.PL USE_LOCAL_SQLITE=1 ; fi ;\
	make

	if test ! -d $(SQLITE2); then tar xzf $(SQLITE2_ARCHIVE); fi
	cd $(SQLITE2) ; \
	if test ! -e Makefile; then perl -I.. -MConfig_ub Makefile.PL ; fi ;\
	make

	if test ! -d $(TAGSET); then tar xzf $(TAGSET_ARCHIVE); fi
	cd $(TAGSET) ; \
	if test ! -e Makefile; then perl -I.. -MConfig_ub Makefile.PL ; fi ;\
	make

	if test ! -d $(TEMPLATE); then tar xzf $(TEMPLATE_ARCHIVE); fi
	cd $(TEMPLATE) ; \
	if test ! -e Makefile; then perl -I.. -MConfig_ub Makefile.PL ; fi ;\
	make

	if test ! -d $(TIMEDATE); then tar xzf $(TIMEDATE_ARCHIVE); fi
	cd $(TIMEDATE) ; \
	if test ! -e Makefile; then perl -I.. -MConfig_ub Makefile.PL ; fi ;\
	make

xmlrpc_modules_build: $(XMLRPC_ARCHIVES)
	if test ! -d $(VERSION_MODULE); then tar xzf $(VERSION_ARCHIVE); fi
	cd $(VERSION_MODULE) ; \
	if test ! -e Makefile; then perl -I.. -MConfig_ub Makefile.PL --perl_only ; fi ;\
	make

	if test ! -d $(SOAPLITE); then tar xzf $(SOAPLITE_ARCHIVE); fi
	cd $(SOAPLITE) ; \
	if test ! -e Makefile; then perl -I.. -MConfig_ub Makefile.PL ; fi ;\
	make

japanese_modules_build: $(JAPANESESUPPORT_ARCHIVES)
	if test ! -d $(KAKASI); then tar xzf $(KAKASI_ARCHIVE); fi
	cd $(KAKASI); \
	if test ! -e Makefile; \
	then \
	  env CPPFLAGS="-Os -g -isysroot /Developer/SDKs/MacOSX10.4u.sdk -arch i386 -arch ppc750" \
	  env LDFLAGS="-Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk -arch i386 -arch ppc750 -mmacosx-version-min=10.3" \
	  ./configure --disable-dependency-tracking --disable-shared ; \
	fi ;\
	make

	if test ! -d $(TEXTKAKASI); then tar xzf $(TEXTKAKASI_ARCHIVE); fi
	cd $(TEXTKAKASI); \
	if test ! -e Makefile; then perl -I.. -MConfig_kakasi Makefile.PL ; fi ;\
	make

ssl_modules_build: $(SSL_ARCHIVES)
	if test ! -d $(NETSSLEAY); then tar xzf $(NETSSLEAY_ARCHIVE); fi
	cd $(NETSSLEAY); \
	if test ! -e Makefile; then perl -I.. -MConfig_ub Makefile.PL ; fi ;\
	make

	if test ! -d $(IOSOCKETSSL); then tar xzf $(IOSOCKETSSL_ARCHIVE); fi
	cd $(IOSOCKETSSL); \
	if test ! -e Makefile; then perl -I../$(NETSSLEAY)/blib/lib Makefile.PL ; fi ;\
	make

$(DBI_ARCHIVE):
	@if test ! -e $(DBI_ARCHIVE); \
	then \
	  curl --output $(DBI_ARCHIVE) --location --silent $(DBI_URL); \
	fi
$(SQLITE_ARCHIVE):
	@if test ! -e $(SQLITE_ARCHIVE); \
	then \
	  curl --output $(SQLITE_ARCHIVE) --location --silent $(SQLITE_URL); \
	fi
$(SQLITE2_ARCHIVE):
	@if test ! -e $(SQLITE2_ARCHIVE); \
	then \
	  curl --output $(SQLITE2_ARCHIVE) --location --silent $(SQLITE2_URL); \
	fi
$(TAGSET_ARCHIVE):
	@if test ! -e $(TAGSET_ARCHIVE); \
	then \
	  curl --output $(TAGSET_ARCHIVE) --location --silent $(TAGSET_URL); \
	fi
$(TEMPLATE_ARCHIVE):
	@if test ! -e $(TEMPLATE_ARCHIVE); \
	then \
	  curl --output $(TEMPLATE_ARCHIVE) --location --silent $(TEMPLATE_URL); \
	fi
$(TIMEDATE_ARCHIVE):
	@if test ! -e $(TIMEDATE_ARCHIVE); \
	then \
	  curl --output $(TIMEDATE_ARCHIVE) --location --silent $(TIMEDATE_URL); \
	fi
$(SOAPLITE_ARCHIVE):
	@if test ! -e $(SOAPLITE_ARCHIVE); \
	then \
	  curl --output $(SOAPLITE_ARCHIVE) --location --silent $(SOAPLITE_URL); \
	fi
$(VERSION_ARCHIVE):
	@if test ! -e $(VERSION_ARCHIVE); \
	then \
	  curl --output $(VERSION_ARCHIVE) --location --silent $(VERSION_URL); \
	fi
$(KAKASI_ARCHIVE):
	@if test ! -e $(KAKASI_ARCHIVE); \
	then \
	  curl --output $(KAKASI_ARCHIVE) --location --silent $(KAKASI_URL); \
	fi
$(TEXTKAKASI_ARCHIVE):
	@if test ! -e $(TEXTKAKASI_ARCHIVE); \
	then \
	  curl --output $(TEXTKAKASI_ARCHIVE) --location --silent $(TEXTKAKASI_URL); \
	fi
$(NETSSLEAY_ARCHIVE):
	@if test ! -e $(NETSSLEAY_ARCHIVE); \
	then \
	  curl --output $(NETSSLEAY_ARCHIVE) --location --silent $(NETSSLEAY_URL); \
	fi
$(IOSOCKETSSL_ARCHIVE):
	@if test ! -e $(IOSOCKETSSL_ARCHIVE); \
	then \
	  curl --output $(IOSOCKETSSL_ARCHIVE) --location --silent $(IOSOCKETSSL_URL); \
	fi

fakeconfig:
	@echo Checking ExtUtils::FakeConfig version...
	@perl -MExtUtils::FakeConfig -e 'print $$ExtUtils::FakeConfig::VERSION,"\n";'

kakasi_dictionary: $(KAKASI)/kanwadict $(KAKASI)/itaijidict
	cd $(KAKASI) ; \
	head -c 73728 <kanwadict >kanwadict-head ; \
	tail -c +73729 <kanwadict >kanwadict-body ; \
	perl -e 'binmode STDIN; binmode STDOUT; $$a = qw(); while (<>) {$$a.=$$_}; $$a =~ s/(.)(.)(.)(.)/$$4$$3$$2$$1/sg; print $$a;' <kanwadict-head >kanwadict-head-swap ; \
	CPU_TYPE=`/usr/bin/uname -p` ; \
	CPU_TYPE='powerpc' ; \
	case $$CPU_TYPE in \
	powerpc ) \
	  mv kanwadict-head-swap kanwadict-head_i386 ; \
	  mv kanwadict-head kanwadict-head_ppc ; \
	  ;; \
	i386 ) \
	  mv kanwadict-head kanwadict-head_i386 ; \
	  mv kanwadict-head-swap kanwadict-head_ppc; \
	  ;; \
	esac

	if test ! -d $(KAKASI_DIC_ROOT); then mkdir $(KAKASI_DIC_ROOT); fi
	cp -f $(KAKASI)/kanwadict-body $(KAKASI_DIC_ROOT)
	cp -f $(KAKASI)/kanwadict-head_i386 $(KAKASI_DIC_ROOT)
	cp -f $(KAKASI)/kanwadict-head_ppc $(KAKASI_DIC_ROOT)
	cp -f $(KAKASI)/itaijidict $(KAKASI_DIC_ROOT)

