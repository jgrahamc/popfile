#--------------------------------------------------------------------------
#
# addssl.nsi --- This is the NSIS script used to create a utility which downloads and
#                installs SSL support for an existing POPFile 0.22.0 (or later) installation.
#
#                The version of Module.pm distributed with POPFile 0.22.0 results in extremely
#                slow message downloads (e.g. 6 minutes for a 2,713 byte msg) so this utility
#                will apply a patch to update Module.pm v1.40 to v1.41 (the original file will
#                be backed up as Module.pm.bk1). The patch is only applied if v1.40 is found.
#                A patch status message is always displayed.
#
#                An 'include' file is used to ensure this utility and the main POPFile
#                installer download and install the same SSL support files.
#
# Copyright (c) 2004-2005 John Graham-Cumming
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

  ;------------------------------------------------
  ; How the Module.pm patch was created
  ;------------------------------------------------

  ; The patch used to update Module.pm v1.40 to v1.41 was created using the VPATCH package
  ; which is supplied with NSIS. The command used to create the patch was:
  ;   GenPat.exe Module.pm Module_ssl.pm Module_ssl.pat
  ; where Module.pm was CVS version 1.40 and Module_ssl.pm was CVS version 1.41.

#--------------------------------------------------------------------------
# Compile-time command-line switches (used by 'makensis.exe')
#--------------------------------------------------------------------------
#
# /DENGLISH_MODE
#
# To build an 'SSL Setup' wizard that only displays English messages (so there is no need to
# ensure all of the non-English *-pfi.nsh files are up-to-date), supply the command-line
# switch /DENGLISH_MODE when compiling this script.
#
#--------------------------------------------------------------------------

  ;------------------------------------------------
  ; Define PFI_VERBOSE to get more compiler output
  ;------------------------------------------------

## !define PFI_VERBOSE

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

  ; This build is for use with the POPFile installer-created installations

  !define C_PFI_PRODUCT  "POPFile"

  Name                   "POPFile SSL Setup"

  !define C_PFI_VERSION  "0.0.14"

  ; Mention the wizard's version number in the window title

  Caption                "POPFile SSL Setup v${C_PFI_VERSION}"

  ; Name to be used for the program file (also used for the 'Version Information')

  !define C_OUTFILE      "addssl.exe"


#--------------------------------------------------------------------------
# User Registers (Global)
#--------------------------------------------------------------------------

  ; This script uses 'User Variables' (with names starting with 'G_') to hold GLOBAL data.

  Var G_ROOTDIR            ; full path to the folder used for the POPFile program files
  Var G_MPLIBDIR           ; full path to the folder used for most of the minimal Perl files

  Var G_PLS_FIELD_1        ; used to customize some language strings

  ; NSIS provides 20 general purpose user registers:
  ; (a) $R0 to $R9   are used as local registers
  ; (b) $0 to $9     are used as additional local registers

  ; Local registers referred to by 'defines' use names starting with 'L_' (eg L_LNE, L_OLDUI)
  ; and the scope of these 'defines' is limited to the "routine" where they are used.

  ; In earlier versions of the NSIS compiler, 'User Variables' did not exist, and the convention
  ; was to use $R0 to $R9 as 'local' registers and $0 to $9 as 'global' ones. This is why this
  ; script uses registers $R0 to $R9 in preference to registers $0 to $9.

  ; POPFile constants have been given names beginning with 'C_' (eg C_README)
  ; except for 'IO_NL' and 'MB_NL' which are used when assembling multi-line strings


#--------------------------------------------------------------------------
# Use the "Modern User Interface"
#--------------------------------------------------------------------------

  !include "MUI.nsh"


#--------------------------------------------------------------------------
# Include private library functions and macro definitions
#--------------------------------------------------------------------------

  ; Avoid compiler warnings by disabling the functions and definitions we do not use

  !define ADDSSL

  !include "..\pfi-library.nsh"


