#--------------------------------------------------------------------------
#
# installer.nsi --- This is the NSIS script used to create the
#                   Windows installer for POPFile. This script uses
#                   three custom pages whose layouts are defined
#                   in the files "ioA.ini", "ioB.ini" and "ioC.ini".
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
#--------------------------------------------------------------------------

; Modified to work with NSIS 2.0b4 (CVS) or later

#--------------------------------------------------------------------------
# WARNINGS:
#
# (1) This script requires "NSIS Modern User Interface" version 1.65 (17 June 2003 or later)
#     because it uses the new (simplified) page configuration system.
#
# (2) This script must be compiled with MAKENSIS.EXE dated 28 June 2003 @ 06:44 (or later)
#     (earlier versions will crash while generating the language tables)
#
#--------------------------------------------------------------------------
# LANGUAGE SUPPORT:
#
# The installer defaults to supporting a number of languages (the default is 'English').
#
# If required, a command-line switch can be used to build an English-only version.
#
# Normal multi-language build command:  makensis installer.nsi
#
# To build an English-only installer:   makensis /DENGLISH_ONLY installer.nsi
#
# To remove any of the additional languages, only TWO lines need to be commented-out:
#
# (a) comment-out the relevant '!insertmacro PFI_LANG_LOAD' line in the list of languages
#     in the 'Language Support for the installer and uninstaller' block of code
#
# (b) comment-out the relevant '!insertmacro PFI_SETTING' line in the list of languages
#     in the code which handles the 'UI Languages' component
#
# For example, to remove support for the 'Dutch' language, comment-out the
#     !insertmacro PFI_LANG_LOAD "Dutch"
# line in the list of languages supported by the installer and comment-out the
#     !insertmacro UI_LANG_CONFIG "DUTCH" "Nederlands"
# line in the code which handles the 'UI Languages' component.
#
# The number of languages which can be supported depends upon the availability of:
#
#     (1) an up-to-date main NSIS language file ({NSIS}\Contrib\Language files\*.nlf)
# _and_
#     (2) an up-to-date NSIS MUI Language file ({NSIS}\Contrib\Modern UI\Language files\*.nsh)
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# At present (02 July 2003) support for 'Bulgarian' and 'Danish' has been disabled (as described
# above) because in these two cases the corresponding NLF file is out-of-step and this could
# result in the wrong messages being displayed during the installation.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
# To add support for a language which is already supported by the NSIS MUI package, two files
# are required:
#
#   <NSIS Language NAME>-mui.nsh  - holds customised versions of the standard MUI text strings
#                                   (eg removing the 'reboot' reference from the 'Welcome' page)
#
#   <NSIS Language NAME>-pfi.nsh  - holds strings used on the custom pages and elsewhere
#
# Once these files have been prepared and placed in the 'languages' directory with the other
# *-mui.nsh and *-pfi.nsh files, add a new '!insertmacro PFI_LANG_LOAD' line to load these
# two new files and, if there is a suitable POPFile UI language file for the new language,
# add a suitable '!insertmacro UI_LANG_CONFIG' line in the section which handles the optional
# 'Languages' component to allow the installer to select the appropriate UI language.
#--------------------------------------------------------------------------

  ; POPFile constants have been given names beginning with 'C_' (eg C_README)

  !define MUI_PRODUCT   "POPFile"

  !ifndef ENGLISH_ONLY
    !define MUI_VERSION   "0.20.0 (ML)"
  !else
    !define MUI_VERSION   "0.20.0 (English)"
  !endif

  !define C_README        "v0.19.0.change"
  !define C_RELEASE_NOTES "..\engine\${C_README}"

  !include "MUI.nsh"
  !include "Sections.nsh"

#--------------------------------------------------------------------------
# Version Information settings (for the installer EXE and uninstaller EXE)
#--------------------------------------------------------------------------

  ; This feature is "under construction" (and has not yet been documented in NSIS user manual)

  ; 'VIProductVersion' format is X.X.X.X where X is a number in range 0 to 65535
  ; representing the following values: Major.Minor.Release.Build

  VIProductVersion "0.19.0.0"

  VIAddVersionKey "ProductName" "POPFile"
  VIAddVersionKey "Comments" "POPFile Homepage: http://popfile.sourceforge.net"
  VIAddVersionKey "CompanyName" "POPFile Team"
#  VIAddVersionKey "LegalTrademarks" "POPFile"
  VIAddVersionKey "LegalCopyright" "© 2001-2003  John Graham-Cumming"
  VIAddVersionKey "FileDescription" "POPFile Automatic email classification"
  VIAddVersionKey "FileVersion" "${MUI_VERSION}"

  !ifndef ENGLISH_ONLY
    VIAddVersionKey "Build" "Multi-Language (Experimental)"
  !else
    VIAddVersionKey "Build" "English-Only (Experimental)"
  !endif

  VIAddVersionKey "Build Date/Time" "${__DATE__} @ ${__TIME__}"
  VIAddVersionKey "Build Script" "${__FILE__} (${__TIMESTAMP__})"

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

  ; Select either "accept/do not accept" radio buttons or "accept" checkbox for the license page

#  !define MUI_LICENSEPAGE_RADIOBUTTONS
  !define MUI_LICENSEPAGE_CHECKBOX

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

  ; Debug aid: Allow log file checking (by clicking "Show Details" button on the "Install" page)

  !define MUI_FINISHPAGE_NOAUTOCLOSE

  ;-----------------------------------------
  ; General Settings - Other Settings
  ;-----------------------------------------

  ; Show a message box with a warning when the user closes the installation

  !define MUI_ABORTWARNING

  ;-----------------------------------------
  ; Interface Settings
  ;-----------------------------------------

  ; The "Special" bitmap appears on the "Welcome" and "Finish" pages,
  ; the "Header" bitmap appears on the other pages of the installer.

  !define MUI_SPECIALBITMAP "special.bmp"
  !define MUI_HEADERBITMAP "hdr-right.bmp"
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

  ; Use a "leave" function to look for 'popfile.cfg' in the directory selected for this install

  !define MUI_CUSTOMFUNCTION_DIRECTORY_LEAVE CheckExistingConfig

  ; Use a "pre" function for the 'Finish' page to ensure installer only offers to display
  ; POPFile User Interface if user has chosen to start POPFile from the installer.

  !define MUI_CUSTOMFUNCTION_FINISH_PRE CheckRunStatus

#--------------------------------------------------------------------------
# User Registers (Global)
#--------------------------------------------------------------------------

  ; NSIS provides 20 general purpose user registers:
  ; (a) $0 to $9 are used as global registers
  ; (b) $R0 to $R9 are used as local registers

  ; Global registers referred to by 'defines' use names starting with 'G_'

  !define G_POP3     $0   ; POP3 port (1-65535)
  !define G_GUI      $1   ; GUI port (1-65535)
  !define G_STARTUP  $2   ; automatic startup flag (1 = yes, 0 = no)
  !define G_NOTEPAD  $3   ; path to notepad.exe ("" = not found in search path)

  ; Local registers referred to by 'defines' use names starting with 'L_' (eg L_LNE, L_OLDUI)
  ; and the scope of these 'defines' is limited to the "routine" where they are used.

  ; POPFile constants have been given names beginning with 'C_' (eg C_README)

