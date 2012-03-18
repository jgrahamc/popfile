#--------------------------------------------------------------------------
#
# pfi-library.nsi --- This is a collection of library functions and macro
#                     definitions for inclusion in the NSIS scripts used
#                     to create (and test) the POPFile Windows installer.
#
# Copyright (c) 2003-2011 John Graham-Cumming
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify it
#   under the terms of version 2 of the GNU General Public License as
#   published by the Free Software Foundation.
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
#  (4) CREATEUSER       defined in portable\CreateUserData.nsi (for POPFile Portable)
#  (5) DBANALYSER       defined in test\pfidbanalyser.nsi (POPFile SQLite Database Analyser)
#  (6) DBSTATUS         defined in test\pfidbstatus.nsi (POPFile SQLite Database Status Check)
#  (7) IMAPUPDATER      defined in add-ons\updateimap.nsi (POPFile 'IMAP Updater' wizard)
#  (8) INSTALLER        defined in installer.nsi (the main installer program, setup.exe)
#  (9) LFNFIXER         defined in portable\lfnfixer.nsi (LFN fixer for POPFile Portable)
# (10) MONITORCC        defined in MonitorCC.nsi (the corpus conversion monitor)
# (11) MSGCAPTURE       defined in msgcapture.nsi (used to capture POPFile's console messages)
# (12) ONDEMAND         defined in add-ons\OnDemand.nsi (starts POPFile & email client together)
# (13) PFIDIAG          defined in test\pfidiag.nsi (helps diagnose installer-related problems)
# (14) PLUGINCHECK      defined in toolkit\plugin-vcheck.nsi (checks the extra NSIS plugins)
# (15) PORTABLE         defined in portable\POPFilePortable.nsi (PortableApps format launcher)
# (16) RESTORE          defined in restore.nsi (POPFile 'User Data' Restore utility)
# (17) RUNPOPFILE       defined in runpopfile.nsi (simple front-end for popfile.exe)
# (18) RUNSQLITE        defined in runsqlite.nsi (simple front-end for sqlite.exe/sqlite3.exe)
# (19) SHUTDOWN         defined in portable\POPFilePortableShutdown.nsi (shutdown POPFile Portable)
# (20) STOP_POPFILE     defined in stop_popfile.nsi (the 'POPFile Silent Shutdown' utility)
# (21) TRANSLATOR       defined in test\translator.nsi (main installer translations testbed)
# (22) TRANSLATOR_AUW   defined in test\transAUW.nsi ('Add POPFile User' translations testbed)
#--------------------------------------------------------------------------

!ifndef PFI_VERBOSE
  !verbose 3
!endif

#--------------------------------------------------------------------------
# Since so many scripts rely upon this library file, provide an easy way
# for the installers/uninstallers, wizards and other utilities to identify
# the particular library file used by NSIS to compile the executable file
# (by using this constant in the executable's "Version Information" data).
#--------------------------------------------------------------------------

  !define C_PFI_LIBRARY_VERSION     "0.6.4"

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
# Marker used by the 'PFI_CheckIfLocked' function to detect the end of the input data
#--------------------------------------------------------------------------

  !define C_EXE_END_MARKER  "/EndOfExeList"

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
  ; (3) Normally the MUI's language selection menu uses the name defined in the MUI language
  ;     file, however it is possible to override this by supplying an alternative string
  ;     (the MENUNAME parameter in this macro). At present the only alternative string used
  ;     is "Nihongo" which replaces "Japanese" to make things easier for non-English-speaking
  ;     users - see 'pfi-languages.nsh' for details.

  !macro PFI_LANG_LOAD LANG MENUNAME
      !if "${MENUNAME}" != "-"
          !define LANGFILE_${LANG}_NAME "${MENUNAME}"
      !endif
      !insertmacro MUI_LANGUAGE "${LANG}"
      !ifdef ADDSSL | CREATEUSER | TRANSLATOR | TRANSLATOR_AUW
          !include "..\languages\${LANG}-pfi.nsh"
      !else
          !include "languages\${LANG}-pfi.nsh"
      !endif
  !macroend

#--------------------------------------------------------------------------
#
# Macros used to preserve up to 3 backup copies of a file
#
# (Note: input file will be "removed" by renaming it)
#--------------------------------------------------------------------------

  ;--------------------------------------------------------------------------
  ; This version generates uses 'DetailsPrint' to generate more meaningful log entries
  ;--------------------------------------------------------------------------

  !macro PFI_BACKUP_123_DP FOLDER FILE

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

  !macro PFI_BACKUP_123 FOLDER FILE

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


#==============================================================================
#
# Macros used only by the 'installer.nsi' script (and/or its 'include' files):
#
#     PFI_SkinMove
#     PFI_DeleteSkin
#     PFI_SectionNotSelected
#
# Note: The 'translator.nsi' script builds the utility which tests the translations.
#==============================================================================

!ifdef INSTALLER | TRANSLATOR

  ;--------------------------------------------------------------------------
  ; 'installer.nsi' macro used when rearranging existing skins
  ;--------------------------------------------------------------------------

    !macro PFI_SkinMove OLDNAME NEWNAME

        !insertmacro PFI_UNIQUE_ID

        IfFileExists "$G_ROOTDIR\skins\${OLDNAME}.css" 0 skip_${PFI_UNIQUE_ID}
        CreateDirectory "$G_ROOTDIR\skins\${NEWNAME}"
        Rename "$G_ROOTDIR\skins\${OLDNAME}.css" "$G_ROOTDIR\skins\${NEWNAME}\style.css"

      skip_${PFI_UNIQUE_ID}:

    !macroend

  ;--------------------------------------------------------------------------
  ; 'installer.nsi' macro used when uninstalling the new style skins
  ;--------------------------------------------------------------------------

    !macro PFI_DeleteSkin FOLDER

        !insertmacro PFI_UNIQUE_ID

        IfFileExists "${FOLDER}\*.*" 0 skip_${PFI_UNIQUE_ID}
        Delete "${FOLDER}\*.css"
        Delete "${FOLDER}\*.gif"
        Delete "${FOLDER}\*.png"
        Delete "${FOLDER}\*.thtml"
        RMDir  "${FOLDER}"

      skip_${PFI_UNIQUE_ID}:

    !macroend

  ;--------------------------------------------------------------------------
  ; 'installer.nsi' macro used when generating data for the "Setup Summary" page
  ;--------------------------------------------------------------------------

    !macro PFI_SectionNotSelected SECTION JUMPIFNOTSELECTED
        !insertmacro PFI_UNIQUE_ID

        !insertmacro SectionFlagIsSet "${SECTION}" "${SF_SELECTED}" "selected_${PFI_UNIQUE_ID}" "${JUMPIFNOTSELECTED}"

      selected_${PFI_UNIQUE_ID}:
    !macroend

!endif


#==============================================================================
#
# Macros used only by the 'adduser.nsi' script (and/or its 'include' files):
#
#     PFI_UI_LANG_CONFIG
#     PFI_OECONFIG_LOG_ENTRY
#     PFI_OOECONFIG_BEFORE_LOG
#     PFI_OOECONFIG_CHANGES_LOG
#     PFI_SkinCaseChange
#     PFI_Copy_HKLM_to_HKCU
#
# Note: The 'transAUW.nsi' script builds the utility which tests the translations.
#==============================================================================

