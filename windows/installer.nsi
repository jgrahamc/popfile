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
# The original 'installer.nsi' script has been divided into several files:
#
#  (1) installer.nsi                 - master script which uses the following 'include' files
#  (2) installer-SecPOPFile-body.nsh - body of section used to install the POPFile program
#  (3) installer-SecPOPFile-func.nsh - functions used by the above 'include' file
#  (4) installer-SecMinPerl-body.nsh - body of section used to install the basic minimal Perl
#  (5) installer-Uninstall.nsh       - source for the POPFile uninstaller (uninstall.exe)
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
# /SSL
#
# If there are problems downloading the optional SSL support files from the Internet, the
# installer will skip this part of the installation. If SSL support is required, the SSL
# files can be added by re-running the installer with the /SSL command-line switch to make
# it skip everything except the downloading and installation of the SSL support files.
#
# The /SSL switch can use uppercase or lowercase.
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

  Var G_SSL_ONLY           ; 1 = SSL-only installation, 0 = normal installation

  Var G_PLS_FIELD_1        ; used to customize translated text strings

  Var G_DLGITEM            ; HWND of the UI dialog field we are going to modify

  ;-------------------------------------------------------------------------------
  ; At present (14 March 2004) POPFile does not work properly if POPFILE_ROOT or POPFILE_USER
  ; are set to values containing spaces. A simple workaround is to use short file name format
  ; values for these environment variables. But some systems may not support short file names
  ; (e.g. using short file names on NTFS volumes can have a significant impact on performance)
  ; so we need to check if short file names are supported (if they are not, we insist upon paths
  ; which do not contain spaces).
  ;-------------------------------------------------------------------------------

  Var G_SFN_DISABLED       ; 1 = short file names not supported, 0 = short file names available

  ;-------------------------------------------------------------------------------

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
# Include private library functions and macro definitions
#--------------------------------------------------------------------------

  ; Avoid compiler warnings by disabling the functions and definitions we do not use

  !define INSTALLER

  !include "pfi-library.nsh"
  !include "WriteEnvStr.nsh"

  ; Macros used for entries in the installation log file

  !macro SECTIONLOG_ENTER NAME
      SetDetailsPrint listonly
      DetailPrint "----------------------------------------"
      DetailPrint "$\"${NAME}$\" Section (entry)"
      DetailPrint "----------------------------------------"
      DetailPrint ""
  !macroend

  !macro SECTIONLOG_EXIT NAME
      SetDetailsPrint listonly
      DetailPrint ""
      DetailPrint "----------------------------------------"
      DetailPrint "$\"${NAME}$\" Section (exit)"
      DetailPrint "----------------------------------------"
      DetailPrint ""
  !macroend

