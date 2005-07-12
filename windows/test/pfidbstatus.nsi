#-------------------------------------------------------------------------------------------
#
# pfidbstatus.nsi --- A simple utility to check the status and integrity of POPFile's SQLite
#                     database using the SQLite command-line utility.
#
#                     SQLite 2.x and 3.x database files are not compatible therefore separate
#                     command-line utilities have to be used: sqlite.exe for 2.x format files
#                     and sqlite3.exe for 3.x format files.
#
#                     In order to reduce the size of this simple utility, it is assumed that
#                     the appropriate version of the SQLite utility is available on the target
#                     system (the utility searches for the utility in several likely places).
#
# Copyright (c) 2005  John Graham-Cumming
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
#-------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------
# Usage (one optional parameter):
#
#        pfidbstatus
#  or    pfidbstatus database_filename
#
# Normally 'database_filename' will simply be the default SQLite database filename, popfile.db.
# This utility is intended for use via a shortcut created in the 'User Data' folder by the
# 'POPFile User Data' wizard (setupuser.exe) or by simply double-clicking the utility's icon.
#
# If no parameter is given the utility makes several attempts to find the database file:
#
# (1) If the default SQLite database file (popfile.db) is found in the current folder then
#     it is assumed that this is the database to be checked.
#
# (2) If the default SQLite database file (popfile.db) is found in the same folder as the
#     utility then it is assumed that this is the database to be checked.
#
# (3) If the POPFILE_USER environment variable has been defined and the POPFile configuration
#     file (popfile.cfg) is found in the specified folder then the name and location of the
#     SQLite database file is extracted.
#
# (4) If the POPFILE_USER environment variable has been defined and the specified folder exists
#     but the name and location of the SQLite database file cannot be determined, the utility
#     looks for the default SQLite database file (popfile.db) in that folder.
#
# (5) If the 'User Data' folder location is specified in the Registry, the folder exists and
#     the POPFile configuration file (popfile.cfg) is found there then the name and location
#     of the SQLite database file is extracted.
#
# (6) If the 'User Data' folder location is specified in the Registry and the folder exists
#     but the name and location of the SQLite database file cannot be determined, the utility
#     looks for the default SQLite database file (popfile.db) in that folder.
#
# (7) The search is abandoned if the above steps fail to find the database (the utility exits).
#
#-------------------------------------------------------------------------------------------

  ; This version of the script has been tested with the "NSIS 2.0" compiler (final),
  ; released 7 February 2004, with no "official" NSIS patches applied. This compiler
  ; can be downloaded from http://prdownloads.sourceforge.net/nsis/nsis20.exe?download

  !define ${NSIS_VERSION}_found

  !ifndef v2.0_found
      !warning \
          "$\r$\n\
          $\r$\n***   NSIS COMPILER WARNING:\
          $\r$\n***\
          $\r$\n***   This script has only been tested using the NSIS 2.0 compiler\
          $\r$\n***   and may not work properly with this NSIS ${NSIS_VERSION} compiler\
          $\r$\n***\
          $\r$\n***   The resulting 'installer' program should be tested carefully!\
          $\r$\n$\r$\n"
  !endif

  !undef  ${NSIS_VERSION}_found

  ;--------------------------------------------------------------------------
  ; Symbols used to avoid confusion over where the line breaks occur.
  ;
  ; ${IO_NL} is used for InstallOptions-style 'new line' sequences.
  ; ${MB_NL} is used for MessageBox-style 'new line' sequences.
  ;
  ; (these two constants do not follow the 'C_' naming convention described below)
  ;--------------------------------------------------------------------------

  !define IO_NL   "\r\n"
  !define MB_NL   "$\r$\n"

  ;--------------------------------------------------------------------------
  ; POPFile constants have been given names beginning with 'C_' (eg C_README)
  ;--------------------------------------------------------------------------

  !define C_VERSION   "0.0.2"     ; see 'VIProductVersion' comment below for format details
  !define C_OUTFILE   "pfidbstatus.exe"

  ; The default NSIS caption is "Name Setup" so we override it here

  Name    "POPFile SQLite Database Status Check"
  Caption "POPFile SQLite Database Status Check ${C_VERSION}"

  ; Specify EXE filename and icon for the 'installer'

  OutFile "${C_OUTFILE}"

  Icon "..\POPFileIcon\popfile.ico"

