#--------------------------------------------------------------------------
#
# installer.nsi --- This is the NSIS script used to create the Windows installer
#                   for POPFile. This script installs the PROGRAM files and creates
#                   some registry entries, then calls the 'Add POPFile User' wizard
#                   (adduser.exe) to install and configure the user data (including
#                   the POPFILE_ROOT and POPFILE_USER environment variables) for the
#                   user running the installer.
#
#                   Requires the following programs (built using NSIS):
#
#                   (1) adduser.exe    (NSIS script: adduser.nsi)
#                   (2) runpopfile.exe (NSIS script: runpopfile.nsi)
#                   (3) stop_pf.exe    (NSIS script: stop_popfile.nsi)
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
# the User Data. At present POPFIle does not work properly if the values in these variables
# contain spaces. As a workaround, we use short file name format to ensure there are no spaces.
# However some systems do not support short file names (using short file names on NTFS systems
# can have a significant impact on performance, for example) and in these cases we insist upon
# paths which do not contain spaces.
#
# This build of the installer is unable to detect every case where short file name support has
# been disabled, so this command-line switch is provided to force the installer to insist upon
# paths which do not contain spaces.  The switch can use uppercase or lowercase.
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
  ; POPFile constants have been given names beginning with 'C_' (eg C_README)
  ;--------------------------------------------------------------------------

  !ifndef C_POPFILE_MAJOR_VERSION
    !error "$\r$\n$\r$\nFatal error: POPFile Major Version parameter not supplied$\r$\n"
  !endif

  !ifndef C_POPFILE_MINOR_VERSION
    !error "$\r$\n$\r$\nFatal error: POPFile Minor Version parameter not supplied$\r$\n"
  !endif

  !ifndef C_POPFILE_REVISION
    !error "$\r$\n$\r$\nFatal error: POPFile Revision parameter not supplied$\r$\n"
  !endif

  !ifndef C_POPFILE_RC
    !error "$\r$\n$\r$\nFatal error: POPFile RC parameter not supplied$\r$\n"
  !endif

  !define C_PFI_PRODUCT  "POPFile"
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

  ;--------------------------------------------------------------------------------
  ; Constants for the timeout loop used by 'WaitUntilUnlocked' and 'un.WaitUntilUnlocked'
  ;--------------------------------------------------------------------------------

  ; Timeout loop counter start value (counts down to 0)

  !define C_SHUTDOWN_LIMIT    20

  ; Delay (in milliseconds) used inside the timeout loop

  !define C_SHUTDOWN_DELAY    1000

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
  Var G_MPBINDIR           ; full path to the folder used for the minimal Perl EXE and DLL files
  Var G_MPLIBDIR           ; full path to the folder used for the rest of the minimal Perl files

  Var G_GUI                ; GUI port (1-65535)

  Var G_STARTUP            ; used to indicate if a banner was shown before the 'WELCOME' page

  Var G_NOTEPAD            ; path to notepad.exe ("" = not found in search path)

  Var G_WINUSERNAME        ; current Windows user login name
  Var G_WINUSERTYPE        ; user group ('Admin', 'Power', 'User', 'Guest' or 'Unknown')

  Var G_SFN_DISABLED       ; 1 = short file names not supported, 0 = short file names available

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

  VIAddVersionKey "ProductName" "${C_PFI_PRODUCT}"
  VIAddVersionKey "Comments" "POPFile Homepage: http://popfile.sf.net"
  VIAddVersionKey "CompanyName" "The POPFile Project"
  VIAddVersionKey "LegalCopyright" "© 2001-2004  John Graham-Cumming"
  VIAddVersionKey "FileDescription" "POPFile Automatic email classification"
  VIAddVersionKey "FileVersion" "${C_PFI_VERSION}"

  !ifndef ENGLISH_MODE
    !ifndef NO_KAKASI
      VIAddVersionKey "Build" "Multi-Language (with Kakasi) multi-user seamless"
    !else
      VIAddVersionKey "Build" "Multi-Language (without Kakasi) multi-user seamless"
    !endif
  !else
    !ifndef NO_KAKASI
      VIAddVersionKey "Build" "English-Mode (with Kakasi) multi-user seamless"
    !else
      VIAddVersionKey "Build" "English-Mode (without Kakasi) multi-user seamless"
    !endif
  !endif

  VIAddVersionKey "Build Date/Time" "${__DATE__} @ ${__TIME__}"
  VIAddVersionKey "Build Script" "${__FILE__}$\r$\n(${__TIMESTAMP__})"

#--------------------------------------------------------------------------
# Include private library functions and macro definitions
#--------------------------------------------------------------------------

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
  !define MUI_HEADERIMAGE_BITMAP              "test\hdr-common-cvs.bmp"
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

  !define MUI_WELCOMEFINISHPAGE_BITMAP        "test\special-cvs.bmp"

  ;----------------------------------------------------------------
  ;  Interface Settings - Installer FINISH Page Interface Settings
  ;----------------------------------------------------------------

  ; Debug aid: Hide the installation log but let user display it (using "Show details" button)

##  !define MUI_FINISHPAGE_NOAUTOCLOSE

  ;----------------------------------------------------------------
  ;  Interface Settings - Abort Warning Settings
  ;----------------------------------------------------------------

  ; Show a message box with a warning when the user closes the installation

  !define MUI_ABORTWARNING

  ;----------------------------------------------------------------
  ; Customize MUI - General Custom Function
  ;----------------------------------------------------------------

  ; Use a custom '.onGUIInit' function to add language-specific texts to custom page INI files

  !define MUI_CUSTOMFUNCTION_GUIINIT          PFIGUIInit

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

  !insertmacro MUI_PAGE_INSTFILES

  ;---------------------------------------------------
  ; Installer Page - FINISH
  ;---------------------------------------------------

  ; Use a "pre" function for the FINISH page to run the 'Add POPFile User' wizard to
  ; configure POPFile for the user running the installer.

  ; For this build we skip our own FINISH page and disable the wizard's language selection
  ; dialog and WELCOME page to make the wizard appear as an extension of the main 'setup.exe'
  ; installer.

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

  OutFile "setup.exe"

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
  FileWrite ${L_OUTPUT_FILE_HANDLE} ${L_TEMP}$\r$\n
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

  !define L_RESERVED            $1    ; used in the system.dll call

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

  StrCpy $G_STARTUP "no banner"

  MessageBox MB_YESNO|MB_ICONQUESTION \
      "$(PFI_LANG_MBRELNOTES_1)\
      $\r$\n$\r$\n\
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

  StrCpy $G_STARTUP "banner displayed"

  Banner::show /NOUNLOAD /set 76 "$(PFI_LANG_OPTIONS_BANNER_1)" "$(PFI_LANG_OPTIONS_BANNER_2)"

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
# Installer Section: POPFile component
#--------------------------------------------------------------------------

