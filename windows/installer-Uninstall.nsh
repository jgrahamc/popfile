#--------------------------------------------------------------------------
#
# installer-Uninstall.nsh --- This 'include' file contains the 'Uninstall' part of the main
#                             NSIS 'installer.nsi' script used to create the POPFile installer.
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
#  The 'installer.nsi' script file contains the following code:
#
#     #==========================================================================
#     #==========================================================================
#     # The 'Uninstall' part of the script is in a separate file
#     #==========================================================================
#     #==========================================================================
#
#       !include "installer-Uninstall.nsh"
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

  ; Retrieve the language used when POPFile was installed, and use it for the uninstaller
  ; (if the language entry is not found in the registry, a 'language selection' dialog is shown)

  !insertmacro MUI_UNGETLANGUAGE

  StrCpy $G_ROOTDIR   "$INSTDIR"
  StrCpy $G_MPLIBDIR  "$INSTDIR\lib"

  ; Starting with 0.21.0 the registry is used to store the location of the 'User Data'
  ; (if setup.exe or adduser.exe was used to create/update the 'User Data' for this user)

  ReadRegStr $G_USERDIR HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "UserDir_LFN"
  StrCmp $G_USERDIR "" 0 got_user_path

  ; Pre-release versions of the 0.21.0 installer used a sub-folder for the default user data

  StrCpy $G_USERDIR "$INSTDIR\user"

  ; If we are uninstalling an upgraded installation, the default user data may be in $INSTDIR
  ; instead of $INSTDIR\user

  IfFileExists "$G_USERDIR\popfile.cfg" got_user_path
  StrCpy $G_USERDIR   "$INSTDIR"

got_user_path:

  ; Email settings are stored on a 'per user' basis therefore we need to know which user is
  ; running the uninstaller (e.g. so we can check ownership of any local 'User Data' we find)

	ClearErrors
	UserInfo::GetName
	IfErrors 0 got_name

  ; Assume Win9x system, so user has 'Admin' rights
  ; (UserInfo works on Win98SE so perhaps it is only Win95 that fails ?)

  StrCpy $G_WINUSERNAME "UnknownUser"
  StrCpy $G_WINUSERTYPE "Admin"
  Goto start_uninstall

got_name:
	Pop $G_WINUSERNAME
  StrCmp $G_WINUSERNAME "" 0 get_usertype
  StrCpy $G_WINUSERNAME "UnknownUser"

get_usertype:
  UserInfo::GetAccountType
	Pop $G_WINUSERTYPE
  StrCmp $G_WINUSERTYPE "Admin" start_uninstall
  StrCmp $G_WINUSERTYPE "Power" start_uninstall
  StrCmp $G_WINUSERTYPE "User" start_uninstall
  StrCmp $G_WINUSERTYPE "Guest" start_uninstall
  StrCpy $G_WINUSERTYPE "Unknown"

start_uninstall:
FunctionEnd

#--------------------------------------------------------------------------
# Uninstaller Sections (this build uses all of these and executes them in the order shown)
#
#  (1) un.Uninstall Begin    - requests confirmation if appropriate
#  (2) un.Local User Data    - looks for and removes 'User Data' from the PROGRAM folder
#  (3) un.Shutdown POPFile   - shutdown POPFile if necessary (to avoid the need to reboot)
#  (4) un.Start Menu Entries - remove StartUp shortcuts and Start Menu entries
#  (5) un.POPFile Core       - uninstall POPFile PROGRAM files
#  (6) un.Skins              - uninstall POPFile skins
#  (7) un.Languages          - uninstall POPFile UI languages
#  (8) un.QuickStart Guide   - uninstall POPFile English QuickStart Guide
#  (9) un.Kakasi             - uninstall Kakasi package and remove its environment variables
# (10) un.Minimal Perl       - uninstall minimal Perl, including all of the optional modules
# (11) un.Registry Entries   - remove 'Add/Remove Program' data and other registry entries
# (12) un.Uninstall End      - remove remaining files/folders (if it is safe to do so)
#
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.Uninstall Begin' (the first section in the uninstaller)
#--------------------------------------------------------------------------

