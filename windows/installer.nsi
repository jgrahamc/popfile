#--------------------------------------------------------------------------
#
# installer.nsi --- This is the NSIS script used to create the
#                   Windows installer for POPFile. This script uses
#                   four custom pages whose layouts are defined
#                   in the files "ioA.ini", "ioB.ini", "ioC.ini" and "ioD.ini".
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

; As of 9 August 2003, the latest release of the NSIS compiler is 2.0b3. Since its release in
; March 2003, the compiler has been greatly improved. This script uses many of the improvements
; introduced since then. Although the NSIS compiler has been updated to 2.0b4 (CVS), the only
; way to obtain this version is to install the 2.0b3 release and then apply some CVS updates.
;
; There are two ways to apply these CVS updates:
;
; (a) use the 'NSIS Update' feature provided by the 'NSIS Menu', or
;
;(b) obtain a NSIS 'Nightly' CVS update and use it to upgrade the 2.0b3 installation.
;
; The 'NSIS Update' feature does not work reliably at the moment, due to SourceForge.net's
; current CVS server problems, so the quickest way to update NSIS to 2.0b4 (CVS) is by means
; of the snapshot which is a ZIP file created several times a day from data on the 'real' CVS
; servers (so it is NOT subject to the same problems as the 'NSIS Update' feature).
;
; This version of the script has been tested with NSIS 2.0b4 (CVS) after updating it by using
; the 27 August 2003 (19:44 GMT) version of the NSIS CVS snapshot.

#--------------------------------------------------------------------------
# LANGUAGE SUPPORT:
#
# The installer defaults to multi-language mode ('English' plus a number of other languages).
#
# If required, a command-line switch can be used to build an English-only version.
#
# Normal multi-language build command:  makensis.exe installer.nsi
# To build an English-only installer:   makensis.exe  /DENGLISH_MODE installer.nsi
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
# To add support for a language which is already supported by the NSIS MUI package, two files
# are required:
#
#   <NSIS Language NAME>-mui.nsh  - holds customised versions of the standard MUI text strings
#                                   (eg removing the 'reboot' reference from the 'Welcome' page)
#
#   <NSIS Language NAME>-pfi.nsh  - holds strings used on the custom pages and elsewhere
#
# Once these files have been prepared and placed in the 'windows\languages' directory with the
# other *-mui.nsh and *-pfi.nsh files, add a new '!insertmacro PFI_LANG_LOAD' line to load these
# two new files and, if there is a suitable POPFile UI language file for the new language,
# add a suitable '!insertmacro UI_LANG_CONFIG' line in the section which handles the optional
# 'Languages' component to allow the installer to select the appropriate UI language.
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
#--------------------------------------------------------------------------

  ;--------------------------------------------------------------------------
  ; POPFile constants have been given names beginning with 'C_' (eg C_README)
  ;--------------------------------------------------------------------------

  !define MUI_PRODUCT   "POPFile"
  !define MUI_VERSION   "0.20.0"

  !define C_README        "v0.20.0.change"
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

# !define PFI_VERBOSE

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

  VIProductVersion "0.20.0.0"

  VIAddVersionKey "ProductName" "${MUI_PRODUCT}"
  VIAddVersionKey "Comments" "POPFile Homepage: http://popfile.sourceforge.net"
  VIAddVersionKey "CompanyName" "The POPFile Project"
  VIAddVersionKey "LegalCopyright" "© 2001-2003  John Graham-Cumming"
  VIAddVersionKey "FileDescription" "POPFile Automatic email classification"
  VIAddVersionKey "FileVersion" "${MUI_VERSION}"

  !ifndef ENGLISH_MODE
    VIAddVersionKey "Build" "Multi-Language"
  !else
    VIAddVersionKey "Build" "English-Mode"
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
# Define the Page order for the installer (and the uninstaller)
#--------------------------------------------------------------------------

  ; Installer Pages

  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  Page custom SetOptionsPage "CheckPortOptions"
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro CBP_PAGE_SELECTBUCKETS
  Page custom SetOutlookExpressPage
  Page custom StartPOPFilePage "CheckLaunchOptions"
  Page custom ConvertCorpusPage
  !insertmacro MUI_PAGE_FINISH

  ; Uninstaller Pages

  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES

