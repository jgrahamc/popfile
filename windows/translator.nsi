#--------------------------------------------------------------------------
#
# translator.nsi --- This NSIS script is used to create a special version
#                    of the POPFile Windows installer. This test program does not
#                    install POPFile, it only installs a few files and allows
#                    buckets to be created - it is designed to provide a realistic
#                    testbed for the POPFile Installer/Uninstaller language files.
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
#
# This NSIS script can be compiled on a system which does NOT have Perl installed.
#
# To compile this script, the following additional POPFile CVS files are required:
#
#   engine\license
#
#   windows\CBP.nsh
#   windows\hdr-common.bmp
#   windows\ioA.ini
#   windows\ioB.ini
#   windows\ioC.ini
#   windows\ioD.ini
#   windows\ioE.ini
#   windows\ioF.ini
#   windows\ioG.ini
#   windows\pfi-library.nsh
#   windows\remove.ico
#   windows\special.bmp
#
#   windows\translator.change           (the 'release notes' text file for this test program)
#   windows\translator.htm              (a simple HTML file used to represent the POPFile UI)
#   windows\translator.nsi              (this file; included to show its relative position)
#
#   windows\languages\English-pfi.nsh
#   windows\languages\*-pfi.nsh         (optional - see the 'LANGUAGE SUPPORT' comment below)
#
#   windows\POPFileIcon\popfile.ico
#
#   windows\UI\pfi_modern.exe
#   windows\UI\pfi_headerbmpr.exe
#
# This test program does NOT install POPFile or make any Outlook Express, Outlook or Eudora
# configuration changes.
#
# The only files unique to this test program are 'translator.change', 'translator.htm' and
# 'translator.nsi' - all of the other files are also used in the real POPFile installer.
#
#--------------------------------------------------------------------------

; As of 19 November 2003, the latest release of the NSIS compiler is 2.0b4. This release
; contains significant changes (especially to the MUI which is used by the POPFile installer)
; which are not backward-compatible (i.e. this POPFile installer script cannot be built by
; earlier versions of the NSIS compiler).

;  This version was tested using "NSIS 2 Release Candidate 1" released 27 December 2003

; IMPORTANT:
; The Outlook and Outlook Express Configuration pages use the NOWORDWRAP flag and this requires
; InstallOptions 2.3 (or later). This means InstallOptions.dll dated 5 Dec 2003 or later
; (i.e. InstallOptions.dll v1.73 or later). If this script is compiled with an earlier version
; of the DLL, the account details will not be displayed correctly if any field exceeds the
; column width.

#--------------------------------------------------------------------------
# LANGUAGE SUPPORT:
#
# The test program defaults to multi-language mode ('English' plus a number of other languages).
#
# If required, a command-line switch can be used to build an English-only version.
#
# Normal multi-language build command:  makensis.exe translator.nsi
# To build an English-only version:     makensis.exe  /DENGLISH_MODE translator.nsi
#
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
#   <NSIS Language NAME>-pfi.nsh  - holds customised versions of the standard MUI text strings
#                                   (eg removing the 'reboot' reference from the 'Welcome' page)
#                                   plus strings used on the custom pages and elsewhere
#
# Once this file has been prepared and placed in the 'windows\languages' directory with the
# other *-pfi.nsh files, add a new '!insertmacro PFI_LANG_LOAD' line to load this new file
# and, if there is a suitable POPFile UI language file for the new language, add a suitable
# '!insertmacro UI_LANG_CONFIG' line in the section which handles the optional 'Languages'
# component to allow the installer to select the appropriate UI language.
#--------------------------------------------------------------------------
# NOTE:
# This source file is a modified version of the 'real thing' so some comments may refer to
# actions which are not applicable to this test program. For example, this test program
# does not shutdown an existing version of POPFile or install/startup a new version of POPFile.
#--------------------------------------------------------------------------

  ;--------------------------------------------------------------------------
  ; POPFile constants have been given names beginning with 'C_' (eg C_README)
  ;--------------------------------------------------------------------------

  !define C_PFI_PRODUCT       "PFI Testbed"
  !define C_PFI_VERSION       "0.9.2"

  !ifdef    C_POPFILE_MAJOR_VERSION
    !undef  C_POPFILE_MAJOR_VERSION
  !endif

  !ifdef    C_POPFILE_MINOR_VERSION
    !undef  C_POPFILE_MINOR_VERSION
  !endif

  !ifdef    C_POPFILE_REVISION
    !undef  C_POPFILE_REVISION
  !endif

  !ifdef    C_POPFILE_RC
    !undef  C_POPFILE_RC
  !endif

  !define C_POPFILE_MAJOR_VERSION    "0"
  !define C_POPFILE_MINOR_VERSION   "12"
  !define C_POPFILE_REVISION         "3"

  Name                        "${C_PFI_PRODUCT}"
  Caption                     "${C_PFI_PRODUCT} ${C_PFI_VERSION} Setup"
  UninstallCaption            "${C_PFI_PRODUCT} ${C_PFI_VERSION} Uninstall"

  !ifndef ENGLISH_MODE
    !define C_PFI_VERSION_ID  "${C_PFI_VERSION} (ML)"
  !else
    !define C_PFI_VERSION_ID  "${C_PFI_VERSION} (English)"
  !endif

  !define C_README          "translator.change"
  !define C_RELEASE_NOTES   "${C_README}"