Section "un.Uninstall Begin" UnSecBegin

  !define L_TEMP        $R9

  Push ${L_TEMP}

  ReadINIStr ${L_TEMP} "$G_USERDIR\install.ini" "Settings" "Owner"
  StrCmp ${L_TEMP} "" section_exit
  StrCmp ${L_TEMP} $G_WINUSERNAME section_exit

  MessageBox MB_YESNO|MB_ICONSTOP|MB_DEFBUTTON2 \
      "$(PFI_LANG_UN_MBDIFFUSER_1) ('${L_TEMP}') !\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_UN_MBNOTFOUND_2)" IDYES section_exit
  Abort "$(PFI_LANG_UN_ABORT_1)"

section_exit:
  Pop ${L_TEMP}

  !undef L_TEMP

SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.Local User Data'
#
# There may be 'User Data' in the same folder as the PROGRAM files (especially if this is
# an upgraded installation) so we must run the 'User Data' uninstaller before we uninstall
# POPFile (to restore any email settings changed by the installer).
#--------------------------------------------------------------------------

Section "un.Local User Data" UnSecUserData

  !define L_RESULT    $R9

  Push ${L_RESULT}

  IfFileExists "$G_ROOTDIR\popfile.pl" look_for_uninstalluser
  IfFileExists "$G_ROOTDIR\popfile.exe" look_for_uninstalluser
    MessageBox MB_YESNO|MB_ICONSTOP|MB_DEFBUTTON2 \
        "$(PFI_LANG_UN_MBNOTFOUND_1) '$G_ROOTDIR'.\
        ${MB_NL}${MB_NL}\
        $(PFI_LANG_UN_MBNOTFOUND_2)" IDYES look_for_uninstalluser
    Abort "$(PFI_LANG_UN_ABORT_1)"

look_for_uninstalluser:
  IfFileExists "$G_ROOTDIR\uninstalluser.exe" 0 section_exit

  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

  ; Uninstall the 'User Data' in the PROGRAM folder before uninstalling the PROGRAM files
  ; (note that running 'uninstalluser.exe' with the '_?=dir' option means it will be unable
  ; to delete itself because the program is NOT automatically relocated to the TEMP folder)

  HideWindow
  ExecWait '"$G_ROOTDIR\uninstalluser.exe" _?=$G_ROOTDIR' ${L_RESULT}
  BringToFront

  ; If the 'User Data' uninstaller did not return the normal "success" code (e.g. because user
  ; cancelled the 'User Data' uninstall) then we must retain the user data and uninstalluser.exe

  StrCmp ${L_RESULT} "0" 0 section_exit

  ; If any email settings have NOT been restored and the user wishes to try again later,
  ; the relevant INI file will still exist and we should not remove it or uninstalluser.exe

  IfFileExists "$G_ROOTDIR\pfi-outexpress.ini" section_exit
  IfFileExists "$G_ROOTDIR\pfi-outlook.ini" section_exit
  IfFileExists "$G_ROOTDIR\pfi-eudora.ini" section_exit
  Delete "$G_ROOTDIR\uninstalluser.exe"

section_exit:
  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

  Pop ${L_RESULT}

  !undef L_RESULT

SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.Shutdown POPFile'
#--------------------------------------------------------------------------

Section "un.Shutdown POPFile" UnSecShutdown

  !define L_CFG         $R9   ; used as file handle
  !define L_EXE         $R8   ; full path of the EXE to be monitored
  !define L_LNE         $R7   ; a line from popfile.cfg
  !define L_TEMP        $R6
  !define L_TEXTEND     $R5   ; used to ensure correct handling of lines longer than 1023 chars

  Push ${L_CFG}
  Push ${L_EXE}
  Push ${L_LNE}
  Push ${L_TEMP}
  Push ${L_TEXTEND}

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROG_SHUTDOWN)"
  SetDetailsPrint listonly

  ; Starting with POPfile 0.21.0 an experimental version of 'popfile-service.exe' was included
  ; to allow POPFile to be run as a Windows service.

  Push "POPFile"
  Call un.PFI_ServiceRunning
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "true" manual_shutdown

  ; If the POPFile we are to uninstall is still running, one of the EXE files will be 'locked'

  Push $G_ROOTDIR
  Call un.PFI_FindLockedPFE
  Pop ${L_EXE}
  StrCmp ${L_EXE} "" check_pfi_utils

  ; The program files we are about to remove are in use so we need to shut POPFile down

  IfFileExists "$G_USERDIR\popfile.cfg" 0 manual_shutdown

  ; Use the UI port setting in the configuration file to shutdown POPFile

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
  StrCmp ${L_TEMP} "success" check_pfi_utils