#--------------------------------------------------------------------------
# Version Information settings (for the installer EXE and uninstaller EXE)
#--------------------------------------------------------------------------

  ; 'VIProductVersion' format is X.X.X.X where X is a number in range 0 to 65535
  ; representing the following values: Major.Minor.Release.Build

  VIProductVersion "${C_POPFILE_MAJOR_VERSION}.${C_POPFILE_MINOR_VERSION}.${C_POPFILE_REVISION}.0"

  VIAddVersionKey "ProductName"             "${C_PFI_PRODUCT}"
  VIAddVersionKey "Comments"                "POPFile Homepage: http://getpopfile.org/"
  VIAddVersionKey "CompanyName"             "The POPFile Project"
  VIAddVersionKey "LegalCopyright"          "Copyright (c) 2005  John Graham-Cumming"
  VIAddVersionKey "FileDescription"         "POPFile Automatic email classification"
  VIAddVersionKey "FileVersion"             "${C_PFI_VERSION}"
  VIAddVersionKey "OriginalFilename"        "${C_OUTFILE}"

  !ifndef ENGLISH_MODE
    !ifndef NO_KAKASI
      VIAddVersionKey "Build"               "Multi-Language installer (with Kakasi)"
    !else
      VIAddVersionKey "Build"               "Multi-Language installer (without Kakasi)"
    !endif
  !else
    !ifndef NO_KAKASI
      VIAddVersionKey "Build"               "English-Mode installer (with Kakasi)"
    !else
      VIAddVersionKey "Build"               "English-Mode installer (without Kakasi)"
    !endif
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

  ; Use a "pre" function to check if only the SSL Support files are to be installed

  !define MUI_PAGE_CUSTOMFUNCTION_PRE         "CheckSSLOnlyFlag"

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
  ; Installer Page - Show user what we are about to do and get permission to proceed
  ;
  ; This page must come immediately before the INSTFILES page ('MUI_PAGE_INSTFILES')
  ;---------------------------------------------------

  Page custom GetPermissionToInstall

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

  ; Note that the 'InstallDir' value has a trailing slash (to override the default behaviour)
  ;
  ; By default, NSIS will append '\${C_PFI_PRODUCT}' to the path selected using the 'Browse'
  ; button if the path does not already end with '\${C_PFI_PRODUCT}'. If the 'Browse' button
  ; is used to select 'C:\Program Files\POPFile Test' the installer will install the program
  ; in the 'C:\Program Files\POPFile Test\POPFile' folder and although this location is shown
  ; on the DIRECTORY page before the user clicks the 'Next' button most users will not notice
  ; that '\POPFile' has been appended to the location they selected. This problem will be made
  ; worse if there is an existing version of POPFile in the 'C:\Program Files\POPFile Test'
  ; folder since there will already be a 'C:\Program Files\POPFile Test\POPFile' folder holding
  ; Configuration.pm, History.pm, etc
  ;
  ; By adding a trailing slash we ensure that if the user selects a folder using the 'Browse'
  ; button then that is what the installer will use. One side effect of this change is that it
  ; is now easier for users to select a folder such as 'C:\Program Files' for the installation
  ; (which is not a good choice - so we refuse to accept any path matching the target system's
  ; "program files" folder; see the 'CheckExistingProgDir' function)

  InstallDir "$PROGRAMFILES\${C_PFI_PRODUCT}\"
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
  ReserveFile "${NSISDIR}\Plugins\untgz.dll"
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
  Call PFI_TrimNewlines
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

  StrCpy $G_SSL_ONLY "0"    ; assume a full installation is required
  Call PFI_GetParameters
  Pop ${L_RESERVED}
  StrCmp ${L_RESERVED} "/SSL" 0 exit
  StrCpy $G_SSL_ONLY "1"    ; just download and install the SSL support files

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
# Installer Section: StartLog (this must be the very first section)
#
# Creates the log header with information about this installation
#--------------------------------------------------------------------------

Section "-StartLog"

  SetDetailsPrint listonly

  DetailPrint "------------------------------------------------------------"
  DetailPrint "$(^Name) v${C_PFI_VERSION} Installer Log"
  DetailPrint "------------------------------------------------------------"
  DetailPrint "Command-line: $CMDLINE"
  DetailPrint "User Details: $G_WINUSERNAME ($G_WINUSERTYPE)"
  DetailPrint "PFI Language: $LANGUAGE"
  DetailPrint "------------------------------------------------------------"
  Call PFI_GetDateTimeStamp
  Pop $G_PLS_FIELD_1
  DetailPrint "Installation started $G_PLS_FIELD_1"
  DetailPrint "------------------------------------------------------------"
  DetailPrint ""

SectionEnd

#--------------------------------------------------------------------------
# Installer Section: POPFile component (always installed)
#
# Installs the POPFile program files.
#--------------------------------------------------------------------------

Section "POPFile" SecPOPFile
  !include "installer-SecPOPFile-body.nsh"
SectionEnd

; Functions used only by "installer-SecPOPFile-body.nsh"

!include "installer-SecPOPFile-func.nsh"

