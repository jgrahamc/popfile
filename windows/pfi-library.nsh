#--------------------------------------------------------------------------
#
# pfi-library.nsi --- This is a collection of library functions and macro
#                     definitions for inclusion in the NSIS scripts used
#                     to create (and test) the POPFile Windows installer.
#
# Copyright (c) 2003-2005 John Graham-Cumming
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
# Since so many scripts rely upon this library file, provide an easy way
# for the installers/uninstallers, wizards and other utilities to identify
# the particular library file used by NSIS to compile the executable file
# (by using this constant in the executable's "Version Information" data).
#--------------------------------------------------------------------------

  !define C_PFI_LIBRARY_VERSION     "0.1.7"

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

!ifdef ADDSSL | TRANSLATOR | TRANSLATOR_AUW
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
#     PFI_MinPerlMove
#     PFI_SkinMove
#     PFI_DeleteSkin
#     PFI_SectionNotSelected
#
# Note: The 'translator.nsi' script builds the utility which tests the translations.
#==============================================================================

!ifdef INSTALLER | TRANSLATOR

  ;--------------------------------------------------------------------------
  ; 'installer.nsi' macro used when rearranging existing minimal Perl system
  ;--------------------------------------------------------------------------

    !macro PFI_MinPerlMove SUBFOLDER

        !insertmacro PFI_UNIQUE_ID

        IfFileExists "$G_ROOTDIR\${SUBFOLDER}\*.*" 0 skip_${PFI_UNIQUE_ID}
        Rename "$G_ROOTDIR\${SUBFOLDER}" "$G_MPLIBDIR\${SUBFOLDER}"

      skip_${PFI_UNIQUE_ID}:

    !macroend

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
  ; 'adduser.nsi' macro used to ensure current skin selection uses lowercase
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
#    Installer Function: PFI_GetParameters
#    Installer Function: PFI_GetRoot
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
    # Installer Function: PFI_GetParameters
    #
    # Returns the command-line parameters (if any) supplied when the installer was started
    #
    # Inputs:
    #         none
    # Outputs:
    #         (top of stack)     - all of the parameters supplied on the command line (may be "")
    #
    # Usage:
    #         Call PFI_GetParameters
    #         Pop $R0
    #
    #         (if 'setup.exe /SSL' was used to start the installer, $R0 will hold '/SSL')
    #
    #--------------------------------------------------------------------------

    Function PFI_GetParameters

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


!ifdef ADDUSER | INSTALLER | RESTORE
    #--------------------------------------------------------------------------
    # Installer Function: PFI_GetRoot
    #
    # This function returns the root directory of a given path.
    # The given path must be a full path. Normal paths and UNC paths are supported.
    #
    # NB: The path is assumed to use backslashes (\)
    #
    # Inputs:
    #         (top of stack)          - input path
    #
    # Outputs:
    #         (top of stack)          - the root part of the path (eg "X:" or "\\server\share")
    #
    # Usage:
    #
    #         Push "C:\Program Files\Directory\Whatever"
    #         Call PFI_GetRoot
    #         Pop $R0
    #
    #         ($R0 at this point is ""C:")
    #
    #--------------------------------------------------------------------------

    Function PFI_GetRoot
      Exch $0
      Push $1
      Push $2
      Push $3
      Push $4

      StrCpy $1 $0 2
      StrCmp $1 "\\" UNC
      StrCpy $0 $1
      Goto done

    UNC:
      StrCpy $2 3
      StrLen $3 $0

    loop:
      IntCmp $2 $3 "" "" loopend
      StrCpy $1 $0 1 $2
      IntOp $2 $2 + 1
      StrCmp $1 "\" loopend loop

    loopend:
      StrCmp $4 "1" +3
      StrCpy $4 1
      Goto loop

      IntOp $2 $2 - 1
      StrCpy $0 $0 $2

    done:
      Pop $4
      Pop $3
      Pop $2
      Pop $1
      Exch $0
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


