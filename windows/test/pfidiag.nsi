#--------------------------------------------------------------------------
#
# pfidiag.nsi --- This NSIS script is used to create a simple diagnostic utility
#                 to assist in solving problems with POPFile installations created
#                 by the Windows installer for POPFile v0.21.0 (or later).
#
# Copyright (c) 2004  John Graham-Cumming
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

; This version of the script has been tested with the "NSIS 2" compiler (final),
; released 7 February 2004, with no "official" NSIS patches/CVS updates applied.

#--------------------------------------------------------------------------
# Run-time command-line switch (used by 'pfidiag.exe')
#--------------------------------------------------------------------------
#
# /SIMPLE
#
# This command-line switch selects the default mode which only displays a few key values.
# If no command-line switch is supplied (or if an unrecognized one is supplied), the default
# mode is selected. Uppercase or lowercase may be used.
#
# /FULL
#
# Normally the utility displays enough information to identify the location of the 'User Data'
# files. If this command-line switch is supplied, the utility displays much more information
# (which might help debug strange behaviour, for example). Uppercase or lowercase may be used.
#
# If both command-line switches are supplied, the default mode will be used.
#
#--------------------------------------------------------------------------

  ;--------------------------------------------------------------------------
  ; POPFile constants have been given names beginning with 'C_' (eg C_README)
  ;--------------------------------------------------------------------------

  !define C_VERSION   "0.0.41"

  ;--------------------------------------------------------------------------
  ; The default NSIS caption is "$(^Name) Setup" so we override it here
  ;--------------------------------------------------------------------------

  Name    "PFI Diagnostic Utility"
  Caption "$(^Name) v${C_VERSION}"

  ; Check data created by the "main" POPFile installer and/or its 'Add POPFile User' wizard

  !define C_PFI_PRODUCT                 "POPFile"
  !define C_PFI_PRODUCT_REGISTRY_ENTRY  "Software\POPFile Project\${C_PFI_PRODUCT}\MRI"

#--------------------------------------------------------------------------
# Use the "Modern User Interface"
#--------------------------------------------------------------------------

  !include "MUI.nsh"

#--------------------------------------------------------------------------
# Version Information settings (for the utility's EXE file)
#--------------------------------------------------------------------------

  ; 'VIProductVersion' format is X.X.X.X where X is a number in range 0 to 65535
  ; representing the following values: Major.Minor.Release.Build

  VIProductVersion                   "${C_VERSION}.0"

  VIAddVersionKey "ProductName"      "PFI Diagnostic Utility"
  VIAddVersionKey "Comments"         "POPFile Homepage: http://popfile.sf.net"
  VIAddVersionKey "CompanyName"      "The POPFile Project"
  VIAddVersionKey "LegalCopyright"   "Copyright (c) 2004  John Graham-Cumming"
  VIAddVersionKey "FileDescription"  "PFI Diagnostic Utility"
  VIAddVersionKey "FileVersion"      "${C_VERSION}"

  VIAddVersionKey "Build Date/Time"  "${__DATE__} @ ${__TIME__}"
  VIAddVersionKey "Build Script"     "${__FILE__}$\r$\n(${__TIMESTAMP__})"

#--------------------------------------------------------------------------
# Configure the MUI pages
#--------------------------------------------------------------------------

  ;----------------------------------------------------------------
  ; Interface Settings - General Interface Settings
  ;----------------------------------------------------------------

  ; The icon file for the utility

  !define MUI_ICON                            "pfinfo.ico"

  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP              "..\hdr-common.bmp"
  !define MUI_HEADERIMAGE_RIGHT

  ;----------------------------------------------------------------
  ;  Interface Settings - Interface Resource Settings
  ;----------------------------------------------------------------

  ; The banner provided by the default 'modern.exe' UI does not provide much room for the
  ; two lines of text, e.g. the German version is truncated, so we use a custom UI which
  ; provides slightly wider text areas. Each area is still limited to a single line of text.

  !define MUI_UI                              "..\UI\pfi_modern.exe"

  ; The 'hdr-common.bmp' logo is only 90 x 57 pixels, much smaller than the 150 x 57 pixel
  ; space provided by the default 'modern_headerbmpr.exe' UI, so we use a custom UI which
  ; leaves more room for the TITLE and SUBTITLE text.

  !define MUI_UI_HEADERIMAGE_RIGHT            "..\UI\pfi_headerbmpr.exe"

  ;----------------------------------------------------------------
  ;  Interface Settings - Installer Finish Page Interface Settings
  ;----------------------------------------------------------------

  ; Show the installation log and leave the window open when utility has completed its work

  ShowInstDetails show
  !define MUI_FINISHPAGE_NOAUTOCLOSE

#--------------------------------------------------------------------------
# Define the Page order for the utility
#--------------------------------------------------------------------------

  ;---------------------------------------------------
  ; Installer Page - Install files
  ;---------------------------------------------------

  ; Override the standard "Installing..." page header

  !define MUI_PAGE_HEADER_TEXT                    "Generating the PFI Diagnostic report..."
  !define MUI_PAGE_HEADER_SUBTEXT \
          "Searching for POPFile registry entries and the POPFile environment variables"

  ; Override the standard "Installation complete..." page header

  !define MUI_INSTFILESPAGE_FINISHHEADER_TEXT     "POPFile Installer Diagnostic Utility"
  !define MUI_INSTFILESPAGE_FINISHHEADER_SUBTEXT \
          "For a simple report use 'PFIDIAG'       For a detailed report use 'PFIDIAG /FULL'"

  !insertmacro MUI_PAGE_INSTFILES