#--------------------------------------------------------------------------
# Use the "Modern User Interface"
#--------------------------------------------------------------------------

  !include "MUI.nsh"

#--------------------------------------------------------------------------
# Include private library functions and macro definitions
#--------------------------------------------------------------------------

  ; Avoid compiler warnings by disabling the functions and definitions we do not use

  !define DBSTATUS

  !include "..\pfi-library.nsh"

#--------------------------------------------------------------------------

  ; 'VIProductVersion' format is X.X.X.X where X is a number in range 0 to 65535
  ; representing the following values: Major.Minor.Release.Build

  VIProductVersion                          "${C_VERSION}.0"

  VIAddVersionKey "ProductName"             "POPFile SQLite Database Status Check"
  VIAddVersionKey "Comments"                "POPFile Homepage: http://getpopfile.org/"
  VIAddVersionKey "CompanyName"             "The POPFile Project"
  VIAddVersionKey "LegalCopyright"          "Copyright (c) 2005  John Graham-Cumming"
  VIAddVersionKey "FileDescription"         "Check the status of POPFile's SQLite database"
  VIAddVersionKey "FileVersion"             "${C_VERSION}"
  VIAddVersionKey "OriginalFilename"        "${C_OUTFILE}"

  VIAddVersionKey "Build Date/Time"         "${__DATE__} @ ${__TIME__}"
  !ifdef C_PFI_LIBRARY_VERSION
    VIAddVersionKey "Build Library Version" "${C_PFI_LIBRARY_VERSION}"
  !endif
  VIAddVersionKey "Build Script"            "${__FILE__}${MB_NL}(${__TIMESTAMP__})"

#----------------------------------------------------------------------------------------

#--------------------------------------------------------------------------
# User Variables (Global)
#--------------------------------------------------------------------------

  ; This script uses 'User Variables' (with names starting with 'G_') to hold GLOBAL data.

  Var G_DATADIR        ; folder path where we expect to find the SQLite database file
  Var G_DATABASE       ; holds name (and possibly path) to the SQLite database

  Var G_SQLITEUTIL     ; name of the appropriate SQLite command-line utility

  Var G_DBFORMAT       ; SQLite database format ('2.x', '3.x' or an error string)
  Var G_DBSCHEMA       ; SQLite database schema ( a number like '12' or an error string)

  Var G_PLS_FIELD_1    ; used to customize language strings
  Var G_PLS_FIELD_2    ; used to customize language strings

#--------------------------------------------------------------------------
# Configure the MUI pages
#--------------------------------------------------------------------------

  ;----------------------------------------------------------------
  ; Interface Settings - General Interface Settings
  ;----------------------------------------------------------------

  ; The icon file for the utility

  !define MUI_ICON                            "..\POPFileIcon\popfile.ico"

  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP              "..\hdr-common.bmp"
  !define MUI_HEADERIMAGE_RIGHT

  ;----------------------------------------------------------------
  ; Interface Settings - Interface Resource Settings
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
  ; Interface Settings - Installer Finish Page Interface Settings
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

  ; Override standard "Installing..." page header

  !define MUI_PAGE_HEADER_TEXT                    "$(DBS_LANG_STD_HDR)"
  !define MUI_PAGE_HEADER_SUBTEXT                 "$(DBS_LANG_STD_SUBHDR)"

  ; Override the standard "Installation complete..." page header

  !define MUI_INSTFILESPAGE_FINISHHEADER_TEXT     "$(DBS_LANG_END_HDR)"
  !define MUI_INSTFILESPAGE_FINISHHEADER_SUBTEXT  "$(DBS_LANG_END_SUBHDR)"

  ; Override the standard "Installation Aborted..." page header

  !define MUI_INSTFILESPAGE_ABORTHEADER_TEXT      "$(DBS_LANG_ABORT_HDR)"
  !define MUI_INSTFILESPAGE_ABORTHEADER_SUBTEXT   "$(DBS_LANG_ABORT_SUBHDR)"

  !insertmacro MUI_PAGE_INSTFILES

