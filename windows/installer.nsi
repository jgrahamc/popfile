#--------------------------------------------------------------------------
#
# installer.nsi --- This is the NSIS script used to create the
#                   Windows installer for POPFile. This script uses
#                   several custom pages whose layouts are defined
#                   in the files "ioA.ini", "ioB.ini", "ioC.ini",
#                   "ioD.ini", "ioE.ini", "ioF.ini" and "ioG.ini".
#
# Copyright (c) 2001-2003 John Graham-Cumming
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

; As of 19 November 2003, the latest release of the NSIS compiler is 2.0b4. This release
; contains significant changes (especially to the MUI which is used by the POPFile installer)
; which are not backward-compatible (i.e. this POPFile installer script cannot be built by
; earlier versions of the NSIS compiler).

; This version of the script has been tested with NSIS 2.0b4 dated 19 November 2003 after
; applying the NSIS CVS snapshot dated 22 December 2003 (08:44 GMT).

; IMPORTANT:
; The Outlook and Outlook Express Configuration pages use the NOWORDWRAP flag which requires
; InstallOptions 2.3 (or later). This means InstallOptions.dll dated 5 Dec 2003 or later
; (i.e. InstallOptions.dll v1.73 or later). If this script is compiled with an earlier version
; of the DLL, the account details will not be displayed correctly if any field exceeds the
; column width.

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
# For example, to build the installer for POPFile 0.20.1 the following command-line could be
# used:
#
# makensis.exe /DC_POPFILE_MAJOR_VERSION=0 /DC_POPFILE_MINOR_VERSION=20 /DC_POPFILE_REVISION=1 /DC_POPFILE_RC installer.nsi
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
# Run-time command-line switches (used by 'setup.exe')
#--------------------------------------------------------------------------
#
# /OUTLOOK
#
# The 'Outlook' reconfiguration code has had very little testing so far, therefore the
# installer does not normally offer to reconfigure 'Outlook' accounts. To enable the
# configuration of 'Outlook' accounts, use the command-line switch /OUTLOOK when starting
# the installer (the commands 'setup.exe /OUTLOOK' or 'setup.exe /outlook' can be used)
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
# Removing support for a particular language:
#
# To remove any of the additional languages, only TWO lines need to be commented-out:
#
# (a) comment-out the relevant '!insertmacro PFI_LANG_LOAD' line in the list of languages
#     in the 'Language Support for the installer and uninstaller' block of code
#
# (b) comment-out the relevant '!insertmacro UI_LANG_CONFIG' line in the list of languages
#     in the code which handles the 'UI Languages' component
#
# For example, to remove support for the 'Dutch' language, comment-out the line
#
#     !insertmacro PFI_LANG_LOAD "Dutch"
#
# in the list of languages supported by the installer, and comment-out the line
#
#     !insertmacro UI_LANG_CONFIG "DUTCH" "Nederlands"
#
# in the code which handles the 'UI Languages' component (Section "Languages").
#
#--------------------------------------------------------------------------
# Adding support for a particular language (it must be supported by NSIS):
#
# The number of languages which can be supported depends upon the availability of:
#
#     (1) an up-to-date main NSIS language file ({NSIS}\Contrib\Language files\*.nlf)
# and
#     (2) an up-to-date NSIS MUI Language file ({NSIS}\Contrib\Modern UI\Language files\*.nsh)
#
# To add support for a language which is already supported by the NSIS MUI package, an extra
# file is required:
#
# <NSIS Language NAME>-pfi.nsh  -  holds customised versions of the standard MUI text strings
#                                  (eg removing the 'reboot' reference from the 'Welcome' page)
#                                  plus strings used on the custom pages and elsewhere
#
# Once this file has been prepared and placed in the 'windows\languages' directory with the
# other *-pfi.nsh files, add a new '!insertmacro PFI_LANG_LOAD' line to load this new file
# and, if there is a suitable POPFile UI language file for the new language, add a suitable
# '!insertmacro UI_LANG_CONFIG' line in the section which handles the optional 'Languages'
# component to allow the installer to select the appropriate UI language.
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
#--------------------------------------------------------------------------

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
  ; Kakasi ZIP file has been unzipped.
  ;
  ; The 'itaijidict' file's path should be '${C_KAKASI_DIR}\kakasi\share\kakasi\itaijidict'
  ; The 'kanwadict'  file's path should be '${C_KAKASI_DIR}\kakasi\share\kakasi\kanwadict'
  ;----------------------------------------------------------------------------------

  !define C_KAKASI_DIR      "kakasi_package"

  ;--------------------------------------------------------------------------------
  ; Constants for the timeout loop used after issuing a POPFile 'shutdown' request
  ;--------------------------------------------------------------------------------

  ; Timeout loop counter start value (counts down to 0)

  !define C_SHUTDOWN_LIMIT    20

  ; Delay (in milliseconds) used inside the timeout loop

  !define C_SHUTDOWN_DELAY    1000

  ;-------------------------------------------------------------------------------
  ; Constants for the timeout loop used after issuing a POPFile 'startup' request
  ;-------------------------------------------------------------------------------

  ; Timeout loop counter start value (counts down to 0)

  !define C_STARTUP_LIMIT    20

  ; Delay (in milliseconds) used inside the timeout loop

  !define C_STARTUP_DELAY    1000

  ;------------------------------------------------
  ; Define PFI_VERBOSE to get more compiler output
  ;------------------------------------------------

## !define PFI_VERBOSE

#--------------------------------------------------------------------------
# Use the "Modern User Interface" and standard NSIS Section flag utilities
#--------------------------------------------------------------------------

  !include "MUI.nsh"
  !include "Sections.nsh"

#--------------------------------------------------------------------------
# Version Information settings (for the installer EXE and uninstaller EXE)
#--------------------------------------------------------------------------

  ; 'VIProductVersion' format is X.X.X.X where X is a number in range 0 to 65535
  ; representing the following values: Major.Minor.Release.Build

  VIProductVersion "${C_POPFILE_MAJOR_VERSION}.${C_POPFILE_MINOR_VERSION}.${C_POPFILE_REVISION}.0"

  VIAddVersionKey "ProductName" "${C_PFI_PRODUCT}"
  VIAddVersionKey "Comments" "POPFile Homepage: http://popfile.sourceforge.net"
  VIAddVersionKey "CompanyName" "The POPFile Project"
  VIAddVersionKey "LegalCopyright" "© 2001-2003  John Graham-Cumming"
  VIAddVersionKey "FileDescription" "POPFile Automatic email classification"
  VIAddVersionKey "FileVersion" "${C_PFI_VERSION}"

  !ifndef ENGLISH_MODE
    !ifndef NO_KAKASI
      VIAddVersionKey "Build" "Multi-Language (with Kakasi)"
    !else
      VIAddVersionKey "Build" "Multi-Language (without Kakasi)"
    !endif
  !else
    !ifndef NO_KAKASI
      VIAddVersionKey "Build" "English-Mode (with Kakasi)"
    !else
      VIAddVersionKey "Build" "English-Mode (without Kakasi)"
    !endif
  !endif

  VIAddVersionKey "Build Date/Time" "${__DATE__} @ ${__TIME__}"
  VIAddVersionKey "Build Script" "${__FILE__}$\r$\n(${__TIMESTAMP__})"

#----------------------------------------------------------------------------------------
# CBP Configuration Data (to override defaults, un-comment the lines below and modify them)
#----------------------------------------------------------------------------------------
#   ; Maximum number of buckets handled (in range 2 to 8)
#
#   !define CBP_MAX_BUCKETS 8
#
#   ; Default bucket selection (use "" if no buckets are to be pre-selected)
#
#   !define CBP_DEFAULT_LIST "inbox|spam|personal|work"
  !define CBP_DEFAULT_LIST "spam|personal|work|other"
#
#   ; List of suggestions for bucket names (use "" if no suggestions are required)
#
#   !define CBP_SUGGESTION_LIST \
#   "admin|business|computers|family|financial|general|hobby|inbox|junk|list-admin|\
#   miscellaneous|not_spam|other|personal|recreation|school|security|shopping|spam|\
#   travel|work"
#----------------------------------------------------------------------------------------
# Make the CBP package available
#----------------------------------------------------------------------------------------

  !include CBP.nsh

#--------------------------------------------------------------------------
# Include private library functions and macro definitions
#--------------------------------------------------------------------------

  !include pfi-library.nsh
  !include WriteEnvStr.nsh

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

  !define MUI_ICON    "POPFileIcon\popfile.ico"
  !define MUI_UNICON  "remove.ico"

  ; The "Header" bitmap appears on all pages of the installer (except Welcome & Finish pages)
  ; and on all pages of the uninstaller.

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
  ;  Interface Settings - Welcome/Finish Page Interface Settings
  ;----------------------------------------------------------------

  ; The "Special" bitmap appears on the "Welcome" and "Finish" pages

  !define MUI_WELCOMEFINISHPAGE_BITMAP "special.bmp"

  ;----------------------------------------------------------------
  ;  Interface Settings - Installer Finish Page Interface Settings
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

  !define MUI_CUSTOMFUNCTION_GUIINIT PFIGUIInit

  ;----------------------------------------------------------------
  ; Language Settings for MUI pages
  ;----------------------------------------------------------------

  ; Same "Language selection" dialog is used for the installer and the uninstaller
  ; so we override the standard "Installer Language" title to avoid confusion.

  !define MUI_LANGDLL_WINDOWTITLE "Language Selection"

  ; Always show the language selection dialog, even if a language has been stored in the
  ; registry (the language stored in the registry will be selected as the default language)

  !define MUI_LANGDLL_ALWAYSSHOW

  ; Remember user's language selection and offer this as the default when re-installing
  ; (uninstaller also uses this setting to determine which language is to be used)

  !define MUI_LANGDLL_REGISTRY_ROOT "HKLM"
  !define MUI_LANGDLL_REGISTRY_KEY "SOFTWARE\${C_PFI_PRODUCT}"
  !define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"

#--------------------------------------------------------------------------
# Define the Page order for the installer (and the uninstaller)
#--------------------------------------------------------------------------

  ;---------------------------------------------------
  ; Installer Page - Welcome
  ;---------------------------------------------------

  ; Use a "pre" function for the 'Welcome' page to ensure the installer window is visible
  ; (if the "Release Notes" were displayed, another window could have been positioned
  ; to obscure the installer window) and to check if the user had 'Admin' rights.

  !define MUI_PAGE_CUSTOMFUNCTION_PRE "CheckUserRights"

  !define MUI_WELCOMEPAGE_TEXT "$(PFI_LANG_WELCOME_INFO_TEXT)"

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

  !insertmacro MUI_PAGE_LICENSE "..\engine\license"

  ;---------------------------------------------------
  ; Installer Page - Select Components to be installed
  ;---------------------------------------------------

  !insertmacro MUI_PAGE_COMPONENTS

  ;---------------------------------------------------
  ; Installer Page - Select installation Directory
  ;---------------------------------------------------

  ; Use a "leave" function to look for 'popfile.cfg' in the directory selected for this install

  !define MUI_PAGE_CUSTOMFUNCTION_LEAVE "CheckExistingConfig"

  !insertmacro MUI_PAGE_DIRECTORY

  ;---------------------------------------------------
  ; Installer Page - POP3 and UI Port Options
  ;---------------------------------------------------

  Page custom SetOptionsPage "CheckPortOptions"

  ;---------------------------------------------------
  ; Installer Page - Install files
  ;---------------------------------------------------

  !insertmacro MUI_PAGE_INSTFILES

  ;---------------------------------------------------
  ; Installer Page - Create Buckets (if necessary)
  ;---------------------------------------------------

  !insertmacro CBP_PAGE_SELECTBUCKETS

  ;---------------------------------------------------
  ; Installer Page - Email Client Configuration
  ;---------------------------------------------------

  Page custom SetEmailClientPage

  ;---------------------------------------------------
  ; Installer Page - Configure Outlook Express accounts
  ;---------------------------------------------------

  Page custom SetOutlookExpressPage "CheckOutlookExpressRequests"

  ;---------------------------------------------------
  ; Installer Page - Configure Outlook accounts
  ;---------------------------------------------------

  Page custom SetOutlookPage "CheckOutlookRequests"

  ;---------------------------------------------------
  ; Installer Page - Configure Eudora personalities
  ;---------------------------------------------------

  Page custom SetEudoraPage

  ;---------------------------------------------------
  ; Installer Page - Choose POPFile launch mode
  ;---------------------------------------------------

  Page custom StartPOPFilePage "CheckLaunchOptions"

  ;---------------------------------------------------
  ; Installer Page - Convert Corpus (if necessary)
  ;---------------------------------------------------

  Page custom ConvertCorpusPage

  ;---------------------------------------------------
  ; Installer Page - Finish (may offer to start UI)
  ;---------------------------------------------------

  ; Use a "pre" function for the 'Finish' page to ensure installer only offers to display
  ; POPFile User Interface if user has chosen to start POPFile from the installer.

  !define MUI_PAGE_CUSTOMFUNCTION_PRE "CheckRunStatus"

  ; Offer to display the POPFile User Interface (The 'CheckRunStatus' function ensures this
  ; option is only offered if the installer has started POPFile running)

  !define MUI_FINISHPAGE_RUN
  !define MUI_FINISHPAGE_RUN_TEXT     "$(PFI_LANG_FINISH_RUN_TEXT)"
  !define MUI_FINISHPAGE_RUN_FUNCTION "RunUI"

  ; Provide a checkbox to let user display the Release Notes for this version of POPFile

  !define MUI_FINISHPAGE_SHOWREADME
  !define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
  !define MUI_FINISHPAGE_SHOWREADME_FUNCTION "ShowReadMe"

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
# User Registers (Global)
#--------------------------------------------------------------------------

  ; This script uses 'User Variables' (with names starting with 'G_') to hold GLOBAL data.

  Var G_POP3               ; POP3 port (1-65535)
  Var G_GUI                ; GUI port (1-65535)
  Var G_STARTUP            ; automatic startup flag (1 = yes, 0 = no)
  Var G_NOTEPAD            ; path to notepad.exe ("" = not found in search path)

  Var G_OOECONFIG_HANDLE   ; to access list of all Outlook/Outlook Express accounts found
  Var G_OOECHANGES_HANDLE  ; to access list of Outlook/Outlook Express configuration changes
  Var G_OOELIST_INDEX      ; to access the list of up to 6 Outlook/Outlook Express accounts
  Var G_OOELIST_CBOX       ; to access one of the 6 checkbox fields on the configuration page
  Var G_SEPARATOR          ; character used to separate the POP3 server from the username

  Var G_HWND               ; HWND of the dialog we are going to modify
  Var G_DLGITEM            ; HWND of the field we are going to modify on that dialog
  Var G_FONT               ; the font we use to modify that field

  Var G_WINUSERNAME        ; current Windows user login name
  Var G_WINUSERTYPE        ; user group ('Admin', 'Power', 'User', 'Guest' or 'Unknown')

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
# Language Support for the installer and uninstaller
#--------------------------------------------------------------------------

  ;-----------------------------------------
  ; Select the languages to be supported by installer/uninstaller.
  ; Currently a subset of the languages supported by NSIS MUI 1.68 (using the NSIS names)
  ;-----------------------------------------

  ; At least one language must be specified for the installer (the default is "English")

  !insertmacro PFI_LANG_LOAD "English"

  ; Conditional compilation: if ENGLISH_MODE is defined, support only 'English'

  !ifndef ENGLISH_MODE

        ; Additional languages supported by the installer.

        ; To remove a language, comment-out the relevant '!insertmacro PFI_LANG_LOAD' line
        ; from this list. (To remove all of these languages, use /DENGLISH_MODE on command-line)

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
  InstallDirRegKey HKLM "SOFTWARE\${C_PFI_PRODUCT}" InstallLocation

#--------------------------------------------------------------------------
# Reserve the files required by the installer (to improve performance)
#--------------------------------------------------------------------------

  ;Things that need to be extracted on startup (keep these lines before any File command!)
  ;Only useful for BZIP2 compression
  ;Use ReserveFile for your own Install Options ini files too!

  !insertmacro MUI_RESERVEFILE_LANGDLL
  !insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
  ReserveFile "ioA.ini"
  ReserveFile "ioB.ini"
  ReserveFile "ioC.ini"
  ReserveFile "ioD.ini"
  ReserveFile "ioE.ini"
  ReserveFile "ioF.ini"
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
  !define L_RESERVED            $1    ; used in the system.dll call

  Push ${L_INPUT_FILE_HANDLE}
  Push ${L_OUTPUT_FILE_HANDLE}
  Push ${L_TEMP}
  Push ${L_RESERVED}

  ; Ensure only one copy of this installer is running

  System::Call 'kernel32::CreateMutexA(i 0, i 0, t "OnlyOnePFI_mutex") i .r1 ?e'
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} 0 continue
  MessageBox MB_OK|MB_ICONEXCLAMATION \
      "Another copy of the POPFile installer is already running!"
  Abort

continue:

  ; Conditional compilation: if ENGLISH_MODE is defined, support only 'English'

  !ifndef ENGLISH_MODE
        !insertmacro MUI_LANGDLL_DISPLAY
  !endif

  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioA.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioB.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioC.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioD.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioE.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioF.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioG.ini"

  !insertmacro MUI_INSTALLOPTIONS_EXTRACT_AS "${C_RELEASE_NOTES}" "${C_README}"

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

  Pop ${L_RESERVED}
  Pop ${L_TEMP}
  Pop ${L_OUTPUT_FILE_HANDLE}
  Pop ${L_INPUT_FILE_HANDLE}

  !undef L_INPUT_FILE_HANDLE
  !undef L_OUTPUT_FILE_HANDLE
  !undef L_TEMP
  !undef L_RESERVED

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: PFIGUIInit
# (custom .onGUIInit function)
#
# Used to complete the initialisation of the installer.
# (this code was moved from '.onInit' in order to permit the custom pages
# to be set up to use the language selected by the user)
#--------------------------------------------------------------------------

Function PFIGUIInit

  SearchPath $G_NOTEPAD notepad.exe

  MessageBox MB_YESNO|MB_ICONQUESTION \
      "$(PFI_LANG_MBRELNOTES_1)\
      $\r$\n$\r$\n\
      $(PFI_LANG_MBRELNOTES_2)" IDNO continue

  StrCmp $G_NOTEPAD "" use_file_association
  ExecWait 'notepad.exe "$PLUGINSDIR\${C_README}.txt"'
  GoTo continue

use_file_association:
  ExecShell "open" "$PLUGINSDIR\${C_README}.txt"

continue:

  ; Insert appropriate language strings into the custom page INI files
  ; (the CBP package creates its own INI file so there is no need for a CBP *Page_Init function)

  Call SetOptionsPage_Init
  Call SetEmailClientPage_Init
  Call SetOutlookOutlookExpressPage_Init
  Call SetEudoraPage_Init
  Call StartPOPFilePage_Init
  Call ConvertCorpusPage_Init

  !ifndef NO_KAKASI

      ; Ensure the 'Kakasi' section is selected if 'Japanese' has been chosen

      Call HandleKakasi

  !endif

FunctionEnd

#--------------------------------------------------------------------------
# Installer Section: POPFile component
#--------------------------------------------------------------------------

Section "POPFile" SecPOPFile

  ; Make this section mandatory (i.e. it is always installed)

  SectionIn RO

  !define L_CFG   $R9   ; file handle

  Push ${L_CFG}

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_UPGRADE)"
  SetDetailsPrint listonly

  ; If we are installing over a previous version, ensure that version is not running

  Call MakeItSafe

  ; Retrieve the POP3 and GUI ports from the ini and get whether we install the
  ; POPFile run in the Startup group

  !insertmacro MUI_INSTALLOPTIONS_READ $G_POP3    "ioA.ini" "Field 2" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $G_GUI     "ioA.ini" "Field 4" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $G_STARTUP "ioA.ini" "Field 5" "State"

  WriteRegStr HKLM "SOFTWARE\${C_PFI_PRODUCT}" InstallLocation $INSTDIR

  ; Install the POPFile Core files

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_CORE)"
  SetDetailsPrint listonly

  SetOutPath $INSTDIR

  File "..\engine\license"
  File "${C_RELEASE_NOTES}"
  CopyFiles /SILENT /FILESONLY "$PLUGINSDIR\${C_README}.txt" "$INSTDIR\${C_README}.txt"

  File "..\engine\popfile.exe"
  File "..\engine\popfilef.exe"
  File "..\engine\popfileb.exe"
  File "..\engine\popfileif.exe"
  File "..\engine\popfileib.exe"

  File "stop_pf.exe"
  File "wrapper.exe"
  File "wrapperf.exe"
  File "wrapperb.exe"
  File "sqlite.exe"

  ; Create default configuration data for use by the 'wrapper' utilities

  WriteINIStr "$INSTDIR\wrapper.ini" "Configuration" "POPFileFolder" "$INSTDIR"
  WriteINIStr "$INSTDIR\wrapper.ini" "Configuration" "UserDataFolder" "$INSTDIR"

  File "..\engine\popfile.pl"
  File "..\engine\insert.pl"
  File "..\engine\bayes.pl"
  File "..\engine\pipe.pl"

  File "..\engine\pix.gif"
  File "..\engine\favicon.ico"
  File "..\engine\black.gif"
  File "..\engine\otto.gif"

  IfFileExists "$INSTDIR\stopwords" 0 copy_stopwords
  MessageBox MB_YESNO|MB_ICONQUESTION \
      "POPFile 'stopwords' $(PFI_LANG_MBSTPWDS_1)\
      $\r$\n$\r$\n\
      $(PFI_LANG_MBSTPWDS_2)\
      $\r$\n$\r$\n\
      $(PFI_LANG_MBSTPWDS_3) 'stopwords.bak')\
      $\r$\n$\r$\n\
      $(PFI_LANG_MBSTPWDS_4) 'stopwords.default')" IDNO copy_default_stopwords
  IfFileExists "$INSTDIR\stopwords.bak" 0 make_backup
  SetFileAttributes "$INSTDIR\stopwords.bak" NORMAL

