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
# The following symbols are used to construct the expressions defining the required subset:
#
#  (1) ADDSSL           defined in add-ons\addssl.nsi (POPFile 'SSL Setup' wizard)
#  (2) ADDUSER          defined in adduser.nsi ('Add POPFile User' wizard)
#  (3) BACKUP           defined in backup.nsi (POPFile 'User Data' Backup utility)
#  (4) INSTALLER        defined in installer.nsi (the main installer program, setup.exe)
#  (5) MSGCAPTURE       defined in msgcapture.nsi (used to capture POPFile's console messages)
#  (6) PFIDIAG          defined in test\pfidiag.nsi (helps diagnose installer-related problems)
#  (7) RESTORE          defined in restore.nsi (POPFile 'User Data' Restore utility)
#  (8) RUNPOPFILE       defined in runpopfile.nsi (simple front-end for popfile.exe)
#  (9) RUNSQLITE        defined in runsqlite.nsi (simple front-end for sqlite.exe/sqlite3.exe)
# (10) STOP_POPFILE     defined in stop_popfile.nsi (the 'POPFile Silent Shutdown' utility)
# (11) TRANSLATOR       defined in test\translator.nsi (main installer translations testbed)
# (12) TRANSLATOR_AUW   defined in test\transAUW.nsi ('Add POPFile User' translations testbed)
#--------------------------------------------------------------------------

!ifndef PFI_VERBOSE
  !verbose 3
!endif

#--------------------------------------------------------------------------
# Symbols used to avoid confusion over where the line breaks occur.
#
# ${IO_NL} is used for InstallOptions-style 'new line' sequences.
# ${MB_NL} is used for MessageBox-style 'new line' sequences.
#--------------------------------------------------------------------------

!ifndef IO_NL
  !define IO_NL     "\r\n"
!endif

!ifndef MB_NL
  !define MB_NL     "$\r$\n"
!endif

#--------------------------------------------------------------------------
# Universal POPFile Constant: the URL used to access the User Interface (UI)
#--------------------------------------------------------------------------
#
# Starting with the 0.22.0 release, the system tray icon will use "localhost"
# to access the User Interface (UI) instead of "127.0.0.1". The installer and
# PFI utilities will follow suit by using the ${C_UI_URL} universal constant
# when accessing the UI instead of hard-coded references to "127.0.0.1".
#
# Using a universal constant makes it easy to revert to "127.0.0.1" since
# every NSIS script used to access the UI has been updated to use this
# universal constant and the constant is only defined in this file.
#--------------------------------------------------------------------------

  !define C_UI_URL    "localhost"
##  !define C_UI_URL    "127.0.0.1"

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
      Delete "${FOLDER}\*.png"
      Delete "${FOLDER}\*.thtml"
      RMDir  "${FOLDER}"

    skip_${PFI_UNIQUE_ID}:

  !macroend

#--------------------------------------------------------------------------
#
# Macro used to preserve up to 3 backup copies of a file
#
# (Note: input file will be "removed" by renaming it)
#--------------------------------------------------------------------------

  ;--------------------------------------------------------------------------
  ; This version generates uses 'DetailsPrint' to generate more meaningful log entries
  ;--------------------------------------------------------------------------

  !macro BACKUP_123_DP FOLDER FILE

      !insertmacro PFI_UNIQUE_ID

      IfFileExists "${FOLDER}\${FILE}" 0 continue_${PFI_UNIQUE_ID}
      SetDetailsPrint none
      IfFileExists "${FOLDER}\${FILE}.bk1" 0 the_first_${PFI_UNIQUE_ID}
      IfFileExists "${FOLDER}\${FILE}.bk2" 0 the_second_${PFI_UNIQUE_ID}
      IfFileExists "${FOLDER}\${FILE}.bk3" 0 the_third_${PFI_UNIQUE_ID}
      Delete "${FOLDER}\${FILE}.bk3"

    the_third_${PFI_UNIQUE_ID}:
      Rename "${FOLDER}\${FILE}.bk2" "${FOLDER}\${FILE}.bk3"
      SetDetailsPrint listonly
      DetailPrint "Backup file '${FILE}.bk3' updated"
      SetDetailsPrint none

    the_second_${PFI_UNIQUE_ID}:
      Rename "${FOLDER}\${FILE}.bk1" "${FOLDER}\${FILE}.bk2"
      SetDetailsPrint listonly
      DetailPrint "Backup file '${FILE}.bk2' updated"
      SetDetailsPrint none

    the_first_${PFI_UNIQUE_ID}:
      Rename "${FOLDER}\${FILE}" "${FOLDER}\${FILE}.bk1"
      SetDetailsPrint listonly
      DetailPrint "Backup file '${FILE}.bk1' updated"

    continue_${PFI_UNIQUE_ID}:
  !macroend

  ;--------------------------------------------------------------------------
  ; This version does not include any 'DetailsPrint' instructions
  ;--------------------------------------------------------------------------

  !macro BACKUP_123 FOLDER FILE

      !insertmacro PFI_UNIQUE_ID

      IfFileExists "${FOLDER}\${FILE}" 0 continue_${PFI_UNIQUE_ID}
      IfFileExists "${FOLDER}\${FILE}.bk1" 0 the_first_${PFI_UNIQUE_ID}
      IfFileExists "${FOLDER}\${FILE}.bk2" 0 the_second_${PFI_UNIQUE_ID}
      IfFileExists "${FOLDER}\${FILE}.bk3" 0 the_third_${PFI_UNIQUE_ID}
      Delete "${FOLDER}\${FILE}.bk3"

    the_third_${PFI_UNIQUE_ID}:
      Rename "${FOLDER}\${FILE}.bk2" "${FOLDER}\${FILE}.bk3"

    the_second_${PFI_UNIQUE_ID}:
      Rename "${FOLDER}\${FILE}.bk1" "${FOLDER}\${FILE}.bk2"

    the_first_${PFI_UNIQUE_ID}:
      Rename "${FOLDER}\${FILE}" "${FOLDER}\${FILE}.bk1"

    continue_${PFI_UNIQUE_ID}:
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