#--------------------------------------------------------------------------
# Version Information settings (for the wizard's EXE file)
#--------------------------------------------------------------------------

  ; 'VIProductVersion' format is X.X.X.X where X is a number in range 0 to 65535
  ; representing the following values: Major.Minor.Release.Build

  VIProductVersion                          "${C_PFI_VERSION}.0"

  VIAddVersionKey "ProductName"             "POPFile SSL Setup wizard"
  VIAddVersionKey "Comments"                "POPFile Homepage: http://getpopfile.org/"
  VIAddVersionKey "CompanyName"             "The POPFile Project"
  VIAddVersionKey "LegalCopyright"          "Copyright (c) 2005  John Graham-Cumming"
  VIAddVersionKey "FileDescription"         "Installs SSL support for POPFile 0.22 or later"
  VIAddVersionKey "FileVersion"             "${C_PFI_VERSION}"
  VIAddVersionKey "OriginalFilename"        "${C_OUTFILE}"

  !ifndef ENGLISH_MODE
    VIAddVersionKey "Build"                 "Multi-Language"
  !else
    VIAddVersionKey "Build"                 "English-Mode"
  !endif

  VIAddVersionKey "Build Date/Time"         "${__DATE__} @ ${__TIME__}"
  !ifdef C_PFI_LIBRARY_VERSION
    VIAddVersionKey "Build Library Version" "${C_PFI_LIBRARY_VERSION}"
  !endif
  VIAddVersionKey "Build Script"            "${__FILE__}${MB_NL}(${__TIMESTAMP__})"


#--------------------------------------------------------------------------
# Configure the MUI pages
#--------------------------------------------------------------------------

  ;----------------------------------------------------------------
  ; Interface Settings - General Interface Settings
  ;----------------------------------------------------------------

  !define MUI_ICON                            "..\POPFileIcon\popfile.ico"

  ; The "Header" bitmap appears on all pages of the wizard (except Welcome & Finish pages)

  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP              "hdr-update.bmp"
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
  ;  Interface Settings - Welcome/Finish Page Interface Settings
  ;----------------------------------------------------------------

  ; The "Special" bitmap appears on the "Welcome" and "Finish" pages

  !define MUI_WELCOMEFINISHPAGE_BITMAP        "special-update.bmp"

  ;----------------------------------------------------------------
  ;  Interface Settings - Installer Finish Page Interface Settings
  ;----------------------------------------------------------------

  ; Debug aid: The log window shows progress messages

#  ShowInstDetails show
  !define MUI_FINISHPAGE_NOAUTOCLOSE

  ;----------------------------------------------------------------
  ;  Interface Settings - Abort Warning Settings
  ;----------------------------------------------------------------

  ; Show a message box with a warning when the user closes the wizard before it has finished

  !define MUI_ABORTWARNING
  !define MUI_ABORTWARNING_TEXT               "$(PSS_LANG_ABORT_WARNING)"

  ;----------------------------------------------------------------
  ; Customize MUI - General Custom Function
  ;----------------------------------------------------------------

  ; Use a custom '.onGUIInit' function to permit language-specific error messages
  ; (the user-selected language is not available for use in the .onInit function)

  !define MUI_CUSTOMFUNCTION_GUIINIT          PFIGUIInit

  ;----------------------------------------------------------------
  ; Language Settings for MUI pages
  ;----------------------------------------------------------------

  ; Override the standard "Installer Language" title to avoid confusion.

  !define MUI_LANGDLL_WINDOWTITLE             "SSL Setup"

  ; Use the language selected when POPFile was last installed or updated
  ; (if the language setting is not found, the user will be asked to select a language)

  !define MUI_LANGDLL_REGISTRY_ROOT           "HKCU"
  !define MUI_LANGDLL_REGISTRY_KEY            "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI"
  !define MUI_LANGDLL_REGISTRY_VALUENAME      "Installer Language"


