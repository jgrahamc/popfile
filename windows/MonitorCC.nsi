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

; This version of the script has been tested with the "NSIS 2 Release Candidate 4" compiler,
; released 2 February 2004, with no patches applied.
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
#    PERLDIR=full path to the folder where wperl.exe has been installed (created by installer)
#    ROOTDIR=full path to the folder where POPFile has been installed (created by installer)
#    USERDIR=full path to the folder with the POPFile configuration data (created by installer)
#    KReboot=either 'yes' or 'no' (created by installer)
#    ITAIJIDICTPATH=full path to the 'itaijidict' file (created by installer if KReboot=yes)
#    KANWADICTPATH=full path to the 'kanwadict' file (created by installer if KReboot=yes)
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

  ;--------------------------------------------------------------------------
  ; POPFile constants have been given names beginning with 'C_' (eg C_README)
  ;--------------------------------------------------------------------------

  !define C_PFI_PRODUCT  "POPFile Corpus Conversion Monitor"
  Name                   "${C_PFI_PRODUCT}"

  !define C_PFI_VERSION  "0.1.3"

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

  VIProductVersion "${C_PFI_VERSION}.0"

  VIAddVersionKey "ProductName" "${C_PFI_PRODUCT}"
  VIAddVersionKey "Comments" "POPFile Homepage: http://popfile.sf.net"
  VIAddVersionKey "CompanyName" "The POPFile Project"
  VIAddVersionKey "LegalCopyright" "� 2004  John Graham-Cumming"
  VIAddVersionKey "FileDescription" "POPFile Corpus Conversion Monitor"
  VIAddVersionKey "FileVersion" "${C_PFI_VERSION}"

  VIAddVersionKey "Build" "Multi-Language"

  VIAddVersionKey "Build Date/Time" "${__DATE__} @ ${__TIME__}"
  VIAddVersionKey "Build Script" "${__FILE__}$\r$\n(${__TIMESTAMP__})"

#--------------------------------------------------------------------------
# Configure the MUI pages
#--------------------------------------------------------------------------

  ;----------------------------------------------------------------
  ; Interface Settings - General Interface Settings
  ;----------------------------------------------------------------

  ; The icon file for the utility

  !define MUI_ICON    "POPFileIcon\popfile.ico"

  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP "hdr-common.bmp"
  !define MUI_HEADERIMAGE_RIGHT

  ;----------------------------------------------------------------
  ;  Interface Settings - Interface Resource Settings
  ;----------------------------------------------------------------

  ; The banner provided by the default 'modern.exe' UI does not provide much room for the
  ; two lines of text, e.g. the German version is truncated, so we use a custom UI which
  ; provides slightly wider text areas. Each area is still limited to a single line of text.

  !define MUI_UI "UI\pfi_modern.exe"

  ; The 'hdr-common.bmp' logo is only 90 x 57 pixels, much smaller than the 150 x 57 pixel
  ; space provided by the default 'modern_headerbmpr.exe' UI, so we use a custom UI which
  ; leaves more room for the TITLE and SUBTITLE text.

  !define MUI_UI_HEADERIMAGE_RIGHT "UI\pfi_headerbmpr.exe"

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

  !define MUI_CUSTOMFUNCTION_GUIINIT PFIGUIInit

  ;----------------------------------------------------------------
  ; Language Settings for MUI pages
  ;----------------------------------------------------------------

  ; Override the standard prompt (to match the one used by the main installer)

  !define MUI_LANGDLL_WINDOWTITLE "Language Selection"

  ; Use same language setting as the POPFile installer (if this registry entry
  ; is not found, the user will be asked to select the language to be used)

  !define MUI_LANGDLL_REGISTRY_ROOT "HKLM"
  !define MUI_LANGDLL_REGISTRY_KEY "SOFTWARE\POPFile"
  !define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"

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
  ; Currently a subset of the languages supported by NSIS MUI 1.68 (using the NSIS names)
  ;-----------------------------------------

  ; Default language (appears first in the drop-down list)

  !insertmacro PFI_LANG_LOAD "English"

  ; Additional languages supported by the utility

  ; To remove a language, comment-out the relevant '!insertmacro PFI_LANG_LOAD' line below.

  ; Entries will appear in the drop-down list of languages in the order given below
  ; (the order used here ensures that the list entries appear in alphabetic order).

  !insertmacro PFI_LANG_LOAD "Bulgarian"
  !insertmacro PFI_LANG_LOAD "SimpChinese"
  !insertmacro PFI_LANG_LOAD "TradChinese"
  !insertmacro PFI_LANG_LOAD "Czech"
  !insertmacro PFI_LANG_LOAD "Danish"
  !insertmacro PFI_LANG_LOAD "German"
  !insertmacro PFI_LANG_LOAD "Spanish"
  !insertmacro PFI_LANG_LOAD "French"
  !insertmacro PFI_LANG_LOAD "Greek"
  !insertmacro PFI_LANG_LOAD "Italian"
  !insertmacro PFI_LANG_LOAD "Japanese"
  !insertmacro PFI_LANG_LOAD "Korean"
  !insertmacro PFI_LANG_LOAD "Hungarian"
  !insertmacro PFI_LANG_LOAD "Dutch"
  !insertmacro PFI_LANG_LOAD "Norwegian"
  !insertmacro PFI_LANG_LOAD "Polish"
  !insertmacro PFI_LANG_LOAD "Portuguese"
  !insertmacro PFI_LANG_LOAD "PortugueseBR"
  !insertmacro PFI_LANG_LOAD "Russian"
  !insertmacro PFI_LANG_LOAD "Slovak"
  !insertmacro PFI_LANG_LOAD "Finnish"
  !insertmacro PFI_LANG_LOAD "Swedish"
  !insertmacro PFI_LANG_LOAD "Turkish"
  !insertmacro PFI_LANG_LOAD "Ukrainian"

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

  ;Things that need to be extracted on startup (keep these lines before any File command!)
  ;Only useful for BZIP2 compression

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
# Used to complete the initialisation of the utility. This code was moved from
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

  ; Adjust low order Int32 if it is negative

  StrCpy $3 $1 1
  StrCmp $3 "-" 0 low_order_ok
  System::Int64Op  $1 + 4294967296
  Pop $1

