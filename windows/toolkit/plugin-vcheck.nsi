#------------------------------------------------------------------------------------
#
# plugin-vcheck.nsi --- This utility creates an INCLUDE file ('plugin-status.nsh')
#                       which can be used by 'installer.nsi' (and other NSIS scripts)
#                       at compile-time to ensure that the NSIS compiler is using the
#                       correct versions of the extra (i.e. not shipped with NSIS)
#                       plugins used by the installer and other NSIS-based programs.
#
#                       NOTE:
#                          The INCLUDE file ('plugin-status.nsh') will be created
#                          (or updated) in the current working directory.
#
# Copyright (c) 2011-2012  John Graham-Cumming
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify it
#   under the terms of version 2 of the GNU General Public License as
#   published by the Free Software Foundation.
#
#   POPFile is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with POPFile; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#------------------------------------------------------------------------------------

  ##########################################################################
  #
  # IMPORTANT NOTE:
  #
  # This list of plugins has been copied from POPFile 1.x and needs
  # to be updated for POPFile 2.x (e.g. POPFile 2.x's installer will be
  # built using NSIS 2.46 and may require a different selection of NSIS
  # plugins or newer versions of some NSIS plugins).
  #
  ##########################################################################

  ;--------------------------------------------------------------------------
  ; List of the plugin files to be checked (in '${NSISDIR}\Plugins\' folder):
  ;--------------------------------------------------------------------------
  ; [  1 ]  AccessControl.dll
  ; [  2 ]  DumpLog.dll
  ; [  3 ]  dumpstate.dll
  ; [  4 ]  getsize.dll
  ; [  5 ]  GetVersion.dll
  ; [  6 ]  inetc.dll
  ; [  7 ]  LockedList.dll
  ; [  8 ]  md5dll.dll
  ; [  9 ]  MoreInfo.dll
  ; [ 10 ]  nsUnzip.dll
  ; [ 11 ]  ShellLink.dll
  ; [ 12 ]  SimpleSC.dll
  ; [ 13 ]  UAC.dll
  ; [ 14 ]  untgz.dll
  ;--------------------------------------------------------------------------
  ; 'AccessControl' NSIS plugin
  ;--------------------------------------------------------------------------
  ; The UAC plugin works by running an 'outer' installer at the 'standard user'
  ; level and an 'inner' installer at the 'admin' level. To support two-way
  ; communication between these two installer instances the 'inner' one creates
  ; a temporary file in the 'All Users' data folder and uses the 'AccessControl'
  ; plugin to grant the 'outer' installer Read/Write access to this temporary file.
  ;
  ; A similar method is used by the two instances of the POPFile uninstaller.
  ;
  ; The 'NSIS Wiki' page for the 'AccessControl' plugin (description, example and
  ; download links):
  ;          http://nsis.sourceforge.net/AccessControl_plug-in
  ;
  ; The plugin's history can be found at
  ;          http://nsis.sourceforge.net/File:AccessControl.zip
  ;--------------------------------------------------------------------------
  ; 'DumpLog' NSIS plugin
  ;--------------------------------------------------------------------------
  ; This plugin saves the installation log to a file and is much, much faster
  ; than the 'Dump Content of Log Window to File' function shown in the NSIS
  ; Users Manual (see section D.4 in Appendix D of the manual for NSIS 2.45).
  ;
  ; The 'NSIS Wiki' page for the 'DumpLog' plugin (description, example and
  ; download links):
  ;          http://nsis.sourceforge.net/DumpLog_plug-in
  ;
  ; The plugin's history can be found at
  ;          http://nsis.sourceforge.net/File:DumpLog.zip
  ;--------------------------------------------------------------------------
  ; 'dumpstate' NSIS plugin
  ;--------------------------------------------------------------------------
  ; This plugin is a very useful debug utility which not only shows the current
  ; state of the standard NSIS variables and stack but allows them to be changed.
  ;
  ; The 'NSIS Wiki' page for the 'dumpstate' plugin (description, example and
  ; download links):
  ;          http://nsis.sourceforge.net/DumpState_plug-in
  ;
  ; The plugin's history can be found at
  ;          http://nsis.sourceforge.net/File:Dumpstate-0-1-.2.zip
  ;--------------------------------------------------------------------------
  ; 'GetSize' NSIS plugin
  ;--------------------------------------------------------------------------
  ; This plugin is used to find the size of the SQLite database file.
  ;
  ; 'GetSize' plugin thread in the "NSIS Discussion" forum:
  ;          http://forums.winamp.com/showthread.php?threadid=224452
  ;
  ; 'GetSize' plugin download link (from the above forum thread):
  ;          http://forums.winamp.com/attachment.php?postid=1756112
  ;
  ; The 'GetSize' plugin has not been added to the NSIS Wiki. The plugin's
  ; author decided to include its functions in a much larger general purpose
  ; plugin (Locate). This enhanced plugin (it is more than 3 times the size
  ; of 'GetSize') has been added to the NSIS Wiki:
  ;          http://nsis.sourceforge.net/Locate_plugin
  ;--------------------------------------------------------------------------
  ; 'GetVersion' NSIS plugin
  ;--------------------------------------------------------------------------
  ; This plugin is used to identify the Windows version found on the target machine.
  ;
  ; The 'NSIS Wiki' page for the 'GetVersion' plugin (description, example and
  ; download links):
  ;          http://nsis.sourceforge.net/GetVersion_(Windows)_plug-in
  ;
  ; The plugin's history can be found at
  ;          http://nsis.sourceforge.net/File:GetVersion.zip
  ;--------------------------------------------------------------------------
  ; 'Inetc' NSIS plugin
  ;--------------------------------------------------------------------------
  ; This plugin is used to download files and to silently access the POPFile
  ; UI's 'Shutdown' page. The 'Inetc' plugin has much better proxy support than
  ; the standard 'NSISdl' plugin shipped with NSIS.
  ;
  ; The 'NSIS Wiki' page for the 'Inetc' plugin (description, example and
  ; download links):
  ;          http://nsis.sourceforge.net/Inetc_plug-in
  ;
  ; The plugin's history can be found at
  ;          http://nsis.sourceforge.net/File:Inetc.zip
  ;--------------------------------------------------------------------------
  ; 'LockedList' NSIS plugin
  ;--------------------------------------------------------------------------
  ; This plugin is used to check if a particular POPFile file (usually an EXE file)
  ; is being used. There are several different ways to run POPFile so a list of
  ; programs (specified using the full pathname) needs to be checked.
  ;
  ; The 'NSIS Wiki' page for the 'LockedList' plugin (description and download
  ; links):
  ;          http://nsis.sourceforge.net/LockedList_plug-in
  ;
  ; The plugin's history can be found at
  ;          http://nsis.sourceforge.net/File:LockedList.zip
  ;--------------------------------------------------------------------------
  ; 'md5dll' NSIS plugin
  ;--------------------------------------------------------------------------
  ; This plugin is used to calculate the MD5 checksum for a file. It is used
  ; at compile time to verify the correct set of extra NSIS plugins is being
  ; used and at run time to check the status of the files for the 'MeCab' package
  ; (one of the optional parsers provided to handle Japanese text).
  ;
  ; The 'NSIS Wiki' page for the 'md5dll' plugin (description, example and
  ; download links):
  ;          http://nsis.sourceforge.net/MD5_plugin
  ;
  ; The plugin's history can be found at
  ;          http://nsis.sourceforge.net/File:md5dll.zip
  ;--------------------------------------------------------------------------
  ; 'MoreInfo' NSIS plugin
  ;--------------------------------------------------------------------------
  ; This plugin is used to extract version information from an executable.
  ;
  ; The 'NSIS Wiki' page for the 'md5dll' plugin (description, example and
  ; download links):
  ;          http://nsis.sourceforge.net/MoreInfo_plugin
  ;--------------------------------------------------------------------------
  ; 'nsUnzip' NSIS plugin
  ;--------------------------------------------------------------------------
  ; POPFile currently offers a choice of three parsers for Japanese (Nihongo)
  ; text: internal, Kakasi and MeCab. The installer includes all of the files
  ; for the first two parsers but the MeCab package is too big to include. This
  ; plugin is used to extract the dictionary files from the MeCab archive after
  ; it has been downloaded from the POPFile web site.
  ;
  ; The 'NSIS Wiki' page for the 'nsUnzip' plugin (description and download
  ; links):
  ;          http://nsis.sourceforge.net/NsUnzip_plugin
  ;
  ; The plugin's history can be found at
  ;          http://nsis.sourceforge.net/File:nsUnzip.zip
  ;--------------------------------------------------------------------------
  ; 'ShellLink' NSIS plugin
  ;--------------------------------------------------------------------------
  ; This plugin is used to read shell link (.lnk) files. It can also be used
  ; to change these files but at present this feature is not used by POPFile.
  ;
  ; The 'NSIS Wiki' page for the 'ShellLink' plugin (description and download
  ; links):
  ;          http://nsis.sourceforge.net/ShellLink_plugin
  ;
  ; The plugin's history can be found at
  ;          http://nsis.sourceforge.net/File:Shelllink.zip
  ;--------------------------------------------------------------------------
  ; 'SimpleSC' NSIS plugin
  ;--------------------------------------------------------------------------
  ; This plugin contains basic service functions like start, stop the service
  ; or checking the service status. It also contains advanced service functions
  ; for example setting the service description, changed the logon account,
  ; granting or removing the service logon privilege.
  ;
  ; The 'NSIS Wiki' page for the 'SimpleSC' plugin (description and download
  ; links):
  ;          http://nsis.sourceforge.net/NSIS_Simple_Service_Plugin
  ;
  ; The plugin's history is not easy to track because each release uses a
  ; different filename (e.g. NSIS_Simple_Service_Plugin_1.29.zip)
  ;--------------------------------------------------------------------------
  ; 'UAC' NSIS plugin
  ;--------------------------------------------------------------------------
  ; The new 'User Account Control' (UAC) feature in Windows Vista makes it
  ; difficult to install POPFile from a 'standard' user account. This script uses
  ; a special NSIS plugin (UAC) which allows the 'POPFile program files' part of
  ; the installation to be run at the 'admin' level and the user-specific POPFile
  ; configuration part to be run at the 'user' level.
  ;
  ; The 'NSIS Wiki' page for the 'UAC' plugin (description, example and download
  ; links):
  ;          http://nsis.sourceforge.net/UAC_plug-in
  ;--------------------------------------------------------------------------
  ; 'untgz' NSIS plugin
  ;--------------------------------------------------------------------------
  ; This plugin is used to extract files from the *.tar.gz archives. It is used
  ; to extract some files from the MeCab package (an optional Japanese parser).
  ;
  ; The 'NSIS Wiki' page for the 'untgz' plugin (description, example and
  ; download links):
  ;          http://nsis.sourceforge.net/UnTGZ_plug-in
  ;
  ; The plugin's history can be found at
  ;          http://nsis.sourceforge.net/File:Untgz.zip
  ;--------------------------------------------------------------------------

  ;--------------------------------------------------------------------------
  ; MD5 Checksum file format
  ;--------------------------------------------------------------------------
  ; The list of plugins to be checked and their expected MD5 checksums
  ; is read from the file 'extra-plugins.md5' stored in the same folder
  ; as this utility. Each plugin has an entry like this:
  ;
  ;    9a7d35d1e9e5dfb6a7872d49cf64db83 *inetc.dll
  ;
  ; Lines starting with '#' or ';' in 'extra-plugins.md5' are ignored,
  ; as are empty lines.
  ;
  ; Lines in 'extra-plugins.md5' which contain MD5 sums are assumed to be
  ; in this format:
  ;
  ; (a) positions 1 to 32 contain a 32 character hexadecimal number (line starts in column 1)
  ; (b) column 33 is a space character (' ')
  ; (c) column 34 is the text/binary flag (' ' = text, '*' = binary)
  ; (d) column 35 is the first character of the filename (filename terminates with end-of-line)
  ;--------------------------------------------------------------------------

  ; This version of the script has been tested with the "NSIS v2.46" compiler,
  ; released 6 December 2009. This particular compiler can be downloaded from
  ; http://prdownloads.sourceforge.net/nsis/nsis-2.46-setup.exe?download

  !define C_EXPECTED_VERSION  "v2.46"

  !define ${NSIS_VERSION}_found

  !ifndef ${C_EXPECTED_VERSION}_found
      !warning \
          "$\n\
          $\n***   NSIS COMPILER WARNING:\
          $\n***\
          $\n***   This script has only been tested using the NSIS ${C_EXPECTED_VERSION} compiler\
          $\n***   and may not work properly with this NSIS ${NSIS_VERSION} compiler\
          $\n***\
          $\n***   The resulting 'installer' program should be tested carefully!\
          $\n$\n"
  !endif

  !undef  ${NSIS_VERSION}_found
  !undef  C_EXPECTED_VERSION

  ;--------------------------------------------------------------------------
  ; Symbol used to avoid confusion over where the line breaks occur.
  ;
  ; ${LF}    is used for simple 'line-feed' characters.
  ;
  ; (this constant does not follow the 'C_' naming convention described below)
  ;--------------------------------------------------------------------------

  !define LF      "$\n"

  ;--------------------------------------------------------------------------
  ; POPFile constants have been given names beginning with 'C_' (eg C_README)
  ;--------------------------------------------------------------------------

  !define C_VERSION       "1.0.0"     ; see 'VIProductVersion' below for format details
  !define C_OUTFILE       "plugin-vcheck.exe"

  !define C_RESULTS_FILE  "plugin-status.nsh"

  Name "NSIS Extra Plugin Status Check ${C_VERSION}"

  ; Specify EXE filename and icon for the 'installer'

  OutFile "${C_OUTFILE}"

  Icon "..\POPFileIcon\popfile.ico"

  ; Selecting 'silent' mode makes the installer behave like a command-line utility

  SilentInstall silent

  ;--------------------------------------------------------------------------
  ; Windows Vista and Windows 7 expect to find a manifest specifying the execution level
  ;--------------------------------------------------------------------------

  RequestExecutionLevel   user

#------------------------------------------------------------------------------------
# Include private library functions and macro definitions
#------------------------------------------------------------------------------------

  ; Avoid compiler warnings by disabling the functions and definitions we do not use

  !define PLUGINCHECK

  !include "..\pfi-library.nsh"
  !include "..\pfi-nsis-library.nsh"

#------------------------------------------------------------------------------------

  ; 'VIProductVersion' format is X.X.X.X where X is a number in range 0 to 65535
  ; representing the following values: Major.Minor.Release.Build

  VIProductVersion                          "${C_VERSION}.0"

  !define /date C_BUILD_YEAR                "%Y"

  VIAddVersionKey "ProductName"             "NSIS Extra Plugin Status Check Utility"
  VIAddVersionKey "Comments"                "POPFile Homepage: http://getpopfile.org/"
  VIAddVersionKey "CompanyName"             "The POPFile Project"
  VIAddVersionKey "LegalTrademarks"         "POPFile is a registered trademark of \
                                             John Graham-Cumming"
  VIAddVersionKey "LegalCopyright"          "Copyright (c) ${C_BUILD_YEAR}  John Graham-Cumming"
  VIAddVersionKey "FileDescription"         "Used when compiling the POPFile installer"
  VIAddVersionKey "FileVersion"             "${C_VERSION}"
  VIAddVersionKey "OriginalFilename"        "${C_OUTFILE}"

  VIAddVersionKey "Build Compiler"           "NSIS ${NSIS_VERSION}"
  VIAddVersionKey "Build Date/Time"         "${__DATE__} @ ${__TIME__}"
  !ifdef C_PFI_LIBRARY_VERSION
    VIAddVersionKey "Build Library Version" "${C_PFI_LIBRARY_VERSION}"
  !endif
  !ifdef C_NSIS_LIBRARY_VERSION
    VIAddVersionKey "NSIS Library Version"  "${C_NSIS_LIBRARY_VERSION}"
  !endif
  VIAddVersionKey "Build Script"            "${__FILE__}$\r${LF}(${__TIMESTAMP__})" ;need CRLF here!

#------------------------------------------------------------------------------------

Section default

  !define C_SPACER_A        "   "
  !define C_SPACER_B        "      "

  !define L_DATA            $R9
  !define L_EXPECTED_MD5    $R8   ; the expected MD5 sum for the file
  !define L_FILEPATH        $R7   ; path to the file to be checked
  !define L_HANDLE          $R6   ; handle used to access the MD5 sums file
  !define L_INCORRECT_COUNT $R5
  !define L_INCORRECT_LIST  $R4
  !define L_MISSING_COUNT   $R3
  !define L_MISSING_LIST    $R2
  !define L_PLUGIN_NAME     $R1
  !define L_RESULT          $R0
  !define L_RESULTS_FILE    $9    ; File handle used to access the output file
  !define L_TEMP            $8
  !define L_TEXT            $7

  Push ${L_DATA}
  Push ${L_EXPECTED_MD5}
  Push ${L_FILEPATH}
  Push ${L_HANDLE}
  Push ${L_INCORRECT_COUNT}
  Push ${L_INCORRECT_LIST}
  Push ${L_MISSING_COUNT}
  Push ${L_MISSING_LIST}
  Push ${L_PLUGIN_NAME}
  Push ${L_RESULT}
  Push ${L_RESULTS_FILE}
  Push ${L_TEMP}
  Push ${L_TEXT}

  InitPluginsDir

  FileOpen ${L_RESULTS_FILE} "$PLUGINSDIR\${C_RESULTS_FILE}" w

  FileWrite ${L_RESULTS_FILE} "!ifndef LF${LF}"
  FileWrite ${L_RESULTS_FILE} "  !define C_PLUGIN_LF${LF}"
  FileWrite ${L_RESULTS_FILE} "  !define LF $\"$$"
  FileWrite ${L_RESULTS_FILE} "\n$\"${LF}"
  FileWrite ${L_RESULTS_FILE} "!endif${LF}${LF}"

  IfFileExists "$EXEDIR\extra-plugins.md5" found_checksums
  FileWrite ${L_RESULTS_FILE} "!define C_PLUGIN_CHECKSUMS $\"missing$\"${LF}${LF}"

  StrCpy ${L_RESULT} "$$"
  StrCpy ${L_RESULT} "${L_RESULT}{LF}$$"
  StrCpy ${L_RESULT} "${L_RESULT}{LF}${C_SPACER_A}*** Fatal Error ***$$"
  StrCpy ${L_RESULT} "${L_RESULT}{LF}$$"
  StrCpy ${L_RESULT} "${L_RESULT}{LF}"
  StrCpy ${L_RESULT} "${L_RESULT}${C_SPACER_A}Checksum file ('extra-plugins.md5') is missing!$$"
  StrCpy ${L_RESULT} "${L_RESULT}{LF}$$"
  StrCpy ${L_RESULT} "${L_RESULT}{LF}${C_SPACER_A}($EXEDIR\extra-plugins.md5)"
  Goto print_result

found_checksums:
  FileWrite ${L_RESULTS_FILE}  "!define C_PLUGIN_CHECKSUMS $\"found$\"${LF}${LF}"

  StrCpy ${L_MISSING_LIST}    "$$"
  StrCpy ${L_MISSING_LIST}    "${L_MISSING_LIST}{LF}"
  StrCpy ${L_INCORRECT_LIST}  "${L_MISSING_LIST}"

  SetPluginUnload alwaysoff

  StrCpy ${L_INCORRECT_COUNT} 0
  StrCpy ${L_MISSING_COUNT}   0

  FileOpen ${L_HANDLE} "$EXEDIR\extra-plugins.md5" r

read_next_line:
  FileRead ${L_HANDLE} ${L_DATA}
  StrCmp ${L_DATA} "" end_of_file
  StrCpy ${L_TEMP} ${L_DATA} 1
  StrCmp ${L_TEMP} '#' read_next_line
  StrCmp ${L_TEMP} ';' read_next_line
  Push ${L_DATA}
  Call NSIS_TrimNewlines
  Pop ${L_DATA}
  StrCmp ${L_DATA} "" read_next_line
  StrCpy ${L_FILEPATH} ${L_DATA} "" 34       ; NSIS strings start at position 0 not 1
  StrCpy ${L_PLUGIN_NAME} ${L_FILEPATH} -4
  StrCpy ${L_FILEPATH} "${NSISDIR}\Plugins\${L_FILEPATH}"
  IfFileExists "${L_FILEPATH}" get_expected_MD5
  IntOp ${L_MISSING_COUNT} ${L_MISSING_COUNT} + 1
  StrCpy ${L_MISSING_LIST} "${L_MISSING_LIST}$$"
  StrCpy ${L_MISSING_LIST} "${L_MISSING_LIST}{LF}${C_SPACER_B}${L_PLUGIN_NAME}"
  Goto read_next_line

get_expected_MD5:
  StrCpy ${L_EXPECTED_MD5} ${L_DATA} 32
  Push ${L_EXPECTED_MD5}
  Call PFI_StrCheckHexadecimal
  Pop ${L_EXPECTED_MD5}
  md5dll::GetMD5File "${L_FILEPATH}"
  Pop ${L_TEMP}
  StrCmp ${L_EXPECTED_MD5} ${L_TEMP} read_next_line
  IntOp ${L_INCORRECT_COUNT} ${L_INCORRECT_COUNT} + 1
  StrCpy ${L_INCORRECT_LIST} "${L_INCORRECT_LIST}$$"
  StrCpy ${L_INCORRECT_LIST} "${L_INCORRECT_LIST}{LF}${C_SPACER_B}${L_PLUGIN_NAME}"
  Goto read_next_line

end_of_file:
  FileClose ${L_HANDLE}

  IntCmp ${L_MISSING_COUNT} 1 one_missing none_missing several_missing

one_missing:
  StrCpy ${L_TEXT} "The following NSIS plugin is missing:"
  Goto update_missing_text

several_missing:
  StrCpy ${L_TEXT} "The following ${L_MISSING_COUNT} NSIS plugins are missing:"

update_missing_text:
  StrCpy ${L_RESULT} "$$"
  StrCpy ${L_RESULT} "${L_RESULT}{LF}$$"
  StrCpy ${L_RESULT} "${L_RESULT}{LF}${C_SPACER_A}*** Fatal Error ***$$"
  StrCpy ${L_RESULT} "${L_RESULT}{LF}$$"
  StrCpy ${L_RESULT} "${L_RESULT}{LF}"
  StrCpy ${L_RESULT} "${L_RESULT}${C_SPACER_A}${L_TEXT}${L_MISSING_LIST}"

  IntCmp ${L_INCORRECT_COUNT} 1 add_one_incorrect print_result add_several_incorrect

add_one_incorrect:
  StrCpy ${L_TEXT} "NSIS is using an incorrect version of the following plugin:"
  Goto add_incorrect_text

add_several_incorrect:
  StrCpy ${L_TEXT} "NSIS is using incorrect versions of the following ${L_INCORRECT_COUNT} plugins:"

add_incorrect_text:
  StrCpy ${L_RESULT} "${L_RESULT}$$"
  StrCpy ${L_RESULT} "${L_RESULT}{LF}$$"
  StrCpy ${L_RESULT} "${L_RESULT}{LF}${C_SPACER_A}${L_TEXT}${L_INCORRECT_LIST}"
  Goto print_result

none_missing:
  IntCmp ${L_INCORRECT_COUNT} 1 only_one_incorrect no_problems only_several_incorrect

only_one_incorrect:
  StrCpy ${L_TEXT} "NSIS is using an incorrect version of the following plugin:"
  Goto update_incorrect_text

only_several_incorrect:
  StrCpy ${L_TEXT} "NSIS is using incorrect versions of the following ${L_INCORRECT_COUNT} plugins:"

update_incorrect_text:
  StrCpy ${L_RESULT} "$$"
  StrCpy ${L_RESULT} "${L_RESULT}{LF}$$"
  StrCpy ${L_RESULT} "${L_RESULT}{LF}${C_SPACER_A}*** Fatal Error ***$$"
  StrCpy ${L_RESULT} "${L_RESULT}{LF}$$"
  StrCpy ${L_RESULT} "${L_RESULT}{LF}"
  StrCpy ${L_RESULT} "${L_RESULT}${C_SPACER_A}${L_TEXT}${L_INCORRECT_LIST}"
  Goto print_result

no_problems:
  StrCpy ${L_RESULT} '!echo $\"$$'
  StrCpy ${L_RESULT} '${L_RESULT}{LF}$$'
  StrCpy ${L_RESULT} '${L_RESULT}{LF}Extra NSIS plugins all present and correct!$$'
  StrCpy ${L_RESULT} '${L_RESULT}{LF}$$'
  StrCpy ${L_RESULT} '${L_RESULT}{LF}$$'
  StrCpy ${L_RESULT} '${L_RESULT}{LF}$\"'
  FileWrite ${L_RESULTS_FILE} ${L_RESULT}${LF}
  Goto print_undefs

print_result:
  StrCpy ${L_RESULT} "${L_RESULT}$$"
  StrCpy ${L_RESULT} "${L_RESULT}{LF}"
  FileWrite ${L_RESULTS_FILE}  '!error $\"${L_RESULT}$\"${LF}'

print_undefs:
  SetPluginUnload manual

  ; Now unload the MD5 DLL to allow the $PLUGINSDIR to be removed automatically

  md5dll::GetMD5String "dummy"
  Pop ${L_TEMP}

  FileWrite ${L_RESULTS_FILE} "${LF}!ifdef C_PLUGIN_LF${LF}"
  FileWrite ${L_RESULTS_FILE} "  !undef C_PLUGIN_LF${LF}"
  FileWrite ${L_RESULTS_FILE} "  !undef LF${LF}"
  FileWrite ${L_RESULTS_FILE} "!endif${LF}${LF}"

  FileClose ${L_RESULTS_FILE}

  ; Only update the status report file if there is any change

  Call CompareStatusReports
  Pop ${L_RESULT}
  StrCmp ${L_RESULT} "same" exit

  ; Fully-qualified path names should always be used with the 'CopyFiles' instruction.
  ; Using relative paths will have unpredictable results!

  GetFullPathName ${L_FILEPATH} "."
  CopyFiles /SILENT /FILESONLY "$PLUGINSDIR\${C_RESULTS_FILE}" "${L_FILEPATH}\${C_RESULTS_FILE}"

exit:
  Pop ${L_TEXT}
  Pop ${L_TEMP}
  Pop ${L_RESULTS_FILE}
  Pop ${L_RESULT}
  Pop ${L_PLUGIN_NAME}
  Pop ${L_MISSING_LIST}
  Pop ${L_MISSING_COUNT}
  Pop ${L_INCORRECT_LIST}
  Pop ${L_INCORRECT_COUNT}
  Pop ${L_HANDLE}
  Pop ${L_FILEPATH}
  Pop ${L_EXPECTED_MD5}
  Pop ${L_DATA}

  !undef L_DATA
  !undef L_EXPECTED_MD5
  !undef L_FILEPATH
  !undef L_HANDLE
  !undef L_INCORRECT_COUNT
  !undef L_INCORRECT_LIST
  !undef L_MISSING_COUNT
  !undef L_MISSING_LIST
  !undef L_PLUGIN_NAME
  !undef L_RESULT
  !undef L_RESULTS_FILE
  !undef L_TEMP
  !undef L_TEXT

 SectionEnd

#--------------------------------------------------------------------------
# Function: CompareStatusReports
#
# Compare the newly prepared '${C_RESULTS_FILE}' file with the version
# found in the current working directory and report the result. These
# files may use CRLF or LF as the end-of-line marker so the file size
# is not tested. Return either "same" or "different" result string via
# the stack.
#
# These files can contain empty lines, i.e lines with CRLF or LF only
#--------------------------------------------------------------------------

Function CompareStatusReports

  !define L_NEW_FILE    $R9   ; handle used to access newly created status report
  !define L_NEW_TEXT    $R8
  !define L_OLD_FILE    $R7   ; handle used to access existing status report
  !define L_OLD_TEXT    $R6
  !define L_RESULT      $R5

  !define C_NEW_STATUS  "$PLUGINSDIR\${C_RESULTS_FILE}"
  !define C_OLD_STATUS  ".\${C_RESULTS_FILE}"

  Push ${L_RESULT}
  Push ${L_NEW_FILE}
  Push ${L_NEW_TEXT}
  Push ${L_OLD_FILE}
  Push ${L_OLD_TEXT}

  StrCpy ${L_RESULT}  "different"

  IfFileExists "${C_OLD_STATUS}" 0 exit

  FileOpen ${L_NEW_FILE} "${C_NEW_STATUS}" r
  FileOpen ${L_OLD_FILE} "${C_OLD_STATUS}" r

loop:
  FileRead ${L_NEW_FILE} ${L_NEW_TEXT}
  FileRead ${L_OLD_FILE} ${L_OLD_TEXT}
  StrCmp ${L_NEW_TEXT} "" 0 trim_text
  StrCmp ${L_NEW_TEXT} ${L_OLD_TEXT} files_match

trim_text:
  Push ${L_NEW_TEXT}
  Call NSIS_TrimNewlines
  Pop ${L_NEW_TEXT}
  Push ${L_OLD_TEXT}
  Call NSIS_TrimNewlines
  Pop ${L_OLD_TEXT}
  StrCmp ${L_NEW_TEXT} ${L_OLD_TEXT} loop close_files

files_match:
  StrCpy ${L_RESULT} "same"

close_files:
  FileClose ${L_NEW_FILE}
  FileClose ${L_OLD_FILE}

exit:
  Pop ${L_OLD_TEXT}
  Pop ${L_OLD_FILE}
  Pop ${L_NEW_TEXT}
  Pop ${L_NEW_FILE}
  Exch ${L_RESULT}

  !undef C_NEW_STATUS
  !undef C_OLD_STATUS

  !undef L_NEW_FILE
  !undef L_NEW_TEXT
  !undef L_OLD_FILE
  !undef L_OLD_TEXT
  !undef L_RESULT

FunctionEnd

;--------------------------------------
; end-of-file
;--------------------------------------