#--------------------------------------------------------------------------
# Define the Page order for the wizard
#--------------------------------------------------------------------------

  ;---------------------------------------------------
  ; Installer Page - Welcome
  ;---------------------------------------------------

  !define MUI_WELCOMEPAGE_TITLE                   "$(PSS_LANG_WELCOME_TITLE)"
  !define MUI_WELCOMEPAGE_TEXT                    "$(PSS_LANG_WELCOME_TEXT)"

  !insertmacro MUI_PAGE_WELCOME

  ;---------------------------------------------------
  ; Installer Page - License Page (uses English GPL)
  ;---------------------------------------------------

  !define MUI_LICENSEPAGE_CHECKBOX
  !define MUI_PAGE_HEADER_SUBTEXT                 "$(PSS_LANG_LICENSE_SUBHDR)"
  !define MUI_LICENSEPAGE_TEXT_BOTTOM             "$(PSS_LANG_LICENSE_BOTTOM)"

  !insertmacro MUI_PAGE_LICENSE                   "license.gpl"

  ;---------------------------------------------------
  ; Installer Page - Select installation Directory
  ;---------------------------------------------------

  ; Use a "pre" function to look for a registry entry for the 0.22.x version of POPFile
  ; (this build is intended for use with POPFile 0.22.x)

  !define MUI_PAGE_CUSTOMFUNCTION_PRE             "CheckForExistingInstallation"

  ; Use a "leave" function to check that the user has selected an appropriate folder

  !define MUI_PAGE_CUSTOMFUNCTION_LEAVE           "CheckInstallDir"

  ; This page is used to select the folder where the POPFile PROGRAM files can be found
  ; (we use this to generate the installation path for the POPFile SSL support files)

  !define MUI_PAGE_HEADER_TEXT                    "$(PSS_LANG_DESTNDIR_TITLE)"
  !define MUI_PAGE_HEADER_SUBTEXT                 "$(PSS_LANG_DESTNDIR_SUBTITLE)"
  !define MUI_DIRECTORYPAGE_TEXT_TOP              "$(PSS_LANG_DESTNDIR_TEXT_TOP)"
  !define MUI_DIRECTORYPAGE_TEXT_DESTINATION      "$(PSS_LANG_DESTNDIR_TEXT_DESTN)"

  !insertmacro MUI_PAGE_DIRECTORY

  ;---------------------------------------------------
  ; Installer Page - Install files
  ;---------------------------------------------------

  ; Override the standard "Installing..." page header

  !define MUI_PAGE_HEADER_TEXT                    "$(PSS_LANG_STD_HDR)"
  !define MUI_PAGE_HEADER_SUBTEXT                 "$(PSS_LANG_STD_SUBHDR)"

  ; Override the standard "Installation complete..." page header

  !define MUI_INSTFILESPAGE_FINISHHEADER_TEXT     "$(PSS_LANG_END_HDR)"
  !define MUI_INSTFILESPAGE_FINISHHEADER_SUBTEXT  "$(PSS_LANG_END_SUBHDR)"

  ; Override the standard "Installation Aborted..." page header

  !define MUI_INSTFILESPAGE_ABORTHEADER_TEXT      "$(PSS_LANG_ABORT_HDR)"
  !define MUI_INSTFILESPAGE_ABORTHEADER_SUBTEXT   "$(PSS_LANG_ABORT_SUBHDR)"

  !insertmacro MUI_PAGE_INSTFILES

  ;---------------------------------------------------
  ; Installer Page - Finish
  ;---------------------------------------------------

  !define MUI_FINISHPAGE_TITLE                    "$(PSS_LANG_FINISH_TITLE)"
  !define MUI_FINISHPAGE_TEXT                     "$(PSS_LANG_FINISH_TEXT)"

  !define MUI_FINISHPAGE_SHOWREADME               "$G_ROOTDIR\addssl.txt"
  !define MUI_FINISHPAGE_SHOWREADME_TEXT          "$(PSS_LANG_FINISH_README)"

  !insertmacro MUI_PAGE_FINISH


#--------------------------------------------------------------------------
# Language Support for the utility
#--------------------------------------------------------------------------

  ;-----------------------------------------
  ; Select the languages to be supported by the wizard
  ;-----------------------------------------

  ; At least one language must be specified for the wizard (the default is "English")

  !insertmacro PFI_LANG_LOAD "English"

  ; Conditional compilation: if ENGLISH_MODE is defined, support only 'English'

  !ifndef ENGLISH_MODE
      !include "..\pfi-languages.nsh"
  !endif


#--------------------------------------------------------------------------
# General settings
#--------------------------------------------------------------------------

  ; Specify NSIS output filename

  OutFile "${C_OUTFILE}"

  ; Ensure CRC checking cannot be turned off using the /NCRC command-line switch

  CRCcheck Force

#--------------------------------------------------------------------------
# Default Destination Folder
#--------------------------------------------------------------------------

  InstallDir "$PROGRAMFILES\${C_PFI_PRODUCT}\"

#--------------------------------------------------------------------------
# Reserve the files required by the wizard (to improve performance)
#--------------------------------------------------------------------------

  ; Things that need to be extracted on startup (keep these lines before any File command!)
  ; Only useful when solid compression is used (by default, solid compression is enabled
  ; for BZIP2 and LZMA compression)

  !insertmacro MUI_RESERVEFILE_LANGDLL
  !insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
  ReserveFile "${NSISDIR}\Plugins\NSISdl.dll"
  ReserveFile "${NSISDIR}\Plugins\System.dll"
  ReserveFile "${NSISDIR}\Plugins\untgz.dll"
  ReserveFile "${NSISDIR}\Plugins\vpatch.dll"


