#--------------------------------------------------------------------------
#
# pfidiag.nsi --- This NSIS script is used to create a simple diagnostic utility
#                 to assist in solving problems with POPFile installations created
#                 by the Windows installer for POPFile v0.21.0 (or later).
#
# Copyright (c) 2004-2005  John Graham-Cumming
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


  ;------------------------------------------------
  ; This script requires the 'ShellLink' NSIS plugin
  ;------------------------------------------------
  ;
  ; This script uses a special NSIS plugin (ShellLink) to extract information from a Windows
  ; shortcut (*.lnk) file
  ;
  ; The 'NSIS Wiki' page for the 'ShellLink' plugin (description, example and download links):
  ; http://nsis.sourceforge.net/wiki/ShellLink_plugin
  ;
  ; To compile this script, copy the 'ShellLink.dll' file to the standard NSIS plugins folder
  ; (${NSISDIR}\Plugins\). The 'ShellLink' source and example files can be unzipped to the
  ; ${NSISDIR}\Contrib\ShellLink\ folder if you wish, but this step is entirely optional.
  ;
  ; This script requires v1.1 (or later) of the ShellLink plugin


#--------------------------------------------------------------------------
# Run-time command-line switch (used by 'pfidiag.exe')
#--------------------------------------------------------------------------
#
# /HELP
#
# Displays some simple notes about the command-line options
#
# /SIMPLE
#
# This command-line switch selects the default mode which only displays a few key values.
# The display window is automatically scrolled to display the POPFile program and 'User Data'
# locations since these are likely to be of most interest to the user.
#
# /FULL
#
# Normally the utility displays enough information to identify the location of the 'User Data'
# files. If this command-line switch is supplied, the utility displays much more information
# (which might help debug strange behaviour, for example).
#
# /SHORTCUT
#
# This command-line switch creates a Start Menu shortcut to the 'User Data' folder (accessed
# via the Start -> Programs -> POPFile -> Support -> User Data (<username>) entry)
#
#
# NOTES:
#
# ( 1)  Uppercase or lowercase may be used for the command-line switches.
#
# ( 2)  If no command-line switch is supplied, the default mode (/SIMPLE) is selected.
#
# ( 3)  It is assumed that only one command-line option will be supplied. If an invalid
#       option or a combination of options is supplied then the /HELP option is selected.
#
#--------------------------------------------------------------------------


  ;--------------------------------------------------------------------------
  ; POPFile constants have been given names beginning with 'C_' (eg C_README)
  ;--------------------------------------------------------------------------

  !define C_VERSION   "0.0.57"

  !define C_OUTFILE   "pfidiag.exe"

  ;--------------------------------------------------------------------------
  ; The default NSIS caption is "$(^Name) Setup" so we override it here
  ;--------------------------------------------------------------------------

  Name    "PFI Diagnostic Utility"
  Caption "$(^Name) v${C_VERSION}"

  ; Check data created by the "main" POPFile installer and/or its 'Add POPFile User' wizard

  !define C_PFI_PRODUCT                 "POPFile"
  !define C_PFI_PRODUCT_REGISTRY_ENTRY  "Software\POPFile Project\${C_PFI_PRODUCT}\MRI"

#--------------------------------------------------------------------------
# Use the "Modern User Interface"
#--------------------------------------------------------------------------

  !include "MUI.nsh"

#--------------------------------------------------------------------------
# Include private library functions and macro definitions
#--------------------------------------------------------------------------

  ; Avoid compiler warnings by disabling the functions and definitions we do not use

  !define PFIDIAG

  !include "..\pfi-library.nsh"

#--------------------------------------------------------------------------
# Version Information settings (for the utility's EXE file)
#--------------------------------------------------------------------------

  ; 'VIProductVersion' format is X.X.X.X where X is a number in range 0 to 65535
  ; representing the following values: Major.Minor.Release.Build

  VIProductVersion                          "${C_VERSION}.0"

  VIAddVersionKey "ProductName"             "PFI Diagnostic Utility"
  VIAddVersionKey "Comments"                "POPFile Homepage: http://getpopfile.org/"
  VIAddVersionKey "CompanyName"             "The POPFile Project"
  VIAddVersionKey "LegalCopyright"          "Copyright (c) 2005  John Graham-Cumming"
  VIAddVersionKey "FileDescription"         "PFI Diagnostic Utility"
  VIAddVersionKey "FileVersion"             "${C_VERSION}"
  VIAddVersionKey "OriginalFilename"        "${C_OUTFILE}"

  VIAddVersionKey "Build Date/Time"         "${__DATE__} @ ${__TIME__}"
  !ifdef C_PFI_LIBRARY_VERSION
    VIAddVersionKey "Build Library Version" "${C_PFI_LIBRARY_VERSION}"
  !endif
  VIAddVersionKey "Build Script"            "${__FILE__}$\r$\n(${__TIMESTAMP__})"

#--------------------------------------------------------------------------
# User Variables (Global)
#--------------------------------------------------------------------------

  ; This script uses 'User Variables' (with names starting with 'G_') to hold GLOBAL data.

  Var G_DIAG_MODE         ; holds the current mode ('simple', 'full', 'shortcut' or 'help')

  Var G_WINUSERNAME       ; current Windows user login name

  Var G_WIN_OS_TYPE       ; 0 = Win9x, 1 = more modern version of Windows

  Var G_EXPECTED_ROOT     ; expected value for POPFILE_ROOT (the POPFile program location)
  Var G_EXPECTED_USER     ; expected value for POPFILE_USER (the 'User Data' location)

  Var G_POPFILE_USER      ; from POPFILE_USER environment variable, used to check backups etc