make_backup:
  CopyFiles /SILENT /FILESONLY "$INSTDIR\stopwords" "$INSTDIR\stopwords.bak"

copy_stopwords:
  File "..\engine\stopwords"

copy_default_stopwords:
  File /oname=stopwords.default "..\engine\stopwords"
  FileOpen  ${L_CFG} $PLUGINSDIR\popfile.cfg a
  FileSeek  ${L_CFG} 0 END
  FileWrite ${L_CFG} "pop3_port $G_POP3$\r$\n"
  FileWrite ${L_CFG} "html_port $G_GUI$\r$\n"
  FileClose ${L_CFG}
  IfFileExists "$INSTDIR\popfile.cfg" 0 update_config
  SetFileAttributes "$INSTDIR\popfile.cfg" NORMAL
  IfFileExists "$INSTDIR\popfile.cfg.bak" 0 make_cfg_backup
  MessageBox MB_YESNO|MB_ICONQUESTION \
      "$(PFI_LANG_MBCFGBK_1) 'popfile.cfg' $(PFI_LANG_MBCFGBK_2) ('popfile.cfg.bak').\
      $\r$\n$\r$\n\
      $(PFI_LANG_MBCFGBK_3)\
      $\r$\n$\r$\n\
      $(PFI_LANG_MBCFGBK_4)" IDNO update_config
  SetFileAttributes "$INSTDIR\popfile.cfg.bak" NORMAL

make_cfg_backup:
  CopyFiles /SILENT /FILESONLY $INSTDIR\popfile.cfg $INSTDIR\popfile.cfg.bak

update_config:
  CopyFiles /SILENT /FILESONLY $PLUGINSDIR\popfile.cfg $INSTDIR\

  SetOutPath $INSTDIR\Classifier

  File "..\engine\Classifier\Bayes.pm"
  File "..\engine\Classifier\WordMangle.pm"
  File "..\engine\Classifier\MailParse.pm"
  File "..\engine\Classifier\popfile.sql"

  SetOutPath $INSTDIR\Platform
  File "..\engine\Platform\MSWin32.pm"

  SetOutPath $INSTDIR\POPFile
  File "..\engine\POPFile\MQ.pm"
  File "..\engine\POPFile\Loader.pm"
  File "..\engine\POPFile\Logger.pm"
  File "..\engine\POPFile\Module.pm"
  File "..\engine\POPFile\Configuration.pm"

  ; CVS builds use installer version data to set the POPFile version

  FileOpen ${L_CFG} "$INSTDIR\POPFile\popfile_version" w
  FileWrite ${L_CFG} "${C_POPFILE_MAJOR_VERSION}$\r$\n${C_POPFILE_MINOR_VERSION}$\r$\n${C_POPFILE_REVISION}$\r$\n"
  FileClose ${L_CFG}

  SetOutPath $INSTDIR\Proxy
  File "..\engine\Proxy\Proxy.pm"
  File "..\engine\Proxy\POP3.pm"

  SetOutPath $INSTDIR\UI
  File "..\engine\UI\HTML.pm"
  File "..\engine\UI\HTTP.pm"

  SetOutPath $INSTDIR\manual
  File "..\engine\manual\*.gif"
  SetOutPath $INSTDIR\manual\en
  File "..\engine\manual\en\*.html"

  SetOutPath $INSTDIR\languages
  File "..\engine\languages\English.msg"

  ; Install the Minimal Perl files

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_PERL)"
  SetDetailsPrint listonly

  SetOutPath $INSTDIR
  File "${C_PERL_DIR}\bin\perl.exe"
  File "${C_PERL_DIR}\bin\wperl.exe"
  File "${C_PERL_DIR}\bin\perl58.dll"
  File "${C_PERL_DIR}\lib\AutoLoader.pm"
  File "${C_PERL_DIR}\lib\Carp.pm"
  File "${C_PERL_DIR}\lib\Config.pm"
  File "${C_PERL_DIR}\lib\constant.pm"
  File "${C_PERL_DIR}\lib\DynaLoader.pm"
  File "${C_PERL_DIR}\lib\Errno.pm"
  File "${C_PERL_DIR}\lib\Exporter.pm"
  File "${C_PERL_DIR}\lib\IO.pm"
  File "${C_PERL_DIR}\lib\integer.pm"
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

  SetOutPath $INSTDIR\Carp
  File "${C_PERL_DIR}\lib\Carp\*"

  SetOutPath $INSTDIR\Exporter
  File "${C_PERL_DIR}\lib\Exporter\*"

  SetOutPath $INSTDIR\File
  File "${C_PERL_DIR}\lib\File\Glob.pm"

  SetOutPath $INSTDIR\Getopt
  File "${C_PERL_DIR}\lib\Getopt\Long.pm"

  SetOutPath $INSTDIR\IO
  File "${C_PERL_DIR}\lib\IO\*"

  SetOutPath $INSTDIR\IO\Socket
  File "${C_PERL_DIR}\lib\IO\Socket\*"

  SetOutPath $INSTDIR\MIME
  File "${C_PERL_DIR}\lib\MIME\*"

  SetOutPath $INSTDIR\Sys
  File "${C_PERL_DIR}\lib\Sys\*"

  SetOutPath $INSTDIR\Text
  File "${C_PERL_DIR}\lib\Text\ParseWords.pm"

  SetOutPath $INSTDIR\warnings
  File "${C_PERL_DIR}\lib\warnings\register.pm"

  SetOutPath $INSTDIR\auto\DynaLoader
  File "${C_PERL_DIR}\lib\auto\DynaLoader\*"

  SetOutPath $INSTDIR\auto\File\Glob
  File "${C_PERL_DIR}\lib\auto\File\Glob\*"

  SetOutPath $INSTDIR\auto\IO
  File "${C_PERL_DIR}\lib\auto\IO\*"

  SetOutPath $INSTDIR\auto\MIME\Base64
  File "${C_PERL_DIR}\lib\auto\MIME\Base64\*"

  SetOutPath $INSTDIR\auto\POSIX
  File "${C_PERL_DIR}\lib\auto\POSIX\POSIX.dll"
  File "${C_PERL_DIR}\lib\auto\POSIX\autosplit.ix"
  File "${C_PERL_DIR}\lib\auto\POSIX\load_imports.al"

  SetOutPath $INSTDIR\auto\Socket
  File "${C_PERL_DIR}\lib\auto\Socket\*"

  SetOutPath $INSTDIR\auto\Sys\Hostname
  File "${C_PERL_DIR}\lib\auto\Sys\Hostname\*"

  ; Install Perl modules and library files for BerkeleyDB support

  SetOutPath $INSTDIR
  File "${C_PERL_DIR}\site\lib\BerkeleyDB.pm"
  File "${C_PERL_DIR}\lib\UNIVERSAL.pm"

  SetOutPath $INSTDIR\auto\BerkeleyDB
  File "${C_PERL_DIR}\site\lib\auto\BerkeleyDB\autosplit.ix"
  File "${C_PERL_DIR}\site\lib\auto\BerkeleyDB\BerkeleyDB.bs"
  File "${C_PERL_DIR}\site\lib\auto\BerkeleyDB\BerkeleyDB.dll"
  File "${C_PERL_DIR}\site\lib\auto\BerkeleyDB\BerkeleyDB.exp"
  File "${C_PERL_DIR}\site\lib\auto\BerkeleyDB\BerkeleyDB.lib"

  ; Install Perl modules and library files for SQLite support

  SetOutPath $INSTDIR
  File "${C_PERL_DIR}\lib\base.pm"
  File "${C_PERL_DIR}\lib\overload.pm"
  File "${C_PERL_DIR}\site\lib\DBI.pm"

  SetOutPath $INSTDIR\auto\DBD\SQLite
  File "${C_PERL_DIR}\site\lib\auto\DBD\SQLite\SQLite.bs"
  File "${C_PERL_DIR}\site\lib\auto\DBD\SQLite\SQLite.dll"
  File "${C_PERL_DIR}\site\lib\auto\DBD\SQLite\SQLite.exp"
  File "${C_PERL_DIR}\site\lib\auto\DBD\SQLite\SQLite.lib"

  SetOutPath $INSTDIR\auto\DBI
  File "${C_PERL_DIR}\site\lib\auto\DBI\DBI.bs"
  File "${C_PERL_DIR}\site\lib\auto\DBI\DBI.dll"
  File "${C_PERL_DIR}\site\lib\auto\DBI\DBI.exp"
  File "${C_PERL_DIR}\site\lib\auto\DBI\DBI.lib"

  SetOutPath $INSTDIR\String
  File "${C_PERL_DIR}\site\lib\String\Interpolate.pm"

  SetOutPath $INSTDIR\DBD
  File "${C_PERL_DIR}\site\lib\DBD\SQLite.pm"

  ; Create the uninstall program BEFORE creating the shortcut to it
  ; (this ensures that the correct "uninstall" icon appears in the START MENU shortcut)

  SetOutPath $INSTDIR
  Delete $INSTDIR\uninstall.exe
  WriteUninstaller $INSTDIR\uninstall.exe

  ; Create the START MENU entries

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_SHORT)"
  SetDetailsPrint listonly

  ; 'CreateShortCut' uses '$OUTDIR' as the working directory for the shortcut
  ; ('SetOutPath' is one way to change the value of $OUTDIR)

  SetOutPath "$SMPROGRAMS\${C_PFI_PRODUCT}"
  SetOutPath $INSTDIR
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Run POPFile.lnk" \
                 "$INSTDIR\wrapper.exe"
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Uninstall POPFile.lnk" \
                 "$INSTDIR\uninstall.exe"
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Release Notes.lnk" \
                 "$INSTDIR\${C_README}.txt"

  SetOutPath "$SMPROGRAMS\${C_PFI_PRODUCT}"
  WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\POPFile User Interface.url" \
              "InternetShortcut" "URL" "http://127.0.0.1:$G_GUI/"
  WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\Shutdown POPFile.url" \
              "InternetShortcut" "URL" "http://127.0.0.1:$G_GUI/shutdown"
  WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\Manual.url" \
              "InternetShortcut" "URL" "file://$INSTDIR/manual/en/manual.html"
  WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\FAQ.url" \
              "InternetShortcut" "URL" \
              "http://sourceforge.net/docman/display_doc.php?docid=14421&group_id=63137"

  SetOutPath "$SMPROGRAMS\${C_PFI_PRODUCT}\Support"
  WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\POPFile Home Page.url" \
              "InternetShortcut" "URL" "http://popfile.sourceforge.net/"

  SetOutPath $INSTDIR
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Shutdown POPFile silently.lnk" \
                 "$INSTDIR\stop_pf.exe" "/showerrors $G_GUI"

  StrCmp $G_STARTUP "1" 0 skip_autostart_set
      SetOutPath $SMSTARTUP
      SetOutPath $INSTDIR
      CreateShortCut "$SMSTARTUP\Run POPFile.lnk" \
                     "$INSTDIR\wrapper.exe"
skip_autostart_set:

  ; Remove redundant links (used by earlier versions of POPFile)

  Delete "$SMSTARTUP\Run POPFile in background.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Run POPFile in background.lnk"

  ; Create entry in the Control Panel's "Add/Remove Programs" list

  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "DisplayName" "${C_PFI_PRODUCT} ${C_PFI_VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "NoModify" "1"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "NoRepair" "1"

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_ENDSEC)"
  SetDetailsPrint listonly

  Pop ${L_CFG}

  !undef L_CFG

SectionEnd

#--------------------------------------------------------------------------
# Installer Section: Flat File Corpus Backup component (always 'installed')
#
# If we are performing an upgrade of a 'flat file' version of POPFile, we make a backup of the
# flat file corpus structure. Note that if a backup already exists, we do nothing.
#
# The backup is created in the '$INSTDIR\backup' folder. Information on the backup is stored
# in the 'backup.ini' file to assist in restoring the flat file corpus. A copy of 'popfile.cfg'
# is also placed in the backup folder.
#--------------------------------------------------------------------------

Section "-FlatFileBackup" SecBackup

  !define L_CFG_HANDLE    $R9     ; handle for "popfile.cfg"
  !define L_CORPUS_PATH   $R8     ; full path to the corpus
  !define L_TEMP          $R7

  Push ${L_CFG_HANDLE}
  Push ${L_CORPUS_PATH}
  Push ${L_TEMP}

  IfFileExists "$INSTDIR\popfile.cfg" 0 exit
  IfFileExists "$INSTDIR\backup\backup.ini" exit

  ; Use data in 'popfile.cfg' to generate the full path to the corpus folder

  Push $INSTDIR
  Call GetCorpusPath
  Pop ${L_CORPUS_PATH}

  FindFirst ${L_CFG_HANDLE} ${L_TEMP} ${L_CORPUS_PATH}\*.*

  ; If the "corpus" directory does not exist then "${L_CFG_HANDLE}" will be empty

  StrCmp ${L_CFG_HANDLE} "" nothing_to_backup

  ; Now search through the corpus folder, looking for buckets (at this point ${L_TEMP} is ".")

corpus_check:
  FindNext ${L_CFG_HANDLE} ${L_TEMP}
  StrCmp ${L_TEMP} ".." corpus_check
  StrCmp ${L_TEMP} "" nothing_to_backup

  ; Assume what we've found is a bucket folder, now check if it contains
  ; a BerkeleyDB file or a flat-file corpus file. We stop our search as
  ; soon as we find either type of file (i.e. we do not examine every bucket)

  IfFileExists "${L_CORPUS_PATH}\${L_TEMP}\table.db" nothing_to_backup
  IfFileExists "${L_CORPUS_PATH}\${L_TEMP}\table" backup_corpus
  Goto corpus_check

backup_corpus:

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_FFCBACK)"
  SetDetailsPrint listonly

  CreateDirectory "$INSTDIR\backup"
  CopyFiles "$INSTDIR\popfile.cfg" "$INSTDIR\backup\popfile.cfg"
  WriteINIStr "$INSTDIR\backup\backup.ini" "FlatFileCorpus" "CorpusPath" "${L_CORPUS_PATH}"

  StrCpy ${L_TEMP} ${L_CORPUS_PATH}
  Push ${L_TEMP}
  Call GetParent
  Pop ${L_TEMP}
  WriteINIStr "$INSTDIR\backup\backup.ini" "FlatFileCorpus" "ParentPath" "${L_TEMP}"
  StrLen ${L_TEMP} ${L_TEMP}
  IntOp ${L_TEMP} ${L_TEMP} + 1
  StrCpy ${L_TEMP} ${L_CORPUS_PATH} "" ${L_TEMP}

  ClearErrors
  CopyFiles /SILENT "${L_CORPUS_PATH}\*.*" "$INSTDIR\backup\${L_TEMP}"
  IfErrors 0 continue
  DetailPrint "Error detected when making corpus backup"
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(PFI_LANG_MBFFCERR_1)"

continue:
  WriteINIStr "$INSTDIR\backup\backup.ini" "FlatFileCorpus" "Corpus" "${L_TEMP}"
  WriteINIStr "$INSTDIR\backup\backup.ini" "FlatFileCorpus" "Status" "new"

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_ENDSEC)"
  SetDetailsPrint listonly

nothing_to_backup:
  FindClose ${L_CFG_HANDLE}

exit:
  Pop ${L_TEMP}
  Pop ${L_CORPUS_PATH}
  Pop ${L_CFG_HANDLE}

  !undef L_CFG_HANDLE
  !undef L_CORPUS_PATH
  !undef L_TEMP

SectionEnd

#--------------------------------------------------------------------------
# Installer Section: (optional) Skins component
#--------------------------------------------------------------------------

Section "Skins" SecSkins

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_SKINS)"
  SetDetailsPrint listonly

  SetOutPath $INSTDIR\skins
  File "..\engine\skins\*.css"
  File "..\engine\skins\*.gif"
  SetOutPath $INSTDIR\skins\lavishImages
  File "..\engine\skins\lavishImages\*.gif"
  SetOutPath $INSTDIR\skins\sleetImages
  File "..\engine\skins\sleetImages\*.gif"

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_ENDSEC)"
  SetDetailsPrint listonly

SectionEnd

#--------------------------------------------------------------------------
# Installer Section: (optional) UI Languages component
#
# If this component is selected, the installer will attempt to preset the POPFile UI
# language to match the language used for the installation. The 'UI_LANG_CONFIG' macro
# defines the mapping between NSIS language name and POPFile UI language name.
# The POPFile UI language is only preset if the required UI language file exists.
# If no match is found or if the UI language file does not exist, the default UI language
# is used (it is left to POPFile to determine which language to use).
#
# By the time this section is executed, the function 'CheckExistingConfig' in conjunction with
# the processing performed in the "POPFile" section will have removed all UI language settings
# from 'popfile.cfg' so all we have to do is append the UI setting to the file. If we do not
# append anything, POPFile will choose the default language.
#--------------------------------------------------------------------------

Section "Languages" SecLangs

  !define L_CFG   $R9   ; file handle
  !define L_LANG  $R8   ; language to be used for POPFile UI

  Push ${L_CFG}
  Push ${L_LANG}

  StrCpy ${L_LANG} ""     ; assume default POPFile UI language will be used.

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_LANGS)"
  SetDetailsPrint listonly

  SetOutPath $INSTDIR\languages
  File "..\engine\languages\*.msg"

  ; There are several special cases: some UI languages are not yet supported by the
  ; installer, so if we are upgrading a system which was using one of these UI languages,
  ; we re-select it, provided the UI language file still exists.

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_LANG} "ioC.ini" "Inherited" "html_language"
  StrCmp ${L_LANG} "?" 0 use_inherited_lang
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_LANG} "ioC.ini" "Inherited" "language"
  StrCmp ${L_LANG} "?" use_installer_lang

use_inherited_lang:
  StrCmp ${L_LANG} "English-UK" special_case
  StrCmp ${L_LANG} "Hebrew"  0 use_installer_lang

special_case:
  IfFileExists "$INSTDIR\languages\${L_LANG}.msg" lang_save

use_installer_lang:

  ; Conditional compilation: if ENGLISH_MODE is defined, installer supports only 'English'
  ; so we use whatever UI language was defined in the existing 'popfile.cfg' file (if none
  ; found then we let POPFile use the default UI language)

  !ifndef ENGLISH_MODE

        ; UI_LANG_CONFIG parameters: "NSIS Language name"  "POPFile UI language name"

        !insertmacro UI_LANG_CONFIG "ENGLISH" "English"
        !insertmacro UI_LANG_CONFIG "BULGARIAN" "Bulgarian"
        !insertmacro UI_LANG_CONFIG "SIMPCHINESE" "Chinese-Simplified"
        !insertmacro UI_LANG_CONFIG "TRADCHINESE" "Chinese-Traditional"
        !insertmacro UI_LANG_CONFIG "CZECH" "Czech"
        !insertmacro UI_LANG_CONFIG "DANISH" "Dansk"
        !insertmacro UI_LANG_CONFIG "GERMAN" "Deutsch"
        !insertmacro UI_LANG_CONFIG "SPANISH" "Espanol"
        !insertmacro UI_LANG_CONFIG "FRENCH" "Francais"
        !insertmacro UI_LANG_CONFIG "GREEK" "Hellenic"
        !insertmacro UI_LANG_CONFIG "ITALIAN" "Italiano"
        !insertmacro UI_LANG_CONFIG "JAPANESE" "Nihongo"
        !insertmacro UI_LANG_CONFIG "KOREAN" "Korean"
        !insertmacro UI_LANG_CONFIG "HUNGARIAN" "Hungarian"
        !insertmacro UI_LANG_CONFIG "DUTCH" "Nederlands"
        !insertmacro UI_LANG_CONFIG "NORWEGIAN" "Norsk"
        !insertmacro UI_LANG_CONFIG "POLISH" "Polish"
        !insertmacro UI_LANG_CONFIG "PORTUGUESE" "Portugues"
        !insertmacro UI_LANG_CONFIG "PORTUGUESEBR" "Portugues do Brasil"
        !insertmacro UI_LANG_CONFIG "RUSSIAN" "Russian"
        !insertmacro UI_LANG_CONFIG "SLOVAK" "Slovak"
        !insertmacro UI_LANG_CONFIG "FINNISH" "Suomi"
        !insertmacro UI_LANG_CONFIG "SWEDISH" "Svenska"
        !insertmacro UI_LANG_CONFIG "TURKISH" "Turkce"
        !insertmacro UI_LANG_CONFIG "UKRAINIAN" "Ukrainian"

        ; at this point, no match was found so we use the default POPFile UI language
        ; (and leave it to POPFile to determine which language to use)
  !endif

  goto lang_done

lang_save:
  FileOpen  ${L_CFG} $INSTDIR\popfile.cfg a
  FileSeek  ${L_CFG} 0 END
  FileWrite ${L_CFG} "html_language ${L_LANG}$\r$\n"
  FileClose ${L_CFG}

lang_done:
  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_ENDSEC)"
  SetDetailsPrint listonly

  Pop ${L_LANG}
  Pop ${L_CFG}

  !undef L_CFG
  !undef L_LANG

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

      ;--------------------------------------------------------------------------
      ; Install Kakasi package
      ;--------------------------------------------------------------------------

      SetOutPath $INSTDIR
      File /r "${C_KAKASI_DIR}\kakasi"

      ; Add Environment Variables for Kakasi

      Push ITAIJIDICTPATH
      Push $INSTDIR\kakasi\share\kakasi\itaijidict
      Call WriteEnvStr
      Push KANWADICTPATH
      Push $INSTDIR\kakasi\share\kakasi\kanwadict
      Call WriteEnvStr

      ;--------------------------------------------------------------------------
      ; Install Perl modules: base.pm, the Encode collection and Text::Kakasi
      ;--------------------------------------------------------------------------

      SetOutPath $INSTDIR
      File "${C_PERL_DIR}\lib\base.pm"
      File "${C_PERL_DIR}\lib\Encode.pm"

      SetOutPath $INSTDIR\Encode
      File /r "${C_PERL_DIR}\lib\Encode\*"

      SetOutPath $INSTDIR\auto\Encode
      File /r "${C_PERL_DIR}\lib\auto\Encode\*"

      SetOutPath $INSTDIR\Text
      File "${C_PERL_DIR}\site\lib\Text\Kakasi.pm"

      SetOutPath $INSTDIR\auto\Text\Kakasi
      File "${C_PERL_DIR}\site\lib\auto\Text\Kakasi\*"

    SectionEnd
