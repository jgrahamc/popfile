#--------------------------------------------------------------------------
# Slovak-mui.nsh
#
# This file contains additional "Slovak" text strings used by the Windows installer
# for POPFile (these strings are customised versions of strings provided by NSIS).
#
# See 'Slovak-pfi.nsh' for the strings which are used on the custom pages.
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
"Chyst·te sa nainötalovaù POPFile na svoj poËÌtaË.\r\n\r\nPred zaËiatkom inötal·cie je odpor˙ËanÈ zavrieù vöetky ostatnÈ aplik·cie.\r\n\r\n"

#--------------------------------------------------------------------------
# Standard MUI Page - Finish
#
# The MUI_TEXT_FINISH_RUN text should be a short phrase (not a long paragraph)
#--------------------------------------------------------------------------

!insertmacro MUI_LANGUAGEFILE_STRING MUI_TEXT_FINISH_RUN \
"POPFile UûÌvateæskÈ rozhranie"

#--------------------------------------------------------------------------
# End of 'Slovak-mui.nsh'
#--------------------------------------------------------------------------