#--------------------------------------------------------------------------
# Configure the MUI pages
#--------------------------------------------------------------------------
  ;-----------------------------------------
  ; General Settings - License Page Settings
  ;-----------------------------------------

  ; Three styles of 'License Agreement' page are available:
  ; (1) New style with an 'I accept' checkbox below the license window
  ; (2) New style with 'I accept/I do not accept' radio buttons below the license window
  ; (3) Classic style with the 'Next' button replaced by an 'Agree' button
  ;     (to get the 'Classic' style, comment-out the CHECKBOX and the RADIOBUTTONS 'defines')

  !define MUI_LICENSEPAGE_CHECKBOX
#  !define MUI_LICENSEPAGE_RADIOBUTTONS

  ;-----------------------------------------
  ; General Settings - Finish Page Settings
  ;-----------------------------------------

  ; Offer to display the POPFile User Interface (The 'CheckRunStatus' function ensures this
  ; option is only offered if the installer has started POPFile running)

  !define MUI_FINISHPAGE_RUN
  !define MUI_FINISHPAGE_RUN_FUNCTION "RunUI"

  ; Display the Release Notes for this version of POPFile

  !define MUI_FINISHPAGE_SHOWREADME
  !define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
  !define MUI_FINISHPAGE_SHOWREADME_FUNCTION "ShowReadMe"

  ; Debug aid: Hide the installation log but let user display it (using "Show details" button)

;  !define MUI_FINISHPAGE_NOAUTOCLOSE

  ;-----------------------------------------
  ; General Settings - Other Settings
  ;-----------------------------------------

  ; Show a message box with a warning when the user closes the installation

  !define MUI_ABORTWARNING

  ;-----------------------------------------
  ; Interface Settings
  ;-----------------------------------------

  ; The banner provided by the default 'modern.exe' UI does not provide much room for the
  ; two lines of text, e.g. the German version is truncated, so we use a custom UI which
  ; provides slightly wider text areas. Each area is still limited to a single line of text.

  !define MUI_UI "UI\pfi_modern.exe"

  ; The 'hdr-common.bmp' logo is only 90 x 57 pixels, much smaller than the 150 x 57 pixel
  ; space provided by the default 'modern_headerbmpr.exe' UI, so we use a custom UI which
  ; leaves more room for the TITLE and SUBTITLE text.

  !define MUI_UI_HEADERBITMAP_RIGHT "UI\pfi_headerbmpr.exe"

  ; The "Special" bitmap appears on the "Welcome" and "Finish" pages,
  ; the "Header" bitmap appears on the other pages of the installer.

  !define MUI_SPECIALBITMAP "special.bmp"
  !define MUI_HEADERBITMAP "hdr-common.bmp"
  !define MUI_HEADERBITMAP_RIGHT

  ; The icon files for the installer and uninstaller must have the same structure. For example,
  ; if one icon file contains a 32x32 16-colour image and a 16x16 16-colour image then the other
  ; file cannot just contain a 32x32 16-colour image, it must also have a 16x16 16-colour image.

  !define MUI_ICON    "POPFileIcon\popfile.ico"
  !define MUI_UNICON  "remove.ico"

  ;-----------------------------------------
  ; Custom Functions added to MUI pages
  ;-----------------------------------------

  ; Use a custom '.onGUIInit' function to add language-specific texts to custom page INI files

  !define MUI_CUSTOMFUNCTION_GUIINIT PFIGUIInit

  ; Use a "pre" function for the 'Welcome' page to ensure the installer window is visible
  ; (if the "Release Notes" were displayed, another window could have been positioned
  ; to obscure the installer window)

  !define MUI_CUSTOMFUNCTION_WELCOME_PRE "ShowInstaller"

  ; Use a "leave" function to look for 'popfile.cfg' in the directory selected for this install

  !define MUI_CUSTOMFUNCTION_DIRECTORY_LEAVE "CheckExistingConfig"

  ; Use a "pre" function for the 'Finish' page to ensure installer only offers to display
  ; POPFile User Interface if user has chosen to start POPFile from the installer.

  !define MUI_CUSTOMFUNCTION_FINISH_PRE "CheckRunStatus"