!ifdef ADDUSER | TRANSLATOR_AUW
  ;--------------------------------------------------------------------------
  ; 'adduser.nsi' macro used to select the POPFile UI language according to the language used
  ; for the installation process (NSIS language names differ from those used by POPFile's UI)
  ;--------------------------------------------------------------------------

  !macro PFI_UI_LANG_CONFIG PFI_SETTING UI_SETTING
        !insertmacro PFI_UNIQUE_ID

        StrCmp $LANGUAGE ${LANG_${PFI_SETTING}} 0 skip_${PFI_UNIQUE_ID}
        IfFileExists "$G_ROOTDIR\languages\${UI_SETTING}.msg" 0 lang_done
        StrCpy ${L_LANG} "${UI_SETTING}"
        Goto lang_save

      skip_${PFI_UNIQUE_ID}:
  !macroend

  ;--------------------------------------------------------------------------
  ; 'adduser.nsi' macros used to make 'Outlook' & 'Outlook Express' account log files
  ;--------------------------------------------------------------------------

  !macro PFI_OECONFIG_LOG_ENTRY LOGTYPE VALUE WIDTH
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

  !macro PFI_OOECONFIG_BEFORE_LOG VALUE WIDTH
      !insertmacro PFI_OECONFIG_LOG_ENTRY "OOECONFIG" "${VALUE}" "${WIDTH}"
  !macroend

  !macro PFI_OOECONFIG_CHANGES_LOG VALUE WIDTH
      !insertmacro PFI_OECONFIG_LOG_ENTRY "OOECHANGES" "${VALUE}" "${WIDTH}"
  !macroend

  ;--------------------------------------------------------------------------
  ; 'adduser.nsi' macro used to ensure current skin selection uses lowercase.
  ; This macro is also used to handle the necessary conversion when an existing
  ; installation uses an obsolete skin which is no longer shipped with POPFile.
  ;--------------------------------------------------------------------------

  !macro PFI_SkinCaseChange OLDNAME NEWNAME

      !insertmacro PFI_UNIQUE_ID

      StrCmp ${L_SKIN} "${OLDNAME}" 0 skip_${PFI_UNIQUE_ID}
      StrCpy ${L_SKIN} "${NEWNAME}"
      Goto save_skin_setting

    skip_${PFI_UNIQUE_ID}:

  !macroend

  ;--------------------------------------------------------------------------
  ; 'adduser.nsi' macro used to update HKCU registry data using HKLM data
  ;--------------------------------------------------------------------------

  !macro PFI_Copy_HKLM_to_HKCU VAR NAME

    ReadRegStr ${VAR} HKLM "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "${NAME}"
    WriteRegStr HKCU "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "${NAME}" ${VAR}

  !macroend

!endif


#==============================================================================================
#
# Functions used only during 'installation' (i.e. not used by any 'uninstall' operations):
#
#    Installer Function: PFI_GetIEVersion
#    Installer Function: PFI_GetSeparator
#    Installer Function: PFI_GetSFNStatus
#    Installer Function: PFI_SetTrayIconMode
#    Installer Function: PFI_StrStripLZS
#
#==============================================================================================


!ifdef INSTALLER | PFIDIAG
    #--------------------------------------------------------------------------
    # Installer Function: PFI_GetIEVersion
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
    #         Call PFI_GetIEVersion
    #         Pop $R0
    #
    #         ($R0 at this point is "5.0", for example)
    #
    #--------------------------------------------------------------------------

    Function PFI_GetIEVersion

      !define L_REGDATA   $R9
      !define L_TEMP      $R8

      Push ${L_REGDATA}
      Push ${L_TEMP}

      ClearErrors
      ReadRegStr ${L_REGDATA} HKLM "Software\Microsoft\Internet Explorer" "Version"
      IfErrors ie_123

      ; Internet Explorer 4.0 or later is installed. The 'Version' value is a string with the
      ; following format: major-version.minor-version.build-number.sub-build-number

      ; According to Microsoft's Help and Support site (http://support.microsoft.com/kb/969393/)
      ; the 'Version' string under 'HKLM\Software\Microsoft\Internet Explorer' can be used to
      ; determine which version of Internet Explorer is installed. For our purposes there is no
      ; need to worry about every possible value (the Help and Support page lists over 50 versions)
      ;
      ; Internet Explorer Version         'Version' string
      ;    4.0                               4.71.1712.6
      ;    4.01                              4.72.2106.8
      ;    5                                 5.00.2014.0216
      ;    5.5                               5.50.4134.0600
      ;    6.0 (XP)                          6.0.2600.0000
      ;    7 (Vista)                         7.00.6000.16386
      ;    8 (XP,Vista,Server 2003 & 2008)   8.00.6001.18702

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


!ifdef ADDUSER | TRANSLATOR_AUW
    #--------------------------------------------------------------------------
    # Installer Function: PFI_GetSeparator
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
    #         Call PFI_GetSeparator
    #         Pop $R0
    #
    #         ($R0 at this point is ":" unless popfile.cfg has altered the default setting)
    #
    #--------------------------------------------------------------------------

    Function PFI_GetSeparator

      !define L_SEPARATOR   $R9   ; character used to separate the pop3 server from the username

      Push ${L_SEPARATOR}

      Push "$G_USERDIR\popfile.cfg"
      Push "pop3_separator"               ; used by POPFile 0.19.0 or later
      Call PFI_CfgSettingRead
      Pop ${L_SEPARATOR}
      StrCmp ${L_SEPARATOR} "" 0 exit

      Push "$G_USERDIR\popfile.cfg"
      Push "separator"                    ;  used by POPFile 0.18.x or earlier
      Call PFI_CfgSettingRead
      Pop ${L_SEPARATOR}
      StrCmp ${L_SEPARATOR} "" 0 exit

      StrCpy ${L_SEPARATOR} ":"

    exit:
      Exch ${L_SEPARATOR}

      !undef L_SEPARATOR

    FunctionEnd
!endif


!ifdef ADDUSER | INSTALLER | PORTABLE | RESTORE
    #--------------------------------------------------------------------------
    # Installer Function: PFI_GetSFNStatus
    #
    # The current version of POPFile does not work properly if the values in the POPFILE_ROOT
    # and POPFILE_USER environment variables contain spaces, therefore the installer uses the
    # SFN (Short File Name) format for these values. Normally SFN support is enabled but on
    # some NTFS-based systems SFN support has been disabled for performance reasons.
    #
    # Inputs:
    #         (top of stack)     - installation folder (e.g. as selected via DIRECTORY page)
    # Outputs:
    #         (top of stack)     - SFN Support Status (1 = enabled, 0 = disabled)
    #
    # Usage:
    #         Push $INSTDIR
    #         Call PFI_GetSFNStatus
    #         Pop $R0
    #
    #         ($R0 will be "1" is SFN Support is enabled for the $INSTDIR volume)
    #
    #--------------------------------------------------------------------------

    Function PFI_GetSFNStatus

      !define L_FOLDERPATH   $0     ; NB: System plugin call uses '$0' instead of this symbol
      !define L_FILESYSTEM   $1     ; NB: System plugin call uses 'r1' instead of this symbol
      !define L_RESULT       $2     ; NB: System plugin call uses 'r2' instead of this symbol

      Exch ${L_FOLDERPATH}
      Push ${L_FILESYSTEM}
      Push ${L_RESULT}

      ReadRegStr ${L_RESULT} HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion
      StrCmp ${L_RESULT} "" sfn_enabled

      Push ${L_FOLDERPATH}
      Call PFI_GetCompleteFPN       ; convert input path to LFN format if possible
      Pop ${L_RESULT}               ; "" is returned if path does not exist yet
      StrCmp ${L_RESULT} "" getroot
      StrCpy ${L_FOLDERPATH} ${L_RESULT}

    getroot:
      Push ${L_FOLDERPATH}
      Call NSIS_GetRoot             ; extract the "X:" or "\\server\share" part of the path
      Pop ${L_FOLDERPATH}
      StrCpy ${L_FILESYSTEM} ""     ; volume's file system type, eg FAT32, NTFS, CDFS, UDF, ""
      StrCpy ${L_RESULT} ""         ; return code 1 = success, 0 = fail
      System::Call "kernel32::GetVolumeInformation(t '$0\',,,,,,t .r1, i ${NSIS_MAX_STRLEN}) i .r2"
      StrCmp ${L_FILESYSTEM} "NTFS" 0 sfn_enabled
      ReadRegDWORD ${L_RESULT} \
      HKLM "System\CurrentControlSet\Control\FileSystem" "NtfsDisable8dot3NameCreation"
      StrCmp ${L_RESULT} "1" 0 sfn_enabled
      StrCpy ${L_FOLDERPATH} "0"
      Goto exit

    sfn_enabled:
      StrCpy ${L_FOLDERPATH} "1"

    exit:
      Pop ${L_RESULT}
      Pop ${L_FILESYSTEM}
      Exch ${L_FOLDERPATH}

      !undef L_FOLDERPATH
      !undef L_FILESYSTEM
      !undef L_RESULT

    FunctionEnd
!endif


!ifdef ADDUSER
    #--------------------------------------------------------------------------
    # Installer Function: PFI_SetTrayIconMode
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
    #         Call PFI_SetTrayIconMode
    #
    #--------------------------------------------------------------------------

    Function PFI_SetTrayIconMode

      !define L_MODE        $R9   ; new console mode
      !define L_RESULT      $R8   ; operation result

      Exch ${L_MODE}
      Push ${L_RESULT}

      Push "$G_USERDIR\popfile.cfg"
      Push "windows_trayicon"             ;  used by POPFile 0.19.0 or later
      Push ${L_MODE}
      Call PFI_CfgSettingWrite_without_backup
      Pop ${L_RESULT}
;;;      MessageBox MB_OK "Set tray icon to '${L_MODE}' result = ${L_RESULT}"

      Pop ${L_RESULT}
      Pop ${L_MODE}

      !undef L_MODE
      !undef L_RESULT

    FunctionEnd
!endif


!ifdef ADDUSER | BACKUP | CREATEUSER | RESTORE | TRANSLATOR_AUW
    #--------------------------------------------------------------------------
    # Installer Function: PFI_StrStripLZS
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
    #         Call PFI_StrStripLZS
    #         Pop $R0
    #
    #         ($R0 at this point is "123")
    #
    #--------------------------------------------------------------------------

    Function PFI_StrStripLZS

      !define L_CHAR      $R9   ; current character
      !define L_LIMIT     $R8   ; use string length (instead of a null) to detect end-of-string
      !define L_STRING    $R7   ; the string to be processed

      Exch ${L_STRING}
      Push ${L_CHAR}
      Push ${L_LIMIT}

    loop:
      StrLen ${L_LIMIT} ${L_STRING}
      StrCmp ${L_LIMIT} 0 done
      StrCpy ${L_CHAR} ${L_STRING} 1
      StrCmp ${L_CHAR} " " strip_char
      StrCmp ${L_CHAR} "0" strip_char
      Goto done

    strip_char:
      StrCpy ${L_STRING} ${L_STRING} "" 1
      Goto loop

    done:
      Pop ${L_LIMIT}
      Pop ${L_CHAR}
      Exch ${L_STRING}

      !undef L_CHAR
      !undef L_LIMIT
      !undef L_STRING

    FunctionEnd
!endif


#==============================================================================================
#
# Functions used only during 'uninstallation' (i.e. not used by any 'install' operations):
#
#    Installer Function: un.PFI_DeleteEnvStr
#    Installer Function: un.PFI_DeleteEnvStrNTAU
#
#==============================================================================================


!ifdef INSTALLER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_DeleteEnvStr
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
    #         Call un.PFI_DeleteEnvStr
    #
    #--------------------------------------------------------------------------

    Function un.PFI_DeleteEnvStr
      Exch $0       ; $0 now has the name of the variable
      Push $1
      Push $2
      Push $3
      Push $4
      Push $5

      Call un.NSIS_IsNT
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
    # Uninstaller Function: un.PFI_DeleteEnvStrNTAU
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
    #         Call un.PFI_DeleteEnvStrNTAU
    #
    #--------------------------------------------------------------------------

    Function un.PFI_DeleteEnvStrNTAU
      Exch $0       ; $0 now has the name of the variable
      Push $1
      Push $2
      Push $3
      Push $4
      Push $5

      Call un.NSIS_IsNT
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
# Macro-based Functions which may be used by the installer and uninstaller (in alphabetic order)
#
#    Macro:                PFI_AtLeastVista
#    Installer Function:   PFI_AtLeastVista
#    Uninstaller Function: un.PFI_AtLeastVista
#
#    Macro:                PFI_AtLeastWin2K
#    Installer Function:   PFI_AtLeastWin2K
#    Uninstaller Function: un.PFI_AtLeastWin2K
#
#    Macro:                PFI_AtLeastWinNT4
#    Installer Function:   PFI_AtLeastWinNT4
#    Uninstaller Function: un.PFI_AtLeastWinNT4
#
#    Macro:                PFI_CfgSettingRead
#    Installer Function:   PFI_CfgSettingRead
#    Uninstaller Function: un.PFI_CfgSettingRead
#
#    Macro:                PFI_CfgSettingWrite_with_backup
#    Installer Function:   PFI_CfgSettingWrite_with_backup
#    Uninstaller Function: un.PFI_CfgSettingWrite_with_backup
#
#    Macro:                PFI_CfgSettingWrite_without_backup
#    Installer Function:   PFI_CfgSettingWrite_without_backup
#    Uninstaller Function: un.PFI_CfgSettingWrite_without_backup
#
#    Macro:                PFI_CheckIfLocked
#    Installer Function:   PFI_CheckIfLocked
#    Uninstaller Function: un.PFI_CheckIfLocked
#
#    Macro:                PFI_CheckSQLiteIntegrity
#    Installer Function:   PFI_CheckSQLiteIntegrity
#    Uninstaller Function: un.PFI_CheckSQLiteIntegrity
#
#    Macro:                PFI_DumpLog
#    Installer Function:   PFI_DumpLog
#    Uninstaller Function: un.PFI_DumpLog
#
#    Macro:                PFI_FindLockedPFE
#    Installer Function:   PFI_FindLockedPFE
#    Uninstaller Function: un.PFI_FindLockedPFE
#
#    Macro:                PFI_GetCompleteFPN
#    Installer Function:   PFI_GetCompleteFPN
#    Uninstaller Function: un.PFI_GetCompleteFPN
#
#    Macro:                PFI_GetCorpusPath
#    Installer Function:   PFI_GetCorpusPath
#    Uninstaller Function: un.PFI_GetCorpusPath
#
#    Macro:                PFI_GetDatabaseName
#    Installer Function:   PFI_GetDatabaseName
#    Uninstaller Function: un.PFI_GetDatabaseName
#
#    Macro:                PFI_GetDataPath
#    Installer Function:   PFI_GetDataPath
#    Uninstaller Function: un.PFI_GetDataPath
#
#    Macro:                PFI_GetDateTimeStamp
#    Installer Function:   PFI_GetDateTimeStamp
#    Uninstaller Function: un.PFI_GetDateTimeStamp
#
#    Macro:                PFI_GetFileSize
#    Installer Function:   PFI_GetFileSize
#    Uninstaller Function: un.PFI_GetFileSize
#
#    Macro:                PFI_GetLocalTime
#    Installer Function:   PFI_GetLocalTime
#    Uninstaller Function: un.PFI_GetLocalTime
#
#    Macro:                PFI_GetMessagesPath
#    Installer Function:   PFI_GetMessagesPath
#    Uninstaller Function: un.PFI_GetMessagesPath
#
#    Macro:                PFI_GetPOPFileSchemaVersion
#    Installer Function:   PFI_GetPOPFileSchemaVersion
#    Uninstaller Function: un.PFI_GetPOPFileSchemaVersion
#
#    Macro:                PFI_GetSQLdbPathName
#    Installer Function:   PFI_GetSQLdbPathName
#    Uninstaller Function: un.PFI_GetSQLdbPathName
#
#    Macro:                PFI_GetSQLiteFormat
#    Installer Function:   PFI_GetSQLiteFormat
#    Uninstaller Function: un.PFI_GetSQLiteFormat
#
#    Macro:                PFI_GetSQLiteSchemaVersion
#    Installer Function:   PFI_GetSQLiteSchemaVersion
#    Uninstaller Function: un.PFI_GetSQLiteSchemaVersion
#
#    Macro:                PFI_GetTimeStamp
#    Installer Function:   PFI_GetTimeStamp
#    Uninstaller Function: un.PFI_GetTimeStamp
#
#    Macro:                PFI_RequestPFIUtilsShutdown
#    Installer Function:   PFI_RequestPFIUtilsShutdown
#    Uninstaller Function: un.PFI_RequestPFIUtilsShutdown
#
#    Macro:                PFI_RunSQLiteCommand
#    Installer Function:   PFI_RunSQLiteCommand
#    Uninstaller Function: un.PFI_RunSQLiteCommand
#
#    Macro:                PFI_SendToRecycleBin
#    Installer Function:   PFI_SendToRecycleBin
#    Uninstaller Function: un.PFI_SendToRecycleBin
#
#    Macro:                PFI_ServiceActive
#    Installer Function:   PFI_ServiceActive
#    Uninstaller Function: un.PFI_ServiceActive
#
#    Macro:                PFI_ServiceCall
#    Installer Function:   PFI_ServiceCall
#    Uninstaller Function: un.PFI_ServiceCall
#
#    Macro:                PFI_ServiceRunning
#    Installer Function:   PFI_ServiceRunning
#    Uninstaller Function: un.PFI_ServiceRunning
#
#    Macro:                PFI_ServiceStatus
#    Installer Function:   PFI_ServiceStatus
#    Uninstaller Function: un.PFI_ServiceStatus
#
#    Macro:                PFI_ShutdownViaUI
#    Installer Function:   PFI_ShutdownViaUI
#    Uninstaller Function: un.PFI_ShutdownViaUI
#
#    Macro:                PFI_StrBackSlash
#    Installer Function:   PFI_StrBackSlash
#    Uninstaller Function: un.PFI_StrBackSlash
#
#    Macro:                PFI_StrCheckDecimal
#    Installer Function:   PFI_StrCheckDecimal
#    Uninstaller Function: un.PFI_StrCheckDecimal
#
#    Macro:                PFI_StrCheckHexadecimal
#    Installer Function:   PFI_StrCheckHexadecimal
#    Uninstaller Function: un.PFI_StrCheckHexadecimal
#
#    Macro:                PFI_StrStr
#    Installer Function:   PFI_StrStr
#    Uninstaller Function: un.PFI_StrStr
#
#    Macro:                PFI_WaitUntilUnlocked
#    Installer Function:   PFI_WaitUntilUnlocked
#    Uninstaller Function: un.PFI_WaitUntilUnlocked
#
#==============================================================================================

#--------------------------------------------------------------------------
# Macro: PFI_AtLeastVista
#
# The installation process and the uninstall process may both need a function which
# detects if we are running on Windows Vista or later. This macro makes maintenance easier
# by ensuring that both processes use identical functions, with the only difference being
# their names.
#
# NOTE:
# The !insertmacro PFI_AtLeastVista "" and !insertmacro PFI_AtLeastVista "un."
# commands are included in this file so the NSIS script can use 'Call PFI_AtLeastVista'
# and 'Call un.PFI_AtLeastVista' without additional preparation.
#
# Inputs:
#         (none)
#
# Outputs:
#         (top of stack)   - 1 if Vista or later, 0 if WinXP or earlier
#
# Usage (after macro has been 'inserted'):
#
#         Call PFI_AtLeastVista
#         Pop $R0
#
#         ($R0 at this point is "0" if running on, say, Windows 2000)
#--------------------------------------------------------------------------

!macro PFI_AtLeastVista UN
  Function ${UN}PFI_AtLeastVista

    !define L_RESULT  $R9
    !define L_TEMP    $R8

    Push ${L_RESULT}
    Push ${L_TEMP}

    ClearErrors
    ReadRegStr ${L_RESULT} HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion
    IfErrors preVistasystem
    StrCpy ${L_TEMP} ${L_RESULT} 1
    IntCmp ${L_TEMP} 5 preVistasystem preVistasystem 0
    StrCpy ${L_RESULT} "1"
    Goto exit

  preVistasystem:
    StrCpy ${L_RESULT} "0"

  exit:
    Pop ${L_TEMP}
    Exch ${L_RESULT}

    !undef L_RESULT
    !undef L_TEMP

  FunctionEnd
!macroend

!ifdef ADDUSER | INSTALLER
      #--------------------------------------------------------------------------
      # Installer Function: PFI_AtLeastVista
      #
      # This function is used during the installation process
      #--------------------------------------------------------------------------

      !insertmacro PFI_AtLeastVista ""
!endif

!ifdef INSTALLER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_AtLeastVista
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro PFI_AtLeastVista "un."
!endif


#--------------------------------------------------------------------------
# Macro: PFI_AtLeastWin2K
#
# The installation process and the uninstall process may both need a function which
# detects if we are running on Windows 2000 or later. This macro makes maintenance easier
# by ensuring that both processes use identical functions, with the only difference being
# their names.
#
# NOTE:
# The !insertmacro PFI_AtLeastWin2K "" and !insertmacro PFI_AtLeastWin2K "un."
# commands are included in this file so the NSIS script can use 'Call PFI_AtLeastWin2K'
# and 'Call un.PFI_AtLeastWin2K' without additional preparation.
#
# Inputs:
#         (none)
#
# Outputs:
#         (top of stack)   - 0 if Win9x, WinME, Win NT or 1 if higher
#
# Usage (after macro has been 'inserted'):
#
#         Call PFI_AtLeastWin2K
#         Pop $R0
#
#         ($R0 at this point is "0" if running on Win95, Win98, WinME, NT3.x or NT 4.x)
#--------------------------------------------------------------------------

!macro PFI_AtLeastWin2K UN
  Function ${UN}PFI_AtLeastWin2K

    !define L_RESULT  $R9
    !define L_TEMP    $R8

    Push ${L_RESULT}
    Push ${L_TEMP}

    ClearErrors
    ReadRegStr ${L_RESULT} HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion
    IfErrors preWin2Ksystem
    StrCpy ${L_TEMP} ${L_RESULT} 1
    IntCmp ${L_TEMP} 4 preWin2Ksystem preWin2Ksystem 0
    StrCpy ${L_RESULT} "1"
    Goto exit

  preWin2Ksystem:
    StrCpy ${L_RESULT} "0"

  exit:
    Pop ${L_TEMP}
    Exch ${L_RESULT}

    !undef L_RESULT
    !undef L_TEMP

  FunctionEnd
!macroend

!ifdef INSTALLER
      #--------------------------------------------------------------------------
      # Installer Function: PFI_AtLeastWin2K
      #
      # This function is used during the installation process
      #--------------------------------------------------------------------------

      !insertmacro PFI_AtLeastWin2K ""
!endif

;#--------------------------------------------------------------------------
;# Uninstaller Function: un.PFI_AtLeastWin2K
;#
;# This function is used during the uninstall process
;#--------------------------------------------------------------------------
;
;!insertmacro PFI_AtLeastWin2K "un."


#--------------------------------------------------------------------------
# Macro: PFI_AtLeastWinNT4
#
# The installation process and the uninstall process may both need a function which
# detects if we are running on Windows NT4 or later. This macro makes maintenance easier
# by ensuring that both processes use identical functions, with the only difference being
# their names.
#
# NOTE:
# The !insertmacro PFI_AtLeastWinNT4 "" and !insertmacro PFI_AtLeastWinNT4 "un."
# commands are included in this file so the NSIS script can use 'Call PFI_AtLeastWinNT4'
# and 'Call un.PFI_AtLeastWinNT4' without additional preparation.
#
# Inputs:
#         (none)
#
# Outputs:
#         (top of stack)   - 0 if Win9x or WinME, 1 if Win NT4 or higher
#
# Usage (after macro has been 'inserted'):
#
#         Call PFI_AtLeastWinNT4
#         Pop $R0
#
#         ($R0 at this point is "0" if running on Win95, Win98, WinME or NT3.x)
#--------------------------------------------------------------------------

!macro PFI_AtLeastWinNT4 UN
  Function ${UN}PFI_AtLeastWinNT4

    !define L_RESULT  $R9
    !define L_TEMP    $R8

    Push ${L_RESULT}
    Push ${L_TEMP}

    ClearErrors
    ReadRegStr ${L_RESULT} HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion
    IfErrors preNT4system
    StrCpy ${L_TEMP} ${L_RESULT} 1
    StrCmp ${L_TEMP} '3' preNT4system
    StrCpy ${L_RESULT} "1"
    Goto exit

  preNT4system:
    StrCpy ${L_RESULT} "0"

  exit:
    Pop ${L_TEMP}
    Exch ${L_RESULT}

    !undef L_RESULT
    !undef L_TEMP

  FunctionEnd
!macroend

!ifdef ADDSSL | ADDUSER | BACKUP | INSTALLER | MONITORCC | ONDEMAND | RESTORE
      #--------------------------------------------------------------------------
      # Installer Function: PFI_AtLeastWinNT4
      #
      # This function is used during the installation process
      #--------------------------------------------------------------------------

      !insertmacro PFI_AtLeastWinNT4 ""
!endif

!ifdef ADDUSER | INSTALLER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_AtLeastWinNT4
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro PFI_AtLeastWinNT4 "un."
!endif


#--------------------------------------------------------------------------
# Macro: PFI_CfgSettingRead
#
# The installation process and the uninstall process may both require a function
# to read the value of a setting from POPFile's configuration file. This macro
# makes maintenance easier by ensuring that both processes use identical functions,
# with the only difference being their names.
#
# NOTE:
# The !insertmacro PFI_CfgSettingRead "" and !insertmacro PFI_CfgSettingRead "un."
# commands are included here so the NSIS script can use 'Call PFI_CfgSettingRead' and
# 'Call un.PFI_CfgSettingRead' without additional preparation.
#
# This function is used to read the value of one of the settings in the
# POPFile configuration file (popfile.cfg). Although POPFile always uses
# the 'popfile.cfg' filename for its configuration data, some NSIS-based
# programs work with local copies so the filename and location is always
# passed as a parameter to this function.
#
# Note that the entire file is scanned and we return the last match found!
# Early versions of POPFile did not clean the file so there can be more
# than one line setting the same value (POPFile uses the last one found)
#
# Inputs:
#         (top of stack)        - the configuration setting to be read
#         (top of stack - 1)    - full path to the configuration file
#
# Outputs:
#         (top of stack)        - current value of the configuration setting
#                                (empty string returned if error detected)
#
#         ErrorFlag             - clear if no errors detected,
#                                 set if file not found, or
#                                 set if setting not found
#
# Usage (after macro has been 'inserted'):
#
#         Push "C:\User\Data\POPFile\popfile.cfg"
#         Push "html_port"
#         Call PFI_CfgSettingRead
#         Pop $R0
#
#         ($R0 at this point is "8080" if the default UI port is being used.
#          The Error flag will also be clear now).
#
#--------------------------------------------------------------------------

!macro PFI_CfgSettingRead UN
  Function ${UN}PFI_CfgSettingRead

    !define L_CFG       $R9     ; handle for the configuration file
    !define L_LINE      $R8     ; a line from the configuration file
    !define L_MATCHLEN  $R7     ; length (incl terminator space) of setting
    !define L_PARAM     $R6     ; possible match from configuration file
    !define L_RESULT    $R5
    !define L_SETTING   $R4     ; the configuration setting to be read
    !define L_TEXTEND   $R3     ; helps ensure correct handling of lines over 1023 chars long

    Exch ${L_SETTING}           ; get the name of the setting to be found
    Exch
    Exch ${L_CFG}               ; get the full path to the configuration file
    Push ${L_LINE}
    Push ${L_MATCHLEN}
    Push ${L_PARAM}
    Push ${L_RESULT}
    Push ${L_TEXTEND}

    StrCpy ${L_RESULT} ""
    StrCmp ${L_SETTING} "" error_exit

    StrCpy ${L_SETTING} "${L_SETTING} "   ; include the terminating space
    StrLen ${L_MATCHLEN} ${L_SETTING}

    ClearErrors
    FileOpen  ${L_CFG} "${L_CFG}" r
    IfErrors error_exit

  found_eol:
    StrCpy ${L_TEXTEND} "<eol>"

  loop:
    FileRead ${L_CFG} ${L_LINE}
    StrCmp ${L_LINE} "" done
    StrCmp ${L_TEXTEND} "<eol>" 0 check_eol
    StrCmp ${L_LINE} "$\n" loop

    StrCpy ${L_PARAM} ${L_LINE} ${L_MATCHLEN}
    StrCmp ${L_PARAM} ${L_SETTING} 0 check_eol
    StrCpy ${L_RESULT} ${L_LINE} "" ${L_MATCHLEN}

  check_eol:

    ; Now read file until we get to end of the current line
    ; (i.e. until we find text ending in <CR><LF>, <CR> or <LF>)

    StrCpy ${L_TEXTEND} ${L_LINE} 1 -1
    StrCmp ${L_TEXTEND} "$\n" found_eol
    StrCmp ${L_TEXTEND} "$\r" found_eol loop

  done:
    FileClose ${L_CFG}
    StrCmp ${L_RESULT} "" error_exit
    Push ${L_RESULT}
    Call ${UN}NSIS_TrimNewlines
    Pop ${L_RESULT}
    ClearErrors
    StrCmp ${L_RESULT} "" 0 exit

  error_exit:
    SetErrors

  exit:
    StrCpy ${L_SETTING} ${L_RESULT}
    Pop ${L_TEXTEND}
    Pop ${L_RESULT}
    Pop ${L_PARAM}
    Pop ${L_MATCHLEN}
    Pop ${L_LINE}
    Pop ${L_CFG}
    Exch ${L_SETTING}

    !undef L_CFG
    !undef L_LINE
    !undef L_MATCHLEN
    !undef L_PARAM
    !undef L_RESULT
    !undef L_SETTING
    !undef L_TEXTEND

  FunctionEnd
!macroend

!ifdef ADDSSL | ADDUSER | CREATEUSER | DBANALYSER | DBSTATUS | PFIDIAG | INSTALLER | MSGCAPTURE | ONDEMAND | PORTABLE | RUNPOPFILE | SHUTDOWN | TRANSLATOR_AUW
    #--------------------------------------------------------------------------
    # Installer Function: PFI_CfgSettingRead
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_CfgSettingRead ""
!endif

!ifdef ADDUSER | INSTALLER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_CfgSettingRead
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro PFI_CfgSettingRead "un."
!endif


#--------------------------------------------------------------------------
# Macro: PFI_CfgSettingWrite_with_backup/PFI_CfgSettingWrite_without_backup
#
# The installation process and the uninstall process may both require a function
# to write a new setting value to POPFile's configuration file. This macro
# makes maintenance easier by ensuring that both processes use identical functions,
# with the only difference being their names.
#
# This function is used to write a value for one of the settings in the
# POPFile configuration file (popfile.cfg). Although POPFile always uses
# the 'popfile.cfg' filename for its configuration data, some NSIS-based
# programs work with local copies so the absolute path location is always
# passed as a parameter to this function.
#
# Note that if an empty string is supplied as the value then the named setting
# will be deleted from the configuration file.
#
# The 'with_backup' variants use the standard 1-2-3 backup naming sequence. For
# cases where several values are being set the "without_backup' variants may be
# more useful (since only three backups are maintained the original file could
# easily be lost).
#
# Inputs:
#         (top of stack)        - the value to be set (if "" setting will be deleted)
#         (top of stack - 1)    - the configuration setting's name
#         (top of stack - 2)    - full path to the configuration file
#
# Outputs:
#         (top of stack)        - operation result:
#                                    CHANGED - the setting has been changed,
#                                    DELETED - entry deleted from the file,
#                                    ADDED   - new entry added at end of file,
#                                    SAME    - file left unchanged,
#                                 or ERROR   - an error was detected
#
#         ErrorFlag             - clear if no errors detected,
#                                 set if file not found, or
#                                 set if setting not found
#
# Usage (after macro has been 'inserted'):
#
#         Push "C:\User\Data\POPFile\popfile.cfg"
#         Push "html_port"
#         Push "8080"
#         Call PFI_CfgSettingWrite_with_backup
#         Pop $R0
#
#         ($R0 at this point is "SAME" if the configuration file currently
#          uses the value 8080; in this case the file is not re-written so
#          a backup copy of the original file is _not_ made)
#
#--------------------------------------------------------------------------

!macro PFI_CfgSettingWrite UN BACKUP

  !if '${BACKUP}' == 'backup'
      Function ${UN}PFI_CfgSettingWrite_with_backup
  !else
      Function ${UN}PFI_CfgSettingWrite_without_backup
  !endif

    !ifndef C_CFG_WRITE
      !define C_CFG_WRITE
      !define C_CFG_WRITE_CHANGED   "CHANGED"
      !define C_CFG_WRITE_DELETED   "DELETED"
      !define C_CFG_WRITE_ADDED     "ADDED"
      !define C_CFG_WRITE_SAME      "SAME"
      !define C_CFG_WRITE_ERROR     "ERROR"

      !define C_FALSE               "FALSE"
      !define C_TRUE                "TRUE"
    !endif

    !define L_FOUND       $R9   ; TRUE | FALSE
    !define L_LINE        $R8   ; a line from the configuration file
    !define L_MATCHLEN    $R7   ; length (incl terminator space) of setting
    !define L_NEW_HANDLE  $R6   ; handle for the new configuration file
    !define L_OLD_CFG     $R5   ; the full path to the configuration file
    !define L_OLD_HANDLE  $R4   ; handle for the original configuration file
    !define L_PARAM       $R3   ; possible match from configuration file
    !define L_SETTING     $R2   ; the configuration setting to be written
    !define L_STATUS      $R1   ; holds one of the C_CFG_WRITE_* constants listed above
    !define L_TEMP        $R0
    !define L_TEXTEND     $9    ; helps ensure correct handling of lines over 1023 chars long
    !define L_VALUE       $8    ; the new value for the configuration setting

    Exch ${L_VALUE}             ; get the new value to be set
    Exch
    Exch ${L_SETTING}           ; get the name of the configuration setting
    Exch 2
    Exch ${L_OLD_CFG}           ; get the full path to the configuration file
    Push ${L_FOUND}
    Push ${L_LINE}
    Push ${L_MATCHLEN}
    Push ${L_NEW_HANDLE}
    Push ${L_OLD_HANDLE}
    Push ${L_PARAM}
    Push ${L_STATUS}
    Push ${L_TEMP}
    Push ${L_TEXTEND}

    StrCpy ${L_FOUND} "${C_FALSE}"
    StrCpy ${L_STATUS} ""

    StrCmp ${L_SETTING} "" error_exit

    StrCpy ${L_SETTING} "${L_SETTING} "   ; include the terminating space
    StrLen ${L_MATCHLEN} ${L_SETTING}

    ClearErrors
    FileOpen  ${L_NEW_HANDLE} "$PLUGINSDIR\new.cfg" w
    IfFileExists "${L_OLD_CFG}" 0 add_setting
    FileOpen  ${L_OLD_HANDLE} "${L_OLD_CFG}" r
    IfErrors error_exit

  found_eol:
    StrCpy ${L_TEXTEND} "<eol>"

  loop:
    FileRead ${L_OLD_HANDLE} ${L_LINE}
    StrCmp ${L_LINE} "" copy_done
    StrCmp ${L_TEXTEND} "<eol>" 0 copy_line
    StrCmp ${L_LINE} "$\n" copy_line

    StrCpy ${L_PARAM} ${L_LINE} ${L_MATCHLEN}
    StrCmp ${L_PARAM} ${L_SETTING} 0 copy_line

    ; Setting found: can now change or delete it

    StrCpy ${L_FOUND} "${C_TRUE}"

    StrCmp ${L_VALUE} "" delete_it

    StrCpy ${L_TEMP} ${L_LINE} "" ${L_MATCHLEN}
    Push ${L_TEMP}
    Call ${UN}NSIS_TrimNewlines
    Pop ${L_TEMP}
    StrCmp ${L_VALUE} ${L_TEMP} 0 change_it
    StrCmp ${L_STATUS} "${C_CFG_WRITE_CHANGED}" copy_line
    StrCpy ${L_STATUS} "${C_CFG_WRITE_SAME}"
    Goto copy_line

  delete_it:
    StrCpy ${L_STATUS} "${C_CFG_WRITE_DELETED}"
    Goto loop

  change_it:
    FileWrite ${L_NEW_HANDLE} "${L_SETTING}${L_VALUE}${MB_NL}"
    StrCpy ${L_STATUS} "${C_CFG_WRITE_CHANGED}"
    Goto loop

  copy_line:
    FileWrite ${L_NEW_HANDLE} ${L_LINE}

  ; Now read file until we get to end of the current line
  ; (i.e. until we find text ending in <CR><LF>, <CR> or <LF>)

    StrCpy ${L_TEXTEND} ${L_LINE} 1 -1
    StrCmp ${L_TEXTEND} "$\n" found_eol
    StrCmp ${L_TEXTEND} "$\r" found_eol loop

  copy_done:
    FileClose ${L_OLD_HANDLE}
    StrCmp ${L_FOUND} "TRUE" close_new_file

    ; Setting not found in file so we add it at the end
    ; (or create a new file with just this single entry)

  add_setting:
    FileWrite ${L_NEW_HANDLE} "${L_SETTING}${L_VALUE}${MB_NL}"
    StrCpy ${L_STATUS} ${C_CFG_WRITE_ADDED}

  close_new_file:
    FileClose ${L_NEW_HANDLE}

    StrCmp ${L_STATUS} ${C_CFG_WRITE_SAME} success_exit
    Push ${L_OLD_CFG}
    Call ${UN}NSIS_GetParent
    Pop ${L_TEMP}
    StrCmp ${L_TEMP} "" 0 path_supplied
    StrCpy ${L_TEMP} "."
    Goto update_file

  path_supplied:
    StrLen ${L_VALUE} ${L_TEMP}
    IntOp ${L_VALUE} ${L_VALUE} + 1
    StrCpy ${L_OLD_CFG} ${L_OLD_CFG} "" ${L_VALUE}

  update_file:
    !if '${BACKUP}' == 'backup'
        !insertmacro PFI_BACKUP_123 "${L_TEMP}" "${L_OLD_CFG}"
    !else
        Delete "$PLUGINSDIR\old.cfg"
        Rename "${L_TEMP}\${L_OLD_CFG}"  "$PLUGINSDIR\old.cfg"
    !endif
    ClearErrors
    Rename "$PLUGINSDIR\new.cfg" "${L_TEMP}\${L_OLD_CFG}"
    IfErrors error_exit

  success_exit:
    ClearErrors
    Goto exit

  error_exit:
    StrCpy ${L_STATUS} ${C_CFG_WRITE_ERROR}
    SetErrors

  exit:
    StrCpy ${L_SETTING} ${L_STATUS}
    Pop ${L_TEXTEND}
    Pop ${L_TEMP}
    Pop ${L_STATUS}
    Pop ${L_PARAM}
    Pop ${L_OLD_HANDLE}
    Pop ${L_NEW_HANDLE}
    Pop ${L_MATCHLEN}
    Pop ${L_LINE}
    Pop ${L_FOUND}
    Pop ${L_OLD_CFG}
    Pop ${L_VALUE}
    Exch ${L_SETTING}

    !undef L_FOUND
    !undef L_LINE
    !undef L_MATCHLEN
    !undef L_NEW_HANDLE
    !undef L_OLD_CFG
    !undef L_OLD_HANDLE
    !undef L_PARAM
    !undef L_SETTING
    !undef L_STATUS
    !undef L_TEMP
    !undef L_TEXTEND
    !undef L_VALUE

  FunctionEnd
!macroend

!macro PFI_CfgSettingWrite_with_backup UN
  !insertmacro PFI_CfgSettingWrite "${UN}" "backup"
!macroend

!macro PFI_CfgSettingWrite_without_backup UN
  !insertmacro PFI_CfgSettingWrite "${UN}" "no_backup"
!macroend

!ifdef PORTABLE
    #--------------------------------------------------------------------------
    # Installer Function: PFI_CfgSettingWrite_with_backup
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_CfgSettingWrite_with_backup ""
!endif

;#--------------------------------------------------------------------------
;# Uninstaller Function: un.PFI_CfgSettingWrite_with_backup
;#
;# This function is used during the uninstallation process
;#--------------------------------------------------------------------------
;
;!insertmacro PFI_CfgSettingWrite_with_backup "un."

!ifdef ADDUSER | CREATEUSER
    #--------------------------------------------------------------------------
    # Installer Function: PFI_CfgSettingWrite_without_backup
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_CfgSettingWrite_without_backup ""
!endif

!ifdef INSTALLER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_CfgSettingWrite_without_backup
    #
    # This function is used during the uninstallation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_CfgSettingWrite_without_backup "un."
!endif


#--------------------------------------------------------------------------
# Macro: PFI_CheckIfLocked
#
# The installation process and the uninstall process may both require a function
# which checks if a particular POPFile file (usually an EXE file) is being used.
# This macro makes maintenance easier by ensuring that both processes use identical
# functions, with the only difference being their names.
#
# There are several different ways to run POPFile so this function accepts a list
# of full pathnames to the executable files which are to be checked (to make it
# easier to check the various ways in which POPFile can be run). This list is
# passed via the stack, with a marker string being used to mark the list's end.
#
# Normally the LockedList plugin will be used to check if any of the specified
# executable files is in use.
#
# Note that the format of the path supplied to the plugin is important. If a program
# was started from a 'hybrid' path using a mixture of SFN and LFN names, such as
# "C:\PROGRA~1\POPFILE\popfileib.exe", and the plugin is given the equivalent LFN
# path ("C:\Program Files\POPFile\popfileib.exe") then the plugin will fail to detect
# if this particular executable is locked.
#
# To avoid these LFN/SFN problems we use the plugin's special "filename only" mode by
# supplying the file name without the path. In this mode the plugin calls a 'callback'
# function for each matching locked file found so all we have to do is check if the
# file found is one of the ones in which we are interested.
#
# This function is normally used to check if a particular executable (.exe) file is
# locked. However to make the function more general purpose it checks if a DLL has
# been specified and treats that as an executable. All other filenames are assumed
# to be ordinary files.
#
# Note that the 'LockecdList::IsFileLocked' function cannot be used here as under
# some circumstances (still to be investigated!) it mistakenly reports that a file
# is locked.
#
# Unfortunately the 'LockedList' plugin relies upon OS features only found in
# Windows NT4 or later so older systems such as Win9x must be treated as special
# cases.
#
# If none of the specified files is locked then an empty string is returned,
# otherwise the function returns the path to the first locked file it detects.
#
# NOTE:
# The !insertmacro PFI_CheckIfLocked "" & !insertmacro PFI_CheckIfLocked "un." commands
# are included in this file so the NSIS script can use 'Call PFI_CheckIfLocked' and
# 'Call un.PFI_CheckIfLocked' without additional preparation.
#
# Inputs:
#         (top of stack)           - full path of an EXE file to be checked
#         (top of stack - 1)       - full path of an EXE file to be checked
#          ...
#         (top of stack - n)       - full path of an EXE file to be checked
#         (top of stack - (n + 1)) - end-of-data marker (see C_EXE_END_MARKER definition)
#
# Outputs:
#         (top of stack)           - if none of the files is in use, an empty string ("")
#                                    is returned, otherwise the path to the first locked
#                                    file found is returned
#
# Usage (after macro has been 'inserted'):
#
#         Push "${C_EXE_END_MARKER}"
#         Push "$INSTDIR\wperl.exe"
#         Call PFI_CheckIfLocked
#         Pop $R0
#
#        (if the file is no longer in use, $R0 will be "")
#--------------------------------------------------------------------------

!macro PFI_CheckIfLocked UN

  !ifndef PFI_CheckIfLocked_Globals

      ; Since the function gets an unknown number of parameters via the stack
      ; it makes the code much simpler if the function uses GLOBAL variables
      ; instead of the '!define X/Push X/Pop X/!undef X' sequences normally
      ; used to preserve any local variables used by the function

      !define PFI_CheckIfLocked_Globals
      var /GLOBAL G_CIL_FILE
      var /GLOBAL G_CIL_FLAG
      var /GLOBAL G_CIL_PATH
      var /GLOBAL G_CIL_RESULT
      var /GLOBAL G_CIL_TEMP
  !endif

  Function ${UN}PFI_CheckIfLocked_Callback
    Pop $G_CIL_RESULT   ; Get process ID (and ignore it)
    Exch
    Pop $G_CIL_RESULT   ; Get description (and ignore it)
    Call ${UN}PFI_GetCompleteFPN
    Pop $G_CIL_RESULT   ; Get "full path to the locked file"
    StrCmp $G_CIL_RESULT "$G_CIL_PATH\$G_CIL_FILE" 0 continue
    StrCpy $G_CIL_FLAG $G_CIL_RESULT
    Push false
    Goto exit

  continue:
    Push true

  exit:
  FunctionEnd

  Function ${UN}PFI_CheckIfLocked
    Call ${UN}PFI_AtLeastWinNT4
    Pop $G_CIL_FLAG
    StrCmp $G_CIL_FLAG "0" specialcase

    ; The target system provides the features required by the LockedList plugin

    StrCpy $G_CIL_FLAG ""

  get_next_input_param:
    ClearErrors
    Pop $G_CIL_PATH
    IfErrors panic
    StrCmp $G_CIL_PATH "${C_EXE_END_MARKER}" input_exhausted
    StrCmp $G_CIL_FLAG "" 0 get_next_input_param
    IfFileExists "$G_CIL_PATH" 0 get_next_input_param

    ; Normally the POPFile programs are started using a hybrid path, where the filename
    ; is given in LFN rather than SFN form but the remainder of the path is in SFN form.
    ;
    ; For example instead of using the pathname "C:\Program Files\POPFile\popfileif.exe"
    ; or the pathname "C:\PROGRA~1\POPFILE\POPFIL~2.EXE" to start the program, the hybrid
    ; pathname "C:\PROGRA~1\POPFILE\popfileif.exe" is used.
    ;
    ; These hybrid pathnames cause problems because the LockedList plugin searches for
    ; an exact match with the specified pathame. As a workaround we use the plugin's
    ; special "filename only" mode to find, for example, "popfileif.exe" and then
    ; analyse the results to see if any match the path in which we are interested.
    ;
    ; Note that the 'LockedList::IsFileLocked' function _cannot_ be used here
    ; because it incorrectly reports some files are locked.

    DetailPrint "Is '$G_CIL_PATH' locked?"
    Push $G_CIL_PATH
    Call ${UN}PFI_GetCompleteFPN
    Pop $G_CIL_FILE
    Push $G_CIL_FILE
    Call ${UN}NSIS_GetParent
    Pop $G_CIL_PATH
    StrLen $G_CIL_TEMP $G_CIL_PATH
    IntOp $G_CIL_TEMP $G_CIL_TEMP + 1
    StrCpy $G_CIL_FILE $G_CIL_FILE "" $G_CIL_TEMP
    StrCpy $G_CIL_TEMP $G_CIL_FILE "" -4
    StrCmp $G_CIL_TEMP ".exe" check_module
    StrCmp $G_CIL_TEMP ".dll" check_module

    ; Assume the file is "our" POPFile database so there is no need to use
    ; the LockedList plugin's "AddFile" mode to check if the file is locked

    SetFileAttributes "$G_CIL_PATH\$G_CIL_FILE" NORMAL
    ClearErrors
    FileOpen $G_CIL_TEMP "$G_CIL_PATH\$G_CIL_FILE" a
    FileClose $G_CIL_TEMP
    IfErrors 0 get_next_input_param
    StrCpy $G_CIL_FLAG "$G_CIL_PATH\$G_CIL_FILE"
    Goto get_next_input_param

  check_module:
    LockedList::AddModule /NOUNLOAD "\$G_CIL_FILE"
    GetFunctionAddress $G_CIL_TEMP ${UN}PFI_CheckIfLocked_Callback
    LockedList::SilentSearch $G_CIL_TEMP
    Goto get_next_input_param

  panic:
    MessageBox MB_OK|MB_ICONSTOP "Internal Error:\
      ${MB_NL}${MB_NL}\
      '${UN}PFI_CheckIfLocked' function did not find\
      ${MB_NL}\
      the '${C_EXE_END_MARKER}' marker on the stack!"
    Abort "Internal Error: \
        '${UN}PFI_CheckIfLocked' function did not find the \
        '${C_EXE_END_MARKER}' marker on the stack!"

  input_exhausted:
    Push $G_CIL_FLAG
    Goto exit

    ; Windows 95, 98, ME and NT3.x are treated as special cases
    ; (because they do not support the LockedList plugin)

  specialcase:
    StrCpy $G_CIL_FLAG ""

  loop:
    ClearErrors
    Pop $G_CIL_PATH
    IfErrors panic
    StrCmp $G_CIL_PATH "${C_EXE_END_MARKER}" allread
    StrCmp $G_CIL_FLAG "" 0 loop
    IfFileExists "$G_CIL_PATH" 0 loop
    SetFileAttributes "$G_CIL_PATH" NORMAL
    ClearErrors
    FileOpen $G_CIL_FILE "$G_CIL_PATH" a
    FileClose $G_CIL_FILE
    IfErrors 0 loop
    StrCpy $G_CIL_FLAG "$G_CIL_PATH"
    Goto loop

  allread:
    Push $G_CIL_FLAG

  exit:
  FunctionEnd
!macroend

!ifdef ADDSSL | ADDUSER | BACKUP | INSTALLER | MONITORCC | ONDEMAND | RESTORE
    #--------------------------------------------------------------------------
    # Installer Function: PFI_CheckIfLocked
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_CheckIfLocked ""
!endif

!ifdef ADDUSER | INSTALLER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_CheckIfLocked
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro PFI_CheckIfLocked "un."
!endif


#--------------------------------------------------------------------------
# Macro: PFI_CheckSQLiteIntegrity
#
# The installation process and the uninstall process may both need a function which
# uses the SQLite command-line utility to perform a database integrity check. This macro
# makes maintenance easier by ensuring that both processes use identical functions, with
# the only difference being their names.
#
# NOTE:
# The !insertmacro PFI_CheckSQLiteIntegrity "" and !insertmacro PFI_CheckSQLiteIntegrity "un."
# commands are included in this file so the NSIS script can use 'Call PFI_CheckSQLiteIntegrity'
# and 'Call un.PFI_CheckSQLiteIntegrity' without additional preparation.
#
# Inputs:
#         (top of stack)     - full pathname of the SQLite database file
#
# Outputs:
#         (top of stack)     - the result from the SQLite command-line utility ('ok' expected)
#                              If the result is enclosed in parentheses then an error occurred.
#
# Usage (after macro has been 'inserted'):
#
#         Push "popfile.db"
#         Call PFI_CheckSQLiteIntegrity
#         Pop $R0
#
#         ($R0 will be "ok" if the popfile.db file passes the integrity check)
#--------------------------------------------------------------------------

!macro PFI_CheckSQLiteIntegrity UN
  Function ${UN}PFI_CheckSQLiteIntegrity

    Push "pragma integrity_check;"
    Call ${UN}PFI_RunSQLiteCommand

  FunctionEnd
!macroend

!ifdef BACKUP
    #--------------------------------------------------------------------------
    # Installer Function: PFI_CheckSQLiteIntegrity
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_CheckSQLiteIntegrity ""
!endif

#--------------------------------------------------------------------------
# Uninstaller Function: un.PFI_CheckSQLiteIntegrity
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro PFI_CheckSQLiteIntegrity "un."


#--------------------------------------------------------------------------
# Macro: PFI_DumpLog
#
# The installation process and the uninstall process may both need a function which dumps the
# log using a filename supplied via the stack. This macro makes maintenance easier by ensuring
# that both processes use identical functions, with the only difference being their names.
#
# NOTE:
# The !insertmacro PFI_DumpLog "" and !insertmacro PFI_DumpLog "un." commands are included in this file
# so NSIS scripts can use 'Call PFI_DumpLog' and 'Call un.PFI_DumpLog' without additional preparation.
#
# Inputs:
#         (top of stack)     - the full path of the file where the log will be dumped
#
# Outputs:
#         (none)
#
# Usage (after macro has been 'inserted'):
#
#         Push "$G_ROOTDIR\install.log"
#         Call PFI_DumpLog
#
#        (the log contents will be saved in the "$G_ROOTDIR\install.log" file)
#--------------------------------------------------------------------------

!macro PFI_DumpLog UN
  Function ${UN}PFI_DumpLog

    !define L_LOGFILE   $R9
    !define L_RESULT    $R8

    Exch ${L_LOGFILE}
    Push ${L_RESULT}

    DumpLog::DumpLog "${L_LOGFILE}" .R8
    StrCmp ${L_RESULT} 0 exit

    MessageBox MB_OK|MB_ICONEXCLAMATION "$(PFI_LANG_MB_SAVELOG_ERROR)\
        ${MB_NL}${MB_NL}\
        (${L_LOGFILE})"

  exit:
    Pop ${L_RESULT}
    Pop ${L_LOGFILE}

    !undef L_LOGFILE
    !undef L_RESULT

  FunctionEnd
!macroend

!ifdef ADDSSL | BACKUP | IMAPUPDATER | INSTALLER | RESTORE
    #--------------------------------------------------------------------------
    # Installer Function: PFI_DumpLog
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_DumpLog ""
!endif

!ifdef INSTALLER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_DumpLog
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro PFI_DumpLog "un."
!endif


#--------------------------------------------------------------------------
# Macro: PFI_FindLockedPFE
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
# The !insertmacro PFI_FindLockedPFE "" and !insertmacro PFI_FindLockedPFE "un." commands are included
# in this file so the NSIS script can use 'Call PFI_FindLockedPFE' and 'Call un.PFI_FindLockedPFE'
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
#         Call PFI_FindLockedPFE
#         Pop $R0
#
#        (if popfileb.exe is still running, $R0 will be "C:\Program Files\POPFile\popfileb.exe")
#--------------------------------------------------------------------------

!macro PFI_FindLockedPFE UN
  Function ${UN}PFI_FindLockedPFE
    !define L_PATH          $R9    ; full path to the POPFile EXE files which are to be checked
    !define L_RESULT        $R8    ; either the full path to a locked file or an empty string

    Exch ${L_PATH}
    Push ${L_RESULT}
    Exch

    Push "${C_EXE_END_MARKER}"

    Push "${L_PATH}\popfileb.exe"     ; runs POPFile in the background
    Push "${L_PATH}\popfileib.exe"    ; runs POPFile in the background with system tray icon
    Push "${L_PATH}\popfilef.exe"     ; runs POPFile in the foreground/console window/DOS box
    Push "${L_PATH}\popfileif.exe"    ; runs POPFile in the foreground with system tray icon
    Push "${L_PATH}\wperl.exe"        ; runs POPFile in the background (using popfile.pl)
    Push "${L_PATH}\perl.exe"         ; runs POPFile in the foreground (using popfile.pl)

    Call ${UN}PFI_CheckIfLocked
    Pop ${L_RESULT}
    DetailPrint "${UN}PFI_CheckIfLocked returned '${L_RESULT}'"

    Pop ${L_PATH}
    Exch ${L_RESULT}              ; return full path to a locked file or an empty string

    !undef L_PATH
    !undef L_RESULT
  FunctionEnd
!macroend

!ifdef ADDSSL | ADDUSER | BACKUP | INSTALLER | RESTORE
    #--------------------------------------------------------------------------
    # Installer Function: PFI_FindLockedPFE
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_FindLockedPFE ""
!endif

!ifdef ADDUSER | INSTALLER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_FindLockedPFE
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro PFI_FindLockedPFE "un."
!endif


#--------------------------------------------------------------------------
# Macro: PFI_GetCompleteFPN
#
# The installation process and the uninstall process may need a function which converts a path
# into the full/long version (e.g. which converts 'C:\PROGRA~1' into 'C:\Program Files'). There
# is a built-in NSIS command for this (GetFullPathName) but it only converts part of the path,
# eg. it converts 'C:\PROGRA~1\PRE-RE~1' into 'C:\PROGRA~1\Pre-release POPFile' instead of the
# expected 'C:\Program Files\Pre-release POPFile' string. This macro makes maintenance easier
# by ensuring that both processes use identical functions, with the only difference being their
# names.
#
# If the specified path does not exist, an empty string is returned in order to make this
# function act like the built-in NSIS command (GetFullPathName).
#
# NOTE:
# The !insertmacro PFI_GetCompleteFPN "" and !insertmacro PFI_GetCompleteFPN "un." commands are
# included in this file so the NSIS script and/or other library functions in 'pfi-library.nsh'
# can use 'Call PFI_GetCompleteFPN' and 'Call un.PFI_GetCompleteFPN' without additional preparation.
#
# Inputs:
#         (top of stack)     - path to be converted to long filename format
# Outputs:
#         (top of stack)     - full (long) path name or an empty string if path was not found
#
# Usage (after macro has been 'inserted'):
#
#         Push "c:\progra~1"
#         Call PFI_GetCompleteFPN
#         Pop $R0
#
#         ($R0 now holds 'C:\Program Files')
#
#--------------------------------------------------------------------------

!macro PFI_GetCompleteFPN UN
    Function ${UN}PFI_GetCompleteFPN

      Exch $0   ; the input path
      Push $1   ; the result string (will be empty if the input path does not exist)
      Exch
      Push $2

      ; 'GetLongPathNameA' is not available in Windows 95 systems (but it is in Windows 98)

      ClearErrors
      ReadRegStr $1 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion
      IfErrors 0 use_system_plugin
      ReadRegStr $1 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion" VersionNumber
      StrCpy $2 $1 1
      StrCmp $2 '4' 0 use_NSIS_code
      StrCpy $2 $1 3
      StrCmp $2 '4.0' use_NSIS_code use_system_plugin

    use_NSIS_code:
      Push $3

      StrCpy $1 ""                ; used to hold the long filename format result
      StrCpy $2 ""                ; holds a component part of the long filename

      ; Convert the input path ($0) into a long path ($1) if possible

    loop:
      GetFullPathName $3 $0       ; Converts the last part of the path to long filename format
      StrCmp $3 "" done           ; An empty string here means the path doesn't exist
      StrCpy $2 $3 1 -1
      StrCmp $2 '.' finished_unc  ; If last char of result is '.' then the path was a UNC one
      StrCpy $0 $3                ; Set path we are working on to the 'GetFullPathName' result
      Push $0
      Call ${UN}NSIS_GetParent
      Pop $2
      StrLen $3 $2
      StrCpy $3 $0 "" $3          ; Get the last part of the path, including the leading '\'
      StrCpy $1 "$3$1"            ; Update the long filename result
      StrCpy $0 $2                ; Now prepare to convert the next part of the path
      StrCpy $3 $2 1 -1
      StrCmp $3 ':' done loop     ; We're done if all that is left is the drive letter part

    finished_unc:
      StrCpy $2 $0                ; $0 holds the '\\server\share' part of the UNC path

    done:
      StrCpy $1 "$2$1"            ; Assemble the last component of the long filename result

      Pop $3
      Goto exit

    use_system_plugin:
      StrCpy $1 ""

      ; Convert the input path ($0) into a long path ($1) if possible

      System::Call "Kernel32::GetLongPathNameA(t '$0', &t .r1, i ${NSIS_MAX_STRLEN})"

    exit:
      Pop $2
      Pop $0
      Exch $1

    FunctionEnd
!macroend

!ifdef ADDSSL | ADDUSER | BACKUP | DBANALYSER | DBSTATUS | INSTALLER | MONITORCC | ONDEMAND | PORTABLE | RESTORE
    #--------------------------------------------------------------------------
    # Installer Function: PFI_GetCompleteFPN
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_GetCompleteFPN ""
!endif

!ifdef ADDUSER | INSTALLER
  #--------------------------------------------------------------------------
  # Uninstaller Function: un.PFI_GetCompleteFPN
  #
  # This function is used during the uninstall process
  #--------------------------------------------------------------------------

  !insertmacro PFI_GetCompleteFPN "un."
!endif

#--------------------------------------------------------------------------
# Macro: PFI_GetCorpusPath
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
# The !insertmacro PFI_GetCorpusPath "" and !insertmacro PFI_GetCorpusPath "un." commands are included
# in this file so the NSIS script can use 'Call PFI_GetCorpusPath' and 'Call un.PFI_GetCorpusPath'
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
#         Call un.PFI_GetCorpusPath
#         Pop $R0
#
#         ($R0 will be "C:\Program Files\POPFile\corpus" if default corpus location is used)
#--------------------------------------------------------------------------

!macro PFI_GetCorpusPath UN
  Function ${UN}PFI_GetCorpusPath

    !define L_RESULT        $R9
    !define L_SOURCE        $R8

    Exch ${L_SOURCE}                            ; path to the folder holding 'popfile.cfg'
    Push ${L_RESULT}
    Exch

    IfFileExists "${L_SOURCE}\popfile.cfg" 0 use_default_locn

    Push "${L_SOURCE}\popfile.cfg"
    Push "bayes_corpus"                         ; used by POPFile 0.19.0 or later
    Call ${UN}PFI_CfgSettingRead
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" 0 use_cfg_data

    Push "${L_SOURCE}\popfile.cfg"
    Push "corpus"                               ; used by POPFile 0.18.x or earlier
    Call ${UN}PFI_CfgSettingRead
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" 0 use_cfg_data

  use_default_locn:
    StrCpy ${L_RESULT} "${L_SOURCE}\corpus"     ; this is the 'flat-file' default location
    Goto got_result

  use_cfg_data:
    Push ${L_SOURCE}
    Push ${L_RESULT}
    Call ${UN}PFI_GetDataPath
    Pop ${L_RESULT}

  got_result:
    Pop ${L_SOURCE}
    Exch ${L_RESULT}  ; place full path of 'corpus' directory on top of the stack

    !undef L_RESULT
    !undef L_SOURCE

  FunctionEnd
!macroend

!ifdef ADDUSER
    #--------------------------------------------------------------------------
    # Installer Function: PFI_GetCorpusPath
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_GetCorpusPath ""
!endif

#--------------------------------------------------------------------------
# Uninstaller Function: un.PFI_GetCorpusPath
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro PFI_GetCorpusPath "un."


#--------------------------------------------------------------------------
# Macro: PFI_GetDatabaseName
#
# The installation process and the uninstall process may both need a function which extracts
# the name of the SQLite database file from the POPFile configuration file ('popfile.cfg').
# The default filename is 'popfile.db' (which means it is stored in the 'User Data' folder).
# POPFile releases 0.21.x and 0.22.x used the 'bayes_database' entry to hold the filename but
# the 0.23.0 and later releases use the 'database_database' entry instead. This macro makes
# maintenance easier by ensuring that both processes use identical functions, with the only
# difference being their names.
#
# NOTE:
# The !insertmacro PFI_GetDatabaseName "" and !insertmacro PFI_GetDatabaseName "un." commands
# are included in this file so the NSIS script can use 'Call PFI_GetDatabaseName' and
# 'Call un.PFI_GetDatabaseName' without additional preparation.
#
# Inputs:
#         (top of stack)       - the path where 'popfile.cfg' is to be found
#
# Outputs:
#         (top of stack)       - string with the current value of the 'database_database' or
#                                the 'bayes_database' entry from the 'popfile.cfg' file
#                                (if no entry is not found (perhaps because a "clean" install
#                                is in progress), the default value for the entry is returned)
#
# Usage (after macro has been 'inserted'):
#
#         Push $G_USERDIR
#         Call PFI_GetDatabaseName
#         Pop $R0
#
#         ($R0 will be "popfile.db" if the default was in use or if this is a "clean" install)
#--------------------------------------------------------------------------

!macro PFI_GetDatabaseName UN
  Function ${UN}PFI_GetDatabaseName

    !define L_RESULT        $R9
    !define L_SOURCE        $R8

    Exch ${L_SOURCE}              ; where we are supposed to find the 'popfile.cfg' file
    Push ${L_RESULT}
    Exch

    IfFileExists "${L_SOURCE}\popfile.cfg" 0 use_default

    Push "${L_SOURCE}\popfile.cfg"
    Push "bayes_database"                     ; used by POPFile 0.21.0 or later
    Call ${UN}PFI_CfgSettingRead
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" 0 got_result

    Push "${L_SOURCE}\popfile.cfg"
    Push "database_database"                  ; used by unreleased 'trunk' code (0.23/2.x)
    Call ${UN}PFI_CfgSettingRead
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" 0 got_result

  use_default:
    StrCpy ${L_RESULT} "popfile.db"

  got_result:
    Pop ${L_SOURCE}
    Exch ${L_RESULT}

    !undef L_RESULT
    !undef L_SOURCE

  FunctionEnd
!macroend

!ifdef ADDUSER
    #--------------------------------------------------------------------------
    # Installer Function: PFI_GetDatabaseName
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_GetDatabaseName ""
!endif

#--------------------------------------------------------------------------
# Uninstaller Function: un.PFI_GetDatabaseName
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro PFI_GetDatabaseName "un."


#--------------------------------------------------------------------------
# Macro: PFI_GetDataPath
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
# The !insertmacro PFI_GetDataPath "" and !insertmacro PFI_GetDataPath "un." commands are included
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
#         Call un.PFI_GetDataPath
#         Pop $R0
#
#         ($R0 will be "C:\corpus", assuming $G_USERDIR was "C:\Program Files\POPFile")
#--------------------------------------------------------------------------

!macro PFI_GetDataPath UN
  Function ${UN}PFI_GetDataPath

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
    Call ${UN}PFI_StrBackSlash            ; ensure parameter uses backslashes
    Pop ${L_DATA}

    StrCmp ${L_DATA} ".\" source_folder

    ; If data path does not end in "..\" strip any trailing slash
    ; (so we always return a result without a trailing slash)

    StrCpy ${L_TEMP} ${L_DATA} 3 -3
    StrCmp ${L_TEMP} "..\" analyse_data
    StrCpy ${L_TEMP} ${L_TEMP} 1 -1
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
    Call ${UN}NSIS_GetParent
    Pop ${L_RESULT}
    StrCpy ${L_TEMP} ${L_DATA} 3
    StrCmp ${L_TEMP} "..\" relative_again
    StrCpy ${L_DATA} ${L_RESULT}\${L_DATA}

    ; Strip trailing slash (so we always return a result without a trailing slash)

    StrCpy ${L_TEMP} ${L_DATA} 1 -1
    StrCmp ${L_TEMP} '\' 0 got_path
    StrCpy ${L_DATA} ${L_DATA} -1
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

!ifdef ADDUSER | BACKUP | DBANALYSER | DBSTATUS | PFIDIAG | RESTORE | RUNPOPFILE
    #--------------------------------------------------------------------------
    # Installer Function: PFI_GetDataPath
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_GetDataPath ""
!endif

!ifdef ADDUSER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_GetDataPath
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro PFI_GetDataPath "un."
!endif


#--------------------------------------------------------------------------
# Macro: PFI_GetDateTimeStamp
#
# The installation process and the uninstall process may need a function which returns a
# string with the current date and time (using the current time from Windows). This macro
# makes maintenance easier by ensuring that both processes use identical functions, with
# the only difference being their names.
#
# NOTE:
# The !insertmacro PFI_GetDateTimeStamp "" and !insertmacro PFI_GetDateTimeStamp "un." commands are
# included in this file so the NSIS script and/or other library functions in 'pfi-library.nsh'
# can use 'Call PFI_GetDateTimeStamp' & 'Call un.PFI_GetDateTimeStamp' without additional preparation.
#
# Inputs:
#         (none)
# Outputs:
#         (top of stack)     - string with current date and time (eg '08-Dec-2003 @ 23:01:59')
#
# Usage (after macro has been 'inserted'):
#
#         Call PFI_GetDateTimeStamp
#         Pop $R9
#
#         ($R9 now holds a string like '08-Dec-2003 @ 23:01:59')
#--------------------------------------------------------------------------

!macro PFI_GetDateTimeStamp UN
  Function ${UN}PFI_GetDateTimeStamp

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

    Call ${UN}PFI_GetLocalTime
    Pop ${L_YEAR}
    Pop ${L_MONTH}
    Pop ${L_DAY}              ; ignore day of week
    Pop ${L_DAY}
    Pop ${L_HOURS}
    Pop ${L_MINUTES}
    Pop ${L_SECONDS}
    Pop ${L_DATETIMESTAMP}    ; ignore milliseconds

    StrCpy ${L_DAY} "0${L_DAY}" "" -2

    IntOp ${L_MONTH} ${L_MONTH} & 0xF
    IntOp ${L_MONTH} ${L_MONTH} << 2
    StrCpy ${L_MONTH} \
      "??? Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ??? ??? ???" 3 ${L_MONTH}

    StrCpy ${L_HOURS} "0${L_HOURS}" "" -2
    StrCpy ${L_MINUTES} "0${L_MINUTES}" "" -2
    StrCpy ${L_SECONDS} "0${L_SECONDS}" "" -2

    StrCpy ${L_DATETIMESTAMP} \
      "${L_DAY}-${L_MONTH}-${L_YEAR} @ ${L_HOURS}:${L_MINUTES}:${L_SECONDS}"

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

!ifndef CREATEUSER & MONITORCC & ONDEMAND & PLUGINCHECK & PORTABLE & RUNPOPFILE & RUNSQLITE & SHUTDOWN & STOP_POPFILE & TRANSLATOR
    #--------------------------------------------------------------------------
    # Installer Function: PFI_GetDateTimeStamp
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_GetDateTimeStamp ""
!endif

!ifdef ADDUSER | INSTALLER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_GetDateTimeStamp
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro PFI_GetDateTimeStamp "un."
!endif


#--------------------------------------------------------------------------
# Macro: PFI_GetFileSize
#
# The installation process and the uninstall process may need a function which gets the
# size (in bytes) of a particular file. This macro makes maintenance easier by ensuring
# that both processes use identical functions, with the only difference being their names.
#
# If the specified file is not found, the function returns -1
#
# NOTE:
# The !insertmacro PFI_GetFileSize "" and !insertmacro PFI_GetFileSize "un." commands are included
# in this file so the NSIS script and/or other library functions in 'pfi-library.nsh' can use
# 'Call PFI_GetFileSize' and 'Call un.PFI_GetFileSize' without additional preparation.
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
#         Call PFI_GetFileSize
#         Pop $R0
#
#         ($R0 now holds the size (in bytes) of the 'spam' bucket's 'table' file)
#
#--------------------------------------------------------------------------

!macro PFI_GetFileSize UN
    Function ${UN}PFI_GetFileSize

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

!ifdef ADDSSL | ADDUSER | BACKUP | INSTALLER | ONDEMAND | RESTORE | STOP_POPFILE
    #--------------------------------------------------------------------------
    # Installer Function: PFI_GetFileSize
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_GetFileSize ""
!endif

!ifdef ADDUSER | INSTALLER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_GetFileSize
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro PFI_GetFileSize "un."
!endif


#--------------------------------------------------------------------------
# Macro: PFI_GetLocalTime
#
# The installation process and the uninstall process may need a function which gets the
# local time from Windows (to generate data and/or time stamps, etc). This macro makes
# maintenance easier by ensuring that both processes use identical functions, with
# the only difference being their names.
#
# Normally this function will be used by a higher level one which returns a suitable string.
#
# NOTE:
# The !insertmacro PFI_GetLocalTime "" and !insertmacro PFI_GetLocalTime "un." commands are included
# in this file so the NSIS script and/or other library functions in 'pfi-library.nsh' can use
# 'Call PFI_GetLocalTime' and 'Call un.PFI_GetLocalTime' without additional preparation.
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
#         Call PFI_GetLocalTime
#         Pop $Year
#         Pop $Month
#         Pop $DayOfWeek
#         Pop $Day
#         Pop $Hours
#         Pop $Minutes
#         Pop $Seconds
#         Pop $Milliseconds
#--------------------------------------------------------------------------

!macro PFI_GetLocalTime UN
  Function ${UN}PFI_GetLocalTime

    Push $1
    Push $2
    Push $3
    Push $4
    Push $5
    Push $6
    Push $7
    Push $8

    System::Call '*(&i2, &i2, &i2, &i2, &i2, &i2, &i2, &i2) i .r1'
    System::Call 'kernel32::GetLocalTime(i) i(r1)'
    System::Call \
      '*$1(&i2, &i2, &i2, &i2, &i2, &i2, &i2, &i2)(.r8, .r7, .r6, .r5, .r4, .r3, .r2, .r1)'

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

!ifndef CREATEUSER & MONITORCC & ONDEMAND & PLUGINCHECK & PORTABLE & RUNPOPFILE & RUNSQLITE & SHUTDOWN & STOP_POPFILE & TRANSLATOR
    #--------------------------------------------------------------------------
    # Installer Function: PFI_GetLocalTime
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_GetLocalTime ""
!endif

!ifdef ADDUSER | INSTALLER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_GetLocalTime
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro PFI_GetLocalTime "un."
!endif


#--------------------------------------------------------------------------
# Macro: PFI_GetMessagesPath
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
# The !insertmacro PFI_GetMessagesPath "" and !insertmacro PFI_GetMessagesPath "un." commands are
# included in this file so the NSIS script can use 'Call PFI_GetMessagesPath' and
# 'Call un.PFI_GetMessagesPath' without additional preparation.
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
#         Call un.PFI_GetMessagesPath
#         Pop $R0
#
#         ($R0 will be "C:\Program Files\POPFile\messages" if this is an upgraded installation
#          which used the default location)
#--------------------------------------------------------------------------

!macro PFI_GetMessagesPath UN
  Function ${UN}PFI_GetMessagesPath

    !define L_RESULT        $R9
    !define L_SOURCE        $R8

    Exch ${L_SOURCE}              ; path to folder holding the configuration file
    Push ${L_RESULT}
    Exch

    IfFileExists "${L_SOURCE}\popfile.cfg" 0 use_default_locn

    Push "${L_SOURCE}\popfile.cfg"
    Push "GLOBAL_msgdir"                      ; used by POPFile 0.19.0 or later
    Call ${UN}PFI_CfgSettingRead
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" 0 use_cfg_data

    Push "${L_SOURCE}\popfile.cfg"
    Push "msgdir"                             ; used by POPFile 0.18.x
    Call ${UN}PFI_CfgSettingRead
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" 0 use_cfg_data

  use_default_locn:
    StrCpy ${L_RESULT} "${L_SOURCE}\messages"
    Goto got_result

  use_cfg_data:
    Push ${L_SOURCE}
    Push ${L_RESULT}
    Call ${UN}PFI_GetDataPath
    Pop ${L_RESULT}

  got_result:
    Pop ${L_SOURCE}
    Exch ${L_RESULT}  ; place full path of 'messages' folder on top of the stack

    !undef L_RESULT
    !undef L_SOURCE

  FunctionEnd
!macroend

;;!ifdef ADDUSER
;;    #--------------------------------------------------------------------------
;;    # Installer Function: PFI_GetMessagesPath
;;    #
;;    # This function is used during the installation process
;;    #--------------------------------------------------------------------------
;;
;;    !insertmacro PFI_GetMessagesPath ""
;;!endif
;;
!ifdef ADDUSER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_GetMessagesPath
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro PFI_GetMessagesPath "un."
!endif


#--------------------------------------------------------------------------
# Macro: PFI_GetPOPFileSchemaVersion
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
# The !insertmacro PFI_GetPOPFileSchemaVersion "" and !insertmacro PFI_GetPOPFileSchemaVersion "un."
# commands are included in this file so the NSIS script can use 'Call PFI_GetPOPFileSchemaVersion'
# and 'Call un.PFI_GetPOPFileSchemaVersion' without additional preparation.
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
#         Call PFI_GetPOPFileSchemaVersion
#         Pop $R0
#
#         ($R0 will be "3" if the first line of the popfile.sql file is "-- POPFILE SCHEMA 3")
#--------------------------------------------------------------------------

!macro PFI_GetPOPFileSchemaVersion UN
  Function ${UN}PFI_GetPOPFileSchemaVersion

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
    Call ${UN}NSIS_TrimNewlines
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
    # Installer Function: PFI_GetPOPFileSchemaVersion
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_GetPOPFileSchemaVersion ""
!endif

#--------------------------------------------------------------------------
# Uninstaller Function: un.PFI_GetPOPFileSchemaVersion
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro PFI_GetPOPFileSchemaVersion "un."


#--------------------------------------------------------------------------
# Macro: PFI_GetSQLdbPathName
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
# The !insertmacro PFI_GetSQLdbPathName "" and !insertmacro PFI_GetSQLdbPathName "un." commands
# are included in this file so the NSIS script can use 'Call PFI_GetSQLdbPathName' and
# 'Call un.PFI_GetSQLdbPathName' without additional preparation.
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
#         Call un.PFI_GetSQLdbPathName
#         Pop $R0
#
#         ($R0 will be "C:\Program Files\POPFile\popfile.db" if this is an upgraded version of
#          a pre-0.21.0 installation using the default location)
#--------------------------------------------------------------------------

!macro PFI_GetSQLdbPathName UN
  Function ${UN}PFI_GetSQLdbPathName

    !define L_RESULT        $R9
    !define L_SOURCE        $R8
    !define L_SQL_CONNECT   $R7
    !define L_SQL_CORPUS    $R6

    Exch ${L_SOURCE}              ; where we are supposed to find the 'popfile.cfg' file
    Push ${L_RESULT}
    Exch
    Push ${L_SQL_CONNECT}
    Push ${L_SQL_CORPUS}

    IfFileExists "${L_SOURCE}\popfile.cfg" 0 no_sql_set

    Push "${L_SOURCE}\popfile.cfg"
    Push "bayes_dbconnect"              ; used by POPFile 0.21.0 or later
    Call ${UN}PFI_CfgSettingRead
    Pop ${L_SQL_CONNECT}
    StrCmp ${L_SQL_CONNECT} "" 0 get_database_name

    Push "${L_SOURCE}\popfile.cfg"
    Push "database_dbconnect"           ; used by unreleased 'trunk' code (0.23/2.x)
    Call ${UN}PFI_CfgSettingRead
    Pop ${L_SQL_CONNECT}
    StrCmp ${L_SQL_CONNECT} "" no_sql_set

    Push "${L_SOURCE}\popfile.cfg"
    Push "database_database"            ; used by unreleased 'trunk' code (0.23/2.x)
    Call ${UN}PFI_CfgSettingRead
    Pop ${L_SQL_CORPUS}
    Goto check_sql_settings

  get_database_name:
    Push "${L_SOURCE}\popfile.cfg"
    Push "bayes_database"               ; used by POPFile 0.21.0 or later
    Call ${UN}PFI_CfgSettingRead
    Pop ${L_SQL_CORPUS}

  check_sql_settings:

    ; If a SQL setting other than the default SQLite one is found, assume existing system
    ; is using an alternative SQL database (such as MySQL) so there is no SQLite database

    StrCpy ${L_SQL_CONNECT} ${L_SQL_CONNECT} 10
    StrCmp ${L_SQL_CONNECT} "dbi:SQLite" 0 not_sqlite
    StrCmp ${L_SQL_CORPUS} "" no_sql_set got_sql_corpus

  not_sqlite:
    StrCpy ${L_RESULT} "Not SQLite"
    Goto got_result

  no_sql_set:
    StrCpy ${L_RESULT} ""
    Goto got_result

  got_sql_corpus:
    Push ${L_SOURCE}
    Push ${L_SQL_CORPUS}
    Call ${UN}PFI_GetDataPath
    Pop ${L_RESULT}

  got_result:
    Pop ${L_SQL_CORPUS}
    Pop ${L_SQL_CONNECT}
    Pop ${L_SOURCE}
    Exch ${L_RESULT}

    !undef L_RESULT
    !undef L_SOURCE
    !undef L_SQL_CONNECT
    !undef L_SQL_CORPUS

  FunctionEnd
!macroend

!ifdef ADDUSER | DBANALYSER | DBSTATUS
    #--------------------------------------------------------------------------
    # Installer Function: PFI_GetSQLdbPathName
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_GetSQLdbPathName ""
!endif

#--------------------------------------------------------------------------
# Uninstaller Function: un.PFI_GetSQLdbPathName
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro PFI_GetSQLdbPathName "un."


#--------------------------------------------------------------------------
# Macro: PFI_GetSQLiteFormat
#
# The installation process and the uninstall process may both need a function which determines
# the format of the SQLite database. SQLite 2.x and 3.x databases use incompatible formats and
# the only way to determine the format is to examine the first few bytes in the database file.
# This macro makes maintenance easier by ensuring that both processes use identical functions,
# with the only difference being their names.
#
# NOTE:
# The !insertmacro PFI_GetSQLiteFormat "" and !insertmacro PFI_GetSQLiteFormat "un." commands
# are included in this file so the NSIS script can use 'Call PFI_GetSQLiteFormat' and
# 'Call un.PFI_GetSQLiteFormat' without additional preparation.
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
#                              If result is enclosed in parentheses then an error occurred.
#
# Usage (after macro has been 'inserted'):
#
#         Push "popfile.db"
#         Call PFI_GetSQLiteFormat
#         Pop $R0
#
#         ($R0 will be "2.x" if the popfile.db file belongs to POPFile 0.21.0)
#--------------------------------------------------------------------------

!macro PFI_GetSQLiteFormat UN
  Function ${UN}PFI_GetSQLiteFormat

    !define L_BYTE       $R9  ; byte read from the database file
    !define L_COUNTER    $R8  ; expects null-terminated string, but also uses a length limit
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

    ; Unrecognized format string found, return it enclosed in parentheses (to indicate error)

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

!ifdef ADDUSER | BACKUP | DBANALYSER | DBSTATUS | PORTABLE | RUNSQLITE | RESTORE
    #--------------------------------------------------------------------------
    # Installer Function: PFI_GetSQLiteFormat
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_GetSQLiteFormat ""
!endif

#--------------------------------------------------------------------------
# Uninstaller Function: un.PFI_GetSQLiteFormat
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro PFI_GetSQLiteFormat "un."


#--------------------------------------------------------------------------
# Macro: PFI_GetSQLiteSchemaVersion
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
# The !insertmacro PFI_GetSQLiteSchemaVersion "" and !insertmacro PFI_GetSQLiteSchemaVersion "un."
# commands are included in this file so the NSIS script can use 'Call PFI_GetSQLiteSchemaVersion'
# and 'Call un.PFI_GetSQLiteSchemaVersion' without additional preparation.
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
#         Call PFI_GetSQLiteSchemaVersion
#         Pop $R0
#
#         ($R0 will be "3" if the popfile.db database uses POPFile Schema version 3)
#--------------------------------------------------------------------------

!macro PFI_GetSQLiteSchemaVersion UN
  Function ${UN}PFI_GetSQLiteSchemaVersion

    Push "select version from popfile;"
    Call ${UN}PFI_RunSQLiteCommand

  FunctionEnd
!macroend

!ifdef ADDUSER | BACKUP | RESTORE
    #--------------------------------------------------------------------------
    # Installer Function: PFI_GetSQLiteSchemaVersion
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_GetSQLiteSchemaVersion ""
!endif

#--------------------------------------------------------------------------
# Uninstaller Function: un.PFI_GetSQLiteSchemaVersion
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro PFI_GetSQLiteSchemaVersion "un."


#--------------------------------------------------------------------------
# Macro: PFI_GetTimeStamp
#
# The installation process and the uninstall process may need a function which uses the
# local time from Windows to generate a time stamp (eg '01:23:45'). This macro makes
# maintenance easier by ensuring that both processes use identical functions, with
# the only difference being their names.
#
# NOTE:
# The !insertmacro PFI_GetTimeStamp "" and !insertmacro PFI_GetTimeStamp "un." commands are included
# in this file so the NSIS script and/or other library functions in 'pfi-library.nsh' can use
# 'Call PFI_GetTimeStamp' and 'Call un.PFI_GetTimeStamp' without additional preparation.
#
# Inputs:
#         (none)
# Outputs:
#         (top of stack)     - string holding current time (eg '23:01:59')
#
# Usage (after macro has been 'inserted'):
#
#         Call PFI_GetTimeStamp
#         Pop $R9
#
#         ($R9 now holds a string like '23:01:59')
#--------------------------------------------------------------------------

!macro PFI_GetTimeStamp UN
  Function ${UN}PFI_GetTimeStamp

    !define L_TIMESTAMP   $R9
    !define L_HOURS       $R8
    !define L_MINUTES     $R7
    !define L_SECONDS     $R6

    Push ${L_TIMESTAMP}
    Push ${L_HOURS}
    Push ${L_MINUTES}
    Push ${L_SECONDS}

    Call ${UN}PFI_GetLocalTIme
    Pop ${L_TIMESTAMP}    ; ignore year
    Pop ${L_TIMESTAMP}    ; ignore month
    Pop ${L_TIMESTAMP}    ; ignore day of week
    Pop ${L_TIMESTAMP}    ; ignore day
    Pop ${L_HOURS}
    Pop ${L_MINUTES}
    Pop ${L_SECONDS}
    Pop ${L_TIMESTAMP}    ; ignore milliseconds

    StrCpy ${L_HOURS} "0${L_HOURS}" "" -2
    StrCpy ${L_MINUTES} "0${L_MINUTES}" "" -2
    StrCpy ${L_SECONDS} "0${L_SECONDS}" "" -2
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
# Installer Function: PFI_GetTimeStamp
#
# This function is used during the installation process
#--------------------------------------------------------------------------

;!insertmacro PFI_GetTimeStamp ""

#--------------------------------------------------------------------------
# Uninstaller Function: un.PFI_GetTimeStamp
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro PFI_GetTimeStamp "un."


#--------------------------------------------------------------------------
# Macro: PFI_RequestPFIUtilsShutdown
#
# The installation process and the uninstall process may both need a function which checks if
# any of the POPFile Installer (PFI) utilities is in use and asks the user to shut them down.
# This macro makes maintenance easier by ensuring that both processes use identical functions,
# with the only difference being their names.
#
# NOTE:
# The !insertmacro PFI_RequestPFIUtilsShutdown "" and !insertmacro PFI_RequestPFIUtilsShutdown "un."
# commands are included in this file so the NSIS script can use 'Call PFI_RequestPFIUtilsShutdown'
# and 'Call un.PFI_RequestPFIUtilsShutdown' without additional preparation.
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
#         Call PFI_RequestPFIUtilsShutdown
#
#--------------------------------------------------------------------------

!macro PFI_RequestPFIUtilsShutdown UN
  Function ${UN}PFI_RequestPFIUtilsShutdown
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
    Push "${C_EXE_END_MARKER}"
    Push "${L_PATH}\pfimsgcapture.exe"
    Call ${UN}PFI_CheckIfLocked
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
    Push "${C_EXE_END_MARKER}"
    Push "${L_PATH}\msgcapture.exe"
    Call ${UN}PFI_CheckIfLocked
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
    Push "${C_EXE_END_MARKER}"
    Push "${L_PATH}\stop_pf.exe"
    Call ${UN}PFI_CheckIfLocked
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
    Push "${C_EXE_END_MARKER}"
    Push "${L_PATH}\pfidiag.exe"
    Call ${UN}PFI_CheckIfLocked
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
    # Installer Function: PFI_RequestPFIUtilsShutdown
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_RequestPFIUtilsShutdown ""
!endif

!ifdef INSTALLER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_RequestPFIUtilsShutdown
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro PFI_RequestPFIUtilsShutdown "un."
!endif


#--------------------------------------------------------------------------
# Macro: PFI_RunSQLiteCommand
#
# The installation process and the uninstall process may both need a function which uses the
# SQLite command-line utility to run a single command, such as an integrity check. This macro
# makes maintenance easier by ensuring that both processes use identical functions, with the
# only difference being their names.
#
# NOTE:
# The !insertmacro PFI_RunSQLiteCommand "" and !insertmacro PFI_RunSQLiteCommand "un."
# commands are included in this file so the NSIS script can use 'Call PFI_RunSQLiteCommand'
# and 'Call un.PFI_RunSQLiteCommand' without additional preparation.
#
# Inputs:
#         (top of stack)     - the command to be passed to the SQLite command-line utility
#         (top of stack - 1) - full pathname of the SQLite database file
#
# Outputs:
#         (top of stack)     - the result string returned by the SQLite command-line utility
#                              If the result is enclosed in parentheses then an error occurred.
#
# Usage (after macro has been 'inserted'):
#
#         Push "popfile.db"
#         Push "pragma integrity_check;"
#         Call PFI_RunSQLiteCommand
#         Pop $R0
#
#         ($R0 will be "ok" if the popfile.db file passes the integrity check)
#--------------------------------------------------------------------------

!macro PFI_RunSQLiteCommand UN
  Function ${UN}PFI_RunSQLiteCommand

    !define L_COMMAND     $R9   ; the command to be run by the SQLite command-line utility
    !define L_DATABASE    $R8   ; name of the SQLite database file
    !define L_RESULT      $R7   ; string returned on top of the stack
    !define L_SQLITEPATH  $R6   ; path to sqlite.exe utility
    !define L_SQLITEUTIL  $R5   ; used to run relevant SQLite utility
    !define L_STATUS      $R4   ; status code returned by SQLite utility
    !define L_WORKINGDIR  $R3   ; current working directory

    Exch ${L_COMMAND}
    Exch
    Exch ${L_DATABASE}
    Push ${L_RESULT}
    Exch 2
    Push ${L_SQLITEPATH}
    Push ${L_SQLITEUTIL}
    Push ${L_STATUS}
    Push ${L_WORKINGDIR}

    Push ${L_DATABASE}
    Call ${UN}PFI_GetSQLiteFormat
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
    GetFullPathName ${L_WORKINGDIR} ".\"

    Push "${L_DATABASE}"
    Call ${UN}NSIS_GetParent
    Pop ${L_STATUS}
    StrCmp ${L_STATUS} "" run_it_now

    ; The SQLite command-line utility does not handle paths containing non-ASCII characters
    ; properly. An example where this will cause a problem is when the POPFile 'User Data'
    ; has been installed in the default location for a user with a Japanese login name.
    ; As a workaround we change the current working directory to the folder containing the
    ; database and supply only the database's filename when calling the command-line utility.

    StrLen ${L_RESULT} ${L_STATUS}
    IntOp ${L_RESULT} ${L_RESULT} + 1
    StrCpy "${L_DATABASE}" "${L_DATABASE}" "" ${L_RESULT}
    SetOutPath "${L_STATUS}"

  run_it_now:
    nsExec::ExecToStack '"${L_SQLITEPATH}\${L_SQLITEUTIL}" "${L_DATABASE}" "${L_COMMAND}"'
    Pop ${L_STATUS}
    Call ${UN}NSIS_TrimNewlines
    Pop ${L_RESULT}
    SetOutPath ${L_WORKINGDIR}
    StrCmp ${L_STATUS} "0" exit
    StrCpy ${L_RESULT} "(${L_RESULT})"

  exit:
    Pop ${L_WORKINGDIR}
    Pop ${L_STATUS}
    Pop ${L_SQLITEUTIL}
    Pop ${L_SQLITEPATH}
    Pop ${L_COMMAND}
    Pop ${L_DATABASE}
    Exch ${L_RESULT}

    !undef L_COMMAND
    !undef L_DATABASE
    !undef L_RESULT
    !undef L_SQLITEPATH
    !undef L_SQLITEUTIL
    !undef L_STATUS
    !undef L_WORKINGDIR

  FunctionEnd
!macroend

!ifdef ADDUSER | BACKUP | RESTORE
    #--------------------------------------------------------------------------
    # Installer Function: PFI_RunSQLiteCommand
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_RunSQLiteCommand ""
!endif

#--------------------------------------------------------------------------
# Uninstaller Function: un.PFI_RunSQLiteCommand
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro PFI_RunSQLiteCommand "un."


#--------------------------------------------------------------------------
# Macro: PFI_SendToRecycleBin
#
# The installation process and the uninstall process may both need a function which silently
# sends one or more files (or folders) to the Recycle Bin instead of permanently deleting
# them. The standard Windows wildcards can be used to define what is to be deleted. A non-zero
# return value indicates an error occurred (e.g. file not found).
#
# This macro makes maintenance easier by ensuring that both processes use identical functions,
# with the only difference being their names.
#
# NOTES:
# (1) NSIS strings are terminated by a single NULL character. The SHFileOperation function
#     requires _two_ NULL characters at the end of the string specifying the file(s) to be
#     sent to the Recycle Bin
#
# (2) The !insertmacro PFI_SendToRecycleBin "" and !insertmacro PFI_SendToRecycleBin "un."
#     commands are included in this file so the NSIS script can use 'Call PFI_SendToRecycleBin'
#     and 'Call un.PFI_SendToRecycleBin' without additional preparation.
#
# Input:
#       (top of stack)          - full path of file/files/directory to be sent to Recycle Bin
#
# Output:
#       (top of stack)          - operation return code (0 = success)
#
# Usage (after macro has been 'inserted'):
#
#       Push "C:\Program Files\My Program\config.dat"
#       Call PFI_SendToRecycleBin
#       Pop $R0
#
#       ($R0 will be "0" if the file was successfully sent to the Recycle Bin)
#       ($R0 will be "1026" if the specified file cannot be found)
#
#--------------------------------------------------------------------------

!macro PFI_SendToRecycleBin UN

    !define FO_DELETE             0x3

    !define FOF_SILENT            0x4
    !define FOF_NOCONFIRMATION    0x10
    !define FOF_ALLOWUNDO         0x40

    !define USE_RECYCLEBIN        ${FOF_ALLOWUNDO}|${FOF_SILENT}|${FOF_NOCONFIRMATION}

  Function ${UN}PFI_SendToRecycleBin

    Exch $R0    ; the input data (the full path to the file to be sent to the Recycle Bin)
    Push $R1
    Push $R2
    Push $R3

    ; Create a structure holding a string terminated by two NULL characters

    System::Call "*(&t${NSIS_MAX_STRLEN}) i.R3"

    StrCpy $R1 $R3                       ; Get start address of buffer for pFrom parameter
    StrLen $R2 $R0
    IntOp $R2 $R2 + 1
    System::Call "*$R1(&t$R2 '$R0')"     ; Transfer string and its NULL terminator to the buffer
    IntOp $R1 $R1 + $R2
    System::Call "*$R1(&t1 '')"          ; Place the second terminating NULL in the buffer

    ; Create the SHFILEOPSTRUCT structure required by the SHFileOperation function

    System::Call "*(i $HWNDPARENT, i ${FO_DELETE}, i R3, t '', &i2 ${USE_RECYCLEBIN},i 0, i 0, t '') i.R1"

    ; Send the specified file(s) to the Recycle Bin

    System::Call "shell32::SHFileOperationA(i R1)i.R2"

    System::Free $R3      ; Free the string terminated by two NULL characters
    System::Free $R1      ; Free the SHFILEOPSTRUCT structure
    StrCpy $R0 $R2        ; Prepare to return the SHFileOperation function result code

    Pop $R3
    Pop $R2
    Pop $R1
    Exch $R0

  FunctionEnd
!macroend

!ifdef BACKUP | INSTALLER
    #--------------------------------------------------------------------------
    # Installer Function: PFI_SendToRecycleBin
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_SendToRecycleBin ""
!endif

#--------------------------------------------------------------------------
# Uninstaller Function: un.PFI_SendToRecycleBin
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro PFI_SendToRecycleBin "un."


#--------------------------------------------------------------------------
# Macro: PFI_ServiceActive
#
# The installation process and the uninstall process may both need a function which checks
# if a particular Windows service is "active". At present this function only checks if the
# specified service is "paused" or "running" since the function is only used to detect if
# it is safe to overwrite/delete the popfile-service.exe file during installation/uninstalling.
# This macro makes maintenance easier by ensuring that both processes use identical functions,
# with the only difference being their names.
#
# NOTE:
# The !insertmacro PFI_ServiceActive "" and !insertmacro PFI_ServiceActive "un." commands are included
# in this file so the NSIS script can use 'Call PFI_ServiceActive' and 'Call un.PFI_ServiceActive'
# without additional preparation.
#
# Inputs:
#         (top of stack)       - name of the Windows Service to be checked (normally "POPFile")
#
# Outputs:
#         (top of stack)       - string containing one of the following result codes:
#                                   true           - service is pause or running
#                                   false          - service is neither paused nor running
#
# Usage (after macro has been 'inserted'):
#
#         Push "POPFile"
#         Call PFI_ServiceActive
#         Pop $R0
#
#         (if $R0 at this point is "true" then POPFile is paused or running as a Windows service)
#
#--------------------------------------------------------------------------

!macro PFI_ServiceActive UN

  Function ${UN}PFI_ServiceActive

    !define L_PLUGINSTATUS    $R9   ; success (0) or failure (<> 0) of the plugin
    !define L_RESULT          $R8   ; returned by plugin after a successful call
    !define L_SERVICENAME     $R7   ; name of the service

    Push ${L_PLUGINSTATUS}
    Push ${L_SERVICENAME}
    Push ${L_RESULT}                ; used to return the result from this function
    Exch 3
    Pop ${L_SERVICENAME}

    ; The SimpleSC plugin (and popfile-service.exe) cannot be used on Win9x systems

    Call ${UN}NSIS_IsNT
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} 0 error_exit

    ; Check if the service exists

    SimpleSC::ExistsService "${L_SERVICENAME}"
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "0" 0 error_exit

    ; Check if the service is running

    SimpleSC::ServiceIsRunning "${L_SERVICENAME}"
    Pop ${L_PLUGINSTATUS}
    IntCmp ${L_PLUGINSTATUS} 0 check_if_running
    Push  ${L_PLUGINSTATUS}
    SimpleSC::GetErrorMessage
    Pop ${L_RESULT}
    MessageBox MB_OK|MB_ICONSTOP "Internal Error: ServiceRunning call failed\
        ${MB_NL}${MB_NL}\
        (Code: ${L_PLUGINSTATUS} Error: ${L_RESULT})"
    Goto error_exit

  check_if_running:
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "1" success_exit

    ; Check if the service is paused

    SimpleSC::ServiceIsPaused "${L_SERVICENAME}"
    Pop ${L_PLUGINSTATUS}
    IntCmp ${L_PLUGINSTATUS} 0 check_if_paused
    Push  ${L_PLUGINSTATUS}
    SimpleSC::GetErrorMessage
    Pop ${L_RESULT}
    MessageBox MB_OK|MB_ICONSTOP "Internal Error: ServiceIsPaused call failed\
        ${MB_NL}${MB_NL}\
        (Code: ${L_PLUGINSTATUS} Error: ${L_RESULT})"
    Goto error_exit

  check_if_paused:
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "0" error_exit

  success_exit:
    StrCpy ${L_RESULT} "true"
    Goto exit

  error_exit:
    StrCpy ${L_RESULT} "false"

  exit:
    Pop ${L_SERVICENAME}
    Pop ${L_PLUGINSTATUS}
    Exch ${L_RESULT}           ; stack = result code string

  !undef L_PLUGINSTATUS
  !undef L_RESULT
  !undef L_SERVICENAME

  FunctionEnd
