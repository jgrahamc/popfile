#--------------------------------------------------------------------------
#
# installer-SecPOPFile-body.nsh --- This 'include' file contains the body of the "POPFile"
#                                   Section of the main 'installer.nsi' NSIS script used to
#                                   create the Windows installer for POPFile.
#
#                                   The non-library functions used in this file are contained
#                                   in a separate file (see 'installer-SecPOPFile-func.nsh')
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
#         Section "POPFile" SecPOPFile
#           !include "installer-SecPOPFile-body.nsh"
#         SectionEnd
#
#         ; Functions used only by "installer-SecPOPFile-body.nsh"
#
#         !include "installer-SecPOPFile-func.nsh"
#--------------------------------------------------------------------------
# Processing performed:
#
# (a) If upgrading, shutdown existing version and rearrange minimal Perl files
# (b) Create registry entries (HKLM and/or HKCU) for POPFile program files
# (c) Install POPFile core program files and release notes
# (d) Write the uninstaller program and create/update the Start Menu shortcuts
# (e) Create 'Add/Remove Program' entry
#--------------------------------------------------------------------------

; Section "POPFile" SecPOPFile

  !insertmacro SECTIONLOG_ENTER "POPFile"

  ; Make this section mandatory (i.e. it is always installed)

  SectionIn RO

  !define L_RESULT        $R9
  !define L_TEMP          $R8

  Push ${L_RESULT}
  Push ${L_TEMP}

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_UPGRADE) $(PFI_LANG_TAKE_A_FEW_SECONDS)"
  SetDetailsPrint listonly

  ; Before POPFile 0.21.0, POPFile and the minimal Perl shared the same folder structure
  ; and there was only one set of user data (stored in the same folder as POPFile).

  ; Phase 1 of the multi-user support introduced in 0.21.0 required some slight changes
  ; to the folder structure (to permit POPFile to be run from any folder after setting the
  ; POPFILE_ROOT and POPFILE_USER environment variables to appropriate values).

  ; The folder arrangement used for this build:
  ;
  ; (a) $INSTDIR         -  main POPFile installation folder, holds popfile.pl and several
  ;                         other *.pl scripts, runpopfile.exe, popfile*.exe plus three of the
  ;                         minimal Perl files (perl.exe, wperl.exe and perl58.dll)
  ;
  ; (b) $INSTDIR\kakasi  -  holds the Kakasi package used to process Japanese email
  ;                         (only installed when Japanese support is required)
  ;
  ; (c) $INSTDIR\lib     -  minimal Perl installation (except for the three files stored
  ;                         in the $INSTDIR folder to avoid runtime problems)
  ;
  ; (d) $INSTDIR\*       -  the remaining POPFile folders (Classifier, languages, skins, etc)
  ;
  ; For this build, each user is expected to have separate user data folders. By default each
  ; user data folder will contain popfile.cfg, stopwords, stopwords.default, popfile.db,
  ; the messages folder, etc. The 'Add POPFile User' wizard (adduser.exe) is responsible for
  ; creating/updating these user data folders and for handling conversion of existing flat file
  ; or BerkeleyDB corpus files to the new SQL database format.
  ;
  ; For increased flexibility, some global user variables are used in addition to $INSTDIR
  ; (this makes it easier to change the folder structure used by the installer).

  ; $G_ROOTDIR is initialised by 'CheckExistingProgDir' (the DIRECTORY page's "leave" function)

  StrCpy $G_MPLIBDIR  "$G_ROOTDIR\lib"

  IfFileExists "$G_ROOTDIR\*.*" rootdir_exists
  ClearErrors
  CreateDirectory "$G_ROOTDIR"
  IfErrors 0 rootdir_exists
  SetDetailsPrint both
  DetailPrint "Fatal error: unable to create folder for the POPFile program files"
  SetDetailsPrint listonly
  MessageBox MB_OK|MB_ICONSTOP|MB_TOPMOST "Error: Unable to create folder for the POPFile program files\
      ${MB_NL}${MB_NL}\
      ($G_ROOTDIR)"
  Abort

rootdir_exists:

  ; Starting with POPFile 0.22.0 the system tray icon uses 'localhost' instead of '127.0.0.1'
  ; to display the User Interface (and the installer has been updated to follow suit), so we
  ; need to ensure Win9x systems have a suitable 'hosts' file

  Call PFI_IsNT
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "1" continue
  Call CheckHostsFile

continue:

  ; If we are installing over a previous version, ensure that version is not running

  Call MakeRootDirSafe

  ; Starting with 0.21.0, a new structure is used for the minimal Perl (to enable POPFile to
  ; be started from any folder, once POPFILE_ROOT and POPFILE_USER have been initialized)

  Call MinPerlRestructure

  ; Now that the HTML for the UI is no longer embedded in the Perl code, a new skin system is
  ; used so we attempt to convert the existing skins to work with the new system

  Call SkinsRestructure

  StrCmp $G_WINUSERTYPE "Admin" 0 current_user_root
  WriteRegStr HKLM "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "Installer Language" "$LANGUAGE"
  WriteRegStr HKLM "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "POPFile Major Version" "${C_POPFILE_MAJOR_VERSION}"
  WriteRegStr HKLM "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "POPFile Minor Version" "${C_POPFILE_MINOR_VERSION}"
  WriteRegStr HKLM "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "POPFile Revision" "${C_POPFILE_REVISION}"
  WriteRegStr HKLM "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "POPFile RevStatus" "${C_POPFILE_RC}"
  WriteRegStr HKLM "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "InstallPath" "$G_ROOTDIR"
  WriteRegStr HKLM "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "Author" "setup.exe"
  WriteRegStr HKLM "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_LFN" "$G_ROOTDIR"
  StrCmp $G_SFN_DISABLED "0" find_HKLM_root_sfn
  StrCpy ${L_TEMP} "Not supported"
  Goto save_HKLM_root_sfn

find_HKLM_root_sfn:
  GetFullPathName /SHORT ${L_TEMP} "$G_ROOTDIR"

save_HKLM_root_sfn:
  WriteRegStr HKLM "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_SFN" "${L_TEMP}"

current_user_root:
  WriteRegStr HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "Installer Language" "$LANGUAGE"
  WriteRegStr HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "POPFile Major Version" "${C_POPFILE_MAJOR_VERSION}"
  WriteRegStr HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "POPFile Minor Version" "${C_POPFILE_MINOR_VERSION}"
  WriteRegStr HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "POPFile Revision" "${C_POPFILE_REVISION}"
  WriteRegStr HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "POPFile RevStatus" "${C_POPFILE_RC}"
  WriteRegStr HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "InstallPath" "$G_ROOTDIR"
  WriteRegStr HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "Author" "setup.exe"
  WriteRegStr HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_LFN" "$G_ROOTDIR"
  StrCmp $G_SFN_DISABLED "0" find_HKCU_root_sfn
  StrCpy ${L_TEMP} "Not supported"
  Goto save_HKCU_root_sfn

find_HKCU_root_sfn:
  GetFullPathName /SHORT ${L_TEMP} "$G_ROOTDIR"

save_HKCU_root_sfn:
  WriteRegStr HKCU "Software\POPFile Project\${C_PFI_PRODUCT}\MRI" "RootDir_SFN" "${L_TEMP}"

  ; Install the POPFile Core files

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_CORE)"
  SetDetailsPrint listonly

  SetOutPath "$G_ROOTDIR"

  ; Remove redundant files (from earlier test versions of the installer)

  Delete "$G_ROOTDIR\wrapper.exe"
  Delete "$G_ROOTDIR\wrapperf.exe"
  Delete "$G_ROOTDIR\wrapperb.exe"

  ; Install POPFile 'core' files

  File "..\engine\license"
  File "${C_RELEASE_NOTES}"
  CopyFiles /SILENT /FILESONLY "$PLUGINSDIR\${C_README}.txt" "$G_ROOTDIR\${C_README}.txt"

  File "..\engine\popfile.exe"
  File "..\engine\popfilef.exe"
  File "..\engine\popfileb.exe"
  File "..\engine\popfileif.exe"
  File "..\engine\popfileib.exe"
  File "..\engine\popfile-service.exe"
  File /nonfatal "/oname=pfi-stopwords.default" "..\engine\stopwords"

  File "runpopfile.exe"
  File "stop_pf.exe"
  File "sqlite.exe"
  File "runsqlite.exe"
  File "adduser.exe"
  File /nonfatal "test\pfidiag.exe"
  File "msgcapture.exe"

  IfFileExists "$G_ROOTDIR\pfimsgcapture.exe" 0 app_paths
  Delete "$G_ROOTDIR\pfimsgcapture.exe"
  File "/oname=pfimsgcapture.exe" "msgcapture.exe"

