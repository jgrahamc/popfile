#--------------------------------------------------------------------------
#
# adduser.nsi --- This is the NSIS script used to create the 'Add POPFile User' wizard
#                 which is used by the POPFile installer (setup.exe) to perform the
#                 user-specific parts of the installation. This wizard is also installed
#                 in the main POPFile installation folder for use when a new user tries
#                 to run POPFile for the first time. Some simple "repair work" can also
#                 be done using this wizard.
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
# The original 'adduser.nsi' script has been divided into several files:
#
#  (1) adduser.nsi             - master script which uses the following 'include' files
#  (2) adduser-Version.nsh     - version number for 'Add POPFile User' wizard & uninstaller
#  (3) adduser-EmailConfig.nsh - source for email account reconfiguration pages & functions
#  (4) adduser-Uninstall.nsh   - source for the 'User Data' uninstaller (uninstalluser.exe)
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

#--------------------------------------------------------------------------
# Compile-time command-line switches (used by 'makensis.exe')
#--------------------------------------------------------------------------
#
# /DENGLISH_MODE
#
# To build an 'Add POPFile User' wizard that only displays English messages (so there is no
# need to ensure all of the non-English *-pfi.nsh files are up-to-date), supply the command-line
# switch /DENGLISH_MODE when compiling this script. This switch only affects the language used
# by the wizard, it does not affect which files get installed.
#
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
# Optional run-time command-line switches (used by 'adduser.exe')
#--------------------------------------------------------------------------
#
# /install
#
# This command-line switch is used when this wizard is called by the main installer program
# (setup.exe) and makes the wizard skip the language selection dialog. When this switch is used
# and an upgrade installation is being performed, the wizard asks if the existing configuration
# data is to be upgraded (instead of simply displaying the DIRECTORY page which selects the
# folder to be used for the 'User Data') because this build of the wizard can only upgrade the
# existing data 'in situ'. If user does not choose to upgrade the existing data then the normal
# DIRECTORY page is displayed with the normal default 'User Data' location as the default folder
# (the user is free to select an alternative location).
#
# /installreboot
#
# This command-line switch behaves like /install but also makes the wizard set the reboot flag
# to force a reboot. When the Kakasi package is installed on a Win9x system, a reboot is usually
# required in order to create the system-wide environment variables used by the package. Since
# the main installer quits before calling the wizard, it is up to the wizard to force the reboot
# if one is required.
#
# /restore="absolute path to the restored 'User Data' folder"
#
# This command-line switch is used when this wizard is called by the POPFile 'User Data' Restore
# utility to complete the restoration of the 'User Data'. The path provided via this switch will
# be used to update the registry, environment variables and Start Menu entries.
# NOTE: The path should be enclosed in quotes (eg /restore="C:\Program Files\POPFile")
#
# Note: These command-line switches are mutually exclusive
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
# LANGUAGE SUPPORT:
#
# The wizard defaults to multi-language mode ('English' plus a number of other languages).
#
# If required, the command-line switch /DENGLISH_MODE can be used to build an English-only
# version.
#--------------------------------------------------------------------------
# The POPFile installer uses several multi-language mode programs built using NSIS. To make
# maintenance easier, an 'include' file (pfi-languages.nsh) defines the supported languages.
#
# Removing support for a particular language:
#
# To remove any of the additional languages, only TWO lines need to be commented-out:
#
# (a) comment-out the relevant '!insertmacro PFI_LANG_LOAD' line in the list of languages
#     in the in the 'pfi-languages.nsh' file.
#
# (b) comment-out the relevant '!insertmacro UI_LANG_CONFIG' line in the list of languages
#     in the code which preselects the UI language (in this file)
#
# For example, to remove support for the 'Dutch' language, comment-out the line
#
#     !insertmacro PFI_LANG_LOAD "Dutch"
#
# in the 'pfi-languages.nsh' file, and comment-out the line
#
#     !insertmacro UI_LANG_CONFIG "DUTCH" "Nederlands"
#
# in the code which preselects the UI language (Section "Languages").
#
#--------------------------------------------------------------------------
# Adding support for a particular language:
#
# The 'pfi-languages.nsh' file explains how to add support for an additional language.
#
# If there is a suitable POPFile UI language file for the new language, add a suitable
# '!insertmacro UI_LANG_CONFIG' line in the section below which handles the optional 'Languages'
# component to allow the wizard to select the appropriate UI language.
#--------------------------------------------------------------------------

  ;------------------------------------------------
  ; 'Add User' wizard overview
  ;------------------------------------------------

  ; This wizard is used by the main POPfile installer ('setup.exe') to perform the user-specific
  ; configuration for the user who is running the installer. The main installer is now solely
  ; concerned with installing the POPFile program files and the associated registry entries.
  ;
  ; This wizard is also used when 'runpopfile.exe' is unable to determine appropriate values for
  ; the POPFILE_ROOT and POPFILE_USER environment variables which are used by POPFile 0.21.0
  ; (or later). For example, if a multi-user install was performed then the first time a new
  ; user tries to use the standard 'Run POPFile' shortcut there will be no HKCU registry data
  ; to tell 'runpopfile.exe' how to initialise the environment variables.
  ;
  ; This wizard uses HKLM Registry data to create the necessary HKCU entries and ensures the
  ; environment variables are initialized before running POPFile. It also offers to reconfigure
  ; any suitable Outlook Express, Outlook or Eudora accounts for the user and can monitor the
  ; conversion of an existing flat file or BerkeleyDB corpus to a new SQL database, or the
  ; upgrading of an existing SQL database to use a new database schema .
  ;
  ; Other uses for this wizard include allowing a user to switch between different sets of
  ; configuration data and repairing 'damaged' HKCU entries.
  ;
  ; The wizard creates an uninstaller (uninstalluser.exe) which makes it easy to restore the
  ; Outlook Express, Outlook and Eudora settings which were changed by the wizard, in addition
  ; to removing the user's POPFile configuration data.

  ;------------------------------------------------
  ; Define PFI_VERBOSE to get more compiler output
  ;------------------------------------------------

## !define PFI_VERBOSE

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

  ; This build is for use with the POPFile installer

  !define C_PFI_PRODUCT  "POPFile"

  ; Name to be used for the program file (also used for the 'Version Information')

  !define C_OUTFILE      "adduser.exe"

  Name                   "POPFile User"

  ; Now that the NSIS script for 'adduser.exe' has been divided into several files, it is
  ; convenient to use an "include" file to define the version number (${C_PFI_VERSION}).

  !include "adduser-Version.nsh"

  ; Mention the wizard's version number in the titles of the installer & uninstaller windows

  Caption                "Add POPFile User v${C_PFI_VERSION}"
  UninstallCaption       "Remove POPFile User v${C_PFI_VERSION}"

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

  ; Note: C_STD_DEFAULT_USERDATA and C_ALT_DEFAULT_USERDATA must not end with trailing slashes

  !define C_STD_DEFAULT_USERDATA  "$APPDATA\POPFile"
  !define C_ALT_DEFAULT_USERDATA  "$WINDIR\Application Data\POPFile"

  ;-------------------------------------------------------------------------------
  ; Constant used to avoid problems with Banner.dll
  ;
  ; (some versions of the DLL do not like being 'destroyed' immediately)
  ;-------------------------------------------------------------------------------

  ; Minimum time for the banner to be shown (in milliseconds)

  !define C_MIN_BANNER_DISPLAY_TIME  250

  ;-------------------------------------------------------------------------------
  ; Constant used to give POPFile time to start its web server and be able to display the UI
  ;-------------------------------------------------------------------------------

  ; Sleep delay (in milliseconds) used after starting POPFile (in 'CheckLaunchOptions' function)

  !define C_UI_STARTUP_DELAY         5000

#--------------------------------------------------------------------------
# User Registers (Global)
#--------------------------------------------------------------------------

  ; This script uses 'User Variables' (with names starting with 'G_') to hold GLOBAL data.

  Var G_PFISETUP           ; parameter passed from main installer (setup.exe)
                           ; or the 'User Data' Restore utility (pfi-restore (<username>).exe)

  Var G_ROOTDIR            ; full path to the folder used for the POPFile program files
  Var G_USERDIR            ; full path to the folder containing the 'popfile.cfg' file

  Var G_POP3               ; POP3 port (1-65535)
  Var G_GUI                ; GUI port (1-65535)
  Var G_PFIFLAG            ; (a) Installer:
                           ;     POPFile automatic startup flag (1 = yes, 0 = no)
                           ; (b) Uninstaller:
                           ;     'normal'  = being run by the user who is the owner
                           ;     'special' = being run by a user other than the owner
                           ;     'success' = email settings restored OK (in 'normal' mode)
                           ;     'fail'    = email settings problem found (in 'normal' mode)

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

  Var G_PLS_FIELD_1        ; used to customize translated text strings
  Var G_PLS_FIELD_2        ; used to customize translated text strings (used in 'CBP.nsh' file)

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
# Use the "Modern User Interface" and the standard NSIS list of common Windows Messages
#--------------------------------------------------------------------------

  !include "MUI.nsh"
  !include "WinMessages.nsh"

#--------------------------------------------------------------------------
# Include private library functions and macro definitions
#--------------------------------------------------------------------------

  ; Avoid compiler warnings by disabling the functions and definitions we do not use

  !define ADDUSER

  !include "pfi-library.nsh"
  !include "WriteEnvStr.nsh"

#--------------------------------------------------------------------------
# Version Information settings (for the installer EXE and uninstaller EXE)
#--------------------------------------------------------------------------

  ; 'VIProductVersion' format is X.X.X.X where X is a number in range 0 to 65535
  ; representing the following values: Major.Minor.Release.Build

  VIProductVersion                          "${C_PFI_VERSION}.0"

  VIAddVersionKey "ProductName"             "POPFile User wizard"
  VIAddVersionKey "Comments"                "POPFile Homepage: http://getpopfile.org/"
  VIAddVersionKey "CompanyName"             "The POPFile Project"
  VIAddVersionKey "LegalCopyright"          "Copyright (c) 2005  John Graham-Cumming"
  VIAddVersionKey "FileDescription"         "Add/Remove POPFile User wizard"
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
#
#   Allow the names of the default buckets (for a 'clean' install) to be translated,
#   but they can use only the characters abcdefghijklmnopqrstuvwxyz_-0123456789
#
  !define CBP_DEFAULT_LIST "$(PFI_LANG_CBP_DEFAULT_BUCKETS)"
#
#   ; List of suggestions for bucket names (use "" if no suggestions are required)
#
#   !define CBP_SUGGESTION_LIST \
#   "admin|business|computers|family|financial|general|hobby|inbox|junk|list-admin|\
#   miscellaneous|not_spam|other|personal|recreation|school|security|shopping|spam|\
#   travel|work"
#
#   Allow the list of suggested bucket names (for a 'clean' install) to be translated,
#   but they can use only the characters abcdefghijklmnopqrstuvwxyz_-0123456789
#
  !define CBP_SUGGESTION_LIST "$(PFI_LANG_CBP_SUGGESTED_NAMES)"
#
#----------------------------------------------------------------------------------------
# Make the CBP package available
#----------------------------------------------------------------------------------------

  !include CBP.nsh

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

  ; The "Header" bitmap appears on all pages of the installer (except WELCOME & FINISH pages)
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

  ; The "Special" bitmap appears on the "WELCOME" and "FINISH" pages

  !define MUI_WELCOMEFINISHPAGE_BITMAP        "special.bmp"

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

  !define MUI_CUSTOMFUNCTION_GUIINIT          "PFIGUIInit"

  ; Use a custom 'un.onGUIInit' function to allow language-specific texts in the username check

  !define MUI_CUSTOMFUNCTION_UNGUIINIT        "un.PFIGUIInit"

  ;----------------------------------------------------------------
  ; Language Settings for MUI pages
  ;----------------------------------------------------------------

  ; Same "Language selection" dialog is used for the installer and the uninstaller
  ; so we override the standard "Installer Language" title to avoid confusion.

  !define MUI_LANGDLL_WINDOWTITLE             "Add/Remove POPFile User"

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

  ; Use a "leave" function to decide upon a suitable initial value for the user data folder
  ; (this initial value is used for the DIRECTORY page used to select 'User Data' location).

  !define MUI_PAGE_CUSTOMFUNCTION_LEAVE       "ChooseDefaultDataDir"

  ; Text used to replace the standard WELCOME page text

  !define MUI_WELCOMEPAGE_TEXT                "$(PFI_LANG_ADDUSER_INFO_TEXT)"

  !insertmacro MUI_PAGE_WELCOME

  ;---------------------------------------------------
  ; Installer Page - Select user data Directory
  ;---------------------------------------------------

  ; Use a "pre" function to determine if this page should be displayed. This build of the
  ; wizard cannot relocate an existing set of user data, so when the wizard is called from
  ; the main 'setup.exe' installer to upgrade an existing installation, the DIRECTORY page
  ; is bypassed, we use the existing location and upgrade any old-style corpus files there
  ; (the user is allowed to choose a different location, to avoid upgrading existing data).

  !define MUI_PAGE_CUSTOMFUNCTION_PRE         "CheckUserDirStatus"

  ; Use a "leave" function to look for an existing 'popfile.cfg' and use it to determine some
  ; initial settings for this installation.

  !define MUI_PAGE_CUSTOMFUNCTION_LEAVE       "CheckExistingDataDir"

  ; This page is used to select the folder for the POPFile USER DATA files

  !define MUI_PAGE_HEADER_TEXT                "$(PFI_LANG_USERDIR_TITLE)"
  !define MUI_PAGE_HEADER_SUBTEXT             "$(PFI_LANG_USERDIR_SUBTITLE)"
  !define MUI_DIRECTORYPAGE_TEXT_TOP          "$(PFI_LANG_USERDIR_TEXT_TOP)"
  !define MUI_DIRECTORYPAGE_TEXT_DESTINATION  "$(PFI_LANG_USERDIR_TEXT_DESTN)"

  !insertmacro MUI_PAGE_DIRECTORY

  ;---------------------------------------------------
  ; Installer Page - POP3 and UI Port Options
  ;---------------------------------------------------

  Page custom SetOptionsPage                  "CheckPortOptions"

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
  ; Installer Page - A "pre" function for the "Choose POPFile launch mode" page
  ;---------------------------------------------------

  PageEx custom
    PageCallbacks                             "CheckCorpusUpgradeStatus"
  PageExEnd

  ;---------------------------------------------------
  ; Installer Page - Choose POPFile launch mode
  ;---------------------------------------------------

  Page custom StartPOPFilePage                "CheckLaunchOptions"

  ;---------------------------------------------------
  ; Installer Page - FINISH (may offer to start UI)
  ;---------------------------------------------------

  !define MUI_FINISHPAGE_TEXT                 "$(PFI_LANG_ADDUSER_FINISH_INFO)"

  ; Use a "pre" function for the 'FINISH' page to ensure installer only offers to display
  ; POPFile User Interface if user has chosen to start POPFile from the installer.

  !define MUI_PAGE_CUSTOMFUNCTION_PRE         "CheckRunStatus"

  ; Use a "leave" function for the 'FINISH' page to remove any empty corpus folders left
  ; behind after POPFile has converted the buckets (if any) created by the CBP package.
  ; (If the user doesn't run POPFile from the installer, these corpus folders will not be empty)

  !define MUI_PAGE_CUSTOMFUNCTION_LEAVE       "RemoveEmptyCBPCorpus"

  ; Offer to display the POPFile User Interface (The 'CheckRunStatus' function ensures this
  ; option is only offered if the installer has started POPFile running)

  !define MUI_FINISHPAGE_RUN
  !define MUI_FINISHPAGE_RUN_TEXT             "$(PFI_LANG_FINISH_RUN_TEXT)"
  !define MUI_FINISHPAGE_RUN_FUNCTION         "RunUI"

  ; Provide a checkbox to let user display the Release Notes for this version of POPFile

  !define MUI_FINISHPAGE_SHOWREADME
  !define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
  !define MUI_FINISHPAGE_SHOWREADME_FUNCTION  "ShowReadMe"

  ; Provide a link to the POPFile Home Page

  !define MUI_FINISHPAGE_LINK                 "$(PFI_LANG_FINISH_WEB_LINK_TEXT)"
  !define MUI_FINISHPAGE_LINK_LOCATION        "http://getpopfile.org/"

  !insertmacro MUI_PAGE_FINISH

  ;---------------------------------------------------
  ; Uninstaller Page - Confirmation Page
  ;---------------------------------------------------

  !define MUI_PAGE_HEADER_TEXT                "$(PFI_LANG_REMUSER_TITLE)"
  !define MUI_PAGE_HEADER_SUBTEXT             "$(PFI_LANG_REMUSER_SUBTITLE)"
  !define MUI_UNCONFIRMPAGE_TEXT_TOP          "$(PFI_LANG_REMUSER_TEXT_TOP)"

  !insertmacro MUI_UNPAGE_CONFIRM

  ;---------------------------------------------------
  ; Uninstaller Page - Uninstall POPFile
  ;---------------------------------------------------

  ; Override the standard "Uninstalling/Please wait.." page header

  !define MUI_PAGE_HEADER_TEXT                "$(PFI_LANG_REMOVING_TITLE)"
  !define MUI_PAGE_HEADER_SUBTEXT             "$(PFI_LANG_REMOVING_SUBTITLE)"

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
  ; By default, NSIS will append '\POPFile' to the path selected using the 'Browse' button if
  ; the path does not already end with '\POPFile'. If the 'Browse' button is used to select
  ; 'C:\Application Data\POPFile Test' the wizard will install the 'User Data' in the folder
  ; 'C:\Application Data\POPFile Test\POPFile' and although this location is displayed on the
  ; DIRECTORY page before the user clicks the 'Next' button most users will not notice that
  ; '\POPFile' has been appended to the location they selected.
  ;
  ; By adding a trailing slash we ensure that if the user selects a folder using the 'Browse'
  ; button then that is what the wizard will use. One side effect of this change is that it
  ; is now easier for users to select a folder such as 'C:\Program Files' for the 'User Data'
  ; (which is not a good choice - so we refuse to accept any path matching the target system's
  ; "program files" folder; see the 'CheckExistingDataDir' function)

  InstallDir "${C_STD_DEFAULT_USERDATA}\"

#--------------------------------------------------------------------------
# Reserve the files required by the installer (to improve performance)
#--------------------------------------------------------------------------

  ; Things that need to be extracted on startup (keep these lines before any File command!)
  ; Only useful when solid compression is used (by default, solid compression is enabled
  ; for BZIP2 and LZMA compression)

  !insertmacro MUI_RESERVEFILE_LANGDLL
  !insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
  ReserveFile "${NSISDIR}\Plugins\Banner.dll"
  ReserveFile "${NSISDIR}\Plugins\nsExec.dll"
  ReserveFile "${NSISDIR}\Plugins\NSISdl.dll"
  ReserveFile "${NSISDIR}\Plugins\System.dll"
  ReserveFile "${NSISDIR}\Plugins\UserInfo.dll"
  ReserveFile "ioA.ini"
  ReserveFile "ioB.ini"
  ReserveFile "ioC.ini"
  ReserveFile "ioE.ini"
  ReserveFile "ioF.ini"

#--------------------------------------------------------------------------
# Installer Function: .onInit - installer starts by offering a choice of languages
#--------------------------------------------------------------------------

Function .onInit

  ; The command-line switch '/install' (or '/installreboot') is used to suppress this wizard's
  ; language selection dialog when the wizard is called from 'setup.exe' during installation
  ; of POPFile. The '/restore="path to restored data"' switch performs a similar function when
  ; this wizard is called from the POPFile 'User Data' Restore wizard.

  Call PFI_GetParameters
  Pop $G_PFISETUP
  StrCpy $G_PFIFLAG $G_PFISETUP 9
  StrCmp $G_PFIFLAG "/restore=" special_case
  StrCmp $G_PFISETUP "/install" special_case
  StrCmp $G_PFISETUP "/installreboot" 0 normal_startup
  SetRebootFlag true

special_case:
  ReadRegStr $LANGUAGE \
             "HKCU" "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "Installer Language"
  Goto extract_files

normal_startup:

  ; Conditional compilation: if ENGLISH_MODE is defined, support only 'English'

  !ifndef ENGLISH_MODE
        !insertmacro MUI_LANGDLL_DISPLAY
  !endif

extract_files:
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioA.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioB.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioC.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioE.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioF.ini"

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
# Used to complete the initialization of the installer.
# This code was moved from '.onInit' in order to permit the use of language-specific strings
# (the selected language is not available inside the '.onInit' function)
#--------------------------------------------------------------------------

Function PFIGUIInit

  !define L_RESERVED            $1    ; used in the system.dll call

  StrCpy $G_ROOTDIR "$EXEDIR"
  IfFileExists "$G_ROOTDIR\runpopfile.exe" 0 try_registry
  IfFileExists "$G_ROOTDIR\popfile.pl" compatible

try_registry:
  ReadRegStr $G_ROOTDIR HKLM "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_LFN"
  StrCmp $G_ROOTDIR "" 0 compatible
  MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_COMPAT_NOTFOUND)"
  Abort

