#--------------------------------------------------------------------------
#
# msgcapture.nsi --- This NSIS script is used to create a simple utility which displays
#                    the POPFile console messages and makes it easy to copy them to the
#                    clipboard (so they can be saved in a text file). This utility avoids
#                    the need to display the console window (when the console window was
#                    used by earlier installers it caused confusion amongst some users).
#
# Copyright (c) 2004  John Graham-Cumming
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
; released 7 February 2004, with no "official" NSIS patches/CVS updates applied.

#--------------------------------------------------------------------------
# Support provided for this utility by the Windows installer
#--------------------------------------------------------------------------
#
# Starting with POPFile 0.22.0 the Windows version of POPFile installs this utility in the
# main POPFile program folder where it can be used to start POPFile (instead of the normal
# Start Menu shortcuts). This provides a simple way to run POPFile in console mode without
# changing the POPFile configuration file (e.g. if some debugging is required).
#
# If required, the Windows version of POPFile can be configured to run this utility whenever
# 'console mode' is selected. This means the UI can be used to enable/disable this utility
# (by enabling/disabling 'console mode').
#
# To activate this feature, simply rename the file 'msgcapture.exe' as 'pfimsgcapture.exe'
# (or make a copy of it and call the copy 'pfimsgcapture.exe') then start POPFile using a
# shortcut created by the installer or by running 'runpopfile.exe' (found in the main POPFile
# program folder).
#
# To return to using a DOS-box when console mode is selected, rename the 'pfimsgcapture.exe'
# program as 'msgcapture.exe' (or delete 'pfimsgcapture.exe' if you created it by renaming a
# copy of 'msgcapture.exe').
#
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
# Optional run-time command-line switch (used by 'msgcapture.exe')
#--------------------------------------------------------------------------
#
# /TIMEOUT=xx
#
# By default the utility waits for POPFile to terminate (via a normal shutdown, a crash or
# other termination of the process). This command-line switch is used to specify a timeout
# delay (in seconds) after which this utility will exit (without stopping POPFile).
#
# Valid timeouts are in the range 1 to 99 secs (for this version).
#
# If /TIMEOUT=0 is specified then the utility will wait until POPFile terminates
# (this is the default behaviour).
#
# When the main POPFile installer (or the 'Add POPFile User' wizard) calls this utility,
# different header text is required so the installer (and wizard) use /TIMEOUT=PFI to
# inform the utility.
#
# Uppercase or lowercase can be used for the command-line switch.
#
#--------------------------------------------------------------------------

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
  ; (two commonly used exceptions to this rule are 'IO_NL' and 'MB_NL')
  ;--------------------------------------------------------------------------

  !define C_VERSION             "0.0.57"

  !define C_OUTFILE             "msgcapture.exe"

  ; The timeout used when the installer calls this utility to monitor the SQL database upgrade

  !define C_INSTALLER_TIMEOUT   30

  ;--------------------------------------------------------------------------
  ; The default NSIS caption is "$(^Name) Setup" so we override it here
  ;--------------------------------------------------------------------------

  Name    "POPFile Message Capture Utility"
  Caption "$(^Name) v${C_VERSION}"

#--------------------------------------------------------------------------
# Use the "Modern User Interface"
#--------------------------------------------------------------------------

  !include "MUI.nsh"

#--------------------------------------------------------------------------
# Version Information settings (for the utility's EXE file)
#--------------------------------------------------------------------------

  ; 'VIProductVersion' format is X.X.X.X where X is a number in range 0 to 65535
  ; representing the following values: Major.Minor.Release.Build

  VIProductVersion                   "${C_VERSION}.0"

  VIAddVersionKey "ProductName"      "PFI Message Capture Utility"
  VIAddVersionKey "Comments"         "POPFile Homepage: http://getpopfile.org"
  VIAddVersionKey "CompanyName"      "The POPFile Project"
  VIAddVersionKey "LegalCopyright"   "Copyright (c) 2004  John Graham-Cumming"
  VIAddVersionKey "FileDescription"  "PFI Message Capture Utility (0-99 sec timeout)"
  VIAddVersionKey "FileVersion"      "${C_VERSION}"
  VIAddVersionKey "OriginalFilename" "${C_OUTFILE}"

  VIAddVersionKey "Build Date/Time"  "${__DATE__} @ ${__TIME__}"
  VIAddVersionKey "Build Script"     "${__FILE__}${MB_NL}(${__TIMESTAMP__})"