app_paths:

  ; Add 'stop_pf.exe' to 'App Paths' to allow it to be run using Start -> Run -> stop_pf params

  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\stop_pf.exe" \
      "" "$G_ROOTDIR\stop_pf.exe"

  SetOutPath "$G_ROOTDIR"

  File "..\engine\popfile.pl"
  File "..\engine\popfile-check-setup.pl"
  File "..\engine\popfile.pck"
  File "..\engine\insert.pl"
  File "..\engine\bayes.pl"
  File "..\engine\pipe.pl"

  File "..\engine\favicon.ico"

  SetOutPath "$G_ROOTDIR\Classifier"
  File "..\engine\Classifier\Bayes.pm"
  File "..\engine\Classifier\WordMangle.pm"
  File "..\engine\Classifier\MailParse.pm"
  IfFileExists "$G_ROOTDIR\Classifier\popfile.sql" update_the_schema

no_previous_version:
  WriteINIStr "$G_ROOTDIR\pfi-data.ini" "Settings" "Owner" "$G_WINUSERNAME"
  DeleteINIStr "$G_ROOTDIR\pfi-data.ini" "Settings" "OldSchema"
  Goto install_schema

update_the_schema:
  Push "$G_ROOTDIR\Classifier\popfile.sql"
  Call PFI_GetPOPFileSchemaVersion
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "()" assume_early_schema
  StrCpy ${L_TEMP} ${L_RESULT} 1
  StrCmp ${L_TEMP} "(" no_previous_version remember_version

