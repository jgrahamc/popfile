;
; Copyright (c) 2001-2003 John Graham-Cumming
;

!define MUI_PRODUCT "POPFile" 
!define MUI_VERSION "0.18.0"

!include "${NSISDIR}\Contrib\Modern UI\System.nsh"

;--------------------------------
;Configuration
  
  !define MUI_COMPONENTSPAGE
  !define MUI_DIRECTORYPAGE
  !define MUI_ABORTWARNING
  
  !define MUI_UNINSTALLER
  
  !define MUI_CUSTOMPAGECOMMANDS
    
  !define POP3    $0
  !define GUI     $1
  !define STARTUP $2
  !define CFG     $3
  !define LNE     $4
  !define CMPRE   $5
  
  ;Language
  !insertmacro MUI_LANGUAGE "English"

  ;General
  OutFile "setup.exe"
  
  ;Install Options pages
  
    ;Header
    LangString TEXT_IO_TITLE ${LANG_ENGLISH} "Install Options Page"
    LangString TEXT_IO_SUBTITLE ${LANG_ENGLISH} "Options"
  
  ;Page order 
  !insertmacro MUI_PAGECOMMAND_COMPONENTS
  !insertmacro MUI_PAGECOMMAND_DIRECTORY
  Page custom SetOptionsPage  "Options"
  !insertmacro MUI_PAGECOMMAND_INSTFILES

  ;Component-selection page
    ;Descriptions
    LangString DESC_SecPOPFile ${LANG_ENGLISH} "Installs the core files needed by POPFile."
    LangString DESC_SecPerl    ${LANG_ENGLISH} "Installs minimal Perl needed by POPFile."
    LangString DESC_SecSkins   ${LANG_ENGLISH} "Installs POPFile skins that allow you to change the look and feel of the POPFile user interface."
    LangString DESC_SecLangs   ${LANG_ENGLISH} "Installs non-English language translations of the POPFile UI and manual."

  ;Folder-selection page
  InstallDir "$PROGRAMFILES\${MUI_PRODUCT}"
  InstallDirRegKey HKLM SOFTWARE\POPFile InstallLocation
  
  ;Things that need to be extracted on startup (keep these lines before any File command!)
  ;Only useful for BZIP2 compression
  ;Use ReserveFile for your own Install Options ini files too!
  !insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
  ReserveFile "ioA.ini"

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

  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioA.ini"
  
FunctionEnd

;--------------------------------
;Modern UI System

!insertmacro MUI_SYSTEM

;--------------------------------
;Installer Sections

Section "POPFile" SecPOPFile

  ; Retrieve the POP3 and GUI ports from the ini and get whether we install the
  ; POPFile run in the Startup group
  !insertmacro MUI_INSTALLOPTIONS_READ ${POP3}    "ioA.ini" "Field 2" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ ${GUI}     "ioA.ini" "Field 4" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ ${STARTUP} "ioA.ini" "Field 5" "State"

  WriteRegStr HKLM SOFTWARE\POPFile InstallLocation $INSTDIR

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

Section "Minimal Perl" SecPerl

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

SectionEnd

Section "Skins" SecSkins

  SetOutPath $INSTDIR\skins
  File "..\engine\skins\*.css"
  File "..\engine\skins\*.gif"

SectionEnd

Section "Languages" SecLangs

  SetOutPath $INSTDIR\languages
  File "..\engine\languages\*.msg"

  SetOutPath $INSTDIR\manual\br
  File "..\engine\manual\br\*.html"
  SetOutPath $INSTDIR\manual\de
  File "..\engine\manual\de\*.html"
  File "..\engine\manual\de\*.gif"
  SetOutPath $INSTDIR\manual\no
  File "..\engine\manual\no\*.html"
  SetOutPath $INSTDIR\manual\fr
  File "..\engine\manual\fr\*.html"

SectionEnd

!insertmacro MUI_SECTIONS_FINISHHEADER ;Insert this macro after the sections

;--------------------------------
;Descriptions

!insertmacro MUI_FUNCTIONS_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecPOPFile} $(DESC_SecPOPFile)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecPerl} $(DESC_SecPerl)
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
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY  "ioA.ini"
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
  Delete $INSTDIR\manual\br\*.html
  Delete $INSTDIR\manual\no\*.html
  Delete $INSTDIR\manual\fr\*.html
  Delete $INSTDIR\manual\de\*.html
  Delete $INSTDIR\manual\de\*.gif
  RMDir $INSTDIR\manual\en
  RMDir $INSTDIR\manual\br
  RMDir $INSTDIR\manual\no
  RMDir $INSTDIR\manual\fr
  RMDir $INSTDIR\manual\de
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