#--------------------------------------------------------------------------
# User Registers (Global)
#--------------------------------------------------------------------------

  ; This script uses 'User Variables' (with names starting with 'G_') to hold GLOBAL data.

  Var   G_POP3        ; POP3 port (1-65535)
  Var   G_GUI         ; GUI port (1-65535)
  Var   G_STARTUP     ; automatic startup flag (1 = yes, 0 = no)
  Var   G_NOTEPAD     ; path to notepad.exe ("" = not found in search path)

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
  ; Language Settings for MUI pages
  ;-----------------------------------------

  ; Same "Language selection" dialog is used for the installer and the uninstaller
  ; so we override the standard "Installer Language" title to avoid confusion.

  !define MUI_TEXT_LANGDLL_WINDOWTITLE "Language Selection"

  ; Always show the language selection dialog, even if a language has been stored in the
  ; registry (the language stored in the registry will be selected as the default language)

  !define MUI_LANGDLL_ALWAYSSHOW

  ; Remember user's language selection and offer this as the default when re-installing
  ; (uninstaller also uses this setting to determine which language is to be used)

  !define MUI_LANGDLL_REGISTRY_ROOT "HKLM"
  !define MUI_LANGDLL_REGISTRY_KEY "SOFTWARE\${MUI_PRODUCT}"
  !define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"

  ;-----------------------------------------
  ; Select the languages to be supported by installer/uninstaller.
  ; Currently a subset of the languages supported by NSIS MUI 1.65 (using the NSIS names)
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

        !insertmacro PFI_LANG_LOAD "Bulgarian"    ; 'New style' license msgs missing (27-Jun-03)
        !insertmacro PFI_LANG_LOAD "SimpChinese"
        !insertmacro PFI_LANG_LOAD "TradChinese"
        !insertmacro PFI_LANG_LOAD "Czech"
        !insertmacro PFI_LANG_LOAD "Danish"       ; 'New style' license msgs missing (27-Jun-03)
        !insertmacro PFI_LANG_LOAD "German"
        !insertmacro PFI_LANG_LOAD "Spanish"
        !insertmacro PFI_LANG_LOAD "French"
        !insertmacro PFI_LANG_LOAD "Greek"
        !insertmacro PFI_LANG_LOAD "Italian"
        !insertmacro PFI_LANG_LOAD "Japanese"
        !insertmacro PFI_LANG_LOAD "Korean"
        !insertmacro PFI_LANG_LOAD "Hungarian"
        !insertmacro PFI_LANG_LOAD "Dutch"
        !insertmacro PFI_LANG_LOAD "Polish"
        !insertmacro PFI_LANG_LOAD "Portuguese"
        !insertmacro PFI_LANG_LOAD "PortugueseBR"
        !insertmacro PFI_LANG_LOAD "Russian"
        !insertmacro PFI_LANG_LOAD "Slovak"
        !insertmacro PFI_LANG_LOAD "Finnish"      ; 'New style' license msgs missing (27-Jun-03)
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

  InstallDir "$PROGRAMFILES\${MUI_PRODUCT}"
  InstallDirRegKey HKLM "SOFTWARE\${MUI_PRODUCT}" InstallLocation

#--------------------------------------------------------------------------
# Reserve the files required by the installer (to improve performance)
#--------------------------------------------------------------------------

  ;Things that need to be extracted on startup (keep these lines before any File command!)
  ;Only useful for BZIP2 compression
  ;Use ReserveFile for your own Install Options ini files too!

  !insertmacro MUI_RESERVEFILE_LANGDLL
  !insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
  !insertmacro MUI_RESERVEFILE_WELCOMEFINISHPAGE
  ReserveFile "ioA.ini"
  ReserveFile "ioB.ini"
  ReserveFile "ioC.ini"
  ReserveFile "ioD.ini"
  ReserveFile "${C_RELEASE_NOTES}"

#--------------------------------------------------------------------------
# Installer Function: .onInit - installer starts by offering a choice of languages
#--------------------------------------------------------------------------