#--------------------------------------------------------------------------
# Language Support for the utility
#--------------------------------------------------------------------------

  !insertmacro MUI_LANGUAGE "English"

  ;--------------------------------------------------------------------------
  ; Current build only supports English and uses local strings
  ; instead of language strings from languages\*-pfi.nsh files
  ;--------------------------------------------------------------------------

  !macro DBS_TEXT NAME VALUE
      LangString ${NAME} ${LANG_ENGLISH} "${VALUE}"
  !macroend

  !insertmacro DBS_TEXT DBS_LANG_STD_HDR        "POPFile SQLite Database Status Check"
  !insertmacro DBS_TEXT DBS_LANG_STD_SUBHDR     "Please wait while the database status is checked"

  !insertmacro DBS_TEXT DBS_LANG_END_HDR        "POPFile SQLite Database Status Check"
  !insertmacro DBS_TEXT DBS_LANG_END_SUBHDR     "To save the report, use right-click in the message window,${MB_NL}copy to the clipboard then paste the report into a text file"

  !insertmacro DBS_TEXT DBS_LANG_ABORT_HDR      "POPFile SQLite Database Status Check Failed"
  !insertmacro DBS_TEXT DBS_LANG_ABORT_SUBHDR   "Problem detected - see error report in window below"

  !insertmacro DBS_TEXT DBS_LANG_RIGHTCLICK     "Right-click in the window below to copy the report to the clipboard"

  !insertmacro DBS_TEXT DBS_LANG_DBNOTFOUND_1   "Unable to find the '$G_DATABASE' file (the SQLite database)"
  !insertmacro DBS_TEXT DBS_LANG_DBNOTFOUND_2   "(looked in '$G_PLS_FIELD_1' folder)"
  !insertmacro DBS_TEXT DBS_LANG_DBNOTFOUND     "$(DBS_LANG_DBNOTFOUND_1)${MB_NL}${MB_NL}$(DBS_LANG_DBNOTFOUND_2)"

  !insertmacro DBS_TEXT DBS_LANG_NODBPARAM_1    "No SQLite database filename specified."
  !insertmacro DBS_TEXT DBS_LANG_NODBPARAM_2    "Usage: $G_PLS_FIELD_1 <database>"
  !insertmacro DBS_TEXT DBS_LANG_NODBPARAM_3    " e.g.  $G_PLS_FIELD_1 popfile.db"
  !insertmacro DBS_TEXT DBS_LANG_NODBPARAM_4    " e.g.  $G_PLS_FIELD_1 C:\Program Files\POPFile\popfile.db"
  !insertmacro DBS_TEXT DBS_LANG_NODBPARAM      "$(DBS_LANG_NODBPARAM_1)${MB_NL}${MB_NL}$(DBS_LANG_NODBPARAM_2)${MB_NL}$(DBS_LANG_NODBPARAM_3)${MB_NL}$(DBS_LANG_NODBPARAM_4)"

  !insertmacro DBS_TEXT DBS_LANG_OPENERR        "unable to open file"

  !insertmacro DBS_TEXT DBS_LANG_DBIDENTIFIED   "The '$G_DATABASE' file is a SQLite $G_DBFORMAT database"

  !insertmacro DBS_TEXT DBS_LANG_UTILNOTFOUND_1 "Unable to find the '$G_SQLITEUTIL' file (the SQLite $G_DBFORMAT utility)"
  !insertmacro DBS_TEXT DBS_LANG_UTILNOTFOUND_2 "(looked in '$G_PLS_FIELD_1' folder, 'POPFILE_ROOT' and Registry)"
  !insertmacro DBS_TEXT DBS_LANG_UTILNOTFOUND   "$(DBS_LANG_UTILNOTFOUND_1)${MB_NL}${MB_NL}$(DBS_LANG_UTILNOTFOUND_2)"

  !insertmacro DBS_TEXT DBS_LANG_STARTERROR     "Unable to start the '$G_SQLITEUTIL' utility"
  !insertmacro DBS_TEXT DBS_LANG_VERSIONERROR   "Error: Unable to determine the '$G_SQLITEUTIL' utility's version number"

  !insertmacro DBS_TEXT DBS_LANG_UNKNOWNFMT_1   "Unable to tell if '$G_DATABASE' is a SQLite database file"
  !insertmacro DBS_TEXT DBS_LANG_UNKNOWNFMT_2   "File format not known $G_DBFORMAT"
  !insertmacro DBS_TEXT DBS_LANG_UNKNOWNFMT_3   "Please shutdown POPFile before using this utility"
  !insertmacro DBS_TEXT DBS_LANG_UNKNOWNFORMAT  "$(DBS_LANG_UNKNOWNFMT_1)${MB_NL}${MB_NL}$(DBS_LANG_UNKNOWNFMT_2)${MB_NL}${MB_NL}$(DBS_LANG_UNKNOWNFMT_3)"

  !insertmacro DBS_TEXT DBS_LANG_NOSQLITE_1     "Error: POPFile not configured to use SQLite"
  !insertmacro DBS_TEXT DBS_LANG_NOSQLITE_2     "(see the configuration data in '$G_DATADIR')"
  !insertmacro DBS_TEXT DBS_LANG_NOSQLITE       "$(DBS_LANG_NOSQLITE_1)${MB_NL}${MB_NL}$(DBS_LANG_NOSQLITE_2))"

  !insertmacro DBS_TEXT DBS_LANG_CURRENT_DIR    "Current folder: $INSTDIR"
  !insertmacro DBS_TEXT DBS_LANG_UTILITY_DIR    "Utility folder: $EXEDIR"

  !insertmacro DBS_TEXT DBS_LANG_COMMANDLINE    "Command line  : $G_DATABASE"
  !insertmacro DBS_TEXT DBS_LANG_NOCOMMANDLINE  "Searching for database because no command-line parameter supplied"

  !insertmacro DBS_TEXT DBS_LANG_TRY_ENV_VAR    "Trying to find database using POPFILE_USER environment variable"
  !insertmacro DBS_TEXT DBS_LANG_ENV_VAR_VAL    "'User Data' folder (from POPFILE_USER) = $G_DATADIR"
  !insertmacro DBS_TEXT DBS_LANG_NOT_ENV_VAR    "Unable to find database using POPFILE_USER environment variable"

  !insertmacro DBS_TEXT DBS_LANG_TRY_HKCU_REG   "Trying to find database using registry data (HKCU)"
  !insertmacro DBS_TEXT DBS_LANG_HKCU_REG_VAL   "'User Data' folder (from HKCU entry) = $G_DATADIR"
  !insertmacro DBS_TEXT DBS_LANG_NOT_HKCU_REG   "Unable to find database using registry data (HKCU)"

  !insertmacro DBS_TEXT DBS_LANG_TRY_CURRENT    "Trying to find database (popfile.db) in current folder"
  !insertmacro DBS_TEXT DBS_LANG_NOT_CURRENT    "Unable to find database (popfile.db) in current folder"

  !insertmacro DBS_TEXT DBS_LANG_TRY_EXEDIR     "Trying to find database (popfile.db) in same folder as utility"
  !insertmacro DBS_TEXT DBS_LANG_NOT_EXEDIR     "Unable to find database (popfile.db) in same folder as utility"

  !insertmacro DBS_TEXT DBS_LANG_SEARCHING      "..."
  !insertmacro DBS_TEXT DBS_LANG_FOUNDIT        "... found it!"

  !insertmacro DBS_TEXT DBS_LANG_DIRNOTFILE     "Error: '$G_DATABASE' is a folder, not a database file"
  !insertmacro DBS_TEXT DBS_LANG_CHECKTHISONE   "POPFile database found ($G_DATABASE)"

  !insertmacro DBS_TEXT DBS_LANG_DBFORMAT       "Database is in SQLite $G_DBFORMAT format"
  !insertmacro DBS_TEXT DBS_LANG_DBFORMATSCHEMA "$(DBS_LANG_DBFORMAT) and uses POPFile schema version $G_DBSCHEMA"
  !insertmacro DBS_TEXT DBS_LANG_DBSCHEMAERROR  "SQLite error detected when extracting POPFile schema version:"

  !insertmacro DBS_TEXT DBS_LANG_SQLITEUTIL     "SQLite $G_PLS_FIELD_2 utility found in $G_PLS_FIELD_1"
  !insertmacro DBS_TEXT DBS_LANG_SQLITECOMMAND  "Result of running the 'pragma integrity_check;' command:"
  !insertmacro DBS_TEXT DBS_LANG_SQLITEDBISOK   "The POPFile database has passed the SQLite integrity check!"

  !insertmacro DBS_TEXT DBS_LANG_SQLITEFAIL     "Error: The SQLite utility returned error code $G_PLS_FIELD_1"

  ;------------------------------------------------------------------------
  ; Macro to make it easy to delete the last row in the details window
  ;------------------------------------------------------------------------

  !macro DELETE_LAST_ENTRY
      Push $0
      Call GetDetailViewItemCount
      Pop $0
      IntOp $0 $0 - 1                       ; decrement to get the right index of last entry
      Push $0
      Call DeleteDetailViewItem
      Pop $0
  !macroend

  ;--------------------------------------------------------------------------

