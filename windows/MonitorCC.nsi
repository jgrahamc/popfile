#--------------------------------------------------------------------------
#
# MonitorCC.nsi --- This is the NSIS script used to create the utility used by the
#                   POPFile Windows installer when a flat-file or BerkeleyDB corpus
#                   needs to be converted to the new SQL database format.
#
# Copyright (c) 2004 John Graham-Cumming
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
; released 7 February 2004, with no patches applied.
;
; Expect 3 compiler warnings, all related to standard NSIS language files which are out-of-date.

#--------------------------------------------------------------------------
# Run-time command-line switches (used by 'monitorcc.exe')
#--------------------------------------------------------------------------
#
# <conversion settings filename>
#
# The full filename (including the path) of the INI file containing details of the POPFile
# installation and the corpus files which are to be converted. If no parameter is found or
# if the file cannot be found, an error message is displayed. The INI file is used to supply
# all of the required data thus isolating this utility from any changes in the folder structure
# used by the POPFile installer.
#
#--------------------------------------------------------------------------
# INI File Structure
#
#  [Settings]
#    CONVERT=full path to program used to perform the conversion (created by installer)
#    ROOTDIR=full path to the folder where POPFile has been installed (created by installer)
#    USERDIR=full path to the folder with the POPFile configuration data (created by installer)
#
#  [FolderList]
#    MaxNum=number of bucket folders found by installer (each has a Path-n entry in the section)
#    Path-n=full path to a bucket folder (created and used by installer)
#
#  [BucketList]
#    FileCount=number of bucket files found by the installer (each has a [Bucket-n] section)
#    TotalSize=total size (in bytes) of all bucket files found by the installer
#    StartTime=in 0.01 minute units (created by this utility)
#    Stop_Time=in 0.01 minute units (created by this utility)
#
#  [Bucket-n]
#    File_Name=full path to a bucket file (a flat file (table) or BerkeleyDB (table.db) file)
#    File_Size=size of the 'table' file or 'table.db' file (in bytes)
#    Stop_Time=in 0.01 minute units (set to '0' by the installer, updated by this utility)
#    ElapsTime=in 0.01 minute units (set to '0' by the installer, updated by this utility)
#
#  (Data for the first bucket file is in section [Bucket-1], the second in [Bucket-2], etc)
#--------------------------------------------------------------------------
# The POPFile installer uses several multi-language mode programs built using NSIS. To make
# maintenance easier, an 'include' file (pfi-languages.nsh) defines the supported languages.
#
# To remove support for a particular language, comment-out the relevant line in the list of
# languages in the 'pfi-languages.nsh' file.
#
# For instructions on how to add support for new languages, see the 'pfi-languages.nsh' file.
#--------------------------------------------------------------------------

  ;--------------------------------------------------------------------------
  ; POPFile constants have been given names beginning with 'C_' (eg C_README)
  ;--------------------------------------------------------------------------

  !define C_PFI_PRODUCT  "POPFile Corpus Conversion Monitor"
  Name                   "${C_PFI_PRODUCT}"

  !define C_PFI_VERSION  "0.1.14"

  ; Mention the version number in the window title

  Caption                "${C_PFI_PRODUCT} ${C_PFI_VERSION}"

  ;------------------------------------------------
  ; Define PFI_VERBOSE to get more compiler output
  ;------------------------------------------------

## !define PFI_VERBOSE

#--------------------------------------------------------------------------
# Use the "Modern User Interface"
#--------------------------------------------------------------------------

  !include "MUI.nsh"

#--------------------------------------------------------------------------
# Version Information settings (for the utility's EXE file)
#--------------------------------------------------------------------------

  ; 'VIProductVersion' format is X.X.X.X where X is a number in range 0 to 65535
  ; representing the following values: Major.Minor.Release.Build

  VIProductVersion                   "${C_PFI_VERSION}.0"

  VIAddVersionKey "ProductName"      "${C_PFI_PRODUCT}"
  VIAddVersionKey "Comments"         "POPFile Homepage: http://popfile.sf.net"
  VIAddVersionKey "CompanyName"      "The POPFile Project"
  VIAddVersionKey "LegalCopyright"   "© 2004  John Graham-Cumming"
  VIAddVersionKey "FileDescription"  "POPFile Corpus Conversion Monitor"
  VIAddVersionKey "FileVersion"      "${C_PFI_VERSION}"

  VIAddVersionKey "Build"            "Multi-Language"

  VIAddVersionKey "Build Date/Time"  "${__DATE__} @ ${__TIME__}"
  VIAddVersionKey "Build Script"     "${__FILE__}$\r$\n(${__TIMESTAMP__})"