#--------------------------------------------------------------------------
# Language Support for the utility
#--------------------------------------------------------------------------

  !insertmacro MUI_LANGUAGE "English"

#--------------------------------------------------------------------------
# General settings
#--------------------------------------------------------------------------

  ; Specify EXE filename and icon for the utility

  OutFile "pfidiag.exe"

  ; Ensure details are shown

  ShowInstDetails show

;--------------------------------------------------------------------------
; Section: default
;--------------------------------------------------------------------------

Section default

  !define L_DIAG_MODE       $R9   ; controls the level of detail supplied by the utility
  !define L_EXPECTED_ROOT   $R8   ; expected value for POPFILE_ROOT or SFN version of RootDir
  !define L_EXPECTED_USER   $R7   ; expected value for POPFILE_USER or SFN version of UserDir
  !define L_ITAIJIDICTPATH  $R6   ; current Kakasi environment variable
  !define L_KANWADICTPATH   $R5   ; current Kakasi environment variable
  !define L_POPFILE_ROOT    $R4   ; current environment variable
  !define L_POPFILE_USER    $R3   ; current environment variable
  !define L_REGDATA         $R2   ; data read from registry
  !define L_STATUS_ROOT     $R1   ; used when reporting whether or not 'popfile.pl' exists
  !define L_STATUS_USER     $R0   ; used when reporting whether or not 'popfile.cfg' exists
  !define L_TEMP            $9
  !define L_WIN_OS_TYPE     $8    ; 0 = Win9x, 1 = more modern version of Windows
  !define L_WINUSERNAME     $7    ; user's Windows login name
  !define L_WINUSERTYPE     $6

  ; If the command-line switch /FULL has been supplied, display "everything"
  ; (for convenience we set ${L_DIAG_MODE} internally to either "full" or "simple")

  Call GetParameters
  Pop ${L_DIAG_MODE}
  StrCpy ${L_TEMP} ${L_DIAG_MODE} 1
  StrCmp ${L_TEMP} "/" 0 set_simple
  StrCpy ${L_DIAG_MODE} ${L_DIAG_MODE} "" 1
  StrCmp ${L_DIAG_MODE} "full" diag_mode_set
  StrCmp ${L_DIAG_MODE} "simple" diag_mode_set

set_simple:
  StrCpy ${L_DIAG_MODE} "simple"

diag_mode_set:
  Call IsNT
  Pop ${L_WIN_OS_TYPE}

  ; The 'UserInfo' plugin may return an error if run on a Win9x system but since Win9x systems
  ; do not support different account types, we treat this error as if user has 'Admin' rights.

	ClearErrors
	UserInfo::GetName
	IfErrors 0 got_name

  ; Assume Win9x system, so user has 'Admin' rights

  StrCpy ${L_WINUSERNAME} "UnknownUser"
  StrCpy ${L_WINUSERNAME} "Admin"
  Goto start_report

got_name:
	Pop ${L_WINUSERNAME}
  StrCmp ${L_WINUSERNAME} "" 0 get_usertype
  StrCpy ${L_WINUSERNAME} "UnknownUser"

get_usertype:
  UserInfo::GetAccountType
	Pop ${L_WINUSERTYPE}
  StrCmp ${L_WINUSERTYPE} "Admin" start_report
  StrCmp ${L_WINUSERTYPE} "Power" start_report
  StrCmp ${L_WINUSERTYPE} "User" start_report
  StrCmp ${L_WINUSERTYPE} "Guest" start_report
  StrCpy ${L_WINUSERTYPE} "Unknown"

