Summary: Automatic Email Classification

Name: popfile
Version: 1.1.1
Release: 2%{?dist}

Group: Applications/Internet

URL: http://getpopfile.org/
License: GPLv2

# BuildRequires:
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-root
BuildArch: noarch

Source0: http://getpopfile.org/downloads/%{name}-%{version}.zip
Source1: popfile
Source2: start_popfile.sh
# Patch0: no patch

#Requires: perl >= 5.8.1
#Requires: perl(Digest::MD5) perl(MIME::Base64) perl(MIME::QuotedPrint)
#Requires: perl(DBI)
Requires: perl(DBD::SQLite)
#Requires: perl(DBD::SQLite2)
#Requires: perl(Date::Parse) perl(Date::Format)
#Requires: perl(HTML::Template) perl(HTML::Tagset)
Requires: perl(IO::Socket::SSL)
Requires: perl(SOAP::Lite)
Requires: kakasi kakasi-dict perl(Text::Kakasi) perl(Encode)

Requires(post): chkconfig
Requires(preun): chkconfig
Requires(preun): initscripts
Requires(postun): initscripts

%description
POPFile is an automatic mail classification tool. Once properly set up
and trained, it will scan all email as it arrives and classify it
based on your training. You can give it a simple job, like separating
out junk e-mail, or a complicated one-like filing mail into a dozen
folders. Think of it as a personal assistant for your inbox.

%prep

%setup -q -c %{name}-%{version} -T
%{__unzip} -qoa %{SOURCE0}
find . -type f | xargs chmod 0644
%{__cp} -p %{SOURCE1} .
%{__cp} -p %{SOURCE2} .

%build

%install
%{__rm} -rf $RPM_BUILD_ROOT

# popfile program
%{__mkdir_p} $RPM_BUILD_ROOT%{_datadir}/%{name}

%{__cp} -p -r * $RPM_BUILD_ROOT%{_datadir}/%{name}/
%{__install} -p -m 755 *.pl $RPM_BUILD_ROOT%{_datadir}/%{name}/
%{__rm} -f $RPM_BUILD_ROOT%{_datadir}/%{name}/popfile

# popfile data files
%{__mkdir_p} $RPM_BUILD_ROOT%{_localstatedir}/lib/%{name}
%{__install} -p -m 644 stopwords $RPM_BUILD_ROOT%{_localstatedir}/lib/%{name}

# popfile log files
%{__mkdir_p} $RPM_BUILD_ROOT%{_localstatedir}/log/%{name}

# start up script
%{__mkdir_p} $RPM_BUILD_ROOT%{_initddir}
%{__install} -p -m 755 popfile $RPM_BUILD_ROOT%{_initddir}/popfile

%{__install} -p -m 755 start_popfile.sh $RPM_BUILD_ROOT%{_datadir}/%{name}/

%clean

%{__rm} -rf $RPM_BUILD_ROOT

%pre

#if [ "$1" = 2 ]; then
    #/sbin/service %{name} stop >/dev/null 2>&1
#fi
exit 0

%post

/sbin/chkconfig --add %{name}
#/sbin/chkconfig %{name} on
#/sbin/service %{name} start >/dev/null 2>&1
exit 0

%preun

if [ "$1" = 0 ]; then
    /sbin/service %{name} stop >/dev/null 2>&1
    #/sbin/chkconfig %{name} off
    /sbin/chkconfig --del %{name}
fi
exit 0

%postun

if [ "$1" -ge "1" ] ; then
    /sbin/service %{name} condrestart >/dev/null 2>&1 || :
fi

exit 0

%files
%defattr(-,root,root,-)

# popfile program

%dir %{_datadir}/%{name}
%{_datadir}/%{name}/bayes.pl
%{_datadir}/%{name}/black.gif
%{_datadir}/%{name}/favicon.ico
%{_datadir}/%{name}/insert.pl
%doc %{_datadir}/%{name}/license
%{_datadir}/%{name}/otto.gif
%{_datadir}/%{name}/otto.png
%{_datadir}/%{name}/pipe.pl
%{_datadir}/%{name}/pix.gif
%{_datadir}/%{name}/popfile.pck
%{_datadir}/%{name}/popfile.pl
%{_datadir}/%{name}/stopwords
%doc %{_datadir}/%{name}/v%{version}.change
%doc %{_datadir}/%{name}/v%{version}.change.nihongo

%{_datadir}/%{name}/Classifier/
%{_datadir}/%{name}/POPFile/
%{_datadir}/popfile/Proxy/
%{_datadir}/%{name}/UI/
%{_datadir}/%{name}/Services/
%{_datadir}/%{name}/languages/
%{_datadir}/%{name}/skins/

# popfile data files

%dir %{_localstatedir}/lib/%{name}
#%config(missingok) %{_localstatedir}/lib/%{name}/popfile.cfg
#%config(missingok) %{_localstatedir}/lib/%{name}/popfile.db
%config(noreplace) %{_localstatedir}/lib/%{name}/stopwords

# popfile log files

%dir %{_localstatedir}/log/%{name}

# start up script

%{_initddir}/popfile
%{_datadir}/%{name}/start_popfile.sh


%changelog
* Mon Sep 28 2009 naoki iimura <naoki@getpopfile.org> 1.1.1-2
-  removed the license statement
-  updated the release number to "<release number>%%{?dist}" style
-  removed the Vendor/Exclusiveos tags
-  removed the Requires tag for perl itself
-  updated the perl module dependencies to use virtual Provides names
-  added perl(Encode) dependency
-  fixed permission of popfile and start_popfile.sh
-  simplified the %%install section
-  added "-p" option to "install" command and "cp" command to preserve
   timestamps
-  rewrote macros in "%%{name}" style
-  use %%{_initddir} macro instead of %%{_initrddir}
-  added missing Requres(post), Requires(preun) and Requires(postun)
-  commented out '/sbin/service popfile stop' in %%pre script
-  added %%postun script
-  updated the scripts to use "/sbin/service" style
-  updated %%defattr to %%defattr(-,root,root,-) in the %%files section
-  simplified the %%files section
-  popfile init.d script
   updated chkconfig and deleted Default-Start and Default-Stop lines

* Sat Sep 26 2009 naoki iimura <naoki@getpopfile.org> 1.1.1-1.1
-  new upstream version

* Sun Jul 5 2009 naoki iimura <naoki@getpopfile.org> 1.1.1-0.3.rc3
-  new upstream version

* Mon Jun 22 2009 naoki iimura <naoki@getpopfile.org> 1.1.1-0.2.rc2
-  new upstream version

* Sat Jun 20 2009 naoki iimura <naoki@getpopfile.org> 1.1.1-0.1.rc1
-  release 1 for version 1.1.1-RC1

