#--------------------------------------------------------------------------
#
# transAUW.nsi --- This NSIS script is used to create a special version of the
#                  'Add POPFile User' wizard. This test program does not perform
#                  any POPFile configuration - it only displays the screens and
#                  messages of the real wizard (to help test the translations).
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
; (if the default multi-language wizard is compiled).
;
; NOTE: The language selection menu order used in this wizard assumes that the NSIS MUI
; 'Japanese.nsh' language file has been patched to use 'Nihongo' instead of 'Japanese'
; [see 'SMALL NSIS PATCH REQUIRED' in the 'pfi-languages.nsh' file]

; IMPORTANT:
; The Outlook and Outlook Express Configuration pages use the NOWORDWRAP flag and this requires
; InstallOptions 2.3 (or later). This means InstallOptions.dll dated 5 Dec 2003 or later
; (i.e. InstallOptions.dll v1.73 or later). If this script is compiled with an earlier version
; of the DLL, the account details will not be displayed correctly if any field exceeds the
; column width.

#--------------------------------------------------------------------------
# Optional run-time command-line switch (used by 'transauw.exe')
#--------------------------------------------------------------------------
#
# /install
#
# This command-line switch is used when this wizard is called by the main testbed program
# (pfi-testbed.exe) and makes the wizard skip the language selection dialog and WELCOME page.
#
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
# LANGUAGE SUPPORT:
#
# The wizard defaults to multi-language mode ('English' plus a number of other languages).
#
# If required, the command-line switch /DENGLISH_MODE can be used to build an English-only
# version.
#
# Normal multi-language build command:  makensis.exe transAUW.nsi
# To build an English-only version:     makensis.exe  /DENGLISH_MODE transAUW.nsi
#--------------------------------------------------------------------------
# The POPFile installer uses several multi-language mode programs built using NSIS. To make
# maintenance easier, an 'include' file (pfi-languages.nsh) defines the supported languages.
#
# To remove any of the additional languages, comment-out the relevant line in the list of
# languages in the 'pfi-languages.nsh' file.
#
# The 'pfi-languages.nsh' file explains how to add support for an additional language.
#--------------------------------------------------------------------------
# NOTE:
# This script file includes modified parts of the 'real thing' so some comments may refer to
# actions which are not applicable to this test program. For example, this test program
# does not shutdown an existing version of POPFile or install/startup a new version of POPFile.
#--------------------------------------------------------------------------

  ;--------------------------------------------------------------------------
  ; POPFile constants have been given names beginning with 'C_' (eg C_README)
  ;--------------------------------------------------------------------------

  !define C_PFI_PRODUCT      "PFI Testbed"
  !define C_PFI_VERSION      "0.1.1"

  !ifndef ENGLISH_MODE
    !define C_PFI_VERSION_ID "${C_PFI_VERSION} (ML)"
  !else
    !define C_PFI_VERSION_ID "${C_PFI_VERSION} (English)"
  !endif

  !define C_README           "translator.change"
  !define C_RELEASE_NOTES    "${C_README}"

  Name                       "POPFile User"

  ; Mention the wizard's version number in the titles of the installer & uninstaller windows

  Caption                    "Add POPFile User v${C_PFI_VERSION}"
  UninstallCaption           "Remove POPFile User v${C_PFI_VERSION}"

  ;----------------------------------------------------------------------
  ; Default location for POPFile User Data files (popfile.cfg and others)
  ;
  ; Detection of the 'current user' path for $APPDATA requires Internet Explorer 4 and above.
  ; Detection of the 'all users' path for $APPDATA requires Internet Explorer 5 and above.
  ;
  ; NOTE: Windows 95 systems with Internet Explorer 4 installed also need to have
  ;       Active Desktop installed, otherwise $APPDATA will not be available. For
  ;       these cases, an alternative constant is used to define the default location.
  ;----------------------------------------------------------------------

  !define C_STD_DEFAULT_USERDATA  "$APPDATA\PFI Testbed"
  !define C_ALT_DEFAULT_USERDATA  "$WINDIR\Application Data\PFI Testbed"

#--------------------------------------------------------------------------
# Delays (in milliseconds) used to simulate installation and uninstall activities
#--------------------------------------------------------------------------

  !define C_INST_PROG_UPGRADE_DELAY     2000
  !define C_INST_PROG_MBOX_DELAY        1000
  !define C_INST_PROG_SHORT_DELAY       2500
  !define C_INST_PROG_NONSQL_DELAY      2500

  !define C_INST_RUN_BANNER_DELAY       2500

  !define C_UNINST_PROG_SHUTDOWN_DELAY  2500
  !define C_UNINST_PROG_SHORT_DELAY     2500
  !define C_UNINST_PROG_EMAIL_DELAY     2500

#------------------------------------------------
# Define PFI_VERBOSE to get more compiler output
#------------------------------------------------

## !define PFI_VERBOSE

#--------------------------------------------------------------------------
# User Registers (Global)
#--------------------------------------------------------------------------

  ; This script uses 'User Variables' (with names starting with 'G_') to hold GLOBAL data.

  Var G_ROOTDIR            ; full path to the folder used for the POPFile program files
  Var G_USERDIR            ; used to pass popfile.cfg folder path to CBP package

  Var G_POP3               ; POP3 port (1-65535)
  Var G_GUI                ; GUI port (1-65535)
  Var G_STARTUP            ; startup flag (/install = called from pfi-testbed.exe)

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
# Use the "Modern User Interface"
#--------------------------------------------------------------------------

  !include "MUI.nsh"

#--------------------------------------------------------------------------
# Version Information settings (for the wizard's EXE and the uninstaller EXE)
#--------------------------------------------------------------------------

  ; 'VIProductVersion' format is X.X.X.X where X is a number in range 0 to 65535
  ; representing the following values: Major.Minor.Release.Build

  VIProductVersion                  "${C_PFI_VERSION}.0"

  VIAddVersionKey "ProductName"     "POPFile 'Add/Remove User' Language Testbed"
  VIAddVersionKey "Comments"        "POPFile Homepage: http://popfile.sf.net"
  VIAddVersionKey "CompanyName"     "The POPFile Project"
  VIAddVersionKey "LegalCopyright"  "© 2001-2004  John Graham-Cumming"
  VIAddVersionKey "FileDescription" "POPFile 'Add/Remove User' Testbed"
  VIAddVersionKey "FileVersion"     "${C_PFI_VERSION_ID}"

  VIAddVersionKey "Build Date/Time" "${__DATE__} @ ${__TIME__}"
  VIAddVersionKey "Build Script"    "${__FILE__}$\r$\n(${__TIMESTAMP__})"

  !ifndef ENGLISH_MODE
    VIAddVersionKey "Build Type"    "Multi-Language 'Add/Remove User' Translation Testbed"
  !else
    VIAddVersionKey "Build Type"    "English-Only 'Add/Remove User' Testbed"
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

  !include "..\CBP.nsh"