!ifdef INSTALLER | PFIDIAG
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


!ifndef ADDSSL & BACKUP
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
!endif


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
      FileWrite ${L_NEW_CFG} "windows_trayicon ${L_MODE}${MB_NL}"
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
#    Macro:                GetDatabaseName
#    Installer Function:   GetDatabaseName
#    Uninstaller Function: un.GetDatabaseName
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
#    Macro:                GetMessagesPath
#    Installer Function:   GetMessagesPath
#    Uninstaller Function: un.GetMessagesPath
#
#    Macro:                GetParent
#    Installer Function:   GetParent
#    Uninstaller Function: un.GetParent
#
#    Macro:                GetPOPFileSchemaVersion
#    Installer Function:   GetPOPFileSchemaVersion
#    Uninstaller Function: un.GetPOPFileSchemaVersion
#
#    Macro:                GetSQLdbPathName
#    Installer Function:   GetSQLdbPathName
#    Uninstaller Function: un.GetSQLdbPathName
#
#    Macro:                GetSQLiteFormat
#    Installer Function:   GetSQLiteFormat
#    Uninstaller Function: un.GetSQLiteFormat
#
#    Macro:                GetSQLiteSchemaVersion
#    Installer Function:   GetSQLiteSchemaVersion
#    Uninstaller Function: un.GetSQLiteSchemaVersion
#
#    Macro:                GetTimeStamp
#    Installer Function:   GetTimeStamp
#    Uninstaller Function: un.GetTimeStamp
#
#    Macro:                RequestPFIUtilsShutdown
#    Installer Function:   RequestPFIUtilsShutdown
#    Uninstaller Function: un.RequestPFIUtilsShutdown
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

!ifdef ADDSSL | ADDUSER | BACKUP | INSTALLER | RESTORE
    #--------------------------------------------------------------------------
    # Installer Function: CheckIfLocked
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro CheckIfLocked ""
!endif

!ifdef ADDUSER | INSTALLER
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

!ifdef ADDSSL | ADDUSER | BACKUP | INSTALLER | RESTORE
    #--------------------------------------------------------------------------
    # Installer Function: FindLockedPFE
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro FindLockedPFE ""
!endif

!ifdef ADDUSER | INSTALLER
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
# Macro: GetDatabaseName
#
# The installation process and the uninstall process may both need a function which finds the
# value of the 'bayes_database' entry in the POPFile configuration file ('popfile.cfg'). This
# entry supplies the name of the SQLite database used by POPFile and has a default value of
# 'popfile.db'. This macro makes maintenance easier by ensuring that both processes use
# identical functions, with the only difference being their names.
#
# NOTE:
# The !insertmacro GetDatabaseName "" and !insertmacro GetDatabaseName "un." commands
# are included in this file so the NSIS script can use 'Call GetDatabaseName' and
# 'Call un.GetDatabaseName' without additional preparation.
#
# Inputs:
#         (top of stack)          - the path where 'popfile.cfg' is to be found
#
# Outputs:
#         (top of stack)          - string with the current value of the 'bayes_database' entry
#                                   (if entry is not found (perhaps because a "clean" install is
#                                   in progress), the default value for the entry is returned)
#
# Usage (after macro has been 'inserted'):
#
#         Push $G_USERDIR
#         Call GetDatabaseName
#         Pop $R0
#
#         ($R0 will be "popfile.db" if the default was in use or if this is a "clean" install)
#--------------------------------------------------------------------------

!macro GetDatabaseName UN
  Function ${UN}GetDatabaseName

    !define L_FILE_HANDLE   $R9   ; used to access the configuration file (popfile.cfg)
    !define L_PARAM         $R8   ; parameter from the configuration file
    !define L_RESULT        $R7
    !define L_SOURCE        $R6   ; folder containing the configuration file
    !define L_TEMP          $R5
    !define L_TEXTEND       $R4   ; helps ensure correct handling of lines over 1023 chars long

    Exch ${L_SOURCE}          ; where we are supposed to look for the 'popfile.cfg' file
    Push ${L_RESULT}
    Exch
    Push ${L_FILE_HANDLE}
    Push ${L_PARAM}
    Push ${L_TEMP}
    Push ${L_TEXTEND}

    StrCpy ${L_RESULT} ""

    IfFileExists "${L_SOURCE}\popfile.cfg" 0 use_default

    FileOpen ${L_FILE_HANDLE} "${L_SOURCE}\popfile.cfg" r

  found_eol:
    StrCpy ${L_TEXTEND} "<eol>"

  loop:
    FileRead ${L_FILE_HANDLE} ${L_PARAM}
    StrCmp ${L_PARAM} "" cfg_file_done
    StrCmp ${L_TEXTEND} "<eol>" 0 check_eol
    StrCmp ${L_PARAM} "$\n" loop

    StrCpy ${L_TEMP} ${L_PARAM} 15
    StrCmp ${L_TEMP} "bayes_database " 0 check_eol
    StrCpy ${L_RESULT} ${L_PARAM} "" 15

    ; Now read file until we get to end of the current line
    ; (i.e. until we find text ending in <CR><LF>, <CR> or <LF>)

  check_eol:
    StrCpy ${L_TEXTEND} ${L_PARAM} 1 -1
    StrCmp ${L_TEXTEND} "$\n" found_eol
    StrCmp ${L_TEXTEND} "$\r" found_eol loop

  cfg_file_done:
    FileClose ${L_FILE_HANDLE}

    StrCmp ${L_RESULT} "" use_default
    Push ${L_RESULT}
    Call ${UN}TrimNewlines
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" use_default got_result

  use_default:
    StrCpy ${L_RESULT} "popfile.db"

  got_result:
    Pop ${L_TEXTEND}
    Pop ${L_TEMP}
    Pop ${L_PARAM}
    Pop ${L_FILE_HANDLE}
    Pop ${L_SOURCE}
    Exch ${L_RESULT}

    !undef L_FILE_HANDLE
    !undef L_PARAM
    !undef L_RESULT
    !undef L_SOURCE
    !undef L_TEMP
    !undef L_TEXTEND

  FunctionEnd