#--------------------------------------------------------------------------
# Include private library functions and macro definitions
#--------------------------------------------------------------------------

  ; Avoid compiler warnings by disabling the functions and definitions we do not use

  !define MSGCAPTURE

  !include "pfi-library.nsh"

#--------------------------------------------------------------------------
# User Registers (Global)
#--------------------------------------------------------------------------

  ; This script uses 'User Variables' (with names starting with 'G_') to hold GLOBAL data.

  Var G_MODE_FLAG         ; "" = normal mode, "PFI" = called from the installer
  Var G_TIMEOUT           ; timeout value in seconds (can be supplied on command-line)
                          ; Two special 'timeout' cases are supported: 0 and PFI

#--------------------------------------------------------------------------
# Configure the MUI pages
#--------------------------------------------------------------------------

  ;----------------------------------------------------------------
  ; Interface Settings - General Interface Settings
  ;----------------------------------------------------------------

  ; The icon file for the utility

  !define MUI_ICON                            "POPFileIcon\popfile.ico"

  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP              "hdr-common.bmp"
  !define MUI_HEADERIMAGE_RIGHT

  ;----------------------------------------------------------------
  ;  Interface Settings - Interface Resource Settings
  ;----------------------------------------------------------------

  ; The banner provided by the default 'modern.exe' UI does not provide much room for the
  ; two lines of text, e.g. the German version is truncated, so we use a custom UI which
  ; provides slightly wider text areas. Each area is still limited to a single line of text.

  !define MUI_UI                              "UI\pfi_modern.exe"

  ; The 'hdr-common.bmp' logo is only 90 x 57 pixels, much smaller than the 150 x 57 pixel
  ; space provided by the default 'modern_headerbmpr.exe' UI, so we use a custom UI which
  ; leaves more room for the TITLE and SUBTITLE text.

  !define MUI_UI_HEADERIMAGE_RIGHT            "UI\pfi_headerbmpr.exe"

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
  ; Installer Page - Install files
  ;---------------------------------------------------

  ; Override the standard "Installation complete..." page header

  !define MUI_INSTFILESPAGE_FINISHHEADER_TEXT     $(PFI_LANG_MSGCAP_END_HDR)
  !define MUI_INSTFILESPAGE_FINISHHEADER_SUBTEXT  $(PFI_LANG_MSGCAP_END_SUBHDR)

  ; Override the standard "Installation Aborted..." page header

  !define MUI_INSTFILESPAGE_ABORTHEADER_TEXT      $(PFI_LANG_MSGCAP_ABORT_HDR)
  !define MUI_INSTFILESPAGE_ABORTHEADER_SUBTEXT   $(PFI_LANG_MSGCAP_ABORT_SUBHDR)

  ; Use a custom "show" function to ensure the page header reflects the current
  ; timeout setting while the utility is capturing the POPFile console messages

  !define MUI_PAGE_CUSTOMFUNCTION_SHOW             UpdateHeader

  !insertmacro MUI_PAGE_INSTFILES