start_report:
  DetailPrint "------------------------------------------------------------"
  DetailPrint "POPFile $(^Name) v${C_VERSION} (${L_DIAG_MODE} mode)"
  DetailPrint "------------------------------------------------------------"
  DetailPrint ""

  DetailPrint "Current UserName  = ${L_WINUSERNAME} (${L_WINUSERTYPE})"
  DetailPrint ""

  StrCmp ${L_DIAG_MODE} "simple" simple_HKCU_locns

  DetailPrint "IsNT return code  = ${L_WIN_OS_TYPE}"

  Call GetIEVersion
  Pop ${L_TEMP}
  DetailPrint "Internet Explorer = ${L_TEMP}"
  DetailPrint ""

  DetailPrint "------------------------------------------------------------"
  DetailPrint "Start Menu Locations"
  DetailPrint "------------------------------------------------------------"
  DetailPrint ""

  SetShellVarContext all
  DetailPrint "AU: $$SMPROGRAMS   = < $SMPROGRAMS >"
  DetailPrint "AU: $$SMSTARTUP    = < $SMSTARTUP >"
  DetailPrint ""

  SetShellVarContext current
  DetailPrint "CU: $$SMPROGRAMS   = < $SMPROGRAMS >"
  DetailPrint "CU: $$SMSTARTUP    = < $SMSTARTUP >"
  DetailPrint ""

  DetailPrint "------------------------------------------------------------"
  DetailPrint "Obsolete/testbed Registry Entries"
  DetailPrint "------------------------------------------------------------"
  DetailPrint ""

  DetailPrint "[1] Pre-0.21 Data:"
  DetailPrint ""

  ReadRegStr ${L_REGDATA} HKLM "Software\POPFile" "InstallLocation"
  DetailPrint "Pre-0.21 POPFile  = < ${L_REGDATA} >"

  ReadRegStr ${L_REGDATA} HKLM "Software\POPFile Testbed" "InstallLocation"
  DetailPrint "Pre-0.21 Testbed  = < ${L_REGDATA} >"
  DetailPrint ""

  DetailPrint "[2] 0.21 Test Installer Data:"
  DetailPrint ""

  ReadRegStr ${L_REGDATA} HKLM "Software\POPFile Project\POPFileTest\MRI" "RootDir_LFN"
  DetailPrint "HKLM: RootDir_LFN = < ${L_REGDATA} >"
  ReadRegStr ${L_REGDATA} HKLM "Software\POPFile Project\POPFileTest\MRI" "RootDir_SFN"
  DetailPrint "HKLM: RootDir_SFN = < ${L_REGDATA} >"
  DetailPrint ""

  ReadRegStr ${L_REGDATA} HKCU "Software\POPFile Project\POPFileTest\MRI" "RootDir_LFN"
  DetailPrint "HKCU: RootDir_LFN = < ${L_REGDATA} >"
  ReadRegStr ${L_REGDATA} HKCU "Software\POPFile Project\POPFileTest\MRI" "RootDir_SFN"
  DetailPrint "HKCU: RootDir_SFN = < ${L_REGDATA} >"
  ReadRegStr ${L_REGDATA} HKCU "Software\POPFile Project\POPFileTest\MRI" "UserDir_LFN"
  DetailPrint "HKCU: UserDir_LFN = < ${L_REGDATA} >"
  ReadRegStr ${L_REGDATA} HKCU "Software\POPFile Project\POPFileTest\MRI" "UserDir_SFN"
  DetailPrint "HKCU: UserDir_SFN = < ${L_REGDATA} >"
  DetailPrint ""

  DetailPrint "[3] Current PFI Testbed Data:"
  DetailPrint ""

  ReadRegStr ${L_REGDATA} HKCU "Software\POPFile Project\PFI Testbed\MRI" "InstallPath"
  DetailPrint "MRI PFI Testbed   = < ${L_REGDATA} >"
  ReadRegStr ${L_REGDATA} HKCU "Software\POPFile Project\PFI Testbed\MRI" "UserDataPath"
  DetailPrint "MRI PFI Testdata  = < ${L_REGDATA} >"
  DetailPrint ""

  DetailPrint "------------------------------------------------------------"
  DetailPrint "POPFile Registry Data"
  DetailPrint "------------------------------------------------------------"
  DetailPrint ""

  ; Check NTFS Short File Name support

  ReadRegDWORD ${L_REGDATA} \
      HKLM "System\CurrentControlSet\Control\FileSystem" "NtfsDisable8dot3NameCreation"
  DetailPrint "NTFS SFN Disabled = < ${L_REGDATA} >"
  DetailPrint ""

  ; Check HKLM data

  ReadRegStr ${L_TEMP} HKLM "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "POPFile Major Version"
  StrCpy ${L_REGDATA} ${L_TEMP}
  ReadRegStr ${L_TEMP} HKLM "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "POPFile Minor Version"
  StrCpy ${L_REGDATA} ${L_REGDATA}.${L_TEMP}
  ReadRegStr ${L_TEMP} HKLM "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "POPFile Revision"
  StrCpy ${L_REGDATA} ${L_REGDATA}.${L_TEMP}
  ReadRegStr ${L_TEMP} HKLM "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "POPFile RevStatus"
  StrCpy ${L_REGDATA} ${L_REGDATA}${L_TEMP}
  DetailPrint "HKLM: MRI Version = < ${L_REGDATA} >"

  ReadRegStr ${L_REGDATA} HKLM "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "InstallPath"
  DetailPrint "HKLM: InstallPath = < ${L_REGDATA} >"
  ReadRegStr ${L_REGDATA} HKLM "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "RootDir_LFN"
  DetailPrint "HKLM: RootDir_LFN = < ${L_REGDATA} >"
  StrCpy ${L_EXPECTED_ROOT} ${L_REGDATA}
  ReadRegStr ${L_REGDATA} HKLM "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "RootDir_SFN"
  DetailPrint "HKLM: RootDir_SFN = < ${L_REGDATA} >"
  StrCmp ${L_REGDATA} "Not supported" end_HKLM_root
  GetFullPathName /SHORT ${L_EXPECTED_ROOT} ${L_EXPECTED_ROOT}
  StrCmp ${L_EXPECTED_ROOT} ${L_REGDATA} end_HKLM_root
  DetailPrint "^^^^^ Error ^^^^^"
  DetailPrint "Expected Root SFN = < ${L_EXPECTED_ROOT} >"

