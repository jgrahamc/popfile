#--------------------------------------------------------------------------
# Korean-pfi.nsh
#
# This file contains the "Korean" text strings used by the Windows installer
# for POPFile (includes customised versions of strings provided by NSIS and
# strings which are unique to POPFile).
#
# These strings are grouped according to the page/window where they are used
#
# Copyright (c) 2001-2004 John Graham-Cumming
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
#
# Translation created by: Joonyup Jeon (goodwill@hananet.net)
# Translation updated by: Joonyup Jeon (goodwill@hananet.net)
#
#--------------------------------------------------------------------------
# String Formatting (applies to PFI_LANG_*_MB* text used for message boxes):
#
#   (1) The sequence  $\r$\n        inserts a newline
#   (2) The sequence  $\r$\n$\r\$n  inserts a blank line
#
# (the 'PFI_LANG_CBP_MBCONTERR_2' message box string which is listed under the heading
# 'Custom Page - POPFile Classification Bucket Creation' includes some examples)
#--------------------------------------------------------------------------
# String Formatting (applies to PFI_LANG_*_IO_ text used for custom pages):
#
#   (1) The sequence  \r\n      inserts a newline
#   (2) The sequence  \r\n\r\n  inserts a blank line
#
# (the 'PFI_LANG_CBP_IO_INTRO' custom page string which is listed under the heading
# 'Custom Page - POPFile Classification Bucket Creation' includes some examples)
#--------------------------------------------------------------------------

!ifndef PFI_VERBOSE
  !verbose 3
!endif

#--------------------------------------------------------------------------
# Mark the start of the language data
#--------------------------------------------------------------------------

!define PFI_LANG  "KOREAN"

#==========================================================================
# Customised versions of strings used on standard MUI pages
#==========================================================================

#--------------------------------------------------------------------------
# Standard MUI Page - Welcome
#
# The sequence \r\n\r\n inserts a blank line (note that the PFI_LANG_WELCOME_INFO_TEXT string
# should end with a \r\n\r\n$_CLICK sequence).
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_WELCOME_INFO_TEXT \
"이 마법사는 귀하의 컴퓨터에 POPFile(팝파일)을 설치할 것입니다.\r\n\r\n설치를 시작하기 전에 모든 프로그램을 종료시킬 것을 권장합니다.\r\n\r\n$_CLICK"

!insertmacro PFI_LANG_STRING PFI_LANG_WELCOME_ADMIN_TEXT \
"IMPORTANT NOTICE:\r\n\r\nThe current user does NOT have 'Administrator' rights.\r\n\r\nIf multi-user support is required, it is recommended that you cancel this installation and use an 'Administrator' account to install POPFile."

#--------------------------------------------------------------------------
# Standard MUI Page - Installation Page
#
# (used by the 'Corpus Conversion Monitor' utility)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_TITLE        "POPFile Corpus Conversion"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_SUBTITLE     "The existing corpus must be converted to work with this version of POPFile"

!insertmacro PFI_LANG_STRING PFI_LANG_ENDCONVERT_TITLE     "POPFile Corpus Conversion Completed"
!insertmacro PFI_LANG_STRING PFI_LANG_ENDCONVERT_SUBTITLE  "Please click Close to continue"

#--------------------------------------------------------------------------
# Standard MUI Page - Finish
#
# The PFI_LANG_FINISH_RUN_TEXT text should be a short phrase (not a long paragraph)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_FINISH_RUN_TEXT \
"팝파일 사용자 화면"

#==========================================================================
# Strings used for custom pages, message boxes and banners
#==========================================================================

#--------------------------------------------------------------------------
# General purpose banner text (also suitable for page titles/subtitles)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_BANNER_1    "이전 버전 제거 중"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_BANNER_2    "몇초 정도 걸릴 수 있습니다..."

#--------------------------------------------------------------------------
# Message displayed when installer exits because another copy is running
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_INSTALLER_MUTEX     "Another copy of the POPFile installer is already running !"

#--------------------------------------------------------------------------
# Message box warning that a previous installation has been found
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_1  "이전 버전의 POPFile(팝파일)이 설치된 것이 감지되었습니다."
!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_2  "Do you want to upgrade it ?"

#--------------------------------------------------------------------------
# Startup message box offering to display the Release Notes
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_1        "POPFile(팝파일) 릴리즈 노트를 표시할까요?"
!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_2        "POPFile을 업그레이드하시는 것이라면 '예' 를 권장합니다. (설치 전에 POPFile 폴더를 백업하셔야 할 수도 있습니다.)"

