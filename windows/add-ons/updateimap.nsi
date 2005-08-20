#--------------------------------------------------------------------------
#
# updateimap.nsi --- This is the NSIS script used to create a utility which downloads and
#                    installs either the latest version of the experimental IMAP.pm module
#                    or the version specified on the command-line. This utility is intended
#                    for use with an existing POPFile 0.22.x installation (the IMAP module
#                    is still 'experimental' so it is not shipped with the 0.22.0 release).
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


  ;------------------------------------------------
  ; This script uses 'cURL' to perform the downloads
  ;------------------------------------------------

  ; The standard NSIS 'nsisdl' plugin cannot be used to download the IMAP.pm module because
  ; the server does not supply the content length so the 'curl' is used to download the data.
  ;
  ; For further information, including download links for a wide variety of platforms, visit
  ; curl's web site at http://curl.haxx.se
  ;
  ; There are over 15 official mirrors of the main web site and a similar number of official
  ; download mirrors.
  ;
  ; For this IMAP Updater wizard the "Win32 - Generic - non-SSL" version of 'curl' was used.
  ;
  ; The curl program contains built-in help (curl.exe --help) and a manual (curl.exe --manual)


#--------------------------------------------------------------------------
# Optional run-time command-line switch (used by 'updateimap.exe')
#--------------------------------------------------------------------------
#
# /revision=CVS revision number
#
# By default this wizard downloads the most recent version found in CVS. If the wizard fails to
# correctly identify the most recent version or if the user wishes to download and install a
# particular revision then this command-line switch can be used.
#
# For example, to download and install IMAP.pm v1.4 use the command:
#
#   updateimap.exe /revision=1.4
#
# To get the most recent version without knowing its revision number, use the command:
#
#   updateimap.exe /revision=1.999
#
# (assuming the most recent version number is less than or equal to 1.999)
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
  ; (two commonly used exceptions to this rule are 'IO_NL' and 'MB_NL')
  ;--------------------------------------------------------------------------

  ; This build is for use with the POPFile installer-created installations

  !define C_PFI_PRODUCT  "POPFile"

  Name                   "POPFile IMAP Updater"

  !define C_PFI_VERSION  "0.0.5"

  ; Mention the wizard's version number in the window title

  Caption                "POPFile IMAP Updater v${C_PFI_VERSION}"

  ; Name to be used for the program file (also used for the 'Version Information')

  !define C_OUTFILE      "updateimap.exe"

  ;--------------------------------------------------------------------------
  ; Addresses used to download the list of available IMAP.pm revisions and to
  ; download a particular revision. Some simple parsing is performed on the
  ; available IMAP.pm revisions list in an attempt to find the most recent one.
  ;--------------------------------------------------------------------------

  ; SourceForge URL for the CVS Revision History for the POPFile IMAP module

  !define C_CVS_HISTORY_URL   "http://cvs.sourceforge.net/viewcvs.py/popfile/engine/Services/IMAP.pm"

  ; SourceForge URL used when downloading a particular CVS revision of the IMAP module

  !define C_CVS_IMAP_DL_URL   "http://cvs.sourceforge.net/viewcvs.py/*checkout*/popfile/engine/Services/IMAP.pm?rev=$G_REVISION"


#--------------------------------------------------------------------------
# User Registers (Global)
#--------------------------------------------------------------------------

  ; This script uses 'User Variables' (with names starting with 'G_') to hold GLOBAL data.

  Var G_ROOTDIR            ; full path to the folder used for the POPFile program files

  Var G_REVISION           ; The IMAP.pm CVS revision to be downloaded (e.g. 1.5) which is
                           ; extracted from the CVS history page or specified on command-line

  Var G_REVDATE            ; The date of the most recent CVS revision found in the list
                           ; (e.g. "Mon Aug 23 12:18:58 2004 UTC")

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

  !define IMAPUPDATER

  !include "..\pfi-library.nsh"


