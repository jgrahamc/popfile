#--------------------------------------------------------------------------
#
# pfi-library.nsi --- This is a collection of library functions and macro
#                     definitions for inclusion in the NSIS scripts used
#                     to create (and test) the POPFile Windows installer.
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
# CONDITIONAL COMPILATION NOTES
#
# This library is used by many different scripts which only require subsets of the library.
# Conditional compilation is used to select the appropriate entries for a particular script
# (to avoid unnecessary compiler warnings).
#
# The following symbols are used to indicate the required subset:
#
# (1) ADDUSER          defined in adduser.nsi ('Add POPFile User' wizard)
# (2) MSGCAPTURE       defined in msgcapture.nsi (used to capture POPFile's console messages)
# (3) RUNPOPFILE       defined in runpopfile.nsi (simple front-end for popfile.exe)
# (4) TRANSLATOR       defined in translator.nsi (main installer translations test program)
# (5) TRANSLATOR_AUW   defined in transAUW.nsi ('Add POPFile User' translations test program)
#--------------------------------------------------------------------------

!ifndef PFI_VERBOSE
  !verbose 3
!endif

#--------------------------------------------------------------------------
#
# Macro which makes it easy to avoid relative jumps when defining macros
#
#--------------------------------------------------------------------------

  !macro PFI_UNIQUE_ID
      !ifdef PFI_UNIQUE_ID
        !undef PFI_UNIQUE_ID
      !endif
      !define PFI_UNIQUE_ID ${__LINE__}
  !macroend

#--------------------------------------------------------------------------
#
# Macros used to simplify inclusion/selection of the necessary language files
#
#--------------------------------------------------------------------------

  ;--------------------------------------------------------------------------
  ; Used in the '*-pfi.nsh' files to define the text strings for the installer
  ;--------------------------------------------------------------------------

  !macro PFI_LANG_STRING NAME VALUE
      LangString ${NAME} ${LANG_${PFI_LANG}} "${VALUE}"
  !macroend

  ;--------------------------------------------------------------------------
  ; Used in '*-pfi.nsh' files to define the text strings for fields in a custom page INI file
  ;--------------------------------------------------------------------------

  !macro PFI_IO_TEXT PATH FIELD TEXT
      WriteINIStr "$PLUGINSDIR\${PATH}" "Field ${FIELD}" "Text" "${TEXT}"
  !macroend

  ;--------------------------------------------------------------------------
  ; Used in '*-pfi.nsh' files to define entries in [Settings] section of a custom page INI file
  ;--------------------------------------------------------------------------

  !macro PFI_IO_SETTING PATH FIELD TEXT
      WriteINIStr "$PLUGINSDIR\${PATH}" "Settings" "${FIELD}" "${TEXT}"
  !macroend

  ;--------------------------------------------------------------------------
  ; Used in multi-language scripts to define the languages to be supported
  ;--------------------------------------------------------------------------

  ; Macro used to load the files required for each language:
  ; (1) The MUI_LANGUAGE macro loads the standard MUI text strings for a particular language
  ; (2) '*-pfi.nsh' contains the text strings used for pages, progress reports, logs etc

!ifdef TRANSLATOR | TRANSLATOR_AUW
        !macro PFI_LANG_LOAD LANG
            !insertmacro MUI_LANGUAGE "${LANG}"
            !include "..\languages\${LANG}-pfi.nsh"
        !macroend
!else
        !macro PFI_LANG_LOAD LANG
            !insertmacro MUI_LANGUAGE "${LANG}"
            !include "languages\${LANG}-pfi.nsh"
        !macroend