#--------------------------------------------------------------------------
# Installer Section: Minimal Perl component (always installed)
#
# Installs the minimal Perl.
#--------------------------------------------------------------------------

Section "-Minimal Perl" SecMinPerl
  !include "installer-SecMinPerl-body.nsh"
SectionEnd

#--------------------------------------------------------------------------
# Installer Section: (optional) Skins component (default = selected)
#
# Installs additional skins to allow the look-and-feel of the User Interface
# to be changed. The 'default' skin is always installed (by the 'POPFile'
# section) since this is the default skin for POPFile.
#--------------------------------------------------------------------------

Section "Skins" SecSkins

  !insertmacro SECTIONLOG_ENTER "Skins"

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

  !insertmacro SECTIONLOG_EXIT "Skins"

SectionEnd

#--------------------------------------------------------------------------
# Installer Section: (optional) UI Languages component (default = selected)
#--------------------------------------------------------------------------

Section "Languages" SecLangs

  !insertmacro SECTIONLOG_ENTER "Languages"

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_LANGS)"
  SetDetailsPrint listonly

  SetOutPath "$G_ROOTDIR\languages"
  File "..\engine\languages\*.msg"

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_ENDSEC)"
  SetDetailsPrint listonly

  !insertmacro SECTIONLOG_EXIT "Languages"

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

      !insertmacro SECTIONLOG_ENTER "Kakasi"

      !define L_RESERVED  $0    ; used in system.dll call

      Push ${L_RESERVED}

      ;--------------------------------------------------------------------------
      ; Install Kakasi package
      ;--------------------------------------------------------------------------

      SetOutPath "$G_ROOTDIR"
      File /r "${C_KAKASI_DIR}\kakasi"

      ; Add Environment Variables for Kakasi

      Push "ITAIJIDICTPATH"
      Push "$G_ROOTDIR\kakasi\share\kakasi\itaijidict"

      StrCmp $G_WINUSERTYPE "Admin" all_users_1
      Call PFI_WriteEnvStr
      Goto next_var

    all_users_1:
      Call PFI_WriteEnvStrNTAU

    next_var:
      Push "KANWADICTPATH"
      Push "$G_ROOTDIR\kakasi\share\kakasi\kanwadict"

      StrCmp $G_WINUSERTYPE "Admin" all_users_2
      Call PFI_WriteEnvStr
      Goto set_env

    all_users_2:
      Call PFI_WriteEnvStrNTAU

    set_env:
      IfRebootFlag set_vars_now

      ; Running on a non-Win9x system which already has the correct Kakaksi environment data
      ; or running on a non-Win9x system

      Call PFI_IsNT
      Pop ${L_RESERVED}
      StrCmp ${L_RESERVED} "0" continue

      ; Running on a non-Win9x system so we ensure the Kakasi environment variables
      ; are updated to match this installation

    set_vars_now:
      System::Call 'Kernel32::SetEnvironmentVariableA(t, t) \
                    i("ITAIJIDICTPATH", "$G_ROOTDIR\kakasi\share\kakasi\itaijidict").r0'
      StrCmp ${L_RESERVED} 0 0 itaiji_set_ok
      MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_ENVNOTSET) (ITAIJIDICTPATH)"

    itaiji_set_ok:
      System::Call 'Kernel32::SetEnvironmentVariableA(t, t) \
                    i("KANWADICTPATH", "$G_ROOTDIR\kakasi\share\kakasi\kanwadict").r0'
      StrCmp ${L_RESERVED} 0 0 continue
      MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_ENVNOTSET) (KANWADICTPATH)"

    continue:

      ;--------------------------------------------------------------------------
      ; Install Perl modules: base.pm, bytes.pm, the Encode collection and Text::Kakasi
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

      !insertmacro SECTIONLOG_EXIT "Kakasi"

    SectionEnd
!endif

SubSection /e "Optional modules" SubSecOptional

