#-------------------------------------------------------------------------------------------
#
# pfidbanalyser.nsi --- A utility to display the output from the SQLite Database Analyser
#                       command-line utility. The report contains a lot of technical detail
#                       about the structure of the specified SQLite database file.
#
#                       SQLite 2.x and 3.x database files are not compatible therefore
#                       separate command-line utilities have to be used:
#
#                       (a) sqlite_analyzer.exe for 2.x format files, and
#                       (b) sqlite3_analyzer.exe for 3.x format files
#
#                       Since the current version of POPFile uses SQLite 2.x format database
#                       files, only SQLite 2.x format files are fully supported in this
#                       release. However if the database is in SQLite 3.x format a search
#                       for the SQLite 3.x version of the analyser utility will be made.
#
# Copyright (c) 2006  John Graham-Cumming
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
#-------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------
# Usage (one optional parameter):
#
#        pfidbanalyser
#  or    pfidbanalyser database_filename
#
# Normally 'database_filename' will simply be the default SQLite database filename, popfile.db.
#
# If no parameter is given the utility makes several attempts to find the database file:
#
# (1) If the default SQLite database file (popfile.db) is found in the current folder then
#     it is assumed that this is the database to be analysed.
#
# (2) If the default SQLite database file (popfile.db) is found in the same folder as the
#     utility then it is assumed that this is the database to be analysed.
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
# NOTE: Priority is given to the current folder and the folder containing the utility to make
#       it easy to use the utility (e.g. just put it in the same folder as the popfile.db file)
#
#-------------------------------------------------------------------------------------------

  ;--------------------------------------------------------------------------
  ; Select LZMA compression (to generate smallest EXE file)
  ;--------------------------------------------------------------------------

  SetCompressor lzma

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

  !define C_VERSION   "0.0.6"     ; see 'VIProductVersion' comment below for format details
  !define C_OUTFILE   "pfidbanalyser.exe"

  ; The default NSIS caption is "Name Setup" so we override it here

  Name    "POPFile SQLite Database Analyser (stand-alone)"
  Caption "POPFile SQLite Database Analyser ${C_VERSION} (stand-alone)"

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

  !define DBANALYSER

  !include "..\pfi-library.nsh"

#--------------------------------------------------------------------------

  ; 'VIProductVersion' format is X.X.X.X where X is a number in range 0 to 65535
  ; representing the following values: Major.Minor.Release.Build

  VIProductVersion                          "${C_VERSION}.0"

  VIAddVersionKey "ProductName"             "POPFile SQLite Database Analyser (stand-alone version)"
  VIAddVersionKey "Comments"                "POPFile Homepage: http://getpopfile.org/"
  VIAddVersionKey "CompanyName"             "The POPFile Project"
  VIAddVersionKey "LegalCopyright"          "Copyright (c) 2006  John Graham-Cumming"
  VIAddVersionKey "FileDescription"         "Technical analysis of POPFile SQLite database"
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

  Var G_WINUSERNAME    ; current Windows user login name

  Var G_DATADIR        ; folder path where we expect to find the SQLite database file
  Var G_DATABASE       ; holds name (and possibly path) to the SQLite database

  Var G_SQLITEINFO     ; name of the appropriate SQLite analyser command-line utility

  Var G_DBFORMAT       ; SQLite database format ('2.x', '3.x' or an error string)

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

  !define MUI_PAGE_HEADER_TEXT                    "$(DBA_LANG_STD_HDR)"
  !define MUI_PAGE_HEADER_SUBTEXT                 "$(DBA_LANG_STD_SUBHDR)"

  ; Override the standard "Installation complete..." page header

  !define MUI_INSTFILESPAGE_FINISHHEADER_TEXT     "$(DBA_LANG_END_HDR)"
  !define MUI_INSTFILESPAGE_FINISHHEADER_SUBTEXT  "$(DBA_LANG_END_SUBHDR)"

  ; Override the standard "Installation Aborted..." page header

  !define MUI_INSTFILESPAGE_ABORTHEADER_TEXT      "$(DBA_LANG_ABORT_HDR)"
  !define MUI_INSTFILESPAGE_ABORTHEADER_SUBTEXT   "$(DBA_LANG_ABORT_SUBHDR)"

  !insertmacro MUI_PAGE_INSTFILES