!endif

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
  IntCmp ${L_TEMP} 5 0 not_good exit
  StrCmp ${L_VERSION} '5.5' exit

not_good:

  ; Ensure custom page matches the selected language (left-to-right or right-to-left order)

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioG.ini" "Settings" "RTL" "$(^RTL)"

  !insertmacro PFI_IO_TEXT "ioG.ini" "1" "$(PFI_LANG_PERLREQ_IO_TEXT_1)"
  !insertmacro PFI_IO_TEXT "ioG.ini" "2" "$(PFI_LANG_PERLREQ_IO_TEXT_2) ${L_VERSION}"
  !insertmacro PFI_IO_TEXT "ioG.ini" "3" "$(PFI_LANG_PERLREQ_IO_TEXT_3)"

  !insertmacro MUI_HEADER_TEXT "$(PFI_LANG_PERLREQ_TITLE)" "$(PFI_LANG_PERLREQ_SUBTITLE)"

  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioG.ini"

exit:
  Pop ${L_VERSION}
  Pop ${L_TEMP}

  !undef L_TEMP
  !undef L_VERSION

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: CheckUserRights
# (the "pre" function for the WELCOME page)
#
# Try to ensure the installer window is not hidden behind any other windows.
#
# On systems which support different types of user, recommend that POPFile is installed by
# a user with 'Administrative' rights (this makes it easier to use POPFile's multi-user mode).
#--------------------------------------------------------------------------

Function CheckUserRights

  !define L_WELCOME_TEXT  $R9

  Push ${L_WELCOME_TEXT}

  ; After showing the release notes, the installer may not be "on top" so try to correct this.
  ; (On Windows XP this command may only flash the installer's task bar icon)

  BringToFront

  ; The 'UserInfo' plugin may return an error if run on a Win9x system but since Win9x systems
  ; do not support different account types, we treat this error as if user has 'Admin' rights.

	ClearErrors
	UserInfo::GetName
	IfErrors 0 got_name

  ; Assume Win9x system, so user has 'Admin' rights (To do: look for username in Registry?)
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

  ; On the 'Welcome' page, add a note recommending that POPFile is installed by a user
  ; with 'Administrator' rights

  !insertmacro MUI_INSTALLOPTIONS_READ "${L_WELCOME_TEXT}" "ioSpecial.ini" "Field 3" "Text"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 3" "Text" \
      "${L_WELCOME_TEXT}\
      \r\n\r\n\
      $(PFI_LANG_WELCOME_ADMIN_TEXT)"

exit:
  Pop ${L_WELCOME_TEXT}

  !undef L_WELCOME_TEXT

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: MakeItSafe
#
# If we are installing on top of a previous installation, we try to shut it down
# (to allow the files to be overwritten without requiring a reboot)
#--------------------------------------------------------------------------

Function MakeItSafe

  !define L_CFG      $R9    ; file handle
  !define L_EXE      $R8    ; name of EXE file to be monitored
  !define L_NEW_GUI  $R7
  !define L_OLD_GUI  $R6
  !define L_RESULT   $R5

  Push ${L_CFG}
  Push ${L_EXE}
  Push ${L_NEW_GUI}
  Push ${L_OLD_GUI}
  Push ${L_RESULT}

  ; If we are about to overwrite an existing version which is still running,
  ; then one of the EXE files will be 'locked' which means we have to shutdown POPFile.
  ; POPFile v0.20.0 and later may be using 'popfileb.exe', 'popfilef.exe', 'popfileib.exe',
  ; 'popfileif.exe', or 'perl.exe' ('wperl.exe' is another possibility if this is an upgraded
  ; installation). Earlier versions of POPFile use only 'perl.exe' or 'wperl.exe'.

  DetailPrint "Checking $INSTDIR\popfileb.exe"

  Push "$INSTDIR\popfileb.exe"
  Call CheckIfLocked
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" 0 attempt_shutdown

  DetailPrint "Checking $INSTDIR\popfileib.exe"

  Push "$INSTDIR\popfileib.exe"
  Call CheckIfLocked
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" 0 attempt_shutdown

  DetailPrint "Checking $INSTDIR\popfilef.exe"

  Push "$INSTDIR\popfilef.exe"
  Call CheckIfLocked
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" 0 attempt_shutdown

  DetailPrint "Checking $INSTDIR\popfileif.exe"

  Push "$INSTDIR\popfileif.exe"
  Call CheckIfLocked
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" 0 attempt_shutdown

  DetailPrint "Checking $INSTDIR\wperl.exe"

  Push "$INSTDIR\wperl.exe"
  Call CheckIfLocked
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" 0 attempt_shutdown

  DetailPrint "Checking $INSTDIR\perl.exe"

  Push "$INSTDIR\perl.exe"
  Call CheckIfLocked
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" exit_now

attempt_shutdown:
  !insertmacro MUI_INSTALLOPTIONS_READ "${L_NEW_GUI}" "ioA.ini" "UI Port" "NewStyle"
  !insertmacro MUI_INSTALLOPTIONS_READ "${L_OLD_GUI}" "ioA.ini" "UI Port" "OldStyle"

  Push ${L_OLD_GUI}
  Call StrCheckDecimal
  Pop ${L_OLD_GUI}
  StrCmp ${L_OLD_GUI} "" try_other_port

  DetailPrint "$(PFI_LANG_INST_LOG_1) ${L_OLD_GUI} [old style port]"
  NSISdl::download_quiet http://127.0.0.1:${L_OLD_GUI}/shutdown "$PLUGINSDIR\shutdown.htm"
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "success" check_exe

try_other_port:
  Push ${L_NEW_GUI}
  Call StrCheckDecimal
  Pop ${L_NEW_GUI}
  StrCmp ${L_NEW_GUI} "" check_exe

  DetailPrint "$(PFI_LANG_INST_LOG_1) ${L_NEW_GUI} [new style port]"
  NSISdl::download_quiet http://127.0.0.1:${L_NEW_GUI}/shutdown "$PLUGINSDIR\shutdown.htm"
  Pop ${L_RESULT} ; Ignore the result

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
  Pop ${L_OLD_GUI}
  Pop ${L_NEW_GUI}
  Pop ${L_EXE}
  Pop ${L_CFG}

  !undef L_CFG
  !undef L_EXE
  !undef L_NEW_GUI
  !undef L_OLD_GUI
  !undef L_RESULT
FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: CheckExistingConfig
# (the "leave" function for the DIRECTORY selection page)
#
# This function is used to extract the POP3 and UI ports from the 'popfile.cfg'
# configuration file (if any) in the directory used for this installation.
#
# As it is possible that there are multiple entries for these parameters in the file,
# this function removes them all as it makes a new copy of the file. New port data
# entries will be added to this copy and the original updated (and backed up) when
# the "POPFile" section of the installer is executed.
#
# If the user has selected the optional 'Languages' component then this function also strips
# out the POPFile UI language setting to allow the installer to easily preset the UI language
# to match the language selected for use by the installer. (See the code which handles the
# 'Languages' component for further details). A copy of any settings found is kept in 'ioC.ini'
# for later use in the 'Languages' section.
#
# This function also ensures that only one copy of the tray icon & console settings is present,
# and saves (in 'ioC.ini') any values found for use when the user is offered the chance to start
# POPFile from the installer. If no setting is found, we save '?' in 'ioC.ini'. These settings
# are used by the 'StartPOPFilePage' and 'CheckLaunchOptions' functions.
#--------------------------------------------------------------------------

Function CheckExistingConfig

  !define L_CFG       $R9     ; handle for "popfile.cfg"
  !define L_CLEANCFG  $R8     ; handle for "clean" copy
  !define L_CMPRE     $R7     ; config param name
  !define L_LNE       $R6     ; a line from popfile.cfg
  !define L_OLDUI     $R5     ; used to hold old-style of GUI port
  !define L_STRIPLANG $R4
  !define L_TRAYICON  $R3     ; a config parameter used by popfile.exe
  !define L_CONSOLE   $R2     ; a config parameter used by popfile.exe
  !define L_LANG_NEW  $R1     ; new style UI lang parameter
  !define L_LANG_OLD  $R0     ; old style UI lang parameter

  ; Warn the user if we are about to upgrade an existing installation
  ; and allow user to select a different directory if they wish

  IfFileExists "$INSTDIR\popfile.pl" warning
  IfFileExists "$INSTDIR\popfile.cfg" warning
  Goto continue

warning:
  MessageBox MB_YESNO|MB_ICONQUESTION "$(PFI_LANG_DIRSELECT_MBWARN_1)\
      $\r$\n$\r$\n\
      $INSTDIR\
      $\r$\n$\r$\n$\r$\n\
      $(PFI_LANG_DIRSELECT_MBWARN_2)" IDYES continue
  Abort

continue:

  Push ${L_CFG}
  Push ${L_CLEANCFG}
  Push ${L_CMPRE}
  Push ${L_LNE}
  Push ${L_OLDUI}
  Push ${L_STRIPLANG}
  Push ${L_TRAYICON}
  Push ${L_CONSOLE}
  Push ${L_LANG_NEW}
  Push ${L_LANG_OLD}

  ; If the 'Languages' component is being installed, installer is allowed to preset UI language

  !insertmacro SectionFlagIsSet ${SecLangs} 1 strip nostrip

strip:
  StrCpy ${L_STRIPLANG} "yes"
  Goto init_port_vars

nostrip:
  StrCpy ${L_STRIPLANG} ""

init_port_vars:
  StrCpy $G_POP3 ""
  StrCpy $G_GUI ""
  StrCpy ${L_OLDUI} ""

  StrCpy ${L_TRAYICON} ""
  StrCpy ${L_CONSOLE} ""

  StrCpy ${L_LANG_NEW} ""
  StrCpy ${L_LANG_OLD} ""

  ; See if we can get the current pop3 and gui port from an existing configuration.
  ; There may be more than one entry for these ports in the file - use the last one found
  ; (but give priority to any "html_port" entry).

  ClearErrors

  FileOpen  ${L_CFG} $INSTDIR\popfile.cfg r
  FileOpen  ${L_CLEANCFG} $PLUGINSDIR\popfile.cfg w

loop:
  FileRead   ${L_CFG} ${L_LNE}
  IfErrors done

  StrCpy ${L_CMPRE} ${L_LNE} 5
  StrCmp ${L_CMPRE} "port " got_port

  StrCpy ${L_CMPRE} ${L_LNE} 10
  StrCmp ${L_CMPRE} "pop3_port " got_pop3_port
  StrCmp ${L_CMPRE} "html_port " got_html_port

  StrCpy ${L_CMPRE} ${L_LNE} 8
  StrCmp ${L_CMPRE} "ui_port " got_ui_port

  StrCpy ${L_CMPRE} ${L_LNE} 17
  StrCmp ${L_CMPRE} "windows_trayicon " got_trayicon
  StrCpy ${L_CMPRE} ${L_LNE} 16
  StrCmp ${L_CMPRE} "windows_console " got_console

  StrCmp ${L_STRIPLANG} "" transfer

  ; do not transfer any UI language settings to the copy of popfile.cfg

  StrCpy ${L_CMPRE} ${L_LNE} 9
  StrCmp ${L_CMPRE} "language " got_lang_old
  StrCpy ${L_CMPRE} ${L_LNE} 14
  StrCmp ${L_CMPRE} "html_language " got_lang_new

transfer:
  FileWrite  ${L_CLEANCFG} ${L_LNE}
  Goto loop

got_port:
  StrCpy $G_POP3 ${L_LNE} 5 5
  Goto loop

got_pop3_port:
  StrCpy $G_POP3 ${L_LNE} 5 10
  Goto loop

got_ui_port:
  StrCpy ${L_OLDUI} ${L_LNE} 5 8
  Goto loop

got_html_port:
  StrCpy $G_GUI ${L_LNE} 5 10
  Goto loop

got_trayicon:
  StrCpy ${L_TRAYICON} ${L_LNE} 1 17
  Goto loop

got_console:
  StrCpy ${L_CONSOLE} ${L_LNE} 1 16
  Goto loop

got_lang_new:
  StrCpy ${L_LANG_NEW} ${L_LNE} "" 14
  Goto loop

got_lang_old:
  StrCpy ${L_LANG_OLD} ${L_LNE} "" 9
  Goto loop

done:
  FileClose ${L_CFG}

  ; Before closing the clean copy of 'popfile.cfg' we add the most recent settings for the
  ; system tray icon and console mode, if valid values were found. If no valid values were
  ; found, we add nothing to the clean copy. A record of our findings is stored in 'ioC.ini'
  ; for use by 'StartPOPFilePage' and 'CheckLaunchOptions'.

  StrCmp ${L_CONSOLE} "0" found_console
  StrCmp ${L_CONSOLE} "1" found_console
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Inherited" "Console" "?"
  Goto check_trayicon

found_console:
  FileWrite ${L_CLEANCFG} "windows_console ${L_CONSOLE}$\r$\n"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Inherited" "Console" "${L_CONSOLE}"

check_trayicon:
  StrCmp ${L_TRAYICON} "0" found_trayicon
  StrCmp ${L_TRAYICON} "1" found_trayicon
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Inherited" "TrayIcon" "?"
  Goto close_cleancopy

found_trayicon:
  FileWrite ${L_CLEANCFG} "windows_trayicon ${L_TRAYICON}$\r$\n"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Inherited" "TrayIcon" "${L_TRAYICON}"

close_cleancopy:
  FileClose ${L_CLEANCFG}

  ; We save the UI language settings for later use when the 'Languages' section is processed
  ; (if no settings were found, we save '?'). If 'Languages' component is not selected, these
  ; saved settings will not be used (any existing settings were copied to the new 'popfile.cfg')

  Push ${L_LANG_NEW}
  Call TrimNewlines
  Pop ${L_LANG_NEW}
  StrCmp ${L_LANG_NEW} "" 0 check_lang_old
  StrCpy ${L_LANG_NEW} "?"

check_lang_old:
  Push ${L_LANG_OLD}
  Call TrimNewlines
  Pop ${L_LANG_OLD}
  StrCmp ${L_LANG_OLD} "" 0 save_langs
  StrCpy ${L_LANG_OLD} "?"

save_langs:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Inherited" "html_language" "${L_LANG_NEW}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Inherited" "language" "${L_LANG_OLD}"

  Push $G_POP3
  Call TrimNewlines
  Pop $G_POP3

  Push $G_GUI
  Call TrimNewlines
  Pop $G_GUI

  Push ${L_OLDUI}
  Call TrimNewlines
  Pop ${L_OLDUI}

  ; Save the UI port settings (from popfile.cfg) for later use by the 'MakeItSafe' function

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioA.ini" "UI Port" "NewStyle" "$G_GUI"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioA.ini" "UI Port" "OldStyle" "${L_OLDUI}"

  ; The 'port' and 'pop3_port' settings are treated as equals so we use the last entry found.
  ; If 'ui_port' and 'html_port' settings were found, we use the last 'html_port' we found.

  StrCmp $G_GUI "" 0 validity_checks
  StrCpy $G_GUI ${L_OLDUI}

validity_checks:

  ; check port values (config file may have no port data or invalid port data)

  StrCmp $G_POP3 $G_GUI 0 ports_differ

  ; Config file has no port data or same port used for POP3 and GUI
  ; (i.e. the data is not valid), so use POPFile defaults

  StrCpy $G_POP3 "110"
  StrCpy $G_GUI "8080"
  Goto ports_ok

ports_differ:
  StrCmp $G_POP3 "" default_pop3
  Push $G_POP3
  Call StrCheckDecimal
  Pop $G_POP3
  StrCmp $G_POP3 "" default_pop3
  IntCmp $G_POP3 1 pop3_ok default_pop3
  IntCmp $G_POP3 65535 pop3_ok pop3_ok

default_pop3:
  StrCpy $G_POP3 "110"
  StrCmp $G_POP3 $G_GUI 0 pop3_ok
  StrCpy $G_POP3 "111"

pop3_ok:
  StrCmp $G_GUI "" default_gui
  Push $G_GUI
  Call StrCheckDecimal
  Pop $G_GUI
  StrCmp $G_GUI "" default_gui
  IntCmp $G_GUI 1 ports_ok default_gui
  IntCmp $G_GUI 65535 ports_ok ports_ok

default_gui:
  StrCpy $G_GUI "8080"
  StrCmp $G_POP3 $G_GUI 0 ports_ok
  StrCpy $G_GUI "8081"

ports_ok:
  Pop ${L_LANG_OLD}
  Pop ${L_LANG_NEW}
  Pop ${L_CONSOLE}
  Pop ${L_TRAYICON}
  Pop ${L_STRIPLANG}
  Pop ${L_OLDUI}
  Pop ${L_LNE}
  Pop ${L_CMPRE}
  Pop ${L_CLEANCFG}
  Pop ${L_CFG}

  !undef L_CFG
  !undef L_CLEANCFG
  !undef L_CMPRE
  !undef L_LNE
  !undef L_OLDUI
  !undef L_STRIPLANG
  !undef L_TRAYICON
  !undef L_CONSOLE
  !undef L_LANG_NEW
  !undef L_LANG_OLD

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: SetOptionsPage_Init
#
# This function adds language texts to the INI file used by the "SetOptionsPage" function
# (to make the custom page use the language selected by the user for the installer)
#--------------------------------------------------------------------------

Function SetOptionsPage_Init

  ; Ensure custom page matches the selected language (left-to-right or right-to-left order)

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioA.ini" "Settings" "RTL" "$(^RTL)"

  !insertmacro PFI_IO_TEXT "ioA.ini" "1" "$(PFI_LANG_OPTIONS_IO_POP3)"
  !insertmacro PFI_IO_TEXT "ioA.ini" "3" "$(PFI_LANG_OPTIONS_IO_GUI)"
  !insertmacro PFI_IO_TEXT "ioA.ini" "5" "$(PFI_LANG_OPTIONS_IO_STARTUP)"
  !insertmacro PFI_IO_TEXT "ioA.ini" "6" "$(PFI_LANG_OPTIONS_IO_WARNING)"
  !insertmacro PFI_IO_TEXT "ioA.ini" "7" "$(PFI_LANG_OPTIONS_IO_MESSAGE)"

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: SetOptionsPage (generates a custom page)
#
# This function is used to configure the POP3 and UI ports, and
# whether or not POPFile should be started automatically when Windows starts.
#
# A "leave" function (CheckPortOptions) is used to validate the port
# selections made by the user.
#--------------------------------------------------------------------------

Function SetOptionsPage

  !define L_PORTLIST  $R9   ; combo box ports list
  !define L_RESULT    $R8

  Push ${L_PORTLIST}
  Push ${L_RESULT}

  ; The function "CheckExistingConfig" loads $G_POP3 and $G_GUI with the settings found in
  ; a previously installed "popfile.cfg" file or if no such file is found, it loads the
  ; POPFile default values. Now we display these settings and allow the user to change them.

  ; The POP3 and GUI port numbers must be in the range 1 to 65535 inclusive, and they
  ; must be different. This function assumes that the values "CheckExistingConfig" has loaded
  ; into $G_POP3 and $G_GUI are valid.

  !insertmacro MUI_HEADER_TEXT "$(PFI_LANG_OPTIONS_TITLE)" "$(PFI_LANG_OPTIONS_SUBTITLE)"

  ; If the POP3 (or GUI) port determined by "CheckExistingConfig" is not present in the list of
  ; possible values for the POP3 (or GUI) combobox, add it to the end of the list.

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_PORTLIST} "ioA.ini" "Field 2" "ListItems"
  Push |${L_PORTLIST}|
  Push |$G_POP3|
  Call StrStr
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "" 0 POP3_is_in_list
  StrCpy ${L_PORTLIST} ${L_PORTLIST}|$G_POP3
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioA.ini" "Field 2" "ListItems" ${L_PORTLIST}

POP3_is_in_list:
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_PORTLIST} "ioA.ini" "Field 4" "ListItems"
  Push |${L_PORTLIST}|
  Push |$G_GUI|
  Call StrStr
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "" 0 GUI_is_in_list
  StrCpy ${L_PORTLIST} ${L_PORTLIST}|$G_GUI
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioA.ini" "Field 4" "ListItems" ${L_PORTLIST}

GUI_is_in_list:

  ; If the StartUp folder contains a link to start POPFile automatically
  ; then offer to keep this facility in place.

  IfFileExists "$SMSTARTUP\Run POPFile in background.lnk" 0 show_defaults
    !insertmacro MUI_INSTALLOPTIONS_WRITE "ioA.ini" "Field 5" "State" 1

show_defaults:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioA.ini" "Field 2" "State" $G_POP3
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioA.ini" "Field 4" "State" $G_GUI

  ; Now display the custom page and wait for the user to make their selections.
  ; The function "CheckPortOptions" will check the validity of the selections
  ; and refuse to proceed until suitable ports have been chosen.

  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioA.ini"

  ; Store validated data (for use when the "POPFile" section is processed)

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioA.ini" "Field 2" "State" $G_POP3
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioA.ini" "Field 4" "State" $G_GUI

  Pop ${L_RESULT}
  Pop ${L_PORTLIST}

  !undef L_PORTLIST
  !undef L_RESULT

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: CheckPortOptions
# (the "leave" function for the custom page created by "SetOptionsPage")
#
# This function is used to validate the POP3 and UI ports selected by the user.
# If the selections are not valid, user is asked to select alternative values.
#--------------------------------------------------------------------------

