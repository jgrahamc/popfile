#--------------------------------------------------------------------------
#
# transMCC.nsi --- This is the NSIS script used to create a special version
#                  of the Corpus Conversion Utility.  This version makes it
#                  easy to check the various language strings used by the
#                  real utility.
#
# Copyright (c) 2001-2004 John Graham-Cumming
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
;
; Expect 3 compiler warnings, all related to standard NSIS language files which are out-of-date
;
; NOTE: The language selection menu order used in this program assumes that the NSIS MUI
; 'Japanese.nsh' language file has been patched to use 'Nihongo' instead of 'Japanese'
; [see 'SMALL NSIS PATCH REQUIRED' in the 'Support for Japanese text processing' section
; of the header comment at the start of the 'installer.nsi' file]

#--------------------------------------------------------------------------
# Optional run-time command-line switch (used by 'transmcc.exe')
#--------------------------------------------------------------------------
#
# /abort
#
# If this command-line switch is present, the utility displays the fatal error messages
# and terminates via an 'Abort' instruction in order to display the MUI header text used
# when corpus conversion has failed.
#
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

  !define C_PFI_PRODUCT      "Corpus Conversion Testbed"
  Name                       "${C_PFI_PRODUCT}"

  !define C_PFI_VERSION      "0.1.3"

  ; Mention the version number in the window title

  Caption                    "${C_PFI_PRODUCT} ${C_PFI_VERSION}"

  ;------------------------------------------------
  ; Constants used to specify delays (in milliseconds)
  ;------------------------------------------------

  !define C_STANDARD_DELAY   3000

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
  VIAddVersionKey "FileDescription"  "POPFile Corpus Conversion Testbed"
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

  !define MUI_ICON                            "..\POPFileIcon\popfile.ico"

  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP              "hdr-common-test.bmp"
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

  ;----------------------------------------------------------------
  ;  Interface Settings - Abort Warning Settings
  ;----------------------------------------------------------------

  ; Show a message box with a warning when the user closes the installation

  !define MUI_ABORTWARNING

  ;----------------------------------------------------------------
  ; Language Settings for MUI pages
  ;----------------------------------------------------------------

  ; Override the standard prompt (to match the one used by the main installer)

  !define MUI_LANGDLL_WINDOWTITLE             "Language Selection"

  ; Use same language setting as the installer (assumes the translator testbed installer)

  !define MUI_LANGDLL_REGISTRY_ROOT           "HKCU"
  !define MUI_LANGDLL_REGISTRY_KEY            "SOFTWARE\POPFile Project\PFI Testbed\MRI"
  !define MUI_LANGDLL_REGISTRY_VALUENAME      "Installer Language"

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

  ; Global variables used to simplify translation of the conversion progress messages

  Var G_BUCKET_COUNT      ; number of bucket files to be converted
  Var G_ELAPSED_TIME      ; elapsed time for corpus conversion
  Var G_DECPLACES         ; used to hold the 2 decimal places when displaying the elapsed time
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
  ; Used in 'ConvertCorpus.nsi' to define the languages to be supported
  ;--------------------------------------------------------------------------

  ; Macro used to load the files required for each language:
  ; (1) The MUI_LANGUAGE macro loads the standard MUI text strings for a particular language
  ; (2) '*-pfi.nsh' contains the text strings used for pages, progress reports, logs etc

  !macro PFI_LANG_LOAD LANG
    !insertmacro MUI_LANGUAGE "${LANG}"
    !include "..\languages\${LANG}-pfi.nsh"
  !macroend

  ;-----------------------------------------
  ; Select the languages to be supported by the utility
  ; Currently a subset of the languages supported by NSIS MUI 1.68 (using the NSIS names)
  ;-----------------------------------------

  ; Default language (appears first in the drop-down list)

  !insertmacro PFI_LANG_LOAD "English"

  ; Additional languages supported by the utility

  !include "..\pfi-languages.nsh"

#--------------------------------------------------------------------------
# General settings
#--------------------------------------------------------------------------

  ; Specify NSIS output filename

  OutFile "transmcc.exe"

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
# Functions used to manipulate the contents of the details view
#--------------------------------------------------------------------------

  !define C_LVM_GETITEMCOUNT        0x1004
  !define C_LVM_DELETEITEM          0x1008

; This function deletes one element (i.e. one row) from the details view
; Push the index of the element to delete before calling this function

Function DeleteDetailViewItem
  Exch $0
  Push $1
  FindWindow $1 "#32770" "" $HWNDPARENT
  GetDlgItem $1 $1 0x3F8                  ; This is the Control ID of the details view
  SendMessage $1 ${C_LVM_DELETEITEM} $0 0
  Pop $1
  Pop $0
FunctionEnd

; This function gets the count of entries (i.e. rows) from the details view
; You must Pop the result value after calling this function

Function GetDetailViewItemCount
  Push $1
  FindWindow $1 "#32770" "" $HWNDPARENT
  GetDlgItem $1 $1 0x3F8                  ; This is the Control ID of the details view
  SendMessage $1 ${C_LVM_GETITEMCOUNT} 0 0 $1
  Exch $1
FunctionEnd

