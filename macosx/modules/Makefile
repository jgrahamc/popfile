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

PACKAGE_ROOT=../Package_Root
POPFILE_ROOT=$(PACKAGE_ROOT)/Library/POPFile
LIB_ROOT = $(POPFILE_ROOT)/lib

KAKASI_DIC_ROOT = $(POPFILE_ROOT)/kakasi

SSLPACKAGE_ROOT = ../addssl/Package_Root
SSLPACKAGE_LIBRARY_ROOT = $(SSLPACKAGE_ROOT)/Library
SSLPOPFILE_ROOT = $(SSLPACKAGE_LIBRARY_ROOT)/POPFile

FAKECONFIG = ExtUtils-FakeConfig-0.12
FAKECONFIG_ARCHIVE = $(FAKECONFIG).zip
FAKECONFIG_URL = http://search.cpan.org/CPAN/authors/id/M/MB/MBARBON/$(FAKECONFIG_ARCHIVE)

DBI = DBI-1.616
DBI_ARCHIVE = $(DBI).tar.gz
DBI_URL = http://search.cpan.org/CPAN/authors/id/T/TI/TIMB/$(DBI_ARCHIVE)

SQLITE = DBD-SQLite-1.33
SQLITE_ARCHIVE = $(SQLITE).tar.gz
SQLITE_URL = http://search.cpan.org/CPAN/authors/id/A/AD/ADAMK/$(SQLITE_ARCHIVE)

SQLITE2 = DBD-SQLite2-0.33
SQLITE2_ARCHIVE = $(SQLITE2).tar.gz
SQLITE2_URL = http://search.cpan.org/CPAN/authors/id/M/MS/MSERGEANT/$(SQLITE2_ARCHIVE)

TAGSET = HTML-Tagset-3.20
TAGSET_ARCHIVE = $(TAGSET).tar.gz
TAGSET_URL = http://search.cpan.org/CPAN/authors/id/P/PE/PETDANCE/$(TAGSET_ARCHIVE)

TEMPLATE = HTML-Template-2.10
TEMPLATE_ARCHIVE = $(TEMPLATE).tar.gz
TEMPLATE_URL = http://search.cpan.org/CPAN/authors/id/W/WO/WONKO/$(TEMPLATE_ARCHIVE)

TIMEDATE = TimeDate-1.20
TIMEDATE_ARCHIVE = $(TIMEDATE).tar.gz
TIMEDATE_URL = http://search.cpan.org/CPAN/authors/id/G/GB/GBARR/$(TIMEDATE_ARCHIVE)

# v2.0

DIGESTSHA = Digest-SHA-5.70
DIGESTSHA_ARCHIVE = $(DIGESTSHA).tar.gz
DIGESTSHA_URL = http://search.cpan.org/CPAN/authors/id/M/MS/MSHELOR/$(DIGESTSHA_ARCHIVE)

CRYPT_CBC = Crypt-CBC-2.30
CRYPT_CBC_ARCHIVE = $(CRYPT_CBC).tar.gz
CRYPT_CBC_URL = http://search.cpan.org/CPAN/authors/id/L/LD/LDS/$(CRYPT_CBC_ARCHIVE)

CRYPT_BLOWFISH = Crypt-Blowfish-2.12
CRYPT_BLOWFISH_ARCHIVE = $(CRYPT_BLOWFISH).tar.gz
CRYPT_BLOWFISH_URL = http://search.cpan.org/CPAN/authors/id/D/DP/DPARIS/$(CRYPT_BLOWFISH_ARCHIVE)

CRYPT_OPENSSL_RANDOM = Crypt-OpenSSL-Random-0.04
CRYPT_OPENSSL_RANDOM_ARCHIVE = $(CRYPT_OPENSSL_RANDOM).tar.gz
CRYPT_OPENSSL_RANDOM_URL = http://search.cpan.org/CPAN/authors/id/I/IR/IROBERTS/$(CRYPT_OPENSSL_RANDOM_ARCHIVE)

# XMLRCP Support

SOAPLITE = SOAP-Lite-0.714
SOAPLITE_ARCHIVE = $(SOAPLITE).tar.gz
SOAPLITE_URL = http://search.cpan.org/CPAN/authors/id/M/MK/MKUTTER/$(SOAPLITE_ARCHIVE)

