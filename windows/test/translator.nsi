#--------------------------------------------------------------------------
#
# translator.nsi --- This NSIS script is used to create a special version
#                    of the POPFile Windows installer. This test program does not
#                    install POPFile, it only installs a few files - it is designed
#                    to provide a reasonably realistic test of the language files
#                    for the POPFile installer/uninstaller package.
#
#                    Requires the following test programs:
#                    (1) transauw.exe (built using the 'transAUW.nsi' NSIS script)
#                    (2) transmcc.exe (built using the 'transMCC.nsi' NSIS script)
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
# To build the entire translator test package, the following additional POPFile CVS files
# are required:
#
#   engine\license
#
#   windows\CBP.nsh
#   windows\ioA.ini
#   windows\ioB.ini
#   windows\ioC.ini
#   windows\ioE.ini
#   windows\ioF.ini
#   windows\ioG.ini
#   windows\pfi-languages.nsh
#   windows\pfi-library.nsh
#   windows\remove.ico
#
#   windows\languages\English-pfi.nsh
#   windows\languages\*-pfi.nsh         (optional - see the 'LANGUAGE SUPPORT' comment below)
#
#   windows\POPFileIcon\popfile.ico
#
#   windows\UI\pfi_modern.exe
#   windows\UI\pfi_headerbmpr.exe
#
#   windows\test\hdr-common-test.bmp    (customised version of the logo used on most pages)
#   windows\test\special-test.bmp       (customised bitmap for the WELCOME and FINISH pages)
#   windows\test\translator.nsi         (this file; included to show its relative position)
#   windows\test\transAUW.nsi           (a test version of 'adduser.nsi', builds transauw.exe)
#   windows\test\transMCC.nsi           (a test version of 'MonitorCC.nsi', builds transmcc.exe)
#
# The following non-CVS files are used:
#
#   windows\test\translator.change      (the 'release notes' text file for this test package)
#   windows\test\translator.htm         (a simple HTML file used to represent the POPFile UI)
#
# The translator test package does NOT install POPFile, make any Outlook Express, Outlook or
# Eudora configuration changes or convert any existing old-style corpus files.
#
# The only files unique to this test package are those in the 'windows\test' folder - all of the
# other files are also used in the real POPFile installer.
#
#--------------------------------------------------------------------------

; This version of the script has been tested with the "NSIS 2" compiler (final),
; released 7 February 2004, with no patches applied.
;
; Expect 3 compiler warnings, all related to standard NSIS language files which are out-of-date.

; IMPORTANT:
; The Outlook and Outlook Express Configuration pages use the NOWORDWRAP flag and this requires
; InstallOptions 2.3 (or later). This means InstallOptions.dll dated 5 Dec 2003 or later
; (i.e. InstallOptions.dll v1.73 or later). If this script is compiled with an earlier version
; of the DLL, the account details will not be displayed correctly if any field exceeds the
; column width.

#--------------------------------------------------------------------------
# Optional run-time command-line switch (used by 'setup.exe')
#--------------------------------------------------------------------------
#
# /nouser
#
# This command-line switch is used to stop the installer from launching the 'Add POPFile User'
# wizard after installing the POPFile program files.
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
# LANGUAGE SUPPORT:
#
# The testbed defaults to multi-language mode ('English' plus a number of other languages).
#
# If required, the command-line switch /DENGLISH_MODE can be used to build an English-only
# version.
#
# Normal multi-language build command:  makensis.exe translator.nsi
# To build an English-only version:     makensis.exe  /DENGLISH_MODE translator.nsi
#--------------------------------------------------------------------------
# The POPFile installer uses several multi-language mode programs built using NSIS. To make
# maintenance easier, an 'include' file (pfi-languages.nsh) defines the supported languages.
#
# To remove support for a particular language, comment-out the relevant line in the list of
# languages in the 'pfi-languages.nsh' file.
#
# For instructions on how to add support for new languages, see the 'pfi-languages.nsh' file.
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
  !define C_PFI_VERSION       "0.11.1"

  Name                        "${C_PFI_PRODUCT}"
  Caption                     "${C_PFI_PRODUCT} ${C_PFI_VERSION} Setup"
  UninstallCaption            "${C_PFI_PRODUCT} ${C_PFI_VERSION} Uninstall"

  !ifndef ENGLISH_MODE
    !define C_PFI_VERSION_ID  "${C_PFI_VERSION} (ML)"
  !else
    !define C_PFI_VERSION_ID  "${C_PFI_VERSION} (English)"
  !endif

  !define C_README            "translator.change"
  !define C_RELEASE_NOTES     "${C_README}"

