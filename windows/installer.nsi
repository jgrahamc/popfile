#--------------------------------------------------------------------------
#
# installer.nsi --- This is the NSIS script used to create the
#                   Windows installer for POPFile. This script uses
#                   two custom pages whose layouts are defined
#                   in the files "ioA.ini" and "ioB.ini".
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
#--------------------------------------------------------------------------

; Modified to work with NSIS 2.0b4 (CVS) or later

#--------------------------------------------------------------------------

  !define MUI_PRODUCT "POPFile"
  !define MUI_VERSION "0.19.0 RC3"
  !include "MUI.nsh"

#----------------------------------------------------------------------------------------
# CBP Configuration Data (leave lines commented-out if defaults are satisfactory)
#----------------------------------------------------------------------------------------
#   ; Maximum number of buckets handled (in range 2 to 8)
#
#   !define CBP_MAX_BUCKETS 8
#
#   ; Default bucket selection (use "" if no buckets are to be pre-selected)
#
#   !define CBP_DEFAULT_LIST "in-box|junk|personal|work"
#
#   ; List of suggestions for bucket names (use "" if no suggestions are required)
#
#   !define CBP_SUGGESTION_LIST \
#   "admin|business|computers|family|financial|general|hobby|in-box|junk|list-admin|\
#   miscellaneous|not_spam|other|personal|recreation|school|security|shopping|spam|\
#   travel|work"
#----------------------------------------------------------------------------------------
# Make the CBP package available
#----------------------------------------------------------------------------------------

  !include CBP.nsh

#--------------------------------------------------------------------------
# Installer Configuration
#--------------------------------------------------------------------------

  !define MUI_CUSTOMPAGECOMMANDS

  ; The "Special" bitmap appears on the "Welcome" and "Finish" pages,
  ; the "Header" bitmap appears on the other pages of the installer.
  
  !define MUI_SPECIALBITMAP "special.bmp"
  !define MUI_HEADERBITMAP "hdr-right.bmp"
  !define MUI_HEADERBITMAP_RIGHT

  !define MUI_WELCOMEPAGE
  !define MUI_LICENSEPAGE
  ; Select either "accept/do not accept" radio buttons or "accept" checkbox for the license page
#    !define MUI_LICENSEPAGE_RADIOBUTTONS
    !define MUI_LICENSEPAGE_CHECKBOX
  !define MUI_COMPONENTSPAGE
  !define MUI_DIRECTORYPAGE
  ; Use a "leave" function to look for 'popfile.cfg' in the directory selected for this install
    !define MUI_CUSTOMFUNCTION_DIRECTORY_LEAVE CheckExistingConfig
  !define MUI_ABORTWARNING
  !define MUI_FINISHPAGE

  ; The icon files for the installer and uninstaller must have the same structure. For example,
  ; if one icon file contains a 32x32 16-colour image and a 16x16 16-colour image then the other
  ; file cannot just contain a 32x32 16-colour image, it must also have a 16x16 16-colour image.
  
  !define MUI_ICON    "POPFileIcon\popfile.ico"
  !define MUI_UNICON  "remove.ico" 

  !define MUI_UNINSTALLER
  !define MUI_UNCONFIRMPAGE

#--------------------------------------------------------------------------
# User Registers (Global)
#--------------------------------------------------------------------------

  ; NSIS provides 20 general purpose user registers:
  ; (a) $0 to $9 are used as global registers
  ; (b) $R0 to $R9 are used as local registers

  !define POP3     $0   ; POP3 port (1-65535)
  !define GUI      $1   ; GUI port (1-65535)
  !define STARTUP  $2   ; automatic startup flag (1 = yes, 0 = no)
  !define CFG      $3   ; general purpose file handle
  
  !define OEID     $6
  !define ID       $7
  !define OEIDENT  $8
  !define ACCTID   $9

#--------------------------------------------------------------------------
# Language
#--------------------------------------------------------------------------

  !insertmacro MUI_LANGUAGEFILE_STRING MUI_TEXT_WELCOME_INFO_TEXT \
      "This wizard will guide you through the installation of ${MUI_PRODUCT}.\r\n\r\n\
      It is recommended that you close all other applications before starting Setup.\r\n\r\n"
  !insertmacro MUI_LANGUAGE "English"

#--------------------------------------------------------------------------
# General settings
#--------------------------------------------------------------------------

  ; Specify NSIS output filename

  OutFile "setup.exe"

  ; Ensure CRC checking cannot be turned off using the command-line switch

  CRCcheck Force
  
  ; Data file for license page

  LicenseData "..\engine\license"

#--------------------------------------------------------------------------
# Install Options page header text
#--------------------------------------------------------------------------

  LangString TEXT_IO_TITLE ${LANG_ENGLISH} "Install Options Page"
  LangString TEXT_IO_SUBTITLE ${LANG_ENGLISH} "Options"

#--------------------------------------------------------------------------
# Define the Page order for the installer
#--------------------------------------------------------------------------

  !insertmacro MUI_PAGECOMMAND_WELCOME
  !insertmacro MUI_PAGECOMMAND_LICENSE
  !insertmacro MUI_PAGECOMMAND_COMPONENTS
  !insertmacro MUI_PAGECOMMAND_DIRECTORY
  Page custom SetOptionsPage "CheckPortOptions" ": Options"
  !insertmacro MUI_PAGECOMMAND_INSTFILES
  !insertmacro CBP_PAGECOMMAND_SELECTBUCKETS ": Create POPFile Buckets"
  Page custom SetOutlookOrOutlookExpressPage "" ": Configure Outlook Express"
  !insertmacro MUI_PAGECOMMAND_FINISH