Function CheckPortOptions

  !define L_RESULT    $R9

  Push ${L_RESULT}

  !insertmacro MUI_INSTALLOPTIONS_READ $G_POP3 "ioA.ini" "Field 2" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $G_GUI "ioA.ini" "Field 4" "State"

  ; strip leading zeroes and spaces from user input

  Push $G_POP3
  Call StrStripLZS
  Pop $G_POP3
  Push $G_GUI
  Call StrStripLZS
  Pop $G_GUI

  StrCmp $G_POP3 $G_GUI ports_must_differ
  Push $G_POP3
  Call StrCheckDecimal
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "" bad_pop3
  IntCmp $G_POP3 1 pop3_ok bad_pop3
  IntCmp $G_POP3 65535 pop3_ok pop3_ok

bad_pop3:
  MessageBox MB_OK|MB_ICONEXCLAMATION \
      "$(PFI_LANG_OPTIONS_MBPOP3_1) $\"$G_POP3$\"'.\
      $\r$\n$\r$\n\
      $(PFI_LANG_OPTIONS_MBPOP3_2)\
      $\r$\n$\r$\n\
      $(PFI_LANG_OPTIONS_MBPOP3_3)"
  Goto bad_exit

pop3_ok:
  Push $G_GUI
  Call StrCheckDecimal
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "" bad_gui
  IntCmp $G_GUI 1 good_exit bad_gui
  IntCmp $G_GUI 65535 good_exit good_exit

bad_gui:
  MessageBox MB_OK|MB_ICONEXCLAMATION \
      "$(PFI_LANG_OPTIONS_MBGUI_1) $\"$G_GUI$\".\
      $\r$\n$\r$\n\
      $(PFI_LANG_OPTIONS_MBGUI_2)\
      $\r$\n$\r$\n\
      $(PFI_LANG_OPTIONS_MBGUI_3)"
  Goto bad_exit

ports_must_differ:
  MessageBox MB_OK|MB_ICONEXCLAMATION \
      "$(PFI_LANG_OPTIONS_MBDIFF_1)\
      $\r$\n$\r$\n\
      $(PFI_LANG_OPTIONS_MBDIFF_2)"

bad_exit:

  ; Stay with the custom page created by "SetOptionsPage"

  Pop ${L_RESULT}
  Abort

good_exit:

  ; Allow next page in the installation sequence to be shown

  Pop ${L_RESULT}

  !undef L_RESULT

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: SetEmailClientPage_Init
#
# This function adds language texts to the INI file used by "SetEmailClientPage" function
# (to make the custom page use the language selected by the user for the installer)
#--------------------------------------------------------------------------

Function SetEmailClientPage_Init

  ; Ensure custom page matches the selected language (left-to-right or right-to-left order)

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioF.ini" "Settings" "RTL" "$(^RTL)"

  !insertmacro PFI_IO_TEXT "ioF.ini" "1" "$(PFI_LANG_MAILCFG_IO_TEXT_1)"
  !insertmacro PFI_IO_TEXT "ioF.ini" "3" "$(PFI_LANG_MAILCFG_IO_TEXT_2)"

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: SetEmailClientPage (generates a custom page)
#
# This function is used to introduce the reconfiguration of email clients
#--------------------------------------------------------------------------

Function SetEmailClientPage

  !define L_CLIENT_INDEX    $R9
  !define L_CLIENT_LIST     $R8
  !define L_CLIENT_NAME     $R7
  !define L_CLIENT_TYPE     $R6   ; used to indicate if client can be reconfigured by installer
  !define L_SEPARATOR       $R5
  !define L_TEMP            $R4

  Push ${L_CLIENT_INDEX}
  Push ${L_CLIENT_LIST}
  Push ${L_CLIENT_NAME}
  Push ${L_CLIENT_TYPE}
  Push ${L_SEPARATOR}
  Push ${L_TEMP}

  !insertmacro MUI_HEADER_TEXT "$(PFI_LANG_MAILCFG_TITLE)" "$(PFI_LANG_MAILCFG_SUBTITLE)"

  StrCpy ${L_CLIENT_INDEX} 0
  StrCpy ${L_CLIENT_LIST} ""
  StrCpy ${L_SEPARATOR} ""

read_next_name:
  EnumRegKey ${L_CLIENT_NAME} HKLM "Software\Clients\Mail" ${L_CLIENT_INDEX}
  StrCmp ${L_CLIENT_NAME} "" display_results
  StrCmp ${L_CLIENT_NAME} "Hotmail" incrm_index
  Push "|Microsoft Outlook|Outlook Express|Eudora|"
  Push "|${L_CLIENT_NAME}|"
  Call StrStr
  Pop ${L_CLIENT_TYPE}
  StrCmp ${L_CLIENT_TYPE} "" add_to_list
  StrCpy ${L_CLIENT_TYPE} " (*)"

  ReadRegStr ${L_TEMP} HKLM "Software\Clients\Mail\${L_CLIENT_NAME}\shell\open\command" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioF.ini" "ClientEXE" "${L_CLIENT_NAME}" "${L_TEMP}"

add_to_list:
  StrCpy ${L_CLIENT_LIST} "${L_CLIENT_LIST}${L_SEPARATOR}${L_CLIENT_NAME}${L_CLIENT_TYPE}"
  StrCpy ${L_SEPARATOR} "\r\n"

incrm_index:
  IntOp ${L_CLIENT_INDEX} ${L_CLIENT_INDEX} + 1
  Goto read_next_name

display_results:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioF.ini" "Field 2" "State" "${L_CLIENT_LIST}"

  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioF.ini"

  Pop ${L_TEMP}
  Pop ${L_SEPARATOR}
  Pop ${L_CLIENT_TYPE}
  Pop ${L_CLIENT_NAME}
  Pop ${L_CLIENT_LIST}
  Pop ${L_CLIENT_INDEX}

  !undef L_CLIENT_INDEX
  !undef L_CLIENT_LIST
  !undef L_CLIENT_NAME
  !undef L_CLIENT_TYPE
  !undef L_SEPARATOR
  !undef L_TEMP

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: SetOutlookOutlookExpressPage_Init
#
# This function adds language texts to the INI file used by "SetOutlookExpressPage" function
# and by the "SetOutlookPage" function (to make the custom page use the language selected by
# the user for the installer)
#--------------------------------------------------------------------------

Function SetOutlookOutlookExpressPage_Init

  ; Ensure custom page matches the selected language (left-to-right or right-to-left order)

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioB.ini" "Settings" "RTL" "$(^RTL)"

  !insertmacro PFI_IO_TEXT "ioB.ini" "1" "$(PFI_LANG_OOECFG_IO_BOXHDR)"
  !insertmacro PFI_IO_TEXT "ioB.ini" "3" "$(PFI_LANG_OOECFG_IO_FOOTNOTE)"
  !insertmacro PFI_IO_TEXT "ioB.ini" "4" "$(PFI_LANG_OOECFG_IO_ACCOUNTHDR)"
  !insertmacro PFI_IO_TEXT "ioB.ini" "5" "$(PFI_LANG_OOECFG_IO_EMAILHDR)"
  !insertmacro PFI_IO_TEXT "ioB.ini" "6" "$(PFI_LANG_OOECFG_IO_SERVERHDR)"
  !insertmacro PFI_IO_TEXT "ioB.ini" "7" "$(PFI_LANG_OOECFG_IO_USRNAMEHDR)"

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: SetOutlookExpressPage (generates a custom page)
#
# This function is used to reconfigure Outlook Express accounts
#--------------------------------------------------------------------------

Function SetOutlookExpressPage

  ; More than one "identity" can be created in OE. Each of these identities is
  ; given a GUID and these GUIDs are stored in HKEY_CURRENT_USER\Identities.

  ; Each identity can have several email accounts and the details for these
  ; accounts are grouped according to the GUID which "owns" the accounts.

  ; We step through every identity defined in HKEY_CURRENT_USER\Identities and
  ; for each one found check its OE email account data.

  ; When OE is installed, it (usually) creates an initial identity which stores its
  ; email account data in a fixed registry location. If an identity with an "Identity Ordinal"
  ; value of 1 is found, we need to look for its OE email account data in
  ;
  ;     HKEY_CURRENT_USER\Software\Microsoft\Internet Account Manager\Accounts
  ;
  ; otherwise we look in the GUID's entry in HKEY_CURRENT_USER\Identities, using the path
  ;
  ;     HKEY_CURRENT_USER\Identities\{GUID}\Software\Microsoft\Internet Account Manager\Accounts

  ; All of the OE account data for an identity appears "under" the path defined
  ; above, e.g. if an identity has several accounts, the account data is stored like this:
  ;    HKEY_CURRENT_USER\...\Internet Account Manager\Accounts\00000001
  ;    HKEY_CURRENT_USER\...\Internet Account Manager\Accounts\00000002
  ;    etc

  !define L_ACCOUNT     $R9   ; path to the data for the current OE account (less the HKCU part)
  !define L_ACCT_INDEX  $R8   ; used to loop through OE accounts for the current OE Identity
  !define L_CFG         $R7   ; file handle
  !define L_GUID        $R6   ; GUID of the current entry in HKCU\Identities list
  !define L_GUID_INDEX  $R5   ; used to loop through the list of OE Identities
  !define L_IDENTITY    $R4   ; plain text form of OE Identity name
  !define L_OEDATA      $R3   ; some data (it varies) for current OE account
  !define L_OEPATH      $R2   ; holds part of the path used to access OE account data
  !define L_ORDINALS    $R1   ; "Identity Ordinals" flag (1 = found, 0 = not found)
  !define L_PORT        $R0   ; POP3 Port used for an OE Account
  !define L_STATUS      $9    ; keeps track of the status of the account we are checking
  !define L_TEMP        $8

  !define L_POP3SERVER    $7
  !define L_EMAILADDRESS  $6
  !define L_USERNAME      $5

  Push ${L_ACCOUNT}
  Push ${L_ACCT_INDEX}
  Push ${L_CFG}
  Push ${L_GUID}
  Push ${L_GUID_INDEX}
  Push ${L_IDENTITY}
  Push ${L_OEDATA}
  Push ${L_OEPATH}
  Push ${L_ORDINALS}
  Push ${L_PORT}
  Push ${L_STATUS}
  Push ${L_TEMP}

  Push ${L_POP3SERVER}
  Push ${L_EMAILADDRESS}
  Push ${L_USERNAME}

  !insertmacro MUI_HEADER_TEXT "$(PFI_LANG_EXPCFG_TITLE)" "$(PFI_LANG_EXPCFG_SUBTITLE)"

  ; If Outlook Express is running, ask the user to shut it down now
  ; (user is allowed to ignore our request)

check_again:
  FindWindow ${L_STATUS} "Outlook Express Browser Class"
  IsWindow ${L_STATUS} 0 open_logfiles

  MessageBox MB_ABORTRETRYIGNORE|MB_ICONSTOP|MB_DEFBUTTON2 "$(PFI_LANG_MBCLIENT_EXP)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_1)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_2)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_3)"\
             IDRETRY check_again IDIGNORE open_logfiles

  ; Abort has been selected so we do not offer to reconfigure any Outlook Express accounts

  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioB.ini" "Settings" "NumFields" "1"
  !insertmacro PFI_IO_TEXT "ioB.ini" "1" "$(PFI_LANG_EXPCFG_IO_CANCELLED)"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioB.ini"
  Goto exit

open_logfiles:
  Call GetDateTimeStamp
  Pop ${L_TEMP}

  FileOpen  $G_OOECONFIG_HANDLE "$INSTDIR\expconfig.txt" w
  FileWrite $G_OOECONFIG_HANDLE "$(PFI_LANG_EXPCFG_LOG_BEFORE) (${L_TEMP})$\r$\n$\r$\n"
  !insertmacro OOECONFIG_BEFORE_LOG  "$(PFI_LANG_EXPCFG_LOG_IDENTITY)"  20
  !insertmacro OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OOECFG_LOG_ACCOUNT)"   20
  !insertmacro OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OOECFG_LOG_EMAIL)"     30
  !insertmacro OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OOECFG_LOG_SERVER)"    20
  !insertmacro OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OOECFG_LOG_USER)"      20
  FileWrite $G_OOECONFIG_HANDLE "$(PFI_LANG_OOECFG_LOG_PORT)$\r$\n$\r$\n"

  FileOpen  $G_OOECHANGES_HANDLE "$INSTDIR\expchanges.txt" a
  FileSeek  $G_OOECHANGES_HANDLE 0 END
  FileWrite $G_OOECHANGES_HANDLE "$(PFI_LANG_ExpCFG_LOG_AFTER) (${L_TEMP})$\r$\n$\r$\n"
  !insertmacro OOECONFIG_CHANGES_LOG  "$(PFI_LANG_EXPCFG_LOG_IDENTITY)"   20
  !insertmacro OOECONFIG_CHANGES_LOG  "$(PFI_LANG_OOECFG_LOG_ACCOUNT)"    20
  !insertmacro OOECONFIG_CHANGES_LOG  "$(PFI_LANG_OOECFG_LOG_NEWSERVER)"  17
  !insertmacro OOECONFIG_CHANGES_LOG  "$(PFI_LANG_OOECFG_LOG_NEWUSER)"    40
  FileWrite $G_OOECHANGES_HANDLE "$(PFI_LANG_OOECFG_LOG_NEWPORT)$\r$\n$\r$\n"

  ; Determine the separator character to be used when configuring an email account for POPFile

  Call GetSeparator
  Pop $G_SEPARATOR

  ; Start with an empty list of accounts and reset the list "pointers"

  Call ResetOutlookOutlookExpressAccountList

  StrCpy ${L_GUID_INDEX} 0

  ; Get the next identity from the registry

get_guid:
  EnumRegKey ${L_GUID} HKCU "Identities" ${L_GUID_INDEX}
  StrCmp ${L_GUID} "" finished_oe_config

  ; Check if this is the GUID for the first "Main Identity" created by OE as the account data
  ; for that identity is stored separately from the account data for the other OE identities.
  ; If no "Identity Ordinal" value found, use the first "Main Identity" created by OE.

  StrCpy ${L_ORDINALS} "1"

  ReadRegDWORD ${L_TEMP} HKCU "Identities\${L_GUID}" "Identity Ordinal"
  IntCmp ${L_TEMP} 1 firstOrdinal noOrdinals otherOrdinal

firstOrdinal:
  StrCpy ${L_OEPATH} ""
  goto check_accounts

noOrdinals:
  StrCpy ${L_ORDINALS} "0"
  StrCpy ${L_OEPATH} ""
  goto check_accounts

otherOrdinal:
  StrCpy ${L_OEPATH} "Identities\${L_GUID}\"

check_accounts:

  ; Now check all of the accounts for the current OE Identity

  StrCpy ${L_ACCT_INDEX} 0

next_acct:

  ; Reset the text string used to keep track of the status of the email account we are checking

  StrCpy ${L_STATUS} ""

  EnumRegKey ${L_ACCOUNT} \
             HKCU "${L_OEPATH}Software\Microsoft\Internet Account Manager\Accounts" \
             ${L_ACCT_INDEX}
  StrCmp ${L_ACCOUNT} "" finished_this_guid
  StrCpy ${L_ACCOUNT} \
        "${L_OEPATH}Software\Microsoft\Internet Account Manager\Accounts\${L_ACCOUNT}"

  ; Now extract the POP3 Server data, if this does not exist then this account is
  ; not configured for mail so move on. If the data is "127.0.0.1" assume the account has
  ; already been configured for use with POPFile.

  ReadRegStr ${L_OEDATA} HKCU ${L_ACCOUNT} "POP3 Server"
  StrCmp ${L_OEDATA} "" try_next_account

  ; Have found an email account so we add a new entry to the list (which can hold 6 accounts)

  IntOp $G_OOELIST_INDEX $G_OOELIST_INDEX + 1    ; used to access the [Account] data in ioB.ini
  IntOp $G_OOELIST_CBOX $G_OOELIST_CBOX + 1      ; field number for relevant checkbox

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Settings" "NumFields" "$G_OOELIST_CBOX"

  StrCmp ${L_OEDATA} "127.0.0.1" 0 check_pop3_server
  StrCpy ${L_STATUS} "bad IP"
  Goto check_pop3_username

check_pop3_server:

  ; If 'POP3 Server' data contains the separator character, we cannot configure this account

  Push ${L_OEDATA}
  Push $G_SEPARATOR
  Call StrStr
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" check_pop3_username
  StrCpy ${L_STATUS} "bad servername"

check_pop3_username:

  ; Prepare to display the 'POP3 Server' data

  StrCpy ${L_POP3SERVER} ${L_OEDATA}

  ReadRegStr ${L_OEDATA} HKCU ${L_ACCOUNT} "SMTP Email Address"

  StrCpy ${L_EMAILADDRESS} ${L_OEDATA}

  ReadRegDWORD ${L_PORT} HKCU ${L_ACCOUNT} "POP3 Port"
  StrCmp ${L_PORT} "" 0 port_ok
  StrCpy ${L_PORT} "110"

port_ok:
  ReadRegStr ${L_OEDATA} HKCU ${L_ACCOUNT} "POP3 User Name"
  StrCpy ${L_USERNAME} ${L_OEDATA}
  StrCmp ${L_USERNAME} "" bad_username

  ; If 'POP3 User Name' data contains the separator character, we cannot configure this account

  Push ${L_OEDATA}
  Push $G_SEPARATOR
  Call StrStr
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" configurable
  StrCmp ${L_STATUS} "" 0 configurable

bad_username:
  StrCpy ${L_STATUS} "bad username"
  Goto continue

configurable:
  StrCmp ${L_STATUS} "" 0 continue
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field $G_OOELIST_CBOX" "Flags" ""

continue:

  ; Find the Username used by OE for this identity and the OE Account Name
  ; (so we can unambiguously report which email account we are offering to reconfigure).

  ReadRegStr ${L_IDENTITY} HKCU "Identities\${L_GUID}\" "Username"
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 1" "Text" "'${L_IDENTITY}' $(PFI_LANG_OOECFG_IO_BOXHDR)"
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Identity" "Username" "${L_IDENTITY}"

  ReadRegStr ${L_OEDATA} HKCU ${L_ACCOUNT} "Account Name"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 8" "State"
  StrCpy ${L_TEMP} ""
  StrCmp ${L_STATUS} "" no_padding
  StrCpy ${L_TEMP} "\r\n\r\n"

no_padding:
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Field 8" "State" "${L_STATUS}${L_TEMP}${L_OEDATA}"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 9" "State"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Field 9" "State" "${L_STATUS}${L_TEMP}${L_EMAILADDRESS}"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 10" "State"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Field 10" "State" "${L_STATUS}${L_TEMP}${L_POP3SERVER}"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 11" "State"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Field 11" "State" "${L_STATUS}${L_TEMP}${L_USERNAME}"

  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Account $G_OOELIST_INDEX" "AccountName" "${L_OEDATA}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Account $G_OOELIST_INDEX" "EmailAddress" "${L_EMAILADDRESS}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Account $G_OOELIST_INDEX" "POP3server" "${L_POP3SERVER}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Account $G_OOELIST_INDEX" "POP3username" "${L_USERNAME}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Account $G_OOELIST_INDEX" "POP3port" "${L_PORT}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Account $G_OOELIST_INDEX" "RegistryKey" "${L_ACCOUNT}"

  !insertmacro OOECONFIG_BEFORE_LOG  "${L_IDENTITY}"     20
  !insertmacro OOECONFIG_BEFORE_LOG  "${L_OEDATA}"       20
  !insertmacro OOECONFIG_BEFORE_LOG  "${L_EMAILADDRESS}" 30
  !insertmacro OOECONFIG_BEFORE_LOG  "${L_POP3SERVER}"   20
  !insertmacro OOECONFIG_BEFORE_LOG  "${L_USERNAME}"     20
  FileWrite $G_OOECONFIG_HANDLE "${L_PORT}$\r$\n"

  IntCmp $G_OOELIST_INDEX 6 display_list try_next_account try_next_account

display_list:

  ; Display the OE account data with checkboxes enabled for those accounts we can configure

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Identity" "PageStatus" "new"

  !insertmacro MUI_INSTALLOPTIONS_INITDIALOG "ioB.ini"
  Pop $G_HWND                 ; HWND of dialog we want to modify

  ; In 'GetDlgItem', use (1200 + Field number - 1) to refer to the field to be changed

  GetDlgItem $G_DLGITEM $G_HWND 1200             ; Field 1 = IDENTITY label (above the box)
  CreateFont $G_FONT "MS Shell Dlg" 8 700        ; use a 'bolder' version of the font in use
  SendMessage $G_DLGITEM ${WM_SETFONT} $G_FONT 0

  !insertmacro MUI_INSTALLOPTIONS_SHOW_RETURN
  Pop ${L_TEMP}

  StrCmp ${L_TEMP} "cancel" finished_this_guid
  StrCmp ${L_TEMP} "back" finished_this_guid

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioB.ini" "Identity" "PageStatus"
  StrCmp ${L_TEMP} "updated" display_list
  StrCmp ${L_TEMP} "leftover_ticks" display_list

  Call ResetOutlookOutlookExpressAccountList

try_next_account:
  IntOp ${L_ACCT_INDEX} ${L_ACCT_INDEX} + 1
  goto next_acct

finished_this_guid:
  IntCmp $G_OOELIST_INDEX 0 continue_guid continue_guid

display_list_again:
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Identity" "PageStatus" "new"

  !insertmacro MUI_INSTALLOPTIONS_INITDIALOG "ioB.ini"
  Pop $G_HWND                 ; HWND of dialog we want to modify

  ; In 'GetDlgItem', use (1200 + Field number - 1) to refer to the field to be changed

  GetDlgItem $G_DLGITEM $G_HWND 1200             ; Field 1 = IDENTITY label (above the box)
  CreateFont $G_FONT "MS Shell Dlg" 8 700        ; use a 'bolder' version of the font in use
  SendMessage $G_DLGITEM ${WM_SETFONT} $G_FONT 0

  !insertmacro MUI_INSTALLOPTIONS_SHOW_RETURN
  Pop ${L_TEMP}

  StrCmp ${L_TEMP} "cancel" finished_this_guid
  StrCmp ${L_TEMP} "back" finished_this_guid

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioB.ini" "Identity" "PageStatus"
  StrCmp ${L_TEMP} "updated" display_list_again
  StrCmp ${L_TEMP} "leftover_ticks" display_list_again

  Call ResetOutlookOutlookExpressAccountList

