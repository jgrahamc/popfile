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

# ------------------------------
#   data definition
# ------------------------------


%define name popfile
%define version 1.1.1
%define release RC1
# %%define prefix /usr/local^

Summary: POPFile - Automatic Email Classification

Name: %{name}
Version: %{version}
Release: %{release}

Source0: http://getpopfile.org/downloads/%{name}-%{version}-%{release}.zip
Source1: popfile
# Patch0: popfile-1.1.1.patch
License: GPL
Group: Applications/Internet
URL: http://getpopfile.org/

Requires: perl
#Requires: perl-Digest-MD5 perl-MIME-Base64 perl-MIME-QuotedPrint
Requires: perl-DBI perl-DBD-SQLite
#Requires: perl-DBD-SQLite2
Requires: perl-TimeDate perl-HTML-Template perl-HTML-Tagset
Requires: perl-IO-Socket-SSL perl-Net-SSLeay
Requires: perl-SOAP-Lite
Requires: kakasi kakasi-dict perl-Text-Kakasi

# BuildRequires:
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-root
BuildArch: noarch

Packager: naoki iimura <naoki@getpopfile.org>
Vendor: naoki iimura <naoki@getpopfile.org>
Distribution: Fedora 10

%description
POPFile is an automatic mail classification tool. Once properly set up
and trained, it will scan all email as it arrives and classify it
based on your training. You can give it a simple job, like separating
out junk e-mail, or a complicated one-like filing mail into a dozen
folders. Think of it as a personal assistant for your inbox.

# ------------------------------
#   scripts
# ------------------------------

%prep

%{__unzip} -qoa %{_sourcedir}/%name-%version-%release.zip
cp %{_sourcedir}/popfile .


%build


%install

rm -rf $RPM_BUILD_ROOT

# popfile program

install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name

install -m644 license $RPM_BUILD_ROOT%{_datadir}/%name
install -m644 stopwords $RPM_BUILD_ROOT%{_datadir}/%name
install -m644 popfile.pck $RPM_BUILD_ROOT%{_datadir}/%name
install -m644 v%version.change $RPM_BUILD_ROOT%{_datadir}/%name
install -m644 v%version.change.nihongo $RPM_BUILD_ROOT%{_datadir}/%name

install -m755 *.pl $RPM_BUILD_ROOT%{_datadir}/%name
install -m644 *.gif $RPM_BUILD_ROOT%{_datadir}/%name
install -m644 *.png $RPM_BUILD_ROOT%{_datadir}/%name
install -m644 *.ico $RPM_BUILD_ROOT%{_datadir}/%name