compatible:
  Push ${L_RESERVED}

  ; Ensure only one copy of this installer is running

  System::Call 'kernel32::CreateMutexA(i 0, i 0, t "OnlyOnePFI_AUW_mutex") i .r1 ?e'
  Pop ${L_RESERVED}
  StrCmp ${L_RESERVED} 0 mutex_ok
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(PFI_LANG_INSTALLER_MUTEX)"
  Abort

mutex_ok:

  ; Insert appropriate language strings into the custom page INI files
  ; (the CBP package creates its own INI file so there is no need for a CBP *Page_Init function)

  Call SetOptionsPage_Init
  Call SetEmailClientPage_Init
  Call SetOutlookOutlookExpressPage_Init
  Call SetEudoraPage_Init
  Call StartPOPFilePage_Init

  Pop ${L_RESERVED}

  !undef L_RESERVED

FunctionEnd

#--------------------------------------------------------------------------
# Installer Section: POPFile component
#
# (a) If upgrading, shutdown existing version of POPFile
# (b) Create registry entries for current user (HKCU)
# (c) Create POPFILE_ROOT & POPFILE_USER environment variables (temporary ones if Win9x system)
# (d) Install/update POPFile configuration files (popfile.cfg, stopwords, stopwords.default)
# (e) Write the uninstaller (for the 'User Data') and create/update the Start Menu shortcuts
# (f) Create 'Add/Remove Program' entry for the 'User Data'
#--------------------------------------------------------------------------

Section "POPFile" SecPOPFile

  ; Make this section mandatory (i.e. it is always installed)

  SectionIn RO

  !define L_CFG           $R9   ; file handle
  !define L_POPFILE_ROOT  $R8
  !define L_POPFILE_USER  $R7
  !define L_TEMP          $R6

  !define L_RESERVED      $0    ; used in system.dll calls
  Push ${L_RESERVED}

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_REGSET)"
  SetDetailsPrint listonly

  IfFileExists "$G_USERDIR\*.*" userdir_exists
  ClearErrors
  CreateDirectory "$G_USERDIR"
  IfErrors 0 userdir_exists
  SetDetailsPrint both
  DetailPrint "Fatal error: unable to create folder for the 'User Data' files"
  SetDetailsPrint listonly
  MessageBox MB_OK|MB_ICONSTOP|MB_TOPMOST \
      "Error: Unable to create folder for the 'User Data' files\
      ${MB_NL}${MB_NL}\
      ($G_USERDIR)"
  Abort

userdir_exists:

  ; If we are installing over a previous version, ensure that version is not running

  Call MakeUserDirSafe

  Push ${L_CFG}
  Push ${L_POPFILE_ROOT}
  Push ${L_POPFILE_USER}
  Push ${L_TEMP}

  ; If the wizard is in the same folder as POPFile, check the HKLM data is still valid

  IfFileExists "$EXEDIR\popfile.pl" 0 update_HKCU_data

  ; If user has 'Admin' rights and this wizard is in a different folder from that specified
  ; for POPFile in HKLM, make the HKLM data point to the wizard's folder. (This will make the
  ; wizard use the version of POPFile in the wizard's folder when adding a new POPFile user.)

  StrCmp $G_WINUSERTYPE "Admin" 0 update_HKCU_data
  ReadRegStr ${L_TEMP} HKLM "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_LFN"
  StrCmp ${L_TEMP} "$G_ROOTDIR" update_HKCU_data
  WriteRegStr HKLM "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_LFN" "$G_ROOTDIR"
  StrCmp $G_SFN_DISABLED "0" find_HKLM_root_sfn
  StrCpy ${L_TEMP} "Not supported"
  Goto save_HKLM_root_sfn

find_HKLM_root_sfn:
  GetFullPathName /SHORT ${L_TEMP} "$G_ROOTDIR"

save_HKLM_root_sfn:
  WriteRegStr HKLM "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_SFN" "${L_TEMP}"

  IfFileExists "$SMPROGRAMS\${C_PFI_PRODUCT}\Uninstall POPFile.lnk" 0 update_HKCU_data
  IfFileExists "$G_ROOTDIR\uninstall.exe" 0 update_HKCU_data
  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Uninstall POPFile.lnk" NORMAL
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Uninstall POPFile.lnk" \
                 "$G_ROOTDIR\uninstall.exe"

update_HKCU_data:

  ; For this build, each user is expected to have a separate user data folder. The wizard uses
  ; the $G_USERDIR variable to hold the full path to this folder. By default each folder will
  ; contain popfile.cfg, stopwords, stopwords.default, popfile.db, the messages folder, etc.
  ; If an existing flat file or BerkeleyDB corpus is to be converted to the new SQL database
  ; format, a backup copy of the old corpus will be saved in the $G_USERDIR\backup folder.

  ; For flexibility, several global user variables are used to access installation folders
  ; (1) $G_ROOTDIR is initialized by the 'PFIGUIInit' function
  ; (2) $G_USERDIR is normally initialized by the 'User Data' DIRECTORY page

  ReadRegStr ${L_TEMP} HKLM "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "InstallPath"
  Push ${L_TEMP}
  Call PFI_GetCompleteFPN
  Pop ${L_TEMP}
  StrCmp $G_ROOTDIR ${L_TEMP} 0 update_author

  ; The version data in the registry applies to the POPFile programs we have found, so copy it

  !insertmacro PFI_Copy_HKLM_to_HKCU "${L_TEMP}" "POPFile Major Version"
  !insertmacro PFI_Copy_HKLM_to_HKCU "${L_TEMP}" "POPFile Minor Version"
  !insertmacro PFI_Copy_HKLM_to_HKCU "${L_TEMP}" "POPFile Revision"
  !insertmacro PFI_Copy_HKLM_to_HKCU "${L_TEMP}" "POPFile RevStatus"

update_author:
  WriteRegStr HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "Author" "adduser.exe"
  WriteRegStr HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "Owner" "$G_WINUSERNAME"

  WriteRegStr HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "InstallPath" "$G_ROOTDIR"
  WriteRegStr HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_LFN" "$G_ROOTDIR"
  StrCmp $G_SFN_DISABLED "0" find_root_sfn
  StrCpy ${L_TEMP} "Not supported"
  Goto save_root_sfn

find_root_sfn:
  GetFullPathName /SHORT ${L_TEMP} "$G_ROOTDIR"

save_root_sfn:
  WriteRegStr HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_SFN" "${L_TEMP}"

  WriteINIStr "$G_USERDIR\install.ini" "Settings" "Owner" "$G_WINUSERNAME"
  WriteINIStr "$G_USERDIR\install.ini" "Settings" "Class" "$G_WINUSERTYPE"
  WriteINIStr "$G_USERDIR\install.ini" "Settings" "LastU" "adduser.exe"

  DeleteRegValue HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "UserDataPath"
  WriteRegStr HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "UserDir_LFN" "$G_USERDIR"
  StrCmp $G_SFN_DISABLED "0" find_user_sfn
  StrCpy ${L_TEMP} "Not supported"
  Goto save_user_sfn

find_user_sfn:
  GetFullPathName /SHORT ${L_TEMP} "$G_USERDIR"

save_user_sfn:
  WriteRegStr HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "UserDir_SFN" "${L_TEMP}"

  ; Now ensure the POPFILE_ROOT and POPFILE_USER environment variables have the correct data

  ; On non-Win9x systems we create entries in the registry to do this. On Win9x we could use
  ; AUTOEXEC.BAT to do something similar but that would require a reboot to action the changes
  ; required when one user logs off and another logs on, so we don't bother.

  ; On all systems we update these two environment variables NOW (i.e for this process)
  ; so we can start POPFile from the installer.

  ReadRegStr ${L_POPFILE_ROOT} HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_SFN"
  StrCmp ${L_POPFILE_ROOT} "Not supported" 0 check_root_env
  ReadRegStr ${L_POPFILE_ROOT} HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_LFN"

check_root_env:
  ReadEnvStr ${L_TEMP} "POPFILE_ROOT"
  StrCmp ${L_POPFILE_ROOT} ${L_TEMP} root_set_ok
  Call PFI_IsNT
  Pop ${L_RESERVED}
  StrCmp ${L_RESERVED} 0 set_root_now
  WriteRegStr HKCU "Environment" "POPFILE_ROOT" ${L_POPFILE_ROOT}
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

set_root_now:
  System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("POPFILE_ROOT", "${L_POPFILE_ROOT}").r0'
  StrCmp ${L_RESERVED} 0 0 root_set_ok
  MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_ENVNOTSET) (POPFILE_ROOT)"

root_set_ok:
  ReadRegStr ${L_POPFILE_USER} HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "UserDir_SFN"
  StrCmp ${L_POPFILE_USER} "Not supported" 0 check_user_env
  ReadRegStr ${L_POPFILE_USER} HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "UserDir_LFN"

check_user_env:
  ReadEnvStr ${L_TEMP} "POPFILE_USER"
  StrCmp ${L_POPFILE_USER} ${L_TEMP} continue
  Call PFI_IsNT
  Pop ${L_RESERVED}
  StrCmp ${L_RESERVED} 0 set_user_now
  WriteRegStr HKCU "Environment" "POPFILE_USER" ${L_POPFILE_USER}
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

set_user_now:
  System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("POPFILE_USER", "${L_POPFILE_USER}").r0'
  StrCmp ${L_RESERVED} 0 0 continue
  MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_CONVERT_ENVNOTSET) (POPFILE_USER)"

continue:
  SetOutPath "$G_USERDIR"

  Push $G_USERDIR
  Call PFI_GetSQLdbPathName
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "Not SQLite" stopwords

  ; Create a shortcut to make it easier to run the SQLite utility. There are two versions of
  ; the SQLite utility (one for SQlite 2.x format files and one for SQLite 3.x format files)
  ; so we use 'runsqlite.exe' which automatically selects and runs the appropriate version.

  Push $G_USERDIR
  Call PFI_GetDatabaseName
  Pop ${L_TEMP}

  SetFileAttributes "$G_USERDIR\Run SQLite utility.lnk" NORMAL
  CreateShortCut "$G_USERDIR\Run SQLite utility.lnk" \
                 "$G_ROOTDIR\runsqlite.exe" "${L_TEMP}"

stopwords:
  IfFileExists "$G_ROOTDIR\pfi-stopwords.default" 0 update_config_ports

  ; If we are processing data newly restored by the POPFile 'User Data' Restore utility,
  ; do not touch the 'stopwords' file in case it has just been restored (but we still
  ; update the default 'stopwords' file to the one distributed with 'our' version of POPFile)

  StrCpy ${L_TEMP} $G_PFISETUP 9
  StrCmp ${L_TEMP} "/restore=" copy_default_stopwords

  ; If we are upgrading and the user did not have a 'stopwords' file then do not install one
  ; (but still update the default file to the one distributed with 'our' version of POPFile)

  IfFileExists "$G_USERDIR\popfile.cfg" 0 copy_stopwords
  IfFileExists "$G_USERDIR\stopwords" 0 copy_default_stopwords

  ; We are upgrading an existing installation which uses 'stopwords'. If 'our' default list is
  ; the same as the list used by the existing installation then there is no need to find out
  ; what we are supposed to do with the 'stopwords' file.

  Call CompareStopwords
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "same" copy_default_stopwords

  MessageBox MB_YESNO|MB_ICONQUESTION \
      "$(PFI_LANG_MBSTPWDS_A)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_MBSTPWDS_B)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_MBSTPWDS_C)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_MBSTPWDS_D)" IDNO copy_default_stopwords
  IfFileExists "$G_USERDIR\stopwords.bak" 0 make_backup
  SetFileAttributes "$G_USERDIR\stopwords.bak" NORMAL

