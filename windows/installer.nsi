;

; Copyright (c) 2001-2003 John Graham-Cumming

;

; Modified to work with NSIS v2.0b1

!define MUI_PRODUCT "POPFile" 

!define MUI_VERSION "0.18.1"

!include "MUI.nsh"

;--------------------------------

;Configuration

  

  !define MUI_WELCOMEPAGE

  !define MUI_COMPONENTSPAGE

  !define MUI_DIRECTORYPAGE

  !define MUI_ABORTWARNING

  !define MUI_FINISHPAGE

  

  !define MUI_UNINSTALLER

  

  !define MUI_CUSTOMPAGECOMMANDS

  ; Support for 20 user variables is provided by NSIS. They recommend using

  ; variables $0 to $9 as global variables and reserving $R0 to $R9 for

  ; use as local variables.

    

  !define POP3     $0

  !define GUI      $1

  !define STARTUP  $2

  !define CFG      $3

  !define LNE      $4

  !define CMPRE    $5

  !define OEID     $6

  !define ID       $7

  !define OEIDENT  $8

  !define ACCTID   $9

  

  ;Language

  !insertmacro MUI_LANGUAGEFILE_STRING MUI_TEXT_WELCOME_INFO_TEXT "This wizard will guide you through the installation of ${MUI_PRODUCT}.\r\n\r\nIt is recommended that you close all other applications before starting Setup.\r\n\r\n"
  !insertmacro MUI_LANGUAGE "English"

  ;General
  OutFile "setup.exe"
  
  ;Install Options pages
  
    ;Header
    LangString TEXT_IO_TITLE ${LANG_ENGLISH} "Install Options Page"
    LangString TEXT_IO_SUBTITLE ${LANG_ENGLISH} "Options"
  
  ;Page order 
  !insertmacro MUI_PAGECOMMAND_WELCOME
  !insertmacro MUI_PAGECOMMAND_COMPONENTS
  !insertmacro MUI_PAGECOMMAND_DIRECTORY
  Page custom SetOptionsPage  "Options"
  !insertmacro MUI_PAGECOMMAND_INSTFILES
  Page custom SetOutlookExpressPage  "Configure Outlook Express"
  !insertmacro MUI_PAGECOMMAND_FINISH

  ;Component-selection page
    ;Descriptions
    LangString DESC_SecPOPFile ${LANG_ENGLISH} "Installs the core files needed by POPFile, including a minimal version of Perl."
    LangString DESC_SecSkins   ${LANG_ENGLISH} "Installs POPFile skins that allow you to change the look and feel of the POPFile user interface."
    LangString DESC_SecLangs   ${LANG_ENGLISH} "Installs non-English language versions of the POPFile UI."

  ;Folder-selection page
  InstallDir "$PROGRAMFILES\${MUI_PRODUCT}"
  InstallDirRegKey HKLM SOFTWARE\POPFile InstallLocation
  
  ;Things that need to be extracted on startup (keep these lines before any File command!)
  ;Only useful for BZIP2 compression
  ;Use ReserveFile for your own Install Options ini files too!

  !insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
  !insertmacro MUI_RESERVEFILE_WELCOMEFINISHPAGE
  ReserveFile "ioA.ini"
  ReserveFile "ioB.ini"

Function .onInit

  ; See if we can get the current pop3 and gui port
  ; from an existing configuration
  FileOpen  ${CFG} $INSTDIR\popfile.cfg r

loop:
  FileRead   ${CFG} ${LNE}
  IfErrors done

  StrCpy ${CMPRE} ${LNE} 5
  StrCmp ${CMPRE} "port " got_port not_port   
got_port:
  StrCpy ${POP3} ${LNE} 5 5
  goto loop
  
not_port:
  StrCpy ${CMPRE} ${LNE} 8
  StrCmp ${CMPRE} "ui_port " got_ui_port loop   
got_ui_port:
  StrCpy ${GUI} ${LNE} 5 8
  
  goto loop

done:  
  FileClose ${CFG}

  ; If the POP3 port is undefined then default it to 110
  StrCmp ${POP3} "" 0 skip_pop3_set 
  StrCpy ${POP3} "110"
skip_pop3_set:

  ; If the GUI port is undefined then default it to 8080
  StrCmp ${GUI} "" 0 skip_gui_set 
  StrCpy ${GUI} "8080"