#--------------------------------------------------------------------------
# Macros used to simplify many of the tests
#--------------------------------------------------------------------------

  ;---------------------------------------------------------------
  ; Differentiate between non-existent and empty registry strings
  ;---------------------------------------------------------------

  !macro CHECK_REG_ENTRY VALUE ROOT_KEY SUB_KEY NAME MESSAGE

      !insertmacro PFI_UNIQUE_ID

      ClearErrors
      ReadRegStr "${VALUE}" ${ROOT_KEY} "${SUB_KEY}" "${NAME}"
      StrCmp "${VALUE}" "" 0 show_value_${PFI_UNIQUE_ID}
      IfErrors 0 show_value_${PFI_UNIQUE_ID}
      DetailPrint "${MESSAGE}= ><"
      Goto continue_${PFI_UNIQUE_ID}

    show_value_${PFI_UNIQUE_ID}:
      DetailPrint "${MESSAGE}= < ${VALUE} >"

    continue_${PFI_UNIQUE_ID}:
  !macroend

  ;---------------------------------------------------------------------
  ; Check registry strings used for the "0.21 Test Installer"
  ;---------------------------------------------------------------------

  !macro CHECK_TESTMRI_ENTRY VALUE ROOT_KEY NAME MESSAGE
    !insertmacro CHECK_REG_ENTRY "${VALUE}" \
                "${ROOT_KEY}" "Software\POPFile Project\POPFileTest\MRI" "${NAME}" "${MESSAGE}"
  !macroend

  ;---------------------------------------------------------------------
  ; Check registry strings used for the current "PFI Testbed" which tests installer translations
  ;---------------------------------------------------------------------

  !macro CHECK_TESTBED_ENTRY VALUE ROOT_KEY NAME MESSAGE
    !insertmacro CHECK_REG_ENTRY "${VALUE}" \
                "${ROOT_KEY}" "Software\POPFile Project\PFI Testbed\MRI" "${NAME}" "${MESSAGE}"
  !macroend

  ;---------------------------------------------------------------------
  ; Check registry strings used for the "real" POPFile installer (0.21.0 or later)
  ;---------------------------------------------------------------------

  !macro CHECK_MRI_ENTRY VALUE ROOT_KEY NAME MESSAGE
    !insertmacro CHECK_REG_ENTRY "${VALUE}" \
                "${ROOT_KEY}" "Software\POPFile Project\POPFile\MRI" "${NAME}" "${MESSAGE}"
  !macroend

  ;---------------------------------------------------------------------------
  ; Differentiate between non-existent and empty POPFile environment variables
  ; (on Win9x systems it is quite normal for these variables to be undefined, as
  ; the 'runpopfile.exe' program creates them 'on the fly' when it runs POPFile)
  ;---------------------------------------------------------------------------

  !macro CHECK_ENVIRONMENT REGISTER ENV_VARIABLE MESSAGE

      !insertmacro PFI_UNIQUE_ID

      ClearErrors
      ReadEnvStr "${REGISTER}" "${ENV_VARIABLE}"
      StrCmp "${REGISTER}" "" 0 show_value_${PFI_UNIQUE_ID}
      IfErrors 0 show_value_${PFI_UNIQUE_ID}
      StrCmp $G_WIN_OS_TYPE "1" notWin9x_${PFI_UNIQUE_ID}
      DetailPrint "${MESSAGE}= ><   (this is OK)"
      Goto continue_${PFI_UNIQUE_ID}

    notWin9x_${PFI_UNIQUE_ID}:
      DetailPrint "${MESSAGE}= ><"
      Goto continue_${PFI_UNIQUE_ID}

    show_value_${PFI_UNIQUE_ID}:
      DetailPrint "${MESSAGE}= < ${REGISTER} >"

    continue_${PFI_UNIQUE_ID}:
  !macroend

  ;---------------------------------------------------------------------------
  ; Differentiate between non-existent and empty Kakasi environment variables
  ; (these variables are only defined if the Kakasi software has been installed)
  ;---------------------------------------------------------------------------

  !macro CHECK_KAKASI REGISTER ENV_VARIABLE MESSAGE

      !insertmacro PFI_UNIQUE_ID

      ClearErrors
      ReadEnvStr "${REGISTER}" "${ENV_VARIABLE}"
      StrCmp "${REGISTER}" "" 0 show_value_${PFI_UNIQUE_ID}
      IfErrors 0 show_value_${PFI_UNIQUE_ID}
      IfFileExists "$G_EXPECTED_ROOT\kakasi\*.*" Kakasi_${PFI_UNIQUE_ID}
      DetailPrint "${MESSAGE}= ><   (this is OK)"
      Goto continue_${PFI_UNIQUE_ID}

    Kakasi_${PFI_UNIQUE_ID}:
      DetailPrint "${MESSAGE}= ><"
      Goto continue_${PFI_UNIQUE_ID}

    show_value_${PFI_UNIQUE_ID}:
      DetailPrint "${MESSAGE}= < ${REGISTER} >"

    continue_${PFI_UNIQUE_ID}:
  !macroend

#--------------------------------------------------------------------------
# Configure the MUI pages
#--------------------------------------------------------------------------

  ;----------------------------------------------------------------
  ; Interface Settings - General Interface Settings
  ;----------------------------------------------------------------

  ; The icon file for the utility

  !define MUI_ICON                            "pfinfo.ico"

  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP              "..\hdr-common.bmp"
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
  ;  Interface Settings - Installer Finish Page Interface Settings
  ;----------------------------------------------------------------

  ; Show the installation log and leave the window open when utility has completed its work

  ShowInstDetails show
  !define MUI_FINISHPAGE_NOAUTOCLOSE

#--------------------------------------------------------------------------
# Define the Page order for the utility
#--------------------------------------------------------------------------

  ;---------------------------------------------------
  ; Installer Page - Generate Diagnostic Report
  ;---------------------------------------------------

  ; Override the standard "Installing..." page header

  !define MUI_PAGE_HEADER_TEXT                      "$(PFI_LANG_DIAG_STD_HDR)"
  !define MUI_PAGE_HEADER_SUBTEXT                   "$(PFI_LANG_DIAG_STD_SUBHDR)"

  ; Override the standard "Installation complete..." page header

  !define MUI_INSTFILESPAGE_FINISHHEADER_TEXT       "$(PFI_LANG_DIAG_END_HDR)"
  !define MUI_INSTFILESPAGE_FINISHHEADER_SUBTEXT    "$(PFI_LANG_DIAG_END_SUBHDR)"

  !insertmacro MUI_PAGE_INSTFILES

#--------------------------------------------------------------------------
# Language Support for the utility
#--------------------------------------------------------------------------

  !insertmacro MUI_LANGUAGE "English"

  ;--------------------------------------------------------------------------
  ; Current build only supports English and uses local strings
  ; instead of language strings from languages\*-pfi.nsh files
  ;--------------------------------------------------------------------------

  !macro PFI_DIAG_TEXT NAME VALUE
    LangString ${NAME} ${LANG_ENGLISH} "${VALUE}"
  !macroend

  !insertmacro PFI_DIAG_TEXT "PFI_LANG_DIAG_STD_HDR"    \
         "Generating the PFI Diagnostic report..."
  !insertmacro PFI_DIAG_TEXT "PFI_LANG_DIAG_STD_SUBHDR" \
        "Searching for POPFile registry entries and the POPFile environment variables"

  !insertmacro PFI_DIAG_TEXT "PFI_LANG_DIAG_END_HDR"    \
        "POPFile Installer Diagnostic Utility"
  !insertmacro PFI_DIAG_TEXT "PFI_LANG_DIAG_END_SUBHDR" \
        "For a simple report use 'PFIDIAG'       For other options, use 'PFIDIAG /HELP'"

  !insertmacro PFI_DIAG_TEXT "PFI_LANG_DIAG_RIGHTCLICK" \
        "Right-click in the window below to copy the report to the clipboard"


#--------------------------------------------------------------------------
# General settings
#--------------------------------------------------------------------------

  ; Specify EXE filename and icon for the utility

  OutFile "${C_OUTFILE}"

  ; Ensure details are shown, so user can see the diagnostic report

  ShowInstDetails show


;--------------------------------------------------------------------------
; Section: Initialise (always executed)
;
; Get diagnostic mode from command-line and for convenience strip the leading '/' from it.
; The OS type (0 = Win9x, 1 = non-Win9x) is checked more than once in this utility so we
; detect it here and store the result in a global variable for later use.
;--------------------------------------------------------------------------

Section "Initialise"

  !define L_TEMP    $R9

  Push ${L_TEMP}

  Call PFI_GetParameters
  Pop $G_DIAG_MODE

  StrCmp $G_DIAG_MODE "" set_default
  StrCpy ${L_TEMP} $G_DIAG_MODE 1
  StrCmp ${L_TEMP} "/" 0 set_help

  StrCpy $G_DIAG_MODE $G_DIAG_MODE "" 1
  StrCmp $G_DIAG_MODE "full" get_os_type
  StrCmp $G_DIAG_MODE "help" get_os_type
  StrCmp $G_DIAG_MODE "shortcut" get_os_type
  StrCmp $G_DIAG_MODE "simple" get_os_type

set_help:
  StrCpy $G_DIAG_MODE "help"
  Goto get_os_type

set_default:
  StrCpy $G_DIAG_MODE "simple"

get_os_type:
  Call IsNT
  Pop $G_WIN_OS_TYPE

  Pop ${L_TEMP}

  !undef L_TEMP

SectionEnd


;--------------------------------------------------------------------------
; Section: Start Report
;--------------------------------------------------------------------------

Section "Start Report"

  StrCmp $G_DIAG_MODE "simple" enter_section
  StrCmp $G_DIAG_MODE "full" enter_section next_section