make_backup:
  CopyFiles /SILENT /FILESONLY "$G_USERDIR\stopwords" "$G_USERDIR\stopwords.bak"

copy_stopwords:
  CopyFiles /SILENT /FILESONLY "$G_ROOTDIR\pfi-stopwords.default" "$G_USERDIR\stopwords"

copy_default_stopwords:
  CopyFiles /SILENT /FILESONLY "$G_ROOTDIR\pfi-stopwords.default" "$G_USERDIR\stopwords.default"

update_config_ports:
  FileOpen  ${L_CFG} "$PLUGINSDIR\popfile.cfg" a
  FileSeek  ${L_CFG} 0 END
  FileWrite ${L_CFG} "pop3_port $G_POP3${MB_NL}"
  FileWrite ${L_CFG} "html_port $G_GUI${MB_NL}"
  FileClose ${L_CFG}
  !insertmacro PFI_BACKUP_123_DP "$G_USERDIR" "popfile.cfg"
  CopyFiles /SILENT /FILESONLY "$PLUGINSDIR\popfile.cfg" "$G_USERDIR\"

  ; Create the uninstall program BEFORE creating the shortcut to it
  ; (this ensures that the correct "uninstall" icon appears in the START MENU shortcut)

  ; NOTE: The main POPFile installer uses 'uninstall.exe' so we have to use a different name
  ; in case the user has selected the main POPFile directory for the user data

  SetOutPath "$G_USERDIR"
  Delete "$G_USERDIR\uninstalluser.exe"
  WriteUninstaller "$G_USERDIR\uninstalluser.exe"

  ; Create the START MENU entries

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_SHORT)"
  SetDetailsPrint listonly

  ; 'CreateShortCut' uses '$OUTDIR' as the working directory for the shortcut
  ; ('SetOutPath' is one way to change the value of $OUTDIR)

  ; 'CreateShortCut' fails to update existing shortcuts if they are read-only, so try to clear
  ; the read-only attribute first. Similar handling is required for the Internet shortcuts.

  ; For this build the following simple scheme is used for the shortcuts:
  ; (a) a 'POPFile' folder with the standard set of shortcuts is created for the current user
  ; (b) if the user ticked the relevant checkbox then a 'Run POPFile' shortcut is placed in the
  ;     current user's StartUp folder.
  ; (c) if the user did not tick the relevant checkbox then the 'Run POPFile' shortcut is
  ;     removed from the current user's StartUp folder

  ReadRegStr $G_ROOTDIR HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_LFN"

  SetOutPath "$SMPROGRAMS\${C_PFI_PRODUCT}"
  SetOutPath "$G_ROOTDIR"

  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Run POPFile.lnk" NORMAL
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Run POPFile.lnk" \
                 "$G_ROOTDIR\runpopfile.exe"

  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Uninstall POPFile Data ($G_WINUSERNAME).lnk" NORMAL
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Uninstall POPFile Data ($G_WINUSERNAME).lnk" \
                 "$G_USERDIR\uninstalluser.exe"

  ; Use registry data to construct the name of the NOTEPAD-compatible release notes file

  ReadRegStr ${L_RESERVED}  HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "POPFile Major Version"
  ReadRegStr ${L_TEMP} HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "POPFile Minor Version"
  StrCpy ${L_RESERVED} "v${L_RESERVED}.${L_TEMP}"
  ReadRegStr ${L_TEMP} HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "POPFile Revision"
  StrCpy ${L_RESERVED} "${L_RESERVED}.${L_TEMP}.change.txt"
  IfFileExists "$G_ROOTDIR\${L_RESERVED}" 0 skip_rel_notes

  SetOutPath "$G_ROOTDIR"
  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Release Notes.lnk" NORMAL
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Release Notes.lnk" \
                 "$G_ROOTDIR\${L_RESERVED}"

skip_rel_notes:
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

  IfFileExists "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\User Data ($G_WINUSERNAME).lnk" 0 pfidiag_entries
  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\User Data ($G_WINUSERNAME).lnk" NORMAL
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\User Data ($G_WINUSERNAME).lnk" \
                 "$G_USERDIR"

pfidiag_entries:
  IfFileExists "$G_ROOTDIR\pfidiag.exe" 0 silent_shutdown
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\PFI Diagnostic utility.lnk"
  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\PFI Diagnostic utility (simple).lnk" NORMAL
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\PFI Diagnostic utility (simple).lnk" \
                 "$G_ROOTDIR\pfidiag.exe"
  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\PFI Diagnostic utility (full).lnk" NORMAL
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\PFI Diagnostic utility (full).lnk" \
                 "$G_ROOTDIR\pfidiag.exe" "/full"
  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\Create 'User Data' shortcut.lnk" NORMAL
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\Create 'User Data' shortcut.lnk" \
                 "$G_ROOTDIR\pfidiag.exe" "/shortcut"

silent_shutdown:
  SetOutPath "$G_ROOTDIR"
  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Shutdown POPFile silently.lnk" NORMAL
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Shutdown POPFile silently.lnk" \
                 "$G_ROOTDIR\stop_pf.exe" "/showerrors $G_GUI"

  StrCmp $G_PFIFLAG "1" set_autostart_set
  Delete "$SMSTARTUP\Run POPFile.lnk"
  Goto end_autostart_set

set_autostart_set:
  SetOutPath "$SMSTARTUP"
  SetOutPath "$G_ROOTDIR"
  SetFileAttributes "$SMSTARTUP\Run POPFile.lnk" NORMAL
  CreateShortCut "$SMSTARTUP\Run POPFile.lnk" "$G_ROOTDIR\runpopfile.exe" "/startup"

end_autostart_set:

  ; Create entry in the Control Panel's "Add/Remove Programs" list

  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}_Data" \
              "DisplayName" "${C_PFI_PRODUCT} Data ($G_WINUSERNAME)"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}_Data" \
              "UninstallString" "$G_USERDIR\uninstalluser.exe"
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}_Data" \
              "NoModify" "1"
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}_Data" \
              "NoRepair" "1"

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_BE_PATIENT)"
  SetDetailsPrint listonly

  Pop ${L_TEMP}
  Pop ${L_POPFILE_USER}
  Pop ${L_POPFILE_ROOT}
  Pop ${L_CFG}

  Pop ${L_RESERVED}
  !undef L_RESERVED

  !undef L_CFG
  !undef L_POPFILE_ROOT
  !undef L_POPFILE_USER
  !undef L_TEMP

SectionEnd

#--------------------------------------------------------------------------
# Installer Section: "Out-of-date SQLite Database" Backup component (always 'installed')
#
# If we are performing an upgrade of a POPFile 0.21.x (or later) installation, the SQL database
# may need to be upgraded (e.g. 0.22.0 uses a different database schema from 0.21.x). If the
# existing installation uses SQLite we try to make a backup copy of the database before starting
# POPFile to perform the upgrade.
#
# (If upgrading from 0.21.x to 0.22.0 (or later) then the message history will also be converted
# but we do not attempt to make a backup of the message history).
#
# The backup is created in the '$G_USERDIR\backup' folder. Information on the backup is stored
# in the 'backup.ini' file to assist in restoring the old corpus.
#
# If SQL database conversion is required, we will use the 'Message Capture' utility to show
# the conversion progress reports (instead of running POPFile in a console window).
#--------------------------------------------------------------------------

Section "-SQLCorpusBackup" SecSQLBackup

  !define L_POPFILE_SCHEMA    $R9   ; database schema version used by newly installed POPFile
  !define L_SQL_DB            $R8
  !define L_SQLITE_SCHEMA     $R7   ; database schema version used by existing SQLite database
  !define L_TEMP              $R6

  Push ${L_POPFILE_SCHEMA}
  Push ${L_SQL_DB}
  Push ${L_SQLITE_SCHEMA}
  Push ${L_TEMP}

  ; If there is no 'popfile.cfg' then we cannot find the SQL database configuration

  IfFileExists "$G_USERDIR\popfile.cfg" 0 exit

  ; If the SQLite backup folder exists, do not attempt to backup the database
  ; (we only make one SQLite backup at present)

  IfFileExists "$G_USERDIR\backup\oldsql\*.*" exit

  ; We only backup the database if the existing installation used the default SQLite package

  Push $G_USERDIR
  Call PFI_GetSQLdbPathName
  Pop ${L_SQL_DB}
  StrCmp ${L_SQL_DB} "" exit
  StrCmp ${L_SQL_DB} "Not SQLite" exit

  ; If the newly installed POPFile database schema differs from the version used by the
  ; SQLite database, we make a backup copy of the database (because POPFile will perform
  ; an automatic database upgrade when it is started).

  Push "$G_ROOTDIR\Classifier\popfile.sql"
  Call PFI_GetPOPFileSchemaVersion
  Pop ${L_POPFILE_SCHEMA}
  StrCpy ${L_TEMP} ${L_POPFILE_SCHEMA} 1
  StrCmp ${L_TEMP} "(" 0 get_sqlite_schema
  StrCpy ${L_POPFILE_SCHEMA} "0"

get_sqlite_schema:
  Push ${L_SQL_DB}
  Call PFI_GetSQLiteSchemaVersion
  Pop ${L_SQLITE_SCHEMA}
  StrCpy ${L_TEMP} ${L_SQLITE_SCHEMA} 1
  StrCmp ${L_TEMP} "(" 0 got_schemas
  StrCpy ${L_SQLITE_SCHEMA} "0"

got_schemas:
  IntCmp ${L_POPFILE_SCHEMA} ${L_SQLITE_SCHEMA} exit

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_SQLBACKUP)"
  SetDetailsPrint listonly

  ; An out-of-date SQLite database has been found, so we make a backup copy

  CreateDirectory "$G_USERDIR\backup"
  WriteINIStr "$G_USERDIR\backup\backup.ini" "OldSQLdatabase" "DatabasePath" "${L_SQL_DB}"

  Push ${L_SQL_DB}
  Call PFI_GetParent
  Pop ${L_TEMP}
  WriteINIStr "$G_USERDIR\backup\backup.ini" "OldSQLdatabase" "ParentPath" "${L_TEMP}"
  StrLen ${L_TEMP} ${L_TEMP}
  IntOp ${L_TEMP} ${L_TEMP} + 1
  StrCpy ${L_TEMP} ${L_SQL_DB} "" ${L_TEMP}

  WriteINIStr "$G_USERDIR\backup\backup.ini" "OldSQLdatabase" "BackupPath" "$G_USERDIR\backup\oldsql"
  WriteINIStr "$G_USERDIR\backup\backup.ini" "OldSQLdatabase" "Database" "${L_TEMP}"

  CreateDirectory "$G_USERDIR\backup\oldsql"
  CopyFiles "${L_SQL_DB}" "$G_USERDIR\backup\oldsql\${L_TEMP}"

  WriteINIStr "$G_USERDIR\backup\backup.ini" "OldSQLdatabase" "Status" "New"

exit:
  Pop ${L_TEMP}
  Pop ${L_SQLITE_SCHEMA}
  Pop ${L_SQL_DB}
  Pop ${L_POPFILE_SCHEMA}

  !undef L_POPFILE_SCHEMA
  !undef L_SQL_DB
  !undef L_SQLITE_SCHEMA
  !undef L_TEMP

SectionEnd

#--------------------------------------------------------------------------
# Installer Section: Flat File or BerkeleyDB Corpus Backup component (always 'installed')
#
# If we are performing an upgrade of a 'flat file' or 'BerkeleyDB' version of POPFile, we make
# a backup of the old corpus structure. Note that if a backup already exists, we do nothing.
#
# The backup is created in the '$G_USERDIR\backup' folder. Information on the backup is stored
# in the 'backup.ini' file to assist in restoring the old corpus. A copy of 'popfile.cfg'
# is also placed in the backup folder.
#
# If corpus conversion is required, create a list of bucket files to be monitored during the
# conversion process (it can take several minutes to convert large corpus files)
#--------------------------------------------------------------------------

Section "-NonSQLCorpusBackup" SecBackup

  !define L_CFG_HANDLE    $R9     ; handle for "popfile.cfg"
  !define L_BUCKET_COUNT  $R8     ; used to update the list of bucket filenames
  !define L_BUCKET_NAME   $R7     ; name of a bucket folder
  !define L_CORPUS_PATH   $R6     ; full path to the corpus
  !define L_CORPUS_SIZE   $R5     ; total number of bytes in all the table/table.db files found
  !define L_FOLDER_COUNT  $R4     ; used to update the list of bucket folder paths
  !define L_TEMP          $R3

  Push ${L_CFG_HANDLE}
  Push ${L_BUCKET_COUNT}
  Push ${L_BUCKET_NAME}
  Push ${L_CORPUS_PATH}
  Push ${L_CORPUS_SIZE}
  Push ${L_FOLDER_COUNT}
  Push ${L_TEMP}

  IfFileExists "$G_USERDIR\popfile.cfg" 0 exit
  IfFileExists "$G_USERDIR\backup\nonsql\*.*" exit

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_FINDCORPUS)"
  SetDetailsPrint listonly

  ; Save installation-specific data for use by the 'Monitor Corpus Conversion' utility

  WriteINIStr "$PLUGINSDIR\corpus.ini" "Settings" "CONVERT" "$G_ROOTDIR\popfileb.exe"
  WriteINIStr "$PLUGINSDIR\corpus.ini" "Settings" "ROOTDIR" "$G_ROOTDIR"
  WriteINIStr "$PLUGINSDIR\corpus.ini" "Settings" "USERDIR" "$G_USERDIR"

  ; Use data in 'popfile.cfg' to generate the full path to the corpus folder

  Push $G_USERDIR
  Call PFI_GetCorpusPath
  Pop ${L_CORPUS_PATH}

  StrCpy ${L_FOLDER_COUNT} 0
  WriteINIStr "$PLUGINSDIR\corpus.ini" "FolderList" "MaxNum" ${L_FOLDER_COUNT}

  StrCpy ${L_BUCKET_COUNT} 0
  WriteINIStr "$PLUGINSDIR\corpus.ini" "BucketList" "FileCount" ${L_BUCKET_COUNT}

  FindFirst ${L_CFG_HANDLE} ${L_BUCKET_NAME} "${L_CORPUS_PATH}\*.*"

  ; If the "corpus" directory does not exist then "${L_CFG_HANDLE}" will be empty

  StrCmp ${L_CFG_HANDLE} "" nothing_to_backup

  StrCpy ${L_CORPUS_SIZE} 0

  FindNext ${L_CFG_HANDLE} ${L_BUCKET_NAME}
  StrCmp ${L_BUCKET_NAME} ".." corpus_check
  StrCmp ${L_BUCKET_NAME} "" check_bucket_count got_bucket_name

  ; Now search through the corpus folder, looking for buckets

corpus_check:
  FindNext ${L_CFG_HANDLE} ${L_BUCKET_NAME}
  StrCmp ${L_BUCKET_NAME} "" check_bucket_count

got_bucket_name:

  IfFileExists "${L_CORPUS_PATH}\${L_BUCKET_NAME}\*.*" 0 corpus_check

  ; Have found a folder, so we make a note to make it easier to remove the folder after
  ; corpus conversion has been completed (folder will only be removed if it is empty)

  IntOp ${L_FOLDER_COUNT} ${L_FOLDER_COUNT} + 1
  WriteINIStr "$PLUGINSDIR\corpus.ini" "FolderList" "MaxNum" ${L_FOLDER_COUNT}
  WriteINIStr "$PLUGINSDIR\corpus.ini" "FolderList" \
              "Path-${L_FOLDER_COUNT}" "${L_CORPUS_PATH}\${L_BUCKET_NAME}"

  ; Assume what we've found is a bucket folder, now check if it contains
  ; a BerkeleyDB file or a flat-file corpus file. We make a list of all the
  ; buckets we find so we can later monitor the progress of the conversion process.
  ; If we find both types of corpus file in a particular bucket, we add both to the list.

  IfFileExists "${L_CORPUS_PATH}\${L_BUCKET_NAME}\table.db" bdb_bucket
  IfFileExists "${L_CORPUS_PATH}\${L_BUCKET_NAME}\table" flat_bucket
  Goto corpus_check