#--------------------------------------------------------------------------
# Custom Page - Check Perl Requirements
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_TITLE       "Out-of-date System Components Detected"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_SUBTITLE    "The version of Perl used by POPFile may not work properly on this system"

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_1   "When POPFile displays its User Interface, the current default browser will be used.\r\n\r\nPOPFile does not require a specific browser, it will work with almost any browser.\r\n\r\nPOPFile is written in Perl so a minimal version of Perl is installed which uses some components distributed with Internet Explorer."
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_2   "The installer has detected that this system has Internet Explorer"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_3   "The version of Perl supplied with POPFile requires Internet Explorer 5.5 (or later).\r\n\r\nIt is recommended that this system is upgraded to use Internet Explorer 5.5 or a later version."

#--------------------------------------------------------------------------
# Standard MUI Page - Choose Components
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING DESC_SecPOPFile              "POPFile에 필요한 핵심 파일(Perl의 최소설치 버전 포함)을 설치합니다."
!insertmacro PFI_LANG_STRING DESC_SecSkins                "사용자 인터페이스 화면의 모양을 바꿀 수 있는 POPFile 스킨을 설치합니다."
!insertmacro PFI_LANG_STRING DESC_SecLangs                "POPFile 사용자화면의 다국어 버전을 설치합니다."

#--------------------------------------------------------------------------
# Custom Page - POPFile Installation Options
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_TITLE       "POPFile(팝파일) 설치 옵션"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_SUBTITLE    "굳이 바꾸셔야 하지 않으면 바꾸지 마십시오."

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_POP3     "POP3 연결을 위한 디폴트 포트 번호를 선택하십시오(110을 권장합니다)."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_GUI      "'사용자 화면' 연결을 위한 디폴트 포트 번호를 선택하십시오(8080을 권장합니다)."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_STARTUP  "윈도우 시작시에 자동으로 POPFile을 실행합니다(백그라운드로 실행)."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_WARNING  "경고"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_MESSAGE  "POPFile을 업그레이드하시는 것이라면 인스톨러는 현재 버전을 종료시킬 것입니다."

; Message Boxes used when validating user's selections

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_1    "POP3 포트가 설정될 수 없습니다 - 포트:"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_2    "포트는 1에서 65535 까지의 숫자여야만 합니다."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_3    "POP3 포트 선택을 변경하십시오."

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_1     "'사용자 화면' 포트가 설정될 수 없습니다 - 포트:"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_2     "포트는 1에서 65535 까지의 숫자여야만 합니다."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_3     "'사용자 화면' 포트 선택을 변경하십시오."

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_1    "POP3 포트는 '사용자 화면' 포트와 반드시 달라야 합니다."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_2    "포트 선택을 변경하십시오."

#--------------------------------------------------------------------------
# Standard MUI Page - Installing POPfile
#--------------------------------------------------------------------------

; Installation Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_UPGRADE   "업그레이드 설치인지 확인 중..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_CORE      "POPFile 핵심 파일을 설치 중..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_PERL      "Perl 최소 설치 중..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SHORT     "POPFile 바로가기 생성 중..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_CORPUS    "Making corpus backup. This may take a few seconds..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SKINS     "POPFile 스킨 파일 설치 중..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_LANGS     "POPFile UI 언어 파일 설치 중..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_ENDSEC    "계속 진행하기 위해 '다음'을 누르십시오."

; Installation Log Messages

!insertmacro PFI_LANG_STRING PFI_LANG_INST_LOG_1          "이전 버전의 POPFile을 종료 중 - 포트:"

; Message Box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_1          "이전 설치에 의한 파일 발견."
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_2          "이 파일을 업데이트 하시겠습니까?"
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_3          "'예'를 누르면 업데이트합니다. (이전 파일은 다음으로 저장될 것입니다:"
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_4          "'아니오'를 누르면 이전 파일을 보존합니다. (새 파일은 다음으로 저장될 것입니다:"

!insertmacro PFI_LANG_STRING PFI_LANG_MBCFGBK_1           "백업:"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCFGBK_2           "이 이미 존재합니다."
!insertmacro PFI_LANG_STRING PFI_LANG_MBCFGBK_3           "이 파일을 덮어 쓰시겠습니까?"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCFGBK_4           "'예'를 누르시면 덮어 씁니다. '아니오'를 누르시면 백업을 만들지 않습니다."

