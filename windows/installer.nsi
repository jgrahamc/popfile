; installer.nsi

; The name of the installer
Name "POPFile Installer"

; The file to write
OutFile "setup.exe"

; The default installation directory
InstallDir $PROGRAMFILES\POPFile

; The text to prompt the user to enter a directory
DirText "This will install POPFile on your computer. Choose a directory where POPFile will be installed"

; The stuff to install
Section "ThisNameIsIgnoredSoWhyBother?"
  
  SetOutPath $INSTDIR
  File "..\engine\*.pl"
  File "..\engine\pix.gif"
  File "C:\Perl\bin\perl.exe"
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

  SetOutPath $INSTDIR
  CreateShortCut "$SMPROGRAMS\POPFile\Run POPFile.lnk" \
                 "$INSTDIR\perl.exe" popfile.pl
;  CreateShortCut "$SMPROGRAMS\POPFile\Run POPFile in background.lnk" \
;                 "$INSTDIR\wperl.exe" popfile.pl
;  WriteINIStr "$SMPROGRAMS\POPFile\POPFile User Interface.url" \
;              "InternetShortcut" "URL" "http://127.0.0.1:8080/"
;  WriteINIStr "$SMPROGRAMS\POPFile\Support\POPFile Home Page.url" \
;              "InternetShortcut" "URL" "http://popfile.sourceforge.net/"
;  WriteINIStr "$SMPROGRAMS\POPFile\Support\POPFile Manual.url" \
;              "InternetShortcut" "URL" "http://popfile.sourceforge.net/manual.html"
SectionEnd ; end the section

; eof