#--------------------------------------------------------------------------
# Include private library functions and macro definitions
#--------------------------------------------------------------------------

  ; Avoid compiler warnings by disabling the functions and definitions we do not use

  !define TRANSLATOR_AUW

  !include "..\pfi-library.nsh"

#--------------------------------------------------------------------------
# Configure the MUI pages
#--------------------------------------------------------------------------

  ;----------------------------------------------------------------
  ; Interface Settings - General Interface Settings
  ;----------------------------------------------------------------

  ; The icon files for the wizard and uninstaller must have the same structure. For example,
  ; if one icon file contains a 32x32 16-colour image and a 16x16 16-colour image then the other
  ; file cannot just contain a 32x32 16-colour image, it must also have a 16x16 16-colour image.
  ; The order of the images in each icon file must also be the same.

  !define MUI_ICON                            "..\POPFileIcon\popfile.ico"
  !define MUI_UNICON                          "..\remove.ico"

  ; The "Header" bitmap appears on all pages of the wizard (except Welcome & Finish pages)
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

  ; Show a message box with a warning when the user closes the wizard

  !define MUI_ABORTWARNING

  ;----------------------------------------------------------------
  ; Customize MUI - General Custom Function
  ;----------------------------------------------------------------

  ; Use a custom '.onGUIInit' function to add language-specific texts to custom page INI files

  !define MUI_CUSTOMFUNCTION_GUIINIT          "PFIGUIInit"

  ;----------------------------------------------------------------
  ; Language Settings for MUI pages
  ;----------------------------------------------------------------

  ; Same "Language selection" dialog is used for the wizard and the uninstaller
  ; so we override the standard "Installer Language" title to avoid confusion.

  !define MUI_LANGDLL_WINDOWTITLE             "Language Selection"

  ; Always show the language selection dialog, even if a language has been stored in the
  ; registry (the language stored in the registry will be selected as the default language)

  !define MUI_LANGDLL_ALWAYSSHOW

  ; Remember user's language selection and offer this as the default when re-running wizard
  ; (uninstaller also uses this setting to determine which language is to be used)

  !define MUI_LANGDLL_REGISTRY_ROOT           "HKCU"
  !define MUI_LANGDLL_REGISTRY_KEY            "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI"
  !define MUI_LANGDLL_REGISTRY_VALUENAME      "Installer Language"

#--------------------------------------------------------------------------
# Define the Page order for the wizard (and the uninstaller)
#--------------------------------------------------------------------------

  ;---------------------------------------------------
  ; Installer Page - Welcome
  ;---------------------------------------------------

  ; Use a "pre" function to decide whether or not to show the WELCOME page
  ; (if called from main testbed (pfi-testbed.exe) there is no need for another WELCOME page)

  !define MUI_PAGE_CUSTOMFUNCTION_PRE         "CheckStartMode"

  !define MUI_WELCOMEPAGE_TEXT                "$(PFI_LANG_ADDUSER_INFO_TEXT)"

  ; Use a "leave" function to decide upon a suitable initial value for the user data folder
  ; (this initial value is used for the DIRECTORY page used to select 'User Data' location).

  !define MUI_PAGE_CUSTOMFUNCTION_LEAVE       "ChooseDefaultDataDir"

  !insertmacro MUI_PAGE_WELCOME

  ;---------------------------------------------------
  ; Installer Page - Select user data Directory
  ;---------------------------------------------------

  ; Use a "leave" function to look for an existing 'popfile.cfg' and use it to determine some
  ; initial settings for this installation.

  !define MUI_PAGE_CUSTOMFUNCTION_LEAVE       "CheckExistingDataDir"

  ; This page is used to select the folder for the POPFile USER DATA files

  !define MUI_DIRECTORYPAGE_VARIABLE          $G_USERDIR

  !define MUI_PAGE_HEADER_TEXT                "$(PFI_LANG_USERDIR_TITLE)"
  !define MUI_PAGE_HEADER_SUBTEXT             "$(PFI_LANG_USERDIR_SUBTITLE)"
  !define MUI_DIRECTORYPAGE_TEXT_TOP          "$(PFI_LANG_USERDIR_TEXT_TOP)"
  !define MUI_DIRECTORYPAGE_TEXT_DESTINATION  "$(PFI_LANG_USERDIR_TEXT_DESTN)"

  !insertmacro MUI_PAGE_DIRECTORY

  ;---------------------------------------------------
  ; Installer Page - POP3 and UI Port Options
  ;---------------------------------------------------

  Page custom SetOptionsPage "CheckPortOptions"

  ;---------------------------------------------------
  ; Installer Page - Install files
  ;---------------------------------------------------

  !define MUI_PAGE_HEADER_TEXT                "$(PFI_LANG_ADDUSER_TITLE)"
  !define MUI_PAGE_HEADER_SUBTEXT             "$(PFI_LANG_ADDUSER_SUBTITLE)"

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

  Page custom SetOutlookExpressPage           "CheckOutlookExpressRequests"

  ;---------------------------------------------------
  ; Installer Page - Configure Outlook accounts
  ;---------------------------------------------------

  Page custom SetOutlookPage                  "CheckOutlookRequests"

  ;---------------------------------------------------
  ; Installer Page - Configure Eudora personalities
  ;---------------------------------------------------

  Page custom SetEudoraPage                   "CheckEudoraRequests"

  ;---------------------------------------------------
  ; Installer Page - Choose POPFile launch mode
  ;---------------------------------------------------

  Page custom StartPOPFilePage                "CheckLaunchOptions"

  ;---------------------------------------------------
  ; Installer Page - Finish (may offer to start UI)
  ;---------------------------------------------------

  !define MUI_FINISHPAGE_TEXT                 "$(PFI_LANG_ADDUSER_FINISH_INFO)"

  ; Use a "pre" function for the 'Finish' page to ensure wizard only offers to display
  ; POPFile User Interface if user has chosen to start POPFile from the wizard.

  !define MUI_PAGE_CUSTOMFUNCTION_PRE         "CheckRunStatus"

  ; Offer to display the POPFile User Interface (The 'CheckRunStatus' function ensures this
  ; option is only offered if the wizard has started POPFile running)

  !define MUI_FINISHPAGE_RUN
  !define MUI_FINISHPAGE_RUN_TEXT             "$(PFI_LANG_FINISH_RUN_TEXT)"
  !define MUI_FINISHPAGE_RUN_FUNCTION         "RunUI"

  ; Provide a checkbox to let user display the Release Notes for this version of POPFile

  !define MUI_FINISHPAGE_SHOWREADME
  !define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
  !define MUI_FINISHPAGE_SHOWREADME_FUNCTION  "ShowReadMe"

  !insertmacro MUI_PAGE_FINISH

  ;---------------------------------------------------
  ; Uninstaller Page - Confirmation Page
  ;---------------------------------------------------

  !define MUI_PAGE_HEADER_TEXT                "$(PFI_LANG_REMUSER_TITLE)"
  !define MUI_PAGE_HEADER_SUBTEXT             "$(PFI_LANG_REMUSER_SUBTITLE)"
  !define MUI_UNCONFIRMPAGE_TEXT_TOP          "$(PFI_LANG_REMUSER_TEXT_TOP)"

  !insertmacro MUI_UNPAGE_CONFIRM

  ;---------------------------------------------------
  ; Uninstaller Page - Uninstall POPFile User Data
  ;---------------------------------------------------

  !define MUI_PAGE_HEADER_TEXT                "$(PFI_LANG_REMOVING_TITLE)"
  !define MUI_PAGE_HEADER_SUBTEXT             "$(PFI_LANG_REMOVING_SUBTITLE)"

  !insertmacro MUI_UNPAGE_INSTFILES