;------------------------------
; Section: CheckSQLiteDatabase
;------------------------------

Section CheckSQLiteDatabase

  !define L_TEMP    $R9

  SetDetailsPrint textonly
  DetailPrint "$(DBS_LANG_RIGHTCLICK)"
  SetDetailsPrint listonly

  DetailPrint "------------------------------------------------------------"
  DetailPrint "$(^Name) v${C_VERSION}"
  DetailPrint "------------------------------------------------------------"
  DetailPrint ""

  ; Set OutPath to the working directory (to cope with cases where no database path is supplied)

  GetFullPathName $INSTDIR ".\"

  SetDetailsPrint none
  SetOutPath "$INSTDIR"
  SetDetailsPrint listonly

  DetailPrint "$(DBS_LANG_CURRENT_DIR)"
  DetailPrint "$(DBS_LANG_UTILITY_DIR)"

  ; The command-line can be used to supply the name of a database file in the current folder
  ; (e.g. mydata.db), a relative filename for the database file (e.g. ..\data\mydata.db) or
  ; the full pathname for the database file (D:\Application Data\POPFile\popfile.db).

  Call PFI_GetParameters
  Pop $G_DATABASE
  StrCmp $G_DATABASE "" check_currentdir
  DetailPrint "$(DBS_LANG_COMMANDLINE)"
  Goto lookforfile

