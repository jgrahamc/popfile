!define MUI_PRODUCT "POPFile"
!define MUI_VERSION "0.17"

!include "${NSISDIR}\Contrib\Modern UI\System.nsh"

;--------------------------------
;Configuration
  
  !define MUI_COMPONENTSPAGE
  !define MUI_DIRECTORYPAGE
  !define MUI_ABORTWARNING
  
  !define MUI_UNINSTALLER
  
  !define MUI_CUSTOMPAGECOMMANDS
    
  !define POP3    $R0
  !define GUI     $R1
  !define STARTUP $R2
  !define CFG     $R3
  
  ;Language
  !insertmacro MUI_LANGUAGE "English"

  ;General
  OutFile "setup2.exe"
  
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

  ;Folder-selection page
  InstallDir "$PROGRAMFILES\${MUI_PRODUCT}"
  InstallDirRegKey HKLM SOFTWARE\POPFile InstallLocation
  
  ;Things that need to be extracted on startup (keep these lines before any File command!)
  ;Only useful for BZIP2 compression
  ;Use ReserveFile for your own Install Options ini files too!
  !insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
  ReserveFile "ioA.ini"
  ReserveFile "ioB.ini"

Function .onInit

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

  ; If the POP3 port is undefined then default it to 110
  StrCmp ${POP3} "" 0 skip_pop3_set 
      StrCpy ${POP3} "110"
skip_pop3_set:

  ; If the GUI port is undefined then default it to 8080
  StrCmp ${GUI} "" 0 skip_gui_set 
    StrCpy ${GUI} "8080"
skip_gui_set:

  WriteRegStr HKLM SOFTWARE\POPFile InstallLocation $INSTDIR

  SetOutPath $INSTDIR
  File "..\engine\*.pl"
  File "..\engine\pix.gif"
  File "..\engine\black.gif"
  
  FileOpen  ${CFG} $INSTDIR\popfile.cfg w
  FileWrite ${CFG} "port ${POP3}$\n"
  FileWrite ${CFG} "ui_port ${GUI}$\n"
  FileClose ${CFG}

  SetOutPath $INSTDIR\Classifier
  File "..\engine\Classifier\*.pm"

  SetOutPath $INSTDIR\manual
  File "..\engine\manual\*.html"

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
              "InternetShortcut" "URL" "file://$INSTDIR/manual/manual.html"
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
  File "C:\Perl\bin\perl.exe"
  File "C:\Perl\bin\wperl.exe"
  File "C:\Perl\bin\perl56.dll"
  File "C:\Perl\lib\AutoLoader.pm"
  File "C:\Perl\lib\Carp.pm"
  File "C:\Perl\lib\Config.pm"
  File "C:\Perl\lib\DynaLoader.pm"
  File "C:\Perl\lib\Errno.pm"
  File "C:\Perl\lib\Exporter.pm"
  File "C:\Perl\lib\IO.pm"
  File "C:\Perl\lib\locale.pm"
  File "C:\Perl\lib\SelectSaver.pm"
  File "C:\Perl\lib\Socket.pm"
  File "C:\Perl\lib\strict.pm"
  File "C:\Perl\lib\Symbol.pm"
  File "C:\Perl\lib\vars.pm"
  File "C:\Perl\lib\warnings.pm"
  File "C:\Perl\lib\XSLoader.pm"

  SetOutPath $INSTDIR\Exporter
  File "C:\Perl\lib\Exporter\*"

  SetOutPath $INSTDIR\IO
  File "C:\Perl\lib\IO\*"

  SetOutPath $INSTDIR\Sys
  File "C:\Perl\lib\Sys\*"

  SetOutPath $INSTDIR\IO\Socket
  File "C:\Perl\lib\IO\Socket\*"

  SetOutPath $INSTDIR\auto\DynaLoader
  File "C:\Perl\lib\auto\DynaLoader\*"
  
  SetOutPath $INSTDIR\auto\File\Glob
  File "C:\Perl\lib\auto\File\Glob\*"

  SetOutPath $INSTDIR\auto\IO
  File "C:\Perl\lib\auto\IO\*"

  SetOutPath $INSTDIR\auto\Socket
  File "C:\Perl\lib\auto\Socket\*"

  SetOutPath $INSTDIR\File
  File "C:\Perl\lib\File\Glob.pm"

  SetOutPath $INSTDIR\warnings
  File "C:\Perl\lib\warnings\register.pm"

SectionEnd

Section "Skins" SecSkins

  SetOutPath $INSTDIR\skins
  File "..\engine\skins\*.css"
  File "..\engine\skins\*.gif"

SectionEnd

!insertmacro MUI_SECTIONS_FINISHHEADER ;Insert this macro after the sections

;--------------------------------
;Descriptions

!insertmacro MUI_FUNCTIONS_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecPOPFile} $(DESC_SecPOPFile)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecPerl} $(DESC_SecPerl)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecSkins} $(DESC_SecSkins)
!insertmacro MUI_FUNCTIONS_DESCRIPTION_END

;--------------------------------
;Installer Functions

Function SetOptionsPage
  !insertmacro MUI_HEADER_TEXT "POPFile Installation Options" "Leave these options unchanged unless you need to change them"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioA.ini"
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


  Delete $INSTDIR\popfile.cfg
  Delete $INSTDIR\*.log
  Delete $INSTDIR\*.pl
  Delete $INSTDIR\*.gif
  Delete $INSTDIR\*.pm
  Delete $INSTDIR\*.exe
  Delete $INSTDIR\*.dll
  
  Delete $INSTDIR\Classifier\*.pm
  RMDir $INSTDIR\Classifier
  Delete $INSTDIR\Exporter\*.*
  RMDir $INSTDIR\Exporter
  Delete $INSTDIR\skins\*.css
  Delete $INSTDIR\skins\*.gif
  RMDir $INSTDIR\skins
  Delete $INSTDIR\manual\*.html
  RMDir $INSTDIR\manual

  Delete $INSTDIR\IO\*.*
  Delete $INSTDIR\IO\Socket\*.*
  RMDir /r $INSTDIR\IO
  Delete $INSTDIR\Sys\*.*
  RMDir /r $INSTDIR\Sys
  Delete $INSTDIR\auto\DynaLoader\*.*
  Delete $INSTDIR\auto\File\Glob\*.*
  Delete $INSTDIR\auto\IO\*.*
  Delete $INSTDIR\auto\Socket\*.*
  RMDir /r $INSTDIR\auto
  Delete $INSTDIR\File\*.*
  RMDir $INSTDIR\File
  Delete $INSTDIR\warnings\*.*
  RMDir $INSTDIR\warnings
  
  RMDir /r $INSTDIR\messages
  RMDir /r $INSTDIR\corpus
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