end_HKLM_root:
  DetailPrint ""

  ; Check HKCU data

  ReadRegStr ${L_REGDATA} HKCU "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "Owner"
  DetailPrint "HKCU: Data Owner  = < ${L_REGDATA} >"

  ReadRegStr ${L_TEMP} HKCU "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "POPFile Major Version"
  StrCpy ${L_REGDATA} ${L_TEMP}
  ReadRegStr ${L_TEMP} HKCU "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "POPFile Minor Version"
  StrCpy ${L_REGDATA} ${L_REGDATA}.${L_TEMP}
  ReadRegStr ${L_TEMP} HKCU "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "POPFile Revision"
  StrCpy ${L_REGDATA} ${L_REGDATA}.${L_TEMP}
  ReadRegStr ${L_TEMP} HKCU "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "POPFile RevStatus"
  StrCpy ${L_REGDATA} ${L_REGDATA}${L_TEMP}
  DetailPrint "HKCU: MRI Version = < ${L_REGDATA} >"

  ReadRegStr ${L_REGDATA} HKCU "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "RootDir_LFN"
  DetailPrint "HKCU: RootDir_LFN = < ${L_REGDATA} >"
  StrCpy ${L_EXPECTED_ROOT} ${L_REGDATA}
  StrCpy ${L_STATUS_ROOT} ""
  IfFileExists "${L_REGDATA}\popfile.pl" root_sfn
  StrCpy ${L_STATUS_ROOT} "not "

root_sfn:
  ReadRegStr ${L_REGDATA} HKCU "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "RootDir_SFN"
  DetailPrint "HKCU: RootDir_SFN = < ${L_REGDATA} >"
  StrCmp ${L_REGDATA} "Not supported" end_HKCU_root
  GetFullPathName /SHORT ${L_EXPECTED_ROOT} ${L_EXPECTED_ROOT}
  StrCmp ${L_EXPECTED_ROOT} ${L_REGDATA} end_HKCU_root
  DetailPrint "^^^^^ Error ^^^^^"
  DetailPrint "Expected Root SFN = < ${L_EXPECTED_ROOT} >"

end_HKCU_root:
  DetailPrint ""

  ReadRegStr ${L_REGDATA} HKCU "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "UserDir_LFN"
  DetailPrint "HKCU: UserDir_LFN = < ${L_REGDATA} >"
  StrCpy ${L_POPFILE_USER} ${L_REGDATA}
  StrCpy ${L_EXPECTED_USER} ${L_REGDATA}
  StrCpy ${L_STATUS_USER} ""
  IfFileExists "${L_REGDATA}\popfile.cfg" user_sfn
  StrCpy ${L_STATUS_USER} "not "

user_sfn:
  ReadRegStr ${L_REGDATA} HKCU "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "UserDir_SFN"
  DetailPrint "HKCU: UserDir_SFN = < ${L_REGDATA} >"
  StrCmp ${L_REGDATA} "Not supported" end_HKCU_user
  GetFullPathName /SHORT ${L_EXPECTED_USER} ${L_EXPECTED_USER}
  StrCmp ${L_EXPECTED_USER} ${L_REGDATA} end_HKCU_user
  DetailPrint "^^^^^ Error ^^^^^"
  DetailPrint "Expected User SFN = < ${L_EXPECTED_USER} >"

end_HKCU_user:
  DetailPrint ""
  DetailPrint "HKCU: popfile.pl  = ${L_STATUS_ROOT}found"
  DetailPrint "HKCU: popfile.cfg = ${L_STATUS_USER}found"
  DetailPrint ""

  IfFileExists  "${L_POPFILE_USER}\backup\*.*" 0 check_env_vars

  DetailPrint "------------------------------------------------------------"
  DetailPrint "POPFile Corpus/Database Backup Data"
  DetailPrint "------------------------------------------------------------"
  DetailPrint ""

  DetailPrint "HKCU: backup locn = < ${L_POPFILE_USER}\backup >"
  DetailPrint ""

  StrCpy ${L_STATUS_USER} ""
  IfFileExists "${L_POPFILE_USER}\backup\backup.ini" ini_status
  StrCpy ${L_STATUS_USER} "not "

ini_status:
  DetailPrint "backup.ini file   = ${L_STATUS_USER}found"

  ReadINIStr ${L_TEMP} "${L_POPFILE_USER}\backup\backup.ini" "FlatFileCorpus" "Corpus"
  StrCmp ${L_TEMP} "" no_flat_folder
  StrCpy ${L_STATUS_USER} ""
  IfFileExists "${L_POPFILE_USER}\backup\${L_TEMP}\*.*" flat_status

no_flat_folder:
  StrCpy ${L_STATUS_USER} "not "

flat_status:
  DetailPrint "Flat-file  folder = ${L_STATUS_USER}found"

  ReadINIStr ${L_TEMP} "${L_POPFILE_USER}\backup\backup.ini" "NonSQLCorpus" "Corpus"
  StrCmp ${L_TEMP} "" no_nonsql_folder
  StrCpy ${L_STATUS_USER} ""
  IfFileExists "${L_POPFILE_USER}\backup\nonsql\${L_TEMP}\*.*" nonsql_status

no_nonsql_folder:
  StrCpy ${L_STATUS_USER} "not "

nonsql_status:
  DetailPrint "Flat / BDB folder = ${L_STATUS_USER}found"

  ReadINIStr ${L_TEMP} "${L_POPFILE_USER}\backup\backup.ini" "OldSQLdatabase" "Database"
  StrCmp ${L_TEMP} "" no_sql_backup
  StrCpy ${L_STATUS_USER} ""
  IfFileExists "${L_POPFILE_USER}\backup\oldsql\${L_TEMP}" sql_backup_status