#--------------------------------------------------------------------------
# Language Support for the utility
#--------------------------------------------------------------------------

  !insertmacro MUI_LANGUAGE "English"

  ;--------------------------------------------------------------------------
  ; Current build only supports English and uses local strings
  ; instead of language strings from languages\*-pfi.nsh files
  ;--------------------------------------------------------------------------

  !macro DBA_TEXT NAME VALUE
      LangString ${NAME} ${LANG_ENGLISH} "${VALUE}"
  !macroend

  !insertmacro DBA_TEXT DBA_LANG_STD_HDR        "POPFile SQLite Database Analyser"
  !insertmacro DBA_TEXT DBA_LANG_STD_SUBHDR     "Please wait while the database is analysed"

  !insertmacro DBA_TEXT DBA_LANG_END_HDR        "POPFile SQLite Database Analyser"
  !insertmacro DBA_TEXT DBA_LANG_END_SUBHDR     "To save the report, use right-click in the message window,${MB_NL}copy to the clipboard then paste the report into a text file"

  !insertmacro DBA_TEXT DBA_LANG_ABORT_HDR      "POPFile SQLite Database Analysis Failed"
  !insertmacro DBA_TEXT DBA_LANG_ABORT_SUBHDR   "Problem detected - see error report in window below"

  !insertmacro DBA_TEXT DBA_LANG_RIGHTCLICK     "Right-click in the window below to copy the report to the clipboard"

  !insertmacro DBA_TEXT DBA_LANG_NOCONFIGDATA   "POPFile is not configured for the '$G_WINUSERNAME' user"

  !insertmacro DBA_TEXT DBA_LANG_DBNOTFOUND_1   "Unable to find the '$G_DATABASE' file (the SQLite database)"
  !insertmacro DBA_TEXT DBA_LANG_DBNOTFOUND_2   "(looked in '$G_PLS_FIELD_1' folder)"
  !insertmacro DBA_TEXT DBA_LANG_DBNOTFOUND     "$(DBA_LANG_DBNOTFOUND_1)${MB_NL}${MB_NL}$(DBA_LANG_DBNOTFOUND_2)"

  !insertmacro DBA_TEXT DBA_LANG_NODBPARAM_1    "No SQLite database filename specified."
  !insertmacro DBA_TEXT DBA_LANG_NODBPARAM_2    "Usage: $G_PLS_FIELD_1 <database>"
  !insertmacro DBA_TEXT DBA_LANG_NODBPARAM_3    " e.g.  $G_PLS_FIELD_1 popfile.db"
  !insertmacro DBA_TEXT DBA_LANG_NODBPARAM_4    " e.g.  $G_PLS_FIELD_1 C:\Program Files\POPFile\popfile.db"
  !insertmacro DBA_TEXT DBA_LANG_NODBPARAM_5    " e.g.  $G_PLS_FIELD_1 /REGISTRY"
  !insertmacro DBA_TEXT DBA_LANG_NODBPARAM      "$(DBA_LANG_NODBPARAM_1)${MB_NL}${MB_NL}$(DBA_LANG_NODBPARAM_2)${MB_NL}$(DBA_LANG_NODBPARAM_3)${MB_NL}$(DBA_LANG_NODBPARAM_4)${MB_NL}$(DBA_LANG_NODBPARAM_5)"

  !insertmacro DBA_TEXT DBA_LANG_OPENERR        "unable to open file"

  !insertmacro DBA_TEXT DBA_LANG_DBIDENTIFIED   "The database file is a SQLite $G_DBFORMAT database"

  !insertmacro DBA_TEXT DBA_LANG_UTILNOTFOUND_1 "Unable to find the '$G_SQLITEINFO' file (the SQLite $G_DBFORMAT database analyser)"
  !insertmacro DBA_TEXT DBA_LANG_UTILNOTFOUND_2 "(looked in '$G_PLS_FIELD_1' folder, 'POPFILE_ROOT' and Registry)"
  !insertmacro DBA_TEXT DBA_LANG_UTILNOTFOUND   "$(DBA_LANG_UTILNOTFOUND_1)${MB_NL}${MB_NL}$(DBA_LANG_UTILNOTFOUND_2)"

  !insertmacro DBA_TEXT DBA_LANG_STARTERROR     "Unable to start the '$G_SQLITEINFO' utility"

  !insertmacro DBA_TEXT DBA_LANG_UNKNOWNFMT_1   "Unable to tell if '$G_DATABASE' is a SQLite database file"
  !insertmacro DBA_TEXT DBA_LANG_UNKNOWNFMT_2   "File format not known $G_DBFORMAT"
  !insertmacro DBA_TEXT DBA_LANG_UNKNOWNFMT_3   "Please shutdown POPFile before using this utility"
  !insertmacro DBA_TEXT DBA_LANG_UNKNOWNFORMAT  "$(DBA_LANG_UNKNOWNFMT_1)${MB_NL}${MB_NL}$(DBA_LANG_UNKNOWNFMT_2)${MB_NL}${MB_NL}$(DBA_LANG_UNKNOWNFMT_3)"

  !insertmacro DBA_TEXT DBA_LANG_NOSQLITE_1     "Error: POPFile not configured to use SQLite"
  !insertmacro DBA_TEXT DBA_LANG_NOSQLITE_2     "(see the configuration data in '$G_DATADIR')"
  !insertmacro DBA_TEXT DBA_LANG_NOSQLITE       "$(DBA_LANG_NOSQLITE_1)${MB_NL}${MB_NL}$(DBA_LANG_NOSQLITE_2))"

  !insertmacro DBA_TEXT DBA_LANG_CURRENT_USER   "Current user  : $G_WINUSERNAME"
  !insertmacro DBA_TEXT DBA_LANG_CURRENT_DIR    "Current folder: $INSTDIR"
  !insertmacro DBA_TEXT DBA_LANG_UTILITY_DIR    "Utility folder: $EXEDIR"

  !insertmacro DBA_TEXT DBA_LANG_COMMANDLINE    "Command line  : $G_DATABASE"
  !insertmacro DBA_TEXT DBA_LANG_NOCOMMANDLINE  "Searching for database because no command-line parameter supplied"

  !insertmacro DBA_TEXT DBA_LANG_TRY_ENV_VAR    "Trying to find database using POPFILE_USER environment variable"
  !insertmacro DBA_TEXT DBA_LANG_ENV_VAR_VAL    "'User Data' folder (from POPFILE_USER) = $G_DATADIR"
  !insertmacro DBA_TEXT DBA_LANG_NOT_ENV_VAR    "Unable to find database using POPFILE_USER environment variable"

  !insertmacro DBA_TEXT DBA_LANG_TRY_HKCU_REG   "Trying to find database using registry data (HKCU)"
  !insertmacro DBA_TEXT DBA_LANG_HKCU_REG_VAL   "'User Data' folder (from HKCU entry) = $G_DATADIR"
  !insertmacro DBA_TEXT DBA_LANG_NOT_HKCU_REG   "Unable to find database using registry data (HKCU)"
  !insertmacro DBA_TEXT DBA_LANG_HKCU_INVALID   "Error: No POPFile registry data found for '$G_WINUSERNAME' user"

  !insertmacro DBA_TEXT DBA_LANG_TRY_CURRENT    "Trying to find database (popfile.db) in current folder"
  !insertmacro DBA_TEXT DBA_LANG_NOT_CURRENT    "Unable to find database (popfile.db) in current folder"

  !insertmacro DBA_TEXT DBA_LANG_TRY_EXEDIR     "Trying to find database (popfile.db) in same folder as utility"
  !insertmacro DBA_TEXT DBA_LANG_NOT_EXEDIR     "Unable to find database (popfile.db) in same folder as utility"

  !insertmacro DBA_TEXT DBA_LANG_SEARCHING      "..."
  !insertmacro DBA_TEXT DBA_LANG_FOUNDIT        "... found it!"

  !insertmacro DBA_TEXT DBA_LANG_DIRNOTFILE     "Error: '$G_DATABASE' is a folder, not a database file"
  !insertmacro DBA_TEXT DBA_LANG_CHECKTHISONE   "POPFile database found ($G_DATABASE)"

  !insertmacro DBA_TEXT DBA_LANG_DBFORMAT       "Database is in SQLite $G_DBFORMAT format"

  !insertmacro DBA_TEXT DBA_LANG_SQLITE_INT     "Using built-in SQLite analyser ($G_SQLITEINFO)"
  !insertmacro DBA_TEXT DBA_LANG_SQLITE_EXT     "SQLite analyser ($G_SQLITEINFO) found in $G_PLS_FIELD_1"

  !insertmacro DBA_TEXT DBA_LANG_SQLITECOMMAND  "Starting the database analyser now:"
  !insertmacro DBA_TEXT DBA_LANG_SQLITEDBDONE   "The database analysis has been completed (status code $G_PLS_FIELD_1)"

  !insertmacro DBA_TEXT DBA_LANG_SQLITEFAIL     "Error: The SQLite analyser utility returned error code $G_PLS_FIELD_1"

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
; Section: AnalyseSQLiteDatabase
;------------------------------