continue_guid:

  ; If no "Identity Ordinal" values were found then exit otherwise move on to the next identity

  StrCmp ${L_ORDINALS} "0" finished_oe_config

  IntOp ${L_GUID_INDEX} ${L_GUID_INDEX} + 1
  goto get_guid

finished_oe_config:
  FileWrite $G_OOECONFIG_HANDLE "$\r$\n$(PFI_LANG_OOECFG_LOG_END)$\r$\n$\r$\n"
  FileClose $G_OOECONFIG_HANDLE

  FileWrite $G_OOECHANGES_HANDLE "$\r$\n$(PFI_LANG_OOECFG_LOG_END)$\r$\n$\r$\n"
  FileClose $G_OOECHANGES_HANDLE

exit:
  Pop ${L_USERNAME}
  Pop ${L_EMAILADDRESS}
  Pop ${L_POP3SERVER}

  Pop ${L_TEMP}
  Pop ${L_STATUS}
  Pop ${L_PORT}
  Pop ${L_ORDINALS}
  Pop ${L_OEPATH}
  Pop ${L_OEDATA}
  Pop ${L_IDENTITY}
  Pop ${L_GUID_INDEX}
  Pop ${L_GUID}
  Pop ${L_CFG}
  Pop ${L_ACCT_INDEX}
  Pop ${L_ACCOUNT}

  !undef L_ACCOUNT
  !undef L_ACCT_INDEX
  !undef L_CFG
  !undef L_GUID
  !undef L_GUID_INDEX
  !undef L_IDENTITY
  !undef L_OEDATA
  !undef L_OEPATH
  !undef L_ORDINALS
  !undef L_PORT
  !undef L_STATUS
  !undef L_TEMP

  !undef L_POP3SERVER
  !undef L_EMAILADDRESS
  !undef L_USERNAME

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: ResetOutlookOutlookExpressAccountList
#
# This function is used to empty the list used to display up to 6 accounts for a given identity
#--------------------------------------------------------------------------

Function ResetOutlookOutlookExpressAccountList

  !define L_CBOX_INDEX   $R9
  !define L_TEXT_INDEX   $R8

  Push ${L_CBOX_INDEX}
  Push ${L_TEXT_INDEX}

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Settings" "NumFields" "11"

  StrCpy $G_OOELIST_INDEX     0    ; values 1 to 6 used to access the list
  StrCpy $G_OOELIST_CBOX     11    ; first entry uses field 12

  StrCpy ${L_CBOX_INDEX} 12

next_row:
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field ${L_CBOX_INDEX}" "State" "0"
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field ${L_CBOX_INDEX}" "Flags" "DISABLED"

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 8" "State" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 9" "State" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 10" "State" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 11" "State" ""

  IntOp ${L_CBOX_INDEX} ${L_CBOX_INDEX} + 1
  IntCmp ${L_CBOX_INDEX} 17 next_row next_row

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Identity" "Username" ""

  StrCpy ${L_TEXT_INDEX} 1

next_account:
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Account ${L_TEXT_INDEX}" "AccountName" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Account ${L_TEXT_INDEX}" "EMailAddress" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Account ${L_TEXT_INDEX}" "POP3server" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Account ${L_TEXT_INDEX}" "POP3username" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Account ${L_TEXT_INDEX}" "POP3port" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Account ${L_TEXT_INDEX}" "RegistryKey" ""
  IntOp ${L_TEXT_INDEX} ${L_TEXT_INDEX} + 1
  IntCmp ${L_TEXT_INDEX} 6 next_account next_account

  Pop ${L_TEXT_INDEX}
  Pop ${L_CBOX_INDEX}

  !undef L_CBOX_INDEX
  !undef L_TEXT_INDEX

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: CheckOutlookExpressRequests
#
# This function is used to confirm any Outlook Express account reconfiguration requests
#--------------------------------------------------------------------------

Function CheckOutlookExpressRequests

  !define L_CBOX_INDEX   $R9
  !define L_CBOX_STATE   $R8
  !define L_DATA_INDEX   $R7
  !define L_REGKEY       $R6
  !define L_TEMP         $R5
  !define L_TEXT_ENTRY   $R4
  !define L_IDENTITY     $R3

  !define L_ACCOUNTNAME   $9
  !define L_EMAILADDRESS  $8
  !define L_POP3SERVER    $7
  !define L_POP3USERNAME  $6
  !define L_POP3PORT      $5

  Push ${L_CBOX_INDEX}
  Push ${L_CBOX_STATE}
  Push ${L_DATA_INDEX}
  Push ${L_REGKEY}
  Push ${L_TEMP}
  Push ${L_TEXT_ENTRY}
  Push ${L_IDENTITY}

  Push ${L_ACCOUNTNAME}
  Push ${L_EMAILADDRESS}
  Push ${L_POP3SERVER}
  Push ${L_POP3USERNAME}
  Push ${L_POP3PORT}

  ; If user has cancelled the reconfiguration, there is nothing to do here

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioB.ini" "Settings" "NumFields"
  StrCmp ${L_TEMP} "1" exit

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_IDENTITY} "ioB.ini" "Identity" "Username"

  StrCpy ${L_CBOX_INDEX} 12
  StrCpy ${L_DATA_INDEX} 1

next_row:
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_CBOX_STATE} "ioB.ini" "Field ${L_CBOX_INDEX}" "Flags"
  StrCmp ${L_CBOX_STATE} "DISABLED" continue

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_CBOX_STATE} "ioB.ini" "Field ${L_CBOX_INDEX}" "State"
  StrCmp ${L_CBOX_STATE} "0" continue

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_ACCOUNTNAME}  "ioB.ini" "Account ${L_DATA_INDEX}" "AccountName"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_EMAILADDRESS} "ioB.ini" "Account ${L_DATA_INDEX}" "EMailAddress"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_POP3SERVER}   "ioB.ini" "Account ${L_DATA_INDEX}" "POP3server"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_POP3USERNAME} "ioB.ini" "Account ${L_DATA_INDEX}" "POP3username"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_POP3PORT}     "ioB.ini" "Account ${L_DATA_INDEX}" "POP3port"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_REGKEY}       "ioB.ini" "Account ${L_DATA_INDEX}" "RegistryKey"

  MessageBox MB_YESNO \
      "$(PFI_LANG_EXPCFG_MBIDENTITY) ${L_IDENTITY}\
      $\r$\n$\r$\n\
      $(PFI_LANG_EXPCFG_MBACCOUNT) ${L_ACCOUNTNAME}\
      $\r$\n$\r$\n\
      $(PFI_LANG_OOECFG_MBEMAIL) ${L_EMAILADDRESS}\
      $\r$\n$\r$\n\
      $(PFI_LANG_OOECFG_MBSERVER) 127.0.0.1 \
                                   ($(PFI_LANG_OOECFG_MBOLDVALUE) '${L_POP3SERVER}')\
      $\r$\n$\r$\n\
      $(PFI_LANG_OOECFG_MBUSERNAME) ${L_POP3SERVER}$G_SEPARATOR${L_POP3USERNAME} \
                                     ($(PFI_LANG_OOECFG_MBOLDVALUE) '${L_POP3USERNAME}')\
      $\r$\n$\r$\n\
      $(PFI_LANG_OOECFG_MBOEPORT) $G_POP3 \
                                   ($(PFI_LANG_OOECFG_MBOLDVALUE) '${L_POP3PORT}')\
      $\r$\n$\r$\n$\r$\n\
      $(PFI_LANG_OOECFG_MBQUESTION)\
      " IDNO ignore_tick

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Identity" "PageStatus" "updated"
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field ${L_CBOX_INDEX}" "Flags" "DISABLED"

  ; To be able to restore the registry to previous settings when we uninstall we
  ; write a special file called 'popfile.reg' containing the registry settings
  ; prior to modification.
  ;
  ; For each account we save 3 registry settings, each using 3 lines as follows:
  ;         "Registry key", "POP3 User Name", "original data",
  ;         "Registry key", "POP3 Server", "original data",
  ;         "Registry key", "POP3 Port", "original data"
  ;
  ; NB: This file format is compatible with previous releases of POPFile.

  FileOpen  ${L_TEMP} $INSTDIR\popfile.reg a
  FileSeek  ${L_TEMP} 0 END

  FileWrite ${L_TEMP} "${L_REGKEY}$\n"
  FileWrite ${L_TEMP} "POP3 User Name$\n"
  FileWrite ${L_TEMP} "${L_POP3USERNAME}$\n"

  FileWrite ${L_TEMP} "${L_REGKEY}$\n"
  FileWrite ${L_TEMP} "POP3 Server$\n"
  FileWrite ${L_TEMP} "${L_POP3SERVER}$\n"

  FileWrite ${L_TEMP} "${L_REGKEY}$\n"
  FileWrite ${L_TEMP} "POP3 Port$\n"
  FileWrite ${L_TEMP} "${L_POP3PORT}$\n"

  FileClose ${L_TEMP}

  ; Reconfigure the Outlook Express account

  WriteRegStr HKCU ${L_REGKEY} "POP3 User Name" "${L_POP3SERVER}$G_SEPARATOR${L_POP3USERNAME}"
  WriteRegStr HKCU ${L_REGKEY} "POP3 Server" "127.0.0.1"
  WriteRegDWORD HKCU ${L_REGKEY} "POP3 Port" $G_POP3

  !insertmacro OOECONFIG_CHANGES_LOG  "${L_IDENTITY}"    20
  !insertmacro OOECONFIG_CHANGES_LOG  "${L_ACCOUNTNAME}" 20
  !insertmacro OOECONFIG_CHANGES_LOG  "127.0.0.1"        17
  !insertmacro OOECONFIG_CHANGES_LOG  "${L_POP3SERVER}$G_SEPARATOR${L_POP3USERNAME}"  40
  FileWrite $G_OOECHANGES_HANDLE "$G_POP3$\r$\n"

  Goto continue

ignore_tick:
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Identity" "PageStatus" "leftover_ticks"

continue:
  IntOp ${L_CBOX_INDEX} ${L_CBOX_INDEX} + 1
  IntOp ${L_DATA_INDEX} ${L_DATA_INDEX} + 1
  IntCmp ${L_DATA_INDEX} $G_OOELIST_INDEX next_row next_row

exit:
  Pop ${L_POP3PORT}
  Pop ${L_POP3USERNAME}
  Pop ${L_POP3SERVER}
  Pop ${L_EMAILADDRESS}
  Pop ${L_ACCOUNTNAME}

  Pop ${L_IDENTITY}
  Pop ${L_TEXT_ENTRY}
  Pop ${L_TEMP}
  Pop ${L_REGKEY}
  Pop ${L_DATA_INDEX}
  Pop ${L_CBOX_STATE}
  Pop ${L_CBOX_INDEX}

  !undef L_CBOX_INDEX
  !undef L_CBOX_STATE
  !undef L_DATA_INDEX
  !undef L_REGKEY
  !undef L_TEMP
  !undef L_TEXT_ENTRY
  !undef L_IDENTITY

  !undef L_ACCOUNTNAME
  !undef L_EMAILADDRESS
  !undef L_POP3SERVER
  !undef L_POP3USERNAME
  !undef L_POP3PORT

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: SetOutlookPage (generates a custom page)
#
# This function is used to reconfigure Outlook accounts
#
# NOTE: This function is only used when the /OUTLOOK command-line switch is supplied
#--------------------------------------------------------------------------

Function SetOutlookPage

  ; This is an initial attempt at providing reconfiguration of Outlook POP3 accounts
  ; (unlike the 'SetOutlookExpressPage' function, 'SetOutlookPage' is based upon theory
  ; instead of experiment)

  ; Each version of Outlook seems to use a slightly different location in the registry
  ; (this is an incomplete list but it is all that is to hand at the moment):
  ;
  ; Outlook 2000:
  ;   HKEY_CURRENT_USER\Software\Microsoft\Office\Outlook\OMI Account Manager\Accounts
  ;
  ; Outlook 98:
  ;   HKEY_CURRENT_USER\Software\Microsoft\Office\8.0\Outlook\OMI Account Manager\Accounts
  ;
  ; Outlook 97:
  ;   HKEY_CURRENT_USER\Software\Microsoft\Office\7.0\Outlook\OMI Account Manager\Accounts
  ;
  ; Before working through this list, we try to cheat by looking for the key
  ;
  ;   HKEY_LOCAL_MACHINE\Software\Microsoft\Internet Account Manager\Outlook
  ;
  ; which may solve our problem (e.g. "Software\Microsoft\Office\Outlook\OMI Account Manager")

  ; All of the account data for the current user appears "under" the path defined
  ; above, e.g. if a user has several accounts, the account data is stored like this:
  ;    HKEY_CURRENT_USER\Software\Microsoft\Office\...\OMI Account Manager\Accounts\00000001
  ;    HKEY_CURRENT_USER\Software\Microsoft\Office\...\OMI Account Manager\Accounts\00000002
  ;    etc

  ; (This format is similar to that used by Outlook Express)

  !define L_ACCOUNT       $R9   ; path to data for current Outlook account (less the HKCU part)
  !define L_ACCT_INDEX    $R8   ; used to loop through Outlook accounts for the current user
  !define L_EMAILADDRESS  $R7   ; for an Outlook account
  !define L_OUTDATA       $R5   ; some data (it varies) for current Outlook account
  !define L_OUTLOOK       $R4   ; registry path for the Outlook accounts (less the HKCU part)
  !define L_POP3SERVER    $R3   ; POP3 server name for an Outlook account
  !define L_PORT          $R2   ; POP3 Port used for an Outlook Account
  !define L_STATUS        $R1   ; keeps track of the status of the account we are checking
  !define L_TEMP          $R0
  !define L_USERNAME      $9    ; POP3 username used for an Outlook account

  Push ${L_ACCOUNT}
  Push ${L_ACCT_INDEX}
  Push ${L_EMAILADDRESS}
  Push ${L_OUTDATA}
  Push ${L_OUTLOOK}
  Push ${L_POP3SERVER}
  Push ${L_PORT}
  Push ${L_STATUS}
  Push ${L_TEMP}
  Push ${L_USERNAME}

  ; Only check 'Outlook' accounts if this option was requested when the installer was launched

  Call GetParameters
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "/OUTLOOK" 0 exit

  !insertmacro MUI_HEADER_TEXT "$(PFI_LANG_OUTCFG_TITLE)" "$(PFI_LANG_OUTCFG_SUBTITLE)"

  ; Look for Outlook account data - if none found then quit

  ReadRegStr ${L_OUTLOOK} HKLM "Software\Microsoft\Internet Account Manager" "Outlook"
  StrCmp ${L_OUTLOOK} "" try_outlook_2000
  Push ${L_OUTLOOK}
  Push "OMI Account Manager"
  Call StrStr
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" try_outlook_2000
  StrCpy ${L_TEMP} ${L_OUTLOOK} "" -9
  StrCmp ${L_TEMP} "\Accounts" got_outlook_path
  StrCpy ${L_OUTLOOK} "${L_OUTLOOK}\Accounts"
  Goto got_outlook_path

try_outlook_2000:
  EnumRegKey ${L_OUTLOOK} HKCU "Software\Microsoft\Office\Outlook\OMI Account Manager\Accounts" 0
  StrCmp ${L_OUTLOOK} "" try_outlook_98
  StrCpy ${L_OUTLOOK} "Software\Microsoft\Office\Outlook\OMI Account Manager\Accounts"
  Goto got_outlook_path

try_outlook_98:
  EnumRegKey ${L_OUTLOOK} HKCU "Software\Microsoft\Office\8.0\Outlook\OMI Account Manager\Accounts" 0
  StrCmp ${L_OUTLOOK} "" try_outlook_97
  StrCpy ${L_OUTLOOK} "Software\Microsoft\Office\8.0\Outlook\OMI Account Manager\Accounts"
  Goto got_outlook_path

try_outlook_97:
  EnumRegKey ${L_OUTLOOK} HKCU "Software\Microsoft\Office\7.0\Outlook\OMI Account Manager\Accounts" 0
  StrCmp ${L_OUTLOOK} "" exit
  StrCpy ${L_OUTLOOK} "Software\Microsoft\Office\7.0\Outlook\OMI Account Manager\Accounts"

got_outlook_path:
  MessageBox MB_ABORTRETRYIGNORE|MB_ICONSTOP|MB_DEFBUTTON2 "$(PFI_LANG_MBCLIENT_OUT)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_1)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_2)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_3)"\
             IDRETRY got_outlook_path IDIGNORE open_logfiles

  ; Abort has been selected so we do not offer to reconfigure any Outlook accounts

  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioB.ini" "Settings" "NumFields" "1"
  !insertmacro PFI_IO_TEXT "ioB.ini" "1" "$(PFI_LANG_OUTCFG_IO_CANCELLED)"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioB.ini"
  Goto exit

open_logfiles:
  Call GetDateTimeStamp
  Pop ${L_TEMP}

  FileOpen  $G_OOECONFIG_HANDLE "$INSTDIR\outconfig.txt" w
  FileWrite $G_OOECONFIG_HANDLE "$(PFI_LANG_OUTCFG_LOG_BEFORE) (${L_TEMP})$\r$\n$\r$\n"
  !insertmacro OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OUTCFG_LOG_IDENTITY)"  20
  !insertmacro OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OOECFG_LOG_ACCOUNT)"   20
  !insertmacro OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OOECFG_LOG_EMAIL)"     30
  !insertmacro OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OOECFG_LOG_SERVER)"    20
  !insertmacro OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OOECFG_LOG_USER)"      20
  FileWrite $G_OOECONFIG_HANDLE "$(PFI_LANG_OOECFG_LOG_PORT)$\r$\n$\r$\n"

  FileOpen  $G_OOECHANGES_HANDLE "$INSTDIR\outchanges.txt" a
  FileSeek  $G_OOECHANGES_HANDLE 0 END
  FileWrite $G_OOECHANGES_HANDLE "$(PFI_LANG_OUTCFG_LOG_AFTER) (${L_TEMP})$\r$\n$\r$\n"
  !insertmacro OOECONFIG_CHANGES_LOG  "$(PFI_LANG_OUTCFG_LOG_IDENTITY)"   20
  !insertmacro OOECONFIG_CHANGES_LOG  "$(PFI_LANG_OOECFG_LOG_ACCOUNT)"    20
  !insertmacro OOECONFIG_CHANGES_LOG  "$(PFI_LANG_OOECFG_LOG_NEWSERVER)"  17
  !insertmacro OOECONFIG_CHANGES_LOG  "$(PFI_LANG_OOECFG_LOG_NEWUSER)"    40
  FileWrite $G_OOECHANGES_HANDLE "$(PFI_LANG_OOECFG_LOG_NEWPORT)$\r$\n$\r$\n"

  ; Determine the separator character to be used when configuring an email account for POPFile

  Call GetSeparator
  Pop $G_SEPARATOR

  ; Start with an empty list of accounts and reset the list "pointers"

  Call ResetOutlookOutLookExpressAccountList

  ; Now check all of the Outlook accounts for the current user

  StrCpy ${L_ACCT_INDEX} 0

next_acct:

  ; Reset the text string used to keep track of the status of the email account we are checking

  StrCpy ${L_STATUS} ""

  EnumRegKey ${L_ACCOUNT} HKCU ${L_OUTLOOK} ${L_ACCT_INDEX}
  StrCmp ${L_ACCOUNT} "" finished_the_accounts
  StrCpy ${L_ACCOUNT} "${L_OUTLOOK}\${L_ACCOUNT}"

  ; Now extract the POP3 Server data, if this does not exist then this account is
  ; not configured for mail so move on. If the data is "127.0.0.1" assume the account has
  ; already been configured for use with POPFile.

  ReadRegStr ${L_OUTDATA} HKCU ${L_ACCOUNT} "POP3 Server"
  StrCmp ${L_OUTDATA} "" try_next_account

  ; Have found an email account so we add a new entry to the list (which can hold 6 accounts)

  IntOp $G_OOELIST_INDEX $G_OOELIST_INDEX + 1    ; used to access the [Account] data in ioB.ini
  IntOp $G_OOELIST_CBOX $G_OOELIST_CBOX + 1      ; field number for relevant checkbox

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Settings" "NumFields" "$G_OOELIST_CBOX"

  StrCmp ${L_OUTDATA} "127.0.0.1" 0 check_pop3_server
  StrCpy ${L_STATUS} "bad IP"
  Goto check_pop3_username

check_pop3_server:

  ; If 'POP3 Server' data contains the separator character, we cannot configure this account

  Push ${L_OUTDATA}
  Push $G_SEPARATOR
  Call StrStr
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" check_pop3_username
  StrCpy ${L_STATUS} "bad servername"

check_pop3_username:

  ; Prepare to display the 'POP3 Server' data

  StrCpy ${L_POP3SERVER} ${L_OUTDATA}

  ReadRegStr ${L_OUTDATA} HKCU ${L_ACCOUNT} "SMTP Email Address"

  StrCpy ${L_EMAILADDRESS} ${L_OUTDATA}

  ReadRegDWORD ${L_PORT} HKCU ${L_ACCOUNT} "POP3 Port"
  StrCmp ${L_PORT} "" 0 port_ok
  StrCpy ${L_PORT} "110"

port_ok:
  ReadRegStr ${L_OUTDATA} HKCU ${L_ACCOUNT} "POP3 User Name"
  StrCpy ${L_USERNAME} ${L_OUTDATA}
  StrCmp ${L_USERNAME} "" bad_username

  ; If 'POP3 User Name' data contains the separator character, we cannot configure this account

  Push ${L_OUTDATA}
  Push $G_SEPARATOR
  Call StrStr
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" configurable
  StrCmp ${L_STATUS} "" 0 configurable

