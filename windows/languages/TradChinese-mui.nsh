#--------------------------------------------------------------------------
# TradChinese-mui.nsh
#
# This file contains additional "TradChinese" text strings used by the Windows installer
# for POPFile (these strings are customised versions of strings provided by NSIS).
#
# See 'TradChinese-pfi.nsh' for the strings which are used on the custom pages.
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

; POPFile translation not available - use default NSIS message

;!insertmacro MUI_LANGUAGEFILE_STRING MUI_TEXT_WELCOME_INFO_TEXT \
;"This wizard will guide you through the installation of POPFile.\r\n\r\n\It is recommended that you close all other applications before starting Setup.\r\n\r\n"

; Default NSIS message:

;!insertmacro MUI_LANGUAGEFILE_STRING MUI_TEXT_WELCOME_INFO_TEXT \
;"這將會在你的電腦，安裝 POPFile 。\r\n\r\n在開始安裝之前，建議先關閉其他所有應用程式。這將允許\「安裝程式」更新指定的系統檔案，而不需要重新啟動你的電腦。\r\n\r\n"

#--------------------------------------------------------------------------
# Standard MUI Page - Finish
#
# The MUI_TEXT_FINISH_RUN text should be a short phrase (not a long paragraph)
#--------------------------------------------------------------------------

!insertmacro MUI_LANGUAGEFILE_STRING MUI_TEXT_FINISH_RUN \
"POPFile User Interface"

#--------------------------------------------------------------------------
# End of 'TradChinese-mui.nsh'
#--------------------------------------------------------------------------
