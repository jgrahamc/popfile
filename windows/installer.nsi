#--------------------------------------------------------------------------
#
# installer.nsi --- This is the NSIS script used to create the Windows installer
#                   for POPFile. This script installs the PROGRAM files and creates
#                   some registry entries, then calls the 'Add POPFile User' wizard
#                   (adduser.exe) to install and configure the user data (including
#                   the POPFILE_ROOT and POPFILE_USER environment variables) for the
#                   user running the installer.
#
#                   (A) Requires the following programs (built using NSIS):
#
#                       (1) adduser.exe     (NSIS script: adduser.nsi)
#                       (2) msgcapture.exe  (NSIS script: msgcapture.nsi)
#                       (3) runpopfile.exe  (NSIS script: runpopfile.nsi)
#                       (4) runsqlite.exe   (NSIS script: runsqlite.nsi)
#                       (5) stop_pf.exe     (NSIS script: stop_popfile.nsi)
#
#                   (B) The following programs (built using NSIS) are optional:
#
#                       (1) pfidiag.exe     (NSIS script: test\pfidiag.nsi)
#
# Copyright (c) 2002-2005 John Graham-Cumming
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
; (if the default multi-language installer is compiled).
;
; NOTE: The language selection menu order used in this script assumes that the NSIS MUI
; 'Japanese.nsh' language file has been patched to use 'Nihongo' instead of 'Japanese'
; [see 'SMALL NSIS PATCH REQUIRED' in the 'pfi-languages.nsh' file]

; INSTALLER SIZE: The LZMA compression method is used to reduce the size of the 'setup.exe'
; file by around 25% compared to the default compression method but at the expense of greatly
; increased compilation times (LZMA compilation (with the default LZMA settings) takes almost
; two and a half times as long as it does when the default compression method is used).

#--------------------------------------------------------------------------
# POPFile Version Data:
#
# In order to simplify maintenance, the POPFile version number and 'Release Candidate' status
# are passed as command-line parameters to the NSIS compiler.
#
# The following 4 parameters must be supplied (where x is a value in range 0 to 65535):
#
# (a) the Major Version number      (supplied as /DC_POPFILE_MAJOR_VERSION=x)
# (b) the Minor Version number      (supplied as /DC_POPFILE_MINOR_VERSION=x)
# (c) the Revision number           (supplied as /DC_POPFILE_REVISION=x)
# (d) the Release Candidate number  (supplied as /DC_POPFILE_RC=RCx)
#
# Note that if a production build is required (i.e. not a Release Candidate), /DC_POPFILE_RC
# or /DC_POPFILE_RC= or /DC_POPFILE_RC="" can be used instead of /DC_POPFILE_RC=RCx
#
# For example, to build the installer for the final POPFile 0.21.1 release, the following
# command-line could be used:
#
# makensis.exe /DC_POPFILE_MAJOR_VERSION=0 /DC_POPFILE_MINOR_VERSION=21 /DC_POPFILE_REVISION=1 /DC_POPFILE_RC installer.nsi
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
# Compile-time command-line switches (used by 'makensis.exe')
#--------------------------------------------------------------------------
#
# /DENGLISH_MODE
#
# To build an installer that only displays English messages (so there is no need to ensure all
# of the non-English *-pfi.nsh files are up-to-date), supply the command-line switch
# /DENGLISH_MODE when compiling the installer. This switch only affects the language used by
# the installer, it does not affect which files get installed.
#
# /DNO_KAKASI
#
# When the default compression mode is used to compile the installer, the Kakasi package and
# the additional Perl components it requires cause the installer to almost double in size.
# If the /DNO_KAKASI command-line switch is used, the installer will be built without these
# additional packages so the compile time and the installer size will be greatly reduced.
#
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
# Run-time command-line switch (used by 'setup.exe')
#--------------------------------------------------------------------------
#
# /NOSPACES
#
# Two environment variables are used to specify the location of the POPFile PROGRAM files and
# the User Data. At present POPFile does not work properly if the values in these variables
# contain spaces. As a workaround, we use short file name format to ensure there are no spaces.
# However some systems do not support short file names (using short file names on NTFS systems
# can have a significant impact on performance, for example) and in these cases we insist upon
# paths which do not contain spaces.
#
# This build of the installer is unable to detect every case where short file name support has
# been disabled, so this command-line switch is provided to force the installer to insist upon
# paths which do not contain spaces.  The switch can use uppercase or lowercase.
#
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
# LANGUAGE SUPPORT:
#
# The installer defaults to multi-language mode ('English' plus a number of other languages).
#
# If required, the command-line switch /DENGLISH_MODE can be used to build an English-only
# version. This switch can appear before or after the four POPFile version number parameters.
#--------------------------------------------------------------------------
# The POPFile installer uses several multi-language mode programs built using NSIS. To make
# maintenance easier, an 'include' file (pfi-languages.nsh) defines the supported languages.
#
# To remove support for a particular language, comment-out the relevant line in the list of
# languages in the 'pfi-languages.nsh' file.
#
# For instructions on how to add support for new languages, see the 'pfi-languages.nsh' file.
#--------------------------------------------------------------------------
# Support for Japanese text processing
#
# This version of the installer installs the Kakasi package and the Text::Kakasi Perl module
# used by POPFile when processing Japanese text. Further information about Kakasi, including
# 'download' links for the Kakasi package and the Text::Kakasi Perl module, can be found at
# http://kakasi.namazu.org/
#
# This version of the installer also installs the complete Perl 'Encode' collection of modules
# to complete the Japanese support requirements.
#
# The Kakasi package and the additional Perl modules almost double the size of the installer
# (assuming that the default compression method is used). If the command-line switch
# /DNO_KAKASI is used then a smaller installer can be built by omitting the Japanese support.
#
# SMALL NSIS PATCH REQUIRED: See 'pfi-languages.nsh' for details.
#--------------------------------------------------------------------------

  ;------------------------------------------------
  ; Define PFI_VERBOSE to get more compiler output
  ;------------------------------------------------

## !define PFI_VERBOSE

  ;--------------------------------------------------------------------------
  ; Select LZMA compression to reduce 'setup.exe' size by around 30%
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

  !ifndef C_POPFILE_MAJOR_VERSION
    !error "${MB_NL}${MB_NL}Fatal error: 'POPFile Major Version' parameter not supplied${MB_NL}"
  !endif

  !ifndef C_POPFILE_MINOR_VERSION
    !error "${MB_NL}${MB_NL}Fatal error: 'POPFile Minor Version' parameter not supplied${MB_NL}"
  !endif

  !ifndef C_POPFILE_REVISION
    !error "${MB_NL}${MB_NL}Fatal error: 'POPFile Revision' parameter not supplied${MB_NL}"
  !endif

  !ifndef C_POPFILE_RC
    !error "${MB_NL}${MB_NL}Fatal error: 'POPFile RC' parameter not supplied${MB_NL}"
  !endif

  !define C_PFI_PRODUCT  "POPFile"

  ; Name to be used for the installer program file (also used for the 'Version Information')

  !define C_OUTFILE     "setup${C_POPFILE_RC}.exe"

  Name                   "${C_PFI_PRODUCT}"

  !define C_PFI_VERSION  "${C_POPFILE_MAJOR_VERSION}.${C_POPFILE_MINOR_VERSION}.${C_POPFILE_REVISION}${C_POPFILE_RC}"

  ; Mention the POPFile version number in the titles of the installer & uninstaller windows

  Caption                "${C_PFI_PRODUCT} ${C_PFI_VERSION} Setup"
  UninstallCaption       "${C_PFI_PRODUCT} ${C_PFI_VERSION} Uninstall"

  !define C_README        "v${C_POPFILE_MAJOR_VERSION}.${C_POPFILE_MINOR_VERSION}.${C_POPFILE_REVISION}.change"
  !define C_RELEASE_NOTES "..\engine\${C_README}"

  ;----------------------------------------------------------------------
  ; Root directory for the Perl files (used when building the installer)
  ;----------------------------------------------------------------------

  !define C_PERL_DIR      "C:\Perl"

  ;----------------------------------------------------------------------------------
  ; Root directory for the Kakasi package.
  ;
  ; The Kakasi package is distributed as a ZIP file which contains several folders
  ; (bin, doc, include, lib and share) all of which are under a top level folder
  ; called 'kakasi'. 'C_KAKASI_DIR' is used to refer to the folder into which the
  ; Kakasi ZIP file has been unzipped so that NSIS can find the files when making the installer.
  ;
  ; The 'itaijidict' file's path should be '${C_KAKASI_DIR}\kakasi\share\kakasi\itaijidict'
  ; The 'kanwadict'  file's path should be '${C_KAKASI_DIR}\kakasi\share\kakasi\kanwadict'
  ;----------------------------------------------------------------------------------

  !define C_KAKASI_DIR      "kakasi_package"

  ;-------------------------------------------------------------------------------
  ; Constant used to avoid problems with Banner.dll
  ;
  ; (some versions of the DLL do not like being 'destroyed' immediately)
  ;-------------------------------------------------------------------------------

  ; Minimum time for the banner to be shown (in milliseconds)

  !define C_MIN_BANNER_DISPLAY_TIME    250

#--------------------------------------------------------------------------
# User Registers (Global)
#--------------------------------------------------------------------------

  ; This script uses 'User Variables' (with names starting with 'G_') to hold GLOBAL data.

  Var G_ROOTDIR            ; full path to the folder used for the POPFile PROGRAM files
  Var G_USERDIR            ; full path to the folder containing the 'popfile.cfg' file
  Var G_MPLIBDIR           ; full path to the folder used for the rest of the minimal Perl files

  Var G_GUI                ; GUI port (1-65535)

  Var G_PFIFLAG            ; Multi-purpose variable:
                            ; (1) used to indicate if banner was shown before the 'WELCOME' page
                            ; (2) used to avoid unnecessary Install/Upgrade button text updates

  Var G_NOTEPAD            ; path to notepad.exe ("" = not found in search path)

  Var G_WINUSERNAME        ; current Windows user login name
  Var G_WINUSERTYPE        ; user group ('Admin', 'Power', 'User', 'Guest' or 'Unknown')

  Var G_SFN_DISABLED       ; 1 = short file names not supported, 0 = short file names available

  Var G_PLS_FIELD_1        ; used to customize translated text strings

  Var G_DLGITEM            ; HWND of the UI dialog field we are going to modify

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
# Use the "Modern User Interface", the standard NSIS Section flag utilities
# and the standard NSIS list of common Windows Messages
#--------------------------------------------------------------------------

  !include "MUI.nsh"
  !include "Sections.nsh"
  !include "WinMessages.nsh"

#--------------------------------------------------------------------------
# Version Information settings (for the installer EXE and uninstaller EXE)
#--------------------------------------------------------------------------

  ; 'VIProductVersion' format is X.X.X.X where X is a number in range 0 to 65535
  ; representing the following values: Major.Minor.Release.Build

  VIProductVersion "${C_POPFILE_MAJOR_VERSION}.${C_POPFILE_MINOR_VERSION}.${C_POPFILE_REVISION}.0"

  VIAddVersionKey "ProductName"      "${C_PFI_PRODUCT}"
  VIAddVersionKey "Comments"         "POPFile Homepage: http://getpopfile.org"
  VIAddVersionKey "CompanyName"      "The POPFile Project"
  VIAddVersionKey "LegalCopyright"   "Copyright (c) 2004  John Graham-Cumming"
  VIAddVersionKey "FileDescription"  "POPFile Automatic email classification"
  VIAddVersionKey "FileVersion"      "${C_PFI_VERSION}"
  VIAddVersionKey "OriginalFilename" "${C_OUTFILE}"

  !ifndef ENGLISH_MODE
    !ifndef NO_KAKASI
      VIAddVersionKey "Build"        "Multi-Language installer (with Kakasi)"
    !else
      VIAddVersionKey "Build"        "Multi-Language installer (without Kakasi)"
    !endif
  !else
    !ifndef NO_KAKASI
      VIAddVersionKey "Build"        "English-Mode installer (with Kakasi)"
    !else
      VIAddVersionKey "Build"        "English-Mode installer (without Kakasi)"
    !endif
  !endif

  VIAddVersionKey "Build Date/Time"  "${__DATE__} @ ${__TIME__}"
  VIAddVersionKey "Build Script"     "${__FILE__}${MB_NL}(${__TIMESTAMP__})"

#--------------------------------------------------------------------------
# Include private library functions and macro definitions
#--------------------------------------------------------------------------

  ; Avoid compiler warnings by disabling the functions and definitions we do not use

  !define INSTALLER

  !include "pfi-library.nsh"
  !include "WriteEnvStr.nsh"

#--------------------------------------------------------------------------
# Configure the MUI pages
#--------------------------------------------------------------------------

  ;----------------------------------------------------------------
  ; Interface Settings - General Interface Settings
  ;----------------------------------------------------------------

  ; The icon files for the installer and uninstaller must have the same structure. For example,
  ; if one icon file contains a 32x32 16-colour image and a 16x16 16-colour image then the other
  ; file cannot just contain a 32x32 16-colour image, it must also have a 16x16 16-colour image.
  ; The order of the images in each icon file must also be the same.

  !define MUI_ICON                            "POPFileIcon\popfile.ico"
  !define MUI_UNICON                          "remove.ico"

  ; The "Header" bitmap appears on all pages of the installer (except 'WELCOME' & 'FINISH')
  ; and on all pages of the uninstaller.

  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP              "hdr-common.bmp"
  !define MUI_HEADERIMAGE_RIGHT

  ;----------------------------------------------------------------
  ;  Interface Settings - Interface Resource Settings
  ;----------------------------------------------------------------

  ; The banner provided by the default 'modern.exe' UI does not provide much room for the
  ; two lines of text, e.g. the German version is truncated, so we use a custom UI which
  ; provides slightly wider text areas. Each area is still limited to a single line of text.

  !define MUI_UI                              "UI\pfi_modern.exe"

  ; The 'hdr-common.bmp' logo is only 90 x 57 pixels, much smaller than the 150 x 57 pixel
  ; space provided by the default 'modern_headerbmpr.exe' UI, so we use a custom UI which
  ; leaves more room for the TITLE and SUBTITLE text.

  !define MUI_UI_HEADERIMAGE_RIGHT            "UI\pfi_headerbmpr.exe"

  ;----------------------------------------------------------------
  ;  Interface Settings - WELCOME/FINISH Page Interface Settings
  ;----------------------------------------------------------------

  ; The "Special" bitmap appears on the 'WELCOME' and 'FINISH' pages

  !define MUI_WELCOMEFINISHPAGE_BITMAP        "special.bmp"

  ;----------------------------------------------------------------
  ;  Interface Settings - Installer FINISH Page Interface Settings
  ;----------------------------------------------------------------

  ; Debug aid: Hide the installation log but let user display it (using "Show details" button)

  !define MUI_FINISHPAGE_NOAUTOCLOSE

  ;----------------------------------------------------------------
  ;  Interface Settings - Abort Warning Settings
  ;----------------------------------------------------------------

  ; Show a message box with a warning when the user closes the installation

  !define MUI_ABORTWARNING

  ;----------------------------------------------------------------
  ; Customize MUI - General Custom Function
  ;----------------------------------------------------------------

  ; Use a custom '.onGUIInit' function to add language-specific texts to custom page INI files

  !define MUI_CUSTOMFUNCTION_GUIINIT          "PFIGUIInit"

  ;----------------------------------------------------------------
  ; Language Settings for MUI pages
  ;----------------------------------------------------------------

  ; Same "Language selection" dialog is used for the installer and the uninstaller
  ; so we override the standard "Installer Language" title to avoid confusion.

  !define MUI_LANGDLL_WINDOWTITLE             "Language Selection"

  ; Always show the language selection dialog, even if a language has been stored in the
  ; registry (the language stored in the registry will be selected as the default language)
  ; This makes it easy to recover from a previous 'bad' choice of language for the installer

  !define MUI_LANGDLL_ALWAYSSHOW

  ; Remember user's language selection and offer this as the default when re-installing
  ; (uninstaller also uses this setting to determine which language is to be used)

  !define MUI_LANGDLL_REGISTRY_ROOT           "HKCU"
  !define MUI_LANGDLL_REGISTRY_KEY            "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI"
  !define MUI_LANGDLL_REGISTRY_VALUENAME      "Installer Language"