Section "POPFile" SecPOPFile

  ; Make this section mandatory (i.e. it is always installed)

  SectionIn RO

  !define L_CFG           $R9   ; file handle
  !define L_POPFILE_ROOT  $R8   ; path to popfile.pl (used in environment variable)
  !define L_POPFILE_USER  $R7   ; path to popfile.cfg (used in environment variable)
  !define L_TEMP          $R6
  !define L_RESERVED      $0    ; reserved for use in system.dll calls

  Push ${L_CFG}
  Push ${L_POPFILE_ROOT}
  Push ${L_POPFILE_USER}
  Push ${L_TEMP}
  Push ${L_RESERVED}

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_UPGRADE)"
  SetDetailsPrint listonly

  ; Before POPFile 0.21.0, POPFile and the minimal Perl shared the same folder structure
  ; and there was only one set of user data (stored in the same folder as POPFile).

  ; Phase 1 of the multi-user support introduced in 0.21.0 requires some slight changes
  ; to the folder structure (to permit POPFile to be run from any folder after setting the
  ; POPFILE_ROOT and POPFILE_USER environment variables to appropriate values).

  ; The folder arrangement used for this build:
  ;
  ; (a) $INSTDIR         -  main POPFile installation folder, holds popfile.pl and several
  ;                         other *.pl scripts, popfile*.exe, popfile*.exe plus three of the
  ;                         minimal Perl files (perl.exe, wperl.exe and perl58.dll)
  ;
  ; (b) $INSTDIR\kakasi  -  holds the Kakasi package used to process Japanese email
  ;                         (only installed when Japanese support is required)
  ;
  ; (c) $INSTDIR\lib     -  minimal Perl installation (except for the three files stored
  ;                         in the $INSTDIR folder to avoid runtime problems)
  ;
  ; (d) $INSTDIR\*       -  the remaining POPFile folders (Classifier, languages, manual, etc)
  ;
  ; For this build, each user is expected to have separate user data folders. By default each
  ; user data folder will contain popfile.cfg, stopwords, stopwords.default, popfile.db,
  ; the messages folder, etc. The 'Add POPFile User' wizard (adduser.exe) is responsible for
  ; creating/updating these user data folders and for handling conversion of existing flat file
  ; or BerkeleyDB corpus files to the new SQL database.
  ;
  ; For increased flexibility, some global user variables are used in addition to $INSTDIR
  ; (this makes it easier to change the folder structure used by the installer).

  StrCpy $G_ROOTDIR   "$INSTDIR"
  StrCpy $G_MPBINDIR  "$INSTDIR"
  StrCpy $G_MPLIBDIR  "$INSTDIR\lib"

  ; If we are installing over a previous version, ensure that version is not running

  Call MakeRootDirSafe

  ; Starting with 0.21.0, a new structure is used for the minimal Perl (to enable POPFile to
  ; be started from any folder, once POPFILE_ROOT and POPFILE_USER have been initialized)

  Call MinPerlRestructure

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
  GetFullPathName /SHORT ${L_TEMP} $G_ROOTDIR

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
  GetFullPathName /SHORT ${L_TEMP} $G_ROOTDIR