!ifdef ADDUSER | INSTALLER | RESTORE
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
      Call PFI_GetRoot              ; extract the "X:" or "\\server\share" part of the path
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
#    Macro:                PFI_GetDateStamp
#    Installer Function:   PFI_GetDateStamp
#    Uninstaller Function: un.PFI_GetDateStamp
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
#    Macro:                PFI_GetParent
#    Installer Function:   PFI_GetParent
#    Uninstaller Function: un.PFI_GetParent
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
#    Macro:                PFI_StrStr
#    Installer Function:   PFI_StrStr
#    Uninstaller Function: un.PFI_StrStr
#
#    Macro:                PFI_TrimNewlines
#    Installer Function:   PFI_TrimNewlines
#    Uninstaller Function: un.PFI_TrimNewlines
#
#    Macro:                PFI_WaitUntilUnlocked
#    Installer Function:   PFI_WaitUntilUnlocked
#    Uninstaller Function: un.PFI_WaitUntilUnlocked
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
# The !insertmacro PFI_CheckIfLocked "" and !insertmacro PFI_CheckIfLocked "un." commands are included
# in this file so the NSIS script can use 'Call PFI_CheckIfLocked' and 'Call un.PFI_CheckIfLocked'
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
#         Call PFI_CheckIfLocked
#         Pop $R0
#
#        (if the file is no longer in use, $R0 will be "")
#        (if the file is still being used, $R0 will be "$INSTDIR\wperl.exe")
#--------------------------------------------------------------------------

!macro PFI_CheckIfLocked UN
  Function ${UN}PFI_CheckIfLocked
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

      !ifndef LVM_GETITEMCOUNT
          !define LVM_GETITEMCOUNT 0x1004
      !endif
      !ifndef LVM_GETITEMTEXT
        !define LVM_GETITEMTEXT 0x102D
      !endif

      Exch $5
      Push $0
      Push $1
      Push $2
      Push $3
      Push $4
      Push $6

      FindWindow $0 "#32770" "" $HWNDPARENT
      GetDlgItem $0 $0 1016
      StrCmp $0 0 error
      FileOpen $5 $5 "w"
      StrCmp $5 "" error
      SendMessage $0 ${LVM_GETITEMCOUNT} 0 0 $6
      System::Alloc ${NSIS_MAX_STRLEN}
      Pop $3
      StrCpy $2 0
      System::Call "*(i, i, i, i, i, i, i, i, i) i \
                    (0, 0, 0, 0, 0, r3, ${NSIS_MAX_STRLEN}) .r1"

    loop:
      StrCmp $2 $6 done
      System::Call "User32::SendMessageA(i, i, i, i) i \
                    ($0, ${LVM_GETITEMTEXT}, $2, r1)"
      System::Call "*$3(&t${NSIS_MAX_STRLEN} .r4)"
      FileWrite $5 "$4${MB_NL}"
      IntOp $2 $2 + 1
      Goto loop

    done:
      FileClose $5
      System::Free $1
      System::Free $3
      Goto exit

    error:
      MessageBox MB_OK|MB_ICONEXCLAMATION "$(PFI_LANG_MB_SAVELOG_ERROR)"

    exit:
      Pop $6
      Pop $4
      Pop $3
      Pop $2
      Pop $1
      Pop $0
      Pop $5

    FunctionEnd
!macroend

!ifdef ADDSSL | BACKUP | INSTALLER | RESTORE
    #--------------------------------------------------------------------------
    # Installer Function: PFI_DumpLog
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_DumpLog ""
!endif

