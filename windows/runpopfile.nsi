#-------------------------------------------------------------------------------------------
#
# runpopfile.nsi --- A simple front-end which runs the 'popfile.exe' starter program
#                    after ensuring the necessary environment variables exist. If the
#                    variables are undefined, the registry data created by the installer
#                    is used to define them. If suitable registry data cannot be found,
#                    the 'Add POPFile User' wizard is launched (if it can be found).
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
#-------------------------------------------------------------------------------------------
#
# This version of the script has been tested with the "NSIS 2" compiler (final),
# released 7 February 2004, with no patches applied.
#
#--------------------------------------------------------------------------
# Optional run-time command-line switch (used by 'runpopfile.exe')
#--------------------------------------------------------------------------
#
# /startup
#
# If this command-line switch is present, the utility does not call the 'Add POPFile User'
# wizard if the HKCU registry data appears to belong to a different user or if the POPFILE_ROOT
# and POPFILE_USER environment variables are undefined and the wizard is unable to find suitable
# registry data to initialise them.
#
# This switch is intended for use in the Start Menu's 'StartUp' folder when all users share the
# same StartUp folder (to avoid unexpected 'Add POPFile User' activity if some users do not use
# (or have not yet used) POPFile). The switch can be in uppercase or lowercase.
#-------------------------------------------------------------------------------------------

  !define C_PFI_VERSION   0.1.4

  Name    "Run POPFile"
  Caption "Run POPFile"

  Icon "POPFileIcon\popfile.ico"

  OutFile runpopfile.exe

  ; 'Silent' installers run invisibly
  
  SilentInstall silent

  ; This build is for use with the POPFile installer

  !define C_PFI_PRODUCT   "POPFile"

#--------------------------------------------------------------------------
# Use the standard NSIS list of common Windows Messages
#--------------------------------------------------------------------------

  !include WinMessages.nsh

#--------------------------------------------------------------------------
# Version Information settings (for the installer EXE and uninstaller EXE)
#--------------------------------------------------------------------------

  ; 'VIProductVersion' format is X.X.X.X where X is a number in range 0 to 65535
  ; representing the following values: Major.Minor.Release.Build

  VIProductVersion "${C_PFI_VERSION}.0"

  VIAddVersionKey "ProductName" "Run POPFile"
  VIAddVersionKey "Comments" "POPFile Homepage: http://popfile.sf.net"
  VIAddVersionKey "CompanyName" "The POPFile Project"
  VIAddVersionKey "LegalCopyright" "© 2004  John Graham-Cumming"
  VIAddVersionKey "FileDescription" "Simple front-end for the POPFile starter program"
  VIAddVersionKey "FileVersion" "${C_PFI_VERSION}"

  VIAddVersionKey "Build Date/Time" "${__DATE__} @ ${__TIME__}"
  VIAddVersionKey "Build Script" "${__FILE__}$\r$\n(${__TIMESTAMP__})"

#--------------------------------------------------------------------------
# A simple front-end for POPFile's starter program (popfile.exe)
#--------------------------------------------------------------------------

Section default

  !define L_EXEFILE       $R9   ; where we expect to find popfile.exe and (perhaps) adduser.exe
  !define L_POPFILE_ROOT  $R8   ; path to the POPFile program (popfile.pl, and other files)
  !define L_POPFILE_USER  $R7   ; path to user's popfile.cfg file
  !define L_TEMP          $R6
  !define L_WINOS_FLAG    $R5   ; 1 = modern Windows system, 0 = Win9x system
  !define L_WINUSERNAME   $R4   ; Windows login name used to confirm validity of HKCU data

  !define L_RESERVED      $0    ; used in system.dll calls

	ClearErrors
	UserInfo::GetName
	IfErrors default_name
	Pop ${L_WINUSERNAME}
  StrCmp ${L_WINUSERNAME} "" 0 check_registry

default_name:
  StrCpy ${L_WINUSERNAME} "UnknownUser"