!macroend

!ifdef ADDUSER
    #--------------------------------------------------------------------------
    # Installer Function: GetDatabaseName
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro GetDatabaseName ""
!endif

#--------------------------------------------------------------------------
# Uninstaller Function: un.GetDatabaseName
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro GetDatabaseName "un."


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
# The result is returned without a trailing slash even if the 'data folder' parameter had one,
# e.g. 'C:\Program Files\POPFile' and './' are converted to 'C:\Program Files\POPFile'
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

    StrCmp ${L_DATA} ".\" source_folder

    ; Strip trailing slash (so we always return a result without a trailing slash)

    StrCpy ${L_TEMP} ${L_DATA} 1 -1
    StrCmp ${L_TEMP} '\' 0 analyse_data
    StrCpy ${L_DATA} ${L_DATA} -1

  analyse_data:
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

!ifdef ADDUSER | BACKUP | RESTORE | RUNPOPFILE
    #--------------------------------------------------------------------------
    # Installer Function: GetDataPath
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro GetDataPath ""
!endif

!ifdef ADDUSER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.GetDataPath
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro GetDataPath "un."
!endif


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

!ifdef ADDSSL | ADDUSER | BACKUP | MSGCAPTURE | PFIDIAG | RESTORE | TRANSLATOR_AUW
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

!ifdef ADDSSL | ADDUSER | BACKUP | INSTALLER | RESTORE | STOP_POPFILE
    #--------------------------------------------------------------------------
    # Installer Function: GetFileSize
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro GetFileSize ""
!endif

!ifdef ADDUSER | INSTALLER
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

!ifdef ADDSSL | ADDUSER | BACKUP | MSGCAPTURE | PFIDIAG | RESTORE | TRANSLATOR_AUW
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
# Macro: GetMessagesPath
#
# The installation process and the uninstall process may need a function which finds the full
# path for the folder used to store the message history if a copy of 'popfile.cfg' is found in
# the installation folder. This macro makes maintenance easier by ensuring that both processes
# use identical functions, with the only difference being their names.
#
# Note that this function is only concerned with the location of the folder used to hold the
# temporary copies of recently classified messages; it has nothing to do with the optional
# message archives which POPFile can maintain.
#
# The 'popfile.cfg' file is used to determine the full path of the folder where the message
# files are stored. By default the message history is stored in the '$G_USERDIR\messages'
# folder but the 'popfile.cfg' file can define a different location, using a variety of paths
# (eg relative, absolute, local or even remote). This function returns a path which does not
# end with a trailing slash, even if the path specified in 'popfile.cfg' ends with one.
#
# If 'popfile.cfg' is found in the specified folder, we use the relevant parameter (if present)
# otherwise we assume the default location is to be used (the sub-folder called 'messages').
#
# NOTE:
# The !insertmacro GetMessagesPath "" and !insertmacro GetMessagesPath "un." commands are
# included in this file so the NSIS script can use 'Call GetMessagesPath' and
# 'Call un.GetMessagesPath' without additional preparation.
#
# Inputs:
#         (top of stack)          - the path where 'popfile.cfg' is to be found
#
# Outputs:
#         (top of stack)          - the full (unambiguous) path to the message history data
#
# Usage (after macro has been 'inserted'):
#
#         Push $G_USERDIR
#         Call un.GetMessagesPath
#         Pop $R0
#
#         ($R0 will be "C:\Program Files\POPFile\messages" if this is an upgraded installation
#          which used the default location)
#--------------------------------------------------------------------------

!macro GetMessagesPath UN
  Function ${UN}GetMessagesPath

    !define L_FILE_HANDLE   $R9
    !define L_MSG_HISTORY   $R8
    !define L_RESULT        $R7
    !define L_SOURCE        $R6
    !define L_TEMP          $R5
    !define L_TEXTEND       $R4   ; helps ensure correct handling of lines over 1023 chars long

    Exch ${L_SOURCE}          ; where we are supposed to look for the 'popfile.cfg' file
    Push ${L_RESULT}
    Exch
    Push ${L_FILE_HANDLE}
    Push ${L_MSG_HISTORY}
    Push ${L_TEMP}
    Push ${L_TEXTEND}

    StrCpy ${L_MSG_HISTORY} ""

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
    StrCmp ${L_RESULT} "msgdir " got_old_msgdir
    StrCpy ${L_RESULT} ${L_TEMP} 14
    StrCmp ${L_RESULT} "GLOBAL_msgdir " got_new_msgdir
    Goto check_eol

  got_old_msgdir:
    StrCpy ${L_MSG_HISTORY} ${L_TEMP} "" 7
    Goto check_eol

  got_new_msgdir:
    StrCpy ${L_MSG_HISTORY} ${L_TEMP} "" 14

    ; Now read file until we get to end of the current line
    ; (i.e. until we find text ending in <CR><LF>, <CR> or <LF>)

  check_eol:
    StrCpy ${L_TEXTEND} ${L_TEMP} 1 -1
    StrCmp ${L_TEXTEND} "$\n" found_eol
    StrCmp ${L_TEXTEND} "$\r" found_eol loop

  cfg_file_done:
    FileClose ${L_FILE_HANDLE}
    Push ${L_MSG_HISTORY}
    Call ${UN}TrimNewlines
    Pop ${L_MSG_HISTORY}
    StrCmp ${L_MSG_HISTORY} "" use_default_locn use_cfg_data

  use_default_locn:
    StrCpy ${L_RESULT} ${L_SOURCE}\messages
    Goto got_result

  use_cfg_data:
    Push ${L_SOURCE}
    Push ${L_MSG_HISTORY}
    Call ${UN}GetDataPath
    Pop ${L_RESULT}

  got_result:
    Pop ${L_TEXTEND}
    Pop ${L_TEMP}
    Pop ${L_MSG_HISTORY}
    Pop ${L_FILE_HANDLE}
    Pop ${L_SOURCE}
    Exch ${L_RESULT}  ; place full path of 'messages' folder on top of the stack

    !undef L_FILE_HANDLE
    !undef L_MSG_HISTORY
    !undef L_RESULT
    !undef L_SOURCE
    !undef L_TEMP
    !undef L_TEXTEND

  FunctionEnd