manual_shutdown:
  StrCpy $G_PLS_FIELD_1 "POPFile"
  DetailPrint "Unable to shutdown $G_PLS_FIELD_1 automatically - manual intervention requested"
  MessageBox MB_OK|MB_ICONEXCLAMATION|MB_TOPMOST "$(PFI_LANG_MBMANSHUT_1)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_MBMANSHUT_2)\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_MBMANSHUT_3)"

  ; Assume user has managed to shutdown POPFile

check_pfi_utils:
  Push $G_ROOTDIR
  Call un.PFI_RequestPFIUtilsShutdown

  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

  Pop ${L_TEXTEND}
  Pop ${L_TEMP}
  Pop ${L_LNE}
  Pop ${L_EXE}
  Pop ${L_CFG}

  !undef L_CFG
  !undef L_EXE
  !undef L_LNE
  !undef L_TEMP
  !undef L_TEXTEND

SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.Start Menu Entries'
#--------------------------------------------------------------------------

Section "un.Start Menu Entries" UnSecStartMenu

  !define L_TEMP  $R9

  Push ${L_TEMP}

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROG_SHORT)"
  SetDetailsPrint listonly

  SetShellVarContext all
  StrCmp $G_WINUSERTYPE "Admin" menucleanup
  SetShellVarContext current

menucleanup:
  IfFileExists "$SMPROGRAMS\${C_PFI_PRODUCT}\QuickStart Guide.url" 0 delete_menu_entries
  ReadINIStr ${L_TEMP} "$SMPROGRAMS\${C_PFI_PRODUCT}\QuickStart Guide.url" \
      "InternetShortcut" "URL"
  StrCmp ${L_TEMP} "file://$G_ROOTDIR/manual/en/manual.html" delete_menu_entries exit

delete_menu_entries:
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\POPFile Home Page.url"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\POPFile Support (Wiki).url"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\PFI Diagnostic utility (simple).lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\PFI Diagnostic utility (full).lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\Create 'User Data' shortcut.lnk"
  RMDir "$SMPROGRAMS\${C_PFI_PRODUCT}\Support"

  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Release Notes.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Run POPFile.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Run POPFile in background.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Shutdown POPFile silently.lnk"

  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\FAQ.url"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\QuickStart Guide.url"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\POPFile User Interface.url"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Shutdown POPFile.url"

  Delete "$SMSTARTUP\Run POPFile in background.lnk"
  Delete "$SMSTARTUP\Run POPFile.lnk"

  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Uninstall POPFile.lnk"
  RMDir "$SMPROGRAMS\${C_PFI_PRODUCT}"

exit:

  ; Restore the default NSIS context

  SetShellVarContext current

  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

  Pop ${L_TEMP}

  !undef L_TEMP

SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.POPFile Core'
#
# Files are explicitly deleted (instead of just using wildcards or 'RMDir /r' commands)
# in an attempt to avoid unexpectedly deleting any files created by the user after installation.
# Current commands only cover most recent versions of POPFile - need to add commands to cover
# more of the early versions of POPFile.
#--------------------------------------------------------------------------

