#--------------------------------------------------------------------------
#
# getssl.nsh --- This NSIS 'include' file is used by the POPFile installer (installer.nsi)
#                and by the 'SSL Setup' wizard (add-ons\addssl.nsi) to download and install
#                SSL support for POPFile. If the optional SSL support is required, the
#                installer will download the necessary files during the installation. The
#                'SSL Setup' wizard can be used to add SSL support to an existing POPFile
#                0.22 (or later) installation. This 'include' file ensures that these two
#                programs download and install the same SSL files.
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
# This product downloads software developed by the OpenSSL Project for use
# in the OpenSSL Toolkit (http://www.openssl.org/)
#--------------------------------------------------------------------------

; This version of the script has been tested with the "NSIS 2" compiler (final),
; released 7 February 2004, with no "official" NSIS patches applied.

  ;------------------------------------------------
  ; This script requires the 'untgz' NSIS plugin
  ;------------------------------------------------

  ; This script uses a special NSIS plugin (untgz) to extract files from the *.tar.gz archives.
  ;
  ; The 'NSIS Archives' page for the 'untgz' plugin (description, example and download links):
  ; http://nsis.sourceforge.net/archive/nsisweb.php?page=74&instances=0,32
  ;
  ; Alternative download links can be found at the 'untgz' author's site:
  ; http://www.darklogic.org/win32/nsis/plugins/
  ;
  ; To compile this script, copy the 'untgz.dll' file to the standard NSIS plugins folder
  ; (${NSISDIR}\Plugins\). The 'untgz' source and example files can be unzipped to the
  ; ${NSISDIR}\Contrib\untgz\ folder if you wish, but this step is entirely optional.
  ;
  ; Tested with versions 1.0.5, 1.0.6 and 1.0.7 of the 'untgz' plugin.


#--------------------------------------------------------------------------
# URLs used to download the necessary SSL support archives and files
# (all from the University of Winnipeg Repository)
#--------------------------------------------------------------------------

  ; To check if the target computer is connected to the Internet, we ping this address:

  !define C_UWR_URL_TO_PING   "http://theoryx5.uwinnipeg.ca/"

  ; In addition to some extra Perl modules, POPFile's SSL support needs two OpenSSL DLLs.

  !define C_UWR_IO_SOCKET_SSL "http://theoryx5.uwinnipeg.ca/ppms/x86/IO-Socket-SSL.tar.gz"
  !define C_UWR_NET_SSLEAY    "http://theoryx5.uwinnipeg.ca/ppms/x86/Net_SSLeay.pm.tar.gz"
  !define C_UWR_DLL_SSLEAY32  "http://theoryx5.uwinnipeg.ca/ppms/scripts/ssleay32.dll"
  !define C_UWR_DLL_LIBEAY32  "http://theoryx5.uwinnipeg.ca/ppms/scripts/libeay32.dll"


#--------------------------------------------------------------------------
# User Registers (Global)
#--------------------------------------------------------------------------

  Var G_SSL_FILEURL        ; full URL used to download SSL file

  Var G_PLS_FIELD_2        ; used to customise translated text strings


#--------------------------------------------------------------------------
# Installer Section: POPFile SSL Support
#--------------------------------------------------------------------------

!ifdef INSTALLER
    Section /o "SSL Support" SecSSL
!else
    Section "SSL Support" SecSSL
!endif

  ; The wizard does not contain the SSL support files so we provide an estimate which
  ; includes a slack space allowance (based upon the development system's statistics)

  AddSize 2560

  !define L_RESULT  $R0  ; used by the 'untgz' plugin to return the result

  Push ${L_RESULT}

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_PROG_CHECKINTERNET) $(PFI_LANG_TAKE_SEVERAL_SECONDS)"
  SetDetailsPrint listonly

  !define FLAG_ICC_FORCE_CONNECTION 0x00000001

  ; The system call result is returned in 'r10' (i.e. in $R0)

  System::Call "wininet::InternetCheckConnection( \
  t '${C_UWR_URL_TO_PING}', \
  i ${FLAG_ICC_FORCE_CONNECTION}, i 0) i .r10"

  StrCmp ${L_RESULT} "error" no_ie3
  StrCmp ${L_RESULT} "0" no_connection
  DetailPrint "InternetCheckConnection: online (${L_RESULT})"
  Goto download