CLASS_INSPECTOR = Class-Inspector-1.25
CLASS_INSPECTOR_ARCHIVE = $(CLASS_INSPECTOR).tar.gz
CLASS_INSPECTOR_URL = http://search.cpan.org/CPAN/authors/id/A/AD/ADAMK/$(CLASS_INSPECTOR_ARCHIVE)

VERSION_MODULE = version-0.95
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

NETSSLEAY = Net-SSLeay-1.42
NETSSLEAY_ARCHIVE = $(NETSSLEAY).tar.gz
NETSSLEAY_URL = http://search.cpan.org/CPAN/authors/id/M/MI/MIKEM/$(NETSSLEAY_ARCHIVE)

IOSOCKETSSL = IO-Socket-SSL-1.53
IOSOCKETSSL_ARCHIVE = $(IOSOCKETSSL).tar.gz
IOSOCKETSSL_URL = http://search.cpan.org/CPAN/authors/id/S/SU/SULLR/$(IOSOCKETSSL_ARCHIVE)

# Socks support

SOCKS = IO-Socket-Socks-0.60
SOCKS_ARCHIVE = $(SOCKS).tar.gz
SOCKS_URL = http://search.cpan.org/CPAN/authors/id/O/OL/OLEG/$(SOCKS_ARCHIVE)


CORE_ARCHIVES = $(DBI_ARCHIVE) $(SQLITE_ARCHIVE) $(SQLITE2_ARCHIVE) $(TAGSET_ARCHIVE) $(TEMPLATE_ARCHIVE) $(TIMEDATE_ARCHIVE) $(DIGESTSHA_ARCHIVE) $(CRYPT_BLOWFISH_ARCHIVE) $(CRYPT_OPENSSL_RANDOM_ARCHIVE) $(CRYPT_CBC_ARCHIVE)
CORE_MODULES = $(DBI) $(SQLITE) $(SQLITE2) $(TAGSET) $(TEMPLATE) $(TIMEDATE) $(DIGESTSHA) $(CRYPT_BLOWFISH) $(CRYPT_OPENSSL_RANDOM) $(CRYPT_CBC)

JAPANESESUPPORT_ARCHIVES = $(KAKASI_ARCHIVE) $(TEXTKAKASI_ARCHIVE)
JAPANESESUPPORT_MODULES = $(KAKASI) $(TEXTKAKASI)

XMLRPC_ARCHIVES = $(SOAPLITE_ARCHIVE) $(VERSION_ARCHIVE) $(CLASS_INSPECTOR_ARCHIVE)
XMLRPC_MODULES = $(SOAPLITE) $(VERSION_MODULE) $(CLASS_INSPECTOR_MODULE)

SSL_ARCHIVES = $(NETSSLEAY_ARCHIVE) $(IOSOCKETSSL_ARCHIVE)
SSL_MODULES = $(NETSSLEAY) $(IOSOCKETSSL)

SOCKS_ARCHIVES = $(SOCKS_ARCHIVE)
SOCKS_MODULES = $(SOCKS)

all: build
build: core_modules japanese_modules xmlrpc_modules ssl_modules socks_modules kakasi_dictionary

all-clean: clean
	rm -rf $(CORE_ARCHIVES) $(JAPANESESUPPORT_ARCHIVES) $(XMLRPC_ARCHIVES) $(SSL_ARCHIVES) $(SOCKS_ARCHIVES)