#--------------------------------------------------------------------------
# Language Support for the utility
#--------------------------------------------------------------------------

  !insertmacro MUI_LANGUAGE "English"

  ;--------------------------------------------------------------------------
  ; Current build only supports English and uses local strings
  ; instead of language strings from languages\*-pfi.nsh files
  ;--------------------------------------------------------------------------

  !macro PFI_MSGCAP_TEXT NAME VALUE
    LangString ${NAME} ${LANG_ENGLISH} "${VALUE}"
  !macroend

  !insertmacro PFI_MSGCAP_TEXT "PFI_LANG_MSGCAP_STD_HDR"        "Capturing messages from POPFile..."
  !insertmacro PFI_MSGCAP_TEXT "PFI_LANG_MSGCAP_STD_SUBHDR"     "Message capture will stop when POPFile shuts down${MB_NL}or if $G_TIMEOUT seconds pass without any messages"

  !insertmacro PFI_MSGCAP_TEXT "PFI_LANG_MSGCAP_PFI_HDR"        "Capturing database conversion messages..."
  !insertmacro PFI_MSGCAP_TEXT "PFI_LANG_MSGCAP_PFI_SUBHDR"     "Wait for the Close button to be enabled then click it to continue the installation"

  !insertmacro PFI_MSGCAP_TEXT "PFI_LANG_MSGCAP_NOTIME_HDR"     "Capturing messages from POPFile..."
  !insertmacro PFI_MSGCAP_TEXT "PFI_LANG_MSGCAP_NOTIME_SUBHDR"  "Message capture will stop when POPFile shuts down"

  !insertmacro PFI_MSGCAP_TEXT "PFI_LANG_MSGCAP_END_HDR"        "POPFile Message Capture Completed"
  !insertmacro PFI_MSGCAP_TEXT "PFI_LANG_MSGCAP_END_SUBHDR"     "To save the messages, use right-click in the message window,${MB_NL}copy to the clipboard then paste the messages into a text file"

  !insertmacro PFI_MSGCAP_TEXT "PFI_LANG_MSGCAP_ABORT_HDR"      "POPFile Message Capture Failed"
  !insertmacro PFI_MSGCAP_TEXT "PFI_LANG_MSGCAP_ABORT_SUBHDR"   "Problem detected - see error report in window below"

  !insertmacro PFI_MSGCAP_TEXT "PFI_LANG_MSGCAP_RIGHTCLICK"     "Right-click in the window below to copy the report to the clipboard"

  !insertmacro PFI_MSGCAP_TEXT "PFI_LANG_MSGCAP_CLICKCLOSE"     "Please click 'Close' to continue with the installation"
  !insertmacro PFI_MSGCAP_TEXT "PFI_LANG_MSGCAP_CLICKCANCEL"    "Please click 'Cancel' to continue with the installation"

  !insertmacro PFI_MSGCAP_TEXT "PFI_LANG_MSGCAP_MBOPTIONERROR"  "'$G_TIMEOUT' is not a valid option for this utility${MB_NL}${MB_NL}Usage: $R1 /TIMEOUT=x${MB_NL}where x is in the range 0 to 99 and specifies the timeout in seconds${MB_NL}${MB_NL}(use 0 to make the utility wait for POPFile to exit)"

#--------------------------------------------------------------------------
# General settings
#--------------------------------------------------------------------------

  ; Specify EXE filename and icon for the utility

  OutFile "${C_OUTFILE}"

  ; Ensure details are shown

  ShowInstDetails show

#--------------------------------------------------------------------------
# Installer Function: .onInit
#
# Checks if the user has specified a timeout value to override the default setting
# using the /TIMEOUT=xx command-line option (valid values are in range 0 to 99 inclusive)
#
# The special timeout value "PFI" is used to indicate that the utility has been called by the
# installer to monitor the conversion of an old SQL database.
#
# If an invalid option is supplied, an error message is displayed.
#--------------------------------------------------------------------------

Function .onInit

  !define L_TEMP    $R9

  Push ${L_TEMP}

  StrCpy $G_MODE_FLAG ""      ; select 'normal' mode by default

  Call GetParameters
  Pop $G_TIMEOUT
  StrCmp $G_TIMEOUT "" default
  StrCpy ${L_TEMP} $G_TIMEOUT 9
  StrCmp ${L_TEMP} "/timeout=" 0 usage_error
  StrCpy ${L_TEMP} $G_TIMEOUT "" 9
  StrCmp ${L_TEMP} "PFI" installer_mode
  Push ${L_TEMP}
  Call StrCheckDecimal
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" usage_error
  StrCmp ${L_TEMP} "0" exit
  IntCmp ${L_TEMP} 99 exit exit usage_error

usage_error:

  ; This utility is sometimes renamed as 'pfimsgcapture.exe' so we need
  ; to ensure we use the correct name in the 'usage' message. The first
  ; system call gets the full pathname (returned in $R0) and the second call
  ; extracts the filename (and possibly the extension) part (returned in $R1)

  ; No need to worry about corrupting $R0 and $R1 (we abort after displaying the message)

  System::Call 'kernel32::GetModuleFileNameA(i 0, t .R0, i 1024)'
  System::Call 'comdlg32::GetFileTitleA(t R0, t .R1, i 1024)'
  MessageBox MB_OK|MB_ICONSTOP "$(PFI_LANG_MSGCAP_MBOPTIONERROR)"
  Abort

installer_mode:
  StrCpy $G_MODE_FLAG "PFI"
  StrCpy ${L_TEMP} ${C_INSTALLER_TIMEOUT}
  Goto exit

default:
  StrCpy ${L_TEMP} "0"

exit:
  StrCpy $G_TIMEOUT ${L_TEMP}
  Pop ${L_TEMP}

  !undef L_TEMP

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: UpdateHeader
# (the "show" function for the INSTFILES page)
#--------------------------------------------------------------------------