Section AnalyseSQLiteDatabase

  !define L_TEMP    $R9

  Push ${L_TEMP}

  SetDetailsPrint textonly
  DetailPrint "$(DBA_LANG_RIGHTCLICK)"
  SetDetailsPrint listonly

  DetailPrint "------------------------------------------------------------"
  DetailPrint "$(^Name) v${C_VERSION}"
  DetailPrint "------------------------------------------------------------"
  DetailPrint ""

  ClearErrors
  UserInfo::GetName
  IfErrors default_name
  Pop $G_WINUSERNAME
  StrCmp $G_WINUSERNAME "" 0 check_input

default_name:
  StrCpy $G_WINUSERNAME "UnknownUser"

check_input:

  ; Set OutPath to the working directory (to cope with cases where no database path is supplied)

  GetFullPathName $INSTDIR ".\"

  SetDetailsPrint none
  SetOutPath "$INSTDIR"
  SetDetailsPrint listonly

  DetailPrint "$(DBA_LANG_CURRENT_USER)"
  DetailPrint "$(DBA_LANG_CURRENT_DIR)"
  StrCmp "$INSTDIR" "$EXEDIR" check_command_line
  DetailPrint "$(DBA_LANG_UTILITY_DIR)"

check_command_line:

  ; The command-line can be used to supply the name of a database file in the current folder
  ; (e.g. mydata.db), a relative filename for the database file (e.g. ..\data\mydata.db) or
  ; the full pathname for the database file (e.g. D:\Application Data\POPFile\popfile.db).

  Call PFI_GetParameters
  Pop $G_DATABASE
  StrCmp $G_DATABASE "" check_currentdir
  DetailPrint "$(DBA_LANG_COMMANDLINE)"
  StrCmp $G_DATABASE "/REGISTRY" 0 lookforfile
  DetailPrint ""
  Goto use_registry