no_sql_backup:
  StrCpy ${L_STATUS_USER} "not "

sql_backup_status:
  DetailPrint "SQLite DB  backup = ${L_STATUS_USER}found"
  DetailPrint ""
  Goto check_env_vars

simple_HKCU_locns:
  ReadRegStr ${L_REGDATA} HKCU "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "RootDir_LFN"
  DetailPrint "Program folder    = < ${L_REGDATA} >"
  StrCpy ${L_EXPECTED_ROOT} ${L_REGDATA}
  StrCpy ${L_STATUS_ROOT} ""
  IfFileExists "${L_REGDATA}\popfile.pl" simple_root_sfn
  StrCpy ${L_STATUS_ROOT} "not "

simple_root_sfn:
  ReadRegStr ${L_REGDATA} HKCU "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "RootDir_SFN"
  DetailPrint "SFN equivalent    = < ${L_REGDATA} >"
  StrCmp ${L_REGDATA} "Not supported" end_simple_root
  GetFullPathName /SHORT ${L_EXPECTED_ROOT} ${L_EXPECTED_ROOT}
  StrCmp ${L_EXPECTED_ROOT} ${L_REGDATA} end_simple_root
  DetailPrint "^^^^^ Error ^^^^^"
  DetailPrint "Expected value    = < ${L_EXPECTED_ROOT} >"

end_simple_root:
  DetailPrint ""

  ReadRegStr ${L_REGDATA} HKCU "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "UserDir_LFN"
  DetailPrint "User Data folder  = < ${L_REGDATA} >"
  StrCpy ${L_EXPECTED_USER} ${L_REGDATA}
  StrCpy ${L_STATUS_USER} ""
  IfFileExists "${L_REGDATA}\popfile.cfg" simple_user_sfn
  StrCpy ${L_STATUS_USER} "not "

simple_user_sfn:
  ReadRegStr ${L_REGDATA} HKCU "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "UserDir_SFN"
  DetailPrint "SFN equivalent    = < ${L_REGDATA} >"
  StrCmp ${L_REGDATA} "Not supported" end_simple_user
  GetFullPathName /SHORT ${L_EXPECTED_USER} ${L_EXPECTED_USER}
  StrCmp ${L_EXPECTED_USER} ${L_REGDATA} end_simple_user
  DetailPrint "^^^^^ Error ^^^^^"
  DetailPrint "Expected value    = < ${L_EXPECTED_USER} >"

end_simple_user:
  DetailPrint ""
  DetailPrint "popfile.pl file   = ${L_STATUS_ROOT}found"
  DetailPrint "popfile.cfg file  = ${L_STATUS_USER}found"
  DetailPrint ""

check_env_vars:

  ; Check current environment variables

  ReadEnvStr ${L_POPFILE_ROOT}   "POPFILE_ROOT"
  ReadEnvStr ${L_POPFILE_USER}   "POPFILE_USER"
  ReadEnvStr ${L_ITAIJIDICTPATH} "ITAIJIDICTPATH"
  ReadEnvStr ${L_KANWADICTPATH}  "KANWADICTPATH"

  DetailPrint "------------------------------------------------------------"
  DetailPrint "POPFile Environment Variables"
  DetailPrint "------------------------------------------------------------"
  DetailPrint ""

  DetailPrint "'POPFILE_ROOT'    = < ${L_POPFILE_ROOT} >"
  StrCmp ${L_WIN_OS_TYPE} "1" compare_root_var
  StrCmp ${L_POPFILE_ROOT} "" check_user

compare_root_var:
  StrCmp ${L_EXPECTED_ROOT} ${L_POPFILE_ROOT} check_user
  DetailPrint "^^^^^ Error ^^^^^"
  DetailPrint "Expected value    = < ${L_EXPECTED_ROOT} >"
  DetailPrint ""

check_user:
  DetailPrint "'POPFILE_USER'    = < ${L_POPFILE_USER} >"
  StrCmp ${L_WIN_OS_TYPE} "1" compare_user_var
  StrCmp ${L_POPFILE_USER} "" check_vars

compare_user_var:
  StrCmp ${L_EXPECTED_USER} ${L_POPFILE_USER} check_vars
  DetailPrint "^^^^^ Error ^^^^^"
  DetailPrint "Expected value    = < ${L_EXPECTED_USER} >"

check_vars:
  DetailPrint ""

  StrCmp ${L_POPFILE_ROOT} "" check_user_var

  StrCpy ${L_TEMP} ""
  IfFileExists "${L_POPFILE_ROOT}\popfile.pl" root_var_status
  StrCpy ${L_TEMP} "not "

root_var_status:
  StrCmp ${L_DIAG_MODE} "simple" simple_root_status
  DetailPrint "Env: popfile.pl   = ${L_TEMP}found"
  Goto check_user_var

simple_root_status:
  DetailPrint "popfile.pl file   = ${L_TEMP}found"

check_user_var:
  StrCmp ${L_POPFILE_USER} "" 0 user_result
  StrCmp ${L_POPFILE_ROOT} "" check_kakasi blank_line