#--------------------------------------------------------------------------
# Installer Section: (optional) POPFile NNTP proxy (default = not selected)
#
# If this component is selected, the installer installs the POPFile NNTP proxy module
#--------------------------------------------------------------------------

Section /o "NNTP proxy" SecNNTP

  !insertmacro SECTIONLOG_ENTER "NNTP Proxy"

  SetOutPath "$G_ROOTDIR\Proxy"
  File "..\engine\Proxy\NNTP.pm"

  !insertmacro SECTIONLOG_EXIT "NNTP Proxy"

SectionEnd

#--------------------------------------------------------------------------
# Installer Section: (optional) POPFile SMTP proxy (default = not selected)
#
# If this component is selected, the installer installs the POPFile SMTP proxy module
#--------------------------------------------------------------------------

Section /o "SMTP proxy" SecSMTP

  !insertmacro SECTIONLOG_ENTER "SMTP Proxy"

  SetOutPath "$G_ROOTDIR\Proxy"
  File "..\engine\Proxy\SMTP.pm"

  !insertmacro SECTIONLOG_EXIT "SMTP Proxy"

SectionEnd

#--------------------------------------------------------------------------
# Installer Section: (optional) POPFile XMLRPC component (default = not selected)
#
# If this component is selected, the installer installs the POPFile XMLRPC support
# (UI\XMLRPC.pm and POPFile\API.pm) and the extra Perl modules required by XMLRPC.pm.
# The XMLRPC module exposes the POPFile API to allow access to many POPFile functions.
#--------------------------------------------------------------------------

Section /o "XMLRPC" SecXMLRPC

  !insertmacro SECTIONLOG_ENTER "XMLRPC"

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

  !insertmacro SECTIONLOG_EXIT "XMLRPC"

SectionEnd

#--------------------------------------------------------------------------
# Installer Section: (optional) POPFile IMAP component (default = not selected)
#
# If this component is selected, the installer installs the experimental IMAP module.
#--------------------------------------------------------------------------

Section /o "IMAP" SecIMAP

  !insertmacro SECTIONLOG_ENTER "IMAP"

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

  !insertmacro SECTIONLOG_EXIT "IMAP"

SectionEnd

#--------------------------------------------------------------------------
# Installer Section: (optional) Perl IO::Socket::Socks module (default = not selected)
#
# If this component is selected, the installer installs the Perl Socks module to provide
# SOCKS V support for all of the POPFile proxies.
#--------------------------------------------------------------------------

Section /o "SOCKS" SecSOCKS

  !insertmacro SECTIONLOG_ENTER "SOCKS"

  SetOutPath "$G_MPLIBDIR\IO\Socket"
  File "${C_PERL_DIR}\site\lib\IO\Socket\Socks.pm"

  !insertmacro SECTIONLOG_EXIT "SOCKS"

SectionEnd

#--------------------------------------------------------------------------
# Installer Section: (optional) SSL Support for POPFile (default = not selected)
#
# If this component is selected, the installer downloads and installs the extra
# Perl modules and the necessary OpenSSL libraries required to support SSL access
# access to mail servers. The installer waits until all of these extra files have
# been downloaded before installing any of them. If the download attempt fails, the
# installation will continue (since SSL support is an optional feature). A later
# attempt can be made by running the stand-alone 'SSL Setup' wizard to download
# and install only these extra SSL support files.
#
# Note: The 'getssl.nsh' file includes more than just the 'Section' code.
#
# The 'getssl.nsh' file is used by the 'SSL Setup' wizard to ensure it
# handles the downloading and installation of the SSL support files in the
# same way as the main POPFile installer.
#--------------------------------------------------------------------------

  !include "getssl.nsh"

SubSectionEnd

#--------------------------------------------------------------------------
# Installer Section: StopLog (this must be the very last section)
#
# Finishes the log file and saves it (making backups of up to 3 previous logs)
#--------------------------------------------------------------------------