#--------------------------------------------------------------------------
# Component-selection page description text
#--------------------------------------------------------------------------

  LangString DESC_SecPOPFile ${LANG_ENGLISH} "Installs the core files needed by POPFile, \
                                              including a minimal version of Perl."
  LangString DESC_SecSkins   ${LANG_ENGLISH} "Installs POPFile skins that allow you to change \
                                              the look and feel of the POPFile user interface."
  LangString DESC_SecLangs   ${LANG_ENGLISH} "Installs non-English language versions of the \
                                              POPFile UI."

#--------------------------------------------------------------------------
# Default Destination Folder
#--------------------------------------------------------------------------

  InstallDir "$PROGRAMFILES\${MUI_PRODUCT}"
  InstallDirRegKey HKLM SOFTWARE\POPFile InstallLocation

#--------------------------------------------------------------------------
# Reserve the files required by the installer (to improve performance)
#--------------------------------------------------------------------------

  ;Things that need to be extracted on startup (keep these lines before any File command!)
  ;Only useful for BZIP2 compression
  ;Use ReserveFile for your own Install Options ini files too!

  !insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
  !insertmacro MUI_RESERVEFILE_WELCOMEFINISHPAGE
  ReserveFile "ioA.ini"
  ReserveFile "ioB.ini"

#--------------------------------------------------------------------------
# Initialise the installer
#--------------------------------------------------------------------------

Function .onInit

  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioA.ini"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioB.ini"

  File /oname=$PLUGINSDIR\release.txt "..\engine\v0.19.0.change"
  MessageBox MB_YESNO "Display POPFile Release Notes ?$\r$\n$\r$\n\
      'Yes' recommended if you are upgrading." IDNO exit
  SearchPath $R0 notepad.exe
  StrCmp $R0 "" use_file_association
  ExecWait 'notepad.exe "$PLUGINSDIR\release.txt"'
  GoTo exit

use_file_association:
  ExecShell "open" "$PLUGINSDIR\release.txt"
  
exit:
FunctionEnd

#--------------------------------------------------------------------------
# Installer Section: POPFile component
#--------------------------------------------------------------------------

Section "POPFile" SecPOPFile

  ; Make this section mandatory (i.e. it is always installed)

  SectionIn RO

  ; Retrieve the POP3 and GUI ports from the ini and get whether we install the
  ; POPFile run in the Startup group

  !insertmacro MUI_INSTALLOPTIONS_READ ${POP3}    "ioA.ini" "Field 2" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ ${GUI}     "ioA.ini" "Field 4" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ ${STARTUP} "ioA.ini" "Field 5" "State"

  WriteRegStr HKLM SOFTWARE\POPFile InstallLocation $INSTDIR

  ; Install the POPFile Core files

  SetOutPath $INSTDIR
   
  File "..\engine\license"
  File "..\engine\v0.19.0.change"
  File "..\engine\*.pl"
  File "..\engine\pix.gif"
  File "..\engine\black.gif"
  
  IfFileExists "$INSTDIR\stopwords" stopwords_found
  File "..\engine\stopwords"
  Goto stopwords_done

stopwords_found:
  IfFileExists "$INSTDIR\stopwords.default" 0 use_other_name
  MessageBox MB_YESNO "Copy of default 'stopwords' already exists ('stopwords.default').$\r$\n\
      $\r$\nOK to overwrite this file?$\r$\n$\r$\n\
      Click 'Yes' to overwrite, click 'No' to skip updating this file" IDNO stopwords_done
  SetFileAttributes stopwords.default NORMAL
      
use_other_name:
  File /oname=stopwords.default "..\engine\stopwords"

stopwords_done:
  FileOpen  ${CFG} $PLUGINSDIR\popfile.cfg a
  FileSeek  ${CFG} 0 END
  FileWrite ${CFG} "pop3_port ${POP3}$\r$\n"
  FileWrite ${CFG} "html_port ${GUI}$\r$\n"
  FileClose ${CFG}
  IfFileExists "$INSTDIR\popfile.cfg" 0 update_config
  IfFileExists "$INSTDIR\popfile.cfg.bak" 0 make_cfg_backup
  MessageBox MB_YESNO "Backup copy of 'popfile.cfg' already exists ('popfile.cfg.bak').$\r$\n\
      $\r$\nOK to overwrite this file?$\r$\n$\r$\n\
      Click 'Yes' to overwrite, click 'No' to skip making a backup copy" IDNO update_config
  SetFileAttributes popfile.cfg.bak NORMAL
make_cfg_backup:
  CopyFiles $INSTDIR\popfile.cfg $INSTDIR\popfile.cfg.bak
      