Section "un.POPFile Core" UnSecCore

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROG_CORE)"
  SetDetailsPrint listonly

  Delete "$G_ROOTDIR\wrapper.exe"
  Delete "$G_ROOTDIR\wrapperf.exe"
  Delete "$G_ROOTDIR\wrapperb.exe"
  Delete "$G_ROOTDIR\wrapper.ini"

  Delete "$G_ROOTDIR\runpopfile.exe"
  Delete "$G_ROOTDIR\adduser.exe"
  Delete "$G_ROOTDIR\sqlite.exe"
  Delete "$G_ROOTDIR\runsqlite.exe"
  Delete "$G_ROOTDIR\pfidiag.exe"
  Delete "$G_ROOTDIR\msgcapture.exe"
  Delete "$G_ROOTDIR\pfimsgcapture.exe"

  IfFileExists "$G_ROOTDIR\pfidiag.exe" try_again
  IfFileExists "$G_ROOTDIR\msgcapture.exe" try_again
  IfFileExists "$G_ROOTDIR\msgcapture.exe" 0 continue

try_again:
  Sleep 1000
  Delete "$G_ROOTDIR\pfidiag.exe"
  Delete "$G_ROOTDIR\msgcapture.exe"
  Delete "$G_ROOTDIR\pfimsgcapture.exe"

continue:
  Delete "$G_ROOTDIR\otto.png"
  Delete "$G_ROOTDIR\*.gif"
  Delete "$G_ROOTDIR\*.change"
  Delete "$G_ROOTDIR\*.change.txt"

  Delete "$G_ROOTDIR\pfi-data.ini"

  Delete "$G_ROOTDIR\popfile.pl"
  Delete "$G_ROOTDIR\popfile-check-setup.pl"
  Delete "$G_ROOTDIR\popfile.pck"
  Delete "$G_ROOTDIR\*.pm"

  Delete "$G_ROOTDIR\bayes.pl"
  Delete "$G_ROOTDIR\insert.pl"
  Delete "$G_ROOTDIR\pipe.pl"
  Delete "$G_ROOTDIR\favicon.ico"
  Delete "$G_ROOTDIR\popfile.exe"
  Delete "$G_ROOTDIR\popfilef.exe"
  Delete "$G_ROOTDIR\popfileb.exe"
  Delete "$G_ROOTDIR\popfileif.exe"
  Delete "$G_ROOTDIR\popfileib.exe"
  Delete "$G_ROOTDIR\popfile-service.exe"
  Delete "$G_ROOTDIR\stop_pf.exe"
  Delete "$G_ROOTDIR\license"
  Delete "$G_ROOTDIR\pfi-stopwords.default"

  Delete "$G_ROOTDIR\Classifier\*.pm"
  Delete "$G_ROOTDIR\Classifier\popfile.sql"
  RMDir "$G_ROOTDIR\Classifier"

  Delete "$G_ROOTDIR\Platform\*.pm"
  Delete "$G_ROOTDIR\Platform\*.dll"
  RMDir "$G_ROOTDIR\Platform"

  Delete "$G_ROOTDIR\POPFile\*.pm"
  Delete "$G_ROOTDIR\POPFile\popfile_version"
  RMDir "$G_ROOTDIR\POPFile"

  Delete "$G_ROOTDIR\Proxy\*.pm"
  RMDir "$G_ROOTDIR\Proxy"

  Delete "$G_ROOTDIR\Server\*.pm"
  RMDir "$G_ROOTDIR\Server"

  Delete "$G_ROOTDIR\Services\*.pm"
  RMDir "$G_ROOTDIR\Services"

  Delete "$G_ROOTDIR\UI\*.pm"
  RMDir "$G_ROOTDIR\UI"

  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.Skins'
#--------------------------------------------------------------------------

Section "un.Skins" UnSecSkins

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROG_SKINS)"
  SetDetailsPrint listonly

  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\blue"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\coolblue"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\coolbrown"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\coolgreen"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\coolorange"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\coolyellow"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\default"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\glassblue"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\green"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\klingon"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\lavish"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\lrclaptop"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\oceanblue"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\orange"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\orangecream"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\osx"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\outlook"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\prjbluegrey"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\prjsteelbeach"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\simplyblue"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\sleet"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\sleet-rtl"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\smalldefault"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\smallgrey"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\strawberryrose"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\tinydefault"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\tinygrey"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\white"
  !insertmacro PFI_DeleteSkin "$G_ROOTDIR\skins\windows"

  RMDir "$G_ROOTDIR\skins"

  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.Languages'
