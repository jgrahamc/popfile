#-------------------------------------------------------------------------------------------
#
# runpopfile.nsi --- A simple front-end which runs the 'popfile.exe' starter program
#                    after ensuring the necessary environment variables exist. If the
#                    variables are undefined, the registry data created by the installer
#                    is used to define them. If suitable registry data cannot be found,
#                    the 'Add POPFile User' wizard is launched (if it can be found).
#
#                    To make debugging easier, the utility will use the POPFile Message
#                    Capture utility (if it is available) whenever the 'windows-console'
#                    mode is selected in 'popfile.cfg'.
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
#-------------------------------------------------------------------------------------------
#
# This version of the script has been tested with the "NSIS 2" compiler (final),
# released 7 February 2004, with no "official" NSIS patches/CVS updates applied.
#
#--------------------------------------------------------------------------
# Optional run-time command-line switches (used by 'runpopfile.exe')
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
#
# This switch cannot be combined with the '/config' switch.
#
# ---------------------------------------------------------------------------------------
#
# /config=path to a folder containing popfile.cfg
# (either a full path or one relative to the folder containing runpopfile.exe)
#
# Normally the utility sets the POPFILE_ROOT and POPFILE_USER environment variables to the
# user-specific values found in the registry. This switch is intended for use when a particular
# user has more than one configuration (one for POP3 work and one for NNTP work, perhaps) and
# wishes to easily switch between them.
#
# If the following conditions are met the utility will temporarily make POPFILE_ROOT point to
# the folder containing the utility and POPFILE_USER point to the specified user data folder:
#
# (1) this utility is stored in the same folder as the 'popfile.exe' program, and
# (2) this command-line switch is present, and
# (3) the path supplied is valid (i.e. it points to a folder which contains popfile.cfg), and
# (4) the path supplied does not contain spaces if short file name support has been disabled
#
# These temporary changes will override any existing values in these environment variables.
#
# This switch cannot be combined with the '/startup' switch.
#
#-------------------------------------------------------------------------------------------

  !define C_PFI_VERSION   0.1.11

  Name    "Run POPFile"
  Caption "Run POPFile (enhanced)"

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
# Version Information settings (for runpopfile.exe)
#--------------------------------------------------------------------------

  ; 'VIProductVersion' format is X.X.X.X where X is a number in range 0 to 65535
  ; representing the following values: Major.Minor.Release.Build

  VIProductVersion                  "${C_PFI_VERSION}.0"

  VIAddVersionKey "ProductName"     "Run POPFile"
  VIAddVersionKey "Comments"        "POPFile Homepage: http://popfile.sf.net"
  VIAddVersionKey "CompanyName"     "The POPFile Project"
  VIAddVersionKey "LegalCopyright"  "Copyright (c) 2004  John Graham-Cumming"
  VIAddVersionKey "FileDescription" "Enhanced front-end for POPFile starter program"
  VIAddVersionKey "FileVersion"     "${C_PFI_VERSION}"

  VIAddVersionKey "Build Date/Time" "${__DATE__} @ ${__TIME__}"
  VIAddVersionKey "Build Script"    "${__FILE__}$\r$\n(${__TIMESTAMP__})"

#--------------------------------------------------------------------------
# Include private library functions and macro definitions
#--------------------------------------------------------------------------

  ; Avoid compiler warnings by disabling the functions and definitions we do not use

  !define RUNPOPFILE

  !include "pfi-library.nsh"

#--------------------------------------------------------------------------
# Language strings used by the POPFile Windows installer
#--------------------------------------------------------------------------

  !include "languages\English-pfi.nsh"

#--------------------------------------------------------------------------
# A simple front-end for POPFile's starter program (popfile.exe)
#--------------------------------------------------------------------------

Section default

  !define L_CFG           $R9   ; file handle used to access 'popfile.cfg'
  !define L_CONSOLE       $R8   ; 1 = console mode selected, 0 = background mode selected
  !define L_EXEFILE       $R7   ; where we expect to find popfile.exe and (perhaps) adduser.exe
  !define L_LINE          $R6   ; a line (or part of line) from 'popfile.cfg'
  !define L_PARAMS        $R5   ; command-line parameters (everything after 'runpopfile' part)
  !define L_PFI_ROOT      $R4   ; path to the POPFile program (popfile.pl, and other files)
  !define L_PFI_USER      $R3   ; path to user's 'popfile.cfg' file
  !define L_TEMP          $R2
  !define L_TEXTEND       $R1   ; helps ensure correct handling of lines over 1023 chars long
  !define L_WINOS_FLAG    $R0   ; 1 = modern Windows system, 0 = Win9x system
  !define L_WINUSERNAME   $9    ; Windows login name used to confirm validity of HKCU data

  !define L_RESERVED      $0    ; used in system.dll calls

  ; Need to be able to confirm ownership when accessing the HKCU data

	ClearErrors
	UserInfo::GetName
	IfErrors default_name
	Pop ${L_WINUSERNAME}
  StrCmp ${L_WINUSERNAME} "" 0 find_popfile