#--------------------------------------------------------------------------
# Define the Page order for the installer (and the uninstaller)
#--------------------------------------------------------------------------

  ;---------------------------------------------------
  ; Installer Page - WELCOME
  ;---------------------------------------------------

  ; Use a "pre" function for the 'WELCOME' page to get the user name and user rights
  ; (For this build, if user has 'Admin' rights we perform a multi-user install,
  ; otherwise we perform a single-user install)

  !define MUI_PAGE_CUSTOMFUNCTION_PRE         "CheckUserRights"

  !define MUI_WELCOMEPAGE_TEXT                "$(PFI_LANG_WELCOME_INFO_TEXT)"

  !insertmacro MUI_PAGE_WELCOME

  ;---------------------------------------------------
  ; Installer Page - Check some system requirements of the minimal Perl we install
  ;---------------------------------------------------

  Page custom CheckPerlRequirementsPage

  ;---------------------------------------------------
  ; Installer Page - License Page (uses English GPL)
  ;---------------------------------------------------

  ; Three styles of 'License Agreement' page are available:
  ; (1) New style with an 'I accept' checkbox below the license window
  ; (2) New style with 'I accept/I do not accept' radio buttons below the license window
  ; (3) Classic style with the 'Next' button replaced by an 'Agree' button
  ;     (to get the 'Classic' style, comment-out the CHECKBOX and the RADIOBUTTONS 'defines')

  !define MUI_LICENSEPAGE_CHECKBOX
##  !define MUI_LICENSEPAGE_RADIOBUTTONS

  !insertmacro MUI_PAGE_LICENSE               "..\engine\license"

  ;---------------------------------------------------
  ; Installer Page - Select Components to be installed
  ;---------------------------------------------------

  !insertmacro MUI_PAGE_COMPONENTS

  ;---------------------------------------------------
  ; Installer Page - Select Installation Directory
  ;---------------------------------------------------

  ; Use a "pre" function to select an initial value for the PROGRAM files installation folder

  !define MUI_PAGE_CUSTOMFUNCTION_PRE         "CheckForExistingLocation"

  ; Use a "leave" function to check if we are upgrading an existing installation

  !define MUI_PAGE_CUSTOMFUNCTION_LEAVE       "CheckExistingProgDir"

  ; This page is used to select the folder for the POPFile PROGRAM files

  !define MUI_PAGE_HEADER_TEXT                "$(PFI_LANG_ROOTDIR_TITLE)"
  !define MUI_DIRECTORYPAGE_TEXT_DESTINATION  "$(PFI_LANG_ROOTDIR_TEXT_DESTN)"

  !insertmacro MUI_PAGE_DIRECTORY

  ;---------------------------------------------------
  ; Installer Page - Install POPFile PROGRAM files
  ;---------------------------------------------------

  ; Replace the standard "Installation Complete/Setup was completed successfully" header
  ; with one indicating that the next step is to configure POPFile

  !define MUI_INSTFILESPAGE_FINISHHEADER_TEXT    "$(PFI_LANG_INSTFINISH_TITLE)"
  !define MUI_INSTFILESPAGE_FINISHHEADER_SUBTEXT "$(PFI_LANG_INSTFINISH_SUBTITLE)"

  !insertmacro MUI_PAGE_INSTFILES

  ;---------------------------------------------------
  ; Installer Page - FINISH
  ;---------------------------------------------------

  ; Use a "pre" function for the FINISH page to run the 'Add POPFile User' wizard to
  ; configure POPFile for the user running the installer.

  ; For this build we skip our own FINISH page and disable the wizard's language selection
  ; dialog to make the wizard appear as an extension of the main 'setup.exe' installer.

  !define MUI_PAGE_CUSTOMFUNCTION_PRE         "InstallUserData"

  ; Provide a checkbox to let user display the Release Notes for this version of POPFile

  !define MUI_FINISHPAGE_SHOWREADME
  !define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
  !define MUI_FINISHPAGE_SHOWREADME_FUNCTION  "ShowReadMe"

  !insertmacro MUI_PAGE_FINISH

  ;---------------------------------------------------
  ; Uninstaller Page - Confirmation Page
  ;---------------------------------------------------

  !insertmacro MUI_UNPAGE_CONFIRM

  ;---------------------------------------------------
  ; Uninstaller Page - Uninstall POPFile
  ;---------------------------------------------------

  !insertmacro MUI_UNPAGE_INSTFILES

#--------------------------------------------------------------------------
# Language Support for the installer and uninstaller
#--------------------------------------------------------------------------

  ;-----------------------------------------
  ; Select the languages to be supported by installer/uninstaller.
  ;-----------------------------------------

  ; At least one language must be specified for the installer (the default is "English")

  !insertmacro PFI_LANG_LOAD "English"

  ; Conditional compilation: if ENGLISH_MODE is defined, support only 'English'

  !ifndef ENGLISH_MODE

        !include "pfi-languages.nsh"

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

  InstallDir "$PROGRAMFILES\${C_PFI_PRODUCT}"
  InstallDirRegKey HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "InstallPath"

#--------------------------------------------------------------------------
# Reserve the files required by the installer (to improve performance)
#--------------------------------------------------------------------------

  ; Things that need to be extracted on startup (keep these lines before any File command!)
  ; Only useful when solid compression is used (by default, solid compression is enabled
  ; for BZIP2 and LZMA compression)

  !insertmacro MUI_RESERVEFILE_LANGDLL
  !insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
  ReserveFile "${NSISDIR}\Plugins\Banner.dll"
  ReserveFile "${NSISDIR}\Plugins\NSISdl.dll"
  ReserveFile "${NSISDIR}\Plugins\System.dll"
  ReserveFile "${NSISDIR}\Plugins\UserInfo.dll"
  ReserveFile "ioG.ini"
  ReserveFile "${C_RELEASE_NOTES}"

#--------------------------------------------------------------------------
# Installer Function: .onInit - installer starts by offering a choice of languages
#--------------------------------------------------------------------------

Function .onInit

  ; The reason why '.onInit' preserves the registers it uses is that it makes debugging easier!

  !define L_INPUT_FILE_HANDLE   $R9
  !define L_OUTPUT_FILE_HANDLE  $R8
  !define L_TEMP                $R7

  Push ${L_INPUT_FILE_HANDLE}
  Push ${L_OUTPUT_FILE_HANDLE}
  Push ${L_TEMP}

  ; Conditional compilation: if ENGLISH_MODE is defined, support only 'English'

  !ifndef ENGLISH_MODE
        !insertmacro MUI_LANGDLL_DISPLAY
  !endif

  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioG.ini"
  File "/oname=$PLUGINSDIR\${C_README}" "${C_RELEASE_NOTES}"

  ; Ensure the release notes are in a format which the standard Windows NOTEPAD.EXE can use.
  ; When the "POPFile" section is processed, the converted release notes will be copied to the
  ; installation directory to ensure user has a copy which can be read by NOTEPAD.EXE later.

  FileOpen ${L_INPUT_FILE_HANDLE}  "$PLUGINSDIR\${C_README}" r
  FileOpen ${L_OUTPUT_FILE_HANDLE} "$PLUGINSDIR\${C_README}.txt" w
  ClearErrors

loop:
  FileRead ${L_INPUT_FILE_HANDLE} ${L_TEMP}
  IfErrors close_files
  Push ${L_TEMP}
  Call TrimNewlines
  Pop ${L_TEMP}
  FileWrite ${L_OUTPUT_FILE_HANDLE} "${L_TEMP}${MB_NL}"
  Goto loop

close_files:
  FileClose ${L_INPUT_FILE_HANDLE}
  FileClose ${L_OUTPUT_FILE_HANDLE}

  Pop ${L_TEMP}
  Pop ${L_OUTPUT_FILE_HANDLE}
  Pop ${L_INPUT_FILE_HANDLE}

  !undef L_INPUT_FILE_HANDLE
  !undef L_OUTPUT_FILE_HANDLE
  !undef L_TEMP

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: PFIGUIInit
# (custom .onGUIInit function)
#
# Used to complete the initialization of the installer.
# This code was moved from '.onInit' in order to permit the use of language-specific strings
# (the selected language is not available inside the '.onInit' function)
#--------------------------------------------------------------------------

Function PFIGUIInit

  !define L_RESERVED      $1    ; used in the system.dll call

  Push ${L_RESERVED}

  ; Ensure only one copy of this installer is running

  System::Call 'kernel32::CreateMutexA(i 0, i 0, t "OnlyOnePFI_mutex") i .r1 ?e'
  Pop ${L_RESERVED}
  StrCmp ${L_RESERVED} 0 mutex_ok
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(PFI_LANG_INSTALLER_MUTEX)"
  Abort

mutex_ok:
  SearchPath $G_NOTEPAD notepad.exe

  ; Assume user displays the release notes

  StrCpy $G_PFIFLAG "no banner"

  MessageBox MB_YESNO|MB_ICONQUESTION \
      "$(PFI_LANG_MBRELNOTES_1)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_MBRELNOTES_2)" IDNO notes_ignored

  StrCmp $G_NOTEPAD "" use_file_association
  Exec 'notepad.exe "$PLUGINSDIR\${C_README}.txt"'
  GoTo continue

use_file_association:
  ExecShell "open" "$PLUGINSDIR\${C_README}.txt"
  Goto continue

notes_ignored:

  ; There may be a slight delay at this point and on some systems the 'WELCOME' page may appear
  ; in two stages (first an empty MUI page appears and a little later the page contents appear).
  ; This looks a little strange (and may prompt the user to start clicking buttons too soon)
  ; so we display a banner to reassure the user. The banner will be removed by 'CheckUserRights'

  StrCpy $G_PFIFLAG "banner displayed"

  Call ShowPleaseWaitBanner

continue:

  !ifndef NO_KAKASI

      ; Ensure the 'Kakasi' section is selected if 'Japanese' has been chosen

      Call HandleKakasi

  !endif

  ; At present (14 March 2004) POPFile does not work properly if POPFILE_ROOT or POPFILE_USER
  ; are set to values containing spaces. A simple workaround is to use short file name format
  ; values for these environment variables. But some systems may not support short file names
  ; (e.g. using short file names on NTFS volumes can have a significant impact on performance)
  ; so we need to check if short file names are supported (if they are not, we insist upon paths
  ; which do not contain spaces).

  ; There are two registry keys of interest: one for NTFS and one for FAT. NSIS can check the
  ; NTFS setting directly as it is a DWORD value but it is unable to check the FAT setting as
  ; it is stored as a BINARY value (the built-in NSIS commands can only read DWORD and STRING
  ; values). A command-line option can be used to force the installer to insist upon paths
  ; which do not contain spaces.

  Call GetParameters
  Pop ${L_RESERVED}
  StrCmp ${L_RESERVED} "/nospaces" 0 check_registry
  StrCpy $G_SFN_DISABLED "1"
  Goto exit

check_registry:
  ReadRegDWORD $G_SFN_DISABLED \
      HKLM "System\CurrentControlSet\Control\FileSystem" "NtfsDisable8dot3NameCreation"
  StrCmp $G_SFN_DISABLED "1" exit
  StrCpy $G_SFN_DISABLED "0"

exit:
  Pop ${L_RESERVED}

  !undef L_RESERVED

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: .onVerifyInstDir
#
# This function is called every time the user changes the installation directory. It ensures
# that the button used to start the installation process is labelled "Install" or "Upgrade"
# depending upon the currently selected directory. As this function is called EVERY time the
# directory is altered, the button text is only updated when a change is required.
#
# The '$G_PFIFLAG' global variable is initialized by 'CheckForExistingLocation'
# (the "pre" function for the PROGRAM DIRECTORY page).
#--------------------------------------------------------------------------

Function .onVerifyInstDir

  IfFileExists "$INSTDIR\popfile.pl" upgrade
  StrCmp $G_PFIFLAG "install" exit
  StrCpy $G_PFIFLAG "install"
  GetDlgItem $G_DLGITEM $HWNDPARENT 1
  SendMessage $G_DLGITEM ${WM_SETTEXT} 0 "STR:$(^InstallBtn)"
  Goto exit

upgrade:
  StrCmp $G_PFIFLAG "upgrade" exit
  StrCpy $G_PFIFLAG "upgrade"
  GetDlgItem $G_DLGITEM $HWNDPARENT 1
  SendMessage $G_DLGITEM ${WM_SETTEXT} 0 "STR:$(PFI_LANG_INST_BTN_UPGRADE)"

exit:
FunctionEnd

#--------------------------------------------------------------------------
# Installer Section: POPFile component (always installed)
#
# (a) If upgrading, shutdown existing version and rearrange minimal Perl files
# (b) Create registry entries (HKLM and/or HKCU) for POPFile program files
# (c) Install POPFile core program files and release notes
# (d) Install minimal Perl system
# (e) Write the uninstaller program and create/update the Start Menu shortcuts
# (f) Create 'Add/Remove Program' entry
#--------------------------------------------------------------------------

Section "POPFile" SecPOPFile

  ; Make this section mandatory (i.e. it is always installed)

  SectionIn RO

  !define L_RESULT        $R9
  !define L_TEMP          $R8

  Push ${L_RESULT}
  Push ${L_TEMP}

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_UPGRADE) $(PFI_LANG_TAKE_A_FEW_SECONDS)"
  SetDetailsPrint listonly

  ; Before POPFile 0.21.0, POPFile and the minimal Perl shared the same folder structure
  ; and there was only one set of user data (stored in the same folder as POPFile).

  ; Phase 1 of the multi-user support introduced in 0.21.0 required some slight changes
  ; to the folder structure (to permit POPFile to be run from any folder after setting the
  ; POPFILE_ROOT and POPFILE_USER environment variables to appropriate values).

  ; The folder arrangement used for this build:
  ;
  ; (a) $INSTDIR         -  main POPFile installation folder, holds popfile.pl and several
  ;                         other *.pl scripts, runpopfile.exe, popfile*.exe plus three of the
  ;                         minimal Perl files (perl.exe, wperl.exe and perl58.dll)
  ;
  ; (b) $INSTDIR\kakasi  -  holds the Kakasi package used to process Japanese email
  ;                         (only installed when Japanese support is required)
  ;
  ; (c) $INSTDIR\lib     -  minimal Perl installation (except for the three files stored
  ;                         in the $INSTDIR folder to avoid runtime problems)
  ;
  ; (d) $INSTDIR\*       -  the remaining POPFile folders (Classifier, languages, skins, etc)
  ;
  ; For this build, each user is expected to have separate user data folders. By default each
  ; user data folder will contain popfile.cfg, stopwords, stopwords.default, popfile.db,
  ; the messages folder, etc. The 'Add POPFile User' wizard (adduser.exe) is responsible for
  ; creating/updating these user data folders and for handling conversion of existing flat file
  ; or BerkeleyDB corpus files to the new SQL database format.
  ;
  ; For increased flexibility, some global user variables are used in addition to $INSTDIR
  ; (this makes it easier to change the folder structure used by the installer).

  StrCpy $G_ROOTDIR   "$INSTDIR"
  StrCpy $G_MPLIBDIR  "$INSTDIR\lib"

  IfFileExists "$G_ROOTDIR\*.*" rootdir_exists
  ClearErrors
  CreateDirectory "$G_ROOTDIR"
  IfErrors 0 rootdir_exists
  SetDetailsPrint both
  DetailPrint "Fatal error: unable to create folder for the POPFile program files"
  SetDetailsPrint listonly
  MessageBox MB_OK|MB_ICONSTOP|MB_TOPMOST "Error: Unable to create folder for the POPFile program files\
      ${MB_NL}${MB_NL}\
      ($G_ROOTDIR)"
  Abort