check_currentdir:
  DetailPrint ""
  DetailPrint "$(DBA_LANG_NOCOMMANDLINE)"
  DetailPrint ""

  DetailPrint "$(DBA_LANG_TRY_CURRENT)$(DBA_LANG_SEARCHING)"
  StrCpy $G_DATABASE "popfile.db"
  IfFileExists "$INSTDIR\$G_DATABASE" found_in_current
  !insertmacro DELETE_LAST_ENTRY
  DetailPrint "$(DBA_LANG_NOT_CURRENT)"

  StrCmp "$INSTDIR" "$EXEDIR" try_env_var
  DetailPrint "$(DBA_LANG_TRY_EXEDIR)$(DBA_LANG_SEARCHING)"
  IfFileExists "$EXEDIR\$G_DATABASE" found_in_exedir
  !insertmacro DELETE_LAST_ENTRY
  DetailPrint "$(DBA_LANG_NOT_EXEDIR)"

try_env_var:
  DetailPrint "$(DBA_LANG_TRY_ENV_VAR)$(DBA_LANG_SEARCHING)"
  ReadEnvStr $G_DATADIR "POPFILE_USER"
  StrCmp $G_DATADIR "" try_registry
  Push $G_DATADIR
  Call PFI_GetCompleteFPN
  Pop $G_DATADIR
  !insertmacro DELETE_LAST_ENTRY
  DetailPrint "$(DBA_LANG_ENV_VAR_VAL)"
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
  DetailPrint "$(DBA_LANG_TRY_ENV_VAR)$(DBA_LANG_FOUNDIT)"
  Goto split_path