#--------------------------------------------------------------------------
# Language Support for the 'Add POPFile User' wizard
#--------------------------------------------------------------------------

  ;-----------------------------------------
  ; Select the languages to be supported by the wizard and its uninstaller.
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

  ; Specify NSIS output filename for the wizard

  OutFile "transauw.exe"

  ; Ensure CRC checking cannot be turned off using the /NCRC command-line switch

  CRCcheck Force

#--------------------------------------------------------------------------
# Default Destination Folder
#--------------------------------------------------------------------------

  InstallDir "$PROGRAMFILES\${C_PFI_PRODUCT}"
  InstallDirRegKey HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "UserDataPath"

#--------------------------------------------------------------------------
# Reserve the files required by the wizard (to improve performance)
#--------------------------------------------------------------------------

  ; Things that need to be extracted on startup (keep these lines before any File command!)
  ; Only useful when solid compression is used (by default, solid compression is enabled
  ; for BZIP2 and LZMA compression)

  !insertmacro MUI_RESERVEFILE_LANGDLL
  !insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
  ReserveFile "..\ioA.ini"
  ReserveFile "..\ioB.ini"
  ReserveFile "..\ioC.ini"
  ReserveFile "..\ioE.ini"
  ReserveFile "..\ioF.ini"

#--------------------------------------------------------------------------
# Installer Function: .onInit - wizard normally starts by offering a choice of languages
#--------------------------------------------------------------------------

Function .onInit

  ; The main testbed (pfi-testbed.exe) simulates the installation of the POPFile Program files
  ; and then calls this wizard to simulate the creation/updating of the POPFile User Data for
  ; the current user. The command-line switch '/install' is used to suppress this wizard's
  ; language selection dialog and WELCOME page when it is called from pfi-testbed.exe.

  Call GetParameters
  Pop $G_STARTUP
  StrCmp $G_STARTUP "/install" 0 normal_startup
  ReadRegStr $LANGUAGE \
             "HKCU" "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "Installer Language"
  Goto extract_files

normal_startup:

  ; Conditional compilation: if ENGLISH_MODE is defined, support only 'English'

  !ifndef ENGLISH_MODE
        !insertmacro MUI_LANGDLL_DISPLAY
  !endif

extract_files:
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT_AS "..\ioA.ini" "ioA.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT_AS "..\ioB.ini" "ioB.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT_AS "..\ioC.ini" "ioC.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT_AS "..\ioE.ini" "ioE.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT_AS "..\ioF.ini" "ioF.ini"

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
  StrCmp $G_WINUSERTYPE "Power" exit
  StrCmp $G_WINUSERTYPE "User" exit
  StrCmp $G_WINUSERTYPE "Guest" exit
  StrCpy $G_WINUSERTYPE "Unknown"

exit:
FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: PFIGUIInit
# (custom .onGUIInit function)
#
# Used to complete the initialization of the wizard.
# (this code was moved from '.onInit' in order to permit the custom pages
# to be set up to use the language selected by the user)
#--------------------------------------------------------------------------

Function PFIGUIInit

  ; If launched from the main testbed, suppress the compatibility message

  StrCmp $G_STARTUP "/install" continue

  MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_COMPAT_NOTFOUND)"
  IfFileExists "$EXEDIR\uninst_testbed.exe" continue
  Abort

continue:
  StrCpy $G_ROOTDIR "$EXEDIR"

  ; Insert appropriate language strings into the custom page INI files
  ; (the CBP package creates its own INI file so there is no need for a CBP *Page_Init function)

  Call SetOptionsPage_Init
  Call SetEmailClientPage_Init
  Call SetOutlookOutlookExpressPage_Init
  Call SetEudoraPage_Init
  Call StartPOPFilePage_Init

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

  WriteRegStr HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "UserDataPath" "$G_USERDIR"

  MessageBox MB_YESNO|MB_ICONQUESTION \
      "POPFile 'stopwords' $(PFI_LANG_MBSTPWDS_1)\
      $\r$\n$\r$\n\
      $(PFI_LANG_MBSTPWDS_2)\
      $\r$\n$\r$\n\
      $(PFI_LANG_MBSTPWDS_3) 'stopwords.bak')\
      $\r$\n$\r$\n\
      $(PFI_LANG_MBSTPWDS_4) 'stopwords.default')"

  Sleep ${C_INST_PROG_MBOX_DELAY}

  ; Create the uninstall program BEFORE creating the shortcut to it
  ; (this ensures that the correct "uninstall" icon appears in the START MENU shortcut)

  SetOutPath $G_USERDIR
  Delete $G_USERDIR\uninst_transauw.exe
  WriteUninstaller $G_USERDIR\uninst_transauw.exe

  ; Create the START MENU entries

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_SHORT)"
  SetDetailsPrint listonly

  ; 'CreateShortCut' uses '$OUTDIR' as the working directory for the shortcut
  ; ('SetOutPath' is one way to change the value of $OUTDIR)

  SetOutPath "$SMPROGRAMS\${C_PFI_PRODUCT}\Add User Demo"
  SetOutPath $G_USERDIR
  CreateShortCut \
      "$SMPROGRAMS\${C_PFI_PRODUCT}\Add User Demo\Uninstall Testbed Data ($G_WINUSERNAME).lnk" \
      "$G_USERDIR\uninst_transauw.exe"

  Sleep ${C_INST_PROG_SHORT_DELAY}

  ; Create entry in the Control Panel's "Add/Remove Programs" list

  WriteRegStr HKCU \
              "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}_AUW" \
              "DisplayName" "${C_PFI_PRODUCT} ${C_PFI_VERSION}"
  WriteRegStr HKCU \
              "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}_AUW" \
              "UninstallString" "$G_USERDIR\uninst_transauw.exe"
  WriteRegDWORD HKCU \
                "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}_AUW" \
                "NoModify" "1"
  WriteRegDWORD HKCU \
                "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}_AUW" \
                "NoRepair" "1"

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_ENDSEC)"
  SetDetailsPrint listonly

  Pop ${L_CFG}

  !undef L_CFG

SectionEnd

#--------------------------------------------------------------------------
# Installer Section: Flat File Corpus Backup component (always 'installed')
#--------------------------------------------------------------------------

Section "-NonSQLCorpusBackup" SecBackup

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_CORPUS)"
  SetDetailsPrint listonly

  Sleep ${C_INST_PROG_NONSQL_DELAY}

  DetailPrint "Error detected when making corpus backup"
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(PFI_LANG_MBCORPUS_1)"

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_ENDSEC)"
  SetDetailsPrint listonly