Function .onInit

  !define L_INPUT_FILE_HANDLE   $R9
  !define L_OUTPUT_FILE_HANDLE  $R8
  !define L_LINE                $R7

  Push ${L_INPUT_FILE_HANDLE}
  Push ${L_OUTPUT_FILE_HANDLE}
  Push ${L_LINE}

  ; Conditional compilation: if ENGLISH_MODE is defined, support only 'English'

  !ifndef ENGLISH_MODE
        !insertmacro MUI_LANGDLL_DISPLAY
  !endif

  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioA.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioB.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioC.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioD.ini"

  !insertmacro MUI_INSTALLOPTIONS_EXTRACT_AS "${C_RELEASE_NOTES}" "${C_README}"

  ; Ensure the release notes are in a format which the standard Windows NOTEPAD.EXE can use.
  ; When the "POPFile" section is processed, the converted release notes will be copied to the
  ; installation directory to ensure user has a copy which can be read by NOTEPAD.EXE later.

  FileOpen ${L_INPUT_FILE_HANDLE}  "$PLUGINSDIR\${C_README}" r
  FileOpen ${L_OUTPUT_FILE_HANDLE} "$PLUGINSDIR\${C_README}.txt" w
  ClearErrors

loop:
  FileRead ${L_INPUT_FILE_HANDLE} ${L_LINE}
  IfErrors close_files
  Push ${L_LINE}
  Call TrimNewlines
  Pop ${L_LINE}
  FileWrite ${L_OUTPUT_FILE_HANDLE} ${L_LINE}$\r$\n
  Goto loop

close_files:
  FileClose ${L_INPUT_FILE_HANDLE}
  FileClose ${L_OUTPUT_FILE_HANDLE}

  Pop ${L_LINE}
  Pop ${L_OUTPUT_FILE_HANDLE}
  Pop ${L_INPUT_FILE_HANDLE}

  !undef L_INPUT_FILE_HANDLE
  !undef L_OUTPUT_FILE_HANDLE
  !undef L_LINE
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
  Call SetOutlookExpressPage_Init
  Call StartPOPFilePage_Init
  Call ConvertCorpusPage_Init

  ; Ensure the 'Kakasi' section is selected if 'Japanese' has been chosen

  Call HandleKakasi

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

  WriteRegStr HKLM "SOFTWARE\${MUI_PRODUCT}" InstallLocation $INSTDIR

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

  SetOutPath $INSTDIR\Platform
  File "..\engine\Platform\MSWin32.pm"

  SetOutPath $INSTDIR\POPFile
  File "..\engine\POPFile\MQ.pm"
  File "..\engine\POPFile\Loader.pm"
  File "..\engine\POPFile\Logger.pm"
  File "..\engine\POPFile\Module.pm"
  File "..\engine\POPFile\Configuration.pm"

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
  File "${C_PERL_DIR}\bin\perl58.dll"
  File "${C_PERL_DIR}\lib\AutoLoader.pm"
  File "${C_PERL_DIR}\lib\Carp.pm"
  File "${C_PERL_DIR}\lib\Config.pm"
  File "${C_PERL_DIR}\lib\DynaLoader.pm"
  File "${C_PERL_DIR}\lib\Errno.pm"
  File "${C_PERL_DIR}\lib\Exporter.pm"
  File "${C_PERL_DIR}\lib\IO.pm"
  File "${C_PERL_DIR}\lib\integer.pm"
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

  SetOutPath "$SMPROGRAMS\${MUI_PRODUCT}"
  SetOutPath $INSTDIR
  CreateShortCut "$SMPROGRAMS\${MUI_PRODUCT}\Run POPFile.lnk" \
                 "$INSTDIR\popfile.exe"
  CreateShortCut "$SMPROGRAMS\${MUI_PRODUCT}\Uninstall POPFile.lnk" \
                 "$INSTDIR\uninstall.exe"
  CreateShortCut "$SMPROGRAMS\${MUI_PRODUCT}\Release Notes.lnk" \
                 "$INSTDIR\${C_README}.txt"

  SetOutPath "$SMPROGRAMS\${MUI_PRODUCT}"
  WriteINIStr "$SMPROGRAMS\${MUI_PRODUCT}\POPFile User Interface.url" \
              "InternetShortcut" "URL" "http://127.0.0.1:$G_GUI/"
  WriteINIStr "$SMPROGRAMS\${MUI_PRODUCT}\Shutdown POPFile.url" \
              "InternetShortcut" "URL" "http://127.0.0.1:$G_GUI/shutdown"
  WriteINIStr "$SMPROGRAMS\${MUI_PRODUCT}\Manual.url" \
              "InternetShortcut" "URL" "file://$INSTDIR/manual/en/manual.html"
  WriteINIStr "$SMPROGRAMS\${MUI_PRODUCT}\FAQ.url" \
              "InternetShortcut" "URL" \
              "http://sourceforge.net/docman/display_doc.php?docid=14421&group_id=63137"

  SetOutPath "$SMPROGRAMS\${MUI_PRODUCT}\Support"
  WriteINIStr "$SMPROGRAMS\${MUI_PRODUCT}\Support\POPFile Home Page.url" \
              "InternetShortcut" "URL" "http://popfile.sourceforge.net/"

  SetOutPath $INSTDIR
  CreateShortCut "$SMPROGRAMS\${MUI_PRODUCT}\Shutdown POPFile silently.lnk" \
                 "$INSTDIR\stop_pf.exe" "/showerrors $G_GUI"

  StrCmp $G_STARTUP "1" 0 skip_autostart_set
      SetOutPath $SMSTARTUP
      SetOutPath $INSTDIR
      CreateShortCut "$SMSTARTUP\Run POPFile.lnk" \
                     "$INSTDIR\popfile.exe"