bdb_bucket:
  IntOp ${L_BUCKET_COUNT} ${L_BUCKET_COUNT} + 1
  WriteINIStr "$PLUGINSDIR\corpus.ini" "BucketList" "FileCount" ${L_BUCKET_COUNT}
  WriteINIStr "$PLUGINSDIR\corpus.ini" "Bucket-${L_BUCKET_COUNT}" "File_Name" \
                                       "${L_CORPUS_PATH}\${L_BUCKET_NAME}\table.db"
  Push "${L_CORPUS_PATH}\${L_BUCKET_NAME}\table.db"
  Call PFI_GetFileSize
  Pop ${L_TEMP}
  IntOp ${L_CORPUS_SIZE} ${L_CORPUS_SIZE} + ${L_TEMP}
  WriteINIStr "$PLUGINSDIR\corpus.ini" "Bucket-${L_BUCKET_COUNT}" "File_Size" "${L_TEMP}"
  WriteINIStr "$PLUGINSDIR\corpus.ini" "Bucket-${L_BUCKET_COUNT}" "Stop_Time" "0"
  WriteINIStr "$PLUGINSDIR\corpus.ini" "Bucket-${L_BUCKET_COUNT}" "ElapsTime" "0"

  IfFileExists "${L_CORPUS_PATH}\${L_BUCKET_NAME}\table" 0 corpus_check

flat_bucket:
  IntOp ${L_BUCKET_COUNT} ${L_BUCKET_COUNT} + 1
  WriteINIStr "$PLUGINSDIR\corpus.ini" "BucketList" "FileCount" ${L_BUCKET_COUNT}
  WriteINIStr "$PLUGINSDIR\corpus.ini" "Bucket-${L_BUCKET_COUNT}" "File_Name" \
                                       "${L_CORPUS_PATH}\${L_BUCKET_NAME}\table"
  Push "${L_CORPUS_PATH}\${L_BUCKET_NAME}\table"
  Call PFI_GetFileSize
  Pop ${L_TEMP}
  IntCmp ${L_TEMP} 3 valid_size 0 valid_size

  ; Very early versions of POPFile used an empty 'table' file to represent an empty bucket
  ; so we replace these files with an updated flat file version of an empty bucket to avoid
  ; problems when this flat file corpus is converted to the new SQL database format

  FileOpen ${L_TEMP} "${L_CORPUS_PATH}\${L_BUCKET_NAME}\table" w
  FileWrite ${L_TEMP} "__CORPUS__ __VERSION__ 1${MB_NL}"
  FileClose ${L_TEMP}
  StrCpy ${L_TEMP} 26

valid_size:
  IntOp ${L_CORPUS_SIZE} ${L_CORPUS_SIZE} + ${L_TEMP}
  WriteINIStr "$PLUGINSDIR\corpus.ini" "Bucket-${L_BUCKET_COUNT}" "File_Size" "${L_TEMP}"
  WriteINIStr "$PLUGINSDIR\corpus.ini" "Bucket-${L_BUCKET_COUNT}" "Stop_Time" "0"
  WriteINIStr "$PLUGINSDIR\corpus.ini" "Bucket-${L_BUCKET_COUNT}" "ElapsTime" "0"
  Goto corpus_check

check_bucket_count:
  WriteINIStr "$PLUGINSDIR\corpus.ini" "BucketList" "TotalSize" ${L_CORPUS_SIZE}
  FlushINI "$PLUGINSDIR\corpus.ini"
  StrCmp ${L_BUCKET_COUNT} 0 nothing_to_backup

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_CORPUS)"
  SetDetailsPrint listonly

  CreateDirectory "$G_USERDIR\backup\nonsql"
  CopyFiles "$G_USERDIR\popfile.cfg" "$G_USERDIR\backup\popfile.cfg"
  WriteINIStr "$G_USERDIR\backup\backup.ini" "NonSQLCorpus" "CorpusPath" "${L_CORPUS_PATH}"

  StrCpy ${L_TEMP} ${L_CORPUS_PATH}
  Push ${L_TEMP}
  Call PFI_GetParent
  Pop ${L_TEMP}
  WriteINIStr "$G_USERDIR\backup\backup.ini" "NonSQLCorpus" "ParentPath" "${L_TEMP}"
  StrLen ${L_TEMP} ${L_TEMP}
  IntOp ${L_TEMP} ${L_TEMP} + 1
  StrCpy ${L_TEMP} ${L_CORPUS_PATH} "" ${L_TEMP}
  WriteINIStr "$G_USERDIR\backup\backup.ini" "NonSQLCorpus" "BackupPath" "$G_USERDIR\backup\nonsql"

  ClearErrors
  CopyFiles /SILENT "${L_CORPUS_PATH}" "$G_USERDIR\backup\nonsql\"
  IfErrors 0 continue
  DetailPrint "Error detected when making corpus backup"
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(PFI_LANG_MBCORPUS_1)"

continue:
  WriteINIStr "$G_USERDIR\backup\backup.ini" "NonSQLCorpus" "Corpus" "${L_TEMP}"
  WriteINIStr "$G_USERDIR\backup\backup.ini" "NonSQLCorpus" "Status" "new"

  ; Extract the 'Monitor Corpus Conversion' utility (for use by the 'ConvertCorpus' function)

  File "/oname=$PLUGINSDIR\monitorcc.exe" "monitorcc.exe"

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_ENDSEC)"
  SetDetailsPrint listonly

nothing_to_backup:
  FindClose ${L_CFG_HANDLE}

exit:
  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_BE_PATIENT)"
  SetDetailsPrint listonly

  Pop ${L_TEMP}
  Pop ${L_FOLDER_COUNT}
  Pop ${L_CORPUS_SIZE}
  Pop ${L_CORPUS_PATH}
  Pop ${L_BUCKET_NAME}
  Pop ${L_BUCKET_COUNT}
  Pop ${L_CFG_HANDLE}

  !undef L_CFG_HANDLE
  !undef L_BUCKET_COUNT
  !undef L_BUCKET_NAME
  !undef L_CORPUS_PATH
  !undef L_CORPUS_SIZE
  !undef L_FOLDER_COUNT
  !undef L_TEMP

SectionEnd

#--------------------------------------------------------------------------
# Installer Section: UI Languages component (always 'installed')
#
# The installer will attempt to preset the POPFile UI
# language to match the language used for the installation. The 'UI_LANG_CONFIG' macro
# defines the mapping between NSIS language name and POPFile UI language name.
# The POPFile UI language is only preset if the required UI language file exists.
# If no match is found or if the UI language file does not exist, the default UI language
# is used (it is left to POPFile to determine which language to use).
#
# By the time this section is executed, the function 'CheckExistingConfigData' in conjunction
# with the processing performed in the "POPFile" section will have removed all UI language
# settings from 'popfile.cfg' so all we have to do is append the UI setting to the file. If we
# do not append anything, POPFile will choose the default language.
#--------------------------------------------------------------------------

Section "-Languages" SecLangs

  !define L_CFG   $R9   ; file handle
  !define L_LANG  $R8   ; language to be used for POPFile UI

  Push ${L_CFG}
  Push ${L_LANG}

  StrCpy ${L_LANG} ""     ; assume default POPFile UI language will be used.

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_LANGS)"
  SetDetailsPrint listonly

  ; There are several special cases: some UI languages are not yet supported by the
  ; installer, so if we are upgrading a system which was using one of these UI languages,
  ; we re-select it, provided the UI language file still exists.

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_LANG} "pfi-cfg.ini" "Inherited" "html_language"
  StrCmp ${L_LANG} "?" 0 use_inherited_lang
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_LANG} "pfi-cfg.ini" "Inherited" "language"
  StrCmp ${L_LANG} "?" use_installer_lang

use_inherited_lang:
  StrCmp ${L_LANG} "Chinese-Simplified-GB2312" special_case
  StrCmp ${L_LANG} "Chinese-Traditional-BIG5" special_case
  StrCmp ${L_LANG} "English-UK" special_case
  StrCmp ${L_LANG} "Hebrew" special_case
  StrCmp ${L_LANG} "Klingon" special_case
  Goto use_installer_lang

special_case:
  IfFileExists "$G_ROOTDIR\languages\${L_LANG}.msg" lang_save

use_installer_lang:

  ; Conditional compilation: if ENGLISH_MODE is defined, installer supports only 'English'
  ; so we use whatever UI language was defined in the existing 'popfile.cfg' file (if none
  ; found then we let POPFile use the default UI language)

  !ifndef ENGLISH_MODE

        ; UI_LANG_CONFIG parameters: "NSIS Language name"  "POPFile UI language name"
        ; (the order used here matches that used in the 'Language Selection' dropdown
        ; list displayed when the wizard is started)

        !insertmacro PFI_UI_LANG_CONFIG "ENGLISH" "English"
        !insertmacro PFI_UI_LANG_CONFIG "ARABIC" "Arabic"
        !insertmacro PFI_UI_LANG_CONFIG "BULGARIAN" "Bulgarian"
        !insertmacro PFI_UI_LANG_CONFIG "SIMPCHINESE" "Chinese-Simplified"
        !insertmacro PFI_UI_LANG_CONFIG "TRADCHINESE" "Chinese-Traditional"
        !insertmacro PFI_UI_LANG_CONFIG "CZECH" "Czech"
        !insertmacro PFI_UI_LANG_CONFIG "DANISH" "Dansk"
        !insertmacro PFI_UI_LANG_CONFIG "GERMAN" "Deutsch"
        !insertmacro PFI_UI_LANG_CONFIG "SPANISH" "Espanol"
        !insertmacro PFI_UI_LANG_CONFIG "FRENCH" "Francais"
        !insertmacro PFI_UI_LANG_CONFIG "GREEK" "Hellenic"
        !insertmacro PFI_UI_LANG_CONFIG "ITALIAN" "Italiano"
        !insertmacro PFI_UI_LANG_CONFIG "KOREAN" "Korean"
        !insertmacro PFI_UI_LANG_CONFIG "HUNGARIAN" "Hungarian"
        !insertmacro PFI_UI_LANG_CONFIG "DUTCH" "Nederlands"
        !insertmacro PFI_UI_LANG_CONFIG "JAPANESE" "Nihongo"
        !insertmacro PFI_UI_LANG_CONFIG "NORWEGIAN" "Norsk"
        !insertmacro PFI_UI_LANG_CONFIG "POLISH" "Polish"
        !insertmacro PFI_UI_LANG_CONFIG "PORTUGUESE" "Portugues"
        !insertmacro PFI_UI_LANG_CONFIG "PORTUGUESEBR" "Portugues do Brasil"
        !insertmacro PFI_UI_LANG_CONFIG "RUSSIAN" "Russian"
        !insertmacro PFI_UI_LANG_CONFIG "SLOVAK" "Slovak"
        !insertmacro PFI_UI_LANG_CONFIG "FINNISH" "Suomi"
        !insertmacro PFI_UI_LANG_CONFIG "SWEDISH" "Svenska"
        !insertmacro PFI_UI_LANG_CONFIG "TURKISH" "Turkce"
        !insertmacro PFI_UI_LANG_CONFIG "UKRAINIAN" "Ukrainian"

        ; at this point, no match was found so we use the default POPFile UI language
        ; (and leave it to POPFile to determine which language to use)
  !endif

  goto lang_done

lang_save:
  FileOpen  ${L_CFG} "$G_USERDIR\popfile.cfg" a
  FileSeek  ${L_CFG} 0 END
  FileWrite ${L_CFG} "html_language ${L_LANG}${MB_NL}"
  FileClose ${L_CFG}

lang_done:
  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_BE_PATIENT)"
  SetDetailsPrint listonly

  Pop ${L_LANG}
  Pop ${L_CFG}

  !undef L_CFG
  !undef L_LANG

SectionEnd

#--------------------------------------------------------------------------
# Installer Section: MakeBatchFile (always 'installed')
#
# Since we only create environment variables 'on the fly' on Win9x systems, this simple batch
# file is provided to make it easier to run POPFile from the command-line (e.g. to help debug
# problems).
#--------------------------------------------------------------------------

Section "-MakeBatchFile" SecMakeBatch

  !define L_FILEHANDLE      $R9
  !define L_POPFILE_ROOT    $R8
  !define L_POPFILE_USER    $R7
  !define L_TIMESTAMP       $R6

  Push ${L_FILEHANDLE}
  Push ${L_POPFILE_ROOT}
  Push ${L_POPFILE_USER}
  Push ${L_TIMESTAMP}

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_MAKEBAT)"
  SetDetailsPrint listonly

  Call PFI_GetDateTimeStamp
  Pop ${L_TIMESTAMP}

  ReadEnvStr ${L_POPFILE_ROOT} "POPFILE_ROOT"
  ReadEnvStr ${L_POPFILE_USER} "POPFILE_USER"

  SetFileAttributes "$G_USERDIR\pfi-run.bat" NORMAL
  FileOpen ${L_FILEHANDLE} "$G_USERDIR\pfi-run.bat" w

  FileWrite ${L_FILEHANDLE} "@echo off${MB_NL}"
  FileWrite ${L_FILEHANDLE} "${MB_NL}"
  FileWrite ${L_FILEHANDLE} "REM ---------------------------------------------------------------------${MB_NL}"
  FileWrite ${L_FILEHANDLE} "REM Simple batch file to run POPFile (for '$G_WINUSERNAME' user)${MB_NL}"
  FileWrite ${L_FILEHANDLE} "REM${MB_NL}"
  FileWrite ${L_FILEHANDLE} "REM Created by 'Add POPFile User' v${C_PFI_VERSION} on ${L_TIMESTAMP}${MB_NL}"
  FileWrite ${L_FILEHANDLE} "REM ---------------------------------------------------------------------${MB_NL}"
  FileWrite ${L_FILEHANDLE} "${MB_NL}"
  FileWrite ${L_FILEHANDLE} "REM POPFile program location = $G_ROOTDIR${MB_NL}"
  FileWrite ${L_FILEHANDLE} "${MB_NL}"
  FileWrite ${L_FILEHANDLE} "set POPFILE_ROOT=${L_POPFILE_ROOT}${MB_NL}"
  FileWrite ${L_FILEHANDLE} "${MB_NL}"
  FileWrite ${L_FILEHANDLE} "REM POPFile User Data folder = $G_USERDIR${MB_NL}"
  FileWrite ${L_FILEHANDLE} "${MB_NL}"
  FileWrite ${L_FILEHANDLE} "set POPFILE_USER=${L_POPFILE_USER}${MB_NL}"
  FileWrite ${L_FILEHANDLE} "${MB_NL}"
  FileWrite ${L_FILEHANDLE} "REM ---------------------------------------------------------------------${MB_NL}"
  FileWrite ${L_FILEHANDLE} "REM To run in 'Normal' mode, remove REM from the start of the next line${MB_NL}"
  FileWrite ${L_FILEHANDLE} "REM goto normal${MB_NL}"
  FileWrite ${L_FILEHANDLE} "REM ---------------------------------------------------------------------${MB_NL}"
  FileWrite ${L_FILEHANDLE} "${MB_NL}"
  FileWrite ${L_FILEHANDLE} "REM --------------------${MB_NL}"
  FileWrite ${L_FILEHANDLE} "REM Debug mode${MB_NL}"
  FileWrite ${L_FILEHANDLE} "REM --------------------${MB_NL}"
  FileWrite ${L_FILEHANDLE} "${MB_NL}"
  FileWrite ${L_FILEHANDLE} "if exist $\"%POPFILE_ROOT%\msgcapture.exe$\" goto msgcapture${MB_NL}"
  FileWrite ${L_FILEHANDLE} "if exist $\"%POPFILE_ROOT%\pfimsgcapture.exe$\" goto pfimsgcapture${MB_NL}"
  FileWrite ${L_FILEHANDLE} "${MB_NL}"
  FileWrite ${L_FILEHANDLE} "REM Debug command: Start POPFile in foreground using 'popfile.pl'${MB_NL}"
  FileWrite ${L_FILEHANDLE} "${MB_NL}"
  FileWrite ${L_FILEHANDLE} "$\"%POPFILE_ROOT%\perl.exe$\" $\"%POPFILE_ROOT%\popfile.pl$\" --verbose${MB_NL}"
  FileWrite ${L_FILEHANDLE} "goto exit${MB_NL}"
  FileWrite ${L_FILEHANDLE} "${MB_NL}"
  FileWrite ${L_FILEHANDLE} "REM Debug command: Start POPFile using the 'Message Capture' utility${MB_NL}"
  FileWrite ${L_FILEHANDLE} "${MB_NL}"
  FileWrite ${L_FILEHANDLE} ":msgcapture${MB_NL}"
  FileWrite ${L_FILEHANDLE} "$\"%POPFILE_ROOT%\msgcapture.exe$\" /TIMEOUT=0${MB_NL}"
  FileWrite ${L_FILEHANDLE} "goto exit${MB_NL}"
  FileWrite ${L_FILEHANDLE} "${MB_NL}"
  FileWrite ${L_FILEHANDLE} ":pfimsgcapture${MB_NL}"
  FileWrite ${L_FILEHANDLE} "$\"%POPFILE_ROOT%\pfimsgcapture.exe$\" /TIMEOUT=0${MB_NL}"
  FileWrite ${L_FILEHANDLE} "goto exit${MB_NL}"
  FileWrite ${L_FILEHANDLE} "${MB_NL}"
  FileWrite ${L_FILEHANDLE} "REM --------------------${MB_NL}"
  FileWrite ${L_FILEHANDLE} "REM Normal mode${MB_NL}"
  FileWrite ${L_FILEHANDLE} "REM --------------------${MB_NL}"
  FileWrite ${L_FILEHANDLE} "${MB_NL}"
  FileWrite ${L_FILEHANDLE} "REM Normal command: Start POPFile using the settings in 'popfile.cfg'${MB_NL}"
  FileWrite ${L_FILEHANDLE} "${MB_NL}"
  FileWrite ${L_FILEHANDLE} ":normal${MB_NL}"
  FileWrite ${L_FILEHANDLE} "$\"%POPFILE_ROOT%\popfile.exe$\"${MB_NL}"
  FileWrite ${L_FILEHANDLE} "${MB_NL}"
  FileWrite ${L_FILEHANDLE} "REM --------------------${MB_NL}"
  FileWrite ${L_FILEHANDLE} "REM Exit from batch file${MB_NL}"
  FileWrite ${L_FILEHANDLE} "REM --------------------${MB_NL}"
  FileWrite ${L_FILEHANDLE} "${MB_NL}"
  FileWrite ${L_FILEHANDLE} ":exit${MB_NL}"

  FileClose ${L_FILEHANDLE}

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_ENDSEC)"
  SetDetailsPrint listonly

  Pop ${L_TIMESTAMP}
  Pop ${L_POPFILE_USER}
  Pop ${L_POPFILE_ROOT}
  Pop ${L_FILEHANDLE}

  !undef L_FILEHANDLE
  !undef L_POPFILE_ROOT
  !undef L_POPFILE_USER
  !undef L_TIMESTAMP