SectionEnd

#--------------------------------------------------------------------------
# Installer Function: CheckStartMode
# The "pre" function for the WELCOME page.
#
# If called from the main installer, no need to display another WELCOME page
#--------------------------------------------------------------------------

Function CheckStartMode

  ; The main testbed (pfi-testbed.exe) simulates the installation of the POPFile Program files
  ; and then calls this wizard to simulate the creation/updating of the POPFile User Data for
  ; the current user. The command-line switch '/install' is used to suppress this wizard's
  ; WELCOME page and language selection dialog when it is called from pfi-testbed.exe.

  StrCmp $G_STARTUP "/install" 0 show_WELCOME_page

  ; Need to call the WELCOME page's "leave" function (to initialise $G_USERDIR)

  Call ChooseDefaultDataDir
  Abort

show_WELCOME_page:
FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: MakeItSafe
#
# If we are installing on top of a previous installation, we try to shut it down
# (to allow the files to be overwritten without requiring a reboot)
#--------------------------------------------------------------------------

Function MakeItSafe

  Banner::show /NOUNLOAD /set 76 "$(PFI_LANG_BE_PATIENT)" "$(PFI_LANG_TAKE_A_FEW_SECONDS)"
  Sleep ${C_INST_RUN_BANNER_DELAY}
  Banner::destroy
  Sleep ${C_INST_RUN_BANNER_DELAY}

  DetailPrint "$(PFI_LANG_INST_LOG_SHUTDOWN) 9876"
  DetailPrint "$(PFI_LANG_TAKE_A_FEW_SECONDS)"

  MessageBox MB_OK|MB_ICONEXCLAMATION|MB_TOPMOST "$(PFI_LANG_MBMANSHUT_1)\
    $\r$\n$\r$\n\
    $(PFI_LANG_MBMANSHUT_2)\
    $\r$\n$\r$\n\
    $(PFI_LANG_MBMANSHUT_3)"

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: ChooseDefaultDataDir
# (the "leave" function for the WELCOME page)
#
# This function is used to choose a suitable initial value for the DIRECTORY page which allows
# the user to choose where their POPFile Configuration data is to be stored.
#--------------------------------------------------------------------------

Function ChooseDefaultDataDir

  !define  L_RESULT    $R9

  ; This function initialises the $G_USERDIR global user variable for use by the DIRECTORY page

  ; Starting with the 0.21.0 release, user-specific data is stored in the registry

  ReadRegStr $G_USERDIR HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "UserDataPath"
  StrCmp $G_USERDIR "" use_default_locn
  Goto exit

use_default_locn:

  ;----------------------------------------------------------------------
  ; Default location for POPFile User Data files (popfile.cfg and others)
  ;
  ; Windows 95 systems with Internet Explorer 4 installed also need to have
  ; Active Desktop installed, otherwise $APPDATA will not be available.
  ;----------------------------------------------------------------------

  StrCmp $APPDATA "" 0 appdata_valid
  StrCpy $G_USERDIR "${C_ALT_DEFAULT_USERDATA}\$G_WINUSERNAME"
  Goto exit

appdata_valid:
  Push ${L_RESULT}

  StrCpy $G_USERDIR "${C_STD_DEFAULT_USERDATA}"
  Push $G_USERDIR
  Push $G_WINUSERNAME
  Call StrStr
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "" 0 default_locn_ok
  StrCpy $G_USERDIR "$G_USERDIR\$G_WINUSERNAME"

default_locn_ok:
  Pop ${L_RESULT}

exit:

  !undef L_RESULT

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: CheckExistingDataDir
# (the "leave" function for the DIRECTORY page)
#--------------------------------------------------------------------------

Function CheckExistingDataDir

  MessageBox MB_YESNO|MB_ICONQUESTION "$(PFI_LANG_DIRSELECT_MBWARN_3)\
      $\r$\n$\r$\n\
      $G_USERDIR\
      $\r$\n$\r$\n$\r$\n\
      $(PFI_LANG_DIRSELECT_MBWARN_2)" IDYES continue

continue:
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

  ; For the PFI Testbed the 'User Data' folder is always a sub-folder of the folder
  ; containing the test program (i.e. we ignore the value selected via the DIRECTORY page).

  StrCpy $G_USERDIR "$EXEDIR\PFI Testbed"
  StrCpy $G_POP3 "110"
  StrCpy $G_GUI "8080"

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
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioF.ini" \
              "Settings" "BackButtonText" "$(PFI_LANG_MAILCFG_IO_SKIPALL)"

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
  !define L_CLIENT_TYPE     $R6   ; used to indicate if client can be reconfigured by wizard
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

  !insertmacro MUI_INSTALLOPTIONS_DISPLAY_RETURN "ioF.ini"
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "back" 0 exit
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioF.ini" "ClientEXE" "ConfigStatus" "SkipAll"

  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioF.ini" "Settings" "NumFields" "1"
  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioF.ini" "Settings" "BackEnabled" "0"
  !insertmacro PFI_IO_TEXT "ioF.ini" "1" "$(PFI_LANG_MAILCFG_IO_CANCEL)"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioF.ini"

exit:
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
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioB.ini" \
              "Settings" "BackButtonText" "$(PFI_LANG_MAILCFG_IO_SKIPONE)"

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

  MessageBox MB_ABORTRETRYIGNORE|MB_ICONSTOP|MB_DEFBUTTON2 "$(PFI_LANG_MBCLIENT_EXP)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_1)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_2)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_3)"\
             IDRETRY open_logfiles IDIGNORE open_logfiles

abort_oe_config:

  ; Either 'Abort' has been selected so we do not offer to reconfigure any Outlook Express
  ; accounts or 'Cancel' has been selected during the Outlook Express configuration process
  ; so we stop now

  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioB.ini" "Settings" "NumFields" "1"
  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioB.ini" "Settings" "BackEnabled" "0"
  !insertmacro PFI_IO_TEXT "ioB.ini" "1" "$(PFI_LANG_EXPCFG_IO_CANCELLED)"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioB.ini"
  StrCmp $G_OOECONFIG_HANDLE "" exit
  FileWrite $G_OOECONFIG_HANDLE "$\r$\n$(PFI_LANG_EXPCFG_IO_CANCELLED)$\r$\n"
  Goto finished_oe_config