save_HKCU_root_sfn:
  WriteRegStr HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_SFN" "${L_TEMP}"

  ; Install the POPFile Core files

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_CORE)"
  SetDetailsPrint listonly

  SetOutPath $G_ROOTDIR

  ; Remove redundant files (from earlier test versions of the installer)

  Delete $G_ROOTDIR\wrapper.exe
  Delete $G_ROOTDIR\wrapperf.exe
  Delete $G_ROOTDIR\wrapperb.exe

  File "..\engine\license"
  File "${C_RELEASE_NOTES}"
  CopyFiles /SILENT /FILESONLY "$PLUGINSDIR\${C_README}.txt" "$G_ROOTDIR\${C_README}.txt"

  File "..\engine\popfile.exe"
  File "..\engine\popfilef.exe"
  File "..\engine\popfileb.exe"
  File "..\engine\popfileif.exe"
  File "..\engine\popfileib.exe"
  File "..\engine\popfile-service.exe"

  File "runpopfile.exe"
  File "stop_pf.exe"
  File "sqlite.exe"
  File "adduser.exe"

  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\stop_pf.exe" \
      "" "$G_ROOTDIR\stop_pf.exe"

  SetOutPath $G_ROOTDIR

  File "..\engine\popfile.pl"
  File "..\engine\insert.pl"
  File "..\engine\bayes.pl"
  File "..\engine\pipe.pl"

  File "..\engine\pix.gif"
  File "..\engine\favicon.ico"
  File "..\engine\black.gif"
  File "..\engine\otto.gif"

  SetOutPath $G_ROOTDIR\Classifier

  File "..\engine\Classifier\Bayes.pm"
  File "..\engine\Classifier\WordMangle.pm"
  File "..\engine\Classifier\MailParse.pm"
  File "..\engine\Classifier\popfile.sql"

  SetOutPath $G_ROOTDIR\Platform
  File "..\engine\Platform\MSWin32.pm"

  SetOutPath $G_ROOTDIR\POPFile
  File "..\engine\POPFile\MQ.pm"
  File "..\engine\POPFile\Loader.pm"
  File "..\engine\POPFile\Logger.pm"
  File "..\engine\POPFile\Module.pm"
  File "..\engine\POPFile\Configuration.pm"
  File "..\engine\POPFile\popfile_version"

  SetOutPath $G_ROOTDIR\Proxy
  File "..\engine\Proxy\Proxy.pm"
  File "..\engine\Proxy\POP3.pm"

  SetOutPath $G_ROOTDIR\UI
  File "..\engine\UI\HTML.pm"
  File "..\engine\UI\HTTP.pm"

  SetOutPath $G_ROOTDIR\manual
  File "..\engine\manual\*.gif"

  SetOutPath $G_ROOTDIR\manual\en
  File "..\engine\manual\en\*.html"

  ; Default UI language

  SetOutPath $G_ROOTDIR\languages
  File "..\engine\languages\English.msg"

  ; Default UI skin (the POPFile UI looks better if a skin is used)

  SetOutPath $G_ROOTDIR\skins
  File "..\engine\skins\SimplyBlue.css"

  ; Install the Minimal Perl files

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_PERL)"
  SetDetailsPrint listonly

  SetOutPath $G_MPBINDIR
  File "${C_PERL_DIR}\bin\perl.exe"
  File "${C_PERL_DIR}\bin\wperl.exe"
  File "${C_PERL_DIR}\bin\perl58.dll"

  SetOutPath $G_MPLIBDIR

  File "${C_PERL_DIR}\lib\AutoLoader.pm"
  File "${C_PERL_DIR}\lib\Carp.pm"
  File "${C_PERL_DIR}\lib\Config.pm"
  File "${C_PERL_DIR}\lib\constant.pm"
  File "${C_PERL_DIR}\lib\DynaLoader.pm"
  File "${C_PERL_DIR}\lib\Errno.pm"
  File "${C_PERL_DIR}\lib\Exporter.pm"
  File "${C_PERL_DIR}\lib\integer.pm"
  File "${C_PERL_DIR}\lib\IO.pm"
  File "${C_PERL_DIR}\lib\lib.pm"
  File "${C_PERL_DIR}\lib\locale.pm"
  File "${C_PERL_DIR}\lib\POSIX.pm"
  File "${C_PERL_DIR}\lib\SelectSaver.pm"
  File "${C_PERL_DIR}\lib\Socket.pm"
  File "${C_PERL_DIR}\lib\strict.pm"
  File "${C_PERL_DIR}\lib\Symbol.pm"
  File "${C_PERL_DIR}\lib\vars.pm"
  File "${C_PERL_DIR}\lib\warnings.pm"
  File "${C_PERL_DIR}\lib\XSLoader.pm"

  SetOutPath $G_MPLIBDIR\Carp
  File "${C_PERL_DIR}\lib\Carp\*"

  SetOutPath $G_MPLIBDIR\Digest
  File "${C_PERL_DIR}\lib\Digest\MD5.pm"

  SetOutPath $G_MPLIBDIR\Exporter
  File "${C_PERL_DIR}\lib\Exporter\*"

  SetOutPath $G_MPLIBDIR\File
  File "${C_PERL_DIR}\lib\File\Glob.pm"

  SetOutPath $G_MPLIBDIR\Getopt
  File "${C_PERL_DIR}\lib\Getopt\Long.pm"

  SetOutPath $G_MPLIBDIR\HTML
  File "${C_PERL_DIR}\site\lib\HTML\Tagset.pm"

  SetOutPath $G_MPLIBDIR\IO
  File "${C_PERL_DIR}\lib\IO\*"

  SetOutPath $G_MPLIBDIR\IO\Socket
  File "${C_PERL_DIR}\lib\IO\Socket\*"

  SetOutPath $G_MPLIBDIR\MIME
  File "${C_PERL_DIR}\lib\MIME\*"

  SetOutPath $G_MPLIBDIR\Sys
  File "${C_PERL_DIR}\lib\Sys\*"

  SetOutPath $G_MPLIBDIR\Text
  File "${C_PERL_DIR}\lib\Text\ParseWords.pm"

  SetOutPath $G_MPLIBDIR\warnings
  File "${C_PERL_DIR}\lib\warnings\register.pm"

  SetOutPath $G_MPLIBDIR\auto\Digest\MD5
  File "${C_PERL_DIR}\lib\auto\Digest\MD5\*"

  SetOutPath $G_MPLIBDIR\auto\DynaLoader
  File "${C_PERL_DIR}\lib\auto\DynaLoader\*"

  SetOutPath $G_MPLIBDIR\auto\File\Glob
  File "${C_PERL_DIR}\lib\auto\File\Glob\*"

  SetOutPath $G_MPLIBDIR\auto\IO
  File "${C_PERL_DIR}\lib\auto\IO\*"

  SetOutPath $G_MPLIBDIR\auto\MIME\Base64
  File "${C_PERL_DIR}\lib\auto\MIME\Base64\*"

  SetOutPath $G_MPLIBDIR\auto\POSIX
  File "${C_PERL_DIR}\lib\auto\POSIX\POSIX.dll"
  File "${C_PERL_DIR}\lib\auto\POSIX\autosplit.ix"
  File "${C_PERL_DIR}\lib\auto\POSIX\load_imports.al"

  SetOutPath $G_MPLIBDIR\auto\Socket
  File "${C_PERL_DIR}\lib\auto\Socket\*"

  SetOutPath $G_MPLIBDIR\auto\Sys\Hostname
  File "${C_PERL_DIR}\lib\auto\Sys\Hostname\*"

  ; Install Perl modules and library files for BerkeleyDB support
  ; (required in case we have to convert BerkeleyDB corpus files from an earlier version)

  SetOutPath $G_MPLIBDIR
  File "${C_PERL_DIR}\site\lib\BerkeleyDB.pm"
  File "${C_PERL_DIR}\lib\UNIVERSAL.pm"

  SetOutPath $G_MPLIBDIR\auto\BerkeleyDB
  File "${C_PERL_DIR}\site\lib\auto\BerkeleyDB\autosplit.ix"
  File "${C_PERL_DIR}\site\lib\auto\BerkeleyDB\BerkeleyDB.bs"
  File "${C_PERL_DIR}\site\lib\auto\BerkeleyDB\BerkeleyDB.dll"
  File "${C_PERL_DIR}\site\lib\auto\BerkeleyDB\BerkeleyDB.exp"
  File "${C_PERL_DIR}\site\lib\auto\BerkeleyDB\BerkeleyDB.lib"

  ; Install Perl modules and library files for SQLite support

  SetOutPath $G_MPLIBDIR
  File "${C_PERL_DIR}\lib\base.pm"
  File "${C_PERL_DIR}\lib\overload.pm"
  File "${C_PERL_DIR}\site\lib\DBI.pm"

  SetOutPath $G_MPLIBDIR\auto\DBD\SQLite
  File "${C_PERL_DIR}\site\lib\auto\DBD\SQLite\SQLite.bs"
  File "${C_PERL_DIR}\site\lib\auto\DBD\SQLite\SQLite.dll"
  File "${C_PERL_DIR}\site\lib\auto\DBD\SQLite\SQLite.exp"
  File "${C_PERL_DIR}\site\lib\auto\DBD\SQLite\SQLite.lib"

  SetOutPath $G_MPLIBDIR\auto\DBI
  File "${C_PERL_DIR}\site\lib\auto\DBI\DBI.bs"
  File "${C_PERL_DIR}\site\lib\auto\DBI\DBI.dll"
  File "${C_PERL_DIR}\site\lib\auto\DBI\DBI.exp"
  File "${C_PERL_DIR}\site\lib\auto\DBI\DBI.lib"

  SetOutPath $G_MPLIBDIR\DBD
  File "${C_PERL_DIR}\site\lib\DBD\SQLite.pm"

  ; Create the uninstall program BEFORE creating the shortcut to it
  ; (this ensures that the correct "uninstall" icon appears in the START MENU shortcut)

  SetOutPath $INSTDIR
  Delete $INSTDIR\uninstall.exe
  WriteUninstaller $INSTDIR\uninstall.exe

  ; Attempt to remove StartUp shortcuts created during previous installations

  SetShellVarContext all
  Delete "$SMSTARTUP\Run POPFile.lnk"

  SetShellVarContext current
  Delete "$SMSTARTUP\Run POPFile.lnk"

  ; Create the START MENU entries

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_SHORT)"
  SetDetailsPrint listonly

  ; 'CreateShortCut' uses '$OUTDIR' as the working directory for the shortcut
  ; ('SetOutPath' is one way to change the value of $OUTDIR)

  ; If the user has 'Admin' rights, create a 'POPFile' folder with a set of shortcuts in
  ; the 'All Users' Start Menu . If the user does not have 'Admin' rights, the shortcuts
  ; are created in the 'Current User' Start Menu.

  ; If the 'All Users' folder is not found, NSIS will return the 'Current User' folder.

  SetShellVarContext all
  StrCmp $G_WINUSERTYPE "Admin" create_shortcuts
  SetShellVarContext current