enter_section:
  SetDetailsPrint listonly

  DetailPrint "------------------------------------------------------------"
  DetailPrint "POPFile $(^Name) v${C_VERSION} ($G_DIAG_MODE mode)"
  DetailPrint "------------------------------------------------------------"
  DetailPrint "String data report format (not used for numeric data)"
  DetailPrint ""
  DetailPrint "string not found              :  ><"
  DetailPrint "empty string found            :  <  >"
  DetailPrint "string with 'xyz' value found :  < xyz >"
  DetailPrint "------------------------------------------------------------"
  DetailPrint ""

next_section:
SectionEnd


;--------------------------------------------------------------------------
; Section: User Name And Type
;--------------------------------------------------------------------------

Section "User Name And Type"

  StrCmp $G_DIAG_MODE "simple" enter_section
  StrCmp $G_DIAG_MODE "full" enter_section
  StrCmp $G_DIAG_MODE "shortcut" enter_section next_section

enter_section:

  !define L_WINUSERTYPE    $R9     ; user's rights

  Push ${L_WINUSERTYPE}

  ; The 'UserInfo' plugin may return an error if run on a Win9x system but since Win9x systems
  ; do not support different account types, we treat this error as if user has 'Admin' rights.

  ClearErrors
  UserInfo::GetName
  IfErrors 0 got_name

  ; Assume Win9x system, so user has 'Admin' rights

  StrCpy $G_WINUSERNAME "UnknownUser"
  StrCpy ${L_WINUSERTYPE} "Admin"
  Goto section_end

got_name:
  Pop $G_WINUSERNAME
  StrCmp $G_WINUSERNAME "" 0 get_usertype
  StrCpy $G_WINUSERNAME "UnknownUser"

get_usertype:
  UserInfo::GetAccountType
  Pop ${L_WINUSERTYPE}
  StrCmp ${L_WINUSERTYPE} "Admin" section_end
  StrCmp ${L_WINUSERTYPE} "Power" section_end
  StrCmp ${L_WINUSERTYPE} "User" section_end
  StrCmp ${L_WINUSERTYPE} "Guest" section_end
  StrCpy ${L_WINUSERTYPE} "Unknown"

section_end:
  DetailPrint "Current UserName  = $G_WINUSERNAME (${L_WINUSERTYPE})"
  DetailPrint ""

  Pop ${L_WINUSERTYPE}

  !undef L_WINUSERTYPE

next_section:
SectionEnd


;--------------------------------------------------------------------------
; Section: OS Type And IE Version
;--------------------------------------------------------------------------

Section "OS Type and IE Version"

  StrCmp $G_DIAG_MODE "full" enter_section next_section

enter_section:

  !define L_TEMP    $R9

  Push ${L_TEMP}

  DetailPrint "IsNT return code  = $G_WIN_OS_TYPE"

  Call PFI_GetIEVersion
  Pop ${L_TEMP}
  DetailPrint "Internet Explorer = ${L_TEMP}"
  DetailPrint ""

  Pop ${L_TEMP}

  !undef L_TEMP

next_section:
SectionEnd


;--------------------------------------------------------------------------
; Section: Start Menu Locations and Shortcuts
;--------------------------------------------------------------------------

Section "Start Menu and Shortcuts"

  StrCmp $G_DIAG_MODE "full" enter_section next_section

enter_section:

  !define L_ALL_USERS       $R9   ; number of 'all users' StartUp POPFile shortcuts detected
  !define L_CURRENT_USER    $R8   ; number of 'current user' StartUp POPFile shortcuts detected
  !define L_TEMP            $R7

  Push ${L_ALL_USERS}
  Push ${L_CURRENT_USER}
  Push ${L_TEMP}

  DetailPrint "------------------------------------------------------------"
  DetailPrint "Start Menu Locations"
  DetailPrint "------------------------------------------------------------"
  DetailPrint ""

  SetShellVarContext all
  DetailPrint "AU: $$SMPROGRAMS   = < $SMPROGRAMS >"
  DetailPrint "AU: $$SMSTARTUP    = < $SMSTARTUP >"
  StrCpy ${L_TEMP} $SMSTARTUP
  DetailPrint ""
  DetailPrint "Search results for the $\"AU: $$SMSTARTUP$\" folder:"
  Push "$SMSTARTUP"
  Call AnalyseShortcuts
  Pop ${L_ALL_USERS}
  DetailPrint ""

  SetShellVarContext current
  DetailPrint "CU: $$SMPROGRAMS   = < $SMPROGRAMS >"
  DetailPrint "CU: $$SMSTARTUP    = < $SMSTARTUP >"

  ; If 'all users' & 'current user' use same StartUp folder there is no need to check it again

  StrCmp ${L_TEMP} "$SMSTARTUP" 0 check_CU_shortcuts
  DetailPrint ""
  DetailPrint "($\"CU: $$SMSTARTUP$\" folder is same as $\"AU: $$SMSTARTUP$\" folder)"
  Goto section_end

check_CU_shortcuts:
  DetailPrint ""
  DetailPrint "Search results for the $\"CU: $$SMSTARTUP$\" folder:"
  Push "$SMSTARTUP"
  Call AnalyseShortcuts
  Pop ${L_CURRENT_USER}

  IntOp ${L_TEMP}  ${L_ALL_USERS} +  ${L_CURRENT_USER}
  IntCmp ${L_TEMP} 1 section_end section_end
  DetailPrint ""
  DetailPrint "'POPFile' total   = ${L_TEMP}"
  DetailPrint "^^^^ Warning ^^^^   The $\"'POPFile' total$\" is greater than one"

section_end:
  Pop ${L_TEMP}
  Pop ${L_CURRENT_USER}
  Pop ${L_ALL_USERS}

  !undef L_ALL_USERS
  !undef L_CURRENT_USER
  !undef L_TEMP

next_section:
SectionEnd


;--------------------------------------------------------------------------
; Section: Obsolete/Testbed Registry Entries
;--------------------------------------------------------------------------

Section "Obsolete/Testbed Registry Data"

  StrCmp $G_DIAG_MODE "full" enter_section next_section

enter_section:

  !define L_REGDATA    $R9   ; data read from registry

  Push ${L_REGDATA}

  DetailPrint ""
  DetailPrint "------------------------------------------------------------"
  DetailPrint "Obsolete/testbed Registry Entries"
  DetailPrint "------------------------------------------------------------"
  DetailPrint ""

  DetailPrint "[1] Pre-0.21 Data:"
  DetailPrint ""

  !insertmacro CHECK_REG_ENTRY "${L_REGDATA}" \
      "HKLM" "Software\POPFile" "InstallLocation" "Pre-0.21 POPFile  "
  !insertmacro CHECK_REG_ENTRY "${L_REGDATA}" \
      "HKLM" "Software\POPFile Testbed" "InstallLocation" "Pre-0.21 Testbed  "
  DetailPrint ""

  DetailPrint "[2] 0.21 Test Installer Data:"
  DetailPrint ""

  !insertmacro CHECK_TESTMRI_ENTRY "${L_REGDATA}" "HKLM" "RootDir_LFN" "HKLM: RootDir_LFN "
  !insertmacro CHECK_TESTMRI_ENTRY "${L_REGDATA}" "HKLM" "RootDir_SFN" "HKLM: RootDir_SFN "
  DetailPrint ""

  !insertmacro CHECK_TESTMRI_ENTRY "${L_REGDATA}" "HKCU" "RootDir_LFN" "HKCU: RootDir_LFN "
  !insertmacro CHECK_TESTMRI_ENTRY "${L_REGDATA}" "HKCU" "RootDir_SFN" "HKCU: RootDir_SFN "
  !insertmacro CHECK_TESTMRI_ENTRY "${L_REGDATA}" "HKCU" "UserDir_LFN" "HKCU: UserDir_LFN "
  !insertmacro CHECK_TESTMRI_ENTRY "${L_REGDATA}" "HKCU" "UserDir_SFN" "HKCU: UserDir_SFN "
  DetailPrint ""

  DetailPrint "[3] Current PFI Testbed Data:"
  DetailPrint ""

  !insertmacro CHECK_TESTBED_ENTRY "${L_REGDATA}" "HKCU" "InstallPath"  "MRI PFI Testbed   "
  !insertmacro CHECK_TESTBED_ENTRY "${L_REGDATA}" "HKCU" "UserDataPath" "MRI PFI Testdata  "
  DetailPrint ""

  Pop ${L_REGDATA}

  !undef L_REGDATA