open_logfiles:
  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioB.ini" "Settings" "BackEnabled" "1"

  Call GetDateTimeStamp
  Pop ${L_TEMP}

  FileOpen  $G_OOECONFIG_HANDLE "$G_USERDIR\expconfig.txt" w
  FileWrite $G_OOECONFIG_HANDLE "$(PFI_LANG_EXPCFG_LOG_BEFORE) (${L_TEMP})$\r$\n$\r$\n"
  !insertmacro OOECONFIG_BEFORE_LOG  "$(PFI_LANG_EXPCFG_LOG_IDENTITY)"  20
  !insertmacro OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OOECFG_LOG_ACCOUNT)"   20
  !insertmacro OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OOECFG_LOG_EMAIL)"     30
  !insertmacro OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OOECFG_LOG_SERVER)"    20
  !insertmacro OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OOECFG_LOG_USER)"      20
  FileWrite $G_OOECONFIG_HANDLE "$(PFI_LANG_OOECFG_LOG_PORT)$\r$\n$\r$\n"

  FileOpen  $G_OOECHANGES_HANDLE "$G_USERDIR\expchanges.txt" a
  FileSeek  $G_OOECHANGES_HANDLE 0 END
  FileWrite $G_OOECHANGES_HANDLE "$(PFI_LANG_EXPCFG_LOG_AFTER) (${L_TEMP})$\r$\n$\r$\n"
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
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Field 1" "Text" "'${L_IDENTITY}' $(PFI_LANG_OOECFG_IO_BOXHDR)"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Identity" "Username" "${L_IDENTITY}"

  ReadRegStr ${L_OEDATA} HKCU ${L_ACCOUNT} "Account Name"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 8" "State"
  StrCpy ${L_TEMP} ""
  StrCmp ${L_STATUS} "" no_padding
  StrCpy ${L_TEMP} "\r\n\r\n"

no_padding:
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Field 8" "State" "${L_STATUS}${L_TEMP}${L_OEDATA}"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 9" "State"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Field 9" "State" "${L_STATUS}${L_TEMP}${L_EMAILADDRESS}"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 10" "State"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Field 10" "State" "${L_STATUS}${L_TEMP}${L_POP3SERVER}"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 11" "State"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Field 11" "State" "${L_STATUS}${L_TEMP}${L_USERNAME}"

  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Account $G_OOELIST_INDEX" "AccountName" "${L_OEDATA}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Account $G_OOELIST_INDEX" "EmailAddress" "${L_EMAILADDRESS}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Account $G_OOELIST_INDEX" "POP3server" "${L_POP3SERVER}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Account $G_OOELIST_INDEX" "POP3username" "${L_USERNAME}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Account $G_OOELIST_INDEX" "POP3port" "${L_PORT}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Account $G_OOELIST_INDEX" "RegistryKey" "${L_ACCOUNT}"

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

  StrCmp ${L_TEMP} "back" abort_oe_config
  StrCmp ${L_TEMP} "cancel" finished_this_guid

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

  StrCmp ${L_TEMP} "back" abort_oe_config
  StrCmp ${L_TEMP} "cancel" finished_this_guid

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

  !insertmacro MUI_INSTALLOPTIONS_READ \
               ${L_ACCOUNTNAME}  "ioB.ini" "Account ${L_DATA_INDEX}" "AccountName"
  !insertmacro MUI_INSTALLOPTIONS_READ \
               ${L_EMAILADDRESS} "ioB.ini" "Account ${L_DATA_INDEX}" "EMailAddress"
  !insertmacro MUI_INSTALLOPTIONS_READ \
               ${L_POP3SERVER}   "ioB.ini" "Account ${L_DATA_INDEX}" "POP3server"
  !insertmacro MUI_INSTALLOPTIONS_READ \
               ${L_POP3USERNAME} "ioB.ini" "Account ${L_DATA_INDEX}" "POP3username"
  !insertmacro MUI_INSTALLOPTIONS_READ \
               ${L_POP3PORT}     "ioB.ini" "Account ${L_DATA_INDEX}" "POP3port"
  !insertmacro MUI_INSTALLOPTIONS_READ \
               ${L_REGKEY}       "ioB.ini" "Account ${L_DATA_INDEX}" "RegistryKey"

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

  ; The testbed does NOT change any Outlook Express settings

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

  MessageBox MB_ABORTRETRYIGNORE|MB_ICONSTOP|MB_DEFBUTTON2 "$(PFI_LANG_MBCLIENT_OUT)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_1)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_2)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_3)"\
             IDRETRY examine_registry IDIGNORE examine_registry

abort_outlook_config:

  ; Either 'Abort' has been selected so we do not offer to reconfigure any Outlook accounts
  ; or 'Cancel' has been selected during the Outlook configuration process so we stop now

  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioB.ini" "Settings" "NumFields" "1"
  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioB.ini" "Settings" "BackEnabled" "0"
  !insertmacro PFI_IO_TEXT "ioB.ini" "1" "$(PFI_LANG_OUTCFG_IO_CANCELLED)"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioB.ini"
  StrCmp $G_OOECONFIG_HANDLE "" exit
  FileWrite $G_OOECONFIG_HANDLE "$\r$\n$(PFI_LANG_OUTCFG_IO_CANCELLED)$\r$\n"
  Goto finished_outlook_config

examine_registry:
  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioB.ini" "Settings" "BackEnabled" "1"

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
  EnumRegKey ${L_OUTLOOK} \
             HKCU "Software\Microsoft\Office\Outlook\OMI Account Manager\Accounts" 0
  StrCmp ${L_OUTLOOK} "" try_outlook_98
  StrCpy ${L_OUTLOOK} "Software\Microsoft\Office\Outlook\OMI Account Manager\Accounts"
  Goto got_outlook_path

try_outlook_98:
  EnumRegKey ${L_OUTLOOK} \
             HKCU "Software\Microsoft\Office\8.0\Outlook\OMI Account Manager\Accounts" 0
  StrCmp ${L_OUTLOOK} "" try_outlook_97
  StrCpy ${L_OUTLOOK} "Software\Microsoft\Office\8.0\Outlook\OMI Account Manager\Accounts"
  Goto got_outlook_path

try_outlook_97:
  EnumRegKey ${L_OUTLOOK} \
             HKCU "Software\Microsoft\Office\7.0\Outlook\OMI Account Manager\Accounts" 0
  StrCmp ${L_OUTLOOK} "" use_dummy
  StrCpy ${L_OUTLOOK} "Software\Microsoft\Office\7.0\Outlook\OMI Account Manager\Accounts"
  Goto got_outlook_path

use_dummy:
  StrCpy ${L_OUTLOOK} "dummy"

got_outlook_path:
  Call GetDateTimeStamp
  Pop ${L_TEMP}

  FileOpen  $G_OOECONFIG_HANDLE "$G_USERDIR\outconfig.txt" w
  FileWrite $G_OOECONFIG_HANDLE "$(PFI_LANG_OUTCFG_LOG_BEFORE) (${L_TEMP})$\r$\n$\r$\n"
  !insertmacro OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OUTCFG_LOG_IDENTITY)"  20
  !insertmacro OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OOECFG_LOG_ACCOUNT)"   20
  !insertmacro OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OOECFG_LOG_EMAIL)"     30
  !insertmacro OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OOECFG_LOG_SERVER)"    20
  !insertmacro OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OOECFG_LOG_USER)"      20
  FileWrite $G_OOECONFIG_HANDLE "$(PFI_LANG_OOECFG_LOG_PORT)$\r$\n$\r$\n"

  FileOpen  $G_OOECHANGES_HANDLE "$G_USERDIR\outchanges.txt" a
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

  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Field 1" "Text" "'$G_WINUSERNAME' $(PFI_LANG_OOECFG_IO_BOXHDR)"
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Identity" "Username" "$G_WINUSERNAME"

  ReadRegStr ${L_OUTDATA} HKCU ${L_ACCOUNT} "Account Name"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 8" "State"
  StrCpy ${L_TEMP} ""
  StrCmp ${L_STATUS} "" no_padding
  StrCpy ${L_TEMP} "\r\n\r\n"