update_config:
  CopyFiles $PLUGINSDIR\popfile.cfg $INSTDIR\

  SetOutPath $INSTDIR\Classifier
  File "..\engine\Classifier\Bayes.pm"
  File "..\engine\Classifier\WordMangle.pm"
  File "..\engine\Classifier\MailParse.pm"
  SetOutPath $INSTDIR\POPFile
  File "..\engine\POPFile\Logger.pm"
  File "..\engine\POPFile\Module.pm"
  File "..\engine\POPFile\Configuration.pm"
  SetOutPath $INSTDIR\Proxy
  File "..\engine\Proxy\Proxy.pm"
  File "..\engine\Proxy\POP3.pm"
  SetOutPath $INSTDIR\Platform
  File "..\engine\Platform\MSWin32.pm"
  File "..\engine\Platform\POPFileIcon.dll"
  SetOutPath $INSTDIR\UI
  File "..\engine\UI\HTML.pm"
  File "..\engine\UI\HTTP.pm"

  SetOutPath $INSTDIR\manual
  File "..\engine\manual\*.gif"
  SetOutPath $INSTDIR\manual\en
  File "..\engine\manual\en\*.html"

  SetOutPath $INSTDIR\languages
  File "..\engine\languages\English.msg"

  ; Install the Minimal Perl files

  SetOutPath $INSTDIR
  File "C:\Perl58\bin\perl.exe"
  File "C:\Perl58\bin\wperl.exe"
  File "C:\Perl58\bin\perl58.dll"
  File "C:\Perl58\lib\AutoLoader.pm"
  File "C:\Perl58\lib\Carp.pm"
  File "C:\Perl58\lib\Config.pm"
  File "C:\Perl58\lib\DynaLoader.pm"
  File "C:\Perl58\lib\Errno.pm"
  File "C:\Perl58\lib\Exporter.pm"
  File "C:\Perl58\lib\IO.pm"
  File "C:\Perl58\lib\integer.pm"
  File "C:\Perl58\lib\locale.pm"
  File "C:\Perl58\lib\POSIX.pm"
  File "C:\Perl58\lib\SelectSaver.pm"
  File "C:\Perl58\lib\Socket.pm"
  File "C:\Perl58\lib\strict.pm"
  File "C:\Perl58\lib\Symbol.pm"
  File "C:\Perl58\lib\vars.pm"
  File "C:\Perl58\lib\warnings.pm"
  File "C:\Perl58\lib\XSLoader.pm"

  SetOutPath $INSTDIR\Carp
  File "C:\Perl58\lib\Carp\*"

  SetOutPath $INSTDIR\Exporter
  File "C:\Perl58\lib\Exporter\*"

  SetOutPath $INSTDIR\MIME
  File "C:\Perl58\lib\MIME\*"

  SetOutPath $INSTDIR\Win32
  File "C:\Perl58\site\lib\Win32\API.pm"

  SetOutPath $INSTDIR\Win32\API
  File "C:\Perl58\site\lib\Win32\API\*.pm"

  SetOutPath $INSTDIR\auto\Win32\API
  File "C:\Perl58\site\lib\auto\Win32\API\*"

  SetOutPath $INSTDIR\IO
  File "C:\Perl58\lib\IO\*"

  SetOutPath $INSTDIR\Sys
  File "C:\Perl58\lib\Sys\*"

  SetOutPath $INSTDIR\Text
  File "C:\Perl58\lib\Text\ParseWords.pm"

  SetOutPath $INSTDIR\IO\Socket
  File "C:\Perl58\lib\IO\Socket\*"

  SetOutPath $INSTDIR\auto\DynaLoader
  File "C:\Perl58\lib\auto\DynaLoader\*"

  SetOutPath $INSTDIR\auto\File\Glob
  File "C:\Perl58\lib\auto\File\Glob\*"

  SetOutPath $INSTDIR\auto\MIME\Base64
  File "C:\Perl58\lib\auto\MIME\Base64\*"

  SetOutPath $INSTDIR\auto\IO
  File "C:\Perl58\lib\auto\IO\*"

  SetOutPath $INSTDIR\auto\Socket
  File "C:\Perl58\lib\auto\Socket\*"

  SetOutPath $INSTDIR\auto\Sys\Hostname
  File "C:\Perl58\lib\auto\Sys\Hostname\*"

  SetOutPath $INSTDIR\auto\POSIX
  File "C:\Perl58\lib\auto\POSIX\POSIX.dll"
  File "C:\Perl58\lib\auto\POSIX\autosplit.ix"
  File "C:\Perl58\lib\auto\POSIX\load_imports.al"

  SetOutPath $INSTDIR\File
  File "C:\Perl58\lib\File\Glob.pm"

  SetOutPath $INSTDIR\warnings
  File "C:\Perl58\lib\warnings\register.pm"

  ; Create the uninstall program BEFORE creating the shortcut to it
  ; (this ensures that the correct "uninstall" icon appears in the START MENU shortcut)
  
  SetOutPath $INSTDIR
  Delete $INSTDIR\uninstall.exe
  WriteUninstaller $INSTDIR\uninstall.exe

  ; Create the START MENU entries

  SetOutPath $SMPROGRAMS\POPFile
  SetOutPath $INSTDIR
  CreateShortCut "$SMPROGRAMS\POPFile\Run POPFile.lnk" \
                 "$INSTDIR\perl.exe" popfile.pl
  CreateShortCut "$SMPROGRAMS\POPFile\Run POPFile in background.lnk" \
                 "$INSTDIR\wperl.exe" popfile.pl
  CreateShortCut "$SMPROGRAMS\POPFile\Uninstall POPFile.lnk" \
                 "$INSTDIR\uninstall.exe"
  SetOutPath $SMPROGRAMS\POPFile
  WriteINIStr "$SMPROGRAMS\POPFile\POPFile User Interface.url" \
              "InternetShortcut" "URL" "http://127.0.0.1:${GUI}/"
  WriteINIStr "$SMPROGRAMS\POPFile\Shutdown POPFile.url" \
              "InternetShortcut" "URL" "http://127.0.0.1:${GUI}/shutdown"
  WriteINIStr "$SMPROGRAMS\POPFile\Manual.url" \
              "InternetShortcut" "URL" "file://$INSTDIR/manual/en/manual.html"
  WriteINIStr "$SMPROGRAMS\POPFile\FAQ.url" \
              "InternetShortcut" "URL" \
              "http://sourceforge.net/docman/display_doc.php?docid=14421&group_id=63137"
  SetOutPath $SMPROGRAMS\POPFile\Support
  WriteINIStr "$SMPROGRAMS\POPFile\Support\POPFile Home Page.url" \
              "InternetShortcut" "URL" "http://popfile.sourceforge.net/"

  StrCmp ${STARTUP} "1" 0 skip_autostart_set
      SetOutPath $SMSTARTUP
      SetOutPath $INSTDIR
      CreateShortCut "$SMSTARTUP\Run POPFile in background.lnk" \
                     "$INSTDIR\wperl.exe" popfile.pl