!endif

  ;--------------------------------------------------------------------------
  ; Used in 'adduser.nsi' to select the POPFile UI language according to the language used
  ; for the installation process (NSIS language names differ from those used by POPFile's UI)
  ;--------------------------------------------------------------------------

  !macro UI_LANG_CONFIG PFI_SETTING UI_SETTING
        !insertmacro PFI_UNIQUE_ID

        StrCmp $LANGUAGE ${LANG_${PFI_SETTING}} 0 skip_${PFI_UNIQUE_ID}
        IfFileExists "$G_ROOTDIR\languages\${UI_SETTING}.msg" 0 lang_done
        StrCpy ${L_LANG} "${UI_SETTING}"
        Goto lang_save

      skip_${PFI_UNIQUE_ID}:
  !macroend

#--------------------------------------------------------------------------
#
# Macros used when writing log files during 'Outlook' and 'Outlook Express' account processing
#
#--------------------------------------------------------------------------

  !macro OECONFIG_LOG_ENTRY LOGTYPE VALUE WIDTH
      !insertmacro PFI_UNIQUE_ID

      Push $R9
      Push $R8

      StrCpy $R9 "${VALUE}"
      StrLen $R8 $R9
      IntCmp $R8 ${WIDTH} copy_${PFI_UNIQUE_ID} 0 copy_${PFI_UNIQUE_ID}
      StrCpy $R9 "$R9                              " ${WIDTH}

    copy_${PFI_UNIQUE_ID}:
      FileWrite $G_${LOGTYPE}_HANDLE "$R9  "

      Pop $R8
      Pop $R9
  !macroend

  !macro OOECONFIG_BEFORE_LOG VALUE WIDTH
      !insertmacro OECONFIG_LOG_ENTRY "OOECONFIG" "${VALUE}" "${WIDTH}"
  !macroend

  !macro OOECONFIG_CHANGES_LOG VALUE WIDTH
      !insertmacro OECONFIG_LOG_ENTRY "OOECHANGES" "${VALUE}" "${WIDTH}"
  !macroend

#--------------------------------------------------------------------------
#
# Macro used by 'installer.nsi' when rearranging existing minimal Perl system
#
#--------------------------------------------------------------------------

  !macro MinPerlMove SUBFOLDER

      !insertmacro PFI_UNIQUE_ID

      IfFileExists "$G_ROOTDIR\${SUBFOLDER}\*.*" 0 skip_${PFI_UNIQUE_ID}
      Rename "$G_ROOTDIR\${SUBFOLDER}" "$G_MPLIBDIR\${SUBFOLDER}"

    skip_${PFI_UNIQUE_ID}:

  !macroend

#--------------------------------------------------------------------------
#
# Macro used by 'installer.nsi' when rearranging existing skins
#
#--------------------------------------------------------------------------

  !macro SkinMove OLDNAME NEWNAME

      !insertmacro PFI_UNIQUE_ID

      IfFileExists "$G_ROOTDIR\skins\${OLDNAME}.css" 0 skip_${PFI_UNIQUE_ID}
      CreateDirectory "$G_ROOTDIR\skins\${NEWNAME}"
      Rename "$G_ROOTDIR\skins\${OLDNAME}.css" "$G_ROOTDIR\skins\${NEWNAME}\style.css"

    skip_${PFI_UNIQUE_ID}:

  !macroend

#--------------------------------------------------------------------------
#
# Macro used by 'installer.nsi' when uninstalling the new style skins
#
#--------------------------------------------------------------------------

  !macro DeleteSkin FOLDER

      !insertmacro PFI_UNIQUE_ID

      IfFileExists "${FOLDER}\*.*" 0 skip_${PFI_UNIQUE_ID}
      Delete "${FOLDER}\*.css"
      Delete "${FOLDER}\*.gif"
      Delete "${FOLDER}\*.thtml"
      RmDir  "${FOLDER}"

    skip_${PFI_UNIQUE_ID}:

  !macroend


#==============================================================================================
#
# Functions used only during installation of POPFile or User Data files (in alphabetic order)
#
#    Installer Function: GetIEVersion
#    Installer Function: GetParameters
#    Installer Function: GetSeparator
#    Installer Function: SetTrayIconMode
#    Installer Function: StrStripLZS
#
#==============================================================================================


!ifndef ADDUSER & MSGCAPTURE & RUNPOPFILE & TRANSLATOR & TRANSLATOR_AUW
    #--------------------------------------------------------------------------
    # Installer Function: GetIEVersion
    #
    # Uses the registry to determine which version of Internet Explorer is installed.
    #
    # Inputs:
    #         (none)
    # Outputs:
    #         (top of stack)     - string containing the Internet Explorer version
    #                              (1.x, 2.x, 3.x, 4.x, 5.0, 5.5, 6.0). If Internet Explorer
    #                              is not installed properly or at all, '?.?' is returned.
    #
    # Usage:
    #         Call GetIEVersion
    #         Pop $R0
    #
    #         ($R0 at this point is "5.0", for example)
    #
    #--------------------------------------------------------------------------

    Function GetIEVersion

      !define L_REGDATA   $R9
      !define L_TEMP      $R8

      Push ${L_REGDATA}
      Push ${L_TEMP}

      ClearErrors
      ReadRegStr ${L_REGDATA} HKLM "Software\Microsoft\Internet Explorer" "Version"
      IfErrors ie_123

      ; Internet Explorer 4.0 or later is installed. The 'Version' value is a string with the
      ; following format: major-version.minor-version.build-number.sub-build-number

      ; According to MSDN, the 'Version' string under 'HKLM\Software\Microsoft\Internet Explorer'
      ; can have the following values:
      ;
      ; Internet Explorer Version     'Version' string
      ;    4.0                          4.71.1712.6
      ;    4.01                         4.72.2106.8
      ;    4.01 SP1                     4.72.3110.3
      ;    5                  	        5.00.2014.0216
      ;    5.5                          5.50.4134.0100
      ;    6.0 Public Preview           6.0.2462.0000
      ;    6.0 Public Preview Refresh   6.0.2479.0006
      ;    6.0 RTM                    	6.0.2600.0000

      StrCpy ${L_TEMP} ${L_REGDATA} 1
      StrCmp ${L_TEMP} "4" ie_4
      StrCpy ${L_REGDATA} ${L_REGDATA} 3
      Goto done

    ie_4:
      StrCpy ${L_REGDATA} "4.x"
      Goto done

    ie_123:

      ; Older versions of Internet Explorer use the 'IVer' string under the same registry key
      ; (HKLM\Software\Microsoft\Internet Explorer). The 'IVer' string is used as follows:
      ;
      ; Internet Explorer 1.0 for Windows 95 (included with Microsoft Plus! for Windows 95)
      ; uses the value '100'
      ;
      ; Internet Explorer 2.0 for Windows 95 uses the value '102'
      ;
      ; Versions of Internet Explorer that are included with Windows NT 4.0 use the value '101'
      ;
      ; Internet Explorer 3.x updates the 'IVer' string value to '103'

      ClearErrors
      ReadRegStr ${L_REGDATA} HKLM "Software\Microsoft\Internet Explorer" "IVer"
      IfErrors error

      StrCpy ${L_REGDATA} ${L_REGDATA} 3
      StrCmp ${L_REGDATA} '100' ie1
      StrCmp ${L_REGDATA} '101' ie2
      StrCmp ${L_REGDATA} '102' ie2

      StrCpy ${L_REGDATA} '3.x'       ; default to ie3 if not 100, 101, or 102.
      Goto done

    ie1:
      StrCpy ${L_REGDATA} '1.x'
      Goto done

    ie2:
      StrCpy ${L_REGDATA} '2.x'
      Goto done

    error:
      StrCpy ${L_REGDATA} '?.?'

    done:
      Pop ${L_TEMP}
      Exch ${L_REGDATA}

      !undef L_REGDATA
      !undef L_TEMP

    FunctionEnd
!endif


#--------------------------------------------------------------------------
# Installer Function: GetParameters
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
#         (if 'setup.exe /outlook' was used to start the installer, $R0 will hold '/outlook')
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


!ifdef ADDUSER | TRANSLATOR_AUW
    #--------------------------------------------------------------------------
    # Installer Function: GetSeparator
    #
    # Returns the character to be used as the separator when configuring an e-mail account.
    # If the character is not defined in popfile.cfg, the default separator (':') is returned
    #
    # Inputs:
    #         none
    # Outputs:
    #         (top of stack)     - character to be used as the separator
    #
    # Usage:
    #         Call GetSeparator
    #         Pop $R0
    #
    #         ($R0 at this point is ":" unless popfile.cfg has altered the default setting)
    #
    #--------------------------------------------------------------------------

    Function GetSeparator

      !define L_CFG         $R9   ; file handle
      !define L_LNE         $R8   ; a line from the popfile.cfg file
      !define L_PARAM       $R7
      !define L_SEPARATOR   $R6   ; character used to separate the pop3 server from the username
      !define L_TEXTEND     $R5   ; helps ensure correct handling of lines over 1023 chars long

      Push ${L_SEPARATOR}
      Push ${L_CFG}
      Push ${L_LNE}
      Push ${L_PARAM}
      Push ${L_TEXTEND}

      StrCpy ${L_SEPARATOR} ""

      FileOpen  ${L_CFG} "$G_USERDIR\popfile.cfg" r

    found_eol:
      StrCpy ${L_TEXTEND} "<eol>"

    loop:
      FileRead ${L_CFG} ${L_LNE}
      StrCmp ${L_LNE} "" separator_done
      StrCmp ${L_TEXTEND} "<eol>" 0 check_eol
      StrCmp ${L_LNE} "$\n" loop

      StrCpy ${L_PARAM} ${L_LNE} 10
      StrCmp ${L_PARAM} "separator " old_separator
      StrCpy ${L_PARAM} ${L_LNE} 15
      StrCmp ${L_PARAM} "pop3_separator " new_separator
      Goto check_eol

    old_separator:
      StrCpy ${L_SEPARATOR} ${L_LNE} 1 10
      Goto check_eol

    new_separator:
      StrCpy ${L_SEPARATOR} ${L_LNE} 1 15

      ; Now read file until we get to end of the current line
      ; (i.e. until we find text ending in <CR><LF>, <CR> or <LF>)

    check_eol:
      StrCpy ${L_TEXTEND} ${L_LNE} 1 -1
      StrCmp ${L_TEXTEND} "$\n" found_eol
      StrCmp ${L_TEXTEND} "$\r" found_eol loop

    separator_done:
      FileClose ${L_CFG}
      StrCmp ${L_SEPARATOR} "" default
      StrCmp ${L_SEPARATOR} "$\r" default
      StrCmp ${L_SEPARATOR} "$\n" 0 exit

    default:
      StrCpy ${L_SEPARATOR} ":"

    exit:
      Pop ${L_TEXTEND}
      Pop ${L_PARAM}
      Pop ${L_LNE}
      Pop ${L_CFG}
      Exch ${L_SEPARATOR}

      !undef L_CFG
      !undef L_LNE
      !undef L_PARAM
      !undef L_SEPARATOR
      !undef L_TEXTEND

    FunctionEnd
!endif


!ifdef ADDUSER
    #--------------------------------------------------------------------------
    # Installer Function: SetTrayIconMode
    #
    # Used to set required system tray icon mode in 'popfile.cfg'
    #
    # Inputs:
    #         (top of stack)     - required system tray icon  mode (0 = disabled, 1 = enabled)
    #
    # Outputs:
    #         none
    #
    # Usage:
    #         Push "1"
    #         Call SetTrayIconMode
    #
    #--------------------------------------------------------------------------

    Function SetTrayIconMode

      !define L_NEW_CFG     $R9   ; file handle used for clean copy
      !define L_OLD_CFG     $R8   ; file handle for old version
      !define L_LNE         $R7   ; a line from the popfile.cfg file
      !define L_MODE        $R6   ; new console mode
      !define L_PARAM       $R5
      !define L_TEXTEND     $R4   ; helps ensure correct handling of lines over 1023 chars long

      Exch ${L_MODE}
      Push ${L_NEW_CFG}
      Push ${L_OLD_CFG}
      Push ${L_LNE}
      Push ${L_PARAM}
      Push ${L_TEXTEND}

      FileOpen  ${L_OLD_CFG} "$G_USERDIR\popfile.cfg" r
      FileOpen  ${L_NEW_CFG} "$PLUGINSDIR\new.cfg" w

    found_eol:
      StrCpy ${L_TEXTEND} "<eol>"

    loop:
      FileRead ${L_OLD_CFG} ${L_LNE}
      StrCmp ${L_LNE} "" copy_done
      StrCmp ${L_TEXTEND} "<eol>" 0 copy_lne
      StrCmp ${L_LNE} "$\n" copy_lne

      StrCpy ${L_PARAM} ${L_LNE} 17
      StrCmp ${L_PARAM} "windows_trayicon " 0 copy_lne
      FileWrite ${L_NEW_CFG} "windows_trayicon ${L_MODE}$\r$\n"
      Goto loop

    copy_lne:
      FileWrite ${L_NEW_CFG} ${L_LNE}

    ; Now read file until we get to end of the current line
    ; (i.e. until we find text ending in <CR><LF>, <CR> or <LF>)

      StrCpy ${L_TEXTEND} ${L_LNE} 1 -1
      StrCmp ${L_TEXTEND} "$\n" found_eol
      StrCmp ${L_TEXTEND} "$\r" found_eol loop

   copy_done:
      FileClose ${L_OLD_CFG}
      FileClose ${L_NEW_CFG}

      Delete "$G_USERDIR\popfile.cfg"
      Rename "$PLUGINSDIR\new.cfg" "$G_USERDIR\popfile.cfg"

      Pop ${L_TEXTEND}
      Pop ${L_PARAM}
      Pop ${L_LNE}
      Pop ${L_OLD_CFG}
      Pop ${L_NEW_CFG}
      Pop ${L_MODE}

      !undef L_NEW_CFG
      !undef L_OLD_CFG
      !undef L_LNE
      !undef L_MODE
      !undef L_PARAM
      !undef L_TEXTEND

    FunctionEnd
!endif


!ifdef ADDUSER | TRANSLATOR_AUW
    #--------------------------------------------------------------------------
    # Installer Function: StrStripLZS
    #
    # Strips any combination of leading zeroes and spaces from a string.
    #
    # Inputs:
    #         (top of stack)     - string to be processed
    # Outputs:
    #         (top of stack)     - processed string (with no leading zeroes or spaces)
    #
    # Usage:
    #         Push "  123"        ; the strings "000123" or " 0 0 0123" will give same result
    #         Call StrStripLZS
    #         Pop $R0
    #
    #         ($R0 at this point is "123")
    #
    #--------------------------------------------------------------------------

    Function StrStripLZS

      !define L_CHAR      $R9
      !define L_STRING    $R8

      Exch ${L_STRING}
      Push ${L_CHAR}

    loop:
      StrCpy ${L_CHAR} ${L_STRING} 1
      StrCmp ${L_CHAR} "" done
      StrCmp ${L_CHAR} " " strip_char
      StrCmp ${L_CHAR} "0" strip_char
      Goto done

    strip_char:
      StrCpy ${L_STRING} ${L_STRING} "" 1
      Goto loop

    done:
      Pop ${L_CHAR}
      Exch ${L_STRING}

      !undef L_CHAR
      !undef L_STRING

    FunctionEnd
!endif


#==============================================================================================
#
# Macro-based Functions which may be used by the installer and uninstaller (in alphabetic order)
#
#    Macro:                CheckIfLocked
#    Installer Function:   CheckIfLocked
#    Uninstaller Function: un.CheckIfLocked
#
#    Macro:                FindLockedPFE
#    Installer Function:   FindLockedPFE
#    Uninstaller Function: un.FindLockedPFE
#
#    Macro:                GetCorpusPath
#    Installer Function:   GetCorpusPath
#    Uninstaller Function: un.GetCorpusPath
#
#    Macro:                GetDataPath
#    Installer Function:   GetDataPath
#    Uninstaller Function: un.GetDataPath
#
#    Macro:                GetDateStamp
#    Installer Function:   GetDateStamp
#    Uninstaller Function: un.GetDateStamp
#
#    Macro:                GetDateTimeStamp
#    Installer Function:   GetTimeStamp
#    Uninstaller Function: un.GetTimeStamp
#
#    Macro:                GetFileSize
#    Installer Function:   GetFileSize
#    Uninstaller Function: un.GetFileSize
#
#    Macro:                GetLocalTime
#    Installer Function:   GetLocalTime
#    Uninstaller Function: un.GetLocalTime
#
#    Macro:                GetParent
#    Installer Function:   GetParent
#    Uninstaller Function: un.GetParent
#
#    Macro:                GetTimeStamp
#    Installer Function:   GetTimeStamp
#    Uninstaller Function: un.GetTimeStamp
#
#    Macro:                ServiceCall
#    Installer Function:   ServiceCall
#    Uninstaller Function: un.ServiceCall
#
#    Macro:                ServiceRunning
#    Installer Function:   ServiceRunning
#    Uninstaller Function: un.ServiceRunning
#
#    Macro:                ServiceStatus
#    Installer Function:   ServiceStatus
#    Uninstaller Function: un.ServiceStatus
#
#    Macro:                ShutdownViaUI
#    Installer Function:   ShutdownViaUI
#    Uninstaller Function: un.ShutdownViaUI
#
#    Macro:                StrBackSlash
#    Installer Function:   StrBackSlash
#    Uninstaller Function: un.StrBackSlash
#
#    Macro:                StrCheckDecimal
#    Installer Function:   StrCheckDecimal
#    Uninstaller Function: un.StrCheckDecimal
#
#    Macro:                StrStr
#    Installer Function:   StrStr
#    Uninstaller Function: un.StrStr
#
#    Macro:                TrimNewlines
#    Installer Function:   TrimNewlines
#    Uninstaller Function: un.TrimNewlines
#
#    Macro:                WaitUntilUnlocked
#    Installer Function:   WaitUntilUnlocked
#    Uninstaller Function: un.WaitUntilUnlocked
#
#==============================================================================================


#--------------------------------------------------------------------------
# Macro: CheckIfLocked
#
# The installation process and the uninstall process may both use a function which checks if
# a particular executable file (an EXE file) is being used. This macro makes maintenance easier
# by ensuring that both processes use identical functions, with the only difference being their
# names.
#
# The EXE file to be checked depends upon the version of POPFile in use and upon how it has
# been configured. If the specified EXE file is no longer in use, this function returns an empty
# string (otherwise it returns the input parameter unchanged).
#
# NOTE:
# The !insertmacro CheckIfLocked "" and !insertmacro CheckIfLocked "un." commands are included
# in this file so the NSIS script can use 'Call CheckIfLocked' and 'Call un.CheckIfLocked'
# without additional preparation.
#
# Inputs:
#         (top of stack)     - the full path of the EXE file to be checked
#
# Outputs:
#         (top of stack)     - if file is no longer in use, an empty string ("") is returned
#                              otherwise the input string is returned
#
# Usage (after macro has been 'inserted'):
#
#         Push "$INSTDIR\wperl.exe"
#         Call CheckIfLocked
#         Pop $R0
#
#        (if the file is no longer in use, $R0 will be "")
#        (if the file is still being used, $R0 will be "$INSTDIR\wperl.exe")
#--------------------------------------------------------------------------

!macro CheckIfLocked UN
  Function ${UN}CheckIfLocked
    !define L_EXE           $R9   ; full path to the EXE file which is to be monitored
    !define L_FILE_HANDLE   $R8

    Exch ${L_EXE}
    Push ${L_FILE_HANDLE}

    IfFileExists "${L_EXE}" 0 unlocked_exit
    SetFileAttributes "${L_EXE}" NORMAL

    ClearErrors
    FileOpen ${L_FILE_HANDLE} "${L_EXE}" a
    FileClose ${L_FILE_HANDLE}
    IfErrors exit

  unlocked_exit:
    StrCpy ${L_EXE} ""

   exit:
    Pop ${L_FILE_HANDLE}
    Exch ${L_EXE}

    !undef L_EXE
    !undef L_FILE_HANDLE
  FunctionEnd
!macroend

!ifndef MSGCAPTURE & RUNPOPFILE & TRANSLATOR & TRANSLATOR_AUW
    #--------------------------------------------------------------------------
    # Installer Function: CheckIfLocked
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro CheckIfLocked ""
!endif

!ifndef MSGCAPTURE & RUNPOPFILE & TRANSLATOR & TRANSLATOR_AUW
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.CheckIfLocked
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro CheckIfLocked "un."
!endif


#--------------------------------------------------------------------------
# Macro: FindLockedPFE
#
# The installation process and the uninstall process may both use a function which checks if
# any of the POPFile executable (EXE) files is being used. This macro makes maintenance easier
# by ensuring that both processes use identical functions, with the only difference being their
# names.
#
# Early versions of POPFile only had two EXE files to check (perl.exe and wperl.exe) but current
# versions have a much greater choice. More than one script needs to perform these checks, so
# these macro-based functions have been created to make it easier to change the list of files to
# be checked.
#
# NOTE:
# The !insertmacro FindLockedPFE "" and !insertmacro FindLockedPFE "un." commands are included
# in this file so the NSIS script can use 'Call FindLockedPFE' and 'Call un.FindLockedPFE'
# without additional preparation.
#
# Inputs:
#         (top of stack)   - the path where the EXE files can be found
#
# Outputs:
#         (top of stack)   - if a locked EXE file is found, its full path is returned otherwise
#                            an empty string ("") is returned (to show that no files are locked)
#
# Usage (after macro has been 'inserted'):
#
#         Push "C:\Program Files\POPFile"
#         Call FindLockedPFE
#         Pop $R0
#
#        (if popfileb.exe is still running, $R0 will be "C:\Program Files\POPFile\popfileb.exe")
#--------------------------------------------------------------------------

!macro FindLockedPFE UN
  Function ${UN}FindLockedPFE
    !define L_PATH          $R9    ; full path to the POPFile EXE files which are to be checked
    !define L_RESULT        $R8    ; either the full path to a locked file or an empty string

    Exch ${L_PATH}
    Push ${L_RESULT}
    Exch

    DetailPrint "Checking '${L_PATH}\popfileb.exe' ..."

    Push "${L_PATH}\popfileb.exe"  ; runs POPFile in the background
    Call ${UN}CheckIfLocked
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" 0 exit

    DetailPrint "Checking '${L_PATH}\popfileib.exe' ..."

    Push "${L_PATH}\popfileib.exe" ; runs POPFile in the background with system tray icon
    Call ${UN}CheckIfLocked
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" 0 exit

    DetailPrint "Checking '${L_PATH}\popfilef.exe' ..."

    Push "${L_PATH}\popfilef.exe"  ; runs POPFile in the foreground/console window/DOS box
    Call ${UN}CheckIfLocked
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" 0 exit

    DetailPrint "Checking '${L_PATH}\popfileif.exe' ..."

    Push "${L_PATH}\popfileif.exe" ; runs POPFile in the foreground with system tray icon
    Call ${UN}CheckIfLocked
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" 0 exit

    DetailPrint "Checking '${L_PATH}\wperl.exe' ..."

    Push "${L_PATH}\wperl.exe"     ; runs POPFile in the background (using popfile.pl)
    Call ${UN}CheckIfLocked
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" 0 exit

    DetailPrint "Checking '${L_PATH}\perl.exe' ..."

    Push "${L_PATH}\perl.exe"      ; runs POPFile in the foreground (using popfile.pl)
    Call ${UN}CheckIfLocked
    Pop ${L_RESULT}

   exit:
    Pop ${L_PATH}
    Exch ${L_RESULT}              ; return full path to a locked file or an empty string

    !undef L_PATH
    !undef L_RESULT
  FunctionEnd
!macroend

!ifndef MSGCAPTURE & RUNPOPFILE & TRANSLATOR & TRANSLATOR_AUW
    #--------------------------------------------------------------------------
    # Installer Function: FindLockedPFE
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro FindLockedPFE ""
!endif

!ifndef MSGCAPTURE & RUNPOPFILE & TRANSLATOR & TRANSLATOR_AUW
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.FindLockedPFE
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro FindLockedPFE "un."
!endif


#--------------------------------------------------------------------------
# Macro: GetCorpusPath
#
# The installation process and the uninstall process may both use a function which finds the
# full path for the corpus if a copy of 'popfile.cfg' is found in the installation folder. This
# macro makes maintenance easier by ensuring that both processes use identical functions, with
# the only difference being their names.
#
# The 'popfile.cfg' file is used to determine the full path of the directory where the corpus
# files are stored. By default the flat file and BerkeleyDB versions of POPFile (i.e. versions
# prior to 0.21.0) store the corpus in the '$G_USERDIR\corpus' directory but the 'popfile.cfg'
# file can define a different location, using a variety of paths (eg relative, absolute, local
# or even remote). If the path specified in 'popfile.cfg' ends with a trailing slash, the
# trailing slash is stripped.
#
# If 'popfile.cfg' is found in the specified folder, we use the corpus parameter (if present)
# otherwise we assume the default location is to be used (the sub-folder called 'corpus').
#
# NOTE:
# The !insertmacro GetCorpusPath "" and !insertmacro GetCorpusPath "un." commands are included
# in this file so the NSIS script can use 'Call GetCorpusPath' and 'Call un.GetCorpusPath'
# without additional preparation.
#
# Inputs:
#         (top of stack)          - the path where 'popfile.cfg' is to be found
#
# Outputs:
#         (top of stack)          - string containing the full (unambiguous) path to the corpus
#
# Usage (after macro has been 'inserted'):
#
#         Push $G_USERDIR
#         Call un.GetCorpusPath
#         Pop $R0
#
#         ($R0 will be "C:\Program Files\POPFile\corpus" if default corpus location is used)
#--------------------------------------------------------------------------

!macro GetCorpusPath UN
  Function ${UN}GetCorpusPath

    !define L_CORPUS        $R9
    !define L_FILE_HANDLE   $R8
    !define L_RESULT        $R7
    !define L_SOURCE        $R6
    !define L_TEMP          $R5
    !define L_TEXTEND       $R4   ; helps ensure correct handling of lines over 1023 chars long

    Exch ${L_SOURCE}          ; where we are supposed to look for the 'popfile.cfg' file
    Push ${L_RESULT}
    Exch
    Push ${L_CORPUS}
    Push ${L_FILE_HANDLE}
    Push ${L_TEMP}
    Push ${L_TEXTEND}

    StrCpy ${L_CORPUS} ""

    IfFileExists "${L_SOURCE}\popfile.cfg" 0 use_default_locn

    FileOpen ${L_FILE_HANDLE} "${L_SOURCE}\popfile.cfg" r

  found_eol:
    StrCpy ${L_TEXTEND} "<eol>"

  loop:
    FileRead ${L_FILE_HANDLE} ${L_TEMP}
    StrCmp ${L_TEMP} "" cfg_file_done
    StrCmp ${L_TEXTEND} "<eol>" 0 check_eol
    StrCmp ${L_TEMP} "$\n" loop

    StrCpy ${L_RESULT} ${L_TEMP} 7
    StrCmp ${L_RESULT} "corpus " got_old_corpus
    StrCpy ${L_RESULT} ${L_TEMP} 13
    StrCmp ${L_RESULT} "bayes_corpus " got_new_corpus
    Goto check_eol

  got_old_corpus:
    StrCpy ${L_CORPUS} ${L_TEMP} "" 7
    Goto check_eol

  got_new_corpus:
    StrCpy ${L_CORPUS} ${L_TEMP} "" 13

    ; Now read file until we get to end of the current line
    ; (i.e. until we find text ending in <CR><LF>, <CR> or <LF>)

  check_eol:
    StrCpy ${L_TEXTEND} ${L_TEMP} 1 -1
    StrCmp ${L_TEXTEND} "$\n" found_eol
    StrCmp ${L_TEXTEND} "$\r" found_eol loop

  cfg_file_done:
    FileClose ${L_FILE_HANDLE}
    Push ${L_CORPUS}
    Call ${UN}TrimNewlines
    Pop ${L_CORPUS}
    StrCmp ${L_CORPUS} "" use_default_locn use_cfg_data

  use_default_locn:
    StrCpy ${L_RESULT} ${L_SOURCE}\corpus
    Goto got_result

  use_cfg_data:
    StrCpy ${L_TEMP} ${L_CORPUS} 1 -1
    StrCmp ${L_TEMP} "/" strip_slash no_trailing_slash
    StrCmp ${L_TEMP} "\" 0 no_trailing_slash

  strip_slash:
    StrCpy ${L_CORPUS} ${L_CORPUS} -1

  no_trailing_slash:
    Push ${L_SOURCE}
    Push ${L_CORPUS}
    Call ${UN}GetDataPath
    Pop ${L_RESULT}

  got_result:
    Pop ${L_TEXTEND}
    Pop ${L_TEMP}
    Pop ${L_FILE_HANDLE}
    Pop ${L_CORPUS}
    Pop ${L_SOURCE}
    Exch ${L_RESULT}  ; place full path of 'corpus' directory on top of the stack

    !undef L_CORPUS
    !undef L_FILE_HANDLE
    !undef L_RESULT
    !undef L_SOURCE
    !undef L_TEMP
    !undef L_TEXTEND

  FunctionEnd
!macroend

!ifdef ADDUSER
    #--------------------------------------------------------------------------
    # Installer Function: GetCorpusPath
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro GetCorpusPath ""
!endif

#--------------------------------------------------------------------------
# Uninstaller Function: un.GetCorpusPath
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro GetCorpusPath "un."


#--------------------------------------------------------------------------
# Macro: GetDataPath
#
# The installation process and the uninstall process may both use a function which converts a
# 'base directory' and a 'data folder' parameter (usually relative to the 'base directory')
# into a single, absolute path. For example, it will convert 'C:\Program Files\POPFile' and
# 'corpus' into 'C:\Program Files\POPFile\corpus'. This macro makes maintenance easier by
# ensuring that both processes use identical functions, with the only difference being their
# names.
#
# It is assumed that the 'base directory' is in standard Windows format with no trailing slash.
#
# The 'data folder' may be supplied in a variety of different formats, for example:
# corpus, ./corpus, "..\..\corpus", Z:/Data/corpus or even "\\server\share\corpus".
#
# NOTE:
# The !insertmacro GetDataPath "" and !insertmacro GetDataPath "un." commands are included
# in this file so the NSIS script can use 'Call GetDataPath' and 'Call un.GetDataPath'
# without additional preparation.
#
# Inputs:
#         (top of stack)          - the 'data folder' parameter (eg "../../corpus")
#         (top of stack - 1)      - the 'base directory' parameter
#
# Outputs:
#         (top of stack)          - string containing the full (unambiguous) path to the data
#                                   (the string "" is returned if input data was null)
#
# Usage (after macro has been 'inserted'):
#
#         Push $G_USERDIR
#         Push "../../corpus"
#         Call un.GetDataPath
#         Pop $R0
#
#         ($R0 will be "C:\corpus", assuming $G_USERDIR was "C:\Program Files\POPFile")
#--------------------------------------------------------------------------

!macro GetDataPath UN
  Function ${UN}GetDataPath

    !define L_BASEDIR     $R9
    !define L_DATA        $R8
    !define L_RESULT      $R7
    !define L_TEMP        $R6

    Exch ${L_DATA}        ; the 'data folder' parameter (often a relative path)
    Exch
    Exch ${L_BASEDIR}      ; the 'base directory' used for cases where 'data folder' is relative
    Push ${L_RESULT}
    Push ${L_TEMP}

    StrCmp ${L_DATA} "" 0 strip_quotes
    StrCpy ${L_DATA} ${L_BASEDIR}
    Goto got_path

  strip_quotes:

    ; Strip leading/trailing quotes, if any

    StrCpy ${L_TEMP} ${L_DATA} 1
    StrCmp ${L_TEMP} '"' 0 slashconversion
    StrCpy ${L_DATA} ${L_DATA} "" 1
    StrCpy ${L_TEMP} ${L_DATA} 1 -1
    StrCmp ${L_TEMP} '"' 0 slashconversion
    StrCpy ${L_DATA} ${L_DATA} -1

  slashconversion:
    StrCmp ${L_DATA} "." source_folder
    Push ${L_DATA}
    Call ${UN}StrBackSlash            ; ensure parameter uses backslashes
    Pop ${L_DATA}

    StrCpy ${L_TEMP} ${L_DATA} 2
    StrCmp ${L_TEMP} ".\" sub_folder
    StrCmp ${L_TEMP} "\\" got_path

    StrCpy ${L_TEMP} ${L_DATA} 3
    StrCmp ${L_TEMP} "..\" relative_folder

    StrCpy ${L_TEMP} ${L_DATA} 1
    StrCmp ${L_TEMP} "\" basedir_drive

    StrCpy ${L_TEMP} ${L_DATA} 1 1
    StrCmp ${L_TEMP} ":" got_path

    ; Assume path can be safely added to 'base directory'

    StrCpy ${L_DATA} ${L_BASEDIR}\${L_DATA}
    Goto got_path

  source_folder:
    StrCpy ${L_DATA} ${L_BASEDIR}
    Goto got_path

  sub_folder:
    StrCpy ${L_DATA} ${L_DATA} "" 2
    StrCpy ${L_DATA} ${L_BASEDIR}\${L_DATA}
    Goto got_path

  relative_folder:
    StrCpy ${L_RESULT} ${L_BASEDIR}

  relative_again:
    StrCpy ${L_DATA} ${L_DATA} "" 3
    Push ${L_RESULT}
    Call ${UN}GetParent
    Pop ${L_RESULT}
    StrCpy ${L_TEMP} ${L_DATA} 3
    StrCmp ${L_TEMP} "..\" relative_again
    StrCpy ${L_DATA} ${L_RESULT}\${L_DATA}
    Goto got_path

  basedir_drive:
    StrCpy ${L_TEMP} ${L_BASEDIR} 2
    StrCpy ${L_DATA} ${L_TEMP}${L_DATA}

  got_path:
    Pop ${L_TEMP}
    Pop ${L_RESULT}
    Pop ${L_BASEDIR}
    Exch ${L_DATA}  ; place full path to the data directory on top of the stack

    !undef L_BASEDIR
    !undef L_DATA
    !undef L_RESULT
    !undef L_TEMP

  FunctionEnd
!macroend

!ifdef ADDUSER | RUNPOPFILE
    #--------------------------------------------------------------------------
    # Installer Function: GetDataPath
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro GetDataPath ""
!endif

#--------------------------------------------------------------------------
# Uninstaller Function: un.GetDataPath
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro GetDataPath "un."


#--------------------------------------------------------------------------
# Macro: GetDateStamp
#
# The installation process and the uninstall process may need a function which uses the
# local time from Windows to generate a date stamp (eg '08-Dec-2003'). This macro makes
# maintenance easier by ensuring that both processes use identical functions, with
# the only difference being their names.
#
# NOTE:
# The !insertmacro GetDateStamp "" and !insertmacro GetDateStamp "un." commands are included
# in this file so the NSIS script and/or other library functions in 'pfi-library.nsh' can use
# 'Call GetDateStamp' and 'Call un.GetDateStamp' without additional preparation.
#
# Inputs:
#         (none)
# Outputs:
#         (top of stack)     - string holding current date (eg '07-Dec-2003')
#
# Usage (after macro has been 'inserted'):
#
#         Call un.GetDateStamp
#         Pop $R9
#
#         ($R9 now holds a string like '07-Dec-2003')
#--------------------------------------------------------------------------

!macro GetDateStamp UN
  Function ${UN}GetDateStamp

    !define L_DATESTAMP   $R9
    !define L_DAY         $R8
    !define L_MONTH       $R7
    !define L_YEAR        $R6

    Push ${L_DATESTAMP}
    Push ${L_DAY}
    Push ${L_MONTH}
    Push ${L_YEAR}

    Call ${UN}GetLocalTime
    Pop ${L_YEAR}
    Pop ${L_MONTH}
    Pop ${L_DAY}          ; ignore day of week
    Pop ${L_DAY}
    Pop ${L_DATESTAMP}    ; ignore hours
    Pop ${L_DATESTAMP}    ; ignore minutes
    Pop ${L_DATESTAMP}    ; ignore seconds
    Pop ${L_DATESTAMP}    ; ignore milliseconds

    IntCmp ${L_DAY} 10 +2 0 +2
    StrCpy ${L_DAY} "0${L_DAY}"

    StrCmp ${L_MONTH} 1 0 +3
    StrCpy ${L_MONTH} Jan
    Goto AssembleStamp

    StrCmp ${L_MONTH} 2 0 +3
    StrCpy ${L_MONTH} Feb
    Goto AssembleStamp

    StrCmp ${L_MONTH} 3 0 +3
    StrCpy ${L_MONTH} Mar
    Goto AssembleStamp

    StrCmp ${L_MONTH} 4 0 +3
    StrCpy ${L_MONTH} Apr
    Goto AssembleStamp

    StrCmp ${L_MONTH} 5 0 +3
    StrCpy ${L_MONTH} May
    Goto AssembleStamp

    StrCmp ${L_MONTH} 6 0 +3
    StrCpy ${L_MONTH} Jun
    Goto AssembleStamp

    StrCmp ${L_MONTH} 7 0 +3
    StrCpy ${L_MONTH} Jul
    Goto AssembleStamp

    StrCmp ${L_MONTH} 8 0 +3
    StrCpy ${L_MONTH} Aug
    Goto AssembleStamp

    StrCmp ${L_MONTH} 9 0 +3
    StrCpy ${L_MONTH} Sep
    Goto AssembleStamp

    StrCmp ${L_MONTH} 10 0 +3
    StrCpy ${L_MONTH} Oct
    Goto AssembleStamp

    StrCmp ${L_MONTH} 11 0 +3
    StrCpy ${L_MONTH} Nov
    Goto AssembleStamp

    StrCmp ${L_MONTH} 12 0 +2
    StrCpy ${L_MONTH} Dec

  AssembleStamp:
    StrCpy ${L_DATESTAMP} "${L_DAY}-${L_MONTH}-${L_YEAR}"

    Pop ${L_YEAR}
    Pop ${L_MONTH}
    Pop ${L_DAY}
    Exch ${L_DATESTAMP}

    !undef L_DATESTAMP
    !undef L_DAY
    !undef L_MONTH
    !undef L_YEAR

  FunctionEnd
!macroend

#--------------------------------------------------------------------------
# Installer Function: GetDateStamp
#
# This function is used during the installation process
#--------------------------------------------------------------------------

;!insertmacro GetDateStamp ""

#--------------------------------------------------------------------------
# Uninstaller Function: un.GetDateStamp
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro GetDateStamp "un."


#--------------------------------------------------------------------------
# Macro: GetDateTimeStamp
#
# The installation process and the uninstall process may need a function which returns a
# string with the current date and time (using the current time from Windows). This macro
# makes maintenance easier by ensuring that both processes use identical functions, with
# the only difference being their names.
#
# NOTE:
# The !insertmacro GetDateTimeStamp "" and !insertmacro GetDateTimeStamp "un." commands are
# included in this file so the NSIS script and/or other library functions in 'pfi-library.nsh'
# can use 'Call GetDateTimeStamp' & 'Call un.GetDateTimeStamp' without additional preparation.
#
# Inputs:
#         (none)
# Outputs:
#         (top of stack)     - string with current date and time (eg '08-Dec-2003 @ 23:01:59')
#
# Usage (after macro has been 'inserted'):
#
#         Call GetDateTimeStamp
#         Pop $R9
#
#         ($R9 now holds a string like '08-Dec-2003 @ 23:01:59')
#--------------------------------------------------------------------------

!macro GetDateTimeStamp UN
  Function ${UN}GetDateTimeStamp

    !define L_DATETIMESTAMP   $R9
    !define L_DAY             $R8
    !define L_MONTH           $R7
    !define L_YEAR            $R6
    !define L_HOURS           $R5
    !define L_MINUTES         $R4
    !define L_SECONDS         $R3

    Push ${L_DATETIMESTAMP}
    Push ${L_DAY}
    Push ${L_MONTH}
    Push ${L_YEAR}
    Push ${L_HOURS}
    Push ${L_MINUTES}
    Push ${L_SECONDS}

    Call ${UN}GetLocalTime
    Pop ${L_YEAR}
    Pop ${L_MONTH}
    Pop ${L_DAY}              ; ignore day of week
    Pop ${L_DAY}
    Pop ${L_HOURS}
    Pop ${L_MINUTES}
    Pop ${L_SECONDS}
    Pop ${L_DATETIMESTAMP}    ; ignore milliseconds

    IntCmp ${L_DAY} 10 +2 0 +2
    StrCpy ${L_DAY} "0${L_DAY}"

    StrCmp ${L_MONTH} 1 0 +3
    StrCpy ${L_MONTH} Jan
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 2 0 +3
    StrCpy ${L_MONTH} Feb
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 3 0 +3
    StrCpy ${L_MONTH} Mar
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 4 0 +3
    StrCpy ${L_MONTH} Apr
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 5 0 +3
    StrCpy ${L_MONTH} May
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 6 0 +3
    StrCpy ${L_MONTH} Jun
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 7 0 +3
    StrCpy ${L_MONTH} Jul
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 8 0 +3
    StrCpy ${L_MONTH} Aug
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 9 0 +3
    StrCpy ${L_MONTH} Sep
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 10 0 +3
    StrCpy ${L_MONTH} Oct
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 11 0 +3
    StrCpy ${L_MONTH} Nov
    Goto DoubleDigitTime

    StrCmp ${L_MONTH} 12 0 +2
    StrCpy ${L_MONTH} Dec

  DoubleDigitTime:
    IntCmp ${L_HOURS} 10 +2 0 +2
    StrCpy ${L_HOURS} "0${L_HOURS}"

    IntCmp ${L_MINUTES} 10 +2 0 +2
    StrCpy ${L_MINUTES} "0${L_MINUTES}"

    IntCmp ${L_SECONDS} 10 +2 0 +2
    StrCpy ${L_SECONDS} "0${L_SECONDS}"

    StrCpy ${L_DATETIMESTAMP} "${L_DAY}-${L_MONTH}-${L_YEAR} @ ${L_HOURS}:${L_MINUTES}:${L_SECONDS}"

    Pop ${L_SECONDS}
    Pop ${L_MINUTES}
    Pop ${L_HOURS}
    Pop ${L_YEAR}
    Pop ${L_MONTH}
    Pop ${L_DAY}
    Exch ${L_DATETIMESTAMP}

    !undef L_DATETIMESTAMP
    !undef L_DAY
    !undef L_MONTH
    !undef L_YEAR
    !undef L_HOURS
    !undef L_MINUTES
    !undef L_SECONDS

  FunctionEnd
!macroend

!ifdef ADDUSER | MSGCAPTURE | TRANSLATOR_AUW
    #--------------------------------------------------------------------------
    # Installer Function: GetDateTimeStamp
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro GetDateTimeStamp ""
!endif

!ifdef ADDUSER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.GetDateTimeStamp
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro GetDateTimeStamp "un."
!endif


#--------------------------------------------------------------------------
# Macro: GetFileSize
#
# The installation process and the uninstall process may need a function which gets the
# size (in bytes) of a particular file. This macro makes maintenance easier by ensuring
# that both processes use identical functions, with the only difference being their names.
#
# If the specified file is not found, the function returns -1
#
# NOTE:
# The !insertmacro GetFileSize "" and !insertmacro GetFileSize "un." commands are included
# in this file so the NSIS script and/or other library functions in 'pfi-library.nsh' can use
# 'Call GetFileSize' and 'Call un.GetFileSize' without additional preparation.
#
# Inputs:
#         (top of stack)     - filename of file to be checked
# Outputs:
#         (top of stack)     - length of the file (in bytes)
#                              or '-1' if file not found
#                              or '-2' if error occurred
#
# Usage (after macro has been 'inserted'):
#
#         Push "corpus\spam\table"
#         Call GetFileSize
#         Pop $R0
#
#         ($R0 now holds the size (in bytes) of the 'spam' bucket's 'table' file)
#
#--------------------------------------------------------------------------

!macro GetFileSize UN
    Function ${UN}GetFileSize

      !define L_FILENAME  $R9
      !define L_RESULT    $R8

      Exch ${L_FILENAME}
      Push ${L_RESULT}
      Exch

      IfFileExists ${L_FILENAME} find_size
      StrCpy ${L_RESULT} "-1"
      Goto exit

    find_size:
      ClearErrors
      FileOpen ${L_RESULT} ${L_FILENAME} r
      FileSeek ${L_RESULT} 0 END ${L_FILENAME}
      FileClose ${L_RESULT}
      IfErrors 0 return_size
      StrCpy ${L_RESULT} "-2"
      Goto exit

    return_size:
      StrCpy ${L_RESULT} ${L_FILENAME}

    exit:
      Pop ${L_FILENAME}
      Exch ${L_RESULT}

      !undef L_FILENAME
      !undef L_RESULT

    FunctionEnd
!macroend

!ifndef MSGCAPTURE & RUNPOPFILE & TRANSLATOR & TRANSLATOR_AUW
    #--------------------------------------------------------------------------
    # Installer Function: GetFileSize
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro GetFileSize ""
!endif

!ifndef MSGCAPTURE & RUNPOPFILE & TRANSLATOR & TRANSLATOR_AUW
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.GetFileSize
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro GetFileSize "un."
!endif


#--------------------------------------------------------------------------
# Macro: GetLocalTime
#
# The installation process and the uninstall process may need a function which gets the
# local time from Windows (to generate data and/or time stamps, etc). This macro makes
# maintenance easier by ensuring that both processes use identical functions, with
# the only difference being their names.
#
# Normally this function will be used by a higher level one which returns a suitable string.
#
# NOTE:
# The !insertmacro GetLocalTime "" and !insertmacro GetLocalTime "un." commands are included
# in this file so the NSIS script and/or other library functions in 'pfi-library.nsh' can use
# 'Call GetLocalTime' and 'Call un.GetLocalTime' without additional preparation.
#
# Inputs:
#         (none)
# Outputs:
#         (top of stack)     - year         (4-digits)
#         (top of stack - 1) - month        (1 to 12)
#         (top of stack - 2) - day of week  (0 = Sunday, 6 = Saturday)
#         (top of stack - 3) - day          (1 - 31)
#         (top of stack - 4) - hours        (0 - 23)
#         (top of stack - 5) - minutes      (0 - 59)
#         (top of stack - 6) - seconds      (0 - 59)
#         (top of stack - 7) - milliseconds (0 - 999)
#
# Usage (after macro has been 'inserted'):
#
#         Call GetLocalTime
#         Pop $Year
#         Pop $Month
#         Pop $DayOfWeek
#         Pop $Day
#         Pop $Hours
#         Pop $Minutes
#         Pop $Seconds
#         Pop $Milliseconds
#--------------------------------------------------------------------------

!macro GetLocalTime UN
  Function ${UN}GetLocalTime

    # Preparing Variables

    Push $1
    Push $2
    Push $3
    Push $4
    Push $5
    Push $6
    Push $7
    Push $8

    # Calling the Function GetLocalTime from Kernel32.dll

    System::Call '*(&i2, &i2, &i2, &i2, &i2, &i2, &i2, &i2) i .r1'
    System::Call 'kernel32::GetLocalTime(i) i(r1)'
    System::Call '*$1(&i2, &i2, &i2, &i2, &i2, &i2, &i2, &i2)(.r8, .r7, .r6, .r5, .r4, .r3, .r2, .r1)'

    # Returning to User

    Exch $8
    Exch
    Exch $7
    Exch
    Exch 2
    Exch $6
    Exch 2
    Exch 3
    Exch $5
    Exch 3
    Exch 4
    Exch $4
    Exch 4
    Exch 5
    Exch $3
    Exch 5
    Exch 6
    Exch $2
    Exch 6
    Exch 7
    Exch $1
    Exch 7

  FunctionEnd
!macroend

!ifdef ADDUSER | MSGCAPTURE | TRANSLATOR_AUW
    #--------------------------------------------------------------------------
    # Installer Function: GetLocalTime
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro GetLocalTime ""
!endif

!ifdef ADDUSER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.GetLocalTime
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro GetLocalTime "un."
!endif


#--------------------------------------------------------------------------
# Macro: GetParent
#
# The installation process and the uninstall process may both use a function which extracts the
# parent directory from a given path. This macro makes maintenance easier by ensuring that both
# processes use identical functions, with the only difference being their names.
#
# NB: The path is assumed to use backslashes (\)
#
# NOTE:
# The !insertmacro GetParent "" and !insertmacro GetParent "un." commands are included
# in this file so the NSIS script can use 'Call GetParent' and 'Call un.GetParent'
# without additional preparation.
#
# Inputs:
#         (top of stack)          - string containing a path (e.g. C:\A\B\C)
#
# Outputs:
#         (top of stack)          - the parent part of the input string (e.g. C:\A\B)
#
# Usage (after macro has been 'inserted'):
#
#         Push "C:\Program Files\Directory\Whatever"
#         Call un.GetParent
#         Pop $R0
#
#         ($R0 at this point is ""C:\Program Files\Directory")
#
#--------------------------------------------------------------------------

!macro GetParent UN
  Function ${UN}GetParent
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
!macroend

!ifdef ADDUSER | RUNPOPFILE
    #--------------------------------------------------------------------------
    # Installer Function: GetParent
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro GetParent ""
!endif

#--------------------------------------------------------------------------
# Uninstaller Function: un.GetParent
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro GetParent "un."


#--------------------------------------------------------------------------
# Macro: GetTimeStamp
#
# The installation process and the uninstall process may need a function which uses the
# local time from Windows to generate a time stamp (eg '01:23:45'). This macro makes
# maintenance easier by ensuring that both processes use identical functions, with
# the only difference being their names.
#
# NOTE:
# The !insertmacro GetTimeStamp "" and !insertmacro GetTimeStamp "un." commands are included
# in this file so the NSIS script and/or other library functions in 'pfi-library.nsh' can use
# 'Call GetTimeStamp' and 'Call un.GetTimeStamp' without additional preparation.
#
# Inputs:
#         (none)
# Outputs:
#         (top of stack)     - string holding current time (eg '23:01:59')
#
# Usage (after macro has been 'inserted'):
#
#         Call GetTimeStamp
#         Pop $R9
#
#         ($R9 now holds a string like '23:01:59')
#--------------------------------------------------------------------------

!macro GetTimeStamp UN
  Function ${UN}GetTimeStamp

    !define L_TIMESTAMP   $R9
    !define L_HOURS       $R8
    !define L_MINUTES     $R7
    !define L_SECONDS     $R6

    Push ${L_TIMESTAMP}
    Push ${L_HOURS}
    Push ${L_MINUTES}
    Push ${L_SECONDS}

    Call ${UN}GetLocalTIme
    Pop ${L_TIMESTAMP}    ; ignore year
    Pop ${L_TIMESTAMP}    ; ignore month
    Pop ${L_TIMESTAMP}    ; ignore day of week
    Pop ${L_TIMESTAMP}    ; ignore day
    Pop ${L_HOURS}
    Pop ${L_MINUTES}
    Pop ${L_SECONDS}
    Pop ${L_TIMESTAMP}    ; ignore milliseconds

    IntCmp ${L_HOURS} 10 +2 0 +2
    StrCpy ${L_HOURS} "0${L_HOURS}"

    IntCmp ${L_MINUTES} 10 +2 0 +2
    StrCpy ${L_MINUTES} "0${L_MINUTES}"

    IntCmp ${L_SECONDS} 10 +2 0 +2
    StrCpy ${L_SECONDS} "0${L_SECONDS}"

    StrCpy ${L_TIMESTAMP} "${L_HOURS}:${L_MINUTES}:${L_SECONDS}"

    Pop ${L_SECONDS}
    Pop ${L_MINUTES}
    Pop ${L_HOURS}
    Exch ${L_TIMESTAMP}

    !undef L_TIMESTAMP
    !undef L_HOURS
    !undef L_MINUTES
    !undef L_SECONDS

  FunctionEnd
!macroend

#--------------------------------------------------------------------------
# Installer Function: GetTimeStamp
#
# This function is used during the installation process
#--------------------------------------------------------------------------

;!insertmacro GetTimeStamp ""

#--------------------------------------------------------------------------
# Uninstaller Function: un.GetTimeStamp
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro GetTimeStamp "un."


#--------------------------------------------------------------------------
# Macro: ServiceCall
#
# The installation process and the uninstall process may both need a function which interfaces
# with the Windows Service Control Manager (SCM).  This macro makes maintenance easier by
# ensuring that both processes use identical functions, with the only difference being their
# names.
#
# NOTE: This version only supports a subset of the available Service Control Manager actions.
#
# NOTE:
# The !insertmacro ServiceCall "" and !insertmacro ServiceCall "un." commands are included
# in this file so the NSIS script can use 'Call ServiceCall' and 'Call un.ServiceCall'
# without additional preparation.
#
# Inputs:
#         (top of stack)       - action required (only the following action is supported):
#                                   status     - returns status of the named service
#
#         (top of stack - 1)   - service name (normally 'POPFile')
#
# Outputs:
#         (top of stack)       - string containing a result code. Result codes depend upon the
#                                value of the 'action required' input parameter:
#
#                                'status' action result codes:
#                                   scmerror          - unable to open service database (Win9x?)
#                                   openerror         - unable to get a handle to the service
#
#                                   running           - service is running
#                                   stopped           - service is stopped
#                                   start_pending     - the service is starting
#                                   stop_pending      - the service is stopping
#                                   continue_pending  - the service continue is pending
#                                   pause_pending     - the service pause is pending
#                                   paused            - the service is paused
#
#                                   unknown           - (the response didn't match any of above)
#
#                                result code for all other action requests:
#                                   unsupportedaction - an unsupported action was requested
#
# Usage (after macro has been 'inserted'):
#
#         Push "status"
#         Push "POPFile"
#         Call un.ServiceCall
#         Pop $R0
#
#         (if $R0 at this point is "running" then POPFile is running as a Windows service)
#
#--------------------------------------------------------------------------

!macro ServiceCall UN

  !ifndef PFI_SERVICE_DEFINES
      !define PFI_SERVICE_DEFINES

      !define SC_MANAGER_ALL_ACCESS    0x3F
      !define SERVICE_ALL_ACCESS    0xF01FF

      !define SERVICE_STOPPED           0x1
      !define SERVICE_START_PENDING     0x2
      !define SERVICE_STOP_PENDING      0x3
      !define SERVICE_RUNNING           0x4
      !define SERVICE_CONTINUE_PENDING  0x5
      !define SERVICE_PAUSE_PENDING     0x6
      !define SERVICE_PAUSED            0x7
  !endif

  Function ${UN}ServiceCall

    Push $0   ; used to return the result
    Push $2
    Push $3
    Push $4   ; OpenSCManager handle
    Push $5   ; OpenService handle
    Push $6
    Push $7
    Exch 7
    Pop $2    ; service name
    Exch 7
    Pop $3    ; action required

    StrCmp $3 "status" 0 unsupported_action

    System::Call 'advapi32::OpenSCManagerA(n, n, i ${SC_MANAGER_ALL_ACCESS}) i.r4'
    IntCmp $4 0 scm_error

    StrCpy $0 "openerr"
    System::Call 'advapi32::OpenServiceA(i r4, t r2, i ${SERVICE_ALL_ACCESS}) i.r5'
    IntCmp $5 0 close_OpenSCM_handle

#  action_status:
    Push $R1
    System::Call '*(i,i,i,i,i,i,i) i.R1'
    System::Call 'advapi32::QueryServiceStatus(i r5, i $R1) i'
    System::Call '*$R1(i, i .r6)'
    System::Free $R1
    Pop $R1
    IntFmt $6 "0x%X" $6
    StrCpy $0 "running"
    IntCmp $6 ${SERVICE_RUNNING} closehandles
    StrCpy $0 "stopped"
    IntCmp $6 ${SERVICE_STOPPED} closehandles
    StrCpy $0 "start_pending"
    IntCmp $6 ${SERVICE_START_PENDING} closehandles
    StrCpy $0 "stop_pending"
    IntCmp $6 ${SERVICE_STOP_PENDING} closehandles
    StrCpy $0 "continue_pending"
    IntCmp $6 ${SERVICE_CONTINUE_PENDING} closehandles
    StrCpy $0 "pause_pending"
    IntCmp $6 ${SERVICE_PAUSE_PENDING} closehandles
    StrCpy $0 "paused"
    IntCmp $6 ${SERVICE_PAUSED} closehandles
    StrCpy $0 "unknown"
    Goto closehandles

  unsupported_action:
    StrCpy $0 "unsupportedaction"
    DetailPrint "'ServiceCall' unsupported action ($3)"
    Goto return_result

  scm_error:
    StrCpy $0 "scmerror"
    DetailPrint "'ServiceCall' failed (Win9x system?)"
    Goto return_result

  closehandles:
    IntCmp $5 0 close_OpenSCM_handle
    System::Call 'advapi32::CloseServiceHandle(i r5) n'

  close_OpenSCM_handle:
    IntCmp $4 0 display_result
    System::Call 'advapi32::CloseServiceHandle(i r4) n'

  display_result:
    DetailPrint "$2 'ServiceCall' response: $0"

  return_result:
    Pop $5
    Pop $4
    Pop $3
    Pop $2
    Exch 2
    Pop $6
    Pop $7
    Exch $0           ; stack = result code string
  FunctionEnd
!macroend

!ifndef MSGCAPTURE & RUNPOPFILE & TRANSLATOR & TRANSLATOR_AUW
  #--------------------------------------------------------------------------
  # Installer Function: ServiceCall
  #
  # This function is used during the installation process
  #--------------------------------------------------------------------------

  !insertmacro ServiceCall ""

  #--------------------------------------------------------------------------
  # Uninstaller Function: un.ServiceCall
  #
  # This function is used during the uninstall process
  #--------------------------------------------------------------------------

  !insertmacro ServiceCall "un."
!endif


#--------------------------------------------------------------------------
# Macro: ServiceRunning
#
# The installation process and the uninstall process may both need a function which checks
# if a particular Windows service is running. This macro makes maintenance easier by ensuring
# that both processes use identical functions, with the only difference being their names.
#
# NOTE:
# The !insertmacro ServiceRunning "" and !insertmacro ServiceRunning "un." commands are included
# in this file so the NSIS script can use 'Call ServiceRunning' and 'Call un.ServiceRunning'
# without additional preparation.
#
# Inputs:
#         (top of stack)       - name of the Windows Service to be checked (normally "POPFile")
#
# Outputs:
#         (top of stack)       - string containing one of the following result codes:
#                                   true           - service is running
#                                   false          - service is not running
#
# Usage (after macro has been 'inserted'):
#
#         Push "POPFile"
#         Call ServiceRunning
#         Pop $R0
#
#         (if $R0 at this point is "true" then POPFile is running as a Windows service)
#
#--------------------------------------------------------------------------

!macro ServiceRunning UN
  Function ${UN}ServiceRunning

    !define L_RESULT    $R9

    Push ${L_RESULT}
    Exch
    Push "status"
    Exch
    Call ${UN}ServiceCall     ; uses 2 parameters from top of stack (top = servicename, action)
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "running" 0 not_running
    StrCpy ${L_RESULT} "true"
    Goto exit

  not_running:
    StrCpy ${L_RESULT} "false"

  exit:
    Exch ${L_RESULT}          ; return "true" or "false" on top of stack

    !undef L_RESULT

  FunctionEnd
!macroend

!ifndef MSGCAPTURE & RUNPOPFILE & TRANSLATOR & TRANSLATOR_AUW
  #--------------------------------------------------------------------------
  # Installer Function: ServiceRunning
  #
  # This function is used during the installation process
  #--------------------------------------------------------------------------

  !insertmacro ServiceRunning ""

  #--------------------------------------------------------------------------
  # Uninstaller Function: un.ServiceRunning
  #
  # This function is used during the uninstall process
  #--------------------------------------------------------------------------

  !insertmacro ServiceRunning "un."
!endif


#--------------------------------------------------------------------------
# Macro: ServiceStatus
#
# The installation process and the uninstall process may both need a function which checks
# the status of a particular Windows Service. This macro makes maintenance easier by ensuring
# that both processes use identical functions, with the only difference being their names.
#
# NOTE:
# The !insertmacro ServiceStatus "" and !insertmacro ServiceStatus "un." commands are included
# in this file so the NSIS script can use 'Call ServiceStatus' and 'Call un.ServiceStatus'
# without additional preparation.
#
# Inputs:
#         (top of stack)       - name of the Windows Service to be checked (normally "POPFile")
#
# Outputs:
#         (top of stack)       - string containing one of the following result codes:
#
#                                   scmerror          - unable to open service database (Win9x?)
#                                   openerror         - unable to get a handle to the service
#
#                                   running           - service is running
#                                   stopped           - service is stopped
#                                   start_pending     - the service is starting
#                                   stop_pending      - the service is stopping
#                                   continue_pending  - the service continue is pending
#                                   pause_pending     - the service pause is pending
#                                   paused            - the service is paused
#
#                                   unknown           - (the response didn't match any of above)
#
# Usage (after macro has been 'inserted'):
#
#         Push "POPFile"
#         Call ServiceStatus
#         Pop $R0
#
#         (if $R0 at this point is "running" then POPFile is running as a Windows service)
#
#--------------------------------------------------------------------------

!macro ServiceStatus UN
  Function ${UN}ServiceStatus

    Push "status"            ; action required
    Exch                     ; top of stack = servicename, action required
    Call ${UN}ServiceCall

  FunctionEnd
!macroend

#--------------------------------------------------------------------------
# Installer Function: ServiceStatus
#
# This function is used during the installation process
#--------------------------------------------------------------------------

;!insertmacro ServiceStatus ""

#--------------------------------------------------------------------------
# Uninstaller Function: un.ServiceStatus
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro ServiceStatus "un."


#--------------------------------------------------------------------------
# Macro: ShutdownViaUI
#
# The installation process and the uninstall process may both use a function which attempts to
# shutdown POPFile using the User Interface (UI) invisibly (i.e. no browser window is used).
# This macro makes maintenance easier by ensuring that both processes use identical functions,
# with the only difference being their names.
#
# To avoid the need to parse the HTML page downloaded by NSISdl, we call NSISdl again if the
# first call succeeds. If the second call succeeds, we assume the UI is password protected.
# As a debugging aid, we don't overwrite the first HTML file with the result of the second call.
#
# NOTE:
# The !insertmacro ShutdownViaUI "" and !insertmacro ShutdownViaUI "un." commands are included
# in this file so the NSIS script can use 'Call ShutdownViaUI' and 'Call un.ShutdownViaUI'
# without additional preparation.
#
# Inputs:
#         (top of stack)       - UI port to be used when issuing the shutdown request
#
# Outputs:
#         (top of stack)       - string containing one of the following result codes:
#
#                                   "success"    (meaning UI shutdown request appeared to work)
#
#                                   "failure"    (meaning UI shutdown request failed)
#
#                                   "password?"  (meaning failure: UI may be password protected)
#
#                                   "badport"    (meaning failure: invalid UI port supplied)
#
# Usage (after macro has been 'inserted'):
#
#         Push "8080"
#         Call ShutdownViaUI
#         Pop $R0
#
#         (if $R0 at this point is "password?" then POPFile is still running)
#
#--------------------------------------------------------------------------

!macro ShutdownViaUI UN
  Function ${UN}ShutdownViaUI

    ;--------------------------------------------------------------------------
    ; Override the default timeout for NSISdl requests (specifies timeout in milliseconds)

    !define C_SVU_DLTIMEOUT       /TIMEOUT=10000

    ; Delay between the two shutdown requests (in milliseconds)

    !define C_SVU_DLGAP           2000
    ;--------------------------------------------------------------------------

    !define L_RESULT    $R9
    !define L_UIPORT    $R8

    Exch ${L_UIPORT}
    Push ${L_RESULT}
    Exch

    StrCmp ${L_UIPORT} "" badport
    Push ${L_UIPORT}
    Call ${UN}StrCheckDecimal
    Pop ${L_UIPORT}
    StrCmp ${L_UIPORT} "" badport
    IntCmp ${L_UIPORT} 1 port_ok badport
    IntCmp ${L_UIPORT} 65535 port_ok port_ok

  badport:
    StrCpy ${L_RESULT} "badport"
    Goto exit

  port_ok:
    NSISdl::download_quiet ${C_SVU_DLTIMEOUT} http://127.0.0.1:${L_UIPORT}/shutdown "$PLUGINSDIR\shutdown_1.htm"
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "success" try_again
    StrCpy ${L_RESULT} "failure"
    Goto exit

  try_again:
    Sleep ${C_SVU_DLGAP}
    NSISdl::download_quiet ${C_SVU_DLTIMEOUT} http://127.0.0.1:${L_UIPORT}/shutdown "$PLUGINSDIR\shutdown_2.htm"
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "success" 0 shutdown_ok
    Push "$PLUGINSDIR\shutdown_2.htm"
    Call ${UN}GetFileSize
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} 0 shutdown_ok
    StrCpy ${L_RESULT} "password?"
    Goto exit

  shutdown_ok:
    StrCpy ${L_RESULT} "success"

  exit:
    Pop ${L_UIPORT}
    Exch ${L_RESULT}

    !undef C_SVU_DLTIMEOUT
    !undef C_SVU_DLGAP

    !undef L_RESULT
    !undef L_UIPORT

  FunctionEnd
