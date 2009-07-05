# ---------------------------------------------------------------------------
#
# Copyright (c) 2001-2009 John Graham-Cumming
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

Summary: Automatic Email Classification

Name: popfile
Version: 1.1.1
Release: 0.3.rc3

Group: Applications/Internet

Vendor: POPFile Core Team
URL: http://getpopfile.org/
License: GPLv2

Exclusiveos: linux

# BuildRequires:
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-root
BuildArch: noarch

Source0: http://getpopfile.org/downloads/%{name}-%{version}-RC3.zip
Source1: popfile
Source2: start_popfile.sh
# Patch0: no patch

Requires: perl >= 5.8.1
#Requires: perl-Digest-MD5 perl-MIME-Base64 perl-MIME-QuotedPrint
Requires: perl-DBI perl-DBD-SQLite
#Requires: perl-DBD-SQLite2
Requires: perl-TimeDate perl-HTML-Template perl-HTML-Tagset
Requires: perl-IO-Socket-SSL
Requires: perl-SOAP-Lite
Requires: kakasi kakasi-dict perl-Text-Kakasi

%description
POPFile is an automatic mail classification tool. Once properly set up
and trained, it will scan all email as it arrives and classify it
based on your training. You can give it a simple job, like separating
out junk e-mail, or a complicated one-like filing mail into a dozen
folders. Think of it as a personal assistant for your inbox.


%prep

%setup -c %name-%version -T
%{__unzip} -qoa %{SOURCE0}
%{__cp} %{SOURCE1} .
%{__cp} %{SOURCE2} .


%build


%install

%{__rm} -rf $RPM_BUILD_ROOT

# popfile program

%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name

%{__install} -m644 license $RPM_BUILD_ROOT%{_datadir}/%name
%{__install} -m644 stopwords $RPM_BUILD_ROOT%{_datadir}/%name
%{__install} -m644 popfile.pck $RPM_BUILD_ROOT%{_datadir}/%name
%{__install} -m644 v%version.change $RPM_BUILD_ROOT%{_datadir}/%name
%{__install} -m644 v%version.change.nihongo $RPM_BUILD_ROOT%{_datadir}/%name

%{__install} -m755 *.pl $RPM_BUILD_ROOT%{_datadir}/%name
%{__install} -m644 *.gif $RPM_BUILD_ROOT%{_datadir}/%name
%{__install} -m644 *.png $RPM_BUILD_ROOT%{_datadir}/%name
%{__install} -m644 *.ico $RPM_BUILD_ROOT%{_datadir}/%name

%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/Classifier
%{__install} -m644 Classifier/* $RPM_BUILD_ROOT%{_datadir}/%name/Classifier

%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/POPFile
%{__install} -m644 POPFile/* $RPM_BUILD_ROOT%{_datadir}/%name/POPFile

%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/Proxy
%{__install} -m644 Proxy/* $RPM_BUILD_ROOT%{_datadir}/%name/Proxy

%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/UI
%{__install} -m644 UI/* $RPM_BUILD_ROOT%{_datadir}/%name/UI

%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/Services
%{__install} -m644 Services/*.pm $RPM_BUILD_ROOT%{_datadir}/%name/Services

%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/Services/IMAP
%{__install} -m644 Services/IMAP/* $RPM_BUILD_ROOT%{_datadir}/%name/Services/IMAP

%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/languages
%{__install} -m644 languages/* $RPM_BUILD_ROOT%{_datadir}/%name/languages

%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins
%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/blue
%{__install} -m644 skins/blue/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/blue
%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/coolblue
%{__install} -m644 skins/coolblue/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/coolblue
%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/coolbrown
%{__install} -m644 skins/coolbrown/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/coolbrown
%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/coolmint
%{__install} -m644 skins/coolmint/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/coolmint
%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/coolorange
%{__install} -m644 skins/coolorange/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/coolorange
%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/coolyellow
%{__install} -m644 skins/coolyellow/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/coolyellow
%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/default
%{__install} -m644 skins/default/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/default
%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/glassblue
%{__install} -m644 skins/glassblue/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/glassblue
%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/green
%{__install} -m644 skins/green/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/green
%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/lavish
%{__install} -m644 skins/lavish/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/lavish
%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/ocean
%{__install} -m644 skins/ocean/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/ocean
%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/oceanblue
%{__install} -m644 skins/oceanblue/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/oceanblue
%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/orange
%{__install} -m644 skins/orange/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/orange
%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/orangecream
%{__install} -m644 skins/orangecream/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/orangecream
%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/osx
%{__install} -m644 skins/osx/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/osx
%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/outlook
%{__install} -m644 skins/outlook/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/outlook
%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/simplyblue
%{__install} -m644 skins/simplyblue/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/simplyblue
%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/sleet
%{__install} -m644 skins/sleet/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/sleet
%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/sleet-rtl
%{__install} -m644 skins/sleet-rtl/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/sleet-rtl
%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/smalldefault
%{__install} -m644 skins/smalldefault/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/smalldefault
%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/smallgrey
%{__install} -m644 skins/smallgrey/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/smallgrey
%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/strawberryrose
%{__install} -m644 skins/strawberryrose/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/strawberryrose
%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/tinygrey
%{__install} -m644 skins/tinygrey/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/tinygrey
%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/white
%{__install} -m644 skins/white/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/white
%{__install} -m755 -d $RPM_BUILD_ROOT%{_datadir}/%name/skins/windows
%{__install} -m644 skins/windows/* $RPM_BUILD_ROOT%{_datadir}/%name/skins/windows

# popfile data files

%{__install} -m 755 -d $RPM_BUILD_ROOT%{_localstatedir}/lib/%name
%{__install} -m 644 stopwords $RPM_BUILD_ROOT%{_localstatedir}/lib/%name

# popfile log files

%{__install} -m 755 -d $RPM_BUILD_ROOT%{_localstatedir}/log/%name

# start up script

%{__install} -m 755 -d $RPM_BUILD_ROOT%{_initrddir}
%{__install} -m 755 popfile $RPM_BUILD_ROOT%{_initrddir}/popfile

%{__install} -m 755 start_popfile.sh $RPM_BUILD_ROOT%{_datadir}/%name/


%clean

%{__rm} -rf $RPM_BUILD_ROOT


%pre

if [ "$1" -ge 2 ]; then
    /sbin/service popfile stop >/dev/null 2>&1
fi
exit 0


%post

/sbin/chkconfig --add popfile
#/sbin/chkconfig popfile on
#/sbin/service start >/dev/null 2>&1
exit 0


%preun

if [ "$1" = 0 ]; then
    %{_initrddir}/popfile stop >/dev/null 2>&1
    #/sbin/chkconfig popfile off
    /sbin/chkconfig --del popfile
fi
exit 0


%postun

exit 0


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
%doc %{_datadir}/%name/v%version.change
%doc %{_datadir}/%name/v%version.change.nihongo

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
#%config(missingok) %{_localstatedir}/lib/%name/popfile.db
%config(noreplace) %{_localstatedir}/lib/%name/stopwords

# popfile log files

%dir %{_localstatedir}/log/%name

# start up script

%{_initrddir}/popfile
%{_datadir}/%name/start_popfile.sh


%changelog
* Sun Jul 5 2009 naoki iimura <naoki@getpopfile.org> 1.1.1-0.3.rc3
-  new upstream version

* Mon Jun 22 2009 naoki iimura <naoki@getpopfile.org> 1.1.1-0.2.rc2
-  new upstream version

* Sat Jun 20 2009 naoki iimura <naoki@getpopfile.org> 1.1.1-0.1.rc1
-  release 1 for version 1.1.1-RC1

