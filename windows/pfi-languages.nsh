#--------------------------------------------------------------------------
#
# pfi-languages.nsh --- This 'include' file lists the non-English languages currently
#                       supported by the POPFile Windows installer and its associated
#                       utilties. This makes maintenance easier.
#
# Copyright (c) 2004 John Graham-Cumming
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

  !insertmacro PFI_LANG_LOAD "Arabic"
  !insertmacro PFI_LANG_LOAD "Bulgarian"
  !insertmacro PFI_LANG_LOAD "SimpChinese"
  !insertmacro PFI_LANG_LOAD "TradChinese"
  !insertmacro PFI_LANG_LOAD "Czech"
  !insertmacro PFI_LANG_LOAD "Danish"
  !insertmacro PFI_LANG_LOAD "German"
  !insertmacro PFI_LANG_LOAD "Spanish"
  !insertmacro PFI_LANG_LOAD "French"
  !insertmacro PFI_LANG_LOAD "Greek"
  !insertmacro PFI_LANG_LOAD "Italian"
  !insertmacro PFI_LANG_LOAD "Korean"
  !insertmacro PFI_LANG_LOAD "Hungarian"
  !insertmacro PFI_LANG_LOAD "Dutch"
  !insertmacro PFI_LANG_LOAD "Japanese"
  !insertmacro PFI_LANG_LOAD "Norwegian"
  !insertmacro PFI_LANG_LOAD "Polish"
  !insertmacro PFI_LANG_LOAD "Portuguese"
  !insertmacro PFI_LANG_LOAD "PortugueseBR"
  !insertmacro PFI_LANG_LOAD "Russian"
  !insertmacro PFI_LANG_LOAD "Slovak"
  !insertmacro PFI_LANG_LOAD "Finnish"
  !insertmacro PFI_LANG_LOAD "Swedish"
  !insertmacro PFI_LANG_LOAD "Turkish"
  !insertmacro PFI_LANG_LOAD "Ukrainian"

#--------------------------------------------------------------------------
# End of 'pfi-languages.nsh'
#--------------------------------------------------------------------------