create_shortcuts:
  SetOutPath "$SMPROGRAMS\${C_PFI_PRODUCT}"
  SetOutPath $INSTDIR
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Run POPFile.lnk" \
                 "$INSTDIR\runpopfile.exe"
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Uninstall POPFile.lnk" \
                 "$INSTDIR\uninstall.exe"

  SetOutPath $G_ROOTDIR
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Release Notes.lnk" \
                 "$G_ROOTDIR\${C_README}.txt"

  SetOutPath "$SMPROGRAMS\${C_PFI_PRODUCT}"
  WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\POPFile User Interface.url" \
              "InternetShortcut" "URL" "http://127.0.0.1:$G_GUI/"
  WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\Shutdown POPFile.url" \
              "InternetShortcut" "URL" "http://127.0.0.1:$G_GUI/shutdown"
  WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\Manual.url" \
              "InternetShortcut" "URL" "file://$G_ROOTDIR/manual/en/manual.html"

  StrCmp $LANGUAGE ${LANG_JAPANESE} japanese_faq
  WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\FAQ.url" \
              "InternetShortcut" "URL" \
              "http://popfile.sourceforge.net/cgi-bin/wiki.pl?FrequentlyAskedQuestions"
  Goto support

japanese_faq:
  WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\FAQ.url" \
              "InternetShortcut" "URL" \
              "http://popfile.sourceforge.net/cgi-bin/wiki.pl?JP_FrequentlyAskedQuestions"

support:
  SetOutPath "$SMPROGRAMS\${C_PFI_PRODUCT}\Support"
  WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\POPFile Home Page.url" \
              "InternetShortcut" "URL" "http://popfile.sourceforge.net/"

  SetOutPath $G_ROOTDIR
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Shutdown POPFile silently.lnk" \
                 "$G_ROOTDIR\stop_pf.exe" "/showerrors $G_GUI"

  ; Remove redundant links (used by earlier versions of POPFile)

  SetShellVarContext all

  Delete "$SMSTARTUP\Run POPFile in background.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Run POPFile in background.lnk"

  SetShellVarContext current

  Delete "$SMSTARTUP\Run POPFile in background.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Run POPFile in background.lnk"

  ; Create entry in the Control Panel's "Add/Remove Programs" list

  StrCmp $G_WINUSERTYPE "Admin" use_HKLM

  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "DisplayName" "${C_PFI_PRODUCT} ${C_PFI_VERSION}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "NoModify" "1"
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "NoRepair" "1"
  Goto end_section

use_HKLM:
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "DisplayName" "${C_PFI_PRODUCT} ${C_PFI_VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "NoModify" "1"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "NoRepair" "1"

end_section:
  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_ENDSEC)"
  SetDetailsPrint listonly

  Pop ${L_RESERVED}
  Pop ${L_TEMP}
  Pop ${L_POPFILE_USER}
  Pop ${L_POPFILE_ROOT}
  Pop ${L_CFG}

  !undef L_CFG
  !undef L_POPFILE_ROOT
  !undef L_POPFILE_USER
  !undef L_TEMP
  !undef L_RESERVED

SectionEnd

#--------------------------------------------------------------------------
# Installer Section: (optional) Skins component (default = selected)
#
# Installs additional skins to allow the look-and-feel of the User Interface
# to be changed. The 'SimplyBlue' skin is always installed (by the 'POPFile'
# section) since this is the default skin for POPFile.
#--------------------------------------------------------------------------