bad_username:
  StrCpy ${L_STATUS} "bad username"
  Goto continue

configurable:
  StrCmp ${L_STATUS} "" 0 continue
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field $G_OOELIST_CBOX" "Flags" ""

continue:

  ; Find the Username used by Outlook for this identity and the Outlook Account Name
  ; (so we can unambiguously report which email account we are offering to reconfigure).

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 1" "Text" "'$G_WINUSERNAME' $(PFI_LANG_OOECFG_IO_BOXHDR)"
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Identity" "Username" "$G_WINUSERNAME"

  ReadRegStr ${L_OUTDATA} HKCU ${L_ACCOUNT} "Account Name"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 8" "State"
  StrCpy ${L_TEMP} ""
  StrCmp ${L_STATUS} "" no_padding
  StrCpy ${L_TEMP} "\r\n\r\n"

no_padding:
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Field 8" "State" "${L_STATUS}${L_TEMP}${L_OUTDATA}"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 9" "State"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Field 9" "State" "${L_STATUS}${L_TEMP}${L_EMAILADDRESS}"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 10" "State"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Field 10" "State" "${L_STATUS}${L_TEMP}${L_POP3SERVER}"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 11" "State"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Field 11" "State" "${L_STATUS}${L_TEMP}${L_USERNAME}"

  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Account $G_OOELIST_INDEX" "AccountName" "${L_OUTDATA}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Account $G_OOELIST_INDEX" "EmailAddress" "${L_EMAILADDRESS}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Account $G_OOELIST_INDEX" "POP3server" "${L_POP3SERVER}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Account $G_OOELIST_INDEX" "POP3username" "${L_USERNAME}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Account $G_OOELIST_INDEX" "POP3port" "${L_PORT}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Account $G_OOELIST_INDEX" "RegistryKey" "${L_ACCOUNT}"

  !insertmacro OOECONFIG_BEFORE_LOG  "$G_WINUSERNAME"    20
  !insertmacro OOECONFIG_BEFORE_LOG  "${L_OUTDATA}"      20
  !insertmacro OOECONFIG_BEFORE_LOG  "${L_EMAILADDRESS}" 30
  !insertmacro OOECONFIG_BEFORE_LOG  "${L_POP3SERVER}"   20
  !insertmacro OOECONFIG_BEFORE_LOG  "${L_USERNAME}"     20
  FileWrite $G_OOECONFIG_HANDLE "${L_PORT}$\r$\n"

  IntCmp $G_OOELIST_INDEX 6 display_list try_next_account try_next_account

display_list:

  ; Display the Outlook account data with checkboxes enabled for those accounts we can configure

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Identity" "PageStatus" "new"

  !insertmacro MUI_INSTALLOPTIONS_INITDIALOG "ioB.ini"
  Pop $G_HWND                 ; HWND of dialog we want to modify

  ; In 'GetDlgItem', use (1200 + Field number - 1) to refer to the field to be changed

  GetDlgItem $G_DLGITEM $G_HWND 1200              ; Field 1 = IDENTITY label (above the box)
  CreateFont $G_FONT "MS Shell Dlg" 8 700        ; use a 'bolder' version of the font in use
  SendMessage $G_DLGITEM ${WM_SETFONT} $G_FONT 0

  !insertmacro MUI_INSTALLOPTIONS_SHOW_RETURN
  Pop ${L_TEMP}

  StrCmp ${L_TEMP} "cancel" finished_outlook_config
  StrCmp ${L_TEMP} "back" finished_outlook_config

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioB.ini" "Identity" "PageStatus"
  StrCmp ${L_TEMP} "updated" display_list
  StrCmp ${L_TEMP} "leftover_ticks" display_list

  Call ResetOutlookOutlookExpressAccountList

try_next_account:
  IntOp ${L_ACCT_INDEX} ${L_ACCT_INDEX} + 1
  goto next_acct

finished_the_accounts:
  IntCmp $G_OOELIST_INDEX 0 finished_outlook_config

display_list_again:
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Identity" "PageStatus" "new"

  !insertmacro MUI_INSTALLOPTIONS_INITDIALOG "ioB.ini"
  Pop $G_HWND                 ; HWND of dialog we want to modify

  ; In 'GetDlgItem', use (1200 + Field number - 1) to refer to the field to be changed

  GetDlgItem $G_DLGITEM $G_HWND 1200              ; Field 1 = IDENTITY label (above the box)
  CreateFont $G_FONT "MS Shell Dlg" 8 700        ; use a 'bolder' version of the font in use
  SendMessage $G_DLGITEM ${WM_SETFONT} $G_FONT 0

  !insertmacro MUI_INSTALLOPTIONS_SHOW_RETURN
  Pop ${L_TEMP}

  StrCmp ${L_TEMP} "cancel" finished_outlook_config
  StrCmp ${L_TEMP} "back" finished_outlook_config

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioB.ini" "Identity" "PageStatus"
  StrCmp ${L_TEMP} "updated" display_list_again
  StrCmp ${L_TEMP} "leftover_ticks" display_list_again

  Call ResetOutlookOutlookExpressAccountList

finished_outlook_config:
  FileWrite $G_OOECONFIG_HANDLE "$\r$\n$(PFI_LANG_OOECFG_LOG_END)$\r$\n$\r$\n"
  FileClose $G_OOECONFIG_HANDLE

  FileWrite $G_OOECHANGES_HANDLE "$\r$\n$(PFI_LANG_OOECFG_LOG_END)$\r$\n$\r$\n"
  FileClose $G_OOECHANGES_HANDLE

exit:
  Pop ${L_USERNAME}
  Pop ${L_TEMP}
  Pop ${L_STATUS}
  Pop ${L_PORT}
  Pop ${L_POP3SERVER}
  Pop ${L_OUTLOOK}
  Pop ${L_OUTDATA}
  Pop ${L_EMAILADDRESS}
  Pop ${L_ACCT_INDEX}
  Pop ${L_ACCOUNT}

  !undef L_ACCOUNT
  !undef L_ACCT_INDEX
  !undef L_EMAILADDRESS
  !undef L_OUTDATA
  !undef L_OUTLOOK
  !undef L_POP3SERVER
  !undef L_PORT
  !undef L_STATUS
  !undef L_TEMP
  !undef L_USERNAME

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: CheckOutlookRequests
#
# This function is used to confirm any Outlook Express account reconfiguration requests
#--------------------------------------------------------------------------

Function CheckOutlookRequests

  !define L_CBOX_INDEX   $R9
  !define L_CBOX_STATE   $R8
  !define L_DATA_INDEX   $R7
  !define L_REGKEY       $R6
  !define L_TEMP         $R5
  !define L_TEXT_ENTRY   $R4
  !define L_IDENTITY     $R3

  !define L_ACCOUNTNAME   $9
  !define L_EMAILADDRESS  $8
  !define L_POP3SERVER    $7
  !define L_POP3USERNAME  $6
  !define L_POP3PORT      $5

  Push ${L_CBOX_INDEX}
  Push ${L_CBOX_STATE}
  Push ${L_DATA_INDEX}
  Push ${L_REGKEY}
  Push ${L_TEMP}
  Push ${L_TEXT_ENTRY}
  Push ${L_IDENTITY}

  Push ${L_ACCOUNTNAME}
  Push ${L_EMAILADDRESS}
  Push ${L_POP3SERVER}
  Push ${L_POP3USERNAME}
  Push ${L_POP3PORT}

  ; If user has cancelled the reconfiguration, there is nothing to do here

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioB.ini" "Settings" "NumFields"
  StrCmp ${L_TEMP} "1" exit

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_IDENTITY} "ioB.ini" "Identity" "Username"

  StrCpy ${L_CBOX_INDEX} 12
  StrCpy ${L_DATA_INDEX} 1

next_row:
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_CBOX_STATE} "ioB.ini" "Field ${L_CBOX_INDEX}" "Flags"
  StrCmp ${L_CBOX_STATE} "DISABLED" continue

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_CBOX_STATE} "ioB.ini" "Field ${L_CBOX_INDEX}" "State"
  StrCmp ${L_CBOX_STATE} "0" continue

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_ACCOUNTNAME}  "ioB.ini" "Account ${L_DATA_INDEX}" "AccountName"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_EMAILADDRESS} "ioB.ini" "Account ${L_DATA_INDEX}" "EMailAddress"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_POP3SERVER}   "ioB.ini" "Account ${L_DATA_INDEX}" "POP3server"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_POP3USERNAME} "ioB.ini" "Account ${L_DATA_INDEX}" "POP3username"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_POP3PORT}     "ioB.ini" "Account ${L_DATA_INDEX}" "POP3port"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_REGKEY}       "ioB.ini" "Account ${L_DATA_INDEX}" "RegistryKey"

  MessageBox MB_YESNO \
      "$(PFI_LANG_OUTCFG_MBIDENTITY) ${L_IDENTITY}\
      $\r$\n$\r$\n\
      $(PFI_LANG_OUTCFG_MBACCOUNT) ${L_ACCOUNTNAME}\
      $\r$\n$\r$\n\
      $(PFI_LANG_OOECFG_MBEMAIL) ${L_EMAILADDRESS}\
      $\r$\n$\r$\n\
      $(PFI_LANG_OOECFG_MBSERVER) 127.0.0.1 \
                                   ($(PFI_LANG_OOECFG_MBOLDVALUE) '${L_POP3SERVER}')\
      $\r$\n$\r$\n\
      $(PFI_LANG_OOECFG_MBUSERNAME) ${L_POP3SERVER}$G_SEPARATOR${L_POP3USERNAME} \
                                     ($(PFI_LANG_OOECFG_MBOLDVALUE) '${L_POP3USERNAME}')\
      $\r$\n$\r$\n\
      $(PFI_LANG_OOECFG_MBOEPORT) $G_POP3 \
                                   ($(PFI_LANG_OOECFG_MBOLDVALUE) '${L_POP3PORT}')\
      $\r$\n$\r$\n$\r$\n\
      $(PFI_LANG_OOECFG_MBQUESTION)\
      " IDNO ignore_tick

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Identity" "PageStatus" "updated"
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field ${L_CBOX_INDEX}" "Flags" "DISABLED"

  ; To be able to restore the registry to previous settings when we uninstall we
  ; write a special file called 'outlook.reg' containing the registry settings
  ; prior to modification.
  ;
  ; For each account we save 3 settings, each using 3 lines as follows:
  ;         "Registry key", "POP3 User Name", "original data",
  ;         "Registry key", "POP3 Server", "original data",
  ;         "Registry key", "POP3 Port", "original data"
  ;
  ; This format is identical to that used for Outlook Express (but we use a separate file).

  FileOpen  ${L_TEMP} $INSTDIR\outlook.reg a
  FileSeek  ${L_TEMP} 0 END

  FileWrite ${L_TEMP} "${L_REGKEY}$\n"
  FileWrite ${L_TEMP} "POP3 User Name$\n"
  FileWrite ${L_TEMP} "${L_POP3USERNAME}$\n"

  FileWrite ${L_TEMP} "${L_REGKEY}$\n"
  FileWrite ${L_TEMP} "POP3 Server$\n"
  FileWrite ${L_TEMP} "${L_POP3SERVER}$\n"

  FileWrite ${L_TEMP} "${L_REGKEY}$\n"
  FileWrite ${L_TEMP} "POP3 Port$\n"
  FileWrite ${L_TEMP} "${L_POP3PORT}$\n"

  FileClose ${L_TEMP}

  ; Reconfigure the Outlook account

  WriteRegStr HKCU ${L_REGKEY} "POP3 User Name" "${L_POP3SERVER}$G_SEPARATOR${L_POP3USERNAME}"
  WriteRegStr HKCU ${L_REGKEY} "POP3 Server" "127.0.0.1"
  WriteRegDWORD HKCU ${L_REGKEY} "POP3 Port" $G_POP3

  !insertmacro OOECONFIG_CHANGES_LOG  "${L_IDENTITY}"    20
  !insertmacro OOECONFIG_CHANGES_LOG  "${L_ACCOUNTNAME}" 20
  !insertmacro OOECONFIG_CHANGES_LOG  "127.0.0.1"        17
  !insertmacro OOECONFIG_CHANGES_LOG  "${L_POP3SERVER}$G_SEPARATOR${L_POP3USERNAME}"  40
  FileWrite $G_OOECHANGES_HANDLE "$G_POP3$\r$\n"

  Goto continue

ignore_tick:
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Identity" "PageStatus" "leftover_ticks"

continue:
  IntOp ${L_CBOX_INDEX} ${L_CBOX_INDEX} + 1
  IntOp ${L_DATA_INDEX} ${L_DATA_INDEX} + 1
  IntCmp ${L_DATA_INDEX} $G_OOELIST_INDEX next_row next_row

exit:
  Pop ${L_POP3PORT}
  Pop ${L_POP3USERNAME}
  Pop ${L_POP3SERVER}
  Pop ${L_EMAILADDRESS}
  Pop ${L_ACCOUNTNAME}

  Pop ${L_IDENTITY}
  Pop ${L_TEXT_ENTRY}
  Pop ${L_TEMP}
  Pop ${L_REGKEY}
  Pop ${L_DATA_INDEX}
  Pop ${L_CBOX_STATE}
  Pop ${L_CBOX_INDEX}

  !undef L_CBOX_INDEX
  !undef L_CBOX_STATE
  !undef L_DATA_INDEX
  !undef L_REGKEY
  !undef L_TEMP
  !undef L_TEXT_ENTRY
  !undef L_IDENTITY

  !undef L_ACCOUNTNAME
  !undef L_EMAILADDRESS
  !undef L_POP3SERVER
  !undef L_POP3USERNAME
  !undef L_POP3PORT

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: SetEudoraPage_Init
#
# This function adds language texts to the INI file used by the "SetEudoraPage" function
# (to make the custom page use the language selected by the user for the installer)
#--------------------------------------------------------------------------

Function SetEudoraPage_Init

  ; Ensure custom page matches the selected language (left-to-right or right-to-left order)

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Settings" "RTL" "$(^RTL)"

  !insertmacro PFI_IO_TEXT "ioE.ini" "2" "$(PFI_LANG_EUCFG_IO_CHECKBOX)"
  !insertmacro PFI_IO_TEXT "ioE.ini" "3" "$(PFI_LANG_EUCFG_IO_RESTORE)"

  !insertmacro PFI_IO_TEXT "ioE.ini" "5" "$(PFI_LANG_EUCFG_IO_EMAIL)"
  !insertmacro PFI_IO_TEXT "ioE.ini" "6" "$(PFI_LANG_EUCFG_IO_SERVER)"
  !insertmacro PFI_IO_TEXT "ioE.ini" "7" "$(PFI_LANG_EUCFG_IO_USERNAME)"
  !insertmacro PFI_IO_TEXT "ioE.ini" "8" "$(PFI_LANG_EUCFG_IO_POP3PORT)"

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: SetEudoraPage (generates a custom page)
#
# This function is used to reconfigure Eudora personalities
#--------------------------------------------------------------------------

Function SetEudoraPage

  !define L_ININAME   $R9
  !define L_LENGTH    $R8
  !define L_STATUS    $R7
  !define L_TEMP      $R6
  !define L_TERMCHR   $R5

  !define L_EMAIL     $R4
  !define L_SERVER    $R3
  !define L_USER      $R2
  !define L_PORT      $R1

  !define L_INDEX     $R0
  !define L_PERSONA   $9
  !define L_CFGTIME   $8

  !define L_CHANGED   $7

  Push ${L_ININAME}
  Push ${L_LENGTH}
  Push ${L_STATUS}
  Push ${L_TEMP}
  Push ${L_TERMCHR}

  Push ${L_EMAIL}
  Push ${L_SERVER}
  Push ${L_USER}
  Push ${L_PORT}

  Push ${L_INDEX}
  Push ${L_PERSONA}
  Push ${L_CFGTIME}

  Push ${L_CHANGED}

  ; Look for Eudora registry entry which identifies the relevant INI file

  ReadRegStr ${L_STATUS} HKCU "Software\Qualcomm\Eudora\CommandLine" "current"
  StrCmp ${L_STATUS} "" 0 extract_INI_path

  ; No data in registry. Did the 'SetEmailClient' function find a path for the Eudora program?

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioF.ini" "ClientEXE" "Eudora"
  StrCmp ${L_STATUS} "" exit

  ; Look for the Eudora INI file

  Push ${L_STATUS}
  Call GetParent
  Pop ${L_ININAME}
  StrCpy ${L_ININAME} "${L_ININAME}\EUDORA.INI"
  IfFileExists "${L_ININAME}" gotname exit

extract_INI_path:

  ; Extract full path to the Eudora INI file

  StrCpy ${L_TEMP} -1
  StrLen ${L_LENGTH} ${L_STATUS}
  IntOp ${L_LENGTH} 0 - ${L_LENGTH}

  ; Check if we need to look for a space or double-quotes

  StrCpy ${L_ININAME} ${L_STATUS} 1 ${L_TEMP}
  StrCpy ${L_TERMCHR} '"'
  StrCmp ${L_ININAME} '"' loop
  StrCpy ${L_TERMCHR} ' '

  ; We want the last of the three filename 'tokens' in the value extracted from the registry

loop:
  IntOp ${L_TEMP} ${L_TEMP} - 1
  StrCpy ${L_ININAME} ${L_STATUS} 1 ${L_TEMP}
  StrCmp ${L_ININAME} ${L_TERMCHR} extract
  IntCmp ${L_TEMP} ${L_LENGTH} extract
  Goto loop

extract:
  IntOp ${L_TEMP} ${L_TEMP} + 1
  StrCpy ${L_ININAME} ${L_STATUS} "" ${L_TEMP}
  StrCmp ${L_TERMCHR} ' ' gotname
  StrCpy ${L_ININAME} ${L_ININAME} -1

gotname:
  !insertmacro MUI_HEADER_TEXT "$(PFI_LANG_EUCFG_TITLE)" "$(PFI_LANG_EUCFG_SUBTITLE)"

  ; If Eudora is running, ask the user to shut it down now (user may ignore our request)

check_if_running:
  FindWindow ${L_STATUS} "EudoraMainWindow"
  IsWindow ${L_STATUS} 0 continue

  MessageBox MB_ABORTRETRYIGNORE|MB_ICONSTOP|MB_DEFBUTTON2 "$(PFI_LANG_MBCLIENT_EUD)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_1)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_2)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_3)"\
             IDRETRY check_if_running IDIGNORE continue

  ; 'Abort' has been selected so we do not offer to reconfigure any Eudora accounts

  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioE.ini" "Settings" "NumFields" "1"
  !insertmacro PFI_IO_TEXT "ioE.ini" "1" "$(PFI_LANG_EUCFG_IO_CANCELLED)"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioE.ini"
  Goto exit

continue:
  Call GetDateTimeStamp
  Pop ${L_CFGTIME}

  ; If none of the  accounts are changed, we treat this as a special case and offer to change
  ; only the POP3 port for Eudora. The ${L_CHANGED} register is used to detect this case.

  StrCpy ${L_CHANGED} ""

  ; The <Dominant> personality data is stored separately from that of the other personalities

  !insertmacro PFI_IO_TEXT "ioE.ini" "4" "$(PFI_LANG_EUCFG_IO_DOMINANT)"
  StrCpy ${L_PERSONA} "Settings"
  StrCpy ${L_INDEX} -1
  Goto common_to_all

get_next_persona:
  IntOp ${L_INDEX} ${L_INDEX} + 1
  ReadINIStr ${L_PERSONA}  "${L_ININAME}" "Personalities" "Persona${L_INDEX}"
  StrCmp ${L_PERSONA} "" 0 get_details
  StrCmp ${L_CHANGED} "1" exit

  ; None of the personalities have been changed. Offer to change the POPPort setting if this
  ; installation uses a different POP3 port from that currently used by Eudora. This makes it
  ; easy to use Eudora with the newly installed POPFile. Use the "*.*" wildcard for this case.

  StrCmp ${L_PORT} $G_POP3 exit

  !insertmacro PFI_IO_TEXT "ioE.ini" "4" "'<*.*>' $(PFI_LANG_EUCFG_IO_PERSONA)"
  StrCpy ${L_PERSONA} "*.*"
  StrCpy ${L_EMAIL} "*.*"
  StrCpy ${L_SERVER} "*.*"
  StrCpy ${L_USER} "*.*"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 2" "State" "0"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 2" "Flags" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 3" "Flags" ""
  Goto update_persona_details

get_details:
  StrCpy ${L_TEMP} ${L_PERSONA} "" 8

  !insertmacro PFI_IO_TEXT "ioE.ini" "4" "'${L_TEMP}' $(PFI_LANG_EUCFG_IO_PERSONA)"

common_to_all:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 2" "State" "0"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 2" "Flags" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 3" "Flags" ""

  ReadINIStr ${L_EMAIL}  "${L_ININAME}" "${L_PERSONA}" "POPAccount"
  ReadINIStr ${L_SERVER} "${L_ININAME}" "${L_PERSONA}" "POPServer"
  ReadINIStr ${L_USER}   "${L_ININAME}" "${L_PERSONA}" "LoginName"
  ReadINIStr ${L_STATUS} "${L_ININAME}" "${L_PERSONA}" "UsesPOP"
  ReadINIStr ${L_PORT}   "${L_ININAME}" "Settings" "POPPort"

  StrCmp ${L_EMAIL} "" 0 check_server
  StrCpy ${L_EMAIL} "N/A"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 2" "Flags" "DISABLED"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 3" "Flags" "DISABLED"

check_server:
  StrCmp ${L_SERVER} "127.0.0.1" disable
  StrCmp ${L_SERVER} "" 0 check_username
  StrCpy ${L_SERVER} "N/A"

disable:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 2" "Flags" "DISABLED"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 3" "Flags" "DISABLED"