check_currentdir:
  DetailPrint ""
  DetailPrint "$(DBS_LANG_NOCOMMANDLINE)"
  DetailPrint ""

  DetailPrint "$(DBS_LANG_TRY_CURRENT)$(DBS_LANG_SEARCHING)"
  StrCpy $G_DATABASE "popfile.db"
  IfFileExists "$INSTDIR\$G_DATABASE" found_in_current
  !insertmacro DELETE_LAST_ENTRY
  DetailPrint "$(DBS_LANG_NOT_CURRENT)"

  DetailPrint "$(DBS_LANG_TRY_EXEDIR)$(DBS_LANG_SEARCHING)"
  IfFileExists "$EXEDIR\$G_DATABASE" found_in_exedir
  !insertmacro DELETE_LAST_ENTRY
  DetailPrint "$(DBS_LANG_NOT_EXEDIR)"

  DetailPrint "$(DBS_LANG_TRY_ENV_VAR)$(DBS_LANG_SEARCHING)"
  ReadEnvStr $G_DATADIR "POPFILE_USER"
  StrCmp $G_DATADIR "" try_registry
  Push $G_DATADIR
  Call PFI_GetCompleteFPN
  Pop $G_DATADIR
  !insertmacro DELETE_LAST_ENTRY
  DetailPrint "$(DBS_LANG_ENV_VAR_VAL)"
  IfFileExists "$G_DATADIR\*.*" 0 try_registry
  Push $G_DATADIR
  Call PFI_GetSQLdbPathName
  Pop $G_DATABASE
  StrCmp $G_DATABASE "Not SQLite" sqlite_not_used
  StrCmp $G_DATABASE "" 0 check_env_file_exists
  StrCpy $G_DATABASE "$G_DATADIR\popfile.db"

check_env_file_exists:
  IfFileExists "$G_DATABASE" 0 try_registry
  !insertmacro DELETE_LAST_ENTRY
  DetailPrint "$(DBS_LANG_TRY_ENV_VAR)$(DBS_LANG_FOUNDIT)"
  Goto split_path

