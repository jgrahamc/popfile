#-------------------------------------------------------------------------------------------
#
# stop_popfile.nsi --- A simple 'command-line' utility to shutdown POPFile silently.
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
#-------------------------------------------------------------------------------------------
# Usage (one mandatory parameter, two optional parameters):
#
#        STOP_PF [REPORT] PORT [PASSWORD]
#
# One parameter is required: the PORT number used to access the POPFile User Interface
# (the UI port number, in range 1 to 65535).
#
# Returns error code 0 if shutdown was successful (otherwise returns 1)
#
# If an invalid parameter is given (eg 131072), an error is returned.
#
# If no parameters are supplied, or if only '/?' or '/HELP' is supplied, the copyright and
# usage information is displayed.
#
# There are two optional parameters:
#
# (a) 'REPORT' is the first optional parameter and selects the reporting mode:
#
# /SHOWERRORS, /SHOWALL or /SHOWNONE. (/SHOWNONE is used as the default if no mode is supplied)
#
# If '/SHOWERRORS' is specified then a message will be shown if any errors were detected
# (nothing is displayed if the shutdown was successful).
#
# If '/SHOWALL' is specified then a success/fail message will always be shown.
#
# If '/SHOWNONE' is specified then no messages are displayed.
#
# Uppercase or lowercase can be used for this optional parameter.
# If this optional parameter is used, it must be the first parameter.
#
# (b) 'PASSWORD' is the second optional parameter and supplies the POPFile UI password.
#
# If the POPFile UI is protected by a password, the correct password must be supplied otherwise
# the shutdown request will be ignored.
#
# The password parameter is case sensitive and must be the last parameter on the command-line.
#
# This version of the utility uses spaces to separate parameters so the password cannot include
# any spaces (quotes cannot be used to enclose a password containing spaces)
#
#-------------------------------------------------------------------------------------------
#
# An example of a simple batch file to shut down POPFile using the default port using the
# password 'fred' (if any errors are detected, a message box will be displayed):
#
#             STOP_PF.EXE /SHOWERRORS 8080 fred
#
# A batch file which checks the error code after trying to shutdown POPFile using port 9090
# with the UI password set to 'Let_Me_In':
#
#           @ECHO OFF
#           START /WAIT STOP_PF 9090 Let_Me_In
#           IF ERRORLEVEL 1 GOTO FAILED
#           ECHO Shutdown succeeded
#           GOTO DONE
#           :FAILED
#           ECHO **** Shutdown failed ****
#           :DONE
#
# The '/WAIT' parameter is important, otherwise the 'failed' case will not be detected.
#-------------------------------------------------------------------------------------------
#  This version was tested using "NSIS 2 Release Candidate 2" released 5 January 2004
#-------------------------------------------------------------------------------------------

  ; The default NSIS caption is "Name Setup" so we override it here

  Name    "POPFile Silent Shutdown Utility"
  Caption "POPFile Silent Shutdown Utility"

  !define C_VERSION   "0.5.7"       ; see 'VIProductVersion' comment below for format details

  ; Specify EXE filename and icon for the 'installer'

  OutFile stop_pf.exe

  Icon "shutdown.ico"

  ; Selecting 'silent' mode makes the installer behave like a command-line utility

  SilentInstall silent

  ;-------------------------------------------------------------------------------
  ; Time delay constants used in conjunction with the NSISdl plugin
  ;-------------------------------------------------------------------------------

  ; Override the default timeout for NSISdl requests (specifies timeout in milliseconds)

  !define C_DLTIMEOUT                /TIMEOUT=10000

  ; Delay between the two shutdown requests (in milliseconds)

  !define C_DLGAP                    2000