#--------------------------------------------------------------------------
# Delays (in milliseconds) used to simulate installation and uninstall activities
#--------------------------------------------------------------------------

  !define C_INST_PROG_UPGRADE_DELAY   2000
  !define C_INST_PROG_CORE_DELAY      2500
  !define C_INST_PROG_MBOX_DELAY      1000
  !define C_INST_PROG_PERL_DELAY      2500
  !define C_INST_PROG_SHORT_DELAY     2500
  !define C_INST_PROG_FFC_DELAY       2500
  !define C_INST_PROG_SKINS_DELAY     2500
  !define C_INST_PROG_LANGS_DELAY     2500

  !define C_INST_RUN_BANNER_DELAY     2500

  !define C_UNINST_PROGRESS_1_DELAY   2500
  !define C_UNINST_PROGRESS_2_DELAY   2500
  !define C_UNINST_PROGRESS_3_DELAY   2500
  !define C_UNINST_PROGRESS_4_DELAY   2500
  !define C_UNINST_PROGRESS_5_DELAY   2500
  !define C_UNINST_PROGRESS_6_DELAY   2500

#------------------------------------------------
# Define PFI_VERBOSE to get more compiler output
#------------------------------------------------

## !define PFI_VERBOSE

#-----------------------------------------------------------------------------------------
# "Dummy" constants to avoid NSIS compiler warnings (used by macros in 'pfi-library.nsh')
#-----------------------------------------------------------------------------------------

  !define C_SHUTDOWN_LIMIT   10
  !define C_SHUTDOWN_DELAY   500
  !define C_STARTUP_LIMIT    10
  !define C_STARTUP_DELAY    500

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

  VIProductVersion "${C_PFI_VERSION}.0"

  VIAddVersionKey "ProductName" "POPFile Installer Language Testbed"
  VIAddVersionKey "Comments" "POPFile Homepage: http://popfile.sf.net"
  VIAddVersionKey "CompanyName" "The POPFile Project"
  VIAddVersionKey "LegalCopyright" "© 2001-2003  John Graham-Cumming"
  VIAddVersionKey "FileDescription" "POPFile Installer Language Testbed"
  VIAddVersionKey "FileVersion" "${C_PFI_VERSION_ID}"

  VIAddVersionKey "Build Date/Time" "${__DATE__} @ ${__TIME__}"
  VIAddVersionKey "Build Script" "${__FILE__}$\r$\n(${__TIMESTAMP__})"

  !ifndef ENGLISH_MODE
    VIAddVersionKey "Build Type" "Multi-Language Testbed"
  !else
    VIAddVersionKey "Build Type" "English-Only Testbed"
  !endif

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

  ; Let user display the installation log (by clicking the "Show details" button)

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
  ; to obscure the installer window)

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
  Var G_OOELIST_CBOX       ; to access one of the 6 checkbox fields
  Var G_SEPARATOR          ; character used to separate the pop3 server from the username

  Var G_HWND               ; HWND of dialog we are going to modify
  Var G_DLGITEM            ; HWND of the field we are going to modify on that dialog
  Var G_FONT               ; font we use to modify the field

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

  OutFile "pfi-testbed.exe"

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

  Sleep ${C_INST_PROG_UPGRADE_DELAY}

  ; If we are installing over a previous version, (try to) ensure that version is not running

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

  File "${C_RELEASE_NOTES}"
  CopyFiles /SILENT /FILESONLY "$PLUGINSDIR\${C_README}.txt" "$INSTDIR\${C_README}.txt"
  File "translator.htm"

  MessageBox MB_YESNO|MB_ICONQUESTION \
      "POPFile 'stopwords' $(PFI_LANG_MBSTPWDS_1)\
      $\r$\n$\r$\n\
      $(PFI_LANG_MBSTPWDS_2)\
      $\r$\n$\r$\n\
      $(PFI_LANG_MBSTPWDS_3) 'stopwords.bak')\
      $\r$\n$\r$\n\
      $(PFI_LANG_MBSTPWDS_4) 'stopwords.default')"

  Sleep ${C_INST_PROG_MBOX_DELAY}

  MessageBox MB_YESNO|MB_ICONQUESTION \
      "$(PFI_LANG_MBCFGBK_1) 'popfile.cfg' $(PFI_LANG_MBCFGBK_2) ('popfile.cfg.bak').\
      $\r$\n$\r$\n\
      $(PFI_LANG_MBCFGBK_3)\
      $\r$\n$\r$\n\
      $(PFI_LANG_MBCFGBK_4)"

  Sleep ${C_INST_PROG_CORE_DELAY}

  ; Install the Minimal Perl files

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_PERL)"
  SetDetailsPrint listonly

  Sleep ${C_INST_PROG_PERL_DELAY}

  ; Create the uninstall program BEFORE creating the shortcut to it
  ; (this ensures that the correct "uninstall" icon appears in the START MENU shortcut)

  SetOutPath $INSTDIR
  Delete $INSTDIR\uninst_testbed.exe
  WriteUninstaller $INSTDIR\uninst_testbed.exe

  ; Create the START MENU entries

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_SHORT)"
  SetDetailsPrint listonly

  ; 'CreateShortCut' uses '$OUTDIR' as the working directory for the shortcut
  ; ('SetOutPath' is one way to change the value of $OUTDIR)

  SetOutPath "$SMPROGRAMS\${C_PFI_PRODUCT}"
  SetOutPath $INSTDIR
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Uninstall PFI Testbed.lnk" "$INSTDIR\uninst_testbed.exe"

  Sleep ${C_INST_PROG_SHORT_DELAY}

  ; Create entry in the Control Panel's "Add/Remove Programs" list

  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "DisplayName" "${C_PFI_PRODUCT} ${C_PFI_VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "UninstallString" "$INSTDIR\uninst_testbed.exe"
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

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_FFCBACK)"
  SetDetailsPrint listonly

  Sleep ${C_INST_PROG_FFC_DELAY}

  DetailPrint "Error detected when making corpus backup"
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(PFI_LANG_MBFFCERR_1)"

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_ENDSEC)"
  SetDetailsPrint listonly