!macroend

!ifndef MSGCAPTURE & RUNPOPFILE & TRANSLATOR & TRANSLATOR_AUW
    #--------------------------------------------------------------------------
    # Installer Function: ShutdownViaUI
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro ShutdownViaUI ""

    #--------------------------------------------------------------------------
    # Uninstaller Function: un.ShutdownViaUI
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro ShutdownViaUI "un."
!endif


#--------------------------------------------------------------------------
# Macro: StrBackSlash
#
# The installation process and the uninstall process may both use a function which converts all
# slashes in a string into backslashes. This macro makes maintenance easier by ensuring that
# both processes use identical functions, with the only difference being their names.
#
# NOTE:
# The !insertmacro StrBackSlash "" and !insertmacro StrBackSlash "un." commands are included
# in this file so the NSIS script can use 'Call StrBackSlash' and 'Call un.StrBackSlash'
# without additional preparation.
#
# Inputs:
#         (top of stack)            - string containing slashes (e.g. "C:/This/and/That")
#
# Outputs:
#         (top of stack)            - string containing backslashes (e.g. "C:\This\and\That")
#
# Usage (after macro has been 'inserted'):
#
#         Push "C:/Program Files/Directory/Whatever"
#         Call StrBackSlash
#         Pop $R0
#
#         ($R0 at this point is "C:\Program Files\Directory\Whatever")
#
#--------------------------------------------------------------------------