next_section:
SectionEnd


;--------------------------------------------------------------------------
; Section: POPFile Registry Data
;--------------------------------------------------------------------------

Section "POPFile Registry Data"

  StrCmp $G_DIAG_MODE "full" enter_section next_section

enter_section:

  !define L_REGDATA         $R9   ; data read from registry
  !define L_STATUS_ROOT     $R8   ; used when reporting whether or not 'popfile.pl' exists
  !define L_STATUS_USER     $R7   ; used when reporting whether or not 'popfile.cfg' exists
  !define L_TEMP            $R6

  Push ${L_REGDATA}
  Push ${L_STATUS_ROOT}
  Push ${L_STATUS_USER}
  Push ${L_TEMP}

  DetailPrint "------------------------------------------------------------"
  DetailPrint "POPFile Registry Data"
  DetailPrint "------------------------------------------------------------"
  DetailPrint ""

  ; Check NTFS Short File Name support

  ReadRegDWORD ${L_REGDATA} \
      HKLM "System\CurrentControlSet\Control\FileSystem" "NtfsDisable8dot3NameCreation"
  DetailPrint "NTFS SFN Disabled = < ${L_REGDATA} >"
  DetailPrint ""

  ; Check HKLM data

  ReadRegStr ${L_TEMP} HKLM "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "POPFile Major Version"
  StrCpy ${L_REGDATA} ${L_TEMP}
  ReadRegStr ${L_TEMP} HKLM "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "POPFile Minor Version"
  StrCpy ${L_REGDATA} ${L_REGDATA}.${L_TEMP}
  ReadRegStr ${L_TEMP} HKLM "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "POPFile Revision"
  StrCpy ${L_REGDATA} ${L_REGDATA}.${L_TEMP}
  ReadRegStr ${L_TEMP} HKLM "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "POPFile RevStatus"
  StrCpy ${L_REGDATA} ${L_REGDATA}${L_TEMP}
  DetailPrint "HKLM: MRI Version = < ${L_REGDATA} >"

  !insertmacro CHECK_MRI_ENTRY "${L_REGDATA}" "HKLM" "InstallPath" "HKLM: InstallPath "
  !insertmacro CHECK_MRI_ENTRY "${L_REGDATA}" "HKLM" "RootDir_LFN" "HKLM: RootDir_LFN "
  Push ${L_REGDATA}
  Call CheckForTrailingSlash
  StrCpy $G_EXPECTED_ROOT ${L_REGDATA}
  ClearErrors
  ReadRegStr ${L_REGDATA} HKLM "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "RootDir_SFN"
  IfErrors 0 check_HKLM_root_data
  DetailPrint "HKLM: RootDir_SFN = ><"
  Goto end_HKLM_root

check_HKLM_root_data:
  StrCmp ${L_REGDATA} "Not supported" 0 short_HKLM_root
  Push $G_EXPECTED_ROOT
  Call CheckForSpaces
  DetailPrint "HKLM: RootDir_SFN = < ${L_REGDATA} >"
  Goto end_HKLM_root

short_HKLM_root:
  DetailPrint "HKLM: RootDir_SFN = < ${L_REGDATA} >"
  Push ${L_REGDATA}
  Call CheckForTrailingSlash
  GetFullPathName /SHORT $G_EXPECTED_ROOT $G_EXPECTED_ROOT
  StrCpy ${L_TEMP} $G_EXPECTED_ROOT 1 -1
  StrCmp ${L_TEMP} "\" end_HKLM_root
  StrCmp $G_EXPECTED_ROOT ${L_REGDATA} end_HKLM_root
  DetailPrint "^^^^^ Error ^^^^^"
  DetailPrint "Expected Root SFN = < $G_EXPECTED_ROOT >"

end_HKLM_root:
  DetailPrint ""

  ; Check HKCU data

  !insertmacro CHECK_MRI_ENTRY "${L_REGDATA}" "HKCU" "Owner" "HKCU: Data Owner  "
  ReadRegStr ${L_TEMP} HKCU "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "POPFile Major Version"
  StrCpy ${L_REGDATA} ${L_TEMP}
  ReadRegStr ${L_TEMP} HKCU "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "POPFile Minor Version"
  StrCpy ${L_REGDATA} ${L_REGDATA}.${L_TEMP}
  ReadRegStr ${L_TEMP} HKCU "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "POPFile Revision"
  StrCpy ${L_REGDATA} ${L_REGDATA}.${L_TEMP}
  ReadRegStr ${L_TEMP} HKCU "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "POPFile RevStatus"
  StrCpy ${L_REGDATA} ${L_REGDATA}${L_TEMP}
  DetailPrint "HKCU: MRI Version = < ${L_REGDATA} >"

  !insertmacro CHECK_MRI_ENTRY "${L_REGDATA}" "HKCU" "RootDir_LFN" "HKCU: RootDir_LFN "
  Push ${L_REGDATA}
  Call CheckForTrailingSlash
  StrCpy $G_EXPECTED_ROOT ${L_REGDATA}
  StrCpy ${L_STATUS_ROOT} ""
  IfFileExists "${L_REGDATA}\popfile.pl" root_sfn
  StrCpy ${L_STATUS_ROOT} "not "

root_sfn:
  ClearErrors
  ReadRegStr ${L_REGDATA} HKCU "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "RootDir_SFN"
  IfErrors 0 check_HKCU_root_data
  DetailPrint "HKCU: RootDir_SFN = ><"
  Goto end_HKCU_root

check_HKCU_root_data:
  StrCmp ${L_REGDATA} "Not supported"  0 short_HKCU_root
  Push $G_EXPECTED_ROOT
  Call CheckForSpaces
  DetailPrint "HKCU: RootDir_SFN = < ${L_REGDATA} >"
  Goto end_HKCU_root

short_HKCU_root:
  DetailPrint "HKCU: RootDir_SFN = < ${L_REGDATA} >"
  Push ${L_REGDATA}
  Call CheckForTrailingSlash
  GetFullPathName /SHORT $G_EXPECTED_ROOT $G_EXPECTED_ROOT
  StrCpy ${L_TEMP} $G_EXPECTED_ROOT 1 -1
  StrCmp ${L_TEMP} "\" end_HKCU_root
  StrCmp $G_EXPECTED_ROOT ${L_REGDATA} end_HKCU_root
  DetailPrint "^^^^^ Error ^^^^^"
  DetailPrint "Expected Root SFN = < $G_EXPECTED_ROOT >"

end_HKCU_root:
  DetailPrint ""

  !insertmacro CHECK_MRI_ENTRY "${L_REGDATA}" "HKCU" "UserDir_LFN" "HKCU: UserDir_LFN "
  Push ${L_REGDATA}
  Call CheckForTrailingSlash
  StrCpy $G_POPFILE_USER ${L_REGDATA}
  StrCpy $G_EXPECTED_USER ${L_REGDATA}
  StrCpy ${L_STATUS_USER} ""
  IfFileExists "${L_REGDATA}\popfile.cfg" user_sfn
  StrCpy ${L_STATUS_USER} "not "