try_registry:
  !insertmacro DELETE_LAST_ENTRY
  DetailPrint "$(DBS_LANG_NOT_ENV_VAR)"
  DetailPrint "$(DBS_LANG_TRY_HKCU_REG)$(DBS_LANG_SEARCHING)"
  ReadRegStr $G_DATADIR HKCU "Software\POPFile Project\POPFile\MRI" "UserDir_LFN"
  StrCmp $G_DATADIR "" abandon_search
  !insertmacro DELETE_LAST_ENTRY
  DetailPrint "$(DBS_LANG_HKCU_REG_VAL)"
  IfFileExists "$G_DATADIR\*.*" 0 abandon_search
  Push $G_DATADIR
  Call PFI_GetSQLdbPathName
  Pop $G_DATABASE
  StrCmp $G_DATABASE "Not SQLite" sqlite_not_used
  StrCmp $G_DATABASE "" 0 check_reg_file_exists
  StrCpy $G_DATABASE "$G_DATADIR\popfile.db"

check_reg_file_exists:
  IfFileExists "$G_DATABASE" 0 abandon_search
  !insertmacro DELETE_LAST_ENTRY
  DetailPrint "$(DBS_LANG_TRY_HKCU_REG)$(DBS_LANG_FOUNDIT)"
  Goto split_path

sqlite_not_used:
  DetailPrint ""
  DetailPrint "$(DBS_LANG_NOSQLITE_1)"
  DetailPrint "$(DBS_LANG_NOSQLITE_2)"
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(DBS_LANG_NOSQLITE)"
  Goto error_exit

abandon_search:
  !insertmacro DELETE_LAST_ENTRY
  DetailPrint "$(DBS_LANG_NOT_HKCU_REG)"
  StrCpy $G_PLS_FIELD_1 "$INSTDIR"
  Goto give_up

found_in_current:
  !insertmacro DELETE_LAST_ENTRY
  DetailPrint "$(DBS_LANG_TRY_CURRENT)$(DBS_LANG_FOUNDIT)"
  Goto lookforfile

found_in_exedir:
  !insertmacro DELETE_LAST_ENTRY
  DetailPrint "$(DBS_LANG_TRY_EXEDIR)$(DBS_LANG_FOUNDIT)"
  StrCpy $INSTDIR $EXEDIR

lookforfile:
  Push $INSTDIR
  Push $G_DATABASE
  Call PFI_GetDataPath
  Pop $G_DATABASE

split_path:
  Push $G_DATABASE
  Call PFI_GetParent
  Pop $G_PLS_FIELD_1
  StrLen ${L_TEMP} $G_PLS_FIELD_1
  IntOp ${L_TEMP} ${L_TEMP} + 1
  StrCpy $G_DATABASE $G_DATABASE "" ${L_TEMP}
  IfFileExists "$G_PLS_FIELD_1\$G_DATABASE" continue

give_up:
  DetailPrint ""
  DetailPrint "$(DBS_LANG_DBNOTFOUND_1)"
  DetailPrint "$(DBS_LANG_DBNOTFOUND_2)"
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(DBS_LANG_DBNOTFOUND)"

  ; Ensure the correct program name appears in the 'usage' message added to the log.
  ; The first system call gets the full pathname (returned in $R0) and the second call
  ; extracts the filename (and possibly the extension) part (result returned in $R1)

  Push $R0
  Push $R1
  System::Call 'kernel32::GetModuleFileNameA(i 0, t .R0, i 1024)'
  System::Call 'comdlg32::GetFileTitleA(t R0, t .R1, i 1024)'
  StrCpy $G_PLS_FIELD_1 $R1
  Pop $R1
  Pop $R0

  DetailPrint ""
  DetailPrint "$(DBS_LANG_NODBPARAM_2)"
  DetailPrint "$(DBS_LANG_NODBPARAM_3)"
  DetailPrint "$(DBS_LANG_NODBPARAM_4)"
  Goto error_exit