#--------------------------------------------------------------------------
# Uninstaller Function: un.PFI_DumpLog
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro PFI_DumpLog "un."


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

    DetailPrint "Checking '${L_PATH}\popfileb.exe' ..."

    Push "${L_PATH}\popfileb.exe"  ; runs POPFile in the background
    Call ${UN}PFI_CheckIfLocked
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" 0 exit

    DetailPrint "Checking '${L_PATH}\popfileib.exe' ..."

    Push "${L_PATH}\popfileib.exe" ; runs POPFile in the background with system tray icon
    Call ${UN}PFI_CheckIfLocked
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" 0 exit

    DetailPrint "Checking '${L_PATH}\popfilef.exe' ..."

    Push "${L_PATH}\popfilef.exe"  ; runs POPFile in the foreground/console window/DOS box
    Call ${UN}PFI_CheckIfLocked
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" 0 exit

    DetailPrint "Checking '${L_PATH}\popfileif.exe' ..."

    Push "${L_PATH}\popfileif.exe" ; runs POPFile in the foreground with system tray icon
    Call ${UN}PFI_CheckIfLocked
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" 0 exit

    DetailPrint "Checking '${L_PATH}\wperl.exe' ..."

    Push "${L_PATH}\wperl.exe"     ; runs POPFile in the background (using popfile.pl)
    Call ${UN}PFI_CheckIfLocked
    Pop ${L_RESULT}
    StrCmp ${L_RESULT} "" 0 exit

    DetailPrint "Checking '${L_PATH}\perl.exe' ..."

    Push "${L_PATH}\perl.exe"      ; runs POPFile in the foreground (using popfile.pl)
    Call ${UN}PFI_CheckIfLocked
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
      Call ${UN}PFI_GetParent
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

!ifdef ADDUSER | INSTALLER | RESTORE
    #--------------------------------------------------------------------------
    # Installer Function: PFI_GetCompleteFPN
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_GetCompleteFPN ""
!endif

#--------------------------------------------------------------------------
# Uninstaller Function: un.PFI_GetCompleteFPN
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro PFI_GetCompleteFPN "un."


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
    Call ${UN}PFI_TrimNewlines
    Pop ${L_CORPUS}
    StrCmp ${L_CORPUS} "" use_default_locn use_cfg_data

  use_default_locn:
    StrCpy ${L_RESULT} ${L_SOURCE}\corpus
    Goto got_result

  use_cfg_data:
    Push ${L_SOURCE}
    Push ${L_CORPUS}
    Call ${UN}PFI_GetDataPath
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

    StrCpy ${L_TEMP} ${L_PARAM} 18
    StrCmp ${L_TEMP} "database_database " 0 check_old_value
    StrCpy ${L_RESULT} ${L_PARAM} "" 18
    Goto check_eol

  check_old_value:
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
    Call ${UN}PFI_TrimNewlines
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
    Call ${UN}PFI_GetParent
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
# Macro: PFI_GetDateStamp
#
# The installation process and the uninstall process may need a function which uses the
# local time from Windows to generate a date stamp (eg '08-Dec-2003'). This macro makes
# maintenance easier by ensuring that both processes use identical functions, with
# the only difference being their names.
#
# NOTE:
# The !insertmacro PFI_GetDateStamp "" and !insertmacro PFI_GetDateStamp "un." commands are included
# in this file so the NSIS script and/or other library functions in 'pfi-library.nsh' can use
# 'Call PFI_GetDateStamp' and 'Call un.PFI_GetDateStamp' without additional preparation.
#
# Inputs:
#         (none)
# Outputs:
#         (top of stack)     - string holding current date (eg '07-Dec-2003')
#
# Usage (after macro has been 'inserted'):
#
#         Call un.PFI_GetDateStamp
#         Pop $R9
#
#         ($R9 now holds a string like '07-Dec-2003')
#--------------------------------------------------------------------------

!macro PFI_GetDateStamp UN
  Function ${UN}PFI_GetDateStamp

    !define L_DATESTAMP   $R9
    !define L_DAY         $R8
    !define L_MONTH       $R7
    !define L_YEAR        $R6

    Push ${L_DATESTAMP}
    Push ${L_DAY}
    Push ${L_MONTH}
    Push ${L_YEAR}

    Call ${UN}PFI_GetLocalTime
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
# Installer Function: PFI_GetDateStamp
#
# This function is used during the installation process
#--------------------------------------------------------------------------