try_registry:
  !insertmacro DELETE_LAST_ENTRY
  DetailPrint "$(DBA_LANG_NOT_ENV_VAR)"

use_registry:
  DetailPrint "$(DBA_LANG_TRY_HKCU_REG)$(DBA_LANG_SEARCHING)"
  ReadRegStr $G_DATADIR HKCU "Software\POPFile Project\POPFile\MRI" "Owner"
  StrCmp $G_DATADIR $G_WINUSERNAME same_owner
  !insertmacro DELETE_LAST_ENTRY
  StrCmp $G_DATABASE "/REGISTRY" no_reg_data
  DetailPrint ""

no_reg_data:
  DetailPrint "$(DBA_LANG_HKCU_INVALID)"
  Goto usage_msg

same_owner:
  ReadRegStr $G_DATADIR HKCU "Software\POPFile Project\POPFile\MRI" "UserDir_LFN"
  StrCmp $G_DATADIR "" abandon_search
  !insertmacro DELETE_LAST_ENTRY
  DetailPrint "$(DBA_LANG_HKCU_REG_VAL)"
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
  DetailPrint "$(DBA_LANG_TRY_HKCU_REG)$(DBA_LANG_FOUNDIT)"
  Goto split_path

sqlite_not_used:
  DetailPrint ""
  DetailPrint "$(DBA_LANG_NOSQLITE_1)"
  DetailPrint "$(DBA_LANG_NOSQLITE_2)"
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(DBA_LANG_NOSQLITE)"
  Goto error_exit

abandon_search:
  !insertmacro DELETE_LAST_ENTRY
  DetailPrint "$(DBA_LANG_NOT_HKCU_REG)"
  StrCpy $G_PLS_FIELD_1 "$INSTDIR"
  Goto give_up

found_in_current:
  !insertmacro DELETE_LAST_ENTRY
  DetailPrint "$(DBA_LANG_TRY_CURRENT)$(DBA_LANG_FOUNDIT)"
  Goto lookforfile

found_in_exedir:
  !insertmacro DELETE_LAST_ENTRY
  DetailPrint "$(DBA_LANG_TRY_EXEDIR)$(DBA_LANG_FOUNDIT)"
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
  DetailPrint "$(DBA_LANG_DBNOTFOUND_1)"
  DetailPrint "$(DBA_LANG_DBNOTFOUND_2)"
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(DBA_LANG_DBNOTFOUND)"

usage_msg:

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
  DetailPrint "$(DBA_LANG_NODBPARAM_2)"
  DetailPrint ""
  DetailPrint "$(DBA_LANG_NODBPARAM_3)"
  DetailPrint "$(DBA_LANG_NODBPARAM_4)"
  DetailPrint "$(DBA_LANG_NODBPARAM_5)"
  Goto error_exit