#--------------------------------------------------------------------------
# Language Support for the installer and uninstaller
#--------------------------------------------------------------------------

  ;-----------------------------------------
  ; Language Settings for MUI pages
  ;-----------------------------------------

  ; Always show the language selection dialog, even if a language has been stored in the
  ; registry (the language stored in the registry will be selected as the default language)

  !define MUI_LANGDLL_ALWAYSSHOW

  ; Remember user's language selection and offer this as the default when re-installing
  ; (uninstaller also uses this setting to determine which language is to be used)

  !define MUI_LANGDLL_REGISTRY_ROOT "HKLM"
  !define MUI_LANGDLL_REGISTRY_KEY "SOFTWARE\POPFile"
  !define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"

  ;-----------------------------------------
  ; Macros used to simplify inclusion of necessary language files
  ;-----------------------------------------

  ; Used in the '*-pfi.nsh' files to define the text strings for the installer

  !macro PFI_LANG_STRING NAME VALUE
    LangString ${NAME} ${LANG_${PFI_LANG}} "${VALUE}"
  !macroend

  ; Used in the '*-pfi.nsh' files to define the text strings for the uninstaller

  !macro PFI_LANG_UNSTRING NAME VALUE
    !insertmacro PFI_LANG_STRING "un.${NAME}" "${VALUE}"
  !macroend

  ; Used in '*-pfi.nsh' files to define the text strings for fields in a custom page INI file

  !macro PFI_IO_TEXT PATH FIELD TEXT
    WriteINIStr "$PLUGINSDIR\${PATH}" "Field ${FIELD}" "Text" "${TEXT}"
  !macroend

  ; Used in '*-pfi.nsh' files to define entries in [Settings] section of a custom page INI file

  !macro PFI_IO_SETTING PATH FIELD TEXT
    WriteINIStr "$PLUGINSDIR\${PATH}" "Settings" "${FIELD}" "${TEXT}"
  !macroend

  ; Macro used to load the three files required for each language:
  ; (1) '*-mui.nsh' contains the customisations to be applied to the standard MUI text strings
  ; (2) '*-pfi.nsh' contains the text strings used for custom pages, progress reports and logs
  ; (3) the GPL license text (at present every language uses the 'English' version of the GPL)

  !macro PFI_LANG_LOAD LANG
    !include "languages\${LANG}-mui.nsh"
    !insertmacro MUI_LANGUAGE "${LANG}"
    !include "languages\${LANG}-pfi.nsh"
    LicenseData /LANG=${LANG} "..\engine\license"
  !macroend

  ;-----------------------------------------
  ; Select the languages to be supported by installer/uninstaller.
  ; Currently a subset of the languages supported by NSIS MUI 1.65 (using the NSIS names)
  ;-----------------------------------------

  ; At least one language must be specified for the installer (the default is "English")

  !insertmacro PFI_LANG_LOAD "English"

  ; Conditional compilation: if ENGLISH_ONLY is defined, support only 'English'

  !ifndef ENGLISH_ONLY

        ; Additional languages supported by the installer.

        ; Entries will appear in the drop-down list of languages in the order given below.
        ; To remove a language, comment-out the relevant '!insertmacro PFI_LANG_LOAD' line
        ; from this list. (To remove all of these languages, use /DENGLISH_ONLY on command-line)

# [02 July 03] "Bulgarian" disabled because the main NSIS NLF language file is out of date
#        !insertmacro PFI_LANG_LOAD "Bulgarian"    ; NSIS MUI file out-of-date as of 27-Jun-03

        !insertmacro PFI_LANG_LOAD "SimpChinese"
        !insertmacro PFI_LANG_LOAD "TradChinese"

# [02 July 03]  "Danish" disabled because the main NSIS NLF language file is out of date
#        !insertmacro PFI_LANG_LOAD "Danish"       ; NSIS MUI file out-of-date as of 27-Jun-03

        !insertmacro PFI_LANG_LOAD "Dutch"
        !insertmacro PFI_LANG_LOAD "Finnish"      ; NSIS MUI file out-of-date as of 27-Jun-03
        !insertmacro PFI_LANG_LOAD "French"
        !insertmacro PFI_LANG_LOAD "German"
        !insertmacro PFI_LANG_LOAD "Hungarian"
        !insertmacro PFI_LANG_LOAD "Japanese"
        !insertmacro PFI_LANG_LOAD "Korean"
        !insertmacro PFI_LANG_LOAD "Portuguese"
        !insertmacro PFI_LANG_LOAD "PortugueseBR"
        !insertmacro PFI_LANG_LOAD "Russian"
        !insertmacro PFI_LANG_LOAD "Slovak"
        !insertmacro PFI_LANG_LOAD "Spanish"
        !insertmacro PFI_LANG_LOAD "Swedish"
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
  InstallDirRegKey HKLM SOFTWARE\POPFile InstallLocation

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
  ReserveFile "${C_RELEASE_NOTES}"

#--------------------------------------------------------------------------
# Installer Function: .onInit - installer starts by offering a choice of languages
#--------------------------------------------------------------------------

Function .onInit

  ; Conditional compilation: if ENGLISH_ONLY is defined, support only 'English'

  !ifndef ENGLISH_ONLY
        !insertmacro MUI_LANGDLL_DISPLAY
  !endif

  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioA.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioB.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioC.ini"

  !insertmacro MUI_INSTALLOPTIONS_EXTRACT_AS "${C_RELEASE_NOTES}" "release.txt"
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

  !define L_MSG   $R9   ; holds assembled 'language' string
  !define L_TXT   $R8   ; used when assembling 'language' strings

  Push ${L_MSG}
  Push ${L_TXT}

  SearchPath ${G_NOTEPAD} notepad.exe
  StrCpy ${L_MSG} "$(PFI_LANG_MBRELNOTES_1)"
  StrCpy ${L_TXT} "$(PFI_LANG_MBRELNOTES_2)"
  StrCpy ${L_MSG} "${L_MSG}$\r$\n$\r$\n${L_TXT}"
  MessageBox MB_YESNO ${L_MSG} IDNO exit
  StrCmp ${G_NOTEPAD} "" use_file_association
  ExecWait 'notepad.exe "$PLUGINSDIR\release.txt"'
  GoTo exit

use_file_association:
  ExecShell "open" "$PLUGINSDIR\release.txt"

exit:

  ; Insert appropriate language strings into the custom page INI files
  ; (the CBP package creates its own INI file so there is no need for a CBP *Page_Init function)

  Call SetOptionsPage_Init
  Call SetOutlookExpressPage_Init
  Call StartPOPFilePage_Init

  Pop ${L_TXT}
  Pop ${L_MSG}

  !undef L_MSG
  !undef L_TXT
FunctionEnd

#--------------------------------------------------------------------------
# Installer Section: POPFile component
#--------------------------------------------------------------------------

Section "POPFile" SecPOPFile

  ; Make this section mandatory (i.e. it is always installed)

  SectionIn RO

  !define L_CFG   $R9   ; file handle
  !define L_MSG   $R8   ; assembled 'language' string
  !define L_TXT   $R7   ; used when assembling 'language' string

  Push ${L_CFG}
  Push ${L_MSG}
  Push ${L_TXT}

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_UPGRADE)"
  SetDetailsPrint listonly

  ; If we are installing over a previous version, (try to) ensure that version is not running

  Call MakeItSafe

  ; Retrieve the POP3 and GUI ports from the ini and get whether we install the
  ; POPFile run in the Startup group

  !insertmacro MUI_INSTALLOPTIONS_READ ${G_POP3}    "ioA.ini" "Field 2" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ ${G_GUI}     "ioA.ini" "Field 4" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ ${G_STARTUP} "ioA.ini" "Field 5" "State"

  WriteRegStr HKLM SOFTWARE\POPFile InstallLocation $INSTDIR

  ; Install the POPFile Core files

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_CORE)"
  SetDetailsPrint listonly

  SetOutPath $INSTDIR

  File "..\engine\license"
  File "${C_RELEASE_NOTES}"
  StrCmp ${G_NOTEPAD} "" 0 readme_ok
  File /oname=${C_README}.txt "${C_RELEASE_NOTES}"