default_name:
  StrCpy ${L_WINUSERNAME} "UnknownUser"

find_popfile:
  ReadRegStr ${L_EXEFILE} HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_LFN"
  IfFileExists "${L_EXEFILE}\popfile.exe" found_popfile

  ReadRegStr ${L_EXEFILE} HKLM "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_LFN"
  IfFileExists "${L_EXEFILE}\popfile.exe" found_popfile

not_compatible:
  MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_COMPAT_NOTFOUND)"
  Goto exit

found_popfile:
  Call GetParameters
  Pop ${L_PARAMS}
  StrCmp ${L_PARAMS} "" use_reg_dirdata
  StrCmp ${L_PARAMS} "/startup" use_reg_dirdata
  StrCpy ${L_TEMP} ${L_PARAMS} 8
  StrCmp ${L_TEMP} "/config=" extract_config_path
  MessageBox MB_OK|MB_ICONSTOP "Error: Unknown option supplied !\
      $\r$\n$\r$\n\
      (${L_PARAMS})"
  Goto exit

extract_config_path:
  StrCpy ${L_PARAMS} ${L_PARAMS} "" 8
  StrCpy ${L_TEMP} ${L_PARAMS} 1
  StrCmp ${L_TEMP} '"' strip_quotes
  StrCmp ${L_TEMP} "'" strip_quotes check_config

strip_quotes:
  StrCpy ${L_PARAMS} ${L_PARAMS} "" 1
  StrCpy ${L_PARAMS} ${L_PARAMS} -1

check_config:
  StrCmp ${L_PARAMS} "" path_missing

  ; If runpopfile.exe is in same folder as popfile.exe then use $EXEDIR for POPFILE_ROOT value

  IfFileExists "$EXEDIR\popfile.exe" 0 ignore_config
  StrCpy ${L_EXEFILE} $EXEDIR

  ; Allow '/config' to specify either the full path or a path relative to $EXEDIR

  Push ${L_EXEFILE}
  Push ${L_PARAMS}
  Call GetDataPath
  Pop ${L_PFI_USER}
  IfFileExists "${L_PFI_USER}\popfile.cfg" config_found
  MessageBox MB_OK|MB_ICONSTOP "Error: Unable to find popfile.cfg !\
      $\r$\n$\r$\n\
      '/config=${L_PARAMS}' is not valid\
      $\r$\n$\r$\n\
      ('${L_PFI_USER}\popfile.cfg' does not exist)"
  Goto exit

path_missing:
  MessageBox MB_OK|MB_ICONSTOP "Error: /config=${L_PARAMS} is not valid\
      $\r$\n$\r$\n\
      (no 'User Data' path supplied)"
  Goto exit

config_found:

  ; Current version of POPFile does not work properly if POPFILE_ROOT or POPFILE_USER contain
  ; spaces, so we normally use short file name format for these values. NTFS-based systems may
  ; not support short file names (for performance reasons) so we need to be able to handle this.
  ; We assume that the POPFile installer has checked the short file name support, updated the
  ; registry accordingly and ensured that POPFile has been installed in a suitable folder.

  ReadRegStr ${L_TEMP} HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_SFN"
  StrCmp ${L_TEMP} "" try_HKLM_sfn
  StrCmp ${L_TEMP} "Not supported" check_for_spaces get_temp_sfn

try_HKLM_sfn:
  ReadRegStr ${L_TEMP} HKLM "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_SFN"
  StrCmp ${L_TEMP} "" not_compatible
  StrCmp ${L_TEMP} "Not supported" check_for_spaces

get_temp_sfn:
  GetFullPathName /SHORT ${L_PFI_ROOT} ${L_EXEFILE}
  GetFullPathName /SHORT ${L_PFI_USER} ${L_PFI_USER}
  Goto set_temp_vars_now