user_sfn:
  ClearErrors
  ReadRegStr ${L_REGDATA} HKCU "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "UserDir_SFN"
  IfErrors 0 check_HKCU_user_data
  DetailPrint "HKCU: UserDir_SFN = ><"
  Goto end_HKCU_user

check_HKCU_user_data:
  StrCmp ${L_REGDATA} "Not supported" 0 short_HKCU_user
  Push $G_EXPECTED_USER
  Call CheckForSpaces
  DetailPrint "HKCU: UserDir_SFN = < ${L_REGDATA} >"
  Goto end_HKCU_user

short_HKCU_user:
  DetailPrint "HKCU: UserDir_SFN = < ${L_REGDATA} >"
  Push ${L_REGDATA}
  Call CheckForTrailingSlash
  GetFullPathName /SHORT $G_EXPECTED_USER $G_EXPECTED_USER
  StrCpy ${L_TEMP} $G_EXPECTED_USER 1 -1
  StrCmp ${L_TEMP} "\" end_HKCU_user
  StrCmp $G_EXPECTED_USER ${L_REGDATA} end_HKCU_user
  DetailPrint "^^^^^ Error ^^^^^"
  DetailPrint "Expected User SFN = < $G_EXPECTED_USER >"

end_HKCU_user:
  DetailPrint ""
  DetailPrint "HKCU: popfile.pl  = ${L_STATUS_ROOT}found"
  DetailPrint "HKCU: popfile.cfg = ${L_STATUS_USER}found"
  DetailPrint ""

  Pop ${L_TEMP}
  Pop ${L_STATUS_USER}
  Pop ${L_STATUS_ROOT}
  Pop ${L_REGDATA}

  !undef L_REGDATA
  !undef L_STATUS_ROOT
  !undef L_STATUS_USER
  !undef L_TEMP

next_section:
SectionEnd


;--------------------------------------------------------------------------
; Section: POPFile Corpus/Database Backup Data
;--------------------------------------------------------------------------

Section "Corpus/Database Backup Data"

  StrCmp $G_DIAG_MODE "full" enter_section next_section

enter_section:

  !define L_STATUS_USER     $R9   ; used when reporting whether or not 'popfile.cfg' exists
  !define L_TEMP            $R8

  Push ${L_STATUS_USER}
  Push ${L_TEMP}

  IfFileExists  "$G_POPFILE_USER\backup\*.*" 0 section_end

  DetailPrint "------------------------------------------------------------"
  DetailPrint "POPFile Corpus/Database Backup Data"
  DetailPrint "------------------------------------------------------------"
  DetailPrint ""

  DetailPrint "HKCU: backup locn = < $G_POPFILE_USER\backup >"
  DetailPrint ""

  StrCpy ${L_STATUS_USER} ""
  IfFileExists "$G_POPFILE_USER\backup\backup.ini" ini_status
  StrCpy ${L_STATUS_USER} "not "

ini_status:
  DetailPrint "backup.ini file   = ${L_STATUS_USER}found"

  ReadINIStr ${L_TEMP} "$G_POPFILE_USER\backup\backup.ini" "FlatFileCorpus" "Corpus"
  StrCmp ${L_TEMP} "" no_flat_folder
  StrCpy ${L_STATUS_USER} ""
  IfFileExists "$G_POPFILE_USER\backup\${L_TEMP}\*.*" flat_status

no_flat_folder:
  StrCpy ${L_STATUS_USER} "not "

flat_status:
  DetailPrint "Flat-file  folder = ${L_STATUS_USER}found"

  ReadINIStr ${L_TEMP} "$G_POPFILE_USER\backup\backup.ini" "NonSQLCorpus" "Corpus"
  StrCmp ${L_TEMP} "" no_nonsql_folder
  StrCpy ${L_STATUS_USER} ""
  IfFileExists "$G_POPFILE_USER\backup\nonsql\${L_TEMP}\*.*" nonsql_status

no_nonsql_folder:
  StrCpy ${L_STATUS_USER} "not "

nonsql_status:
  DetailPrint "Flat / BDB folder = ${L_STATUS_USER}found"

  ReadINIStr ${L_TEMP} "$G_POPFILE_USER\backup\backup.ini" "OldSQLdatabase" "Database"
  StrCmp ${L_TEMP} "" no_sql_backup
  StrCpy ${L_STATUS_USER} ""
  IfFileExists "$G_POPFILE_USER\backup\oldsql\${L_TEMP}" sql_backup_status

no_sql_backup:
  StrCpy ${L_STATUS_USER} "not "

sql_backup_status:
  DetailPrint "SQLite DB  backup = ${L_STATUS_USER}found"
  DetailPrint ""

section_end:
  Pop ${L_TEMP}
  Pop ${L_STATUS_USER}

  !undef L_STATUS_USER
  !undef L_TEMP

next_section:
SectionEnd


;--------------------------------------------------------------------------
; Section: User-Friendly Program and User Data locations
;--------------------------------------------------------------------------

Section "User-Friendly Program/User Data Locations"

  StrCmp $G_DIAG_MODE "simple" enter_section next_section

enter_section:

  !define L_REGDATA         $R9   ; data read from registry
  !define L_STATUS_ROOT     $R8   ; used when reporting whether or not 'popfile.pl' exists
  !define L_STATUS_USER     $R7   ; used when reporting whether or not 'popfile.cfg' exists
  !define L_TEMP            $R6

  Push ${L_REGDATA}
  Push ${L_STATUS_ROOT}
  Push ${L_STATUS_USER}
  Push ${L_TEMP}

  !insertmacro CHECK_MRI_ENTRY "${L_REGDATA}" "HKCU" "RootDir_LFN" "Program folder    "
  Push ${L_REGDATA}
  Call CheckForTrailingSlash
  StrCpy $G_EXPECTED_ROOT ${L_REGDATA}
  StrCpy ${L_STATUS_ROOT} ""
  IfFileExists "${L_REGDATA}\popfile.pl" simple_root_sfn
  StrCpy ${L_STATUS_ROOT} "not "

simple_root_sfn:
  ClearErrors
  ReadRegStr ${L_REGDATA} HKCU "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "RootDir_SFN"
  IfErrors 0 check_simple_root_data
  DetailPrint "SFN equivalent    = ><"
  Goto end_simple_root

check_simple_root_data:
  StrCmp ${L_REGDATA} "Not supported" 0 short_simple_root
  Push $G_EXPECTED_ROOT
  Call CheckForSpaces
  DetailPrint "SFN equivalent    = < ${L_REGDATA} >"
  Goto end_simple_root

short_simple_root:
  DetailPrint "SFN equivalent    = < ${L_REGDATA} >"
  Push ${L_REGDATA}
  Call CheckForTrailingSlash
  GetFullPathName /SHORT $G_EXPECTED_ROOT $G_EXPECTED_ROOT
  StrCpy ${L_TEMP} $G_EXPECTED_ROOT 1 -1
  StrCmp ${L_TEMP} "\" end_simple_root
  StrCmp $G_EXPECTED_ROOT ${L_REGDATA} end_simple_root
  DetailPrint "^^^^^ Error ^^^^^"
  DetailPrint "Expected value    = < $G_EXPECTED_ROOT >"

