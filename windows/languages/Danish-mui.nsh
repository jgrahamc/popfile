#--------------------------------------------------------------------------
# Danish-mui.nsh
#
# This file contains additional "Danish" text strings used by the Windows installer
# for POPFile (these strings are customised versions of strings provided by NSIS).
#
# See 'Danish-pfi.nsh' for the strings which are used on the custom pages.
#
# These strings are grouped according to the page/window where they are used
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
# Standard MUI Page - Welcome
#
# The sequence \r\n\r\n inserts a blank line (note that the MUI_TEXT_WELCOME_INFO_TEXT string
# should end with a \r\n\r\n sequence because another paragraph follows this string).
#--------------------------------------------------------------------------

!insertmacro MUI_LANGUAGEFILE_STRING MUI_TEXT_WELCOME_INFO_TEXT \
"Dette vil installere POPFile på din computer.\r\n\r\ndet foretrækkes at du lukker alle kørende programmer inden start af guiden.\r\n\r\n"

#--------------------------------------------------------------------------
# Standard MUI Page - License Agreement
#--------------------------------------------------------------------------

; As of 27 June2003, the NSIS MUI language file is not compatible with MUI 1.65
; (this is temporary (and crude) patch to allow installer to support the Danish language)

!insertmacro MUI_LANGUAGEFILE_STRING MUI_INNERTEXT_LICENSE_BOTTOM_CHECKBOX \
"hvis du accepterer alle reglerne, klik Jeg accepterer for at komme videre. Du skal acceptere reglerne for at komme videre POPFile."

!insertmacro MUI_LANGUAGEFILE_STRING MUI_INNERTEXT_LICENSE_BOTTOM_RADIOBUTTONS \
"hvis du accepterer alle reglerne, klik Jeg accepterer for at komme videre. Du skal acceptere reglerne for at komme videre POPFile."

#--------------------------------------------------------------------------
# Standard MUI Page - Finish
#
# The MUI_TEXT_FINISH_RUN text should be a short phrase (not a long paragraph)
#--------------------------------------------------------------------------

!insertmacro MUI_LANGUAGEFILE_STRING MUI_TEXT_FINISH_RUN \
"POPFile Kontrolcenter"

#--------------------------------------------------------------------------
# End of 'Danish-mui.nsh'
#--------------------------------------------------------------------------