skip_autostart_set:

  ; Remove redundant links (used by earlier versions of POPFile)

  Delete "$SMSTARTUP\Run POPFile in background.lnk"
  Delete "$SMPROGRAMS\${MUI_PRODUCT}\Run POPFile in background.lnk"

  ; Create entry in the Control Panel's "Add/Remove Programs" list

  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_PRODUCT}" \
              "DisplayName" "${MUI_PRODUCT} ${MUI_VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_PRODUCT}" \
              "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_PRODUCT}" \
              "NoModify" "1"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_PRODUCT}" \
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
  StrCmp ${L_LANG} "Hebrew" special_case
  StrCmp ${L_LANG} "Norsk"  0 use_installer_lang

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

#--------------------------------------------------------------------------
# Component-selection page descriptions
#
# There is no need to provide any translations for the 'SecKakasi' description
# because it is only visible when the installer is built in ENGLISH_MODE.
#--------------------------------------------------------------------------

  !insertmacro MUI_FUNCTIONS_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecPOPFile} $(DESC_SecPOPFile)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecSkins}   $(DESC_SecSkins)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecLangs}   $(DESC_SecLangs)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecKakasi}   "Kakasi (used to process Japanese email)"
  !insertmacro MUI_FUNCTIONS_DESCRIPTION_END

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

#--------------------------------------------------------------------------
# Installer Function: ShowInstaller
# (the "pre" function for the WELCOME page)
#
# Ensure the installer window is not hidden behind any other windows
#--------------------------------------------------------------------------

Function ShowInstaller
  BringToFront
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
  ; POPFile v0.20.0 and later may be using one of four popfile*.exe files.
  ; Earlier versions of POPFile (up to and including 0.19.1) may be using wperl.exe or perl.exe.

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
# Installer Function: SetOutlookExpressPage_Init
#
# This function adds language texts to the INI file used by the "SetOutlookExpressPage" function
# (to make the custom page use the language selected by the user for the installer)
#--------------------------------------------------------------------------