no_padding:
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Field 8" "State" "${L_STATUS}${L_TEMP}${L_OUTDATA}"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 9" "State"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Field 9" "State" "${L_STATUS}${L_TEMP}${L_EMAILADDRESS}"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 10" "State"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Field 10" "State" "${L_STATUS}${L_TEMP}${L_POP3SERVER}"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 11" "State"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Field 11" "State" "${L_STATUS}${L_TEMP}${L_USERNAME}"

  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Account $G_OOELIST_INDEX" "AccountName"  "${L_OUTDATA}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Account $G_OOELIST_INDEX" "EmailAddress" "${L_EMAILADDRESS}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Account $G_OOELIST_INDEX" "POP3server"   "${L_POP3SERVER}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Account $G_OOELIST_INDEX" "POP3username" "${L_USERNAME}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Account $G_OOELIST_INDEX" "POP3port"     "${L_PORT}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Account $G_OOELIST_INDEX" "RegistryKey"  "${L_ACCOUNT}"

  !insertmacro OOECONFIG_BEFORE_LOG  "$G_WINUSERNAME"    20
  !insertmacro OOECONFIG_BEFORE_LOG  "${L_OUTDATA}"      20
  !insertmacro OOECONFIG_BEFORE_LOG  "${L_EMAILADDRESS}" 30
  !insertmacro OOECONFIG_BEFORE_LOG  "${L_POP3SERVER}"   20
  !insertmacro OOECONFIG_BEFORE_LOG  "${L_USERNAME}"     20
  FileWrite $G_OOECONFIG_HANDLE "${L_PORT}$\r$\n"

  IntCmp $G_OOELIST_INDEX 6 display_list try_next_account try_next_account

use_dummy_data:
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Field 1" "Text" "'$G_WINUSERNAME' $(PFI_LANG_OOECFG_IO_BOXHDR)"
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Identity" "Username" "$G_WINUSERNAME"

  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Field 8" "State" "Sample Account\r\n\r\nAnother One"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 9" "State"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Field 9" "State" "a.sample@.someisp.com\r\n\r\nexample@somewhere.net"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 10" "State"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Field 10" "State" "mail.someisp.com\r\n\r\npop3.mailserver.net"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 11" "State"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Field 11" "State" "sample\r\n\r\nan.example"

  IntOp $G_OOELIST_INDEX $G_OOELIST_INDEX + 1
  IntOp $G_OOELIST_CBOX $G_OOELIST_CBOX + 1
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Field $G_OOELIST_CBOX" "Flags" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Account $G_OOELIST_INDEX" "AccountName" "Sample Account"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Account $G_OOELIST_INDEX" "EmailAddress" "a.sample@.someisp.com"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Account $G_OOELIST_INDEX" "POP3server" "mail.someisp.com"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Account $G_OOELIST_INDEX" "POP3username" "sample"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Account $G_OOELIST_INDEX" "POP3port" "110"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Account $G_OOELIST_INDEX" "RegistryKey" "unknown"

  IntOp $G_OOELIST_INDEX $G_OOELIST_INDEX + 1
  IntOp $G_OOELIST_CBOX $G_OOELIST_CBOX + 1
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Field $G_OOELIST_CBOX" "Flags" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Account $G_OOELIST_INDEX" "AccountName" "Another One"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Account $G_OOELIST_INDEX" "EmailAddress" "example@somewhere.net"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Account $G_OOELIST_INDEX" "POP3server" "pop3.mailserver.net"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Account $G_OOELIST_INDEX" "POP3username" "an.example"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Account $G_OOELIST_INDEX" "POP3port" "110"
  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Account $G_OOELIST_INDEX" "RegistryKey" "unknown"

  !insertmacro MUI_INSTALLOPTIONS_WRITE \
               "ioB.ini" "Settings" "NumFields" "$G_OOELIST_CBOX"

display_list:

  ; Display the Outlook account data with checkboxes enabled for those accounts we can configure

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Identity" "PageStatus" "new"

  !insertmacro MUI_INSTALLOPTIONS_INITDIALOG "ioB.ini"
  Pop $G_HWND                 ; HWND of dialog we want to modify

  ; In 'GetDlgItem', use (1200 + Field number - 1) to refer to the field to be changed

  GetDlgItem $G_DLGITEM $G_HWND 1200            ; Field 1 = 'Outlook User' label (above the box)
  CreateFont $G_FONT "MS Shell Dlg" 8 700       ; use a 'bolder' version of the font in use
  SendMessage $G_DLGITEM ${WM_SETFONT} $G_FONT 0

  !insertmacro MUI_INSTALLOPTIONS_SHOW_RETURN
  Pop ${L_TEMP}

  StrCmp ${L_TEMP} "back" abort_outlook_config
  StrCmp ${L_TEMP} "cancel" finished_outlook_config

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

  GetDlgItem $G_DLGITEM $G_HWND 1200            ; Field 1 = 'Outlook User' label (above the box)
  CreateFont $G_FONT "MS Shell Dlg" 8 700       ; use a 'bolder' version of the font in use
  SendMessage $G_DLGITEM ${WM_SETFONT} $G_FONT 0

  !insertmacro MUI_INSTALLOPTIONS_SHOW_RETURN
  Pop ${L_TEMP}

  StrCmp ${L_TEMP} "back" abort_outlook_config
  StrCmp ${L_TEMP} "cancel" finished_outlook_config

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

  !insertmacro MUI_INSTALLOPTIONS_READ \
               ${L_ACCOUNTNAME}  "ioB.ini" "Account ${L_DATA_INDEX}" "AccountName"
  !insertmacro MUI_INSTALLOPTIONS_READ \
               ${L_EMAILADDRESS} "ioB.ini" "Account ${L_DATA_INDEX}" "EMailAddress"
  !insertmacro MUI_INSTALLOPTIONS_READ \
               ${L_POP3SERVER}   "ioB.ini" "Account ${L_DATA_INDEX}" "POP3server"
  !insertmacro MUI_INSTALLOPTIONS_READ \
               ${L_POP3USERNAME} "ioB.ini" "Account ${L_DATA_INDEX}" "POP3username"
  !insertmacro MUI_INSTALLOPTIONS_READ \
               ${L_POP3PORT}     "ioB.ini" "Account ${L_DATA_INDEX}" "POP3port"
  !insertmacro MUI_INSTALLOPTIONS_READ \
               ${L_REGKEY}       "ioB.ini" "Account ${L_DATA_INDEX}" "RegistryKey"

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
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" \
              "Settings" "BackButtonText" "$(PFI_LANG_MAILCFG_IO_SKIPONE)"

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

  MessageBox MB_ABORTRETRYIGNORE|MB_ICONSTOP|MB_DEFBUTTON2 "$(PFI_LANG_MBCLIENT_EUD)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_1)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_2)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_3)"\
             IDRETRY continue IDIGNORE continue