user_result:
  StrCpy ${L_TEMP} ""
  IfFileExists "${L_POPFILE_USER}\popfile.cfg" user_var_status
  StrCpy ${L_TEMP} "not "

user_var_status:
  StrCmp ${L_DIAG_MODE} "simple" simple_user_status
  DetailPrint "Env: popfile.cfg  = ${L_TEMP}found"
  Goto blank_line

simple_user_status:
  DetailPrint "popfile.cfg file  = ${L_TEMP}found"

blank_line:
  DetailPrint ""

check_kakasi:
  StrCmp ${L_DIAG_MODE} "simple" exit

  DetailPrint "'ITAIJIDICTPATH'  = < ${L_ITAIJIDICTPATH} >"
  DetailPrint "'KANWADICTPATH'   = < ${L_KANWADICTPATH} >"
  DetailPrint ""
  StrCmp ${L_ITAIJIDICTPATH} "" check_other_kakaksi
  StrCpy ${L_TEMP} ""
  IfFileExists "${L_ITAIJIDICTPATH}" display_itaiji_result
  StrCpy ${L_TEMP} "not "

display_itaiji_result:
  DetailPrint "'itaijidict' file = ${L_TEMP}found"

check_other_kakaksi:
  StrCmp ${L_KANWADICTPATH} "" 0 check_kanwa
  StrCmp ${L_ITAIJIDICTPATH} "" exit exit_with_blank_line

check_kanwa:
  StrCpy ${L_TEMP} ""
  IfFileExists "${L_KANWADICTPATH}" display_kanwa_result
  StrCpy ${L_TEMP} "not "

display_kanwa_result:
  DetailPrint "'kanwadict'  file = ${L_TEMP}found"

exit_with_blank_line:
  DetailPrint ""

exit:
  Call GetDateTimeStamp
  Pop ${L_TEMP}
  DetailPrint "------------------------------------------------------------"
  DetailPrint "(report created ${L_TEMP})"
  DetailPrint "------------------------------------------------------------"
  SetDetailsPrint textonly
  DetailPrint "Use right-click menu in the panel below to copy the report to the clipboard"
  SetDetailsPrint none

  !undef L_DIAG_MODE
  !undef L_EXPECTED_ROOT
  !undef L_EXPECTED_USER
  !undef L_ITAIJIDICTPATH
  !undef L_KANWADICTPATH
  !undef L_POPFILE_ROOT
  !undef L_POPFILE_USER
  !undef L_REGDATA
  !undef L_STATUS_ROOT
  !undef L_STATUS_USER
  !undef L_TEMP
  !undef L_WIN_OS_TYPE
  !undef L_WINUSERNAME
  !undef L_WINUSERTYPE

SectionEnd


#--------------------------------------------------------------------------
# Installer Function: IsNT
#
# This function performs a simple check to determine if the utility is running on
# a Win9x system or a more modern OS. (This function is also used by the installer,
# uninstaller, 'Add POPFile User' wizard and runpopfile.exe)
#
# Returns 0 if running on a Win9x system, otherwise returns 1
#
# Inputs:
#         None
#
# Outputs:
#         (top of stack)   - 0 (running on Win9x system) or 1 (running on a more modern OS)
#
# Usage:
#
#         Call IsNT
#         Pop $R0
#
#         ($R0 at this point is 0 if installer is running on a Win9x system)
#
#--------------------------------------------------------------------------

Function IsNT
  Push $0
  ReadRegStr $0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion
  StrCmp $0 "" 0 IsNT_yes
  ; we are not NT.
  Pop $0
  Push 0
  Return

IsNT_yes:
    ; NT!!!
    Pop $0
    Push 1
FunctionEnd


;--------------------------------------------------------------------------
; Remainder of this script is a very small subset of 'pfi-library.nsh'
;--------------------------------------------------------------------------

#--------------------------------------------------------------------------
# Installer Function: GetParameters
#
# Returns the command-line parameters (if any) supplied when the installer was started
#
# Inputs:
#         none
# Outputs:
#         (top of stack)     - all of the parameters supplied on the command line (may be "")
#
# Usage:
#         Call GetParameters
#         Pop $R0
#
#         (if 'setup.exe /outlook' was used to start the installer, $R0 will hold '/outlook')
#
#--------------------------------------------------------------------------

Function GetParameters

  Push $R0
  Push $R1
  Push $R2
  Push $R3

  StrCpy $R2 1
  StrLen $R3 $CMDLINE

  ; Check for quote or space

  StrCpy $R0 $CMDLINE $R2
  StrCmp $R0 '"' 0 +3
  StrCpy $R1 '"'
  Goto loop

  StrCpy $R1 " "

loop:
  IntOp $R2 $R2 + 1
  StrCpy $R0 $CMDLINE 1 $R2
  StrCmp $R0 $R1 get
  StrCmp $R2 $R3 get
  Goto loop

get:
  IntOp $R2 $R2 + 1
  StrCpy $R0 $CMDLINE 1 $R2
  StrCmp $R0 " " get
  StrCpy $R0 $CMDLINE "" $R2

  Pop $R3
  Pop $R2
  Pop $R1
  Exch $R0

FunctionEnd