!macro StrBackSlash UN
  Function ${UN}StrBackSlash
    Exch $R0    ; Input string with slashes
    Push $R1    ; Output string using backslashes
    Push $R2    ; Current character

    StrCpy $R1 ""
    StrCmp $R0 $R1 nothing_to_do

  loop:
    StrCpy $R2 $R0 1
    StrCpy $R0 $R0 "" 1
    StrCmp $R2 "/" found
    StrCpy $R1 "$R1$R2"
    StrCmp $R0 "" done loop

  found:
    StrCpy $R1 "$R1\"
    StrCmp $R0 "" done loop

  done:
    StrCpy $R0 $R1

  nothing_to_do:
    Pop $R2
    Pop $R1
    Exch $R0
  FunctionEnd
!macroend

!ifdef ADDUSER | RUNPOPFILE
    #--------------------------------------------------------------------------
    # Installer Function: StrBackSlash
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro StrBackSlash ""
!endif

#--------------------------------------------------------------------------
# Uninstaller Function: un.StrBackSlash
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro StrBackSlash "un."


#--------------------------------------------------------------------------
# Macro: StrCheckDecimal
#
# The installation process and the uninstall process may both use a function which checks if
# a given string contains a decimal number. This macro makes maintenance easier by ensuring
# that both processes use identical functions, with the only difference being their names.
#
# The 'StrCheckDecimal' and 'un.StrCheckDecimal' functions check that a given string contains
# only the digits 0 to 9. (if the string contains any invalid characters, "" is returned)
#
# NOTE:
# The !insertmacro StrCheckDecimal "" and !insertmacro StrCheckDecimal "un." commands are
# included in this file so the NSIS script can use 'Call StrCheckDecimal' and
# 'Call un.StrCheckDecimal' without additional preparation.
#
# Inputs:
#         (top of stack)   - string which may contain a decimal number
#
# Outputs:
#         (top of stack)   - the input string (if valid) or "" (if invalid)
#
# Usage (after macro has been 'inserted'):
#
#         Push "12345"
#         Call un.StrCheckDecimal
#         Pop $R0
#         ($R0 at this point is "12345")
#
#--------------------------------------------------------------------------

