#--------------------------------------------------------------------------
#
# adduser-Uninstall.nsh --- This 'include' file contains the 'Uninstall' part of the NSIS
#                           script (adduser.nsi) used to build the 'Add POPFile User' wizard.
#
# Copyright (c) 2005 John Graham-Cumming
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
#  The 'adduser.nsi' script file contains the following code:
#
#     #==========================================================================
#     #==========================================================================
#     # The 'Uninstall' part of the script is in a separate file
#     #==========================================================================
#     #==========================================================================
#
#       !include "adduser-Uninstall.nsh"
#
#     #==========================================================================
#     #==========================================================================
#
#--------------------------------------------------------------------------


#####################################################################################
#                                                                                   #
#   ##    ##  ##    ##   ##   ##    ##   #####  ########  #####    ##      ##       #
#   ##    ##  ###   ##   ##   ###   ##  ##   ##    ##    ##   ##   ##      ##       #
#   ##    ##  ####  ##   ##   ####  ##  ##         ##    ##   ##   ##      ##       #
#   ##    ##  ## ## ##   ##   ## ## ##   #####     ##    #######   ##      ##       #
#   ##    ##  ##  ####   ##   ##  ####       ##    ##    ##   ##   ##      ##       #
#   ##    ##  ##   ###   ##   ##   ###  ##   ##    ##    ##   ##   ##      ##       #
#    ######   ##    ##   ##   ##    ##   #####     ##    ##   ##   ######  ######   #
#                                                                                   #
#####################################################################################


#--------------------------------------------------------------------------
# Initialise the uninstaller
#--------------------------------------------------------------------------

Function un.onInit

  ; Retrieve the language used when this version was installed, and use it for the uninstaller

  !insertmacro MUI_UNGETLANGUAGE

  ; Before POPFile 0.21.0, POPFile and the minimal Perl shared the same folder structure.
  ; Phase 1 of the multi-user support introduced in 0.21.0 requires some slight changes
  ; to the folder structure.

  ; For increased flexibility, several global user variables are used (this makes it easier
  ; to change the folder structure used by the wizard)

  StrCpy $G_USERDIR   "$INSTDIR"

  ReadRegStr $G_ROOTDIR HKLM "SOFTWARE\POPFile Project\${C_PFI_PRODUCT}\MRI" "InstallPath"

  ; Email settings are stored on a 'per user' basis therefore we need to know which user is
  ; running the uninstaller so we can check if the email settings can be safely restored

	ClearErrors
	UserInfo::GetName
	IfErrors 0 got_name

  ; Assume Win9x system, so user has 'Admin' rights
  ; (UserInfo works on Win98SE so perhaps it is only Win95 that fails ?)

  StrCpy $G_WINUSERNAME "UnknownUser"
  StrCpy $G_WINUSERTYPE "Admin"
  Goto exit

got_name:
	Pop $G_WINUSERNAME
  StrCmp $G_WINUSERNAME "" 0 get_usertype
  StrCpy $G_WINUSERNAME "UnknownUser"

get_usertype:
  UserInfo::GetAccountType
	Pop $G_WINUSERTYPE
  StrCmp $G_WINUSERTYPE "Admin" exit
  StrCmp $G_WINUSERTYPE "Power" exit
  StrCmp $G_WINUSERTYPE "User" exit
  StrCmp $G_WINUSERTYPE "Guest" exit
  StrCpy $G_WINUSERTYPE "Unknown"

exit:
FunctionEnd

#--------------------------------------------------------------------------
# Uninstaller Function: un.PFIGUIInit
# (custom un.onGUIInit function)
#
# Used to complete the initialization of the uninstaller using language-specific strings.
#--------------------------------------------------------------------------

Function un.PFIGUIInit

  !define L_TEMP        $R9

  Push ${L_TEMP}

  ; Assume uninstaller is being run by the correct user

  StrCpy $G_PFIFLAG "normal"

  ReadINIStr ${L_TEMP} "$G_USERDIR\install.ini" "Settings" "Owner"
  StrCmp ${L_TEMP} "" continue_uninstall
  StrCmp ${L_TEMP} $G_WINUSERNAME continue_uninstall
  StrCpy $G_PFIFLAG "special"
  MessageBox MB_YESNO|MB_ICONSTOP|MB_DEFBUTTON2 \
      "$(PFI_LANG_UN_MBDIFFUSER_1) ('${L_TEMP}') !\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_UN_MBNOTFOUND_2)" IDYES continue_uninstall
  Abort "$(PFI_LANG_UN_ABORT_1)"

continue_uninstall:
  Pop ${L_TEMP}

  !undef L_TEMP

FunctionEnd

#--------------------------------------------------------------------------
# Uninstaller Sections (this build uses all of these and executes them in the order shown)
#
#  (1) un.Uninstall Begin    - requests confirmation if appropriate
#  (2) un.Shutdown POPFile   - shutdown POPFile if necessary (to avoid the need to reboot)
#  (3) un.Email Settings     - restore Outlook Express/Outlook/Eudora email settings
#  (4) un.User Data          - remove corpus, message history and other data folders
#  (5) un.User Config        - uninstall configuration files in $G_USERDIR folder
#  (6) un.ShortCuts          - remove shortcuts
#  (7) un.Environment        - current user's POPFile environment variables
#  (8) un.Registry Entries   - remove 'Add/Remove Program' data and other registry entries
#  (9) un.Uninstall End      - remove remaining files/folders (if it is safe to do so)
#
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.Uninstall Begin' (the first section in the uninstaller)
#--------------------------------------------------------------------------

Section "un.Uninstall Begin" UnSecBegin

  StrCmp $G_PFIFLAG "normal" continue
  DetailPrint ""
  DetailPrint "*** Uninstaller is being run by the 'wrong' user ***"
  DetailPrint ""

continue:
  IfFileExists $G_USERDIR\popfile.cfg skip_confirmation
    MessageBox MB_YESNO|MB_ICONSTOP|MB_DEFBUTTON2 \
        "$(PFI_LANG_UN_MBNOTFOUND_1) '$G_USERDIR'.\
        ${MB_NL}${MB_NL}\
        $(PFI_LANG_UN_MBNOTFOUND_2)" IDYES skip_confirmation
    Abort "$(PFI_LANG_UN_ABORT_1)"