#--------------------------------------------------------------------------
# Configure the MUI pages
#--------------------------------------------------------------------------

  ;----------------------------------------------------------------
  ; Interface Settings - General Interface Settings
  ;----------------------------------------------------------------

  ; The icon file for the utility

  !define MUI_ICON                                "POPFileIcon\popfile.ico"

  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP                  "hdr-common.bmp"
  !define MUI_HEADERIMAGE_RIGHT

  ;----------------------------------------------------------------
  ;  Interface Settings - Interface Resource Settings
  ;----------------------------------------------------------------

  ; The banner provided by the default 'modern.exe' UI does not provide much room for the
  ; two lines of text, e.g. the German version is truncated, so we use a custom UI which
  ; provides slightly wider text areas. Each area is still limited to a single line of text.

  !define MUI_UI                                  "UI\pfi_modern.exe"

  ; The 'hdr-common.bmp' logo is only 90 x 57 pixels, much smaller than the 150 x 57 pixel
  ; space provided by the default 'modern_headerbmpr.exe' UI, so we use a custom UI which
  ; leaves more room for the TITLE and SUBTITLE text.

  !define MUI_UI_HEADERIMAGE_RIGHT                "UI\pfi_headerbmpr.exe"

  ;----------------------------------------------------------------
  ;  Interface Settings - Installer Finish Page Interface Settings
  ;----------------------------------------------------------------

  ; Show the installation log and leave the window open when utility has completed its work
  ; (the log shows corpus conversion progress reports with elapsed times and total time taken)

  ShowInstDetails show
  !define MUI_FINISHPAGE_NOAUTOCLOSE

  ;----------------------------------------------------------------
  ;  Interface Settings - Abort Warning Settings
  ;----------------------------------------------------------------

  ; Show a message box with a warning when the user closes the installation

  !define MUI_ABORTWARNING

  ;----------------------------------------------------------------
  ; Customize MUI - General Custom Function
  ;----------------------------------------------------------------

  ; Use a custom '.onGUIInit' function to allow the use of language-specific error messages

  !define MUI_CUSTOMFUNCTION_GUIINIT              PFIGUIInit

  ;----------------------------------------------------------------
  ; Language Settings for MUI pages
  ;----------------------------------------------------------------

  ; Override the standard prompt (to match the one used by the main installer)

  !define MUI_LANGDLL_WINDOWTITLE                 "Language Selection"

  ; Use same language setting as the POPFile installer (if this registry entry
  ; is not found, the user will be asked to select the language to be used)

  !define MUI_LANGDLL_REGISTRY_ROOT               "HKCU"
  !define MUI_LANGDLL_REGISTRY_KEY                "Software\POPFile Project\POPFile\MRI"
  !define MUI_LANGDLL_REGISTRY_VALUENAME          "Installer Language"

#--------------------------------------------------------------------------
# Define the Page order for the utility
#--------------------------------------------------------------------------

  ;---------------------------------------------------
  ; Installer Page - Install files
  ;---------------------------------------------------

  ; Override the standard "Installing..." page header

  !define MUI_PAGE_HEADER_TEXT                    "$(PFI_LANG_CONVERT_TITLE)"
  !define MUI_PAGE_HEADER_SUBTEXT                 "$(PFI_LANG_CONVERT_SUBTITLE)"

  ; Override the standard "Installation complete..." page header

  !define MUI_INSTFILESPAGE_FINISHHEADER_TEXT     "$(PFI_LANG_ENDCONVERT_TITLE)"
  !define MUI_INSTFILESPAGE_FINISHHEADER_SUBTEXT  "$(PFI_LANG_ENDCONVERT_SUBTITLE)"

  ; Override the standard "Installation Aborted..." page header

  !define MUI_INSTFILESPAGE_ABORTHEADER_TEXT      "$(PFI_LANG_BADCONVERT_TITLE)"
  !define MUI_INSTFILESPAGE_ABORTHEADER_SUBTEXT   "$(PFI_LANG_BADCONVERT_SUBTITLE)"

  !insertmacro MUI_PAGE_INSTFILES