Section "Skins" SecSkins

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_SKINS)"
  SetDetailsPrint listonly

  SetOutPath $G_ROOTDIR\skins
  File "..\engine\skins\*.css"
  File "..\engine\skins\*.gif"

  SetOutPath $G_ROOTDIR\skins\lavishImages
  File "..\engine\skins\lavishImages\*.gif"

  SetOutPath $G_ROOTDIR\skins\sleetImages
  File "..\engine\skins\sleetImages\*.gif"

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

  SetOutPath $G_ROOTDIR\languages
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

      SetOutPath $INSTDIR
      File /r "${C_KAKASI_DIR}\kakasi"

      ; Add Environment Variables for Kakasi

      Push ITAIJIDICTPATH
      Push $INSTDIR\kakasi\share\kakasi\itaijidict

      StrCmp $G_WINUSERTYPE "Admin" all_users_1
      Call WriteEnvStr
      Goto next_var

    all_users_1:
      Call WriteEnvStrNTAU

    next_var:
      Push KANWADICTPATH
      Push $INSTDIR\kakasi\share\kakasi\kanwadict

      StrCmp $G_WINUSERTYPE "Admin" all_users_2
      Call WriteEnvStr
      Goto set_env

    all_users_2:
      Call WriteEnvStrNTAU

    set_env:
      IfRebootFlag save_data

      ; Running on a non-Win9x system which already has the correct Kakaksi environment data
      ; or running on a non-Win9x system

      Call IsNT
      Pop ${L_RESERVED}
      StrCmp ${L_RESERVED} "0" continue

      ; Running on a non-Win9x system so we ensure the Kakasi environment variables
      ; are updated to match this installation

      System::Call 'Kernel32::SetEnvironmentVariableA(t, t) \
                    i("ITAIJIDICTPATH", "$INSTDIR\kakasi\share\kakasi\itaijidict").r0'
      StrCmp ${L_RESERVED} 0 0 itaiji_set_ok
      MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_ENVNOTSET) (ITAIJIDICTPATH)"

    itaiji_set_ok:
      System::Call 'Kernel32::SetEnvironmentVariableA(t, t) \
                    i("KANWADICTPATH", "$INSTDIR\kakasi\share\kakasi\kanwadict").r0'
      StrCmp ${L_RESERVED} 0 0 continue
      MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_ENVNOTSET) (KANWADICTPATH)"

    save_data:

      ; Save installation-specific data for use by the 'Corpus Conversion' utility
      ; if we are running on a Win9x system and require a reboot to install Kakasi properly.

      WriteINIStr "$PLUGINSDIR\corpus.ini" "Settings" "KReboot" "yes"
      WriteINIStr "$PLUGINSDIR\corpus.ini" "Settings" \
                          "ITAIJIDICTPATH" "$INSTDIR\kakasi\share\kakasi\itaijidict"
      WriteINIStr "$PLUGINSDIR\corpus.ini" "Settings" \
                          "KANWADICTPATH"  "$INSTDIR\kakasi\share\kakasi\kanwadict"

    continue:

      ;--------------------------------------------------------------------------
      ; Install Perl modules: base.pm, bytes.pm the Encode collection and Text::Kakasi
      ;--------------------------------------------------------------------------

      SetOutPath $G_MPLIBDIR
      File "${C_PERL_DIR}\lib\base.pm"
      File "${C_PERL_DIR}\lib\bytes.pm"
      File "${C_PERL_DIR}\lib\Encode.pm"

      SetOutPath $G_MPLIBDIR\Encode
      File /r "${C_PERL_DIR}\lib\Encode\*"

      SetOutPath $G_MPLIBDIR\auto\Encode
      File /r "${C_PERL_DIR}\lib\auto\Encode\*"

      SetOutPath $G_MPLIBDIR\Text
      File "${C_PERL_DIR}\site\lib\Text\Kakasi.pm"

      SetOutPath $G_MPLIBDIR\auto\Text\Kakasi
      File "${C_PERL_DIR}\site\lib\auto\Text\Kakasi\*"

      Pop ${L_RESERVED}

      !undef L_RESERVED

    SectionEnd
!endif

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

  SetOutPath $G_ROOTDIR\UI
  File "..\engine\UI\XMLRPC.pm"

  ; POPFile API component used by XMLRPC.pm

  SetOutPath $G_ROOTDIR\POPFile
  File "..\engine\POPFile\API.pm"

  ; Perl modules required to support the POPFile XMLRPC component

  SetOutPath $G_MPLIBDIR
  File "${C_PERL_DIR}\site\lib\LWP.pm"
  File "${C_PERL_DIR}\lib\re.pm"
  File "${C_PERL_DIR}\site\lib\URI.pm"

  SetOutPath $G_MPLIBDIR\HTTP
  File /r "${C_PERL_DIR}\site\lib\HTTP\*"

  SetOutPath $G_MPLIBDIR\LWP
  File /r "${C_PERL_DIR}\site\lib\LWP\*"

  SetOutPath $G_MPLIBDIR\Net
  File /r "${C_PERL_DIR}\site\lib\Net\*"

  SetOutPath $G_MPLIBDIR\SOAP
  File /r "${C_PERL_DIR}\site\lib\SOAP\*"

  SetOutPath $G_MPLIBDIR\Time
  File /r "${C_PERL_DIR}\lib\Time\*"

  SetOutPath $G_MPLIBDIR\URI
  File /r "${C_PERL_DIR}\site\lib\URI\*"

  SetOutPath $G_MPLIBDIR\XML
  File /r "${C_PERL_DIR}\site\lib\XML\*"

  SetOutPath $G_MPLIBDIR\XMLRPC
  File /r "${C_PERL_DIR}\site\lib\XMLRPC\*"

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
    !insertmacro MUI_DESCRIPTION_TEXT ${SecPOPFile} $(DESC_SecPOPFile)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecSkins}   $(DESC_SecSkins)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecLangs}   $(DESC_SecLangs)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecXMLRPC}  $(DESC_SecXMLRPC)
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
      "$(PFI_LANG_PERLREQ_IO_TEXT_5) ${L_VERSION}\r\n\r\n\
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
      \r\n\r\n\
      $(PFI_LANG_WELCOME_ADMIN_TEXT)"

exit:
  Pop ${L_WELCOME_TEXT}

  StrCmp $G_STARTUP "no banner" no_banner

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

  Push ${L_CFG}
  Push ${L_EXE}
  Push ${L_LINE}
  Push ${L_NEW_GUI}
  Push ${L_OLD_GUI}
  Push ${L_PARAM}
  Push ${L_RESULT}

  ; If we are about to overwrite an existing version which is still running,
  ; then one of the EXE files will be 'locked' which means we have to shutdown POPFile.
  ;
  ; POPFile v0.20.0 and later may be using 'popfileb.exe', 'popfilef.exe', 'popfileib.exe',
  ; 'popfileif.exe', 'perl.exe' or 'wperl.exe'.
  ;
  ; Earlier versions of POPFile use only 'perl.exe' or 'wperl.exe'.
  ;
  ; Starting with POPfile 0.21.0 an experimental version of 'popfile-service.exe' was included
  ; to allow POPFile to be run as a Windows service. So we also need to check if POPFile is
  ; running as a service. [NB: Service detection/shutdown is _not_ implemented in this build]

  DetailPrint "Checking '$G_ROOTDIR\popfileb.exe' ..."

  Push "$G_ROOTDIR\popfileb.exe"
  Call CheckIfLocked
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" 0 attempt_shutdown

  DetailPrint "Checking '$G_ROOTDIR\popfileib.exe' ..."

  Push "$G_ROOTDIR\popfileib.exe"
  Call CheckIfLocked
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" 0 attempt_shutdown

  DetailPrint "Checking '$G_ROOTDIR\popfilef.exe' ..."

  Push "$G_ROOTDIR\popfilef.exe"
  Call CheckIfLocked
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" 0 attempt_shutdown

  DetailPrint "Checking '$G_ROOTDIR\popfileif.exe' ..."

  Push "$G_ROOTDIR\popfileif.exe"
  Call CheckIfLocked
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" 0 attempt_shutdown

  DetailPrint "Checking '$G_MPBINDIR\wperl.exe' ..."

  Push "$G_MPBINDIR\wperl.exe"
  Call CheckIfLocked
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" 0 attempt_shutdown

  DetailPrint "Checking '$G_MPBINDIR\perl.exe' ..."

  Push "$G_MPBINDIR\perl.exe"
  Call CheckIfLocked
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" exit_now