skip_confirmation:
SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.Shutdown POPFile'
#--------------------------------------------------------------------------

Section "un.Shutdown POPFile" UnSecShutdown

  !define L_EXE         $R9   ; full path of the EXE to be monitored
  !define L_TEMP        $R8

  Push ${L_EXE}
  Push ${L_TEMP}

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROG_EXESTATUS)"
  SetDetailsPrint listonly

  ; Starting with POPfile 0.21.0 an experimental version of 'popfile-service.exe' was included
  ; to allow POPFile to be run as a Windows service.

  Push "POPFile"
  Call un.PFI_ServiceRunning
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "true" manual_shutdown

  Push $G_ROOTDIR
  Call un.PFI_FindLockedPFE
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" section_exit

  ; Need to shutdown POPFile, so we can remove the SQLite database and other user data

  Call un.GetUIport
  StrCmp $G_GUI "" manual_shutdown
  Push $G_GUI
  Call un.PFI_TrimNewlines
  Call un.PFI_StrCheckDecimal
  Pop $G_GUI
  StrCmp $G_GUI "" manual_shutdown
  DetailPrint "$(PFI_LANG_UN_LOG_SHUTDOWN) $G_GUI"
  DetailPrint "$(PFI_LANG_TAKE_A_FEW_SECONDS)"
  Push $G_GUI
  Call un.PFI_ShutdownViaUI
  Pop ${L_TEMP}

  Push ${L_EXE}
  Call un.PFI_WaitUntilUnlocked
  Push ${L_EXE}
  Call un.PFI_CheckIfLocked
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" section_exit

manual_shutdown:
  StrCpy $G_PLS_FIELD_1 "POPFile"
  DetailPrint "Unable to shutdown $G_PLS_FIELD_1 automatically - manual intervention requested"
  MessageBox MB_OK|MB_ICONEXCLAMATION|MB_TOPMOST "$(PFI_LANG_MBMANSHUT_1)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_MBMANSHUT_2)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_MBMANSHUT_3)"

section_exit:
  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

  Pop ${L_TEMP}
  Pop ${L_EXE}

  !undef L_EXE
  !undef L_TEMP

SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.Email Settings'
#--------------------------------------------------------------------------

Section "un.Email Settings" UnSecEmail

  ; If the uninstaller is being run by the "wrong" user, we cannot restore the email settings

  StrCmp $G_PFIFLAG "special" do_nothing

  !define L_TEMP        $R9
  !define L_UNDOFILE    $R8   ; file holding original email client settings

  Push ${L_TEMP}
  Push ${L_UNDOFILE}

  ; Initialise the status flag (if the email 'restore' fails we may need to retain 'undo' data)

  StrCpy $G_PFIFLAG "success"

  ;------------------------------------
  ; Restore 'Outlook Express' settings
  ;------------------------------------

  StrCpy ${L_UNDOFILE} "pfi-outexpress.ini"
  IfFileExists "$G_USERDIR\${L_UNDOFILE}" 0 end_oe_restore
  Push  ${L_UNDOFILE}
  Push "$(PFI_LANG_UN_PROG_OUTEXPRESS)"
  Push "OUTEXP"
  Call un.RestoreOOE
  Pop ${L_TEMP}

  StrCmp ${L_TEMP} "success" delete_oe_data
  StrCpy $G_PFIFLAG "fail"
  DetailPrint "$(PFI_LANG_UN_LOG_DATAPROBS): ${L_UNDOFILE}"
  MessageBox MB_YESNO|MB_ICONEXCLAMATION \
      "$(PFI_LANG_UN_MBCLIENT_1)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_UN_MBEMAIL_1)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_UN_MBEMAIL_2)" IDNO end_oe_restore
  ExecShell "open" "$G_USERDIR\${L_UNDOFILE}.errors.txt"
  Goto end_oe_restore

delete_oe_data:
  Delete "$G_USERDIR\${L_UNDOFILE}"
  Delete "$G_USERDIR\popfile.reg.bk*"

end_oe_restore:

  ;------------------------------------
  ; Restore 'Outlook' settings
  ;------------------------------------

  StrCpy ${L_UNDOFILE} "pfi-outlook.ini"
  IfFileExists "$G_USERDIR\${L_UNDOFILE}" 0 end_outlook_restore
  Push  ${L_UNDOFILE}
  Push "$(PFI_LANG_UN_PROG_OUTLOOK)"
  Push "OUTLOOK"
  Call un.RestoreOOE
  Pop ${L_TEMP}

  StrCmp ${L_TEMP} "success" delete_outlook_data
  StrCpy $G_PFIFLAG "fail"
  DetailPrint "$(PFI_LANG_UN_LOG_DATAPROBS): ${L_UNDOFILE}"
  MessageBox MB_YESNO|MB_ICONEXCLAMATION \
      "$(PFI_LANG_UN_MBCLIENT_2)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_UN_MBEMAIL_1)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_UN_MBEMAIL_2)" IDNO end_outlook_restore
  ExecShell "open" "$G_USERDIR\${L_UNDOFILE}.errors.txt"
  Goto end_outlook_restore

delete_outlook_data:
  Delete "$G_USERDIR\${L_UNDOFILE}"
  Delete "$G_USERDIR\outlook.reg.bk*"

end_outlook_restore:

  ;------------------------------------
  ; Restore 'Eudora' settings
  ;------------------------------------

  StrCpy ${L_UNDOFILE} "pfi-eudora.ini"
  IfFileExists "$G_USERDIR\${L_UNDOFILE}" 0 end_eudora_restore
  Push  ${L_UNDOFILE}
  Push "$(PFI_LANG_UN_PROG_EUDORA)"
  Call un.RestoreEudora
  Pop ${L_TEMP}

  StrCmp ${L_TEMP} "success" delete_eudora_data
  StrCpy $G_PFIFLAG "fail"
  DetailPrint "$(PFI_LANG_UN_LOG_DATAPROBS): ${L_UNDOFILE}"
  MessageBox MB_YESNO|MB_ICONEXCLAMATION \
      "$(PFI_LANG_UN_MBCLIENT_3)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_UN_MBEMAIL_1)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_UN_MBEMAIL_2)" IDNO end_eudora_restore
  ExecShell "open" "$G_USERDIR\${L_UNDOFILE}.errors.txt"
  Goto end_eudora_restore