!macroend

;;!ifdef ADDUSER
;;    #--------------------------------------------------------------------------
;;    # Installer Function: GetMessagesPath
;;    #
;;    # This function is used during the installation process
;;    #--------------------------------------------------------------------------
;;
;;    !insertmacro GetMessagesPath ""
;;!endif
;;
!ifdef ADDUSER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.GetMessagesPath
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro GetMessagesPath "un."
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

!ifdef ADDSSL | ADDUSER | BACKUP | RESTORE | RUNPOPFILE
    #--------------------------------------------------------------------------
    # Installer Function: GetParent
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro GetParent ""
!endif

!ifdef ADDUSER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.GetParent
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro GetParent "un."
!endif


#--------------------------------------------------------------------------
# Macro: GetPOPFileSchemaVersion
#
# The installation process and the uninstall process may both need a function which determines
# the Database Schema version used by POPFile. POPFile compares this value with the value stored
# in the SQL database to determine when an automatic database upgrade is required. Upgrades can
# take several minutes during which POPFile will appear to be locked up. This function helps the
# installer detect when the SQLite database will be upgraded so it can use the Message Capture
# Utility to display the database upgrade progress reports. This macro makes maintenance easier
# by ensuring both processes use identical functions with the only difference being their names.
#
# NOTE:
# The !insertmacro GetPOPFileSchemaVersion "" and !insertmacro GetPOPFileSchemaVersion "un."
# commands are included in this file so the NSIS script can use 'Call GetPOPFileSchemaVersion'
# and 'Call un.GetPOPFileSchemaVersion' without additional preparation.
#
# Inputs:
#         (top of stack)     - full pathname of the file containing POPFile's database schema
#
# Outputs:
#         (top of stack)     - one of the following result strings:
#                              (a) x          - where 'x' is the version number, e.g. '2'
#                              (b) ()         - early versions of popfile.sql did not specify
#                                               a version number in the first line (the first
#                                               line just started with "-- ----------------")
#                              (c) (<error>)  - an error occurred when determining the schema
#                                               version number or when accessing the file
#
#                              If the result is enclosed in parentheses then an error occurred
#                              (the special case "()" assumes the file is a very early version)
#
# Usage (after macro has been 'inserted'):
#
#         Push "C:\Program Files\POPFile\Classifier\popfile.sql"
#         Call GetPOPFileSchemaVersion
#         Pop $R0
#
#         ($R0 will be "3" if the first line of the popfile.sql file is "-- POPFILE SCHEMA 3")
#--------------------------------------------------------------------------

!macro GetPOPFileSchemaVersion UN
  Function ${UN}GetPOPFileSchemaVersion

    !define L_FILENAME   $R9  ; pathname of the POPFile schema file
    !define L_HANDLE     $R8  ; used to access the schema file
    !define L_RESULT     $R7  ; string returned on top of the stack
    !define L_TEMP       $R6

    Exch ${L_FILENAME}
    Push ${L_RESULT}
    Exch
    Push ${L_HANDLE}
    Push ${L_TEMP}

    StrCpy ${L_RESULT} "unable to open file"

    ClearErrors
    FileOpen ${L_HANDLE} "${L_FILENAME}" r
    IfErrors error_exit
    FileRead ${L_HANDLE} ${L_RESULT}
    FileClose ${L_HANDLE}

    StrCmp ${L_RESULT} "" error_exit
    Push ${L_RESULT}
    Call ${UN}TrimNewlines
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" error_exit

    ; The POPFile database schema file is 'popfile.sql' and since CVS version 1.14 the first
    ; line of the file contains the version number (e.g. "-- POPFILE SCHEMA 3"). In earlier
    ; versions, the first line started with "-- ---------------" instead (the schema version
    ; number was not mentioned).

    StrCpy ${L_TEMP} ${L_RESULT} 18
    StrCmp ${L_TEMP} "-- POPFILE SCHEMA " schema_found
    StrCmp ${L_TEMP} "-- ---------------" 0 error_exit
    StrCpy ${L_RESULT} ""

  error_exit:

    ; Schema string not found so return first 50 chars enclosed in parentheses to indicate error

    StrCpy ${L_RESULT} ${L_RESULT} 50
    StrCpy ${L_RESULT} "(${L_RESULT})"
    Goto exit

  schema_found:
    StrCpy ${L_RESULT} ${L_RESULT} "" 18

  exit:
    Pop ${L_TEMP}
    Pop ${L_HANDLE}
    Pop ${L_FILENAME}
    Exch ${L_RESULT}

    !undef L_FILENAME
    !undef L_HANDLE
    !undef L_RESULT
    !undef L_TEMP

  FunctionEnd
!macroend

!ifdef ADDUSER | INSTALLER
    #--------------------------------------------------------------------------
    # Installer Function: GetPOPFileSchemaVersion
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro GetPOPFileSchemaVersion ""
!endif