#--------------------------------------------------------------------------
# Delays (in milliseconds) used to simulate installation and uninstall activities
#--------------------------------------------------------------------------

  !define C_INST_PROG_UPGRADE_DELAY     2000
  !define C_INST_PROG_CORE_DELAY        2500
  !define C_INST_PROG_PERL_DELAY        2500
  !define C_INST_PROG_SHORT_DELAY       2500
  !define C_INST_PROG_SKINS_DELAY       2500
  !define C_INST_PROG_LANGS_DELAY       2500
  !define C_INST_PROG_XMLRPC_DELAY      2500

  !define C_UNINST_PROG_SHUTDOWN_DELAY  2500
  !define C_UNINST_PROG_SHORT_DELAY     2500
  !define C_UNINST_PROG_CORE_DELAY      2500
  !define C_UNINST_PROG_EMAIL_DELAY     2500
  !define C_UNINST_PROG_SKINS_DELAY     2500
  !define C_UNINST_PROG_PERL_DELAY      2500

#------------------------------------------------
# Define PFI_VERBOSE to get more compiler output
#------------------------------------------------

## !define PFI_VERBOSE

#--------------------------------------------------------------------------
# User Registers (Global)
#--------------------------------------------------------------------------

  ; This script uses 'User Variables' (with names starting with 'G_') to hold GLOBAL data.

  Var G_USERDIR            ; used to pass popfile.cfg folder path to CBP package

  Var G_STARTUP            ; holds the parameters supplied, if any, when starting setup.exe)
  Var G_NOTEPAD            ; path to notepad.exe ("" = not found in search path)

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
# Use the "Modern User Interface"
#--------------------------------------------------------------------------

  !include "MUI.nsh"

#--------------------------------------------------------------------------
# Version Information settings (for the installer EXE and uninstaller EXE)
#--------------------------------------------------------------------------

  ; 'VIProductVersion' format is X.X.X.X where X is a number in range 0 to 65535
  ; representing the following values: Major.Minor.Release.Build

  VIProductVersion                   "${C_PFI_VERSION}.0"

  VIAddVersionKey "ProductName"      "POPFile Installer Language Testbed"
  VIAddVersionKey "Comments"         "POPFile Homepage: http://popfile.sf.net"
  VIAddVersionKey "CompanyName"      "The POPFile Project"
  VIAddVersionKey "LegalCopyright"   "© 2001-2004  John Graham-Cumming"
  VIAddVersionKey "FileDescription"  "POPFile Installer Language Testbed"
  VIAddVersionKey "FileVersion"      "${C_PFI_VERSION_ID}"

  VIAddVersionKey "Build Date/Time"  "${__DATE__} @ ${__TIME__}"
  VIAddVersionKey "Build Script"     "${__FILE__}$\r$\n(${__TIMESTAMP__})"

  !ifndef ENGLISH_MODE
    VIAddVersionKey "Build Type"     "Multi-Language Testbed"
  !else
    VIAddVersionKey "Build Type"     "English-Only Testbed"
  !endif