delete_eudora_data:
  Delete "$G_USERDIR\${L_UNDOFILE}"

end_eudora_restore:
  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

  Pop ${L_UNDOFILE}
  Pop ${L_TEMP}

  !undef L_TEMP
  !undef L_UNDOFILE

do_nothing:
SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.User Data'
#--------------------------------------------------------------------------

Section "un.User Data" UnSecCorpusMsgDir

  !define L_MESSAGES  $R9
  !define L_TEMP      $R8

  Push ${L_MESSAGES}
  Push ${L_TEMP}

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROG_DBMSGDIR)"
  SetDetailsPrint listonly

  ; Win95 generates an error message if 'RMDir /r' is used on a non-existent directory

  IfFileExists "$G_USERDIR\corpus\*.*" 0 skip_nonsql_corpus
  RMDir /r "$G_USERDIR\corpus"

skip_nonsql_corpus:
  Delete "$G_USERDIR\popfile.db"

  Push $G_USERDIR
  Call un.PFI_GetMessagesPath
  Pop ${L_MESSAGES}
  StrLen ${L_TEMP} $G_USERDIR
  StrCpy ${L_TEMP} ${L_MESSAGES} ${L_TEMP}
  StrCmp ${L_TEMP} $G_USERDIR delete_msgdir

  ; The message history is not in a 'User Data' sub-folder so we ask for permission to delete it

  MessageBox MB_YESNO|MB_ICONQUESTION \
    "$(PFI_LANG_UN_MBDELMSGS_1)\
    ${MB_NL}${MB_NL}\
    (${L_MESSAGES})" IDNO section_exit

delete_msgdir:
  IfFileExists "${L_MESSAGES}\*." 0 section_exit
  RMDir /r "${L_MESSAGES}"

section_exit:
  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

  Pop ${L_TEMP}
  Pop ${L_MESSAGES}

  !undef L_MESSAGES
  !undef L_TEMP

SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.User Config'
#--------------------------------------------------------------------------

Section "un.User Config" UnSecConfig

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROG_CONFIG)"
  SetDetailsPrint listonly

  Delete "$G_USERDIR\popfile.cfg"
  Delete "$G_USERDIR\popfile.cfg.bak"
  Delete "$G_USERDIR\popfile.cfg.bk?"
  Delete "$G_USERDIR\*.log"
  Delete "$G_USERDIR\expchanges.txt"
  Delete "$G_USERDIR\expconfig.txt"
  Delete "$G_USERDIR\outchanges.txt"
  Delete "$G_USERDIR\outconfig.txt"

  Delete "$G_USERDIR\stopwords"
  Delete "$G_USERDIR\stopwords.bak"
  Delete "$G_USERDIR\stopwords.default"

  Delete "$G_USERDIR\pfi-run.bat"

  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.ShortCuts'
#--------------------------------------------------------------------------

Section "un.ShortCuts" UnSecShortcuts

  StrCmp $G_PFIFLAG "fail" do_nothing

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROG_SHORT)"
  SetDetailsPrint listonly

  Delete "$G_USERDIR\Run SQLite utility.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Uninstall POPFile Data ($G_WINUSERNAME).lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\User Data ($G_WINUSERNAME).lnk"
  RMDir "$SMPROGRAMS\${C_PFI_PRODUCT}\Support"
  RMDir "$SMPROGRAMS\${C_PFI_PRODUCT}"

  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

do_nothing:
SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.Environment'
#--------------------------------------------------------------------------

Section "un.Environment" UnSecEnvVars

  StrCmp $G_PFIFLAG "special" do_nothing
  StrCmp $G_PFIFLAG "fail" do_nothing

  !define L_TEMP      $R9

  Push ${L_TEMP}

  Call un.PFI_IsNT
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} 0 section_exit

  ; Delete current user's POPFile environment variables

  DeleteRegValue HKCU "Environment" "POPFILE_ROOT"
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
  DeleteRegValue HKCU "Environment" "POPFILE_USER"
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

section_exit:
  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

  Pop ${L_TEMP}

  !undef L_TEMP

do_nothing:
SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.Registry Entries'
#--------------------------------------------------------------------------

Section "un.Registry Entries" UnSecRegistry

  StrCmp $G_PFIFLAG "special" do_nothing
  StrCmp $G_PFIFLAG "fail" do_nothing

  !define L_REGDATA   $R9

  Push ${L_REGDATA}

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROG_REGISTRY)"
  SetDetailsPrint listonly

  ; Clean up registry data if it matches what we are uninstalling

  ReadRegStr ${L_REGDATA} HKCU \
      "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}_Data" \
      "UninstallString"
  StrCmp ${L_REGDATA} "$G_USERDIR\uninstalluser.exe" 0 other_reg_data
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}_Data"

other_reg_data:
  ReadRegStr ${L_REGDATA} HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "UserDir_LFN"
  StrCmp ${L_REGDATA} $G_USERDIR 0 section_exit
  DeleteRegKey HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI"
  DeleteRegKey /ifempty HKCU "Software\POPFile Project\${C_PFI_PRODUCT}"
  DeleteRegKey /ifempty HKCU "Software\POPFile Project"

section_exit:
  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

  Pop ${L_REGDATA}

  !undef L_REGDATA

do_nothing:
SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.Uninstall End'
#
# This is the final section of the uninstaller.
#--------------------------------------------------------------------------

Section "un.Uninstall End" UnSecEnd

  !define L_DEFAULT   $R9
  !define L_RESULT    $R8

  Push ${L_DEFAULT}
  Push ${L_RESULT}

  ; If email client problems found, offer to leave uninstaller behind with the error logs etc

  StrCmp $G_PFIFLAG "success" uninstall_files
  MessageBox MB_YESNO|MB_ICONSTOP \
    "$(PFI_LANG_UN_MBRERUN_1)\
    ${MB_NL}${MB_NL}\
    $(PFI_LANG_UN_MBRERUN_2)\
    ${MB_NL}${MB_NL}\
    $(PFI_LANG_UN_MBRERUN_3)\
    ${MB_NL}${MB_NL}\
    $(PFI_LANG_UN_MBRERUN_4)" IDYES exit