#--------------------------------------------------------------------------
# Installer Function: GetIEVersion
#
# Uses the registry to determine which version of Internet Explorer is installed.
#
# Inputs:
#         (none)
# Outputs:
#         (top of stack)     - string containing the Internet Explorer version
#                              (1.x, 2.x, 3.x, 4.x, 5.0, 5.5, 6.0). If Internet Explorer
#                              is not installed properly or at all, '?.?' is returned.
#
# Usage:
#         Call GetIEVersion
#         Pop $R0
#
#         ($R0 at this point is "5.0", for example)
#
#--------------------------------------------------------------------------

Function GetIEVersion

  !define L_REGDATA   $R9
  !define L_TEMP      $R8

  Push ${L_REGDATA}
  Push ${L_TEMP}

  ClearErrors
  ReadRegStr ${L_REGDATA} HKLM "Software\Microsoft\Internet Explorer" "Version"
  IfErrors ie_123

  ; Internet Explorer 4.0 or later is installed. The 'Version' value is a string with the
  ; following format: major-version.minor-version.build-number.sub-build-number

  ; According to MSDN, the 'Version' string under 'HKLM\Software\Microsoft\Internet Explorer'
  ; can have the following values:
  ;
  ; Internet Explorer Version     'Version' string
  ;    4.0                          4.71.1712.6
  ;    4.01                         4.72.2106.8
  ;    4.01 SP1                     4.72.3110.3
  ;    5                  	        5.00.2014.0216
  ;    5.5                          5.50.4134.0100
  ;    6.0 Public Preview           6.0.2462.0000
  ;    6.0 Public Preview Refresh   6.0.2479.0006
  ;    6.0 RTM                    	6.0.2600.0000

  StrCpy ${L_TEMP} ${L_REGDATA} 1
  StrCmp ${L_TEMP} "4" ie_4
  StrCpy ${L_REGDATA} ${L_REGDATA} 3
  Goto done

ie_4:
  StrCpy ${L_REGDATA} "4.x"
  Goto done

ie_123:

  ; Older versions of Internet Explorer use the 'IVer' string under the same registry key
  ; (HKLM\Software\Microsoft\Internet Explorer). The 'IVer' string is used as follows:
  ;
  ; Internet Explorer 1.0 for Windows 95 (included with Microsoft Plus! for Windows 95)
  ; uses the value '100'
  ;
  ; Internet Explorer 2.0 for Windows 95 uses the value '102'
  ;
  ; Versions of Internet Explorer that are included with Windows NT 4.0 use the value '101'
  ;
  ; Internet Explorer 3.x updates the 'IVer' string value to '103'

  ClearErrors
  ReadRegStr ${L_REGDATA} HKLM "Software\Microsoft\Internet Explorer" "IVer"
  IfErrors error

  StrCpy ${L_REGDATA} ${L_REGDATA} 3
  StrCmp ${L_REGDATA} '100' ie1
  StrCmp ${L_REGDATA} '101' ie2
  StrCmp ${L_REGDATA} '102' ie2

  StrCpy ${L_REGDATA} '3.x'       ; default to ie3 if not 100, 101, or 102.
  Goto done

ie1:
  StrCpy ${L_REGDATA} '1.x'
  Goto done

ie2:
  StrCpy ${L_REGDATA} '2.x'
  Goto done

error:
  StrCpy ${L_REGDATA} '?.?'

done:
  Pop ${L_TEMP}
  Exch ${L_REGDATA}

  !undef L_REGDATA
  !undef L_TEMP

FunctionEnd


#--------------------------------------------------------------------------
# Macro: GetDateTimeStamp
#
# The installation process and the uninstall process may need a function which returns a
# string with the current date and time (using the current time from Windows). This macro
# makes maintenance easier by ensuring that both processes use identical functions, with
# the only difference being their names.
#
# NOTE:
# The !insertmacro GetDateTimeStamp "" and !insertmacro GetDateTimeStamp "un." commands are
# included in this file so the NSIS script and/or other library functions in 'pfi-library.nsh'
# can use 'Call GetDateTimeStamp' & 'Call un.GetDateTimeStamp' without additional preparation.
#
# Inputs:
#         (none)
# Outputs:
#         (top of stack)     - string with current date and time (eg '08-Dec-2003 @ 23:01:59')
#
#  Usage (after macro has been 'inserted'):
#
#         Call GetDateTimeStamp
#         Pop $R9
#
#         ($R9 now holds a string like '08-Dec-2003 @ 23:01:59')
#--------------------------------------------------------------------------