#--------------------------------------------------------------------------

  ; 'VIProductVersion' format is X.X.X.X where X is a number in range 0 to 65535
  ; representing the following values: Major.Minor.Release.Build

  VIProductVersion                   "${C_VERSION}.1"

  VIAddVersionKey "ProductName"      "POPFile Silent Shutdown Utility - stops POPFile without \
                                     opening a browser window."
  VIAddVersionKey "Comments"         "POPFile Homepage: http://popfile.sourceforge.net"
  VIAddVersionKey "CompanyName"      "The POPFile Project"
  VIAddVersionKey "LegalCopyright"   "Copyright (c) 2004  John Graham-Cumming"
  VIAddVersionKey "FileDescription"  "POPFile Silent Shutdown Utility"
  VIAddVersionKey "FileVersion"      "${C_VERSION}"

  VIAddVersionKey "Build Date/Time"  "${__DATE__} @ ${__TIME__}"
  VIAddVersionKey "Build Script"     "${__FILE__}$\r$\n(${__TIMESTAMP__})"

#----------------------------------------------------------------------------------------

#--------------------------------------------------------------------------
# Include private library functions and macro definitions
#--------------------------------------------------------------------------

  ; Avoid compiler warnings by disabling the functions and definitions we do not use

  !define STOP_POPFILE

  !include "pfi-library.nsh"

;-------------------
; Section: Shutdown
;-------------------

Section Shutdown
  !define L_GUI      $R9   ; holds POPFile User Interface (UI) port number
  !define L_PARAMS   $R8   ; parameter(s) extracted from the command-line
  !define L_PASSWORD $R7   ; password to be used for the POPFile UI
  !define L_REPORT   $R6   ; 'none' = no msgs, 'errors' = only errors, 'all' = errors & success
  !define L_RESULT   $R5   ; the status returned from the shutdown request
  !define L_TEMP     $R4

  StrCpy ${L_REPORT} "none"        ; default is to display no success or failure messages

  ; It does not matter if the first command-line parameter uses uppercase or lowercase

  Call GetParameters
  Pop ${L_PARAMS}
  StrCmp ${L_PARAMS} "" usage
  StrCmp ${L_PARAMS} "/?" usage
  StrCmp ${L_PARAMS} "/help" usage

  Push ${L_PARAMS}                            ; Command-line may have more than one parameter
  Call GetNextParam
  Pop ${L_PARAMS}                             ; rest of the command-line
  Pop ${L_RESULT}                             ; first parameter from command-line
  StrCmp ${L_RESULT} "" usage

  ; If the first parameter starts with a digit, assume it is the PORT parameter
  ; and use the default REPORT mode (no messages displayed)

  StrCpy ${L_TEMP} ${L_RESULT} 1
  Push ${L_TEMP}
  Call StrCheckDecimal
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" 0 port_checks
  StrCmp ${L_RESULT} "/showerrors" only_errors
  StrCmp ${L_RESULT} "/showall" all_cases
  StrCmp ${L_RESULT} "/shownone" no_messages
  StrCmp ${L_RESULT} "/?" usage
  StrCmp ${L_RESULT} "/help" usage
  Goto option_error

usage:
  MessageBox MB_OK "POPFile Silent Shutdown Utility v${C_VERSION}            \
    Copyright (c) 2004  John Graham-Cumming\
    $\r$\n$\r$\n\
    This command-line utility shuts POPFile down silently, without opening a browser window.\
    $\r$\n$\r$\n\
    Usage:    STOP_PF  [ <REPORT> ]  <PORT> [ <PASSWORD> ]\
    $\r$\n$\r$\n\
    where <PORT> is the port number used to access the POPFile User Interface (normally 8080).\
    $\r$\n$\r$\n\
    The optional <PASSWORD> is the password (no spaces allowed) for the POPFile User Interface.\
    $\r$\n$\r$\n\
    The optional <REPORT> is /SHOWERRORS (only error messages shown), /SHOWALL\
    $\r$\n\
    (success or error messages always shown), or /SHOWNONE (no messages - this is the default).\
    $\r$\n$\r$\n\
    A success/fail error code is always returned which can be checked in a batch file:\
    $\r$\n\
    $\r$\n          @ECHO OFF\
    $\r$\n          START /WAIT STOP_PF 8080 Let_Me_In\
    $\r$\n          IF ERRORLEVEL 1 GOTO FAILED\
    $\r$\n          ECHO Shutdown succeeded\
    $\r$\n          GOTO DONE\
    $\r$\n          :FAILED\
    $\r$\n          ECHO **** Shutdown failed ****\
    $\r$\n          :DONE\
    $\r$\n$\r$\n\
    Distributed under the terms of the GNU General Public License (GPL)."
  Goto error_exit