check_username:
  StrCmp ${L_USER} "" 0 check_port
  StrCpy ${L_USER} "N/A"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 2" "Flags" "DISABLED"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 3" "Flags" "DISABLED"

check_port:
  StrCmp ${L_PORT} "" 0 check_status
  StrCpy ${L_PORT} "110"

check_status:
  StrCmp ${L_STATUS} 1 update_persona_details
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 2" "Flags" "DISABLED"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 3" "Flags" "DISABLED"

update_persona_details:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 9" "Text" "${L_EMAIL}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 10" "Text" "${L_SERVER}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 11" "Text" "${L_USER}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 12" "Text" "${L_PORT}"

  StrCpy ${L_TEMP} "."
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioE.ini" "Field 2" "Flags"
  StrCmp ${L_STATUS} "DISABLED" write_intro
  StrCpy ${L_TEMP} "$(PFI_LANG_EUCFG_IO_INTRO_2)"

write_intro:
    !insertmacro PFI_IO_TEXT "ioE.ini" "1" "$(PFI_LANG_EUCFG_IO_INTRO_1)${L_TEMP}"

  !insertmacro MUI_INSTALLOPTIONS_INITDIALOG "ioE.ini"
  Pop $G_HWND                 ; HWND of dialog we want to modify

  ; In 'GetDlgItem', use (1200 + Field number - 1) to refer to the field to be changed

  GetDlgItem $G_DLGITEM $G_HWND 1203             ; Field 4 = PERSONA (text in groupbox frame)
  CreateFont $G_FONT "MS Shell Dlg" 8 700        ; use a 'bolder' version of the font in use
  SendMessage $G_DLGITEM ${WM_SETFONT} $G_FONT 0

  !insertmacro MUI_INSTALLOPTIONS_SHOW

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioE.ini" "Field 2" "State"
  StrCmp ${L_STATUS} "1" reconfigure_persona
  StrCmp ${L_PERSONA} "*.*" exit
  Goto get_next_persona

reconfigure_persona:
  ReadINIStr  ${L_STATUS} "$INSTDIR\pfi-eudora.ini" "History" "ListSize"
  StrCmp ${L_STATUS} "" 0 update_list_size
  StrCpy ${L_STATUS} 1
  WriteINIStr "$INSTDIR\pfi-eudora.ini" "History" "ListSize" "1"
  Goto add_entry

update_list_size:
  IntOp ${L_STATUS} ${L_STATUS} + 1
  WriteINIStr "$INSTDIR\pfi-eudora.ini" "History" "ListSize" "${L_STATUS}"

add_entry:
  WriteINIStr "$INSTDIR\pfi-eudora.ini" "History" "Undo-${L_STATUS}" "Created on ${L_CFGTIME}"
  WriteINIStr "$INSTDIR\pfi-eudora.ini" "History" "Path-${L_STATUS}" "${L_ININAME}"

  WriteINIStr "$INSTDIR\pfi-eudora.ini" "Undo-${L_STATUS}" "Persona" "${L_PERSONA}"
  WriteINIStr "$INSTDIR\pfi-eudora.ini" "Undo-${L_STATUS}" "POPAccount" "${L_EMAIL}"
  WriteINIStr "$INSTDIR\pfi-eudora.ini" "Undo-${L_STATUS}" "POPServer" "${L_SERVER}"
  WriteINIStr "$INSTDIR\pfi-eudora.ini" "Undo-${L_STATUS}" "LoginName" "${L_USER}"
  WriteINIStr "$INSTDIR\pfi-eudora.ini" "Undo-${L_STATUS}" "POPPort" "${L_PORT}"

  StrCmp ${L_PERSONA} "*.*" special_case

  WriteINIStr "${L_ININAME}" "${L_PERSONA}" "POPAccount" "${L_SERVER}$G_SEPARATOR${L_USER}@127.0.0.1"
  WriteINIStr "${L_ININAME}" "${L_PERSONA}" "POPServer"  "127.0.0.1"
  WriteINIStr "${L_ININAME}" "${L_PERSONA}" "LoginName"  "${L_SERVER}$G_SEPARATOR${L_USER}"
  WriteINIStr "${L_ININAME}" "Settings"     "POPPort"    $G_POP3
  StrCpy ${L_CHANGED} "1"
  Goto get_next_persona

special_case:
  WriteINIStr "${L_ININAME}" "Settings"     "POPPort"    $G_POP3

exit:
  Pop ${L_CHANGED}

  Pop ${L_CFGTIME}
  Pop ${L_PERSONA}
  Pop ${L_INDEX}

  Pop ${L_PORT}
  Pop ${L_USER}
  Pop ${L_SERVER}
  Pop ${L_EMAIL}

  Pop ${L_TERMCHR}
  Pop ${L_TEMP}
  Pop ${L_STATUS}
  Pop ${L_LENGTH}
  Pop ${L_ININAME}

  !undef L_ININAME
  !undef L_LENGTH
  !undef L_STATUS
  !undef L_TEMP
  !undef L_TERMCHR

  !undef L_EMAIL
  !undef L_SERVER
  !undef L_USER
  !undef L_PORT

  !undef L_INDEX
  !undef L_PERSONA
  !undef L_CFGTIME

  !undef L_CHANGED

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: StartPOPFilePage_Init (adds language texts to custom page INI file)
#
# This function adds language texts to the INI file used by the "StartPOPFilePage" function
# (to make the custom page use the language selected by the user for the installer)
#--------------------------------------------------------------------------

Function StartPOPFilePage_Init

  ; Ensure custom page matches the selected language (left-to-right or right-to-left order)

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Settings" "RTL" "$(^RTL)"

  !insertmacro PFI_IO_TEXT "ioC.ini" "1" "$(PFI_LANG_LAUNCH_IO_INTRO)"
  !insertmacro PFI_IO_TEXT "ioC.ini" "2" "$(PFI_LANG_LAUNCH_IO_NO)"
  !insertmacro PFI_IO_TEXT "ioC.ini" "3" "$(PFI_LANG_LAUNCH_IO_DOSBOX)"
  !insertmacro PFI_IO_TEXT "ioC.ini" "4" "$(PFI_LANG_LAUNCH_IO_BCKGRND)"

  !insertmacro PFI_IO_TEXT "ioC.ini" "6" "$(PFI_LANG_LAUNCH_IO_NOTE_1)"
  !insertmacro PFI_IO_TEXT "ioC.ini" "7" "$(PFI_LANG_LAUNCH_IO_NOTE_2)"
  !insertmacro PFI_IO_TEXT "ioC.ini" "8" "$(PFI_LANG_LAUNCH_IO_NOTE_3)"

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: StartPOPFilePage (generates a custom page)
#
# This function offers to start the newly installed POPFile.
#
# A "leave" function (CheckLaunchOptions) is used to act upon the selection made by the user.
#
# The user is allowed to change their selection by returning to this page (by clicking 'Back'
# on the 'Finish' page) if corpus conversion is not required.
#
# The [Inherited] section in 'ioC.ini' has information on the system tray icon and console mode
# settings found in 'popfile.cfg'. Valid values are 0 (disabled), 1 (enabled) and ? (undefined).
# If any settings are undefined, this function adds the default settings to 'popfile.cfg'
# (i.e. console mode disabled, system tray icon enabled)
#--------------------------------------------------------------------------

Function StartPOPFilePage

  !define L_CFG    $R9
  !define L_TEMP   $R8

  Push ${L_CFG}
  Push ${L_TEMP}

  ; Ensure 'popfile.cfg' has valid settings for system tray icon and console mode
  ; (if necessary, add the default settings to the file and update the [Inherited] copies)

  FileOpen  ${L_CFG} "$INSTDIR\popfile.cfg" a
  FileSeek  ${L_CFG} 0 END

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Inherited" "Console"
  StrCmp ${L_TEMP} "?" 0 check_trayicon
  FileWrite ${L_CFG} "windows_console 0$\r$\n"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Inherited" "Console" "0"

check_trayicon:
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Inherited" "TrayIcon"
  StrCmp ${L_TEMP} "?" 0 close_file
  FileWrite ${L_CFG} "windows_trayicon 1$\r$\n"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Inherited" "TrayIcon" "1"

close_file:
  FileClose ${L_CFG}

  IfRebootFlag 0 page_enabled

  ; We are running on a Win9x system which must be rebooted before Kakasi can be used,
  ; so we are unable to offer to start POPFile at this point

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 2" "State" "1"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 3" "State" "0"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 4" "State" "0"

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 1" "Flags" "DISABLED"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 2" "Flags" "DISABLED"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 3" "Flags" "DISABLED"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 4" "Flags" "DISABLED"

  ; If we are upgrading POPFile, the corpus might have to be converted from flat file format

  ReadINIStr ${L_TEMP} "$INSTDIR\backup\backup.ini" "FlatFileCorpus" "Status"
  StrCmp ${L_TEMP} "new" 0 display_the_page

  ; Corpus conversion will occur when POPFile is started - this may take several minutes,
  ; so we ensure that POPFile will not be run in the background when it is run for the
  ; first time (by using the Start Menu or by running 'popfile.exe').

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Inherited" "Console" "1"
  Push "1"
  Call SetConsoleMode

  ; Remove the 'Click Next to convert the corpus' text (because we need to reboot first)

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioD.ini" "Settings" "NumFields" "7"

  Goto display_the_page

page_enabled:

  ; clear all three radio buttons ('do not start', 'use console', 'run in background')

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 2" "State" "0"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 3" "State" "0"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 4" "State" "0"

  ; If we have returned to this page from the 'Finish' page then we can use the [LastAction]
  ; data to select the appropriate radio button, otherwise we use the [Inherited] data.

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Run Status" "LastAction"
  StrCmp ${L_TEMP} "" use_inherited_data
  StrCmp ${L_TEMP} "console" console
  StrCmp ${L_TEMP} "background" background
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 2" "State" "1"
  Goto display_the_page

use_inherited_data:
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Inherited" "Console"
  StrCmp ${L_TEMP} "0" background

console:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 3" "State" "1"
  Goto display_the_page

background:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 4" "State" "1"

display_the_page:
  !insertmacro MUI_HEADER_TEXT "$(PFI_LANG_LAUNCH_TITLE)" "$(PFI_LANG_LAUNCH_SUBTITLE)"

  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioC.ini"

  Pop ${L_TEMP}
  Pop ${L_CFG}

  !undef L_CFG
  !undef L_TEMP

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: CheckLaunchOptions
# (the "leave" function for the custom page created by "StartPOPFilePage")
#
# This function is used to action the "start POPFile" option selected by the user.
# The user is allowed to return to this page and change their selection, so the
# previous state is stored in the INI file used for this custom page.
#
# If corpus conversion is required, this function will not launch POPFile
# (but it will still update 'popfile.cfg' to reflect the user's startup choice)
#--------------------------------------------------------------------------

Function CheckLaunchOptions

  !define L_CFG         $R9   ; file handle
  !define L_EXE         $R8   ; full path of perl EXE to be monitored
  !define L_TEMP        $R7
  !define L_TRAY        $R6   ; set to 'i' if system tray enabled, otherwise set to ""
  !define L_CONSOLE     $R5   ; new console mode: 0 = disabled, 1 = enabled
  !define L_TIMEOUT     $R4   ; used to wait for the UI to respond (when starting POPFile)

  Push ${L_CFG}
  Push ${L_EXE}
  Push ${L_TEMP}
  Push ${L_TRAY}
  Push ${L_CONSOLE}
  Push ${L_TIMEOUT}

  StrCpy ${L_TRAY} "i"    ; the default is to enable the system tray icon
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Inherited" "TrayIcon"
  StrCmp ${L_TEMP} "1" check_radio_buttons
  StrCpy ${L_TRAY} ""

check_radio_buttons:

  ; Field 2 = 'Do not run POPFile' radio button

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Field 2" "State"
  StrCmp ${L_TEMP} "0" run_popfile

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Run Status" "LastAction"
  StrCmp ${L_TEMP} "" exit_without_banner
  StrCmp ${L_TEMP} "no" exit_without_banner

  ; Selection has been changed from 'use console' or 'run in background' to 'do not run POPFile'

  StrCmp ${L_TEMP} "background" background_to_no
  StrCpy ${L_EXE} "$INSTDIR\popfile${L_TRAY}f.exe"
  Goto lastaction_no

background_to_no:
  StrCpy ${L_EXE} "$INSTDIR\popfile${L_TRAY}b.exe"

lastaction_no:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Run Status" "LastAction" "no"

  ; User has changed their mind: Shutdown the newly installed version of POPFile

  NSISdl::download_quiet http://127.0.0.1:$G_GUI/shutdown "$PLUGINSDIR\shutdown.htm"
  Pop ${L_TEMP}    ; Get the return value (and ignore it)
  Push ${L_EXE}
  Call WaitUntilUnlocked
  Goto exit_without_banner

run_popfile:

  ; Set ${L_EXE} to "" as we do not yet know if we are going to monitor a file in $INSTDIR

  StrCpy ${L_EXE} ""

  ; Field 4 = 'Run POPFile in background' radio button

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Field 4" "State"
  StrCmp ${L_TEMP} "1" run_in_background

  ; Run POPFile using console window

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Run Status" "LastAction"
  StrCmp ${L_TEMP} "console" exit_without_banner
  StrCmp ${L_TEMP} "no" lastaction_console
  StrCmp ${L_TEMP} "" lastaction_console
  StrCpy ${L_EXE} "$INSTDIR\popfile${L_TRAY}b.exe"

lastaction_console:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Run Status" "LastAction" "console"
  StrCpy ${L_CONSOLE} "1"
  Goto display_banner

run_in_background:
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Run Status" "LastAction"
  StrCmp ${L_TEMP} "background" exit_without_banner
  StrCmp ${L_TEMP} "no" lastaction_background
  StrCmp ${L_TEMP} "" lastaction_background
  StrCpy ${L_EXE} "$INSTDIR\popfile${L_TRAY}f.exe"

lastaction_background:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Run Status" "LastAction" "background"
  StrCpy ${L_CONSOLE} "0"

display_banner:
  ReadINIStr ${L_TEMP} "$INSTDIR\backup\backup.ini" "FlatFileCorpus" "Status"
  StrCmp ${L_TEMP} "new" exit_without_banner

  Banner::show /NOUNLOAD /set 76 "$(PFI_LANG_LAUNCH_BANNER_1)" "$(PFI_LANG_LAUNCH_BANNER_2)"

  ; Before starting the newly installed POPFile, ensure that no other version of POPFile
  ; is running on the same UI port as the newly installed version.

  NSISdl::download_quiet http://127.0.0.1:$G_GUI/shutdown "$PLUGINSDIR\shutdown.htm"
  Pop ${L_TEMP}    ; Get the return value (and ignore it)
  Push ${L_EXE}
  Call WaitUntilUnlocked
  Push ${L_CONSOLE}
  Call SetConsoleMode
  SetOutPath $INSTDIR
  ClearErrors
  Exec '"$INSTDIR\wrapper.exe"'
  IfErrors 0 continue
  Banner::destroy
  MessageBox MB_OK|MB_ICONEXCLAMATION|MB_TOPMOST "An error occurred when the installer tried to start POPFile.\
      $\r$\n$\r$\n\
      Please use 'Start -> Programs -> POPFile -> Run POPFile' now.\
      $\r$\n$\r$\n\
      Click 'OK' once POPFile has been started."
  Goto exit_without_banner

continue:

  ; Wait until POPFile is ready to display the UI (may take a second or so)

  StrCpy ${L_TIMEOUT} ${C_STARTUP_LIMIT}   ; Timeout limit to avoid an infinite loop

check_if_ready:
  NSISdl::download_quiet http://127.0.0.1:$G_GUI "$PLUGINSDIR\ui.htm"
  Pop ${L_TEMP}                        ; Did POPFile return an HTML page?
  StrCmp ${L_TEMP} "success" remove_banner
  Sleep ${C_STARTUP_DELAY}
  IntOp ${L_TIMEOUT} ${L_TIMEOUT} - 1
  IntCmp ${L_TIMEOUT} 0 remove_banner remove_banner check_if_ready

remove_banner:
  Banner::destroy

exit_without_banner:

  Pop ${L_TIMEOUT}
  Pop ${L_CONSOLE}
  Pop ${L_TRAY}
  Pop ${L_TEMP}
  Pop ${L_EXE}
  Pop ${L_CFG}

  !undef L_CFG
  !undef L_EXE
  !undef L_TEMP
  !undef L_TRAY
  !undef L_CONSOLE
  !undef L_TIMEOUT

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: ConvertCorpusPage_Init (adds language texts to custom page INI file)
#
# This function adds language texts to the INI file used by the "ConvertCorpusPage" function
# (to make the custom page use the language selected by the user for the installer)
#--------------------------------------------------------------------------

Function ConvertCorpusPage_Init

  ; Ensure custom page matches the selected language (left-to-right or right-to-left order)

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioD.ini" "Settings" "RTL" "$(^RTL)"

  !insertmacro PFI_IO_TEXT "ioD.ini" "1" "$(PFI_LANG_FLATFILE_IO_NOTE_1)"
  !insertmacro PFI_IO_TEXT "ioD.ini" "2" "$(PFI_LANG_FLATFILE_IO_NOTE_2)"
  !insertmacro PFI_IO_TEXT "ioD.ini" "3" "$(PFI_LANG_FLATFILE_IO_NOTE_3)"
  !insertmacro PFI_IO_TEXT "ioD.ini" "4" "$(PFI_LANG_FLATFILE_IO_NOTE_4)"
  !insertmacro PFI_IO_TEXT "ioD.ini" "5" "$(PFI_LANG_FLATFILE_IO_NOTE_5)"
  !insertmacro PFI_IO_TEXT "ioD.ini" "6" "$(PFI_LANG_FLATFILE_IO_NOTE_6)"
  !insertmacro PFI_IO_TEXT "ioD.ini" "7" "$(PFI_LANG_FLATFILE_IO_NOTE_7)"
  !insertmacro PFI_IO_TEXT "ioD.ini" "8" "$(PFI_LANG_FLATFILE_IO_NOTE_8)"

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: ConvertCorpusPage (generates a custom page)
#
# Displays custom page when an existing flat file corpus has to be converted to the new
# BerkeleyDB format. Conversion may take several minutes during which time the POPFile
# User Interface will be unresponsive.
#--------------------------------------------------------------------------

Function ConvertCorpusPage

  !define L_TEMP   $R9

  Push ${L_TEMP}

  ReadINIStr ${L_TEMP} "$INSTDIR\backup\backup.ini" "FlatFileCorpus" "Status"
  StrCmp ${L_TEMP} "new" 0 exit

  !insertmacro MUI_HEADER_TEXT "$(PFI_LANG_FLATFILE_TITLE)" "$(PFI_LANG_FLATFILE_SUBTITLE)"

  !insertmacro MUI_INSTALLOPTIONS_INITDIALOG "ioD.ini"
  Pop $G_HWND                 ; HWND of dialog we want to modify

  ; In 'GetDlgItem', use (1200 + Field number - 1) to refer to the field to be changed

  GetDlgItem $G_DLGITEM $G_HWND 1202             ; Field 3 = text in the WARNING groupbox frame
  CreateFont $G_FONT "MS Shell Dlg" 8 700        ; use a 'bolder' version of the font in use
  SendMessage $G_DLGITEM ${WM_SETFONT} $G_FONT 0

  GetDlgItem $G_DLGITEM $G_HWND 1203             ; Field 4 = text inside the WARNING groupbox
  CreateFont $G_FONT "MS Shell Dlg" 8 700        ; use a 'bolder' version of the font in use
  SendMessage $G_DLGITEM ${WM_SETFONT} $G_FONT 0

  !insertmacro MUI_INSTALLOPTIONS_SHOW

exit:
  Pop ${L_TEMP}

  !undef L_TEMP

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: CheckRunStatus
# (the "pre" function for the 'Finish' page)
#
# The 'Finish' page contains two CheckBoxes: one to control whether or not the installer
# starts the POPFile User Interface and one to control whether or not the 'ReadMe' file is
# displayed. The User Interface only works when POPFile is running, so we must ensure its
# CheckBox can only be ticked if the installer has started POPFile.
#
# NB: User can switch back and forth between the 'Start POPFile' page and the 'Finish' page
# (when corpus conversion is not required)
#--------------------------------------------------------------------------

Function CheckRunStatus

  !define L_TEMP        $R9

  Push ${L_TEMP}

  ; If POPFile is running in a console window, it might be obscuring the installer

  BringToFront

  IfRebootFlag 0 no_reboot_reqd

  ; We have installed Kakasi on a Win9x system and must reboot before using POPFile
  ; (replace previous page with a simple "Please wait" one, in case the page appears
  ; again while the system is rebooting)

  !insertmacro MUI_HEADER_TEXT "$(PFI_LANG_OPTIONS_BANNER_1)" "$(PFI_LANG_OPTIONS_BANNER_2)"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Settings" "NumFields" "0"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioD.ini" "Settings" "NumFields" "0"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Settings" "BackEnabled" "0"

  WriteINIStr "$INSTDIR\backup\backup.ini" "FlatFileCorpus" "Status" "old"

  Goto selection_ok