!macroend

!ifdef ADDSSL | ADDUSER | INSTALLER
    #--------------------------------------------------------------------------
    # Installer Function: PFI_ServiceActive
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_ServiceActive ""
!endif

!ifdef ADDUSER | INSTALLER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_ServiceActive
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro PFI_ServiceActive "un."
!endif


#--------------------------------------------------------------------------
# Macro: PFI_ServiceCall
#
# The installation process and the uninstall process may both need a function which interfaces
# with the Windows Service Control Manager (SCM).  This macro makes maintenance easier by
# ensuring that both processes use identical functions, with the only difference being their
# names.
#
# NOTE: This version only supports a subset of the available Service Control Manager actions.
#
# NOTE:
# The !insertmacro PFI_ServiceCall "" and !insertmacro PFI_ServiceCall "un." commands are included
# in this file so the NSIS script can use 'Call PFI_ServiceCall' and 'Call un.PFI_ServiceCall'
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
#         Call un.PFI_ServiceCall
#         Pop $R0
#
#         (if $R0 at this point is "running" then POPFile is running as a Windows service)
#
#--------------------------------------------------------------------------

!macro PFI_ServiceCall UN

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

  Function ${UN}PFI_ServiceCall

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

!ifdef BACKUP | RESTORE
    #--------------------------------------------------------------------------
    # Installer Function: PFI_ServiceCall
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_ServiceCall ""
!endif