SectionEnd

#--------------------------------------------------------------------------
# Installer Section: (optional) Skins component
#--------------------------------------------------------------------------

Section "Skins" SecSkins

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_SKINS)"
  SetDetailsPrint listonly

  Sleep ${C_INST_PROG_SKINS_DELAY}

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_ENDSEC)"
  SetDetailsPrint listonly

SectionEnd

#--------------------------------------------------------------------------
# Installer Section: (optional) UI Languages component
#--------------------------------------------------------------------------

Section "Languages" SecLangs

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_LANGS)"
  SetDetailsPrint listonly

  Sleep ${C_INST_PROG_LANGS_DELAY}

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_ENDSEC)"
  SetDetailsPrint listonly

SectionEnd

#--------------------------------------------------------------------------
# Component-selection page descriptions
#--------------------------------------------------------------------------

  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecPOPFile} $(DESC_SecPOPFile)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecSkins}   $(DESC_SecSkins)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecLangs}   $(DESC_SecLangs)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

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

  ; Ensure custom page matches the selected language (left-to-right or right-to-left order)

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioG.ini" "Settings" "RTL" "$(^RTL)"

  !insertmacro PFI_IO_TEXT "ioG.ini" "1" "$(PFI_LANG_PERLREQ_IO_TEXT_1)"
  !insertmacro PFI_IO_TEXT "ioG.ini" "2" "$(PFI_LANG_PERLREQ_IO_TEXT_2) ${L_VERSION}"
  !insertmacro PFI_IO_TEXT "ioG.ini" "3" "$(PFI_LANG_PERLREQ_IO_TEXT_3)"

  !insertmacro MUI_HEADER_TEXT "$(PFI_LANG_PERLREQ_TITLE)" "$(PFI_LANG_PERLREQ_SUBTITLE)"

  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioG.ini"

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
  Goto not_admin

got_name:
	Pop $G_WINUSERNAME
  StrCmp $G_WINUSERNAME "" 0 get_usertype
  StrCpy $G_WINUSERNAME "UnknownUser"

get_usertype:
  UserInfo::GetAccountType
	Pop $G_WINUSERTYPE
  StrCmp $G_WINUSERTYPE "Admin" not_admin
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

  !define L_EXE      $R9
  !define L_NEW_GUI  $R8

  Push ${L_EXE}
  Push ${L_NEW_GUI}

  StrCpy ${L_NEW_GUI} "9090"

  DetailPrint "$(PFI_LANG_INST_LOG_1) ${L_NEW_GUI}"

  MessageBox MB_OK|MB_ICONEXCLAMATION|MB_TOPMOST "$(PFI_LANG_MBMANSHUT_1)\
    $\r$\n$\r$\n\
    $(PFI_LANG_MBMANSHUT_2)\
    $\r$\n$\r$\n\
    $(PFI_LANG_MBMANSHUT_3)"

  Goto exit

  ; Insert some (inaccessible) calls to avoid NSIS compiler warnings

  StrCpy ${L_EXE} "$INSTDIR\wperl.exe"
  Push ${L_EXE}
  Call CheckIfLocked
  Pop ${L_EXE}

  StrCpy ${L_EXE} "$INSTDIR\wperl.exe"
  Push ${L_EXE}
  Call WaitUntilUnlocked

  Call GetParameters
  Pop ${L_EXE}
  
  Push "1"
  Call SetConsoleMode

  Push $INSTDIR
  Call GetCorpusPath
  Pop ${L_EXE}

exit:
  Pop ${L_NEW_GUI}
  Pop ${L_EXE}

  !undef L_EXE
  !undef L_NEW_GUI
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
# 'Languages' component for further details).
#--------------------------------------------------------------------------