#--------------------------------------------------------------------------

Section "un.Languages" UnSecLangs

  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

  Delete "$G_ROOTDIR\languages\*.msg"
  RMDir "$G_ROOTDIR\languages"

  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.QuickStart Guide'
#--------------------------------------------------------------------------

Section "un.QuickStart Guide" UnSecQuickGuide

  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

  Delete "$G_ROOTDIR\manual\en\*.html"
  RMDir "$G_ROOTDIR\manual\en"
  Delete "$G_ROOTDIR\manual\*.gif"
  RMDir "$G_ROOTDIR\manual"

  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.Kakasi'
#--------------------------------------------------------------------------

Section "un.Kakasi" UnSecKakasi

  !define L_TEMP        $R9

  Push ${L_TEMP}

  IfFileExists "$INSTDIR\kakasi\*.*" 0 section_exit

  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

  RMDir /r "$INSTDIR\kakasi"

  ;Delete Environment Variables

  Push "KANWADICTPATH"
  Call un.PFI_DeleteEnvStr
  Push "ITAIJIDICTPATH"
  Call un.PFI_DeleteEnvStr

  ; If the 'all users' environment variables refer to this installation, remove them too

  ReadEnvStr ${L_TEMP} "KANWADICTPATH"
  Push ${L_TEMP}
  Push $INSTDIR
  Call un.PFI_StrStr
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" section_exit
  Push "KANWADICTPATH"
  Call un.PFI_DeleteEnvStrNTAU
  Push "ITAIJIDICTPATH"
  Call un.PFI_DeleteEnvStrNTAU

section_exit:
  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

  Pop ${L_TEMP}

  !undef L_TEMP

SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.Minimal Perl'
#--------------------------------------------------------------------------

Section "un.Minimal Perl" UnSecMinPerl

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_UN_PROG_PERL)"
  SetDetailsPrint listonly

  Delete "$G_ROOTDIR\perl*.dll"
  Delete "$G_ROOTDIR\perl.exe"
  Delete "$G_ROOTDIR\wperl.exe"

  ; Win95 displays an error message if an attempt is made to delete non-existent folders
  ; (so we check before removing optional Perl components which may not have been installed)

  IfFileExists "$G_MPLIBDIR\HTTP\*.*" 0 skip_XMLRPC_support
  RMDir /r "$G_MPLIBDIR\HTTP"
  RMDir /r "$G_MPLIBDIR\LWP"
  RMDir /r "$G_MPLIBDIR\Net"
  RMDir /r "$G_MPLIBDIR\SOAP"
  RMDir /r "$G_MPLIBDIR\URI"
  RMDir /r "$G_MPLIBDIR\XML"
  RMDir /r "$G_MPLIBDIR\XMLRPC"

skip_XMLRPC_support:
  RMDir /r "$G_MPLIBDIR\auto"
  RMDir /r "$G_MPLIBDIR\Carp"
  RMDir /r "$G_MPLIBDIR\Class"
  RMDir /r "$G_MPLIBDIR\Crypt"
  RMDir /r "$G_MPLIBDIR\Data"
  RMDir /r "$G_MPLIBDIR\Date"
  RMDir /r "$G_MPLIBDIR\DBD"
  RMDir /r "$G_MPLIBDIR\Digest"
  IfFileExists "$G_MPLIBDIR\Encode\*.*" 0 skip_Encode
  RMDir /r "$G_MPLIBDIR\Encode"

skip_Encode:
  RMDir /r "$G_MPLIBDIR\Exporter"
  RMDir /r "$G_MPLIBDIR\File"
  RMDir /r "$G_MPLIBDIR\Getopt"
  RMDir /r "$G_MPLIBDIR\HTML"
  RMDir /r "$G_MPLIBDIR\IO"
  RMDir /r "$G_MPLIBDIR\Math"
  RMDir /r "$G_MPLIBDIR\MIME"
  RMDir /r "$G_MPLIBDIR\String"
  RMDir /r "$G_MPLIBDIR\Sys"
  RMDir /r "$G_MPLIBDIR\Text"
  RMDir /r "$G_MPLIBDIR\Time"
  RMDir /r "$G_MPLIBDIR\warnings"
  IfFileExists "$G_MPLIBDIR\Win32\*.*" 0 skip_Win32
  RMDir /r "$G_MPLIBDIR\Win32"

