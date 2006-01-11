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
# Copyright (c) 2005-2006 John Graham-Cumming
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
  ; The 'NSIS Wiki' page for the 'untgz' plugin (description, example and download links):
  ; http://nsis.sourceforge.net/UnTGZ_plug-in
  ;
  ; Alternative download links can be found at the 'untgz' author's site:
  ; http://www.darklogic.org/win32/nsis/plugins/
  ;
  ; To compile this script, copy the 'untgz.dll' file to the standard NSIS plugins folder
  ; (${NSISDIR}\Plugins\). The 'untgz' source and example files can be unzipped to the
  ; ${NSISDIR}\Contrib\untgz\ folder if you wish, but this step is entirely optional.
  ;
  ; Tested with versions 1.0.5, 1.0.6, 1.0.7 and 1.0.8 of the 'untgz' plugin.


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
      !insertmacro SECTIONLOG_ENTER "SSL Support"

      ; The main installer does not contain the SSL support files so we provide an estimate
      ; which includes a slack space allowance (based upon the development system's statistics)

      AddSize 2560
!else
    Section "SSL Support" SecSSL

      ; The stand-alone utility includes a compressed set of POPFile 0.22.x compatible SSL
      ; support files so we increase the size estimate to take the necessary unpacking into
      ; account (and assume that there will not be a significant difference in the space
      ; required if the wizard decides to download the SSL support files instead).

      AddSize 1450
!endif


  !define L_RESULT  $R0  ; used by the 'untgz' plugin to return the result

  Push ${L_RESULT}

  !ifdef ADDSSL

      !define L_VER_X    $R1     ; We check only the first three fields in the version number
      !define L_VER_Y    $R2     ; but the code could be further simplified by merely testing
      !define L_VER_Z    $R3     ; the 'build number' field (the field we currently ignore)

      Push ${L_VER_X}
      Push ${L_VER_Y}
      Push ${L_VER_Z}

      ; The stand-alone utility may be used to add SSL support to an 0.22.x installation
      ; which is not compatible with the files in the University of Winnipeg repository,
      ; so we check the minimal Perl's version number to see if we should use the built-in
      ; SSL files instead of downloading the most up-to-date ones.

      IfFileExists "$G_ROOTDIR\perl58.dll" check_Perl_version
      DetailPrint "Assume 0.22.x installation (perl58.dll not found in '$G_ROOTDIR' folder)"
      Goto assume_0_22_x

    check_Perl_version:
      GetDllVersion "$G_ROOTDIR\perl58.dll" ${L_VER_Y} ${L_VER_Z}
      IntOp ${L_VER_X} ${L_VER_Y} / 0x00010000
      IntOp ${L_VER_Y} ${L_VER_Y} & 0x0000FFFF
      IntOp ${L_VER_Z} ${L_VER_Z} / 0x00010000
      DetailPrint "Minimal Perl version ${L_VER_X}.${L_VER_Y}.${L_VER_Z} detected in '$G_ROOTDIR' folder"

      ; Only download the SSL files if the minimal Perl is version 5.8.7 or higher

      StrCpy ${L_RESULT} "built-in"

      IntCmp ${L_VER_X} 5 0 restore_vars set_download_flag
      IntCmp ${L_VER_Y} 8 0 restore_vars set_download_flag
      IntCmp ${L_VER_Z} 7 0 restore_vars set_download_flag

    set_download_flag:
      StrCpy ${L_RESULT} "download"

    restore_vars:
      Pop ${L_VER_Z}
      Pop ${L_VER_Y}
      Pop ${L_VER_X}

      !undef L_VER_X
      !undef L_VER_Y
      !undef L_VER_Z

      StrCmp ${L_RESULT} "download" download_ssl

    assume_0_22_x:

      ; Pretend we've just downloaded these files from the repository

      DetailPrint "therefore built-in SSL files used instead of downloading the latest versions"
      DetailPrint ""
      SetOutPath "$PLUGINSDIR"
      File "ssl-0.22.x\IO-Socket-SSL.tar.gz"
      File "ssl-0.22.x\Net_SSLeay.pm.tar.gz"
      File "ssl-0.22.x\ssleay32.dll"
      File "ssl-0.22.x\libeay32.dll"
      Goto install_SSL_support

    download_ssl:
      DetailPrint "therefore the latest versions of the SSL files will be downloaded"
      DetailPrint ""
  !endif

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
      Goto installer_error_exit
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

  !ifdef INSTALLER
      IfFileExists "$PLUGINSDIR\IO-Socket-SSL.tar.gz" 0 installer_error_exit
      IfFileExists "$PLUGINSDIR\Net_SSLeay.pm.tar.gz" 0 installer_error_exit
      IfFileExists "$PLUGINSDIR\ssleay32.dll" 0 installer_error_exit
      IfFileExists "$PLUGINSDIR\libeay32.dll" 0 installer_error_exit
      StrCmp $G_SSL_ONLY "0" install_SSL_support

      ; The '/SSL' option was supplied so we need to make sure it is safe to install the files

      DetailPrint ""
      SetDetailsPrint both
      DetailPrint "$(PFI_LANG_PROG_CHECKIFRUNNING) $(PFI_LANG_TAKE_SEVERAL_SECONDS)"
      SetDetailsPrint listonly
      DetailPrint ""
      Call MakeRootDirSafe
  !endif

install_SSL_support:

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
    installer_error_exit:
      Push $R1    ; No need to preserve $R0 here as it is known as ${L_RESULT} in this 'Section'

      ; The first system call gets the full pathname (returned in $R0) and the second call
      ; extracts the filename (and possibly the extension) part (returned in $R1)

      System::Call 'kernel32::GetModuleFileNameA(i 0, t .R0, i 1024)'
      System::Call 'comdlg32::GetFileTitleA(t R0, t .R1, i 1024)'
      StrCpy $G_PLS_FIELD_1 $R1
      MessageBox MB_OK|MB_ICONEXCLAMATION "$(PFI_LANG_MB_REPEATSSL)"

      Pop $R1
      Goto exit
  !else
      Call PFI_GetDateTimeStamp
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
      !insertmacro SECTIONLOG_EXIT "SSL Support"
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
  Call PFI_StrBackSlash
  Call PFI_GetParent
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
      Call PFI_GetDateTimeStamp
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