no_messages:
  StrCpy ${L_REPORT} "none"
  Goto other_param

only_errors:
  StrCpy ${L_REPORT} "errors"
  Goto other_param

all_cases:
  StrCpy ${L_REPORT} "all"

other_param:
  Push ${L_PARAMS}
  Call GetNextParam
  Pop ${L_PARAMS}
  Pop ${L_RESULT}               ; the second parameter from the command-line

port_checks:
  StrCmp ${L_RESULT} "" no_port_supplied
  Push ${L_RESULT}
  Call StrCheckDecimal
  Pop ${L_GUI}
  StrCmp ${L_GUI} "" integer_error
  IntCmp ${L_GUI} 0 port_error port_error
  IntCmp ${L_GUI} 65535 0 0 port_error

  ; Create the plugins directory (it will be deleted automatically when we exit)

  InitPluginsDir

  ; Password is assumed to be a single word without any spaces

  Push ${L_PARAMS}
  Call GetNextParam
  Pop ${L_PARAMS}
  Pop ${L_PASSWORD}             ; the next parameter from the command-line

  StrCmp ${L_PASSWORD} "" no_password_supplied

  ; Attempt to shutdown POPFile silently (nothing is displayed, no browser window is opened)
  ; If first attempt appears to succeed, we must try again to check if POPFile has shutdown
  ; (we cannot tell the difference between 'shutdown' and 'incorrect password' responses)

  NSISdl::download_quiet ${C_DLTIMEOUT} http://${C_UI_URL}:${L_GUI}/password?password=${L_PASSWORD}&redirect=/shutdown? "$PLUGINSDIR\shutdown_1.htm"
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "success" try_password_again
  StrCmp ${L_REPORT} "none" error_exit
  MessageBox MB_OK|MB_ICONEXCLAMATION \
      "Silent shutdown with password using port '${L_GUI}' failed\
      $\r$\n\
      (error: ${L_RESULT})"
  Goto error_exit

try_password_again:
  Sleep ${C_DLGAP}
  NSISdl::download_quiet ${C_DLTIMEOUT} http://${C_UI_URL}:${L_GUI}/password?password=${L_PASSWORD}&redirect=/shutdown? "$PLUGINSDIR\shutdown_2.htm"
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "success" 0 password_ok
  Push "$PLUGINSDIR\shutdown_2.htm"
  Call GetFileSize
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} 0 password_ok
  StrCmp ${L_REPORT} "none" error_exit
  MessageBox MB_OK|MB_ICONEXCLAMATION \
      "Silent shutdown with password using port '${L_GUI}' failed\
      $\r$\n\
      (error: wrong UI password supplied ?)"
  Goto error_exit

password_ok:                             ; Return error code 0 (success)
  StrCmp ${L_REPORT} "none" exit
  StrCmp ${L_REPORT} "errors" exit
  MessageBox MB_OK|MB_ICONINFORMATION \
      "Silent shutdown with password OK\
      $\r$\n\
      (port '${L_GUI}' used)"
  Goto exit

no_password_supplied:

  ; Attempt to shutdown POPFile silently (nothing is displayed, no browser window is opened)
  ; If first attempt appears to succeed, we must try again to check if POPFile has shutdown
  ; (we cannot tell the difference between 'shutdown' and 'enter password' responses)

  NSISdl::download_quiet ${C_DLTIMEOUT} http://${C_UI_URL}:${L_GUI}/shutdown "$PLUGINSDIR\shutdown_1.htm"
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "success" try_again
  StrCmp ${L_REPORT} "none" error_exit
  MessageBox MB_OK|MB_ICONEXCLAMATION \
      "Silent shutdown using port '${L_GUI}' failed\
      $\r$\n\
      (error: ${L_RESULT})"
  Goto error_exit

