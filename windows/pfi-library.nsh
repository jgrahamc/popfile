#--------------------------------------------------------------------------
#
# pfi-library.nsi --- This is a collection of library functions and macro
#                     definitions used by 'installer.nsi', the NSIS script
#                     used to create the Windows installer for POPFile.
#
# Copyright (c) 2001-2003 John Graham-Cumming
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

!ifndef PFI_VERBOSE
  !verbose 3
!endif

#--------------------------------------------------------------------------
#
# Macros used to simplify inclusion/selection of the necessary language files
#
#--------------------------------------------------------------------------

  ;--------------------------------------------------------------------------
  ; Used in the '*-pfi.nsh' files to define the text strings for the installer
  ;--------------------------------------------------------------------------

  !macro PFI_LANG_STRING NAME VALUE
    LangString ${NAME} ${LANG_${PFI_LANG}} "${VALUE}"
  !macroend

  ;--------------------------------------------------------------------------
  ; Used in the '*-pfi.nsh' files to define the text strings for the uninstaller
  ;--------------------------------------------------------------------------

  !macro PFI_LANG_UNSTRING NAME VALUE
    !insertmacro PFI_LANG_STRING "un.${NAME}" "${VALUE}"
  !macroend

  ;--------------------------------------------------------------------------
  ; Used in '*-pfi.nsh' files to define the text strings for fields in a custom page INI file
  ;--------------------------------------------------------------------------

  !macro PFI_IO_TEXT PATH FIELD TEXT
    WriteINIStr "$PLUGINSDIR\${PATH}" "Field ${FIELD}" "Text" "${TEXT}"
  !macroend

  ;--------------------------------------------------------------------------
  ; Used in '*-pfi.nsh' files to define entries in [Settings] section of a custom page INI file
  ;--------------------------------------------------------------------------

  !macro PFI_IO_SETTING PATH FIELD TEXT
    WriteINIStr "$PLUGINSDIR\${PATH}" "Settings" "${FIELD}" "${TEXT}"
  !macroend

  ;--------------------------------------------------------------------------
  ; Used in 'installer.nsi' to define the languages to be supported
  ;--------------------------------------------------------------------------

  ; Macro used to load the three files required for each language:
  ; (1) '*-mui.nsh' contains the customisations to be applied to the standard MUI text strings
  ; (2) '*-pfi.nsh' contains the text strings used for custom pages, progress reports and logs
  ; (3) the GPL license text (at present every language uses the 'English' version of the GPL)

  !macro PFI_LANG_LOAD LANG
    !include "languages\${LANG}-mui.nsh"
    !insertmacro MUI_LANGUAGE "${LANG}"
    !include "languages\${LANG}-pfi.nsh"
    LicenseData /LANG=${LANG} "..\engine\license"
  !macroend

  ;--------------------------------------------------------------------------
  ; Used in 'installer.nsi' to select the POPFile UI language according to the language used
  ; for the installation process (NSIS language names differ from those used by POPFile's UI)
  ;--------------------------------------------------------------------------

  !macro UI_LANG_CONFIG PFI_SETTING UI_SETTING
    StrCmp $LANGUAGE ${LANG_${PFI_SETTING}} 0 +4
      IfFileExists "$INSTDIR\languages\${UI_SETTING}.msg" 0 lang_done
      StrCpy ${L_LANG} "${UI_SETTING}"
      Goto lang_save
  !macroend

#--------------------------------------------------------------------------
#
# Macro used by the uninstaller
# (guards against unexpectedly removing the corpus or message history)
#
# Usage:
#   !insertmacro SafeRecursiveRMDir ${__LINE__} $(L_CORPUS}
#
# ${__LINE__} holds the linenumber of the '!insertmacro' command
#--------------------------------------------------------------------------

!macro SafeRecursiveRMDir UNIQUE_ID PATH

  StrCmp ${L_SUBCORPUS} "no" Label_A_${UNIQUE_ID}
  Push ${L_CORPUS}
  Push "${PATH}"
  Call un.StrStr
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" 0 Label_C_${UNIQUE_ID}

Label_A_${UNIQUE_ID}:
  StrCmp ${L_SUBHISTORY} "no" Label_B_${UNIQUE_ID}
  Push ${L_HISTORY}
  Push "${PATH}"
  Call un.StrStr
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" 0 Label_C_${UNIQUE_ID}

Label_B_${UNIQUE_ID}:
  RMDir /r "${PATH}"

Label_C_${UNIQUE_ID}:

!macroend


#==============================================================================================
#
# Functions used only by the installer
#
#==============================================================================================

#--------------------------------------------------------------------------
# Installer Function: GetSeparator
#
# Returns the character to be used as the separator when configuring an e-mail account.
# If the character is not defined in popfile.cfg, the default separator (':') is returned
#
# Inputs:
#         none
# Outputs:
#         (top of stack)     - character to be used as the separator
#
# Usage:
#         Call GetSeparator
#         Pop $R0
#
#         ($R0 at this point is ":" unless popfile.cfg has altered the default setting)
#
#--------------------------------------------------------------------------

Function GetSeparator

  !define L_CFG         $R9   ; file handle
  !define L_LNE         $R8   ; a line from the popfile.cfg file
  !define L_PARAM       $R7
  !define L_SEPARATOR   $R6   ; character used to separate the pop3 server from the username

  Push ${L_SEPARATOR}
  Push ${L_CFG}
  Push ${L_LNE}
  Push ${L_PARAM}

  StrCpy ${L_SEPARATOR} ""

  ClearErrors

  FileOpen  ${L_CFG} "$INSTDIR\popfile.cfg" r

loop:
  FileRead   ${L_CFG} ${L_LNE}
  IfErrors separator_done

  StrCpy ${L_PARAM} ${L_LNE} 10
  StrCmp ${L_PARAM} "separator " old_separator
  StrCpy ${L_PARAM} ${L_LNE} 15
  StrCmp ${L_PARAM} "pop3_separator " new_separator
  Goto loop

old_separator:
  StrCpy ${L_SEPARATOR} ${L_LNE} 1 10
  Goto loop

new_separator:
  StrCpy ${L_SEPARATOR} ${L_LNE} 1 15
  Goto loop

separator_done:
  FileClose ${L_CFG}
  StrCmp ${L_SEPARATOR} "" default
  StrCmp ${L_SEPARATOR} "$\r" default
  StrCmp ${L_SEPARATOR} "$\n" 0 exit

default:
  StrCpy ${L_SEPARATOR} ":"

exit:
  Pop ${L_PARAM}
  Pop ${L_LNE}
  Pop ${L_CFG}
  Exch ${L_SEPARATOR}

  !undef L_CFG
  !undef L_LNE
  !undef L_PARAM
  !undef L_SEPARATOR

FunctionEnd


#==============================================================================================
#
# Functions used only by the uninstaller
#
#==============================================================================================

#--------------------------------------------------------------------------
# Function: un.GetCorpusPath
#
# This function is used by the uninstaller when uninstalling a previous version of POPFile.
# It uses 'popfile.cfg' file to determine the full path of the directory where the corpus files
# are stored. By default POPFile stores the corpus in the '$INSTDIR\corpus' directory but the
# 'popfile.cfg' file can define a different location, using a variety of paths (eg relative,
# absolute, local or even remote).
#
# If 'popfile.cfg' is found in the specified folder, we use the corpus parameter (if present)
# otherwise we assume the default location is to be used (the sub-folder called 'corpus').
#
# Inputs:
#         (top of stack)          - the path where 'popfile.cfg' is to be found
#
# Outputs:
#         (top of stack)          - string containing the full (unambiguous) path to the corpus
#
#  Usage Example:
#         Push $INSTDIR
#         Call un.GetCorpusPath
#         Pop $R0
#
#         ($R0 will be "C:\Program Files\POPFile\corpus" if default corpus location is used)
#--------------------------------------------------------------------------

Function un.GetCorpusPath

  !define L_CORPUS        $R9
  !define L_FILE_HANDLE   $R8
  !define L_RESULT        $R7
  !define L_SOURCE        $R6
  !define L_TEMP          $R5

  Exch ${L_SOURCE}          ; where we are supposed to look for the 'popfile.cfg' file
  Push ${L_RESULT}
  Exch
  Push ${L_CORPUS}
  Push ${L_FILE_HANDLE}
  Push ${L_TEMP}

  StrCpy ${L_CORPUS} ""

  IfFileExists "${L_SOURCE}\popfile.cfg" 0 use_default_locn
  ClearErrors
  FileOpen ${L_FILE_HANDLE} "${L_SOURCE}\popfile.cfg" r

loop:
  FileRead ${L_FILE_HANDLE} ${L_TEMP}
  IfErrors cfg_file_done
  StrCpy ${L_RESULT} ${L_TEMP} 7
  StrCmp ${L_RESULT} "corpus " got_old_corpus
  StrCpy ${L_RESULT} ${L_TEMP} 13
  StrCmp ${L_RESULT} "bayes_corpus " got_new_corpus
  Goto loop

got_old_corpus:
  StrCpy ${L_CORPUS} ${L_TEMP} "" 7
  Goto loop

got_new_corpus:
  StrCpy ${L_CORPUS} ${L_TEMP} "" 13
  Goto loop

cfg_file_done:
  FileClose ${L_FILE_HANDLE}
  Push ${L_CORPUS}
  Call un.TrimNewlines
  Pop ${L_CORPUS}
  StrCmp ${L_CORPUS} "" use_default_locn use_cfg_data

use_default_locn:
  StrCpy ${L_RESULT} ${L_SOURCE}\corpus
  Goto got_result

use_cfg_data:
  Push ${L_SOURCE}
  Push ${L_CORPUS}
  Call un.GetDataPath
  Pop ${L_RESULT}

got_result:
  Pop ${L_TEMP}
  Pop ${L_FILE_HANDLE}
  Pop ${L_CORPUS}
  Pop ${L_SOURCE}
  Exch ${L_RESULT}  ; place full path of 'corpus' directory on top of the stack

  !undef L_CORPUS
  !undef L_FILE_HANDLE
  !undef L_RESULT
  !undef L_SOURCE
  !undef L_TEMP

FunctionEnd

#--------------------------------------------------------------------------
# Function: un.GetHistoryPath
#
# This function is used by the uninstaller when uninstalling a previous version of POPFile.
# It uses 'popfile.cfg' file to determine the full path of the directory where the message
# history files are stored. By default POPFile stores these files in the '$INSTDIR\messages'
# directory but the 'popfile.cfg' file can define a different location, using a variety of
# paths (eg relative, absolute, local or even remote).
#
# If 'popfile.cfg' is found in the specified folder, we use the history parameter (if present)
# otherwise we assume the default location is to be used (the sub-folder called 'messages').
#
# Note that the path specified in 'popfile.cfg' uses a trailing slash (which we do not return)
#
# Inputs:
#         (top of stack)          - the path where 'popfile.cfg' is to be found
#
# Outputs:
#         (top of stack)          - string containing full (unambiguous) path to message history
#
#  Usage Example:
#         Push $INSTDIR
#         Call un.GetHistoryPath
#         Pop $R0
#
#         ($R0 will be "C:\Program Files\POPFile\messages" if POPFile is installed in default
#          location and if the history parameter in 'popfile.cfg' is set to 'messages/')
#--------------------------------------------------------------------------

Function un.GetHistoryPath

  !define L_FILE_HANDLE   $R9
  !define L_HISTORY       $R8
  !define L_RESULT        $R7
  !define L_SOURCE        $R6
  !define L_TEMP          $R5

  Exch ${L_SOURCE}          ; where we are supposed to look for the 'popfile.cfg' file
  Push ${L_RESULT}
  Exch
  Push ${L_HISTORY}
  Push ${L_FILE_HANDLE}
  Push ${L_TEMP}

  StrCpy ${L_HISTORY} ""

  IfFileExists "${L_SOURCE}\popfile.cfg" 0 use_default_locn
  ClearErrors
  FileOpen ${L_FILE_HANDLE} "${L_SOURCE}\popfile.cfg" r

loop:
  FileRead ${L_FILE_HANDLE} ${L_TEMP}
  IfErrors cfg_file_done
  StrCpy ${L_RESULT} ${L_TEMP} 7
  StrCmp ${L_RESULT} "msgdir " got_old_msgdir
  StrCpy ${L_RESULT} ${L_TEMP} 14
  StrCmp ${L_RESULT} "GLOBAL_msgdir " got_new_msgdir
  Goto loop

got_old_msgdir:
  StrCpy ${L_HISTORY} ${L_TEMP} "" 7
  Goto loop

got_new_msgdir:
  StrCpy ${L_HISTORY} ${L_TEMP} "" 14
  Goto loop

cfg_file_done:
  FileClose ${L_FILE_HANDLE}
  Push ${L_HISTORY}
  Call un.TrimNewlines
  Pop ${L_HISTORY}
  StrCmp ${L_HISTORY} "" use_default_locn use_cfg_data

use_default_locn:
  StrCpy ${L_RESULT} "${L_SOURCE}\messages"
  Goto got_result

use_cfg_data:
  StrCpy ${L_TEMP} ${L_HISTORY} 1 -1
  StrCmp ${L_TEMP} "/" strip_slash no_trailing_slash
  StrCmp ${L_TEMP} "\" 0 no_trailing_slash

strip_slash:
  StrCpy ${L_HISTORY} ${L_HISTORY} -1

no_trailing_slash:
  Push ${L_SOURCE}
  Push ${L_HISTORY}
  Call un.GetDataPath
  Pop ${L_RESULT}

got_result:
  Pop ${L_TEMP}
  Pop ${L_FILE_HANDLE}
  Pop ${L_HISTORY}
  Pop ${L_SOURCE}
  Exch ${L_RESULT}  ; place full path of 'messages' directory on top of the stack

  !undef L_FILE_HANDLE
  !undef L_HISTORY
  !undef L_RESULT
  !undef L_SOURCE
  !undef L_TEMP

FunctionEnd

#--------------------------------------------------------------------------
# Function: un.GetDataPath
#
# This function is used to convert a 'base directory' and a 'data folder' parameter (usually
# relative to the 'base directory') into a single, absolute path. For example, it will convert
# 'C:\Program Files\POPFile' and 'corpus' into 'C:\Program Files\POPFile\corpus'.
#
# It is assumed that the 'base directory' is in standard Windows format with no trailing slash.
#
# The 'data folder' may be supplied in a variety of different formats, for example:
# corpus, ./corpus, "..\..\corpus", Z:/Data/corpus or even "\\server\share\corpus".
#
# Inputs:
#         (top of stack)          - the 'data folder' parameter (eg "../../corpus")
#         (top of stack - 1)      - the 'base directory' parameter
#
# Outputs:
#         (top of stack)          - string containing the full (unambiguous) path to the data
#                                   (the string "" is returned if input data was null)
#
#  Usage Example:
#         Push $INSTDIR
#         Push "../../corpus"
#         Call un.GetDataPath
#         Pop $R0
#
#         ($R0 will be "C:\corpus", assuming $INSTDIR was "C:\Program Files\POPFile")
#--------------------------------------------------------------------------

Function un.GetDataPath

  !define L_BASEDIR     $R9
  !define L_DATA        $R8
  !define L_RESULT      $R7
  !define L_TEMP        $R6

  Exch ${L_DATA}        ; the 'data folder' parameter (often a relative path)
  Exch
  Exch ${L_BASEDIR}      ; the 'base directory' used for cases where 'data folder' is relative
  Push ${L_RESULT}
  Push ${L_TEMP}

  StrCmp ${L_DATA} "" 0 strip_quotes
  StrCpy ${L_DATA} ${L_BASEDIR}
  Goto got_path

strip_quotes:

  ; Strip leading/trailing quotes, if any

  StrCpy ${L_TEMP} ${L_DATA} 1
  StrCmp ${L_TEMP} '"' 0 slashconversion
  StrCpy ${L_DATA} ${L_DATA} "" 1
  StrCpy ${L_TEMP} ${L_DATA} 1 -1
  StrCmp ${L_TEMP} '"' 0 slashconversion
  StrCpy ${L_DATA} ${L_DATA} -1

slashconversion:
  StrCmp ${L_DATA} "." source_folder
  Push ${L_DATA}
  Call un.StrBackSlash            ; ensure parameter uses backslashes
  Pop ${L_DATA}

  StrCpy ${L_TEMP} ${L_DATA} 2
  StrCmp ${L_TEMP} ".\" sub_folder
  StrCmp ${L_TEMP} "\\" got_path

  StrCpy ${L_TEMP} ${L_DATA} 3
  StrCmp ${L_TEMP} "..\" relative_folder

  StrCpy ${L_TEMP} ${L_DATA} 1
  StrCmp ${L_TEMP} "\" basedir_drive

  StrCpy ${L_TEMP} ${L_DATA} 1 1
  StrCmp ${L_TEMP} ":" got_path

  ; Assume path can be safely added to 'base directory'

  StrCpy ${L_DATA} ${L_BASEDIR}\${L_DATA}
  Goto got_path

source_folder:
  StrCpy ${L_DATA} ${L_BASEDIR}
  Goto got_path

sub_folder:
  StrCpy ${L_DATA} ${L_DATA} "" 2
  StrCpy ${L_DATA} ${L_BASEDIR}\${L_DATA}
  Goto got_path

relative_folder:
  StrCpy ${L_RESULT} ${L_BASEDIR}

relative_again:
  StrCpy ${L_DATA} ${L_DATA} "" 3
  Push ${L_RESULT}
  Call un.GetParent
  Pop ${L_RESULT}
  StrCpy ${L_TEMP} ${L_DATA} 3
  StrCmp ${L_TEMP} "..\" relative_again
  StrCpy ${L_DATA} ${L_RESULT}\${L_DATA}
  Goto got_path

basedir_drive:
  StrCpy ${L_TEMP} ${L_BASEDIR} 2
  StrCpy ${L_DATA} ${L_TEMP}${L_DATA}

got_path:
  Pop ${L_TEMP}
  Pop ${L_RESULT}
  Pop ${L_BASEDIR}
  Exch ${L_DATA}  ; place full path to the data directory on top of the stack

  !undef L_BASEDIR
  !undef L_DATA
  !undef L_RESULT
  !undef L_TEMP

FunctionEnd

#--------------------------------------------------------------------------
# Function: un.StrBackSlash
#
# This function is used by the uninstaller when it looks for the corpus files for the version
# of POPFile which is being upgraded. It converts all the slashes in a string to backslashes
#
# Inputs:
#         (top of stack)            - string containing slashes (e.g. "C:/This/and/That")
#
# Outputs:
#         (top of stack)            - string containing backslashes (e.g. "C:\This\and\That")
#
# Usage Example:
#         Push "C:/Program Files/Directory/Whatever"
#         Call un.StrBackSlash
#         Pop $R0
#
#         ($R0 at this point is ""C:\Program Files\Directory\Whatever")
#
#--------------------------------------------------------------------------

Function un.StrBackSlash
  Exch $R0    ; Input string with slashes
  Push $R1    ; Output string using backslashes
  Push $R2    ; Current character

  StrCpy $R1 ""
  StrCmp $R0 $R1 nothing_to_do

loop:
  StrCpy $R2 $R0 1
  StrCpy $R0 $R0 "" 1
  StrCmp $R2 "/" found
  StrCpy $R1 "$R1$R2"
  StrCmp $R0 "" done loop

found:
  StrCpy $R1 "$R1\"
  StrCmp $R0 "" done loop

done:
  StrCpy $R0 $R1

nothing_to_do:
  Pop $R2
  Pop $R1
  Exch $R0
FunctionEnd

#--------------------------------------------------------------------------
# Function: un.GetParent
#
# This function is used by the uninstaller when it looks for the corpus files for the version
# of POPFile which is being upgraded. It extracts the parent directory from a given path.
#
# NB: Path is assumed to use backslashes (\)
#
# Inputs:
#         (top of stack)          - string containing a path (e.g. C:\A\B\C)
#
# Outputs:
#         (top of stack)          - the parent part of the input string (e.g. C:\A\B)
#
#  Usage Example:
#         Push "C:\Program Files\Directory\Whatever"
#         Call un.GetParent
#         Pop $R0
#
#         ($R0 at this point is ""C:\Program Files\Directory")
#
#--------------------------------------------------------------------------

Function un.GetParent
  Exch $R0
  Push $R1
  Push $R2

  StrCpy $R1 -1

loop:
  StrCpy $R2 $R0 1 $R1
  StrCmp $R2 "" exit
  StrCmp $R2 "\" exit
  IntOp $R1 $R1 - 1
  Goto loop

exit:
  StrCpy $R0 $R0 $R1
  Pop $R2
  Pop $R1
  Exch $R0
FunctionEnd


#==============================================================================================
#
# Macro-based Functions used by the installer and by the uninstaller
#
#==============================================================================================

#--------------------------------------------------------------------------
# Macro: StrStr
#
# The installation process and the uninstall process both use a function which checks if
# a given string appears inside another string. This macro makes maintenance easier by ensuring
# that both processes use identical functions, with the only difference being their names.
#
# NOTE:
# The !insertmacro StrStr "" and !insertmacro StrStr "un." commands are included in this file
# so 'installer.nsi' can use 'Call StrStr' and 'Call un.StrStr' without additional preparation.
#
# Search for matching string
#
# Inputs:
#         (top of stack)     - the string to be found (needle)
#         (top of stack - 1) - the string to be searched (haystack)
# Outputs:
#         (top of stack)     - string starting with the match, if any
#
#  Usage (after macro has been 'inserted'):
#
#         Push "this is a long string"
#         Push "long"
#         Call StrStr
#         Pop $R0
#         ($R0 at this point is "long string")
#
#--------------------------------------------------------------------------

!macro StrStr UN
  Function ${UN}StrStr

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
!macroend

#--------------------------------------------------------------------------
# Installer Function: StrStr
#
# This function is used during the installation process
#--------------------------------------------------------------------------

!insertmacro StrStr ""

#--------------------------------------------------------------------------
# Uninstaller Function: un.StrStr
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

!insertmacro StrStr "un."


#--------------------------------------------------------------------------
# Macro: StrCheckDecimal
#
# The installation process and the uninstall process both use a function which checks if
# a given string contains a decimal number. This macro makes maintenance easier by ensuring
# that both processes use identical functions, with the only difference being their names.
#
# The 'StrCheckDecimal' and 'un.StrCheckDecimal' functions check that a given string contains
# only the digits 0 to 9. (if the string contains any invalid characters, "" is returned)
#
# NOTE:
# The !insertmacro StrCheckDecimal "" and !insertmacro StrCheckDecimal "un." commands are
# included in this file so 'installer.nsi' can use 'Call StrCheckDecimal' and
# 'Call un.StrCheckDecimal' without additional preparation.
#
# Inputs:
#         (top of stack)   - string which may contain a decimal number
#
# Outputs:
#         (top of stack)   - the input string (if valid) or "" (if invalid)
#
#  Usage (after macro has been 'inserted'):
#
#         Push "12345"
#         Call un.StrCheckDecimal
#         Pop $R0
#         ($R0 at this point is "12345")
#
#--------------------------------------------------------------------------

!macro StrCheckDecimal UN
  Function ${UN}StrCheckDecimal

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
!macroend

#--------------------------------------------------------------------------
# Installer Function: StrCheckDecimal
#
# This function is used during the installation process
#--------------------------------------------------------------------------

!insertmacro StrCheckDecimal ""

#--------------------------------------------------------------------------
# Uninstaller Function: un.StrCheckDecimal
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

!insertmacro StrCheckDecimal "un."


#--------------------------------------------------------------------------
# Macro: TrimNewlines
#
# The installation process and the uninstall process both use a function which trims newlines
# from lines of text. This macro makes maintenance easier by ensuring that both processes use
# identical functions, with the only difference being their names.
#
# NOTE:
# The !insertmacro TrimNewlines "" and !insertmacro TrimNewlines "un." commands are
# included in this file so 'installer.nsi' can use 'Call TrimNewlines' and
# 'Call un.TrimNewlines' without additional preparation.
#
# Inputs:
#         (top of stack)   - string which may end with one or more newlines
#
# Outputs:
#         (top of stack)   - the input string with the trailing newlines (if any) removed
#
#  Usage (after macro has been 'inserted'):
#
#         Push "whatever$\r$\n"
#         Call un.TrimNewlines
#         Pop $R0
#         ($R0 at this point is "whatever")
#
#--------------------------------------------------------------------------

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
# Uninstaller Function: un.TrimNewlines
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

!insertmacro TrimNewlines "un."


#--------------------------------------------------------------------------
# Macro: WaitUntilUnlocked
#
# The installation process and the uninstall process both use a function which checks if
# either '$INSTDIR\wperl.exe' or $INSTDIR\perl.exe' is being used. It may take a little
# while for POPFile to shutdown so the installer/uninstaller calls this function which
# waits in a loop until the specified EXE file is no longer in use. A timeout counter
# is used to avoid an infinite loop.
#
# Inputs:
#         (top of stack)     - the full path of the EXE file to be checked
#
# Outputs:
#         (none)
#
#  Usage (after macro has been 'inserted'):
#
#         Push "$INSTDIR\wperl.exe"
#         Call WaitUntilUnlocked
#
#--------------------------------------------------------------------------

!macro WaitUntilUnlocked UN
  Function ${UN}WaitUntilUnlocked
    !define L_EXE           $R9   ; full path to the EXE file which is to be monitored
    !define L_FILE_HANDLE   $R8
    !define L_TIMEOUT       $R7   ; used to avoid an infinite loop

    Exch ${L_EXE}
    Push ${L_FILE_HANDLE}
    Push ${L_TIMEOUT}

    IfFileExists "${L_EXE}" 0 exit_now
    SetFileAttributes "${L_EXE}" NORMAL
    StrCpy ${L_TIMEOUT} ${C_SHUTDOWN_LIMIT}

  check_if_unlocked:
    Sleep ${C_SHUTDOWN_DELAY}
    ClearErrors
    FileOpen ${L_FILE_HANDLE} "${L_EXE}" a
    FileClose ${L_FILE_HANDLE}
    IfErrors 0 exit_now
    IntOp ${L_TIMEOUT} ${L_TIMEOUT} - 1
    IntCmp ${L_TIMEOUT} 0 exit_now exit_now check_if_unlocked

   exit_now:
    Pop ${L_TIMEOUT}
    Pop ${L_FILE_HANDLE}
    Pop ${L_EXE}

    !undef L_EXE
    !undef L_FILE_HANDLE
    !undef L_TIMEOUT
  FunctionEnd
!macroend

#--------------------------------------------------------------------------
# Installer Function: WaitUntilUnlocked
#
# This function is used during the installation process
#--------------------------------------------------------------------------

!insertmacro WaitUntilUnlocked ""

#--------------------------------------------------------------------------
# Uninstaller Function: un.WaitUntilUnlocked
#
# This function is used during the uninstall process
#--------------------------------------------------------------------------

!insertmacro WaitUntilUnlocked "un."

#--------------------------------------------------------------------------
# End of 'pfi-library.nsh'
#--------------------------------------------------------------------------