#--------------------------------------------------------------------------
# Uninstaller Function: un.GetPOPFileSchemaVersion
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro GetPOPFileSchemaVersion "un."


#--------------------------------------------------------------------------
# Macro: GetSQLdbPathName
#
# The installation process and the uninstall process may both need a function which finds the
# full path (including the filename) for the SQLite database file. This macro makes maintenance
# easier by ensuring that both processes use identical functions, with the only difference being
# their names.
#
# By default the database file is called 'popfile.db' and it is stored in the same folder as the
# 'popfile.cfg' file.
#
# If 'popfile.cfg' specifies a SQL database other than SQLite, this function returns the result
# "Not SQLite"
#
# NOTE:
# The !insertmacro GetSQLdbPathName "" and !insertmacro GetSQLdbPathName "un." commands
# are included in this file so the NSIS script can use 'Call GetSQLdbPathName' and
# 'Call un.GetSQLdbPathName' without additional preparation.
#
# Inputs:
#         (top of stack)          - the path where 'popfile.cfg' is to be found
#
# Outputs:
#         (top of stack)          - string with the full (unambiguous) path to SQLite database
#                                   or "Not SQLite" if the SQL database does not use SQLite
#                                   or "" if the SQLite database is not specified or not found
#
# Usage (after macro has been 'inserted'):
#
#         Push $G_USERDIR
#         Call un.GetSQLdbPathName
#         Pop $R0
#
#         ($R0 will be "C:\Program Files\POPFile\popfile.db" if this is an upgraded version of
#          a pre-0.21.0 installation using the default location)
#--------------------------------------------------------------------------

!macro GetSQLdbPathName UN
  Function ${UN}GetSQLdbPathName

    !define L_FILE_HANDLE   $R9
    !define L_RESULT        $R8
    !define L_SOURCE        $R7
    !define L_SQL_CONNECT   $R6
    !define L_SQL_CORPUS    $R5
    !define L_TEMP          $R4
    !define L_TEXTEND       $R3   ; helps ensure correct handling of lines over 1023 chars long

    Exch ${L_SOURCE}          ; where we are supposed to look for the 'popfile.cfg' file
    Push ${L_RESULT}
    Exch
    Push ${L_FILE_HANDLE}
    Push ${L_SQL_CONNECT}
    Push ${L_SQL_CORPUS}
    Push ${L_TEMP}
    Push ${L_TEXTEND}

    StrCpy ${L_SQL_CORPUS} ""

    IfFileExists "${L_SOURCE}\popfile.cfg" 0 no_sql_set

    FileOpen ${L_FILE_HANDLE} "${L_SOURCE}\popfile.cfg" r

  found_eol:
    StrCpy ${L_TEXTEND} "<eol>"

  loop:
    FileRead ${L_FILE_HANDLE} ${L_TEMP}
    StrCmp ${L_TEMP} "" cfg_file_done
    StrCmp ${L_TEXTEND} "<eol>" 0 check_eol
    StrCmp ${L_TEMP} "$\n" loop

    StrCpy ${L_RESULT} ${L_TEMP} 15
    StrCmp ${L_RESULT} "bayes_database " got_sql_corpus
    StrCpy ${L_RESULT} ${L_TEMP} 16
    StrCmp ${L_RESULT} "bayes_dbconnect " got_sql_connect
    Goto check_eol

  got_sql_corpus:
    StrCpy ${L_SQL_CORPUS} ${L_TEMP} "" 15
    Goto check_eol

  got_sql_connect:
    StrCpy ${L_SQL_CONNECT} ${L_TEMP} "" 16

    ; Now read file until we get to end of the current line
    ; (i.e. until we find text ending in <CR><LF>, <CR> or <LF>)

  check_eol:
    StrCpy ${L_TEXTEND} ${L_TEMP} 1 -1
    StrCmp ${L_TEXTEND} "$\n" found_eol
    StrCmp ${L_TEXTEND} "$\r" found_eol loop

  cfg_file_done:
    FileClose ${L_FILE_HANDLE}

    ; If a SQL setting other than the default SQLite one is found, assume existing system
    ; is using an alternative SQL database (such as MySQL) so there is no SQLite database

    Push ${L_SQL_CONNECT}
    Call ${UN}TrimNewlines
    Pop ${L_SQL_CONNECT}
    StrCmp ${L_SQL_CONNECT} "" no_sql_set
    StrCpy ${L_SQL_CONNECT} ${L_SQL_CONNECT} 10
    StrCmp ${L_SQL_CONNECT} "dbi:SQLite" 0 not_sqlite

    Push ${L_SQL_CORPUS}
    Call ${UN}TrimNewlines
    Pop ${L_SQL_CORPUS}
    StrCmp ${L_SQL_CORPUS} "" no_sql_set use_cfg_data

  not_sqlite:
    StrCpy ${L_RESULT} "Not SQLite"
    Goto got_result

  no_sql_set:
    StrCpy ${L_RESULT} ""
    Goto got_result

  use_cfg_data:
    Push ${L_SOURCE}
    Push ${L_SQL_CORPUS}
    Call ${UN}GetDataPath
    Pop ${L_RESULT}

  got_result:
    Pop ${L_TEXTEND}
    Pop ${L_TEMP}
    Pop ${L_SQL_CORPUS}
    Pop ${L_SQL_CONNECT}
    Pop ${L_FILE_HANDLE}
    Pop ${L_SOURCE}
    Exch ${L_RESULT}

    !undef L_FILE_HANDLE
    !undef L_RESULT
    !undef L_SOURCE
    !undef L_SQL_CONNECT
    !undef L_SQL_CORPUS
    !undef L_TEMP
    !undef L_TEXTEND

  FunctionEnd
!macroend

!ifdef ADDUSER
    #--------------------------------------------------------------------------
    # Installer Function: GetSQLdbPathName
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro GetSQLdbPathName ""
!endif