end_simple_root:
  DetailPrint ""

  !insertmacro CHECK_MRI_ENTRY "${L_REGDATA}" "HKCU" "UserDir_LFN" "User Data folder  "
  Push ${L_REGDATA}
  Call CheckForTrailingSlash
  StrCpy $G_EXPECTED_USER ${L_REGDATA}
  StrCpy ${L_STATUS_USER} ""
  IfFileExists "${L_REGDATA}\popfile.cfg" simple_user_sfn
  StrCpy ${L_STATUS_USER} "not "

simple_user_sfn:
  ClearErrors
  ReadRegStr ${L_REGDATA} HKCU "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "UserDir_SFN"
  IfErrors 0 check_simple_user_data
  DetailPrint "SFN equivalent    = ><"
  Goto end_simple_user

check_simple_user_data:
  StrCmp ${L_REGDATA} "Not supported" 0 short_simple_user
  Push $G_EXPECTED_USER
  Call CheckForSpaces
  DetailPrint "SFN equivalent    = < ${L_REGDATA} >"
  Goto end_simple_user

short_simple_user:
  DetailPrint "SFN equivalent    = < ${L_REGDATA} >"
  Push ${L_REGDATA}
  Call CheckForTrailingSlash
  GetFullPathName /SHORT $G_EXPECTED_USER $G_EXPECTED_USER
  StrCpy ${L_TEMP} $G_EXPECTED_USER 1 -1
  StrCmp ${L_TEMP} "\" end_simple_user
  StrCmp $G_EXPECTED_USER ${L_REGDATA} end_simple_user
  DetailPrint "^^^^^ Error ^^^^^"
  DetailPrint "Expected value    = < $G_EXPECTED_USER >"

end_simple_user:
  DetailPrint ""
  DetailPrint "popfile.pl  file  = ${L_STATUS_ROOT}found"
  DetailPrint "popfile.cfg file  = ${L_STATUS_USER}found"
  DetailPrint ""

  Pop ${L_TEMP}
  Pop ${L_STATUS_USER}
  Pop ${L_STATUS_ROOT}
  Pop ${L_REGDATA}

  !undef L_REGDATA
  !undef L_STATUS_ROOT
  !undef L_STATUS_USER
  !undef L_TEMP

next_section:
SectionEnd


;--------------------------------------------------------------------------
; Section: EnvironmentVariables
;--------------------------------------------------------------------------

Section "Environment Variables"

  StrCmp $G_DIAG_MODE "simple" enter_section
  StrCmp $G_DIAG_MODE "full" enter_section next_section

enter_section:

  !define L_ITAIJIDICTPATH  $R9   ; current Kakasi environment variable
  !define L_KANWADICTPATH   $R8   ; current Kakasi environment variable
  !define L_POPFILE_ROOT    $R7   ; current value of POPFILE_ROOT environment variable
  !define L_TEMP            $R6

  Push ${L_ITAIJIDICTPATH}
  Push ${L_KANWADICTPATH}
  Push ${L_POPFILE_ROOT}
  Push ${L_TEMP}

  DetailPrint "------------------------------------------------------------"
  DetailPrint "POPFile Environment Variables"
  DetailPrint "------------------------------------------------------------"
  DetailPrint ""

  !insertmacro CHECK_ENVIRONMENT "${L_POPFILE_ROOT}" "POPFILE_ROOT" "'POPFILE_ROOT'    "
  StrCmp $G_WIN_OS_TYPE "1" compare_root_var
  StrCmp ${L_POPFILE_ROOT} "" check_user

compare_root_var:
  Push ${L_POPFILE_ROOT}
  Call CheckForTrailingSlash
  Push ${L_POPFILE_ROOT}
  Call CheckForSpaces
  StrCmp $G_EXPECTED_ROOT ${L_POPFILE_ROOT} check_user
  Push $G_EXPECTED_ROOT
  Push " "
  Call PFI_StrStr
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" 0 check_user
  DetailPrint "^^^^^ Error ^^^^^"
  DetailPrint "Expected value    = < $G_EXPECTED_ROOT >"
  DetailPrint ""

check_user:
  !insertmacro CHECK_ENVIRONMENT "$G_POPFILE_USER" "POPFILE_USER" "'POPFILE_USER'    "
  StrCmp $G_WIN_OS_TYPE "1" compare_user_var
  StrCmp $G_POPFILE_USER "" check_vars

compare_user_var:
  Push $G_POPFILE_USER
  Call CheckForTrailingSlash
  Push $G_POPFILE_USER
  Call CheckForSpaces
  StrCmp $G_EXPECTED_USER $G_POPFILE_USER check_vars
  Push $G_EXPECTED_USER
  Push " "
  Call PFI_StrStr
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" 0 check_vars
  DetailPrint "^^^^^ Error ^^^^^"
  DetailPrint "Expected value    = < $G_EXPECTED_USER >"

check_vars:
  DetailPrint ""

  StrCmp ${L_POPFILE_ROOT} "" check_user_var

  StrCpy ${L_TEMP} ""
  IfFileExists "${L_POPFILE_ROOT}\popfile.pl" root_var_status
  StrCpy ${L_TEMP} "not "

root_var_status:
  StrCmp $G_DIAG_MODE "simple" simple_root_status

  DetailPrint "Env: popfile.pl   = ${L_TEMP}found"
  Goto check_user_var

simple_root_status:
  DetailPrint "popfile.pl  file  = ${L_TEMP}found"

check_user_var:
  StrCmp $G_POPFILE_USER "" 0 user_result
  StrCmp ${L_POPFILE_ROOT} "" check_kakasi blank_line

user_result:
  StrCpy ${L_TEMP} ""
  IfFileExists "$G_POPFILE_USER\popfile.cfg" user_var_status
  StrCpy ${L_TEMP} "not "

user_var_status:
  StrCmp $G_DIAG_MODE "simple" simple_user_status

  DetailPrint "Env: popfile.cfg  = ${L_TEMP}found"
  Goto blank_line

simple_user_status:
  DetailPrint "popfile.cfg file  = ${L_TEMP}found"

blank_line:
  DetailPrint ""

check_kakasi:
  !insertmacro CHECK_KAKASI "${L_ITAIJIDICTPATH}" "ITAIJIDICTPATH" "'ITAIJIDICTPATH'  "
  !insertmacro CHECK_KAKASI "${L_KANWADICTPATH}"  "KANWADICTPATH"  "'KANWADICTPATH'   "
  DetailPrint ""

  StrCmp $G_DIAG_MODE "simple" section_end

  StrCmp ${L_ITAIJIDICTPATH} "" check_other_kakaksi
  StrCpy ${L_TEMP} ""
  IfFileExists "${L_ITAIJIDICTPATH}" display_itaiji_result
  StrCpy ${L_TEMP} "not "

display_itaiji_result:
  DetailPrint "'itaijidict' file = ${L_TEMP}found"

check_other_kakaksi:
  StrCmp ${L_KANWADICTPATH} "" 0 check_kanwa
  StrCmp ${L_ITAIJIDICTPATH} "" section_end exit_with_blank_line

check_kanwa:
  StrCpy ${L_TEMP} ""
  IfFileExists "${L_KANWADICTPATH}" display_kanwa_result
  StrCpy ${L_TEMP} "not "

display_kanwa_result:
  DetailPrint "'kanwadict'  file = ${L_TEMP}found"

exit_with_blank_line:
  DetailPrint ""

section_end:
  Pop ${L_TEMP}
  Pop ${L_POPFILE_ROOT}
  Pop ${L_KANWADICTPATH}
  Pop ${L_ITAIJIDICTPATH}

  !undef L_ITAIJIDICTPATH
  !undef L_KANWADICTPATH
  !undef L_POPFILE_ROOT
  !undef L_TEMP

next_section:
SectionEnd


