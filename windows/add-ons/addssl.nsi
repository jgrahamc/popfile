#--------------------------------------------------------------------------
#
# addssl.nsi --- This is the NSIS script used to create a utility which downloads and
#                installs SSL support for an existing POPFile 0.22.0 (or later) installation.
#
#                The version of Module.pm distributed with POPFile 0.22.0 results in extremely
#                slow message downloads (e.g. 6 minutes for a 2,713 byte msg) so this utility
#                will apply a patch to update Module.pm v1.40 to v1.41 (the original file will
#                be backed up as Module.pm.bk1). The patch is only applied if v1.40 is found.
#                A patch status message is always displayed.
#
# Copyright (c) 2004 John Graham-Cumming
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
; released 7 February 2004, with no "official" NSIS patches applied.

  ;------------------------------------------------
  ; This script requires the 'untgz' NSIS plugin
  ;------------------------------------------------

  ; This script uses a special NSIS plugin (untgz) to extract files from the *.tar.gz archives.
  ;
  ; The 'NSIS Archives' page for the 'untgz' plugin (description, example and download links):
  ; http://nsis.sourceforge.net/archive/nsisweb.php?page=74&instances=0,32
  ;
  ; Alternative download links can be found at the 'untgz' author's site:
  ; http://www.darklogic.org/win32/nsis/plugins/
  ;
  ; To compile this script, copy the 'untgz.dll' file to the standard NSIS plugins folder
  ; (${NSISDIR}\Plugins\). The 'untgz' source and example files can be unzipped to the
  ; ${NSISDIR}\Contrib\untgz\ folder if you wish, but this step is entirely optional.

  ;------------------------------------------------
  ; How the Module.pm patch was created
  ;------------------------------------------------

  ; The patch used to update Module.pm v1.40 to v1.41 was created using the VPATCH package
  ; which is supplied with NSIS. The command used to create the patch was:
  ;   GenPat.exe Module.pm Module_ssl.pm Module_ssl.pat
  ; where Module.pm was CVS version 1.40 and Module_ssl.pm was CVS version 1.41.

  ;------------------------------------------------
  ; Define PFI_VERBOSE to get more compiler output
  ;------------------------------------------------

## !define PFI_VERBOSE

  ;--------------------------------------------------------------------------
  ; Select LZMA compression (to generate smallest EXE file)
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

  ; This build is for use with the POPFile installer-created installations

  !define C_PFI_PRODUCT  "POPFile"

  Name                   "POPFile SSL Setup"

  !define C_PFI_VERSION  "0.0.8"

  ; Mention the wizard's version number in the window title

  Caption                "POPFile SSL Setup v${C_PFI_VERSION}"

  ; Name to be used for the program file (also used for the 'Version Information')

  !define C_OUTFILE      "addssl.exe"

#--------------------------------------------------------------------------
# URLs used to download the necessary SSL support archives and files
# (all from the University of Winnipeg Repository)
#--------------------------------------------------------------------------

  !define C_UWR_IO_SOCKET_SSL "http://theoryx5.uwinnipeg.ca/ppms/x86/IO-Socket-SSL.tar.gz"
  !define C_UWR_NET_SSLEAY    "http://theoryx5.uwinnipeg.ca/ppms/x86/Net_SSLeay.pm.tar.gz"
  !define C_UWR_DLL_SSLEAY32  "http://theoryx5.uwinnipeg.ca/ppms/scripts/ssleay32.dll"
  !define C_UWR_DLL_LIBEAY32  "http://theoryx5.uwinnipeg.ca/ppms/scripts/libeay32.dll"


#--------------------------------------------------------------------------
# Universal POPFile Constant: the URL used to access the User Interface (UI)
#--------------------------------------------------------------------------
#
# Starting with the 0.22.0 release, the system tray icon will use "localhost"
# to access the User Interface (UI) instead of "127.0.0.1". The installer and
# PFI utilities will follow suit by using the ${C_UI_URL} universal constant
# when accessing the UI instead of hard-coded references to "127.0.0.1".
#
#--------------------------------------------------------------------------

  !define C_UI_URL    "localhost"
##  !define C_UI_URL    "127.0.0.1"


#--------------------------------------------------------------------------
# User Registers (Global)
#--------------------------------------------------------------------------

  ; This script uses 'User Variables' (with names starting with 'G_') to hold GLOBAL data.

  Var G_ROOTDIR            ; full path to the folder used for the POPFile program files
  Var G_MPLIBDIR           ; full path to the folder used for most of the minimal Perl files

  Var G_SSL_FILEURL        ; full URL used to download SSL file

  Var G_PLS_FIELD_1        ; used to customize some language strings
  Var G_PLS_FIELD_2        ; ditto

  ; NSIS provides 20 general purpose user registers:
  ; (a) $R0 to $R9   are used as local registers
  ; (b) $0 to $9     are used as additional local registers

  ; Local registers referred to by 'defines' use names starting with 'L_' (eg L_LNE, L_OLDUI)
  ; and the scope of these 'defines' is limited to the "routine" where they are used.

  ; In earlier versions of the NSIS compiler, 'User Variables' did not exist, and the convention
  ; was to use $R0 to $R9 as 'local' registers and $0 to $9 as 'global' ones. This is why this
  ; script uses registers $R0 to $R9 in preference to registers $0 to $9.

  ; POPFile constants have been given names beginning with 'C_' (eg C_README)
  ; except for 'IO_NL' and 'MB_NL' which are used when assembling multi-line strings


#--------------------------------------------------------------------------
# Use the "Modern User Interface"
#--------------------------------------------------------------------------

  !include "MUI.nsh"


#--------------------------------------------------------------------------
# Version Information settings (for the wizard's EXE file)
#--------------------------------------------------------------------------

  ; 'VIProductVersion' format is X.X.X.X where X is a number in range 0 to 65535
  ; representing the following values: Major.Minor.Release.Build

  VIProductVersion "${C_PFI_VERSION}.0"

  VIAddVersionKey "ProductName"       "POPFile SSL Setup wizard"
  VIAddVersionKey "Comments"          "POPFile Homepage: http://getpopfile.org"
  VIAddVersionKey "CompanyName"       "The POPFile Project"
  VIAddVersionKey "LegalCopyright"    "Copyright (c) 2004  John Graham-Cumming"
  VIAddVersionKey "FileDescription"   "Installs SSL support for POPFile 0.22.x"
  VIAddVersionKey "FileVersion"       "${C_PFI_VERSION}"
  VIAddVersionKey "OriginalFilename"  "${C_OUTFILE}"

  VIAddVersionKey "Build"             "English-Mode"

  VIAddVersionKey "Build Date/Time"   "${__DATE__} @ ${__TIME__}"
  VIAddVersionKey "Build Script"      "${__FILE__}${MB_NL}(${__TIMESTAMP__})"


#--------------------------------------------------------------------------
#
# Macro which makes it easy to avoid relative jumps when defining macros
#
#--------------------------------------------------------------------------

  !macro PFI_UNIQUE_ID
      !ifdef PFI_UNIQUE_ID
        !undef PFI_UNIQUE_ID
      !endif
      !define PFI_UNIQUE_ID ${__LINE__}
  !macroend

#--------------------------------------------------------------------------
#
# Macro used to preserve up to 3 backup copies of a file
#
# (Note: input file will be "removed" by renaming it)
#--------------------------------------------------------------------------

  ;--------------------------------------------------------------------------
  ; This version generates uses 'DetailsPrint' to generate more meaningful log entries
  ;--------------------------------------------------------------------------

  !macro BACKUP_123_DP FOLDER FILE

      !insertmacro PFI_UNIQUE_ID

      IfFileExists "${FOLDER}\${FILE}" 0 continue_${PFI_UNIQUE_ID}
      SetDetailsPrint none
      IfFileExists "${FOLDER}\${FILE}.bk1" 0 the_first_${PFI_UNIQUE_ID}
      IfFileExists "${FOLDER}\${FILE}.bk2" 0 the_second_${PFI_UNIQUE_ID}
      IfFileExists "${FOLDER}\${FILE}.bk3" 0 the_third_${PFI_UNIQUE_ID}
      Delete "${FOLDER}\${FILE}.bk3"

    the_third_${PFI_UNIQUE_ID}:
      Rename "${FOLDER}\${FILE}.bk2" "${FOLDER}\${FILE}.bk3"
      SetDetailsPrint listonly
      DetailPrint "Backup file '${FILE}.bk3' updated"
      SetDetailsPrint none

    the_second_${PFI_UNIQUE_ID}:
      Rename "${FOLDER}\${FILE}.bk1" "${FOLDER}\${FILE}.bk2"
      SetDetailsPrint listonly
      DetailPrint "Backup file '${FILE}.bk2' updated"
      SetDetailsPrint none

    the_first_${PFI_UNIQUE_ID}:
      Rename "${FOLDER}\${FILE}" "${FOLDER}\${FILE}.bk1"
      SetDetailsPrint listonly
      DetailPrint "Backup file '${FILE}.bk1' updated"

    continue_${PFI_UNIQUE_ID}:
  !macroend

  ;--------------------------------------------------------------------------
  ; This version does not include any 'DetailsPrint' instructions
  ;--------------------------------------------------------------------------

  !macro BACKUP_123 FOLDER FILE

      !insertmacro PFI_UNIQUE_ID

      IfFileExists "${FOLDER}\${FILE}" 0 continue_${PFI_UNIQUE_ID}
      IfFileExists "${FOLDER}\${FILE}.bk1" 0 the_first_${PFI_UNIQUE_ID}
      IfFileExists "${FOLDER}\${FILE}.bk2" 0 the_second_${PFI_UNIQUE_ID}
      IfFileExists "${FOLDER}\${FILE}.bk3" 0 the_third_${PFI_UNIQUE_ID}
      Delete "${FOLDER}\${FILE}.bk3"

    the_third_${PFI_UNIQUE_ID}:
      Rename "${FOLDER}\${FILE}.bk2" "${FOLDER}\${FILE}.bk3"

    the_second_${PFI_UNIQUE_ID}:
      Rename "${FOLDER}\${FILE}.bk1" "${FOLDER}\${FILE}.bk2"

    the_first_${PFI_UNIQUE_ID}:
      Rename "${FOLDER}\${FILE}" "${FOLDER}\${FILE}.bk1"

    continue_${PFI_UNIQUE_ID}:
  !macroend


