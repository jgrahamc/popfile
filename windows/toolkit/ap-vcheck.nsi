#-------------------------------------------------------------------------------------------
#
# ap-vcheck.nsi --- A simple utility used at compile-time to obtain the version and build
#                   number of the ActivePerl installation specified in the 'installer.nsi'
#                   source file. Recent updates to ActivePerl have caused run-time problems
#                   with the minimal Perl and these prompted the creation of this utility.
#                   This utility creates an INCLUDE file which is used by 'installer.nsi'
#                   at compile-time to ensure that the installer is built using a suitable
#                   version of ActivePerl.
#
# Copyright (c) 2007-2012  John Graham-Cumming
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify it
#   under the terms of version 2 of the GNU General Public License as
#   published by the Free Software Foundation.
#
#   POPFile is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with POPFile; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#-------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------
# Usage:
#
# AP-VCHECK Perl installation path
#
# where "Perl installation path" is the value defined as ${C_PERL_DIR} in 'installer.nsi'
#
#-------------------------------------------------------------------------------------------

  ; This version of the script has been tested with the "NSIS v2.46" compiler,
  ; released 6 December 2009. This particular compiler can be downloaded from
  ; http://prdownloads.sourceforge.net/nsis/nsis-2.46-setup.exe?download

  !define C_EXPECTED_VERSION  "v2.46"

  !define ${NSIS_VERSION}_found

  !ifndef ${C_EXPECTED_VERSION}_found
      !warning \
          "$\n\
          $\n***   NSIS COMPILER WARNING:\
          $\n***\
          $\n***   This script has only been tested using the NSIS ${C_EXPECTED_VERSION} compiler\
          $\n***   and may not work properly with this NSIS ${NSIS_VERSION} compiler\
          $\n***\
          $\n***   The resulting 'installer' program should be tested carefully!\
          $\n$\n"
  !endif

  !undef  ${NSIS_VERSION}_found
  !undef  C_EXPECTED_VERSION

  ;--------------------------------------------------------------------------
  ; Symbol used to avoid confusion over where the line breaks occur.
  ;
  ; ${MB_NL} is used for MessageBox-style 'new line' sequences.
  ;
  ; (this constant does not follow the 'C_' naming convention described below)
  ;--------------------------------------------------------------------------

  !define MB_NL   "$\r$\n"

  ;--------------------------------------------------------------------------
  ; POPFile constants have been given names beginning with 'C_' (eg C_README)
  ;--------------------------------------------------------------------------

  !define C_VERSION   "1.0.0"     ; see 'VIProductVersion' comment below for format details
  !define C_OUTFILE   "ap-vcheck.exe"

  Name "ActivePerl Version Check ${C_VERSION}"

  ; Specify EXE filename and icon for the 'installer'

  OutFile "${C_OUTFILE}"

  Icon "..\POPFileIcon\popfile.ico"

  ; Selecting 'silent' mode makes the installer behave like a command-line utility

  SilentInstall silent

  ;--------------------------------------------------------------------------
  ; Windows Vista expects to find a manifest specifying the execution level
  ;--------------------------------------------------------------------------

  RequestExecutionLevel   user

#--------------------------------------------------------------------------

  ; 'VIProductVersion' format is X.X.X.X where X is a number in range 0 to 65535
  ; representing the following values: Major.Minor.Release.Build

  VIProductVersion                          "${C_VERSION}.0"

  !define /date C_BUILD_YEAR                "%Y"

  VIAddVersionKey "ProductName"             "ActivePerl Version Check Utility"
  VIAddVersionKey "Comments"                "POPFile Homepage: http://getpopfile.org/"
  VIAddVersionKey "CompanyName"             "The POPFile Project"
  VIAddVersionKey "LegalTrademarks"         "POPFile is a registered trademark of \
                                             John Graham-Cumming"
  VIAddVersionKey "LegalCopyright"          "Copyright (c) ${C_BUILD_YEAR}  John Graham-Cumming"
  VIAddVersionKey "FileDescription"         "Used when compiling the POPFile installer"
  VIAddVersionKey "FileVersion"             "${C_VERSION}"
  VIAddVersionKey "OriginalFilename"        "${C_OUTFILE}"

  VIAddVersionKey "Build Compiler"           "NSIS ${NSIS_VERSION}"
  VIAddVersionKey "Build Date/Time"         "${__DATE__} @ ${__TIME__}"
  !ifdef C_PFI_LIBRARY_VERSION
    VIAddVersionKey "Build Library Version" "${C_PFI_LIBRARY_VERSION}"
  !endif
  !ifdef C_NSIS_LIBRARY_VERSION
    VIAddVersionKey "NSIS Library Version"  "${C_NSIS_LIBRARY_VERSION}"
  !endif
  VIAddVersionKey "Build Script"            "${__FILE__}${MB_NL}(${__TIMESTAMP__})"