#--------------------------------------------------------------------------
# Uninstaller Function: un.GetSQLdbPathName
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro GetSQLdbPathName "un."


#--------------------------------------------------------------------------
# Macro: GetSQLiteFormat
#
# The installation process and the uninstall process may both need a function which determines
# the format of the SQLite database. SQLite 2.x and 3.x databases use incompatible formats and
# the only way to determine the format is to examine the first few bytes in the database file.
# This macro makes maintenance easier by ensuring that both processes use identical functions,
# with the only difference being their names.
#
# NOTE:
# The !insertmacro GetSQLiteFormat "" and !insertmacro GetSQLiteFormat "un." commands
# are included in this file so the NSIS script can use 'Call GetSQLiteFormat' and
# 'Call un.GetSQLiteFormat' without additional preparation.
#
# Inputs:
#         (top of stack)     - SQLite database filename (may include the path)
#
# Outputs:
#         (top of stack)     - one of the following result strings:
#                              (a) 2.x                   - SQLite 2.1 format database found
#                              (b) 3.x                   - SQLite 3.x format database found
#                              (c) (<format>)            - <format> is what was found in file
#                              (d) (unable to open file) - if file is locked or non-existent
#
#                              If the result is enclosed in parentheses then an error occurred.
#
# Usage (after macro has been 'inserted'):
#
#         Push "popfile.db"
#         Call GetSQLiteFormat
#         Pop $R0
#
#         ($R0 will be "2.x" if the popfile.db file belongs to POPFile 0.21.0)
#--------------------------------------------------------------------------

!macro GetSQLiteFormat UN
  Function ${UN}GetSQLiteFormat

    !define L_BYTE       $R9  ; byte read from the database file
    !define L_COUNTER    $R8  ; expect a null-terminated string, but use a length limit as well
    !define L_FILENAME   $R7  ; name of the SQLite database file
    !define L_HANDLE     $R6  ; used to access the database file
    !define L_RESULT     $R5  ; string returned on top of the stack

    Exch ${L_FILENAME}
    Push ${L_RESULT}
    Exch
    Push ${L_BYTE}
    Push ${L_COUNTER}
    Push ${L_HANDLE}

    StrCpy ${L_RESULT} "unable to open file"
    StrCpy ${L_COUNTER} 47

    ClearErrors
    FileOpen ${L_HANDLE} "${L_FILENAME}" r
    IfErrors done
    StrCpy ${L_RESULT} ""

  loop:
    FileReadByte ${L_HANDLE} ${L_BYTE}
    StrCmp ${L_BYTE} "0" done
    IntCmp ${L_BYTE} 32 0 done
    IntCmp ${L_BYTE} 127 done 0 done
    IntFmt ${L_BYTE} "%c" ${L_BYTE}
    StrCpy ${L_RESULT} "${L_RESULT}${L_BYTE}"
    IntOp ${L_COUNTER} ${L_COUNTER} - 1
    IntCmp ${L_COUNTER} 0 loop done loop

  done:
    FileClose ${L_HANDLE}
    StrCmp ${L_RESULT} "** This file contains an SQLite 2.1 database **" sqlite_2
    StrCpy ${L_COUNTER} ${L_RESULT} 15
    StrCmp ${L_COUNTER} "SQLite format 3" sqlite_3

    ; Unrecognized format string found, so return it enclosed in parentheses (to indicate error)

    StrCpy ${L_RESULT} "(${L_RESULT})"
    Goto exit

  sqlite_2:
    StrCpy ${L_RESULT} "2.x"
    Goto exit

  sqlite_3:
    StrCpy ${L_RESULT} "3.x"

  exit:
    Pop ${L_HANDLE}
    Pop ${L_COUNTER}
    Pop ${L_BYTE}
    Pop ${L_FILENAME}
    Exch ${L_RESULT}

    !undef L_BYTE
    !undef L_COUNTER
    !undef L_FILENAME
    !undef L_HANDLE
    !undef L_RESULT

  FunctionEnd
!macroend

!ifdef ADDUSER | BACKUP | RUNSQLITE | RESTORE
    #--------------------------------------------------------------------------
    # Installer Function: GetSQLiteFormat
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro GetSQLiteFormat ""
!endif

#--------------------------------------------------------------------------
# Uninstaller Function: un.GetSQLiteFormat
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro GetSQLiteFormat "un."


#--------------------------------------------------------------------------
# Macro: GetSQLiteSchemaVersion
#
# The installation process and the uninstall process may both need a function which determines
# the POPFile Schema version used by the SQLite database. POPFile uses this data to determine
# when an automatic database upgrade is required. Upgrades can take several minutes during
# which POPFile will appear to be locked up. This function helps the installer detect when an
# upgrade will occur so it can use the Message Capture Utility to display the database upgrade
# progress reports. This macro makes maintenance easier by ensuring that both processes use
# identical functions, with the only difference being their names.
#
# NOTE:
# The !insertmacro GetSQLiteSchemaVersion "" and !insertmacro GetSQLiteSchemaVersion "un."
# commands are included in this file so the NSIS script can use 'Call GetSQLiteSchemaVersion'
# and 'Call un.GetSQLiteSchemaVersion' without additional preparation.
#
# Inputs:
#         (top of stack)     - SQLite database filename (may include the path)
#
# Outputs:
#         (top of stack)     - one of the following result strings:
#                              (a) x          - where 'x' is the version number, e.g. '2'
#                              (b) (<error>)  - an error occurred when determining the SQLite
#                                               database format or when accessing schema data
#
#                              If the result is enclosed in parentheses then an error occurred
#                              (e.g. if a SQLite 2.x database does not contain any schema data,
#                              "(SQL error: no such table: popfile)" will be returned)
#
# Usage (after macro has been 'inserted'):
#
#         Push "popfile.db"
#         Call GetSQLiteSchemaVersion
#         Pop $R0
#
#         ($R0 will be "3" if the popfile.db database uses POPFile Schema version 3)
#--------------------------------------------------------------------------