assume_early_schema:
  StrCpy ${L_RESULT} "0"

remember_version:
  WriteINIStr "$G_ROOTDIR\pfi-data.ini" "Settings" "Owner" "$G_WINUSERNAME"
  WriteINIStr "$G_ROOTDIR\pfi-data.ini" "Settings" "OldSchema" "${L_RESULT}"

install_schema:
  File "..\engine\Classifier\popfile.sql"

  SetOutPath "$G_ROOTDIR\Platform"
  File "..\engine\Platform\MSWin32.pm"
  Delete "$G_ROOTDIR\Platform\POPFileIcon.dll"

  SetOutPath "$G_ROOTDIR\POPFile"
  File "..\engine\POPFile\MQ.pm"
  File "..\engine\POPFile\Database.pm"
  File "..\engine\POPFile\History.pm"
  File "..\engine\POPFile\Loader.pm"
  File "..\engine\POPFile\Logger.pm"
  File "..\engine\POPFile\Module.pm"
  File "..\engine\POPFile\Mutex.pm"
  File "..\engine\POPFile\Configuration.pm"
  File "..\engine\POPFile\popfile_version"

  SetOutPath "$G_ROOTDIR\Proxy"
  File "..\engine\Proxy\Proxy.pm"
  File "..\engine\Proxy\POP3.pm"

  SetOutPath "$G_ROOTDIR\UI"
  File "..\engine\UI\HTML.pm"
  File "..\engine\UI\HTTP.pm"

  ;-----------------------------------------------------------------------

  ; 'English' version of the QuickStart Guide

  SetOutPath "$G_ROOTDIR\manual"
  File "..\engine\manual\*.gif"

  SetOutPath "$G_ROOTDIR\manual\en"
  File "..\engine\manual\en\*.html"

  ;-----------------------------------------------------------------------

  ; Default UI language

  SetOutPath "$G_ROOTDIR\languages"
  File "..\engine\languages\English.msg"

  ;-----------------------------------------------------------------------

  ; Default UI skin (the POPFile UI looks better if a skin is used)

  SetOutPath "$G_ROOTDIR\skins\default"
  File "..\engine\skins\default\*.*"

  ;-----------------------------------------------------------------------

  ; Create the uninstall program BEFORE creating the shortcut to it
  ; (this ensures that the correct "uninstall" icon appears in the START MENU shortcut)

  SetOutPath "$G_ROOTDIR"
  Delete "$G_ROOTDIR\uninstall.exe"
  WriteUninstaller "$G_ROOTDIR\uninstall.exe"

  ; Attempt to remove some StartUp and Start Menu shortcuts created by previous installations

  SetShellVarContext all
  Delete "$SMSTARTUP\Run POPFile.lnk"
  Delete "$SMSTARTUP\Run POPFile in background.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Run POPFile in background.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Manual.url"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\POPFile Manual.url"

  SetShellVarContext current
  Delete "$SMSTARTUP\Run POPFile.lnk"
  Delete "$SMSTARTUP\Run POPFile in background.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Run POPFile in background.lnk"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Manual.url"
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\POPFile Manual.url"

  ; Create the START MENU entries

  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_SHORT)"
  SetDetailsPrint listonly

  ; 'CreateShortCut' uses '$OUTDIR' as the working directory for the shortcut
  ; ('SetOutPath' is one way to change the value of $OUTDIR)

  ; 'CreateShortCut' fails to update existing shortcuts if they are read-only, so try to clear
  ; the read-only attribute first. Similar handling is required for the Internet shortcuts.

  ; If the user has 'Admin' rights, create a 'POPFile' folder with a set of shortcuts in
  ; the 'All Users' Start Menu . If the user does not have 'Admin' rights, the shortcuts
  ; are created in the 'Current User' Start Menu.

  ; If the 'All Users' folder is not found, NSIS will return the 'Current User' folder.

  SetShellVarContext all
  StrCmp $G_WINUSERTYPE "Admin" create_shortcuts
  SetShellVarContext current