uninstall_files:
  Delete "$G_USERDIR\install.ini"
  Delete "$G_USERDIR\uninstalluser.exe"

  ; Check if the user data was stored in same folder as the POPFile program files

  IfFileExists "$G_USERDIR\popfile.pl" exit
  IfFileExists "$G_USERDIR\perl.exe" exit

  ; Try to remove the 'User Data' folder (this will fail if the folder is not empty)

  RMDir "$G_USERDIR"

  ; If $G_USERDIR was removed, no need to try again

  IfFileExists "$G_USERDIR\*.*" 0 tidy_up

  ; Assume it is safe to offer to remove everything now

  MessageBox MB_YESNO|MB_ICONQUESTION "$(PFI_LANG_UN_MBREMDIR_2)" IDNO exit
  DetailPrint "$(PFI_LANG_UN_LOG_DELUSERDIR)"
  Delete "$G_USERDIR\*.*"
  RMDir /r "$G_USERDIR"

  IfFileExists "$G_USERDIR\*.*" 0 tidy_up
  DetailPrint "$(PFI_LANG_UN_LOG_DELUSERERR)"
  StrCpy $G_PLS_FIELD_1 $G_USERDIR
  MessageBox MB_OK|MB_ICONEXCLAMATION \
      "$(PFI_LANG_UN_MBREMERR_A))"

tidy_up:
  StrCmp $APPDATA "" 0 appdata_valid
  StrCpy ${L_DEFAULT} "${C_ALT_DEFAULT_USERDATA}"
  Goto check_parent

appdata_valid:
  StrCpy ${L_DEFAULT} "${C_STD_DEFAULT_USERDATA}"

check_parent:
  Push $G_USERDIR
  Push ${L_DEFAULT}
  Call un.PFI_StrStr
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "" exit
  RMDir ${L_DEFAULT}

exit:
  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint both

  Pop ${L_RESULT}
  Pop ${L_DEFAULT}

  !undef L_DEFAULT
  !undef L_RESULT

SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Function: un.GetUIport
#
# Used to extract the UI port setting from popfile.cfg and load it into the
# global user variable $G_GUI (if setting is not found $G_GUI is set to "")
# NB: The "raw" parameter is returned (no trimming is performed).
#
# This function is used to avoid the annoying progress bar flicker seen when
# similar code was used in the "un.Shutdown POPFile" section.
#--------------------------------------------------------------------------

Function un.GetUIport

  !define L_CFG         $R9   ; used as file handle
  !define L_LNE         $R8   ; a line from popfile.cfg
  !define L_TEMP        $R7
  !define L_TEXTEND     $R6   ; used to ensure correct handling of lines longer than 1023 chars

  Push ${L_CFG}
  Push ${L_LNE}
  Push ${L_TEMP}
  Push ${L_TEXTEND}

  StrCpy $G_GUI ""

  FileOpen ${L_CFG} "$G_USERDIR\popfile.cfg" r

found_eol:
  StrCpy ${L_TEXTEND} "<eol>"

loop:
  FileRead ${L_CFG} ${L_LNE}
  StrCmp ${L_LNE} "" ui_port_done
  StrCmp ${L_TEXTEND} "<eol>" 0 check_eol
  StrCmp ${L_LNE} "$\n" loop

  StrCpy ${L_TEMP} ${L_LNE} 10
  StrCmp ${L_TEMP} "html_port " 0 check_eol
  StrCpy $G_GUI ${L_LNE} 5 10

  ; Now read file until we get to end of the current line
  ; (i.e. until we find text ending in <CR><LF>, <CR> or <LF>)

check_eol:
  StrCpy ${L_TEXTEND} ${L_LNE} 1 -1
  StrCmp ${L_TEXTEND} "$\n" found_eol
  StrCmp ${L_TEXTEND} "$\r" found_eol loop

ui_port_done:
  FileClose ${L_CFG}

  Pop ${L_TEXTEND}
  Pop ${L_TEMP}
  Pop ${L_LNE}
  Pop ${L_CFG}

  !undef L_CFG
  !undef L_LNE
  !undef L_TEMP
  !undef L_TEXTEND

FunctionEnd

#--------------------------------------------------------------------------
# Uninstaller Function: un.RestoreOOE
#
# Used to restore Outlook or Outlook Express settings using data saved during installation
#
# Inputs:
#         (top of stack)          - mode: "OUTLOOK" = "Outlook", "OUTEXP" = "Outlook Express"
#         (top of stack - 1)      - text string to be shown in uninstaller window/log
#         (top of stack - 2)      - the name of the file holding the 'undo' data
#
# Outputs:
#         (top of stack)          - string with one of the following result codes:
#
#                                      "success"  (all settings restored)
#
#                                      "badmode"  (mode flag was not "OUT" or "EXP")
#
#                                      "corrupt"  (the 'undo' data has been corrupted)
#
#                                      "foreign"  (some data belongs to another user
#                                                  and could not be restored)
#
#                                      "nofile"   (no restore data file found)
#
#                                      "running"  (aborted as email program is still running)
#
#  Usage:
#
#         Push "pfi-outlook.ini"
#         Push "Restoring Outlook settings..."
#         Push "OUTLOOK"
#         Call un.RestoreOOE
#         Pop $R9
#
#         (if $R9 is "foreign", some data was not restored as it doesn't belong to current user)
#--------------------------------------------------------------------------