#--------------------------------------------------------------------------
# Installer Function: .onInit - the wizard starts by offering a choice of languages
#--------------------------------------------------------------------------

Function .onInit

  ; Conditional compilation: if ENGLISH_MODE is defined, support only 'English'

  !ifndef ENGLISH_MODE
        !insertmacro MUI_LANGDLL_DISPLAY
  !endif

FunctionEnd


#--------------------------------------------------------------------------
# Installer Function: PFIGUIInit
# (custom .onGUIInit function)
#
# Used to complete the initialization of the wizard.
# This code was moved from '.onInit' in order to permit the use of language-specific strings
# (the selected language is not available inside the '.onInit' function)
#--------------------------------------------------------------------------

Function PFIGUIInit

  !define L_RESERVED         $1    ; used in the system.dll call

  Push ${L_RESERVED}

  ; Ensure only one copy of this wizard (or any other POPFile installer) is running

  System::Call 'kernel32::CreateMutexA(i 0, i 0, t "OnlyOnePFI_mutex") i .r1 ?e'
  Pop ${L_RESERVED}
  StrCmp ${L_RESERVED} 0 mutex_ok
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(PSS_LANG_MUTEX)"
  Abort

mutex_ok:
  Pop ${L_RESERVED}

  !undef L_RESERVED

FunctionEnd


#--------------------------------------------------------------------------
# Installer Section: Prepare to download and install the SSL Support files
#--------------------------------------------------------------------------

Section "-prepare"

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_UPGRADE) $(PFI_LANG_TAKE_A_FEW_SECONDS)"
  SetDetailsPrint listonly

  DetailPrint "----------------------------------------------------"
  DetailPrint "POPFile SSL Setup v${C_PFI_VERSION}"
  DetailPrint "----------------------------------------------------"

  ; Make sure we do not try to add SSL support to an installation which is in use

  Call MakeRootDirSafe

  ; Important information about SSL support

  DetailPrint ""
  SetOutPath $G_ROOTDIR
  File "addssl.txt"
  DetailPrint ""

SectionEnd


#--------------------------------------------------------------------------
# Installer Section: Download and install POPFile SSL Support files
# (the 'include' file contains more than just the 'Section' code)
#--------------------------------------------------------------------------

  !include "..\getssl.nsh"


#--------------------------------------------------------------------------
# Installer Section: Apply the SSL speed-up patch if necessary then tidy up
#--------------------------------------------------------------------------

Section "-tidyup"

  ; Now patch Module.pm (if it needs to be patched)

  DetailPrint "$(PSS_LANG_PREPAREPATCH)"

  SetDetailsPrint none
  File "/oname=$PLUGINSDIR\patch.pat" "Module_ssl.pat"
  SetDetailsPrint listonly

  DetailPrint ""
  vpatch::vpatchfile "$PLUGINSDIR\patch.pat" "$G_ROOTDIR\POPFile\Module.pm" "$PLUGINSDIR\Module.ssl"
  Pop $G_PLS_FIELD_1

  SetDetailsPrint both
  DetailPrint "$(PSS_LANG_PATCHSTATUS)"
  SetDetailsPrint listonly
  DetailPrint ""

  StrCmp $G_PLS_FIELD_1 "No suitable patches were found" close_log
  StrCmp $G_PLS_FIELD_1 "OK" 0 show_status
  !insertmacro BACKUP_123_DP "$G_ROOTDIR\POPFile" "Module.pm"
  SetDetailsPrint none
  Rename "$PLUGINSDIR\Module.ssl" "$G_ROOTDIR\POPFile\Module.pm"
  IfFileExists "$G_ROOTDIR\POPFile\Module.pm" success
  Rename "$G_ROOTDIR\POPFile\Module.pm.bk1" "$G_ROOTDIR\POPFile\Module.pm"
  SetDetailsPrint listonly
  DetailPrint ""
  SetDetailsPrint both
  DetailPrint "$(PSS_LANG_PATCHFAILED)"
  SetDetailsPrint listonly
  DetailPrint ""
  Call GetDateTimeStamp
  Pop $G_PLS_FIELD_1
  DetailPrint "----------------------------------------------------"
  DetailPrint "POPFile SSL Setup failed ($G_PLS_FIELD_1)"
  DetailPrint "----------------------------------------------------"
  Abort