#--------------------------------------------------------------------------
# Version Information settings (for the wizard's EXE file)
#--------------------------------------------------------------------------

  ; 'VIProductVersion' format is X.X.X.X where X is a number in range 0 to 65535
  ; representing the following values: Major.Minor.Release.Build

  VIProductVersion                          "${C_PFI_VERSION}.0"

  VIAddVersionKey "ProductName"             "POPFile IMAP Updater wizard"
  VIAddVersionKey "Comments"                "POPFile Homepage: http://getpopfile.org/"
  VIAddVersionKey "CompanyName"             "The POPFile Project"
  VIAddVersionKey "LegalCopyright"          "Copyright (c) 2005  John Graham-Cumming"
  VIAddVersionKey "FileDescription"         "Updates the IMAP module for POPFile 0.22.x"
  VIAddVersionKey "FileVersion"             "${C_PFI_VERSION}"
  VIAddVersionKey "OriginalFilename"        "${C_OUTFILE}"

  VIAddVersionKey "Build"                   "English-Mode"

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

  ; The log window shows progress messages and download statistics

  ShowInstDetails show
  !define MUI_FINISHPAGE_NOAUTOCLOSE

  ;----------------------------------------------------------------
  ;  Interface Settings - Abort Warning Settings
  ;----------------------------------------------------------------

  ; Show a message box with a warning when the user closes the wizard before it has finished

  !define MUI_ABORTWARNING

  ;----------------------------------------------------------------
  ; Customize MUI - General Custom Function
  ;----------------------------------------------------------------

  ; Use a custom '.onGUIInit' function to permit language-specific error messages
  ; (the user-selected language is not available for use in the .onInit function)

  !define MUI_CUSTOMFUNCTION_GUIINIT          PFIGUIInit


#--------------------------------------------------------------------------
# Define the Page order for the wizard
#--------------------------------------------------------------------------

  ;---------------------------------------------------
  ; Installer Page - Welcome
  ;---------------------------------------------------

  !define MUI_WELCOMEPAGE_TITLE                   "$(PIU_LANG_WELCOME_TITLE)"
  !define MUI_WELCOMEPAGE_TEXT                    "$(PIU_LANG_WELCOME_TEXT)"

  !insertmacro MUI_PAGE_WELCOME

  ;---------------------------------------------------
  ; Installer Page - License Page (uses English GPL)
  ;---------------------------------------------------

  !define MUI_LICENSEPAGE_CHECKBOX
  !define MUI_PAGE_HEADER_SUBTEXT                 "$(PIU_LANG_LICENSE_SUBHDR)"
  !define MUI_LICENSEPAGE_TEXT_BOTTOM             "$(PIU_LANG_LICENSE_BOTTOM)"

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
  ; (we use this to generate the installation path for the POPFile IMAP module)

  !define MUI_PAGE_HEADER_TEXT                    "$(PIU_LANG_DESTNDIR_TITLE)"
  !define MUI_PAGE_HEADER_SUBTEXT                 "$(PIU_LANG_DESTNDIR_SUBTITLE)"
  !define MUI_DIRECTORYPAGE_TEXT_TOP              "$(PIU_LANG_DESTNDIR_TEXT_TOP)"
  !define MUI_DIRECTORYPAGE_TEXT_DESTINATION      "$(PIU_LANG_DESTNDIR_TEXT_DESTN)"

  !insertmacro MUI_PAGE_DIRECTORY

  ;---------------------------------------------------
  ; Installer Page - Install files
  ;---------------------------------------------------

  ; Override the standard "Installing..." page header

  !define MUI_PAGE_HEADER_TEXT                    "$(PIU_LANG_STD_HDR)"
  !define MUI_PAGE_HEADER_SUBTEXT                 "$(PIU_LANG_STD_SUBHDR)"

  ; Override the standard "Installation complete..." page header

  !define MUI_INSTFILESPAGE_FINISHHEADER_TEXT     "$(PIU_LANG_END_HDR)"
  !define MUI_INSTFILESPAGE_FINISHHEADER_SUBTEXT  "$(PIU_LANG_END_SUBHDR)"

  ; Override the standard "Installation Aborted..." page header

  !define MUI_INSTFILESPAGE_ABORTHEADER_TEXT      "$(PIU_LANG_ABORT_HDR)"
  !define MUI_INSTFILESPAGE_ABORTHEADER_SUBTEXT   "$(PIU_LANG_ABORT_SUBHDR)"

  !insertmacro MUI_PAGE_INSTFILES

  ;---------------------------------------------------
  ; Installer Page - Finish
  ;---------------------------------------------------

  !define MUI_FINISHPAGE_TITLE                    "$(PIU_LANG_FINISH_TITLE)"
  !define MUI_FINISHPAGE_TEXT                     "$(PIU_LANG_FINISH_TEXT)"

  !insertmacro MUI_PAGE_FINISH