continue:
  StrCpy $G_DATABASE "$G_PLS_FIELD_1\$G_DATABASE"
  IfFileExists "$G_DATABASE\*.*" dir_not_file
  DetailPrint ""
  DetailPrint "$(DBS_LANG_CHECKTHISONE)"
  Push $G_DATABASE
  Call PFI_GetSQLiteFormat
  Pop $G_DBFORMAT
  StrCpy $G_SQLITEUTIL "sqlite.exe"
  StrCmp $G_DBFORMAT "2.x" look_for_util
  StrCpy $G_SQLITEUTIL "sqlite3.exe"
  StrCmp $G_DBFORMAT "3.x" look_for_util
  Push $G_DATABASE
  Call PFI_GetParent
  Pop $G_PLS_FIELD_1
  StrLen ${L_TEMP} $G_PLS_FIELD_1
  IntOp ${L_TEMP} ${L_TEMP} + 1
  StrCpy $G_DATABASE $G_DATABASE "" ${L_TEMP}
  DetailPrint ""
  DetailPrint "$(DBS_LANG_UNKNOWNFMT_1)"
  DetailPrint ""
  DetailPrint "$(DBS_LANG_UNKNOWNFMT_2)"
  DetailPrint ""
  DetailPrint "$(DBS_LANG_UNKNOWNFMT_3)"
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(DBS_LANG_UNKNOWNFORMAT)"
  Goto error_exit

look_for_util:
  StrCpy ${L_TEMP} "$EXEDIR"
  StrCpy $G_PLS_FIELD_1 "$EXEDIR"
  IfFileExists "${L_TEMP}\$G_SQLITEUTIL" run_it

  ; It is not in "our" folder so try looking in the usual places

  ReadEnvStr ${L_TEMP} "POPFILE_ROOT"
  StrCmp ${L_TEMP} "" try_HKCU
  Push ${L_TEMP}
  Call PFI_GetCompleteFPN
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" try_HKCU
  IfFileExists "${L_TEMP}\$G_SQLITEUTIL" run_it

try_HKCU:
  ReadRegStr ${L_TEMP} HKCU "Software\POPFile Project\POPFile\MRI" "RootDir_LFN"
  StrCmp ${L_TEMP} "" try_HKLM
  IfFileExists "${L_TEMP}\$G_SQLITEUTIL" run_it

try_HKLM:
  ReadRegStr ${L_TEMP} HKLM "Software\POPFile Project\POPFile\MRI" "RootDir_LFN"
  StrCmp ${L_TEMP} "" no_util
  IfFileExists "${L_TEMP}\$G_SQLITEUTIL" run_it

no_util:
  DetailPrint ""
  DetailPrint "$(DBS_LANG_DBIDENTIFIED)"
  DetailPrint ""
  DetailPrint "$(DBS_LANG_UTILNOTFOUND_1)"
  DetailPrint "$(DBS_LANG_UTILNOTFOUND_2)"
  MessageBox MB_OK|MB_ICONEXCLAMATION \
      "$(DBS_LANG_DBIDENTIFIED)\
      ${MB_NL}${MB_NL}${MB_NL}\
      $(DBS_LANG_UTILNOTFOUND)"
  Goto error_exit

run_it:
  StrCpy $G_PLS_FIELD_1 ${L_TEMP}
  nsExec::ExecToStack '"$G_PLS_FIELD_1\$G_SQLITEUTIL" -version'
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "error" start_error
  StrCmp ${L_TEMP} "timeout" start_error
  IntCmp ${L_TEMP} 1 0 version_error version_error
  Call PFI_TrimNewlines
  Pop $G_PLS_FIELD_2
  StrCpy $G_PLS_FIELD_2 "v$G_PLS_FIELD_2"
  DetailPrint ""
  DetailPrint "$(DBS_LANG_SQLITEUTIL)"
  nsExec::ExecToStack '"$G_PLS_FIELD_1\$G_SQLITEUTIL" "$G_DATABASE" "select version from popfile;"'
  Pop ${L_TEMP}
  Call PFI_TrimNewlines
  Pop $G_DBSCHEMA
  StrCmp ${L_TEMP} "0" schema_ok
  StrCpy $G_DBSCHEMA "($G_DBSCHEMA)"
  DetailPrint ""
  DetailPrint "$(DBS_LANG_DBFORMAT)"
  DetailPrint ""
  DetailPrint "$(DBS_LANG_DBSCHEMAERROR)"
  DetailPrint "$G_DBSCHEMA"
  Goto check_integrity