success:
  SetDetailsPrint listonly
  DetailPrint "$(PSS_LANG_PATCHCOMPLETED)"
  DetailPrint ""

show_status:
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(PSS_LANG_PATCHSTATUS)"

close_log:
  SetDetailsPrint both
  DetailPrint "$(PSS_LANG_PROG_SUCCESS)"
  SetDetailsPrint listonly
  DetailPrint ""
  Call GetDateTimeStamp
  Pop $G_PLS_FIELD_1
  DetailPrint "----------------------------------------------------"
  DetailPrint "POPFile SSL Setup completed $G_PLS_FIELD_1"
  DetailPrint "----------------------------------------------------"
  DetailPrint ""

  ; Save a log showing what was installed

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_PROG_SAVELOG)"
  SetDetailsPrint none
  !insertmacro BACKUP_123 "$G_ROOTDIR" "addssl.log"
  Push "$G_ROOTDIR\addssl.log"
  Call DumpLog

  SetDetailsPrint both
  DetailPrint "Log report saved in '$G_ROOTDIR\addssl.log'"
  SetDetailsPrint none

SectionEnd


#--------------------------------------------------------------------------
# Installer Function: CheckForExistingInstallation
# (the "pre" function for the DIRECTORY selection page)
#
# Set the initial value used by the DIRECTORY page to the location used by the most recent
# installation of POPFile v0.22.x
#--------------------------------------------------------------------------

Function CheckForExistingInstallation

  ReadRegStr $INSTDIR HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "InstallPath"
  StrCmp $INSTDIR "" try_HKLM
  IfFileExists "$INSTDIR\*.*" exit

try_HKLM:
  ReadRegStr $INSTDIR HKLM "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "InstallPath"
  StrCmp $INSTDIR "" use_default
  IfFileExists "$INSTDIR\*.*" exit

use_default:
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(PSS_LANG_COMPAT_NOTFOUND)"
  StrCpy $INSTDIR "$PROGRAMFILES\${C_PFI_PRODUCT}"

exit:
FunctionEnd


#--------------------------------------------------------------------------
# Installer Function: CheckInstallDir
# (the "leave" function for the DIRECTORY selection page)
#
# This function is used to check if a previous POPFile installation exists in the directory
# chosen for this installation's POPFile program files (popfile.pl, etc)
#--------------------------------------------------------------------------

Function CheckInstallDir

  ; Initialise the global user variable used for the main POPFIle program folder location

  StrCpy $G_ROOTDIR "$INSTDIR"

  ; Warn the user if the selected directory does not appear to contain POPFile 0.22.x files
  ; and allow user to select a different directory if they wish

  IfFileExists "$G_ROOTDIR\skins\default\style.css" continue

  StrCpy $G_PLS_FIELD_1 "$INSTDIR"
  MessageBox MB_YESNO|MB_ICONQUESTION "$(PSS_LANG_DESTNDIR_MB_WARN_1)\
      ${MB_NL}${MB_NL}${MB_NL}\
      $(PSS_LANG_DESTNDIR_MB_WARN_2)" IDYES continue

  ; Return to the DIRECTORY selection page

  Abort

continue:

  ; Move to the INSTFILES page (to install the files)

FunctionEnd


#--------------------------------------------------------------------------
# Installer Function: MakeRootDirSafe
#
# We are adding files to a previous installation, so we try to shut it down first
#--------------------------------------------------------------------------

Function MakeRootDirSafe

  IfFileExists "$G_ROOTDIR\*.exe" 0 nothing_to_check

  !define L_CFG      $R9    ; file handle
  !define L_EXE      $R8    ; name of EXE file to be monitored
  !define L_LINE     $R7
  !define L_NEW_GUI  $R6
  !define L_PARAM    $R5
  !define L_RESULT   $R4
  !define L_TEXTEND  $R3    ; used to ensure correct handling of lines longer than 1023 chars

  Push ${L_CFG}
  Push ${L_EXE}
  Push ${L_LINE}
  Push ${L_NEW_GUI}
  Push ${L_PARAM}
  Push ${L_RESULT}
  Push ${L_TEXTEND}

  DetailPrint ""
  SetDetailsPrint both
  DetailPrint "$(PSS_LANG_PROG_CHECKIFRUNNING)"
  SetDetailsPrint listonly

  ; Starting with POPfile 0.21.0 an experimental version of 'popfile-service.exe' was included
  ; to allow POPFile to be run as a Windows service.

  Push "POPFile"
  Call ServiceRunning
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "true" manual_shutdown

  ; If we are about to add SSL support to a POPFile installation which is still running,
  ; then one of the EXE files will be 'locked' which means we have to shutdown POPFile.
  ;
  ; POPFile v0.20.0 and later may be using 'popfileb.exe', 'popfilef.exe', 'popfileib.exe',
  ; 'popfileif.exe', 'perl.exe' or 'wperl.exe'.
  ;
  ; Earlier versions of POPFile use only 'perl.exe' or 'wperl.exe'.

  Push $G_ROOTDIR
  Call FindLockedPFE
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" exit

  ; The program folders we are about to update are in use so we need to shut POPFile down

  DetailPrint "... it is locked."

  ; Attempt to discover which POPFile UI port is used by the current user, so we can issue
  ; a shutdown request.

  ReadRegStr ${L_CFG} HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "UserDir_LFN"
  StrCmp ${L_CFG} "" try_root_dir
  IfFileExists "${L_CFG}\popfile.cfg" check_cfg_file