#--------------------------------------------------------------------------
# Configure the MUI pages
#--------------------------------------------------------------------------

  ;----------------------------------------------------------------
  ; Interface Settings - General Interface Settings
  ;----------------------------------------------------------------

  !define MUI_ICON                            "..\POPFileIcon\popfile.ico"

  ; The "Header" bitmap appears on all pages of the wizard (except Welcome & Finish pages)

  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP              "hdr-update.bmp"
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

  !define MUI_WELCOMEFINISHPAGE_BITMAP        "special-update.bmp"

  ;----------------------------------------------------------------
  ;  Interface Settings - Installer Finish Page Interface Settings
  ;----------------------------------------------------------------

  ; Debug aid: The log window shows progress messages

#  ShowInstDetails show
  !define MUI_FINISHPAGE_NOAUTOCLOSE

  ;----------------------------------------------------------------
  ;  Interface Settings - Abort Warning Settings
  ;----------------------------------------------------------------

  ; Show a message box with a warning when the user closes the wizard before it has finished

  !define MUI_ABORTWARNING
  !define MUI_ABORTWARNING_TEXT               "$(PSS_LANG_ABORT_WARNING)"

  ;----------------------------------------------------------------
  ; Customize MUI - General Custom Function
  ;----------------------------------------------------------------

  ; Use a custom '.onGUIInit' function to permit language-specific error messages
  ; (the user-selected language is not available for use in the .onInit function)

  !define MUI_CUSTOMFUNCTION_GUIINIT          PFIGUIInit


#--------------------------------------------------------------------------
# Define the Page order for the wizard
#--------------------------------------------------------------------------

  ;---------------------------------------------------
  ; Installer Page - Welcome
  ;---------------------------------------------------

  !define MUI_WELCOMEPAGE_TITLE                   "$(PSS_LANG_WELCOME_TITLE)"
  !define MUI_WELCOMEPAGE_TEXT                    "$(PSS_LANG_WELCOME_TEXT)"

  !insertmacro MUI_PAGE_WELCOME

  ;---------------------------------------------------
  ; Installer Page - License Page (uses English GPL)
  ;---------------------------------------------------

  !define MUI_LICENSEPAGE_CHECKBOX
  !define MUI_PAGE_HEADER_SUBTEXT                 "$(PSS_LANG_LICENSE_SUBHDR)"
  !define MUI_LICENSEPAGE_TEXT_BOTTOM             "$(PSS_LANG_LICENSE_BOTTOM)"

  !insertmacro MUI_PAGE_LICENSE                   "license.gpl"

  ;---------------------------------------------------
  ; Installer Page - Select installation Directory
  ;---------------------------------------------------

  ; Use a "pre" function to look for a registry entry for the 0.22.x version of POPFile
  ; (this build is intended for use with POPFile 0.22.x)

  !define MUI_PAGE_CUSTOMFUNCTION_PRE             "CheckForExistingInstallation"

  ; Use a "leave" function to check that the user has selected an appropriate folder

  !define MUI_PAGE_CUSTOMFUNCTION_LEAVE           "CheckInstallDir"

  ; This page is used to select the folder where the POPFile PROGRAM files can be found
  ; (we use this to generate the installation path for the POPFile SSL support files)

  !define MUI_PAGE_HEADER_TEXT                    "$(PSS_LANG_DESTNDIR_TITLE)"
  !define MUI_PAGE_HEADER_SUBTEXT                 "$(PSS_LANG_DESTNDIR_SUBTITLE)"
  !define MUI_DIRECTORYPAGE_TEXT_TOP              "$(PSS_LANG_DESTNDIR_TEXT_TOP)"
  !define MUI_DIRECTORYPAGE_TEXT_DESTINATION      "$(PSS_LANG_DESTNDIR_TEXT_DESTN)"

  !insertmacro MUI_PAGE_DIRECTORY

  ;---------------------------------------------------
  ; Installer Page - Install files
  ;---------------------------------------------------

  ; Override the standard "Installing..." page header

  !define MUI_PAGE_HEADER_TEXT                    "$(PSS_LANG_STD_HDR)"
  !define MUI_PAGE_HEADER_SUBTEXT                 "$(PSS_LANG_STD_SUBHDR)"

  ; Override the standard "Installation complete..." page header

  !define MUI_INSTFILESPAGE_FINISHHEADER_TEXT     "$(PSS_LANG_END_HDR)"
  !define MUI_INSTFILESPAGE_FINISHHEADER_SUBTEXT  "$(PSS_LANG_END_SUBHDR)"

  ; Override the standard "Installation Aborted..." page header

  !define MUI_INSTFILESPAGE_ABORTHEADER_TEXT      "$(PSS_LANG_ABORT_HDR)"
  !define MUI_INSTFILESPAGE_ABORTHEADER_SUBTEXT   "$(PSS_LANG_ABORT_SUBHDR)"

  !insertmacro MUI_PAGE_INSTFILES

  ;---------------------------------------------------
  ; Installer Page - Finish
  ;---------------------------------------------------

  !define MUI_FINISHPAGE_TITLE                    "$(PSS_LANG_FINISH_TITLE)"
  !define MUI_FINISHPAGE_TEXT                     "$(PSS_LANG_FINISH_TEXT)"

  !define MUI_FINISHPAGE_SHOWREADME               "$G_ROOTDIR\addssl.txt"
  !define MUI_FINISHPAGE_SHOWREADME_TEXT          "$(PSS_LANG_FINISH_README)"

  !insertmacro MUI_PAGE_FINISH