#--------------------------------------------------------------------------
# User Registers (Global)
#--------------------------------------------------------------------------

  ; This script uses 'User Variables' (with names starting with 'G_') to hold GLOBAL data.

  Var G_ROOTDIR           ; full path to location of the POPFile files (popfile.pl and others)
  Var G_USERDIR           ; full path to location of the popfile.cfg file
  Var G_INIFILE_PATH      ; file holding details of the bucket which are being converted

  ; Global variables used to simplify translation of the conversion progress messages

  Var G_BUCKET_COUNT      ; number of bucket files to be converted
  Var G_ELAPSED_TIME      ; elapsed time for corpus conversion
  Var G_DECPLACES         ; used to hold the decimal places when displaying the elapsed time
  Var G_STILL_TO_DO       ; number of files still to be converted

  ; NSIS provides 20 general purpose user registers:
  ; (a) $R0 to $R9   are used as local registers
  ; (b) $0 to $9     are used as additional local registers

  ; Local registers referred to by 'defines' use names starting with 'L_' (eg L_LNE, L_OLDUI)
  ; and the scope of these 'defines' is limited to the "routine" where they are used.

  ; In earlier versions of the NSIS compiler, 'User Variables' did not exist, and the convention
  ; was to use $R0 to $R9 as 'local' registers and $0 to $9 as 'global' ones. This is why this
  ; script uses registers $R0 to $R9 in preference to registers $0 to $9.

  ; POPFile constants have been given names beginning with 'C_' (eg C_README)

#--------------------------------------------------------------------------
# Language Support for the utility
#--------------------------------------------------------------------------

  ;--------------------------------------------------------------------------
  ; Used in the '*-pfi.nsh' files to define the text strings for the utility
  ;--------------------------------------------------------------------------

  !macro PFI_LANG_STRING NAME VALUE
    LangString ${NAME} ${LANG_${PFI_LANG}} "${VALUE}"
  !macroend

  ;--------------------------------------------------------------------------
  ; Used in this file to define the languages to be supported
  ;--------------------------------------------------------------------------

  ; Macro used to load the files required for each language:
  ; (1) The MUI_LANGUAGE macro loads the standard MUI text strings for a particular language
  ; (2) '*-pfi.nsh' contains the text strings used for pages, progress reports, logs etc

  !macro PFI_LANG_LOAD LANG
    !insertmacro MUI_LANGUAGE "${LANG}"
    !include "languages\${LANG}-pfi.nsh"
  !macroend

  ;-----------------------------------------
  ; Select the languages to be supported by the utility
  ;-----------------------------------------

  ; Default language (appears first in the drop-down list)

  !insertmacro PFI_LANG_LOAD "English"

  ; Additional languages supported by the utility

  !include "pfi-languages.nsh"

#--------------------------------------------------------------------------
# General settings
#--------------------------------------------------------------------------

  ; Specify NSIS output filename

  OutFile "monitorcc.exe"

  ; Ensure CRC checking cannot be turned off using the /NCRC command-line switch

  CRCcheck Force

#--------------------------------------------------------------------------
# Reserve the files required by the utility (to improve performance)
#--------------------------------------------------------------------------

  ; Things that need to be extracted on startup (keep these lines before any File command!)
  ; Only useful when solid compression is used (by default, solid compression is enabled
  ; for BZIP2 and LZMA compression)

  !insertmacro MUI_RESERVEFILE_LANGDLL


#--------------------------------------------------------------------------
# Installer Function: .onInit - utility offers a choice of languages if no registry data found
#--------------------------------------------------------------------------