#--------------------------------------------------------------------------
# Uninstaller Function: un.PFI_ServiceCall
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro PFI_ServiceCall "un."


#--------------------------------------------------------------------------
# Macro: PFI_ServiceRunning
#
# The installation process and the uninstall process may both need a function which checks
# if a particular Windows service is running. This macro makes maintenance easier by ensuring
# that both processes use identical functions, with the only difference being their names.
#
# NOTE:
# The !insertmacro PFI_ServiceRunning "" and !insertmacro PFI_ServiceRunning "un." commands are included
# in this file so the NSIS script can use 'Call PFI_ServiceRunning' and 'Call un.PFI_ServiceRunning'
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
#         Call PFI_ServiceRunning
#         Pop $R0
#
#         (if $R0 at this point is "true" then POPFile is running as a Windows service)
#
#--------------------------------------------------------------------------

!macro PFI_ServiceRunning UN
  Function ${UN}PFI_ServiceRunning

    !define L_RESULT    $R9

    Push ${L_RESULT}
    Exch
    Push "status"
    Exch
    Call ${UN}PFI_ServiceCall     ; uses 2 parameters from top of stack (top = servicename, action)
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

!ifdef BACKUP | RESTORE
    #--------------------------------------------------------------------------
    # Installer Function: PFI_ServiceRunning
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_ServiceRunning ""
!endif

