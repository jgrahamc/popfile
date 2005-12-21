#--------------------------------------------------------------------------
#
# pfi-languages.nsh --- This 'include' file lists the non-English languages currently
#                       supported by the POPFile Windows installer and its associated
#                       utilities. This makes maintenance easier.
#
# Copyright (c) 2004-2005 John Graham-Cumming
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
#
#--------------------------------------------------------------------------
# Removing support for a particular language:
#
# To remove support for any of these languages, comment-out the relevant line in the list.
#
# For example, to remove support for the 'Dutch' language, comment-out the line
#
#     !insertmacro PFI_LANG_LOAD "Dutch"
#
#--------------------------------------------------------------------------
# Adding support for a particular language (it must be supported by NSIS):
#
# The number of languages which can be supported depends upon the availability of:
#
# (1) an up-to-date main NSIS language file (${NSISDIR}\Contrib\Language files\*.nlf)
# and
# (2) an up-to-date NSIS MUI Language file (${NSISDIR}\Contrib\Modern UI\Language files\*.nsh)
#
# To add support for a language which is already supported by the NSIS MUI package, an extra
# file is required:
#
# <NSIS Language NAME>-pfi.nsh  -  holds customised versions of the standard MUI text strings
#                                  (eg removing the 'reboot' reference from the 'WELCOME' page)
#                                  plus strings used on the custom pages and elsewhere
#
# Once this file has been prepared and placed in the 'windows\languages' directory with the
# other *-pfi.nsh files, add a new '!insertmacro PFI_LANG_LOAD' line to load this new file.
#
# If there is a suitable POPFile UI language file for the new language, some changes will be
# required to the code in 'adduser.nsi' which attempts to select an appropriate UI language.
#--------------------------------------------------------------------------
# SMALL NSIS PATCH REQUIRED:
#
# The POPFile User Interface 'Language' menu uses the name 'Nihongo' to select the Japanese
# language texts. The NSIS default name used to select the Japanese language texts is 'Japanese'
# which can cause some confusion.
#
# It is an easy matter to make the installer display 'Nihongo' in the list of languages offered.
# However this requires a small change to one of the NSIS MUI language files:
#
# In the file ${NSISDIR}\Contrib\Modern UI\Language files\Japanese.nsh, change the value of the
# MUI_LANGNAME string from "Japanese" to "Nihongo". For example, using the file supplied with
# NSIS 2.0, released 7 February 2004, change line 13 from:
#
# !define MUI_LANGNAME "Japanese" ;(“ú–{Œê) Use only ASCII characters (if this is not possible, use the English name)
#
# to:
#
# !define MUI_LANGNAME "Nihongo" ;(“ú–{Œê) Use only ASCII characters (if this is not possible, use the English name)
#
#--------------------------------------------------------------------------
# USAGE EXAMPLES
#
# It is assumed that ENGLISH is the default language and that it is defined before this file
# is 'included' in a NSIS script.
#
# For programs which can be built as either multi-language or English-only:
#
#     ; At least one language must be specified for the installer (the default is "English")
#
#     !insertmacro PFI_LANG_LOAD "English"
#
#     ; Conditional compilation: if ENGLISH_MODE is defined, support only 'English'
#
#     !ifndef ENGLISH_MODE
#         !include "pfi-languages.nsh"
#     !endif
#
# For programs which are always built as multi-language:
#
#     ; Default language (appears first in the drop-down list)
#
#     !insertmacro PFI_LANG_LOAD "English"
#
#     ; Additional languages supported by the utility
#
#     !include "pfi-languages.nsh"
#
#--------------------------------------------------------------------------

  ; Entries will appear in the drop-down list of languages in the order given below
  ; (the order used here ensures that the list entries appear in alphabetic order).

  ; It is assumed that !insertmacro PFI_LANG_LOAD "English" has been used to define "English"
  ; before including this file (which is why "English" does not appear in the list below).

  ; NOTE: The order used here assumes that the NSIS MUI 'Japanese.nsh' language file has
  ; been patched to use 'Nihongo' instead of 'Japanese' [see 'SMALL NSIS PATCH REQUIRED' above]

  ; Currently a subset of the languages supported by NSIS MUI 1.70 (using the NSIS names)

  ; NSIS 2.0 compiler error messages use language ID codes when referring to problems with
  ; language strings, e.g.
  ;
  ;     LangString "PFI_LANG_NSISDL_PLURAL" is not set in language table of language 1041
  ;
  ; Note: 'English' is 'Language 1033'

  !insertmacro PFI_LANG_LOAD "Arabic"             ; Language 1025
  !insertmacro PFI_LANG_LOAD "Bulgarian"          ; Language 1026
  !insertmacro PFI_LANG_LOAD "Catalan"            ; Language 1027
  !insertmacro PFI_LANG_LOAD "SimpChinese"        ; Language 2052
  !insertmacro PFI_LANG_LOAD "TradChinese"        ; Language 1028
  !insertmacro PFI_LANG_LOAD "Czech"              ; Language 1029
  !insertmacro PFI_LANG_LOAD "Danish"             ; Language 1030
  !insertmacro PFI_LANG_LOAD "German"             ; Language 1031
  !insertmacro PFI_LANG_LOAD "Spanish"            ; Language 1034
  !insertmacro PFI_LANG_LOAD "French"             ; Language 1036
  !insertmacro PFI_LANG_LOAD "Greek"              ; Language 1032
  !insertmacro PFI_LANG_LOAD "Italian"            ; Language 1040
  !insertmacro PFI_LANG_LOAD "Korean"             ; Language 1042
  !insertmacro PFI_LANG_LOAD "Hungarian"          ; Language 1038
  !insertmacro PFI_LANG_LOAD "Dutch"              ; Language 1043
  !insertmacro PFI_LANG_LOAD "Japanese"           ; Language 1041
  !insertmacro PFI_LANG_LOAD "Norwegian"          ; Language 1044
  !insertmacro PFI_LANG_LOAD "Polish"             ; Language 1045
  !insertmacro PFI_LANG_LOAD "Portuguese"         ; Language 2070
  !insertmacro PFI_LANG_LOAD "PortugueseBR"       ; Language 1046
  !insertmacro PFI_LANG_LOAD "Russian"            ; Language 1049
  !insertmacro PFI_LANG_LOAD "Slovak"             ; Language 1051
  !insertmacro PFI_LANG_LOAD "Finnish"            ; Language 1035
  !insertmacro PFI_LANG_LOAD "Swedish"            ; Language 1053
  !insertmacro PFI_LANG_LOAD "Turkish"            ; Language 1055
  !insertmacro PFI_LANG_LOAD "Ukrainian"          ; Language 1058

#--------------------------------------------------------------------------
# End of 'pfi-languages.nsh'
#--------------------------------------------------------------------------