try_root_dir:
  IfFileExists "$G_ROOTDIR\popfile.cfg" 0 manual_shutdown
  StrCpy ${L_CFG} "$G_ROOTDIR"

check_cfg_file:
  StrCpy ${L_NEW_GUI} ""

  ; See if we can get the current gui port from an existing configuration.
  ; There may be more than one entry for this port in the file - use the last one found

  FileOpen  ${L_CFG} "${L_CFG}\popfile.cfg" r

found_eol:
  StrCpy ${L_TEXTEND} "<eol>"

loop:
  FileRead ${L_CFG} ${L_LINE}
  StrCmp ${L_LINE} "" done
  StrCmp ${L_TEXTEND} "<eol>" 0 check_eol
  StrCmp ${L_LINE} "$\n" loop

  StrCpy ${L_PARAM} ${L_LINE} 10
  StrCmp ${L_PARAM} "html_port " 0 check_eol
  StrCpy ${L_NEW_GUI} ${L_LINE} 5 10

  ; Now read file until we get to end of the current line
  ; (i.e. until we find text ending in <CR><LF>, <CR> or <LF>)

check_eol:
  StrCpy ${L_TEXTEND} ${L_LINE} 1 -1
  StrCmp ${L_TEXTEND} "$\n" found_eol
  StrCmp ${L_TEXTEND} "$\r" found_eol loop

done:
  FileClose ${L_CFG}

  Push ${L_NEW_GUI}
  Call TrimNewlines
  Pop ${L_NEW_GUI}

  StrCmp ${L_NEW_GUI} "" manual_shutdown
  DetailPrint "$(PFI_LANG_INST_LOG_SHUTDOWN) ${L_NEW_GUI}"
  DetailPrint "$(PFI_LANG_TAKE_A_FEW_SECONDS)"
  Push ${L_NEW_GUI}
  Call ShutdownViaUI
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "success" check_exe
  StrCmp ${L_RESULT} "password?" manual_shutdown

check_exe:
  DetailPrint "Waiting for '${L_EXE}' to unlock after NSISdl request..."
  DetailPrint "Please be patient, this may take more than 30 seconds"
  Push ${L_EXE}
  Call WaitUntilUnlocked
  DetailPrint "Checking if '${L_EXE}' is still locked after NSISdl request..."
  Push ${L_EXE}
  Call CheckIfLocked
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" unlocked_now

manual_shutdown:
  StrCpy $G_PLS_FIELD_1 "POPFile"
  DetailPrint "Unable to shutdown $G_PLS_FIELD_1 automatically - manual intervention requested"
  MessageBox MB_OK|MB_ICONEXCLAMATION|MB_TOPMOST "$(PFI_LANG_MBMANSHUT_1)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_MBMANSHUT_2)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_MBMANSHUT_3)"
  Goto exit

unlocked_now:
  DetailPrint "File is now unlocked"

exit:
  Pop ${L_TEXTEND}
  Pop ${L_RESULT}
  Pop ${L_PARAM}
  Pop ${L_NEW_GUI}
  Pop ${L_LINE}
  Pop ${L_EXE}
  Pop ${L_CFG}

  !undef L_CFG
  !undef L_EXE
  !undef L_LINE
  !undef L_NEW_GUI
  !undef L_PARAM
  !undef L_RESULT
  !undef L_TEXTEND

nothing_to_check:
FunctionEnd

#--------------------------------------------------------------------------
# End of 'addssl.nsi'
#--------------------------------------------------------------------------