no_reboot_reqd:

  ; Enable the 'Run' CheckBox on the 'Finish' page (it may have been disabled on our last visit)

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 4" "Flags" ""

  ; Get the status of the 'Do not run POPFile' radio button on the 'Start POPFile' page
  ; If user has not started POPFile, we cannot offer to display the POPFile User Interface

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Field 2" "State"
  StrCmp ${L_TEMP} "1" disable_UI_option

  ; If flat file corpus conversion is required, we cannot offer to display the POPFile UI
  ; (conversion may take several minutes, during which time the UI will be unresponsive)

  ReadINIStr ${L_TEMP} "$INSTDIR\backup\backup.ini" "FlatFileCorpus" "Status"
  StrCmp ${L_TEMP} "new" 0 selection_ok

  WriteINIStr "$INSTDIR\backup\backup.ini" "FlatFileCorpus" "Status" "old"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Settings" "BackEnabled" "0"

  ; When 'popfile.exe' is used to run POPFile, the 'windows_console' parameter in 'popfile.cfg'
  ; is used to choose between running in a console window or running in the background. However
  ; for corpus conversion we want to run in a console window (to display the progress reports,
  ; in case the conversion takes several minutes), so we "cheat" by using 'popfilef.exe' to run
  ; POPFile in a console window with the system tray icon disabled. This avoids the need to make
  ; any changes to 'popfile.cfg' so the next time 'popfile.exe' is used to start POPFile, the
  ; the settings in 'popfile.cfg' will be used.

  SetOutPath $INSTDIR
  ClearErrors
  Exec '"$INSTDIR\wrapperf.exe"'
  IfErrors 0 disable_UI_option
  MessageBox MB_OK|MB_TOPMOST "An error occurred when starting the corpus conversion process."

disable_UI_option:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 4" "State" "0"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 4" "Flags" "DISABLED"

selection_ok:
  Pop ${L_TEMP}

  !undef L_TEMP

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: RunUI
# (the "Run" function for the 'Finish' page)
#--------------------------------------------------------------------------

Function RunUI

  ExecShell "open" "$SMPROGRAMS\${C_PFI_PRODUCT}\POPFile User Interface.url"

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: ShowReadMe
# (the "ReadMe" function for the 'Finish' page)
#--------------------------------------------------------------------------

Function ShowReadMe

  StrCmp $G_NOTEPAD "" use_file_association
  Exec 'notepad.exe "$INSTDIR\${C_README}.txt"'
  goto exit

use_file_association:
  ExecShell "open" "$INSTDIR\${C_README}.txt"

exit:
FunctionEnd

#--------------------------------------------------------------------------
# Initialise the uninstaller
#--------------------------------------------------------------------------

Function un.onInit

  ; Retrieve the language used when this version was installed, and use it for the uninstaller

  !insertmacro MUI_UNGETLANGUAGE

FunctionEnd

#--------------------------------------------------------------------------
# Uninstaller Section
#--------------------------------------------------------------------------

Section "Uninstall"

  !define L_CFG         $R9   ; used as file handle
  !define L_EXE         $R8   ; full path of the EXE to be monitored
  !define L_INDEX       $R7
  !define L_ININAME     $R6   ; full path to the Eudora INI file modified by the installer
  !define L_LNE         $R5   ; a line from popfile.cfg
  !define L_OLDUI       $R4   ; holds old-style UI port (if previous POPFile is an old version)
  !define L_PERSONA     $R3   ; full section name for a Eudora personality
  !define L_POP_ACCOUNT $R2   ; L_POP_* used to restore Eudora settings
  !define L_POP_LOGIN   $R1
  !define L_POP_PORT    $R0
  !define L_POP_SERVER  $9
  !define L_REG_KEY     $8    ; L_REG_* used to restore Outlook/Outlook Express settings
  !define L_REG_SUBKEY  $7
  !define L_REG_VALUE   $6
  !define L_TEMP        $5

  IfFileExists $INSTDIR\popfile.pl skip_confirmation
  IfFileExists $INSTDIR\popfile.exe skip_confirmation
    MessageBox MB_YESNO|MB_ICONSTOP|MB_DEFBUTTON2 \
        "$(PFI_LANG_UN_MBNOTFOUND_1) '$INSTDIR'.\
        $\r$\n$\r$\n\
        $(PFI_LANG_UN_MBNOTFOUND_2)" IDYES skip_confirmation
    Abort "$(PFI_LANG_UN_ABORT_1)"

skip_confirmation:
  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROGRESS_1)"
  SetDetailsPrint listonly

  ; If the POPFile we are to uninstall is still running, one of the EXE files will be 'locked'

  Push "$INSTDIR\popfileb.exe"
  Call un.CheckIfLocked
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" 0 attempt_shutdown

  Push "$INSTDIR\popfileib.exe"
  Call un.CheckIfLocked
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" 0 attempt_shutdown

  Push "$INSTDIR\popfilef.exe"
  Call un.CheckIfLocked
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" 0 attempt_shutdown

  Push "$INSTDIR\popfileif.exe"
  Call un.CheckIfLocked
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" 0 attempt_shutdown

  Push "$INSTDIR\wperl.exe"
  Call un.CheckIfLocked
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" 0 attempt_shutdown

  Push "$INSTDIR\perl.exe"
  Call un.CheckIfLocked
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" remove_shortcuts

attempt_shutdown:
  StrCpy $G_GUI ""
  StrCpy ${L_OLDUI} ""

  ClearErrors
  FileOpen ${L_CFG} "$INSTDIR\popfile.cfg" r

loop:
  FileRead ${L_CFG} ${L_LNE}
  IfErrors ui_port_done

  StrCpy ${L_TEMP} ${L_LNE} 10
  StrCmp ${L_TEMP} "html_port " got_html_port

  StrCpy ${L_TEMP} ${L_LNE} 8
  StrCmp ${L_TEMP} "ui_port " got_ui_port
  Goto loop

got_html_port:
  StrCpy $G_GUI ${L_LNE} 5 10
  Goto loop

got_ui_port:
  StrCpy ${L_OLDUI} ${L_LNE} 5 8
  Goto loop

ui_port_done:
  FileClose ${L_CFG}

  StrCmp $G_GUI "" use_other_port
  Push $G_GUI
  Call un.TrimNewlines
  Call un.StrCheckDecimal
  Pop $G_GUI
  StrCmp $G_GUI "" use_other_port
  DetailPrint "$(PFI_LANG_UN_LOG_1) $G_GUI"
  NSISdl::download_quiet http://127.0.0.1:$G_GUI/shutdown "$PLUGINSDIR\shutdown.htm"
  Pop ${L_TEMP}
  Goto check_shutdown

use_other_port:
  Push ${L_OLDUI}
  Call un.TrimNewlines
  Call un.StrCheckDecimal
  Pop ${L_OLDUI}
  StrCmp ${L_OLDUI} "" remove_shortcuts
  DetailPrint "$(PFI_LANG_UN_LOG_1) ${L_OLDUI}"
  NSISdl::download_quiet http://127.0.0.1:${L_OLDUI}/shutdown "$PLUGINSDIR\shutdown.htm"
  Pop ${L_TEMP}

check_shutdown:
  Push ${L_EXE}
  Call un.WaitUntilUnlocked

remove_shortcuts:
  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROGRESS_2)"
  SetDetailsPrint listonly

  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\POPFile Home Page.url"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\POPFile Manual.url"
  RMDir "$SMPROGRAMS\${C_PFI_PRODUCT}\Support"

  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Release Notes.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Run POPFile.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Run POPFile in background.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Shutdown POPFile silently.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Uninstall POPFile.lnk"

  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\FAQ.url"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Manual.url"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\POPFile User Interface.url"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Shutdown POPFile.url"
  RMDir "$SMPROGRAMS\${C_PFI_PRODUCT}"

  Delete "$SMSTARTUP\Run POPFile in background.lnk"
  Delete "$SMSTARTUP\Run POPFile.lnk"

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROGRESS_3)"
  SetDetailsPrint listonly

  Delete $INSTDIR\popfile.pl
  Delete $INSTDIR\popfile.exe
  Delete $INSTDIR\popfile.cfg.bak
  Delete $INSTDIR\*.pm
  Delete $INSTDIR\*.dll
  Delete $INSTDIR\wperl.exe
  Delete $INSTDIR\wrapper.exe
  Delete $INSTDIR\wrapperf.exe
  Delete $INSTDIR\wrapperb.exe
  Delete $INSTDIR\wrapper.ini
  Delete $INSTDIR\sqlite.exe

  Delete $INSTDIR\expchanges.txt
  Delete $INSTDIR\expconfig.txt
  Delete $INSTDIR\outchanges.txt
  Delete $INSTDIR\outconfig.txt

  Delete $INSTDIR\*.gif
  Delete $INSTDIR\*.log
  Delete $INSTDIR\*.change
  Delete $INSTDIR\*.change.txt

  Delete $INSTDIR\bayes.pl
  Delete $INSTDIR\insert.pl
  Delete $INSTDIR\pipe.pl
  Delete $INSTDIR\favicon.ico
  Delete $INSTDIR\perl.exe
  Delete $INSTDIR\popfile.exe
  Delete $INSTDIR\popfilef.exe
  Delete $INSTDIR\popfileb.exe
  Delete $INSTDIR\popfileif.exe
  Delete $INSTDIR\popfileib.exe
  Delete $INSTDIR\stop_pf.exe
  Delete $INSTDIR\license
  Delete $INSTDIR\popfile.cfg

  ; Restore any email client settings which were changed during the install process

  IfFileExists "$INSTDIR\popfile.reg" 0 end_oe_restore

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROGRESS_4)"
  SetDetailsPrint listonly

  ; Read the registry settings found in popfile.reg and restore them
  ; it there are any.   All are assumed to be in HKCU

  ClearErrors
  FileOpen ${L_CFG} $INSTDIR\popfile.reg r
  IfErrors quit_oe_restore
  DetailPrint "$(PFI_LANG_UN_PROGRESS_4)"
  DetailPrint "$(PFI_LANG_UN_LOG_2): popfile.reg"

  ; The restore data for an OE account data can have either TWO or THREE entries, as follows:

  ; Entry 1
  ; Line x    : <Registry key for the OE Account>
  ; Line x+1  : POP 3 User Name
  ; Line x+2  : <user name data>

  ; Entry 2
  ; Line x+3  : <Registry key for the OE Account>
  ; Line x+4  : POP3 Server
  ; Line x+5  : <server data>

  ; Entry 3
  ; Line x+6  : <Registry key for the OE Account>
  ; Line x+7  : POP3 Port
  ; Line x+8  : <port number>

  ; NB The third entry (POP3 Port) only exists in post v0.20.1a installations.

restore_oe_loop:
  FileRead ${L_CFG} ${L_REG_KEY}
  Push ${L_REG_KEY}
  Call un.TrimNewlines
  Pop ${L_REG_KEY}
  IfErrors quit_oe_restore

  FileRead ${L_CFG} ${L_REG_SUBKEY}
  Push ${L_REG_SUBKEY}
  Call un.TrimNewlines
  Pop ${L_REG_SUBKEY}
  IfErrors quit_oe_restore

  FileRead ${L_CFG} ${L_REG_VALUE}
  Push ${L_REG_VALUE}
  Call un.TrimNewlines
  Pop ${L_REG_VALUE}
  IfErrors quit_oe_restore

  StrCmp ${L_REG_SUBKEY} "POP3 Port" 0 oe_string_value
  WriteRegDWORD HKCU ${L_REG_KEY} ${L_REG_SUBKEY} ${L_REG_VALUE}
  Goto log_oe_restore

oe_string_value:
  WriteRegStr HKCU ${L_REG_KEY} ${L_REG_SUBKEY} ${L_REG_VALUE}

log_oe_restore:
  DetailPrint "$(PFI_LANG_UN_LOG_3) ${L_REG_SUBKEY}: ${L_REG_VALUE}"
  goto restore_oe_loop

quit_oe_restore:
  FileClose ${L_CFG}
  DetailPrint "$(PFI_LANG_UN_LOG_4): popfile.reg"
  Delete $INSTDIR\popfile.reg

end_oe_restore:
  IfFileExists "$INSTDIR\outlook.reg" 0 end_outlook_restore

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROGRESS_7)"
  SetDetailsPrint listonly

  ; Read the registry settings found in outlook.reg and restore them
  ; it there are any.   All are assumed to be in HKCU

  ClearErrors
  FileOpen ${L_CFG} $INSTDIR\outlook.reg r
  IfErrors quit_outlook_restore
  DetailPrint "$(PFI_LANG_UN_PROGRESS_7)"
  DetailPrint "$(PFI_LANG_UN_LOG_2): outlook.reg"

  ; The restore data for an Outlook account data has following structure:

  ; Entry 1
  ; Line x    : <Registry key for the Outlook Account>
  ; Line x+1  : POP 3 User Name
  ; Line x+2  : <user name data>

  ; Entry 2
  ; Line x+3  : <Registry key for the Outlook Account>
  ; Line x+4  : POP3 Server
  ; Line x+5  : <server data>

  ; Entry 3
  ; Line x+6  : <Registry key for the Outlook Account>
  ; Line x+7  : POP3 Port
  ; Line x+8  : <port number>

restore_outlook_loop:
  FileRead ${L_CFG} ${L_REG_KEY}
  Push ${L_REG_KEY}
  Call un.TrimNewlines
  Pop ${L_REG_KEY}
  IfErrors quit_outlook_restore

  FileRead ${L_CFG} ${L_REG_SUBKEY}
  Push ${L_REG_SUBKEY}
  Call un.TrimNewlines
  Pop ${L_REG_SUBKEY}
  IfErrors quit_outlook_restore

  FileRead ${L_CFG} ${L_REG_VALUE}
  Push ${L_REG_VALUE}
  Call un.TrimNewlines
  Pop ${L_REG_VALUE}
  IfErrors quit_outlook_restore

  StrCmp ${L_REG_SUBKEY} "POP3 Port" 0 outlook_string_value
  WriteRegDWORD HKCU ${L_REG_KEY} ${L_REG_SUBKEY} ${L_REG_VALUE}
  Goto log_outlook_restore

outlook_string_value:
  WriteRegStr HKCU ${L_REG_KEY} ${L_REG_SUBKEY} ${L_REG_VALUE}

log_outlook_restore:
  DetailPrint "$(PFI_LANG_UN_LOG_3) ${L_REG_SUBKEY}: ${L_REG_VALUE}"
  goto restore_outlook_loop

quit_outlook_restore:
  FileClose ${L_CFG}
  DetailPrint "$(PFI_LANG_UN_LOG_4): outlook.reg"
  Delete $INSTDIR\outlook.reg

end_outlook_restore:
  IfFileExists "$INSTDIR\pfi-eudora.ini" 0 end_email_restore

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROGRESS_8)"
  SetDetailsPrint listonly

  ; If Eudora is running, ask the user to shut it down now (user may ignore our request)

check_if_running:
  FindWindow ${L_TEMP} "EudoraMainWindow"
  IsWindow ${L_TEMP} 0 restore_eudora

  MessageBox MB_ABORTRETRYIGNORE|MB_ICONSTOP|MB_DEFBUTTON2 "$(PFI_LANG_MBCLIENT_EUD)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_4)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_5)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_6)"\
             IDABORT end_email_restore IDRETRY check_if_running

restore_eudora:
  ClearErrors
  ReadINIStr ${L_INDEX} "$INSTDIR\pfi-eudora.ini" "History" "ListSize"
  IfErrors quit_eudora_restore
  Push ${L_INDEX}
  Call un.StrCheckDecimal
  Pop ${L_INDEX}
  StrCmp ${L_INDEX} "" quit_eudora_restore
  DetailPrint "$(PFI_LANG_UN_PROGRESS_8)"

read_undo_entry:

  ; Check the 'undo' entry has all of the necessary values

  ReadINIStr ${L_ININAME} "$INSTDIR\pfi-eudora.ini" "History" "Path-${L_INDEX}"
  StrCmp ${L_ININAME} "" next_undo
  IfFileExists ${L_ININAME} 0 next_undo

  ReadINIStr ${L_PERSONA} "$INSTDIR\pfi-eudora.ini" "Undo-${L_INDEX}" "Persona"
  StrCmp ${L_PERSONA} "" next_undo

  ReadINIStr ${L_POP_ACCOUNT} "$INSTDIR\pfi-eudora.ini" "Undo-${L_INDEX}" "POPAccount"
  StrCmp ${L_POP_ACCOUNT} "" next_undo

  ReadINIStr ${L_POP_SERVER} "$INSTDIR\pfi-eudora.ini" "Undo-${L_INDEX}" "POPServer"
  StrCmp ${L_POP_SERVER} "" next_undo

  ReadINIStr ${L_POP_LOGIN} "$INSTDIR\pfi-eudora.ini" "Undo-${L_INDEX}" "LoginName"
  StrCmp ${L_POP_LOGIN} "" next_undo

  ReadINIStr ${L_POP_PORT} "$INSTDIR\pfi-eudora.ini" "Undo-${L_INDEX}" "POPPort"
  StrCmp ${L_POP_PORT} "" next_undo

  StrCmp ${L_PERSONA} "*.*" special_case

  ClearErrors
  ReadINIStr ${L_TEMP} "${L_ININAME}" "${L_PERSONA}" "POPAccount"
  IfErrors next_undo
  WriteINIStr "${L_ININAME}" "${L_PERSONA}" "POPAccount" "${L_POP_ACCOUNT}"
  WriteINIStr "${L_ININAME}" "${L_PERSONA}" "POPServer" "${L_POP_SERVER}"
  WriteINIStr "${L_ININAME}" "${L_PERSONA}" "LoginName" "${L_POP_LOGIN}"

special_case:
  WriteINIStr "${L_ININAME}" "Settings"     "POPPort" "${L_POP_PORT}"

  DetailPrint "$(PFI_LANG_UN_LOG_3) ${L_PERSONA} 'POPServer': ${L_POP_SERVER}"
  DetailPrint "$(PFI_LANG_UN_LOG_3) ${L_PERSONA} 'LoginName': ${L_POP_LOGIN}"
  DetailPrint "$(PFI_LANG_UN_LOG_3) ${L_PERSONA} 'POPPort': ${L_POP_PORT}"

next_undo:
  IntOp ${L_INDEX} ${L_INDEX} - 1
  IntCmp ${L_INDEX} 0 quit_eudora_restore quit_eudora_restore read_undo_entry

quit_eudora_restore:
  Delete $INSTDIR\pfi-eudora.ini

end_email_restore:
  Delete $INSTDIR\Classifier\*.pm
  Delete $INSTDIR\Classifier\popfile.sql
  RMDir $INSTDIR\Classifier

  Delete $INSTDIR\Platform\*.pm
  Delete $INSTDIR\Platform\*.dll
  RMDir $INSTDIR\Platform

  Delete $INSTDIR\POPFile\*.pm
  Delete $INSTDIR\POPFile\popfile_version
  RMDir $INSTDIR\POPFile

  Delete $INSTDIR\Proxy\*.pm
  RMDir $INSTDIR\Proxy

  Delete $INSTDIR\UI\*.pm
  RMDir $INSTDIR\UI

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROGRESS_5)"
  SetDetailsPrint listonly

  Delete $INSTDIR\skins\*.css
  Delete $INSTDIR\skins\*.gif
  Delete $INSTDIR\skins\lavishImages\*.gif
  Delete $INSTDIR\skins\sleetImages\*.gif
  RMDir $INSTDIR\skins\sleetImages
  RMDir $INSTDIR\skins\lavishImages
  RMDir $INSTDIR\skins

  Delete $INSTDIR\manual\en\*.html
  RMDir $INSTDIR\manual\en
  Delete $INSTDIR\manual\*.gif
  RMDir $INSTDIR\manual

  Delete $INSTDIR\languages\*.msg
  RMDir $INSTDIR\languages

  RMDir /r $INSTDIR\corpus
  Delete $INSTDIR\popfile.db

  RMDir /r $INSTDIR\messages

  Delete $INSTDIR\stopwords
  Delete $INSTDIR\stopwords.bak
  Delete $INSTDIR\stopwords.default

  IfFIleExists "$INSTDIR\kakasi\*.*" 0 skip_kakasi
  RMDir /r "$INSTDIR\kakasi"

  ;Delete Environment Variables

  Push KANWADICTPATH
  Call un.DeleteEnvStr
  Push ITAIJIDICTPATH
  Call un.DeleteEnvStr

skip_kakasi:
  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROGRESS_6)"
  SetDetailsPrint listonly

  RMDir /r "$INSTDIR\auto"
  RMDir /r "$INSTDIR\Carp"
  RMDir /r "$INSTDIR\DBD"
  RMDir /r "$INSTDIR\Encode"
  RMDir /r "$INSTDIR\Exporter"
  RMDir /r "$INSTDIR\File"
  RMDir /r "$INSTDIR\Getopt"
  RMDir /r "$INSTDIR\IO"
  RMDir /r "$INSTDIR\MIME"
  RMDir /r "$INSTDIR\String"
  RMDir /r "$INSTDIR\Sys"
  RMDir /r "$INSTDIR\Text"
  RMDir /r "$INSTDIR\warnings"
  RMDir /r "$INSTDIR\Win32"

  Delete "$INSTDIR\Uninstall.exe"

  RMDir $INSTDIR

  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}"
  DeleteRegKey HKLM "SOFTWARE\${C_PFI_PRODUCT}"

  ; if $INSTDIR was removed, skip these next ones

  IfFileExists $INSTDIR 0 Removed
    MessageBox MB_YESNO|MB_ICONQUESTION "$(PFI_LANG_UN_MBREMDIR_1)" IDNO Removed
    DetailPrint "$(PFI_LANG_UN_LOG_5)"
    Delete $INSTDIR\*.* ; this would be skipped if the user hits no
    RMDir /r $INSTDIR
    IfFileExists $INSTDIR 0 Removed
      DetailPrint "$(PFI_LANG_UN_LOG_6)"
      MessageBox MB_OK|MB_ICONEXCLAMATION \
          "$(PFI_LANG_UN_MBREMERR_1): $INSTDIR $(PFI_LANG_UN_MBREMERR_2)"
Removed:

  SetDetailsPrint both

  !undef L_CFG
  !undef L_EXE
  !undef L_INDEX
  !undef L_ININAME
  !undef L_LNE
  !undef L_OLDUI
  !undef L_PERSONA
  !undef L_POP_ACCOUNT
  !undef L_POP_LOGIN
  !undef L_POP_PORT
  !undef L_POP_SERVER
  !undef L_REG_KEY
  !undef L_REG_SUBKEY
  !undef L_REG_VALUE
  !undef L_TEMP

SectionEnd

#--------------------------------------------------------------------------
# End of 'installer.nsi'
#--------------------------------------------------------------------------