#--------------------------------------------------------------------------
# Language Support for the utility
#--------------------------------------------------------------------------

  !insertmacro MUI_LANGUAGE "English"

  ;--------------------------------------------------------------------------
  ; Current build only supports English and uses local strings
  ; instead of language strings from languages\*-pfi.nsh files
  ;--------------------------------------------------------------------------

  !macro PLS_TEXT NAME VALUE
      LangString ${NAME} ${LANG_ENGLISH} "${VALUE}"
  !macroend

  ;--------------------------------------------------------------------------
  ; WELCOME page
  ;--------------------------------------------------------------------------

  !insertmacro PLS_TEXT PIU_LANG_WELCOME_TITLE         "Welcome to the $(^NameDA) Wizard"
  !insertmacro PLS_TEXT PIU_LANG_WELCOME_TEXT          "This utility will download the POPFile IMAP module from CVS.${IO_NL}${IO_NL}Normally it will download the most up-to-date version, but you can request a particular version by starting the utility with the /revision=1.x option (where x is the revision of interest).${IO_NL}${IO_NL}For example: updateimap.exe /revision=1.5${IO_NL}${IO_NL}For the most recent revision, set x to a huge number like 999${IO_NL}${IO_NL}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${IO_NL}   WARNING:${IO_NL}${IO_NL}   PLEASE SHUT DOWN POPFILE NOW !${IO_NL}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${IO_NL}${IO_NL}$_CLICK"

  ;--------------------------------------------------------------------------
  ; LICENSE page
  ;--------------------------------------------------------------------------

  !insertmacro PLS_TEXT PIU_LANG_LICENSE_SUBHDR        "Please review the license terms before using $(^NameDA)."
  !insertmacro PLS_TEXT PIU_LANG_LICENSE_BOTTOM        "If you accept the terms of the agreement, click the check box below. You must accept the agreement to use $(^NameDA). $_CLICK"

  ;--------------------------------------------------------------------------
  ; Source DIRECTORY page
  ;--------------------------------------------------------------------------

  !insertmacro PLS_TEXT PIU_LANG_DESTNDIR_TITLE        "Choose existing POPFile installation"
  !insertmacro PLS_TEXT PIU_LANG_DESTNDIR_SUBTITLE     "This IMAP module should only be added to an existing POPFile 0.22.x installation"
  !insertmacro PLS_TEXT PIU_LANG_DESTNDIR_TEXT_TOP     "The IMAP module must be installed using the same installation folder as POPFile 0.22.x.${MB_NL}${MB_NL}This utility will update the IMAP module in the version of POPFile which is installed in the following folder. To install in a different POPFile 0.22.x installation, click Browse and select another folder. $_CLICK"
  !insertmacro PLS_TEXT PIU_LANG_DESTNDIR_TEXT_DESTN   "Existing POPFile 0.22.x installation folder"

  !insertmacro PLS_TEXT PIU_LANG_DESTNDIR_MB_WARN_1    "POPFile 0.22.x does NOT seem to be installed in${MB_NL}${MB_NL}$G_PLS_FIELD_1"
  !insertmacro PLS_TEXT PIU_LANG_DESTNDIR_MB_WARN_2    "Are you sure you want to use this folder ?"

  ;--------------------------------------------------------------------------
  ; INSTFILES page
  ;--------------------------------------------------------------------------

  ; Initial page header

  !insertmacro PLS_TEXT PIU_LANG_STD_HDR               "Adding/Updating the IMAP module (for POPFile 0.22.x)"
  !insertmacro PLS_TEXT PIU_LANG_STD_SUBHDR            "Please wait while the IMAP module is downloaded and installed..."

  ; Successful completion page header

  !insertmacro PLS_TEXT PIU_LANG_END_HDR               "IMAP installation completed"
  !insertmacro PLS_TEXT PIU_LANG_END_SUBHDR            "IMAP module v$G_REVISION has been installed successfully"

  ; Unsuccessful completion page header

  !insertmacro PLS_TEXT PIU_LANG_ABORT_HDR             "IMAP installation failed"
  !insertmacro PLS_TEXT PIU_LANG_ABORT_SUBHDR          "The attempt to add or update the IMAP module has failed"

  ; Progress reports

  !insertmacro PLS_TEXT PIU_LANG_PROG_INITIALISE       "Initializing..."
  !insertmacro PLS_TEXT PIU_LANG_PROG_GETLIST          "Downloading list of available CVS revisions..."
  !insertmacro PLS_TEXT PIU_LANG_PROG_CHECKDOWNLOAD    "Analyzing the result of the download operation..."
  !insertmacro PLS_TEXT PIU_LANG_PROG_FINDREVISION     "Searching the list to find the most recent IMAP revision..."
  !insertmacro PLS_TEXT PIU_LANG_PROG_USERCANCELLED    "IMAP update cancelled by the user"
  !insertmacro PLS_TEXT PIU_LANG_PROG_GETIMAP          "Downloading the IMAP.pm module..."
  !insertmacro PLS_TEXT PIU_LANG_PROG_BACKUPIMAP       "Making backup copy of previous IMAP.pm file..."
  !insertmacro PLS_TEXT PIU_LANG_PROG_INSTALLIMAP      "Updating the IMAP.pm file..."
  !insertmacro PLS_TEXT PIU_LANG_PROG_SUCCESS          "POPFile 0.22.x IMAP support updated to v$G_REVISION"
  !insertmacro PLS_TEXT PIU_LANG_PROG_SAVELOG          "Saving install log file..."

  !insertmacro PLS_TEXT PIU_LANG_TAKE_A_FEW_SECONDS    "(this may take a few seconds)"

  ;--------------------------------------------------------------------------
  ; FINISH page
  ;--------------------------------------------------------------------------

  !insertmacro PLS_TEXT PIU_LANG_FINISH_TITLE          "Completing the $(^NameDA) Wizard"
  !insertmacro PLS_TEXT PIU_LANG_FINISH_TEXT           "POPFile IMAP module v$G_REVISION has been installed.${IO_NL}${IO_NL}You can now start POPFile and use the POPFile User Interface to activate and configure the IMAP module.${IO_NL}${IO_NL}Click Finish to close this wizard."

  ;--------------------------------------------------------------------------
  ; Miscellaneous strings
  ;--------------------------------------------------------------------------

  !insertmacro PLS_TEXT PIU_LANG_MUTEX                 "Another copy of the IMAP Updater wizard is running!"

  !insertmacro PLS_TEXT PIU_LANG_COMPAT_NOTFOUND       "Warning: Cannot find compatible version of POPFile !"

  !insertmacro PLS_TEXT PIU_LANG_MB_BADOPTION_1        "Invalid command-line option supplied ($G_PLS_FIELD_1)"
  !insertmacro PLS_TEXT PIU_LANG_MB_BADOPTION_2        "Usage examples:"
  !insertmacro PLS_TEXT PIU_LANG_MB_BADOPTION_3        "(to get the most up-to-date revision using CVS data)"
  !insertmacro PLS_TEXT PIU_LANG_MB_BADOPTION_4        "(where x is the required revision number, starting at 1)"
  !insertmacro PLS_TEXT PIU_LANG_MB_BADOPTION_5        "To get the most recent revision, set x to a huge number like 999"
  !insertmacro PLS_TEXT PIU_LANG_MB_BADOPTION_ALL      "$(PIU_LANG_MB_BADOPTION_1)${MB_NL}${MB_NL}$(PIU_LANG_MB_BADOPTION_2)${MB_NL}${MB_NL}updateimap.exe${MB_NL}$(PIU_LANG_MB_BADOPTION_3)${MB_NL}${MB_NL}or${MB_NL}${MB_NL}update.exe /revision=1.x${MB_NL}$(PIU_LANG_MB_BADOPTION_4)${MB_NL}${MB_NL}$(PIU_LANG_MB_BADOPTION_5)"

  !insertmacro PLS_TEXT PIU_LANG_ANALYSISFAILED_1      "Sorry, unable to determine the most recent revision!"
  !insertmacro PLS_TEXT PIU_LANG_ANALYSISFAILED_2      "You can specify a particular revision using the command"
  !insertmacro PLS_TEXT PIU_LANG_ANALYSISFAILED_3      "updateimap.exe /revision=1.x"
  !insertmacro PLS_TEXT PIU_LANG_MB_ANALYSISFAILED     "$(PIU_LANG_ANALYSISFAILED_1)${MB_NL}${MB_NL}$(PIU_LANG_ANALYSISFAILED_2)${MB_NL}${MB_NL}$(PIU_LANG_ANALYSISFAILED_3)"

  !insertmacro PLS_TEXT PIU_LANG_MB_GETPERMISSION      "Do you want to download and install IMAP.pm v$G_REVISION ?$G_REVDATE"

  !insertmacro PLS_TEXT PIU_LANG_MB_HISTORYFAIL_1      "Download of the list of available CVS revisions failed"
  !insertmacro PLS_TEXT PIU_LANG_MB_HISTORYFAIL_2      "(error: $G_PLS_FIELD_1)"

  !insertmacro PLS_TEXT PIU_LANG_MB_IMAPFAIL_1         "Download of IMAP module failed"
  !insertmacro PLS_TEXT PIU_LANG_MB_IMAPFAIL_2         "(error: $G_PLS_FIELD_1)"

  !insertmacro PLS_TEXT PIU_LANG_MB_BADIMAPFILE_1      "The downloaded file is not a POPFile module !"
  !insertmacro PLS_TEXT PIU_LANG_MB_BADIMAPFILE_2      "First line starts with '$G_PLS_FIELD_1'"
  !insertmacro PLS_TEXT PIU_LANG_MB_BADIMAPFILE_3      "Expected to find only '# POPFILE LOADABLE MODULE'"
  !insertmacro PLS_TEXT PIU_LANG_MB_BADIMAPFILE_4      "Downloaded file ignored - no changes made to POPFile"

  ; String required by the 'PFI_DumpLog' library function (hence the 'PFI_LANG_' prefix)

  !insertmacro PLS_TEXT PFI_LANG_MB_SAVELOG_ERROR      "Error: problem detected when saving the log file"

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

  !insertmacro MUI_RESERVEFILE_INSTALLOPTIONS


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
  !define L_TEMP             $R9   ; used when checking the command-line parameter (if any)

  Push ${L_RESERVED}
  Push ${L_TEMP}

  ; Ensure only one copy of this wizard (or any other POPFile installer) is running

  System::Call 'kernel32::CreateMutexA(i 0, i 0, t "OnlyOnePFI_mutex") i .r1 ?e'
  Pop ${L_RESERVED}
  StrCmp ${L_RESERVED} 0 mutex_ok
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(PIU_LANG_MUTEX)"
  Abort

