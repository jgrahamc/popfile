#--------------------------------------------------------------------------
# Bulgarian-mui.nsh
#
# This file contains additional "Bulgarian" text strings used by the Windows installer
# for POPFile (these strings are customised versions of strings provided by NSIS).
#
# See 'Bulgarian-pfi.nsh' for the strings which are used on the custom pages.
#
# These strings are grouped according to the page/window where they are used
#
# Copyright (c) 2001-2003 John Graham-Cumming
#
#--------------------------------------------------------------------------

!ifndef PFI_VERBOSE
  !verbose 3
!endif

#--------------------------------------------------------------------------
# Standard MUI Page - Welcome
#
# The sequence \r\n\r\n inserts a blank line (note that the MUI_TEXT_WELCOME_INFO_TEXT string
# should end with a \r\n\r\n sequence because another paragraph follows this string).
#--------------------------------------------------------------------------

!insertmacro MUI_LANGUAGEFILE_STRING MUI_TEXT_WELCOME_INFO_TEXT \
"Той ще инсталира POPFile на вашия компютър.\r\n\r\nПрепоръчва се да затворите всички други приложения, преди да стартирате инсталацията.\r\n\r\n"

#--------------------------------------------------------------------------
# Standard MUI Page - License Agreement
#--------------------------------------------------------------------------

; As of 27 June 2003, the NSIS MUI language file is not compatible with MUI 1.65
; (this is a temporary (and crude) patch to allow installer to support the Bulgarian language)

; English text for MUI_INNERTEXT_LICENSE_BOTTOM_CHECKBOX:
;"If you accept the terms of the agreement, click the check box below. You must accept the agreement to install POPFile."

!insertmacro MUI_LANGUAGEFILE_STRING MUI_INNERTEXT_LICENSE_BOTTOM_CHECKBOX \
"Ако приемате всички условия от споразумението, Изберете 'Съгласен', за да продължите. Трябва да приемете споразумението, за да инсталирате POPFile."

; English text for MUI_INNERTEXT_LICENSE_BOTTOM_RADIOBUTTONS:
;"If you accept the terms of the agreement, select the first option below. You must accept the agreement to install POPFile."

!insertmacro MUI_LANGUAGEFILE_STRING MUI_INNERTEXT_LICENSE_BOTTOM_RADIOBUTTONS \
"Ако приемате всички условия от споразумението, Изберете 'Съгласен', за да продължите. Трябва да приемете споразумението, за да инсталирате POPFile."

#--------------------------------------------------------------------------
# Standard MUI Page - Finish
#
# The MUI_TEXT_FINISH_RUN text should be a short phrase (not a long paragraph)
#--------------------------------------------------------------------------

!insertmacro MUI_LANGUAGEFILE_STRING MUI_TEXT_FINISH_RUN \
"POPFile Потребителски интерфейс"

#--------------------------------------------------------------------------
# End of 'Bulgarian-mui.nsh'
#--------------------------------------------------------------------------