#--------------------------------------------------------------------------
# Language Support for the utility
#--------------------------------------------------------------------------

  !insertmacro MUI_LANGUAGE "English"

  ;--------------------------------------------------------------------------
  ; Current build only supports English and uses local strings
  ; instead of language strings from languages\*-pfi.nsh files
  ;--------------------------------------------------------------------------

  !macro PLS_TEXT NAME VALUE
      LangString ${NAME} ${LANG_ENGLISH} "${VALUE}"
  !macroend

  ;--------------------------------------------------------------------------
  ; WELCOME page
  ;--------------------------------------------------------------------------

  !insertmacro PLS_TEXT PSS_LANG_WELCOME_TITLE         "Welcome to the $(^NameDA) Wizard"
  !insertmacro PLS_TEXT PSS_LANG_WELCOME_TEXT          "This utility will download and install the files needed to allow POPFile to use SSL when accessing mail servers.${IO_NL}${IO_NL}This version does not configure any email accounts to use SSL, it just installs the necessary Perl components and DLLs.${IO_NL}${IO_NL}This product downloads software developed by the OpenSSL Project for use in the OpenSSL Toolkit (http://www.openssl.org/)${IO_NL}${IO_NL}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${IO_NL}${IO_NL}   PLEASE SHUT DOWN POPFILE NOW${IO_NL}${IO_NL}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${IO_NL}${IO_NL}$_CLICK"

  ;--------------------------------------------------------------------------
  ; LICENSE page
  ;--------------------------------------------------------------------------

  !insertmacro PLS_TEXT PSS_LANG_LICENSE_SUBHDR        "Please review the license terms before using $(^NameDA)."
  !insertmacro PLS_TEXT PSS_LANG_LICENSE_BOTTOM        "If you accept the terms of the agreement, click the check box below. You must accept the agreement to use $(^NameDA). $_CLICK"

  ;--------------------------------------------------------------------------
  ; Source DIRECTORY page
  ;--------------------------------------------------------------------------

  !insertmacro PLS_TEXT PSS_LANG_DESTNDIR_TITLE        "Choose existing POPFile installation"
  !insertmacro PLS_TEXT PSS_LANG_DESTNDIR_SUBTITLE     "SSL support should only be added to an existing POPFile 0.22.x installation"
  !insertmacro PLS_TEXT PSS_LANG_DESTNDIR_TEXT_TOP     "SSL support must be installed using the same installation folder as POPFile 0.22.x.${MB_NL}${MB_NL}This utility will add SSL support to the version of POPFile which is installed in the following folder. To install in a different POPFile 0.22.x installation, click Browse and select another folder. $_CLICK"
  !insertmacro PLS_TEXT PSS_LANG_DESTNDIR_TEXT_DESTN   "Existing POPFile 0.22.x installation folder"

  !insertmacro PLS_TEXT PSS_LANG_DESTNDIR_MB_WARN_1    "POPFile 0.22.x does NOT seem to be installed in${MB_NL}${MB_NL}$G_PLS_FIELD_1"
  !insertmacro PLS_TEXT PSS_LANG_DESTNDIR_MB_WARN_2    "Are you sure you want to use this folder ?"

  ;--------------------------------------------------------------------------
  ; INSTFILES page
  ;--------------------------------------------------------------------------

  ; Initial page header

  !insertmacro PLS_TEXT PSS_LANG_STD_HDR               "Installing SSL support (for POPFile 0.22.x)"
  !insertmacro PLS_TEXT PSS_LANG_STD_SUBHDR            "Please wait while the SSL files are downloaded and installed..."

  ; Successful completion page header

  !insertmacro PLS_TEXT PSS_LANG_END_HDR               "POPFile SSL Support installation completed"
  !insertmacro PLS_TEXT PSS_LANG_END_SUBHDR            "SSL support for POPFile has been installed successfully"

  ; Unsuccessful completion page header

  !insertmacro PLS_TEXT PSS_LANG_ABORT_HDR             "POPFile SSL Support installation failed"
  !insertmacro PLS_TEXT PSS_LANG_ABORT_SUBHDR          "The attempt to add SSL support to POPFile has failed"

  ; Progress reports

  !insertmacro PLS_TEXT PSS_LANG_PROG_INITIALISE       "Initializing..."
  !insertmacro PLS_TEXT PSS_LANG_PROG_STARTDOWNLOAD    "Downloading $G_PLS_FIELD_1 file from $G_PLS_FIELD_2"
  !insertmacro PLS_TEXT PSS_LANG_PROG_CHECKIFRUNNING   "Checking if POPFile is running..."
  !insertmacro PLS_TEXT PSS_LANG_PROG_USERCANCELLED    "POPFile SSL Support installation cancelled by the user"
  !insertmacro PLS_TEXT PSS_LANG_PROG_FILECOPY         "Copying $G_PLS_FIELD_2 files..."
  !insertmacro PLS_TEXT PSS_LANG_PROG_FILEEXTRACT      "Extracting files from $G_PLS_FIELD_2 archive..."
  !insertmacro PLS_TEXT PSS_LANG_PROG_SUCCESS          "POPFile 0.22.x SSL support installed"
  !insertmacro PLS_TEXT PSS_LANG_PROG_SAVELOG          "Saving install log file..."

  !insertmacro PLS_TEXT PSS_LANG_TAKE_A_FEW_SECONDS    "(this may take a few seconds)"

  ;--------------------------------------------------------------------------
  ; FINISH page
  ;--------------------------------------------------------------------------

  !insertmacro PLS_TEXT PSS_LANG_FINISH_TITLE          "Completing the $(^NameDA) Wizard"
  !insertmacro PLS_TEXT PSS_LANG_FINISH_TEXT           "SSL support for POPFile 0.22.x has been installed.${IO_NL}${IO_NL}You can now start POPFile and configure POPFile and your email client to use SSL.${IO_NL}${IO_NL}Click Finish to close this wizard."

  !insertmacro PLS_TEXT PSS_LANG_FINISH_README         "Important information"

  ;--------------------------------------------------------------------------
  ; Miscellaneous strings
  ;--------------------------------------------------------------------------

  !insertmacro PLS_TEXT PSS_LANG_MUTEX                 "Another copy of the SSL Setup wizard is running!"

  !insertmacro PLS_TEXT PSS_LANG_COMPAT_NOTFOUND       "Warning: Cannot find compatible version of POPFile !"

  !insertmacro PLS_TEXT PSS_LANG_ABORT_WARNING         "Are you sure you want to quit the $(^NameDA) Wizard?"

  !insertmacro PLS_TEXT PSS_LANG_MB_NSISDLFAIL_1       "Download of $G_PLS_FIELD_1 file failed"
  !insertmacro PLS_TEXT PSS_LANG_MB_NSISDLFAIL_2       "(error: $G_PLS_FIELD_2)"

  !insertmacro PLS_TEXT PSS_LANG_MB_UNPACKFAIL         "Error detected while installing files in $G_PLS_FIELD_1 folder"

  !insertmacro PLS_TEXT PSS_LANG_PREPAREPATCH          "Updating Module.pm (to avoid slow speed SSL downloads)"
  !insertmacro PLS_TEXT PSS_LANG_PATCHSTATUS           "Module.pm patch status: $G_PLS_FIELD_1"
  !insertmacro PLS_TEXT PSS_LANG_PATCHCOMPLETED        "Module.pm file has been updated"
  !insertmacro PLS_TEXT PSS_LANG_PATCHFAILED           "Module.pm file has not been updated"

  ; Strings required by the PFI Library functions

  !insertmacro PLS_TEXT PFI_LANG_INST_LOG_SHUTDOWN     "Shutting down POPFile using port"
  !insertmacro PLS_TEXT PFI_LANG_TAKE_A_FEW_SECONDS    "This may take a few seconds..."
  !insertmacro PLS_TEXT PFI_LANG_MBMANSHUT_1           "Unable to shutdown '$G_PLS_FIELD_1' automatically."
  !insertmacro PLS_TEXT PFI_LANG_MBMANSHUT_2           "Please shutdown '$G_PLS_FIELD_1' manually now."
  !insertmacro PLS_TEXT PFI_LANG_MBMANSHUT_3           "When '$G_PLS_FIELD_1' has been shutdown, click 'OK' to continue."


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

  InstallDir "$PROGRAMFILES\${C_PFI_PRODUCT}\"

#--------------------------------------------------------------------------
# Reserve the files required by the wizard (to improve performance)
#--------------------------------------------------------------------------

  ; Things that need to be extracted on startup (keep these lines before any File command!)
  ; Only useful when solid compression is used (by default, solid compression is enabled
  ; for BZIP2 and LZMA compression)

  !insertmacro MUI_RESERVEFILE_INSTALLOPTIONS


#--------------------------------------------------------------------------
# Installer Function: PFIGUIInit
# (custom .onGUIInit function)
#
# Used to complete the initialization of the wizard.
# This code was moved from '.onInit' in order to permit the use of language-specific strings
# (the selected language is not available inside the '.onInit' function)
#--------------------------------------------------------------------------

Function PFIGUIInit

  !define L_RESERVED         $1    ; used in the system.dll call

  Push ${L_RESERVED}

  ; Ensure only one copy of this wizard (or any other POPFile installer) is running

  System::Call 'kernel32::CreateMutexA(i 0, i 0, t "OnlyOnePFI_mutex") i .r1 ?e'
  Pop ${L_RESERVED}
  StrCmp ${L_RESERVED} 0 mutex_ok
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(PSS_LANG_MUTEX)"
  Abort