SectionEnd

#--------------------------------------------------------------------------
# Installer Function: ChooseDefaultDataDir
# (the "leave" function for the WELCOME page)
#
# This function is used to choose a suitable initial value for the DIRECTORY page which allows
# the user to choose where their POPFile Configuration data is to be stored.
#--------------------------------------------------------------------------

Function ChooseDefaultDataDir

  !define  L_RESULT    $R9

  ; Starting with the 0.21.0 release, user-specific data is stored in the registry

  ReadRegStr $INSTDIR HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "UserDir_LFN"
  StrCmp $INSTDIR "" look_elsewhere
  IfFileExists "$INSTDIR\*.*" exit

look_elsewhere:

  ; All versions prior to 0.21.0 stored popfile.pl and popfile.cfg in the same folder

  StrCpy $INSTDIR "$G_ROOTDIR"
  IfFileExists "$INSTDIR\popfile.cfg" exit

  ; Check if we are installing over a version which uses an early alternative folder structure

  StrCpy $INSTDIR "$G_ROOTDIR\user"
  IfFileExists "$INSTDIR\popfile.cfg" exit

  ;----------------------------------------------------------------------
  ; Default location for POPFile User Data files (popfile.cfg and others)
  ;
  ; Windows 95 systems with Internet Explorer 4 installed also need to have
  ; Active Desktop installed, otherwise $APPDATA will not be available.
  ;----------------------------------------------------------------------

  StrCmp $APPDATA "" 0 appdata_valid
  StrCpy $INSTDIR "${C_ALT_DEFAULT_USERDATA}\$G_WINUSERNAME"
  Goto exit

appdata_valid:
  Push ${L_RESULT}

  StrCpy $INSTDIR "${C_STD_DEFAULT_USERDATA}"
  Push $INSTDIR
  Push $G_WINUSERNAME
  Call PFI_StrStr
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "" 0 default_locn_ok
  StrCpy $INSTDIR "$INSTDIR\$G_WINUSERNAME"

default_locn_ok:
  Pop ${L_RESULT}

exit:

  !undef L_RESULT

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: CheckUserDirStatus
# (the "pre" function for the User Data DIRECTORY selection page)
#
# This build of the installer is unable to relocate an existing set of user data, so if we
# find one during the PROGRAM installation (i.e. when we have been called from the 'setup.exe'
# installer), we ask for permission to upgrade the existing data. If permission is given, the
# normal DIRECTORY page which lets the user select where the 'User Data' is to be stored is not
# shown and we use the location of the existing user data instead.
#
# If upgrade permission is not given, we display the DIRECTORY page (suggesting the default
# location used for a 'clean' installation) to let the user choose where the new configuration
# data will be created.
#
# If the wizard is called directly (i.e. without either of the command-line switches used by
# the main 'setup.exe' installer) then the DIRECTORY page is not bypassed, to allow the user
# to discover the current 'User Data' location.
#--------------------------------------------------------------------------

Function CheckUserDirStatus

  !define L_RESULT    $R9

  Push ${L_RESULT}
  StrCpy ${L_RESULT} $G_PFISETUP 9
  StrCmp ${L_RESULT} "/restore=" restore_install
  Pop ${L_RESULT}

  IfFileExists "$INSTDIR\popfile.cfg" 0 exit
  StrCmp $G_PFISETUP "/install" upgrade_install
  StrCmp $G_PFISETUP "/installreboot" 0 exit

upgrade_install:
  GetDlgItem $G_DLGITEM $HWNDPARENT 1037
  SendMessage $G_DLGITEM ${WM_SETTEXT} 0 "STR:$(PFI_LANG_USERDIR_TITLE)"
  GetDlgItem $G_DLGITEM $HWNDPARENT 1038
  SendMessage $G_DLGITEM ${WM_SETTEXT} 0 "STR:$(PFI_LANG_USERDIR_SUBTITLE)"

  MessageBox MB_YESNO|MB_ICONQUESTION "$(PFI_LANG_DIRSELECT_MBWARN_3)\
      ${MB_NL}${MB_NL}\
      $INSTDIR\
      ${MB_NL}${MB_NL}${MB_NL}\
      $(PFI_LANG_DIRSELECT_MBWARN_2)" IDNO offer_default
  StrCpy $G_USERDIR $INSTDIR
  Call CheckExistingConfigData
  Abort

restore_install:
  GetDlgItem $G_DLGITEM $HWNDPARENT 1037
  SendMessage $G_DLGITEM ${WM_SETTEXT} 0 "STR:$(PFI_LANG_USERDIR_TITLE)"
  GetDlgItem $G_DLGITEM $HWNDPARENT 1038
  SendMessage $G_DLGITEM ${WM_SETTEXT} 0 "STR:$(PFI_LANG_USERDIR_SUBTITLE)"
  StrCpy $G_USERDIR $G_PFISETUP "" 9
  StrCpy ${L_RESULT} $G_USERDIR 1
  StrCmp ${L_RESULT} '"' 0 no_quotes
  StrCpy $G_USERDIR $G_USERDIR "" 1
  StrCpy $G_USERDIR $G_USERDIR -1

no_quotes:
  StrCpy ${L_RESULT} $G_USERDIR 1 -1
  StrCmp ${L_RESULT} "\" 0 check_config
  StrCpy $G_USERDIR $G_USERDIR -1

check_config:
  Pop ${L_RESULT}
  IfFileExists "$G_USERDIR\pfi-restore.log" 0 invalid_restore
  MessageBox MB_YESNO|MB_ICONQUESTION "$(PFI_LANG_DIRSELECT_MBWARN_4)\
      ${MB_NL}${MB_NL}\
      ($G_USERDIR)\
      ${MB_NL}${MB_NL}${MB_NL}\
      $(PFI_LANG_DIRSELECT_MBWARN_5)" IDNO quit_wizard
  Call CheckExistingConfigData
  Abort

invalid_restore:
  MessageBox MB_OK|MB_ICONSTOP "Error: No 'restore' data found at specified location !\
      ${MB_NL}${MB_NL}\
      ($G_USERDIR)"

quit_wizard:
  Quit

offer_default:
  StrCmp $APPDATA "" 0 appdata_valid
  StrCpy $INSTDIR "${C_ALT_DEFAULT_USERDATA}\$G_WINUSERNAME"
  Goto exit

appdata_valid:
  Push ${L_RESULT}

  StrCpy $INSTDIR "${C_STD_DEFAULT_USERDATA}"
  Push $INSTDIR
  Push $G_WINUSERNAME
  Call PFI_StrStr
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "" 0 default_locn_ok
  StrCpy $INSTDIR "$INSTDIR\$G_WINUSERNAME"

default_locn_ok:
  Pop ${L_RESULT}

exit:

  ; Display the User Data DIRECTORY page

  !undef L_RESULT

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: CheckExistingDataDir
# (the "leave" function for the DIRECTORY page)
#
# Now that we are overriding the default InstallDir behaviour, we really need to check
# that the main 'Program Files' folder has not been selected for the 'User Data' folder.
#
# POPFile currently does not support paths containing spaces in POPFILE_ROOT and POPFILE_USER
# so we use the short file name format for these two environment variables. However some
# installations may not support short file names, so the wizard checks if the main installer
# (setup.exe) was configured to use short file names. If short file names are not being used,
# we must reject any path which contains spaces.
#--------------------------------------------------------------------------

Function CheckExistingDataDir

  !define L_RESULT    $R9

  Push ${L_RESULT}

  ; Strip trailing slashes (if any) from the path selected by the user

  Push $INSTDIR
  Pop $INSTDIR
  StrCpy $G_USERDIR "$INSTDIR"

  ; We do not permit POPFile 'User Data' to be in the main 'Program Files' folder
  ; (i.e. we do not allow 'popfile.cfg' etc to be stored there)

  StrCmp $G_USERDIR "$PROGRAMFILES" return_to_directory_selection

  ; Assume SFN support is enabled (the default setting for Windows)

  StrCpy $G_SFN_DISABLED "0"

  Push $G_USERDIR
  Call PFI_GetSFNStatus
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "1" check_SFN_PROGRAMFILES
  StrCpy $G_SFN_DISABLED "1"

  ; Short file names are not supported here, so we cannot accept any path containing spaces.

  Push $G_USERDIR
  Push ' '
  Call PFI_StrStr
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "" check_locn
  Push $G_USERDIR
  Call PFI_GetRoot
  Pop $G_PLS_FIELD_1
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(PFI_LANG_DIRSELECT_MBNOSFN)"

return_to_directory_selection:
  Pop ${L_RESULT}
  Abort

check_SFN_PROGRAMFILES:
  GetFullPathName /SHORT ${L_RESULT} "$PROGRAMFILES"
  StrCmp $G_USERDIR "${L_RESULT}" return_to_directory_selection

check_locn:

  ; We always try to use the LFN format, even if the user has entered a SFN format path

  Push $G_USERDIR
  Call PFI_GetCompleteFPN
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "" got_path
  StrCpy $G_USERDIR ${L_RESULT}

got_path:
  Pop ${L_RESULT}

  ; Warn the user if we are about to upgrade an existing installation
  ; and allow user to select a different directory if they wish

  IfFileExists "$G_USERDIR\popfile.cfg" 0 continue
  MessageBox MB_YESNO|MB_ICONQUESTION "$(PFI_LANG_DIRSELECT_MBWARN_3)\
      ${MB_NL}${MB_NL}\
      $G_USERDIR\
      ${MB_NL}${MB_NL}${MB_NL}\
      $(PFI_LANG_DIRSELECT_MBWARN_2)" IDYES continue

  ; We are returning to the DIRECTORY page

  Abort

continue:
  Call CheckExistingConfigData

  !undef L_RESULT

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: CheckExistingConfigData
#
# This function is used to extract the POP3 and UI ports from the 'popfile.cfg'
# configuration file (if a copy is found when the wizard starts up).
#
# As it is possible that there are multiple entries for these parameters in the file,
# this function removes them all as it makes a new copy of the file. New port data
# entries will be added to this copy and the original updated (and backed up) when
# the "POPFile" section of the installer is executed.
#
# If the user has selected the optional 'Languages' component then this function also strips
# out the POPFile UI language setting to allow the installer to easily preset the UI language
# to match the language selected for use by the installer. (See the code which handles the
# 'Languages' component for further details). A copy of any settings found is kept in the
# 'pfi-cfg.ini' file for later use in the 'Languages' section.
#
# This function also ensures that only one copy of the tray icon & console settings is present,
# and saves (in 'pfi-cfg.ini') any values found for use when the user is offered the chance
# to start POPFile from the installer. If no setting is found, we save '?' in 'pfi-cfg.ini'.
# These settings are used by the 'StartPOPFilePage' and 'CheckLaunchOptions' functions.
#
# The 0.22.0 release introduced a new template-based skin system. Although the new system
# uses the same skin names as in earlier releases, these names are now in lowercase. The UI
# is case-sensitive so we have to convert the skin name to lowercase otherwise the current
# skin will not be shown in the Configuration page of the UI (the UI will show the first entry
# in the list ("blue") instead of the skin currently in use).
#--------------------------------------------------------------------------

Function CheckExistingConfigData

  !define L_CFG       $R9     ; handle for "popfile.cfg"
  !define L_CLEANCFG  $R8     ; handle for "clean" copy
  !define L_CMPRE     $R7     ; config param name
  !define L_LNE       $R6     ; a line from popfile.cfg
  !define L_OLDUI     $R5     ; used to hold old-style of GUI port
  !define L_TRAYICON  $R4     ; a config parameter used by popfile.exe
  !define L_CONSOLE   $R3     ; a config parameter used by popfile.exe
  !define L_LANG_NEW  $R2     ; new style UI lang parameter
  !define L_LANG_OLD  $R1     ; old style UI lang parameter
  !define L_TEXTEND   $R0     ; used to ensure correct handling of lines longer than 1023 chars
  !define L_SKIN      $9      ; current skin setting

  Push ${L_CFG}
  Push ${L_CLEANCFG}
  Push ${L_CMPRE}
  Push ${L_LNE}
  Push ${L_OLDUI}
  Push ${L_TRAYICON}
  Push ${L_CONSOLE}
  Push ${L_LANG_NEW}
  Push ${L_LANG_OLD}
  Push ${L_TEXTEND}
  Push ${L_SKIN}

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

  FileOpen  ${L_CFG} "$G_USERDIR\popfile.cfg" r
  FileOpen  ${L_CLEANCFG} "$PLUGINSDIR\popfile.cfg" w

found_eol:
  StrCpy ${L_TEXTEND} "<eol>"