abort_eudora_config:

  ; Either 'Abort' has been selected so we do not offer to reconfigure any Eudora accounts
  ; or 'Cancel' has been selected during the Eudora configuration process so we stop now

  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioE.ini" "Settings" "NumFields" "1"
  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioE.ini" "Settings" "BackEnabled" "0"
  !insertmacro PFI_IO_TEXT "ioE.ini" "1" "$(PFI_LANG_EUCFG_IO_CANCELLED)"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioE.ini"
  Goto exit

continue:
  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioE.ini" "Settings" "BackEnabled" "1"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioE.ini" "Field 2" "Text"
  StrCpy ${L_STATUS} "${L_STATUS} ($(PFI_LANG_EUCFG_IO_POP3PORT) $G_POP3)"
  !insertmacro PFI_IO_TEXT "ioE.ini" "2" "${L_STATUS}"

  ; The <Dominant> personality data is stored separately from that of the other personalities

  !insertmacro PFI_IO_TEXT "ioE.ini" "4" "$(PFI_LANG_EUCFG_IO_DOMINANT)"
  StrCpy ${L_PERSONA} "Settings"
  StrCpy ${L_INDEX} -1
  Goto common_to_all

get_next_persona:
  IntOp ${L_INDEX} ${L_INDEX} + 1
  ReadINIStr ${L_PERSONA}  "${L_ININAME}" "Personalities" "Persona${L_INDEX}"
  StrCmp ${L_PERSONA} "" exit
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

  !insertmacro MUI_INSTALLOPTIONS_SHOW_RETURN
  Pop ${L_STATUS}
  StrCmp ${L_STATUS} "back" abort_eudora_config
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
# Installer Function: CheckEudoraRequests
#
# This function is used to confirm any Eudora personality reconfiguration requests
#--------------------------------------------------------------------------

Function CheckEudoraRequests

  !define L_EMAIL     $R9
  !define L_PERSONA   $R8
  !define L_PORT      $R7
  !define L_SERVER    $R6
  !define L_USER      $R5

  Push ${L_EMAIL}
  Push ${L_PERSONA}
  Push ${L_PORT}
  Push ${L_SERVER}
  Push ${L_USER}

  ; If user has cancelled Eudora reconfiguration, there is nothing to do

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_EMAIL} "ioE.ini" "Settings" "NumFields"
  StrCmp ${L_EMAIL} "1" exit

  ; If user has not requested reconfiguration of this account, there is nothing to do

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_PERSONA} "ioE.ini" "Field 2" "State"
  StrCmp ${L_PERSONA} "0" exit

  ; User has ticked the 'Reconfigure' box so show the changes we are about to make

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_PERSONA} "ioE.ini" "Field 4" "Text"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_EMAIL}   "ioE.ini" "Field 9" "Text"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_SERVER}  "ioE.ini" "Field 10" "Text"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_USER}    "ioE.ini" "Field 11" "Text"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_PORT}    "ioE.ini" "Field 12" "Text"

  MessageBox MB_YESNO \
      "${L_PERSONA}\
      $\r$\n$\r$\n\
      $(PFI_LANG_OOECFG_MBEMAIL) ${L_EMAIL}\
      $\r$\n$\r$\n\
      $(PFI_LANG_OOECFG_MBSERVER) 127.0.0.1 \
                                   ($(PFI_LANG_OOECFG_MBOLDVALUE) '${L_SERVER}')\
      $\r$\n$\r$\n\
      $(PFI_LANG_OOECFG_MBUSERNAME) ${L_SERVER}$G_SEPARATOR${L_USER} \
                                     ($(PFI_LANG_OOECFG_MBOLDVALUE) '${L_USER}')\
      $\r$\n$\r$\n\
      $(PFI_LANG_OOECFG_MBOEPORT) $G_POP3 \
                                   ($(PFI_LANG_OOECFG_MBOLDVALUE) '${L_PORT}')\
      $\r$\n$\r$\n$\r$\n\
      $(PFI_LANG_OOECFG_MBQUESTION)\
      " IDYES exit
  Pop ${L_USER}
  Pop ${L_SERVER}
  Pop ${L_PORT}
  Pop ${L_PERSONA}
  Pop ${L_EMAIL}
  Abort

exit:
  Pop ${L_USER}
  Pop ${L_SERVER}
  Pop ${L_PORT}
  Pop ${L_PERSONA}
  Pop ${L_EMAIL}

  !undef L_EMAIL
  !undef L_PERSONA
  !undef L_PORT
  !undef L_SERVER
  !undef L_USER

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

  RMDir /r "$G_USERDIR\corpus"

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

  IfFileExists "$G_ROOTDIR\translator.htm" 0 exit
  ExecShell "open" "$G_ROOTDIR\translator.htm"

exit:
FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: ShowReadMe
# (the "ReadMe" function for the 'Finish' page)
#--------------------------------------------------------------------------

Function ShowReadMe

  IfFileExists "$G_ROOTDIR\${C_README}.txt" 0 exit
  ExecShell "open" "$G_ROOTDIR\${C_README}.txt"

exit:
FunctionEnd

#--------------------------------------------------------------------------
# Initialise the uninstaller
#--------------------------------------------------------------------------

Function un.onInit

  ; Retrieve the language used when this version was installed, and use it for the uninstaller

  !insertmacro MUI_UNGETLANGUAGE

  ; For increased flexibility, several global user variables are used (this makes it easier
  ; to change the folder structure used by the wizard)

  StrCpy $G_USERDIR   $INSTDIR

  ReadRegStr $G_ROOTDIR HKLM "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "InstallPath"

  ; Email settings are stored on a 'per user' basis therefore we need to know which user is
  ; running the uninstaller so we can check if the email settings can be safely restored

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
  StrCmp $G_WINUSERTYPE "Power" exit
  StrCmp $G_WINUSERTYPE "User" exit
  StrCmp $G_WINUSERTYPE "Guest" exit
  StrCpy $G_WINUSERTYPE "Unknown"

exit:
FunctionEnd

#--------------------------------------------------------------------------
# Uninstaller Section
#--------------------------------------------------------------------------

Section "Uninstall"

  MessageBox MB_YESNO|MB_ICONSTOP|MB_DEFBUTTON2 \
      "$(PFI_LANG_UN_MBDIFFUSER_1) ('Owner') !\
      $\r$\n$\r$\n\
      $(PFI_LANG_UN_MBNOTFOUND_2)" IDYES look_for_popfile
  Abort "$(PFI_LANG_UN_ABORT_1)"