; Macro to make it easy to delete the last row in the details window

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
# Installer Section: ConvertCorpus
#--------------------------------------------------------------------------

Section ConvertCorpus

  SetDetailsPrint listonly

  Call GetParameters
  Pop $G_STILL_TO_DO
  StrCmp $G_STILL_TO_DO "/abort" show_fatal_errors

  DetailPrint "PFI_LANG_CONVERT_MUTEX"
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(PFI_LANG_CONVERT_MUTEX)"
  !insertmacro DELETE_LAST_ENTRY

  DetailPrint "PFI_LANG_CONVERT_PRIVATE"
  MessageBox MB_OK|MB_ICONINFORMATION "$(PFI_LANG_CONVERT_PRIVATE)"
  !insertmacro DELETE_LAST_ENTRY

  DetailPrint "PFI_LANG_CONVERT_NOFILE"
  MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_NOFILE)\
      $\r$\n$\r$\n\
      ($EXEDIR)"
  !insertmacro DELETE_LAST_ENTRY

  Goto continue

show_fatal_errors:
  DetailPrint "PFI_LANG_CONVERT_ENVNOTSET"
  MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_ENVNOTSET) (ITAIJIDICTPATH)"
  !insertmacro DELETE_LAST_ENTRY

  DetailPrint "PFI_LANG_CONVERT_NOPOPFILE"
  MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_NOPOPFILE) (POPFILE_ROOT)"
  !insertmacro DELETE_LAST_ENTRY

  DetailPrint "PFI_LANG_CONVERT_NOKAKASI"
  MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_NOKAKASI) (ITAIJIDICTPATH)"
  !insertmacro DELETE_LAST_ENTRY

  DetailPrint "PFI_LANG_CONVERT_STARTERR"
  MessageBox MB_OK|MB_ICONSTOP|MB_TOPMOST "$(PFI_LANG_CONVERT_STARTERR)"
  !insertmacro DELETE_LAST_ENTRY

  DetailPrint ""
  DetailPrint "$(PFI_LANG_CONVERT_FATALERR)"
  DetailPrint ""
  MessageBox MB_OK|MB_ICONSTOP|MB_TOPMOST "$(PFI_LANG_CONVERT_FATALERR)"
  Abort

continue:
  StrCpy $G_BUCKET_COUNT 2
  StrCpy $G_STILL_TO_DO 2

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_CONVERT_ESTIMATE)$(PFI_LANG_CONVERT_WAITING)"
  SetDetailsPrint listonly
  DetailPrint ""
  DetailPrint "$(PFI_LANG_CONVERT_TOTALFILES)"
  DetailPrint ""
  DetailPrint ""

  ; Bucket 1, Pass 1

  Sleep ${C_STANDARD_DELAY}

  StrCpy $G_DECPLACES     "05"
  StrCpy $G_ELAPSED_TIME  "0"
  !insertmacro DELETE_LAST_ENTRY
  DetailPrint "$(PFI_LANG_CONVERT_PROGRESS_N)"

  ; Bucket 1, Pass 2

  Sleep ${C_STANDARD_DELAY}

  StrCpy $G_DECPLACES     "10"
  StrCpy $G_ELAPSED_TIME  "0"
  !insertmacro DELETE_LAST_ENTRY
  DetailPrint "$(PFI_LANG_CONVERT_PROGRESS_N)"

  ; Bucket 1, Pass 3

  Sleep ${C_STANDARD_DELAY}

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_CONVERT_ESTIMATE)1.20 $(PFI_LANG_CONVERT_MINUTES)"
  SetDetailsPrint listonly

  StrCpy $G_BUCKET_COUNT 1
  StrCpy $G_STILL_TO_DO 1

  StrCpy $G_DECPLACES    "23"
  StrCpy $G_ELAPSED_TIME "0"
  DetailPrint "$(PFI_LANG_CONVERT_PROGRESS_1)"

  ; Bucket 2, Pass 1

  Sleep ${C_STANDARD_DELAY}

  StrCpy $G_DECPLACES     "35"
  StrCpy $G_ELAPSED_TIME  "0"
  !insertmacro DELETE_LAST_ENTRY
  DetailPrint "$(PFI_LANG_CONVERT_PROGRESS_1)"

  ; Bucket 2, Pass 2

  Sleep ${C_STANDARD_DELAY}

  StrCpy $G_DECPLACES     "50"
  StrCpy $G_ELAPSED_TIME  "0"
  !insertmacro DELETE_LAST_ENTRY
  DetailPrint "$(PFI_LANG_CONVERT_PROGRESS_1)"

  ; Bucket 2, Pass 3

  Sleep ${C_STANDARD_DELAY}

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_CONVERT_ESTIMATE)1.20 $(PFI_LANG_CONVERT_MINUTES)"
  SetDetailsPrint listonly

  Sleep ${C_STANDARD_DELAY}

  ; All converted

  StrCpy $G_DECPLACES     "65"
  StrCpy $G_ELAPSED_TIME  "0"

  DetailPrint ""
  SetDetailsPrint both
  DetailPrint "$(PFI_LANG_CONVERT_SUMMARY)"
  SetDetailsPrint listonly
  DetailPrint ""

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
# End of 'transMCC.nsi'
#--------------------------------------------------------------------------