!macro StrCheckDecimal UN
  Function ${UN}StrCheckDecimal

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
!macroend

!ifndef RUNPOPFILE & TRANSLATOR
    #--------------------------------------------------------------------------
    # Installer Function: StrCheckDecimal
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro StrCheckDecimal ""
!endif

!ifndef MSGCAPTURE & RUNPOPFILE & TRANSLATOR & TRANSLATOR_AUW
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.StrCheckDecimal
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro StrCheckDecimal "un."
!endif


#--------------------------------------------------------------------------
# Macro: StrStr
#
# The installation process and the uninstall process may both use a function which checks if
# a given string appears inside another string. This macro makes maintenance easier by ensuring
# that both processes use identical functions, with the only difference being their names.
#
# NOTE:
# The !insertmacro StrStr "" and !insertmacro StrStr "un." commands are included in this file
# so the NSIS script can use 'Call StrStr' and 'Call un.StrStr' without additional preparation.
#
# Search for matching string
#
# Inputs:
#         (top of stack)     - the string to be found (needle)
#         (top of stack - 1) - the string to be searched (haystack)
# Outputs:
#         (top of stack)     - string starting with the match, if any
#
# Usage (after macro has been 'inserted'):
#
#         Push "this is a long string"
#         Push "long"
#         Call StrStr
#         Pop $R0
#         ($R0 at this point is "long string")
#
#--------------------------------------------------------------------------