skip_gui_set:

  InitPluginsDir
  File /oname=$PLUGINSDIR\ioA.ini ioA.ini
  File /oname=$PLUGINSDIR\ioB.ini ioB.ini

FunctionEnd

;--------------------------------
;Modern UI System

!insertmacro MUI_SYSTEM

;--------------------------------
;Installer Sections

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
  File "..\engine\*.pl"
  File "..\engine\pix.gif"
  File "..\engine\black.gif"
  
  FileOpen  ${CFG} $INSTDIR\popfile.cfg a
  FileSeek  ${CFG} 0 END
  FileWrite ${CFG} "port ${POP3}$\n"
  FileWrite ${CFG} "ui_port ${GUI}$\n"
  FileClose ${CFG}

  SetOutPath $INSTDIR\Classifier
  File "..\engine\Classifier\Bayes.pm"
  File "..\engine\Classifier\WordMangle.pm"
  File "..\engine\Classifier\MailParse.pm"
  SetOutPath $INSTDIR\POPFile
  File "..\engine\POPFile\Logger.pm"
  File "..\engine\POPFile\Configuration.pm"
  SetOutPath $INSTDIR\Proxy
  File "..\engine\Proxy\POP3.pm"
  SetOutPath $INSTDIR\UI
  File "..\engine\UI\HTML.pm"

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
  SetOutPath $SMPROGRAMS\POPFile\Support
  WriteINIStr "$SMPROGRAMS\POPFile\Support\POPFile Home Page.url" \
              "InternetShortcut" "URL" "http://popfile.sourceforge.net/"
  WriteINIStr "$SMPROGRAMS\POPFile\Support\POPFile Manual.url" \
              "InternetShortcut" "URL" "http://popfile.sourceforge.net/manual.html"

  StrCmp ${STARTUP} "1" 0 skip_autostart_set 
      SetOutPath $SMSTARTUP
      SetOutPath $INSTDIR
      CreateShortCut "$SMSTARTUP\Run POPFile in background.lnk" \
                     "$INSTDIR\wperl.exe" popfile.pl
skip_autostart_set:
              
  SetOutPath $INSTDIR
  Delete $INSTDIR\uninstall.exe 
  WriteUninstaller $INSTDIR\uninstall.exe

SectionEnd

Section "Skins" SecSkins

  SetOutPath $INSTDIR\skins
  File "..\engine\skins\*.css"
  File "..\engine\skins\*.gif"

SectionEnd

Section "Languages" SecLangs

  SetOutPath $INSTDIR\languages
  File "..\engine\languages\*.msg"

SectionEnd

;--------------------------------
;Descriptions

!insertmacro MUI_FUNCTIONS_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecPOPFile} $(DESC_SecPOPFile)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecSkins} $(DESC_SecSkins)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecLangs} $(DESC_SecLangs)
!insertmacro MUI_FUNCTIONS_DESCRIPTION_END

;--------------------------------
;Installer Functions

Function SetOptionsPage
  !insertmacro MUI_HEADER_TEXT "POPFile Installation Options" "Leave these options unchanged unless you need to change them"
  !insertmacro MUI_INSTALLOPTIONS_READ $R5 "ioA.ini" "Field 2" "ListItems"
  StrCpy $R5 $R5|${POP3}
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioA.ini" "Field 2" "ListItems" $R5
  !insertmacro MUI_INSTALLOPTIONS_READ $R5 "ioA.ini" "Field 4" "ListItems"
  StrCpy $R5 $R5|${GUI}
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioA.ini" "Field 4" "ListItems" $R5
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioA.ini" "Field 2" "State" ${POP3}
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioA.ini" "Field 4" "State" ${GUI}

  Push $R0
  InstallOptions::dialog $PLUGINSDIR\ioA.ini
  Pop $R0
FunctionEnd

; This function is used to reconfigure Outlook Express accounts