Function .onInit

  !insertmacro MUI_LANGDLL_DISPLAY

FunctionEnd


#--------------------------------------------------------------------------
# Installer Function: PFIGUIInit
# (custom .onGUIInit function)
#
# Used to complete the initialization of the utility. This code was moved from
# '.onInit' in order to permit the use of language-specific error messages
#--------------------------------------------------------------------------

Function PFIGUIInit

  ; 'PFIGUIInit' preserves the registers it uses in order to make debugging easier!

  !define L_RESERVED            $1    ; used in the system.dll call
  !define L_TEMP                $R9

  Push ${L_RESERVED}
  Push ${L_TEMP}

  ; Ensure only one copy of this utility is running

  System::Call 'kernel32::CreateMutexA(i 0, i 0, t "OnlyOneMonitorCC_mutex") i .r1 ?e'
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} 0 continue
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(PFI_LANG_CONVERT_MUTEX)"
  Abort

continue:
  Call GetParameters
  Pop $G_INIFILE_PATH
  StrCmp $G_INIFILE_PATH "" 0 got_param
  MessageBox MB_OK|MB_ICONINFORMATION "$(PFI_LANG_CONVERT_PRIVATE)"
  Abort

got_param:
  StrCpy ${L_TEMP} $G_INIFILE_PATH 1
  StrCmp ${L_TEMP} '"' 0 no_quotes
  StrCpy $G_INIFILE_PATH $G_INIFILE_PATH "" 1
  StrCpy $G_INIFILE_PATH $G_INIFILE_PATH -1

no_quotes:
  IfFileExists "$G_INIFILE_PATH" exit
  MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_NOFILE)\
      $\r$\n$\r$\n\
      ($G_INIFILE_PATH)"
  Abort

exit:
  Pop ${L_TEMP}
  Pop ${L_RESERVED}

  !undef L_RESERVED
  !undef L_TEMP

FunctionEnd


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


#--------------------------------------------------------------------------
# NOTE: Special plugin handling is used for the 'GetLocalTimeAsMin100' function
# and the 'ConvertCorpus' section which immediately follows it in this script.
#
# The LangDLL.dll used by '.onInit' (above) is not affected therefore it
# does not need to be manually unloaded before we exit from this utility.
#
# The 'System' plugin calls in 'PFIGUIInit' (above) are also not affected.
#
# The 'GetLocalTimeAsMin100' function and the 'ConvertCorpus' section make extensive use
# of the 'System' plugin, so we follow the recommendation of the plugin's author and tell
# NSIS not to bother unloading it after every call. Before we exit from the utility, we must
# ensure the plugin is manually unloaded, otherwise NSIS will not be able to delete the
# $PLUGINSDIR (the directory used for the plugins).
#
# The 'System' plugin is manually unloaded immediately after the 'exit' label in the
# 'ConvertCorpus' section (the normal exit from this utility)
#
# If other plugins are used in the future, they may also need to be manually unloaded
# before the utility exits (depending upon where they are used in this script).
#--------------------------------------------------------------------------

  SetPluginUnload alwaysoff


#--------------------------------------------------------------------------
# Installer Function: GetLocalTimeAsMin100
#
# Returns on the stack Int64 of the current local time in 0.01 minute units
# (derived from the FILETIME Structure of current local time)
#
# Inputs:
#         (none)
# Outputs:
#         (top of stack)     - current local time in 0.01 minute units (Int64)
#
# Usage:
#
#         Call GetLocalTimeAsMin100
#         Pop $R0
#
#         ($R0 at this point is '21198050952', for example)
#
#--------------------------------------------------------------------------

Function GetLocalTimeAsMin100

  Push $0
  Push $1
  Push $2
  Push $3

  System::Call '*(&i2, &i2, &i2, &i2, &i2, &i2, &i2, &i2) i .r1'
  System::Call '*(i, i) l .r0'
  System::Call 'kernel32::GetLocalTime(i) i(r1)'
  System::Call 'kernel32::SystemTimeToFileTime(i, l) l(r1, r0)'
  System::Call '*$0(i .r1, i .r2)'

  ; $1 contains the low  order Int32
  ; $2 contains the high order Int32

  ; High order Int32 adjustment required if low order Int32 is negative (i.e. if top bit is set)

  StrCpy $3 $1 1
  StrCmp $3 "-" 0 convert_to_int64
  IntOp $2 $2 + 1

