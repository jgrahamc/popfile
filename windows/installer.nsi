Name "POPFile Installer"
OutFile "setup.exe"
InstallDir $PROGRAMFILES\POPFile
ShowInstDetails show
ShowUninstDetails show

DirText "This will install POPFile on your computer. Choose a directory where POPFile will be installed"
Section "POPFile"
  
  SetOutPath $INSTDIR
  File "..\engine\*.pl"
  File "..\engine\pix.gif"
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
  File "C:\Perl\lib\SelectSaver.pm"
  File "C:\Perl\lib\Socket.pm"
  File "C:\Perl\lib\strict.pm"
  File "C:\Perl\lib\Symbol.pm"
  File "C:\Perl\lib\vars.pm"
  File "C:\Perl\lib\warnings.pm"
  File "C:\Perl\lib\XSLoader.pm"
  
  SetOutPath $INSTDIR\Classifier
  File "..\engine\Classifier\*.pm"

  SetOutPath $INSTDIR\Exporter
  File "C:\Perl\lib\Exporter\*"

  SetOutPath $INSTDIR\IO
  File "C:\Perl\lib\IO\*"

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
              "InternetShortcut" "URL" "http://127.0.0.1:8080/"
  SetOutPath $SMPROGRAMS\POPFile\Support
  WriteINIStr "$SMPROGRAMS\POPFile\Support\POPFile Home Page.url" \
              "InternetShortcut" "URL" "http://popfile.sourceforge.net/"
  WriteINIStr "$SMPROGRAMS\POPFile\Support\POPFile Manual.url" \
              "InternetShortcut" "URL" "http://popfile.sourceforge.net/manual.html"
              
  SetOutPath $INSTDIR
  Delete $INSTDIR\uninstall.exe 
  WriteUninstaller $INSTDIR\uninstall.exe

SectionEnd ; end the section

UninstallText "This will uninstall POPFile from your system:"
Section Uninstall
  IfFileExists $INSTDIR\popfile.pl skip_confirmation
    MessageBox MB_YESNO "It does not appear that POPFile is installed in the directory '$INSTDIR'.$\r$\nContinue anyway (not recommended)" IDYES skip_confirmation
    Abort "Uninstall aborted by user"
skip_confirmation:

  Delete $SMPROGRAMS\POPFile\Support\*.url
  RMDir $SMPROGRAMS\POPFile\Support

  Delete $SMPROGRAMS\POPFile\*.lnk
  Delete $SMPROGRAMS\POPFile\*.url
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

  Delete $INSTDIR\IO\*.*
  Delete $INSTDIR\IO\Socket\*.*
  RMDir /r $INSTDIR\IO
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
  RMDir $INSTDIR

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
SectionEnd

; eof
