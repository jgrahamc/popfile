#-------------------------------------------------------------------------------------------
#
# wrapper.nsi --- A simple utility to run POPFile after ensuring the necessary
#                 environment variables exist. These environment variables are
#                 defined in 'wrapper.ini' (so they can be easily altered).
#                 If 'wrapper.ini' is not found in the current directory,
#                 the utility creates the file there automatically.
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
#-------------------------------------------------------------------------------------------
#
#  This version was tested using NSIS 2.0b4 released 19 November 2003
#  with the NSIS CVS snapshot of 22 December 2003 (08:44) applied.
#
#-------------------------------------------------------------------------------------------
# Compile-time command-line switches (used by 'makensis.exe')
#-------------------------------------------------------------------------------------------
#
# This script can be used to build three different 'wrapper' utilities:
#
# (a) (no switch supplied)
#
#     This builds 'wrapper.exe' which uses the 'windows_console' entry in 'popfile.cfg'
#     to determine the POPFile mode (0 = background, 1 = foreground). If the entry doesn't
#     exist or if 'popfile.cfg' cannot be found, the utility will select foreground mode.
#
# (b) /DBACKGROUND
#
#     This builds 'wrapperb.exe' which runs POPFile in the background (i.e. runs it invisibly)
#
# (c) /DFOREGROUND
#
#     This builds 'wrapperf.exe' which runs POPFile in a console window (i.e. in a 'DOS box')
#
#-------------------------------------------------------------------------------------------
# Structure of the WRAPPER.INI file:
#
# There are two sections in the INI file: one ('Configuration') can be updated by the user to
# take advantage of the simple multi-user features introduced in POPFile v0.21.0 but the other
# ('Environment') is always updated by the utility (to record the environment it sets up when
# starting POPFile).
#
# [Configuration]
# POPFileFolder=path to the folder containing the POPFile program files
# UserDataFolder=path to the folder containing the user's POPFile configuration file(s)
#
# [Environment]
# POPFILE_ROOT=short-filename path (in lowercase) to the POPFile program files
# POPFILE_USER=short-filename path (in lowercase) to the user's configuration file(s)
#
# NOTES:
#
# (1) The POPFile installer defaults to single-user case so it creates a default 'wrapper.ini'
#     file in the installation folder, containing only 3 lines:
#
#     [Configuration]
#     POPFileFolder=C:\Program Files\POPFile
#     UserDataFolder=C:\Program Files\POPFile
#
#     (assuming the default installation folder was used)
#
# (2) When the 'wrapper' utility finds this default 'wrapper.ini' file, it will add a new
#     section to it:
#
#     [Environment]
#     POPFILE_ROOT=c:\progra~1\popfile
#     POPFILE_USER=.
#
#    (notice that the POPFILE_USER value uses a relative path)
#-------------------------------------------------------------------------------------------

  ; The default NSIS caption is "Name Setup" so we override it here

  Name    "POPFile Wrapper Utility"
  Caption "POPFile Wrapper Utility"

  !define VERSION   "0.2.0"     ; see 'VIProductVersion' comment below for format details

  !ifdef BACKGROUND
          OutFile wrapperb.exe
  !else ifdef FOREGROUND
          OutFile wrapperf.exe
  !else
          OutFile wrapper.exe
  !endif

  ; All variants use the same 'Otto the octopus' icon

  Icon "POPFileIcon\popfile.ico"

  ; Selecting 'silent' mode makes the installer behave like a command-line utility

  SilentInstall silent

#--------------------------------------------------------------------------

  ; 'VIProductVersion' format is X.X.X.X where X is a number in range 0 to 65535
  ; representing the following values: Major.Minor.Release.Build

  VIProductVersion "${VERSION}.1"

  VIAddVersionKey "ProductName" "POPFile Wrapper Utility"
  VIAddVersionKey "Comments" "POPFile Homepage: http://popfile.sourceforge.net"
  VIAddVersionKey "CompanyName" "The POPFile Project"
  VIAddVersionKey "LegalCopyright" "© 2001-2003  John Graham-Cumming"
  VIAddVersionKey "FileDescription" "Start POPFile (with environment variables)"
  VIAddVersionKey "FileVersion" "${VERSION}"

  VIAddVersionKey "Build Date/Time" "${__DATE__} @ ${__TIME__}"
  VIAddVersionKey "Build Script" "${__FILE__}$\r$\n(${__TIMESTAMP__})"

  !ifdef BACKGROUND
        VIAddVersionKey "Build Type" "Background mode"
  !else ifdef FOREGROUND
        VIAddVersionKey "Build Type" "Foreground mode"
  !else
        VIAddVersionKey "Build Type" "Automatic mode"
  !endif