#--------------------------------------------------------------------------
# Include private library functions and macro definitions
#--------------------------------------------------------------------------

  ; Avoid compiler warnings by disabling the functions and definitions we do not use

  !define TRANSLATOR

  !include "..\pfi-library.nsh"

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

  !define MUI_ICON                            "..\POPFileIcon\popfile.ico"
  !define MUI_UNICON                          "..\remove.ico"

  ; The "Header" bitmap appears on all pages of the installer (except Welcome & Finish pages)
  ; and on all pages of the uninstaller.

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
  ;  Interface Settings - Welcome/Finish Page Interface Settings
  ;----------------------------------------------------------------

  ; The "Special" bitmap appears on the "Welcome" and "Finish" pages

  !define MUI_WELCOMEFINISHPAGE_BITMAP        "special-test.bmp"

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

  !define MUI_CUSTOMFUNCTION_GUIINIT          PFIGUIInit

  ;----------------------------------------------------------------
  ; Language Settings for MUI pages
  ;----------------------------------------------------------------

  ; Same "Language selection" dialog is used for the installer and the uninstaller
  ; so we override the standard "Installer Language" title to avoid confusion.

  !define MUI_LANGDLL_WINDOWTITLE             "Language Selection"

  ; Always show the language selection dialog, even if a language has been stored in the
  ; registry (the language stored in the registry will be selected as the default language)

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
  ; Installer Page - Welcome
  ;---------------------------------------------------

  ; Use a "pre" function for the 'Welcome' page to ensure the installer window is visible
  ; (if the "Release Notes" were displayed, another window could have been positioned
  ; to obscure the installer window)

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

  !insertmacro MUI_PAGE_LICENSE               "..\..\engine\license"

  ;---------------------------------------------------
  ; Installer Page - Select Components to be installed
  ;---------------------------------------------------

  !insertmacro MUI_PAGE_COMPONENTS

  ;---------------------------------------------------
  ; Installer Page - Select installation Directory
  ;---------------------------------------------------

  ; Use a "leave" function to look for 'popfile.cfg' in the directory selected for this install

  !define MUI_PAGE_CUSTOMFUNCTION_LEAVE       "CheckExistingConfig"

  ; This page is used to select the folder for the POPFile PROGRAM files

  !define MUI_PAGE_HEADER_TEXT                "$(PFI_LANG_ROOTDIR_TITLE)"
  !define MUI_DIRECTORYPAGE_TEXT_DESTINATION  "$(PFI_LANG_ROOTDIR_TEXT_DESTN)"

  !insertmacro MUI_PAGE_DIRECTORY

  ;---------------------------------------------------
  ; Installer Page - Install files
  ;---------------------------------------------------

  !insertmacro MUI_PAGE_INSTFILES

  ;---------------------------------------------------
  ; Installer Page - Finish
  ;---------------------------------------------------

  ; Use a "pre" function for the 'Finish' page to run the 'Add POPFile User' wizard to
  ; configure POPFile for the user running the installer.

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
  ; Currently a subset of the languages supported by NSIS MUI 1.70 (using the NSIS names)
  ;-----------------------------------------

  ; At least one language must be specified for the installer (the default is "English")

  !insertmacro PFI_LANG_LOAD "English"

  ; Conditional compilation: if ENGLISH_MODE is defined, support only 'English'

  !ifndef ENGLISH_MODE
        !include "..\pfi-languages.nsh"
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
  InstallDirRegKey HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "InstallPath"

#--------------------------------------------------------------------------
# Reserve the files required by the installer (to improve performance)
#--------------------------------------------------------------------------

  ;Things that need to be extracted on startup (keep these lines before any File command!)
  ;Only useful for BZIP2 compression
  ;Use ReserveFile for your own Install Options ini files too!

  !insertmacro MUI_RESERVEFILE_LANGDLL
  !insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
  ReserveFile "..\ioG.ini"
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

  !insertmacro MUI_INSTALLOPTIONS_EXTRACT_AS "..\ioG.ini" "ioG.ini"

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
# (this code was moved from '.onInit' in order to permit the custom pages
# to be set up to use the language selected by the user)
#--------------------------------------------------------------------------

Function PFIGUIInit

  MessageBox MB_OK|MB_ICONEXCLAMATION "$(PFI_LANG_INSTALLER_MUTEX)"

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

  StrCpy $G_USERDIR $INSTDIR

  ; If we are installing over a previous version, (try to) ensure that version is not running

  Call MakeItSafe

  WriteRegStr HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "InstallPath" "$INSTDIR"

  ; Install the POPFile Core files

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_CORE)"
  SetDetailsPrint listonly

  SetOutPath $INSTDIR

  File "${C_RELEASE_NOTES}"
  CopyFiles /SILENT /FILESONLY "$PLUGINSDIR\${C_README}.txt" "$INSTDIR\${C_README}.txt"
  File "translator.htm"
  File "transauw.exe"
  File "transmcc.exe"

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
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Add POPFile User Demo.lnk" \
                 "$INSTDIR\transauw.exe"
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Corpus Conversion Demo.lnk" \
                 "$INSTDIR\transmcc.exe"
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Corpus Conversion Demo (failure).lnk" \
                 "$INSTDIR\transmcc.exe" "/abort"
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Uninstall PFI Testbed.lnk" \
                 "$INSTDIR\uninst_testbed.exe"

  Sleep ${C_INST_PROG_SHORT_DELAY}

  ; Create entry in the Control Panel's "Add/Remove Programs" list

  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "DisplayName" "${C_PFI_PRODUCT} ${C_PFI_VERSION}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "UninstallString" "$INSTDIR\uninst_testbed.exe"
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "NoModify" "1"
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "NoRepair" "1"

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_ENDSEC)"
  SetDetailsPrint listonly

  Pop ${L_CFG}

  !undef L_CFG

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
# Installer Section: (optional) POPFile XMLRPC component
#--------------------------------------------------------------------------