#----------------------------------------------------------------------------------------

Section default

  !define C_DEF_AP_FOLDER     "!define C_AP_FOLDER   "

  !define C_DEF_AP_MAJOR      "!define C_AP_MAJOR    "
  !define C_DEF_AP_MINOR      "!define C_AP_MINOR    "
  !define C_DEF_AP_REVSN      "!define C_AP_REVISION "
  !define C_DEF_AP_BUILD      "!define C_AP_BUILD    "
  !define C_DEF_AP_VERSN      "!define C_AP_VERSION  "

  !define C_DEF_AP_STATUS     "!define C_AP_STATUS   "
  !define C_DEF_AP_ERRMSG     "!define C_AP_ERRORMSG "

  !define L_PERL_DLL         $R9     ; Name of the Perl DLL file used to obtain the build number etc
  !define L_PERL_BIN_FOLDER  $R8     ; Location of ActivePerl installation's 'BIN' folder
  !define L_PERL_FOLDER      $R7     ; Location of ActivePerl installation (passed via the command-line)
  !define L_RESULTS_FILE     $R6     ; File handle used to access the output file (ap-version.nsh)

  StrCpy ${L_PERL_FOLDER} ""

  ; Get the location of the ActivePerl installation we are to check

  Call GetParameters
  Pop ${L_PERL_FOLDER}

  StrCmp ${L_PERL_FOLDER} "" 0 look_for_Perl
  FileOpen ${L_RESULTS_FILE} "ap-version.nsh" w
  FileWrite ${L_RESULTS_FILE}  "${C_DEF_AP_STATUS} $\"failure$\"${MB_NL}${MB_NL}"
  FileWrite ${L_RESULTS_FILE}  "${C_DEF_AP_ERRMSG} $\"ActivePerl location not supplied$\"${MB_NL}"
  FileClose ${L_RESULTS_FILE}
  Goto exit

look_for_Perl:
  StrCpy ${L_PERL_BIN_FOLDER} "${L_PERL_FOLDER}\bin"
  IfFileExists "${L_PERL_BIN_FOLDER}\*.*" look_for_DLL
  FileOpen ${L_RESULTS_FILE} "ap-version.nsh" w
  FileWrite ${L_RESULTS_FILE}  "${C_DEF_AP_STATUS} $\"failure$\"${MB_NL}${MB_NL}"
  FileWrite ${L_RESULTS_FILE}  "${C_DEF_AP_FOLDER} $\"${L_PERL_FOLDER}$\"${MB_NL}"
  FileWrite ${L_RESULTS_FILE}  "${C_DEF_AP_ERRMSG} $\"'${L_PERL_BIN_FOLDER}' folder not found$\"${MB_NL}"
  FileClose ${L_RESULTS_FILE}
  Goto exit

