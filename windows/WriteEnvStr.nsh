#--------------------------------------------------------------------------
#
# WriteEnvStr.nsh --- This file contains the environment manipulation functions
#                     used by 'installer.nsi' when installing/uninstalling the
#                     'Kakasi' package.
#
# Copyright (c) 2003-2004 John Graham-Cumming
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

  ;--------------------------------------------------------------------------
  ; Symbols used to avoid confusion over where the line breaks occur.
  ;
  ; ${IO_NL} is used for InstallOptions-style 'new line' sequences.
  ; ${MB_NL} is used for MessageBox-style 'new line' sequences.
  ;--------------------------------------------------------------------------

!ifndef IO_NL
  !define IO_NL     "\r\n"
!endif

!ifndef MB_NL
  !define MB_NL     "$\r$\n"
!endif

!ifndef ADDUSER & NO_KAKASI
    #--------------------------------------------------------------------------
    # Installer Function: WriteEnv
    #
    # Writes an environment variable which is available to the 'current user' on a modern OS.
    # On Win9x systems, AUTOEXEC.BAT is updated and the Reboot flag is set to request a reboot
    # to make the new variable available for use.
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

      ; Registers common to Win9x and non-Win9x processing

      !define ENV_NAME        $R9   ; name of the environment variable
      !define ENV_VALUE       $R8   ; value of the environment variable
      !define TEMP            $R7

      ; Registers used only for Win9x processing

      !define DESTN           $R6   ; used to access the revised AUTOEXEC.BAT file
      !define ENV_FOUND       $R5   ; 0 = variable not found, 1 = variable found in AUTOEXEC.BAT
      !define ENV_SETLEN      $R4   ; length of the string in ${ENV_SETNAME}
      !define ENV_SETNAME     $R3   ; left-hand side of SET command for the variable, incl '='
      !define LINE            $R2   ; a line from AUTOEXEC.BAT
      !define SOURCE          $R1   ; used to access original AUTOEXEC.BAT file
      !define TEMPFILE        $R0   ; name of file used to build the revised AUTOEXEC.BAT file

      Exch ${ENV_VALUE}
      Exch
      Exch ${ENV_NAME}
      Push ${TEMP}

      Call IsNT
      Pop ${TEMP}
      StrCmp ${TEMP} 1 WriteEnvStr_NT

      ; On Win9x system, so we add the new data to AUTOEXEC.BAT if it is not already there

      Push ${DESTN}
      Push ${ENV_FOUND}
      Push ${ENV_SETLEN}
      Push ${ENV_SETNAME}
      Push ${LINE}
      Push ${SOURCE}
      Push ${TEMPFILE}

      StrCpy ${ENV_SETNAME} "SET ${ENV_NAME}="
      StrLen ${ENV_SETLEN} ${ENV_SETNAME}

      StrCpy ${SOURCE} $WINDIR 2            ; Get the drive used for Windows (usually 'C:')
      FileOpen ${SOURCE} "${SOURCE}\autoexec.bat" r
      GetTempFileName ${TEMPFILE}
      FileOpen ${DESTN} ${TEMPFILE} w

      StrCpy ${ENV_FOUND} 0

    loop:
      FileRead ${SOURCE} ${LINE}            ; Read line from AUTOEXEC.BAT
      StrCmp ${LINE} "" eof_found
      Push ${LINE}
      Call TrimNewlines
      Pop ${LINE}
      StrCmp ${LINE} "" copy_line           ; Blank lines are preserved in the copy we make
      StrCpy ${TEMP} ${LINE} ${ENV_SETLEN}
      StrCmp ${TEMP} ${ENV_SETNAME} 0 copy_line
      StrCpy ${ENV_FOUND} 1                 ; Have found a match. Now check the value it defines.
      StrCpy ${TEMP} ${LINE} "" ${ENV_SETLEN}
      StrCmp ${TEMP} ${ENV_VALUE} 0 different_value
      ReadEnvStr ${TEMP} ${ENV_NAME}        ; Identical value found. Now see if it currently exists.
      StrCmp ${TEMP} ${ENV_VALUE} copy_line
      SetRebootFlag true                    ; Value does not exist, so we need to reboot

    copy_line:
      FileWrite ${DESTN} "${LINE}${MB_NL}"
      Goto loop

    different_value:
      FileWrite ${DESTN} "REM ${LINE}${MB_NL}"    ; 'Comment out' the incorrect value
      FileWrite ${DESTN} "${ENV_SETNAME}${ENV_VALUE}${MB_NL}"
      SetRebootFlag true
      Goto loop

    eof_found:
      StrCmp ${ENV_FOUND} 1 autoexec_done
      FileWrite ${DESTN} "${ENV_SETNAME}${ENV_VALUE}${MB_NL}"   ; Append line for the new variable
      SetRebootFlag true

    autoexec_done:
      FileClose ${SOURCE}
      FileClose ${DESTN}

      IfRebootFlag 0 win9x_done
      StrCpy ${SOURCE} $WINDIR 2
      Delete "${SOURCE}\autoexec.bat"
      CopyFiles /SILENT ${TEMPFILE} "${SOURCE}\autoexec.bat"
      Delete ${TEMPFILE}

    win9x_done:
      Pop ${TEMPFILE}
      Pop ${SOURCE}
      Pop ${LINE}
      Pop ${ENV_SETNAME}
      Pop ${ENV_SETLEN}
      Pop ${ENV_FOUND}
      Pop ${DESTN}
      Goto WriteEnvStr_done

      ; More modern OS case (AUTOEXEC.BAT not relevant)

    WriteEnvStr_NT:
      WriteRegExpandStr HKCU "Environment" ${ENV_NAME} ${ENV_VALUE}
      SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} \
            0 "STR:Environment" /TIMEOUT=5000

    WriteEnvStr_done:
      Pop ${TEMP}
      Pop ${ENV_NAME}
      Pop ${ENV_VALUE}

      !undef ENV_NAME
      !undef ENV_VALUE
      !undef TEMP

      !undef DESTN
      !undef ENV_FOUND
      !undef ENV_SETLEN
      !undef ENV_SETNAME
      !undef LINE
      !undef SOURCE
      !undef TEMPFILE

    FunctionEnd


    #--------------------------------------------------------------------------
    # Installer Function: WriteEnvNTAU
    #
    # Writes an environment variable which is available to all users on a modern OS.
    # On Win9x systems, AUTOEXEC.BAT is updated and the Reboot flag is set to request a reboot
    # to make the new variable available for use.
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
    #         Call WriteEnvStrNTAU
    #
    #--------------------------------------------------------------------------

    Function WriteEnvStrNTAU

      ; Registers common to Win9x and non-Win9x processing

      !define ENV_NAME        $R9   ; name of the environment variable
      !define ENV_VALUE       $R8   ; value of the environment variable
      !define TEMP            $R7

      ; Registers used only for Win9x processing

      !define DESTN           $R6   ; used to access the revised AUTOEXEC.BAT file
      !define ENV_FOUND       $R5   ; 0 = variable not found, 1 = variable found in AUTOEXEC.BAT
      !define ENV_SETLEN      $R4   ; length of the string in ${ENV_SETNAME}
      !define ENV_SETNAME     $R3   ; left-hand side of SET command for the variable, incl '='
      !define LINE            $R2   ; a line from AUTOEXEC.BAT
      !define SOURCE          $R1   ; used to access original AUTOEXEC.BAT file
      !define TEMPFILE        $R0   ; name of file used to build the revised AUTOEXEC.BAT file

      Exch ${ENV_VALUE}
      Exch
      Exch ${ENV_NAME}
      Push ${TEMP}

      Call IsNT
      Pop ${TEMP}
      StrCmp ${TEMP} 1 WriteEnvStr_NT

      ; On Win9x system, so we add the new data to AUTOEXEC.BAT if it is not already there

      Push ${DESTN}
      Push ${ENV_FOUND}
      Push ${ENV_SETLEN}
      Push ${ENV_SETNAME}
      Push ${LINE}
      Push ${SOURCE}
      Push ${TEMPFILE}

      StrCpy ${ENV_SETNAME} "SET ${ENV_NAME}="
      StrLen ${ENV_SETLEN} ${ENV_SETNAME}

      StrCpy ${SOURCE} $WINDIR 2            ; Get the drive used for Windows (usually 'C:')
      FileOpen ${SOURCE} "${SOURCE}\autoexec.bat" r
      GetTempFileName ${TEMPFILE}
      FileOpen ${DESTN} ${TEMPFILE} w

      StrCpy ${ENV_FOUND} 0

    loop:
      FileRead ${SOURCE} ${LINE}            ; Read line from AUTOEXEC.BAT
      StrCmp ${LINE} "" eof_found
      Push ${LINE}
      Call TrimNewlines
      Pop ${LINE}
      StrCmp ${LINE} "" copy_line           ; Blank lines are preserved in the copy we make
      StrCpy ${TEMP} ${LINE} ${ENV_SETLEN}
      StrCmp ${TEMP} ${ENV_SETNAME} 0 copy_line
      StrCpy ${ENV_FOUND} 1                 ; Have found a match. Now check the value it defines.
      StrCpy ${TEMP} ${LINE} "" ${ENV_SETLEN}
      StrCmp ${TEMP} ${ENV_VALUE} 0 different_value
      ReadEnvStr ${TEMP} ${ENV_NAME}        ; Identical value found. Now see if it currently exists.
      StrCmp ${TEMP} ${ENV_VALUE} copy_line
      SetRebootFlag true                    ; Value does not exist, so we need to reboot

    copy_line:
      FileWrite ${DESTN} "${LINE}${MB_NL}"
      Goto loop

    different_value:
      FileWrite ${DESTN} "REM ${LINE}${MB_NL}"    ; 'Comment out' the incorrect value
      FileWrite ${DESTN} "${ENV_SETNAME}${ENV_VALUE}${MB_NL}"
      SetRebootFlag true
      Goto loop

    eof_found:
      StrCmp ${ENV_FOUND} 1 autoexec_done
      FileWrite ${DESTN} "${ENV_SETNAME}${ENV_VALUE}${MB_NL}"   ; Append line for the new variable
      SetRebootFlag true

    autoexec_done:
      FileClose ${SOURCE}
      FileClose ${DESTN}

      IfRebootFlag 0 win9x_done
      StrCpy ${SOURCE} $WINDIR 2
      Delete "${SOURCE}\autoexec.bat"
      CopyFiles /SILENT ${TEMPFILE} "${SOURCE}\autoexec.bat"
      Delete ${TEMPFILE}

    win9x_done:
      Pop ${TEMPFILE}
      Pop ${SOURCE}
      Pop ${LINE}
      Pop ${ENV_SETNAME}
      Pop ${ENV_SETLEN}
      Pop ${ENV_FOUND}
      Pop ${DESTN}
      Goto WriteEnvStr_done

      ; More modern OS case (AUTOEXEC.BAT not relevant)

    WriteEnvStr_NT:
      WriteRegExpandStr HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" \
            ${ENV_NAME} ${ENV_VALUE}
      SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} \
            0 "STR:Environment" /TIMEOUT=5000

    WriteEnvStr_done:
      Pop ${TEMP}
      Pop ${ENV_NAME}
      Pop ${ENV_VALUE}

      !undef ENV_NAME
      !undef ENV_VALUE
      !undef TEMP

      !undef DESTN
      !undef ENV_FOUND
      !undef ENV_SETLEN
      !undef ENV_SETNAME
      !undef LINE
      !undef SOURCE
      !undef TEMPFILE

    FunctionEnd
!endif

!ifndef ADDUSER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.DeleteEnvStr
    #
    # Removes an environment variable defined for the current user on a modern OS.
    # On Win9x systems, AUTOEXEC.BAT is updated and the Reboot flag is set to request a reboot.
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
      StrCmp $3 "${MB_NL}" DeleteEnvStr_dosLoop

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
      DeleteRegValue HKCU "Environment" $0
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


    #--------------------------------------------------------------------------
    # Uninstaller Function: un.DeleteEnvStrNTAU
    #
    # Removes an environment variable defined for all users on a modern OS.
    # On Win9x systems, AUTOEXEC.BAT is updated and the Reboot flag is set to request a reboot.
    #
    # Inputs:
    #         (top of stack)       - name of the environment variable to be removed
    #
    # Outputs:
    #         none
    #
    # Usage:
    #         Push "HOMEDIR"
    #         Call un.DeleteEnvStrNTAU
    #
    #--------------------------------------------------------------------------

    Function un.DeleteEnvStrNTAU
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
      StrCmp $3 "${MB_NL}" DeleteEnvStr_dosLoop

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
      DeleteRegValue HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" $0
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
!endif

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
#         (top of stack)   - 0 (running on Win9x system) or 1 (running on a more modern OS)
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