!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_1         "Unable to shutdown POPFile automatically."
!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_2         "Please shutdown POPFile manually now."
!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_3         "When POPFile has been shutdown, click 'OK' to continue."

!insertmacro PFI_LANG_STRING PFI_LANG_MBCORPUS_1          "Error detected when the installer tried to backup the old corpus."

#--------------------------------------------------------------------------
# Custom Page - POPFile Classification Bucket Creation
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_TITLE           "POPFile 분류 버킷 생성"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_SUBTITLE        "POPFile은 메일 분류를 위해 최소한 2개의 버킷을 필요로 합니다."

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_INTRO        "필요에 따라, 설치 후에도 버킷 갯수와 이름을 쉽게 바꾸실 수 있습니다.\r\n\r\n버킷 이름은 반드시 영어 소문자와 숫자, 하이픈과 언더스코어(_)만으로 이루어진 한 단어여야 합니다."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_CREATE       "버킷을 생성하십시오. 드랍 다운 메뉴에서 제공된 것을 선택하시거나 원하시는 이름을 직접 치십시오."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_DELETE       "목록에 있는 버킷을 삭제하시려면 '제거' 체크박스에 체크표시 하시고 '계속' 버튼을 클릭하십시오."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_LISTHDR      "POPFile이 사용할 버킷"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_REMOVE       "제거"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_CONTINUE     "계속"

; Text strings used for status messages under the bucket list

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_1        "버킷을 더 추가할 필요는 없습니다."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_2        "최소한 2개의 버킷을 정의해야 합니다."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_3        "버킷이 최소한 1개 더 필요합니다."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_4        "인스톨러는 "
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_5        "개 이상의 버킷을 생성할 수 없습니다."

; Message box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_1      " "
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_2      "이라는 버킷이 이미 정의되었습니다. "
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_3      "새 버킷에 다른 이름을 주십시오."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_1      "인스톨러는 최대 "
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_2      "개의 버킷을 생성할 수 있습니다."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_3      "POPFile이 설치된 후에 더 많은 버킷을 생성할 수 있습니다"

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_1      " "
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_2      "은(는) 유효한 버킷 이름이 아닙니다."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_3      "버킷 이름은 반드시 영어소문자와 숫자, 그리고 - 와 _ 만으로 이루어진 한 단어여야 합니다."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_4      "이 버킷에 다른 이름을 지정해 주십시오."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_1     "POPFile이 메일 분류를 하기 위해서는 최소한 2개의 버킷이 필요합니다."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_2     "생성할 버킷 이름을 입력하십시오-$\r$\n$\r$\n드랍 다운 메뉴에서 제공된 것을 선택하시거나$\r$\n$\r$\n원하시는 이름을 직접 치십시오."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_3     "설치가 계속 되려면 최소한 2개의 버킷을 정의하셔야 합니다."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_1        "개의 POPFile이 사용할 버킷이 정의되었습니다."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_2        "POPFile이 이 버킷을 사용하도록 설정하시겠습니까?"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_3        "버킷 선택을 변경하려면 '아니오'를 클릭하십시오."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_1      "인스톨러는 다음 버킷을 생성할 수 없었습니다:"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_2      "중"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_3      "의 선택하신 버킷"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_4      "POPFile이 설치된 후 '사용자 화면'을 이용하여 버킷을 추가하실 수 있습니다.$\r$\n$\r$\n"

#--------------------------------------------------------------------------
# Custom Page - Email Client Reconfiguration
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_TITLE       "Email Client Configuration"
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_SUBTITLE    "POPFile can reconfigure several email clients for you"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_TEXT_1   "Mail clients marked (*) can be reconfigured automatically, assuming simple accounts are used.\r\n\r\nIt is strongly recommended that accounts which require authentication are configured manually."
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_TEXT_2   "IMPORTANT: PLEASE SHUT DOWN THE RECONFIGURABLE EMAIL CLIENTS NOW\r\n\r\nThis feature is still under development (e.g. some Outlook accounts may not be detected).\r\n\r\nPlease check that the reconfiguration was successful (before using the email client)."

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_CANCEL   "Email client reconfiguration cancelled by user"

#--------------------------------------------------------------------------
# Text used on buttons to skip configuration of email clients
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_SKIPALL  "Skip All"
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_SKIPONE  "Skip Client"