schema_ok:
  DetailPrint ""
  DetailPrint "$(DBS_LANG_DBFORMATSCHEMA)"

check_integrity:
  DetailPrint ""
  DetailPrint "$(DBS_LANG_SQLITECOMMAND)"
  nsExec::ExecToLog '"$G_PLS_FIELD_1\$G_SQLITEUTIL" "$G_DATABASE" "pragma integrity_check;"'
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "error" start_error
  StrCmp ${L_TEMP} "timeout" start_error
  IntCmp ${L_TEMP} 0 exit
  StrCpy $G_PLS_FIELD_1 ${L_TEMP}
  DetailPrint ""
  DetailPrint "$(DBS_LANG_SQLITEFAIL)"
  Goto error_exit

dir_not_file:
  DetailPrint ""
  DetailPrint "$(DBS_LANG_DIRNOTFILE)"
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(DBS_LANG_DIRNOTFILE)"
  Goto error_exit

version_error:
  StrCpy $G_PLS_FIELD_2 ""
  DetailPrint ""
  DetailPrint "$(DBS_LANG_SQLITEUTIL)"
  DetailPrint ""
  DetailPrint "$(DBS_LANG_VERSIONERROR)"
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(DBS_LANG_VERSIONERROR)"
  Goto error_exit

start_error:
  DetailPrint ""
  DetailPrint "$(DBS_LANG_STARTERROR)"
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(DBS_LANG_STARTERROR)"

error_exit:
  Call PFI_GetDateTimeStamp
  Pop ${L_TEMP}
  DetailPrint ""
  DetailPrint "------------------------------------------------------------"
  DetailPrint "(status check failed ${L_TEMP})"
  DetailPrint "------------------------------------------------------------"
  SetDetailsPrint none
  Abort

exit:
  DetailPrint ""
  DetailPrint "$(DBS_LANG_SQLITEDBISOK)"
  Call PFI_GetDateTimeStamp
  Pop ${L_TEMP}
  DetailPrint ""
  DetailPrint "------------------------------------------------------------"
  DetailPrint "(report finished ${L_TEMP})"
  DetailPrint "------------------------------------------------------------"
  SetDetailsPrint none

  !undef L_TEMP

SectionEnd

#--------------------------------------------------------------------------
# Functions used to manipulate the contents of the details view
#--------------------------------------------------------------------------

  ;------------------------------------------------------------------------
  ; Constants used when accessing the details view
  ;------------------------------------------------------------------------

  !define C_LVM_GETITEMCOUNT        0x1004
  !define C_LVM_DELETEITEM          0x1008

#--------------------------------------------------------------------------
# Installer Function: GetDetailViewItemCount
#
# Returns the number of rows in the details view (on the INSTFILES page)
#
# Inputs:
#         none
# Outputs:
#         (top of stack)     - number of rows in the details view window
#
# Usage:
#
#         Call GetDetailViewItemCount
#         Pop $R9
#
#--------------------------------------------------------------------------

Function GetDetailViewItemCount
  Push $1
  FindWindow $1 "#32770" "" $HWNDPARENT
  GetDlgItem $1 $1 0x3F8                  ; This is the Control ID of the details view
  SendMessage $1 ${C_LVM_GETITEMCOUNT} 0 0 $1
  Exch $1
FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: DeleteDetailViewItem
#
# Deletes one row from the details view (on the INSTFILES page)
#
# Inputs:
#         (top of stack)     - index number of the row to be deleted
# Outputs:
#         none
#
# Usage:
#
#         Push $R9
#         Call DeleteDetailViewItem
#
#--------------------------------------------------------------------------

Function DeleteDetailViewItem
  Exch $0
  Push $1
  FindWindow $1 "#32770" "" $HWNDPARENT
  GetDlgItem $1 $1 0x3F8                  ; This is the Control ID of the details view
  SendMessage $1 ${C_LVM_DELETEITEM} $0 0
  Pop $1
  Pop $0
FunctionEnd

;--------------------------
; End of 'pfidbstatus.nsi'
;--------------------------