Section "-StopLog"

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_PROG_SAVELOG) $(PFI_LANG_TAKE_SEVERAL_SECONDS)"
  SetDetailsPrint listonly
  Call PFI_GetDateTimeStamp
  Pop $G_PLS_FIELD_1
  StrCmp $G_SSL_ONLY "0" normal_log
  DetailPrint "------------------------------------------------------------"
  DetailPrint "SSL Support installation finished $G_PLS_FIELD_1"
  DetailPrint "------------------------------------------------------------"
  Goto save_log

normal_log:
  DetailPrint "------------------------------------------------------------"
  DetailPrint "'Add POPFile User' will be called to configure POPFile"
  IfRebootFlag 0 close_log
  DetailPrint "(a reboot is required to complete the Kakasi installation)"

close_log:
  DetailPrint "------------------------------------------------------------"
  DetailPrint "Main program installation finished $G_PLS_FIELD_1"
  DetailPrint "------------------------------------------------------------"

save_log:

  ; Save a log showing what was installed

  !insertmacro PFI_BACKUP_123_DP "$G_ROOTDIR" "install.log"
  Push "$G_ROOTDIR\install.log"
  Call PFI_DumpLog
  DetailPrint "Log report saved in '$G_ROOTDIR\install.log'"
  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_ENDSEC)"
  SetDetailsPrint listonly

SectionEnd

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
    !insertmacro MUI_DESCRIPTION_TEXT ${SecSSL}         $(DESC_SecSSL)
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

  Push ${L_TEMP}

  Call PFI_GetIEVersion
  Pop $G_PLS_FIELD_1

  StrCpy ${L_TEMP} $G_PLS_FIELD_1 1
  StrCmp ${L_TEMP} '?' not_good
  IntCmp ${L_TEMP} 5 exit not_good exit

not_good:

  ; Ensure custom page matches the selected language (left-to-right or right-to-left order)

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioG.ini" "Settings" "RTL" "$(^RTL)"

  !insertmacro PFI_IO_TEXT "ioG.ini" "1" \
      "$(PFI_LANG_PERLREQ_IO_TEXT_A)\
       $(PFI_LANG_PERLREQ_IO_TEXT_B)\
       $(PFI_LANG_PERLREQ_IO_TEXT_C)\
       $(PFI_LANG_PERLREQ_IO_TEXT_D)"

  !insertmacro PFI_IO_TEXT "ioG.ini" "2" \
      "$(PFI_LANG_PERLREQ_IO_TEXT_E)\
       $(PFI_LANG_PERLREQ_IO_TEXT_F)\
       $(PFI_LANG_PERLREQ_IO_TEXT_G)"

  !insertmacro MUI_HEADER_TEXT "$(PFI_LANG_PERLREQ_TITLE)" " "

  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioG.ini"

exit:
  Pop ${L_TEMP}

  !undef L_TEMP

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: GetPermissionToInstall
# (this is the last page shown before the installation starts)
#
# Display the information collected from the user to show what we are about to do.
# The 'Back' button can be used to navigate to earlier pages if the user wishes to
# change this information (i.e. select/deselect a component or change the install folder)
#--------------------------------------------------------------------------

Function GetPermissionToInstall

  !define L_TEMP   $R9

  Push ${L_TEMP}

  ; This is a very simple custom page so we create the INI file here

  ; Ensure custom page matches the selected language (left-to-right or right-to-left order)

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioData.ini" "Settings" "RTL" "$(^RTL)"

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioData.ini" "Settings" "NumFields" "1"

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioData.ini" "Field 1"  "Type"   "text"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioData.ini" "Field 1"  "Left"   "0"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioData.ini" "Field 1"  "Right"  "300"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioData.ini" "Field 1"  "Top"    "0"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioData.ini" "Field 1"  "Bottom" "140"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioData.ini" "Field 1"  "Flags"  "MULTILINE|HSCROLL|VSCROLL|READONLY"

  !insertmacro MUI_HEADER_TEXT "$(PFI_LANG_SUMMARY_TITLE)" "$(PFI_LANG_SUMMARY_SUBTITLE)"

  ; The entries in the "Basic" and "Optional" component lists are indented a little

  !define C_NLT     "${IO_NL}\t"

  IfFileExists "$G_ROOTDIR\popfile.pl" upgrade
  StrCpy ${L_TEMP} "$(PFI_LANG_SUMMARY_NEWLOCN)"
  GetDlgItem $G_DLGITEM $HWNDPARENT 1
  SendMessage $G_DLGITEM ${WM_SETTEXT} 0 "STR:$(^InstallBtn)"
  Goto start_summary

