#-------------------------------------------------------------------------------------------
#
# runsqlite.nsi --- A simple front-end to the SQLite command-line utility. By default POPFile
#                   0.21.x and 0.22.0 used SQLite 2.x format databases. A future release will
#                   use SQLite 3.x (and POPFile 0.22.x might be patched to work with SQLite 3)
#
#                   SQLite 2.x and 3.x database files are not compatible therefore separate
#                   command-line utilities have to be used: sqlite.exe for 2.x format files
#                   and sqlite3.exe for 3.x format files. This utility ensures the appropriate
#                   utility is used to access the specified SQLite database file.
#
# Copyright (c) 2004-2005  John Graham-Cumming
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
# Usage (one mandatory parameter):
#
#        RUNSQLITE database_filename
#
# This utility is intended for use via a shortcut created in the 'User Data' folder by the
# 'Add POPFile User' wizard (adduser.exe). Normally the 'database_filename' parameter will
# simply be the default SQLite database filename, popfile.db.
#
#-------------------------------------------------------------------------------------------

; This version of the script has been tested with the "NSIS 2" compiler (final),
; released 7 February 2004, with no "official" NSIS patches/CVS updates applied.

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
  !define C_OUTFILE   "runsqlite.exe"

  ; The default NSIS caption is "Name Setup" so we override it here

  Name    "POPFile Run SQLite Utility"
  Caption "POPFile Run SQLite Utility ${C_VERSION}"

  ; Specify EXE filename and icon for the 'installer'

  OutFile "${C_OUTFILE}"

  Icon "POPFileIcon\popfile.ico"

  ; Selecting 'silent' mode makes the installer behave like a command-line utility

  SilentInstall silent

#--------------------------------------------------------------------------
# Include private library functions and macro definitions
#--------------------------------------------------------------------------

  ; Avoid compiler warnings by disabling the functions and definitions we do not use

  !define RUNSQLITE

  !include "pfi-library.nsh"

#--------------------------------------------------------------------------

  ; 'VIProductVersion' format is X.X.X.X where X is a number in range 0 to 65535
  ; representing the following values: Major.Minor.Release.Build

  VIProductVersion                          "${C_VERSION}.0"

  VIAddVersionKey "ProductName"             "Run SQLite 2.x/3.x utility to examine a POPFile database"
  VIAddVersionKey "Comments"                "POPFile Homepage: http://getpopfile.org/"
  VIAddVersionKey "CompanyName"             "The POPFile Project"
  VIAddVersionKey "LegalCopyright"          "Copyright (c) 2005  John Graham-Cumming"
  VIAddVersionKey "FileDescription"         "Run SQLite Utility for POPFile"
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

  Var G_DATABASE       ; holds name (and possibly path) to the SQLite database
  Var G_SQLITEUTIL     ; name of the appropriate SQLite command-line utility
  Var G_DBFORMAT       ; SQLite database format ('2.x', '3.x' or an error string)

#--------------------------------------------------------------------------
# Language Support for the utility
#--------------------------------------------------------------------------

  ;--------------------------------------------------------------------------
  ; Current build only supports English and uses local strings
  ; instead of language strings from languages\*-pfi.nsh files
  ;--------------------------------------------------------------------------

  !macro RSU_TEXT NAME VALUE
      LangString ${NAME} ${LANG_ENGLISH} "${VALUE}"
  !macroend

  !insertmacro RSU_TEXT RSU_LANG_DBNOTFOUND     "Unable to find the '$G_DATABASE' file (the SQLite database)${MB_NL}${MB_NL}(looked in $OUTDIR folder)"
  !insertmacro RSU_TEXT RSU_LANG_NODBPARAM      "No SQLite database filename specified.${MB_NL}${MB_NL}Usage: runsqlite <database>${MB_NL}e.g. runsqlite popfile.db"
  !insertmacro RSU_TEXT RSU_LANG_OPENERR        "unable to open file"
  !insertmacro RSU_TEXT RSU_LANG_DBIDENTIFIED   "The '$G_DATABASE' file is a SQLite $G_DBFORMAT database"
  !insertmacro RSU_TEXT RSU_LANG_UTILNOTFOUND   "Unable to find the '$G_SQLITEUTIL' file (the SQLite $G_DBFORMAT utility)${MB_NL}${MB_NL}(looked in $EXEDIR folder)"
  !insertmacro RSU_TEXT RSU_LANG_STARTERROR     "Unable to start the '$G_SQLITEUTIL' utility"
  !insertmacro RSU_TEXT RSU_LANG_UNKNOWNFORMAT  "Unable to tell if '$G_DATABASE' is a SQLite database file${MB_NL}${MB_NL}File format not known $G_DBFORMAT"

  ;--------------------------------------------------------------------------

;-------------------
; Section: RunSQLiteUtility
;-------------------

Section RunSQLiteUtility

  !define L_TEMP    $R9

  ; Set OutPath to the working directory (to cope with cases where no database path is supplied)

  GetFullPathName ${L_TEMP} ".\"
  SetOutPath "${L_TEMP}"

  Call GetParameters
  Pop $G_DATABASE
  StrCmp $G_DATABASE "" no_file_supplied

  IfFileExists "$G_DATABASE" continue
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(RSU_LANG_DBNOTFOUND)"
  Goto error_exit

no_file_supplied:
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(RSU_LANG_NODBPARAM)"
  Goto error_exit

continue:
  Push $G_DATABASE
  Call GetSQLiteFormat
  Pop $G_DBFORMAT
  StrCpy $G_SQLITEUTIL "sqlite.exe"
  StrCmp $G_DBFORMAT "2.x" run_sqlite
  StrCpy $G_SQLITEUTIL "sqlite3.exe"
  StrCmp $G_DBFORMAT "3.x" run_sqlite
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(RSU_LANG_UNKNOWNFORMAT)"
  Goto error_exit

run_sqlite:
  IfFileExists "$EXEDIR\$G_SQLITEUTIL" run_it
  MessageBox MB_OK|MB_ICONEXCLAMATION \
      "$(RSU_LANG_DBIDENTIFIED)\
      ${MB_NL}${MB_NL}${MB_NL}\
      $(RSU_LANG_UTILNOTFOUND)"
  Goto error_exit

run_it:
  ClearErrors
  Exec '"$EXEDIR\$G_SQLITEUTIL" "$G_DATABASE"'
  IfErrors start_error
  Goto exit

start_error:
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(RSU_LANG_STARTERROR)"

error_exit:
  Abort                                  ; Return error code 1 (failure)

exit:
                                         ; Return error code 0 (success)
  !undef L_TEMP

SectionEnd

;-------------
; end-of-file
;-------------