#--------------------------------------------------------------------------
# Uninstaller Function: un.PFI_ServiceRunning
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro PFI_ServiceRunning "un."


#--------------------------------------------------------------------------
# Macro: PFI_ServiceStatus
#
# The installation process and the uninstall process may both need a function which checks
# the status of a particular Windows Service. This macro makes maintenance easier by ensuring
# that both processes use identical functions, with the only difference being their names.
#
# NOTE:
# The !insertmacro PFI_ServiceStatus "" and !insertmacro PFI_ServiceStatus "un." commands are included
# in this file so the NSIS script can use 'Call PFI_ServiceStatus' and 'Call un.PFI_ServiceStatus'
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
#         Call PFI_ServiceStatus
#         Pop $R0
#
#         (if $R0 at this point is "running" then POPFile is running as a Windows service)
#
#--------------------------------------------------------------------------

!macro PFI_ServiceStatus UN
  Function ${UN}PFI_ServiceStatus

    Push "status"            ; action required
    Exch                     ; top of stack = servicename, action required
    Call ${UN}PFI_ServiceCall

  FunctionEnd
!macroend

#--------------------------------------------------------------------------
# Installer Function: PFI_ServiceStatus
#
# This function is used during the installation process
#--------------------------------------------------------------------------

;!insertmacro PFI_ServiceStatus ""

