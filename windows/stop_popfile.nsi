#-------------------------------------------------------------------------------------------
#
# stop_popfile.nsi --- A simple 'command-line' utility to shutdown POPFile silently.
#
#                      One parameter is required: the port number used to access the
#                      POPFile User Interface (the UI port number, in range 1 to 65535).
#
#                      Returns error code 0 if shutdown was successful (otherwise returns 1)
#
#                      If an invalid parameter is given (eg 131072), an error is returned.
#                      If no parameter is supplied, the usage information is displayed.
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
#-------------------------------------------------------------------------------------------
#
# An example of a simple batch file to shut down POPFile using the default port:
#
#             STOP_PF.EXE 8080
#
# A batch file which checks the error code after trying to shutdown POPFile using port 9090:
#
#           @ECHO OFF
#           START /W STOP_PF 9090
#           IF ERRORLEVEL 1 GOTO FAILED
#           ECHO Shutdown succeeded
#           GOTO DONE
#           :FAILED
#           ECHO **** Shutdown failed ****
#           :DONE
#
# The '/W' parameter is important, otherwise the 'failed' case will not be detected.
#-------------------------------------------------------------------------------------------
#  This version was tested using NSIS 2.0b4 (CVS) with the 27 August 2003 (19:44 GMT) update
#-------------------------------------------------------------------------------------------

  ; The default NSIS caption is "Name Setup" so we override it here

  Name    "POPFile Silent Shutdown Utility"
  Caption "POPFile Silent Shutdown Utility"

  !define VERSION   "0.3.0"       ; see 'VIProductVersion' comment below for format details

  ; Specify EXE filename and icon for the 'installer'

  OutFile stop_pf.exe

  Icon "shutdown.ico"

  ; Selecting 'silent' mode makes the installer behave like a command-line utility

  SilentInstall silent

#--------------------------------------------------------------------------

  ; 'VIProductVersion' format is X.X.X.X where X is a number in range 0 to 65535
  ; representing the following values: Major.Minor.Release.Build

  VIProductVersion "${VERSION}.1"

  VIAddVersionKey "ProductName" "POPFile Silent Shutdown Utility - stops POPFile without \
                  opening a browser window."
  VIAddVersionKey "Comments" "POPFile Homepage: http://popfile.sourceforge.net"
  VIAddVersionKey "CompanyName" "The POPFile Project"
  VIAddVersionKey "LegalCopyright" "© 2001-2003  John Graham-Cumming"
  VIAddVersionKey "FileDescription" "POPFile Silent Shutdown Utility"
  VIAddVersionKey "FileVersion" "${VERSION}"

  VIAddVersionKey "Build Date/Time" "${__DATE__} @ ${__TIME__}"
  VIAddVersionKey "Build Script" "${__FILE__}$\r$\n(${__TIMESTAMP__})"

#----------------------------------------------------------------------------------------

;-------------------
; Section: Shutdown
;-------------------

Section Shutdown
  !define L_GUI  $R9

  ; Create the plugins directory (it will be deleted automatically when we exit)

  InitPluginsDir

  ; Check if any command-line parameter was supplied

  Call GetParameters
  Pop ${L_GUI}
  StrCmp ${L_GUI} "" 0 check_port
  MessageBox MB_OK "POPFile Silent Shutdown Utility v${VERSION}      \
      Copyright (c) 2001-2003 John Graham-Cumming\
      $\r$\n$\r$\n\
      This utility shuts POPFile down silently, without opening a browser window.\
      $\r$\n$\r$\n\
      Usage:    STOP_PF <PORT>\
      $\r$\n$\r$\n\
      where <PORT> is the port number used to access the POPFile User Interface (normally 8080)\
      $\r$\n$\r$\n\
      A success/fail error code is returned which can be checked in a batch file:\
      $\r$\n\
      $\r$\n          @ECHO OFF\
      $\r$\n          START /W STOP_PF 8080\
      $\r$\n          IF ERRORLEVEL 1 GOTO FAILED\
      $\r$\n          ECHO Shutdown succeeded\
      $\r$\n          GOTO DONE\
      $\r$\n          :FAILED\
      $\r$\n          ECHO **** Shutdown failed ****\
      $\r$\n          :DONE\
      $\r$\n$\r$\n\
      Distributed under the terms of the GNU General Public License (GPL).\
      "
  Goto ok

check_port:

  ; Valid port numbers are in the range 1 to 65535 inclusive

  Push ${L_GUI}
  Call StrCheckDecimal
  Pop ${L_GUI}
  StrCmp ${L_GUI} "" port_error
  IntCmp ${L_GUI} 0 port_error port_error
  IntCmp ${L_GUI} 65535 0 0 port_error

  ; Attempt to shutdown POPFile silently (nothing is displayed, no browser window is opened)

  NSISdl::download_quiet http://127.0.0.1:${L_GUI}/shutdown "$PLUGINSDIR\shutdown.htm"
  Pop ${L_GUI}
  StrCmp ${L_GUI} "success" ok

port_error:
  Abort                         ; Return error code 1 (failure)

ok:                             ; Return error code 0 (success)
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
# General Purpose Library Function: StrCheckDecimal
#--------------------------------------------------------------------------
#
# This function checks that a given string contains only the digits 0 to 9
# (if the string contains any invalid characters, "" is returned)
#
# Inputs:
#         (top of stack)   - string which may contain a decimal number
#
# Outputs:
#         (top of stack)   - the input string (if valid) or "" (if invalid)
#
#  Usage:
#         Push "12345"
#         Call StrCheckDecimal
#         Pop $R0
#
#         ($R0 at this point is "12345")
#
#--------------------------------------------------------------------------

Function StrCheckDecimal

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

;-------------
; end-of-file
;-------------