skip_autostart_set:
  
  ; Create entry in the Control Panel's "Add/Remove Programs" list

  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_PRODUCT}" \
              "DisplayName" "${MUI_PRODUCT} ${MUI_VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_PRODUCT}" \
              "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_PRODUCT}" \
              "NoModify" "1"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_PRODUCT}" \
              "NoRepair" "1"

SectionEnd

#--------------------------------------------------------------------------
# Installer Section: (optional) Skins component
#--------------------------------------------------------------------------

Section "Skins" SecSkins

  SetOutPath $INSTDIR\skins
  File "..\engine\skins\*.css"
  File "..\engine\skins\*.gif"
  SetOutPath $INSTDIR\skins\lavishImages
  File "..\engine\skins\lavishImages\*.gif"
  SetOutPath $INSTDIR\skins\sleetImages
  File "..\engine\skins\sleetImages\*.gif"

SectionEnd

#--------------------------------------------------------------------------
# Installer Section: (optional) UI Languages component
#--------------------------------------------------------------------------

Section "Languages" SecLangs

  SetOutPath $INSTDIR\languages
  File "..\engine\languages\*.msg"

SectionEnd

#--------------------------------------------------------------------------
# Component-selection page descriptions
#--------------------------------------------------------------------------

  !insertmacro MUI_FUNCTIONS_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecPOPFile} $(DESC_SecPOPFile)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecSkins} $(DESC_SecSkins)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecLangs} $(DESC_SecLangs)
  !insertmacro MUI_FUNCTIONS_DESCRIPTION_END

#--------------------------------------------------------------------------
# Installer Function: CheckExistingConfig
# (the "leave" function for the DIRECTORY selection page)
#
# This function is used to extract the POP3 and UI ports from the 'popfile.cfg'
# configuration file (if any) in the directory used for this installation.
#
# As it is possible that there are multiple entries for these parameters in the file,
# this function removes them all as it makes a new copy of the file. New port data
# entries will be added to this copy and the original updated (and backed up) when
# the "POPFile" section of the installer is executed.
#--------------------------------------------------------------------------

Function CheckExistingConfig

  !define L_CLEANCFG  $R9     ; handle for "clean" copy
  !define L_CMPRE     $R8     ; config param name
  !define L_LNE       $R7     ; a line from popfile.cfg
  !define L_OLDUI     $R6     ; used to hold old-style of GUI port
  
  StrCpy ${POP3} ""
  StrCpy ${GUI} ""
  StrCpy ${L_OLDUI} ""

  ; See if we can get the current pop3 and gui port from an existing configuration.
  ; There may be more than one entry for these ports in the file - use the last one found
  ; (but give priority to any "html_port" entry).

  ClearErrors
  
  FileOpen  ${CFG} $INSTDIR\popfile.cfg r
  FileOpen  ${L_CLEANCFG} $PLUGINSDIR\popfile.cfg w

loop:
  FileRead   ${CFG} ${L_LNE}
  IfErrors done

  StrCpy ${L_CMPRE} ${L_LNE} 5
  StrCmp ${L_CMPRE} "port " got_port

  StrCpy ${L_CMPRE} ${L_LNE} 10
  StrCmp ${L_CMPRE} "pop3_port " got_pop3_port
  StrCmp ${L_CMPRE} "html_port " got_html_port

  StrCpy ${L_CMPRE} ${L_LNE} 8
  StrCmp ${L_CMPRE} "ui_port " got_ui_port
  
  FileWrite  ${L_CLEANCFG} ${L_LNE}
  Goto loop
  
got_port:
  StrCpy ${POP3} ${L_LNE} 5 5
  Goto loop

got_pop3_port:
  StrCpy ${POP3} ${L_LNE} 5 10
  Goto loop

got_ui_port:
  StrCpy ${L_OLDUI} ${L_LNE} 5 8
  Goto loop

got_html_port:
  StrCpy ${GUI} ${L_LNE} 5 10
  Goto loop

