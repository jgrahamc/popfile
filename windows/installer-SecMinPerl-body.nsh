#--------------------------------------------------------------------------
#
# installer-SecMinPerl-body.nsh --- This 'include' file contains the body of the "MinPerl"
#                                   Section of the main 'installer.nsi' NSIS script used to
#                                   create the Windows installer for POPFile. The "MinPerl"
#                                   section installs a minimal Perl which suits the default
#                                   POPFile configuration. For some of the optional POPFile
#                                   components (e.g. XMLRPC) additional Perl components are
#                                   required and these are installed at the same time as the
#                                   optional POPFile component.
#
# Copyright (c) 2005 John Graham-Cumming
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
#--------------------------------------------------------------------------
#  The 'installer.nsi' script file contains the following code:
#
#         Section "-Minimal Perl" SecMinPerl
#           !include "installer-SecMinPerl-body.nsh"
#         SectionEnd
#--------------------------------------------------------------------------

; Section "-Minimal Perl" SecMinPerl

  ; This section installs the "core" version of the minimal Perl. Some of the optional
  ; POPFile components, such as the Kakasi package and POPFile's XMLRPC module, require
  ; extra Perl components which are added when the optional POPFile components are installed.

  !insertmacro SECTIONLOG_ENTER "Minimal Perl"

  ; Install the Minimal Perl files

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_PERL)"
  SetDetailsPrint listonly

  ; Remove empty minimal Perl folder (error flag set if folder not empty)

  ClearErrors
  RMDir "$G_MPLIBDIR"
  IfErrors 0 install_now
  StrCpy $G_PLS_FIELD_1 "$G_MPLIBDIR"
  MessageBox MB_YESNO|MB_ICONQUESTION "$(PFI_LANG_MINPERL_MBREMOLD)" IDNO install_now
  DetailPrint "Remove old minimal Perl folder"
  RMDir /r "$G_MPLIBDIR"
  DetailPrint ""