Function CheckExistingConfig

  !define L_CFG       $R9     ; handle for "popfile.cfg"
  !define L_CLEANCFG  $R8     ; handle for "clean" copy
  !define L_CMPRE     $R7     ; config param name
  !define L_LNE       $R6     ; a line from popfile.cfg
  !define L_OLDUI     $R5     ; used to hold old-style of GUI port

warning:
  MessageBox MB_YESNO|MB_ICONQUESTION "$(PFI_LANG_DIRSELECT_MBWARN_1)\
      $\r$\n$\r$\n\
      $INSTDIR\
      $\r$\n$\r$\n$\r$\n\
      $(PFI_LANG_DIRSELECT_MBWARN_2)" IDYES check_destn
  Abort

check_destn:
  IfFileExists "$INSTDIR\popfile.exe" warning
  IfFileExists "$INSTDIR\perl.exe" warning
  IfFileExists "$INSTDIR\werl.exe" warning
  IfFileExists "$INSTDIR\pix.gif" warning

  Push ${L_CFG}
  Push ${L_CLEANCFG}
  Push ${L_CMPRE}
  Push ${L_LNE}
  Push ${L_OLDUI}

  StrCpy $G_POP3 ""
  StrCpy $G_GUI ""
  StrCpy ${L_OLDUI} ""

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

done:
  FileClose ${L_CFG}
  FileClose ${L_CLEANCFG}

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
  !insertmacro MUI_INSTALLOPTIONS_READ $G_GUI  "ioA.ini" "Field 4" "State"

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

  MessageBox MB_OK|MB_ICONEXCLAMATION \
      "$(PFI_LANG_CBP_MBMAKERR_1) 1 $(PFI_LANG_CBP_MBMAKERR_2) 4 \
      $(PFI_LANG_CBP_MBMAKERR_3)\
      $\r$\n$\r$\n\
      $(PFI_LANG_CBP_MBMAKERR_4)"

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
  StrCmp ${L_CLIENT_LIST} "" 0 display_page
  StrCpy ${L_CLIENT_LIST} "Example Client\r\nAnother Mail Client (*)"

display_page:
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
  MessageBox MB_ABORTRETRYIGNORE|MB_ICONSTOP|MB_DEFBUTTON2 "$(PFI_LANG_MBCLIENT_EXP)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_1)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_2)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_3)"\
             IDRETRY check_again IDIGNORE reconfigure_oe

  ; Abort has been selected so we do not offer to reconfigure any Outlook Express accounts

  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioB.ini" "Settings" "NumFields" "1"
  !insertmacro PFI_IO_TEXT "ioB.ini" "1" "$(PFI_LANG_EXPCFG_IO_CANCELLED)"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioB.ini"
  Goto exit

reconfigure_oe:
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

  GetDlgItem $G_DLGITEM $G_HWND 1200              ; Field 1 = IDENTITY label (above the box)
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

  GetDlgItem $G_DLGITEM $G_HWND 1200              ; Field 1 = IDENTITY label (above the box)
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
  !define L_IDENTITY     $R4

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

  ; The testbed does NOT change any Outlook Express settings, it just saves the current values

  ; To be able to restore the registry to previous settings when we uninstall we
  ; write a special file called popfile.reg.dummy containing the registry settings
  ; prior to modification in the form of lines consisting of
  ;
  ; the\key
  ; thesubkey
  ; the\value

  FileOpen  ${L_TEMP} $INSTDIR\popfile.reg.dummy a
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
#--------------------------------------------------------------------------

Function SetOutlookPage

  ; This is an initial attempt at providing reconfiguration of Outlook POP3 accounts
  ; (unlike the 'SetOutlookExpressPage' function, 'SetOutlookPage' is based upon theory
  ; instead of experiment)

  ; Each version of Outlook seems to use a slightly different location in the registry:
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
  ; which may hold the 'path' we need to use to access the Outlook account data
  ; (e.g. "Software\Microsoft\Office\Outlook\OMI Account Manager")

  ; All of the account data for the current user appears "under" the path defined
  ; above, e.g. if a user has several accounts, the account data is stored like this:
  ;    HKEY_CURRENT_USER\Software\Microsoft\Office\...\OMI Account Manager\Accounts\00000001
  ;    HKEY_CURRENT_USER\Software\Microsoft\Office\...\OMI Account Manager\Accounts\00000002
  ;    etc

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

  !insertmacro MUI_HEADER_TEXT "$(PFI_LANG_OUTCFG_TITLE)" "$(PFI_LANG_OUTCFG_SUBTITLE)"

check_again:
  MessageBox MB_ABORTRETRYIGNORE|MB_ICONSTOP|MB_DEFBUTTON2 "$(PFI_LANG_MBCLIENT_OUT)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_1)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_2)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_3)"\
             IDRETRY check_again IDIGNORE configure_outlook

  ; Abort has been selected so we do not offer to reconfigure any Outlook accounts

  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioB.ini" "Settings" "NumFields" "1"
  !insertmacro PFI_IO_TEXT "ioB.ini" "1" "$(PFI_LANG_OUTCFG_IO_CANCELLED)"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioB.ini"
  Goto exit