readme_ok:
  File "..\engine\popfile.pl"
  File "..\engine\insert.pl"
  File "..\engine\bayes.pl"
  File "..\engine\pipe.pl"
  File "..\engine\pix.gif"
  File "..\engine\black.gif"
  File "..\engine\otto.gif"

  IfFileExists "$INSTDIR\stopwords" 0 copy_stopwords
  StrCpy ${L_MSG} "POPFile 'stopwords' "
  StrCpy ${L_TXT} "$(PFI_LANG_MBSTPWDS_1)"
  StrCpy ${L_MSG} "${L_MSG}${L_TXT}$\r$\n$\r$\n"
  StrCpy ${L_TXT} "$(PFI_LANG_MBSTPWDS_2)"
  StrCpy ${L_MSG} "${L_MSG}${L_TXT}$\r$\n$\r$\n"
  StrCpy ${L_TXT} "$(PFI_LANG_MBSTPWDS_3)"
  StrCpy ${L_MSG} "${L_MSG}${L_TXT} 'stopwords.bak')$\r$\n$\r$\n"
  StrCpy ${L_TXT} "$(PFI_LANG_MBSTPWDS_4)"
  StrCpy ${L_MSG} "${L_MSG}${L_TXT} 'stopwords.default')"
  MessageBox MB_YESNO ${L_MSG} IDNO copy_default_stopwords
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
  FileWrite ${L_CFG} "pop3_port ${G_POP3}$\r$\n"
  FileWrite ${L_CFG} "html_port ${G_GUI}$\r$\n"
  FileClose ${L_CFG}
  IfFileExists "$INSTDIR\popfile.cfg" 0 update_config
  SetFileAttributes "$INSTDIR\popfile.cfg" NORMAL
  IfFileExists "$INSTDIR\popfile.cfg.bak" 0 make_cfg_backup
  StrCpy ${L_MSG} "$(PFI_LANG_MBCFGBK_1)"
  StrCpy ${L_TXT} "$(PFI_LANG_MBCFGBK_2)"
  StrCpy ${L_MSG} "${L_MSG} 'popfile.cfg' ${L_TXT} ('popfile.cfg.bak').$\r$\n$\r$\n"
  StrCpy ${L_TXT} "$(PFI_LANG_MBCFGBK_3)"
  StrCpy ${L_MSG} "${L_MSG}${L_TXT}$\r$\n$\r$\n"
  StrCpy ${L_TXT} "$(PFI_LANG_MBCFGBK_4)"
  StrCpy ${L_MSG} "${L_MSG}${L_TXT}"
  MessageBox MB_YESNO "${L_MSG}" IDNO update_config
  SetFileAttributes "$INSTDIR\popfile.cfg.bak" NORMAL

make_cfg_backup:
  CopyFiles /SILENT /FILESONLY $INSTDIR\popfile.cfg $INSTDIR\popfile.cfg.bak

update_config:
  CopyFiles /SILENT /FILESONLY $PLUGINSDIR\popfile.cfg $INSTDIR\

  SetOutPath $INSTDIR\Classifier
  File "..\engine\Classifier\Bayes.pm"
  File "..\engine\Classifier\WordMangle.pm"
  File "..\engine\Classifier\MailParse.pm"
  SetOutPath $INSTDIR\POPFile
  File "..\engine\POPFile\MQ.pm"
  File "..\engine\POPFile\Logger.pm"
  File "..\engine\POPFile\Module.pm"
  File "..\engine\POPFile\Configuration.pm"
  SetOutPath $INSTDIR\Proxy
  File "..\engine\Proxy\Proxy.pm"
  File "..\engine\Proxy\POP3.pm"
  SetOutPath $INSTDIR\Platform
  File "..\engine\Platform\MSWin32.pm"
  File "..\engine\Platform\POPFileIcon.dll"
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
  File "C:\Perl\bin\perl.exe"
  File "C:\Perl\bin\wperl.exe"
  File "C:\Perl\bin\perl58.dll"
  File "C:\Perl\lib\AutoLoader.pm"
  File "C:\Perl\lib\Carp.pm"
  File "C:\Perl\lib\Config.pm"
  File "C:\Perl\lib\DynaLoader.pm"
  File "C:\Perl\lib\Errno.pm"
  File "C:\Perl\lib\Exporter.pm"
  File "C:\Perl\lib\IO.pm"
  File "C:\Perl\lib\integer.pm"
  File "C:\Perl\lib\locale.pm"
  File "C:\Perl\lib\POSIX.pm"
  File "C:\Perl\lib\SelectSaver.pm"
  File "C:\Perl\lib\Socket.pm"
  File "C:\Perl\lib\strict.pm"
  File "C:\Perl\lib\Symbol.pm"
  File "C:\Perl\lib\vars.pm"
  File "C:\Perl\lib\warnings.pm"
  File "C:\Perl\lib\XSLoader.pm"

  SetOutPath $INSTDIR\Carp
  File "C:\Perl\lib\Carp\*"

  SetOutPath $INSTDIR\Exporter
  File "C:\Perl\lib\Exporter\*"

  SetOutPath $INSTDIR\MIME
  File "C:\Perl\lib\MIME\*"

  SetOutPath $INSTDIR\Win32
  File "C:\Perl\site\lib\Win32\API.pm"

  SetOutPath $INSTDIR\Win32\API
  File "C:\Perl\site\lib\Win32\API\*.pm"

  SetOutPath $INSTDIR\auto\Win32\API
  File "C:\Perl\site\lib\auto\Win32\API\*"

  SetOutPath $INSTDIR\IO
  File "C:\Perl\lib\IO\*"

  SetOutPath $INSTDIR\Sys
  File "C:\Perl\lib\Sys\*"

  SetOutPath $INSTDIR\Text
  File "C:\Perl\lib\Text\ParseWords.pm"

  SetOutPath $INSTDIR\IO\Socket
  File "C:\Perl\lib\IO\Socket\*"

  SetOutPath $INSTDIR\auto\DynaLoader
  File "C:\Perl\lib\auto\DynaLoader\*"

  SetOutPath $INSTDIR\auto\File\Glob
  File "C:\Perl\lib\auto\File\Glob\*"

  SetOutPath $INSTDIR\auto\MIME\Base64
  File "C:\Perl\lib\auto\MIME\Base64\*"

  SetOutPath $INSTDIR\auto\IO
  File "C:\Perl\lib\auto\IO\*"

  SetOutPath $INSTDIR\auto\Socket
  File "C:\Perl\lib\auto\Socket\*"

  SetOutPath $INSTDIR\auto\Sys\Hostname
  File "C:\Perl\lib\auto\Sys\Hostname\*"

  SetOutPath $INSTDIR\auto\POSIX
  File "C:\Perl\lib\auto\POSIX\POSIX.dll"
  File "C:\Perl\lib\auto\POSIX\autosplit.ix"
  File "C:\Perl\lib\auto\POSIX\load_imports.al"

  SetOutPath $INSTDIR\File
  File "C:\Perl\lib\File\Glob.pm"

  SetOutPath $INSTDIR\warnings
  File "C:\Perl\lib\warnings\register.pm"

  ; Create the uninstall program BEFORE creating the shortcut to it
  ; (this ensures that the correct "uninstall" icon appears in the START MENU shortcut)

  SetOutPath $INSTDIR
  Delete $INSTDIR\uninstall.exe
  WriteUninstaller $INSTDIR\uninstall.exe

  ; Create the START MENU entries

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_SHORT)"
  SetDetailsPrint listonly

  SetOutPath $SMPROGRAMS\POPFile
  SetOutPath $INSTDIR
  CreateShortCut "$SMPROGRAMS\POPFile\Run POPFile.lnk" \
                 "$INSTDIR\perl.exe" popfile.pl \
                 "$INSTDIR\Platform\POPFileIcon.dll"
  CreateShortCut "$SMPROGRAMS\POPFile\Run POPFile in background.lnk" \
                 "$INSTDIR\wperl.exe" popfile.pl \
                 "$INSTDIR\Platform\POPFileIcon.dll"
  CreateShortCut "$SMPROGRAMS\POPFile\Uninstall POPFile.lnk" \
                 "$INSTDIR\uninstall.exe"
  SetOutPath $SMPROGRAMS\POPFile
  WriteINIStr "$SMPROGRAMS\POPFile\POPFile User Interface.url" \
              "InternetShortcut" "URL" "http://127.0.0.1:${G_GUI}/"
  WriteINIStr "$SMPROGRAMS\POPFile\Shutdown POPFile.url" \
              "InternetShortcut" "URL" "http://127.0.0.1:${G_GUI}/shutdown"
  WriteINIStr "$SMPROGRAMS\POPFile\Manual.url" \
              "InternetShortcut" "URL" "file://$INSTDIR/manual/en/manual.html"
  WriteINIStr "$SMPROGRAMS\POPFile\FAQ.url" \
              "InternetShortcut" "URL" \
              "http://sourceforge.net/docman/display_doc.php?docid=14421&group_id=63137"
  SetOutPath $SMPROGRAMS\POPFile\Support
  WriteINIStr "$SMPROGRAMS\POPFile\Support\POPFile Home Page.url" \
              "InternetShortcut" "URL" "http://popfile.sourceforge.net/"

  StrCmp ${G_STARTUP} "1" 0 skip_autostart_set
      SetOutPath $SMSTARTUP
      SetOutPath $INSTDIR
      CreateShortCut "$SMSTARTUP\Run POPFile in background.lnk" \
                     "$INSTDIR\wperl.exe" popfile.pl \
                     "$INSTDIR\Platform\POPFileIcon.dll"