#--------------------------------------------------------------------------
# Message box warnings that an email client is still running
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_EXP        "WARNING: Outlook Express appears to be running !"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_OUT        "WARNING: Outlook appears to be running !"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_EUD        "WARNING: Eudora appears to be running !"

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_1     "Please SHUT DOWN the email program then click 'Retry' to reconfigure it"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_2     "(You can click 'Ignore' to reconfigure it, but this is not recommended)"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_3     "Click 'Abort' to skip the reconfiguration of this email program"

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_4     "Please SHUT DOWN the email program then click 'Retry' to restore the settings"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_5     "(You can click 'Ignore' to restore the settings, but this is not recommended)"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_6     "Click 'Abort' to skip the restoring of the original settings"

#--------------------------------------------------------------------------
# Custom Page - Reconfigure Outlook/Outlook Express
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_TITLE         "아웃룩 익스프레스 설정을 변경하십시오."
!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_SUBTITLE      "POPFile은 아웃룩 익스프레스 설정을 변경해드릴 수 있습니다."

!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_TITLE         "Reconfigure Outlook"
!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_SUBTITLE      "POPFile can reconfigure Outlook for you"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_IO_CANCELLED  "Outlook Express reconfiguration cancelled by user"
!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_IO_CANCELLED  "Outlook reconfiguration cancelled by user"

!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_BOXHDR     "accounts"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_ACCOUNTHDR "Account"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_EMAILHDR   "Email address"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_SERVERHDR  "Server"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_USRNAMEHDR "Username"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_FOOTNOTE   "Tick box(es) to reconfigure account(s).\r\nIf you uninstall POPFile the original settings will be restored."

; Message Box to confirm changes to Outlook/Outlook Express account configuration

!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_MBIDENTITY    "Outlook Express Identity :"
!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_MBACCOUNT     "Outlook Express Account :"

!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_MBIDENTITY    "Outlook User :"
!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_MBACCOUNT     "Outlook Account :"

!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBEMAIL       "Email address :"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBSERVER      "POP3 server :"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBUSERNAME    "POP3 username :"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBOEPORT      "POP3 port :"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBOLDVALUE    "currently"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBQUESTION    "Reconfigure this account to work with POPFile ?"

; Title and Column headings for report/log files

!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_LOG_BEFORE    "Outlook Express Settings before any changes were made"
!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_LOG_AFTER     "Changes made to Outlook Express Settings"

!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_LOG_BEFORE    "Outlook Settings before any changes were made"
!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_LOG_AFTER     "Changes made to Outlook Settings"

!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_LOG_END       "(end)"

!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_LOG_IDENTITY  "'IDENTITY'"
!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_LOG_IDENTITY  "'OUTLOOK USER'"

!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_LOG_ACCOUNT   "'ACCOUNT'"

!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_LOG_EMAIL     "'EMAIL ADDRESS'"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_LOG_SERVER    "'POP3 SERVER'"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_LOG_USER      "'POP3 USERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_LOG_PORT      "'POP3 PORT'"

!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_LOG_NEWSERVER "'NEW POP3 SERVER'"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_LOG_NEWUSER   "'NEW POP3 USERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_LOG_NEWPORT   "'NEW POP3 PORT'"

#--------------------------------------------------------------------------
# Custom Page - Reconfigure Eudroa
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_TITLE         "아웃룩 익스프레스 설정을 변경하십시오."
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_SUBTITLE      "POPFile은 아웃룩 익스프레스 설정을 변경해드릴 수 있습니다."

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_CANCELLED  "Eudora reconfiguration cancelled by user"

!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_INTRO_1    "POPFile has detected the following Eudora personality"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_INTRO_2    " and can automatically configure it to work with POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_CHECKBOX   "Reconfigure this personality to work with POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_DOMINANT   "<Dominant> personality"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_PERSONA    "personality"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_EMAIL      "전자 메일 주소:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_SERVER     "받는 메일(POP3) 서버:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_USERNAME   "계정 이름:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_POP3PORT   "POP3 port:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_RESTORE    "POPFile을 언인스톨 하시면 원래 설정이 복원될 것입니다."