Function UpdateHeader

  ; Override the standard "Installing..." header with text appropriate to the /TIMEOUT value

  StrCmp $G_MODE_FLAG "PFI" installer_mode
  StrCmp $G_TIMEOUT "0" no_timeout

  !insertmacro MUI_HEADER_TEXT $(PFI_LANG_MSGCAP_STD_HDR) $(PFI_LANG_MSGCAP_STD_SUBHDR)
  Goto exit

installer_mode:
  !insertmacro MUI_HEADER_TEXT $(PFI_LANG_MSGCAP_PFI_HDR) $(PFI_LANG_MSGCAP_PFI_SUBHDR)
  Goto exit

no_timeout:
  !insertmacro MUI_HEADER_TEXT $(PFI_LANG_MSGCAP_NOTIME_HDR) $(PFI_LANG_MSGCAP_NOTIME_SUBHDR)

exit:
FunctionEnd

;--------------------------------------------------------------------------
; Section: default
;--------------------------------------------------------------------------

Section default

  !define L_PFI_ROOT      $R9   ; path to the POPFile program (popfile.pl, and other files)
  !define L_PFI_USER      $R8  ; path to user's 'popfile.cfg' file
  !define L_RESULT        $R7
  !define L_TEMP          $R6
  !define L_TRAYICON      $R5   ; system tray icon enabled ("i" ) or disabled ("") flag

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_MSGCAP_RIGHTCLICK)"
  SetDetailsPrint listonly

  DetailPrint "------------------------------------------------------------"
  DetailPrint "$(^Name) v${C_VERSION}"
  DetailPrint "------------------------------------------------------------"

  ReadEnvStr ${L_PFI_ROOT} "POPFILE_ROOT"
  ReadEnvStr ${L_PFI_USER} "POPFILE_USER"

  StrCmp ${L_PFI_ROOT} "" no_root
  StrCmp ${L_PFI_USER} "" no_user

  IfFileExists "${L_PFI_USER}\popfile.cfg" found_cfg
  DetailPrint ""
  DetailPrint "Fatal error: cannot find POPFile configuration data"
  DetailPrint ""
  DetailPrint "(${L_PFI_USER}\popfile.cfg does not exist)"
  Goto fatal_error

no_root:
  DetailPrint ""
  DetailPrint "Fatal error: Environment variable POPFILE_ROOT is not defined"
  Goto fatal_error

no_user:
  DetailPrint ""
  DetailPrint "Fatal error: Environment variable POPFILE_USER is not defined"
  Goto fatal_error

start_failed:
  DetailPrint ""
  DetailPrint "Fatal error: unable to start '${L_PFI_ROOT}\popfile${L_TRAYICON}f.exe' program"

fatal_error:
  StrCmp $G_MODE_FLAG "" fatal_error_exit
  DetailPrint ""
  DetailPrint "############################################################"
  DetailPrint ""
  DetailPrint "$(PFI_LANG_MSGCAP_CLICKCANCEL)"
  DetailPrint ""
  DetailPrint "############################################################"

fatal_error_exit:
  Abort

found_cfg:
  Push ${L_PFI_USER}        ; 'User Data' folder location
  Push "1"                  ; assume system tray icon is enabled (the current default setting)
  Call GetTrayIconSetting
  Pop ${L_TRAYICON}         ; "i" if system tray icon enabled, "" if it is disabled
  DetailPrint "POPFILE_ROOT = ${L_PFI_ROOT}"
  DetailPrint "POPFILE_USER = ${L_PFI_USER}"
  IfFileExists "${L_PFI_ROOT}\popfile${L_TRAYICON}f.exe" found_exe
  DetailPrint ""
  DetailPrint "Fatal error: cannot find POPFile program"
  DetailPrint ""
  DetailPrint "(${L_PFI_ROOT}\popfile${L_TRAYICON}f.exe does not exist)"
  Goto fatal_error

found_exe:
  DetailPrint "Using 'popfile${L_TRAYICON}f.exe' to run POPFile"
  DetailPrint "------------------------------------------------------------"

  Call GetDateTimeStamp
  Pop ${L_TEMP}
  DetailPrint "(report started ${L_TEMP})"
  DetailPrint "------------------------------------------------------------"

  StrCmp $G_TIMEOUT "0" no_timeout
  StrCpy ${L_TEMP} "/TIMEOUT=$G_TIMEOUT000"
  nsExec::ExecToLog ${L_TEMP} '"${L_PFI_ROOT}\popfile${L_TRAYICON}f.exe"'
  Goto get_result