#----------------------------------------------------------------------------------------

;-------------------
; Section: default
;-------------------

Section default

  !define L_CFG           $R9   ; handle used to access popfile.cfg
  !define L_CMPRE         $R8   ; used to look for config parameter
  !define L_CONSOLE       $R7   ; 0 = run in background, 1 = run in console window
  !define L_DATA          $R6
  !define L_POPFILE_ROOT  $R5   ; holds full path to the main POPFile folder
  !define L_POPFILE_USER  $R4   ; holds path to the user's 'popfile.cfg' file

  !define L_RESERVED      $0    ; register $0 is used to return result from System.dll

  ; Expect to find 'wrapper.ini' in the current directory (if not found, we create it there)
  
  ReadINIStr ${L_POPFILE_ROOT} ".\Wrapper.ini" "Configuration" "POPFileFolder"
  StrCmp ${L_POPFILE_ROOT} "" 0 got_pf_path

  ReadRegStr ${L_POPFILE_ROOT} HKLM "SOFTWARE\POPFile" InstallLocation
  StrCmp ${L_POPFILE_ROOT} "" 0 got_new_pf_path

  StrCpy ${L_POPFILE_ROOT} "C:\Program Files\POPFile"
  IfFileExists "${L_POPFILE_ROOT}\*.*" got_new_pf_path
  MessageBox MB_OK|MB_ICONSTOP "Unable to find POPFile installation"
  Goto error_exit

got_new_pf_path:
  WriteINIStr ".\Wrapper.ini" "Configuration" "POPFileFolder" "${L_POPFILE_ROOT}"

got_pf_path:
  IfFileExists "${L_POPFILE_ROOT}\*.*" got_pf_folder
  Push ${L_POPFILE_ROOT}
  Call GetParent
  Pop ${L_POPFILE_ROOT}
  IfFileExists "${L_POPFILE_ROOT}\*.*" got_pf_folder
  MessageBox MB_OK|MB_ICONSTOP "Invalid POPFile folder path supplied"
  Goto error_exit

got_pf_folder:
  IfFileExists "${L_POPFILE_ROOT}\popfile.pl" pf_ok
  MessageBox MB_OK|MB_ICONSTOP "POPFile folder does not appear to contain POPFile files"
  Goto error_exit

pf_ok:
  ReadINIStr ${L_POPFILE_USER} ".\Wrapper.ini" "Configuration" "UserDataFolder"
  StrCmp ${L_POPFILE_USER} "" 0 got_ud_path

  ReadRegStr ${L_POPFILE_USER} HKLM "SOFTWARE\POPFile" InstallLocation
  StrCmp ${L_POPFILE_USER} "" 0 got_new_ud_path

  StrCpy ${L_POPFILE_USER} "C:\Program Files\POPFile"
  IfFileExists "${L_POPFILE_USER}\*.*" got_new_ud_path
  MessageBox MB_OK|MB_ICONSTOP "Unable to find User Data folder"
  Goto error_exit

got_new_ud_path:
  WriteINIStr ".\Wrapper.ini" "Configuration" "UserDataFolder" "${L_POPFILE_USER}"

got_ud_path:
  IfFileExists "${L_POPFILE_USER}\*.*" got_ud_folder
  Push ${L_POPFILE_USER}
  Call GetParent
  Pop ${L_POPFILE_USER}
  IfFileExists "${L_POPFILE_USER}\*.*" got_ud_folder
  MessageBox MB_OK|MB_ICONSTOP "Invalid User Data folder path supplied"
  Goto error_exit

got_ud_folder:
  GetFullPathName /SHORT ${L_POPFILE_ROOT} ${L_POPFILE_ROOT}
  GetFullPathName /SHORT ${L_POPFILE_USER} ${L_POPFILE_USER}
  StrCmp ${L_POPFILE_ROOT} ${L_POPFILE_USER} 0 lowercase
  StrCpy ${L_POPFILE_USER} "."

lowercase:
  Push ${L_POPFILE_ROOT}
  Call StrLower
  Pop ${L_POPFILE_ROOT}
  Push ${L_POPFILE_USER}
  Call StrLower
  Pop ${L_POPFILE_USER}

  WriteINIStr ".\Wrapper.ini" "Environment" "POPFILE_ROOT" "${L_POPFILE_ROOT}"
  WriteINIStr ".\Wrapper.ini" "Environment" "POPFILE_USER" "${L_POPFILE_USER}"

  System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("POPFILE_ROOT", "${L_POPFILE_ROOT}").r0'
  StrCmp $0 0 0 root_set_ok
  MessageBox MB_OK|MB_ICONSTOP "Can't set POPFILE_ROOT environment variable"
  Goto error_exit