done:
  FileClose ${CFG}
  FileClose ${L_CLEANCFG}
  
  ; The 'port' and 'pop3_port' settings are treated as equals so we use the last entry found.
  ; If 'ui_port' and 'html_port' settings were found, we use the last 'html_port' we found.
  
  StrCmp ${GUI} "" 0 validity_checks
  StrCpy ${GUI} ${L_OLDUI}

validity_checks:
  
  ; check port values (config file may have no port data or invalid port data)

  StrCmp ${POP3} ${GUI} 0 ports_differ
  
  ; Config file has no port data or same port used for POP3 and GUI
  ; (i.e. the data is not valid), so use POPFile defaults

  StrCpy ${POP3} "110"
  StrCpy ${GUI} "8080"
  Goto ports_ok

ports_differ:
  Push ${POP3}
  Call TrimNewlines
  Pop ${POP3}

  Push ${GUI}
  Call TrimNewlines
  Pop ${GUI}
  
  StrCmp ${POP3} "" default_pop3
  Push ${POP3}
  Call StrCheckDecimal
  Pop ${POP3}
  StrCmp ${POP3} "" default_pop3
  IntCmp ${POP3} 1 pop3_ok default_pop3
  IntCmp ${POP3} 65535 pop3_ok pop3_ok

default_pop3:
  StrCpy ${POP3} "110"
  StrCmp ${POP3} ${GUI} 0 pop3_ok
  StrCpy ${POP3} "111"

pop3_ok:
  StrCmp ${GUI} "" default_gui
  Push ${GUI}
  Call StrCheckDecimal
  Pop ${GUI}
  StrCmp ${GUI} "" default_gui
  IntCmp ${GUI} 1 ports_ok default_gui
  IntCmp ${GUI} 65535 ports_ok ports_ok

default_gui:
  StrCpy ${GUI} "8080"
  StrCmp ${POP3} ${GUI} 0 ports_ok
  StrCpy ${GUI} "8081"

ports_ok:

  !undef L_CLEANCFG
  !undef L_CMPRE
  !undef L_LNE
  !undef L_OLDUI

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: SetOptionsPage (generates a custom page)
#
# This function is used to configure the POP3 and UI ports, and
# whether or not POPFile should be started automatically.
#
# A "leave" function (CheckPortOptions) is used to validate the port
# selections made by the user.
#--------------------------------------------------------------------------

Function SetOptionsPage

  !define L_PORTLIST  $R9   ; combo box ports list
  !define L_RESULT    $R8

  ; The function "CheckExistingConfig" loads ${POP3} and ${GUI} with the settings found in
  ; a previously installed "popfile.cfg" file or if no such file is found, it loads the
  ; POPFile default values. Now we display these settings and allow the user to change them.

  ; The POP3 and GUI port numbers must be in the range 1 to 65535 inclusive, and they
  ; must be different. This function assumes that the values "CheckExistingConfig" has loaded
  ; into ${POP3} and ${GUI} are valid.

  !insertmacro MUI_HEADER_TEXT "POPFile Installation Options" \
                               "Leave these options unchanged unless you need to change them"

  ; If the POP3 (or GUI) port determined by "CheckExistingConfig" is not present in the list of
  ; possible values for the POP3 (or GUI) combobox, add it to the end of the list.

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_PORTLIST} "ioA.ini" "Field 2" "ListItems"
  Push |${L_PORTLIST}|
  Push |${POP3}|
  Call StrStr
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "" 0 POP3_is_in_list
  StrCpy ${L_PORTLIST} ${L_PORTLIST}|${POP3}
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioA.ini" "Field 2" "ListItems" ${L_PORTLIST}

POP3_is_in_list:
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_PORTLIST} "ioA.ini" "Field 4" "ListItems"
  Push |${L_PORTLIST}|
  Push |${GUI}|
  Call StrStr
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "" 0 GUI_is_in_list
  StrCpy ${L_PORTLIST} ${L_PORTLIST}|${GUI}
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioA.ini" "Field 4" "ListItems" ${L_PORTLIST}

GUI_is_in_list:

  ; If the StartUp folder contains a link to start POPFile automatically
  ; then offer to keep this facility in place.

  IfFileExists "$SMSTARTUP\Run POPFile in background.lnk" 0 show_defaults
    !insertmacro MUI_INSTALLOPTIONS_WRITE "ioA.ini" "Field 5" "State" 1

show_defaults:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioA.ini" "Field 2" "State" ${POP3}
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioA.ini" "Field 4" "State" ${GUI}

  ; Now display the custom page and wait for the user to make their selections.
  ; The function "CheckPortOptions" will check the validity of the selections
  ; and refuse to proceed until suitable ports have been chosen.
  
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioA.ini"

  !undef L_PORTLIST
  !undef L_RESULT

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: CheckPortOptions
# (the "leave" function for the custom page created by "SetOptionsPage")
#
# This function is used to validate the POP3 and UI ports selected by the user.
# If the selections are not valid, user is asked to select alternative values.
#--------------------------------------------------------------------------

Function CheckPortOptions

  !define L_RESULT    $R9

  !insertmacro MUI_INSTALLOPTIONS_READ ${POP3} "ioA.ini" "Field 2" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ ${GUI} "ioA.ini" "Field 4" "State"

  StrCmp ${POP3} ${GUI} ports_must_differ
  Push ${POP3}
  Call StrCheckDecimal
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "" bad_pop3
  IntCmp ${POP3} 1 pop3_ok bad_pop3
  IntCmp ${POP3} 65535 pop3_ok pop3_ok