skip_autostart_set:

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

  Pop ${L_TXT}
  Pop ${L_MSG}
  Pop ${L_CFG}

  !undef L_CFG
  !undef L_MSG
  !undef L_TXT

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
# defines the mapping between NSIS language name and POPFile UI language name. This
# macro will only preset the UI language if the required UI language file is present.
# If no match is found or if the UI language file is not present, the default UI language
# is used (it is left to POPFile to determine which language to use).
#--------------------------------------------------------------------------

Section "Languages" SecLangs

  ; Macro to simplify the code which selects a UI language based upon the installer language
  ; (the installer uses NSIS language names which differ from the names used by POPFile's UI)

  !macro UI_LANG_CONFIG PFI_SETTING UI_SETTING
    StrCmp $LANGUAGE ${LANG_${PFI_SETTING}} 0 +4
      IfFileExists "$INSTDIR\languages\${UI_SETTING}.msg" 0 lang_done
      StrCpy ${L_LANG} "${UI_SETTING}"
      Goto lang_save
  !macroend

  !define L_CFG   $R9   ; file handle
  !define L_LANG  $R8

  Push ${L_CFG}
  Push ${L_LANG}

  StrCpy ${L_LANG} ""     ; assume default POPFile UI language will be used.

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_LANGS)"
  SetDetailsPrint listonly

  SetOutPath $INSTDIR\languages
  File "..\engine\languages\*.msg"

  ; Conditional compilation: if ENGLISH_ONLY is defined, installer supports only 'English'
  ; so there is no need to select a language for the POPFile UI

  !ifndef ENGLISH_ONLY

        ; UI_LANG_CONFIG parameters: "NSIS Language name"  "POPFile UI language name"

        !insertmacro UI_LANG_CONFIG "ENGLISH" "English"

# [02 July 03] "Bulgarian" disabled because the main NSIS NLF language file is out of date
#        !insertmacro UI_LANG_CONFIG "BULGARIAN" "Bulgarian"

        !insertmacro UI_LANG_CONFIG "SIMPCHINESE" "Chinese-Simplified"
        !insertmacro UI_LANG_CONFIG "TRADCHINESE" "Chinese-Traditional"

# [02 July 03]  "Danish" disabled because the main NSIS NLF language file is out of date
#        !insertmacro UI_LANG_CONFIG "DANISH" "Dansk"

        !insertmacro UI_LANG_CONFIG "DUTCH" "Nederlands"
        !insertmacro UI_LANG_CONFIG "FINNISH" "Suomi"
        !insertmacro UI_LANG_CONFIG "FRENCH" "Francais"
        !insertmacro UI_LANG_CONFIG "GERMAN" "Deutsch"
        !insertmacro UI_LANG_CONFIG "HUNGARIAN" "Hungarian"
        !insertmacro UI_LANG_CONFIG "JAPANESE" "Nihongo"
        !insertmacro UI_LANG_CONFIG "KOREAN" "Korean"
        !insertmacro UI_LANG_CONFIG "PORTUGUESE" "Português"
        !insertmacro UI_LANG_CONFIG "PORTUGUESEBR" "Português do Brasil"
        !insertmacro UI_LANG_CONFIG "RUSSIAN" "Russian"
        !insertmacro UI_LANG_CONFIG "SLOVAK" "Slovak"
        !insertmacro UI_LANG_CONFIG "SPANISH" "Español"
        !insertmacro UI_LANG_CONFIG "SWEDISH" "Svenska"
        !insertmacro UI_LANG_CONFIG "UKRAINIAN" "Ukrainian"

        ; at this point, no match was found so we use the default POPFile UI language
        ; (and leave it to POPFile to determine which language to use)

        goto lang_done

      lang_save:
        FileOpen  ${L_CFG} $INSTDIR\popfile.cfg a
        FileSeek  ${L_CFG} 0 END
        FileWrite ${L_CFG} "html_language ${L_LANG}$\r$\n"
        FileClose ${L_CFG}

      lang_done:
  !endif

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_ENDSEC)"
  SetDetailsPrint listonly

  Pop ${L_LANG}
  Pop ${L_CFG}

  !undef L_CFG
  !undef L_LANG

SectionEnd

#--------------------------------------------------------------------------
# Component-selection page descriptions
#--------------------------------------------------------------------------

  !insertmacro MUI_FUNCTIONS_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecPOPFile} $(DESC_SecPOPFile)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecSkins}   $(DESC_SecSkins)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecLangs}   $(DESC_SecLangs)
  !insertmacro MUI_FUNCTIONS_DESCRIPTION_END

#--------------------------------------------------------------------------
# Installer Function: MakeItSafe
#
# If we are installing on top of a previous installation, we try to shut it down
# (to allow the files to be overwritten without requiring a reboot)
#--------------------------------------------------------------------------

Function MakeItSafe

  !define L_CFG      $R9    ; file handle
  !define L_NEW_GUI  $R8
  !define L_OLD_GUI  $R7
  !define L_RESULT   $R6

  Push ${L_CFG}
  Push ${L_NEW_GUI}
  Push ${L_OLD_GUI}
  Push ${L_RESULT}

  ; A quick test ignoring fact that popfile.cfg may specify a non-default location for PID file

  IfFileExists "$INSTDIR\popfile.pid" attempt_shutdown

  ; If we are about to overwrite an existing version which is still running,
  ; then one of the EXE files will be 'locked' which means we have to shutdown POPFile

  IfFileExists "$INSTDIR\wperl.exe" 0 other_perl
  SetFileAttributes "$INSTDIR\wperl.exe" NORMAL
  ClearErrors
  FileOpen ${L_CFG} "$INSTDIR\wperl.exe" a
  FileClose ${L_CFG}
  IfErrors attempt_shutdown

other_perl:
  IfFileExists "$INSTDIR\perl.exe" 0 exit_now
  SetFileAttributes "$INSTDIR\perl.exe" NORMAL
  ClearErrors
  FileOpen ${L_CFG} "$INSTDIR\perl.exe" a
  FileClose ${L_CFG}
  IfErrors 0 exit_now

attempt_shutdown:
  !insertmacro MUI_INSTALLOPTIONS_READ "${L_NEW_GUI}" "ioA.ini" "UI Port" "NewStyle"
  !insertmacro MUI_INSTALLOPTIONS_READ "${L_OLD_GUI}" "ioA.ini" "UI Port" "OldStyle"

  Push ${L_OLD_GUI}
  Call StrCheckDecimal
  Pop ${L_OLD_GUI}
  StrCmp ${L_OLD_GUI} "" try_other_port

  StrCpy ${L_RESULT} "$(PFI_LANG_INST_LOG_1)"
  DetailPrint "${L_RESULT} ${L_OLD_GUI}"
  NSISdl::download_quiet http://127.0.0.1:${L_OLD_GUI}/shutdown "$PLUGINSDIR\shutdown.htm"
  Sleep 250 ; milliseconds
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "success" exit_now

try_other_port:
  Push ${L_NEW_GUI}
  Call StrCheckDecimal
  Pop ${L_NEW_GUI}
  StrCmp ${L_NEW_GUI} "" exit_now

  StrCpy ${L_RESULT} "$(PFI_LANG_INST_LOG_1)"
  DetailPrint "${L_RESULT} ${L_NEW_GUI}"
  NSISdl::download_quiet http://127.0.0.1:${L_NEW_GUI}/shutdown "$PLUGINSDIR\shutdown.htm"
  Sleep 250 ; milliseconds
  Pop ${L_RESULT} ; Ignore the result

exit_now:
  Pop ${L_RESULT}
  Pop ${L_OLD_GUI}
  Pop ${L_NEW_GUI}
  Pop ${L_CFG}

  !undef L_CFG
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
# 'Languages' component for further details).
#--------------------------------------------------------------------------