upgrade:
  StrCpy ${L_TEMP} "$(PFI_LANG_SUMMARY_UPGRADELOCN)"
  GetDlgItem $G_DLGITEM $HWNDPARENT 1
  SendMessage $G_DLGITEM ${WM_SETTEXT} 0 "STR:$(PFI_LANG_INST_BTN_UPGRADE)"

start_summary:
  StrCpy $G_PLS_FIELD_1 "${L_TEMP}${IO_NL}${IO_NL}\
      $(PFI_LANG_SUMMARY_BASICLIST)${IO_NL}"
  StrCpy ${L_TEMP} "${C_NLT}$(PFI_LANG_SUMMARY_NONE)"

  !insertmacro PFI_SectionNotSelected ${SecPOPFile} check_min_perl
  StrCpy ${L_TEMP} ""
  StrCpy $G_PLS_FIELD_1 "$G_PLS_FIELD_1${C_NLT}\
          $(PFI_LANG_SUMMARY_POPFILECORE)${C_NLT}\
          $(PFI_LANG_SUMMARY_DEFAULTSKIN)${C_NLT}\
          $(PFI_LANG_SUMMARY_DEFAULTLANG)"

check_min_perl:
  !insertmacro PFI_SectionNotSelected ${SecMinPerl} check_skins
  StrCpy ${L_TEMP} ""
  StrCpy $G_PLS_FIELD_1 "$G_PLS_FIELD_1${C_NLT}$(PFI_LANG_SUMMARY_MINPERL)"

check_skins:
  !insertmacro PFI_SectionNotSelected ${SecSkins} check_langs
  StrCpy ${L_TEMP} ""
  StrCpy $G_PLS_FIELD_1 "$G_PLS_FIELD_1${C_NLT}$(PFI_LANG_SUMMARY_EXTRASKINS)"

check_langs:
  !insertmacro PFI_SectionNotSelected ${SecLangs} check_kakasi
  StrCpy ${L_TEMP} ""
  StrCpy $G_PLS_FIELD_1 "$G_PLS_FIELD_1${C_NLT}$(PFI_LANG_SUMMARY_EXTRALANGS)"

check_kakasi:
  !ifndef NO_KAKASI
      !insertmacro PFI_SectionNotSelected ${SecKakasi} end_basic
      StrCpy ${L_TEMP} ""
      StrCpy $G_PLS_FIELD_1 "$G_PLS_FIELD_1${C_NLT}$(PFI_LANG_SUMMARY_KAKASI)"

    end_basic:
  !endif
  StrCpy $G_PLS_FIELD_1 "$G_PLS_FIELD_1${L_TEMP}${IO_NL}${IO_NL}\
      $(PFI_LANG_SUMMARY_OPTIONLIST)${IO_NL}"

  ; Check the optional components in alphabetic order

  StrCpy ${L_TEMP} "\t$(PFI_LANG_SUMMARY_NONE)"

  !insertmacro PFI_SectionNotSelected ${SecIMAP} check_nntp
  StrCpy ${L_TEMP} ""
  StrCpy $G_PLS_FIELD_1 "$G_PLS_FIELD_1${C_NLT}$(PFI_LANG_SUMMARY_IMAP)"