convert_to_int64:
  System::Int64Op  $2 * 4294967296
  pop $3
  System::Int64Op  $3 + $1
  pop $3
  System::Int64Op  $3 / 6000000

  Exch 4
  Exch 3
  Exch 2
  Exch

  Pop $3
  Pop $2
  Pop $1
  Pop $0

FunctionEnd


#--------------------------------------------------------------------------
# Installer Section: ConvertCorpus
#--------------------------------------------------------------------------

Section ConvertCorpus

  !define C_LOOP_DELAY    5000    ; delay (in milliseconds) used after each pass through list

  !define L_BYTES_DONE    $R9     ; number of bytes converted (updated when a file is deleted)
  !define L_BYTES_LEFT    $R8     ; number of bytes still to be converted
  !define L_BYTES_RATE    $R7     ; used to estimate the time remaining
  !define L_BUCKET_PATH   $R6     ; full path to a corpus bucket file we are monitoring
  !define L_CONVERTEXE    $R5     ; holds command (including full path) used to convert corpus
  !define L_CORPUS_SIZE   $R4     ; total number of bytes in all the bucket files in the list
  !define L_LAST_CHANGE   $R3     ; used to detect when a bucket file has been deleted
  !define L_NEXT_EXECHECK $R2     ; used to decide when to check POPFile is still running
  !define L_POPFILE_ROOT  $R1     ; environment variable holding path to popfile.pl
  !define L_POPFILE_USER  $R0     ; environment variable holding path to popfile.cfg
  !define L_START_TIME    $9     ; time in Min100 units when we started the corpus conversion
  !define L_TEMP          $8
  !define L_TIME_LEFT     $7      ; estimated time remaining (updated when a file is deleted)

  !define L_RESERVED      $0      ; used to get result from the System.dll plugin
  Push ${L_RESERVED}

  Push ${L_BYTES_DONE}
  Push ${L_BYTES_LEFT}
  Push ${L_BYTES_RATE}
  Push ${L_BUCKET_PATH}
  Push ${L_CONVERTEXE}
  Push ${L_CORPUS_SIZE}
  Push ${L_LAST_CHANGE}
  Push ${L_NEXT_EXECHECK}
  Push ${L_POPFILE_ROOT}
  Push ${L_POPFILE_USER}
  Push ${L_START_TIME}
  Push ${L_TEMP}
  Push ${L_TIME_LEFT}

  SetDetailsPrint listonly

  ; Get full pathname of the program used to convert the corpus (normally this will be
  ; equivalent to a fully expanded version of '$G_ROOTDIR\popfileb.exe'.

  ; We run POPFile in the background without the system tray icon because corpus conversion
  ; can take several minutes (or even tens of minutes) and we do not want to encourage use of
  ; the UI during this period. Earlier versions of this utility used 'wperl.exe' but there were
  ; problems with it not shutting down when the user logs off, so we use 'popfileb.exe' as it
  ; seems to be better behaved.

  ReadINIStr ${L_CONVERTEXE} "$G_INIFILE_PATH" "Settings" "CONVERT"
  StrCmp  ${L_CONVERTEXE} "" no_conv_path
  IfFileExists "${L_CONVERTEXE}\*.*" no_conv_path
  IfFileExists ${L_CONVERTEXE} 0 no_conv_path

  ; Get POPFile program ('popfile.pl') folder location from the INI file

  ReadINIStr $G_ROOTDIR "$G_INIFILE_PATH" "Settings" "ROOTDIR"
  StrCmp  $G_ROOTDIR "" no_root_path

  ; Get POPFile configuration data ('popfile.cfg') folder location from the INI file

  ReadINIStr $G_USERDIR "$G_INIFILE_PATH" "Settings" "USERDIR"
  StrCmp  $G_USERDIR "" no_user_path
  Goto check_env_vars

no_conv_path:
  DetailPrint ""
  DetailPrint "$(PFI_LANG_CONVERT_NOPOPFILE) (popfileb.exe?)"
  DetailPrint ""
  DetailPrint "$(PFI_LANG_CONVERT_FATALERR)"
  DetailPrint ""
  MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_NOPOPFILE) (popfileb.exe?)"
  Abort