mutex_ok:

  ; The wizard does not contain the SSL support files so we provide an estimate which
  ; includes a slack space allowance (based upon the development system's statistics)

  SectionSetSize  0  2560

  Pop ${L_RESERVED}

  !undef L_RESERVED

FunctionEnd


#--------------------------------------------------------------------------
# Installer Section: POPFile SSL Support
#--------------------------------------------------------------------------

Section "SSL" SecSSL

  !define L_RESULT  $R0  ; used by the 'untgz' plugin to return the result

  Push ${L_RESULT}

  SetDetailsPrint listonly

  DetailPrint "----------------------------------------------------"
  DetailPrint "POPFile SSL Setup wizard v${C_PFI_VERSION}"
  DetailPrint "----------------------------------------------------"

  ; Download the archives and OpenSSL DLLs

  Push "${C_UWR_IO_SOCKET_SSL}"
  Call GetSSLFile

  Push "${C_UWR_NET_SSLEAY}"
  Call GetSSLFile

  Push "${C_UWR_DLL_SSLEAY32}"
  Call GetSSLFile

  Push "${C_UWR_DLL_LIBEAY32}"
  Call GetSSLFile

  ; Make sure we do not try to add SSL support to an installation which is in use

  Call MakeRootDirSafe

  ; Important information about SSL support

  DetailPrint ""
  SetOutPath $G_ROOTDIR
  File "addssl.txt"

  ; Now install the files required for SSL support

  StrCpy $G_MPLIBDIR "$G_ROOTDIR\lib"

  StrCpy $G_PLS_FIELD_1 "$G_MPLIBDIR\IO\Socket"
  DetailPrint ""
  CreateDirectory $G_PLS_FIELD_1
  SetDetailsPrint both
  StrCpy $G_PLS_FIELD_2 "IO-Socket-SSL.tar.gz"
  DetailPrint "$(PSS_LANG_PROG_FILEEXTRACT)"
  SetDetailsPrint listonly
  untgz::extractFile -d "$G_PLS_FIELD_1" "$PLUGINSDIR\IO-Socket-SSL.tar.gz" "SSL.pm"
  StrCmp ${L_RESULT} "success" label_a error_exit

label_a:
  DetailPrint ""
  StrCpy $G_PLS_FIELD_1 "$G_MPLIBDIR\Net"
  CreateDirectory $G_PLS_FIELD_1
  SetDetailsPrint both
  StrCpy $G_PLS_FIELD_2 "Net_SSLeay.pm.tar.gz"
  DetailPrint "$(PSS_LANG_PROG_FILEEXTRACT)"
  SetDetailsPrint listonly
  untgz::extractFile -d "$G_PLS_FIELD_1" "$PLUGINSDIR\Net_SSLeay.pm.tar.gz" "SSLeay.pm"
  StrCmp ${L_RESULT} "success" label_b error_exit

label_b:
  DetailPrint ""
  StrCpy $G_PLS_FIELD_1 "$G_MPLIBDIR\Net\SSLeay"
  CreateDirectory $G_PLS_FIELD_1
  SetDetailsPrint both
  StrCpy $G_PLS_FIELD_2 "Net_SSLeay.pm.tar.gz"
  DetailPrint "$(PSS_LANG_PROG_FILEEXTRACT)"
  SetDetailsPrint listonly
  untgz::extractFile -d "$G_PLS_FIELD_1" "$PLUGINSDIR\Net_SSLeay.pm.tar.gz" "Handle.pm"
  StrCmp ${L_RESULT} "success" label_c error_exit

label_c:
  DetailPrint ""
  StrCpy $G_PLS_FIELD_1 "$G_MPLIBDIR\auto\Net\SSLeay"
  CreateDirectory $G_PLS_FIELD_1
  SetDetailsPrint both
  StrCpy $G_PLS_FIELD_2 "OpenSSL DLL"
  DetailPrint "$(PSS_LANG_PROG_FILECOPY)"
  SetDetailsPrint listonly
  CopyFiles /SILENT "$PLUGINSDIR\ssleay32.dll" "$G_PLS_FIELD_1\ssleay32.dll"
  CopyFiles /SILENT "$PLUGINSDIR\libeay32.dll" "$G_PLS_FIELD_1\libeay32.dll"
  DetailPrint ""
  SetDetailsPrint both
  StrCpy $G_PLS_FIELD_2 "Net_SSLeay.pm.tar.gz"
  DetailPrint "$(PSS_LANG_PROG_FILEEXTRACT)"
  SetDetailsPrint listonly
  untgz::extractV -j -d "$G_PLS_FIELD_1" "$PLUGINSDIR\Net_SSLeay.pm.tar.gz" -x ".exists" "*.html" "*.pl" "*.pm" --
  StrCmp ${L_RESULT} "success" check_bs_file

error_exit:
  SetDetailsPrint listonly
  DetailPrint ""
  SetDetailsPrint both
  DetailPrint "$(PSS_LANG_MB_UNPACKFAIL)"
  SetDetailsPrint listonly
  DetailPrint ""
  MessageBox MB_OK|MB_ICONSTOP "$(PSS_LANG_MB_UNPACKFAIL)"

error_timestamp:
  Call GetDateTimeStamp
  Pop $G_PLS_FIELD_1
  DetailPrint "----------------------------------------------------"
  DetailPrint "POPFile SSL Setup failed ($G_PLS_FIELD_1)"
  DetailPrint "----------------------------------------------------"
  Abort

check_bs_file:

  ; The current 'untgz' plugin does not extract empty files (i.e. file size is 0 bytes) so we
  ; cheat a little to ensure the $G_MPLIBDIR\auto\Net\SSLeay\SSLeay.* files are all 'extracted'

  IfFileExists "$G_PLS_FIELD_1\SSLeay.bs" done
  File "/oname=$G_PLS_FIELD_1\SSLeay.bs" "zerobyte.file"

done:
  DetailPrint ""

  ; Now patch Module.pm (if it needs to be patched)

  DetailPrint "$(PSS_LANG_PREPAREPATCH)"

  SetDetailsPrint none
  File "/oname=$PLUGINSDIR\patch.pat" "Module_ssl.pat"
  SetDetailsPrint listonly

  DetailPrint ""
  vpatch::vpatchfile "$PLUGINSDIR\patch.pat" "$G_ROOTDIR\POPFile\Module.pm" "$PLUGINSDIR\Module.ssl"
  Pop $G_PLS_FIELD_1

  SetDetailsPrint both
  DetailPrint "$(PSS_LANG_PATCHSTATUS)"
  SetDetailsPrint listonly
  DetailPrint ""

  StrCmp $G_PLS_FIELD_1 "OK" 0 show_status
  !insertmacro BACKUP_123_DP "$G_ROOTDIR\POPFile" "Module.pm"
  SetDetailsPrint none
  Rename "$PLUGINSDIR\Module.ssl" "$G_ROOTDIR\POPFile\Module.pm"
  IfFileExists "$G_ROOTDIR\POPFile\Module.pm" success
  Rename "$G_ROOTDIR\POPFile\Module.pm.bk1" "$G_ROOTDIR\POPFile\Module.pm"
  SetDetailsPrint listonly
  DetailPrint ""
  SetDetailsPrint both
  DetailPrint "$(PSS_LANG_PATCHFAILED)"
  SetDetailsPrint listonly
  DetailPrint ""
  Goto error_timestamp

success:
  SetDetailsPrint listonly
  DetailPrint "$(PSS_LANG_PATCHCOMPLETED)"
  DetailPrint ""

show_status:
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(PSS_LANG_PATCHSTATUS)"

  SetDetailsPrint both
  DetailPrint "$(PSS_LANG_PROG_SUCCESS)"
  SetDetailsPrint listonly
  DetailPrint ""
  Call GetDateTimeStamp
  Pop $G_PLS_FIELD_1
  DetailPrint "----------------------------------------------------"
  DetailPrint "POPFile SSL Setup completed $G_PLS_FIELD_1"
  DetailPrint "----------------------------------------------------"
  DetailPrint ""

  ; Save a log showing what was installed

  SetDetailsPrint textonly
  DetailPrint "$(PSS_LANG_PROG_SAVELOG)"
  SetDetailsPrint none
  !insertmacro BACKUP_123 "$G_ROOTDIR" "addssl.log"
  Push "$G_ROOTDIR\addssl.log"
  Call DumpLog

  SetDetailsPrint both
  DetailPrint "Log report saved in '$G_ROOTDIR\addssl.log'"
  SetDetailsPrint none

  Pop ${L_RESULT}

  !undef L_RESULT

SectionEnd


#--------------------------------------------------------------------------
# Installer Function: CheckForExistingInstallation
# (the "pre" function for the DIRECTORY selection page)
#
# Set the initial value used by the DIRECTORY page to the location used by the most recent
# installation of POPFile v0.22.x
#--------------------------------------------------------------------------

Function CheckForExistingInstallation

  ReadRegStr $INSTDIR HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "InstallPath"
  StrCmp $INSTDIR "" try_HKLM
  IfFileExists "$INSTDIR\*.*" exit

try_HKLM:
  ReadRegStr $INSTDIR HKLM "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "InstallPath"
  StrCmp $INSTDIR "" use_default
  IfFileExists "$INSTDIR\*.*" exit

use_default:
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(PSS_LANG_COMPAT_NOTFOUND)"
  StrCpy $INSTDIR "$PROGRAMFILES\${C_PFI_PRODUCT}"

exit:
FunctionEnd


#--------------------------------------------------------------------------
# Installer Function: CheckInstallDir
# (the "leave" function for the DIRECTORY selection page)
#
# This function is used to check if a previous POPFile installation exists in the directory
# chosen for this installation's POPFile program files (popfile.pl, etc)
#--------------------------------------------------------------------------

Function CheckInstallDir

  ; Initialise the global user variable used for the main POPFIle program folder location

  StrCpy $G_ROOTDIR "$INSTDIR"

  ; Warn the user if the selected directory does not appear to contain POPFile 0.22.x files
  ; and allow user to select a different directory if they wish

  IfFileExists "$G_ROOTDIR\skins\default\style.css" continue

  StrCpy $G_PLS_FIELD_1 "$INSTDIR"
  MessageBox MB_YESNO|MB_ICONQUESTION "$(PSS_LANG_DESTNDIR_MB_WARN_1)\
      ${MB_NL}${MB_NL}${MB_NL}\
      $(PSS_LANG_DESTNDIR_MB_WARN_2)" IDYES continue

  ; Return to the DIRECTORY selection page

  Abort

continue:

  ; Move to the INSTFILES page (to install the files)

FunctionEnd


#--------------------------------------------------------------------------
# Installer Function: MakeRootDirSafe
#
# We are adding files to a previous installation, so we try to shut it down first
#--------------------------------------------------------------------------

Function MakeRootDirSafe

  IfFileExists "$G_ROOTDIR\*.exe" 0 nothing_to_check

  !define L_CFG      $R9    ; file handle
  !define L_EXE      $R8    ; name of EXE file to be monitored
  !define L_LINE     $R7
  !define L_NEW_GUI  $R6
  !define L_PARAM    $R5
  !define L_RESULT   $R4
  !define L_TEXTEND  $R3    ; used to ensure correct handling of lines longer than 1023 chars

  Push ${L_CFG}
  Push ${L_EXE}
  Push ${L_LINE}
  Push ${L_NEW_GUI}
  Push ${L_PARAM}
  Push ${L_RESULT}
  Push ${L_TEXTEND}

  DetailPrint ""
  SetDetailsPrint both
  DetailPrint "$(PSS_LANG_PROG_CHECKIFRUNNING)"
  SetDetailsPrint listonly

  ; Starting with POPfile 0.21.0 an experimental version of 'popfile-service.exe' was included
  ; to allow POPFile to be run as a Windows service.

  Push "POPFile"
  Call ServiceRunning
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "true" manual_shutdown

  ; If we are about to add SSL support to a POPFile installation which is still running,
  ; then one of the EXE files will be 'locked' which means we have to shutdown POPFile.
  ;
  ; POPFile v0.20.0 and later may be using 'popfileb.exe', 'popfilef.exe', 'popfileib.exe',
  ; 'popfileif.exe', 'perl.exe' or 'wperl.exe'.
  ;
  ; Earlier versions of POPFile use only 'perl.exe' or 'wperl.exe'.

  Push $G_ROOTDIR
  Call FindLockedPFE
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" exit

  ; The program folders we are about to update are in use so we need to shut POPFile down

  DetailPrint "... it is locked."

  ; Attempt to discover which POPFile UI port is used by the current user, so we can issue
  ; a shutdown request.

  ReadRegStr ${L_CFG} HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "UserDir_LFN"
  StrCmp ${L_CFG} "" try_root_dir
  IfFileExists "${L_CFG}\popfile.cfg" check_cfg_file

try_root_dir:
  IfFileExists "$G_ROOTDIR\popfile.cfg" 0 manual_shutdown
  StrCpy ${L_CFG} "$G_ROOTDIR"

check_cfg_file:
  StrCpy ${L_NEW_GUI} ""

  ; See if we can get the current gui port from an existing configuration.
  ; There may be more than one entry for this port in the file - use the last one found

  FileOpen  ${L_CFG} "${L_CFG}\popfile.cfg" r

found_eol:
  StrCpy ${L_TEXTEND} "<eol>"

loop:
  FileRead ${L_CFG} ${L_LINE}
  StrCmp ${L_LINE} "" done
  StrCmp ${L_TEXTEND} "<eol>" 0 check_eol
  StrCmp ${L_LINE} "$\n" loop

  StrCpy ${L_PARAM} ${L_LINE} 10
  StrCmp ${L_PARAM} "html_port " 0 check_eol
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

  StrCmp ${L_NEW_GUI} "" manual_shutdown
  DetailPrint "$(PFI_LANG_INST_LOG_SHUTDOWN) ${L_NEW_GUI}"
  DetailPrint "$(PFI_LANG_TAKE_A_FEW_SECONDS)"
  Push ${L_NEW_GUI}
  Call ShutdownViaUI
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "success" check_exe
  StrCmp ${L_RESULT} "password?" manual_shutdown

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
  Goto exit

unlocked_now:
  DetailPrint "File is now unlocked"

exit:
  Pop ${L_TEXTEND}
  Pop ${L_RESULT}
  Pop ${L_PARAM}
  Pop ${L_NEW_GUI}
  Pop ${L_LINE}
  Pop ${L_EXE}
  Pop ${L_CFG}

  !undef L_CFG
  !undef L_EXE
  !undef L_LINE
  !undef L_NEW_GUI
  !undef L_PARAM
  !undef L_RESULT
  !undef L_TEXTEND

nothing_to_check:
FunctionEnd


#--------------------------------------------------------------------------
# Installer Function: GetSSLFile
#
# Inputs:
#         (top of stack)     - full URL used to download the SSL file
# Outputs:
#         none
#--------------------------------------------------------------------------

Function GetSSLFile

  Pop $G_SSL_FILEURL

  StrCpy $G_PLS_FIELD_1 $G_SSL_FILEURL
  Push $G_PLS_FIELD_1
  Call StrBackSlash
  Call GetParent
  Pop $G_PLS_FIELD_2
  StrLen $G_PLS_FIELD_2 $G_PLS_FIELD_2
  IntOp $G_PLS_FIELD_2 $G_PLS_FIELD_2 + 1
  StrCpy $G_PLS_FIELD_1 "$G_PLS_FIELD_1" "" $G_PLS_FIELD_2
  StrCpy $G_PLS_FIELD_2 "$G_SSL_FILEURL" $G_PLS_FIELD_2
  DetailPrint ""
  DetailPrint "$(PSS_LANG_PROG_STARTDOWNLOAD)"
  NSISdl::download "$G_SSL_FILEURL" "$PLUGINSDIR\$G_PLS_FIELD_1"
  Pop $G_PLS_FIELD_2
  StrCmp $G_PLS_FIELD_2 "success" file_received
  SetDetailsPrint both
  DetailPrint "$(PSS_LANG_MB_NSISDLFAIL_1)"
  SetDetailsPrint listonly
  DetailPrint "$(PSS_LANG_MB_NSISDLFAIL_2)"
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(PSS_LANG_MB_NSISDLFAIL_1)${MB_NL}$(PSS_LANG_MB_NSISDLFAIL_2)"
  SetDetailsPrint listonly
  DetailPrint ""
  Call GetDateTimeStamp
  Pop $G_PLS_FIELD_1
  DetailPrint "----------------------------------------------------"
  DetailPrint "POPFile SSL Setup failed ($G_PLS_FIELD_1)"
  DetailPrint "----------------------------------------------------"
  Abort

file_received:
FunctionEnd


#--------------------------------------------------------------------------
# Installer Function: DumpLog
#
# This function saves the contents of the install log (from INSTPAGE) in a file.
# The stack is used to pass the full pathname of the file to be used.
#--------------------------------------------------------------------------

  !define LVM_GETITEMCOUNT 0x1004
  !define LVM_GETITEMTEXT 0x102D

Function DumpLog
  Exch $5
  Push $0
  Push $1
  Push $2
  Push $3
  Push $4
  Push $6

  FindWindow $0 "#32770" "" $HWNDPARENT
  GetDlgItem $0 $0 1016
  StrCmp $0 0 error
  FileOpen $5 $5 "w"
  StrCmp $5 "" error
  SendMessage $0 ${LVM_GETITEMCOUNT} 0 0 $6
  System::Alloc ${NSIS_MAX_STRLEN}
  Pop $3
  StrCpy $2 0
  System::Call "*(i, i, i, i, i, i, i, i, i) i \
                (0, 0, 0, 0, 0, r3, ${NSIS_MAX_STRLEN}) .r1"

loop:
  StrCmp $2 $6 done
  System::Call "User32::SendMessageA(i, i, i, i) i \
                ($0, ${LVM_GETITEMTEXT}, $2, r1)"
  System::Call "*$3(&t${NSIS_MAX_STRLEN} .r4)"
  FileWrite $5 "$4${MB_NL}"
  IntOp $2 $2 + 1
  Goto loop

done:
  FileClose $5
  System::Free $1
  System::Free $3
  Goto exit

error:
  MessageBox MB_OK|MB_ICONEXCLAMATION "Error: problem detected when saving the log file"

exit:
  Pop $6
  Pop $4
  Pop $3
  Pop $2
  Pop $1
  Pop $0
  Exch $5

FunctionEnd


#==============================================================================================
# Small (sic) subset of the main PFI macro/function library (pfi-library.nsh)
#==============================================================================================
#
# Macro-based Functions  (in alphabetic order):
#
#    Macro:                CheckIfLocked
#    Installer Function:   CheckIfLocked
#
#    Macro:                FindLockedPFE
#    Installer Function:   FindLockedPFE
#
#    Macro:                GetDateTimeStamp
#    Installer Function:   GetDateTimeStamp
#
#    Macro:                GetFileSize
#    Installer Function:   GetFileSize
#
#    Macro:                GetLocalTime
#    Installer Function:   GetLocalTime
#
#    Macro:                GetParent
#    Installer Function:   GetParent
#
#    Macro:                ServiceCall
#    Installer Function:   ServiceCall
#
#    Macro:                ServiceRunning
#    Installer Function:   ServiceRunning
#
#    Macro:                ShutdownViaUI
#    Installer Function:   ShutdownViaUI
#
#    Macro:                StrBackSlash
#    Installer Function:   StrBackSlash
#
#    Macro:                StrCheckDecimal
#    Installer Function:   StrCheckDecimal
#
#    Macro:                TrimNewlines
#    Installer Function:   TrimNewlines
#
#    Macro:                WaitUntilUnlocked
#    Installer Function:   WaitUntilUnlocked
#
#==============================================================================================


#--------------------------------------------------------------------------
# Macro: CheckIfLocked
#
# The installation process and the uninstall process may both use a function which checks if
# a particular executable file (an EXE file) is being used. This macro makes maintenance easier
# by ensuring that both processes use identical functions, with the only difference being their
# names.
#
# The EXE file to be checked depends upon the version of POPFile in use and upon how it has
# been configured. If the specified EXE file is no longer in use, this function returns an empty
# string (otherwise it returns the input parameter unchanged).
#
# NOTE:
# The !insertmacro CheckIfLocked "" and !insertmacro CheckIfLocked "un." commands are included
# in this file so the NSIS script can use 'Call CheckIfLocked' and 'Call un.CheckIfLocked'
# without additional preparation.
#
# Inputs:
#         (top of stack)     - the full path of the EXE file to be checked
#
# Outputs:
#         (top of stack)     - if file is no longer in use, an empty string ("") is returned
#                              otherwise the input string is returned
#
# Usage (after macro has been 'inserted'):
#
#         Push "$INSTDIR\wperl.exe"
#         Call CheckIfLocked
#         Pop $R0
#
#        (if the file is no longer in use, $R0 will be "")
#        (if the file is still being used, $R0 will be "$INSTDIR\wperl.exe")
#--------------------------------------------------------------------------

!macro CheckIfLocked UN
  Function ${UN}CheckIfLocked
    !define L_EXE           $R9   ; full path to the EXE file which is to be monitored
    !define L_FILE_HANDLE   $R8

    Exch ${L_EXE}
    Push ${L_FILE_HANDLE}

    IfFileExists "${L_EXE}" 0 unlocked_exit
    SetFileAttributes "${L_EXE}" NORMAL

    ClearErrors
    FileOpen ${L_FILE_HANDLE} "${L_EXE}" a
    FileClose ${L_FILE_HANDLE}
    IfErrors exit

  unlocked_exit:
    StrCpy ${L_EXE} ""

   exit:
    Pop ${L_FILE_HANDLE}
    Exch ${L_EXE}

    !undef L_EXE
    !undef L_FILE_HANDLE
  FunctionEnd
!macroend

#--------------------------------------------------------------------------
# Installer Function: CheckIfLocked
#
# This function is used during the installation process
#--------------------------------------------------------------------------

!insertmacro CheckIfLocked ""


#--------------------------------------------------------------------------
# Macro: FindLockedPFE
#
# The installation process and the uninstall process may both use a function which checks if
# any of the POPFile executable (EXE) files is being used. This macro makes maintenance easier
# by ensuring that both processes use identical functions, with the only difference being their
# names.
#
# Early versions of POPFile only had two EXE files to check (perl.exe and wperl.exe) but current
# versions have a much greater choice. More than one script needs to perform these checks, so
# these macro-based functions have been created to make it easier to change the list of files to
# be checked.
#
# NOTE:
# The !insertmacro FindLockedPFE "" and !insertmacro FindLockedPFE "un." commands are included
# in this file so the NSIS script can use 'Call FindLockedPFE' and 'Call un.FindLockedPFE'
# without additional preparation.
#
# Inputs:
#         (top of stack)   - the path where the EXE files can be found
#
# Outputs:
#         (top of stack)   - if a locked EXE file is found, its full path is returned otherwise
#                            an empty string ("") is returned (to show that no files are locked)
#
# Usage (after macro has been 'inserted'):
#
#         Push "C:\Program Files\POPFile"
#         Call FindLockedPFE
#         Pop $R0
#
#        (if popfileb.exe is still running, $R0 will be "C:\Program Files\POPFile\popfileb.exe")
#--------------------------------------------------------------------------

!macro FindLockedPFE UN
  Function ${UN}FindLockedPFE
    !define L_PATH          $R9    ; full path to the POPFile EXE files which are to be checked
    !define L_RESULT        $R8    ; either the full path to a locked file or an empty string

    Exch ${L_PATH}
    Push ${L_RESULT}
    Exch

    DetailPrint "Checking '${L_PATH}\popfileb.exe' ..."

    Push "${L_PATH}\popfileb.exe"  ; runs POPFile in the background
    Call ${UN}CheckIfLocked
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" 0 exit

    DetailPrint "Checking '${L_PATH}\popfileib.exe' ..."

    Push "${L_PATH}\popfileib.exe" ; runs POPFile in the background with system tray icon
    Call ${UN}CheckIfLocked
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" 0 exit

    DetailPrint "Checking '${L_PATH}\popfilef.exe' ..."

    Push "${L_PATH}\popfilef.exe"  ; runs POPFile in the foreground/console window/DOS box
    Call ${UN}CheckIfLocked
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" 0 exit

    DetailPrint "Checking '${L_PATH}\popfileif.exe' ..."

    Push "${L_PATH}\popfileif.exe" ; runs POPFile in the foreground with system tray icon
    Call ${UN}CheckIfLocked
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" 0 exit

    DetailPrint "Checking '${L_PATH}\wperl.exe' ..."

    Push "${L_PATH}\wperl.exe"     ; runs POPFile in the background (using popfile.pl)
    Call ${UN}CheckIfLocked
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" 0 exit

    DetailPrint "Checking '${L_PATH}\perl.exe' ..."

    Push "${L_PATH}\perl.exe"      ; runs POPFile in the foreground (using popfile.pl)
    Call ${UN}CheckIfLocked
    Pop ${L_RESULT}

   exit:
    Pop ${L_PATH}
    Exch ${L_RESULT}              ; return full path to a locked file or an empty string

    !undef L_PATH
    !undef L_RESULT
  FunctionEnd
!macroend

#--------------------------------------------------------------------------
# Installer Function: FindLockedPFE
#
# This function is used during the installation process
#--------------------------------------------------------------------------

!insertmacro FindLockedPFE ""


#--------------------------------------------------------------------------
# Macro: GetDateTimeStamp
#
# The installation process and the uninstall process may need a function which returns a
# string with the current date and time (using the current time from Windows). This macro
# makes maintenance easier by ensuring that both processes use identical functions, with
# the only difference being their names.
#
# NOTE:
# The !insertmacro GetDateTimeStamp "" and !insertmacro GetDateTimeStamp "un." commands are
# included in this file so the NSIS script and/or other library functions in 'pfi-library.nsh'
# can use 'Call GetDateTimeStamp' & 'Call un.GetDateTimeStamp' without additional preparation.
#
# Inputs:
#         (none)
# Outputs:
#         (top of stack)     - string with current date and time (eg '08-Dec-2003 @ 23:01:59')
#
# Usage (after macro has been 'inserted'):
#
#         Call GetDateTimeStamp
#         Pop $R9
#
#         ($R9 now holds a string like '08-Dec-2003 @ 23:01:59')
#--------------------------------------------------------------------------

!macro GetDateTimeStamp UN
  Function ${UN}GetDateTimeStamp

    !define L_DATETIMESTAMP   $R9
    !define L_DAY             $R8
    !define L_MONTH           $R7
    !define L_YEAR            $R6
    !define L_HOURS           $R5
    !define L_MINUTES         $R4
    !define L_SECONDS         $R3

    Push ${L_DATETIMESTAMP}
    Push ${L_DAY}
    Push ${L_MONTH}
    Push ${L_YEAR}
    Push ${L_HOURS}
    Push ${L_MINUTES}
    Push ${L_SECONDS}

    Call ${UN}GetLocalTime
    Pop ${L_YEAR}
    Pop ${L_MONTH}
    Pop ${L_DAY}              ; ignore day of week
    Pop ${L_DAY}
    Pop ${L_HOURS}
    Pop ${L_MINUTES}
    Pop ${L_SECONDS}
    Pop ${L_DATETIMESTAMP}    ; ignore milliseconds

    IntCmp ${L_DAY} 10 +2 0 +2
    StrCpy ${L_DAY} "0${L_DAY}"

    StrCmp ${L_MONTH} 1 0 +3
    StrCpy ${L_MONTH} Jan
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 2 0 +3
    StrCpy ${L_MONTH} Feb
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 3 0 +3
    StrCpy ${L_MONTH} Mar
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 4 0 +3
    StrCpy ${L_MONTH} Apr
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 5 0 +3
    StrCpy ${L_MONTH} May
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 6 0 +3
    StrCpy ${L_MONTH} Jun
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 7 0 +3
    StrCpy ${L_MONTH} Jul
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 8 0 +3
    StrCpy ${L_MONTH} Aug
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 9 0 +3
    StrCpy ${L_MONTH} Sep
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 10 0 +3
    StrCpy ${L_MONTH} Oct
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 11 0 +3
    StrCpy ${L_MONTH} Nov
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 12 0 +2
    StrCpy ${L_MONTH} Dec

  DoubleDigitTime:
    IntCmp ${L_HOURS} 10 +2 0 +2
    StrCpy ${L_HOURS} "0${L_HOURS}"

    IntCmp ${L_MINUTES} 10 +2 0 +2
    StrCpy ${L_MINUTES} "0${L_MINUTES}"

    IntCmp ${L_SECONDS} 10 +2 0 +2
    StrCpy ${L_SECONDS} "0${L_SECONDS}"

    StrCpy ${L_DATETIMESTAMP} "${L_DAY}-${L_MONTH}-${L_YEAR} @ ${L_HOURS}:${L_MINUTES}:${L_SECONDS}"

    Pop ${L_SECONDS}
    Pop ${L_MINUTES}
    Pop ${L_HOURS}
    Pop ${L_YEAR}
    Pop ${L_MONTH}
    Pop ${L_DAY}
    Exch ${L_DATETIMESTAMP}

    !undef L_DATETIMESTAMP
    !undef L_DAY
    !undef L_MONTH
    !undef L_YEAR
    !undef L_HOURS
    !undef L_MINUTES
    !undef L_SECONDS

  FunctionEnd
!macroend

#--------------------------------------------------------------------------
# Installer Function: GetDateTimeStamp
#
# This function is used during the installation process
#--------------------------------------------------------------------------

!insertmacro GetDateTimeStamp ""


#--------------------------------------------------------------------------
# Macro: GetFileSize
#
# The installation process and the uninstall process may need a function which gets the
# size (in bytes) of a particular file. This macro makes maintenance easier by ensuring
# that both processes use identical functions, with the only difference being their names.
#
# If the specified file is not found, the function returns -1
#
# NOTE:
# The !insertmacro GetFileSize "" and !insertmacro GetFileSize "un." commands are included
# in this file so the NSIS script and/or other library functions in 'pfi-library.nsh' can use
# 'Call GetFileSize' and 'Call un.GetFileSize' without additional preparation.
#
# Inputs:
#         (top of stack)     - filename of file to be checked
# Outputs:
#         (top of stack)     - length of the file (in bytes)
#                              or '-1' if file not found
#                              or '-2' if error occurred
#
# Usage (after macro has been 'inserted'):
#
#         Push "corpus\spam\table"
#         Call GetFileSize
#         Pop $R0
#
#         ($R0 now holds the size (in bytes) of the 'spam' bucket's 'table' file)
#
#--------------------------------------------------------------------------

!macro GetFileSize UN
    Function ${UN}GetFileSize

      !define L_FILENAME  $R9
      !define L_RESULT    $R8

      Exch ${L_FILENAME}
      Push ${L_RESULT}
      Exch

      IfFileExists ${L_FILENAME} find_size
      StrCpy ${L_RESULT} "-1"
      Goto exit

    find_size:
      ClearErrors
      FileOpen ${L_RESULT} ${L_FILENAME} r
      FileSeek ${L_RESULT} 0 END ${L_FILENAME}
      FileClose ${L_RESULT}
      IfErrors 0 return_size
      StrCpy ${L_RESULT} "-2"
      Goto exit

    return_size:
      StrCpy ${L_RESULT} ${L_FILENAME}

    exit:
      Pop ${L_FILENAME}
      Exch ${L_RESULT}

      !undef L_FILENAME
      !undef L_RESULT

    FunctionEnd
!macroend

#--------------------------------------------------------------------------
# Installer Function: GetFileSize
#
# This function is used during the installation process
#--------------------------------------------------------------------------

!insertmacro GetFileSize ""


#--------------------------------------------------------------------------
# Macro: GetLocalTime
#
# The installation process and the uninstall process may need a function which gets the
# local time from Windows (to generate data and/or time stamps, etc). This macro makes
# maintenance easier by ensuring that both processes use identical functions, with
# the only difference being their names.
#
# Normally this function will be used by a higher level one which returns a suitable string.
#
# NOTE:
# The !insertmacro GetLocalTime "" and !insertmacro GetLocalTime "un." commands are included
# in this file so the NSIS script and/or other library functions in 'pfi-library.nsh' can use
# 'Call GetLocalTime' and 'Call un.GetLocalTime' without additional preparation.
#
# Inputs:
#         (none)
# Outputs:
#         (top of stack)     - year         (4-digits)
#         (top of stack - 1) - month        (1 to 12)
#         (top of stack - 2) - day of week  (0 = Sunday, 6 = Saturday)
#         (top of stack - 3) - day          (1 - 31)
#         (top of stack - 4) - hours        (0 - 23)
#         (top of stack - 5) - minutes      (0 - 59)
#         (top of stack - 6) - seconds      (0 - 59)
#         (top of stack - 7) - milliseconds (0 - 999)
#
# Usage (after macro has been 'inserted'):
#
#         Call GetLocalTime
#         Pop $Year
#         Pop $Month
#         Pop $DayOfWeek
#         Pop $Day
#         Pop $Hours
#         Pop $Minutes
#         Pop $Seconds
#         Pop $Milliseconds
#--------------------------------------------------------------------------

!macro GetLocalTime UN
  Function ${UN}GetLocalTime

    # Preparing Variables

    Push $1
    Push $2
    Push $3
    Push $4
    Push $5
    Push $6
    Push $7
    Push $8

    # Calling the Function GetLocalTime from Kernel32.dll

    System::Call '*(&i2, &i2, &i2, &i2, &i2, &i2, &i2, &i2) i .r1'
    System::Call 'kernel32::GetLocalTime(i) i(r1)'
    System::Call '*$1(&i2, &i2, &i2, &i2, &i2, &i2, &i2, &i2)(.r8, .r7, .r6, .r5, .r4, .r3, .r2, .r1)'

    # Returning to User

    Exch $8
    Exch
    Exch $7
    Exch
    Exch 2
    Exch $6
    Exch 2
    Exch 3
    Exch $5
    Exch 3
    Exch 4
    Exch $4
    Exch 4
    Exch 5
    Exch $3
    Exch 5
    Exch 6
    Exch $2
    Exch 6
    Exch 7
    Exch $1
    Exch 7

  FunctionEnd
!macroend

#--------------------------------------------------------------------------
# Installer Function: GetLocalTime
#
# This function is used during the installation process
#--------------------------------------------------------------------------

!insertmacro GetLocalTime ""


#--------------------------------------------------------------------------
# Macro: GetParent
#
# The installation process and the uninstall process may both use a function which extracts the
# parent directory from a given path. This macro makes maintenance easier by ensuring that both
# processes use identical functions, with the only difference being their names.
#
# NB: The path is assumed to use backslashes (\)
#
# NOTE:
# The !insertmacro GetParent "" and !insertmacro GetParent "un." commands are included
# in this file so the NSIS script can use 'Call GetParent' and 'Call un.GetParent'
# without additional preparation.
#
# Inputs:
#         (top of stack)          - string containing a path (e.g. C:\A\B\C)
#
# Outputs:
#         (top of stack)          - the parent part of the input string (e.g. C:\A\B)
#
# Usage (after macro has been 'inserted'):
#
#         Push "C:\Program Files\Directory\Whatever"
#         Call un.GetParent
#         Pop $R0
#
#         ($R0 at this point is ""C:\Program Files\Directory")
#
#--------------------------------------------------------------------------

!macro GetParent UN
  Function ${UN}GetParent
    Exch $R0
    Push $R1
    Push $R2
    Push $R3

    StrCpy $R1 0
    StrLen $R2 $R0

  loop:
    IntOp $R1 $R1 + 1
    IntCmp $R1 $R2 get 0 get
    StrCpy $R3 $R0 1 -$R1
    StrCmp $R3 "\" get
    Goto loop

  get:
    StrCpy $R0 $R0 -$R1

    Pop $R3
    Pop $R2
    Pop $R1
    Exch $R0
  FunctionEnd
!macroend

#--------------------------------------------------------------------------
# Installer Function: GetParent
#
# This function is used during the installation process
#--------------------------------------------------------------------------

!insertmacro GetParent ""


#--------------------------------------------------------------------------
# Macro: ServiceCall
#
# The installation process and the uninstall process may both need a function which interfaces
# with the Windows Service Control Manager (SCM).  This macro makes maintenance easier by
# ensuring that both processes use identical functions, with the only difference being their
# names.
#
# NOTE: This version only supports a subset of the available Service Control Manager actions.
#
# NOTE:
# The !insertmacro ServiceCall "" and !insertmacro ServiceCall "un." commands are included
# in this file so the NSIS script can use 'Call ServiceCall' and 'Call un.ServiceCall'
# without additional preparation.
#
# Inputs:
#         (top of stack)       - action required (only the following action is supported):
#                                   status     - returns status of the named service
#
#         (top of stack - 1)   - service name (normally 'POPFile')
#
# Outputs:
#         (top of stack)       - string containing a result code. Result codes depend upon the
#                                value of the 'action required' input parameter:
#
#                                'status' action result codes:
#                                   scmerror          - unable to open service database (Win9x?)
#                                   openerror         - unable to get a handle to the service
#
#                                   running           - service is running
#                                   stopped           - service is stopped
#                                   start_pending     - the service is starting
#                                   stop_pending      - the service is stopping
#                                   continue_pending  - the service continue is pending
#                                   pause_pending     - the service pause is pending
#                                   paused            - the service is paused
#
#                                   unknown           - (the response didn't match any of above)
#
#                                result code for all other action requests:
#                                   unsupportedaction - an unsupported action was requested
#
# Usage (after macro has been 'inserted'):
#
#         Push "status"
#         Push "POPFile"
#         Call un.ServiceCall
#         Pop $R0
#
#         (if $R0 at this point is "running" then POPFile is running as a Windows service)
#
#--------------------------------------------------------------------------

!macro ServiceCall UN

  !ifndef PFI_SERVICE_DEFINES
      !define PFI_SERVICE_DEFINES

      !define SC_MANAGER_ALL_ACCESS    0x3F
      !define SERVICE_ALL_ACCESS    0xF01FF

      !define SERVICE_STOPPED           0x1
      !define SERVICE_START_PENDING     0x2
      !define SERVICE_STOP_PENDING      0x3
      !define SERVICE_RUNNING           0x4
      !define SERVICE_CONTINUE_PENDING  0x5
      !define SERVICE_PAUSE_PENDING     0x6
      !define SERVICE_PAUSED            0x7
  !endif

  Function ${UN}ServiceCall

    Push $0   ; used to return the result
    Push $2
    Push $3
    Push $4   ; OpenSCManager handle
    Push $5   ; OpenService handle
    Push $6
    Push $7
    Exch 7
    Pop $2    ; service name
    Exch 7
    Pop $3    ; action required

    StrCmp $3 "status" 0 unsupported_action

    System::Call 'advapi32::OpenSCManagerA(n, n, i ${SC_MANAGER_ALL_ACCESS}) i.r4'
    IntCmp $4 0 scm_error

    StrCpy $0 "openerr"
    System::Call 'advapi32::OpenServiceA(i r4, t r2, i ${SERVICE_ALL_ACCESS}) i.r5'
    IntCmp $5 0 close_OpenSCM_handle

#  action_status:
    Push $R1
    System::Call '*(i,i,i,i,i,i,i) i.R1'
    System::Call 'advapi32::QueryServiceStatus(i r5, i $R1) i'
    System::Call '*$R1(i, i .r6)'
    System::Free $R1
    Pop $R1
    IntFmt $6 "0x%X" $6
    StrCpy $0 "running"
    IntCmp $6 ${SERVICE_RUNNING} closehandles
    StrCpy $0 "stopped"
    IntCmp $6 ${SERVICE_STOPPED} closehandles
    StrCpy $0 "start_pending"
    IntCmp $6 ${SERVICE_START_PENDING} closehandles
    StrCpy $0 "stop_pending"
    IntCmp $6 ${SERVICE_STOP_PENDING} closehandles
    StrCpy $0 "continue_pending"
    IntCmp $6 ${SERVICE_CONTINUE_PENDING} closehandles
    StrCpy $0 "pause_pending"
    IntCmp $6 ${SERVICE_PAUSE_PENDING} closehandles
    StrCpy $0 "paused"
    IntCmp $6 ${SERVICE_PAUSED} closehandles
    StrCpy $0 "unknown"
    Goto closehandles

  unsupported_action:
    StrCpy $0 "unsupportedaction"
    DetailPrint "'ServiceCall' unsupported action ($3)"
    Goto return_result

  scm_error:
    StrCpy $0 "scmerror"
    DetailPrint "'ServiceCall' failed (Win9x system?)"
    Goto return_result

  closehandles:
    IntCmp $5 0 close_OpenSCM_handle
    System::Call 'advapi32::CloseServiceHandle(i r5) n'

  close_OpenSCM_handle:
    IntCmp $4 0 display_result
    System::Call 'advapi32::CloseServiceHandle(i r4) n'

  display_result:
    DetailPrint "$2 'ServiceCall' response: $0"

  return_result:
    Pop $5
    Pop $4
    Pop $3
    Pop $2
    Exch 2
    Pop $6
    Pop $7
    Exch $0           ; stack = result code string
  FunctionEnd
!macroend

#--------------------------------------------------------------------------
# Installer Function: ServiceCall
#
# This function is used during the installation process
#--------------------------------------------------------------------------

!insertmacro ServiceCall ""


#--------------------------------------------------------------------------
# Macro: ServiceRunning
#
# The installation process and the uninstall process may both need a function which checks
# if a particular Windows service is running. This macro makes maintenance easier by ensuring
# that both processes use identical functions, with the only difference being their names.
#
# NOTE:
# The !insertmacro ServiceRunning "" and !insertmacro ServiceRunning "un." commands are included
# in this file so the NSIS script can use 'Call ServiceRunning' and 'Call un.ServiceRunning'
# without additional preparation.
#
# Inputs:
#         (top of stack)       - name of the Windows Service to be checked (normally "POPFile")
#
# Outputs:
#         (top of stack)       - string containing one of the following result codes:
#                                   true           - service is running
#                                   false          - service is not running
#
# Usage (after macro has been 'inserted'):
#
#         Push "POPFile"
#         Call ServiceRunning
#         Pop $R0
#
#         (if $R0 at this point is "true" then POPFile is running as a Windows service)
#
#--------------------------------------------------------------------------

!macro ServiceRunning UN
  Function ${UN}ServiceRunning

    !define L_RESULT    $R9

    Push ${L_RESULT}
    Exch
    Push "status"
    Exch
    Call ${UN}ServiceCall     ; uses 2 parameters from top of stack (top = servicename, action)
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "running" 0 not_running
    StrCpy ${L_RESULT} "true"
    Goto exit

  not_running:
    StrCpy ${L_RESULT} "false"

  exit:
    Exch ${L_RESULT}          ; return "true" or "false" on top of stack

    !undef L_RESULT

  FunctionEnd
!macroend

#--------------------------------------------------------------------------
# Installer Function: ServiceRunning
#
# This function is used during the installation process
#--------------------------------------------------------------------------

!insertmacro ServiceRunning ""


#--------------------------------------------------------------------------
# Macro: ShutdownViaUI
#
# The installation process and the uninstall process may both use a function which attempts to
# shutdown POPFile using the User Interface (UI) invisibly (i.e. no browser window is used).
# This macro makes maintenance easier by ensuring that both processes use identical functions,
# with the only difference being their names.
#
# To avoid the need to parse the HTML page downloaded by NSISdl, we call NSISdl again if the
# first call succeeds. If the second call succeeds, we assume the UI is password protected.
# As a debugging aid, we don't overwrite the first HTML file with the result of the second call.
#
# NOTE:
# The !insertmacro ShutdownViaUI "" and !insertmacro ShutdownViaUI "un." commands are included
# in this file so the NSIS script can use 'Call ShutdownViaUI' and 'Call un.ShutdownViaUI'
# without additional preparation.
#
# Inputs:
#         (top of stack)       - UI port to be used when issuing the shutdown request
#
# Outputs:
#         (top of stack)       - string containing one of the following result codes:
#
#                                   "success"    (meaning UI shutdown request appeared to work)
#
#                                   "failure"    (meaning UI shutdown request failed)
#
#                                   "password?"  (meaning failure: UI may be password protected)
#
#                                   "badport"    (meaning failure: invalid UI port supplied)
#
# Usage (after macro has been 'inserted'):
#
#         Push "8080"
#         Call ShutdownViaUI
#         Pop $R0
#
#         (if $R0 at this point is "password?" then POPFile is still running)
#
#--------------------------------------------------------------------------

!macro ShutdownViaUI UN
  Function ${UN}ShutdownViaUI

    ;--------------------------------------------------------------------------
    ; Override the default timeout for NSISdl requests (specifies timeout in milliseconds)

    !define C_SVU_DLTIMEOUT       /TIMEOUT=10000

    ; Delay between the two shutdown requests (in milliseconds)

    !define C_SVU_DLGAP           2000
    ;--------------------------------------------------------------------------

    !define L_RESULT    $R9
    !define L_UIPORT    $R8

    Exch ${L_UIPORT}
    Push ${L_RESULT}
    Exch

    StrCmp ${L_UIPORT} "" badport
    Push ${L_UIPORT}
    Call ${UN}StrCheckDecimal
    Pop ${L_UIPORT}
    StrCmp ${L_UIPORT} "" badport
    IntCmp ${L_UIPORT} 1 port_ok badport
    IntCmp ${L_UIPORT} 65535 port_ok port_ok

  badport:
    StrCpy ${L_RESULT} "badport"
    Goto exit

  port_ok:
    NSISdl::download_quiet ${C_SVU_DLTIMEOUT} http://${C_UI_URL}:${L_UIPORT}/shutdown "$PLUGINSDIR\shutdown_1.htm"
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "success" try_again
    StrCpy ${L_RESULT} "failure"
    Goto exit

  try_again:
    Sleep ${C_SVU_DLGAP}
    NSISdl::download_quiet ${C_SVU_DLTIMEOUT} http://${C_UI_URL}:${L_UIPORT}/shutdown "$PLUGINSDIR\shutdown_2.htm"
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "success" 0 shutdown_ok
    Push "$PLUGINSDIR\shutdown_2.htm"
    Call ${UN}GetFileSize
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} 0 shutdown_ok
    StrCpy ${L_RESULT} "password?"
    Goto exit

  shutdown_ok:
    StrCpy ${L_RESULT} "success"

  exit:
    Pop ${L_UIPORT}
    Exch ${L_RESULT}

    !undef C_SVU_DLTIMEOUT
    !undef C_SVU_DLGAP

    !undef L_RESULT
    !undef L_UIPORT

  FunctionEnd