;!insertmacro PFI_GetDateStamp ""

#--------------------------------------------------------------------------
# Uninstaller Function: un.PFI_GetDateStamp
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

;!insertmacro PFI_GetDateStamp "un."


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

!ifdef ADDSSL | ADDUSER | BACKUP | INSTALLER | MSGCAPTURE | PFIDIAG | RESTORE | TRANSLATOR_AUW
    #--------------------------------------------------------------------------
    # Installer Function: PFI_GetDateTimeStamp
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_GetDateTimeStamp ""
!endif

!ifdef ADDUSER
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

!ifdef ADDSSL | ADDUSER | BACKUP | INSTALLER | RESTORE | STOP_POPFILE
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

!ifdef ADDSSL | ADDUSER | BACKUP | INSTALLER | MSGCAPTURE | PFIDIAG | RESTORE | TRANSLATOR_AUW
    #--------------------------------------------------------------------------
    # Installer Function: PFI_GetLocalTime
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_GetLocalTime ""
!endif

!ifdef ADDUSER
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
    Call ${UN}PFI_TrimNewlines
    Pop ${L_MSG_HISTORY}
    StrCmp ${L_MSG_HISTORY} "" use_default_locn use_cfg_data

  use_default_locn:
    StrCpy ${L_RESULT} ${L_SOURCE}\messages
    Goto got_result

  use_cfg_data:
    Push ${L_SOURCE}
    Push ${L_MSG_HISTORY}
    Call ${UN}PFI_GetDataPath
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
# Macro: PFI_GetParent
#
# The installation process and the uninstall process may both use a function which extracts the
# parent directory from a given path. This macro makes maintenance easier by ensuring that both
# processes use identical functions, with the only difference being their names.
#
# NB: The path is assumed to use backslashes (\)
#
# NOTE:
# The !insertmacro PFI_GetParent "" and !insertmacro PFI_GetParent "un." commands are included
# in this file so the NSIS script can use 'Call PFI_GetParent' and 'Call un.PFI_GetParent'
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
#         Call un.PFI_GetParent
#         Pop $R0
#
#         ($R0 at this point is ""C:\Program Files\Directory")
#
#--------------------------------------------------------------------------

!macro PFI_GetParent UN
  Function ${UN}PFI_GetParent
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

!ifdef ADDSSL | ADDUSER | BACKUP | INSTALLER | RESTORE | RUNPOPFILE
    #--------------------------------------------------------------------------
    # Installer Function: PFI_GetParent
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_GetParent ""
!endif