no_ie3:
  DetailPrint "InternetCheckConnection: no IE3"
  Goto manual_connect

no_connection:
  DetailPrint "InternetCheckConnection: offline"

manual_connect:
  DetailPrint "InternetCheckConnection: manual connect requested"
  MessageBox MB_OKCANCEL|MB_ICONINFORMATION "$(PFI_LANG_MB_INTERNETCONNECT)" IDOK download
  DetailPrint "InternetCheckConnection: cancelled by user"
  !ifdef INSTALLER
      Goto exit
  !else
      Goto error_exit
  !endif

download:

  ; Download the archives and OpenSSL DLLs

  Push "${C_UWR_IO_SOCKET_SSL}"
  Call GetSSLFile

  Push "${C_UWR_NET_SSLEAY}"
  Call GetSSLFile

  Push "${C_UWR_DLL_SSLEAY32}"
  Call GetSSLFile

  Push "${C_UWR_DLL_LIBEAY32}"
  Call GetSSLFile

  ; Now install the files required for SSL support

  StrCpy $G_MPLIBDIR "$G_ROOTDIR\lib"

  StrCpy $G_PLS_FIELD_1 "$G_MPLIBDIR\IO\Socket"
  DetailPrint ""
  CreateDirectory $G_PLS_FIELD_1
  SetDetailsPrint both
  StrCpy $G_PLS_FIELD_2 "IO-Socket-SSL.tar.gz"
  DetailPrint "$(PFI_LANG_PROG_FILEEXTRACT)"
  SetDetailsPrint listonly
  untgz::extractFile -d "$G_PLS_FIELD_1" "$PLUGINSDIR\IO-Socket-SSL.tar.gz" "SSL.pm"
  StrCmp ${L_RESULT} "success" label_a error_exit

label_a:
  DetailPrint ""
  StrCpy $G_PLS_FIELD_1 "$G_MPLIBDIR\Net"
  CreateDirectory $G_PLS_FIELD_1
  SetDetailsPrint both
  StrCpy $G_PLS_FIELD_2 "Net_SSLeay.pm.tar.gz"
  DetailPrint "$(PFI_LANG_PROG_FILEEXTRACT)"
  SetDetailsPrint listonly
  untgz::extractFile -d "$G_PLS_FIELD_1" "$PLUGINSDIR\Net_SSLeay.pm.tar.gz" "SSLeay.pm"
  StrCmp ${L_RESULT} "success" label_b error_exit

label_b:
  DetailPrint ""
  StrCpy $G_PLS_FIELD_1 "$G_MPLIBDIR\Net\SSLeay"
  CreateDirectory $G_PLS_FIELD_1
  SetDetailsPrint both
  StrCpy $G_PLS_FIELD_2 "Net_SSLeay.pm.tar.gz"
  DetailPrint "$(PFI_LANG_PROG_FILEEXTRACT)"
  SetDetailsPrint listonly
  untgz::extractFile -d "$G_PLS_FIELD_1" "$PLUGINSDIR\Net_SSLeay.pm.tar.gz" "Handle.pm"
  StrCmp ${L_RESULT} "success" label_c error_exit

label_c:
  DetailPrint ""
  StrCpy $G_PLS_FIELD_1 "$G_MPLIBDIR\auto\Net\SSLeay"
  CreateDirectory $G_PLS_FIELD_1
  SetDetailsPrint both
  StrCpy $G_PLS_FIELD_2 "OpenSSL DLL"
  DetailPrint "$(PFI_LANG_PROG_FILECOPY)"
  SetDetailsPrint listonly
  CopyFiles /SILENT "$PLUGINSDIR\ssleay32.dll" "$G_PLS_FIELD_1\ssleay32.dll"
  CopyFiles /SILENT "$PLUGINSDIR\libeay32.dll" "$G_PLS_FIELD_1\libeay32.dll"
  DetailPrint ""
  SetDetailsPrint both
  StrCpy $G_PLS_FIELD_2 "Net_SSLeay.pm.tar.gz"
  DetailPrint "$(PFI_LANG_PROG_FILEEXTRACT)"
  SetDetailsPrint listonly
  untgz::extractV -j -d "$G_PLS_FIELD_1" "$PLUGINSDIR\Net_SSLeay.pm.tar.gz" -x ".exists" "*.html" "*.pl" "*.pm" --
  StrCmp ${L_RESULT} "success" check_bs_file