rootdir_exists:

  ; Starting with POPFile 0.22.0 the system tray icon uses 'localhost' instead of '127.0.0.1'
  ; to display the User Interface (and the installer has been updated to follow suit), so we
  ; need to ensure Win9x systems have a suitable 'hosts' file

  Call IsNT
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "1" continue
  Call CheckHostsFile

continue:

  ; If we are installing over a previous version, ensure that version is not running

  Call MakeRootDirSafe

  ; Starting with 0.21.0, a new structure is used for the minimal Perl (to enable POPFile to
  ; be started from any folder, once POPFILE_ROOT and POPFILE_USER have been initialized)

  Call MinPerlRestructure

  ; Now that the HTML for the UI is no longer embedded in the Perl code, a new skin system is
  ; used so we attempt to convert the existing skins to work with the new system

  Call SkinsRestructure

  StrCmp $G_WINUSERTYPE "Admin" 0 current_user_root
  WriteRegStr HKLM "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "Installer Language" "$LANGUAGE"
  WriteRegStr HKLM "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "POPFile Major Version" "${C_POPFILE_MAJOR_VERSION}"
  WriteRegStr HKLM "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "POPFile Minor Version" "${C_POPFILE_MINOR_VERSION}"
  WriteRegStr HKLM "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "POPFile Revision" "${C_POPFILE_REVISION}"
  WriteRegStr HKLM "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "POPFile RevStatus" "${C_POPFILE_RC}"
  WriteRegStr HKLM "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "InstallPath" "$INSTDIR"
  WriteRegStr HKLM "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "Author" "setup.exe"
  WriteRegStr HKLM "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_LFN" "$G_ROOTDIR"
  StrCmp $G_SFN_DISABLED "0" find_HKLM_root_sfn
  StrCpy ${L_TEMP} "Not supported"
  Goto save_HKLM_root_sfn

find_HKLM_root_sfn:
  GetFullPathName /SHORT ${L_TEMP} "$G_ROOTDIR"

save_HKLM_root_sfn:
  WriteRegStr HKLM "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_SFN" "${L_TEMP}"

current_user_root:
  WriteRegStr HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "Installer Language" "$LANGUAGE"
  WriteRegStr HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "POPFile Major Version" "${C_POPFILE_MAJOR_VERSION}"
  WriteRegStr HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "POPFile Minor Version" "${C_POPFILE_MINOR_VERSION}"
  WriteRegStr HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "POPFile Revision" "${C_POPFILE_REVISION}"
  WriteRegStr HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "POPFile RevStatus" "${C_POPFILE_RC}"
  WriteRegStr HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "InstallPath" "$INSTDIR"
  WriteRegStr HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "Author" "setup.exe"
  WriteRegStr HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_LFN" "$G_ROOTDIR"
  StrCmp $G_SFN_DISABLED "0" find_HKCU_root_sfn
  StrCpy ${L_TEMP} "Not supported"
  Goto save_HKCU_root_sfn

find_HKCU_root_sfn:
  GetFullPathName /SHORT ${L_TEMP} "$G_ROOTDIR"

save_HKCU_root_sfn:
  WriteRegStr HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_SFN" "${L_TEMP}"

  ; Install the POPFile Core files

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_CORE)"
  SetDetailsPrint listonly

  SetOutPath "$G_ROOTDIR"

  ; Remove redundant files (from earlier test versions of the installer)

  Delete "$G_ROOTDIR\wrapper.exe"
  Delete "$G_ROOTDIR\wrapperf.exe"
  Delete "$G_ROOTDIR\wrapperb.exe"

  ; Install POPFile 'core' files

  File "..\engine\license"
  File "${C_RELEASE_NOTES}"
  CopyFiles /SILENT /FILESONLY "$PLUGINSDIR\${C_README}.txt" "$G_ROOTDIR\${C_README}.txt"

  File "..\engine\popfile.exe"
  File "..\engine\popfilef.exe"
  File "..\engine\popfileb.exe"
  File "..\engine\popfileif.exe"
  File "..\engine\popfileib.exe"
  File "..\engine\popfile-service.exe"
  File /nonfatal "/oname=pfi-stopwords.default" "..\engine\stopwords"

  File "runpopfile.exe"
  File "stop_pf.exe"
  File "sqlite.exe"
  File "runsqlite.exe"
  File "adduser.exe"
  File /nonfatal "test\pfidiag.exe"
  File "msgcapture.exe"

  IfFileExists "$G_ROOTDIR\pfimsgcapture.exe" 0 app_paths
  Delete "$G_ROOTDIR\pfimsgcapture.exe"
  File "/oname=pfimsgcapture.exe" "msgcapture.exe"

app_paths:

  ; Add 'stop_pf.exe' to 'App Paths' to allow it to be run using Start -> Run -> stop_pf params

  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\stop_pf.exe" \
      "" "$G_ROOTDIR\stop_pf.exe"

  SetOutPath "$G_ROOTDIR"

  File "..\engine\popfile.pl"
  File "..\engine\popfile.pck"
  File "..\engine\insert.pl"
  File "..\engine\bayes.pl"
  File "..\engine\pipe.pl"

  File "..\engine\pix.gif"
  File "..\engine\favicon.ico"
  File "..\engine\black.gif"
  File "..\engine\otto.gif"
  File "..\engine\otto.png"

  SetOutPath "$G_ROOTDIR\Classifier"
  File "..\engine\Classifier\Bayes.pm"
  File "..\engine\Classifier\WordMangle.pm"
  File "..\engine\Classifier\MailParse.pm"
  IfFileExists "$G_ROOTDIR\Classifier\popfile.sql" update_the_schema

no_previous_version:
  WriteINIStr "$G_ROOTDIR\pfi-data.ini" "Settings" "Owner" "$G_WINUSERNAME"
  DeleteINIStr "$G_ROOTDIR\pfi-data.ini" "Settings" "OldSchema"
  Goto install_schema

update_the_schema:
  Push "$G_ROOTDIR\Classifier\popfile.sql"
  Call GetPOPFileSchemaVersion
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "()" assume_early_schema
  StrCpy ${L_TEMP} ${L_RESULT} 1
  StrCmp ${L_TEMP} "(" no_previous_version remember_version

assume_early_schema:
  StrCpy ${L_RESULT} "0"

remember_version:
  WriteINIStr "$G_ROOTDIR\pfi-data.ini" "Settings" "Owner" "$G_WINUSERNAME"
  WriteINIStr "$G_ROOTDIR\pfi-data.ini" "Settings" "OldSchema" "${L_RESULT}"

install_schema:
  File "..\engine\Classifier\popfile.sql"

  SetOutPath "$G_ROOTDIR\Platform"
  File "..\engine\Platform\MSWin32.pm"
  Delete "$G_ROOTDIR\Platform\POPFileIcon.dll"

  SetOutPath "$G_ROOTDIR\POPFile"
  File "..\engine\POPFile\MQ.pm"
  File "..\engine\POPFile\Database.pm"
  File "..\engine\POPFile\History.pm"
  File "..\engine\POPFile\Loader.pm"
  File "..\engine\POPFile\Logger.pm"
  File "..\engine\POPFile\Module.pm"
  File "..\engine\POPFile\Mutex.pm"
  File "..\engine\POPFile\Configuration.pm"
  File "..\engine\POPFile\popfile_version"

  SetOutPath "$G_ROOTDIR\Proxy"
  File "..\engine\Proxy\Proxy.pm"
  File "..\engine\Proxy\POP3.pm"

  SetOutPath "$G_ROOTDIR\UI"
  File "..\engine\UI\HTML.pm"
  File "..\engine\UI\HTTP.pm"

  ; 'English' version of the QuickStart Guide

  SetOutPath "$G_ROOTDIR\manual"
  File "..\engine\manual\*.gif"

  SetOutPath "$G_ROOTDIR\manual\en"
  File "..\engine\manual\en\*.html"

  ; Default UI language

  SetOutPath "$G_ROOTDIR\languages"
  File "..\engine\languages\English.msg"

  ; Default UI skin (the POPFile UI looks better if a skin is used)

  SetOutPath "$G_ROOTDIR\skins\default"
  File "..\engine\skins\default\*.*"

  ; Install the Minimal Perl files

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_PERL)"
  SetDetailsPrint listonly

  SetOutPath "$G_ROOTDIR"
  File "${C_PERL_DIR}\bin\perl.exe"
  File "${C_PERL_DIR}\bin\wperl.exe"
  File "${C_PERL_DIR}\bin\perl58.dll"

  SetOutPath "$G_MPLIBDIR"
  File "${C_PERL_DIR}\lib\AutoLoader.pm"
  File "${C_PERL_DIR}\lib\Carp.pm"
  File "${C_PERL_DIR}\lib\Config.pm"
  File "${C_PERL_DIR}\lib\constant.pm"
  File "${C_PERL_DIR}\lib\DynaLoader.pm"
  File "${C_PERL_DIR}\lib\Errno.pm"
  File "${C_PERL_DIR}\lib\Exporter.pm"
  File "${C_PERL_DIR}\lib\Fcntl.pm"
  File "${C_PERL_DIR}\lib\integer.pm"
  File "${C_PERL_DIR}\lib\IO.pm"
  File "${C_PERL_DIR}\lib\lib.pm"
  File "${C_PERL_DIR}\lib\locale.pm"
  File "${C_PERL_DIR}\lib\POSIX.pm"
  File "${C_PERL_DIR}\lib\re.pm"
  File "${C_PERL_DIR}\lib\SelectSaver.pm"
  File "${C_PERL_DIR}\lib\Socket.pm"
  File "${C_PERL_DIR}\lib\strict.pm"
  File "${C_PERL_DIR}\lib\Symbol.pm"
  File "${C_PERL_DIR}\lib\vars.pm"
  File "${C_PERL_DIR}\lib\warnings.pm"
  File "${C_PERL_DIR}\lib\XSLoader.pm"

  SetOutPath "$G_MPLIBDIR\Carp"
  File "${C_PERL_DIR}\lib\Carp\*"

  SetOutPath "$G_MPLIBDIR\Date"
  File "${C_PERL_DIR}\site\lib\Date\Format.pm"
  File "${C_PERL_DIR}\site\lib\Date\Parse.pm"

  SetOutPath "$G_MPLIBDIR\Digest"
  File "${C_PERL_DIR}\lib\Digest\MD5.pm"

  SetOutPath "$G_MPLIBDIR\Exporter"
  File "${C_PERL_DIR}\lib\Exporter\*"

  SetOutPath "$G_MPLIBDIR\File"
  File "${C_PERL_DIR}\lib\File\Copy.pm"
  File "${C_PERL_DIR}\lib\File\Glob.pm"
  File "${C_PERL_DIR}\lib\File\Spec.pm"

  SetOutPath "$G_MPLIBDIR\File\Spec"
  File "${C_PERL_DIR}\lib\File\Spec\Unix.pm"
  File "${C_PERL_DIR}\lib\File\Spec\Win32.pm"

  SetOutPath "$G_MPLIBDIR\Getopt"
  File "${C_PERL_DIR}\lib\Getopt\Long.pm"

  SetOutPath "$G_MPLIBDIR\HTML"
  File "${C_PERL_DIR}\site\lib\HTML\Tagset.pm"
  File "${C_PERL_DIR}\site\lib\HTML\Template.pm"

  SetOutPath "$G_MPLIBDIR\IO"
  File "${C_PERL_DIR}\lib\IO\*"

  SetOutPath "$G_MPLIBDIR\IO\Socket"
  File "${C_PERL_DIR}\lib\IO\Socket\*"

  SetOutPath "$G_MPLIBDIR\MIME"
  File "${C_PERL_DIR}\lib\MIME\*"

  SetOutPath "$G_MPLIBDIR\Sys"
  File "${C_PERL_DIR}\lib\Sys\*"

  SetOutPath "$G_MPLIBDIR\Text"
  File "${C_PERL_DIR}\lib\Text\ParseWords.pm"

  SetOutPath "$G_MPLIBDIR\Time"
  File "${C_PERL_DIR}\lib\Time\Local.pm"
  File "${C_PERL_DIR}\site\lib\Time\Zone.pm"

  SetOutPath "$G_MPLIBDIR\warnings"
  File "${C_PERL_DIR}\lib\warnings\register.pm"

  SetOutPath "$G_MPLIBDIR\auto\Digest\MD5"
  File "${C_PERL_DIR}\lib\auto\Digest\MD5\*"

  SetOutPath "$G_MPLIBDIR\auto\DynaLoader"
  File "${C_PERL_DIR}\lib\auto\DynaLoader\*"

  SetOutPath "$G_MPLIBDIR\auto\File\Glob"
  File "${C_PERL_DIR}\lib\auto\File\Glob\*"

  SetOutPath "$G_MPLIBDIR\auto\IO"
  File "${C_PERL_DIR}\lib\auto\IO\*"

  SetOutPath "$G_MPLIBDIR\auto\MIME\Base64"
  File "${C_PERL_DIR}\lib\auto\MIME\Base64\*"

  SetOutPath "$G_MPLIBDIR\auto\POSIX"
  File "${C_PERL_DIR}\lib\auto\POSIX\POSIX.dll"
  File "${C_PERL_DIR}\lib\auto\POSIX\autosplit.ix"
  File "${C_PERL_DIR}\lib\auto\POSIX\load_imports.al"

  SetOutPath "$G_MPLIBDIR\auto\Fcntl"
  File "${C_PERL_DIR}\lib\auto\Fcntl\Fcntl.dll"

  SetOutPath "$G_MPLIBDIR\auto\Socket"
  File "${C_PERL_DIR}\lib\auto\Socket\*"

  SetOutPath "$G_MPLIBDIR\auto\Sys\Hostname"
  File "${C_PERL_DIR}\lib\auto\Sys\Hostname\*"

  ; Install Perl modules and library files for BerkeleyDB support
  ; (required in case we have to convert BerkeleyDB corpus files from an earlier version)

  SetOutPath "$G_MPLIBDIR"
  File "${C_PERL_DIR}\site\lib\BerkeleyDB.pm"
  File "${C_PERL_DIR}\lib\UNIVERSAL.pm"

  SetOutPath "$G_MPLIBDIR\auto\BerkeleyDB"
  File "${C_PERL_DIR}\site\lib\auto\BerkeleyDB\autosplit.ix"
  File "${C_PERL_DIR}\site\lib\auto\BerkeleyDB\BerkeleyDB.bs"
  File "${C_PERL_DIR}\site\lib\auto\BerkeleyDB\BerkeleyDB.dll"
  File "${C_PERL_DIR}\site\lib\auto\BerkeleyDB\BerkeleyDB.exp"
  File "${C_PERL_DIR}\site\lib\auto\BerkeleyDB\BerkeleyDB.lib"

  ; Install Perl modules and library files for SQLite support

  SetOutPath "$G_MPLIBDIR"
  File "${C_PERL_DIR}\lib\base.pm"
  File "${C_PERL_DIR}\lib\overload.pm"
  File "${C_PERL_DIR}\site\lib\DBI.pm"

  SetOutPath "$G_MPLIBDIR\DBD"
  File "${C_PERL_DIR}\site\lib\DBD\SQLite.pm"

  SetOutPath "$G_MPLIBDIR\auto\DBD\SQLite"
  File "${C_PERL_DIR}\site\lib\auto\DBD\SQLite\SQLite.bs"
  File "${C_PERL_DIR}\site\lib\auto\DBD\SQLite\SQLite.dll"
  File "${C_PERL_DIR}\site\lib\auto\DBD\SQLite\SQLite.exp"
  File "${C_PERL_DIR}\site\lib\auto\DBD\SQLite\SQLite.lib"

  SetOutPath "$G_MPLIBDIR\auto\DBI"
  File "${C_PERL_DIR}\site\lib\auto\DBI\DBI.bs"
  File "${C_PERL_DIR}\site\lib\auto\DBI\DBI.dll"
  File "${C_PERL_DIR}\site\lib\auto\DBI\DBI.exp"
  File "${C_PERL_DIR}\site\lib\auto\DBI\DBI.lib"

  ; Create the uninstall program BEFORE creating the shortcut to it
  ; (this ensures that the correct "uninstall" icon appears in the START MENU shortcut)

  SetOutPath "$G_ROOTDIR"
  Delete "$G_ROOTDIR\uninstall.exe"
  WriteUninstaller "$G_ROOTDIR\uninstall.exe"

  ; Attempt to remove some StartUp and Start Menu shortcuts created by previous installations

  SetShellVarContext all
  Delete "$SMSTARTUP\Run POPFile.lnk"
  Delete "$SMSTARTUP\Run POPFile in background.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Run POPFile in background.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Manual.url"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\POPFile Manual.url"

  SetShellVarContext current
  Delete "$SMSTARTUP\Run POPFile.lnk"
  Delete "$SMSTARTUP\Run POPFile in background.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Run POPFile in background.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Manual.url"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\POPFile Manual.url"

  ; Create the START MENU entries

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_SHORT)"
  SetDetailsPrint listonly

  ; 'CreateShortCut' uses '$OUTDIR' as the working directory for the shortcut
  ; ('SetOutPath' is one way to change the value of $OUTDIR)

  ; 'CreateShortCut' fails to update existing shortcuts if they are read-only, so try to clear
  ; the read-only attribute first. Similar handling is required for the Internet shortcuts.

  ; If the user has 'Admin' rights, create a 'POPFile' folder with a set of shortcuts in
  ; the 'All Users' Start Menu . If the user does not have 'Admin' rights, the shortcuts
  ; are created in the 'Current User' Start Menu.

  ; If the 'All Users' folder is not found, NSIS will return the 'Current User' folder.

  SetShellVarContext all
  StrCmp $G_WINUSERTYPE "Admin" create_shortcuts
  SetShellVarContext current