loop:
  FileRead ${L_CFG} ${L_LNE}
  StrCmp ${L_LNE} "" done
  StrCmp ${L_TEXTEND} "<eol>" 0 copy_lne
  StrCmp ${L_LNE} "$\n" copy_lne

  StrCpy ${L_CMPRE} ${L_LNE} 5
  StrCmp ${L_CMPRE} "port " got_port
  StrCmp ${L_CMPRE} "skin " got_skin_old

  StrCpy ${L_CMPRE} ${L_LNE} 10
  StrCmp ${L_CMPRE} "pop3_port " got_pop3_port
  StrCmp ${L_CMPRE} "html_port " got_html_port
  StrCmp ${L_CMPRE} "html_skin " got_skin_new

  StrCpy ${L_CMPRE} ${L_LNE} 8
  StrCmp ${L_CMPRE} "ui_port " got_ui_port

  StrCpy ${L_CMPRE} ${L_LNE} 17
  StrCmp ${L_CMPRE} "windows_trayicon " got_trayicon
  StrCpy ${L_CMPRE} ${L_LNE} 16
  StrCmp ${L_CMPRE} "windows_console " got_console

  ; do not transfer any UI language settings to the copy of popfile.cfg

  StrCpy ${L_CMPRE} ${L_LNE} 9
  StrCmp ${L_CMPRE} "language " got_lang_old
  StrCpy ${L_CMPRE} ${L_LNE} 14
  StrCmp ${L_CMPRE} "html_language " got_lang_new copy_lne

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

got_skin_old:
  StrCpy ${L_SKIN} ${L_LNE} "" 5
  Goto got_skin

got_skin_new:
  StrCpy ${L_SKIN} ${L_LNE} "" 10

got_skin:
  Push ${L_SKIN}
  Call PFI_TrimNewlines
  Pop ${L_SKIN}

  !insertmacro PFI_SkinCaseChange "CoolBlue"       "coolblue"
  !insertmacro PFI_SkinCaseChange "CoolBrown"      "coolbrown"
  !insertmacro PFI_SkinCaseChange "CoolGreen"      "coolgreen"
  !insertmacro PFI_SkinCaseChange "CoolOrange"     "coolorange"
  !insertmacro PFI_SkinCaseChange "CoolYellow"     "coolyellow"
  !insertmacro PFI_SkinCaseChange "Lavish"         "lavish"
  !insertmacro PFI_SkinCaseChange "LRCLaptop"      "lrclaptop"
  !insertmacro PFI_SkinCaseChange "orangeCream"    "orangecream"
  !insertmacro PFI_SkinCaseChange "PRJBlueGrey"    "prjbluegrey"
  !insertmacro PFI_SkinCaseChange "PRJSteelBeach"  "prjsteelbeach"
  !insertmacro PFI_SkinCaseChange "SimplyBlue"     "simplyblue"
  !insertmacro PFI_SkinCaseChange "Sleet"          "sleet"
  !insertmacro PFI_SkinCaseChange "Sleet-RTL"      "sleet-rtl"
  !insertmacro PFI_SkinCaseChange "StrawberryRose" "strawberryrose"

save_skin_setting:
  StrCpy ${L_LNE} "${L_CMPRE}${L_SKIN}${MB_NL}"

copy_lne:
  FileWrite ${L_CLEANCFG} ${L_LNE}

  ; Now read file until we get to end of the current line
  ; (i.e. until we find text ending in <CR><LF>, <CR> or <LF>)

  StrCpy ${L_TEXTEND} ${L_LNE} 1 -1
  StrCmp ${L_TEXTEND} "$\n" found_eol
  StrCmp ${L_TEXTEND} "$\r" found_eol loop

done:
  FileClose ${L_CFG}

  ; Ensure the 'clean copy' ends with end-of-line terminator so we can safely append data to it

  StrCmp ${L_TEXTEND} "<eol>" add_to_the_copy
  FileWrite ${L_CLEANCFG} "${MB_NL}"

add_to_the_copy:

  ; Before closing the clean copy of 'popfile.cfg' we add the most recent settings for the
  ; system tray icon and console mode, if valid values were found. If no valid values were
  ; found, we add nothing to the clean copy. A record of our findings is stored in the file
  ; 'pfi-cfg.ini' for later use by 'StartPOPFilePage' and 'CheckLaunchOptions'.

  StrCmp ${L_CONSOLE} "0" found_console
  StrCmp ${L_CONSOLE} "1" found_console
  !insertmacro MUI_INSTALLOPTIONS_WRITE "pfi-cfg.ini" "Inherited" "Console" "?"
  Goto check_trayicon

found_console:
  FileWrite ${L_CLEANCFG} "windows_console ${L_CONSOLE}${MB_NL}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "pfi-cfg.ini" "Inherited" "Console" "${L_CONSOLE}"

check_trayicon:
  StrCmp ${L_TRAYICON} "0" found_trayicon
  StrCmp ${L_TRAYICON} "1" found_trayicon
  !insertmacro MUI_INSTALLOPTIONS_WRITE "pfi-cfg.ini" "Inherited" "TrayIcon" "?"
  Goto close_cleancopy

found_trayicon:
  FileWrite ${L_CLEANCFG} "windows_trayicon ${L_TRAYICON}${MB_NL}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "pfi-cfg.ini" "Inherited" "TrayIcon" "${L_TRAYICON}"

close_cleancopy:
  FileClose ${L_CLEANCFG}

  ; We save the UI language settings for later use when the 'Languages' section is processed
  ; (if no settings were found, we save '?'). If 'Languages' component is not selected, these
  ; saved settings will not be used (any existing settings were copied to the new 'popfile.cfg')

  Push ${L_LANG_NEW}
  Call PFI_TrimNewlines
  Pop ${L_LANG_NEW}
  StrCmp ${L_LANG_NEW} "" 0 check_lang_old
  StrCpy ${L_LANG_NEW} "?"

check_lang_old:
  Push ${L_LANG_OLD}
  Call PFI_TrimNewlines
  Pop ${L_LANG_OLD}
  StrCmp ${L_LANG_OLD} "" 0 save_langs
  StrCpy ${L_LANG_OLD} "?"

save_langs:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "pfi-cfg.ini" "Inherited" "html_language" "${L_LANG_NEW}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "pfi-cfg.ini" "Inherited" "language" "${L_LANG_OLD}"

  Push $G_POP3
  Call PFI_TrimNewlines
  Pop $G_POP3

  Push $G_GUI
  Call PFI_TrimNewlines
  Pop $G_GUI

  Push ${L_OLDUI}
  Call PFI_TrimNewlines
  Pop ${L_OLDUI}

  ; Save the UI port settings (from popfile.cfg) for later use by the 'MakeUserDirSafe' function

  !insertmacro MUI_INSTALLOPTIONS_WRITE "pfi-cfg.ini" "Inherited" "NewStyleUI" "$G_GUI"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "pfi-cfg.ini" "Inherited" "OldStyleUI" "${L_OLDUI}"

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
  Call PFI_StrCheckDecimal
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
  Call PFI_StrCheckDecimal
  Pop $G_GUI
  StrCmp $G_GUI "" default_gui
  IntCmp $G_GUI 1 ports_ok default_gui
  IntCmp $G_GUI 65535 ports_ok ports_ok

default_gui:
  StrCpy $G_GUI "8080"
  StrCmp $G_POP3 $G_GUI 0 ports_ok
  StrCpy $G_GUI "8081"

ports_ok:
  Pop ${L_SKIN}
  Pop ${L_TEXTEND}
  Pop ${L_LANG_OLD}
  Pop ${L_LANG_NEW}
  Pop ${L_CONSOLE}
  Pop ${L_TRAYICON}
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
  !undef L_TRAYICON
  !undef L_CONSOLE
  !undef L_LANG_NEW
  !undef L_LANG_OLD
  !undef L_TEXTEND
  !undef L_SKIN

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
# This function loads the validated values into $G_POP3 and $G_GUI and also
# sets $G_PFIFLAG to the state of the 'Run POPFile at Windows startup' checkbox
#
# A "leave" function (CheckPortOptions) is used to validate the port
# selections made by the user.
#--------------------------------------------------------------------------

Function SetOptionsPage

  !define L_PORTLIST  $R9   ; combo box ports list
  !define L_RESULT    $R8

  Push ${L_PORTLIST}
  Push ${L_RESULT}

  ; The function 'CheckExistingConfigData' loads $G_POP3 and $G_GUI with the settings found in
  ; a previously installed "popfile.cfg" file or if no such file is found, it loads the
  ; POPFile default values. Now we display these settings and allow the user to change them.

  ; The POP3 and GUI port numbers must be in the range 1 to 65535 inclusive, and they
  ; must be different. This function assumes that the values loaded by 'CheckExistingConfigData'
  ; into $G_POP3 and $G_GUI are valid.

  !insertmacro MUI_HEADER_TEXT "$(PFI_LANG_OPTIONS_TITLE)" "$(PFI_LANG_OPTIONS_SUBTITLE)"

  ; If the POP3 (or GUI) port determined by 'CheckExistingConfigData' is not present in the
  ; list of possible values for the POP3 (or GUI) combobox, add it to the end of the list.

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_PORTLIST} "ioA.ini" "Field 2" "ListItems"
  Push "|${L_PORTLIST}|"
  Push "|$G_POP3|"
  Call PFI_StrStr
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "" 0 POP3_is_in_list
  StrCpy ${L_PORTLIST} "${L_PORTLIST}|$G_POP3"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioA.ini" "Field 2" "ListItems" ${L_PORTLIST}

POP3_is_in_list:
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_PORTLIST} "ioA.ini" "Field 4" "ListItems"
  Push "|${L_PORTLIST}|"
  Push "|$G_GUI|"
  Call PFI_StrStr
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "" 0 GUI_is_in_list
  StrCpy ${L_PORTLIST} "${L_PORTLIST}|$G_GUI"
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

  !insertmacro MUI_INSTALLOPTIONS_INITDIALOG "ioA.ini"
  Pop $G_HWND                 ; HWND of dialog we want to modify

  !ifndef ENGLISH_MODE

    ; Do not attempt to display "bold" text when using Chinese, Japanese or Korean

    StrCmp $LANGUAGE ${LANG_SIMPCHINESE} button_text
    StrCmp $LANGUAGE ${LANG_TRADCHINESE} button_text
    StrCmp $LANGUAGE ${LANG_JAPANESE} button_text
    StrCmp $LANGUAGE ${LANG_KOREAN} button_text
  !endif

  ; In 'GetDlgItem', use (1200 + Field number - 1) to refer to the field to be changed

  GetDlgItem $G_DLGITEM $G_HWND 1204            ; Field 5 = 'Run POPFile at startup' checkbox
  CreateFont $G_FONT "MS Shell Dlg" 10 700      ; use larger & bolder version of the font in use
  SendMessage $G_DLGITEM ${WM_SETFONT} $G_FONT 0

  !ifndef ENGLISH_MODE
    button_text:
  !endif

  ; If we are about to upgrade an existing installation or reset POPFile to use newly restored
  ; 'User Data', remind the user by changing the text on the "Install" button to "Upgrade" or
  ; "Restore" as appropriate

  StrCpy ${L_RESULT} $G_PFISETUP 9
  StrCmp ${L_RESULT} "/restore=" restore

  IfFileExists "$G_USERDIR\popfile.cfg" upgrade
  GetDlgItem $G_DLGITEM $HWNDPARENT 1           ; "Next" button, also used for "Install"
  SendMessage $G_DLGITEM ${WM_SETTEXT} 0 "STR:$(^InstallBtn)"
  Goto showpage

restore:
  GetDlgItem $G_DLGITEM $HWNDPARENT 1           ; "Next" button, also used for "Install"
  SendMessage $G_DLGITEM ${WM_SETTEXT} 0 "STR:$(PFI_LANG_INST_BTN_RESTORE)"
  Goto showpage

upgrade:
  GetDlgItem $G_DLGITEM $HWNDPARENT 1           ; "Next" button, also used for "Install"
  SendMessage $G_DLGITEM ${WM_SETTEXT} 0 "STR:$(PFI_LANG_INST_BTN_UPGRADE)"

showpage:
  !insertmacro MUI_INSTALLOPTIONS_SHOW

  ; Store validated data (for completeness)

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioA.ini" "Field 2" "State" $G_POP3
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioA.ini" "Field 4" "State" $G_GUI

  ; Retrieve the state of the 'Run POPFile automatically when Windows starts' checkbox

  !insertmacro MUI_INSTALLOPTIONS_READ $G_PFIFLAG "ioA.ini" "Field 5" "State"

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
  Call PFI_StrStripLZS
  Pop $G_POP3
  Push $G_GUI
  Call PFI_StrStripLZS
  Pop $G_GUI

  StrCmp $G_POP3 $G_GUI ports_must_differ
  Push $G_POP3
  Call PFI_StrCheckDecimal
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "" bad_pop3
  IntCmp $G_POP3 1 pop3_ok bad_pop3
  IntCmp $G_POP3 65535 pop3_ok pop3_ok

bad_pop3:
  MessageBox MB_OK|MB_ICONEXCLAMATION \
      "$(PFI_LANG_OPTIONS_MBPOP3_A)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_OPTIONS_MBPOP3_B)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_OPTIONS_MBPOP3_C)"
  Goto bad_exit

pop3_ok:
  Push $G_GUI
  Call PFI_StrCheckDecimal
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "" bad_gui
  IntCmp $G_GUI 1 good_exit bad_gui
  IntCmp $G_GUI 65535 good_exit good_exit

bad_gui:
  MessageBox MB_OK|MB_ICONEXCLAMATION \
      "$(PFI_LANG_OPTIONS_MBGUI_A)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_OPTIONS_MBGUI_B)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_OPTIONS_MBGUI_C)"
  Goto bad_exit

ports_must_differ:
  MessageBox MB_OK|MB_ICONEXCLAMATION \
      "$(PFI_LANG_OPTIONS_MBDIFF_1)\
      ${MB_NL}${MB_NL}\
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
# Installer Function: MakeUserDirSafe
#
# If we are installing on top of a previous installation, we try to shut it down
# (to allow the files to be overwritten without requiring a reboot)
#--------------------------------------------------------------------------

Function MakeUserDirSafe

  StrCmp $G_PFISETUP "/install" nothing_to_check
  StrCmp $G_PFISETUP "/installreboot" nothing_to_check
  IfFileExists "$G_USERDIR\popfile.cfg" 0 nothing_to_check

  !define L_GUI_PORT  $R9
  !define L_RESULT    $R8

  Push ${L_GUI_PORT}
  Push ${L_RESULT}

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_UPGRADE)"
  SetDetailsPrint listonly

  ; Starting with POPfile 0.21.0 an experimental version of 'popfile-service.exe' was included
  ; to allow POPFile to be run as a Windows service.

  Push "POPFile"
  Call PFI_ServiceRunning
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "true" manual_shutdown

  ; Using 'FindLockedPFE' is a temporary solution (until popfile.pid's location is "inherited")
  ; (could check popfile.db instead but we currently assume the default location for it too)

  Push $G_ROOTDIR
  Call PFI_FindLockedPFE
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "" exit_now

  ; If we are upgrading an existing installation then 'CheckExistingConfigData' will have
  ; extracted the GUI port parameters from the existing popfile.cfg file

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_GUI_PORT} "pfi-cfg.ini" "Inherited" "NewStyleUI"
  StrCmp ${L_GUI_PORT} "" try_old_style
  DetailPrint "$(PFI_LANG_INST_LOG_SHUTDOWN) ${L_GUI_PORT} [new style port]"
  DetailPrint "$(PFI_LANG_TAKE_A_FEW_SECONDS)"
  Push ${L_GUI_PORT}
  Call PFI_ShutdownViaUI
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "success" exit_now
  StrCmp ${L_RESULT} "password?" manual_shutdown

try_old_style:
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_GUI_PORT} "pfi-cfg.ini" "Inherited" "OldStyleUI"
  StrCmp ${L_GUI_PORT} "" manual_shutdown
  DetailPrint "$(PFI_LANG_INST_LOG_SHUTDOWN) ${L_GUI_PORT} [old style port]"
  DetailPrint "$(PFI_LANG_TAKE_A_FEW_SECONDS)"
  Push ${L_GUI_PORT}
  Call PFI_ShutdownViaUI
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "success" exit_now

manual_shutdown:
  StrCpy $G_PLS_FIELD_1 "POPFile"
  DetailPrint "Unable to shutdown $G_PLS_FIELD_1 automatically - manual intervention requested"
  MessageBox MB_OK|MB_ICONEXCLAMATION|MB_TOPMOST "$(PFI_LANG_MBMANSHUT_1)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_MBMANSHUT_2)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_MBMANSHUT_3)"

exit_now:
  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

  Pop ${L_RESULT}
  Pop ${L_GUI_PORT}

  !undef L_GUI_PORT
  !undef L_RESULT