Function CheckExistingConfig

  !define L_CFG       $R9     ; handle for "popfile.cfg"
  !define L_CLEANCFG  $R8     ; handle for "clean" copy
  !define L_CMPRE     $R7     ; config param name
  !define L_LNE       $R6     ; a line from popfile.cfg
  !define L_OLDUI     $R5     ; used to hold old-style of GUI port
  !define L_STRIPLANG $R4

  Push ${L_CFG}
  Push ${L_CLEANCFG}
  Push ${L_CMPRE}
  Push ${L_LNE}
  Push ${L_OLDUI}
  Push ${L_STRIPLANG}

  ; If the 'Languages' component is being installed, installer is allowed to preset UI language

  !insertmacro SectionFlagIsSet ${SecLangs} 1 strip nostrip

strip:
  StrCpy ${L_STRIPLANG} "yes"
  Goto init_port_vars

nostrip:
  StrCpy ${L_STRIPLANG} ""

init_port_vars:
  StrCpy ${G_POP3} ""
  StrCpy ${G_GUI} ""
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

  StrCmp ${L_STRIPLANG} "" transfer

  ; do not transfer any UI language settings to the copy of popfile.cfg

  StrCpy ${L_CMPRE} ${L_LNE} 9
  StrCmp ${L_CMPRE} "language " loop
  StrCpy ${L_CMPRE} ${L_LNE} 14
  StrCmp ${L_CMPRE} "html_language " loop

transfer:
  FileWrite  ${L_CLEANCFG} ${L_LNE}
  Goto loop

got_port:
  StrCpy ${G_POP3} ${L_LNE} 5 5
  Goto loop

got_pop3_port:
  StrCpy ${G_POP3} ${L_LNE} 5 10
  Goto loop

got_ui_port:
  StrCpy ${L_OLDUI} ${L_LNE} 5 8
  Goto loop

got_html_port:
  StrCpy ${G_GUI} ${L_LNE} 5 10
  Goto loop

done:
  FileClose ${L_CFG}
  FileClose ${L_CLEANCFG}

  Push ${G_POP3}
  Call TrimNewlines
  Pop ${G_POP3}

  Push ${G_GUI}
  Call TrimNewlines
  Pop ${G_GUI}

  Push ${L_OLDUI}
  Call TrimNewlines
  Pop ${L_OLDUI}

  ; Save the UI port settings (from popfile.cfg) for later use by the 'MakeItSafe' function

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioA.ini" "UI Port" "NewStyle" "${G_GUI}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioA.ini" "UI Port" "OldStyle" "${L_OLDUI}"

  ; The 'port' and 'pop3_port' settings are treated as equals so we use the last entry found.
  ; If 'ui_port' and 'html_port' settings were found, we use the last 'html_port' we found.

  StrCmp ${G_GUI} "" 0 validity_checks
  StrCpy ${G_GUI} ${L_OLDUI}

validity_checks:

  ; check port values (config file may have no port data or invalid port data)

  StrCmp ${G_POP3} ${G_GUI} 0 ports_differ

  ; Config file has no port data or same port used for POP3 and GUI
  ; (i.e. the data is not valid), so use POPFile defaults

  StrCpy ${G_POP3} "110"
  StrCpy ${G_GUI} "8080"
  Goto ports_ok

ports_differ:
  StrCmp ${G_POP3} "" default_pop3
  Push ${G_POP3}
  Call StrCheckDecimal
  Pop ${G_POP3}
  StrCmp ${G_POP3} "" default_pop3
  IntCmp ${G_POP3} 1 pop3_ok default_pop3
  IntCmp ${G_POP3} 65535 pop3_ok pop3_ok

default_pop3:
  StrCpy ${G_POP3} "110"
  StrCmp ${G_POP3} ${G_GUI} 0 pop3_ok
  StrCpy ${G_POP3} "111"

pop3_ok:
  StrCmp ${G_GUI} "" default_gui
  Push ${G_GUI}
  Call StrCheckDecimal
  Pop ${G_GUI}
  StrCmp ${G_GUI} "" default_gui
  IntCmp ${G_GUI} 1 ports_ok default_gui
  IntCmp ${G_GUI} 65535 ports_ok ports_ok

default_gui:
  StrCpy ${G_GUI} "8080"
  StrCmp ${G_POP3} ${G_GUI} 0 ports_ok
  StrCpy ${G_GUI} "8081"

ports_ok:

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
# whether or not POPFile should be started automatically.
#
# A "leave" function (CheckPortOptions) is used to validate the port
# selections made by the user.
#--------------------------------------------------------------------------

Function SetOptionsPage

  !define L_PORTLIST  $R9   ; combo box ports list
  !define L_RESULT    $R8

  Push ${L_PORTLIST}
  Push ${L_RESULT}

  ; The function "CheckExistingConfig" loads ${G_POP3} and ${G_GUI} with the settings found in
  ; a previously installed "popfile.cfg" file or if no such file is found, it loads the
  ; POPFile default values. Now we display these settings and allow the user to change them.

  ; The POP3 and GUI port numbers must be in the range 1 to 65535 inclusive, and they
  ; must be different. This function assumes that the values "CheckExistingConfig" has loaded
  ; into ${G_POP3} and ${G_GUI} are valid.

  !insertmacro MUI_HEADER_TEXT "$(PFI_LANG_OPTIONS_TITLE)" "$(PFI_LANG_OPTIONS_SUBTITLE)"

  ; If the POP3 (or GUI) port determined by "CheckExistingConfig" is not present in the list of
  ; possible values for the POP3 (or GUI) combobox, add it to the end of the list.

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_PORTLIST} "ioA.ini" "Field 2" "ListItems"
  Push |${L_PORTLIST}|
  Push |${G_POP3}|
  Call StrStr
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "" 0 POP3_is_in_list
  StrCpy ${L_PORTLIST} ${L_PORTLIST}|${G_POP3}
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioA.ini" "Field 2" "ListItems" ${L_PORTLIST}

POP3_is_in_list:
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_PORTLIST} "ioA.ini" "Field 4" "ListItems"
  Push |${L_PORTLIST}|
  Push |${G_GUI}|
  Call StrStr
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "" 0 GUI_is_in_list
  StrCpy ${L_PORTLIST} ${L_PORTLIST}|${G_GUI}
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioA.ini" "Field 4" "ListItems" ${L_PORTLIST}

GUI_is_in_list:

  ; If the StartUp folder contains a link to start POPFile automatically
  ; then offer to keep this facility in place.

  IfFileExists "$SMSTARTUP\Run POPFile in background.lnk" 0 show_defaults
    !insertmacro MUI_INSTALLOPTIONS_WRITE "ioA.ini" "Field 5" "State" 1

show_defaults:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioA.ini" "Field 2" "State" ${G_POP3}
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioA.ini" "Field 4" "State" ${G_GUI}

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

  !define L_MSG       $R9
  !define L_RESULT    $R8
  !define L_TXT       $R7

  Push ${L_MSG}
  Push ${L_RESULT}
  Push ${L_TXT}

  !insertmacro MUI_INSTALLOPTIONS_READ ${G_POP3} "ioA.ini" "Field 2" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ ${G_GUI} "ioA.ini" "Field 4" "State"

  StrCmp ${G_POP3} ${G_GUI} ports_must_differ
  Push ${G_POP3}
  Call StrCheckDecimal
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "" bad_pop3
  IntCmp ${G_POP3} 1 pop3_ok bad_pop3
  IntCmp ${G_POP3} 65535 pop3_ok pop3_ok

bad_pop3:
  StrCpy ${L_MSG} "$(PFI_LANG_OPTIONS_MBPOP3_1)"
  StrCpy ${L_TXT} "$(PFI_LANG_OPTIONS_MBPOP3_2)"
  StrCpy ${L_MSG} "${L_MSG} $\"${G_POP3}$\"'.$\n$\n${L_TXT}$\n$\n"
  StrCpy ${L_TXT} "$(PFI_LANG_OPTIONS_MBPOP3_3)"
  StrCpy ${L_MSG} "${L_MSG}${L_TXT}"
  MessageBox MB_OK ${L_MSG}
  Goto bad_exit