check_for_spaces:
  Push ${L_PFI_USER}
  Push ' '
  Call StrStr
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" config_is_valid
  MessageBox MB_OK|MB_ICONEXCLAMATION \
      "Current configuration does not support short file names\
      $\r$\n$\r$\n\
      '/config=${L_PARAMS}' is not valid\
      $\r$\n$\r$\n\
      ('${L_PFI_USER}' contains spaces)"
  Goto exit

config_is_valid:
  StrCpy ${L_PFI_ROOT} ${L_EXEFILE}

set_temp_vars_now:
  System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("POPFILE_ROOT", "${L_PFI_ROOT}").r0'
  StrCmp ${L_RESERVED} 0 0 set_temp_user_now
  MessageBox MB_OK|MB_ICONSTOP "Error: Unable to set an environment variable (POPFILE_ROOT)"
  Goto exit

set_temp_user_now:
  System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("POPFILE_USER", "${L_PFI_USER}").r0'
  StrCmp ${L_RESERVED} 0 0 start_popfile
  MessageBox MB_OK|MB_ICONSTOP "Error: Unable to set an environment variable (POPFILE_USER)"
  Goto exit

ignore_config:
  MessageBox MB_OKCANCEL|MB_ICONQUESTION "Warning: the /config option will be ignored\
      $\r$\n$\r$\n\
      ('runpopfile.exe' not in same folder as 'popfile.exe')\
      $\r$\n$\r$\n\
      Click 'Yes' to continue or 'Cancel' to quit" IDCANCEL exit

use_reg_dirdata:
  ReadRegStr ${L_EXEFILE} HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_LFN"
  IfFileExists "${L_EXEFILE}\popfile.exe" got_exe_path

  ReadRegStr ${L_EXEFILE} HKLM "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_LFN"
  IfFileExists "${L_EXEFILE}\popfile.exe" got_exe_path

  StrCpy ${L_EXEFILE} $EXEDIR
  IfFileExists "${L_EXEFILE}\popfile.exe" got_exe_path
  MessageBox MB_OK|MB_ICONSTOP "Error: Unable to start POPFile !\
      $\r$\n$\r$\n\
      POPFile start program not found:\
      $\r$\n\
      ${L_EXEFILE}\popfile.exe"
  Goto exit

got_exe_path:
  ReadRegStr ${L_TEMP} HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "Owner"
  StrCmp ${L_TEMP} ${L_WINUSERNAME} check_root
  StrCmp ${L_TEMP} "" check_root
  Goto add_user

check_root:
  ReadRegStr ${L_PFI_ROOT} HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_SFN"
  StrCmp ${L_PFI_ROOT} "" add_user
  StrCmp ${L_PFI_ROOT} "Not supported" 0 check_root_data
  ReadRegStr ${L_PFI_ROOT} HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_LFN"

check_root_data:
  IfFileExists "${L_PFI_ROOT}\popfile.pl" 0 bad_root_error
  ReadEnvStr ${L_TEMP} "POPFILE_ROOT"
  StrCmp ${L_TEMP} ${L_PFI_ROOT} check_user
  Call IsNT
  Pop ${L_WINOS_FLAG}
  StrCmp ${L_WINOS_FLAG} 0 set_root_now
  WriteRegStr HKCU "Environment" "POPFILE_ROOT" ${L_PFI_ROOT}
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

set_root_now:
  System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("POPFILE_ROOT", "${L_PFI_ROOT}").r0'
  StrCmp ${L_RESERVED} 0 0 check_user
  MessageBox MB_OK|MB_ICONSTOP "Error: Unable to set an environment variable (POPFILE_ROOT)"
  Goto exit

check_user:
  ReadRegStr ${L_PFI_USER} HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "UserDir_SFN"
  StrCmp ${L_PFI_USER} "" add_user
  StrCmp ${L_PFI_USER} "Not supported" 0 check_user_data
  ReadRegStr ${L_PFI_USER} HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "UserDir_LFN"

check_user_data:
  IfFileExists "${L_PFI_USER}\*.*" 0 bad_user_error
  ReadEnvStr ${L_TEMP} "POPFILE_USER"
  StrCmp ${L_TEMP} ${L_PFI_USER} start_popfile
  Call IsNT
  Pop ${L_WINOS_FLAG}
  StrCmp ${L_WINOS_FLAG} 0 set_user_now
  WriteRegStr HKCU "Environment" "POPFILE_USER" ${L_PFI_USER}
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