nothing_to_check:
FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: CompareStopwords
#
# Check if 'our' default stopwords list ($G_ROOTDIR\pfi-stopwords.default) is the
# same as the one used by the installation we are upgrading ($G_USERDIR\stopwords).
# These lists may use CRLF or LF as the end-of-line marker so file size is not tested.
# Return "same" or "different" result string.
#
# It is assumed that there are no blank lines in the 'stopwords' files.
#--------------------------------------------------------------------------

Function CompareStopwords

  !define L_STD_FILE    $R9   ; handle used to access 'our' default stopwords list
  !define L_STD_WORD    $R8
  !define L_USR_FILE    $R7   ; handle used to access existing installation's stopwords list
  !define L_USR_WORD    $R6
  !define L_RESULT      $R5

  !define C_STD_LIST    "$G_ROOTDIR\pfi-stopwords.default"
  !define C_USR_LIST    "$G_USERDIR\stopwords"

  Push ${L_RESULT}
  Push ${L_STD_FILE}
  Push ${L_STD_WORD}
  Push ${L_USR_FILE}
  Push ${L_USR_WORD}

  StrCpy ${L_RESULT}  "different"

  FileOpen ${L_STD_FILE} "${C_STD_LIST}" r
  FileOpen ${L_USR_FILE} "${C_USR_LIST}" r

loop:
  FileRead ${L_STD_FILE} ${L_STD_WORD}
  Push ${L_STD_WORD}
  Call PFI_TrimNewlines
  Pop ${L_STD_WORD}
  FileRead ${L_USR_FILE} ${L_USR_WORD}
  Push ${L_USR_WORD}
  Call PFI_TrimNewlines
  Pop ${L_USR_WORD}
  StrCmp ${L_STD_WORD} ${L_USR_WORD} 0 close_files
  StrCmp ${L_STD_WORD} "" 0 loop
  StrCpy ${L_RESULT} "same"

close_files:
  FileClose ${L_STD_FILE}
  FileClose ${L_USR_FILE}

  Pop ${L_USR_WORD}
  Pop ${L_USR_FILE}
  Pop ${L_STD_WORD}
  Pop ${L_STD_FILE}
  Exch ${L_RESULT}

  !undef C_STD_LIST
  !undef C_USR_LIST

  !undef L_STD_FILE
  !undef L_STD_WORD
  !undef L_USR_FILE
  !undef L_USR_WORD
  !undef L_RESULT

FunctionEnd


#==========================================================================
#==========================================================================
#  A separate file contains the custom page and other functions used when
#  offering to reconfigure email accounts (Outlook Express, Outlook and
#  Eudora are supported in this version of the 'Add POPFile User' wizard)
#==========================================================================
#==========================================================================

  !include "adduser-EmailConfig.nsh"

#==========================================================================
#==========================================================================


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
  !insertmacro PFI_IO_TEXT "ioC.ini" "3" "$(PFI_LANG_LAUNCH_IO_NOICON)"
  !insertmacro PFI_IO_TEXT "ioC.ini" "4" "$(PFI_LANG_LAUNCH_IO_TRAYICON)"

  !insertmacro PFI_IO_TEXT "ioC.ini" "6" "$(PFI_LANG_LAUNCH_IO_NOTE_1)"
  !insertmacro PFI_IO_TEXT "ioC.ini" "7" "$(PFI_LANG_LAUNCH_IO_NOTE_2)"
  !insertmacro PFI_IO_TEXT "ioC.ini" "8" "$(PFI_LANG_LAUNCH_IO_NOTE_3)"

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: CheckCorpusUpgradeStatus (acts as a "pre" function for 'StartPOPFilePage')
#
# There are some special cases where the installer starts POPFile to update the existing data:
#
# POPFile automatically convert an existing  flat-file or BerkeleyDB format corpus to the new
# SQL database format. This corpus conversion may take several minutes, during which time the
# POPFile UI will appear to have "locked up" so we use the "Corpus Conversion Monitor" to show
# some progress messages.
#
# Automatic SQL database upgrades occur when POPFile detects that the current database uses an
# out-of-date schema. These upgrades can take several minutes and during this time POPFile will
# appear to be locked up. If the installer has detected that an automatic upgrade is required,
# it will always start POPFile using the "Message Capture" utility to display the upgrade
# progress messages output by POPFile.
#
# When corpus conversion or a database upgrade is to be performed, the user is not allowed to
# prevent the installer from starting POPFile (this is achieved by disabling the "No, do not
# start POPFile" radiobutton on the "start POPFile" page)
#--------------------------------------------------------------------------

Function CheckCorpusUpgradeStatus

  !define L_POPFILE_SCHEMA    $R9   ; database schema version used by newly installed POPFile
  !define L_SQL_DB            $R8
  !define L_SQLITE_SCHEMA     $R7   ; database schema version used by existing SQLite database
                                    ; or the previous POPFile schema version if SQLite not used
  !define L_TEMP              $R6

  Push ${L_POPFILE_SCHEMA}
  Push ${L_SQL_DB}
  Push ${L_SQLITE_SCHEMA}
  Push ${L_TEMP}

  ; This pseudo "pre" function for 'StartPOPFilePage' may take a few seconds so we tell the
  ; user about this delay and disable the "Back", Next" and "Cancel" buttons (normal operation
  ; will be restored by 'StartPOPFilePage')

  GetDlgItem $G_DLGITEM $HWNDPARENT 1037  ; Header Title Text
  SendMessage $G_DLGITEM ${WM_SETTEXT} 0 "STR:$(PFI_LANG_BE_PATIENT)"
  GetDlgItem $G_DLGITEM $HWNDPARENT 1038  ; Header SubTitle Text
  SendMessage $G_DLGITEM ${WM_SETTEXT} 0 "STR:$(PFI_LANG_TAKE_A_FEW_SECONDS)"
  GetDlgItem $G_DLGITEM $HWNDPARENT 3     ; "Back" button
  EnableWindow $G_DLGITEM 0
  GetDlgItem $G_DLGITEM $HWNDPARENT 1     ; "Next" button
  EnableWindow $G_DLGITEM 0
  GetDlgItem $G_DLGITEM $HWNDPARENT 2     ; "Cancel" button
  EnableWindow $G_DLGITEM 0

  ; If corpus conversion (from flat file or BerkeleyDB format) is required, we will start
  ; POPFile from the installer so we can use the "Corpus Conversion Monitor" to display
  ; some progress reports.

  ReadINIStr ${L_TEMP} "$G_USERDIR\backup\backup.ini" "NonSQLCorpus" "Status"
  StrCmp ${L_TEMP} "new" disable_the_NO_button

  ; If we have made a backup copy of the SQLite database, we will start POPFile from the
  ; installer so we can use the "Message Capture" utility to display the progress reports.

  ReadINIStr ${L_TEMP} "$G_USERDIR\backup\backup.ini" "OldSQLdatabase" "Status"
  StrCmp ${L_TEMP} "new" disable_the_NO_button

  ; If the POPFile database schema has changed then POPFile will perform an automatic upgrade
  ; of the database which could take several minutes, so we use the 'Message Capture' utility
  ; to display the conversion progress reports. For SQLite databases we can query the database
  ; directly, for non-SQLite databases we simply detect a change in the schema file version.

  Push $G_USERDIR
  Call PFI_GetSQLdbPathName
  Pop ${L_SQL_DB}
  StrCmp ${L_SQL_DB} "" exit

  Push "$G_ROOTDIR\Classifier\popfile.sql"
  Call PFI_GetPOPFileSchemaVersion
  Pop ${L_POPFILE_SCHEMA}
  StrCpy ${L_TEMP} ${L_POPFILE_SCHEMA} 1
  StrCmp ${L_TEMP} "(" 0 got_popfile_schema
  StrCpy ${L_POPFILE_SCHEMA} "0"

got_popfile_schema:
  StrCmp ${L_SQL_DB} "Not SQLite" 0 get_sqlite_schema
  ReadINIStr ${L_SQLITE_SCHEMA} "$G_USERDIR\install.ini" "Settings" "SQLSV"
  StrCmp ${L_SQLITE_SCHEMA} "" 0 got_schemas
  ReadINIStr ${L_SQLITE_SCHEMA} "$G_ROOTDIR\pfi-data.ini" "Settings" "OldSchema"
  StrCmp ${L_SQLITE_SCHEMA} "" exit got_schemas

get_sqlite_schema:
  Push ${L_SQL_DB}
  Call PFI_GetSQLiteSchemaVersion
  Pop ${L_SQLITE_SCHEMA}
  StrCpy ${L_TEMP} ${L_SQLITE_SCHEMA} 1
  StrCmp ${L_TEMP} "(" 0 got_schemas
  StrCpy ${L_SQLITE_SCHEMA} "0"

got_schemas:
  IntCmp ${L_POPFILE_SCHEMA} ${L_SQLITE_SCHEMA} exit

disable_the_NO_button:

  ; The installer will start POPFile so we can display corpus conversion or database upgrade
  ; messages which are normally hidden. Therefore we disable the radio button option which
  ; allows the user to stop the installer from starting POPFile

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 2" "Flags" "DISABLED"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 2" "State" "0"   ; 'do not start'
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 3" "State" "0"   ; 'disable tray icon'
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 4" "State" "0"   ; 'enable tray icon'

  ; If we are upgrading use the same system tray icon setting as the old installation,
  ; otherwise use the default setting (system tray icon enabled)

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "pfi-cfg.ini" "Inherited" "TrayIcon"
  StrCmp ${L_TEMP} "0" disable_tray_icon
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 4" "State" "1"
  Goto exit

disable_tray_icon:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 3" "State" "1"

exit:
  Pop ${L_TEMP}
  Pop ${L_SQLITE_SCHEMA}
  Pop ${L_SQL_DB}
  Pop ${L_POPFILE_SCHEMA}

  !undef L_POPFILE_SCHEMA
  !undef L_SQL_DB
  !undef L_SQLITE_SCHEMA
  !undef L_TEMP

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: StartPOPFilePage (generates a custom page)
#
# This function offers to start the newly installed POPFile.
#
# A pseudo "pre" function (CheckCorpusUpgradeStatus) is used to determine whether or not the
# user will be allowed to select the "No, do not start POPFile" option.
#
# A "leave" function (CheckLaunchOptions) is used to act upon the selection made by the user.
#
# The user is allowed to change their selection by returning to this page (by clicking 'Back'
# on the 'FINISH' page) if corpus conversion is not required.
#
# The [Inherited] section in 'pfi-cfg.ini' has information on the system tray icon and the
# console mode settings found in 'popfile.cfg'. Valid values are 0 (disabled), 1 (enabled)
# and ? (undefined). If any settings are undefined, this function adds the default settings
# to 'popfile.cfg' (i.e. console mode disabled, system tray icon enabled)
#--------------------------------------------------------------------------

Function StartPOPFilePage

  !define L_CFG    $R9    ; file handle used to access 'popfile.cfg'
  !define L_TEMP   $R8

  Push ${L_CFG}
  Push ${L_TEMP}

  ; Ensure 'popfile.cfg' has valid settings for system tray icon and console mode
  ; (if necessary, add the default settings to the file and update the [Inherited] copies)

  FileOpen  ${L_CFG} "$G_USERDIR\popfile.cfg" a
  FileSeek  ${L_CFG} 0 END

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "pfi-cfg.ini" "Inherited" "Console"
  StrCmp ${L_TEMP} "?" 0 check_trayicon
  FileWrite ${L_CFG} "windows_console 0${MB_NL}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "pfi-cfg.ini" "Inherited" "Console" "0"

check_trayicon:
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "pfi-cfg.ini" "Inherited" "TrayIcon"
  StrCmp ${L_TEMP} "?" 0 close_file
  FileWrite ${L_CFG} "windows_trayicon 1${MB_NL}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "pfi-cfg.ini" "Inherited" "TrayIcon" "1"

close_file:
  FileClose ${L_CFG}

  IfRebootFlag 0 page_enabled

  ; We are running on a Win9x system which must be rebooted before Kakasi can be used

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Field 1" "Flags"
  StrCmp ${L_TEMP} "DISABLED" display_the_page

  ; If this is a "clean" install (i.e. we have just created some buckets for this user)
  ; then we do not need to start POPFile before we reboot

  ReadINIStr ${L_TEMP} "$PLUGINSDIR\${CBP_C_INIFILE}" "FolderList" "MaxNum"
  StrCmp  ${L_TEMP} "" 0 do_not_start_popfile

  ; If, however, corpus conversion or a SQL database upgrade is required, we treat this as
  ; a special case and start POPFile now so we can monitor the conversion/upgrade because
  ; this process may take several minutes (and it is simpler to monitor it now instead of
  ; waiting until after the reboot).

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Field 2" "Flags"
  StrCmp ${L_TEMP} "DISABLED" display_the_page

do_not_start_popfile:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 2" "State" "1"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 3" "State" "0"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 4" "State" "0"

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 1" "Flags" "DISABLED"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 2" "Flags" "DISABLED"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 3" "Flags" "DISABLED"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 4" "Flags" "DISABLED"

  Goto display_the_page

page_enabled:

  ; clear all three radio buttons ('do not start', 'disable icon', 'enable icon')

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 2" "State" "0"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 3" "State" "0"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 4" "State" "0"

  ; If we have returned to this page from the 'FINISH' page then we can use the [LastAction]
  ; data to select the appropriate radio button, otherwise we use the [Inherited] data.

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "pfi-cfg.ini" "Run Status" "LastAction"
  StrCmp ${L_TEMP} "" use_inherited_data
  StrCmp ${L_TEMP} "disableicon" disableicon
  StrCmp ${L_TEMP} "enableicon" enableicon
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 2" "State" "1"
  Goto display_the_page

use_inherited_data:
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "pfi-cfg.ini" "Inherited" "TrayIcon"
  StrCmp ${L_TEMP} "1" enableicon

disableicon:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Field 3" "State" "1"
  Goto display_the_page

enableicon:
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
# The user is allowed to return to this page and change their selection (if corpus
# conversion is not required), so the previous state is stored in the INI file used
# for this custom page.
#
# There are also some special cases where the installer will start POPFile automatically:
#
# (a) the existing flat-file format corpus is to be converted to SQL database format
#     (and a backup copy of the corpus has been saved in the backup folder)
#
# (b) the existing BerkeleyDB format corpus is to be converted to SQL database format
#     (and a backup copy of the corpus has been saved in the backup folder)
#
# (c) the existing SQL database is to be upgraded to use a new POPFile database schema
#     (and a backup copy of the SQLite database has been saved in the backup folder)
#
# (d) the existing SQL database is to be upgraded to use a new POPFile database schema
#     (and a backup already exists or the existing installation does not use SQLite)
#--------------------------------------------------------------------------

Function CheckLaunchOptions

  !define L_CFG             $R9   ; file handle
  !define L_CONSOLE         $R8   ; set to 'b' for background mode or 'f' for foreground mode
  !define L_EXE             $R7   ; full path of Perl EXE to be monitored
  !define L_POPFILE_SCHEMA  $R6   ; database schema version used by newly installed POPFile
  !define L_TEMP            $R5
  !define L_TRAY            $R4   ; system tray icon mode: 1 = enabled, 0 = disabled

  Push ${L_CFG}
  Push ${L_CONSOLE}
  Push ${L_EXE}
  Push ${L_POPFILE_SCHEMA}
  Push ${L_TEMP}
  Push ${L_TRAY}

  StrCpy ${L_CONSOLE} "b"    ; the default is to run in the background (no console window shown)
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "pfi-cfg.ini" "Inherited" "Console"
  StrCmp ${L_TEMP} "0" check_radio_buttons
  StrCpy ${L_CONSOLE} "f"    ; run in foreground (i.e. run in a console window/DOS box)

check_radio_buttons:

  ; Field 2 = 'Do not run POPFile' radio button

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Field 2" "State"
  StrCmp ${L_TEMP} "0" start_popfile

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Field 2" "Flags"
  StrCmp ${L_TEMP} "DISABLED" exit_without_banner

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "pfi-cfg.ini" "Run Status" "LastAction"
  StrCmp ${L_TEMP} "" set_lastaction_no
  StrCmp ${L_TEMP} "no" exit_without_banner

  ; Selection has been changed from 'disableicon' or 'enableicon' to 'do not run POPFile'

  StrCmp ${L_TEMP} "enableicon" enable_to_no
  StrCpy ${L_EXE} "$G_ROOTDIR\popfile${L_CONSOLE}.exe"
  Goto lastaction_no

