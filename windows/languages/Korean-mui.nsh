#--------------------------------------------------------------------------
# Korean-mui.nsh
#
# This file contains additional "Korean" text strings used by the Windows installer
# for POPFile (these strings are customised versions of strings provided by NSIS).
#
# See 'Korean-pfi.nsh' for the strings which are used on the custom pages.
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

; POPFile translation not available - use default NSIS message

;!insertmacro MUI_LANGUAGEFILE_STRING MUI_TEXT_WELCOME_INFO_TEXT \
;"This wizard will guide you through the installation of POPFile.\r\n\r\n\It is recommended that you close all other applications before starting Setup.\r\n\r\n"

; Default NSIS message:

;!insertmacro MUI_LANGUAGEFILE_STRING MUI_TEXT_WELCOME_INFO_TEXT \
;"이 마법사는 당신의 컴퓨터에 POPFile(을)를 설치할 것입니다.\r\n\r\n설치를 시작하기 전에 모든 프로그램을 종료해주시기 바랍니다. 프로그램을 종료하게 되면 시스템을 재부팅 하지 않고서도 특정한 시스템 파일을 수정할 수 있기 때문입니다.\r\n\r\n"

#--------------------------------------------------------------------------
# Standard MUI Page - Finish
#
# The MUI_TEXT_FINISH_RUN text should be a short phrase (not a long paragraph)
#--------------------------------------------------------------------------

!insertmacro MUI_LANGUAGEFILE_STRING MUI_TEXT_FINISH_RUN \
"POPFile User Interface"

#--------------------------------------------------------------------------
# End of 'Korean-mui.nsh'
#--------------------------------------------------------------------------