bad_option:
  MessageBox MB_OK|MB_ICONSTOP "$(PIU_LANG_MB_BADOPTION_ALL)"
  Abort

mutex_ok:
  Call PFI_GetParameters
  Pop $G_REVISION
  StrCmp $G_REVISION "" exit
  StrCpy $G_PLS_FIELD_1 $G_REVISION
  StrCpy ${L_TEMP} $G_REVISION 12
  StrCmp ${L_TEMP} "/revision=1." 0 bad_option
  StrCpy $G_REVISION $G_REVISION "" 12
  Push $G_REVISION
  Call PFI_StrCheckDecimal
  Pop $G_REVISION
  StrCmp $G_REVISION "" bad_option
  IntCmp $G_REVISION 0 bad_option bad_option
  StrCpy $G_REVISION "1.$G_REVISION"

exit:
  Pop ${L_TEMP}
  Pop ${L_RESERVED}

  !undef L_RESERVED
  !undef L_TEMP

FunctionEnd


#--------------------------------------------------------------------------
# Installer Section: POPFile IMAP component
#
# The NSISdl plugin cannot be used for these downloads because the server
# does not specify the content length so this utility uses cURL instead.
#
# To avoid opening console windows, the cURL output is sent to the log window
# (so no progress reports are displayed during the file download operation
# but we can display some statistics once the file has been downloaded).
#--------------------------------------------------------------------------