configure_outlook:

  ; Look for Outlook account data - if none found then use some dummy data

  ReadRegStr ${L_OUTLOOK} HKLM "Software\Microsoft\Internet Account Manager" "Outlook"
  StrCmp ${L_OUTLOOK} "" try_outlook_2000
  Push ${L_OUTLOOK}
  Push "OMI Account Manager"
  Call StrStr
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" try_outlook_2000

  ; It is hoped that we have now found the appropriate 'path' for the Outlook account data

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
  StrCmp ${L_OUTLOOK} "" use_dummy
  StrCpy ${L_OUTLOOK} "Software\Microsoft\Office\7.0\Outlook\OMI Account Manager\Accounts"
  Goto got_outlook_path

use_dummy:
  StrCpy ${L_OUTLOOK} "dummy"

got_outlook_path:
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

  StrCmp ${L_OUTLOOK} "dummy" use_dummy_data

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

  ; Find the Username used by Outlook and the Outlook Account Name
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

use_dummy_data:
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 1" "Text" "'$G_WINUSERNAME' $(PFI_LANG_OOECFG_IO_BOXHDR)"
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Identity" "Username" "$G_WINUSERNAME"

  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Field 8" "State" "Sample Account\r\n\r\nAnother One"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 9" "State"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Field 9" "State" "a.sample@.someisp.com\r\n\r\nexample@somewhere.net"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 10" "State"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Field 10" "State" "mail.someisp.com\r\n\r\npop3.mailserver.net"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 11" "State"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Field 11" "State" "sample\r\n\r\nan.example"

  IntOp $G_OOELIST_INDEX $G_OOELIST_INDEX + 1
  IntOp $G_OOELIST_CBOX $G_OOELIST_CBOX + 1
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field $G_OOELIST_CBOX" "Flags" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Account $G_OOELIST_INDEX" "AccountName" "Sample Account"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Account $G_OOELIST_INDEX" "EmailAddress" "a.sample@.someisp.com"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Account $G_OOELIST_INDEX" "POP3server" "mail.someisp.com"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Account $G_OOELIST_INDEX" "POP3username" "sample"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Account $G_OOELIST_INDEX" "POP3port" "110"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Account $G_OOELIST_INDEX" "RegistryKey" "unknown"

  IntOp $G_OOELIST_INDEX $G_OOELIST_INDEX + 1
  IntOp $G_OOELIST_CBOX $G_OOELIST_CBOX + 1
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field $G_OOELIST_CBOX" "Flags" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Account $G_OOELIST_INDEX" "AccountName" "Another One"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Account $G_OOELIST_INDEX" "EmailAddress" "example@somewhere.net"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Account $G_OOELIST_INDEX" "POP3server" "pop3.mailserver.net"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Account $G_OOELIST_INDEX" "POP3username" "an.example"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Account $G_OOELIST_INDEX" "POP3port" "110"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Account $G_OOELIST_INDEX" "RegistryKey" "unknown"

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Settings" "NumFields" "$G_OOELIST_CBOX"

display_list:

  ; Display the Outlook account data with checkboxes enabled for those accounts we can configure

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Identity" "PageStatus" "new"

  !insertmacro MUI_INSTALLOPTIONS_INITDIALOG "ioB.ini"
  Pop $G_HWND                 ; HWND of dialog we want to modify

  ; In 'GetDlgItem', use (1200 + Field number - 1) to refer to the field to be changed

  GetDlgItem $G_DLGITEM $G_HWND 1200             ; Field 1 = 'Outlook User' label (above the box)
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
  StrCmp ${L_OUTLOOK} "dummy" finished_the_accounts
  IntOp ${L_ACCT_INDEX} ${L_ACCT_INDEX} + 1
  goto next_acct

finished_the_accounts:
  IntCmp $G_OOELIST_INDEX 0 finished_outlook_config