!ifdef ADDUSER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_GetParent
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro PFI_GetParent "un."
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
    Call ${UN}PFI_TrimNewlines
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

    StrCpy ${L_RESULT} ${L_TEMP} 18
    StrCmp ${L_RESULT} "database_database " got_sql_corpus
    StrCpy ${L_RESULT} ${L_TEMP} 19
    StrCmp ${L_RESULT} "database_dbconnect " got_sql_connect

    StrCpy ${L_RESULT} ${L_TEMP} 15
    StrCmp ${L_RESULT} "bayes_database " got_sql_old_corpus
    StrCpy ${L_RESULT} ${L_TEMP} 16
    StrCmp ${L_RESULT} "bayes_dbconnect " got_sql_old_connect
    Goto check_eol

  got_sql_old_corpus:
    StrCpy ${L_SQL_CORPUS} ${L_TEMP} "" 15
    Goto check_eol

  got_sql_old_connect:
    StrCpy ${L_SQL_CONNECT} ${L_TEMP} "" 16
    Goto check_eol

  got_sql_corpus:
    StrCpy ${L_SQL_CORPUS} ${L_TEMP} "" 18
    Goto check_eol

  got_sql_connect:
    StrCpy ${L_SQL_CONNECT} ${L_TEMP} "" 19

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
    Call ${UN}PFI_TrimNewlines
    Pop ${L_SQL_CONNECT}
    StrCmp ${L_SQL_CONNECT} "" no_sql_set
    StrCpy ${L_SQL_CONNECT} ${L_SQL_CONNECT} 10
    StrCmp ${L_SQL_CONNECT} "dbi:SQLite" 0 not_sqlite

    Push ${L_SQL_CORPUS}
    Call ${UN}PFI_TrimNewlines
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
    Call ${UN}PFI_GetDataPath
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
#                              If the result is enclosed in parentheses then an error occurred.
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

    Exch ${L_COMMAND}
    Exch
    Exch ${L_DATABASE}
    Push ${L_RESULT}
    Exch 2
    Push ${L_SQLITEPATH}
    Push ${L_SQLITEUTIL}
    Push ${L_STATUS}

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
    nsExec::ExecToStack '"${L_SQLITEPATH}\${L_SQLITEUTIL}" "${L_DATABASE}" "${L_COMMAND}"'
    Pop ${L_STATUS}
    Call ${UN}PFI_TrimNewlines
    Pop ${L_RESULT}
    StrCmp ${L_STATUS} "0" exit
    StrCpy ${L_RESULT} "(${L_RESULT})"

  exit:
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

!ifdef ADDSSL | ADDUSER | BACKUP | INSTALLER | RESTORE
    #--------------------------------------------------------------------------
    # Installer Function: PFI_ServiceCall
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_ServiceCall ""
!endif

!ifdef ADDUSER | INSTALLER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_ServiceCall
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro PFI_ServiceCall "un."
!endif


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

!ifdef ADDSSL | ADDUSER | BACKUP | INSTALLER | RESTORE
    #--------------------------------------------------------------------------
    # Installer Function: PFI_ServiceRunning
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_ServiceRunning ""
!endif

!ifdef ADDUSER | INSTALLER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_ServiceRunning
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro PFI_ServiceRunning "un."
!endif


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
# To avoid the need to parse the HTML page downloaded by NSISdl, we call NSISdl again if the
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
    Call ${UN}PFI_StrCheckDecimal
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

!ifdef ADDSSL | ADDUSER | BACKUP | INSTALLER | RESTORE
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

!ifdef ADDSSL | ADDUSER | BACKUP | INSTALLER | RESTORE | RUNPOPFILE
    #--------------------------------------------------------------------------
    # Installer Function: PFI_StrBackSlash
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_StrBackSlash ""
!endif

!ifdef ADDUSER
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
# Macro: PFI_TrimNewlines
#
# The installation process and the uninstall process may both use a function to trim newlines
# from lines of text. This macro makes maintenance easier by ensuring that both processes use
# identical functions, with the only difference being their names.
#
# NOTE:
# The !insertmacro PFI_TrimNewlines "" and !insertmacro PFI_TrimNewlines "un." commands are
# included in this file so the NSIS script can use 'Call PFI_TrimNewlines' and
# 'Call un.PFI_TrimNewlines' without additional preparation.
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
#         Call un.PFI_TrimNewlines
#         Pop $R0
#         ($R0 at this point is "whatever")
#
#--------------------------------------------------------------------------

!macro PFI_TrimNewlines UN
  Function ${UN}PFI_TrimNewlines
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
    # Installer Function: PFI_TrimNewlines
    #
    # This function is used during the installation process
    #--------------------------------------------------------------------------

    !insertmacro PFI_TrimNewlines ""
!endif

!ifdef ADDUSER | INSTALLER
    #--------------------------------------------------------------------------
    # Uninstaller Function: un.PFI_TrimNewlines
    #
    # This function is used during the uninstall process
    #--------------------------------------------------------------------------

    !insertmacro PFI_TrimNewlines "un."
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
# End of 'pfi-library.nsh'
#--------------------------------------------------------------------------