create_shortcuts:
  SetOutPath "$SMPROGRAMS\${C_PFI_PRODUCT}"
  SetOutPath "$G_ROOTDIR"

  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Run POPFile.lnk" NORMAL
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Run POPFile.lnk" \
                 "$G_ROOTDIR\runpopfile.exe"

  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Uninstall POPFile.lnk" NORMAL
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Uninstall POPFile.lnk" \
                 "$G_ROOTDIR\uninstall.exe"

  SetOutPath "$G_ROOTDIR"
  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Release Notes.lnk" NORMAL
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Release Notes.lnk" \
                 "$G_ROOTDIR\${C_README}.txt"

  SetOutPath "$SMPROGRAMS\${C_PFI_PRODUCT}"

  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\POPFile User Interface.url" NORMAL
  WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\POPFile User Interface.url" \
              "InternetShortcut" "URL" "http://${C_UI_URL}:$G_GUI/"

  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Shutdown POPFile.url" NORMAL
  WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\Shutdown POPFile.url" \
              "InternetShortcut" "URL" "http://${C_UI_URL}:$G_GUI/shutdown"

  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\QuickStart Guide.url" NORMAL
  WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\QuickStart Guide.url" \
              "InternetShortcut" "URL" "file://$G_ROOTDIR/manual/en/manual.html"

  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\FAQ.url" NORMAL

  !ifndef ENGLISH_MODE
      StrCmp $LANGUAGE ${LANG_JAPANESE} japanese_faq
  !endif

  WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\FAQ.url" \
              "InternetShortcut" "URL" \
              "http://getpopfile.org/cgi-bin/wiki.pl?FrequentlyAskedQuestions"

  !ifndef ENGLISH_MODE
      Goto support

    japanese_faq:
      WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\FAQ.url" \
                  "InternetShortcut" "URL" \
                  "http://getpopfile.org/cgi-bin/wiki.pl?JP_FrequentlyAskedQuestions"

    support:
  !endif

  SetOutPath "$SMPROGRAMS\${C_PFI_PRODUCT}\Support"

  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\POPFile Home Page.url" NORMAL
  WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\POPFile Home Page.url" \
              "InternetShortcut" "URL" "http://getpopfile.org/"

  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\POPFile Support (Wiki).url" NORMAL

  !ifndef ENGLISH_MODE
      StrCmp $LANGUAGE ${LANG_JAPANESE} japanese_wiki
  !endif

  WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\POPFile Support (Wiki).url" \
              "InternetShortcut" "URL" \
              "http://getpopfile.org/cgi-bin/wiki.pl?POPFileDocumentationProject"

  !ifndef ENGLISH_MODE
      Goto pfidiagnostic

    japanese_wiki:
  WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\POPFile Support (Wiki).url" \
                  "InternetShortcut" "URL" \
                  "http://getpopfile.org/cgi-bin/wiki.pl?JP_POPFileDocumentationProject"

    pfidiagnostic:
  !endif

  IfFileExists "$G_ROOTDIR\pfidiag.exe" 0 silent_shutdown
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\PFI Diagnostic utility.lnk"
  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\PFI Diagnostic utility (simple).lnk" NORMAL
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\PFI Diagnostic utility (simple).lnk" \
                 "$G_ROOTDIR\pfidiag.exe"
  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\PFI Diagnostic utility (full).lnk" NORMAL
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\PFI Diagnostic utility (full).lnk" \
                 "$G_ROOTDIR\pfidiag.exe" "/full"

silent_shutdown:
  SetOutPath "$G_ROOTDIR"

  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Shutdown POPFile silently.lnk" NORMAL
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Shutdown POPFile silently.lnk" \
                 "$G_ROOTDIR\stop_pf.exe" "/showerrors $G_GUI"

  ; Create entry in the Control Panel's "Add/Remove Programs" list

  StrCmp $G_WINUSERTYPE "Admin" use_HKLM

  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "DisplayName" "${C_PFI_PRODUCT} ${C_PFI_VERSION}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "UninstallString" "$G_ROOTDIR\uninstall.exe"
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "NoModify" "1"
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "NoRepair" "1"
  Goto end_section

use_HKLM:
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "DisplayName" "${C_PFI_PRODUCT} ${C_PFI_VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "UninstallString" "$G_ROOTDIR\uninstall.exe"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "NoModify" "1"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "NoRepair" "1"

end_section:
  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_ENDSEC)"
  SetDetailsPrint listonly

  Pop ${L_TEMP}
  Pop ${L_RESULT}

  !undef L_RESULT
  !undef L_TEMP

SectionEnd

#--------------------------------------------------------------------------
# Installer Section: (optional) Skins component (default = selected)
#
# Installs additional skins to allow the look-and-feel of the User Interface
# to be changed. The 'default' skin is always installed (by the 'POPFile'
# section) since this is the default skin for POPFile.
#--------------------------------------------------------------------------

Section "Skins" SecSkins

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_SKINS)"
  SetDetailsPrint listonly

  SetOutPath "$G_ROOTDIR\skins\blue"
  File "..\engine\skins\blue\*.*"

  SetOutPath "$G_ROOTDIR\skins\coolblue"
  File "..\engine\skins\coolblue\*.*"

  SetOutPath "$G_ROOTDIR\skins\coolbrown"
  File "..\engine\skins\coolbrown\*.*"

  SetOutPath "$G_ROOTDIR\skins\coolgreen"
  File "..\engine\skins\coolgreen\*.*"

  SetOutPath "$G_ROOTDIR\skins\coolorange"
  File "..\engine\skins\coolorange\*.*"

  SetOutPath "$G_ROOTDIR\skins\coolyellow"
  File "..\engine\skins\coolyellow\*.*"

  SetOutPath "$G_ROOTDIR\skins\default"
  File "..\engine\skins\default\*.*"

  SetOutPath "$G_ROOTDIR\skins\glassblue"
  File "..\engine\skins\glassblue\*.*"

  SetOutPath "$G_ROOTDIR\skins\green"
  File "..\engine\skins\green\*.*"

  SetOutPath "$G_ROOTDIR\skins\klingon"
  File "..\engine\skins\klingon\*.*"

  SetOutPath "$G_ROOTDIR\skins\lavish"
  File "..\engine\skins\lavish\*.*"

  SetOutPath "$G_ROOTDIR\skins\lrclaptop"
  File "..\engine\skins\lrclaptop\*.*"

  SetOutPath "$G_ROOTDIR\skins\oceanblue"
  File "..\engine\skins\oceanblue\*.*"

  SetOutPath "$G_ROOTDIR\skins\orange"
  File "..\engine\skins\orange\*.*"

  SetOutPath "$G_ROOTDIR\skins\osx"
  File "..\engine\skins\osx\*.*"

  SetOutPath "$G_ROOTDIR\skins\orangecream"
  File "..\engine\skins\orangecream\*.*"

  SetOutPath "$G_ROOTDIR\skins\outlook"
  File "..\engine\skins\outlook\*.*"

  SetOutPath "$G_ROOTDIR\skins\prjbluegrey"
  File "..\engine\skins\prjbluegrey\*.*"

  SetOutPath "$G_ROOTDIR\skins\prjsteelbeach"
  File "..\engine\skins\prjsteelbeach\*.*"

  SetOutPath "$G_ROOTDIR\skins\simplyblue"
  File "..\engine\skins\simplyblue\*.*"

  SetOutPath "$G_ROOTDIR\skins\sleet"
  File "..\engine\skins\sleet\*.*"

  SetOutPath "$G_ROOTDIR\skins\sleet-rtl"
  File "..\engine\skins\sleet-rtl\*.*"

  SetOutPath "$G_ROOTDIR\skins\smalldefault"
  File "..\engine\skins\smalldefault\*.*"

  SetOutPath "$G_ROOTDIR\skins\smallgrey"
  File "..\engine\skins\smallgrey\*.*"

  SetOutPath "$G_ROOTDIR\skins\strawberryrose"
  File "..\engine\skins\strawberryrose\*.*"

  SetOutPath "$G_ROOTDIR\skins\tinydefault"
  File "..\engine\skins\tinydefault\*.*"

  SetOutPath "$G_ROOTDIR\skins\tinygrey"
  File "..\engine\skins\tinygrey\*.*"

  SetOutPath "$G_ROOTDIR\skins\white"
  File "..\engine\skins\white\*.*"

  SetOutPath "$G_ROOTDIR\skins\windows"
  File "..\engine\skins\windows\*.*"

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_ENDSEC)"
  SetDetailsPrint listonly

SectionEnd

#--------------------------------------------------------------------------
# Installer Section: (optional) UI Languages component (default = selected)
#--------------------------------------------------------------------------

Section "Languages" SecLangs

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_LANGS)"
  SetDetailsPrint listonly

  SetOutPath "$G_ROOTDIR\languages"
  File "..\engine\languages\*.msg"

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_ENDSEC)"
  SetDetailsPrint listonly

SectionEnd

!ifndef NO_KAKASI
    #--------------------------------------------------------------------------
    # Installer Section: (optional) Kakasi component
    #
    # This component is automatically installed if 'Japanese' has been selected
    # as the language for the installer. Normally this component is not seen in
    # the 'Components' list, but if an English-mode installer is built this
    # component will be made visible to allow it to be selected by the user.
    #--------------------------------------------------------------------------

    Section "Kakasi" SecKakasi

      !define L_RESERVED  $0    ; used in system.dll call

      Push ${L_RESERVED}

      ;--------------------------------------------------------------------------
      ; Install Kakasi package
      ;--------------------------------------------------------------------------

      SetOutPath "$INSTDIR"
      File /r "${C_KAKASI_DIR}\kakasi"

      ; Add Environment Variables for Kakasi

      Push "ITAIJIDICTPATH"
      Push "$INSTDIR\kakasi\share\kakasi\itaijidict"

      StrCmp $G_WINUSERTYPE "Admin" all_users_1
      Call WriteEnvStr
      Goto next_var

    all_users_1:
      Call WriteEnvStrNTAU

    next_var:
      Push "KANWADICTPATH"
      Push "$INSTDIR\kakasi\share\kakasi\kanwadict"

      StrCmp $G_WINUSERTYPE "Admin" all_users_2
      Call WriteEnvStr
      Goto set_env

    all_users_2:
      Call WriteEnvStrNTAU

    set_env:
      IfRebootFlag set_vars_now

      ; Running on a non-Win9x system which already has the correct Kakaksi environment data
      ; or running on a non-Win9x system

      Call IsNT
      Pop ${L_RESERVED}
      StrCmp ${L_RESERVED} "0" continue

      ; Running on a non-Win9x system so we ensure the Kakasi environment variables
      ; are updated to match this installation

    set_vars_now:
      System::Call 'Kernel32::SetEnvironmentVariableA(t, t) \
                    i("ITAIJIDICTPATH", "$INSTDIR\kakasi\share\kakasi\itaijidict").r0'
      StrCmp ${L_RESERVED} 0 0 itaiji_set_ok
      MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_ENVNOTSET) (ITAIJIDICTPATH)"

    itaiji_set_ok:
      System::Call 'Kernel32::SetEnvironmentVariableA(t, t) \
                    i("KANWADICTPATH", "$INSTDIR\kakasi\share\kakasi\kanwadict").r0'
      StrCmp ${L_RESERVED} 0 0 continue
      MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_ENVNOTSET) (KANWADICTPATH)"

    continue:

      ;--------------------------------------------------------------------------
      ; Install Perl modules: base.pm, bytes.pm the Encode collection and Text::Kakasi
      ;--------------------------------------------------------------------------

      SetOutPath "$G_MPLIBDIR"
      File "${C_PERL_DIR}\lib\base.pm"
      File "${C_PERL_DIR}\lib\bytes.pm"
      File "${C_PERL_DIR}\lib\Encode.pm"

      SetOutPath "$G_MPLIBDIR\Encode"
      File /r "${C_PERL_DIR}\lib\Encode\*"

      SetOutPath "$G_MPLIBDIR\auto\Encode"
      File /r "${C_PERL_DIR}\lib\auto\Encode\*"

      SetOutPath "$G_MPLIBDIR\Text"
      File "${C_PERL_DIR}\site\lib\Text\Kakasi.pm"

      SetOutPath "$G_MPLIBDIR\auto\Text\Kakasi"
      File "${C_PERL_DIR}\site\lib\auto\Text\Kakasi\*"

      Pop ${L_RESERVED}

      !undef L_RESERVED

    SectionEnd
!endif

SubSection "Optional modules" SubSecOptional