root_set_ok:
  System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("POPFILE_USER", "${L_POPFILE_USER}").r0'
  StrCmp $0 0 0 user_set_ok
  MessageBox MB_OK|MB_ICONSTOP "Can't set POPFILE_USER environment variable"
  Goto error_exit

user_set_ok:
  !ifdef BACKGROUND
            SetOutPath "${L_POPFILE_ROOT}"
            Exec '"${L_POPFILE_ROOT}\wperl.exe" popfile.pl'
  !else ifdef FOREGROUND
            SetOutPath "${L_POPFILE_ROOT}"
            Exec '"${L_POPFILE_ROOT}\perl.exe" popfile.pl'
  !else
            StrCpy ${L_CONSOLE} "1"
            StrCpy ${L_DATA} ${L_POPFILE_USER}
            StrCmp ${L_POPFILE_USER} "." 0 open_config
            StrCpy ${L_DATA} ${L_POPFILE_ROOT}

      open_config:
            FileOpen  ${L_CFG} "${L_DATA}\popfile.cfg" r

      loop:
            FileRead   ${L_CFG} ${L_DATA}
            IfErrors done

            StrCpy ${L_CMPRE} ${L_DATA} 16
            StrCmp ${L_CMPRE} "windows_console " got_console
            Goto loop

      got_console:
            StrCpy ${L_CONSOLE} ${L_DATA} 1 16
            Goto loop

      done:
            FileClose ${L_CFG}
            StrCmp ${L_CONSOLE} "0" background
            SetOutPath "${L_POPFILE_ROOT}"
            Exec '"${L_POPFILE_ROOT}\perl.exe" popfile.pl'
            Goto Exit

      background:
            SetOutPath "${L_POPFILE_ROOT}"
            Exec '"${L_POPFILE_ROOT}\wperl.exe" popfile.pl'

      exit:
  !endif

error_exit:
  !undef L_CFG
  !undef L_CMPRE
  !undef L_CONSOLE
  !undef L_DATA
  !undef L_POPFILE_ROOT
  !undef L_POPFILE_USER
  !undef L_RESERVED

SectionEnd


#--------------------------------------------------------------------------
# Installer Function: GetParent
#
# This function extracts the parent directory from a given path.
#
# NB: The path is assumed to use backslashes (\)
#
# Inputs:
#         (top of stack)          - string containing a path (e.g. C:\A\B\C)
#
# Outputs:
#         (top of stack)          - the parent part of the input string (e.g. C:\A\B)
#
#  Usage Example:
#
#         Push "C:\Program Files\Directory\Whatever"
#         Call GetParent
#         Pop $R0
#
#         ($R0 at this point is ""C:\Program Files\Directory")
#
#--------------------------------------------------------------------------

Function GetParent
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


#--------------------------------------------------------------------------
# Function StrLower
#
# Converts uppercase letters in a string into lowercase letters. Other characters unchanged.
#
# Inputs:
#         (top of stack)          - input string
#
# Outputs:
#         (top of stack)          - output string
#
#  Usage Example:
#
#    Push "C:\PROGRA~1\SQLPFILE"
#    Call StrLower
#    Pop $R0
#
#   ($R0 at this point is "c:\progra~1\sqlpfile")
#
#--------------------------------------------------------------------------

Function StrLower

  !define C_LOWERCASE    "abcdefghijklmnopqrstuvwxyz"

  Exch $0   ; The input string
  Push $2   ; Holds the result
  Push $3   ; A character from the input string
  Push $4   ; The offset to a character in the "validity check" string
  Push $5   ; A character from the "validity check" string
  Push $6   ; Holds the current "validity check" string

  StrCpy $2 ""

next_input_char:
  StrCpy $3 $0 1              ; Get next character from the input string
  StrCmp $3 "" done
  StrCpy $6 ${C_LOWERCASE}$3  ; Add character to end of "validity check" to guarantee a match
  StrCpy $0 $0 "" 1
  StrCpy $4 -1

next_valid_char:
  IntOp $4 $4 + 1
  StrCpy $5 $6 1 $4               ; Extract next from "validity check" string
  StrCmp $3 $5 0 next_valid_char  ; We will ALWAYS find a match in the "validity check" string
  StrCpy $2 $2$5                  ; Use "validity check" char to ensure result uses lowercase 
  goto next_input_char

done:
  StrCpy $0 $2                ; Result is a string with no uppercase letters
  Pop $6
  Pop $5
  Pop $4
  Pop $3
  Pop $2
  Exch $0                     ; place result on top of the stack

  !undef C_LOWERCASE

FunctionEnd

;-------------
; end-of-file
;-------------