Function SetOutlookExpressPage_Init

  !insertmacro PFI_IO_TEXT "ioB.ini" "1" "$(PFI_LANG_OECFG_IO_INTRO)"
  !insertmacro PFI_IO_TEXT "ioB.ini" "2" "$(PFI_LANG_OECFG_IO_CHECKBOX)"
  !insertmacro PFI_IO_TEXT "ioB.ini" "3" "$(PFI_LANG_OECFG_IO_EMAIL)"
  !insertmacro PFI_IO_TEXT "ioB.ini" "4" "$(PFI_LANG_OECFG_IO_SERVER)"
  !insertmacro PFI_IO_TEXT "ioB.ini" "5" "$(PFI_LANG_OECFG_IO_USERNAME)"
  !insertmacro PFI_IO_TEXT "ioB.ini" "6" "$(PFI_LANG_OECFG_IO_RESTORE)"

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
  !define L_SEPARATOR   $R0   ; char used to separate the pop3 server from the username
  !define L_TEMP        $9

  Push ${L_ACCOUNT}
  Push ${L_ACCT_INDEX}
  Push ${L_CFG}
  Push ${L_GUID}
  Push ${L_GUID_INDEX}
  Push ${L_IDENTITY}
  Push ${L_OEDATA}
  Push ${L_OEPATH}
  Push ${L_ORDINALS}
  Push ${L_SEPARATOR}
  Push ${L_TEMP}

  ; Determine the separator character to be used when configuring an email account for POPFile

  Call GetSeparator
  Pop ${L_SEPARATOR}

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
  StrCmp ${L_OEDATA} "127.0.0.1" try_next_account

  ; If 'POP3 Server' data contains the separator character, we cannot configure this account

  Push ${L_OEDATA}
  Push ${L_SEPARATOR}
  Call StrStr
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" 0 try_next_account

  !insertmacro MUI_HEADER_TEXT "$(PFI_LANG_OECFG_TITLE)" "$(PFI_LANG_OECFG_SUBTITLE)"

  ; Ensure the 'configure this account' check box is NOT ticked

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 2" "State" "0"

  ; Prepare to display the 'POP3 Server' data

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 8" "Text" ${L_OEDATA}

  ReadRegStr ${L_OEDATA} HKCU ${L_ACCOUNT} "SMTP Email Address"
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 7" "Text" ${L_OEDATA}

  ReadRegStr ${L_OEDATA} HKCU ${L_ACCOUNT} "POP3 User Name"

  ; If 'POP3 User Name' data contains the separator character, we cannot configure this account

  Push ${L_OEDATA}
  Push ${L_SEPARATOR}
  Call StrStr
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" 0 try_next_account

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 9" "Text" ${L_OEDATA}

  ; Find the Username used by OE for this identity and the OE Account Name
  ; (so we can unambiguously report which email account we are offering to reconfigure).

  ReadRegStr ${L_IDENTITY} HKCU "Identities\${L_GUID}\" "Username"
  StrCpy ${L_IDENTITY} $\"${L_IDENTITY}$\"
  ReadRegStr ${L_OEDATA} HKCU ${L_ACCOUNT} "Account Name"
  StrCpy ${L_OEDATA} $\"${L_OEDATA}$\"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioB.ini" "Field 10" "Text" \
      "${L_OEDATA} $(PFI_LANG_OECFG_IO_LINK_1) ${L_IDENTITY} $(PFI_LANG_OECFG_IO_LINK_2)"

  ; Display the OE account data and offer to configure this account to work with POPFile

  !insertmacro MUI_INSTALLOPTIONS_DISPLAY_RETURN "ioB.ini"
  Pop ${L_TEMP}

  StrCmp ${L_TEMP} "cancel" finished_this_guid
  StrCmp ${L_TEMP} "back" finished_this_guid

  ; Has the user ticked the 'configure this account' check box ?

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioB.ini" "Field 2" "State"
  StrCmp ${L_TEMP} "1" change_oe try_next_account

change_oe:
  ReadRegStr ${L_OEDATA} HKCU ${L_ACCOUNT} "POP3 User Name"
  ReadRegStr ${L_TEMP} HKCU ${L_ACCOUNT} "POP3 Server"

  ; To be able to restore the registry to previous settings when we uninstall we
  ; write a special file called popfile.reg containing the registry settings
  ; prior to modification in the form of lines consisting of
  ;
  ; the\key
  ; thesubkey
  ; the\value

  FileOpen  ${L_CFG} $INSTDIR\popfile.reg a
  FileSeek  ${L_CFG} 0 END
  FileWrite ${L_CFG} "${L_ACCOUNT}$\n"
  FileWrite ${L_CFG} "POP3 User Name$\n"
  FileWrite ${L_CFG} "${L_OEDATA}$\n"
  FileWrite ${L_CFG} "${L_ACCOUNT}$\n"
  FileWrite ${L_CFG} "POP3 Server$\n"
  FileWrite ${L_CFG} "${L_TEMP}$\n"
  FileClose ${L_CFG}

  WriteRegStr HKCU ${L_ACCOUNT} "POP3 User Name" "${L_TEMP}${L_SEPARATOR}${L_OEDATA}"
  WriteRegStr HKCU ${L_ACCOUNT} "POP3 Server" "127.0.0.1"