check_nntp:
  !insertmacro PFI_SectionNotSelected ${SecNNTP} check_smtp
  StrCpy ${L_TEMP} ""
  StrCpy $G_PLS_FIELD_1 "$G_PLS_FIELD_1${C_NLT}$(PFI_LANG_SUMMARY_NNTP)"

check_smtp:
  !insertmacro PFI_SectionNotSelected ${SecSMTP} check_socks
  StrCpy ${L_TEMP} ""
  StrCpy $G_PLS_FIELD_1 "$G_PLS_FIELD_1${C_NLT}$(PFI_LANG_SUMMARY_SMTP)"

check_socks:
  !insertmacro PFI_SectionNotSelected ${SecSOCKS} check_ssl
  StrCpy ${L_TEMP} ""
  StrCpy $G_PLS_FIELD_1 "$G_PLS_FIELD_1${C_NLT}$(PFI_LANG_SUMMARY_SOCKS)"

check_ssl:
  !insertmacro PFI_SectionNotSelected ${SecSSL} check_xmlrpc
  StrCpy ${L_TEMP} ""
  StrCpy $G_PLS_FIELD_1 "$G_PLS_FIELD_1${C_NLT}$(PFI_LANG_SUMMARY_SSL)"

check_xmlrpc:
  !insertmacro PFI_SectionNotSelected ${SecXMLRPC} end_optional
  StrCpy ${L_TEMP} ""
  StrCpy $G_PLS_FIELD_1 "$G_PLS_FIELD_1${C_NLT}$(PFI_LANG_SUMMARY_XMLRPC)"

end_optional:
  StrCpy $G_PLS_FIELD_1 "$G_PLS_FIELD_1${L_TEMP}${IO_NL}${IO_NL}\
      $(PFI_LANG_SUMMARY_BACKBUTTON)"

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioData.ini" "Field 1" "State" $G_PLS_FIELD_1

  ; Set focus to the button labelled "Install" or "Upgrade" (instead of the "Summary" data)

  !insertmacro MUI_INSTALLOPTIONS_INITDIALOG "ioData.ini"
  Pop ${L_TEMP}
  GetDlgItem $G_DLGITEM $HWNDPARENT 1
  SendMessage $HWNDPARENT ${WM_NEXTDLGCTL} $G_DLGITEM 1
  !insertmacro MUI_INSTALLOPTIONS_SHOW

  Pop ${L_TEMP}

  !undef L_TEMP

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
# Installer Function: CheckSSLOnlyFlag
# (the "pre" function for the COMPONENTS selection page)
#
# If only the SSL Support files are to be installed, disable the other
# POPFile-component sections and skip the COMPONENTS page
#--------------------------------------------------------------------------

Function CheckSSLOnlyFlag

  StrCmp $G_SSL_ONLY "0" exit

  !insertmacro UnselectSection ${SecPOPFile}
  !insertmacro UnselectSection ${SecMinPerl}
  !insertmacro UnselectSection ${SecSkins}
  !insertmacro UnselectSection ${SecLangs}
  !ifndef NO_KAKASI
    !insertmacro UnselectSection ${SecKakasi}
  !endif
  !insertmacro UnselectSection ${SecNNTP}
  !insertmacro UnselectSection ${SecSMTP}
  !insertmacro UnselectSection ${SecXMLRPC}
  !insertmacro UnselectSection ${SecIMAP}
  !insertmacro UnselectSection ${SecSOCKS}

  !insertmacro SelectSection ${SecSSL}

  ; Do not display the COMPONENTS page

  Abort

exit:

  ; Display the COMPONENTS page

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
# Now that we are overriding the default InstallDir behaviour, we really need to check
# that the main 'Program Files' folder has not been selected for the installation.
#
# This function is used to check if a previous POPFile installation exists in the directory
# chosen for this installation's POPFile PROGRAM files (popfile.pl, etc). If we find one,
# we check if it contains any of the optional components and remind the user if it seems that
# they have forgotten to 'upgrade' them.
#--------------------------------------------------------------------------