display_list_again:
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Identity" "PageStatus" "new"

  !insertmacro MUI_INSTALLOPTIONS_INITDIALOG "ioB.ini"
  Pop $G_HWND                 ; HWND of dialog we want to modify

  ; In 'GetDlgItem', use (1200 + Field number - 1) to refer to the field to be changed

  GetDlgItem $G_DLGITEM $G_HWND 1200             ; Field 1 = 'Outlook User' label (above the box)
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

  ; This utility does not modify any of the Outlook account details, it just updates a log file

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

  ; Create two dummy entries to allow the Eudora strings to be checked

  StrCpy ${L_ININAME} "$PLUGINSDIR\dummy_EUD.ini"

  ; Dummy 'Dominant' personality (which can be reconfigured)

  WriteINIStr "${L_ININAME}" "Settings" "POPAccount" "Sample@sample.org"
  WriteINIStr "${L_ININAME}" "Settings" "POPServer"  "mail.sample.org"
  WriteINIStr "${L_ININAME}" "Settings" "LoginName"  "sample"
  WriteINIStr "${L_ININAME}" "Settings" "POPPort"    "110"
  WriteINIStr "${L_ININAME}" "Settings" "UsesPOP"    "1"

  ; Dummy 'Example' personality (which can't be reconfigured)

  WriteINIStr "${L_ININAME}" "Personalities" "Persona0" "Persona-Example Account"

  WriteINIStr "${L_ININAME}" "Persona-Example Account" "POPAccount" "an.example@another.isp"
  WriteINIStr "${L_ININAME}" "Persona-Example Account" "POPServer"  "127.0.0.1"
  WriteINIStr "${L_ININAME}" "Persona-Example Account" "LoginName"  "example"
  WriteINIStr "${L_ININAME}" "Persona-Example Account" "UsesPOP"    "1"

  !insertmacro MUI_HEADER_TEXT "$(PFI_LANG_EUCFG_TITLE)" "$(PFI_LANG_EUCFG_SUBTITLE)"

  ; If Eudora is running, ask the user to shut it down now
  ; (user is allowed to ignore our request)

check_if_running:
  MessageBox MB_ABORTRETRYIGNORE|MB_ICONSTOP|MB_DEFBUTTON2 "$(PFI_LANG_MBCLIENT_EUD)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_1)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_2)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_3)"\
             IDRETRY check_if_running IDIGNORE configure_eudora

  ; Abort has been selected so we do not offer to reconfigure any Eudora accounts

  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioE.ini" "Settings" "NumFields" "1"
  !insertmacro PFI_IO_TEXT "ioE.ini" "1" "$(PFI_LANG_EUCFG_IO_CANCELLED)"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioE.ini"
  Goto exit

configure_eudora:
  !insertmacro PFI_IO_TEXT "ioE.ini" "4" "$(PFI_LANG_EUCFG_IO_DOMINANT)"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 2" "State" "0"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 2" "Flags" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 3" "Flags" ""

  StrCpy ${L_INDEX} -1

  ReadINIStr ${L_EMAIL}  "${L_ININAME}" "Settings" "POPAccount"
  ReadINIStr ${L_SERVER} "${L_ININAME}" "Settings" "POPServer"
  ReadINIStr ${L_USER}   "${L_ININAME}" "Settings" "LoginName"
  ReadINIStr ${L_PORT}   "${L_ININAME}" "Settings" "POPPort"
  ReadINIStr ${L_STATUS} "${L_ININAME}" "Settings" "UsesPOP"

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
  StrCmp ${L_STATUS} 1 display_persona
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 2" "Flags" "DISABLED"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 3" "Flags" "DISABLED"
  Goto display_persona

get_next_persona:
  IntOp ${L_INDEX} ${L_INDEX} + 1
  ReadINIStr ${L_PERSONA}  "${L_ININAME}" "Personalities" "Persona${L_INDEX}"
  StrCmp ${L_PERSONA} "" exit

  StrCpy ${L_TEMP} ${L_PERSONA} "" 8

  !insertmacro PFI_IO_TEXT "ioE.ini" "4" "'${L_TEMP}' $(PFI_LANG_EUCFG_IO_PERSONA)"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 2" "State" "0"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 2" "Flags" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 3" "Flags" ""

  ReadINIStr ${L_EMAIL}  "${L_ININAME}" "${L_PERSONA}" "POPAccount"
  ReadINIStr ${L_SERVER} "${L_ININAME}" "${L_PERSONA}" "POPServer"
  ReadINIStr ${L_USER}   "${L_ININAME}" "${L_PERSONA}" "LoginName"
  ReadINIStr ${L_PORT}   "${L_ININAME}" "Settings" "POPPort"
  ReadINIStr ${L_STATUS} "${L_ININAME}" "${L_PERSONA}" "UsesPOP"

  StrCmp ${L_EMAIL} "" 0 check_server_A
  StrCpy ${L_EMAIL} "N/A"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 2" "Flags" "DISABLED"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 3" "Flags" "DISABLED"

check_server_A:
  StrCmp ${L_SERVER} "127.0.0.1" disable_A
  StrCmp ${L_SERVER} "" 0 check_username_A
  StrCpy ${L_SERVER} "N/A"

disable_A:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 2" "Flags" "DISABLED"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 3" "Flags" "DISABLED"

check_username_A:
  StrCmp ${L_USER} "" 0 check_port_A
  StrCpy ${L_USER} "N/A"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 2" "Flags" "DISABLED"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 3" "Flags" "DISABLED"

check_port_A:
  StrCmp ${L_PORT} "" 0 check_status_A
  StrCpy ${L_PORT} "110"

check_status_A:
  StrCmp ${L_STATUS} 1 display_persona
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 2" "Flags" "DISABLED"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 3" "Flags" "DISABLED"

display_persona:
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

  Goto get_next_persona

exit:
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
#--------------------------------------------------------------------------

Function StartPOPFilePage

  !insertmacro MUI_HEADER_TEXT "$(PFI_LANG_LAUNCH_TITLE)" "$(PFI_LANG_LAUNCH_SUBTITLE)"

  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioC.ini"

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: CheckLaunchOptions
# (the "leave" function for the custom page created by "StartPOPFilePage")
#
# This function is used to action the "start POPFile" option selected by the user.
# The user is allowed to return to this page and change their selection, so the
# previous state is stored in the INI file used for this custom page.
#--------------------------------------------------------------------------

Function CheckLaunchOptions

  !define L_RESULT      $R9
  !define L_TEMP        $R8

  Push ${L_RESULT}
  Push ${L_TEMP}

  ; Field 2 = 'Do not run POPFile' radio button

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Field 2" "State"
  StrCmp ${L_TEMP} "0" run_popfile

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Run Status" "LastAction"
  StrCmp ${L_TEMP} "" exit_without_banner
  StrCmp ${L_TEMP} "no" exit_without_banner
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Run Status" "LastAction" "no"

  ; User has changed their mind: Shutdown the newly installed version of POPFile

  Sleep 250 ; milliseconds
  goto exit_without_banner

run_popfile:

  ; Field 4 = 'Run POPFile in background' radio button

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Field 4" "State"
  StrCmp ${L_TEMP} "1" run_in_background

  ; Run POPFile in a DOS box

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Run Status" "LastAction"
  StrCmp ${L_TEMP} "DOS-box" exit_without_banner
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Run Status" "LastAction" "DOS-box"

  Banner::show /NOUNLOAD /set 76 "$(PFI_LANG_LAUNCH_BANNER_1)" "$(PFI_LANG_LAUNCH_BANNER_2)"

  ; Before starting the newly installed POPFile, ensure that no other version of POPFile
  ; is running on the same UI port as the newly installed version.

  Sleep ${C_INST_RUN_BANNER_DELAY}
  goto wait_for_popfile

run_in_background:

  ; Run POPFile without a DOS box

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Run Status" "LastAction"
  StrCmp ${L_TEMP} "background" exit_without_banner
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Run Status" "LastAction" "background"

  Banner::show /NOUNLOAD /set 76 "$(PFI_LANG_LAUNCH_BANNER_1)" "$(PFI_LANG_LAUNCH_BANNER_2)"

  ; Before starting the newly installed POPFile, ensure that no other version of POPFile
  ; is running on the same UI port as the newly installed version.

  Sleep ${C_INST_RUN_BANNER_DELAY}

wait_for_popfile:

  ; Wait until POPFile is ready to display the UI (may take a second or so)

  StrCpy ${L_TEMP} 5   ; Timeout limit to avoid an infinite loop

check_if_ready:
  Sleep 250   ; milliseconds
  IntOp ${L_TEMP} ${L_TEMP} - 1
  IntCmp ${L_TEMP} 0 remove_banner remove_banner check_if_ready

remove_banner:
  Banner::destroy

exit_without_banner:

  Pop ${L_TEMP}
  Pop ${L_RESULT}

  !undef L_RESULT
  !undef L_TEMP

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

  !insertmacro MUI_HEADER_TEXT "$(PFI_LANG_FLATFILE_TITLE)" "$(PFI_LANG_FLATFILE_SUBTITLE)"

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

  Banner::show /NOUNLOAD /set 76 "$(PFI_LANG_OPTIONS_BANNER_1)" "$(PFI_LANG_OPTIONS_BANNER_2)"
  Sleep ${C_INST_RUN_BANNER_DELAY}
  Banner::destroy

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: CheckRunStatus
# (the "pre" function for the 'Finish' page)
#
# The 'Finish' page contains two CheckBoxes: one to control whether or not the installer
# starts the POPFile User Interface and one to control whether or not the 'ReadMe' file is
# displayed. The User Interface only works when POPFile is running, so we must ensure its
# CheckBox can only be ticked if the installer has started POPFile.
#--------------------------------------------------------------------------

Function CheckRunStatus

  !define L_TEMP        $R9

  Push ${L_TEMP}

  ; Field 4 is the 'Run' CheckBox on the 'Finish' page

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 4" "Flags" ""

  ; Get the status of the 'Do not run POPFile' radio button on the 'Start POPFile' page

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Field 2" "State"
  StrCmp ${L_TEMP} "0" selection_ok

  ; User has not started POPFile so we cannot offer to display the POPFile User Interface

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

  ExecShell "open" "$INSTDIR\translator.htm"

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
  !define L_EXE         $R7   ; full path of the EXE to be monitored
  !define L_LNE         $R5   ; a line from popfile.cfg
  !define L_OLDUI       $R4   ; holds old-style UI port (if previous POPFile is an old version)
  !define L_REG_KEY     $R3   ; L_REG_* registers are used to  restore Outlook Express settings
  !define L_REG_SUBKEY  $R2
  !define L_REG_VALUE   $R1
  !define L_TEMP        $R0

  MessageBox MB_YESNO|MB_ICONSTOP|MB_DEFBUTTON2 \
      "$(PFI_LANG_UN_MBNOTFOUND_1) '$INSTDIR'.\
      $\r$\n$\r$\n\
      $(PFI_LANG_UN_MBNOTFOUND_2)" IDYES skip_confirmation
  Abort "$(PFI_LANG_UN_ABORT_1)"

skip_confirmation:

  ; Insert some (inaccessible) calls to avoid NSIS compiler warnings

  Goto continue

  StrCpy ${L_EXE} "$INSTDIR\wperl.exe"
  Push ${L_EXE}
  Call un.CheckIfLocked
  Pop ${L_EXE}
  StrCpy ${L_EXE} "$INSTDIR\wperl.exe"
  Push ${L_EXE}
  Call un.WaitUntilUnlocked
  Push "123"
  Call un.StrCheckDecimal
  Pop ${L_EXE}

continue:
  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROGRESS_1)"
  SetDetailsPrint listonly

  DetailPrint "$(PFI_LANG_UN_LOG_1) 8080"

  Sleep ${C_UNINST_PROGRESS_1_DELAY}

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROGRESS_2)"
  SetDetailsPrint listonly

  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Uninstall PFI Testbed.lnk"
  RMDir "$SMPROGRAMS\${C_PFI_PRODUCT}"

  Sleep ${C_UNINST_PROGRESS_2_DELAY}

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROGRESS_3)"
  SetDetailsPrint listonly

  Sleep ${C_UNINST_PROGRESS_3_DELAY}

  Delete $INSTDIR\popfile.cfg.bak

  ; Note: 'translator.htm' is not deleted here
  ; (this ensures the message box showing the 'PFI_LANG_UN_MBREMDIR_1' string appears later on)

  Delete $INSTDIR\*.gif
  Delete $INSTDIR\*.change
  Delete $INSTDIR\*.change.txt
  Delete $INSTDIR\license
  Delete $INSTDIR\popfile.cfg
  Delete $INSTDIR\expchanges.txt
  Delete $INSTDIR\expconfig.txt
  Delete $INSTDIR\outchanges.txt
  Delete $INSTDIR\outconfig.txt

  IfFileExists "$INSTDIR\popfile.reg.dummy" 0 no_reg_file

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROGRESS_4)"
  SetDetailsPrint listonly

  ; Read the registry settings found in popfile.reg.dummy and restore them
  ; it there are any.   All are assumed to be in HKCU

  ClearErrors
  FileOpen ${L_CFG} $INSTDIR\popfile.reg.dummy r
  IfErrors skip_registry_restore
  Sleep ${C_UNINST_PROGRESS_4_DELAY}

  DetailPrint "$(PFI_LANG_UN_LOG_2): popfile.reg.dummy"