no_root_path:
  DetailPrint ""
  DetailPrint "$(PFI_LANG_CONVERT_NOPOPFILE) (POPFILE_ROOT)"
  DetailPrint ""
  DetailPrint "$(PFI_LANG_CONVERT_FATALERR)"
  DetailPrint ""
  MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_NOPOPFILE) (POPFILE_ROOT)"
  Abort

no_user_path:
  DetailPrint ""
  DetailPrint "$(PFI_LANG_CONVERT_NOPOPFILE) (POPFILE_USER)"
  DetailPrint ""
  DetailPrint "$(PFI_LANG_CONVERT_FATALERR)"
  DetailPrint ""
  MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_NOPOPFILE) (POPFILE_USER)"
  Abort

root_not_set:
  DetailPrint ""
  DetailPrint "$(PFI_LANG_CONVERT_ENVNOTSET) (POPFILE_ROOT)"
  DetailPrint ""
  DetailPrint "$(PFI_LANG_CONVERT_FATALERR)"
  DetailPrint ""
  MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_ENVNOTSET) (POPFILE_ROOT)"
  Abort

user_not_set:
  DetailPrint ""
  DetailPrint "$(PFI_LANG_CONVERT_ENVNOTSET) (POPFILE_USER)"
  DetailPrint ""
  DetailPrint "$(PFI_LANG_CONVERT_FATALERR)"
  DetailPrint ""
  MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_ENVNOTSET) (POPFILE_USER)"
  Abort

start_error:
  DetailPrint ""
  DetailPrint "$(PFI_LANG_CONVERT_STARTERR)"
  DetailPrint ""
  MessageBox MB_OK|MB_ICONSTOP|MB_TOPMOST "$(PFI_LANG_CONVERT_STARTERR)"
  Abort

not_running:
  DetailPrint ""
  DetailPrint "$(PFI_LANG_CONVERT_FATALERR)"
  DetailPrint ""
  MessageBox MB_OK|MB_ICONSTOP|MB_TOPMOST "$(PFI_LANG_CONVERT_FATALERR)"
  Abort

check_env_vars:
  ClearErrors
  ReadEnvStr ${L_TEMP} "POPFILE_ROOT"
  IfErrors root_not_set
  ReadEnvStr ${L_TEMP} "POPFILE_USER"
  IfErrors user_not_set
  Exec '"${L_CONVERTEXE}"'
  IfErrors start_error

  ReadINIStr $G_BUCKET_COUNT "$G_INIFILE_PATH" "BucketList" "FileCount"
  StrCpy ${L_LAST_CHANGE} $G_BUCKET_COUNT
  !insertmacro DELETE_LAST_ENTRY
  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_CONVERT_ESTIMATE)$(PFI_LANG_CONVERT_WAITING)"
  SetDetailsPrint listonly
  DetailPrint ""
  DetailPrint "$(PFI_LANG_CONVERT_TOTALFILES)"
  DetailPrint ""
  DetailPrint ""

  Call GetLocalTimeAsMin100
  Pop ${L_START_TIME}
  WriteINIStr "$G_INIFILE_PATH" "BucketList" "StartTime" "${L_START_TIME}"

  ReadINIStr ${L_CORPUS_SIZE} "$G_INIFILE_PATH" "BucketList" "TotalSize"
  StrCpy ${L_BYTES_DONE} 0

  ; If it takes more than one pass to process a particular bucket, we check once a minute that
  ; POPFile is still running (to avoid an infinite loop if popfileb.exe has crashed or been
  ; shutdown). The first check is due at 0 minutes elapsed time.

  StrCpy ${L_NEXT_EXECHECK} -1