clean:
	rm -rf $(CORE_MODULES) $(JAPANESESUPPORT_MODULES) $(XMLRPC_MODULES) $(SSL_MODULES) $(SOCKS_MODULES)
	rm -rf $(LIB_ROOT)/*
	rm -rf $(KAKASI_DIC_ROOT)/*

core_modules:core_modules_build $(CORE_MODULES)
	if test ! -d $(POPFILE_ROOT); then mkdir $(POPFILE_ROOT) ; fi
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

	cp -rf $(DIGESTSHA)/blib/arch/auto $(LIB_ROOT)
	cp -rf $(DIGESTSHA)/blib/lib/* $(LIB_ROOT)

	cp -rf $(CRYPT_CBC)/blib/arch/auto $(LIB_ROOT)
	cp -rf $(CRYPT_CBC)/blib/lib/* $(LIB_ROOT)

	cp -rf $(CRYPT_BLOWFISH)/blib/arch/auto $(LIB_ROOT)
	cp -rf $(CRYPT_BLOWFISH)/blib/lib/* $(LIB_ROOT)

	cp -rf $(CRYPT_OPENSSL_RANDOM)/blib/arch/auto $(LIB_ROOT)
	cp -rf $(CRYPT_OPENSSL_RANDOM)/blib/lib/* $(LIB_ROOT)

xmlrpc_modules: xmlrpc_modules_build
	if test ! -d $(POPFILE_ROOT); then mkdir $(POPFILE_ROOT) ; fi
	if test ! -d $(LIB_ROOT); then mkdir $(LIB_ROOT) ; fi

	cp -rf $(CLASS_INSPECTOR)/lib/* $(LIB_ROOT)

	cp -rf $(SOAPLITE)/lib/* $(LIB_ROOT)

	cp -rf $(VERSION_MODULE)/blib/arch/auto $(LIB_ROOT)
	cp -rf $(VERSION_MODULE)/blib/lib/* $(LIB_ROOT)

japanese_modules: japanese_modules_build
	if test ! -d $(LIB_ROOT); then mkdir $(LIB_ROOT) ; fi

	cp -rf $(TEXTKAKASI)/blib/arch/auto $(LIB_ROOT)
	cp -rf $(TEXTKAKASI)/blib/lib/* $(LIB_ROOT)

ssl_modules: ssl_modules_build
	cp -rf $(NETSSLEAY)/blib/arch/auto $(LIB_ROOT)
	cp -rf $(NETSSLEAY)/blib/lib/* $(LIB_ROOT)

	cp -rf $(IOSOCKETSSL)/blib/arch/auto $(LIB_ROOT)
	cp -rf $(IOSOCKETSSL)/blib/lib/* $(LIB_ROOT)

socks_modules: socks_modules_build
	cp -rf $(SOCKS)/blib/arch/auto $(LIB_ROOT)
	cp -rf $(SOCKS)/blib/lib/* $(LIB_ROOT)


core_modules_build: $(CORE_ARCHIVES)
core_modules_build: fakeconfig
	if test ! -d $(DBI); then tar xzf $(DBI_ARCHIVE); patch $(DBI)/DBIXS.h < ./DBIXS.h.patch; fi
	cd $(DBI) ; \
	if test ! -e Makefile; then /usr/bin/perl -I.. -MConfig_ub Makefile.PL ; fi ;\
	make

	if test ! -d $(SQLITE); then tar xzf $(SQLITE_ARCHIVE); fi
	cd $(SQLITE) ; \
	if test ! -e Makefile; then /usr/bin/perl -I.. -I../$(DBI) -I../$(DBI)/lib -I../$(DBI)/blib/arch -MConfig_ub Makefile.PL USE_LOCAL_SQLITE=1 ; fi ;\
	make

	if test ! -d $(SQLITE2); then tar xzf $(SQLITE2_ARCHIVE); fi
	cd $(SQLITE2) ; \
	if test ! -e Makefile; then /usr/bin/perl -I.. -I../$(DBI) -I../$(DBI)/lib -I../$(DBI)/blib/arch -MConfig_ub Makefile.PL ; fi ;\
	make

	if test ! -d $(TAGSET); then tar xzf $(TAGSET_ARCHIVE); fi
	cd $(TAGSET) ; \
	if test ! -e Makefile; then /usr/bin/perl -I.. -MConfig_ub Makefile.PL ; fi ;\
	make

	if test ! -d $(TEMPLATE); then tar xzf $(TEMPLATE_ARCHIVE); fi
	cd $(TEMPLATE) ; \
	if test ! -e Makefile; then /usr/bin/perl -I.. -MConfig_ub Makefile.PL ; fi ;\
	make

	if test ! -d $(TIMEDATE); then tar xzf $(TIMEDATE_ARCHIVE); fi
	cd $(TIMEDATE) ; \
	if test ! -e Makefile; then /usr/bin/perl -I.. -MConfig_ub Makefile.PL ; fi ;\
	make

	if test ! -d $(DIGESTSHA); then tar xzf $(DIGESTSHA_ARCHIVE); fi
	cd $(DIGESTSHA) ; \
	if test ! -e Makefile; then /usr/bin/perl -I.. -MConfig_ub Makefile.PL ; fi ;\
	make

	if test ! -d $(CRYPT_CBC); then tar xzf $(CRYPT_CBC_ARCHIVE); fi
	cd $(CRYPT_CBC) ; \
	if test ! -e Makefile; then /usr/bin/perl -I.. -MConfig_ub Makefile.PL ; fi ;\
	make

	if test ! -d $(CRYPT_BLOWFISH); then tar xzf $(CRYPT_BLOWFISH_ARCHIVE); fi
	cd $(CRYPT_BLOWFISH) ; \
	if test ! -e Makefile; then /usr/bin/perl -I.. -MConfig_ub Makefile.PL ; fi ;\
	make

	if test ! -d $(CRYPT_OPENSSL_RANDOM); then tar xzf $(CRYPT_OPENSSL_RANDOM_ARCHIVE); fi
	cd $(CRYPT_OPENSSL_RANDOM) ; \
	if test ! -e Makefile; then /usr/bin/perl -I.. -MConfig_ub Makefile.PL ; fi ;\
	make

xmlrpc_modules_build: $(XMLRPC_ARCHIVES)
	if test ! -d $(VERSION_MODULE); then tar xzf $(VERSION_ARCHIVE); fi
	cd $(VERSION_MODULE) ; \
	if test ! -e Makefile; then /usr/bin/perl -I.. -MConfig_ub Makefile.PL --perl_only ; fi ;\
	make

	if test ! -d $(CLASS_INSPECTOR); then tar xzf $(CLASS_INSPECTOR_ARCHIVE); fi
	cd $(CLASS_INSPECTOR) ; \
	if test ! -e Makefile; then /usr/bin/perl -I.. -MConfig_ub Makefile.PL ; fi ;\
	make

	if test ! -d $(SOAPLITE); then tar xzf $(SOAPLITE_ARCHIVE); fi
	cd $(SOAPLITE) ; \
	if test ! -e Makefile; then /usr/bin/perl -I.. -I../$(CLASS_INSPECTOR)/blib/lib -MConfig_ub Makefile.PL -noprompt; fi ;\
	make

japanese_modules_build: $(JAPANESESUPPORT_ARCHIVES)
	if test ! -d $(KAKASI); then tar xzf $(KAKASI_ARCHIVE); fi
	cd $(KAKASI); \
	if test ! -e Makefile; \
	then \
	  PERL510=`/usr/bin/perl -e 'print $$] ge qw{5.010000};'`; \
	  PERL512=`/usr/bin/perl -e 'print $$] ge qw{5.012000};'`; \
	  if test "$$PERL512" == "1"; \
	  then \
		env CPPFLAGS="-Os -g -isysroot /Developer/SDKs/MacOSX10.7.sdk -arch i386 -arch x86_64" \
		env LDFLAGS="-Wl,-syslibroot,/Developer/SDKs/MacOSX10.7.sdk -arch i386 -arch x86_64 -mmacosx-version-min=10.7" \
		./configure --disable-dependency-tracking --disable-shared ; \
	  else \
		if test "$$PERL510" == "1"; \
		then \
		  env CPPFLAGS="-Os -g -isysroot /Developer/SDKs/MacOSX10.6.sdk -arch i386 -arch ppc7400 -arch x86_64" \
		  env LDFLAGS="-Wl,-syslibroot,/Developer/SDKs/MacOSX10.6.sdk -arch i386 -arch ppc7400 -arch x86_64 -mmacosx-version-min=10.6" \
		  ./configure --disable-dependency-tracking --disable-shared ; \
		else \
		  env CPPFLAGS="-Os -g -isysroot /Developer/SDKs/MacOSX10.4u.sdk -arch i386 -arch ppc750 -arch ppc7400 -arch ppc64" \
		  env LDFLAGS="-Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk -arch i386 -arch ppc750 -arch ppc7400 -arch ppc64 -mmacosx-version-min=10.3" \
		  ./configure --disable-dependency-tracking --disable-shared ; \
		fi ; \
	  fi ; \
	fi ; \
	make

	if test ! -d $(TEXTKAKASI); then tar xzf $(TEXTKAKASI_ARCHIVE); fi
	cd $(TEXTKAKASI); \
	if test ! -e Makefile; then /usr/bin/perl -I.. -MConfig_kakasi Makefile.PL ; fi ;\
	make

ssl_modules_build: $(SSL_ARCHIVES)
	if test ! -d $(NETSSLEAY); then tar xzf $(NETSSLEAY_ARCHIVE); fi
	cd $(NETSSLEAY); \
	if test ! -e Makefile; then /usr/bin/perl -I.. -MConfig_ub Makefile.PL ; fi ;\
	make

	if test ! -d $(IOSOCKETSSL); then tar xzf $(IOSOCKETSSL_ARCHIVE); fi
	cd $(IOSOCKETSSL); \
	if test ! -e Makefile; then /usr/bin/perl -I.. -I../$(NETSSLEAY)/blib/lib -MConfig_ub Makefile.PL ; fi ;\
	make

socks_modules_build: $(SOCKS_ARCHIVES)
	if test ! -d $(SOCKS); then tar xzf $(SOCKS_ARCHIVE); fi
	cd $(SOCKS); \
	if test ! -e Makefile; then /usr/bin/perl -I.. -MConfig_ub Makefile.PL ; fi ;\
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
$(DIGESTSHA_ARCHIVE):
	@if test ! -e $(DIGESTSHA_ARCHIVE); \
	then \
	  curl --output $(DIGESTSHA_ARCHIVE) --location --silent $(DIGESTSHA_URL); \
	fi
$(CRYPT_CBC_ARCHIVE):
	@if test ! -e $(CRYPT_CBC_ARCHIVE); \
	then \
	  curl --output $(CRYPT_CBC_ARCHIVE) --location --silent $(CRYPT_CBC_URL); \
	fi
$(CRYPT_BLOWFISH_ARCHIVE):
	@if test ! -e $(CRYPT_BLOWFISH_ARCHIVE); \
	then \
	  curl --output $(CRYPT_BLOWFISH_ARCHIVE) --location --silent $(CRYPT_BLOWFISH_URL); \
	fi
$(CRYPT_OPENSSL_RANDOM_ARCHIVE):
	@if test ! -e $(CRYPT_OPENSSL_RANDOM_ARCHIVE); \
	then \
	  curl --output $(CRYPT_OPENSSL_RANDOM_ARCHIVE) --location --silent $(CRYPT_OPENSSL_RANDOM_URL); \
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
$(CLASS_INSPECTOR_ARCHIVE):
	@if test ! -e $(CLASS_INSPECTOR_ARCHIVE); \
	then \
	  curl --output $(CLASS_INSPECTOR_ARCHIVE) --location --silent $(CLASS_INSPECTOR_URL); \
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
$(SOCKS_ARCHIVE):
	@if test ! -e $(SOCKS_ARCHIVE); \
	then \
	  curl --output $(SOCKS_ARCHIVE) --location --silent $(SOCKS_URL); \
	fi

fakeconfig:
	@echo Checking ExtUtils::FakeConfig version...
	@/usr/bin/perl -MExtUtils::FakeConfig -e 'print $$ExtUtils::FakeConfig::VERSION,"\n";'

kakasi_dictionary: $(KAKASI)/kanwadict $(KAKASI)/itaijidict
	cd $(KAKASI) ; \
	head -c 73728 <kanwadict >kanwadict-head ; \
	tail -c +73729 <kanwadict >kanwadict-body ; \
	/usr/bin/perl -e 'binmode STDIN; binmode STDOUT; $$a = qw(); while (<>) {$$a.=$$_}; $$a =~ s/(.)(.)(.)(.)/$$4$$3$$2$$1/sg; print $$a;' <kanwadict-head >kanwadict-head-swap ; \
	CPU_TYPE=`/usr/bin/uname -p` ; \
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