try_next_account:
  IntOp ${L_ACCT_INDEX} ${L_ACCT_INDEX} + 1
  goto next_acct

finished_this_guid:

  ; If no "Identity Ordinal" values were found then exit otherwise move on to the next identity

  StrCmp ${L_ORDINALS} "0" finished_oe_config

  IntOp ${L_GUID_INDEX} ${L_GUID_INDEX} + 1
  goto get_guid

finished_oe_config:

  Pop ${L_TEMP}
  Pop ${L_SEPARATOR}
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
  !undef L_SEPARATOR
  !undef L_TEMP

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: StartPOPFilePage_Init (adds language texts to custom page INI file)
#
# This function adds language texts to the INI file used by the "StartPOPFilePage" function
# (to make the custom page use the language selected by the user for the installer)
#--------------------------------------------------------------------------

Function StartPOPFilePage_Init

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
  Exec '"$INSTDIR\popfile.exe"'
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

  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioD.ini"

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
  Exec '"$INSTDIR\popfilef.exe"'
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

  ExecShell "open" '"$SMPROGRAMS\${MUI_PRODUCT}\POPFile User Interface.url"'

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

  IfFileExists $INSTDIR\popfile.pl skip_confirmation
  IfFileExists $INSTDIR\popfile.exe skip_confirmation
    MessageBox MB_YESNO|MB_ICONSTOP|MB_DEFBUTTON2 \
        "$(un.PFI_LANG_MBNOTFOUND_1) '$INSTDIR'.\
        $\r$\n$\r$\n\
        $(un.PFI_LANG_MBNOTFOUND_2)" IDYES skip_confirmation
    Abort "$(un.PFI_LANG_ABORT_1)"

skip_confirmation:
  SetDetailsPrint textonly
  DetailPrint "$(un.PFI_LANG_PROGRESS_1)"
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
  DetailPrint "$(un.PFI_LANG_LOG_1) $G_GUI"
  NSISdl::download_quiet http://127.0.0.1:$G_GUI/shutdown "$PLUGINSDIR\shutdown.htm"
  Pop ${L_TEMP}
  Goto check_shutdown

use_other_port:
  Push ${L_OLDUI}
  Call un.TrimNewlines
  Call un.StrCheckDecimal
  Pop ${L_OLDUI}
  StrCmp ${L_OLDUI} "" remove_shortcuts
  DetailPrint "$(un.PFI_LANG_LOG_1) ${L_OLDUI}"
  NSISdl::download_quiet http://127.0.0.1:${L_OLDUI}/shutdown "$PLUGINSDIR\shutdown.htm"
  Pop ${L_TEMP}

check_shutdown:
  Push ${L_EXE}
  Call un.WaitUntilUnlocked