Section "XMLRPC" SecXMLRPC

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_XMLRPC)"
  SetDetailsPrint listonly

  Sleep ${C_INST_PROG_XMLRPC_DELAY}

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
    !insertmacro MUI_DESCRIPTION_TEXT ${SecXMLRPC}  $(DESC_SecXMLRPC)
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

  !insertmacro PFI_IO_TEXT "ioG.ini" "1" \
      "$(PFI_LANG_PERLREQ_IO_TEXT_1)\
       $(PFI_LANG_PERLREQ_IO_TEXT_2)\
       $(PFI_LANG_PERLREQ_IO_TEXT_3)\
       $(PFI_LANG_PERLREQ_IO_TEXT_4)"

  !insertmacro PFI_IO_TEXT "ioG.ini" "2" \
      "$(PFI_LANG_PERLREQ_IO_TEXT_5) 4.2\r\n\r\n\
       $(PFI_LANG_PERLREQ_IO_TEXT_6)\
       $(PFI_LANG_PERLREQ_IO_TEXT_7)"

  !insertmacro MUI_HEADER_TEXT "$(PFI_LANG_PERLREQ_TITLE)" " "

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

  DetailPrint "$(PFI_LANG_INST_LOG_SHUTDOWN) 9876"
  DetailPrint "$(PFI_LANG_TAKE_A_FEW_SECONDS)"

  MessageBox MB_OK|MB_ICONEXCLAMATION|MB_TOPMOST "$(PFI_LANG_MBMANSHUT_1)\
    $\r$\n$\r$\n\
    $(PFI_LANG_MBMANSHUT_2)\
    $\r$\n$\r$\n\
    $(PFI_LANG_MBMANSHUT_3)"

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: CheckExistingConfig
# (the "leave" function for the DIRECTORY selection page)
#--------------------------------------------------------------------------

Function CheckExistingConfig

  MessageBox MB_YESNO|MB_ICONQUESTION "$(PFI_LANG_DIRSELECT_MBWARN_1)\
      $\r$\n$\r$\n\
      $INSTDIR\
      $\r$\n$\r$\n$\r$\n\
      $(PFI_LANG_DIRSELECT_MBWARN_2)" IDYES continue
  Abort

continue:
FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: InstallUserData
# (the "pre" function for the 'Finish' page)
#--------------------------------------------------------------------------

Function InstallUserData

  Call GetParameters
  Pop $G_STARTUP
  StrCmp $G_STARTUP "/nouser" continue
  Exec '"$INSTDIR\transauw.exe" /install'
  Abort

continue:
FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: ShowReadMe
# (the "ReadMe" function for the 'Finish' page)
#--------------------------------------------------------------------------

Function ShowReadMe

  ExecShell "open" "$INSTDIR\${C_README}.txt"

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

  SetDetailsPrint listonly

  IfFileExists "$INSTDIR\PFI Testbed\uninst_transauw.exe" 0 root_uninstall
  HideWindow
  ExecWait '"$INSTDIR\PFI Testbed\uninst_transauw.exe" _?=$INSTDIR\PFI Testbed'
  BringToFront

root_uninstall:
  MessageBox MB_YESNO|MB_ICONSTOP|MB_DEFBUTTON2 \
      "$(PFI_LANG_UN_MBNOTFOUND_1) '$INSTDIR'.\
      $\r$\n$\r$\n\
      $(PFI_LANG_UN_MBNOTFOUND_2)" IDYES skip_confirmation
  Abort "$(PFI_LANG_UN_ABORT_1)"

