#--------------------------------------------------------------------------
# Korean-pfi.nsh
#
# This file contains additional "Korean" text strings used by the Windows installer
# for POPFile (these strings are unique to POPFile).
#
# See 'Korean-mui.nsh' for the strings which modify standard NSIS MUI messages.
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

#--------------------------------------------------------------------------
# Startup message box offering to display the Release Notes
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_1        "POPFile(팝파일) 릴리즈 노트를 표시할까요?"
!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_2        "POPFile을 업그레이드하시는 것이라면 '예' 를 권장합니다. (설치 전에 POPFile 폴더를 백업하셔야 할 수도 있습니다.)"

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

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBUNINST_1    "이전 버전의 POPFile(팝파일)이 설치된 것이 감지되었습니다."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBUNINST_2    "언인스톨 하시겠습니까?"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBUNINST_3    "'예' 가 권장됩니다."

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_1    "POP3 포트가 설정될 수 없습니다 - 포트:"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_2    "포트는 1에서 65535 까지의 숫자여야만 합니다."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_3    "POP3 포트 선택을 변경하십시오."

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_1     "'사용자 화면' 포트가 설정될 수 없습니다 - 포트:"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_2     "포트는 1에서 65535 까지의 숫자여야만 합니다."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_3     "'사용자 화면' 포트 선택을 변경하십시오."

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_1    "POP3 포트는 '사용자 화면' 포트와 반드시 달라야 합니다."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_2    "포트 선택을 변경하십시오."

; Banner message displayed whilst uninstalling old version

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_BANNER_1     "이전 버전 제거 중"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_BANNER_2     "몇초 정도 걸릴 수 있습니다..."

#--------------------------------------------------------------------------
# Standard MUI Page - Installing POPfile
#--------------------------------------------------------------------------

; Installation Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_UPGRADE   "업그레이드 설치인지 확인 중..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_CORE      "POPFile 핵심 파일을 설치 중..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_PERL      "Perl 최소 설치 중..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SHORT     "POPFile 바로가기 생성 중..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_FFCBACK   "Making corpus backup. This may take a few seconds..."
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
# Custom Page - Reconfigure Outlook Express
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_TITLE         "아웃룩 익스프레스 설정을 변경하십시오."
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_SUBTITLE      "POPFile은 아웃룩 익스프레스 설정을 변경해드릴 수 있습니다."

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_INTRO      "다음과 같은 아웃룩 익스프레스 메일 계정이 발견되었습니다. POPFile과 연동되도록 자동으로 설정을 변경할 수 있습니다."
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_CHECKBOX   "이 계정을 POPFile과 연동되도록 설정 변경함"
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_EMAIL      "전자 메일 주소:"
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_SERVER     "받는 메일(POP3) 서버:"
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_USERNAME   "계정 이름:"
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_RESTORE    "POPFile을 언인스톨 하시면 원래 설정이 복원될 것입니다."

!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_LINK_1     "계정 ("
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_LINK_2     ")"

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
# Standard MUI Page - Uninstall POPFile
#--------------------------------------------------------------------------

; Uninstall Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_UNSTRING PFI_LANG_PROGRESS_1        "POPFile 종료 중..."
!insertmacro PFI_LANG_UNSTRING PFI_LANG_PROGRESS_2        "'시작' 메뉴 중 POPFile 항목을 삭제 중..."
!insertmacro PFI_LANG_UNSTRING PFI_LANG_PROGRESS_3        "POPFile 핵심 파일을 삭제 중..."
!insertmacro PFI_LANG_UNSTRING PFI_LANG_PROGRESS_4        "아웃룩 익스프레스 설정을 복원 중..."
!insertmacro PFI_LANG_UNSTRING PFI_LANG_PROGRESS_5        "POPFile 스킨 파일 삭제 중..."
!insertmacro PFI_LANG_UNSTRING PFI_LANG_PROGRESS_6        "Perl 최소 설치 파일 삭제 중..."

; Uninstall Log Messages

!insertmacro PFI_LANG_UNSTRING PFI_LANG_LOG_1             "POPFile을 종료 중 - 포트:"
!insertmacro PFI_LANG_UNSTRING PFI_LANG_LOG_2             "열림"
!insertmacro PFI_LANG_UNSTRING PFI_LANG_LOG_3             "복원됨"
!insertmacro PFI_LANG_UNSTRING PFI_LANG_LOG_4             "닫힘"
!insertmacro PFI_LANG_UNSTRING PFI_LANG_LOG_5             "POPFile 디렉토리의 모든 파일을 제거 중."
!insertmacro PFI_LANG_UNSTRING PFI_LANG_LOG_6             "참고: POPFile 디렉토리로부터 모든 파일을 제거할 수 없습니다."

; Message Box text strings

!insertmacro PFI_LANG_UNSTRING PFI_LANG_MBNOTFOUND_1      "POPFile이 디렉토리에 설치되지 않은 것 같습니다."
!insertmacro PFI_LANG_UNSTRING PFI_LANG_MBNOTFOUND_2      "그래도 계속하시겠습니까?(권장하지 않음)"

!insertmacro PFI_LANG_UNSTRING PFI_LANG_ABORT_1           "사용자에 의해 언인스톨이 취소됨"

!insertmacro PFI_LANG_UNSTRING PFI_LANG_MBREMDIR_1        "POPFile 디렉토리의 모든 파일을 제거하시겠습니까?$\r$\n$\r$\n(직접 생성하신 파일이 있고, 보존하고 싶으시면 '아니오'를 클릭하십시오"

!insertmacro PFI_LANG_UNSTRING PFI_LANG_MBREMERR_1        "참고"
!insertmacro PFI_LANG_UNSTRING PFI_LANG_MBREMERR_2        "는 제거될 수 없었습니다."

#--------------------------------------------------------------------------
# Mark the end of the language data
#--------------------------------------------------------------------------

!undef PFI_LANG

#--------------------------------------------------------------------------
# End of 'Korean-pfi.nsh'
#--------------------------------------------------------------------------