skip_Win32:
  Delete "$G_MPLIBDIR\*.pm"
  RMDIR "$G_MPLIBDIR"

  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.Registry Entries'
#--------------------------------------------------------------------------

Section "un.Registry Entries" UnSecRegistry

  !define L_REGDATA $R9

  Push ${L_REGDATA}

  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

  ; Only remove registry data if it matches what we are uninstalling

  StrCmp $G_WINUSERTYPE "Admin" check_HKLM_data

  ; Uninstalluser.exe deletes all HKCU registry data except for the 'Add/Remove Programs' entry

  ReadRegStr ${L_REGDATA} HKCU \
      "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" "UninstallString"
  StrCmp ${L_REGDATA} "$G_ROOTDIR\uninstall.exe" 0 section_exit
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}"
  Goto section_exit

check_HKLM_data:
  ReadRegStr ${L_REGDATA} HKLM \
      "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" "UninstallString"
  StrCmp ${L_REGDATA} "$G_ROOTDIR\uninstall.exe" 0 other_reg_data
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}"

other_reg_data:
  ReadRegStr ${L_REGDATA} HKLM "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_LFN"
  StrCmp ${L_REGDATA} $G_ROOTDIR 0 section_exit
  DeleteRegKey HKLM "Software\POPFile Project\${C_PFI_PRODUCT}\MRI"
  DeleteRegKey /ifempty HKLM "Software\POPFile Project\${C_PFI_PRODUCT}"
  DeleteRegKey /ifempty HKLM "Software\POPFile Project"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\stop_pf.exe"

section_exit:
  SetDetailsPrint textonly
  DetailPrint " "
  SetDetailsPrint listonly

  Pop ${L_REGDATA}

  !undef L_REGDATA
SectionEnd

#--------------------------------------------------------------------------
# Uninstaller Section: 'un.Uninstall End' (this is the final section in the uninstaller)
#
# Used to terminate the uninstaller - offers to remove any files/folders left behind.
# If any 'User Data' is left in the PROGRAM folder then we preserve it to allow the
# user to make another attempt at restoring the email settings.
#--------------------------------------------------------------------------

Section "un.Uninstall End" UnSecEnd

  Delete "$G_ROOTDIR\install.log.*"
  Delete "$G_ROOTDIR\install.log"
  Delete "$G_ROOTDIR\Uninstall.exe"
  RMDir "$G_ROOTDIR"

  ; if the installation folder ($G_ROOTDIR) was removed, skip these next ones

  IfFileExists "$G_ROOTDIR\*.*" 0 exit

  ; If 'User Data' uninstaller still exists, we cannot offer to remove the remaining files
  ; (some email settings have not been restored and the user wants to try again later or
  ; the user decided not to uninstall the 'User Data' at the moment)

  IfFileExists "$G_ROOTDIR\uninstalluser.exe" exit

  MessageBox MB_YESNO|MB_ICONQUESTION "$(PFI_LANG_UN_MBREMDIR_1)" IDNO exit
  DetailPrint "$(PFI_LANG_UN_LOG_DELROOTDIR)"
  Delete "$G_ROOTDIR\*.*"
  RMDir /r $G_ROOTDIR
  IfFileExists "$G_ROOTDIR\*.*" 0 exit
  DetailPrint "$(PFI_LANG_UN_LOG_DELROOTERR)"
  StrCpy $G_PLS_FIELD_1 $G_ROOTDIR
  MessageBox MB_OK|MB_ICONEXCLAMATION "$(PFI_LANG_UN_MBREMERR_A)"

exit:
  SetDetailsPrint both
SectionEnd

#--------------------------------------------------------------------------
# End of 'installer-Uninstall.nsh'
#--------------------------------------------------------------------------