#--------------------------------------------------------------------------
# Installer Section: (optional) POPFile NNTP proxy (default = not selected)
#
# If this component is selected, the installer installs the POPFile NNTP proxy module
#--------------------------------------------------------------------------

Section /o "NNTP proxy" SecNNTP

  SetOutPath "$G_ROOTDIR\Proxy"
  File "..\engine\Proxy\NNTP.pm"

SectionEnd

#--------------------------------------------------------------------------
# Installer Section: (optional) POPFile SMTP proxy (default = not selected)
#
# If this component is selected, the installer installs the POPFile SMTP proxy module
#--------------------------------------------------------------------------

Section /o "SMTP proxy" SecSMTP

  SetOutPath "$G_ROOTDIR\Proxy"
  File "..\engine\Proxy\SMTP.pm"

SectionEnd

#--------------------------------------------------------------------------
# Installer Section: (optional) POPFile XMLRPC component (default = not selected)
#
# If this component is selected, the installer installs the POPFile XMLRPC support
# (UI\XMLRPC.pm and POPFile\API.pm) and the extra Perl modules required by XMLRPC.pm.
# The XMLRPC module exposes the POPFile API to allow access to many POPFile functions.
#--------------------------------------------------------------------------

Section /o "XMLRPC" SecXMLRPC

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_XMLRPC)"
  SetDetailsPrint listonly

  ; POPFile XMLRPC component

  SetOutPath "$G_ROOTDIR\UI"
  File "..\engine\UI\XMLRPC.pm"

  ; POPFile API component used by XMLRPC.pm

  SetOutPath "$G_ROOTDIR\POPFile"
  File "..\engine\POPFile\API.pm"

  ; Perl modules required to support the POPFile XMLRPC component

  SetOutPath "$G_MPLIBDIR"
  File "${C_PERL_DIR}\site\lib\LWP.pm"
  File "${C_PERL_DIR}\lib\re.pm"
  File "${C_PERL_DIR}\site\lib\URI.pm"

  SetOutPath "$G_MPLIBDIR\HTTP"
  File /r "${C_PERL_DIR}\site\lib\HTTP\*"

  SetOutPath "$G_MPLIBDIR\LWP"
  File /r "${C_PERL_DIR}\site\lib\LWP\*"

  SetOutPath "$G_MPLIBDIR\Net"
  File "${C_PERL_DIR}\site\lib\Net\HTT*"

  SetOutPath "$G_MPLIBDIR\Net\HTTP"
  File "${C_PERL_DIR}\site\lib\Net\HTTP\*"

  SetOutPath "$G_MPLIBDIR\SOAP"
  File /r "${C_PERL_DIR}\site\lib\SOAP\*"

  SetOutPath "$G_MPLIBDIR\Time"
  File /r "${C_PERL_DIR}\lib\Time\*"

  SetOutPath "$G_MPLIBDIR\URI"
  File /r "${C_PERL_DIR}\site\lib\URI\*"

  SetOutPath "$G_MPLIBDIR\XML"
  File /r "${C_PERL_DIR}\site\lib\XML\*"

  SetOutPath "$G_MPLIBDIR\XMLRPC"
  File /r "${C_PERL_DIR}\site\lib\XMLRPC\*"

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_ENDSEC)"
  SetDetailsPrint listonly

SectionEnd

#--------------------------------------------------------------------------
# Installer Section: (optional) POPFile IMAP component (default = not selected)
#
# If this component is selected, the installer installs the experimental IMAP module.
#--------------------------------------------------------------------------

Section /o "IMAP" SecIMAP

  SetDetailsPrint textonly
  DetailPrint "Installing IMAP module..."
  SetDetailsPrint listonly

  ; At present (30 July 2004) the IMAP.pm module resides in the 'Services' sub-folder.
  ; Before the 0.22.0 release, the IMAP.pm module was stored in the 'POPFile' sub-folder
  ; then it was moved (briefly) to the 'Server' sub-folder before finally ending up in
  ; the 'Services' sub-folder for the 0.22.0 release.

  SetOutpath "$G_ROOTDIR\Services"
  File "..\engine\Services\IMAP.pm"

  Delete "$G_ROOTDIR\POPFile\IMAP.pm"
  Delete "$G_ROOTDIR\Server\IMAP.pm"

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_ENDSEC)"
  SetDetailsPrint listonly

SectionEnd

#--------------------------------------------------------------------------
# Installer Section: (optional) Perl IO::Socket::Socks module (default = not selected)
#
# If this component is selected, the installer installs the Perl Socks module to provide
# SOCKS V support for all of the POPFile proxies.
#--------------------------------------------------------------------------

Section /o "SOCKS" SecSOCKS

  SetOutPath "$G_MPLIBDIR\IO\Socket"
  File "${C_PERL_DIR}\site\lib\IO\Socket\Socks.pm"

SectionEnd

SubSectionEnd

#--------------------------------------------------------------------------
# Component-selection page descriptions
#
# There is no need to provide any translations for the 'SecKakasi' description
# because it is only visible when the installer is built in ENGLISH_MODE.
#--------------------------------------------------------------------------

  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecPOPFile}     $(DESC_SecPOPFile)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecSkins}       $(DESC_SecSkins)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecLangs}       $(DESC_SecLangs)
    !insertmacro MUI_DESCRIPTION_TEXT ${SubSecOptional} $(DESC_SubSecOptional)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecNNTP}        $(DESC_SecNNTP)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecSMTP}        $(DESC_SecSMTP)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecXMLRPC}      $(DESC_SecXMLRPC)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecIMAP}        $(DESC_SecIMAP)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecSOCKS}       $(DESC_SecSOCKS)
    !ifndef NO_KAKASI
      !insertmacro MUI_DESCRIPTION_TEXT ${SecKakasi} "Kakasi (used to process Japanese email)"
    !endif
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

!ifndef NO_KAKASI
    #--------------------------------------------------------------------------
    # Installer Function: HandleKakasi
    #
    # This function ensures that when 'Japanese' has been selected as the language
    # for the installer, the 'Kakasi' section is invisibly selected for installation
    # (if any other language is selected, we do not select the invisible 'Kakasi' section).
    #
    # If the installer is built in ENGLISH_MODE then the 'Kakasi' section will be visible
    # to allow it to be selected if it is required.
    #--------------------------------------------------------------------------

    Function HandleKakasi

      !insertmacro UnselectSection ${SecKakasi}

      !ifndef ENGLISH_MODE
            SectionSetText ${SecKakasi} ""            ; this makes the component invisible
            StrCmp $LANGUAGE ${LANG_JAPANESE} 0 exit
            !insertmacro SelectSection ${SecKakasi}
          exit:
      !endif
    FunctionEnd
!endif

#--------------------------------------------------------------------------
# Installer Function: CheckPerlRequirementsPage
#
# The minimal Perl we install requires some Microsoft components which are included in the
# current versions of Windows. Older systems will have suitable versions of these components
# provided Internet Explorer 5.5 or later has been installed. If we find an earlier version
# of Internet Explorer is installed, we suggest the user upgrades to IE 5.5 or later.
#
# It seems that the functions required by POPFile can be supplied by IE 5.0 so we only show
# this page if we find a version earlier than IE 5 (or if we fail to detect the IE version).
#--------------------------------------------------------------------------

Function CheckPerlRequirementsPage

  !define L_TEMP      $R9
  !define L_VERSION   $R8

  Push ${L_TEMP}
  Push ${L_VERSION}

  Call GetIEVersion
  Pop ${L_VERSION}

  StrCpy ${L_TEMP} ${L_VERSION} 1
  StrCmp ${L_TEMP} '?' not_good
  IntCmp ${L_TEMP} 5 exit not_good exit

not_good:

  ; Ensure custom page matches the selected language (left-to-right or right-to-left order)

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioG.ini" "Settings" "RTL" "$(^RTL)"

  !insertmacro PFI_IO_TEXT "ioG.ini" "1" \
      "$(PFI_LANG_PERLREQ_IO_TEXT_1)\
       $(PFI_LANG_PERLREQ_IO_TEXT_2)\
       $(PFI_LANG_PERLREQ_IO_TEXT_3)\
       $(PFI_LANG_PERLREQ_IO_TEXT_4)"

  !insertmacro PFI_IO_TEXT "ioG.ini" "2" \
      "$(PFI_LANG_PERLREQ_IO_TEXT_5) ${L_VERSION}${IO_NL}${IO_NL}\
       $(PFI_LANG_PERLREQ_IO_TEXT_6)\
       $(PFI_LANG_PERLREQ_IO_TEXT_7)"

  !insertmacro MUI_HEADER_TEXT "$(PFI_LANG_PERLREQ_TITLE)" " "

  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioG.ini"

exit:
  Pop ${L_VERSION}
  Pop ${L_TEMP}

  !undef L_TEMP
  !undef L_VERSION

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: CheckUserRights
# (the "pre" function for the 'WELCOME' page)
#
# On systems which support different types of user, recommend that POPFile is installed by
# a user with 'Administrative' rights (this makes it easier to use POPFile's multi-user mode).
#--------------------------------------------------------------------------

Function CheckUserRights

  !define L_WELCOME_TEXT  $R9

  Push ${L_WELCOME_TEXT}

  ; The 'UserInfo' plugin may return an error if run on a Win9x system but since Win9x systems
  ; do not support different account types, we treat this error as if user has 'Admin' rights.

	ClearErrors
	UserInfo::GetName
	IfErrors 0 got_name

  ; Assume Win9x system, so user has 'Admin' rights
  ; (UserInfo works on Win98SE so perhaps it is only Win95 that fails ?)

  StrCpy $G_WINUSERNAME "UnknownUser"
  StrCpy $G_WINUSERTYPE "Admin"
  Goto exit

got_name:
	Pop $G_WINUSERNAME
  StrCmp $G_WINUSERNAME "" 0 get_usertype
  StrCpy $G_WINUSERNAME "UnknownUser"

get_usertype:
  UserInfo::GetAccountType
	Pop $G_WINUSERTYPE
  StrCmp $G_WINUSERTYPE "Admin" exit
  StrCmp $G_WINUSERTYPE "Power" not_admin
  StrCmp $G_WINUSERTYPE "User" not_admin
  StrCmp $G_WINUSERTYPE "Guest" not_admin
  StrCpy $G_WINUSERTYPE "Unknown"

not_admin:

  ; On the 'WELCOME' page, add a note recommending that POPFile is installed by a user
  ; with 'Administrator' rights

  !insertmacro MUI_INSTALLOPTIONS_READ "${L_WELCOME_TEXT}" "ioSpecial.ini" "Field 3" "Text"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 3" "Text" \
      "${L_WELCOME_TEXT}\
      ${IO_NL}${IO_NL}\
      $(PFI_LANG_WELCOME_ADMIN_TEXT)"

exit:
  Pop ${L_WELCOME_TEXT}

  StrCmp $G_PFIFLAG "no banner" no_banner

  ; Remove the banner which was displayed by the 'PFIGUIInit' function

  Sleep ${C_MIN_BANNER_DISPLAY_TIME}
  Banner::destroy

no_banner:

  !undef L_WELCOME_TEXT

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: MakeRootDirSafe
#
# If we are installing on top of a previous installation, we try to shut it down
# (to allow the files to be overwritten without requiring a reboot)
#
# We also need to check if any of the PFI utilities are running (to avoid Abort/Retry/Ignore
# messages or the need to reboot in order to update them)
#--------------------------------------------------------------------------

Function MakeRootDirSafe

  IfFileExists "$G_ROOTDIR\*.exe" 0 nothing_to_check

  !define L_CFG      $R9    ; file handle
  !define L_EXE      $R8    ; name of EXE file to be monitored
  !define L_LINE     $R7
  !define L_NEW_GUI  $R6
  !define L_OLD_GUI  $R5
  !define L_PARAM    $R4
  !define L_RESULT   $R3
  !define L_TEXTEND  $R2    ; used to ensure correct handling of lines longer than 1023 chars

  Push ${L_CFG}
  Push ${L_EXE}
  Push ${L_LINE}
  Push ${L_NEW_GUI}
  Push ${L_OLD_GUI}
  Push ${L_PARAM}
  Push ${L_RESULT}
  Push ${L_TEXTEND}

  ; Starting with POPfile 0.21.0 an experimental version of 'popfile-service.exe' was included
  ; to allow POPFile to be run as a Windows service.

  Push "POPFile"
  Call ServiceRunning
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "true" manual_shutdown

  ; If we are about to overwrite an existing version which is still running,
  ; then one of the EXE files will be 'locked' which means we have to shutdown POPFile.
  ;
  ; POPFile v0.20.0 and later may be using 'popfileb.exe', 'popfilef.exe', 'popfileib.exe',
  ; 'popfileif.exe', 'perl.exe' or 'wperl.exe'.
  ;
  ; Earlier versions of POPFile use only 'perl.exe' or 'wperl.exe'.

  Push $G_ROOTDIR
  Call FindLockedPFE
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" check_pfi_utils

  ; The program files we are about to update are in use so we need to shut POPFile down

  DetailPrint "... it is locked."

  ; Attempt to discover which POPFile UI port is used by the current user, so we can issue
  ; a shutdown request. The following cases are considered:
  ;
  ; (a) upgrading a 0.21.0 or later installation and runpopfile.exe was used to start POPFile,
  ;     so POPFile is using environment variables which match the HKCU RootDir_SFN and
  ;     UserDir_SFN registry data (or HKCU RootDir_LFN and UserDir_LFN if short file names are
  ;     not supported)
  ;
  ; (b) upgrading a pre-0.21.0 installation, so popfile.cfg is in the $G_ROOTDIR folder. Need to
  ;     look for old-style and new-style UI port specifications just like the old installer did.

  ReadRegStr ${L_CFG} HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "UserDir_LFN"
  StrCmp ${L_CFG} "" try_root_dir
  IfFileExists "${L_CFG}\popfile.cfg" check_cfg_file

try_root_dir:
  IfFileExists "$G_ROOTDIR\popfile.cfg" 0 manual_shutdown
  StrCpy ${L_CFG} "$G_ROOTDIR"

check_cfg_file:
  StrCpy ${L_NEW_GUI} ""
  StrCpy ${L_OLD_GUI} ""

  ; See if we can get the current gui port from an existing configuration.
  ; There may be more than one entry for this port in the file - use the last one found
  ; (but give priority to any "html_port" entry).

  FileOpen  ${L_CFG} "${L_CFG}\popfile.cfg" r

found_eol:
  StrCpy ${L_TEXTEND} "<eol>"

loop:
  FileRead ${L_CFG} ${L_LINE}
  StrCmp ${L_LINE} "" done
  StrCmp ${L_TEXTEND} "<eol>" 0 check_eol
  StrCmp ${L_LINE} "$\n" loop

  StrCpy ${L_PARAM} ${L_LINE} 10
  StrCmp ${L_PARAM} "html_port " got_html_port

  StrCpy ${L_PARAM} ${L_LINE} 8
  StrCmp ${L_PARAM} "ui_port " got_ui_port
  Goto check_eol

got_ui_port:
  StrCpy ${L_OLD_GUI} ${L_LINE} 5 8
  Goto check_eol

got_html_port:
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

  Push ${L_OLD_GUI}
  Call TrimNewlines
  Pop ${L_OLD_GUI}

  StrCmp ${L_NEW_GUI} "" try_old_style
  DetailPrint "$(PFI_LANG_INST_LOG_SHUTDOWN) ${L_NEW_GUI} [new style port]"
  DetailPrint "$(PFI_LANG_TAKE_A_FEW_SECONDS)"
  Push ${L_NEW_GUI}
  Call ShutdownViaUI
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "success" check_exe
  StrCmp ${L_RESULT} "password?" manual_shutdown