continue:
  StrCpy $G_PLS_FIELD_2 $G_DATABASE
  StrCpy $G_DATABASE "$G_PLS_FIELD_1\$G_DATABASE"
  IfFileExists "$G_DATABASE\*.*" dir_not_file
  DetailPrint ""
  DetailPrint "$(DBA_LANG_CHECKTHISONE)"
  Push $G_DATABASE
  Call PFI_GetSQLiteFormat
  Pop $G_DBFORMAT
  StrCpy $G_SQLITEINFO "sqlite_analyzer.exe"
  StrCmp $G_DBFORMAT "2.x" extract_util
  StrCpy $G_SQLITEINFO "sqlite3_analyzer.exe"
  StrCmp $G_DBFORMAT "3.x" look_for_util
  Push $G_DATABASE
  Call PFI_GetParent
  Pop $G_PLS_FIELD_1
  StrLen ${L_TEMP} $G_PLS_FIELD_1
  IntOp ${L_TEMP} ${L_TEMP} + 1
  StrCpy $G_DATABASE $G_DATABASE "" ${L_TEMP}
  DetailPrint ""
  DetailPrint "$(DBA_LANG_UNKNOWNFMT_1)"
  DetailPrint ""
  DetailPrint "$(DBA_LANG_UNKNOWNFMT_2)"
  DetailPrint ""
  DetailPrint "$(DBA_LANG_UNKNOWNFMT_3)"
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(DBA_LANG_UNKNOWNFORMAT)"
  Goto error_exit

look_for_util:
  DetailPrint ""
  DetailPrint "$(DBA_LANG_DBIDENTIFIED)"
  StrCpy ${L_TEMP} "$EXEDIR"
  StrCpy $G_PLS_FIELD_1 "$EXEDIR"
  IfFileExists "${L_TEMP}\$G_SQLITEINFO" run_ext_util

  ; It is not in "our" folder so try looking in the usual places

  ReadEnvStr ${L_TEMP} "POPFILE_ROOT"
  StrCmp ${L_TEMP} "" try_HKCU
  Push ${L_TEMP}
  Call PFI_GetCompleteFPN
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" try_HKCU
  IfFileExists "${L_TEMP}\$G_SQLITEINFO" run_ext_util

try_HKCU:
  ReadRegStr ${L_TEMP} HKCU "Software\POPFile Project\POPFile\MRI" "RootDir_LFN"
  StrCmp ${L_TEMP} "" try_HKLM
  IfFileExists "${L_TEMP}\$G_SQLITEINFO" run_ext_util

try_HKLM:
  ReadRegStr ${L_TEMP} HKLM "Software\POPFile Project\POPFile\MRI" "RootDir_LFN"
  StrCmp ${L_TEMP} "" no_util
  IfFileExists "${L_TEMP}\$G_SQLITEINFO" run_ext_util

no_util:
  DetailPrint ""
  DetailPrint "$(DBA_LANG_UTILNOTFOUND_1)"
  DetailPrint "$(DBA_LANG_UTILNOTFOUND_2)"
  MessageBox MB_OK|MB_ICONEXCLAMATION \
      "$(DBA_LANG_DBIDENTIFIED)\
      ${MB_NL}${MB_NL}${MB_NL}\
      $(DBA_LANG_UTILNOTFOUND)"
  Goto error_exit

run_ext_util:
  StrCpy $G_PLS_FIELD_1 ${L_TEMP}
  DetailPrint ""
  DetailPrint "$(DBA_LANG_SQLITE_EXT)"
  Goto run_it

extract_util:
  DetailPrint ""
  DetailPrint "$(DBA_LANG_DBIDENTIFIED)"
  SetDetailsPrint none
  File "/oname=$PLUGINSDIR\sqlite_analyzer.exe" "..\sqlite_analyzer.exe"
  SetDetailsPrint listonly
  StrCpy $G_PLS_FIELD_1 "$PLUGINSDIR"
  DetailPrint ""
  DetailPrint "$(DBA_LANG_SQLITE_INT)"

run_it:
  DetailPrint ""
  DetailPrint "$(DBA_LANG_SQLITECOMMAND)"
  DetailPrint "------------------------------------------------------------"
  DetailPrint ""
  nsExec::ExecToLog '"$G_PLS_FIELD_1\$G_SQLITEINFO" "$G_DATABASE"'
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "error" start_error
  StrCmp ${L_TEMP} "timeout" start_error
  StrCpy $G_PLS_FIELD_1 ${L_TEMP}
  IntCmp ${L_TEMP} 0 exit
  DetailPrint ""
  DetailPrint "------------------------------------------------------------"
  DetailPrint ""
  DetailPrint "$(DBA_LANG_SQLITEFAIL)"
  Goto error_exit