check_registry:
  ReadRegStr ${L_EXEFILE} HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_LFN"
  IfFileExists "${L_EXEFILE}\popfile.exe" got_exe_path

  ReadRegStr ${L_EXEFILE} HKLM "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_LFN"
  IfFileExists "${L_EXEFILE}\popfile.exe" got_exe_path

  StrCpy ${L_EXEFILE} $EXEDIR
  IfFileExists "${L_EXEFILE}\popfile.exe" got_exe_path

  ; Assume the minimal Perl is not available, so look for an alternative ActivePerl installation

  SearchPath ${L_EXEFILE} perl.exe
  StrCmp ${L_EXEFILE} "" perl_missing

  MessageBox MB_YESNO|MB_ICONEXCLAMATION "Warning: minimal Perl not found !\
      $\r$\n$\r$\n\
      Do you want to run POPFile using:\
      $\r$\n$\r$\n\
      ${L_EXEFILE}" IDNO exit
  Goto got_exe_path

perl_missing:
  MessageBox MB_OK|MB_ICONSTOP "Error: Unable to start POPFile !\
      $\r$\n$\r$\n\
      (POPFile start program not found:\
      $\r$\n\
      ${L_EXEFILE}\popfile.exe)"
  Goto exit

got_exe_path:
  ReadRegStr ${L_TEMP} HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "Owner"
  StrCmp ${L_TEMP} ${L_WINUSERNAME} check_root
  StrCmp ${L_TEMP} "" check_root
  Goto add_user

check_root:
  ReadRegStr ${L_POPFILE_ROOT} HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_SFN"
  StrCmp ${L_POPFILE_ROOT} "" add_user
  IfFileExists "${L_POPFILE_ROOT}\popfile.pl" 0 bad_root_error
  ReadEnvStr ${L_TEMP} "POPFILE_ROOT"
  StrCmp ${L_TEMP} ${L_POPFILE_ROOT} check_user
  Call IsNT
  Pop ${L_WINOS_FLAG}
  StrCmp ${L_WINOS_FLAG} 0 set_root_now
  WriteRegStr HKCU "Environment" "POPFILE_ROOT" ${L_POPFILE_ROOT}
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

set_root_now:
  System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("POPFILE_ROOT", "${L_POPFILE_ROOT}").r0'
  StrCmp ${L_RESERVED} 0 0 check_user
  MessageBox MB_OK|MB_ICONSTOP "Error: Unable to set an environment variable (POPFILE_ROOT)"
  Goto exit

check_user:
  ReadRegStr ${L_POPFILE_USER} HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "UserDir_SFN"
  StrCmp ${L_POPFILE_USER} "" add_user
  IfFileExists "${L_POPFILE_USER}\*.*" 0 bad_user_error
  ReadEnvStr ${L_TEMP} "POPFILE_USER"
  StrCmp ${L_TEMP} ${L_POPFILE_USER} start_popfile
  Call IsNT
  Pop ${L_WINOS_FLAG}
  StrCmp ${L_WINOS_FLAG} 0 set_user_now
  WriteRegStr HKCU "Environment" "POPFILE_USER" ${L_POPFILE_USER}
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

set_user_now:
  System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("POPFILE_USER", "${L_POPFILE_USER}").r0'
  StrCmp ${L_RESERVED} 0 0 start_popfile
  MessageBox MB_OK|MB_ICONSTOP "Error: Unable to set an environment variable (POPFILE_USER)"
  Goto exit

start_popfile:
  IfFileExists "${L_EXEFILE}\popfile.exe" use_minimal_perl
  Exec '"${L_EXEFILE}" "${L_POPFILE_ROOT}\popfile.pl"'
  Return

use_minimal_perl:
  Exec '"${L_EXEFILE}\popfile.exe"'
  Return