!macroend

#--------------------------------------------------------------------------
# Installer Function: ShutdownViaUI
#
# This function is used during the installation process
#--------------------------------------------------------------------------

!insertmacro ShutdownViaUI ""


#--------------------------------------------------------------------------
# Macro: StrBackSlash
#
# The installation process and the uninstall process may both use a function which converts all
# slashes in a string into backslashes. This macro makes maintenance easier by ensuring that
# both processes use identical functions, with the only difference being their names.
#
# NOTE:
# The !insertmacro StrBackSlash "" and !insertmacro StrBackSlash "un." commands are included
# in this file so the NSIS script can use 'Call StrBackSlash' and 'Call un.StrBackSlash'
# without additional preparation.
#
# Inputs:
#         (top of stack)            - string containing slashes (e.g. "C:/This/and/That")
#
# Outputs:
#         (top of stack)            - string containing backslashes (e.g. "C:\This\and\That")
#
# Usage (after macro has been 'inserted'):
#
#         Push "C:/Program Files/Directory/Whatever"
#         Call StrBackSlash
#         Pop $R0
#
#         ($R0 at this point is "C:\Program Files\Directory\Whatever")
#
#--------------------------------------------------------------------------

!macro StrBackSlash UN
  Function ${UN}StrBackSlash
    Exch $R0    ; Input string with slashes
    Push $R1    ; Output string using backslashes
    Push $R2    ; Current character

    StrCpy $R1 ""
    StrCmp $R0 $R1 nothing_to_do

  loop:
    StrCpy $R2 $R0 1
    StrCpy $R0 $R0 "" 1
    StrCmp $R2 "/" found
    StrCpy $R1 "$R1$R2"
    StrCmp $R0 "" done loop

  found:
    StrCpy $R1 "$R1\"
    StrCmp $R0 "" done loop

  done:
    StrCpy $R0 $R1

  nothing_to_do:
    Pop $R2
    Pop $R1
    Exch $R0
  FunctionEnd
