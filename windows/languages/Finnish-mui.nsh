#--------------------------------------------------------------------------
# Finnish-mui.nsh
#
# This file contains additional "Finnish" text strings used by the Windows installer
# for POPFile (these strings are customised versions of strings provided by NSIS).
#
# See 'Finnish-pfi.nsh' for the strings which are used on the custom pages.
#
# These strings are grouped according to the page/window where they are used
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
# Standard MUI Page - Welcome
#
# The sequence \r\n\r\n inserts a blank line (note that the MUI_TEXT_WELCOME_INFO_TEXT string
# should end with a \r\n\r\n sequence because another paragraph follows this string).
#--------------------------------------------------------------------------

!insertmacro MUI_LANGUAGEFILE_STRING MUI_TEXT_WELCOME_INFO_TEXT \
"T‰m‰ avustaja ohjaa sinut ohjelman POPFile asennuksen l‰pi.\r\n\r\nOn suositeltavaa sulkea kaikki muut ohjelmat ennen Asennuksen k‰ynnist‰mist‰, sill‰ silloin Asennus voi p‰ivitt‰‰ tiettyj‰ j‰rjestelm‰tiedostoja k‰ynnist‰m‰tt‰ konetta uudelleen.\r\n\r\n"

#--------------------------------------------------------------------------
# Standard MUI Page - License Agreement
#--------------------------------------------------------------------------

; As of 27 June 2003, the NSIS MUI language file is not compatible with MUI 1.65
; (this is a temporary (and crude) patch to allow installer to support the Finnish language)

; English text for MUI_INNERTEXT_LICENSE_BOTTOM_CHECKBOX:
;"If you accept the terms of the agreement, click the check box below. You must accept the agreement to install POPFile."

!insertmacro MUI_LANGUAGEFILE_STRING MUI_INNERTEXT_LICENSE_BOTTOM_CHECKBOX \
"Jos hyv‰ksyt kaikki ehdot, valitse Hyv‰ksyn jatkaaksesi. Sinun pit‰‰ hyv‰ksy‰ ehdot asentaaksesi ohjelman POPFile."

; English text for MUI_INNERTEXT_LICENSE_BOTTOM_RADIOBUTTONS:
;"If you accept the terms of the agreement, select the first option below. You must accept the agreement to install POPFile."

!insertmacro MUI_LANGUAGEFILE_STRING MUI_INNERTEXT_LICENSE_BOTTOM_RADIOBUTTONS \
"Jos hyv‰ksyt kaikki ehdot, valitse Hyv‰ksyn jatkaaksesi. Sinun pit‰‰ hyv‰ksy‰ ehdot asentaaksesi ohjelman POPFile."

#--------------------------------------------------------------------------
# Standard MUI Page - Finish
#
# The MUI_TEXT_FINISH_RUN text should be a short phrase (not a long paragraph)
#--------------------------------------------------------------------------

!insertmacro MUI_LANGUAGEFILE_STRING MUI_TEXT_FINISH_RUN \
"POPFile User Interface"

#--------------------------------------------------------------------------
# End of 'Finnish-mui.nsh'
#--------------------------------------------------------------------------