try_old_style:
  StrCmp ${L_OLD_GUI} "" manual_shutdown
  DetailPrint "$(PFI_LANG_INST_LOG_SHUTDOWN) ${L_OLD_GUI} [old style port]"
  DetailPrint "$(PFI_LANG_TAKE_A_FEW_SECONDS)"
  Push ${L_OLD_GUI}
  Call ShutdownViaUI
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "success" check_exe
  Goto manual_shutdown

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
  Goto check_pfi_utils

unlocked_now:
  DetailPrint "File is now unlocked"

check_pfi_utils:
  Push $G_ROOTDIR
  Call RequestPFIUtilsShutdown

  Pop ${L_TEXTEND}
  Pop ${L_RESULT}
  Pop ${L_PARAM}
  Pop ${L_OLD_GUI}
  Pop ${L_NEW_GUI}
  Pop ${L_LINE}
  Pop ${L_EXE}
  Pop ${L_CFG}

  !undef L_CFG
  !undef L_EXE
  !undef L_LINE
  !undef L_NEW_GUI
  !undef L_OLD_GUI
  !undef L_PARAM
  !undef L_RESULT
  !undef L_TEXTEND

nothing_to_check:
FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: MinPerlRestructure
#
# Prior to POPFile 0.21.0, POPFile really only supported one user so the location of the
# popfile.cfg configuration file was hard-coded and the minimal Perl files were intermingled
# with the POPFile files. POPFile 0.21.0 introduced some multi-user support which means that
# the location of the configuration file is now supplied via an environment variable to allow
# POPFile to be run from any folder.  As a result, some rearrangement of the minimal Perl files
# is required (to avoid Perl runtime errors when POPFile is started from a folder other than
# the one where POPFile is installed).
#--------------------------------------------------------------------------

Function MinPerlRestructure

  IfFileExists "$G_MPLIBDIR\*.pm" exit

  IfFileExists "$G_ROOTDIR\*.pm" 0 exit

  CreateDirectory "$G_MPLIBDIR"

  CopyFiles /SILENT /FILESONLY "$G_ROOTDIR\*.pm" "$G_MPLIBDIR\"
  Delete "$G_ROOTDIR\*.pm"

  !insertmacro MinPerlMove "auto"
  !insertmacro MinPerlMove "Carp"
  !insertmacro MinPerlMove "DBD"
  !insertmacro MinPerlMove "Digest"
  !insertmacro MinPerlMove "Encode"
  !insertmacro MinPerlMove "Exporter"
  !insertmacro MinPerlMove "File"
  !insertmacro MinPerlMove "Getopt"
  !insertmacro MinPerlMove "IO"
  !insertmacro MinPerlMove "MIME"
  !insertmacro MinPerlMove "String"
  !insertmacro MinPerlMove "Sys"
  !insertmacro MinPerlMove "Text"
  !insertmacro MinPerlMove "warnings"

  ; Delete redundant minimal Perl files from earlier installations

  IfFileExists "$G_ROOTDIR\Win32\API.pm" 0 exit
  Delete "$G_ROOTDIR\Win32\API\Callback.pm"
  Delete "$G_ROOTDIR\Win32\API\Struct.pm"
  Delete "$G_ROOTDIR\Win32\API\Type.pm"
  RMDir "$G_ROOTDIR\Win32\API"
  Delete "$G_ROOTDIR\Win32\API.pm"
  RMDir "$G_ROOTDIR\Win32"

exit:
FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: SkinsRestructure
#
# Now that the HTML for the UI is no longer embedded in the Perl code, some changes need to be
# made to the skins. There is now a new default skin which includes a set of HTML template files
# in addition to a CSS file. Additional skins consist of separate folders containing 'style.css'
# and any image files used by the skin (instead of each skin using a uniquely named CSS file in
# the 'skins' folder, with any necessary image files being stored either in the 'skins' folder
# or in a separate sub-folder).
#
# We attempt to rearrange any existing skins to suit this new structure (the current build only
# moves files, it does not edit the CSS files to update any image references within them).
#
# The new default skin and its associated HTML template files are always installed by the
# mandatory 'POPFile' component (even if the 'skins' component is not installed).
#--------------------------------------------------------------------------

Function SkinsRestructure

  RMDir "$G_ROOTDIR\skins\lavishImages"
  RMDir "$G_ROOTDIR\skins\sleetImages"

  IfFileExists "$G_ROOTDIR\skins\default\*.thtml" exit

  !insertmacro SkinMove "blue"           "blue"
  !insertmacro SkinMove "CoolBlue"       "coolblue"
  !insertmacro SkinMove "CoolBrown"      "coolbrown"
  !insertmacro SkinMove "CoolGreen"      "coolgreen"
  !insertmacro SkinMove "CoolOrange"     "coolorange"
  !insertmacro SkinMove "CoolYellow"     "coolyellow"
  !insertmacro SkinMove "default"        "default"
  !insertmacro SkinMove "glassblue"      "glassblue"
  !insertmacro SkinMove "green"          "green"

  IfFileExists "$G_ROOTDIR\skins\lavishImages\*.*" 0 lavish
  Rename  "$G_ROOTDIR\skins\lavishImages" "$G_ROOTDIR\skins\lavish"

lavish:
  !insertmacro SkinMove "Lavish"         "lavish"
  !insertmacro SkinMove "LRCLaptop"      "lrclaptop"
  !insertmacro SkinMove "orange"         "orange"
  !insertmacro SkinMove "orangeCream"    "orangecream"
  !insertmacro SkinMove "outlook"        "outlook"
  !insertmacro SkinMove "PRJBlueGrey"    "prjbluegrey"
  !insertmacro SkinMove "PRJSteelBeach"  "prjsteelbeach"
  !insertmacro SkinMove "SimplyBlue"     "simplyblue"

  IfFileExists "$G_ROOTDIR\skins\sleetImages\*.*" 0 sleet
  Rename  "$G_ROOTDIR\skins\sleetImages" "$G_ROOTDIR\skins\sleet"

sleet:
  !insertmacro SkinMove "Sleet"          "sleet"
  !insertmacro SkinMove "Sleet-RTL"      "sleet-rtl"
  !insertmacro SkinMove "smalldefault"   "smalldefault"
  !insertmacro SkinMove "smallgrey"      "smallgrey"
  !insertmacro SkinMove "StrawberryRose" "strawberryrose"
  !insertmacro SkinMove "tinydefault"    "tinydefault"
  !insertmacro SkinMove "tinygrey"       "tinygrey"
  !insertmacro SkinMove "white"          "white"
  !insertmacro SkinMove "windows"        "windows"

  IfFileExists "$G_ROOTDIR\skins\chipped_obsidian.gif" 0 metalback
  CreateDirectory "$G_ROOTDIR\skins\prjsteelbeach"
  Rename "$G_ROOTDIR\skins\chipped_obsidian.gif" "$G_ROOTDIR\skins\prjsteelbeach\chipped_obsidian.gif"

metalback:
  IfFileExists "$G_ROOTDIR\skins\metalback.gif" 0 check_for_extra_skins
  CreateDirectory "$G_ROOTDIR\skins\prjsteelbeach"
  Rename "$G_ROOTDIR\skins\metalback.gif" "$G_ROOTDIR\skins\prjsteelbeach\metalback.gif"

check_for_extra_skins:

  ; Move any remaining CSS files to an appropriate folder (to make them available for selection)
  ; Only the CSS files are moved, the user will have to adjust any skins which use images

  !define L_CSS_HANDLE    $R9   ; used when searching for non-standard skins
  !define L_SKIN_NAME     $R8   ; name of a non-standard skin (i.e. not supplied with POPFile)

  Push ${L_CSS_HANDLE}
  Push ${L_SKIN_NAME}

  FindFirst ${L_CSS_HANDLE} ${L_SKIN_NAME} "$G_ROOTDIR\skins\*.css"
  StrCmp ${L_CSS_HANDLE} "" all_done_now

process_skin:
  StrCmp ${L_SKIN_NAME} "." look_again
  StrCmp ${L_SKIN_NAME} ".." look_again
  IfFileExists "$G_ROOTDIR\skins\${L_SKIN_NAME}\*.*" look_again
  StrCpy ${L_SKIN_NAME} ${L_SKIN_NAME} -4
  CreateDirectory "$G_ROOTDIR\skins\${L_SKIN_NAME}"
  Rename "$G_ROOTDIR\skins\${L_SKIN_NAME}.css" "$G_ROOTDIR\skins\${L_SKIN_NAME}\style.css"

look_again:
  FindNext ${L_CSS_HANDLE} ${L_SKIN_NAME}
  StrCmp ${L_SKIN_NAME} "" all_done_now process_skin

all_done_now:
  FindClose ${L_CSS_HANDLE}

  Pop ${L_SKIN_NAME}
  Pop ${L_CSS_HANDLE}

  !undef L_CSS_HANDLE
  !undef L_SKIN_NAME

exit:
FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: CheckForExistingLocation
# (the "pre" function for the POPFile PROGRAM DIRECTORY selection page)
#
# Set the initial value used by the POPFile PROGRAM DIRECTORY page to the location used by
# the most recent 0.21.0 (or later version) or the location of any pre-0.21.0 installation.
#--------------------------------------------------------------------------

Function CheckForExistingLocation

  ; Initialize the $G_PFIFLAG used by the '.onVerifyInstDir' function to avoid sending
  ; unnecessary messages to change the text on the button used to start the installation

  StrCpy $G_PFIFLAG ""

  ReadRegStr $INSTDIR HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "InstallPath"
  StrCmp $INSTDIR "" try_HKLM
  IfFileExists "$INSTDIR\*.*" exit

try_HKLM:
  ReadRegStr $INSTDIR HKLM "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "InstallPath"
  StrCmp $INSTDIR "" try_old_style
  IfFileExists "$INSTDIR\*.*" exit

try_old_style:
  ReadRegStr $INSTDIR HKLM "Software\POPFile" "InstallLocation"
  StrCmp $INSTDIR "" use_default
  IfFileExists "$INSTDIR\*.*" exit

use_default:
  StrCpy $INSTDIR "$PROGRAMFILES\${C_PFI_PRODUCT}"

exit:
FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: CheckExistingProgDir
# (the "leave" function for the POPFile PROGRAM DIRECTORY selection page)
#
# This function is used to check if a previous POPFile installation exists in the directory
# chosen for this installation's POPFile PROGRAM files (popfile.pl, etc)
#--------------------------------------------------------------------------

Function CheckExistingProgDir

  !define L_RESULT  $R9

  ; If short file names are not supported on this system,
  ; we cannot accept any path containing spaces.

  StrCmp $G_SFN_DISABLED "0" check_locn

  Push ${L_RESULT}

  Push $INSTDIR
  Push ' '
  Call StrStr
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "" no_spaces
  MessageBox MB_OK|MB_ICONEXCLAMATION \
      "Current configuration does not support short file names!\
      ${MB_NL}${MB_NL}\
      Please select a folder location which does not contain spaces"

  ; Return to the POPFile PROGRAM DIRECTORY selection page

  Pop ${L_RESULT}
  Abort

no_spaces:
  Pop ${L_RESULT}

check_locn:

  ; Initialise the global user variable used for the POPFile PROGRAM files location

  StrCpy $G_ROOTDIR "$INSTDIR"

  ; Warn the user if we are about to upgrade an existing installation
  ; and allow user to select a different directory if they wish

  IfFileExists "$G_ROOTDIR\popfile.pl" warning
  Goto continue

warning:
  MessageBox MB_YESNO|MB_ICONQUESTION "$(PFI_LANG_DIRSELECT_MBWARN_1)\
      ${MB_NL}${MB_NL}\
      $INSTDIR\
      ${MB_NL}${MB_NL}${MB_NL}\
      $(PFI_LANG_DIRSELECT_MBWARN_2)" IDYES check_options

  ; Return to the POPFile PROGRAM DIRECTORY selection page

  Abort

check_options:

  ; If user has NOT selected a program component on the COMPONENTS page and we find that the
  ; version we are about to upgrade includes that program component then the user is asked for
  ; permission to upgrade the component [To do: disable the component if user says 'No' ??]

  !insertmacro SectionFlagIsSet ${SecIMAP} ${SF_SELECTED} check_nntp look_for_imap

look_for_imap:
  IfFileExists "$G_ROOTDIR\Services\IMAP.pm" ask_about_imap
  IfFileExists "$G_ROOTDIR\Server\IMAP.pm" ask_about_imap
  IfFileExists "$G_ROOTDIR\POPFile\IMAP.pm" ask_about_imap check_nntp

ask_about_imap:
  StrCpy $G_PLS_FIELD_1 "POPFile IMAP"
  MessageBox MB_YESNO|MB_ICONQUESTION "$(MBCOMPONENT_PROB_1)\
      ${MB_NL}${MB_NL}\
      $(MBCOMPONENT_PROB_2)" IDNO check_nntp
  !insertmacro SelectSection ${SecIMAP}

check_nntp:
  !insertmacro SectionFlagIsSet ${SecNNTP} ${SF_SELECTED} check_smtp look_for_nntp

look_for_nntp:
  IfFileExists "$G_ROOTDIR\Proxy\NNTP.pm" 0 check_smtp
  StrCpy $G_PLS_FIELD_1 "POPFile NNTP proxy"
  MessageBox MB_YESNO|MB_ICONQUESTION "$(MBCOMPONENT_PROB_1)\
      ${MB_NL}${MB_NL}\
      $(MBCOMPONENT_PROB_2)" IDNO check_smtp
  !insertmacro SelectSection ${SecNNTP}

check_smtp:
  !insertmacro SectionFlagIsSet ${SecSMTP} ${SF_SELECTED} check_socks look_for_smtp

look_for_smtp:
  IfFileExists "$G_ROOTDIR\Proxy\SMTP.pm" 0 check_socks
  StrCpy $G_PLS_FIELD_1 "POPFile SMTP proxy"
  MessageBox MB_YESNO|MB_ICONQUESTION "$(MBCOMPONENT_PROB_1)\
      ${MB_NL}${MB_NL}\
      $(MBCOMPONENT_PROB_2)" IDNO check_socks
  !insertmacro SelectSection ${SecSMTP}

check_socks:
  !insertmacro SectionFlagIsSet ${SecSOCKS} ${SF_SELECTED} check_xmlrpc look_for_socks

look_for_socks:
  IfFileExists "$G_ROOTDIR\lib\IO\Socket\Socks.pm" 0 check_xmlrpc
  StrCpy $G_PLS_FIELD_1 "SOCKS support"
  MessageBox MB_YESNO|MB_ICONQUESTION "$(MBCOMPONENT_PROB_1)\
      ${MB_NL}${MB_NL}\
      $(MBCOMPONENT_PROB_2)" IDNO check_xmlrpc
  !insertmacro SelectSection ${SecSOCKS}

check_xmlrpc:
  !insertmacro SectionFlagIsSet ${SecXMLRPC} ${SF_SELECTED} continue look_for_xmlrpc

look_for_xmlrpc:
  IfFileExists "$G_ROOTDIR\UI\XMLRPC.pm" 0 continue
  StrCpy $G_PLS_FIELD_1 "POPFile XMLRPC"
  MessageBox MB_YESNO|MB_ICONQUESTION "$(MBCOMPONENT_PROB_1)\
      ${MB_NL}${MB_NL}\
      $(MBCOMPONENT_PROB_2)" IDNO continue
  !insertmacro SelectSection ${SecXMLRPC}