low_order_ok:
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
  !define L_CORPUS_SIZE   $R5     ; total number of bytes in all the bucket files in the list
  !define L_LAST_CHANGE   $R4     ; used to detect when a bucket file has been deleted
  !define L_MPBINDIR      $R3     ; folder containing wperl.exe file
  !define L_START_TIME    $R2     ; time in Min100 units when we started the corpus conversion
  !define L_TEMP          $R1
  !define L_TIME_LEFT     $R0     ; estimated time remaining (updated when a file is deleted)

  !define L_RESERVED      $0      ; used to get result from the System.dll plugin
  Push ${L_RESERVED}

  Push ${L_BYTES_DONE}
  Push ${L_BYTES_LEFT}
  Push ${L_BYTES_RATE}
  Push ${L_BUCKET_PATH}
  Push ${L_CORPUS_SIZE}
  Push ${L_LAST_CHANGE}
  Push ${L_MPBINDIR}
  Push ${L_START_TIME}
  Push ${L_TEMP}
  Push ${L_TIME_LEFT}

  SetDetailsPrint listonly

  ; Get minimal Perl binary ('wperl.exe') folder location from the INI file

  ReadINIStr ${L_MPBINDIR} "$G_INIFILE_PATH" "Settings" "PERLDIR"
  StrCmp  ${L_MPBINDIR} "" no_perl_path

  ; Get POPFile program ('popfile.pl') folder location from the INI file

  ReadINIStr $G_ROOTDIR "$G_INIFILE_PATH" "Settings" "ROOTDIR"
  StrCmp  $G_ROOTDIR "" no_root_path

  ; Get POPFile configuration data ('popfile.cfg') folder location from the INI file

  ReadINIStr $G_USERDIR "$G_INIFILE_PATH" "Settings" "USERDIR"
  StrCmp  $G_USERDIR "" no_user_path

  ReadINIStr ${L_TEMP} "$G_INIFILE_PATH" "Settings" "KReboot"
  StrCmp ${L_TEMP} "no" kakasi_done

  ; We are running on a Win9x system and a reboot is required to complete the installation
  ; of the Kakasi package. So we need to set up the two Kakasi environment variables before
  ; running POPFile to do the corpus conversion before the reboot.

  ReadINIStr ${L_TEMP} "$G_INIFILE_PATH" "Settings" "ITAIJIDICTPATH"
  StrCmp ${L_TEMP} "" no_itaiji_path

  ReadINIStr $G_STILL_TO_DO "$G_INIFILE_PATH" "Settings" "KANWADICTPATH"
  StrCmp $G_STILL_TO_DO "" no_kanwa_path

  System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("ITAIJIDICTPATH", "${L_TEMP}").r0'
  StrCmp $0 0 0 itaiji_set_ok
  MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_ENVNOTSET) (ITAIJIDICTPATH)"
  Goto exit