bad_root_error:
  IfFileExists "${L_EXEFILE}\adduser.exe" can_add_root
  MessageBox MB_OK|MB_ICONSTOP "Error: Unable to start POPFile !\
      $\r$\n$\r$\n\
      (POPFile start file not found:\
      $\r$\n\
      ${L_POPFILE_ROOT}\popfile.pl)"
  Goto exit

can_add_root:
  MessageBox MB_YESNO|MB_ICONQUESTION "Error: Unable to start POPFile !\
      $\r$\n$\r$\n\
      (POPFile start file not found:\
      $\r$\n\
      ${L_POPFILE_ROOT}\popfile.pl)\
      $\r$\n$\r$\n\
      Click 'Yes' to reconfigure POPFile now" IDNO exit
  Exec '"${L_EXEFILE}\adduser.exe"'
  Goto exit

bad_user_error:
  IfFileExists "${L_EXEFILE}\adduser.exe" can_add_user
  MessageBox MB_OK|MB_ICONSTOP "Error: Unable to start POPFile !\
      $\r$\n$\r$\n\
      (POPFile 'User Data' not found:\
      $\r$\n\
      ${L_POPFILE_USER})"
  Goto exit

can_add_user:
  MessageBox MB_YESNO|MB_ICONQUESTION "Error: Unable to start POPFile !\
      $\r$\n$\r$\n\
      (POPFile 'User Data' not found:\
      $\r$\n\
      ${L_POPFILE_USER})\
      $\r$\n$\r$\n\
      Click 'Yes' to reconfigure POPFile now" IDNO exit
  Exec '"${L_EXEFILE}\adduser.exe"'
  Goto exit

no_adduser_error:
  MessageBox MB_OK|MB_ICONSTOP "Error: Unable to start the 'Add User' wizard !\
      $\r$\n$\r$\n\
      (POPFile wizard program not found:\
      $\r$\n\
      ${L_EXEFILE}\adduser.exe)"
  Goto exit

add_user:
  Call GetParameters
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "/startup" exit
  IfFileExists "${L_EXEFILE}\adduser.exe" 0 no_adduser_error
  Exec '"${L_EXEFILE}\adduser.exe"'

exit:
SectionEnd

#--------------------------------------------------------------------------
# General Purpose Library Function: GetParameters
#--------------------------------------------------------------------------
#
# Extracts the command-line parameters (if any)
#
# Inputs:
#         (NSIS provides the command-line as $CMDLINE)
#
# Outputs:
#         (top of stack)   - the command-line parameters supplied (if any)
#
#  Usage:
#         Call GetParameters
#         Pop $R0
#
#         ($R0 at this point is "" if no parameters were supplied)
#
#--------------------------------------------------------------------------

Function GetParameters
  Push $R0
  Push $R1
  Push $R2
  Push $R3

  StrCpy $R0 $CMDLINE 1
  StrCpy $R1 '"'
  StrCpy $R2 1
  StrLen $R3 $CMDLINE
  StrCmp $R0 '"' loop
  StrCpy $R1 ' ' ; we're scanning for a space instead of a quote

loop:
  StrCpy $R0 $CMDLINE 1 $R2
  StrCmp $R0 $R1 loop2
  StrCmp $R2 $R3 loop2
  IntOp $R2 $R2 + 1
  Goto loop

loop2:
  IntOp $R2 $R2 + 1
  StrCpy $R0 $CMDLINE 1 $R2
  StrCmp $R0 " " loop2
  StrCpy $R0 $CMDLINE "" $R2

  Pop $R3
  Pop $R2
  Pop $R1
  Exch $R0
FunctionEnd

#--------------------------------------------------------------------------
# Function: IsNT
#
# Returns 0 if running on a Win9x system, otherwise returns 1
#
# Inputs:
#         None
#
# Outputs:
#         (top of stack)   - 0 (running on Win9x system) or 1 (running on a more modern OS)
#
#  Usage:
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
    ; NT!!!
    Pop $0
    Push 1
FunctionEnd

;-------------
; end-of-file
;-------------