Function un.RestoreOOE

  !define L_INDEX       $R9
  !define L_INIV        $R8
  !define L_MESSAGE     $R7
  !define L_POP_PORT    $R6
  !define L_POP_SERVER  $R5
  !define L_POP_USER    $R4
  !define L_REG_KEY     $R3
  !define L_TEMP        $R2
  !define L_UNDOFILE    $R1
  !define L_USERNAME    $R0
  !define L_USERTYPE    $9
  !define L_ERRORLOG    $8
  !define L_MODEFLAG    $7

  Exch ${L_MODEFLAG}
  Exch
  Exch ${L_MESSAGE}
  Exch 2
  Exch ${L_UNDOFILE}

  Push ${L_INDEX}
  Push ${L_INIV}
  Push ${L_POP_PORT}
  Push ${L_POP_SERVER}
  Push ${L_POP_USER}
  Push ${L_REG_KEY}
  Push ${L_TEMP}
  Push ${L_USERNAME}
  Push ${L_USERTYPE}
  Push ${L_ERRORLOG}

  StrCmp ${L_MODEFLAG} "OUTLOOK" find_undofile
  StrCmp ${L_MODEFLAG} "OUTEXP" find_undofile bad_mode

find_undofile:
  IfFileExists "$G_USERDIR\${L_UNDOFILE}" 0 nothing_to_restore

  SetDetailsPrint textonly
  DetailPrint "${L_MESSAGE}"
  SetDetailsPrint listonly
  DetailPrint "$(PFI_LANG_UN_LOG_OPENED): ${L_UNDOFILE}"

  Call un.PFI_GetDateTimeStamp
  Pop ${L_TEMP}

  FileOpen  ${L_ERRORLOG} "$G_USERDIR\${L_UNDOFILE}.errors.txt" a
  FileSeek  ${L_ERRORLOG} 0 END
  FileWrite ${L_ERRORLOG} "Time  : ${L_TEMP}\
      ${MB_NL}\
      Action: ${L_MESSAGE}\
      ${MB_NL}\
      User  : $G_WINUSERNAME\
      ${MB_NL}"

  ; If email program is running, ask the user to shut it down now (user may ignore our request)

  StrCmp ${L_MODEFLAG} "OUT" check_outlook
  StrCpy $G_PLS_FIELD_1 "Outlook Express Browser Class"
  StrCpy $G_PLS_FIELD_2 "$(PFI_LANG_MBCLIENT_EXP)"
  StrCpy ${L_TEMP} "$(PFI_LANG_UN_LOG_EXPRUN)"
  Goto check_if_running

check_outlook:
  StrCpy $G_PLS_FIELD_1 "rctrl_renwnd32"
  StrCpy $G_PLS_FIELD_2 "$(PFI_LANG_MBCLIENT_OUT)"
  StrCpy ${L_TEMP} "$(PFI_LANG_UN_LOG_OUTRUN)"

check_if_running:
  FindWindow ${L_INDEX} $G_PLS_FIELD_1
  IsWindow ${L_INDEX} 0 restore_ooe
  DetailPrint "${L_TEMP}"
  MessageBox MB_ABORTRETRYIGNORE|MB_ICONSTOP|MB_DEFBUTTON2 "$G_PLS_FIELD_2\
             ${MB_NL}${MB_NL}\
             $(PFI_LANG_MBCLIENT_STOP_4)\
             ${MB_NL}${MB_NL}\
             $(PFI_LANG_MBCLIENT_STOP_5)\
             ${MB_NL}${MB_NL}\
             $(PFI_LANG_MBCLIENT_STOP_6)"\
             IDABORT still_running IDRETRY check_if_running
  DetailPrint "$(PFI_LANG_UN_LOG_IGNORE)"

restore_ooe:

  ; Read the registry settings found in the 'undo' file and restore them if there are any.
  ; All are assumed to be in HKCU

  ClearErrors
  ReadINIStr ${L_INDEX} "$G_USERDIR\${L_UNDOFILE}" "History" "ListSize"
  IfErrors ooe_restore_corrupt
  Push ${L_INDEX}
  Call un.PFI_StrCheckDecimal
  Pop ${L_INDEX}
  StrCmp ${L_INDEX} "" ooe_restore_corrupt
  DetailPrint "${L_MESSAGE}"

  StrCpy ${L_MESSAGE} "success"

read_ooe_undo_entry:

  ; Check the 'undo' entry has all of the necessary values

  ReadINIStr ${L_TEMP} "$G_USERDIR\${L_UNDOFILE}" "Undo-${L_INDEX}" "Restored"
  StrCmp ${L_TEMP} "Yes" next_ooe_undo

  ReadINIStr ${L_INIV} "$G_USERDIR\${L_UNDOFILE}" "History" "IniV-${L_INDEX}"
  IntCmp 3 ${L_INIV} 0 0 skip_user_checks

  ReadINIStr ${L_USERNAME} "$G_USERDIR\${L_UNDOFILE}" "History" "User-${L_INDEX}"
  StrCmp ${L_USERNAME} "" skip_ooe_undo
  StrCmp ${L_USERNAME} $G_WINUSERNAME 0 foreign_ooe_undo

  ReadINIStr ${L_USERTYPE} "$G_USERDIR\${L_UNDOFILE}" "History" "Type-${L_INDEX}"
  StrCmp ${L_USERTYPE} "" skip_ooe_undo

skip_user_checks:
  ReadINIStr ${L_REG_KEY} "$G_USERDIR\${L_UNDOFILE}" "Undo-${L_INDEX}" "RegistryKey"
  StrCmp ${L_REG_KEY} "" skip_ooe_undo

  ReadINIStr ${L_POP_USER} "$G_USERDIR\${L_UNDOFILE}" "Undo-${L_INDEX}" "POP3UserName"
  StrCmp ${L_POP_USER} "" skip_ooe_undo

  ReadINIStr ${L_POP_SERVER} "$G_USERDIR\${L_UNDOFILE}" "Undo-${L_INDEX}" "POP3Server"
  StrCmp ${L_POP_SERVER} "" skip_ooe_undo

  IntCmp 3 ${L_INIV} 0 0 skip_port_check

  ReadINIStr ${L_POP_PORT} "$G_USERDIR\${L_UNDOFILE}" "Undo-${L_INDEX}" "POP3Port"
  StrCmp ${L_POP_PORT} "" skip_ooe_undo

