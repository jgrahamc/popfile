#--------------------------------------------------------------------------
#
# WriteEnvStr.nsh --- This file contains the environment manipulation functions
#                     used by 'installer.nsi' when installing/uninstalling the
#                     'Kakasi' package.
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

  !include WinMessages.nsh

  !ifdef ALL_USERS
    !define WriteEnvStr_RegKey \
       'HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"'
  !else
    !define WriteEnvStr_RegKey 'HKCU "Environment"'
  !endif


#--------------------------------------------------------------------------
# Installer Function: WriteEnv
#
# Writes an environment variable. On Win9x systems, AUTOEXEC.BAT is updated
# and the Reboot flag is set to request a reboot to make the new variable
# available for use.
#
# Inputs:
#         (top of stack)       - value for the new environment variable
#         (top of stack - 1)   - name of the new environment variable
#
# Outputs:
#         none
#
# Usage:
#         Push "HOMEDIR"
#         Push "C:\New Home Dir"
#         Call WriteEnvStr
#
#--------------------------------------------------------------------------

Function WriteEnvStr
  Exch $1    ; $1 has environment variable value
  Exch
  Exch $0    ; $0 has environment variable name
  Push $2
  Push $3

  Call IsNT
  Pop $2
  StrCmp $2 1 WriteEnvStr_NT

  ; On Win9x system, so we append the new data to AUTOEXEC.BAT

  StrCpy $2 $WINDIR 2                 ; Copy drive of windows (c:)
  FileOpen $2 "$2\autoexec.bat" a
  FileSeek $2 -2 END
  FileRead $2 $3
  FileSeek $2 0 END
  StrCmp $3 "$\r$\n" eof_ok
  FileWrite $2 "$\r$\n"               ; file did not end with CRLF so we append CRLF

eof_ok:
  FileWrite $2 "SET $0=$1$\r$\n"
  FileClose $2
  SetRebootFlag true
  Goto WriteEnvStr_done

  ; More modern OS case (AUTOEXEC.BAT not relevant)

WriteEnvStr_NT:
  WriteRegExpandStr ${WriteEnvStr_RegKey} $0 $1
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} \
        0 "STR:Environment" /TIMEOUT=5000

WriteEnvStr_done:
  Pop $3
  Pop $2
  Pop $1
  Pop $0
FunctionEnd


#--------------------------------------------------------------------------
# Uninstaller Function: un.DeleteEnvStr
#
# Removes an environment variable. On Win9x systems, AUTOEXEC.BAT is updated
# and the Reboot flag is set to request a reboot.
#
# Inputs:
#         (top of stack)       - name of the environment variable to be removed
#
# Outputs:
#         none
#
# Usage:
#         Push "HOMEDIR"
#         Call un.DeleteEnvStr
#
#--------------------------------------------------------------------------

Function un.DeleteEnvStr
  Exch $0       ; $0 now has the name of the variable
  Push $1
  Push $2
  Push $3
  Push $4
  Push $5

  Call un.IsNT
  Pop $1
  StrCmp $1 1 DeleteEnvStr_NT

  ; On Win9x system, so we have to update AUTOEXEC.BAT

  StrCpy $1 $WINDIR 2
  FileOpen $1 "$1\autoexec.bat" r
  GetTempFileName $4
  FileOpen $2 $4 w
  StrCpy $0 "SET $0="
  SetRebootFlag true

DeleteEnvStr_dosLoop:
  FileRead $1 $3
  StrLen $5 $0
  StrCpy $5 $3 $5
  StrCmp $5 $0 0 no_match

  ; Have found the line which defines the environment variable, so we do not copy it
  ; and we also ignore the following line if it is just a CRLF sequence

  FileRead $1 $3
  StrCmp $3 "$\r$\n" DeleteEnvStr_dosLoop

no_match:
  StrCmp $5 "" DeleteEnvStr_dosLoopEnd
  FileWrite $2 $3
  Goto DeleteEnvStr_dosLoop

DeleteEnvStr_dosLoopEnd:
  FileClose $2
  FileClose $1
  StrCpy $1 $WINDIR 2
  Delete "$1\autoexec.bat"
  CopyFiles /SILENT $4 "$1\autoexec.bat"
  Delete $4
  Goto DeleteEnvStr_done

  ; More modern OS case (AUTOEXEC.BAT not relevant)

DeleteEnvStr_NT:
  DeleteRegValue ${WriteEnvStr_RegKey} $0
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} \
      0 "STR:Environment" /TIMEOUT=5000

DeleteEnvStr_done:
  Pop $5
  Pop $4
  Pop $3
  Pop $2
  Pop $1
  Pop $0
FunctionEnd


#==============================================================================================
#
# Macro-based Functions used by the installer and by the uninstaller
#
#==============================================================================================

#--------------------------------------------------------------------------
# Macro: IsNT
#
# The installation process and the uninstall process both use a function which checks if
# the installer is running on a Win9x system or a more modern OS. This macro makes maintenance
# easier by ensuring that both processes use identical functions, with the only difference
# being their names.
#
# Returns 0 if running on a Win9x system, otherwise returns 1
#
# NOTE:
# The !insertmacro IsNT "" and !insertmacro IsNT "un." commands are included in this file so
# 'installer.nsi' can use 'Call IsNT' and 'Call un.IsNT' without additional preparation.
#
# Inputs:
#         None
#
# Outputs:
#         (top of stack)   - the input string (if valid) or "" (if invalid)
#
#  Usage (after macro has been 'inserted'):
#
#         Call un.IsNT
#         Pop $R0
#
#         ($R0 at this point is 0 if installer is running on a Win9x system)
#
#--------------------------------------------------------------------------

!macro IsNT UN
  Function ${UN}IsNT
    Push $0
    ReadRegStr $0 HKLM \
      "SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion
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
!macroend

#--------------------------------------------------------------------------
# Installer Function: IsNT
#
# This function is used during the installation process
#--------------------------------------------------------------------------

!insertmacro IsNT ""

#--------------------------------------------------------------------------
# Uninstaller Function: un.IsNT
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

!insertmacro IsNT "un."

#--------------------------------------------------------------------------
# End of 'WriteEnvStr.nsh'
#--------------------------------------------------------------------------