bad_pop3:
  MessageBox MB_OK "The POP3 port cannot be set to $\"${POP3}$\".$\n$\n\
      The port must be a number in the range 1 to 65535.$\n$\n\
      Please change your POP3 port selection."
  Goto bad_exit

pop3_ok:
  Push ${GUI}
  Call StrCheckDecimal
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "" bad_gui
  IntCmp ${GUI} 1 good_exit bad_gui
  IntCmp ${GUI} 65535 good_exit good_exit

bad_gui:
  MessageBox MB_OK "The 'User Interface' port cannot be set to $\"${GUI}$\".$\n$\n\
      The port must be a number in the range 1 to 65535.$\n$\n\
      Please change your 'User Interface' port selection."
  Goto bad_exit

ports_must_differ:
  MessageBox MB_OK "The POP3 port must be different from the 'User Interface' port.$\n$\n\
      Please change your port selections."
  Goto bad_exit

bad_exit:
  ; Stay with the custom page created by "SetOptionsPage"
  Abort
  
good_exit:
  ; Allow next page in the installation sequence to be shown
  
  !undef L_RESULT

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: SetOutlookOrOutlookExpressPage (generates a custom page)
#
# This function is used to reconfigure Outlook Express accounts
#--------------------------------------------------------------------------

Function SetOutlookOrOutlookExpressPage

  ; More than one "identity" can be created in OE. Each of these identities is
  ; given a GUID and these GUIDs are stored in HKEY_CURRENT_USER\Identities.
  ; Each identity can have several email accounts and the details for these
  ; accounts are grouped according to the GUID which "owns" the accounts.

  ; When OE is first installed it creates a default identity which is given the
  ; name "Main Identity". Although there is a GUID for this default identity,
  ; OE stores the email account data for this account in a different location
  ; from that of any extra identities which are created by the user.

  ; We step through every identity defined in HKEY_CURRENT_USER\Identities and
  ; for each one found check its OE email account data. If an identity with
  ; an "Identity Ordinal" value of 1 is found, we need to look in the area
  ; dedicated to the initial "Main Identity", otherwise we look for email
  ; account data in that GUID's entry in HKEY_CURRENT_USER\Identities.

  ; The email account data for all identities, although stored in different
  ; locations, uses the same structure. The "path" for each identity starts
  ; with "HKEY_CURRENT_USER\" and ends with "\Internet Account Manager\Accounts".

  ; All of the OE account data for an identity appears "under" the path defined
  ; above, e.g. if an identity has more than three accounts they are found here:
  ;    HKEY_CURRENT_USER\...\Internet Account Manager\Accounts\00000001
  ;    HKEY_CURRENT_USER\...\Internet Account Manager\Accounts\00000002
  ;    HKEY_CURRENT_USER\...\Internet Account Manager\Accounts\00000003
  ;    etc

  !define L_LNE         $R9
  !define L_SEPARATOR   $R8
  !define L_TEMP        $R3
  
  StrCpy ${L_SEPARATOR} ""
  
  ClearErrors
  
  FileOpen  ${CFG} $INSTDIR\popfile.cfg r

loop:
  FileRead   ${CFG} ${L_LNE}
  IfErrors separator_done

  StrCpy ${L_TEMP} ${L_LNE} 10
  StrCmp ${L_TEMP} "separator " old_separator
  StrCpy ${L_TEMP} ${L_LNE} 15
  StrCmp ${L_TEMP} "pop3_separator " new_separator
  Goto loop
  
old_separator:
  StrCpy ${L_SEPARATOR} ${L_LNE} 1 10
  Goto loop

new_separator:
  StrCpy ${L_SEPARATOR} ${L_LNE} 1 15
  Goto loop

separator_done:
  Push ${L_SEPARATOR}
  Call TrimNewlines
  Pop ${L_SEPARATOR}
  
  ; Use separator character from popfile.cfg (if present) otherwise use a semicolon
  
  StrCmp ${L_SEPARATOR} "" 0 check_accounts
  StrCpy ${L_SEPARATOR} ":"

check_accounts:
  StrCpy ${OEID} 0
  
  ; Get the next identity from the registry

next_id:  
  EnumRegKey ${ID} HKCU "Identities" ${OEID}
  StrCmp ${ID} "" finished_oe

  ; Check if this is the GUID for the first "Main Identity" created by OE (i.e. the GUID has
  ; an "Identity Ordinal" value of 1) as the account data for this identity is stored
  ; separately from the other identities. 

  ReadRegDWORD $R4 HKCU "Identities\${ID}" "Identity Ordinal"
  StrCmp $R4 "1" firstID otherID
firstID:
  StrCpy ${OEIDENT} ""
  goto checkID
otherID:
  StrCpy ${OEIDENT} "Identities\${ID}\"

checkID:
  ; Now check all of the accounts for this particular identity

  StrCpy $R1 0
  
  ; Get the next set of OE account data for the specified OE Identity