Function SetOutlookExpressPage

  ; In Outlook Express (v5.0 or later) the email account data may appear in
  ; more than one place, depending upon how Outlook Express has been configured.

  ; First we check the "Main Identity" (also known as the "Default Identity")
  ; which is created when Outlook Express is installed. Note that this identity
  ; may no longer be active, as users are free to delete it after creating
  ; an additional identity and switching to the new one.

  ; The Outlook Express "Main Identity" does not use an "identity number"
  StrCpy ${OEIDENT} ""
  Call CheckOutlookExpressAccounts

  ; Now we have to check if any additional identities have been created in
  ; Outlook Express.  These identities are kept in HKEY_CURRENT_USER\Identities.
  ; If we find any extra identities, we need to see if any of them have email
  ; accounts we can reconfigure for use with POPFile.

  StrCpy ${OEID} 0
  
  ; Get the next identity from the registry

next_id:  
  EnumRegKey ${ID} HKCU "Identities" ${OEID}
  StrCmp ${ID} "" finished_oe

  ; Now check all of the accounts for this particular identity
  StrCpy ${OEIDENT} "Identities\${ID}\"
  Call CheckOutlookExpressAccounts

  ; Now move on to the next identity
  IntOp ${OEID} ${OEID} + 1
  goto next_id

finished_oe:
FunctionEnd

; This function checks all the accounts for a particular Outlook Express identity

Function CheckOutlookExpressAccounts

  ; Called by SetOutLookExpressPage to check all of the accounts for a given
  ; Outlook Express identity: either the "Main Identity", when ${OEIDENT} is
  ; a null string (""), or one of the "Additional Identities", when ${OEIDENT}
  ; is a string such as "Identities\{AB734464-478F-11D7-81C3-00409545B64C}\"

  ; The email account data for all identities, although stored in different
  ; locations, uses the same structure. The "path" for each identity starts
  ; with "HKEY_CURRENT_USER\" and ends with "\Internet Account Manager\Accounts".

  ; OE account data for each identity appears "under" the path defined above, e.g.
  ;    HKEY_CURRENT_USER\...\Internet Account Manager\Accounts\00000001
  ;    HKEY_CURRENT_USER\...\Internet Account Manager\Accounts\00000002
  ;    HKEY_CURRENT_USER\...\Internet Account Manager\Accounts\00000003
  ;    etc

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

  !insertmacro MUI_HEADER_TEXT "Reconfigure Outlook Express" "POPFile can reconfigure Outlook Express for you"
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 2" "State" "0"
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 8" "Text" $R6
  ReadRegStr $R6 HKCU $R5 "SMTP Email Address"
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 7" "Text" $R6
  ReadRegStr $R6 HKCU $R5 "POP3 User Name"
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 9" "Text" $R6
  ReadRegStr $R6 HKCU $R5 "Account Name"
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 10" "Text" $R6
  Push $R0
  InstallOptions::dialog $PLUGINSDIR\ioB.ini
  Pop $R0
  
  StrCmp $R0 "cancel" finished_this_id
  StrCmp $R0 "back" finished_this_id

  !insertmacro MUI_INSTALLOPTIONS_READ $R5 "ioB.ini" "Field 2" "State"
  StrCmp $R5 "1" change_oe next_acct_increment

change_oe:
  StrCpy $R5 "${OEIDENT}Software\Microsoft\Internet Account Manager\Accounts\${ACCTID}"
  ReadRegStr $R6 HKCU $R5 "POP3 User Name"
  ReadRegStr $R7 HKCU $R5 "POP3 Server"
  WriteRegStr HKCU $R5 "POP3 User Name" "$R7:$R6" 
  WriteRegStr HKCU $R5 "POP3 Server" "127.0.0.1"

next_acct_increment:
  IntOp $R1 $R1 + 1
  goto next_acct

finished_this_id:
FunctionEnd

;--------------------------------
;Uninstaller Section

Section "Uninstall"

  IfFileExists $INSTDIR\popfile.pl skip_confirmation
    MessageBox MB_YESNO "It does not appear that POPFile is installed in the directory '$INSTDIR'.$\r$\nContinue anyway (not recommended)" IDYES skip_confirmation
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
  Delete $INSTDIR\popfile.cfg
  
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
  RMDir $INSTDIR\skins
  Delete $INSTDIR\manual\en\*.html
  RMDir $INSTDIR\manual\en
  Delete $INSTDIR\manual\*.gif
  RMDir $INSTDIR\manual
  Delete $INSTDIR\languages\*.msg
  RMDir $INSTDIR\languages

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
  
  Delete "$INSTDIR\modern.exe"
  Delete "$INSTDIR\Uninstall.exe"

  RMDir $INSTDIR

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

;eof