#--------------------------------------------------------------------------
# Uninstaller Function: un.PFI_ServiceStatus
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro PFI_ServiceStatus "un."


#--------------------------------------------------------------------------
# Macro: PFI_ShutdownViaUI
#
# The installation process and the uninstall process may both use a function which attempts to
# shutdown POPFile using the User Interface (UI) invisibly (i.e. no browser window is used).
# This macro makes maintenance easier by ensuring that both processes use identical functions,
# with the only difference being their names.
#
# To avoid the need to parse the HTML page downloaded by inetc, we call inetc again if the
# first call succeeds. If the second call succeeds, we assume the UI is password protected.
# As a debugging aid, we don't overwrite the first HTML file with the result of the second call.
#
# NOTE:
# The !insertmacro PFI_ShutdownViaUI "" and !insertmacro PFI_ShutdownViaUI "un." commands are included
# in this file so the NSIS script can use 'Call PFI_ShutdownViaUI' and 'Call un.PFI_ShutdownViaUI'
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
#         Call PFI_ShutdownViaUI
#         Pop $R0
#
#         (if $R0 at this point is "password?" then POPFile is still running)
#
#--------------------------------------------------------------------------

!macro PFI_ShutdownViaUI UN
  Function ${UN}PFI_ShutdownViaUI

    ;--------------------------------------------------------------------------
    ; Override the default connection timeout for inetc requests (specifies timeout in seconds)
    ; (20 seconds is used to give the user more time to respond to any firewall prompts)

    !define C_SVU_DLTIMEOUT       /CONNECTTIMEOUT=20

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
    Call ${UN}PFI_StrCheckDecimal
    Pop ${L_UIPORT}
    StrCmp ${L_UIPORT} "" badport
    IntCmp ${L_UIPORT} 1 port_ok badport
    IntCmp ${L_UIPORT} 65535 port_ok port_ok

  badport:
    StrCpy ${L_RESULT} "badport"
    Goto exit

  port_ok:
    inetc::get /silent ${C_SVU_DLTIMEOUT} "http://${C_UI_URL}:${L_UIPORT}/shutdown" "$PLUGINSDIR\shutdown_1.htm" /END
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "OK" try_again
    StrCpy ${L_RESULT} "failure"
    Goto exit

  try_again:
    Sleep ${C_SVU_DLGAP}
    inetc::get /silent ${C_SVU_DLTIMEOUT} "http://${C_UI_URL}:${L_UIPORT}/shutdown" "$PLUGINSDIR\shutdown_2.htm" /END
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "OK" 0 shutdown_ok
    Push "$PLUGINSDIR\shutdown_2.htm"
    Call ${UN}PFI_GetFileSize
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