remove_shortcuts:
  SetDetailsPrint textonly
  DetailPrint "$(un.PFI_LANG_PROGRESS_2)"
  SetDetailsPrint listonly

  Delete "$SMPROGRAMS\${MUI_PRODUCT}\Support\POPFile Home Page.url"
  Delete "$SMPROGRAMS\${MUI_PRODUCT}\Support\POPFile Manual.url"
  RMDir "$SMPROGRAMS\${MUI_PRODUCT}\Support"

  Delete "$SMPROGRAMS\${MUI_PRODUCT}\Release Notes.lnk"
  Delete "$SMPROGRAMS\${MUI_PRODUCT}\Run POPFile.lnk"
  Delete "$SMPROGRAMS\${MUI_PRODUCT}\Run POPFile in background.lnk"
  Delete "$SMPROGRAMS\${MUI_PRODUCT}\Shutdown POPFile silently.lnk"
  Delete "$SMPROGRAMS\${MUI_PRODUCT}\Uninstall POPFile.lnk"

  Delete "$SMPROGRAMS\${MUI_PRODUCT}\FAQ.url"
  Delete "$SMPROGRAMS\${MUI_PRODUCT}\Manual.url"
  Delete "$SMPROGRAMS\${MUI_PRODUCT}\POPFile User Interface.url"
  Delete "$SMPROGRAMS\${MUI_PRODUCT}\Shutdown POPFile.url"
  RMDir "$SMPROGRAMS\${MUI_PRODUCT}"

  Delete "$SMSTARTUP\Run POPFile in background.lnk"
  Delete "$SMSTARTUP\Run POPFile.lnk"

  SetDetailsPrint textonly
  DetailPrint "$(un.PFI_LANG_PROGRESS_3)"
  SetDetailsPrint listonly

  Delete $INSTDIR\popfile.pl
  Delete $INSTDIR\popfile.exe
  Delete $INSTDIR\popfile.cfg.bak
  Delete $INSTDIR\*.pm
  Delete $INSTDIR\*.dll
  Delete $INSTDIR\wperl.exe

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

  IfFileExists "$INSTDIR\popfile.reg" 0 no_reg_file

  SetDetailsPrint textonly
  DetailPrint "$(un.PFI_LANG_PROGRESS_4)"
  SetDetailsPrint listonly

  ; Read the registry settings found in popfile.reg and restore them
  ; it there are any.   All are assumed to be in HKCU

  ClearErrors
  FileOpen ${L_CFG} $INSTDIR\popfile.reg r
  IfErrors skip_registry_restore
  DetailPrint "$(un.PFI_LANG_LOG_2): popfile.reg"

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
  WriteRegStr HKCU ${L_REG_KEY} ${L_REG_SUBKEY} ${L_REG_VALUE}
  DetailPrint "$(un.PFI_LANG_LOG_3) ${L_REG_SUBKEY}: ${L_REG_VALUE}"
  goto restore_loop

skip_registry_restore:
  FileClose ${L_CFG}
  DetailPrint "$(un.PFI_LANG_LOG_4): popfile.reg"
  Delete $INSTDIR\popfile.reg

no_reg_file:
  Delete $INSTDIR\Classifier\*.pm
  RMDir $INSTDIR\Classifier

  Delete $INSTDIR\Platform\*.pm
  Delete $INSTDIR\Platform\*.dll
  RMDir $INSTDIR\Platform

  Delete $INSTDIR\POPFile\*.pm
  RMDir $INSTDIR\POPFile

  Delete $INSTDIR\Proxy\*.pm
  RMDir $INSTDIR\Proxy

  Delete $INSTDIR\UI\*.pm
  RMDir $INSTDIR\UI

  SetDetailsPrint textonly
  DetailPrint "$(un.PFI_LANG_PROGRESS_5)"
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
  DetailPrint "$(un.PFI_LANG_PROGRESS_6)"
  SetDetailsPrint listonly

  RMDir /r "$INSTDIR\auto"
  RMDir /r "$INSTDIR\Carp"
  RMDir /r "$INSTDIR\Encode"
  RMDir /r "$INSTDIR\Exporter"
  RMDir /r "$INSTDIR\File"
  RMDir /r "$INSTDIR\IO"
  RMDir /r "$INSTDIR\MIME"
  RMDir /r "$INSTDIR\Sys"
  RMDir /r "$INSTDIR\Text"
  RMDir /r "$INSTDIR\warnings"
  RMDir /r "$INSTDIR\Win32"

  Delete "$INSTDIR\Uninstall.exe"

  RMDir $INSTDIR

  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_PRODUCT}"
  DeleteRegKey HKLM "SOFTWARE\${MUI_PRODUCT}"

  ; if $INSTDIR was removed, skip these next ones

  IfFileExists $INSTDIR 0 Removed
    MessageBox MB_YESNO|MB_ICONQUESTION "$(un.PFI_LANG_MBREMDIR_1)" IDNO Removed
    DetailPrint "$(un.PFI_LANG_LOG_5)"
    Delete $INSTDIR\*.* ; this would be skipped if the user hits no
    RMDir /r $INSTDIR
    IfFileExists $INSTDIR 0 Removed
      DetailPrint "$(un.PFI_LANG_LOG_6)"
      MessageBox MB_OK|MB_ICONEXCLAMATION \
          "$(un.PFI_LANG_MBREMERR_1): $INSTDIR $(un.PFI_LANG_MBREMERR_2)"
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
# End of 'installer.nsi'
#--------------------------------------------------------------------------