skip_port_check:

  ; During installation we changed the 'POP3 Server' to '127.0.0.1'
  ; and if this value still exists, we assume it is safe to restore the original data
  ; (if the value differs, we do not restore the settings)

  ReadRegStr ${L_TEMP} HKCU ${L_REG_KEY} "POP3 Server"
  StrCmp ${L_TEMP} "127.0.0.1" 0 ooe_undo_not_valid

  WriteRegStr   HKCU ${L_REG_KEY} "POP3 User Name" ${L_POP_USER}
  WriteRegStr   HKCU ${L_REG_KEY} "POP3 Server" ${L_POP_SERVER}

  IntCmp 3 ${L_INIV} 0 0 skip_port_restore

  WriteRegDWORD HKCU ${L_REG_KEY} "POP3 Port" ${L_POP_PORT}

skip_port_restore:
  WriteINIStr "$G_USERDIR\${L_UNDOFILE}" "Undo-${L_INDEX}" "Restored" "Yes"

  DetailPrint "$(PFI_LANG_UN_LOG_RESTORED) POP3 User Name: ${L_POP_USER}"
  DetailPrint "$(PFI_LANG_UN_LOG_RESTORED) POP3 Server: ${L_POP_SERVER}"
  DetailPrint "$(PFI_LANG_UN_LOG_RESTORED) POP3 Port: ${L_POP_PORT}"

  Goto next_ooe_undo

foreign_ooe_undo:
  WriteINIStr "$G_USERDIR\${L_UNDOFILE}" "Undo-${L_INDEX}" "Restored" "No (different user)"
  FileWrite ${L_ERRORLOG} "Error : [Undo-${L_INDEX}] (different user)${MB_NL}"
  StrCpy ${L_MESSAGE} "foreign"
  DetailPrint "$(^Skipped)Undo-${L_INDEX}"
  Goto next_ooe_undo

ooe_undo_not_valid:
  WriteINIStr "$G_USERDIR\${L_UNDOFILE}" "Undo-${L_INDEX}" "Restored" "No (data no longer valid)"
  FileWrite ${L_ERRORLOG} "Alert : [Undo-${L_INDEX}] (data no longer valid)${MB_NL}"
  DetailPrint "$(^Skipped)Undo-${L_INDEX}"
  Goto next_ooe_undo

skip_ooe_undo:
  WriteINIStr "$G_USERDIR\${L_UNDOFILE}" "Undo-${L_INDEX}" "Restored" "No (undo data incomplete)"
  FileWrite ${L_ERRORLOG} "Error : [Undo-${L_INDEX}] (undo data incomplete)${MB_NL}"
  StrCpy ${L_MESSAGE} "corrupt"
  DetailPrint "$(^Skipped)Undo-${L_INDEX}"

next_ooe_undo:
  IntOp ${L_INDEX} ${L_INDEX} - 1
  IntCmp ${L_INDEX} 0 quit_restore quit_restore read_ooe_undo_entry

ooe_restore_corrupt:
  FileWrite ${L_ERRORLOG} "Error : [History] data corrupted${MB_NL}"
  StrCpy ${L_MESSAGE} "corrupt"
  DetailPrint "$(^Skipped)${L_UNDOFILE}"
  Goto quit_restore

nothing_to_restore:
  StrCpy ${L_MESSAGE} "nofile"
  Goto exit_now

bad_mode:
  StrCpy ${L_MESSAGE} "badmode"
  Goto exit_now

still_running:
  StrCpy ${L_MESSAGE} "running"
  StrCmp ${L_MODEFLAG} "OUT" outlook_running
  StrCpy ${L_TEMP} "failure ($(PFI_LANG_UN_LOG_EXPRUN))"
  Goto save_result

outlook_running:
  StrCpy ${L_TEMP} "failure ($(PFI_LANG_UN_LOG_OUTRUN))"
  Goto save_result

quit_restore:
  StrCpy ${L_TEMP} ${L_MESSAGE}
  StrCmp ${L_TEMP} "success" save_result
  StrCpy ${L_TEMP} "failure"

save_result:
  FileWrite ${L_ERRORLOG} "Result: ${L_TEMP}${MB_NL}${MB_NL}"
  FileClose ${L_ERRORLOG}
  DetailPrint "$(PFI_LANG_UN_LOG_CLOSED): ${L_UNDOFILE}"
  FlushINI "$G_USERDIR\${L_UNDOFILE}"

exit_now:
  Pop ${L_ERRORLOG}
  Pop ${L_USERTYPE}
  Pop ${L_USERNAME}
  Pop ${L_TEMP}
  Pop ${L_REG_KEY}
  Pop ${L_POP_USER}
  Pop ${L_POP_SERVER}
  Pop ${L_POP_PORT}
  Pop ${L_INIV}
  Pop ${L_INDEX}
  Pop ${L_UNDOFILE}
  Pop ${L_MODEFLAG}
  Exch ${L_MESSAGE}

  !undef L_INDEX
  !undef L_INIV
  !undef L_MESSAGE
  !undef L_POP_PORT
  !undef L_POP_SERVER
  !undef L_POP_USER
  !undef L_REG_KEY
  !undef L_TEMP
  !undef L_UNDOFILE
  !undef L_USERNAME
  !undef L_USERTYPE
  !undef L_ERRORLOG
  !undef L_MODEFLAG

FunctionEnd

#--------------------------------------------------------------------------
# Uninstaller Function: un.RestoreEudora
#
# Used to restore Eudora settings using data saved during installation
#
# Inputs:
#         (top of stack)          - text string to be shown in uninstaller window/log
#         (top of stack - 1)      - the name of the file holding the 'undo' data
#
# Outputs:
#         (top of stack)          - string with one of the following result codes:
#
#                                      "success"  (all settings restored)
#
#                                      "corrupt"  (the 'undo' data has been corrupted)
#
#                                      "foreign"  (some data belongs to another user
#                                                  and could not be restored)
#
#                                      "nofile"   (no restore data file found)
#
#                                      "running"  (aborted because Eudora is still running)
#
#  Usage:
#
#         Push "pfi-eudora.ini"
#         Push "Restoring Eudora settings..."
#         Call un.RestoreEudora
#         Pop $R9
#
#         (if $R9 is "foreign", some data was not restored as it doesn't belong to current user)
#--------------------------------------------------------------------------
# Notes:
#
# (1) Some early versions of the 'SetEudoraPage' function used a special entry in the
#     pfi-eudora.ini file when only the POPPort entry for the Dominant personality was
#     changed. Although this special entry is no longer used, un.RestoreEudora still supports
#     it (for backwards compatibility reasons). The special entry used this format:
#
#           [Undo-x]
#           Persona=*.*
#           POPAccount=*.*
#           POPServer=*.*
#           LoginName=*.*
#           POPPort=value to be restored
#
#     where 'Undo-x' is a normal 'Undo' sequence number
#--------------------------------------------------------------------------