!ifdef ADDSSL | ADDUSER | BACKUP | INSTALLER | ONDEMAND | RESTORE
    #--------------------------------------------------------------------------
    # Installer Function: PFI_ShutdownViaUI
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_ShutdownViaUI ""
!endif

!ifdef ADDUSER | INSTALLER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_ShutdownViaUI
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro PFI_ShutdownViaUI "un."
!endif


#--------------------------------------------------------------------------
# Macro: PFI_StrBackSlash
#
# The installation process and the uninstall process may both use a function which converts all
# slashes in a string into backslashes. This macro makes maintenance easier by ensuring that
# both processes use identical functions, with the only difference being their names.
#
# NOTE:
# The !insertmacro PFI_StrBackSlash "" and !insertmacro PFI_StrBackSlash "un." commands are included
# in this file so the NSIS script can use 'Call PFI_StrBackSlash' and 'Call un.PFI_StrBackSlash'
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
#         Call PFI_StrBackSlash
#         Pop $R0
#
#         ($R0 at this point is "C:\Program Files\Directory\Whatever")
#
#--------------------------------------------------------------------------

!macro PFI_StrBackSlash UN
  Function ${UN}PFI_StrBackSlash
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

!ifdef ADDSSL | ADDUSER | BACKUP | DBANALYSER | DBSTATUS | INSTALLER | PFIDIAG | RESTORE | RUNPOPFILE
    #--------------------------------------------------------------------------
    # Installer Function: PFI_StrBackSlash
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_StrBackSlash ""
!endif

!ifdef ADDUSER | INSTALLER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_StrBackSlash
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro PFI_StrBackSlash "un."
!endif


#--------------------------------------------------------------------------
# Macro: PFI_StrCheckDecimal
#
# The installation process and the uninstall process may both use a function which checks if
# a given string contains a decimal number. This macro makes maintenance easier by ensuring
# that both processes use identical functions, with the only difference being their names.
#
# The 'PFI_StrCheckDecimal' and 'un.PFI_StrCheckDecimal' functions check that a given string contains
# only the digits 0 to 9. (if the string contains any invalid characters, "" is returned)
#
# NOTE:
# The !insertmacro PFI_StrCheckDecimal "" and !insertmacro PFI_StrCheckDecimal "un." commands are
# included in this file so the NSIS script can use 'Call PFI_StrCheckDecimal' and
# 'Call un.PFI_StrCheckDecimal' without additional preparation.
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
#         Call un.PFI_StrCheckDecimal
#         Pop $R0
#         ($R0 at this point is "12345")
#
#--------------------------------------------------------------------------