skip_confirmation:
	ClearErrors
	UserInfo::GetName
	IfErrors 0 got_name

  ; Assume Win9x system, so user has 'Admin' rights
  ; (UserInfo works on Win98SE so perhaps pr*pit is only Win95 that fails ?)

  StrCpy $G_WINUSERNAME "UnknownUser"
  StrCpy $G_WINUSERTYPE "Admin"
  Goto continue

got_name:
	Pop $G_WINUSERNAME
  StrCmp $G_WINUSERNAME "" 0 get_usertype
  StrCpy $G_WINUSERNAME "UnknownUser"

get_usertype:
  UserInfo::GetAccountType
	Pop $G_WINUSERTYPE
  StrCmp $G_WINUSERTYPE "Admin" continue
  StrCmp $G_WINUSERTYPE "Power" continue
  StrCmp $G_WINUSERTYPE "User" continue
  StrCmp $G_WINUSERTYPE "Guest" continue
  StrCpy $G_WINUSERTYPE "Unknown"

continue:
  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROG_SHUTDOWN)"
  SetDetailsPrint listonly

  DetailPrint "$(PFI_LANG_UN_LOG_SHUTDOWN) 8080"

  Sleep ${C_UNINST_PROG_SHUTDOWN_DELAY}

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROG_SHORT)"
  SetDetailsPrint listonly

  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Add POPFile User Demo.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Corpus Conversion Demo.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Corpus Conversion Demo (failure).lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Uninstall PFI Add User Testbed.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Uninstall PFI Testbed.lnk"
  RMDir "$SMPROGRAMS\${C_PFI_PRODUCT}"

  Sleep ${C_UNINST_PROG_SHORT_DELAY}

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROG_CORE)"
  SetDetailsPrint listonly

  Sleep ${C_UNINST_PROG_CORE_DELAY}

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
  DetailPrint "$(PFI_LANG_UN_PROG_OUTEXPRESS)"
  SetDetailsPrint listonly

  ; Read the registry settings found in popfile.reg.dummy and restore them
  ; it there are any.   All are assumed to be in HKCU

  ClearErrors
  FileOpen ${L_CFG} $INSTDIR\popfile.reg.dummy r
  IfErrors skip_registry_restore
  Sleep ${C_UNINST_PROG_EMAIL_DELAY}

  DetailPrint "$(PFI_LANG_UN_LOG_OPENED): popfile.reg.dummy"

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

  DetailPrint "$(PFI_LANG_UN_LOG_RESTORED) ${L_REG_SUBKEY}: ${L_REG_VALUE}"
  goto restore_loop

skip_registry_restore:
  FileClose ${L_CFG}
  DetailPrint "$(PFI_LANG_UN_LOG_DELROOTDIR): popfile.reg.dummy"
  Delete $INSTDIR\popfile.reg.dummy

no_reg_file:
  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROG_SKINS)"
  SetDetailsPrint listonly

  Sleep ${C_UNINST_PROG_SKINS_DELAY}

  Delete $INSTDIR\languages\*.msg
  RMDir $INSTDIR\languages

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROG_PERL)"
  SetDetailsPrint listonly

  Sleep ${C_UNINST_PROG_PERL_DELAY}

  Delete "$INSTDIR\uninst_transauw.exe"
  Delete "$INSTDIR\uninst_testbed.exe"

  RMDir $INSTDIR

  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}"
  DeleteRegKey HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI"
  DeleteRegKey /ifempty HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}"
  DeleteRegKey /ifempty HKCU "SOFTWARE\POPFile Project"

  ; if $INSTDIR was removed, skip these next ones

  IfFileExists $INSTDIR 0 Removed
    MessageBox MB_YESNO|MB_ICONQUESTION "$(PFI_LANG_UN_MBREMDIR_1)" IDNO Removed
    DetailPrint "$(PFI_LANG_UN_LOG_DELUSERDIR)"
    Delete $INSTDIR\*.* ; this would be skipped if the user hits no
    RMDir /r $INSTDIR
    DetailPrint "$(PFI_LANG_UN_LOG_DELUSERERR)"
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