look_for_popfile:
  MessageBox MB_YESNO|MB_ICONSTOP|MB_DEFBUTTON2 \
      "$(PFI_LANG_UN_MBNOTFOUND_1) '$G_USERDIR'.\
      $\r$\n$\r$\n\
      $(PFI_LANG_UN_MBNOTFOUND_2)" IDYES skip_confirmation

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
  DetailPrint "$(PFI_LANG_TAKE_A_FEW_SECONDS)"

  Sleep ${C_UNINST_PROG_SHUTDOWN_DELAY}

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROG_SHORT)"
  SetDetailsPrint listonly

  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Add User Demo\Uninstall Testbed Data ($G_WINUSERNAME).lnk"
  RMDir  "$SMPROGRAMS\${C_PFI_PRODUCT}\Add User Demo"
  RMDir  "$SMPROGRAMS\${C_PFI_PRODUCT}"

  Sleep ${C_UNINST_PROG_SHORT_DELAY}

  ; Display the "restoring Outlook Express settings" messages

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROG_OUTEXPRESS)"
  SetDetailsPrint listonly

  MessageBox MB_ABORTRETRYIGNORE|MB_ICONSTOP|MB_DEFBUTTON2 "$(PFI_LANG_MBCLIENT_EXP)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_4)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_5)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_6)"\
             IDRETRY exp_continue IDIGNORE exp_continue

exp_continue:
  Sleep ${C_UNINST_PROG_EMAIL_DELAY}

  DetailPrint "$(PFI_LANG_UN_LOG_OPENED): popfile.reg.dummy"
  DetailPrint "$(PFI_LANG_UN_LOG_RESTORED) POP3 User Name: an.example"
  DetailPrint "$(PFI_LANG_UN_LOG_RESTORED) POP3 Server: mail.my.isp.com"
  DetailPrint "$(PFI_LANG_UN_LOG_RESTORED) POP3 Port: 110"
  DetailPrint "$(PFI_LANG_UN_LOG_DATAPROBS)"
  DetailPrint "$(PFI_LANG_UN_LOG_DELROOTDIR): popfile.reg.dummy"

  MessageBox MB_YESNO|MB_ICONEXCLAMATION \
      "$(PFI_LANG_UN_MBCLIENT_1)\
      $\r$\n$\r$\n\
      $(PFI_LANG_UN_MBEMAIL_1)\
      $\r$\n$\r$\n\
      $(PFI_LANG_UN_MBEMAIL_2)" IDNO end_exp_restore

end_exp_restore:
  Sleep ${C_UNINST_PROG_EMAIL_DELAY}

  ; Display the "restoring Outlook settings" messages

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROG_OUTLOOK)"
  SetDetailsPrint listonly

  MessageBox MB_ABORTRETRYIGNORE|MB_ICONSTOP|MB_DEFBUTTON2 "$(PFI_LANG_MBCLIENT_OUT)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_4)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_5)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_6)"\
             IDRETRY out_continue IDIGNORE out_continue

out_continue:
  Sleep ${C_UNINST_PROG_EMAIL_DELAY}

  MessageBox MB_YESNO|MB_ICONEXCLAMATION \
      "$(PFI_LANG_UN_MBCLIENT_2)\
      $\r$\n$\r$\n\
      $(PFI_LANG_UN_MBEMAIL_1)\
      $\r$\n$\r$\n\
      $(PFI_LANG_UN_MBEMAIL_2)" IDNO end_out_restore

end_out_restore:
  Sleep ${C_UNINST_PROG_EMAIL_DELAY}

  ; Display the "restoring Eudora settings" messages

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROG_EUDORA)"
  SetDetailsPrint listonly

  MessageBox MB_ABORTRETRYIGNORE|MB_ICONSTOP|MB_DEFBUTTON2 "$(PFI_LANG_MBCLIENT_EUD)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_4)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_5)\
             $\r$\n$\r$\n\
             $(PFI_LANG_MBCLIENT_STOP_6)"\
             IDRETRY eud_continue IDIGNORE eud_continue

eud_continue:
  Sleep ${C_UNINST_PROG_EMAIL_DELAY}

  Delete $G_USERDIR\expchanges.txt
  Delete $G_USERDIR\expconfig.txt
  Delete $G_USERDIR\outchanges.txt
  Delete $G_USERDIR\outconfig.txt

  MessageBox MB_YESNO|MB_ICONEXCLAMATION \
      "$(PFI_LANG_UN_MBCLIENT_3)\
      $\r$\n$\r$\n\
      $(PFI_LANG_UN_MBEMAIL_1)\
      $\r$\n$\r$\n\
      $(PFI_LANG_UN_MBEMAIL_2)" IDNO end_eud_restore

end_eud_restore:
  Sleep ${C_UNINST_PROG_EMAIL_DELAY}

  RMDir /r $G_USERDIR\corpus

  Delete $G_USERDIR\stopwords
  Delete $G_USERDIR\stopwords.bak
  Delete $G_USERDIR\stopwords.default

  MessageBox MB_YESNO|MB_ICONSTOP \
    "$(PFI_LANG_UN_MBRERUN_1)\
    $\r$\n$\r$\n\
    $(PFI_LANG_UN_MBRERUN_2)\
    $\r$\n$\r$\n\
    $(PFI_LANG_UN_MBRERUN_3)\
    $\r$\n$\r$\n\
    $(PFI_LANG_UN_MBRERUN_4)" IDYES remove_all

remove_all:
  RMDir $G_USERDIR

  StrCmp $APPDATA "" 0 appdata_valid
  RMDir "${C_ALT_DEFAULT_USERDATA}"
  Goto remove_shortcut

appdata_valid:
  RMDir "${C_STD_DEFAULT_USERDATA}"

remove_shortcut:
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Uninstall PFI Add User Testbed.lnk"
  RMDir "$SMPROGRAMS\${C_PFI_PRODUCT}"

  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}_AUW"
  DeleteRegKey HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI\UserDataPath"
  DeleteRegKey /ifempty HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI"
  DeleteRegKey /ifempty HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}"
  DeleteRegKey /ifempty HKCU "SOFTWARE\POPFile Project"

  ; The uninstaller (uninst_transauw.exe) has not yet been removed

  MessageBox MB_YESNO|MB_ICONQUESTION "$(PFI_LANG_UN_MBREMDIR_2)" IDNO Removed
Removed:
  DetailPrint "$(PFI_LANG_UN_LOG_DELUSERDIR)"
  Delete $G_USERDIR\*.* ; this would be skipped if the user hits no
  RMDir /r $G_USERDIR
  DetailPrint "$(PFI_LANG_UN_LOG_DELUSERERR)"
  MessageBox MB_OK|MB_ICONEXCLAMATION \
      "$(PFI_LANG_UN_MBREMERR_1): $G_USERDIR $(PFI_LANG_UN_MBREMERR_2)"
  SetDetailsPrint both

SectionEnd

#--------------------------------------------------------------------------
# End of 'transAUW.nsi'
#--------------------------------------------------------------------------