loop:
  ReadINIStr $G_BUCKET_COUNT "$G_INIFILE_PATH" "BucketList" "FileCount"
  StrCpy $G_STILL_TO_DO 0

next_bucket:
  ReadINIStr ${L_BUCKET_PATH} "$G_INIFILE_PATH"  "Bucket-$G_BUCKET_COUNT" "File_Name"
  IfFileExists  "${L_BUCKET_PATH}" check_next_bucket
  ReadINIStr ${L_TEMP} "$G_INIFILE_PATH" "Bucket-$G_BUCKET_COUNT" "Stop_Time"
  StrCmp ${L_TEMP} "0" 0 update_ptr

  ; This file has been deleted since we last checked its status.
  ; Record the current time (to indicate we have noticed this change in status)

  Call GetLocalTimeAsMin100
  Pop ${L_TEMP}
  WriteINIStr "$G_INIFILE_PATH" "Bucket-$G_BUCKET_COUNT" "Stop_Time" "${L_TEMP}"

  System::Int64Op ${L_TEMP} - ${L_START_TIME}
  Pop ${L_TEMP}
  WriteINIStr "$G_INIFILE_PATH" "Bucket-$G_BUCKET_COUNT" "ElapsTime" "${L_TEMP}"
  Push ${L_TEMP}

  ; Update our wild guess at the time to complete the corpus conversion
  ; (the guess remains unchanged until the next time we notice a bucket file has been deleted)

  ReadINIStr ${L_TEMP} "$G_INIFILE_PATH" "Bucket-$G_BUCKET_COUNT" "File_Size"
  IntOp ${L_BYTES_DONE} ${L_BYTES_DONE} + ${L_TEMP}
  Pop ${L_TEMP}

  IntOp ${L_BYTES_RATE} ${L_BYTES_DONE} / ${L_TEMP}
  IntOp ${L_BYTES_LEFT} ${L_CORPUS_SIZE} - ${L_BYTES_DONE}
  IntOp ${L_TIME_LEFT} ${L_BYTES_LEFT} / ${L_BYTES_RATE}

  StrCpy ${L_TEMP} "00${L_TIME_LEFT}" 2 -2
  StrCpy ${L_TIME_LEFT} ${L_TIME_LEFT} -2
  StrCmp ${L_TIME_LEFT} "" 0 update_timeleft
  StrCpy ${L_TIME_LEFT} "0"

update_timeleft:
  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_CONVERT_ESTIMATE)${L_TIME_LEFT}.${L_TEMP} $(PFI_LANG_CONVERT_MINUTES)"
  SetDetailsPrint listonly
  Goto update_ptr

check_next_bucket:
  IntOp $G_STILL_TO_DO $G_STILL_TO_DO + 1

update_ptr:
  IntOp  $G_BUCKET_COUNT $G_BUCKET_COUNT - 1
  IntCmp  $G_BUCKET_COUNT 0 get_elapsed_time get_elapsed_time next_bucket

get_elapsed_time:
  Call GetLocalTimeAsMin100
  Pop $G_ELAPSED_TIME
  System::Int64Op $G_ELAPSED_TIME - ${L_START_TIME}
  Pop $G_ELAPSED_TIME
  StrCpy $G_DECPLACES "00$G_ELAPSED_TIME" 2 -2
  StrCpy $G_ELAPSED_TIME $G_ELAPSED_TIME -2
  StrCmp $G_ELAPSED_TIME "" 0 update_display
  StrCpy $G_ELAPSED_TIME "0"

update_display:
  StrCmp $G_STILL_TO_DO "0" all_converted
  StrCmp ${L_LAST_CHANGE} $G_STILL_TO_DO same_bucket
  StrCpy  ${L_LAST_CHANGE} $G_STILL_TO_DO
  Goto display_progress

same_bucket:
  IntCmp $G_ELAPSED_TIME ${L_NEXT_EXECHECK} 0 delete_last_entry 0
  IntOp ${L_NEXT_EXECHECK} ${L_NEXT_EXECHECK} + 1
  Push "${L_CONVERTEXE}"
  Call CheckIfLocked
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" not_running