#--------------------------------------------------------------------------
# Custom Page - POPFile can now be started
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_TITLE        "이제 POPFile을 시작하실 수 있습니다."
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_SUBTITLE     "POPFile 사용자 화면은 POPFile이 시작된 후에 사용가능합니다."

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_INTRO     "POPFile을 지금 시작할까요?"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NO        "아니오 ('사용자 화면'은 POPFile이 시작되지 않으면 사용할 수 없습니다.)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_DOSBOX    "POPFile 시작 (창에서)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_BCKGRND   "POPFile을 백그라운드에서 시작 (창이 나타나지 않습니다)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_1    "POPFile 시작되고 나면 '사용자 화면'을 표시할 수 있습니다."
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_2    " (a) 시스템 트레이의 POPFile 아이콘을 클릭하시거나,"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_3    " (b) 시작 --> 프로그램(P) --> POPFile --> POPFile User Interface 를 선택하십시오."

; Banner message displayed whilst waiting for POPFile to start

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_BANNER_1     "POPFile을 시동 준비 중."
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_BANNER_2     "몇초 정도 걸릴 수 있습니다..."

#--------------------------------------------------------------------------
# Standard MUI Page - Installation Page (for the 'Corpus Conversion Monitor' utility)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_MUTEX        "Another copy of the 'Corpus Conversion Monitor' is already running !"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_PRIVATE      "The 'Corpus Conversion Monitor' is part of the POPFile installer"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_NOFILE       "Error: Corpus conversion data file does not exist !"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_NOPOPFILE    "Error: POPFile path missing"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_ENVNOTSET    "Error: Unable to set an environment variable"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_NOKAKASI     "Error: Kakasi path missing"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_STARTERR     "An error occurred when starting the corpus conversion process"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_ESTIMATE     "Estimated time remaining: "
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_MINUTES      "minutes"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_WAITING      "(waiting for first file to be converted)"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_TOTALFILES   "There are $G_BUCKET_COUNT bucket files to be converted"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_PROGRESS_N   "After $G_ELAPSED_TIME.$G_DECPLACES minutes there are $G_STILL_TO_DO files left to convert"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_PROGRESS_1   "After $G_ELAPSED_TIME.$G_DECPLACES minutes there is one file left to convert"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_SUMMARY      "Corpus Conversion took $G_ELAPSED_TIME.$G_DECPLACES minutes"

#--------------------------------------------------------------------------
# Standard MUI Page - Uninstall POPFile
#--------------------------------------------------------------------------

; Uninstall Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROGRESS_1        "POPFile 종료 중..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROGRESS_2        "'시작' 메뉴 중 POPFile 항목을 삭제 중..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROGRESS_3        "POPFile 핵심 파일을 삭제 중..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROGRESS_4        "아웃룩 익스프레스 설정을 복원 중..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROGRESS_5        "POPFile 스킨 파일 삭제 중..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROGRESS_6        "Perl 최소 설치 파일 삭제 중..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROGRESS_7        "Restoring Outlook settings..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROGRESS_8        "Restoring Eudora settings..."

; Uninstall Log Messages

!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_1             "POPFile을 종료 중 - 포트:"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_2             "열림"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_3             "복원됨"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_4             "닫힘"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_5             "POPFile 디렉토리의 모든 파일을 제거 중."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_6             "참고: POPFile 디렉토리로부터 모든 파일을 제거할 수 없습니다."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_7             "Data problems"

; Message Box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBNOTFOUND_1      "POPFile이 디렉토리에 설치되지 않은 것 같습니다."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBNOTFOUND_2      "그래도 계속하시겠습니까?(권장하지 않음)"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_ABORT_1           "사용자에 의해 언인스톨이 취소됨"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_1        "'Outlook Express' problem !"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_2        "'Outlook' problem !"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_3        "'Eudora' problem !"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBEMAIL_1         "Unable to restore some original settings"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBEMAIL_2         "Display the error report ?"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_1         "Some email client settings have not been restored !"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_2         "(Details can be found in $INSTDIR folder)"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_3         "Click 'No' to ignore these errors and delete everything"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_4         "Click 'Yes' to keep this data (to allow another attempt later)"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMDIR_1        "POPFile 디렉토리의 모든 파일을 제거하시겠습니까?$\r$\n$\r$\n(직접 생성하신 파일이 있고, 보존하고 싶으시면 '아니오'를 클릭하십시오"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMERR_1        "참고"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMERR_2        "는 제거될 수 없었습니다."

#--------------------------------------------------------------------------
# Mark the end of the language data
#--------------------------------------------------------------------------

!undef PFI_LANG

#--------------------------------------------------------------------------
# End of 'Korean-pfi.nsh'
#--------------------------------------------------------------------------