look_for_DLL:
  StrCpy ${L_PERL_DLL} "perl514.dll"
  IfFileExists "${L_PERL_BIN_FOLDER}\${L_PERL_DLL}" check_Perl_version
  StrCpy ${L_PERL_DLL} "perl512.dll"
  IfFileExists "${L_PERL_BIN_FOLDER}\${L_PERL_DLL}" check_Perl_version
  StrCpy ${L_PERL_DLL} "perl510.dll"
  IfFileExists "${L_PERL_BIN_FOLDER}\${L_PERL_DLL}" check_Perl_version
  StrCpy ${L_PERL_DLL} "perl58.dll"
  IfFileExists "${L_PERL_BIN_FOLDER}\${L_PERL_DLL}" check_Perl_version
  FileOpen ${L_RESULTS_FILE} "ap-version.nsh" w
  FileWrite ${L_RESULTS_FILE}  "${C_DEF_AP_STATUS} $\"failure$\"${MB_NL}${MB_NL}"
  FileWrite ${L_RESULTS_FILE}  "${C_DEF_AP_FOLDER} $\"${L_PERL_FOLDER}$\"${MB_NL}"
  FileWrite ${L_RESULTS_FILE}  "${C_DEF_AP_ERRMSG} $\"perl5[8|10|12|14].dll not found in '${L_PERL_BIN_FOLDER}' folder$\"${MB_NL}"
  FileClose ${L_RESULTS_FILE}
  Goto exit

check_Perl_version:
  !define L_MAJOR     $R1
  !define L_MINOR     $R2
  !define L_REVSN     $R3
  !define L_BUILD     $R4

  GetDllVersion "${L_PERL_BIN_FOLDER}\${L_PERL_DLL}" ${L_MINOR} ${L_BUILD}
  IntOp ${L_MAJOR} ${L_MINOR} / 0x00010000
  IntOp ${L_MINOR} ${L_MINOR} & 0x0000FFFF
  IntOp ${L_REVSN} ${L_BUILD} / 0x00010000
  IntOp ${L_BUILD} ${L_BUILD} & 0x0000FFFF

  FileOpen ${L_RESULTS_FILE} "ap-version.nsh" w
  FileWrite ${L_RESULTS_FILE}  "${C_DEF_AP_STATUS} $\"success$\"${MB_NL}${MB_NL}"
  FileWrite ${L_RESULTS_FILE}  "${C_DEF_AP_FOLDER} $\"${L_PERL_FOLDER}$\"${MB_NL}"
  FileWrite ${L_RESULTS_FILE}  "${C_DEF_AP_MAJOR} $\"${L_MAJOR}$\"${MB_NL}"
  FileWrite ${L_RESULTS_FILE}  "${C_DEF_AP_MINOR} $\"${L_MINOR}$\"${MB_NL}"
  FileWrite ${L_RESULTS_FILE}  "${C_DEF_AP_REVSN} $\"${L_REVSN}$\"${MB_NL}"
  FileWrite ${L_RESULTS_FILE}  "${C_DEF_AP_VERSN} $\"${L_MAJOR}.${L_MINOR}.${L_REVSN}$\"${MB_NL}"
  FileWrite ${L_RESULTS_FILE}  "${C_DEF_AP_BUILD} $\"${L_BUILD}$\"${MB_NL}"
  FileClose ${L_RESULTS_FILE}

 exit:
 SectionEnd

#--------------------------------------------------------------------------
# Function: GetParameters
#
# Returns the command-line parameters (if any) supplied when the installer was started
#
# Inputs:
#         none
# Outputs:
#         (top of stack)     - all of the parameters supplied on the command line (may be "")
#
# Usage:
#         Call GetParameters
#         Pop $R0
#
#         (if 'setup.exe /SSL' was used to start the installer, $R0 will hold '/SSL')
#
#--------------------------------------------------------------------------

Function GetParameters

  Push $R0
  Push $R1
  Push $R2
  Push $R3

  StrCpy $R2 1
  StrLen $R3 $CMDLINE

  ; Check for quote or space

  StrCpy $R0 $CMDLINE $R2
  StrCmp $R0 '"' 0 +3
  StrCpy $R1 '"'
  Goto loop

  StrCpy $R1 " "

loop:
  IntOp $R2 $R2 + 1
  StrCpy $R0 $CMDLINE 1 $R2
  StrCmp $R0 $R1 get
  StrCmp $R2 $R3 get
  Goto loop

get:
  IntOp $R2 $R2 + 1
  StrCpy $R0 $CMDLINE 1 $R2
  StrCmp $R0 " " get
  StrCpy $R0 $CMDLINE "" $R2

  Pop $R3
  Pop $R2
  Pop $R1
  Exch $R0

FunctionEnd

;--------------------------------------
; end-of-file
;--------------------------------------