set_lastaction_no:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "pfi-cfg.ini" "Run Status" "LastAction" "no"
  Goto exit_without_banner

enable_to_no:
  StrCpy ${L_EXE} "$G_ROOTDIR\popfilei${L_CONSOLE}.exe"

lastaction_no:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "pfi-cfg.ini" "Run Status" "LastAction" "no"

  ; User has changed their mind: Shutdown the newly installed version of POPFile

  Push $G_GUI
  Call PFI_ShutdownViaUI
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "password?" 0 exit_without_banner
  StrCpy $G_PLS_FIELD_1 "POPFile"
  DetailPrint "Unable to shutdown $G_PLS_FIELD_1 automatically - manual intervention requested"
  MessageBox MB_OK|MB_ICONEXCLAMATION|MB_TOPMOST "$(PFI_LANG_MBMANSHUT_1)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_MBMANSHUT_2)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_MBMANSHUT_3)"
  Goto exit_without_banner

start_popfile:

  ; Set ${L_EXE} to "" as we do not yet know if we are going to monitor a file in $G_ROOTDIR

  ; If we run POPFile in the background, we display a banner to provide some user feedback
  ; since it can take a few seconds for POPFile to start up.

  ; If we run POPFile in a console window, we do not display a banner because on some systems
  ; the console window might cause the banner DLL to lock up and this in turn locks up the
  ; installer.

  StrCpy ${L_EXE} ""

  ; Field 4 = 'Run POPFile with system tray icon' radio button (this is the default mode)

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Field 4" "State"
  StrCmp ${L_TEMP} "1" run_with_icon

  ; Run POPFile with no system tray icon

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "pfi-cfg.ini" "Run Status" "LastAction"
  StrCmp ${L_TEMP} "disableicon" exit_without_banner
  StrCmp ${L_TEMP} "no" lastaction_disableicon
  StrCmp ${L_TEMP} "" lastaction_disableicon
  StrCpy ${L_EXE} "$G_ROOTDIR\popfilei${L_CONSOLE}.exe"

lastaction_disableicon:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "pfi-cfg.ini" "Run Status" "LastAction" "disableicon"
  StrCpy ${L_TRAY} "0"
  Goto corpus_conv_check

run_with_icon:
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "pfi-cfg.ini" "Run Status" "LastAction"
  StrCmp ${L_TEMP} "enableicon" exit_without_banner
  StrCmp ${L_TEMP} "no" lastaction_enableicon
  StrCmp ${L_TEMP} "" lastaction_enableicon
  StrCpy ${L_EXE} "$G_ROOTDIR\popfile${L_CONSOLE}.exe"

lastaction_enableicon:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "pfi-cfg.ini" "Run Status" "LastAction" "enableicon"
  StrCpy ${L_TRAY} "1"

corpus_conv_check:

  ; To indicate the special cases where the installer is to start POPFile to perform corpus or
  ; database conversion, 'CheckCorpusUpgradeStatus' clears the "No" radio button and disables it

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Field 2" "Flags"
  StrCmp ${L_TEMP} "DISABLED" launch_conversion_monitor

  StrCmp ${L_CONSOLE} "f" do_not_show_banner

  !ifndef ENGLISH_MODE

    ; The Banner plug-in uses the "MS Shell Dlg" font to display the banner text
    ; but East Asian versions of Windows 9x do not support this so in these cases
    ; we use "English" text for the banner (otherwise the text would be unreadable garbage).

    Call PFI_IsNT
    Pop ${L_TEMP}
    StrCmp ${L_TEMP} "1" show_banner

    ; Windows 9x has been detected

    StrCmp $LANGUAGE ${LANG_SIMPCHINESE} use_ENGLISH_banner
    StrCmp $LANGUAGE ${LANG_TRADCHINESE} use_ENGLISH_banner
    StrCmp $LANGUAGE ${LANG_JAPANESE} use_ENGLISH_banner
    StrCmp $LANGUAGE ${LANG_KOREAN} use_ENGLISH_banner
    Goto show_banner

  use_ENGLISH_banner:
    Banner::show /NOUNLOAD /set 76 "Preparing to start POPFile." "This may take a few seconds..."
    Goto do_not_show_banner   ; sic!

    show_banner:
  !endif
  Banner::show /NOUNLOAD /set 76 "$(PFI_LANG_LAUNCH_BANNER_1)" "$(PFI_LANG_LAUNCH_BANNER_2)"

do_not_show_banner:

  ; Before starting the newly installed POPFile, ensure that no other version of POPFile
  ; is running on the same UI port as the newly installed version.

  Push $G_GUI
  Call PFI_ShutdownViaUI
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "password?" 0 continue
  StrCpy $G_PLS_FIELD_1 "POPFile"
  DetailPrint "Unable to shutdown $G_PLS_FIELD_1 automatically - manual intervention requested"
  MessageBox MB_OK|MB_ICONEXCLAMATION|MB_TOPMOST "$(PFI_LANG_MBMANSHUT_1)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_MBMANSHUT_2)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_MBMANSHUT_3)"

continue:
  Push ${L_EXE}
  Call PFI_WaitUntilUnlocked
  Push ${L_TRAY}
  Call PFI_SetTrayIconMode
  SetOutPath $G_ROOTDIR
  ClearErrors
  Exec '"$G_ROOTDIR\popfile.exe" --verbose'
  IfErrors 0 startup_ok
  StrCmp ${L_CONSOLE} "f" error_msg
  Sleep ${C_MIN_BANNER_DISPLAY_TIME}
  Banner::destroy

error_msg:
  MessageBox MB_OK|MB_ICONEXCLAMATION|MB_TOPMOST \
      "An error occurred when the installer tried to start POPFile.\
      ${MB_NL}${MB_NL}\
      Please use 'Start -> Programs -> POPFile -> Run POPFile' now.\
      ${MB_NL}${MB_NL}\
      Click 'OK' once POPFile has been started."
  Goto exit_without_banner

launch_conversion_monitor:

  ; Update the system tray icon setting in 'popfile.cfg' (even though it may be ignored for
  ; some special cases, we need to honour the user's selection for subsequent activations)

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Field 4" "State"
  Push ${L_TEMP}
  Call PFI_SetTrayIconMode

  ; If corpus conversion (from flat file or BerkeleyDB format) is required, we run the
  ; 'Corpus Conversion Monitor' which displays progress messages because the conversion
  ; may take several minutes during which time POPFile will appear to have 'locked up'

  ReadINIStr ${L_TEMP} "$G_USERDIR\backup\backup.ini" "NonSQLCorpus" "Status"
  StrCmp ${L_TEMP} "new" 0 check_database

  WriteINIStr "$G_USERDIR\backup\backup.ini" "NonSQLCorpus" "Status" "old"
  Call ConvertCorpus
  Goto exit_without_banner

check_database:
  ReadINIStr ${L_TEMP} "$G_USERDIR\backup\backup.ini" "OldSQLdatabase" "Status"
  StrCmp ${L_TEMP} "new" 0 sqlupgrade
  WriteINIStr "$G_USERDIR\backup\backup.ini" "OldSQLdatabase" "Status" "old"

sqlupgrade:

  ; When a SQL database upgrade is required we run the 'Message Capture' utility to display
  ; the progress reports because this upgrade may take several minutes during which time
  ; POPFile will appear to have 'locked up'

  Call UpgradeSQLdatabase
  Push "$G_ROOTDIR\Classifier\popfile.sql"
  Call PFI_GetPOPFileSchemaVersion
  Pop ${L_POPFILE_SCHEMA}
  StrCpy ${L_TEMP} ${L_POPFILE_SCHEMA} 1
  StrCmp ${L_TEMP} "(" 0 store_schema
  StrCpy ${L_POPFILE_SCHEMA} "0"

store_schema:
  WriteINIStr "$G_USERDIR\install.ini" "Settings" "SQLSV" "${L_POPFILE_SCHEMA}"
  Goto exit_without_banner

startup_ok:

  ; A simple time delay is used to give POPFile time to get ready to display the UI. It takes
  ; time for POPFile to start up and be able to generate the UI pages - attempts to access the
  ; UI too quickly will result in a browser error message (which must be cancelled by the user)
  ; and an empty browser window (which must be refreshed by the user). Earlier versions of the
  ; installer waited until POPFile could display a UI page but on some systems this wait proved
  ; to be endless. (The installer should have given up after a certain number of failed NSISdl
  ; attempts to access the UI but in some cases NSISdl never returned control to the installer
  ; so the installer stopped responding.)

  Sleep ${C_UI_STARTUP_DELAY}

  StrCmp ${L_CONSOLE} "f" exit_without_banner
  Sleep ${C_MIN_BANNER_DISPLAY_TIME}
  Banner::destroy

exit_without_banner:
  Pop ${L_TRAY}
  Pop ${L_TEMP}
  Pop ${L_POPFILE_SCHEMA}
  Pop ${L_EXE}
  Pop ${L_CONSOLE}
  Pop ${L_CFG}

  !undef L_CFG
  !undef L_CONSOLE
  !undef L_EXE
  !undef L_POPFILE_SCHEMA
  !undef L_TEMP
  !undef L_TRAY

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: ConvertCorpus
#--------------------------------------------------------------------------

Function ConvertCorpus

  !define L_FOLDER_COUNT  $R9
  !define L_FOLDER_PATH   $R8

  Push ${L_FOLDER_COUNT}
  Push ${L_FOLDER_PATH}

  HideWindow
  ExecWait '"$PLUGINSDIR\monitorcc.exe" "$PLUGINSDIR\corpus.ini"'
  BringToFront

  ; Now remove any empty corpus folders (POPFile has deleted the files as they are converted)

  ReadINIStr ${L_FOLDER_COUNT} "$PLUGINSDIR\corpus.ini" "FolderList" "MaxNum"

loop:
  ReadINIStr ${L_FOLDER_PATH} "$PLUGINSDIR\corpus.ini" "FolderList" "Path-${L_FOLDER_COUNT}"
  StrCmp  ${L_FOLDER_PATH} "" try_next_one

  ; Remove this corpus bucket folder if it is completely empty

  RMDir ${L_FOLDER_PATH}

try_next_one:
  IntOp ${L_FOLDER_COUNT} ${L_FOLDER_COUNT} - 1
  IntCmp ${L_FOLDER_COUNT} 0 exit exit loop

exit:

  ; Remove the corpus folder if it is completely empty

  ReadINIStr ${L_FOLDER_PATH} "$G_USERDIR\backup\backup.ini" "NonSQLCorpus" "CorpusPath"
  RMDir ${L_FOLDER_PATH}

  Pop ${L_FOLDER_PATH}
  Pop ${L_FOLDER_COUNT}

  !undef L_FOLDER_COUNT
  !undef L_FOLDER_PATH

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: UpgradeSQLdatabase
#--------------------------------------------------------------------------

Function UpgradeSQLdatabase

  HideWindow
  ExecWait '"$G_ROOTDIR\msgcapture.exe" /TIMEOUT=PFI'
  BringToFront

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: CheckRunStatus
# (the "pre" function for the 'FINISH' page)
#
# The 'FINISH' page contains two CheckBoxes: one to control whether or not the installer
# starts the POPFile User Interface and one to control whether or not the 'ReadMe' file is
# displayed. The User Interface only works when POPFile is running, so we must ensure its
# CheckBox can only be ticked if the installer has started POPFile.
#
# NB: User can switch back and forth between the 'Start POPFile' page and the 'FINISH' page
# (when corpus conversion is not required)
#--------------------------------------------------------------------------

Function CheckRunStatus

  !define L_TEMP              $R9

  Push ${L_TEMP}

  ; If we have installed Kakasi on a Win9x system we may need to reboot before allowing the
  ; user to start POPFile (corpus conversion and SQL database upgrades are special cases)

  IfRebootFlag disable_BACK_button

  ; Enable the 'Run' CheckBox on the 'FINISH' page (it may have been disabled on our last visit)

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 4" "Flags" ""

  ; Get the status of the 'Do not run POPFile' radio button on the 'Start POPFile' page
  ; If user has not started POPFile, we cannot offer to display the POPFile User Interface

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Field 2" "State"
  StrCmp ${L_TEMP} "1" disable_RUN_option

  ; If the installer has started POPFile (because the existing flat-file corpus or BerkeleyDB
  ; corpus needs to be converted to a SQL database or because the existing SQL database needs
  ; to be upgraded) then the 'Do not run POPFile' radio button on the 'Start POPFile' page will
  ; have been disabled. For these special cases we disable the "Back" button.

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Field 2" "Flags"
  StrCmp ${L_TEMP} "DISABLED" 0 exit

disable_BACK_button:
 !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Settings" "BackEnabled" "0"
  Goto exit

disable_RUN_option:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 4" "State" "0"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 4" "Flags" "DISABLED"

exit:

  ; If POPFile is running in a console window, it might be obscuring the installer

  BringToFront

  Pop ${L_TEMP}

  !undef L_TEMP

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: RunUI
# (the "Run" function for the 'FINISH' page)
#
# If the installer is allowed to display the UI, it now displays the Buckets page
# (instead of the default page). This makes it easier for users to check the results
# of upgrading a pre-0.21.0 installation (the upgrade may change some bucket settings).
#--------------------------------------------------------------------------

Function RunUI

  ExecShell "open" "http://${C_UI_URL}:$G_GUI/buckets"

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: ShowReadMe
# (the "ReadMe" function for the 'FINISH' page)
#--------------------------------------------------------------------------

Function ShowReadMe

  IfFileExists "$SMPROGRAMS\${C_PFI_PRODUCT}\Release Notes.lnk" 0 exit
  ExecShell "open" "$SMPROGRAMS\${C_PFI_PRODUCT}\Release Notes.lnk"

exit:
FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: RemoveEmptyCBPCorpus
#
# If the wizard used the CBP package to create some buckets, there may be
# some empty corpus folders left behind (after POPFile has converted the
# buckets to the new SQL format) so we remove these useless empty folders.
#--------------------------------------------------------------------------

Function RemoveEmptyCBPCorpus

  IfFileExists "$PLUGINSDIR\${CBP_C_INIFILE}" 0 nothing_to_do

  !define L_FOLDER_COUNT  $R9
  !define L_FOLDER_PATH   $R8

  Push ${L_FOLDER_COUNT}
  Push ${L_FOLDER_PATH}

  ; Now remove any empty corpus folders left behind after POPFile has converted the buckets
  ; (if any) created by the CBP package.

  ReadINIStr ${L_FOLDER_COUNT} "$PLUGINSDIR\${CBP_C_INIFILE}" "FolderList" "MaxNum"
  StrCmp  ${L_FOLDER_COUNT} "" exit

loop:
  ReadINIStr ${L_FOLDER_PATH} "$PLUGINSDIR\${CBP_C_INIFILE}" "FolderList" "Path-${L_FOLDER_COUNT}"
  StrCmp  ${L_FOLDER_PATH} "" try_next_one

  ; Remove this corpus bucket folder if it is completely empty

  RMDir ${L_FOLDER_PATH}

try_next_one:
  IntOp ${L_FOLDER_COUNT} ${L_FOLDER_COUNT} - 1
  IntCmp ${L_FOLDER_COUNT} 0 corpus_root corpus_root loop

corpus_root:

  ; Remove the corpus folder if it is completely empty

  ReadINIStr ${L_FOLDER_PATH} "$PLUGINSDIR\${CBP_C_INIFILE}" "CBP Data" "CorpusPath"
  RMDir ${L_FOLDER_PATH}

exit:
  Pop ${L_FOLDER_PATH}
  Pop ${L_FOLDER_COUNT}

  !undef L_FOLDER_COUNT
  !undef L_FOLDER_PATH

nothing_to_do:
FunctionEnd


#==========================================================================
#==========================================================================
# The 'Uninstall' part of the script is in a separate file
#==========================================================================
#==========================================================================

  !include "adduser-Uninstall.nsh"

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

      !define L_RESULT    $R9   ; The 'PFI_IsNT' function returns 0 if Win9x was detected

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
# End of 'adduser.nsi'
#--------------------------------------------------------------------------