set_user_now:
  System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("POPFILE_USER", "${L_PFI_USER}").r0'
  StrCmp ${L_RESERVED} 0 0 start_popfile
  MessageBox MB_OK|MB_ICONSTOP "Error: Unable to set an environment variable (POPFILE_USER)"
  Goto exit

start_popfile:
  IfFileExists "${L_EXEFILE}\pfimsgcapture.exe" 0 run_normal_mode
  IfFileExists "${L_PFI_USER}\popfile.cfg" 0 run_normal_mode
  StrCpy ${L_CONSOLE} "0"
  FileOpen ${L_CFG} "${L_PFI_USER}\popfile.cfg" r

found_eol:
  StrCpy ${L_TEXTEND} "<eol>"

loop:
  FileRead ${L_CFG} ${L_LINE}
  StrCmp ${L_LINE} "" options_done
  StrCmp ${L_TEXTEND} "<eol>" 0 check_eol
  StrCmp ${L_LINE} "$\n" loop

  StrCpy ${L_TEMP} ${L_LINE} 16
  StrCmp ${L_TEMP} "windows_console " got_console_option
  Goto check_eol

got_console_option:
  StrCpy ${L_CONSOLE} ${L_LINE} 1 16

check_eol:
  StrCpy ${L_TEXTEND} ${L_LINE} 1 -1
  StrCmp ${L_TEXTEND} "$\n" found_eol
  StrCmp ${L_TEXTEND} "$\r" found_eol loop

options_done:
  FileClose ${L_CFG}
  StrCmp ${L_CONSOLE} "1" run_debug_mode

run_normal_mode:
  Exec '"${L_EXEFILE}\popfile.exe"'
  Goto exit

run_debug_mode:
  Exec '"${L_EXEFILE}\pfimsgcapture.exe" /TIMEOUT=0'
  Goto exit

bad_root_error:
  IfFileExists "${L_EXEFILE}\adduser.exe" can_add_root
  MessageBox MB_OK|MB_ICONSTOP "Error: Unable to start POPFile !\
      $\r$\n$\r$\n\
      POPFile start file not found:\
      $\r$\n\
      ${L_PFI_ROOT}\popfile.pl"
  Goto exit

can_add_root:
  MessageBox MB_YESNO|MB_ICONQUESTION "Error: Unable to start POPFile !\
      $\r$\n$\r$\n\
      POPFile start file not found:\
      $\r$\n\
      ${L_PFI_ROOT}\popfile.pl\
      $\r$\n$\r$\n\
      Click 'Yes' to reconfigure POPFile now" IDYES run_adduser
  Goto exit

bad_user_error:
  IfFileExists "${L_EXEFILE}\adduser.exe" can_add_user
  MessageBox MB_OK|MB_ICONSTOP "Error: Unable to start POPFile !\
      $\r$\n$\r$\n\
      POPFile 'User Data' not found:\
      $\r$\n\
      ${L_PFI_USER}"
  Goto exit

can_add_user:
  MessageBox MB_YESNO|MB_ICONQUESTION "Error: Unable to start POPFile !\
      $\r$\n$\r$\n\
      POPFile 'User Data' not found:\
      $\r$\n\
      ${L_PFI_USER}\
      $\r$\n$\r$\n\
      Click 'Yes' to reconfigure POPFile now" IDYES run_adduser
  Goto exit

no_adduser_error:
  MessageBox MB_OK|MB_ICONSTOP "Error: Unable to start the 'Add User' wizard !\
      $\r$\n$\r$\n\
      POPFile 'Add User' wizard not found:\
      $\r$\n\
      ${L_EXEFILE}\adduser.exe"
  Goto exit

add_user:
  StrCmp ${L_PARAMS} "/startup" exit
  IfFileExists "${L_EXEFILE}\adduser.exe" 0 no_adduser_error

run_adduser:
  Exec '"${L_EXEFILE}\adduser.exe"'

exit:

  !undef L_CFG
  !undef L_CONSOLE
  !undef L_EXEFILE
  !undef L_LINE
  !undef L_PARAMS
  !undef L_PFI_ROOT
  !undef L_PFI_USER
  !undef L_TEMP
  !undef L_TEXTEND
  !undef L_WINOS_FLAG
  !undef L_WINUSERNAME

  !undef L_RESERVED

SectionEnd

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