!macroend

#--------------------------------------------------------------------------
# Installer Function: StrBackSlash
#
# This function is used during the installation process
#--------------------------------------------------------------------------

!insertmacro StrBackSlash ""


#--------------------------------------------------------------------------
# Macro: StrCheckDecimal
#
# The installation process and the uninstall process may both use a function which checks if
# a given string contains a decimal number. This macro makes maintenance easier by ensuring
# that both processes use identical functions, with the only difference being their names.
#
# The 'StrCheckDecimal' and 'un.StrCheckDecimal' functions check that a given string contains
# only the digits 0 to 9. (if the string contains any invalid characters, "" is returned)
#
# NOTE:
# The !insertmacro StrCheckDecimal "" and !insertmacro StrCheckDecimal "un." commands are
# included in this file so the NSIS script can use 'Call StrCheckDecimal' and
# 'Call un.StrCheckDecimal' without additional preparation.
#
# Inputs:
#         (top of stack)   - string which may contain a decimal number
#
# Outputs:
#         (top of stack)   - the input string (if valid) or "" (if invalid)
#
# Usage (after macro has been 'inserted'):
#
#         Push "12345"
#         Call un.StrCheckDecimal
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
# Macro: TrimNewlines
#
# The installation process and the uninstall process may both use a function to trim newlines
# from lines of text. This macro makes maintenance easier by ensuring that both processes use
# identical functions, with the only difference being their names.
#
# NOTE:
# The !insertmacro TrimNewlines "" and !insertmacro TrimNewlines "un." commands are
# included in this file so the NSIS script can use 'Call TrimNewlines' and
# 'Call un.TrimNewlines' without additional preparation.
#
# Inputs:
#         (top of stack)   - string which may end with one or more newlines
#
# Outputs:
#         (top of stack)   - the input string with the trailing newlines (if any) removed
#
# Usage (after macro has been 'inserted'):
#
#         Push "whatever$\r$\n"
#         Call un.TrimNewlines
#         Pop $R0
#         ($R0 at this point is "whatever")
#
#--------------------------------------------------------------------------

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
# Macro: WaitUntilUnlocked
#
# The installation process and the uninstall process may both use a function which waits until
# a particular executable file (an EXE file) is no longer in use. This macro makes maintenance
# easier by ensuring that both processes use identical functions, with the only difference being
# their names.
#
# The EXE file to be checked depends upon the version of POPFile in use and upon how it has been
# configured. It may take a little while for POPFile to shutdown so the installer/uninstaller
# calls this function which waits in a loop until the specified EXE file is no longer in use.
# A timeout counter is used to avoid an infinite loop.
#
# NOTE:
# The !insertmacro WaitUntilUnlocked "" and !insertmacro WaitUntilUnlocked "un." commands are
# included in this file so the NSIS script can use 'Call WaitUntilUnlocked' and
# 'Call un.WaitUntilUnlocked' without additional preparation.
#
# Inputs:
#         (top of stack)     - the full path of the EXE file to be checked
#
# Outputs:
#         (none)
#
# Usage (after macro has been 'inserted'):
#
#         Push "$INSTDIR\wperl.exe"
#         Call WaitUntilUnlocked
#
#--------------------------------------------------------------------------