!macro StrStr UN
  Function ${UN}StrStr

    Exch $R1    ; Make $R1 the "needle", Top of stack = old$R1, haystack
    Exch        ; Top of stack = haystack, old$R1
    Exch $R2    ; Make $R2 the "haystack", Top of stack = old$R2, old$R1

    Push $R3    ; Length of the needle
    Push $R4    ; Counter
    Push $R5    ; Temp

    StrLen $R3 $R1
    StrCpy $R4 0

  loop:
    StrCpy $R5 $R2 $R3 $R4
    StrCmp $R5 $R1 done
    StrCmp $R5 "" done
    IntOp $R4 $R4 + 1
    Goto loop

  done:
    StrCpy $R1 $R2 "" $R4

    Pop $R5
    Pop $R4
    Pop $R3

    Pop $R2
    Exch $R1
  FunctionEnd
!macroend

!ifndef MSGCAPTURE & TRANSLATOR
    #--------------------------------------------------------------------------
    # Installer Function: StrStr
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro StrStr ""
!endif

!ifndef ADDUSER & MSGCAPTURE & RUNPOPFILE & TRANSLATOR & TRANSLATOR_AUW
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.StrStr
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro StrStr "un."
!endif


#--------------------------------------------------------------------------
# Macro: TrimNewlines
#
# The installation process and the uninstall process may both use a function to trim newlines
# from lines of text. This macro makes maintenance easier by ensuring that both processes use
# identical functions, with the only difference being their names.
#
# NOTE:
# The !insertmacro TrimNewlines "" and !insertmacro TrimNewlines "un." commands are
# included in this file so the NSIS script can use 'Call TrimNewlines' and
# 'Call un.TrimNewlines' without additional preparation.
#
# Inputs:
#         (top of stack)   - string which may end with one or more newlines
#
# Outputs:
#         (top of stack)   - the input string with the trailing newlines (if any) removed
#
# Usage (after macro has been 'inserted'):
#
#         Push "whatever$\r$\n"
#         Call un.TrimNewlines
#         Pop $R0
#         ($R0 at this point is "whatever")
#
#--------------------------------------------------------------------------