restore_loop:
  FileRead ${L_CFG} ${L_REG_KEY}
  Push ${L_REG_KEY}
  Call un.TrimNewlines
  Pop ${L_REG_KEY}
  IfErrors skip_registry_restore
  FileRead ${L_CFG} ${L_REG_SUBKEY}
  Push ${L_REG_SUBKEY}
  Call un.TrimNewlines
  Pop ${L_REG_SUBKEY}
  IfErrors skip_registry_restore
  FileRead ${L_CFG} ${L_REG_VALUE}
  Push ${L_REG_VALUE}
  Call un.TrimNewlines
  Pop ${L_REG_VALUE}
  IfErrors skip_registry_restore

  ; Testbed does NOT restore Outlook Express settings (it never changed them during 'install')

  DetailPrint "$(PFI_LANG_UN_LOG_3) ${L_REG_SUBKEY}: ${L_REG_VALUE}"
  goto restore_loop

skip_registry_restore:
  FileClose ${L_CFG}
  DetailPrint "$(PFI_LANG_UN_LOG_4): popfile.reg.dummy"
  Delete $INSTDIR\popfile.reg.dummy

no_reg_file:
  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROGRESS_5)"
  SetDetailsPrint listonly

  Sleep ${C_UNINST_PROGRESS_5_DELAY}

  Delete $INSTDIR\languages\*.msg
  RMDir $INSTDIR\languages

  RMDir /r $INSTDIR\corpus

  Delete $INSTDIR\stopwords
  Delete $INSTDIR\stopwords.bak
  Delete $INSTDIR\stopwords.default

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROGRESS_6)"
  SetDetailsPrint listonly

  Sleep ${C_UNINST_PROGRESS_6_DELAY}

  Delete "$INSTDIR\uninst_testbed.exe"

  RMDir $INSTDIR

  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}"
  DeleteRegKey HKLM "SOFTWARE\${C_PFI_PRODUCT}"

  ; if $INSTDIR was removed, skip these next ones

  IfFileExists $INSTDIR 0 Removed
    MessageBox MB_YESNO|MB_ICONQUESTION "$(PFI_LANG_UN_MBREMDIR_1)" IDNO Removed
    DetailPrint "$(PFI_LANG_UN_LOG_5)"
    Delete $INSTDIR\*.* ; this would be skipped if the user hits no
    RMDir /r $INSTDIR
    DetailPrint "$(PFI_LANG_UN_LOG_6)"
    MessageBox MB_OK|MB_ICONEXCLAMATION \
        "$(PFI_LANG_UN_MBREMERR_1): $INSTDIR $(PFI_LANG_UN_MBREMERR_2)"
Removed:

  SetDetailsPrint both

  !undef L_CFG
  !undef L_EXE
  !undef L_LNE
  !undef L_OLDUI
  !undef L_REG_KEY
  !undef L_REG_SUBKEY
  !undef L_REG_VALUE
  !undef L_TEMP
SectionEnd

#--------------------------------------------------------------------------
# End of 'translator.nsi'
#--------------------------------------------------------------------------