pop3_ok:
  Push ${G_GUI}
  Call StrCheckDecimal
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "" bad_gui
  IntCmp ${G_GUI} 1 good_exit bad_gui
  IntCmp ${G_GUI} 65535 good_exit good_exit

bad_gui:
  StrCpy ${L_MSG} "$(PFI_LANG_OPTIONS_MBGUI_1)"
  StrCpy ${L_TXT} "$(PFI_LANG_OPTIONS_MBGUI_2)"
  StrCpy ${L_MSG} "${L_MSG} $\"${G_GUI}$\".$\n$\n${L_TXT}$\n$\n"
  StrCpy ${L_TXT} "$(PFI_LANG_OPTIONS_MBGUI_3)"
  StrCpy ${L_MSG} "${L_MSG}${L_TXT}"
  MessageBox MB_OK ${L_MSG}
  Goto bad_exit

ports_must_differ:
  StrCpy ${L_MSG} "$(PFI_LANG_OPTIONS_MBDIFF_1)"
  StrCpy ${L_TXT} "$(PFI_LANG_OPTIONS_MBDIFF_2)"
  StrCpy ${L_MSG} "${L_MSG}$\n$\n${L_TXT}"
  MessageBox MB_OK ${L_MSG}

bad_exit:

  ; Stay with the custom page created by "SetOptionsPage"

  Pop ${L_TXT}
  Pop ${L_RESULT}
  Pop ${L_MSG}
  Abort

good_exit:

  ; Allow next page in the installation sequence to be shown

  Pop ${L_TXT}
  Pop ${L_RESULT}
  Pop ${L_MSG}

  !undef L_MSG
  !undef L_RESULT
  !undef L_TXT

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
  !define LG_TEMP        $9   ; a global register "borrowed" for use locally

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
  Push ${LG_TEMP}

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

  ReadRegDWORD ${LG_TEMP} HKCU "Identities\${L_GUID}" "Identity Ordinal"
  IntCmp ${LG_TEMP} 1 firstOrdinal noOrdinals otherOrdinal

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
  Pop ${LG_TEMP}
  StrCmp ${LG_TEMP} "" 0 try_next_account

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
  Pop ${LG_TEMP}
  StrCmp ${LG_TEMP} "" 0 try_next_account

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 9" "Text" ${L_OEDATA}

  ; Find the Username used by OE for this identity and the OE Account Name
  ; (so we can unambiguously report which email account we are offering to reconfigure).

  ReadRegStr ${L_IDENTITY} HKCU "Identities\${L_GUID}\" "Username"
  StrCpy ${L_IDENTITY} $\"${L_IDENTITY}$\"
  ReadRegStr ${L_OEDATA} HKCU ${L_ACCOUNT} "Account Name"
  StrCpy ${L_OEDATA} $\"${L_OEDATA}$\"
  StrCpy ${LG_TEMP} "$(PFI_LANG_OECFG_IO_LINK_1)"
  StrCpy ${L_OEDATA} "${L_OEDATA} ${LG_TEMP} ${L_IDENTITY} "
  StrCpy ${LG_TEMP} "$(PFI_LANG_OECFG_IO_LINK_2)"
  StrCpy ${L_OEDATA} "${L_OEDATA}${LG_TEMP}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioB.ini" "Field 10" "Text" "${L_OEDATA}"

  ; Display the OE account data and offer to configure this account to work with POPFile

  !insertmacro MUI_INSTALLOPTIONS_DISPLAY_RETURN "ioB.ini"
  Pop ${LG_TEMP}

  StrCmp ${LG_TEMP} "cancel" finished_this_guid
  StrCmp ${LG_TEMP} "back" finished_this_guid

  ; Has the user ticked the 'configure this account' check box ?

  !insertmacro MUI_INSTALLOPTIONS_READ ${LG_TEMP} "ioB.ini" "Field 2" "State"
  StrCmp ${LG_TEMP} "1" change_oe try_next_account

change_oe:
  ReadRegStr ${L_OEDATA} HKCU ${L_ACCOUNT} "POP3 User Name"
  ReadRegStr ${LG_TEMP} HKCU ${L_ACCOUNT} "POP3 Server"

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
  FileWrite ${L_CFG} "${LG_TEMP}$\n"
  FileClose ${L_CFG}

  WriteRegStr HKCU ${L_ACCOUNT} "POP3 User Name" "${LG_TEMP}${L_SEPARATOR}${L_OEDATA}"
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

  Pop ${LG_TEMP}
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
  !undef LG_TEMP

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: StartPOPFilePage_Init (adds language texts to custom page INI file)
#
# This function adds language texts to the INI file used by the "StartPOPFilePage" function
# (to make the custom page use the language selected by the user for the installer)
#--------------------------------------------------------------------------

Function StartPOPFilePage_Init

  !define L_MSG   $R9
  !define L_TXT   $R8

  Push ${L_MSG}
  Push ${L_TXT}

  !insertmacro PFI_IO_TEXT "ioC.ini" "1" "$(PFI_LANG_LAUNCH_IO_INTRO)"
  !insertmacro PFI_IO_TEXT "ioC.ini" "2" "$(PFI_LANG_LAUNCH_IO_NO)"
  !insertmacro PFI_IO_TEXT "ioC.ini" "3" "$(PFI_LANG_LAUNCH_IO_DOSBOX)"
  !insertmacro PFI_IO_TEXT "ioC.ini" "4" "$(PFI_LANG_LAUNCH_IO_BCKGRND)"

  StrCpy ${L_MSG} "$(PFI_LANG_LAUNCH_IO_NOTE_1)"
  StrCpy ${L_TXT} "$(PFI_LANG_LAUNCH_IO_NOTE_2)"
  StrCpy ${L_MSG} "${L_MSG}\r\n\r\n${L_TXT}"
  StrCpy ${L_TXT} "$(PFI_LANG_LAUNCH_IO_NOTE_3)"
  StrCpy ${L_MSG} "${L_MSG}\r\n\r\n${L_TXT}"
  !insertmacro PFI_IO_TEXT "ioC.ini" "6" "${L_MSG}"

  Pop ${L_TXT}
  Pop ${L_MSG}

  !undef L_MSG
  !undef L_TXT

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

  NSISdl::download_quiet http://127.0.0.1:${G_GUI}/shutdown "$PLUGINSDIR\shutdown.htm"
  Pop ${L_RESULT}    ; Get the return value (and ignore it)
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

  NSISdl::download_quiet http://127.0.0.1:${G_GUI}/shutdown "$PLUGINSDIR\shutdown.htm"
  Pop ${L_RESULT}    ; Get the return value (and ignore it)
  Sleep 250 ; milliseconds

  ExecShell "open" "$SMPROGRAMS\POPFile\Run POPFile.lnk"
  goto wait_for_popfile

run_in_background:

  ; Run POPFile without a DOS box

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioC.ini" "Run Status" "LastAction"
  StrCmp ${L_TEMP} "background" exit_without_banner
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioC.ini" "Run Status" "LastAction" "background"

  Banner::show /NOUNLOAD /set 76 "$(PFI_LANG_LAUNCH_BANNER_1)" "$(PFI_LANG_LAUNCH_BANNER_2)"

  ; Before starting the newly installed POPFile, ensure that no other version of POPFile
  ; is running on the same UI port as the newly installed version.

  NSISdl::download_quiet http://127.0.0.1:${G_GUI}/shutdown "$PLUGINSDIR\shutdown.htm"
  Pop ${L_RESULT}    ; Get the return value (and ignore it)
  Sleep 250 ; milliseconds

  ExecShell "open" "$SMPROGRAMS\POPFile\Run POPFile in background.lnk"

wait_for_popfile:

  ; Wait until POPFile is ready to display the UI (may take a second or so)

  StrCpy ${L_TEMP} 10   ; Timeout limit to avoid an infinite loop

check_if_ready:
  NSISdl::download_quiet http://127.0.0.1:${G_GUI} "$PLUGINSDIR\ui.htm"
  Pop ${L_RESULT}                        ; Did POPFile return an HTML page?
  StrCmp ${L_RESULT} "success" remove_banner
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

  ; Get the status of the 'Do not run POPFile' radio button on the previous page of installer

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

  ExecShell "open" "http://127.0.0.1:${G_GUI}"

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: ShowReadMe
# (the "ReadMe" function for the 'Finish' page)
#--------------------------------------------------------------------------