attempt_shutdown:
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

  ClearErrors
  FileOpen  ${L_CFG} "${L_CFG}\popfile.cfg" r

loop:
  FileRead   ${L_CFG} ${L_LINE}
  IfErrors done

  StrCpy ${L_PARAM} ${L_LINE} 10
  StrCmp ${L_PARAM} "html_port " got_html_port

  StrCpy ${L_PARAM} ${L_LINE} 8
  StrCmp ${L_PARAM} "ui_port " got_ui_port
  Goto loop

got_ui_port:
  StrCpy ${L_OLD_GUI} ${L_LINE} 5 8
  Goto loop

got_html_port:
  StrCpy ${L_NEW_GUI} ${L_LINE} 5 10
  Goto loop

done:
  FileClose ${L_CFG}

  Push ${L_NEW_GUI}
  Call TrimNewlines
  Pop ${L_NEW_GUI}

  Push ${L_OLD_GUI}
  Call TrimNewlines
  Pop ${L_OLD_GUI}

  StrCmp ${L_NEW_GUI} "" try_old_style
  DetailPrint "$(PFI_LANG_INST_LOG_1) ${L_NEW_GUI} [new style port]"
  Push ${L_NEW_GUI}
  Call ShutdownViaUI
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "success" check_exe
  StrCmp ${L_RESULT} "password?" manual_shutdown

try_old_style:
  StrCmp ${L_OLD_GUI} "" manual_shutdown
  DetailPrint "$(PFI_LANG_INST_LOG_1) ${L_OLD_GUI} [old style port]"
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
  StrCmp ${L_EXE} "" unlocked_exit

manual_shutdown:
  DetailPrint "Unable to shutdown automatically - manual intervention requested"
  MessageBox MB_OK|MB_ICONEXCLAMATION|MB_TOPMOST "$(PFI_LANG_MBMANSHUT_1)\
      $\r$\n$\r$\n\
      $(PFI_LANG_MBMANSHUT_2)\
      $\r$\n$\r$\n\
      $(PFI_LANG_MBMANSHUT_3)"
  Goto exit_now

unlocked_exit:
  DetailPrint "File is now unlocked"

exit_now:
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

!macro MinPerlMove SUBFOLDER

  !insertmacro PFI_UNIQUE_ID

  IfFileExists "$INSTDIR\${SUBFOLDER}\*.*" 0 skip_${PFI_UNIQUE_ID}
  Rename "$INSTDIR\${SUBFOLDER}" "$G_MPLIBDIR\${SUBFOLDER}"

skip_${PFI_UNIQUE_ID}:

!macroend

Function MinPerlRestructure

  IfFileExists "$G_MPLIBDIR\*.pm" exit

  CreateDirectory $G_MPLIBDIR

  CopyFiles /SILENT /FILESONLY "$INSTDIR\*.pm" "$G_MPLIBDIR\"
  Delete "$INSTDIR\*.pm"

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
      $\r$\n$\r$\n\
      Please select a folder location which does not contain spaces"

  ; Return to the POPFile PROGRAM DIRECTORY selection page

  Pop ${L_RESULT}
  Abort

no_spaces:
  Pop ${L_RESULT}

check_locn:

  ; Initialise the global user variable used for the POPFile PROGRAM files location

  StrCpy $G_ROOTDIR $INSTDIR

  ; Warn the user if we are about to upgrade an existing installation
  ; and allow user to select a different directory if they wish

  IfFileExists "$G_ROOTDIR\popfile.pl" warning
  Goto continue

warning:
  MessageBox MB_YESNO|MB_ICONQUESTION "$(PFI_LANG_DIRSELECT_MBWARN_1)\
      $\r$\n$\r$\n\
      $INSTDIR\
      $\r$\n$\r$\n$\r$\n\
      $(PFI_LANG_DIRSELECT_MBWARN_2)" IDYES continue

  ; Return to the POPFile PROGRAM DIRECTORY selection page

  Abort

continue:

  ; Move on to the next page in the installer

  !undef L_RESULT

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: InstallUserData
# (the "pre" function for the FINISH page)
#--------------------------------------------------------------------------

Function InstallUserData

  Call GetParameters
  Pop $G_STARTUP
  StrCmp $G_STARTUP "/nouser" continue

  ; For this build we skip our own FINISH page and disable the wizard's language selection
  ; dialog and WELCOME page to make the wizard appear as an extension of the main 'setup.exe'
  ; installer. [Future builds may pass more than just a command-line switch to the wizard]

  Exec '"$G_ROOTDIR\adduser.exe" /install'
  Abort

continue:
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

#--------------------------------------------------------------------------
# Initialise the uninstaller
#--------------------------------------------------------------------------

Function un.onInit

  ; Retrieve the language used when this version was installed, and use it for the uninstaller

  !insertmacro MUI_UNGETLANGUAGE

  StrCpy $G_ROOTDIR   "$INSTDIR"
  StrCpy $G_MPBINDIR  "$INSTDIR"
  StrCpy $G_MPLIBDIR  "$INSTDIR\lib"

  ReadRegStr $G_USERDIR HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "UserDataPath"
  StrCmp $G_USERDIR "" 0 got_user_path

  StrCpy $G_USERDIR "$INSTDIR\user"

  ; If we are uninstalling an upgraded installation, the default user data may be in $INSTDIR
  ; instead of $INSTDIR\user

  IfFileExists "$G_USERDIR\popfile.cfg" got_user_path
  StrCpy $G_USERDIR   "$INSTDIR"

got_user_path:

  ; Email settings are stored on a 'per user' basis therefore we need to know which user is
  ; running the uninstaller so we can check if the email settings can be safely restored

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
# Uninstaller Section
#--------------------------------------------------------------------------