no_timeout:
  nsExec::ExecToLog '"${L_PFI_ROOT}\popfile${L_TRAYICON}f.exe"'

get_result:
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "error" start_failed
  StrCmp ${L_RESULT} "timeout" 0 display_status
  StrCpy ${L_RESULT} "(more than $G_TIMEOUT seconds since last message)"

display_status:
  DetailPrint ""
  DetailPrint "------------------------------------------------------------"
  DetailPrint "Status code: ${L_RESULT}"

  Call GetDateTimeStamp
  Pop ${L_TEMP}
  DetailPrint "------------------------------------------------------------"
  DetailPrint "(report finished ${L_TEMP})"
  DetailPrint "------------------------------------------------------------"
  StrCmp $G_MODE_FLAG "" exit
  DetailPrint ""
  DetailPrint "############################################################"
  DetailPrint ""
  DetailPrint "$(PFI_LANG_MSGCAP_CLICKCLOSE)"
  DetailPrint ""
  DetailPrint "############################################################"

exit:
  SetDetailsPrint none

  !undef L_PFI_ROOT
  !undef L_PFI_USER
  !undef L_RESULT
  !undef L_TEMP
  !undef L_TRAYICON

SectionEnd

#--------------------------------------------------------------------------
# Installer Function: GetTrayIconSetting
#
# Returns "i" if the system tray icon is enabled in popfile.cfg or "" if it is disabled.
# If the setting is not found in popfile.cfg, use the input parameter to determine the result.
#
# This function avoids the progress bar flicker seen when similar code was in the "Section" body
#--------------------------------------------------------------------------

Function GetTrayIconSetting

  !define L_CFG           $R9   ; file handle used to access 'popfile.cfg'
  !define L_ICONSETTING   $R8   ; 1 (or "i") = system tray icon enabled, 0 (or "") = disabled
  !define L_LINE          $R7   ; line (or part of line) read from 'popfile.cfg'
  !define L_TEMP          $R6
  !define L_TEXTEND       $R5   ; helps ensure correct handling of lines over 1023 chars long
  !define L_USERDATA      $R4   ; location of 'User Data'

  Exch ${L_ICONSETTING}         ; get the setting to be used if value not found in 'popfile.cfg'
  Exch
  Exch ${L_USERDATA}            ; get location where 'popfile.cfg' should be found
  Push ${L_CFG}
  Push ${L_LINE}
  Push ${L_TEMP}
  Push ${L_TEXTEND}

  FileOpen ${L_CFG} "${L_USERDATA}\popfile.cfg" r

found_eol:
  StrCpy ${L_TEXTEND} "<eol>"

loop:
  FileRead ${L_CFG} ${L_LINE}
  StrCmp ${L_LINE} "" options_done
  StrCmp ${L_TEXTEND} "<eol>" 0 check_eol
  StrCmp ${L_LINE} "$\n" loop

  StrCpy ${L_TEMP} ${L_LINE} 17
  StrCmp ${L_TEMP} "windows_trayicon " got_icon_option
  Goto check_eol

got_icon_option:
  StrCpy ${L_ICONSETTING} ${L_LINE} 1 17

check_eol:
  StrCpy ${L_TEXTEND} ${L_LINE} 1 -1
  StrCmp ${L_TEXTEND} "$\n" found_eol
  StrCmp ${L_TEXTEND} "$\r" found_eol loop

options_done:
  FileClose ${L_CFG}

  StrCmp ${L_ICONSETTING} "1" enabled
  StrCpy ${L_ICONSETTING} ""
  Goto exit

enabled:
  StrCpy ${L_ICONSETTING} "i"

exit:
  Pop ${L_TEXTEND}
  Pop ${L_TEMP}
  Pop ${L_LINE}
  Pop ${L_CFG}
  Pop ${L_USERDATA}
  Exch ${L_ICONSETTING}

  !undef L_CFG
  !undef L_ICONSETTING
  !undef L_LINE
  !undef L_TEMP
  !undef L_TEXTEND
  !undef L_USERDATA

FunctionEnd

#--------------------------------------------------------------------------
# End of 'msgcapture.nsi'
#--------------------------------------------------------------------------