itaiji_set_ok:
  System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("KANWADICTPATH", "$G_STILL_TO_DO").r0'
  StrCmp $0 0 0 kakasi_done
  MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_ENVNOTSET) (KANWADICTPATH)"
  Goto exit

no_perl_path:
  MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_NOPOPFILE) (wperl.exe)"
  Goto exit

no_root_path:
  MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_NOPOPFILE) (POPFILE_ROOT)"
  Goto exit

no_user_path:
  MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_NOPOPFILE) (POPFILE_USER)"
  Goto exit

no_itaiji_path:
  MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_NOKAKASI) (ITAIJIDICTPATH)"
  Goto exit

no_kanwa_path:
  MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_NOKAKASI) (KANWADICTPATH)"
  Goto exit

start_error:
  MessageBox MB_OK|MB_ICONSTOP|MB_TOPMOST "$(PFI_LANG_CONVERT_STARTERR)"
  Goto exit

kakasi_done:
  GetFullPathName /SHORT ${L_TEMP} $G_ROOTDIR
  Push ${L_TEMP}
  Call StrLower
  Pop ${L_TEMP}
  System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("POPFILE_ROOT", "${L_TEMP}").r0'
  StrCmp $0 0 0 root_set_ok
  MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_ENVNOTSET) (POPFILE_ROOT)"
  Goto exit

root_set_ok:
  GetFullPathName /SHORT ${L_TEMP} $G_USERDIR
  Push ${L_TEMP}
  Call StrLower
  Pop ${L_TEMP}
  System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("POPFILE_USER", "${L_TEMP}").r0'
  StrCmp $0 0 0 user_set_ok
  MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_ENVNOTSET) (POPFILE_USER)"
  Goto exit

user_set_ok:

  ; Temporary workaround: need to set the working directory otherwise POPFile will not run

  SetOutpath $G_ROOTDIR

  ClearErrors
  Exec '"${L_MPBINDIR}\wperl.exe" "$G_ROOTDIR\popfile.pl"'
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

exit:

  ; We must now unload the system.dll (this allows NSIS to delete the DLL from $PLUGINSDIR)

  SetPluginUnload manual
  System::Free 0

  Pop ${L_TIME_LEFT}
  Pop ${L_TEMP}
  Pop ${L_START_TIME}
  Pop ${L_MPBINDIR}
  Pop ${L_LAST_CHANGE}
  Pop ${L_CORPUS_SIZE}
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
  !undef L_CORPUS_SIZE
  !undef L_LAST_CHANGE
  !undef L_MPBINDIR
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
# Function StrLower
#
# Converts uppercase letters in a string into lowercase letters. Other characters unchanged.
#
# Inputs:
#         (top of stack)          - input string
#
# Outputs:
#         (top of stack)          - output string
#
#  Usage:
#
#    Push "C:\PROGRA~1\SQLPFILE"
#    Call StrLower
#    Pop $R0
#
#   ($R0 at this point is "c:\progra~1\sqlpfile")
#
#--------------------------------------------------------------------------

Function StrLower

  !define C_LOWERCASE    "abcdefghijklmnopqrstuvwxyz"

  Exch $0   ; The input string
  Push $2   ; Holds the result
  Push $3   ; A character from the input string
  Push $4   ; The offset to a character in the "validity check" string
  Push $5   ; A character from the "validity check" string
  Push $6   ; Holds the current "validity check" string

  StrCpy $2 ""

next_input_char:
  StrCpy $3 $0 1              ; Get next character from the input string
  StrCmp $3 "" done
  StrCpy $6 ${C_LOWERCASE}$3  ; Add character to end of "validity check" to guarantee a match
  StrCpy $0 $0 "" 1
  StrCpy $4 -1

next_valid_char:
  IntOp $4 $4 + 1
  StrCpy $5 $6 1 $4               ; Extract next from "validity check" string
  StrCmp $3 $5 0 next_valid_char  ; We will ALWAYS find a match in the "validity check" string
  StrCpy $2 $2$5                  ; Use "validity check" char to ensure result uses lowercase
  goto next_input_char

done:
  StrCpy $0 $2                ; Result is a string with no uppercase letters
  Pop $6
  Pop $5
  Pop $4
  Pop $3
  Pop $2
  Exch $0                     ; place result on top of the stack

  !undef C_LOWERCASE

FunctionEnd

#--------------------------------------------------------------------------
# End of 'MonitorCC.nsi'
#--------------------------------------------------------------------------