create_shortcuts:
  SetOutPath "$SMPROGRAMS\${C_PFI_PRODUCT}"
  SetOutPath "$G_ROOTDIR"

  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Run POPFile.lnk" NORMAL
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Run POPFile.lnk" \
                 "$G_ROOTDIR\runpopfile.exe"

  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Uninstall POPFile.lnk" NORMAL
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Uninstall POPFile.lnk" \
                 "$G_ROOTDIR\uninstall.exe"

  SetOutPath "$G_ROOTDIR"
  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Release Notes.lnk" NORMAL
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Release Notes.lnk" \
                 "$G_ROOTDIR\${C_README}.txt"

  SetOutPath "$SMPROGRAMS\${C_PFI_PRODUCT}"

  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\POPFile User Interface.url" NORMAL
  WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\POPFile User Interface.url" \
              "InternetShortcut" "URL" "http://${C_UI_URL}:$G_GUI/"

  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Shutdown POPFile.url" NORMAL
  WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\Shutdown POPFile.url" \
              "InternetShortcut" "URL" "http://${C_UI_URL}:$G_GUI/shutdown"

  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\QuickStart Guide.url" NORMAL
  WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\QuickStart Guide.url" \
              "InternetShortcut" "URL" "file://$G_ROOTDIR/manual/en/manual.html"

  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\FAQ.url" NORMAL

  !ifndef ENGLISH_MODE
      StrCmp $LANGUAGE ${LANG_JAPANESE} japanese_faq
  !endif

  WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\FAQ.url" \
              "InternetShortcut" "URL" \
              "http://getpopfile.org/cgi-bin/wiki.pl?FrequentlyAskedQuestions"

  !ifndef ENGLISH_MODE
      Goto support

    japanese_faq:
      WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\FAQ.url" \
                  "InternetShortcut" "URL" \
                  "http://getpopfile.org/cgi-bin/wiki.pl?JP_FrequentlyAskedQuestions"

    support:
  !endif

  SetOutPath "$SMPROGRAMS\${C_PFI_PRODUCT}\Support"

  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\POPFile Home Page.url" NORMAL
  WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\POPFile Home Page.url" \
              "InternetShortcut" "URL" "http://getpopfile.org/"

  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\POPFile Support (Wiki).url" NORMAL

  !ifndef ENGLISH_MODE
      StrCmp $LANGUAGE ${LANG_JAPANESE} japanese_wiki
  !endif

  WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\POPFile Support (Wiki).url" \
              "InternetShortcut" "URL" \
              "http://getpopfile.org/cgi-bin/wiki.pl?POPFileDocumentationProject"

  !ifndef ENGLISH_MODE
      Goto pfidiagnostic

    japanese_wiki:
  WriteINIStr "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\POPFile Support (Wiki).url" \
                  "InternetShortcut" "URL" \
                  "http://getpopfile.org/cgi-bin/wiki.pl?JP_POPFileDocumentationProject"

    pfidiagnostic:
  !endif

  IfFileExists "$G_ROOTDIR\pfidiag.exe" 0 silent_shutdown
  Delete "$SMPROGRAMS\${C_PFI_PRODUCT}\PFI Diagnostic utility.lnk"
  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\PFI Diagnostic utility (simple).lnk" NORMAL
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\PFI Diagnostic utility (simple).lnk" \
                 "$G_ROOTDIR\pfidiag.exe"
  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\PFI Diagnostic utility (full).lnk" NORMAL
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Support\PFI Diagnostic utility (full).lnk" \
                 "$G_ROOTDIR\pfidiag.exe" "/full"