install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/Classifier
install -m644 Classifier/* $RPM_BUILD_ROOT%{_datadir}/%name/Classifier

install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/POPFile
install -m644 POPFile/* $RPM_BUILD_ROOT%{_datadir}/%name/POPFile

install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/Proxy
install -m644 Proxy/* $RPM_BUILD_ROOT%{_datadir}/%name/Proxy

install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/UI
install -m644 UI/* $RPM_BUILD_ROOT%{_datadir}/%name/UI

install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/Services
install -m644 Services/*.pm $RPM_BUILD_ROOT%{_datadir}/%name/Services

install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/Services/IMAP
install -m644 Services/IMAP/* $RPM_BUILD_ROOT%{_datadir}/%name/Services/IMAP

install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/languages
install -m644 languages/* $RPM_BUILD_ROOT%{_datadir}/%name/languages

install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins
install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/blue
install -m644 skins/blue/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/blue
install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/coolblue
install -m644 skins/coolblue/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/coolblue
install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/coolbrown
install -m644 skins/coolbrown/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/coolbrown
install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/coolmint
install -m644 skins/coolmint/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/coolmint
install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/coolorange
install -m644 skins/coolorange/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/coolorange
install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/coolyellow
install -m644 skins/coolyellow/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/coolyellow
install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/default
install -m644 skins/default/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/default
install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/glassblue
install -m644 skins/glassblue/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/glassblue
install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/green
install -m644 skins/green/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/green
install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/lavish
install -m644 skins/lavish/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/lavish
install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/ocean
install -m644 skins/ocean/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/ocean
install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/oceanblue
install -m644 skins/oceanblue/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/oceanblue
install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/orange
install -m644 skins/orange/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/orange
install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/orangecream
install -m644 skins/orangecream/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/orangecream
install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/osx
install -m644 skins/osx/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/osx
install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/outlook
install -m644 skins/outlook/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/outlook
install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/simplyblue
install -m644 skins/simplyblue/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/simplyblue
install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/sleet
install -m644 skins/sleet/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/sleet
install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/sleet-rtl
install -m644 skins/sleet-rtl/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/sleet-rtl
install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/smalldefault
install -m644 skins/smalldefault/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/smalldefault
install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/smallgrey
install -m644 skins/smallgrey/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/smallgrey
install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/strawberryrose
install -m644 skins/strawberryrose/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/strawberryrose
install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/tinygrey
install -m644 skins/tinygrey/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/tinygrey
install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/white
install -m644 skins/white/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/white
install -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/windows
install -m644 skins/windows/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/windows

# popfile data files

install -m 755 -d $RPM_BUILD_ROOT%{_localstatedir}/lib/%name
install -m 644 stopwords $RPM_BUILD_ROOT%{_localstatedir}/lib/%name

# popfile log files

install -m 755 -d $RPM_BUILD_ROOT%{_localstatedir}/log/%name

# start up script

install -m 755 -d $RPM_BUILD_ROOT%{_initrddir}
install -m 755 popfile $RPM_BUILD_ROOT%{_initrddir}/popfile


%clean

rm -rf $RPM_BUILD_ROOT


# pre install script

%pre

if [ -e %{_initrddir}/popfile ]; then
    %{_initrddir}/popfile stop
fi
exit 0

# post install script

%post

/sbin/chkconfig --add popfile
/sbin/chkconfig popfile on
%{_initrddir}/popfile start
exit 0

# pre uninstall script

%preun

if [ "$1" = 0 ]; then
    %{_initrddir}/popfile stop
    /sbin/chkconfig popfile off
    /sbin/chkconfig --del popfile
fi
exit 0

# post uninstall script

%postun

exit 0;


# ------------------------------
#   file list
# ------------------------------

%files
%defattr(-,root,root)

# popfile program

%dir %{_datadir}/%name
%{_datadir}/%name/bayes.pl
%{_datadir}/%name/black.gif
%{_datadir}/%name/favicon.ico
%{_datadir}/%name/insert.pl
%doc %{_datadir}/%name/license
%{_datadir}/%name/otto.gif
%{_datadir}/%name/otto.png
%{_datadir}/%name/pipe.pl
%{_datadir}/%name/pix.gif
%{_datadir}/%name/popfile.pck
%{_datadir}/%name/popfile.pl
%{_datadir}/%name/stopwords
%doc %{_datadir}/%name/v1.1.1.change
%doc %{_datadir}/%name/v1.1.1.change.nihongo

%dir %{_datadir}/%name/Classifier
%{_datadir}/%name/Classifier/*

%dir %{_datadir}/%name/POPFile
%{_datadir}/%name/POPFile/*

%dir %{_datadir}/popfile/Proxy
%{_datadir}/%name/Proxy/*

%dir %{_datadir}/%name/UI
%{_datadir}/%name/UI/*

%dir %{_datadir}/%name/Services
%{_datadir}/%name/Services/*

%dir %{_datadir}/%name/languages
%{_datadir}/%name/languages/*

%dir %{_datadir}/%name/skins
%{_datadir}/%name/skins/*

# popfile data files

%dir %{_localstatedir}/lib/%name
#%config(missingok) %{_localstatedir}/lib/%name/popfile.cfg
#%config %{_localstatedir}/lib/%name/popfile.db
%config %{_localstatedir}/lib/%name/stopwords

# popfile log files

%dir %{_localstatedir}/log/%name

# start up script

%{_initrddir}/popfile


# ------------------------------
#   change log
# ------------------------------

%changelog
* Sat Jun 20 2009 naoki iimura <naoki@getpopfile.org>
-  release 1 for version 1.1.1-rc1

# end of file