Function CheckExistingProgDir

  !define L_RESULT  $R9

  Push ${L_RESULT}

  ; Strip trailing slashes (if any) from the path selected by the user

  Push $INSTDIR
  Pop $INSTDIR

  ; We do not permit POPFile to be installed in the target system's 'Program Files' folder
  ; (i.e. we do not allow 'popfile.pl' etc to be stored there)

  StrCmp $INSTDIR "$PROGRAMFILES" return_to_directory_selection

  ; Assume SFN support is enabled (the default setting for Windows)

  StrCpy $G_SFN_DISABLED "0"

  Push $INSTDIR
  Call PFI_GetSFNStatus
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "1" check_SFN_PROGRAMFILES
  StrCpy $G_SFN_DISABLED "1"

  ; Short file names are not supported here, so we cannot accept any path containing spaces.

  Push $INSTDIR
  Push ' '
  Call PFI_StrStr
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "" check_locn
  Push $INSTDIR
  Call PFI_GetRoot
  Pop $G_PLS_FIELD_1
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(PFI_LANG_DIRSELECT_MBNOSFN)"

  ; Return to the POPFile PROGRAM DIRECTORY selection page

return_to_directory_selection:
  Pop ${L_RESULT}
  Abort

check_SFN_PROGRAMFILES:
  GetFullPathName /SHORT ${L_RESULT} "$PROGRAMFILES"
  StrCmp $INSTDIR ${L_RESULT} return_to_directory_selection

check_locn:

  ; Initialise the global user variable used for the POPFile PROGRAM files location
  ; (we always try to use the LFN format, even if the user has entered a SFN format path)

  StrCpy $G_ROOTDIR "$INSTDIR"
  Push $G_ROOTDIR
  Call PFI_GetCompleteFPN
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "" got_path
  StrCpy $G_ROOTDIR ${L_RESULT}

got_path:
  Pop ${L_RESULT}

  ; Warn the user if we are about to upgrade an existing installation
  ; and allow user to select a different directory if they wish

  IfFileExists "$G_ROOTDIR\popfile.pl" warning
  Goto continue

warning:
  MessageBox MB_YESNO|MB_ICONQUESTION "$(PFI_LANG_DIRSELECT_MBWARN_1)\
      ${MB_NL}${MB_NL}\
      $G_ROOTDIR\
      ${MB_NL}${MB_NL}${MB_NL}\
      $(PFI_LANG_DIRSELECT_MBWARN_2)" IDYES check_options

  ; Return to the POPFile PROGRAM DIRECTORY selection page

  Abort

check_options:

  ; If we are only installing the SSL support files, there is no need to check the options

  StrCmp $G_SSL_ONLY "1" continue

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
# Installer Function: InstallUserData
# (the "pre" function for the FINISH page)
#--------------------------------------------------------------------------

Function InstallUserData

  ; If we are only downloading and installing the SSL support files, display the FINISH page

  StrCmp $G_SSL_ONLY "1" exit

  ; For normal installations, skip our own FINISH page and disable the "Add POPFile User"
  ; wizard's language selection dialog to make the wizard appear as an extension of the main
  ; 'setup.exe' installer.
  ; [Future builds may pass more than just a command-line switch to the wizard]

  IfRebootFlag special_case
  Exec '"$G_ROOTDIR\adduser.exe" /install'
  Abort

special_case:
  Exec '"$G_ROOTDIR\adduser.exe" /installreboot'
  Abort

exit:

  ; Display the FINISH page

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


#==========================================================================
#==========================================================================
# The 'Uninstall' part of the script is in a separate file
#==========================================================================
#==========================================================================

  !include "installer-Uninstall.nsh"

#==========================================================================
#==========================================================================


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

      Call PFI_IsNT
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