silent_shutdown:
  SetOutPath "$G_ROOTDIR"

  SetFileAttributes "$SMPROGRAMS\${C_PFI_PRODUCT}\Shutdown POPFile silently.lnk" NORMAL
  CreateShortCut "$SMPROGRAMS\${C_PFI_PRODUCT}\Shutdown POPFile silently.lnk" \
                 "$G_ROOTDIR\stop_pf.exe" "/showerrors $G_GUI"

  ; Create entry in the Control Panel's "Add/Remove Programs" list

  StrCmp $G_WINUSERTYPE "Admin" use_HKLM

  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "DisplayName" "${C_PFI_PRODUCT} ${C_PFI_VERSION}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "UninstallString" "$G_ROOTDIR\uninstall.exe"
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "NoModify" "1"
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "NoRepair" "1"
  Goto end_section

use_HKLM:
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "DisplayName" "${C_PFI_PRODUCT} ${C_PFI_VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "UninstallString" "$G_ROOTDIR\uninstall.exe"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "NoModify" "1"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${C_PFI_PRODUCT}" \
              "NoRepair" "1"

end_section:
  SetDetailsPrint textonly
  DetailPrint "$(PFI_LANG_INST_PROG_ENDSEC)"
  SetDetailsPrint listonly

  !insertmacro SECTIONLOG_EXIT "POPFile"

  Pop ${L_TEMP}
  Pop ${L_RESULT}

  !undef L_RESULT
  !undef L_TEMP

; SectionEnd

#--------------------------------------------------------------------------
# End of 'installer-SecPOPFile-body.nsh'
#--------------------------------------------------------------------------