!macro TrimNewlines UN
  Function ${UN}TrimNewlines
    Exch $R0
    Push $R1
    Push $R2
    StrCpy $R1 0

  loop:
    IntOp $R1 $R1 - 1
    StrCpy $R2 $R0 1 $R1
    StrCmp $R2 "$\r" loop
    StrCmp $R2 "$\n" loop
    IntOp $R1 $R1 + 1
    IntCmp $R1 0 no_trim_needed
    StrCpy $R0 $R0 $R1

  no_trim_needed:
    Pop $R2
    Pop $R1
    Exch $R0
  FunctionEnd
!macroend

!ifndef MSGCAPTURE & RUNPOPFILE & TRANSLATOR_AUW
    #--------------------------------------------------------------------------
    # Installer Function: TrimNewlines
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro TrimNewlines ""
!endif

!ifndef MSGCAPTURE & RUNPOPFILE & TRANSLATOR & TRANSLATOR_AUW
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.TrimNewlines
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro TrimNewlines "un."
!endif

#--------------------------------------------------------------------------
# Macro: WaitUntilUnlocked
#
# The installation process and the uninstall process may both use a function which waits until
# a particular executable file (an EXE file) is no longer in use. This macro makes maintenance
# easier by ensuring that both processes use identical functions, with the only difference being
# their names.
#
# The EXE file to be checked depends upon the version of POPFile in use and upon how it has been
# configured. It may take a little while for POPFile to shutdown so the installer/uninstaller
# calls this function which waits in a loop until the specified EXE file is no longer in use.
# A timeout counter is used to avoid an infinite loop.
#
# NOTE:
# The !insertmacro WaitUntilUnlocked "" and !insertmacro WaitUntilUnlocked "un." commands are
# included in this file so the NSIS script can use 'Call WaitUntilUnlocked' and
# 'Call un.WaitUntilUnlocked' without additional preparation.
#
# Inputs:
#         (top of stack)     - the full path of the EXE file to be checked
#
# Outputs:
#         (none)
#
# Usage (after macro has been 'inserted'):
#
#         Push "$INSTDIR\wperl.exe"
#         Call WaitUntilUnlocked
#
#--------------------------------------------------------------------------