!macro GetDateTimeStamp UN
  Function ${UN}GetDateTimeStamp

    !define L_DATETIMESTAMP   $R9
    !define L_DAY             $R8
    !define L_MONTH           $R7
    !define L_YEAR            $R6
    !define L_HOURS           $R5
    !define L_MINUTES         $R4
    !define L_SECONDS         $R3

    Push ${L_DATETIMESTAMP}
    Push ${L_DAY}
    Push ${L_MONTH}
    Push ${L_YEAR}
    Push ${L_HOURS}
    Push ${L_MINUTES}
    Push ${L_SECONDS}

    Call ${UN}GetLocalTime
    Pop ${L_YEAR}
    Pop ${L_MONTH}
    Pop ${L_DAY}              ; ignore day of week
    Pop ${L_DAY}
    Pop ${L_HOURS}
    Pop ${L_MINUTES}
    Pop ${L_SECONDS}
    Pop ${L_DATETIMESTAMP}    ; ignore milliseconds

    IntCmp ${L_DAY} 10 +2 0 +2
    StrCpy ${L_DAY} "0${L_DAY}"

    StrCmp ${L_MONTH} 1 0 +3
    StrCpy ${L_MONTH} Jan
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 2 0 +3
    StrCpy ${L_MONTH} Feb
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 3 0 +3
    StrCpy ${L_MONTH} Mar
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 4 0 +3
    StrCpy ${L_MONTH} Apr
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 5 0 +3
    StrCpy ${L_MONTH} May
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 6 0 +3
    StrCpy ${L_MONTH} Jun
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 7 0 +3
    StrCpy ${L_MONTH} Jul
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 8 0 +3
    StrCpy ${L_MONTH} Aug
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 9 0 +3
    StrCpy ${L_MONTH} Sep
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 10 0 +3
    StrCpy ${L_MONTH} Oct
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 11 0 +3
    StrCpy ${L_MONTH} Nov
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 12 0 +2
    StrCpy ${L_MONTH} Dec

  DoubleDigitTime:
    IntCmp ${L_HOURS} 10 +2 0 +2
    StrCpy ${L_HOURS} "0${L_HOURS}"

    IntCmp ${L_MINUTES} 10 +2 0 +2
    StrCpy ${L_MINUTES} "0${L_MINUTES}"

    IntCmp ${L_SECONDS} 10 +2 0 +2
    StrCpy ${L_SECONDS} "0${L_SECONDS}"

    StrCpy ${L_DATETIMESTAMP} "${L_DAY}-${L_MONTH}-${L_YEAR} @ ${L_HOURS}:${L_MINUTES}:${L_SECONDS}"

    Pop ${L_SECONDS}
    Pop ${L_MINUTES}
    Pop ${L_HOURS}
    Pop ${L_YEAR}
    Pop ${L_MONTH}
    Pop ${L_DAY}
    Exch ${L_DATETIMESTAMP}

    !undef L_DATETIMESTAMP
    !undef L_DAY
    !undef L_MONTH
    !undef L_YEAR
    !undef L_HOURS
    !undef L_MINUTES
    !undef L_SECONDS

  FunctionEnd
!macroend

#--------------------------------------------------------------------------
# Installer Function: GetDateTimeStamp
#
# This function is used during the installation process
#--------------------------------------------------------------------------

!insertmacro GetDateTimeStamp ""


#--------------------------------------------------------------------------
# Macro: GetLocalTime
#
# The installation process and the uninstall process may need a function which gets the
# local time from Windows (to generate data and/or time stamps, etc). This macro makes
# maintenance easier by ensuring that both processes use identical functions, with
# the only difference being their names.
#
# Normally this function will be used by a higher level one which returns a suitable string.
#
# NOTE:
# The !insertmacro GetLocalTime "" and !insertmacro GetLocalTime "un." commands are included
# in this file so the NSIS script and/or other library functions in 'pfi-library.nsh' can use
# 'Call GetLocalTime' and 'Call un.GetLocalTime' without additional preparation.
#
# Inputs:
#         (none)
# Outputs:
#         (top of stack)     - year         (4-digits)
#         (top of stack - 1) - month        (1 to 12)
#         (top of stack - 2) - day of week  (0 = Sunday, 6 = Saturday)
#         (top of stack - 3) - day          (1 - 31)
#         (top of stack - 4) - hours        (0 - 23)
#         (top of stack - 5) - minutes      (0 - 59)
#         (top of stack - 6) - seconds      (0 - 59)
#         (top of stack - 7) - milliseconds (0 - 999)
#
#  Usage (after macro has been 'inserted'):
#
#         Call GetLocalTime
#         Pop $Year
#         Pop $Month
#         Pop $DayOfWeek
#         Pop $Day
#         Pop $Hours
#         Pop $Minutes
#         Pop $Seconds
#         Pop $Milliseconds
#--------------------------------------------------------------------------

!macro GetLocalTime UN
  Function ${UN}GetLocalTime

    # Preparing Variables

    Push $1
    Push $2
    Push $3
    Push $4
    Push $5
    Push $6
    Push $7
    Push $8

    # Calling the Function GetLocalTime from Kernel32.dll

    System::Call '*(&i2, &i2, &i2, &i2, &i2, &i2, &i2, &i2) i .r1'
    System::Call 'kernel32::GetLocalTime(i) i(r1)'
    System::Call '*$1(&i2, &i2, &i2, &i2, &i2, &i2, &i2, &i2)(.r8, .r7, .r6, .r5, .r4, .r3, .r2, .r1)'

    # Returning to User

    Exch $8
    Exch
    Exch $7
    Exch
    Exch 2
    Exch $6
    Exch 2
    Exch 3
    Exch $5
    Exch 3
    Exch 4
    Exch $4
    Exch 4
    Exch 5
    Exch $3
    Exch 5
    Exch 6
    Exch $2
    Exch 6
    Exch 7
    Exch $1
    Exch 7

  FunctionEnd
!macroend

#--------------------------------------------------------------------------
# Installer Function: GetLocalTime
#
# This function is used during the installation process
#--------------------------------------------------------------------------

!insertmacro GetLocalTime ""


#--------------------------------------------------------------------------
# End of 'pfidiag.nsi'
#--------------------------------------------------------------------------