!macro WaitUntilUnlocked UN
  Function ${UN}WaitUntilUnlocked
    !define L_EXE           $R9   ; full path to the EXE file which is to be monitored
    !define L_FILE_HANDLE   $R8
    !define L_TIMEOUT       $R7   ; used to avoid an infinite loop

    ;-----------------------------------------------------------
    ; Timeout loop counter start value (counts down to 0)

    !ifndef C_SHUTDOWN_LIMIT
      !define C_SHUTDOWN_LIMIT    20
    !endif

    ; Delay (in milliseconds) used inside the timeout loop

    !ifndef C_SHUTDOWN_DELAY
      !define C_SHUTDOWN_DELAY    1000
    !endif
    ;-----------------------------------------------------------

    Exch ${L_EXE}
    Push ${L_FILE_HANDLE}
    Push ${L_TIMEOUT}

    IfFileExists "${L_EXE}" 0 exit_now
    SetFileAttributes "${L_EXE}" NORMAL
    StrCpy ${L_TIMEOUT} ${C_SHUTDOWN_LIMIT}

  check_if_unlocked:
    Sleep ${C_SHUTDOWN_DELAY}
    ClearErrors
    FileOpen ${L_FILE_HANDLE} "${L_EXE}" a
    FileClose ${L_FILE_HANDLE}
    IfErrors 0 exit_now
    IntOp ${L_TIMEOUT} ${L_TIMEOUT} - 1
    IntCmp ${L_TIMEOUT} 0 exit_now exit_now check_if_unlocked

   exit_now:
    Pop ${L_TIMEOUT}
    Pop ${L_FILE_HANDLE}
    Pop ${L_EXE}

    !undef L_EXE
    !undef L_FILE_HANDLE
    !undef L_TIMEOUT
  FunctionEnd
!macroend

#--------------------------------------------------------------------------
# Installer Function: WaitUntilUnlocked
#
# This function is used during the installation process
#--------------------------------------------------------------------------

!insertmacro WaitUntilUnlocked ""


#--------------------------------------------------------------------------
# End of 'addssl.nsi'
#--------------------------------------------------------------------------