Function un.RestoreEudora

  !define L_INDEX       $R9
  !define L_ININAME     $R8   ; full path to the Eudora INI file modified by the installer
  !define L_MESSAGE     $R7
  !define L_PERSONA     $R6   ; full section name for a Eudora personality
  !define L_POP_ACCOUNT $R5   ; L_POP_* used to restore Eudora settings
  !define L_POP_LOGIN   $R4
  !define L_POP_PORT    $R3
  !define L_POP_SERVER  $R2
  !define L_TEMP        $R1
  !define L_UNDOFILE    $R0
  !define L_USERNAME    $9    ; used to check validity of email client data 'undo' data
  !define L_USERTYPE    $8    ; used to check validity of email client data 'undo' data
  !define L_ERRORLOG    $7

  Exch ${L_MESSAGE}
  Exch
  Exch ${L_UNDOFILE}

  Push ${L_INDEX}
  Push ${L_ININAME}
  Push ${L_PERSONA}
  Push ${L_POP_ACCOUNT}
  Push ${L_POP_LOGIN}
  Push ${L_POP_PORT}
  Push ${L_POP_SERVER}
  Push ${L_TEMP}
  Push ${L_USERNAME}
  Push ${L_USERTYPE}
  Push ${L_ERRORLOG}

  IfFileExists "$G_USERDIR\${L_UNDOFILE}" 0 nothing_to_restore

  SetDetailsPrint textonly
  DetailPrint "${L_MESSAGE}"
  SetDetailsPrint listonly
  DetailPrint "$(PFI_LANG_UN_LOG_OPENED): ${L_UNDOFILE}"

  Call un.PFI_GetDateTimeStamp
  Pop ${L_TEMP}

  FileOpen  ${L_ERRORLOG} "$G_USERDIR\${L_UNDOFILE}.errors.txt" a
  FileSeek  ${L_ERRORLOG} 0 END
  FileWrite ${L_ERRORLOG} "Time  : ${L_TEMP}\
      ${MB_NL}\
      Action: ${L_MESSAGE}\
      ${MB_NL}\
      User  : $G_WINUSERNAME\
      ${MB_NL}"

  ; If Eudora is running, ask the user to shut it down now (user may ignore our request)

check_if_running:
  FindWindow ${L_TEMP} "EudoraMainWindow"
  IsWindow ${L_TEMP} 0 restore_eudora
  DetailPrint "$(PFI_LANG_UN_LOG_EUDRUN)"
  MessageBox MB_ABORTRETRYIGNORE|MB_ICONSTOP|MB_DEFBUTTON2 "$(PFI_LANG_MBCLIENT_EUD)\
             ${MB_NL}${MB_NL}\
             $(PFI_LANG_MBCLIENT_STOP_4)\
             ${MB_NL}${MB_NL}\
             $(PFI_LANG_MBCLIENT_STOP_5)\
             ${MB_NL}${MB_NL}\
             $(PFI_LANG_MBCLIENT_STOP_6)"\
             IDABORT still_running IDRETRY check_if_running
  DetailPrint "$(PFI_LANG_UN_LOG_IGNORE)"

restore_eudora:
  ClearErrors
  ReadINIStr ${L_INDEX} "$G_USERDIR\${L_UNDOFILE}" "History" "ListSize"
  IfErrors eudora_restore_corrupt
  Push ${L_INDEX}
  Call un.PFI_StrCheckDecimal
  Pop ${L_INDEX}
  StrCmp ${L_INDEX} "" eudora_restore_corrupt
  DetailPrint "${L_MESSAGE}"

  StrCpy ${L_MESSAGE} "success"

read_eudora_undo_entry:

  ; Check the 'undo' entry has all of the necessary values

  ReadINIStr ${L_TEMP} "$G_USERDIR\${L_UNDOFILE}" "Undo-${L_INDEX}" "Restored"
  StrCmp ${L_TEMP} "Yes" next_eudora_undo

  ReadINIStr ${L_ININAME} "$G_USERDIR\${L_UNDOFILE}" "History" "Path-${L_INDEX}"
  StrCmp ${L_ININAME} "" skip_eudora_undo
  IfFileExists ${L_ININAME} 0 skip_eudora_undo

  ; Very early versions of the Eudora 'undo' file do not have 'User-x' and 'Type-x' data
  ; so we ignore these two entries when processing such a file

  ReadINIStr ${L_TEMP} "$G_USERDIR\${L_UNDOFILE}" "History" "IniV-${L_INDEX}"
  StrCmp ${L_TEMP} "" basic_eudora_undo

  ReadINIStr ${L_USERNAME} "$G_USERDIR\${L_UNDOFILE}" "History" "User-${L_INDEX}"
  StrCmp ${L_USERNAME} "" skip_eudora_undo
  StrCmp ${L_USERNAME} $G_WINUSERNAME 0 foreign_eudora_undo

  ReadINIStr ${L_USERTYPE} "$G_USERDIR\${L_UNDOFILE}" "History" "Type-${L_INDEX}"
  StrCmp ${L_USERTYPE} "" skip_eudora_undo