Function ShowReadMe

  StrCmp ${G_NOTEPAD} "" use_file_association
  Exec 'notepad.exe "$INSTDIR\${C_README}"'
  goto exit

use_file_association:
  ExecShell "open" "$INSTDIR\${C_README}.txt"

exit:
FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: GetSeparator
#
# Returns the character to be used as the separator when configuring an e-mail account.
# If the character is not defined in popfile.cfg, the default separator (':') is returned
#
# Inputs:
#         none
# Outputs:
#         (top of stack)     - character to be used as the separator
#
#  Usage:
#    Call GetSeparator
#    Pop $R0
#
#   ($R0 at this point is ":" unless popfile.cfg has altered the default setting)
#
#--------------------------------------------------------------------------

Function GetSeparator

  !define L_CFG         $R9   ; file handle
  !define L_LNE         $R8   ; a line from the popfile.cfg file
  !define L_PARAM       $R7
  !define L_SEPARATOR   $R6   ; character used to separate the pop3 server from the username

  Push ${L_SEPARATOR}
  Push ${L_CFG}
  Push ${L_LNE}
  Push ${L_PARAM}

  StrCpy ${L_SEPARATOR} ""

  ClearErrors

  FileOpen  ${L_CFG} $INSTDIR\popfile.cfg r

loop:
  FileRead   ${L_CFG} ${L_LNE}
  IfErrors separator_done

  StrCpy ${L_PARAM} ${L_LNE} 10
  StrCmp ${L_PARAM} "separator " old_separator
  StrCpy ${L_PARAM} ${L_LNE} 15
  StrCmp ${L_PARAM} "pop3_separator " new_separator
  Goto loop

old_separator:
  StrCpy ${L_SEPARATOR} ${L_LNE} 1 10
  Goto loop

new_separator:
  StrCpy ${L_SEPARATOR} ${L_LNE} 1 15
  Goto loop

separator_done:
  FileClose ${L_CFG}
  Push ${L_SEPARATOR}
  Call TrimNewlines
  Pop ${L_SEPARATOR}

  ; Use separator character from popfile.cfg (if present) otherwise use a semicolon

  StrCmp ${L_SEPARATOR} "" 0 exit
  StrCpy ${L_SEPARATOR} ":"

exit:
  Pop ${L_PARAM}
  Pop ${L_LNE}
  Pop ${L_CFG}
  Exch ${L_SEPARATOR}

  !undef L_CFG
  !undef L_LNE
  !undef L_PARAM
  !undef L_SEPARATOR

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: StrStr
#
# Search for matching string
#
# Inputs:
#         (top of stack)     - the string to be found (needle)
#         (top of stack - 1) - the string to be searched (haystack)
# Outputs:
#         (top of stack)     - string starting with the match, if any
#
#  Usage:
#    Push "this is a long string"
#    Push "long"
#    Call StrStr
#    Pop $R0
#   ($R0 at this point is "long string")
#
#--------------------------------------------------------------------------

Function StrStr
  Exch $R1    ; Make $R1 the "needle", Top of stack = old$R1, haystack
  Exch        ; Top of stack = haystack, old$R1
  Exch $R2    ; Make $R2 the "haystack", Top of stack = old$R2, old$R1

  Push $R3    ; Length of the needle
  Push $R4    ; Counter
  Push $R5    ; Temp

  StrLen $R3 $R1
  StrCpy $R4 0

loop:
  StrCpy $R5 $R2 $R3 $R4
  StrCmp $R5 $R1 done
  StrCmp $R5 "" done
  IntOp $R4 $R4 + 1
  Goto loop

done:
  StrCpy $R1 $R2 "" $R4

  Pop $R5
  Pop $R4
  Pop $R3

  Pop $R2
  Exch $R1
FunctionEnd

#--------------------------------------------------------------------------
# Macro: StrCheckDecimal
#
# The installation process and the uninstall process both use a function which checks if
# a given string contains a decimal number. This macro makes maintenance easier by ensuring
# that both processes use identical functions, with the only difference being their names.
#
# The 'StrCheckDecimal' and 'un.StrCheckDecimal' functions check that a given string contains
# only the digits 0 to 9. (if the string contains any invalid characters, "" is returned)
#
# Inputs:
#         (top of stack)   - string which may contain a decimal number
#
# Outputs:
#         (top of stack)   - the input string (if valid) or "" (if invalid)
#
# Usage:
#         Push "12345"
#         Call StrCheckDecimal
#         Pop $R0
#         ($R0 at this point is "12345")
#
#--------------------------------------------------------------------------
!macro StrCheckDecimal UN
  Function ${UN}StrCheckDecimal

    !define DECIMAL_DIGIT    "0123456789"

    Exch $0   ; The input string
    Push $1   ; Holds the result: either "" (if input is invalid) or the input string (if valid)
    Push $2   ; A character from the input string
    Push $3   ; The offset to a character in the "validity check" string
    Push $4   ; A character from the "validity check" string
    Push $5   ; Holds the current "validity check" string

    StrCpy $1 ""

  next_input_char:
    StrCpy $2 $0 1                ; Get the next character from the input string
    StrCmp $2 "" done
    StrCpy $5 ${DECIMAL_DIGIT}$2  ; Add it to end of "validity check" to guarantee a match
    StrCpy $0 $0 "" 1
    StrCpy $3 -1

  next_valid_char:
    IntOp $3 $3 + 1
    StrCpy $4 $5 1 $3             ; Extract next "valid" character (from "validity check" string)
    StrCmp $2 $4 0 next_valid_char
    IntCmp $3 10 invalid 0 invalid  ; If match is with the char we added, input string is bad
    StrCpy $1 $1$4                ; Add "valid" character to the result
    goto next_input_char

  invalid:
    StrCpy $1 ""

  done:
    StrCpy $0 $1      ; Result is either a string of decimal digits or ""
    Pop $5
    Pop $4
    Pop $3
    Pop $2
    Pop $1
    Exch $0           ; place result on top of the stack

    !undef DECIMAL_DIGIT

  FunctionEnd
!macroend

#--------------------------------------------------------------------------
# Installer Function: StrCheckDecimal
#
# This function is used during the installation process
#--------------------------------------------------------------------------

!insertmacro StrCheckDecimal ""

#--------------------------------------------------------------------------
# Uninstaller Function: un.StrCheckDecimal
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

!insertmacro StrCheckDecimal "un."

#--------------------------------------------------------------------------
# Macro: TrimNewlines
#
# The installation process and the uninstall process both
# use a function which trims newlines from lines of text.
# This macro makes maintenance easier by ensuring that
# both processes use identical functions, with the only
# difference being their names.
#--------------------------------------------------------------------------

  ; input, top of stack  (e.g. whatever$\r$\n)
  ; output, top of stack (replaces, with e.g. whatever)
  ; modifies no other variables.

!macro TrimNewlines UN
  Function ${UN}TrimNewlines
    Exch $R0
    Push $R1
    Push $R2
    StrCpy $R1 0

  loop:
    IntOp $R1 $R1 - 1
    StrCpy $R2 $R0 1 $R1
    StrCmp $R2 "$\r" loop
    StrCmp $R2 "$\n" loop
    IntOp $R1 $R1 + 1
    IntCmp $R1 0 no_trim_needed
    StrCpy $R0 $R0 $R1

  no_trim_needed:
    Pop $R2
    Pop $R1
    Exch $R0
  FunctionEnd
!macroend

#--------------------------------------------------------------------------
# Installer Function: TrimNewlines
#
# This function is used during the installation process
#--------------------------------------------------------------------------

!insertmacro TrimNewlines ""

#--------------------------------------------------------------------------
# Uninstaller Function: un.TrimNewlines
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

!insertmacro TrimNewlines "un."

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

  !define L_CFG         $R9
  !define L_LNE         $R8
  !define L_MSG         $R7
  !define L_REG_KEY     $R6
  !define L_REG_SUBKEY  $R5
  !define L_REG_VALUE   $R4
  !define L_TEMP        $R3

  IfFileExists $INSTDIR\popfile.pl skip_confirmation
    StrCpy ${L_MSG} "$(un.PFI_LANG_MBNOTFOUND_1)"
    StrCpy ${L_TEMP} "$(un.PFI_LANG_MBNOTFOUND_2)"
    StrCpy ${L_MSG} "${L_MSG} '$INSTDIR'.$\r$\n$\r$\n${L_TEMP}"
    MessageBox MB_YESNO "${L_MSG}" IDYES skip_confirmation
    Abort "$(un.PFI_LANG_ABORT_1)"