next_acct:
  EnumRegKey ${ACCTID} HKCU "${OEIDENT}Software\Microsoft\Internet Account Manager\Accounts" $R1
  StrCmp ${ACCTID} "" finished_this_id

  ; Now extract the POP3 Server, if this does not exist then this account is
  ; not configured for mail so move on
  
  StrCpy $R5 "${OEIDENT}Software\Microsoft\Internet Account Manager\Accounts\${ACCTID}"
  ReadRegStr $R6 HKCU $R5 "POP3 Server"
  StrCmp $R6 "" next_acct_increment
  StrCmp $R6 "127.0.0.1" next_acct_increment

  !insertmacro MUI_HEADER_TEXT "Reconfigure Outlook Express" \
      "POPFile can reconfigure Outlook Express for you"
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 2" "State" "0"
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 8" "Text" $R6

  ; Find the Username used by OE for this identity and the OE Account Name
  ; (so we can unambiguously report which email account we are offering
  ; to reconfigure).

  ReadRegStr $R7 HKCU "Identities\${ID}\" "Username"
  StrCpy $R7 $\"$R7$\"
  ReadRegStr $R6 HKCU $R5 "SMTP Email Address"
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 7" "Text" $R6
  ReadRegStr $R6 HKCU $R5 "POP3 User Name"
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 9" "Text" $R6
  ReadRegStr $R6 HKCU $R5 "Account Name"
  StrCpy $R6 $\"$R6$\"
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 10" "Text" \
      "$R6 account for the $R7 identity"
  
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY_RETURN "ioB.ini"
  Pop $R0
  
  StrCmp $R0 "cancel" finished_this_id
  StrCmp $R0 "back" finished_this_id

  !insertmacro MUI_INSTALLOPTIONS_READ $R5 "ioB.ini" "Field 2" "State"
  StrCmp $R5 "1" change_oe next_acct_increment

change_oe:
  StrCpy $R5 "${OEIDENT}Software\Microsoft\Internet Account Manager\Accounts\${ACCTID}"
  ReadRegStr $R6 HKCU $R5 "POP3 User Name"
  ReadRegStr $R7 HKCU $R5 "POP3 Server"
  
  ; To be able to restore the registry to previous settings when we uninstall we
  ; write a special file called popfile.reg containing the registry settings 
  ; prior to modification in the form of lines consisting of
  ;
  ; the\key
  ; thesubkey
  ; the\value
  
  FileOpen  ${CFG} $INSTDIR\popfile.reg a
  FileSeek  ${CFG} 0 END
  FileWrite ${CFG} "$R5$\n"
  FileWrite ${CFG} "POP3 User Name$\n"
  FileWrite ${CFG} "$R6$\n"     
  FileWrite ${CFG} "$R5$\n"
  FileWrite ${CFG} "POP3 Server$\n"
  FileWrite ${CFG} "$R7$\n"    
  FileClose ${CFG}
  
  WriteRegStr HKCU $R5 "POP3 User Name" "$R7${L_SEPARATOR}$R6" 
  WriteRegStr HKCU $R5 "POP3 Server" "127.0.0.1"

next_acct_increment:
  IntOp $R1 $R1 + 1
  goto next_acct

finished_this_id:
  ; Now move on to the next identity
  IntOp ${OEID} ${OEID} + 1
  goto next_id

finished_oe:

  !undef L_LNE
  !undef L_SEPARATOR
  !undef L_TEMP

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: StrStr
#
# Search for matching string
#
# Inputs:
#         (top of stack)     - the string to be found (needle)
#         (top of stack - 1) - the string to be searched (haystack)
# Outputs:
#         (top of stack)     - string starting with the match, if any
#
#  Usage:
#    Push "this is a long string"
#    Push "long"
#    Call StrStr
#    Pop $R0
#   ($R0 at this point is "long string")
#
#--------------------------------------------------------------------------

Function StrStr
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

#--------------------------------------------------------------------------
# Installer Function: StrCheckDecimal
#
# Checks that a given string contains only the digits 0 to 9.
# (if string contains any invalid characters, "" is returned)
#
# Inputs:
#         (top of stack)   - string which may contain a decimal number
#
# Outputs:
#         (top of stack)   - the input string (if valid) or "" (if invalid)
#
# Usage:
#         Push "12345"
#         Call StrCheckDecimal
#         Pop $R0
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

#--------------------------------------------------------------------------
# Macro: TrimNewlines
#
# The installation process and the uninstall process both
# use a function which trims newlines from lines of text.
# This macro makes maintenance easier by ensuring that
# both processes use identical functions, with the only
# difference being their names.
#--------------------------------------------------------------------------

  ; input, top of stack  (e.g. whatever$\r$\n)
  ; output, top of stack (replaces, with e.g. whatever)
  ; modifies no other variables.

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

#--------------------------------------------------------------------------
# Installer Function: TrimNewlines
#
# This function is used during the installation process
#--------------------------------------------------------------------------

!insertmacro TrimNewlines ""

#--------------------------------------------------------------------------
# Uninstaller Function: unTrimNewlines
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

!insertmacro TrimNewlines "un."

#--------------------------------------------------------------------------
# Uninstaller Section
#--------------------------------------------------------------------------

Section "Uninstall"

  IfFileExists $INSTDIR\popfile.pl skip_confirmation
    MessageBox MB_YESNO "It does not appear that POPFile is installed in the \
        directory '$INSTDIR'.$\r$\nContinue anyway (not recommended)" IDYES skip_confirmation
    Abort "Uninstall aborted by user"