error_exit:
  SetDetailsPrint listonly
  DetailPrint ""
  SetDetailsPrint both
  DetailPrint "$(PFI_LANG_MB_UNPACKFAIL)"
  SetDetailsPrint listonly
  DetailPrint ""
  MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_MB_UNPACKFAIL)"

  !ifdef INSTALLER
      Goto exit
  !else
      Call GetDateTimeStamp
      Pop $G_PLS_FIELD_1
      DetailPrint "----------------------------------------------------"
      DetailPrint "POPFile SSL Setup failed ($G_PLS_FIELD_1)"
      DetailPrint "----------------------------------------------------"
      Abort
  !endif

check_bs_file:

  ; 'untgz' versions earlier than 1.0.6 (released 28 November 2004) are unable to extract
  ; empty files so this script creates the empty 'SSLeay.bs' file if necessary
  ; (to ensure all of the $G_MPLIBDIR\auto\Net\SSLeay\SSLeay.* files exist)

  IfFileExists "$G_PLS_FIELD_1\SSLeay.bs" done
  File "/oname=$G_PLS_FIELD_1\SSLeay.bs" "zerobyte.file"

done:
  DetailPrint ""

  !ifdef INSTALLER
    exit:
      SetDetailsPrint textonly
      DetailPrint "$(PFI_LANG_INST_PROG_ENDSEC)"
      SetDetailsPrint listonly
  !endif

  Pop ${L_RESULT}

  !undef L_RESULT

SectionEnd


#--------------------------------------------------------------------------
# Installer Function: GetSSLFile
#
# Inputs:
#         (top of stack)     - full URL used to download the SSL file
# Outputs:
#         none
#--------------------------------------------------------------------------

  !define C_NSISDL_TRANSLATIONS "/TRANSLATE '$(PFI_LANG_NSISDL_DOWNLOADING)' '$(PFI_LANG_NSISDL_CONNECTING)' '$(PFI_LANG_NSISDL_SECOND)' '$(PFI_LANG_NSISDL_MINUTE)' '$(PFI_LANG_NSISDL_HOUR)' '$(PFI_LANG_NSISDL_PLURAL)' '$(PFI_LANG_NSISDL_PROGRESS)' '$(PFI_LANG_NSISDL_REMAINING)'"

Function GetSSLFile

  Pop $G_SSL_FILEURL

  StrCpy $G_PLS_FIELD_1 $G_SSL_FILEURL
  Push $G_PLS_FIELD_1
  Call StrBackSlash
  Call GetParent
  Pop $G_PLS_FIELD_2
  StrLen $G_PLS_FIELD_2 $G_PLS_FIELD_2
  IntOp $G_PLS_FIELD_2 $G_PLS_FIELD_2 + 1
  StrCpy $G_PLS_FIELD_1 "$G_PLS_FIELD_1" "" $G_PLS_FIELD_2
  StrCpy $G_PLS_FIELD_2 "$G_SSL_FILEURL" $G_PLS_FIELD_2
  DetailPrint ""
  DetailPrint "$(PFI_LANG_PROG_STARTDOWNLOAD)"
  NSISdl::download ${C_NSISDL_TRANSLATIONS} "$G_SSL_FILEURL" "$PLUGINSDIR\$G_PLS_FIELD_1"
  Pop $G_PLS_FIELD_2
  StrCmp $G_PLS_FIELD_2 "success" file_received
  SetDetailsPrint both
  DetailPrint "$(PFI_LANG_MB_NSISDLFAIL_1)"
  SetDetailsPrint listonly
  DetailPrint "$(PFI_LANG_MB_NSISDLFAIL_2)"
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(PFI_LANG_MB_NSISDLFAIL_1)${MB_NL}$(PFI_LANG_MB_NSISDLFAIL_2)"
  SetDetailsPrint listonly
  DetailPrint ""
  !ifdef ADDSSL
      Call GetDateTimeStamp
      Pop $G_PLS_FIELD_1
      DetailPrint "----------------------------------------------------"
      DetailPrint "POPFile SSL Setup failed ($G_PLS_FIELD_1)"
      DetailPrint "----------------------------------------------------"
      Abort
  !endif

file_received:
FunctionEnd


#--------------------------------------------------------------------------
# End of 'getssl.nsh'
#--------------------------------------------------------------------------