install_now:
  SetOutPath "$G_ROOTDIR"
  File "${C_PERL_DIR}\bin\perl.exe"
  File "${C_PERL_DIR}\bin\wperl.exe"
  File "${C_PERL_DIR}\bin\perl58.dll"

  SetOutPath "$G_MPLIBDIR"
  File "${C_PERL_DIR}\lib\AutoLoader.pm"
  File "${C_PERL_DIR}\lib\Carp.pm"
  File "${C_PERL_DIR}\lib\Config.pm"
  File "${C_PERL_DIR}\lib\constant.pm"
  File "${C_PERL_DIR}\lib\DynaLoader.pm"
  File "${C_PERL_DIR}\lib\Errno.pm"
  File "${C_PERL_DIR}\lib\Exporter.pm"
  File "${C_PERL_DIR}\lib\Fcntl.pm"
  File "${C_PERL_DIR}\lib\integer.pm"
  File "${C_PERL_DIR}\lib\IO.pm"
  File "${C_PERL_DIR}\lib\lib.pm"
  File "${C_PERL_DIR}\lib\locale.pm"
  File "${C_PERL_DIR}\lib\POSIX.pm"
  File "${C_PERL_DIR}\lib\re.pm"
  File "${C_PERL_DIR}\lib\SelectSaver.pm"
  File "${C_PERL_DIR}\lib\Socket.pm"
  File "${C_PERL_DIR}\lib\strict.pm"
  File "${C_PERL_DIR}\lib\Symbol.pm"
  File "${C_PERL_DIR}\lib\vars.pm"
  File "${C_PERL_DIR}\lib\warnings.pm"
  File "${C_PERL_DIR}\lib\XSLoader.pm"

  SetOutPath "$G_MPLIBDIR\Carp"
  File "${C_PERL_DIR}\lib\Carp\*"

  SetOutPath "$G_MPLIBDIR\Date"
  File "${C_PERL_DIR}\site\lib\Date\Format.pm"
  File "${C_PERL_DIR}\site\lib\Date\Parse.pm"

  SetOutPath "$G_MPLIBDIR\Digest"
  File "${C_PERL_DIR}\lib\Digest\MD5.pm"

  SetOutPath "$G_MPLIBDIR\Exporter"
  File "${C_PERL_DIR}\lib\Exporter\*"

  SetOutPath "$G_MPLIBDIR\File"
  File "${C_PERL_DIR}\lib\File\Copy.pm"
  File "${C_PERL_DIR}\lib\File\Glob.pm"
  File "${C_PERL_DIR}\lib\File\Spec.pm"

  SetOutPath "$G_MPLIBDIR\File\Spec"
  File "${C_PERL_DIR}\lib\File\Spec\Unix.pm"
  File "${C_PERL_DIR}\lib\File\Spec\Win32.pm"

  SetOutPath "$G_MPLIBDIR\Getopt"
  File "${C_PERL_DIR}\lib\Getopt\Long.pm"

  SetOutPath "$G_MPLIBDIR\HTML"
  File "${C_PERL_DIR}\site\lib\HTML\Tagset.pm"
  File "${C_PERL_DIR}\site\lib\HTML\Template.pm"

  SetOutPath "$G_MPLIBDIR\IO"
  File "${C_PERL_DIR}\lib\IO\*"

  SetOutPath "$G_MPLIBDIR\IO\Socket"
  File "${C_PERL_DIR}\lib\IO\Socket\*"

  SetOutPath "$G_MPLIBDIR\MIME"
  File "${C_PERL_DIR}\lib\MIME\*"

  SetOutPath "$G_MPLIBDIR\Sys"
  File "${C_PERL_DIR}\lib\Sys\*"

  SetOutPath "$G_MPLIBDIR\Text"
  File "${C_PERL_DIR}\lib\Text\ParseWords.pm"

  SetOutPath "$G_MPLIBDIR\Time"
  File "${C_PERL_DIR}\lib\Time\Local.pm"
  File "${C_PERL_DIR}\site\lib\Time\Zone.pm"

  SetOutPath "$G_MPLIBDIR\warnings"
  File "${C_PERL_DIR}\lib\warnings\register.pm"

  SetOutPath "$G_MPLIBDIR\auto\Digest\MD5"
  File "${C_PERL_DIR}\lib\auto\Digest\MD5\*"

  SetOutPath "$G_MPLIBDIR\auto\DynaLoader"
  File "${C_PERL_DIR}\lib\auto\DynaLoader\*"

  SetOutPath "$G_MPLIBDIR\auto\Fcntl"
  File "${C_PERL_DIR}\lib\auto\Fcntl\Fcntl.dll"

  SetOutPath "$G_MPLIBDIR\auto\File\Glob"
  File "${C_PERL_DIR}\lib\auto\File\Glob\*"

  SetOutPath "$G_MPLIBDIR\auto\IO"
  File "${C_PERL_DIR}\lib\auto\IO\*"

  SetOutPath "$G_MPLIBDIR\auto\MIME\Base64"
  File "${C_PERL_DIR}\lib\auto\MIME\Base64\*"

  SetOutPath "$G_MPLIBDIR\auto\POSIX"
  File "${C_PERL_DIR}\lib\auto\POSIX\POSIX.dll"
  File "${C_PERL_DIR}\lib\auto\POSIX\autosplit.ix"
  File "${C_PERL_DIR}\lib\auto\POSIX\load_imports.al"

  SetOutPath "$G_MPLIBDIR\auto\Socket"
  File "${C_PERL_DIR}\lib\auto\Socket\*"

  SetOutPath "$G_MPLIBDIR\auto\Sys\Hostname"
  File "${C_PERL_DIR}\lib\auto\Sys\Hostname\*"

  ; Install Perl modules and library files for BerkeleyDB support. Although POPFile now uses
  ; SQLite (or another SQL database) to store the corpus and other essential data, it retains
  ; the ability to automatically convert old BerkeleyDB format corpus files to the SQL database
  ; format. Therefore the installer still installs the BerkeleyDB Perl components.

  SetOutPath "$G_MPLIBDIR"
  File "${C_PERL_DIR}\site\lib\BerkeleyDB.pm"
  File "${C_PERL_DIR}\lib\UNIVERSAL.pm"

  SetOutPath "$G_MPLIBDIR\auto\BerkeleyDB"
  File "${C_PERL_DIR}\site\lib\auto\BerkeleyDB\autosplit.ix"
  File "${C_PERL_DIR}\site\lib\auto\BerkeleyDB\BerkeleyDB.bs"
  File "${C_PERL_DIR}\site\lib\auto\BerkeleyDB\BerkeleyDB.dll"
  File "${C_PERL_DIR}\site\lib\auto\BerkeleyDB\BerkeleyDB.exp"
  File "${C_PERL_DIR}\site\lib\auto\BerkeleyDB\BerkeleyDB.lib"

  ; Install Perl modules and library files for SQLite support

  SetOutPath "$G_MPLIBDIR"
  File "${C_PERL_DIR}\lib\base.pm"
  File "${C_PERL_DIR}\lib\overload.pm"
  File "${C_PERL_DIR}\site\lib\DBI.pm"

  ; Required in order to use any version of SQLite

  SetOutPath "$G_MPLIBDIR\auto\DBI"
  File "${C_PERL_DIR}\site\lib\auto\DBI\DBI.bs"
  File "${C_PERL_DIR}\site\lib\auto\DBI\DBI.dll"
  File "${C_PERL_DIR}\site\lib\auto\DBI\DBI.exp"
  File "${C_PERL_DIR}\site\lib\auto\DBI\DBI.lib"

  ; Install SQLite support

  SetOutPath "$G_MPLIBDIR\DBD"
  File "${C_PERL_DIR}\site\lib\DBD\SQLite.pm"

  SetOutPath "$G_MPLIBDIR\auto\DBD\SQLite"
  File "${C_PERL_DIR}\site\lib\auto\DBD\SQLite\SQLite.bs"
  File "${C_PERL_DIR}\site\lib\auto\DBD\SQLite\SQLite.dll"
  File "${C_PERL_DIR}\site\lib\auto\DBD\SQLite\SQLite.exp"
  File "${C_PERL_DIR}\site\lib\auto\DBD\SQLite\SQLite.lib"

  ; Extra Perl modules required for the encrypted cookies introduced in POPFile 0.23.0

  SetOutPath "$G_MPLIBDIR"
  File "${C_PERL_DIR}\lib\bytes.pm"
  File "${C_PERL_DIR}\lib\subs.pm"

  SetOutPath "$G_MPLIBDIR\Class"
  File "${C_PERL_DIR}\site\lib\Class\Loader.pm"

  SetOutPath "$G_MPLIBDIR\Crypt"
  File "${C_PERL_DIR}\site\lib\Crypt\Blowfish.pm"
  File "${C_PERL_DIR}\site\lib\Crypt\CBC.pm"
  File "${C_PERL_DIR}\site\lib\Crypt\Random.pm"

  SetOutPath "$G_MPLIBDIR\Crypt\Random"
  File "${C_PERL_DIR}\site\lib\Crypt\Random\Generator.pm"

  SetOutPath "$G_MPLIBDIR\Crypt\Random\Provider"
  File "${C_PERL_DIR}\site\lib\Crypt\Random\Provider\*.pm"

  SetOutPath "$G_MPLIBDIR\Data"
  File "${C_PERL_DIR}\lib\Data\Dumper.pm"

  SetOutPath "$G_MPLIBDIR\Digest"
  File "${C_PERL_DIR}\site\lib\Digest\SHA.pm"

  SetOutPath "$G_MPLIBDIR\Math"
  File "${C_PERL_DIR}\site\lib\Math\Pari.pm"

  SetOutPath "$G_MPLIBDIR\auto\Crypt\Blowfish"
  File "${C_PERL_DIR}\site\lib\auto\Crypt\Blowfish\Blowfish.bs"
  File "${C_PERL_DIR}\site\lib\auto\Crypt\Blowfish\Blowfish.dll"
  File "${C_PERL_DIR}\site\lib\auto\Crypt\Blowfish\Blowfish.exp"
  File "${C_PERL_DIR}\site\lib\auto\Crypt\Blowfish\Blowfish.lib"

  SetOutPath "$G_MPLIBDIR\auto\Data\Dumper"
  File "${C_PERL_DIR}\lib\auto\Data\Dumper\Dumper.bs"
  File "${C_PERL_DIR}\lib\auto\Data\Dumper\Dumper.dll"
  File "${C_PERL_DIR}\lib\auto\Data\Dumper\Dumper.exp"
  File "${C_PERL_DIR}\lib\auto\Data\Dumper\Dumper.lib"

  SetOutPath "$G_MPLIBDIR\auto\Digest\SHA"
  File "${C_PERL_DIR}\site\lib\auto\Digest\SHA\SHA.bs"
  File "${C_PERL_DIR}\site\lib\auto\Digest\SHA\SHA.dll"
  File "${C_PERL_DIR}\site\lib\auto\Digest\SHA\SHA.exp"
  File "${C_PERL_DIR}\site\lib\auto\Digest\SHA\SHA.lib"

  SetOutPath "$G_MPLIBDIR\auto\Math\Pari"
  File "${C_PERL_DIR}\site\lib\auto\Math\Pari\Pari.bs"
  File "${C_PERL_DIR}\site\lib\auto\Math\Pari\Pari.dll"
  File "${C_PERL_DIR}\site\lib\auto\Math\Pari\Pari.exp"
  File "${C_PERL_DIR}\site\lib\auto\Math\Pari\Pari.lib"

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_ENDSEC)"
  SetDetailsPrint listonly

  !insertmacro SECTIONLOG_EXIT "Minimal Perl"

; SectionEnd

#--------------------------------------------------------------------------
# End of 'installer-SecMinPerl-body.nsh'
#--------------------------------------------------------------------------