try_again:
  Sleep ${C_DLGAP}
  NSISdl::download_quiet ${C_DLTIMEOUT} http://${C_UI_URL}:${L_GUI}/shutdown "$PLUGINSDIR\shutdown_2.htm"
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "success" 0 shutdown_ok
  Push "$PLUGINSDIR\shutdown_2.htm"
  Call GetFileSize
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} 0 shutdown_ok
  StrCmp ${L_REPORT} "none" error_exit
  MessageBox MB_OK|MB_ICONEXCLAMATION \
      "Silent shutdown using port '${L_GUI}' failed\
      $\r$\n\
      (error: UI may be password protected ?)"
  Goto error_exit

no_port_supplied:
  StrCmp ${L_REPORT} "none" error_exit
  MessageBox MB_OK|MB_ICONEXCLAMATION "No UI port was supplied"
  Goto error_exit

integer_error:
  StrCmp ${L_REPORT} "none" error_exit
  MessageBox MB_OK|MB_ICONEXCLAMATION "Port number '${L_RESULT}' should only contain the \
      digits 0 to 9"
  Goto error_exit

port_error:
  StrCmp ${L_REPORT} "none" error_exit
  MessageBox MB_OK|MB_ICONEXCLAMATION "Port number '${L_GUI}' is not in range 1 to 65535"
  Goto error_exit

option_error:
  MessageBox MB_OK|MB_ICONEXCLAMATION "Unknown option supplied$\r$\n(${L_RESULT})"

error_exit:
  Abort                                  ; Return error code 1 (failure)

shutdown_ok:                             ; Return error code 0 (success)
  StrCmp ${L_REPORT} "none" exit
  StrCmp ${L_REPORT} "errors" exit
  MessageBox MB_OK|MB_ICONINFORMATION \
      "Silent shutdown OK\
      $\r$\n\
      (port '${L_GUI}' used)"

exit:
  !undef L_GUI
  !undef L_PARAMS
  !undef L_PASSWORD
  !undef L_REPORT
  !undef L_RESULT
  !undef L_TEMP
SectionEnd


#--------------------------------------------------------------------------
# General Purpose Library Function: GetNextParam
#--------------------------------------------------------------------------
#
# Extracts the next parameter (if any) from a list of space-separated parameters
#
# Inputs:
#         (top of stack)       - a list of parameters separated by spaces (list may be empty)
#
# Outputs:
#         (top of stack)       - the remaining parameters (if any)
#         (top of stack - 1)   - the first parameter found in the list
#
# Usage:
#         Push "ABC 123 XYZ"
#         Call GetNextParam
#         Pop $R0
#         Pop $R1
#
#         ($R0 at this point is "123 XYZ")
#         ($R1 at this point is "ABC")
#
#--------------------------------------------------------------------------

Function GetNextParam

  !define L_CHAR      $R9                     ; a character from the input list
  !define L_LIST      $R8                     ; input list of parameters (may be empty)
  !define L_PARAM     $R7                     ; the first parameter found

  Exch ${L_LIST}
  Push ${L_PARAM}
  Push ${L_CHAR}

  StrCpy ${L_PARAM} ""

loop_L:
  StrCpy ${L_CHAR} ${L_LIST} 1                ; get next char from input list
  StrCmp ${L_CHAR} "" done
  StrCpy ${L_LIST} ${L_LIST} "" 1             ; remove char from input list
  StrCmp ${L_CHAR} " " loop_L

loop_P:
  StrCpy ${L_PARAM} ${L_PARAM}${L_CHAR}
  StrCpy ${L_CHAR} ${L_LIST} 1                ; get next char from input list
  StrCmp ${L_CHAR} "" done
  StrCpy ${L_LIST} ${L_LIST} "" 1
  StrCmp ${L_CHAR} " " 0 loop_P               ; loop until a space is found

loop_T:
  StrCpy ${L_CHAR} ${L_LIST} 1                ; get next char from input list
  StrCmp ${L_CHAR} "" done
  StrCmp ${L_CHAR} " " 0 done
  StrCpy ${L_LIST} ${L_LIST} "" 1             ; remove trailing spaces
  Goto loop_T

done:
  Pop ${L_CHAR}
  Exch ${L_PARAM}                             ; put parameter on stack (may be "")
  Exch
  Exch ${L_LIST}                              ; put revised list on stack (may be "")

  !undef L_CHAR
  !undef L_LIST
  !undef L_PARAM

FunctionEnd

;-------------
; end-of-file
;-------------