!macro GetSQLiteSchemaVersion UN
  Function ${UN}GetSQLiteSchemaVersion

    !define L_DATABASE    $R9   ; name of the SQLite database file
    !define L_RESULT      $R8   ; string returned on top of the stack
    !define L_SQLITEPATH  $R7   ; path to sqlite.exe utility
    !define L_SQLITEUTIL  $R6   ; used to run relevant SQLite utility
    !define L_STATUS      $R5   ; status code returned by SQLite utility

    Exch ${L_DATABASE}
    Push ${L_RESULT}
    Exch
    Push ${L_SQLITEPATH}
    Push ${L_SQLITEUTIL}
    Push ${L_STATUS}

    Push ${L_DATABASE}
    Call ${UN}GetSQLiteFormat
    Pop ${L_RESULT}
    StrCpy ${L_SQLITEUTIL} "sqlite.exe"
    StrCmp ${L_RESULT} "2.x" look_for_sqlite
    StrCpy ${L_SQLITEUTIL} "sqlite3.exe"
    StrCmp ${L_RESULT} "3.x" look_for_sqlite
    Goto exit

  look_for_sqlite:
    StrCpy ${L_SQLITEPATH} "$EXEDIR"
    IfFileExists "${L_SQLITEPATH}\${L_SQLITEUTIL}" run_sqlite
    StrCpy ${L_SQLITEPATH} "$PLUGINSDIR"
    IfFileExists "${L_SQLITEPATH}\${L_SQLITEUTIL}" run_sqlite
    StrCpy ${L_RESULT} "(cannot find '${L_SQLITEUTIL}' in '$EXEDIR' or '$PLUGINSDIR')"
    Goto exit

  run_sqlite:
    nsExec::ExecToStack '"${L_SQLITEPATH}\${L_SQLITEUTIL}" "${L_DATABASE}" "select version from popfile;"'
    Pop ${L_STATUS}
    Call ${UN}TrimNewlines
    Pop ${L_RESULT}
    StrCmp ${L_STATUS} "0" exit
    StrCpy ${L_RESULT} "(${L_RESULT})"

  exit:
    Pop ${L_STATUS}
    Pop ${L_SQLITEUTIL}
    Pop ${L_SQLITEPATH}
    Pop ${L_DATABASE}
    Exch ${L_RESULT}

    !undef L_DATABASE
    !undef L_RESULT
    !undef L_SQLITEPATH
    !undef L_SQLITEUTIL
    !undef L_STATUS

  FunctionEnd
!macroend

!ifdef ADDUSER | BACKUP | RESTORE
    #--------------------------------------------------------------------------
    # Installer Function: GetSQLiteSchemaVersion
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro GetSQLiteSchemaVersion ""
!endif

#--------------------------------------------------------------------------
# Uninstaller Function: un.GetSQLiteSchemaVersion
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro GetSQLiteSchemaVersion "un."


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
# Macro: RequestPFIUtilsShutdown
#
# The installation process and the uninstall process may both need a function which checks if
# any of the POPFile Installer (PFI) utilities is in use and asks the user to shut them down.
# This macro makes maintenance easier by ensuring that both processes use identical functions,
# with the only difference being their names.
#
# NOTE:
# The !insertmacro RequestPFIUtilsShutdown "" and !insertmacro RequestPFIUtilsShutdown "un."
# commands are included in this file so the NSIS script can use 'Call RequestPFIUtilsShutdown'
# and 'Call un.RequestPFIUtilsShutdown' without additional preparation.
#
# Inputs:
#         (top of stack)   - the path where the PFI Utilities can be found
#
# Outputs:
#         (none)
#
# Usage (after macro has been 'inserted'):
#
#         Push "C:\Program Files\POPFile"
#         Call RequestPFIUtilsShutdown
#
#--------------------------------------------------------------------------