continue:

  ; Move on to the next page in the installer

  !undef L_RESULT

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: CheckHostsFile
#
# Starting with the 0.22.0 release the system tray icon uses 'http://localhost:port' to open
# the User Interface (earlier versions used 'http://127.0.0.1:port' instead). The installer has
# been updated to follow suit. Some Windows 9x systems may not have a HOSTS file which defines
# 'localhost' so we ensure a suitable one exists
#--------------------------------------------------------------------------

Function CheckHostsFile

  !define L_CFG         $R9
  !define L_LINE        $R8
  !define L_LOCALHOST   $R7
  !define L_TEMP        $R6

  Push ${L_CFG}
  Push ${L_LINE}
  Push ${L_LOCALHOST}
  Push ${L_TEMP}

  IfFileExists "$WINDIR\HOSTS" look_for_localhost
  FileOpen ${L_CFG} "$WINDIR\HOSTS" w
  FileWrite ${L_CFG} "# Created by the installer for ${C_PFI_PRODUCT} ${C_PFI_VERSION}${MB_NL}"
  FileWrite ${L_CFG} "${MB_NL}"
  FileWrite ${L_CFG} "127.0.0.1       localhost${MB_NL}"
  FileClose ${L_CFG}
  Goto exit

look_for_localhost:
  StrCpy ${L_LOCALHOST} ""
  FileOpen ${L_CFG} "$WINDIR\HOSTS" r

loop:
  FileRead ${L_CFG} ${L_LINE}
  StrCmp ${L_LINE} "" done
  StrCpy ${L_TEMP} ${L_LINE} 10
  StrCmp ${L_TEMP} "127.0.0.1 " 0 loop
  Push ${L_LINE}
  Call TrimNewlines
  Push " localhost"
  Call StrStr
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" loop
  StrCmp ${L_TEMP} " localhost" found
  StrCpy ${L_TEMP} ${L_TEMP} 11
  StrCmp ${L_TEMP} " localhost " found
  Goto loop

found:
  StrCpy ${L_LOCALHOST} "1"

done:
  FileClose ${L_CFG}
  StrCmp ${L_LOCALHOST} "1" exit
  FileOpen ${L_CFG} "$WINDIR\HOSTS" a
  FileSeek ${L_CFG} 0 END
  FileWrite ${L_CFG} "${MB_NL}"
  FileWrite ${L_CFG} "# Inserted by the installer for ${C_PFI_PRODUCT} ${C_PFI_VERSION}${MB_NL}"
  FileWrite ${L_CFG} "${MB_NL}"
  FileWrite ${L_CFG} "127.0.0.1       localhost${MB_NL}"
  FileClose ${L_CFG}

exit:
  Pop ${L_TEMP}
  Pop ${L_LOCALHOST}
  Pop ${L_LINE}
  Pop ${L_CFG}

  !undef L_CFG
  !undef L_LINE
  !undef L_LOCALHOST
  !undef L_TEMP

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: InstallUserData
# (the "pre" function for the FINISH page)
#--------------------------------------------------------------------------

Function InstallUserData

  ; For this build we skip our own FINISH page and disable the wizard's language selection
  ; dialog to make the wizard appear as an extension of the main 'setup.exe' installer.
  ; [Future builds may pass more than just a command-line switch to the wizard]

  IfRebootFlag special_case
  Exec '"$G_ROOTDIR\adduser.exe" /install'
  Abort

special_case:
  Exec '"$G_ROOTDIR\adduser.exe" /installreboot'
  Abort

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: ShowReadMe
# (the "ReadMe" function for the FINISH page)
#--------------------------------------------------------------------------

Function ShowReadMe

  StrCmp $G_NOTEPAD "" use_file_association
  Exec 'notepad.exe "$G_ROOTDIR\${C_README}.txt"'
  goto exit

use_file_association:
  ExecShell "open" "$G_ROOTDIR\${C_README}.txt"

exit:
FunctionEnd


#####################################################################################
#                                                                                   #
#   ##    ##  ##    ##   ##   ##    ##   #####  ########  #####    ##      ##       #
#   ##    ##  ###   ##   ##   ###   ##  ##   ##    ##    ##   ##   ##      ##       #
#   ##    ##  ####  ##   ##   ####  ##  ##         ##    ##   ##   ##      ##       #
#   ##    ##  ## ## ##   ##   ## ## ##   #####     ##    #######   ##      ##       #
#   ##    ##  ##  ####   ##   ##  ####       ##    ##    ##   ##   ##      ##       #
#   ##    ##  ##   ###   ##   ##   ###  ##   ##    ##    ##   ##   ##      ##       #
#    ######   ##    ##   ##   ##    ##   #####     ##    ##   ##   ######  ######   #
#                                                                                   #
#####################################################################################


#--------------------------------------------------------------------------
# Initialise the uninstaller
#--------------------------------------------------------------------------

Function un.onInit

  ; Retrieve the language used when POPFile was installed, and use it for the uninstaller
  ; (if the language entry is not found in the registry, a 'language selection' dialog is shown)

  !insertmacro MUI_UNGETLANGUAGE

  StrCpy $G_ROOTDIR   "$INSTDIR"
  StrCpy $G_MPLIBDIR  "$INSTDIR\lib"

  ; Starting with 0.21.0 the registry is used to store the location of the 'User Data'
  ; (if setup.exe or adduser.exe was used to create/update the 'User Data' for this user)

  ReadRegStr $G_USERDIR HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "UserDir_LFN"
  StrCmp $G_USERDIR "" 0 got_user_path

  ; Pre-release versions of the 0.21.0 installer used a sub-folder for the default user data

  StrCpy $G_USERDIR "$INSTDIR\user"

  ; If we are uninstalling an upgraded installation, the default user data may be in $INSTDIR
  ; instead of $INSTDIR\user

  IfFileExists "$G_USERDIR\popfile.cfg" got_user_path
  StrCpy $G_USERDIR   "$INSTDIR"

got_user_path:

  ; Email settings are stored on a 'per user' basis therefore we need to know which user is
  ; running the uninstaller (e.g. so we can check ownership of any local 'User Data' we find)

	ClearErrors
	UserInfo::GetName
	IfErrors 0 got_name

  ; Assume Win9x system, so user has 'Admin' rights
  ; (UserInfo works on Win98SE so perhaps it is only Win95 that fails ?)

  StrCpy $G_WINUSERNAME "UnknownUser"
  StrCpy $G_WINUSERTYPE "Admin"
  Goto start_uninstall

got_name:
	Pop $G_WINUSERNAME
  StrCmp $G_WINUSERNAME "" 0 get_usertype
  StrCpy $G_WINUSERNAME "UnknownUser"

get_usertype:
  UserInfo::GetAccountType
	Pop $G_WINUSERTYPE
  StrCmp $G_WINUSERTYPE "Admin" start_uninstall
  StrCmp $G_WINUSERTYPE "Power" start_uninstall
  StrCmp $G_WINUSERTYPE "User" start_uninstall
  StrCmp $G_WINUSERTYPE "Guest" start_uninstall
  StrCpy $G_WINUSERTYPE "Unknown"

start_uninstall:
FunctionEnd

#--------------------------------------------------------------------------
# Uninstaller Sections (this build uses all of these and executes them in the order shown)
#
#  (1) un.Uninstall Begin    - requests confirmation if appropriate
#  (2) un.Local User Data    - looks for and removes 'User Data' from the PROGRAM folder
#  (3) un.Shutdown POPFile   - shutdown POPFile if necessary (to avoid the need to reboot)
#  (4) un.Start Menu Entries - remove StartUp shortcuts and Start Menu entries
#  (5) un.POPFile Core       - uninstall POPFile PROGRAM files
#  (6) un.Skins              - uninstall POPFile skins
#  (7) un.Languages          - uninstall POPFile UI languages
#  (8) un.QuickStart Guide   - uninstall POPFile English QuickStart Guide
#  (9) un.Kakasi             - uninstall Kakasi package and remove its environment variables
# (10) un.Minimal Perl       - uninstall minimal Perl, including all of the optional modules
# (11) un.Registry Entries   - remove 'Add/Remove Program' data and other registry entries
# (12) un.Uninstall End      - remove remaining files/folders (if it is safe to do so)
#
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.Uninstall Begin' (the first section in the uninstaller)
#--------------------------------------------------------------------------

Section "un.Uninstall Begin" UnSecBegin

  !define L_TEMP        $R9

  Push ${L_TEMP}

  ReadINIStr ${L_TEMP} "$G_USERDIR\install.ini" "Settings" "Owner"
  StrCmp ${L_TEMP} "" section_exit
  StrCmp ${L_TEMP} $G_WINUSERNAME section_exit

  MessageBox MB_YESNO|MB_ICONSTOP|MB_DEFBUTTON2 \
      "$(PFI_LANG_UN_MBDIFFUSER_1) ('${L_TEMP}') !\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_UN_MBNOTFOUND_2)" IDYES section_exit
  Abort "$(PFI_LANG_UN_ABORT_1)"

section_exit:
  Pop ${L_TEMP}

  !undef L_TEMP

SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.Local User Data'
#
# There may be 'User Data' in the same folder as the PROGRAM files (especially if this is
# an upgraded installation) so we must run the 'User Data' uninstaller before we uninstall
# POPFile (to restore any email settings changed by the installer).
#--------------------------------------------------------------------------

Section "un.Local User Data" UnSecUserData

  !define L_RESULT    $R9

  Push ${L_RESULT}

  IfFileExists "$G_ROOTDIR\popfile.pl" look_for_uninstalluser
  IfFileExists "$G_ROOTDIR\popfile.exe" look_for_uninstalluser
    MessageBox MB_YESNO|MB_ICONSTOP|MB_DEFBUTTON2 \
        "$(PFI_LANG_UN_MBNOTFOUND_1) '$G_ROOTDIR'.\
        ${MB_NL}${MB_NL}\
        $(PFI_LANG_UN_MBNOTFOUND_2)" IDYES look_for_uninstalluser
    Abort "$(PFI_LANG_UN_ABORT_1)"

look_for_uninstalluser:
  IfFileExists "$G_ROOTDIR\uninstalluser.exe" 0 section_exit

  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

  ; Uninstall the 'User Data' in the PROGRAM folder before uninstalling the PROGRAM files
  ; (note that running 'uninstalluser.exe' with the '_?=dir' option means it will be unable
  ; to delete itself because the program is NOT automatically relocated to the TEMP folder)

  HideWindow
  ExecWait '"$G_ROOTDIR\uninstalluser.exe" _?=$G_ROOTDIR' ${L_RESULT}
  BringToFront

  ; If the 'User Data' uninstaller did not return the normal "success" code (e.g. because user
  ; cancelled the 'User Data' uninstall) then we must retain the user data and uninstalluser.exe

  StrCmp ${L_RESULT} "0" 0 section_exit

  ; If any email settings have NOT been restored and the user wishes to try again later,
  ; the relevant INI file will still exist and we should not remove it or uninstalluser.exe

  IfFileExists "$G_ROOTDIR\pfi-outexpress.ini" section_exit
  IfFileExists "$G_ROOTDIR\pfi-outlook.ini" section_exit
  IfFileExists "$G_ROOTDIR\pfi-eudora.ini" section_exit
  Delete "$G_ROOTDIR\uninstalluser.exe"

section_exit:
  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

  Pop ${L_RESULT}

  !undef L_RESULT

SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.Shutdown POPFile'
#--------------------------------------------------------------------------

Section "un.Shutdown POPFile" UnSecShutdown

  !define L_CFG         $R9   ; used as file handle
  !define L_EXE         $R8   ; full path of the EXE to be monitored
  !define L_LNE         $R7   ; a line from popfile.cfg
  !define L_TEMP        $R6
  !define L_TEXTEND     $R5   ; used to ensure correct handling of lines longer than 1023 chars

  Push ${L_CFG}
  Push ${L_EXE}
  Push ${L_LNE}
  Push ${L_TEMP}
  Push ${L_TEXTEND}

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROG_SHUTDOWN)"
  SetDetailsPrint listonly

  ; Starting with POPfile 0.21.0 an experimental version of 'popfile-service.exe' was included
  ; to allow POPFile to be run as a Windows service.

  Push "POPFile"
  Call un.ServiceRunning
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "true" manual_shutdown

  ; If the POPFile we are to uninstall is still running, one of the EXE files will be 'locked'

  Push $G_ROOTDIR
  Call un.FindLockedPFE
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" check_pfi_utils

  ; The program files we are about to remove are in use so we need to shut POPFile down

  IfFileExists "$G_USERDIR\popfile.cfg" 0 manual_shutdown

  ; Use the UI port setting in the configuration file to shutdown POPFile

  StrCpy $G_GUI ""

  FileOpen ${L_CFG} "$G_USERDIR\popfile.cfg" r

found_eol:
  StrCpy ${L_TEXTEND} "<eol>"

loop:
  FileRead ${L_CFG} ${L_LNE}
  StrCmp ${L_LNE} "" ui_port_done
  StrCmp ${L_TEXTEND} "<eol>" 0 check_eol
  StrCmp ${L_LNE} "$\n" loop

  StrCpy ${L_TEMP} ${L_LNE} 10
  StrCmp ${L_TEMP} "html_port " 0 check_eol
  StrCpy $G_GUI ${L_LNE} 5 10

  ; Now read file until we get to end of the current line
  ; (i.e. until we find text ending in <CR><LF>, <CR> or <LF>)

check_eol:
  StrCpy ${L_TEXTEND} ${L_LNE} 1 -1
  StrCmp ${L_TEXTEND} "$\n" found_eol
  StrCmp ${L_TEXTEND} "$\r" found_eol loop

ui_port_done:
  FileClose ${L_CFG}

  StrCmp $G_GUI "" manual_shutdown
  Push $G_GUI
  Call un.TrimNewlines
  Call un.StrCheckDecimal
  Pop $G_GUI
  StrCmp $G_GUI "" manual_shutdown
  DetailPrint "$(PFI_LANG_UN_LOG_SHUTDOWN) $G_GUI"
  DetailPrint "$(PFI_LANG_TAKE_A_FEW_SECONDS)"
  Push $G_GUI
  Call un.ShutdownViaUI
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "success" check_pfi_utils

manual_shutdown:
  StrCpy $G_PLS_FIELD_1 "POPFile"
  DetailPrint "Unable to shutdown $G_PLS_FIELD_1 automatically - manual intervention requested"
  MessageBox MB_OK|MB_ICONEXCLAMATION|MB_TOPMOST "$(PFI_LANG_MBMANSHUT_1)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_MBMANSHUT_2)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_MBMANSHUT_3)"

  ; Assume user has managed to shutdown POPFile

check_pfi_utils:
  Push $G_ROOTDIR
  Call un.RequestPFIUtilsShutdown

  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

  Pop ${L_TEXTEND}
  Pop ${L_TEMP}
  Pop ${L_LNE}
  Pop ${L_EXE}
  Pop ${L_CFG}

  !undef L_CFG
  !undef L_EXE
  !undef L_LNE
  !undef L_TEMP
  !undef L_TEXTEND

SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.Start Menu Entries'
#--------------------------------------------------------------------------

Section "un.Start Menu Entries" UnSecStartMenu

  !define L_TEMP  $R9

  Push ${L_TEMP}

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROG_SHORT)"
  SetDetailsPrint listonly

  SetShellVarContext all
  StrCmp $G_WINUSERTYPE "Admin" menucleanup
  SetShellVarContext current