delete_last_entry:
  !insertmacro DELETE_LAST_ENTRY

display_progress:
  StrCmp $G_STILL_TO_DO "1" special_case
  DetailPrint "$(PFI_LANG_CONVERT_PROGRESS_N)"
  Sleep ${C_LOOP_DELAY}
  Goto loop

special_case:
  DetailPrint "$(PFI_LANG_CONVERT_PROGRESS_1)"
  Sleep ${C_LOOP_DELAY}
  Goto loop

all_converted:
  DetailPrint ""
  SetDetailsPrint both
  DetailPrint "$(PFI_LANG_CONVERT_SUMMARY)"
  SetDetailsPrint listonly
  Call GetLocalTimeAsMin100
  Pop ${L_TEMP}
  WriteINIStr "$G_INIFILE_PATH" "BucketList" "Stop_Time" "${L_TEMP}"
  DetailPrint ""
  FlushINI "$G_INIFILE_PATH"

#exit:

  ; We must now unload the system.dll (this allows NSIS to delete the DLL from $PLUGINSDIR)

  SetPluginUnload manual
  System::Free 0

  Pop ${L_TIME_LEFT}
  Pop ${L_TEMP}
  Pop ${L_START_TIME}
  Pop ${L_POPFILE_USER}
  Pop ${L_POPFILE_ROOT}
  Pop ${L_NEXT_EXECHECK}
  Pop ${L_LAST_CHANGE}
  Pop ${L_CORPUS_SIZE}
  Pop ${L_CONVERTEXE}
  Pop ${L_BUCKET_PATH}
  Pop ${L_BYTES_RATE}
  Pop ${L_BYTES_LEFT}
  Pop ${L_BYTES_DONE}

  Pop ${L_RESERVED}
  !undef L_RESERVED

  !undef L_BYTES_DONE
  !undef L_BYTES_LEFT
  !undef L_BYTES_RATE
  !undef L_BUCKET_PATH
  !undef L_CONVERTEXE
  !undef L_CORPUS_SIZE
  !undef L_LAST_CHANGE
  !undef L_NEXT_EXECHECK
  !undef L_POPFILE_ROOT
  !undef L_POPFILE_USER
  !undef L_START_TIME
  !undef L_TEMP
  !undef L_TIME_LEFT

SectionEnd


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
#
#         Call GetParameters
#         Pop $R0
#
#         ($R0 will hold everything found on the command-line after the 'monitorcc.exe' part)
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
# Installer Function: CheckIfLocked
#
# Checks if a particular file (an EXE file, for example) is being used. If the specified file
# is no longer in use, this function returns an empty string (otherwise it returns the input
# parameter unchanged).
#
# Inputs:
#         (top of stack)     - the full pathname of the file to be checked
#
# Outputs:
#         (top of stack)     - if file is no longer in use, an empty string ("") is returned
#                              otherwise the input string is returned
#
#  Usage:
#
#         Push "C:\Program Files\POPFile\wperl.exe"
#         Call CheckIfLocked
#         Pop $R0
#
#        (if the file is no longer in use, $R0 will be "")
#        (if the file is still being used, $R0 will be "C:\Program Files\POPFile\wperl.exe")
#--------------------------------------------------------------------------

Function CheckIfLocked
  !define L_EXE           $R9   ; full path to the file (normally an EXE file) to be checked
  !define L_FILE_HANDLE   $R8

  Exch ${L_EXE}
  Push ${L_FILE_HANDLE}

  IfFileExists "${L_EXE}" 0 unlocked_exit
  SetFileAttributes "${L_EXE}" NORMAL

  ClearErrors
  FileOpen ${L_FILE_HANDLE} "${L_EXE}" a
  FileClose ${L_FILE_HANDLE}
  IfErrors exit

unlocked_exit:
  StrCpy ${L_EXE} ""

exit:
  Pop ${L_FILE_HANDLE}
  Exch ${L_EXE}

  !undef L_EXE
  !undef L_FILE_HANDLE
FunctionEnd

#--------------------------------------------------------------------------
# End of 'MonitorCC.nsi'
#--------------------------------------------------------------------------