skip_confirmation:

  ; If the POPFile we are about to uninstall is still running,
  ; then one of the EXE files will be 'locked'

  SetDetailsPrint textonly
  DetailPrint "$(un.PFI_LANG_PROGRESS_1)"
  SetDetailsPrint listonly

  ; A quick test ignoring fact that popfile.cfg may specify a non-default location for PID file

  IfFileExists "$INSTDIR\popfile.pid" attempt_shutdown

  IfFileExists "$INSTDIR\wperl.exe" 0 other_perl
  SetFileAttributes "$INSTDIR\wperl.exe" NORMAL
  ClearErrors
  FileOpen ${L_CFG} "$INSTDIR\wperl.exe" a
  FileClose ${L_CFG}
  IfErrors attempt_shutdown

other_perl:
  IfFileExists "$INSTDIR\perl.exe" 0 skip_shutdown
  SetFileAttributes "$INSTDIR\perl.exe" NORMAL
  ClearErrors
  FileOpen ${L_CFG} "$INSTDIR\perl.exe" a
  FileClose ${L_CFG}
  IfErrors 0 skip_shutdown

attempt_shutdown:
  ClearErrors
  FileOpen ${L_CFG} $INSTDIR\popfile.cfg r

loop:
  FileRead ${L_CFG} ${L_LNE}
  IfErrors done

  StrCpy ${L_TEMP} ${L_LNE} 10
  StrCmp ${L_TEMP} "html_port " got_html_port
  Goto loop

got_html_port:
  StrCpy ${G_GUI} ${L_LNE} 5 10
  Goto loop

done:
  FileClose ${L_CFG}

  Push ${G_GUI}
  Call un.TrimNewlines
  Call un.StrCheckDecimal
  Pop ${G_GUI}
  StrCmp ${G_GUI} "" skip_shutdown
  StrCpy ${L_MSG} "$(un.PFI_LANG_LOG_1)"
  DetailPrint "${L_MSG} ${G_GUI}"
  NSISdl::download_quiet http://127.0.0.1:${G_GUI}/shutdown "$PLUGINSDIR\shutdown.htm"
  Pop ${L_TEMP}
  Sleep 250 ; milliseconds

skip_shutdown:

  SetDetailsPrint textonly
  DetailPrint "$(un.PFI_LANG_PROGRESS_2)"
  SetDetailsPrint listonly

  Delete $SMPROGRAMS\POPFile\Support\*.url
  RMDir $SMPROGRAMS\POPFile\Support

  Delete $SMPROGRAMS\POPFile\*.lnk
  Delete $SMPROGRAMS\POPFile\*.url
  Delete "$SMSTARTUP\Run POPFile in background.lnk"
  RMDir $SMPROGRAMS\POPFile

  SetDetailsPrint textonly
  DetailPrint "$(un.PFI_LANG_PROGRESS_3)"
  SetDetailsPrint listonly

  Delete $INSTDIR\*.log
  Delete $INSTDIR\*.pl
  Delete $INSTDIR\*.gif
  Delete $INSTDIR\*.pm
  Delete $INSTDIR\*.exe
  Delete $INSTDIR\*.dll
  Delete $INSTDIR\*.change
  Delete $INSTDIR\*.change.txt
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
  StrCpy ${L_MSG} "$(un.PFI_LANG_LOG_2)"
  DetailPrint "${L_MSG}: popfile.reg"

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
  StrCpy ${L_MSG} "$(un.PFI_LANG_LOG_3)"
  DetailPrint "${L_MSG} ${L_REG_SUBKEY}: ${L_REG_VALUE}"
  goto restore_loop

skip_registry_restore:
  FileClose ${L_CFG}
  StrCpy ${L_MSG} "$(un.PFI_LANG_LOG_4)"
  DetailPrint "${L_MSG}: popfile.reg"
  Delete $INSTDIR\popfile.reg

no_reg_file:
  Delete $INSTDIR\Platform\*.pm
  Delete $INSTDIR\Platform\*.dll
  RMDir $INSTDIR\Platform
  Delete $INSTDIR\Proxy\*.pm
  RMDir $INSTDIR\Proxy
  Delete $INSTDIR\UI\*.pm
  RMDir $INSTDIR\UI
  Delete $INSTDIR\POPFile\*.pm
  RMDir $INSTDIR\POPFile
  Delete $INSTDIR\Classifier\*.pm
  RMDir $INSTDIR\Classifier
  Delete $INSTDIR\Exporter\*.*
  RMDir $INSTDIR\Exporter

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
  Delete $INSTDIR\stopwords
  Delete $INSTDIR\stopwords.bak
  Delete $INSTDIR\stopwords.default
  RMDir /r $INSTDIR\messages

  SetDetailsPrint textonly
  DetailPrint "$(un.PFI_LANG_PROGRESS_6)"
  SetDetailsPrint listonly

  Delete $INSTDIR\Win32\API\*
  RmDir /r $INSTDIR\Win32\API
  Delete $INSTDIR\Win32\*
  RmDir /r $INSTDIR\Win32
  Delete $INSTDIR\auto\Win32\API\*
  RmDir /r $INSTDIR\auto\Win32\API
  Delete $INSTDIR\MIME\*.*
  RMDir  $INSTDIR\MIME
  Delete $INSTDIR\IO\*.*
  Delete $INSTDIR\IO\Socket\*.*
  RMDir /r $INSTDIR\IO
  Delete $INSTDIR\Carp\*.*
  RMDir /r $INSTDIR\Carp
  Delete $INSTDIR\Sys\Hostname\*.*
  RMDir /r $INSTDIR\Sys\Hostname
  RMDir /r $INSTDIR\Sys
  Delete $INSTDIR\Text\*.pm
  RMDir /r $INSTDIR\Text
  Delete $INSTDIR\auto\POSIX\*.*
  Delete $INSTDIR\auto\DynaLoader\*.*
  Delete $INSTDIR\auto\File\Glob\*.*
  Delete $INSTDIR\auto\MIME\Base64\*.*
  Delete $INSTDIR\auto\IO\*.*
  Delete $INSTDIR\auto\Socket\*.*
  Delete $INSTDIR\auto\Sys\*.*
  RMDir /r $INSTDIR\auto
  Delete $INSTDIR\File\*.*
  RMDir $INSTDIR\File
  Delete $INSTDIR\warnings\*.*
  RMDir $INSTDIR\warnings

  Delete "$INSTDIR\Uninstall.exe"

  RMDir $INSTDIR

  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_PRODUCT}"
  DeleteRegKey HKLM SOFTWARE\POPFile

  ; if $INSTDIR was removed, skip these next ones

  IfFileExists $INSTDIR 0 Removed
    MessageBox MB_YESNO|MB_ICONQUESTION "$(un.PFI_LANG_MBREMDIR_1)" IDNO Removed
    DetailPrint "$(un.PFI_LANG_LOG_5)"
    Delete $INSTDIR\*.* ; this would be skipped if the user hits no
    RMDir /r $INSTDIR
    IfFileExists $INSTDIR 0 Removed
      DetailPrint "$(un.PFI_LANG_LOG_6)"
      StrCpy ${L_MSG} "$(un.PFI_LANG_MBREMERR_1)"
      StrCpy ${L_TEMP} "$(un.PFI_LANG_MBREMERR_2)"
      StrCpy ${L_MSG} "${L_MSG}: $INSTDIR ${L_TEMP}"
      MessageBox MB_OK|MB_ICONEXCLAMATION ${L_MSG}
Removed:

  SetDetailsPrint both

  !undef L_CFG
  !undef L_LNE
  !undef L_MSG
  !undef L_REG_KEY
  !undef L_REG_SUBKEY
  !undef L_REG_VALUE
  !undef L_TEMP
SectionEnd

#--------------------------------------------------------------------------
# End of 'installer.nsi'
#--------------------------------------------------------------------------