skip_confirmation:

  Delete $SMPROGRAMS\POPFile\Support\*.url
  RMDir $SMPROGRAMS\POPFile\Support

  Delete $SMPROGRAMS\POPFile\*.lnk
  Delete $SMPROGRAMS\POPFile\*.url
  Delete "$SMSTARTUP\Run POPFile in background.lnk"
  RMDir $SMPROGRAMS\POPFile

  Delete $INSTDIR\*.log
  Delete $INSTDIR\*.pl
  Delete $INSTDIR\*.gif
  Delete $INSTDIR\*.pm
  Delete $INSTDIR\*.exe
  Delete $INSTDIR\*.dll
  Delete $INSTDIR\*.change
  Delete $INSTDIR\license
  Delete $INSTDIR\popfile.cfg

  ; Read the registry settings found in popfile.reg and restore them
  ; it there are any.   All are assumed to be in HKCU
  FileOpen ${CFG} $INSTDIR\popfile.reg r
  IfErrors skip_registry_restore
restore_loop:
  FileRead ${CFG} $R5
  Push $R5
  Call un.TrimNewlines
  Pop $R5
  IfErrors skip_registry_restore
  FileRead ${CFG} $R6
  Push $R6
  Call un.TrimNewlines
  Pop $R6
  IfErrors skip_registry_restore
  FileRead ${CFG} $R7
  Push $R7
  Call un.TrimNewlines
  Pop $R7
  IfErrors skip_registry_restore
  WriteRegStr HKCU $R5 $R6 $R7
  goto restore_loop

skip_registry_restore:
  FileClose ${CFG}
  Delete $INSTDIR\popfile.reg

  Delete $INSTDIR\Platform\*.pm
  Delete $INSTDIR\Platform\*.dll
  RMDir $INSTDIR\Platform
  Delete $INSTDIR\Proxy\*.pm
  RMDir $INSTDIR\Proxy
  Delete $INSTDIR\UI\*.pm
  RMDir $INSTDIR\UI
  Delete $INSTDIR\POPFile\*.pm
  RMDir $INSTDIR\POPFile
  Delete $INSTDIR\Classifier\*.pm
  RMDir $INSTDIR\Classifier
  Delete $INSTDIR\Exporter\*.*
  RMDir $INSTDIR\Exporter
  Delete $INSTDIR\skins\*.css
  Delete $INSTDIR\skins\*.gif
  Delete $INSTDIR\skins\lavishImages\*.gif
  Delete $INSTDIR\skins\sleetImages\*.gif
  RMDir $INSTDIR\skins\sleetImages
  RMDir $INSTDIR\skins\lavishImages
  RMDir $INSTDIR\skins
  Delete $INSTDIR\manual\en\*.html
  RMDir $INSTDIR\manual\en
  Delete $INSTDIR\manual\*.gif
  RMDir $INSTDIR\manual
  Delete $INSTDIR\languages\*.msg
  RMDir $INSTDIR\languages
  RMDir /r $INSTDIR\corpus
  Delete $INSTDIR\stopwords
  RMDir /r $INSTDIR\messages

  Delete $INSTDIR\Win32\API\*
  RmDir /r $INSTDIR\Win32\API
  Delete $INSTDIR\Win32\*
  RmDir /r $INSTDIR\Win32
  Delete $INSTDIR\auto\Win32\API\*
  RmDir /r $INSTDIR\auto\Win32\API
  Delete $INSTDIR\MIME\*.*
  RMDir  $INSTDIR\MIME
  Delete $INSTDIR\IO\*.*
  Delete $INSTDIR\IO\Socket\*.*
  RMDir /r $INSTDIR\IO
  Delete $INSTDIR\Carp\*.*
  RMDir /r $INSTDIR\Carp
  Delete $INSTDIR\Sys\Hostname\*.*
  RMDir /r $INSTDIR\Sys\Hostname
  RMDir /r $INSTDIR\Sys
  Delete $INSTDIR\Text\*.pm
  RMDir /r $INSTDIR\Text
  Delete $INSTDIR\auto\POSIX\*.*
  Delete $INSTDIR\auto\DynaLoader\*.*
  Delete $INSTDIR\auto\File\Glob\*.*
  Delete $INSTDIR\auto\MIME\Base64\*.*
  Delete $INSTDIR\auto\IO\*.*
  Delete $INSTDIR\auto\Socket\*.*
  Delete $INSTDIR\auto\Sys\*.*
  RMDir /r $INSTDIR\auto
  Delete $INSTDIR\File\*.*
  RMDir $INSTDIR\File
  Delete $INSTDIR\warnings\*.*
  RMDir $INSTDIR\warnings

  Delete "$INSTDIR\Uninstall.exe"

  RMDir $INSTDIR

  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_PRODUCT}"
  DeleteRegKey HKLM SOFTWARE\POPFile

  ; if $INSTDIR was removed, skip these next ones
  IfFileExists $INSTDIR 0 Removed
    MessageBox MB_YESNO|MB_ICONQUESTION \
      "Do you want to remove all files in your POPFile directory? (If you have anything \
you created that you want to keep, click No)" IDNO Removed
    Delete $INSTDIR\*.* ; this would be skipped if the user hits no
    RMDir /r $INSTDIR
    IfFileExists $INSTDIR 0 Removed
      MessageBox MB_OK|MB_ICONEXCLAMATION \
                 "Note: $INSTDIR could not be removed."
Removed:

  !insertmacro MUI_UNFINISHHEADER

SectionEnd

#--------------------------------------------------------------------------
# End of 'installer.nsi'
#--------------------------------------------------------------------------