!macro WaitUntilUnlocked UN
  Function ${UN}WaitUntilUnlocked
    !define L_EXE           $R9   ; full path to the EXE file which is to be monitored
    !define L_FILE_HANDLE   $R8
    !define L_TIMEOUT       $R7   ; used to avoid an infinite loop

    ;-----------------------------------------------------------
    ; Timeout loop counter start value (counts down to 0)

    !ifndef C_SHUTDOWN_LIMIT
      !define C_SHUTDOWN_LIMIT    20
    !endif

    ; Delay (in milliseconds) used inside the timeout loop

    !ifndef C_SHUTDOWN_DELAY
      !define C_SHUTDOWN_DELAY    1000
    !endif
    ;-----------------------------------------------------------

    Exch ${L_EXE}
    Push ${L_FILE_HANDLE}
    Push ${L_TIMEOUT}

    IfFileExists "${L_EXE}" 0 exit_now
    SetFileAttributes "${L_EXE}" NORMAL
    StrCpy ${L_TIMEOUT} ${C_SHUTDOWN_LIMIT}

  check_if_unlocked:
    Sleep ${C_SHUTDOWN_DELAY}
    ClearErrors
    FileOpen ${L_FILE_HANDLE} "${L_EXE}" a
    FileClose ${L_FILE_HANDLE}
    IfErrors 0 exit_now
    IntOp ${L_TIMEOUT} ${L_TIMEOUT} - 1
    IntCmp ${L_TIMEOUT} 0 exit_now exit_now check_if_unlocked

   exit_now:
    Pop ${L_TIMEOUT}
    Pop ${L_FILE_HANDLE}
    Pop ${L_EXE}

    !undef L_EXE
    !undef L_FILE_HANDLE
    !undef L_TIMEOUT
  FunctionEnd
!macroend

!ifndef MSGCAPTURE & RUNPOPFILE & TRANSLATOR & TRANSLATOR_AUW
    #--------------------------------------------------------------------------
    # Installer Function: WaitUntilUnlocked
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro WaitUntilUnlocked ""
!endif

!ifdef ADDUSER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.WaitUntilUnlocked
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro WaitUntilUnlocked "un."
!endif

#--------------------------------------------------------------------------
# End of 'pfi-library.nsh'
#--------------------------------------------------------------------------