dir_not_file:
  DetailPrint ""
  DetailPrint "$(DBA_LANG_DIRNOTFILE)"
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(DBA_LANG_DIRNOTFILE)"
  Goto error_exit

start_error:
  DetailPrint ""
  DetailPrint "$(DBA_LANG_STARTERROR)"
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(DBA_LANG_STARTERROR)"

error_exit:
  Call PFI_GetDateTimeStamp
  Pop ${L_TEMP}
  DetailPrint ""
  DetailPrint "------------------------------------------------------------"
  DetailPrint "(database analysis failed ${L_TEMP})"
  DetailPrint "------------------------------------------------------------"
  SetDetailsPrint none
  Abort

exit:
  DetailPrint ""
  DetailPrint "------------------------------------------------------------"
  DetailPrint "$(DBA_LANG_SQLITEDBDONE)"
  Call PFI_GetDateTimeStamp
  Pop ${L_TEMP}
  DetailPrint "------------------------------------------------------------"
  DetailPrint "(report finished ${L_TEMP})"
  DetailPrint "------------------------------------------------------------"
  SetDetailsPrint none

  ; Emphasize the 'status code' part of the report by hiding the less important timestamp part

  Call HideFinalTimestamp

  POP ${L_TEMP}

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

  !define C_LVM_ENSUREVISIBLE       0x1013
  !define C_LVM_GETTOPINDEX         0x1027

#--------------------------------------------------------------------------
# Installer Function: GetDetailViewItemCount
#
# Returns the number of rows in the details view (on the INSTFILES page)
#
# Inputs:
#         none
#
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
#
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

#--------------------------------------------------------------------------
# Installer Function: HideFinalTimestamp
#
# Scrolls the details view up a little to hide the final timestamp in order
# to emphasize the end of the analysis report (the timestamp is less important).
#
# The "report finished" timestamp can still be seen by scrolling down or saving
# the entire report to a file via the clipboard.
#
# Inputs:
#         none
#
# Outputs:
#         none
#
# Usage:
#         Call HideFinalTimestamp
#
#--------------------------------------------------------------------------

Function HideFinalTimestamp

  !define L_TEMP      $R9
  !define L_TOPROW    $R8

  Push ${L_TEMP}
  Push ${L_TOPROW}

  ; The final timestamp block uses 3 lines so we want to scroll up 3 lines to bring
  ; more important lines back into view at the top of the list. The LVM_SCROLL message
  ; uses a pixel-based vertical scroll value instead of an item-based value so we take
  ; an easier approach: find the item index of the currently visible top row and then
  ; make visible the item which is 3 rows before that. (The item index is zero based so
  ; we must ensure we never supply a negative item index)

  FindWindow ${L_TOPROW} "#32770" "" $HWNDPARENT
  GetDlgItem ${L_TOPROW} ${L_TOPROW} 0x3F8       ; This is the Control ID of the details view
  SendMessage ${L_TOPROW} ${C_LVM_GETTOPINDEX} 0 0 ${L_TOPROW}

  IntOp ${L_TOPROW} ${L_TOPROW} - 3
  IntCmp ${L_TOPROW} 0 scrollup 0 scrollup
  StrCpy ${L_TOPROW} 0

scrollup:
  FindWindow ${L_TEMP} "#32770" "" $HWNDPARENT
  GetDlgItem ${L_TEMP} ${L_TEMP} 0x3F8           ; This is the Control ID of the details view
  SendMessage ${L_TEMP} ${C_LVM_ENSUREVISIBLE} ${L_TOPROW} 0

  Pop ${L_TOPROW}
  Pop ${L_TEMP}

  !undef L_TEMP
  !undef L_TOPROW

FunctionEnd

;--------------------------
; End of 'pfidbanalyser.nsi'
;--------------------------