Section "Uninstall"

  !define L_CFG         $R9   ; used as file handle
  !define L_EXE         $R8   ; full path of the EXE to be monitored
  !define L_LNE         $R7   ; a line from popfile.cfg
  !define L_TEMP        $R6

  Push ${L_CFG}
  Push ${L_EXE}
  Push ${L_LNE}
  Push ${L_TEMP}

  ReadINIStr ${L_TEMP} "$G_USERDIR\install.ini" "Settings" "Owner"
  StrCmp ${L_TEMP} "" look_for_popfile
  StrCmp ${L_TEMP} $G_WINUSERNAME look_for_popfile
  MessageBox MB_YESNO|MB_ICONSTOP|MB_DEFBUTTON2 \
      "$(PFI_LANG_UN_MBDIFFUSER_1) ('${L_TEMP}') !\
      $\r$\n$\r$\n\
      $(PFI_LANG_UN_MBNOTFOUND_2)" IDYES look_for_popfile
  Abort "$(PFI_LANG_UN_ABORT_1)"

look_for_popfile:
  IfFileExists $G_ROOTDIR\popfile.pl look_for_uninstalluser
  IfFileExists $G_ROOTDIR\popfile.exe look_for_uninstalluser
    MessageBox MB_YESNO|MB_ICONSTOP|MB_DEFBUTTON2 \
        "$(PFI_LANG_UN_MBNOTFOUND_1) '$G_ROOTDIR'.\
        $\r$\n$\r$\n\
        $(PFI_LANG_UN_MBNOTFOUND_2)" IDYES look_for_uninstalluser
    Abort "$(PFI_LANG_UN_ABORT_1)"

look_for_uninstalluser:
  IfFileExists "$G_ROOTDIR\uninstalluser.exe" 0 uninstall_popfile

  ; Uninstall the 'User Data' in the PROGRAM folder before uninstalling the PROGRAM files

  HideWindow
  ExecWait '"$G_ROOTDIR\uninstalluser.exe" _?=$G_ROOTDIR'
  BringToFront

  ; If any email settings have NOT been restored and the user wishes to try again later,
  ; the relevant INI file will still exist and we should not remove it or uninstalluser.exe

  IfFileExists "$G_ROOTDIR\pfi-outexpress.ini" uninstall_popfile
  IfFileExists "$G_ROOTDIR\pfi-outlook.ini" uninstall_popfile
  IfFileExists "$G_ROOTDIR\pfi-eudora.ini" uninstall_popfile
  Delete "$G_ROOTDIR\uninstalluser.exe"

uninstall_popfile:
  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROGRESS_1)"
  SetDetailsPrint listonly

  ; If the POPFile we are to uninstall is still running, one of the EXE files will be 'locked'

  ; Starting with POPfile 0.21.0 an experimental version of 'popfile-service.exe' was included
  ; to allow POPFile to be run as a Windows service. So we also need to check if POPFile is
  ; running as a service. [NB: Service detection/shutdown is _not_ implemented in this build]

  Push "$G_ROOTDIR\popfileb.exe"
  Call un.CheckIfLocked
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" 0 attempt_shutdown

  Push "$G_ROOTDIR\popfileib.exe"
  Call un.CheckIfLocked
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" 0 attempt_shutdown

  Push "$G_ROOTDIR\popfilef.exe"
  Call un.CheckIfLocked
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" 0 attempt_shutdown

  Push "$G_ROOTDIR\popfileif.exe"
  Call un.CheckIfLocked
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" 0 attempt_shutdown

  Push "$G_MPBINDIR\wperl.exe"
  Call un.CheckIfLocked
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" 0 attempt_shutdown

  Push "$G_MPBINDIR\perl.exe"
  Call un.CheckIfLocked
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" remove_shortcuts

attempt_shutdown:
  StrCpy $G_GUI ""

  ClearErrors
  FileOpen ${L_CFG} "$G_USERDIR\popfile.cfg" r

loop:
  FileRead ${L_CFG} ${L_LNE}
  IfErrors ui_port_done

  StrCpy ${L_TEMP} ${L_LNE} 10
  StrCmp ${L_TEMP} "html_port " got_html_port
  Goto loop

got_html_port:
  StrCpy $G_GUI ${L_LNE} 5 10
  Goto loop

ui_port_done:
  FileClose ${L_CFG}

  StrCmp $G_GUI "" manual_shutdown
  Push $G_GUI
  Call un.TrimNewlines
  Call un.StrCheckDecimal
  Pop $G_GUI
  StrCmp $G_GUI "" manual_shutdown
  DetailPrint "$(PFI_LANG_UN_LOG_1) $G_GUI"
  Push $G_GUI
  Call un.ShutdownViaUI
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "success" remove_shortcuts

manual_shutdown:
  DetailPrint "Unable to shutdown automatically - manual intervention requested"
  MessageBox MB_OK|MB_ICONEXCLAMATION|MB_TOPMOST "$(PFI_LANG_MBMANSHUT_1)\
      $\r$\n$\r$\n\
      $(PFI_LANG_MBMANSHUT_2)\
      $\r$\n$\r$\n\
      $(PFI_LANG_MBMANSHUT_3)"

remove_shortcuts:
  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROGRESS_2)"
  SetDetailsPrint listonly

  SetShellVarContext all
  StrCmp $G_WINUSERTYPE "Admin" menucleanup
  SetShellVarContext current