basic_eudora_undo:
  ReadINIStr ${L_PERSONA} "$G_USERDIR\${L_UNDOFILE}" "Undo-${L_INDEX}" "Persona"
  StrCmp ${L_PERSONA} "" skip_eudora_undo

  ReadINIStr ${L_POP_ACCOUNT} "$G_USERDIR\${L_UNDOFILE}" "Undo-${L_INDEX}" "POPAccount"
  StrCmp ${L_POP_ACCOUNT} "" skip_eudora_undo

  ReadINIStr ${L_POP_SERVER} "$G_USERDIR\${L_UNDOFILE}" "Undo-${L_INDEX}" "POPServer"
  StrCmp ${L_POP_SERVER} "" skip_eudora_undo

  ReadINIStr ${L_POP_LOGIN} "$G_USERDIR\${L_UNDOFILE}" "Undo-${L_INDEX}" "LoginName"
  StrCmp ${L_POP_LOGIN} "" skip_eudora_undo

  ReadINIStr ${L_POP_PORT} "$G_USERDIR\${L_UNDOFILE}" "Undo-${L_INDEX}" "POPPort"
  StrCmp ${L_POP_PORT} "" skip_eudora_undo

  ClearErrors
  ReadINIStr ${L_TEMP} "${L_ININAME}" "${L_PERSONA}" "POPAccount"
  IfErrors eudora_undo_not_valid

  StrCmp ${L_POP_ACCOUNT} "*.*" restore_port_only

  WriteINIStr "${L_ININAME}" "${L_PERSONA}" "POPAccount" "${L_POP_ACCOUNT}"
  WriteINIStr "${L_ININAME}" "${L_PERSONA}" "POPServer" "${L_POP_SERVER}"
  WriteINIStr "${L_ININAME}" "${L_PERSONA}" "LoginName" "${L_POP_LOGIN}"

restore_port_only:

  ; Some early versions of the undo data use "*.*" to change the Dominant personality's port

  StrCmp ${L_PERSONA} "*.*" 0 restore_port
  StrCpy ${L_PERSONA} "Settings"

restore_port:
  StrCmp ${L_POP_PORT} "Dominant" remove_port_setting
  StrCmp ${L_POP_PORT} "Default"  remove_port_setting
  WriteINIStr "${L_ININAME}" "${L_PERSONA}" "POPPort" "${L_POP_PORT}"
  Goto restored

remove_port_setting:
  DeleteINIStr "${L_ININAME}" "${L_PERSONA}" "POPPort"

restored:
  WriteINIStr "$G_USERDIR\${L_UNDOFILE}" "Undo-${L_INDEX}" "Restored" "Yes"

  StrCmp ${L_POP_SERVER} "*.*" log_port_restore
  DetailPrint "$(PFI_LANG_UN_LOG_RESTORED) ${L_PERSONA} 'POPServer': ${L_POP_SERVER}"
  DetailPrint "$(PFI_LANG_UN_LOG_RESTORED) ${L_PERSONA} 'LoginName': ${L_POP_LOGIN}"

log_port_restore:
  DetailPrint "$(PFI_LANG_UN_LOG_RESTORED) ${L_PERSONA} 'POPPort': ${L_POP_PORT}"

  Goto next_eudora_undo

foreign_eudora_undo:
  WriteINIStr "$G_USERDIR\${L_UNDOFILE}" "Undo-${L_INDEX}" "Restored" "No (different user)"
  FileWrite ${L_ERRORLOG} "Error : [Undo-${L_INDEX}] (different user)${MB_NL}"
  StrCpy ${L_MESSAGE} "foreign"
  DetailPrint "$(^Skipped)Undo-${L_INDEX}"
  Goto next_eudora_undo

eudora_undo_not_valid:
  WriteINIStr "$G_USERDIR\${L_UNDOFILE}" "Undo-${L_INDEX}" "Restored" "No (data no longer valid)"
  FileWrite ${L_ERRORLOG} "Alert : [Undo-${L_INDEX}] (data no longer valid)${MB_NL}"
  DetailPrint "$(^Skipped)Undo-${L_INDEX}"
  Goto next_eudora_undo

skip_eudora_undo:
  WriteINIStr "$G_USERDIR\${L_UNDOFILE}" "Undo-${L_INDEX}" "Restored" "No (undo data incomplete)"
  FileWrite ${L_ERRORLOG} "Error : [Undo-${L_INDEX}] (undo data incomplete)${MB_NL}"
  StrCpy ${L_MESSAGE} "corrupt"
  DetailPrint "$(^Skipped)Undo-${L_INDEX}"

next_eudora_undo:
  IntOp ${L_INDEX} ${L_INDEX} - 1
  IntCmp ${L_INDEX} 0 quit_restore quit_restore read_eudora_undo_entry

eudora_restore_corrupt:
  FileWrite ${L_ERRORLOG} "Error : [History] data corrupted${MB_NL}"
  StrCpy ${L_MESSAGE} "corrupt"
  DetailPrint "$(^Skipped)${L_UNDOFILE}"
  Goto quit_restore

nothing_to_restore:
  StrCpy ${L_MESSAGE} "nofile"
  Goto exit_now

still_running:
  StrCpy ${L_MESSAGE} "running"
  StrCpy ${L_TEMP} "failure ($(PFI_LANG_UN_LOG_EUDRUN))"
  Goto save_result

quit_restore:
  StrCpy ${L_TEMP} ${L_MESSAGE}
  StrCmp ${L_TEMP} "success" save_result
  StrCpy ${L_TEMP} "failure"

save_result:
  FileWrite ${L_ERRORLOG} "Result: ${L_TEMP}${MB_NL}${MB_NL}"
  FileClose ${L_ERRORLOG}
  DetailPrint "$(PFI_LANG_UN_LOG_CLOSED): ${L_UNDOFILE}"
  FlushINI "$G_USERDIR\${L_UNDOFILE}"

exit_now:
  Pop ${L_ERRORLOG}
  Pop ${L_USERTYPE}
  Pop ${L_USERNAME}
  Pop ${L_TEMP}
  Pop ${L_POP_SERVER}
  Pop ${L_POP_PORT}
  Pop ${L_POP_LOGIN}
  Pop ${L_POP_ACCOUNT}
  Pop ${L_PERSONA}
  Pop ${L_ININAME}
  Pop ${L_INDEX}

  Pop ${L_UNDOFILE}
  Exch ${L_MESSAGE}

  !undef L_INDEX
  !undef L_ININAME
  !undef L_PERSONA
  !undef L_POP_ACCOUNT
  !undef L_POP_LOGIN
  !undef L_POP_PORT
  !undef L_POP_SERVER
  !undef L_TEMP
  !undef L_UNDOFILE
  !undef L_USERNAME
  !undef L_USERTYPE
  !undef L_ERRORLOG

FunctionEnd

#--------------------------------------------------------------------------
# End of 'adduser-Uninstall.nsh'
#--------------------------------------------------------------------------