;--------------------------------------------------------------------------
; Section: Insert TimeStamp (and scroll, if 'simple' mode)
;--------------------------------------------------------------------------

Section "Insert TimeStamp"

  StrCmp $G_DIAG_MODE "simple" enter_section
  StrCmp $G_DIAG_MODE "full" enter_section next_section

enter_section:

  !define L_TEMP    $R9

  Push ${L_TEMP}

  Call PFI_GetDateTimeStamp
  Pop ${L_TEMP}
  DetailPrint "------------------------------------------------------------"
  DetailPrint "(report created ${L_TEMP})"
  DetailPrint "------------------------------------------------------------"

  StrCmp $G_DIAG_MODE "simple" 0 section_end

  ; For 'simple' reports, scroll to the LFN and SFN versions of the installation locations

  Call ScrollToShowPaths

section_end:
  Pop ${L_TEMP}

  !undef L_TEMP

next_section:
SectionEnd


;--------------------------------------------------------------------------
; Section: Create 'User Data' folder shortcut
;--------------------------------------------------------------------------

Section "Create 'User Data' Shortcut"

  StrCmp $G_DIAG_MODE "shortcut" enter_section next_section

enter_section:
  SetDetailsPrint listonly

  !define L_REGDATA         $R9   ; data read from registry

  Push ${L_REGDATA}

  ReadRegStr ${L_REGDATA} HKCU "${C_PFI_PRODUCT_REGISTRY_ENTRY}" "UserDir_LFN"
  StrCmp ${L_REGDATA} "" no_reg_data
  IfFileExists "${L_REGDATA}\*.*" folder_found

no_reg_data:
  DetailPrint "ERROR:"
  DetailPrint ""
  DetailPrint "Unable to create the POPFile 'User Data' shortcut for '$G_WINUSERNAME' user"
  DetailPrint ""
  DetailPrint "(registry entry missing or invalid - run 'adduser.exe' to repair)"
  DetailPrint ""
  Goto section_end

folder_found:
  SetDetailsPrint none
  SetOutPath "$SMPROGRAMS\${C_PFI_PRODUCT}\Support"
  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\User Data ($G_WINUSERNAME).lnk" NORMAL
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\User Data ($G_WINUSERNAME).lnk" \
                 "${L_REGDATA}"
  SetDetailsPrint listonly
  DetailPrint "For easy access to the POPFile 'User Data' for '$G_WINUSERNAME' use the shortcut:"
  DetailPrint ""
  DetailPrint "Start --> Programs --> POPFile --> Support --> User Data ($G_WINUSERNAME)"
  DetailPrint ""

section_end:
  Pop ${L_REGDATA}

  !undef L_REGDATA

next_section:
SectionEnd


;--------------------------------------------------------------------------
; Section: Help Screen
;--------------------------------------------------------------------------

Section "Help Screen"

  StrCmp $G_DIAG_MODE "help" enter_section next_section

enter_section:
  SetDetailsPrint listonly

  DetailPrint "POPFile $(^Name) v${C_VERSION}"
  DetailPrint ""
  DetailPrint "pfidiag            --- displays location of POPFile program and the 'User Data' files"
  DetailPrint ""
  DetailPrint "pfidiag /simple    --- same as 'pfidiag' option"
  DetailPrint ""
  DetailPrint "pfidiag /full      --- displays a more detailed report"
  DetailPrint ""
  DetailPrint "pfidiag /shortcut  --- creates a Start Menu shortcut to the 'User Data' folder"
  DetailPrint ""
  DetailPrint "pfidiag /help      --- displays this help screen"

next_section:
SectionEnd


;--------------------------------------------------------------------------
; Section: The End (always executed)
;--------------------------------------------------------------------------

Section "The End"

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_DIAG_RIGHTCLICK)"
  SetDetailsPrint none

SectionEnd


#--------------------------------------------------------------------------
# Installer Function: IsNT
#
# This function performs a simple check to determine if the utility is running on
# a Win9x system or a more modern OS. (This function is also used by the installer,
# uninstaller, 'Add POPFile User' wizard and runpopfile.exe)
#
# Returns 0 if running on a Win9x system, otherwise returns 1
#
# Inputs:
#         None
#
# Outputs:
#         (top of stack)   - 0 (running on Win9x system) or 1 (running on a more modern OS)
#
# Usage:
#
#         Call IsNT
#         Pop $R0
#
#         ($R0 at this point is 0 if installer is running on a Win9x system)
#
#--------------------------------------------------------------------------

Function IsNT

  Push $0
  ReadRegStr $0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion
  StrCmp $0 "" 0 IsNT_yes

  ; we are not NT.

  Pop $0
  Push 0
  Return

IsNT_yes:
  Pop $0
  Push 1
FunctionEnd


#--------------------------------------------------------------------------
# Installer Function: AnalyseShortcuts
#
# The Windows installer (setup.exe) and the "Add POPFile User" wizard (adduser.exe) only check
# for specific StartUp shortcut names so if the user has renamed a POPFile StartUp shortcut
# created during a previous installation or has created their own shortcut then there may be
# more than one StartUp shortcut for POPFile. This function analyses all shortcuts in the
# specified folder and lists those that appear to start POPFile.
#
# POPFile shortcuts are expected to use command-lines which include one of the following:
#
#  (1) runpopfile.exe
#  (2) popfile.exe
#  (3) popfileb.exe
#  (4) popfilef.exe
#  (5) popfileib.exe
#  (6) popfileif.exe
#  (7) perl.exe popfile.pl
#  (8) wperl.exe popfile.pl
#
# Additional command-line options may be supplied (to override some configuration settings).
#
# For simplicity this version of the function merely looks for the string "POPFile" in the
# shortcut's "target" command-line using a case-insensitive search.
#
# Inputs:
#         (top of stack)   - address of the folder containing the shortcuts to be analysed
#
# Outputs:
#         (top of stack)   - number of shortcuts found which appear to start POPFile
#
# Usage:
#
#         Push "$SMSTARTUP"
#         Call AnalyseShortcuts
#         Pop $R0
#
#         ; if $R0 is 2 or more then something has gone wrong!
#
#--------------------------------------------------------------------------

Function AnalyseShortcuts

  !define L_LNK_FOLDER         $R9   ; folder where the shortcuts (if any) are stored
  !define L_LNK_HANDLE         $R8   ; file handle used when searching for shortcut files
  !define L_LNK_NAME           $R7   ; name of a shortcut file
  !define L_LNK_TOTAL          $R6   ; counts the number of shortcuts we find
  !define L_POPFILE_TOTAL      $R5   ; total number of shortcuts which appear to start POPFile
  !define L_SHORTCUT_ARGS      $R4
  !define L_SHORTCUT_START_IN  $R3
  !define L_SHORTCUT_TARGET    $R2
  !define L_TEMP               $R1

  Exch ${L_LNK_FOLDER}
  Push ${L_LNK_HANDLE}
  Push ${L_LNK_NAME}
  Push ${L_LNK_TOTAL}
  Push ${L_POPFILE_TOTAL}
  Push ${L_SHORTCUT_ARGS}
  Push ${L_SHORTCUT_START_IN}
  Push ${L_SHORTCUT_TARGET}
  Push ${L_TEMP}

  StrCpy ${L_LNK_TOTAL}     0
  StrCpy ${L_POPFILE_TOTAL} 0

  IfFileExists "${L_LNK_FOLDER}\*.*" 0 exit

  FindFirst ${L_LNK_HANDLE} ${L_LNK_NAME} "${L_LNK_FOLDER}\*.lnk"
  StrCmp ${L_LNK_HANDLE} "" all_done_now