menucleanup:
  IfFileExists "$SMPROGRAMS\${C_PFI_PRODUCT}\QuickStart Guide.url" 0 delete_menu_entries
  ReadINIStr ${L_TEMP} "$SMPROGRAMS\${C_PFI_PRODUCT}\QuickStart Guide.url" \
      "InternetShortcut" "URL"
  StrCmp ${L_TEMP} "file://$G_ROOTDIR/manual/en/manual.html" delete_menu_entries exit

delete_menu_entries:
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\POPFile Home Page.url"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\POPFile Support (Wiki).url"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\PFI Diagnostic utility (simple).lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\PFI Diagnostic utility (full).lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\Create 'User Data' shortcut.lnk"
  RMDir "$SMPROGRAMS\${C_PFI_PRODUCT}\Support"

  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Release Notes.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Run POPFile.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Run POPFile in background.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Shutdown POPFile silently.lnk"

  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\FAQ.url"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\QuickStart Guide.url"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\POPFile User Interface.url"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Shutdown POPFile.url"

  Delete "$SMSTARTUP\Run POPFile in background.lnk"
  Delete "$SMSTARTUP\Run POPFile.lnk"

  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Uninstall POPFile.lnk"
  RMDir "$SMPROGRAMS\${C_PFI_PRODUCT}"

exit:

  ; Restore the default NSIS context

  SetShellVarContext current

  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

  Pop ${L_TEMP}

  !undef L_TEMP

SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.POPFile Core'
#
# Files are explicitly deleted (instead of just using wildcards or 'RMDir /r' commands)
# in an attempt to avoid unexpectedly deleting any files create by the user after installation.
# Current commands only cover most recent versions of POPFile - need to add commands to cover
# more of the early versions of POPFile.
#--------------------------------------------------------------------------

Section "un.POPFile Core" UnSecCore

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROG_CORE)"
  SetDetailsPrint listonly

  Delete "$G_ROOTDIR\wrapper.exe"
  Delete "$G_ROOTDIR\wrapperf.exe"
  Delete "$G_ROOTDIR\wrapperb.exe"
  Delete "$G_ROOTDIR\wrapper.ini"

  Delete "$G_ROOTDIR\runpopfile.exe"
  Delete "$G_ROOTDIR\adduser.exe"
  Delete "$G_ROOTDIR\sqlite.exe"
  Delete "$G_ROOTDIR\runsqlite.exe"
  Delete "$G_ROOTDIR\pfidiag.exe"
  Delete "$G_ROOTDIR\msgcapture.exe"
  Delete "$G_ROOTDIR\pfimsgcapture.exe"

  IfFileExists "$G_ROOTDIR\pfidiag.exe" try_again
  IfFileExists "$G_ROOTDIR\msgcapture.exe" try_again
  IfFileExists "$G_ROOTDIR\msgcapture.exe" 0 continue

try_again:
  Sleep 1000
  Delete "$G_ROOTDIR\pfidiag.exe"
  Delete "$G_ROOTDIR\msgcapture.exe"
  Delete "$G_ROOTDIR\pfimsgcapture.exe"

continue:
  Delete "$G_ROOTDIR\otto.png"
  Delete "$G_ROOTDIR\*.gif"
  Delete "$G_ROOTDIR\*.change"
  Delete "$G_ROOTDIR\*.change.txt"

  Delete "$G_ROOTDIR\pfi-data.ini"

  Delete "$G_ROOTDIR\popfile.pl"
  Delete "$G_ROOTDIR\popfile.pck"
  Delete "$G_ROOTDIR\*.pm"

  Delete "$G_ROOTDIR\bayes.pl"
  Delete "$G_ROOTDIR\insert.pl"
  Delete "$G_ROOTDIR\pipe.pl"
  Delete "$G_ROOTDIR\favicon.ico"
  Delete "$G_ROOTDIR\popfile.exe"
  Delete "$G_ROOTDIR\popfilef.exe"
  Delete "$G_ROOTDIR\popfileb.exe"
  Delete "$G_ROOTDIR\popfileif.exe"
  Delete "$G_ROOTDIR\popfileib.exe"
  Delete "$G_ROOTDIR\popfile-service.exe"
  Delete "$G_ROOTDIR\stop_pf.exe"
  Delete "$G_ROOTDIR\license"
  Delete "$G_ROOTDIR\pfi-stopwords.default"

  Delete "$G_ROOTDIR\Classifier\*.pm"
  Delete "$G_ROOTDIR\Classifier\popfile.sql"
  RMDir "$G_ROOTDIR\Classifier"

  Delete "$G_ROOTDIR\Platform\*.pm"
  Delete "$G_ROOTDIR\Platform\*.dll"
  RMDir "$G_ROOTDIR\Platform"

  Delete "$G_ROOTDIR\POPFile\*.pm"
  Delete "$G_ROOTDIR\POPFile\popfile_version"
  RMDir "$G_ROOTDIR\POPFile"

  Delete "$G_ROOTDIR\Proxy\*.pm"
  RMDir "$G_ROOTDIR\Proxy"

  Delete "$G_ROOTDIR\Server\*.pm"
  RMDir "$G_ROOTDIR\Server"

  Delete "$G_ROOTDIR\Services\*.pm"
  RMDir "$G_ROOTDIR\Services"

  Delete "$G_ROOTDIR\UI\*.pm"
  RMDir "$G_ROOTDIR\UI"

  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.Skins'
#--------------------------------------------------------------------------

Section "un.Skins" UnSecSkins

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROG_SKINS)"
  SetDetailsPrint listonly

  !insertmacro DeleteSkin "$G_ROOTDIR\skins\blue"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\coolblue"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\coolbrown"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\coolgreen"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\coolorange"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\coolyellow"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\default"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\glassblue"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\green"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\klingon"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\lavish"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\lrclaptop"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\oceanblue"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\orange"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\orangecream"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\osx"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\outlook"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\prjbluegrey"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\prjsteelbeach"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\simplyblue"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\sleet"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\sleet-rtl"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\smalldefault"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\smallgrey"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\strawberryrose"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\tinydefault"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\tinygrey"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\white"
  !insertmacro DeleteSkin "$G_ROOTDIR\skins\windows"

  RMDir "$G_ROOTDIR\skins"

  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.Languages'
#--------------------------------------------------------------------------

Section "un.Languages" UnSecLangs

  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

  Delete "$G_ROOTDIR\languages\*.msg"
  RMDir "$G_ROOTDIR\languages"

  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.QuickStart Guide'
#--------------------------------------------------------------------------

Section "un.QuickStart Guide" UnSecQuickGuide

  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

  Delete "$G_ROOTDIR\manual\en\*.html"
  RMDir "$G_ROOTDIR\manual\en"
  Delete "$G_ROOTDIR\manual\*.gif"
  RMDir "$G_ROOTDIR\manual"

  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.Kakasi'
#--------------------------------------------------------------------------

Section "un.Kakasi" UnSecKakasi

  !define L_TEMP        $R9

  Push ${L_TEMP}

  IfFileExists "$INSTDIR\kakasi\*.*" 0 section_exit

  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

  RMDir /r "$INSTDIR\kakasi"

  ;Delete Environment Variables

  Push "KANWADICTPATH"
  Call un.DeleteEnvStr
  Push "ITAIJIDICTPATH"
  Call un.DeleteEnvStr

  ; If the 'all users' environment variables refer to this installation, remove them too

  ReadEnvStr ${L_TEMP} "KANWADICTPATH"
  Push ${L_TEMP}
  Push $INSTDIR
  Call un.StrStr
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" section_exit
  Push "KANWADICTPATH"
  Call un.DeleteEnvStrNTAU
  Push "ITAIJIDICTPATH"
  Call un.DeleteEnvStrNTAU

section_exit:
  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

  Pop ${L_TEMP}

  !undef L_TEMP

SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.Minimal Perl'
#--------------------------------------------------------------------------

Section "un.Minimal Perl" UnSecMinPerl

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROG_PERL)"
  SetDetailsPrint listonly

  Delete "$G_ROOTDIR\perl*.dll"
  Delete "$G_ROOTDIR\perl.exe"
  Delete "$G_ROOTDIR\wperl.exe"

  ; Win95 displays an error message if an attempt is made to delete
  ; non-existent folders
  ; (so we check before removing optional Perl components which may
  ; not have been installed)

  IfFileExists "$G_MPLIBDIR\HTTP\*.*" 0 skip_XMLRPC_support
  RMDir /r "$G_MPLIBDIR\HTTP"
  RMDir /r "$G_MPLIBDIR\LWP"
  RMDir /r "$G_MPLIBDIR\Net"
  RMDir /r "$G_MPLIBDIR\SOAP"
  RMDir /r "$G_MPLIBDIR\URI"
  RMDir /r "$G_MPLIBDIR\XML"
  RMDir /r "$G_MPLIBDIR\XMLRPC"

skip_XMLRPC_support:
  RMDir /r "$G_MPLIBDIR\auto"
  RMDir /r "$G_MPLIBDIR\Carp"
  RMDir /r "$G_MPLIBDIR\Date"
  RMDir /r "$G_MPLIBDIR\DBD"
  RMDir /r "$G_MPLIBDIR\Digest"
  IfFileExists "$G_MPLIBDIR\Encode\*.*" 0 skip_Encode
  RMDir /r "$G_MPLIBDIR\Encode"

skip_Encode:
  RMDir /r "$G_MPLIBDIR\Exporter"
  RMDir /r "$G_MPLIBDIR\File"
  RMDir /r "$G_MPLIBDIR\Getopt"
  RMDir /r "$G_MPLIBDIR\HTML"
  RMDir /r "$G_MPLIBDIR\IO"
  RMDir /r "$G_MPLIBDIR\MIME"
  RMDir /r "$G_MPLIBDIR\String"
  RMDir /r "$G_MPLIBDIR\Sys"
  RMDir /r "$G_MPLIBDIR\Text"
  RMDir /r "$G_MPLIBDIR\Time"
  RMDir /r "$G_MPLIBDIR\warnings"
  IfFileExists "$G_MPLIBDIR\Win32\*.*" 0 skip_Win32
  RMDir /r "$G_MPLIBDIR\Win32"

skip_Win32:
  Delete "$G_MPLIBDIR\*.pm"
  RMDIR "$G_MPLIBDIR"

  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.Registry Entries'
#--------------------------------------------------------------------------

Section "un.Registry Entries" UnSecRegistry

  !define L_REGDATA $R9

  Push ${L_REGDATA}

  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

  ; Only remove registry data if it matches what we are uninstalling

  StrCmp $G_WINUSERTYPE "Admin" check_HKLM_data

  ; Uninstalluser.exe deletes all HKCU registry data except for the 'Add/Remove Programs' entry

  ReadRegStr ${L_REGDATA} HKCU \
      "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" "UninstallString"
  StrCmp ${L_REGDATA} "$G_ROOTDIR\uninstall.exe" 0 section_exit
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}"
  Goto section_exit

check_HKLM_data:
  ReadRegStr ${L_REGDATA} HKLM \
      "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" "UninstallString"
  StrCmp ${L_REGDATA} "$G_ROOTDIR\uninstall.exe" 0 other_reg_data
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}"

other_reg_data:
  ReadRegStr ${L_REGDATA} HKLM "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_LFN"
  StrCmp ${L_REGDATA} $G_ROOTDIR 0 section_exit
  DeleteRegKey HKLM "Software\POPFile Project\${C_PFI_PRODUCT}\MRI"
  DeleteRegKey /ifempty HKLM "Software\POPFile Project\${C_PFI_PRODUCT}"
  DeleteRegKey /ifempty HKLM "Software\POPFile Project"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\stop_pf.exe"

section_exit:
  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

  Pop ${L_REGDATA}

  !undef L_REGDATA
SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.Uninstall End' (this is the final section in the uninstaller)
#
# Used to terminate the uninstaller - offers to remove any files/folders left behind.
# If any 'User Data' is left in the PROGRAM folder then we preserve it to allow the
# user to make another attempt at restoring the email settings.
#--------------------------------------------------------------------------

Section "un.Uninstall End" UnSecEnd

  Delete "$G_ROOTDIR\Uninstall.exe"
  RMDir "$G_ROOTDIR"

  ; if the installation folder ($G_ROOTDIR) was removed, skip these next ones

  IfFileExists "$G_ROOTDIR\*.*" 0 exit

  ; If 'User Data' uninstaller still exists, we cannot offer to remove the remaining files
  ; (some email settings have not been restored and the user wants to try again later or
  ; the user decided not to uninstall the 'User Data' at the moment)

  IfFileExists "$G_ROOTDIR\uninstalluser.exe" exit

  MessageBox MB_YESNO|MB_ICONQUESTION "$(PFI_LANG_UN_MBREMDIR_1)" IDNO exit
  DetailPrint "$(PFI_LANG_UN_LOG_DELUSERDIR)"
  Delete "$G_ROOTDIR\*.*"
  RMDir /r $G_ROOTDIR
  IfFileExists "$G_ROOTDIR\*.*" 0 exit
  DetailPrint "$(PFI_LANG_UN_LOG_DELUSERERR)"
  MessageBox MB_OK|MB_ICONEXCLAMATION \
      "$(PFI_LANG_UN_MBREMERR_1): $G_ROOTDIR $(PFI_LANG_UN_MBREMERR_2)"

exit:
  SetDetailsPrint both
SectionEnd

#--------------------------------------------------------------------------
# Macro-based Functions make it easier to maintain identical functions
# which are (or might be) used in the installer and in the uninstaller.
#--------------------------------------------------------------------------

!macro ShowPleaseWaitBanner UN
  Function ${UN}ShowPleaseWaitBanner

    !ifndef ENGLISH_MODE

      ; The Banner plug-in uses the "MS Shell Dlg" font to display the banner text but
      ; East Asian versions of Windows 9x do not support this so in these cases we use
      ; "English" text for the banner (otherwise the text would be unreadable garbage).

      !define L_RESULT    $R9   ; The 'IsNT' function returns 0 if Win9x was detected

      Push ${L_RESULT}

      Call IsNT
      Pop ${L_RESULT}
      StrCmp ${L_RESULT} "1" show_banner

      ; Windows 9x has been detected

      StrCmp $LANGUAGE ${LANG_SIMPCHINESE} use_ENGLISH_banner
      StrCmp $LANGUAGE ${LANG_TRADCHINESE} use_ENGLISH_banner
      StrCmp $LANGUAGE ${LANG_JAPANESE} use_ENGLISH_banner
      StrCmp $LANGUAGE ${LANG_KOREAN} use_ENGLISH_banner
      Goto show_banner

    use_ENGLISH_banner:
      Banner::show /NOUNLOAD /set 76 "Please be patient." "This may take a few seconds..."
      Goto continue

      show_banner:
    !endif

    Banner::show /NOUNLOAD /set 76 "$(PFI_LANG_BE_PATIENT)" "$(PFI_LANG_TAKE_A_FEW_SECONDS)"

    !ifndef ENGLISH_MODE
      continue:
        Pop ${L_RESULT}

        !undef L_RESULT
    !endif

  FunctionEnd
!macroend

#--------------------------------------------------------------------------
# Installer Function: ShowPleaseWaitBanner
#
# This function is used during the installation process
#--------------------------------------------------------------------------

!insertmacro ShowPleaseWaitBanner ""

#--------------------------------------------------------------------------
# Uninstaller Function: un.ShowPleaseWaitBanner
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro ShowPleaseWaitBanner "un."

#--------------------------------------------------------------------------
# End of 'installer.nsi'
#--------------------------------------------------------------------------