!macro PFI_StrCheckDecimal UN
  Function ${UN}PFI_StrCheckDecimal

    !define DECIMAL_DIGIT   "0123456789"   ; accept only these digits
    !define BAD_OFFSET      10             ; length of DECIMAL_DIGIT string

    !define L_STRING        $0   ; The input string
    !define L_RESULT        $1   ; Holds the result: either "" (if input is invalid) or
                                 ; the input string (if the input is valid)
    !define L_CURRENT       $2   ; A character from the input string
    !define L_OFFSET        $3   ; The offset to a character in the "validity check" string
    !define L_VALIDCHAR     $4   ; A character from the "validity check" string
    !define L_VALIDLIST     $5   ; Holds the current "validity check" string
    !define L_CHARSLEFT     $6   ; To cater for MBCS input strings, terminate when end of
                                 ; string reached, not when a null byte reached

    Exch ${L_STRING}
    Push ${L_RESULT}
    Push ${L_CURRENT}
    Push ${L_OFFSET}
    Push ${L_VALIDCHAR}
    Push ${L_VALIDLIST}
    Push ${L_CHARSLEFT}

    StrCpy ${L_RESULT} ""

  next_input_char:
    StrLen ${L_CHARSLEFT} ${L_STRING}
    StrCmp ${L_CHARSLEFT} 0 done
    StrCpy ${L_CURRENT} ${L_STRING} 1                   ; Get the next char from input string
    StrCpy ${L_VALIDLIST} ${DECIMAL_DIGIT}${L_CURRENT}  ; Add it to end of "validity check"
                                                        ; to guarantee a match
    StrCpy ${L_STRING} ${L_STRING} "" 1
    StrCpy ${L_OFFSET} -1

  next_valid_char:
    IntOp ${L_OFFSET} ${L_OFFSET} + 1
    StrCpy ${L_VALIDCHAR} ${L_VALIDLIST} 1 ${L_OFFSET}    ; Extract next "valid" char
                                                          ; (from "validity check" string)
    StrCmp ${L_CURRENT} ${L_VALIDCHAR} 0 next_valid_char
    IntCmp ${L_OFFSET} ${BAD_OFFSET} invalid 0 invalid    ; If match is with the char we
                                                          ; added, input is bad
    StrCpy ${L_RESULT} ${L_RESULT}${L_VALIDCHAR}          ; Add "valid" character to result
    goto next_input_char

  invalid:
    StrCpy ${L_RESULT} ""

  done:
    StrCpy ${L_STRING} ${L_RESULT}  ; Result is either a string of decimal digits or ""
    Pop ${L_CHARSLEFT}
    Pop ${L_VALIDLIST}
    Pop ${L_VALIDCHAR}
    Pop ${L_OFFSET}
    Pop ${L_CURRENT}
    Pop ${L_RESULT}
    Exch ${L_STRING}                ; Place result on top of the stack

    !undef DECIMAL_DIGIT
    !undef BAD_OFFSET

    !undef L_STRING
    !undef L_RESULT
    !undef L_CURRENT
    !undef L_OFFSET
    !undef L_VALIDCHAR
    !undef L_VALIDLIST
    !undef L_CHARSLEFT

  FunctionEnd
!macroend

!ifndef DBANALYSER & LFNFIXER & MONITORCC & PFIDIAG & PLUGINCHECK & PORTABLE & RUNPOPFILE & RUNSQLITE & SHUTDOWN & TRANSLATOR
    #--------------------------------------------------------------------------
    # Installer Function: PFI_StrCheckDecimal
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_StrCheckDecimal ""
!endif

!ifdef ADDUSER | INSTALLER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_StrCheckDecimal
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro PFI_StrCheckDecimal "un."
!endif


#--------------------------------------------------------------------------
# Macro: PFI_StrCheckHexadecimal
#
# The installation process and the uninstall process may both need a function
# which checks if a given string contains only hexadecimal digits. This macro
# makes maintenance easier by ensuring that both processes use identical functions,
# with the only difference being their names.
#
# The 'PFI_StrCheckHexadecimal' and 'un.PFI_StrCheckHexadecimal' functions check that
# a given string contains only the digits 0 to 9 and/or letters A to F (in upper or
# lowercase). If the string contains any invalid characters, "" is returned.
#
# NOTE:
# The !insertmacro PFI_StrCheckHexadecimal "" and !insertmacro PFI_StrCheckHexadecimal "un."
# commands are included in this file so the NSIS script can use 'Call PFI_StrCheckHexadecimal'
# and 'Call un.PFI_StrCheckHexadecimal' without additional preparation.
#
# Inputs:
#         (top of stack)   - string which may contain a hexadecimal number
#
# Outputs:
#         (top of stack)   - the input string (if valid) or "" (if invalid)
#
# Usage (after the macro has been inserted):
#
#         Push "123abc"
#         Call PFI_StrCheckHexadecimal
#         Pop $R0
#
#         ($R0 at this point is "123abc")
#
#--------------------------------------------------------------------------

!macro PFI_StrCheckHexadecimal UN
  Function ${UN}PFI_StrCheckHexadecimal

    !define VALID_DIGIT     "0123456789abcdef"    ; accept only these digits
    !define BAD_OFFSET      16                    ; length of VALID_DIGIT string

    !define L_STRING        $0   ; The input string
    !define L_RESULT        $1   ; Holds the result: either "" (if input is invalid)
                                 ; or the input string (if valid)
    !define L_CURRENT       $2   ; A character from the input string
    !define L_OFFSET        $3   ; The offset to a char in the "validity check" string
    !define L_VALIDCHAR     $4   ; A character from the "validity check" string
    !define L_VALIDLIST     $5   ; Holds the current "validity check" string
    !define L_CHARSLEFT     $6   ; To cater for MBCS input strings, terminate when end
                                 ; of string reached, not when a null byte reached

    Exch ${L_STRING}
    Push ${L_RESULT}
    Push ${L_CURRENT}
    Push ${L_OFFSET}
    Push ${L_VALIDCHAR}
    Push ${L_VALIDLIST}
    Push ${L_CHARSLEFT}

    StrCpy ${L_RESULT} ""

  next_input_char:
    StrLen ${L_CHARSLEFT} ${L_STRING}
    StrCmp ${L_CHARSLEFT} 0 done
    StrCpy ${L_CURRENT} ${L_STRING} 1                 ; Get next char from input string
    StrCpy ${L_VALIDLIST} ${VALID_DIGIT}${L_CURRENT}  ; Add it to end of "validity
                                                      ; check" to guarantee a match
    StrCpy ${L_STRING} ${L_STRING} "" 1
    StrCpy ${L_OFFSET} -1

  next_valid_char:
    IntOp ${L_OFFSET} ${L_OFFSET} + 1
    StrCpy ${L_VALIDCHAR} ${L_VALIDLIST} 1 ${L_OFFSET} ; Extract next "valid" char
                                                       ; (from "validity check" string)
    StrCmp ${L_CURRENT} ${L_VALIDCHAR} 0 next_valid_char
    IntCmp ${L_OFFSET} ${BAD_OFFSET} invalid 0 invalid ; If match is with the char
                                                       ; we added, input is bad
    StrCpy ${L_RESULT} ${L_RESULT}${L_VALIDCHAR}       ; Add "valid" char to result
    goto next_input_char

  invalid:
    StrCpy ${L_RESULT} ""

  done:
    StrCpy ${L_STRING} ${L_RESULT}  ; Result is a string of hexadecimal digits or ""
    Pop ${L_CHARSLEFT}
    Pop ${L_VALIDLIST}
    Pop ${L_VALIDCHAR}
    Pop ${L_OFFSET}
    Pop ${L_CURRENT}
    Pop ${L_RESULT}
    Exch ${L_STRING}                ; Place result on top of the stack

    !undef VALID_DIGIT
    !undef BAD_OFFSET

    !undef L_STRING
    !undef L_RESULT
    !undef L_CURRENT
    !undef L_OFFSET
    !undef L_VALIDCHAR
    !undef L_VALIDLIST
    !undef L_CHARSLEFT

  FunctionEnd
!macroend

!ifdef ADDSSL | INSTALLER | PLUGINCHECK
    #--------------------------------------------------------------------------
    # Installer Function: PFI_StrCheckHexadecimal
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_StrCheckHexadecimal ""
!endif

!ifdef INSTALLER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_StrCheckHexadecimal
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro PFI_StrCheckHexadecimal "un."
!endif


#--------------------------------------------------------------------------
# Macro: PFI_StrStr
#
# The installation process and the uninstall process may both use a function which checks if
# a given string appears inside another string. This macro makes maintenance easier by ensuring
# that both processes use identical functions, with the only difference being their names.
#
# NOTE:
# The !insertmacro PFI_StrStr "" and !insertmacro PFI_StrStr "un." commands are included in this file
# so the NSIS script can use 'Call PFI_StrStr' and 'Call un.PFI_StrStr' without additional preparation.
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
#         Call PFI_StrStr
#         Pop $R0
#         ($R0 at this point is "long string")
#
#--------------------------------------------------------------------------

!macro PFI_StrStr UN
  Function ${UN}PFI_StrStr

    !define L_NEEDLE            $R1   ; the string we are trying to match
    !define L_HAYSTACK          $R2   ; the string in which we search for a match
    !define L_NEEDLE_LENGTH     $R3
    !define L_HAYSTACK_LIMIT    $R4
    !define L_HAYSTACK_OFFSET   $R5   ; the first character has an offset of zero
    !define L_SUBSTRING         $R6   ; a string that might match the 'needle' string

    Exch ${L_NEEDLE}
    Exch
    Exch ${L_HAYSTACK}
    Push ${L_NEEDLE_LENGTH}
    Push ${L_HAYSTACK_LIMIT}
    Push ${L_HAYSTACK_OFFSET}
    Push ${L_SUBSTRING}

    StrLen ${L_NEEDLE_LENGTH} ${L_NEEDLE}
    StrLen ${L_HAYSTACK_LIMIT} ${L_HAYSTACK}

    ; If 'needle' is longer than 'haystack' then return empty string
    ; (to show 'needle' was not found in 'haystack')

    IntCmp ${L_NEEDLE_LENGTH} ${L_HAYSTACK_LIMIT} 0 0 not_found

    ; Adjust the search limit as there is no point in testing substrings
    ; which are known to be shorter than the length of the 'needle' string

    IntOp ${L_HAYSTACK_LIMIT} ${L_HAYSTACK_LIMIT} - ${L_NEEDLE_LENGTH}

    ; The first character is at offset 0

    StrCpy ${L_HAYSTACK_OFFSET} 0

  loop:
    StrCpy ${L_SUBSTRING} ${L_HAYSTACK} ${L_NEEDLE_LENGTH} ${L_HAYSTACK_OFFSET}
    StrCmp ${L_SUBSTRING} ${L_NEEDLE} match_found
    IntOp ${L_HAYSTACK_OFFSET} ${L_HAYSTACK_OFFSET} + 1
    IntCmp ${L_HAYSTACK_OFFSET} ${L_HAYSTACK_LIMIT} loop loop 0

  not_found:
    StrCpy ${L_NEEDLE} ""
    Goto exit

  match_found:
    StrCpy ${L_NEEDLE} ${L_HAYSTACK} "" ${L_HAYSTACK_OFFSET}

  exit:
    Pop ${L_SUBSTRING}
    Pop ${L_HAYSTACK_OFFSET}
    Pop ${L_HAYSTACK_LIMIT}
    Pop ${L_NEEDLE_LENGTH}
    Pop ${L_HAYSTACK}
    Exch ${L_NEEDLE}

    !undef L_NEEDLE
    !undef L_HAYSTACK
    !undef L_NEEDLE_LENGTH
    !undef L_HAYSTACK_LIMIT
    !undef L_HAYSTACK_OFFSET
    !undef L_SUBSTRING

    FunctionEnd
!macroend

!ifndef DBANALYSER & DBSTATUS & IMAPUPDATER & LFNFIXER & MONITORCC & MSGCAPTURE & ONDEMAND & PLUGINCHECK & RUNSQLITE & SHUTDOWN & STOP_POPFILE & TRANSLATOR
    #--------------------------------------------------------------------------
    # Installer Function: PFI_StrStr
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_StrStr ""
!endif

!ifdef ADDUSER | INSTALLER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_StrStr
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro PFI_StrStr "un."
!endif


#--------------------------------------------------------------------------
# Macro: PFI_WaitUntilUnlocked
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
# The !insertmacro PFI_WaitUntilUnlocked "" and !insertmacro PFI_WaitUntilUnlocked "un." commands are
# included in this file so the NSIS script can use 'Call PFI_WaitUntilUnlocked' and
# 'Call un.PFI_WaitUntilUnlocked' without additional preparation.
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
#         Call PFI_WaitUntilUnlocked
#
#--------------------------------------------------------------------------

!macro PFI_WaitUntilUnlocked UN
  Function ${UN}PFI_WaitUntilUnlocked
    !define L_EXE           $R9   ; full path to the EXE file which is to be monitored
    !define L_RESULT        $R8
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
    Push ${L_RESULT}
    Push ${L_TIMEOUT}

    IfFileExists "${L_EXE}" 0 exit_now
    StrCpy ${L_TIMEOUT} ${C_SHUTDOWN_LIMIT}

  check_if_unlocked:
    Sleep ${C_SHUTDOWN_DELAY}
    Push "${C_EXE_END_MARKER}"
    Push "${L_EXE}"
    Call ${UN}PFI_CheckIfLocked
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" exit_now
    IntOp ${L_TIMEOUT} ${L_TIMEOUT} - 1
    IntCmp ${L_TIMEOUT} 0 exit_now exit_now check_if_unlocked

   exit_now:
    Pop ${L_TIMEOUT}
    Pop ${L_RESULT}
    Pop ${L_EXE}

    !undef L_EXE
    !undef L_RESULT
    !undef L_TIMEOUT
  FunctionEnd
!macroend

!ifdef ADDSSL | ADDUSER | INSTALLER | ONDEMAND
    #--------------------------------------------------------------------------
    # Installer Function: PFI_WaitUntilUnlocked
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_WaitUntilUnlocked ""
!endif

!ifdef ADDUSER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_WaitUntilUnlocked
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro PFI_WaitUntilUnlocked "un."
!endif


#--------------------------------------------------------------------------
# Macro: PFI_WriteEnvStr
#
# The installation process and the uninstall process both use a function which
# writes an environment variable which is available to the 'current user' on a
# modern OS. On Win9x systems, AUTOEXEC.BAT is updated and the Reboot flag is set
# to request a reboot to make the new variable available for use. This macro makes
# maintenance easier by ensuring that both processes use identical functions, with
# the only difference being their names.
#
# NOTE:
# The !insertmacro PFI_WriteEnvStr "" and !insertmacro PFI_WriteEnvStr "un." commands
# are included in this file so 'installer.nsi' can use 'Call PFI_WriteEnvStr' and
# 'Call un.PFI_WriteEnvStr' without additional preparation.
#
# Inputs:
#         (top of stack)       - value for the new environment variable
#         (top of stack - 1)   - name of the new environment variable
#
# Outputs:
#         none
#
#  Usage (after macro has been 'inserted'):
#
#         Push "HOMEDIR"
#         Push "C:\New Home Dir"
#         Call PFI_WriteEnvStr
#
#--------------------------------------------------------------------------

!macro PFI_WriteEnvStr UN
  Function ${UN}PFI_WriteEnvStr

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

    Call ${UN}NSIS_IsNT
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
    Call ${UN}NSIS_TrimNewlines
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
!macroend

!ifdef INSTALLER
    #--------------------------------------------------------------------------
    # Installer Function: PFI_WriteEnvStr
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_WriteEnvStr ""

    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_WriteEnvStr
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro PFI_WriteEnvStr "un."
!endif


#--------------------------------------------------------------------------
# Macro: PFI_WriteEnvStrNTAU
#
# The installation process and the uninstall process both use a function which
# writes an environment variable which is available to all users on a modern OS.
# On Win9x systems, AUTOEXEC.BAT is updated and the Reboot flag is set to request
# a reboot to make the new variable available for use. This macro is used to make
# maintenance easier by ensuring that both processes use identical functions, with
# the only difference being their names.
#
# NOTE:
# The !insertmacro PFI_WriteEnvStrNTAU "" and !insertmacro PFI_WriteEnvStrNTAU "un."
# commands are included in this file so 'installer.nsi' can use 'Call PFI_WriteEnvStrNTAU'
# and 'Call un.PFI_WriteEnvStrNTAU' without additional preparation.
#
# Inputs:
#         (top of stack)       - value for the new environment variable
#         (top of stack - 1)   - name of the new environment variable
#
# Outputs:
#         none
#
#  Usage (after macro has been 'inserted'):
#
#         Push "HOMEDIR"
#         Push "C:\New Home Dir"
#         Call PFI_WriteEnvStrNTAU
#
#--------------------------------------------------------------------------

!macro PFI_WriteEnvStrNTAU UN
  Function ${UN}PFI_WriteEnvStrNTAU

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

    Call ${UN}NSIS_IsNT
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
    Call ${UN}NSIS_TrimNewlines
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
!macroend

!ifdef INSTALLER
    #--------------------------------------------------------------------------
    # Installer Function: PFI_WriteEnvStrNTAU
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_WriteEnvStrNTAU ""

    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_WriteEnvStrNTAU
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro PFI_WriteEnvStrNTAU "un."
!endif

#--------------------------------------------------------------------------
# End of 'pfi-library.nsh'
#--------------------------------------------------------------------------