examine_shortcut:
  StrCmp ${L_LNK_NAME} "." look_again
  StrCmp ${L_LNK_NAME} ".." look_again
  IfFileExists "${L_LNK_FOLDER}\${L_LNK_NAME}\*.*" look_again
  IntOp ${L_LNK_TOTAL} ${L_LNK_TOTAL} + 1
  ShellLink::GetShortCutTarget "${L_LNK_FOLDER}\${L_LNK_NAME}"
  Pop ${L_SHORTCUT_TARGET}
  ShellLink::GetShortCutArgs "${L_LNK_FOLDER}\${L_LNK_NAME}"
  Pop ${L_SHORTCUT_ARGS}

  Push ${L_SHORTCUT_TARGET}
  Push "popfile"
  Call PFI_StrStr
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" 0 show_details
  Push ${L_SHORTCUT_ARGS}
  Push "popfile"
  Call PFI_StrStr
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" look_again

show_details:
  IntOp ${L_POPFILE_TOTAL} ${L_POPFILE_TOTAL} + 1
  ShellLink::GetShortCutWorkingDirectory "${L_LNK_FOLDER}\${L_LNK_NAME}"
  Pop ${L_SHORTCUT_START_IN}
  DetailPrint ""
  DetailPrint "Shortcut name     = < ${L_LNK_NAME} >"
  DetailPrint "Shortcut start in = < ${L_SHORTCUT_START_IN} >"
  DetailPrint "Shortcut target   = < ${L_SHORTCUT_TARGET} >"
  StrCpy ${L_TEMP} "found"
  IfFileExists ${L_SHORTCUT_TARGET} show_args
  StrCpy ${L_TEMP} "not found"

show_args:
  StrCmp ${L_SHORTCUT_ARGS} "" no_args
  DetailPrint "Shortcut argument = < ${L_SHORTCUT_ARGS} >"
  Goto show_status

no_args:
  DetailPrint "Shortcut argument = ><"

show_status:
  DetailPrint "Target status     = ${L_TEMP}"

look_again:
  FindNext ${L_LNK_HANDLE} ${L_LNK_NAME}
  StrCmp ${L_LNK_NAME} "" all_done_now examine_shortcut

all_done_now:
  FindClose ${L_LNK_HANDLE}

exit:
  DetailPrint ""
  DetailPrint "*.lnk files found = ${L_LNK_TOTAL}"
  DetailPrint "POPFile shortcuts = ${L_POPFILE_TOTAL}"
  IntCmp ${L_POPFILE_TOTAL} 1 restore_regs restore_regs
  DetailPrint "^^^^ Warning ^^^^   More than one POPFile StartUp shortcut found in this folder"

restore_regs:
  StrCpy ${L_LNK_FOLDER} ${L_POPFILE_TOTAL}

  Pop ${L_TEMP}
  Pop ${L_SHORTCUT_TARGET}
  Pop ${L_SHORTCUT_START_IN}
  Pop ${L_SHORTCUT_ARGS}
  Pop ${L_POPFILE_TOTAL}
  Pop ${L_LNK_TOTAL}
  Pop ${L_LNK_NAME}
  Pop ${L_LNK_HANDLE}
  Exch ${L_LNK_FOLDER}          ; return number of shortcuts which appear to start POPFile

  !undef L_LNK_FOLDER
  !undef L_LNK_HANDLE
  !undef L_LNK_NAME
  !undef L_LNK_TOTAL
  !undef L_POPFILE_TOTAL
  !undef L_SHORTCUT_ARGS
  !undef L_SHORTCUT_START_IN
  !undef L_SHORTCUT_TARGET
  !undef L_TEMP

FunctionEnd


#--------------------------------------------------------------------------
# Installer Function: CheckForSpaces
#
# This function logs an error message if there are any spaces in the input string
#
# Inputs:
#         (top of stack)   - input string
#
# Outputs:
#         (none)
#
# Usage:
#
#         Push "an example"
#         Call CheckForSpaces
#
#         (an error message will be added to the log)
#
#--------------------------------------------------------------------------

Function CheckForSpaces

  !define L_TEMP  $R9

  Exch ${L_TEMP}
  Push ${L_TEMP}
  Push " "
  Call PFI_StrStr
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" exit
  DetailPrint "^^^^^ Error ^^^^^   The above value should not contain spaces"

exit:
  Pop ${L_TEMP}

  !undef L_TEMP

FunctionEnd


#--------------------------------------------------------------------------
# Installer Function: CheckForTrailingSlash
#
# This function logs an error message if there is a trailing slash in the input string
#
# Inputs:
#         (top of stack)   - input string
#
# Outputs:
#         (none)
#
# Usage:
#
#         Push "C:\Program Files\POPFile\"
#         Call CheckForTrailingSlash
#
#         (an error message will be added to the log)
#
#--------------------------------------------------------------------------

Function CheckForTrailingSlash

  !define L_STRING  $R9
  !define L_TEMP    $R8

  Exch ${L_STRING}
  Push ${L_TEMP}

  StrCpy ${L_TEMP} ${L_STRING} 1 -1
  StrCmp ${L_TEMP} "\" 0 exit
  DetailPrint "^^^^^ Error ^^^^^   The above value should not end with '\' character"

exit:
  Pop ${L_TEMP}
  Pop ${L_STRING}

  !undef L_STRING
  !undef L_TEMP

FunctionEnd


#--------------------------------------------------------------------------
# Function used to manipulate the contents of the details view
#--------------------------------------------------------------------------

  ;------------------------------------------------------------------------
  ; Constants used when accessing the details view
  ;------------------------------------------------------------------------

  !define C_LVM_GETITEMCOUNT        0x1004
  !define C_LVM_ENSUREVISIBLE       0x1013

#--------------------------------------------------------------------------
# Installer Function: ScrollToShowPaths
#
# Scrolls the details view up to make it show the locations of the
# program files and the 'User Data' files in LFN and SFN formats.
#
# Inputs:
#         none
#
# Outputs:
#         none
#
# Usage:
#         Call ScrollToShowPaths
#
#--------------------------------------------------------------------------

Function ScrollToShowPaths

  !define L_TEMP      $R9
  !define L_TOPROW    $R8   ; item index of the line we want to be at the top of the window

  Push ${L_TEMP}
  Push ${L_TOPROW}

  ; Even the 'simple' report is too long to fit in the details view window so we
  ; automatically scroll the view to make it display the LFN and SFN versions of
  ; the POPFile program and 'User Data' folder locations (on the assumption that
  ; this is the information most users will want to find first).

  StrCpy ${L_TOPROW} 9    ; index of the blank line immediately before "Current UserName"

  ; Check how many 'details' lines there are

  FindWindow ${L_TEMP} "#32770" "" $HWNDPARENT
  GetDlgItem ${L_TEMP} ${L_TEMP} 0x3F8          ; This is the Control ID of the details view
  SendMessage ${L_TEMP} ${C_LVM_GETITEMCOUNT} 0 0 ${L_TEMP}

  ; No point in trying to display a non-existent line

  IntCmp ${L_TEMP} ${L_TOPROW} exit exit

  ; Scroll up (in effect) to show Current UserName, Program folder & User Data folder entries

  FindWindow ${L_TEMP} "#32770" "" $HWNDPARENT
  GetDlgItem ${L_TEMP} ${L_TEMP} 0x3F8           ; This is the Control ID of the details view
  SendMessage ${L_TEMP} ${C_LVM_ENSUREVISIBLE} ${L_TOPROW} 0

exit:
  Pop ${L_TOPROW}
  Pop ${L_TEMP}

  !undef L_TEMP
  !undef L_TOPROW

FunctionEnd

#--------------------------------------------------------------------------
# End of 'pfidiag.nsi'
#--------------------------------------------------------------------------