Section "IMAP" SecIMAP

  !define L_HANDLE        $R9   ; file handle used to access the CVS log history list
  !define L_RESULT        $R8
  !define L_TEMP          $R7

  ; Local copy of the CVS log history file (which we use to find the most recent revision)

  !define C_CVS_HISTORY_FILE  "$PLUGINSDIR\cvslog.htm"

  ; String used to define cURL report format

  !define C_CURL_REPORT     "Downloaded %{size_download} bytes in %{time_total} seconds${IO_NL}Average speed: %{speed_download} bytes per second${IO_NL}"

  Push ${L_HANDLE}
  Push ${L_RESULT}
  Push ${L_TEMP}

  SetDetailsPrint textonly
  DetailPrint "$(PIU_LANG_PROG_INITIALISE)"
  SetDetailsPrint none

  ; We cannot use the nsisdl plugin here because the server does not specify the content length
  ; (see this script's header comment for information on where to obtain 'curl.exe')

  SetOutPath "$PLUGINSDIR"
  File "curl.exe"
  File "COPYING"
  SetDetailsPrint listonly

  StrCpy $G_REVDATE ""

  DetailPrint "----------------------------------------------"
  DetailPrint "POPFile IMAP Updater wizard v${C_PFI_VERSION}"
  DetailPrint "----------------------------------------------"
  DetailPrint ""

  IfFileExists "$G_ROOTDIR\*.*" check_param
  CreateDirectory $G_ROOTDIR

check_param:
  StrCmp $G_REVISION "" look_for_suitable_version
  DetailPrint "User has requested IMAP.pm v$G_REVISION"
  Goto get_imap_module

look_for_suitable_version:
  IfFileExists "$G_ROOTDIR\POPFile\Database.pm" look_for_most_recent_version
  StrCpy $G_REVISION "1.9"
  DetailPrint "Pre-0.23.0 installation found. Get most recent 0.22-compatible file (IMAP.pm v$G_REVISION)"
  Goto get_imap_module

look_for_most_recent_version:
  SetDetailsPrint both
  DetailPrint "$(PIU_LANG_PROG_GETLIST) $(PIU_LANG_TAKE_A_FEW_SECONDS)"
  SetDetailsPrint listonly
  DetailPrint ""
  nsExec::ExecToLog '"curl.exe" -s -S -w "${C_CURL_REPORT}" -o "${C_CVS_HISTORY_FILE}" "${C_CVS_HISTORY_URL}"'
  Pop ${L_RESULT}
  DetailPrint ""
  SetDetailsPrint textonly
  DetailPrint "$(PIU_LANG_PROG_CHECKDOWNLOAD)"
  SetDetailsPrint listonly
  StrCmp ${L_RESULT} "0" analyse_history
  StrCpy $G_PLS_FIELD_1 ${L_RESULT}
  SetDetailsPrint both
  DetailPrint "$(PIU_LANG_MB_HISTORYFAIL_1)"
  SetDetailsPrint listonly
  DetailPrint "$(PIU_LANG_MB_HISTORYFAIL_2)"
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(PIU_LANG_MB_HISTORYFAIL_1)${MB_NL}$(PIU_LANG_MB_HISTORYFAIL_2)"
  Goto error_exit

analyse_history:
  SetDetailsPrint both
  DetailPrint "$(PIU_LANG_PROG_FINDREVISION)"
  SetDetailsPrint listonly
  Call GetMostRecentVersionInfo
  Pop $G_REVDATE
  Pop $G_REVISION
  StrCmp $G_REVISION "" analysis_failed
  DetailPrint "Search result: IMAP.pm v$G_REVISION ($G_REVDATE)"
  StrCpy $G_REVDATE "${MB_NL}${MB_NL}(CVS timestamp $G_REVDATE)"
  Goto get_imap_module

analysis_failed:
  DetailPrint ""
  DetailPrint "$(PIU_LANG_ANALYSISFAILED_1)"
  DetailPrint ""
  DetailPrint "$(PIU_LANG_ANALYSISFAILED_2)"
  DetailPrint "$(PIU_LANG_ANALYSISFAILED_3)"
  DetailPrint "$(PIU_LANG_MB_BADOPTION_4)"
  DetailPrint ""
  DetailPrint "$(PIU_LANG_MB_BADOPTION_5)"
  MessageBox MB_OK|MB_ICONSTOP "$(PIU_LANG_MB_ANALYSISFAILED)${MB_NL}${MB_NL}$(PIU_LANG_MB_BADOPTION_4)${MB_NL}${MB_NL}$(PIU_LANG_MB_BADOPTION_5)"
  Goto error_exit

get_imap_module:
  DetailPrint ""
  SetDetailsPrint both
  DetailPrint "Ready to download IMAP.pm v$G_REVISION from CVS"
  SetDetailsPrint listonly
  MessageBox MB_YESNO|MB_ICONQUESTION "$(PIU_LANG_MB_GETPERMISSION)" IDYES download_imap
  DetailPrint ""
  SetDetailsPrint both
  DetailPrint "$(PIU_LANG_PROG_USERCANCELLED)"
  SetDetailsPrint listonly
  Goto error_exit

download_imap:
  DetailPrint ""
  SetDetailsPrint both
  DetailPrint "$(PIU_LANG_PROG_GETIMAP) $(PIU_LANG_TAKE_A_FEW_SECONDS)"
  SetDetailsPrint listonly
  DetailPrint ""
  nsExec::ExecToLog '"curl.exe" -s -S -w "${C_CURL_REPORT}" -o "$PLUGINSDIR\IMAP.pm" "${C_CVS_IMAP_DL_URL}"'
  Pop ${L_RESULT}
  DetailPrint ""
  SetDetailsPrint textonly
  DetailPrint "$(PIU_LANG_PROG_CHECKDOWNLOAD)"
  SetDetailsPrint listonly
  StrCmp ${L_RESULT} "0" file_received
  StrCpy $G_PLS_FIELD_1 ${L_RESULT}
  SetDetailsPrint both
  DetailPrint "$(PIU_LANG_MB_IMAPFAIL_1)"
  SetDetailsPrint listonly
  DetailPrint "$(PIU_LANG_MB_IMAPFAIL_2)"
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(PIU_LANG_MB_IMAPFAIL_1)${MB_NL}$(PIU_LANG_MB_IMAPFAIL_2)"
  Goto error_exit

file_received:
  FileOpen ${L_HANDLE} "$PLUGINSDIR\IMAP.pm" r
  FileRead ${L_HANDLE} ${L_RESULT}
  FileClose ${L_HANDLE}
  Push ${L_RESULT}
  Call PFI_TrimNewlines
  Pop $G_PLS_FIELD_1
  StrCpy $G_PLS_FIELD_1 $G_PLS_FIELD_1 25
  StrCmp $G_PLS_FIELD_1 "# POPFILE LOADABLE MODULE" success
  DetailPrint "$(PIU_LANG_MB_BADIMAPFILE_1)"
  DetailPrint ""
  DetailPrint "$(PIU_LANG_MB_BADIMAPFILE_2)"
  DetailPrint "$(PIU_LANG_MB_BADIMAPFILE_3)"
  DetailPrint ""
  DetailPrint "$(PIU_LANG_MB_BADIMAPFILE_4)"
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(PIU_LANG_MB_BADIMAPFILE_1)\
      ${MB_NL}${MB_NL}${MB_NL}\
      $(PIU_LANG_MB_BADIMAPFILE_2)\
      ${MB_NL}${MB_NL}\
      $(PIU_LANG_MB_BADIMAPFILE_3)\
      ${MB_NL}${MB_NL}${MB_NL}\
      $(PIU_LANG_MB_BADIMAPFILE_4)"

error_exit:
  SetDetailsPrint listonly
  DetailPrint ""
  Call PFI_GetDateTimeStamp
  Pop $G_PLS_FIELD_1
  DetailPrint "----------------------------------------------"
  DetailPrint "IMAP Updater failed ($G_PLS_FIELD_1)"
  DetailPrint "----------------------------------------------"
  Abort

success:
  IfFileExists "$G_ROOTDIR\Services\*.*" backup_current_file
  CreateDirectory "$G_ROOTDIR\Services"
  Goto copy_file

backup_current_file:
  DetailPrint "$(PIU_LANG_PROG_BACKUPIMAP)"
  DetailPrint ""
  !insertmacro PFI_BACKUP_123_DP "$G_ROOTDIR\Services" "IMAP.pm"

copy_file:
  DetailPrint ""
  DetailPrint "$(PIU_LANG_PROG_INSTALLIMAP)"
  Rename "$PLUGINSDIR\IMAP.pm" "$G_ROOTDIR\Services\IMAP.pm"
  DetailPrint ""
  SetDetailsPrint both
  DetailPrint "$(PIU_LANG_PROG_SUCCESS)"
  SetDetailsPrint listonly
  DetailPrint ""
  Call PFI_GetDateTimeStamp
  Pop $G_PLS_FIELD_1
  DetailPrint "----------------------------------------------"
  DetailPrint "IMAP Updater completed $G_PLS_FIELD_1"
  DetailPrint "----------------------------------------------"
  DetailPrint ""
  SetDetailsPrint textonly
  DetailPrint "$(PIU_LANG_PROG_SAVELOG)"

  ; Save a log showing what was installed

  !insertmacro PFI_BACKUP_123 "$G_ROOTDIR" "updateimap.log"
  Push "$G_ROOTDIR\updateimap.log"
  Call PFI_DumpLog

  SetDetailsPrint both
  DetailPrint "Log report saved in '$G_ROOTDIR\updateimap.log'"
  SetDetailsPrint none

  Pop ${L_TEMP}
  Pop ${L_RESULT}
  Pop ${L_HANDLE}

  !undef L_HANDLE
  !undef L_RESULT
  !undef L_TEMP

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
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(PIU_LANG_COMPAT_NOTFOUND)"
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

  IfFileExists "$G_ROOTDIR\popfile-service.exe" continue
  IfFileExists "$G_ROOTDIR\runpopfile.exe" continue
  IfFileExists "$G_ROOTDIR\UI\HTML.pm" continue

  MessageBox MB_YESNO|MB_ICONQUESTION "$(PIU_LANG_DESTNDIR_MB_WARN_1)\
      ${MB_NL}${MB_NL}\
      $INSTDIR\
      ${MB_NL}${MB_NL}${MB_NL}\
      $(PIU_LANG_DESTNDIR_MB_WARN_2)" IDYES continue

  ; Return to the DIRECTORY selection page

  Abort

continue:

  ; Move to the INSTFILES page (to install the files)

FunctionEnd


#--------------------------------------------------------------------------
# Installer Function: GetMostRecentVersionInfo
#
# Extracts information from the downloaded CVS history log
#
# Inputs:
#         none
# Outputs:
#         (top of stack)     - CVS timestamp for it (e.g. "Mon Aug 23 12:18:58 2004 UTC")
#                              (if unable to find the data, an empty string is returned)
#         (top of stack - 1) - first revision found, assumed to be the most recent (e.g. "1.6")
#                              (if unable to find the data, an empty string is returned)
#
# Usage:
#         Call GetMostRecentVersionInfo
#         Pop $R0     ; get the timestamp (e.g. "Mon Aug 23 12:18:58 2004 UTC")
#         Pop $R1     ; ge the CVS revision (e.g. "1.6")
#
#         (if no valid data found, $R1 = "" and $R0 = "")
#--------------------------------------------------------------------------

Function GetMostRecentVersionInfo

  !define L_HANDLE      $R9   ; file handle for the log history file
  !define L_LINE        $R8   ; a line from the log history  file
  !define L_PARAM       $R7
  !define L_RESULT_DATE $R6   ; either the most recent CVS revision's timestamp or ""
  !define L_RESULT_REV  $R5   ; either the most recent CVS revision number (e.g. "1.6") or ""
  !define L_TEMP        $R4

  Push ${L_RESULT_DATE}
  Push ${L_RESULT_REV}
  Push ${L_HANDLE}
  Push ${L_LINE}
  Push ${L_PARAM}
  Push ${L_TEMP}

  StrCpy ${L_RESULT_REV} ""
  StrCpy ${L_RESULT_DATE} ""

  FileOpen  ${L_HANDLE} "${C_CVS_HISTORY_FILE}" r

loop:
  FileRead ${L_HANDLE} ${L_LINE}
  StrCmp ${L_LINE} "" done

  StrCpy ${L_PARAM} ${L_LINE} 12
  StrCmp ${L_PARAM} "Revision <b>" 0 loop
  StrCpy ${L_TEMP} 12

revision_loop:
  StrCpy ${L_PARAM} ${L_LINE} 1 ${L_TEMP}
  StrCmp ${L_PARAM} "<" date_loop
  StrCpy ${L_RESULT_REV} "${L_RESULT_REV}${L_PARAM}"
  IntOp ${L_TEMP} ${L_TEMP} + 1
  Goto revision_loop

date_loop:
  FileRead ${L_HANDLE} ${L_LINE}
  StrCmp ${L_LINE} "" done
  StrCpy ${L_PARAM} ${L_LINE} 3
  StrCmp ${L_PARAM} "<i>" 0 date_loop
  StrCpy ${L_RESULT_DATE} ${L_LINE} 28 3

done:
  FileClose ${L_HANDLE}

  Pop ${L_TEMP}
  Pop ${L_PARAM}
  Pop ${L_LINE}
  Pop ${L_HANDLE}
  Exch ${L_RESULT_REV}
  Exch
  Exch ${L_RESULT_DATE}

  !undef L_HANDLE
  !undef L_LINE
  !undef L_PARAM
  !undef L_RESULT_DATE
  !undef L_RESULT_REV
  !undef L_TEMP

FunctionEnd


#--------------------------------------------------------------------------
# End of 'updatemap.nsi'
#--------------------------------------------------------------------------