menucleanup:
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\POPFile Home Page.url"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\POPFile Manual.url"
  RMDir "$SMPROGRAMS\${C_PFI_PRODUCT}\Support"

  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Release Notes.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Run POPFile.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Run POPFile in background.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Shutdown POPFile silently.lnk"

  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\FAQ.url"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Manual.url"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\POPFile User Interface.url"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Shutdown POPFile.url"

  Delete "$SMSTARTUP\Run POPFile in background.lnk"
  Delete "$SMSTARTUP\Run POPFile.lnk"

  SetShellVarContext current

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROGRESS_3)"
  SetDetailsPrint listonly

  Delete $INSTDIR\wrapper.exe
  Delete $INSTDIR\wrapperf.exe
  Delete $INSTDIR\wrapperb.exe
  Delete $INSTDIR\wrapper.ini

  Delete $G_ROOTDIR\runpopfile.exe
  Delete $G_ROOTDIR\adduser.exe
  Delete $G_ROOTDIR\sqlite.exe

  Delete $G_ROOTDIR\*.gif
  Delete $G_ROOTDIR\*.change
  Delete $G_ROOTDIR\*.change.txt

  Delete $G_ROOTDIR\popfile.pl
  Delete $G_ROOTDIR\*.pm

  Delete $G_ROOTDIR\bayes.pl
  Delete $G_ROOTDIR\insert.pl
  Delete $G_ROOTDIR\pipe.pl
  Delete $G_ROOTDIR\favicon.ico
  Delete $G_ROOTDIR\popfile.exe
  Delete $G_ROOTDIR\popfilef.exe
  Delete $G_ROOTDIR\popfileb.exe
  Delete $G_ROOTDIR\popfileif.exe
  Delete $G_ROOTDIR\popfileib.exe
  Delete $G_ROOTDIR\popfile-service.exe
  Delete $G_ROOTDIR\stop_pf.exe
  Delete $G_ROOTDIR\license

  Delete $G_ROOTDIR\Classifier\*.pm
  Delete $G_ROOTDIR\Classifier\popfile.sql
  RMDir $G_ROOTDIR\Classifier

  Delete $G_ROOTDIR\Platform\*.pm
  Delete $G_ROOTDIR\Platform\*.dll
  RMDir $G_ROOTDIR\Platform

  Delete $G_ROOTDIR\POPFile\*.pm
  Delete $G_ROOTDIR\POPFile\popfile_version
  RMDir $G_ROOTDIR\POPFile

  Delete $G_ROOTDIR\Proxy\*.pm
  RMDir $G_ROOTDIR\Proxy

  Delete $G_ROOTDIR\UI\*.pm
  RMDir $G_ROOTDIR\UI

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROGRESS_5)"
  SetDetailsPrint listonly

  Delete $G_MPBINDIR\*.dll
  Delete $G_MPBINDIR\perl.exe
  Delete $G_MPBINDIR\wperl.exe
  RMDir $G_MPBINDIR

  Delete $G_ROOTDIR\skins\*.css
  Delete $G_ROOTDIR\skins\*.gif
  Delete $G_ROOTDIR\skins\lavishImages\*.gif
  Delete $G_ROOTDIR\skins\sleetImages\*.gif
  RMDir $G_ROOTDIR\skins\sleetImages
  RMDir $G_ROOTDIR\skins\lavishImages
  RMDir $G_ROOTDIR\skins

  Delete $G_ROOTDIR\manual\en\*.html
  RMDir $G_ROOTDIR\manual\en
  Delete $G_ROOTDIR\manual\*.gif
  RMDir $G_ROOTDIR\manual

  Delete $G_ROOTDIR\languages\*.msg
  RMDir $G_ROOTDIR\languages

  IfFIleExists "$INSTDIR\kakasi\*.*" 0 skip_kakasi
  RMDir /r "$INSTDIR\kakasi"

  ;Delete Environment Variables

  Push KANWADICTPATH
  Call un.DeleteEnvStr
  Push ITAIJIDICTPATH
  Call un.DeleteEnvStr

  ; If the 'all users' environment variables refer to this installation, remove them too

  ReadEnvStr ${L_TEMP} "KANWADICTPATH"
  Push ${L_TEMP}
  Push $INSTDIR
  Call un.StrStr
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" skip_kakasi
  Push KANWADICTPATH
  Call un.DeleteEnvStrNTAU
  Push ITAIJIDICTPATH
  Call un.DeleteEnvStrNTAU

skip_kakasi:
  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROGRESS_6)"
  SetDetailsPrint listonly

  IfFileExists "$G_MPLIBDIR\HTTP\*.*" 0 skip_XMLRPC_support
  RMDir /r "$G_MPLIBDIR\HTTP"
  RMDir /r "$G_MPLIBDIR\LWP"
  RMDir /r "$G_MPLIBDIR\Net"
  RMDir /r "$G_MPLIBDIR\SOAP"
  RMDir /r "$G_MPLIBDIR\Time"
  RMDir /r "$G_MPLIBDIR\URI"
  RMDir /r "$G_MPLIBDIR\XML"
  RMDir /r "$G_MPLIBDIR\XMLRPC"

skip_XMLRPC_support:
  RMDir /r "$G_MPLIBDIR\auto"
  RMDir /r "$G_MPLIBDIR\Carp"
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
  RMDir /r "$G_MPLIBDIR\warnings"
  IfFileExists "$G_MPLIBDIR\Win32\*.*" 0 skip_Win32
  RMDir /r "$G_MPLIBDIR\Win32"

skip_Win32:
  Delete "$G_MPLIBDIR\*.pm"
  RMDIR $G_MPLIBDIR

  StrCmp $G_WINUSERTYPE "Admin" 0 tidymenu
  SetShellVarContext all

tidymenu:
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Uninstall POPFile.lnk"
  RMDir "$SMPROGRAMS\${C_PFI_PRODUCT}"

  SetShellVarContext current

  Delete "$INSTDIR\Uninstall.exe"

  RMDir $G_ROOTDIR
  RMDir $INSTDIR

  ; Clean up registry data

  StrCmp $G_WINUSERTYPE "Admin" 0 final_check
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}"
  DeleteRegKey HKLM "Software\POPFile Project\${C_PFI_PRODUCT}\MRI"
  DeleteRegKey /ifempty HKLM "Software\POPFile Project\${C_PFI_PRODUCT}"
  DeleteRegKey /ifempty HKLM "Software\POPFile Project"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\stop_pf.exe"

final_check:

  ; if $INSTDIR was removed, skip these next ones

  IfFileExists "$INSTDIR\*.*" 0 exit

  ; If 'User Data' uninstaller still exists, we cannot offer to remove the remaining files
  ; (some email settings have not been restored and the user wants to try again later)

  IfFileExists "$G_ROOTDIR\uninstalluser.exe" exit

  MessageBox MB_YESNO|MB_ICONQUESTION "$(PFI_LANG_UN_MBREMDIR_1)" IDNO exit
  DetailPrint "$(PFI_LANG_UN_LOG_5)"
  Delete "$INSTDIR\*.*"
  RMDir /r $INSTDIR
  IfFileExists "$INSTDIR\*.*" 0 exit
  DetailPrint "$(PFI_LANG_UN_LOG_6)"
  MessageBox MB_OK|MB_ICONEXCLAMATION \
      "$(PFI_LANG_UN_MBREMERR_1): $INSTDIR $(PFI_LANG_UN_MBREMERR_2)"

exit:
  SetDetailsPrint both

  Pop ${L_TEMP}
  Pop ${L_LNE}
  Pop ${L_EXE}
  Pop ${L_CFG}

  !undef L_CFG
  !undef L_EXE
  !undef L_LNE
  !undef L_TEMP

SectionEnd

#--------------------------------------------------------------------------
# End of 'installer.nsi'
#--------------------------------------------------------------------------