!macro RequestPFIUtilsShutdown UN
  Function ${UN}RequestPFIUtilsShutdown
    !define L_PATH          $R9    ; full path to the PFI utilities which are to be checked
    !define L_RESULT        $R8    ; either the full path to a locked file or an empty string

    ;-----------------------------------------------------------
    ; If the user clicks 'OK' too soon after shutting down the utility, an Abort/Retry/Ignore
    ; message appears when the installer tries to overwrite the utility's EXE file)

    ; Delay (in milliseconds) used to give the PFI utility time to shut down

    !ifndef C_PFI_UTIL_SHUTDOWN_DELAY
      !define C_PFI_UTIL_SHUTDOWN_DELAY    1000
    !endif
    ;-----------------------------------------------------------

    Exch ${L_PATH}
    Push ${L_RESULT}

    DetailPrint "Checking '${L_PATH}\pfimsgcapture.exe' ..."
    Push "${L_PATH}\pfimsgcapture.exe"
    Call ${UN}CheckIfLocked
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" pfi_util_a
    StrCpy $G_PLS_FIELD_1 "POPFile Message Capture Utility"
    DetailPrint "Unable to shutdown $G_PLS_FIELD_1 automatically - manual intervention requested"
    MessageBox MB_OK|MB_ICONEXCLAMATION|MB_TOPMOST "$(PFI_LANG_MBMANSHUT_1)\
        ${MB_NL}${MB_NL}\
        $(PFI_LANG_MBMANSHUT_2)\
        ${MB_NL}${MB_NL}\
        $(PFI_LANG_MBMANSHUT_3)"

    ; Assume user has managed to shutdown the POPFile Message Capture Utility (runpopfile)

    Sleep ${C_PFI_UTIL_SHUTDOWN_DELAY}

  pfi_util_a:
    DetailPrint "Checking '${L_PATH}\msgcapture.exe' ..."
    Push "${L_PATH}\msgcapture.exe"
    Call ${UN}CheckIfLocked
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" pfi_util_b
    StrCpy $G_PLS_FIELD_1 "POPFile Message Capture Utility"
    DetailPrint "Unable to shutdown $G_PLS_FIELD_1 automatically - manual intervention requested"
    MessageBox MB_OK|MB_ICONEXCLAMATION|MB_TOPMOST "$(PFI_LANG_MBMANSHUT_1)\
        ${MB_NL}${MB_NL}\
        $(PFI_LANG_MBMANSHUT_2)\
        ${MB_NL}${MB_NL}\
        $(PFI_LANG_MBMANSHUT_3)"

    ; Assume user has managed to shutdown the POPFile Message Capture Utility (standard)

    Sleep ${C_PFI_UTIL_SHUTDOWN_DELAY}

  pfi_util_b:
    DetailPrint "Checking '${L_PATH}\stop_pf.exe' ..."
    Push "${L_PATH}\stop_pf.exe"
    Call ${UN}CheckIfLocked
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" pfi_util_c
    StrCpy $G_PLS_FIELD_1 "POPFile Silent Shutdown Utility"
    DetailPrint "Unable to shutdown $G_PLS_FIELD_1 automatically - manual intervention requested"
    MessageBox MB_OK|MB_ICONEXCLAMATION|MB_TOPMOST "$(PFI_LANG_MBMANSHUT_1)\
        ${MB_NL}${MB_NL}\
        $(PFI_LANG_MBMANSHUT_2)\
        ${MB_NL}${MB_NL}\
        $(PFI_LANG_MBMANSHUT_3)"

    ; Assume user has managed to shutdown the POPFile Message Capture Utility (standard)

    Sleep ${C_PFI_UTIL_SHUTDOWN_DELAY}

  pfi_util_c:
    DetailPrint "Checking '${L_PATH}\pfidiag.exe' ..."
    Push "${L_PATH}\pfidiag.exe"
    Call ${UN}CheckIfLocked
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" exit
    StrCpy $G_PLS_FIELD_1 "PFI Diagnostic Utility"
    DetailPrint "Unable to shutdown $G_PLS_FIELD_1 automatically - manual intervention requested"
    MessageBox MB_OK|MB_ICONEXCLAMATION|MB_TOPMOST "$(PFI_LANG_MBMANSHUT_1)\
        ${MB_NL}${MB_NL}\
        $(PFI_LANG_MBMANSHUT_2)\
        ${MB_NL}${MB_NL}\
        $(PFI_LANG_MBMANSHUT_3)"

    ; Assume user has managed to shutdown the POPFile Message Capture Utility (standard)

    Sleep ${C_PFI_UTIL_SHUTDOWN_DELAY}

   exit:
    Pop ${L_RESULT}
    Pop ${L_PATH}

    !undef L_PATH
    !undef L_RESULT
  FunctionEnd
!macroend

!ifdef INSTALLER
    #--------------------------------------------------------------------------
    # Installer Function: RequestPFIUtilsShutdown
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro RequestPFIUtilsShutdown ""
!endif

!ifdef INSTALLER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.RequestPFIUtilsShutdown
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro RequestPFIUtilsShutdown "un."
!endif


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

!ifdef ADDSSL | ADDUSER | BACKUP | INSTALLER | RESTORE
    #--------------------------------------------------------------------------
    # Installer Function: ServiceCall
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro ServiceCall ""
!endif

!ifdef ADDUSER | INSTALLER
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

!ifdef ADDSSL | ADDUSER | BACKUP | INSTALLER | RESTORE
    #--------------------------------------------------------------------------
    # Installer Function: ServiceRunning
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro ServiceRunning ""
!endif

!ifdef ADDUSER | INSTALLER
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
    NSISdl::download_quiet ${C_SVU_DLTIMEOUT} http://${C_UI_URL}:${L_UIPORT}/shutdown "$PLUGINSDIR\shutdown_1.htm"
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "success" try_again
    StrCpy ${L_RESULT} "failure"
    Goto exit

  try_again:
    Sleep ${C_SVU_DLGAP}
    NSISdl::download_quiet ${C_SVU_DLTIMEOUT} http://${C_UI_URL}:${L_UIPORT}/shutdown "$PLUGINSDIR\shutdown_2.htm"
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

!ifdef ADDSSL | ADDUSER | BACKUP | INSTALLER | RESTORE
    #--------------------------------------------------------------------------
    # Installer Function: ShutdownViaUI
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro ShutdownViaUI ""
!endif

!ifdef ADDUSER | INSTALLER
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

!ifdef ADDSSL | ADDUSER | BACKUP | RESTORE | RUNPOPFILE
    #--------------------------------------------------------------------------
    # Installer Function: StrBackSlash
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro StrBackSlash ""
!endif

!ifdef ADDUSER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.StrBackSlash
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro StrBackSlash "un."
!endif


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

!ifndef PFIDIAG & RUNPOPFILE & RUNSQLITE & TRANSLATOR
    #--------------------------------------------------------------------------
    # Installer Function: StrCheckDecimal
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro StrCheckDecimal ""
!endif

!ifdef ADDUSER | INSTALLER
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

!ifndef ADDSSL & MSGCAPTURE & RUNSQLITE & STOP_POPFILE & TRANSLATOR
    #--------------------------------------------------------------------------
    # Installer Function: StrStr
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro StrStr ""
!endif

!ifdef ADDUSER | INSTALLER
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

!ifdef ADDSSL | ADDUSER | BACKUP | INSTALLER | RESTORE | TRANSLATOR
    #--------------------------------------------------------------------------
    # Installer Function: TrimNewlines
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro TrimNewlines ""
!endif

!ifdef ADDUSER | INSTALLER
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

!ifdef ADDSSL | ADDUSER | INSTALLER
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
