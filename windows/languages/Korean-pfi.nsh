#--------------------------------------------------------------------------
# Korean-pfi.nsh
#
# This file contains the "Korean" text strings used by the Windows installer
# and other NSIS-based Windows utilities for POPFile (includes customised versions
# of strings provided by NSIS and strings which are unique to POPFile).
#
# These strings are grouped according to the page/window and script where they are used
#
# Copyright (c) 2003-2005 John Graham-Cumming
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
#   (1) The sequence  ${MB_NL}          inserts a newline
#   (2) The sequence  ${MB_NL}${MB_NL}  inserts a blank line
#
# (the 'PFI_LANG_CBP_MBCONTERR_2' message box string which is listed under the heading
# 'Custom Page - POPFile Classification Bucket Creation' includes some examples)
#--------------------------------------------------------------------------
# String Formatting (applies to PFI_LANG_*_IO_ text used for custom pages):
#
#   (1) The sequence  ${IO_NL}          inserts a newline
#   (2) The sequence  ${IO_NL}${IO_NL}  inserts a blank line
#
# (the 'PFI_LANG_CBP_IO_INTRO' custom page string which is listed under the heading
# 'Custom Page - POPFile Classification Bucket Creation' includes some examples)
#--------------------------------------------------------------------------
# Some strings will be customised at run-time using data held in Global User Variables.
# These variables will have names which start with '$G_', e.g. $G_PLS_FIELD_1
#--------------------------------------------------------------------------

!ifndef PFI_VERBOSE
  !verbose 3
!endif

#--------------------------------------------------------------------------
# Mark the start of the language data
#--------------------------------------------------------------------------

!define PFI_LANG  "KOREAN"

#--------------------------------------------------------------------------
# Symbols used to avoid confusion over where the line breaks occur.
# (normally these symbols will be defined before this file is 'included')
#
# ${IO_NL} is used for InstallOptions-style 'new line' sequences.
# ${MB_NL} is used for MessageBox-style 'new line' sequences.
#--------------------------------------------------------------------------

!ifndef IO_NL
  !define IO_NL     "\r\n"
!endif

!ifndef MB_NL
  !define MB_NL     "$\r$\n"
!endif

###########################################################################
###########################################################################

#--------------------------------------------------------------------------
# CONTENTS:
#
#   "General Purpose" strings
#
#   "Shared" strings used by more than one script
#
#   "POPFile Installer" strings used by the main POPFile installer/uninstaller (installer.nsi)
#
#   "SSL Setup" strings used by the standalone "SSL Setup" wizard (addssl.nsi)
#
#   "Get SSL" strings used when downloading/installing SSL support (getssl.nsh)
#
#   "Add User" strings used by the 'Add POPFile User' installer/uninstaller (adduser.nsi)
#
#   "Corpus Conversion" strings used by the 'Monitor Corpus Conversion' utility (MonitorCC.nsi)
#
#--------------------------------------------------------------------------

###########################################################################
###########################################################################

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; General Purpose:  (used for banners and page titles/subtitles in several scripts)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_BE_PATIENT           "이전 버전 제거 중"
!insertmacro PFI_LANG_STRING PFI_LANG_TAKE_A_FEW_SECONDS   "몇초 정도 걸릴 수 있습니다..."

###########################################################################
###########################################################################

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Message displayed when wizard does not seem to belong to the current installation [adduser.nsi, runpopfile.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_COMPAT_NOTFOUND      "Error: Compatible version of ${C_PFI_PRODUCT} not found !"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Message box shown (before the WELCOME page) if another installer is running [installer.nsi, adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_INSTALLER_MUTEX      "Another copy of the POPFile installer is already running !"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Message box shown if 'SetEnvironmentVariableA' fails [installer.nsi, adduser.nsi, MonitorCC.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_ENVNOTSET    "Error: Unable to set an environment variable"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Used in message box shown if existing files found when installing [installer.nsi, adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_2   "Do you want to upgrade it ?"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Standard MUI Page - INSTFILES
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; When upgrading an existing installation, change the normal "Install" button to "Upgrade" [installer.nsi, adduser.nsi]

!insertmacro PFI_LANG_STRING PFI_LANG_INST_BTN_UPGRADE     "Upgrade"

; Installation Progress Reports displayed above the progress bar [installer.nsi, adduser.nsi]

!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_UPGRADE    "업그레이드 설치인지 확인 중..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SHORT      "POPFile 바로가기 생성 중..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_LANGS      "POPFile UI 언어 파일 설치 중..."

; Installation Progress Reports displayed above the progress bar [installer.nsi, adduser.nsh, getssl.nsh]

!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_ENDSEC     "계속 진행하기 위해 '다음'을 누르십시오."

; Installation Log Messages [installer.nis, adduser.nsi]

!insertmacro PFI_LANG_STRING PFI_LANG_INST_LOG_SHUTDOWN    "이전 버전의 POPFile을 종료 중 - 포트:"

; Message Box text strings [installer.nsi, adduser.nsi, pfi-library.nsh]

!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_1          "Unable to shutdown '$G_PLS_FIELD_1' automatically."
!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_2          "Please shutdown '$G_PLS_FIELD_1' manually now."
!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_3          "When '$G_PLS_FIELD_1' has been shutdown, click 'OK' to continue."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Message boxes shown if uninstallation is not straightforward [installer.nsi, adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBDIFFUSER_1      "'$G_WINUSERNAME' is attempting to remove data belonging to another user"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBNOTFOUND_1      "POPFile이 디렉토리에 설치되지 않은 것 같습니다."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBNOTFOUND_2      "그래도 계속하시겠습니까?(권장하지 않음)"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Message box shown if uninstaller is cancelled by the user [installer.nsi, adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_UN_ABORT_1           "사용자에 의해 언인스톨이 취소됨"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Standard MUI Page - UNPAGE_INSTFILES [installer.nsi, adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Uninstall Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_SHUTDOWN     "POPFile 종료 중..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_SHORT        "'시작' 메뉴 중 POPFile 항목을 삭제 중..."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Message box shown if uninstaller failed to remove files/folders [installer.nsi, adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; TempTranslationNote: PFI_LANG_UN_MBREMERR_A = PFI_LANG_UN_MBREMERR_1 + ": $G_PLS_FIELD_1 " + PFI_LANG_UN_MBREMERR_2

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMERR_A        "참고: $G_PLS_FIELD_1 는 제거될 수 없었습니다."

###########################################################################
###########################################################################

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; POPFile Installer: Message box shown (before the WELCOME page) offering to display the release notes [installer.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_1         "POPFile(팝파일) 릴리즈 노트를 표시할까요?"
!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_2         "POPFile을 업그레이드하시는 것이라면 '예' 를 권장합니다. (설치 전에 POPFile 폴더를 백업하셔야 할 수도 있습니다.)"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; POPFile Installer: Standard MUI Page - WELCOME [installer.nsi]
;
; The PFI_LANG_WELCOME_INFO_TEXT string should end with a '${IO_NL}${IO_NL}$_CLICK' sequence).
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_WELCOME_INFO_TEXT    "이 마법사는 귀하의 컴퓨터에 POPFile(팝파일)을 설치할 것입니다.${IO_NL}${IO_NL}설치를 시작하기 전에 모든 프로그램을 종료시킬 것을 권장합니다.${IO_NL}${IO_NL}$_CLICK"
!insertmacro PFI_LANG_STRING PFI_LANG_WELCOME_ADMIN_TEXT   "IMPORTANT NOTICE:${IO_NL}${IO_NL}The current user does NOT have 'Administrator' rights.${IO_NL}${IO_NL}If multi-user support is required, it is recommended that you cancel this installation and use an 'Administrator' account to install POPFile."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; POPFile Installer: Custom Page - Check Perl Requirements [installer.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Page Title displayed in the page header (there is no sub-title for this page)

!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_TITLE        "Out-of-date System Components Detected"

; Text strings displayed on the custom page

; TempTranslationNote: PFI_LANG_PERLREQ_IO_TEXT_A =  PFI_LANG_PERLREQ_IO_TEXT_1
; TempTranslationNote: PFI_LANG_PERLREQ_IO_TEXT_B =  PFI_LANG_PERLREQ_IO_TEXT_2
; TempTranslationNote: PFI_LANG_PERLREQ_IO_TEXT_C =  PFI_LANG_PERLREQ_IO_TEXT_3
; TempTranslationNote: PFI_LANG_PERLREQ_IO_TEXT_D =  PFI_LANG_PERLREQ_IO_TEXT_4
; TempTranslationNote: PFI_LANG_PERLREQ_IO_TEXT_E =  PFI_LANG_PERLREQ_IO_TEXT_5 + " $G_PLS_FIELD_1${IO_NL}${IO_NL}"
; TempTranslationNote: PFI_LANG_PERLREQ_IO_TEXT_F =  PFI_LANG_PERLREQ_IO_TEXT_6
; TempTranslationNote: PFI_LANG_PERLREQ_IO_TEXT_G =  PFI_LANG_PERLREQ_IO_TEXT_7

!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_A    "The default browser is used to display the POPFile User Interface (its control centre).${IO_NL}${IO_NL}"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_B    "POPFile does not require a specific browser, it will work with almost any browser.${IO_NL}${IO_NL}"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_C    "A minimal version of Perl is about to be installed (POPFile is written in Perl).${IO_NL}${IO_NL}"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_D    "The Perl supplied with POPFile makes use of some Internet Explorer components and requires Internet Explorer 5.5 (or a later version)."
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_E    "The installer has detected that this system has Internet Explorer $G_PLS_FIELD_1${IO_NL}${IO_NL}"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_F    "It is possible that some features of POPFile may not work properly on this system.${IO_NL}${IO_NL}"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_G    "If you have any problems with POPFile, an upgrade to a newer version of Internet Explorer may help."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; POPFile Installer: Standard MUI Page - COMPONENTS [installer.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING DESC_SecPOPFile               "POPFile에 필요한 핵심 파일(Perl의 최소설치 버전 포함)을 설치합니다."
!insertmacro PFI_LANG_STRING DESC_SecSkins                 "사용자 인터페이스 화면의 모양을 바꿀 수 있는 POPFile 스킨을 설치합니다."
!insertmacro PFI_LANG_STRING DESC_SecLangs                 "POPFile 사용자화면의 다국어 버전을 설치합니다."

!insertmacro PFI_LANG_STRING DESC_SubSecOptional           "Extra POPFile components (for advanced users)"
!insertmacro PFI_LANG_STRING DESC_SecIMAP                  "Installs the POPFile IMAP module"
!insertmacro PFI_LANG_STRING DESC_SecNNTP                  "Installs POPFile's NNTP proxy"
!insertmacro PFI_LANG_STRING DESC_SecSMTP                  "Installs POPFile's SMTP proxy"
!insertmacro PFI_LANG_STRING DESC_SecSOCKS                 "Installs extra Perl components which allow the POPFile proxies to use SOCKS"
!insertmacro PFI_LANG_STRING DESC_SecSSL                   "Downloads and installs the Perl components and SSL libraries which allow POPFile to make SSL connections to mail servers"
!insertmacro PFI_LANG_STRING DESC_SecXMLRPC                "Installs the POPFile XMLRPC module (for access to the POPFile API) and the Perl support it requires."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; POPFile Installer: Standard MUI Page - DIRECTORY (for POPFile program files) [installer.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Page Title shown in the page header and Text shown above the box showing the folder selected for the installation

!insertmacro PFI_LANG_STRING PFI_LANG_ROOTDIR_TITLE        "Choose Program Files Install Location"
!insertmacro PFI_LANG_STRING PFI_LANG_ROOTDIR_TEXT_DESTN   "Destination Folder for the POPFile Program"

; Message box warnings used when verifying the installation folder chosen by user

!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_1   "이전 버전의 POPFile(팝파일)이 설치된 것이 감지되었습니다."

; Text strings used when user has NOT selected a component found in the existing installation

!insertmacro PFI_LANG_STRING MBCOMPONENT_PROB_1            "Do you want to upgrade the existing $G_PLS_FIELD_1 component ?"
!insertmacro PFI_LANG_STRING MBCOMPONENT_PROB_2            "(using out of date POPFile components can cause problems)"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; POPFile Installer: Custom Page - Setup Summary [installer.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Page Title and Sub-title displayed in the page header
; $G_WINUSERNAME holds the Windows login name and $G_WINUSERTYPE holds 'Admin', 'Power', 'User', 'Guest' or 'Unknown'

!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_TITLE        "Setup Summary for '$G_WINUSERNAME' ($G_WINUSERTYPE)"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_SUBTITLE     "These settings will be used to install the POPFile program"

; Display selected installation location and whether or not an upgrade will be performed
; $G_ROOTDIR holds the installation location, e.g. C:\Program Files\POPFile

!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_NEWLOCN      "New POPFile installation at $G_ROOTDIR"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_UPGRADELOCN  "Upgrade existing POPFile installation at $G_ROOTDIR"

; By default all of these components are installed (but Kakasi is only installed when Japanese/Nihongo language is chosen)

!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_BASICLIST    "Basic POPFile components to be installed:"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_POPFILECORE  "POPFile program files"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_MINPERL      "Minimal Perl"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_DEFAULTSKIN  "Default UI Skin"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_DEFAULTLANG  "Default UI Language"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_EXTRASKINS   "Additional UI Skins"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_EXTRALANGS   "Additional UI Languages"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_KAKASI       "Kakasi package"

; By default none of the optional components is installed (user has to select them)

!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_OPTIONLIST   "Optional POPFile components to be installed:"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_NONE         "(none)"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_IMAP         "IMAP module"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_NNTP         "NNTP proxy"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_SMTP         "SMTP proxy"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_SOCKS        "SOCKS support"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_SSL          "SSL support"
!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_XMLRPC       "XMLRPC module"

; The last line in the summary explains how to change the installation selections

!insertmacro PFI_LANG_STRING PFI_LANG_SUMMARY_BACKBUTTON   "To make changes, use the 'Back' button to return to previous pages"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; POPFile Installer: Standard MUI Page - INSTFILES [installer.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Page Title and Sub-title displayed in the page header after installing all the files

!insertmacro PFI_LANG_STRING PFI_LANG_INSTFINISH_TITLE     "Program Files Installed"
!insertmacro PFI_LANG_STRING PFI_LANG_INSTFINISH_SUBTITLE  "${C_PFI_PRODUCT} must be configured before it can be used"

; Installation Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_CORE       "POPFile 핵심 파일을 설치 중..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_PERL       "Perl 최소 설치 중..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SKINS      "POPFile 스킨 파일 설치 중..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_XMLRPC     "Installing POPFile XMLRPC files..."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; POPFile Installer: Standard MUI Page - UNPAGE_INSTFILES [installer.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Uninstall Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_CORE         "POPFile 핵심 파일을 삭제 중..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_SKINS        "POPFile 스킨 파일 삭제 중..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_PERL         "Perl 최소 설치 파일 삭제 중..."

; Uninstall Log Messages

!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_SHUTDOWN      "POPFile을 종료 중 - 포트:"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_DELROOTDIR    "POPFile 디렉토리의 모든 파일을 제거 중."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_DELROOTERR    "참고: POPFile 디렉토리로부터 모든 파일을 제거할 수 없습니다."

; Message Box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMDIR_1        "POPFile 디렉토리의 모든 파일을 제거하시겠습니까?${MB_NL}${MB_NL}$G_ROOTDIR${MB_NL}${MB_NL}(직접 생성하신 파일이 있고, 보존하고 싶으시면 '아니오'를 클릭하십시오"


###########################################################################
###########################################################################

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; SSL Setup: Standard MUI Page - WELCOME
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PSS_LANG_WELCOME_TITLE        "Welcome to the $(^NameDA) Wizard"
!insertmacro PFI_LANG_STRING PSS_LANG_WELCOME_TEXT         "This utility will download and install the files needed to allow POPFile to use SSL when accessing mail servers.${IO_NL}${IO_NL}This version does not configure any email accounts to use SSL, it just installs the necessary Perl components and DLLs.${IO_NL}${IO_NL}This product downloads software developed by the OpenSSL Project for use in the OpenSSL Toolkit (http://www.openssl.org/)${IO_NL}${IO_NL}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${IO_NL}${IO_NL}   PLEASE SHUT DOWN POPFILE NOW${IO_NL}${IO_NL}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${IO_NL}${IO_NL}$_CLICK"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; SSL Setup: Standard MUI Page - LICENSE
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PSS_LANG_LICENSE_SUBHDR       "Please review the license terms before using $(^NameDA)."
!insertmacro PFI_LANG_STRING PSS_LANG_LICENSE_BOTTOM       "If you accept the terms of the agreement, click the check box below. You must accept the agreement to use $(^NameDA). $_CLICK"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; SSL Setup: Standard MUI Page - DIRECTORY
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PSS_LANG_DESTNDIR_TITLE       "Choose existing POPFile 0.22 (or later) installation"
!insertmacro PFI_LANG_STRING PSS_LANG_DESTNDIR_SUBTITLE    "SSL support should only be added to an existing POPFile installation"
!insertmacro PFI_LANG_STRING PSS_LANG_DESTNDIR_TEXT_TOP    "SSL support must be installed using the same installation folder as the POPFile program${MB_NL}${MB_NL}This utility will add SSL support to the version of POPFile which is installed in the following folder. To install in a different POPFile installation, click Browse and select another folder. $_CLICK"
!insertmacro PFI_LANG_STRING PSS_LANG_DESTNDIR_TEXT_DESTN  "Existing POPFile 0.22 (or later) installation folder"

!insertmacro PFI_LANG_STRING PSS_LANG_DESTNDIR_MB_WARN_1   "POPFile 0.22 (or later) does NOT seem to be installed in${MB_NL}${MB_NL}$G_PLS_FIELD_1"
!insertmacro PFI_LANG_STRING PSS_LANG_DESTNDIR_MB_WARN_2   "Are you sure you want to use this folder ?"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; SSL Setup: Standard MUI Page - INSTFILES
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Initial page header

!insertmacro PFI_LANG_STRING PSS_LANG_STD_HDR              "Installing SSL support (for POPFile 0.22 or later)"
!insertmacro PFI_LANG_STRING PSS_LANG_STD_SUBHDR           "Please wait while the SSL files are downloaded and installed..."

; Successful completion page header

!insertmacro PFI_LANG_STRING PSS_LANG_END_HDR              "POPFile SSL Support installation completed"
!insertmacro PFI_LANG_STRING PSS_LANG_END_SUBHDR           "SSL support for POPFile has been installed successfully"

; Unsuccessful completion page header

!insertmacro PFI_LANG_STRING PSS_LANG_ABORT_HDR            "POPFile SSL Support installation failed"
!insertmacro PFI_LANG_STRING PSS_LANG_ABORT_SUBHDR         "The attempt to add SSL support to POPFile has failed"

; Progress reports

!insertmacro PFI_LANG_STRING PSS_LANG_PROG_INITIALISE      "Initializing..."
!insertmacro PFI_LANG_STRING PSS_LANG_PROG_CHECKIFRUNNING  "Checking if POPFile is running..."
!insertmacro PFI_LANG_STRING PSS_LANG_PROG_USERCANCELLED   "POPFile SSL Support installation cancelled by the user"
!insertmacro PFI_LANG_STRING PSS_LANG_PROG_SUCCESS         "POPFile SSL support installed"
!insertmacro PFI_LANG_STRING PSS_LANG_PROG_SAVELOG         "Saving install log file..."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; SSL Setup: Standard MUI Page - FINISH
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PSS_LANG_FINISH_TITLE         "Completing the $(^NameDA) Wizard"
!insertmacro PFI_LANG_STRING PSS_LANG_FINISH_TEXT          "SSL support for POPFile has been installed.${IO_NL}${IO_NL}You can now start POPFile and configure POPFile and your email client to use SSL.${IO_NL}${IO_NL}Click Finish to close this wizard."

!insertmacro PFI_LANG_STRING PSS_LANG_FINISH_README        "Important information"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; SSL Setup: Miscellaneous Strings
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PSS_LANG_MUTEX                "Another copy of the SSL Setup wizard is running!"

!insertmacro PFI_LANG_STRING PSS_LANG_COMPAT_NOTFOUND      "Warning: Cannot find compatible version of POPFile !"

!insertmacro PFI_LANG_STRING PSS_LANG_ABORT_WARNING        "Are you sure you want to quit the $(^NameDA) Wizard?"

!insertmacro PFI_LANG_STRING PSS_LANG_PREPAREPATCH         "Updating Module.pm (to avoid slow speed SSL downloads)"
!insertmacro PFI_LANG_STRING PSS_LANG_PATCHSTATUS          "Module.pm patch status: $G_PLS_FIELD_1"
!insertmacro PFI_LANG_STRING PSS_LANG_PATCHCOMPLETED       "Module.pm file has been updated"
!insertmacro PFI_LANG_STRING PSS_LANG_PATCHFAILED          "Module.pm file has not been updated"

###########################################################################
###########################################################################

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Get SSL: Strings used when downloading and installing the optional SSL files [getssl.nsh]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Progress reports

!insertmacro PFI_LANG_STRING PFI_LANG_PROG_CHECKINTERNET   "Checking Internet connection..."
!insertmacro PFI_LANG_STRING PFI_LANG_PROG_STARTDOWNLOAD   "Downloading $G_PLS_FIELD_1 file from $G_PLS_FIELD_2"
!insertmacro PFI_LANG_STRING PFI_LANG_PROG_FILECOPY        "Copying $G_PLS_FIELD_2 files..."
!insertmacro PFI_LANG_STRING PFI_LANG_PROG_FILEEXTRACT     "Extracting files from $G_PLS_FIELD_2 archive..."

!insertmacro PFI_LANG_STRING PFI_LANG_TAKE_SEVERAL_SECONDS "(this may take several seconds)"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Get SSL: Message Box strings used when installing SSL Support [getssl.nsh]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_MB_INTERNETCONNECT   "The SSL Support files will be downloaded from the Internet${MB_NL}${MB_NL}Please connect to the Internet and the click 'OK'${MB_NL}${MB_NL}or click 'Cancel' to cancel this part of the installation"

!insertmacro PFI_LANG_STRING PFI_LANG_MB_NSISDLFAIL_1      "Download of $G_PLS_FIELD_1 file failed"
!insertmacro PFI_LANG_STRING PFI_LANG_MB_NSISDLFAIL_2      "(error: $G_PLS_FIELD_2)"

!insertmacro PFI_LANG_STRING PFI_LANG_MB_UNPACKFAIL        "Error detected while installing files in $G_PLS_FIELD_1 folder"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Get SSL: NSISdl strings (displayed by the plugin which downloads the SSL files) [getssl.nsh]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; The NSISdl plugin shows two progress bars, for example:
;
;     Downloading libeay32.dll
;
;     118kB (14%) of 816kB @ 3.1kB/s (3 minutes remaining)
;
; The default strings used by the plugin:
;
;   downloading - "Downloading %s"
;   connecting  - "Connecting ..."
;   second      - "second"
;   minute      - "minute"
;   hour        - "hour"
;   plural      - "s"
;   progress    - "%dkB (%d%%) of %dkB @ %d.%01dkB/s"
;   remaining   - " (%d %s%s remaining)"
;
; Note that the "remaining" string starts with a space
;
; Some languages might not be translated properly because plurals are formed simply
; by adding the "plural" value, so "hours" is translated by adding the value of the
; "PFI_LANG_NSISDL_PLURAL" string to the value of the "PFI_LANG_NSISDL_HOUR" string.
; This is a limitation of the NSIS plugin which is used to download the files.
;
; If this is a problem, the plural forms could be used for the PFI_LANG_NSISDL_SECOND,
; PFI_LANG_NSISDL_MINUTE and PFI_LANG_NSISDL_HOUR strings and the PFI_LANG_NSISDL_PLURAL
; string set to a space (" ") [using "" here will generate compiler warnings]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_NSISDL_DOWNLOADING   "Downloading %s"
!insertmacro PFI_LANG_STRING PFI_LANG_NSISDL_CONNECTING    "Connecting ..."
!insertmacro PFI_LANG_STRING PFI_LANG_NSISDL_SECOND        "second"
!insertmacro PFI_LANG_STRING PFI_LANG_NSISDL_MINUTE        "minute"
!insertmacro PFI_LANG_STRING PFI_LANG_NSISDL_HOUR          "hour"
!insertmacro PFI_LANG_STRING PFI_LANG_NSISDL_PLURAL        "s"
!insertmacro PFI_LANG_STRING PFI_LANG_NSISDL_PROGRESS      "%dkB (%d%%) of %dkB @ %d.%01dkB/s"
!insertmacro PFI_LANG_STRING PFI_LANG_NSISDL_REMAINING     " (%d %s%s remaining)"

###########################################################################
###########################################################################

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Standard MUI Page - WELCOME [adduser.nsi]
;
; The PFI_LANG_ADDUSER_INFO_TEXT string should end with a '${IO_NL}${IO_NL}$_CLICK' sequence).
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_INFO_TEXT    "This wizard will guide you through the configuration of POPFile for the '$G_WINUSERNAME' user.${IO_NL}${IO_NL}It is recommended that you close all other applications before continuing.${IO_NL}${IO_NL}$_CLICK"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Standard MUI Page - DIRECTORY [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; $G_WINUSERNAME holds the Windows login name for the user running the wizard

!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_TITLE        "Choose POPFile Data Location for '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_SUBTITLE     "Choose the folder in which to store the POPFile Data for '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_TEXT_TOP     "This version of POPFile uses separate sets of data files for each user.${MB_NL}${MB_NL}Setup will use the following folder for the POPFile data belonging to the '$G_WINUSERNAME' user. To use a different folder for this user, click Browse and select another folder. $_CLICK"
!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_TEXT_DESTN   "Folder to be used to store the POPFile data for '$G_WINUSERNAME'"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Standard MUI Page - INSTFILES [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_TITLE        "Configuring POPFile for '$G_WINUSERNAME' user"
!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_SUBTITLE     "Please wait while the POPFile configuration files are updated for this user"

; When resetting POPFile to use newly restored 'User Data', change "Install" button to "Restore"

!insertmacro PFI_LANG_STRING PFI_LANG_INST_BTN_RESTORE     "Restore"

; Installation Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_CORPUS     "Making corpus backup. This may take a few seconds..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SQLBACKUP  "Backing up the old SQLite database..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_FINDCORPUS "Looking for existing flat-file or BerkeleyDB corpus..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_MAKEBAT    "Generating the 'pfi-run.bat' batch file..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_REGSET     "Updating registry settings and environment variables..."

; Message Box text strings

; TempTranslationNote: PFI_LANG_MBSTPWDS_A = "POPFile 'stopwords' " + PFI_LANG_MBSTPWDS_1
; TempTranslationNote: PFI_LANG_MBSTPWDS_B = PFI_LANG_MBSTPWDS_2
; TempTranslationNote: PFI_LANG_MBSTPWDS_C = PFI_LANG_MBSTPWDS_3 + " 'stopwords.bak')"
; TempTranslationNote: PFI_LANG_MBSTPWDS_D = PFI_LANG_MBSTPWDS_4 + " 'stopwords.default')"

!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_A           "POPFile 'stopwords' 이전 설치에 의한 파일 발견."
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_B           "이 파일을 업데이트 하시겠습니까?"
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_C           "'예'를 누르면 업데이트합니다. (이전 파일은 다음으로 저장될 것입니다: 'stopwords.bak')"
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_D           "'아니오'를 누르면 이전 파일을 보존합니다. (새 파일은 다음으로 저장될 것입니다: 'stopwords.default')"

!insertmacro PFI_LANG_STRING PFI_LANG_MBCORPUS_1           "Error detected when the installer tried to backup the old corpus."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Message box warnings used when verifying the installation folder chosen by user [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_3   "Previous configuration data found at"
!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_4   "Restored configuration data found"
!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_5   "Do you want to use the restored data ?"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Custom Page - POPFile Installation Options [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_TITLE        "POPFile(팝파일) 설치 옵션"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_SUBTITLE     "굳이 바꾸셔야 하지 않으면 바꾸지 마십시오."

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_POP3      "POP3 연결을 위한 디폴트 포트 번호를 선택하십시오(110을 권장합니다)."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_GUI       "'사용자 화면' 연결을 위한 디폴트 포트 번호를 선택하십시오(8080을 권장합니다)."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_STARTUP   "윈도우 시작시에 자동으로 POPFile을 실행합니다(백그라운드로 실행)."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_WARNING   "경고"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_MESSAGE   "POPFile을 업그레이드하시는 것이라면 인스톨러는 현재 버전을 종료시킬 것입니다."

; Message Boxes used when validating user's selections

; TempTranslationNote: PFI_LANG_OPTIONS_MBPOP3_A = PFI_LANG_OPTIONS_MBPOP3_1 + " '$G_POP3'."
; TempTranslationNote: PFI_LANG_OPTIONS_MBPOP3_B = PFI_LANG_OPTIONS_MBPOP3_2
; TempTranslationNote: PFI_LANG_OPTIONS_MBPOP3_C = PFI_LANG_OPTIONS_MBPOP3_3

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_A     "POP3 포트가 설정될 수 없습니다 - 포트: '$G_POP3'."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_B     "포트는 1에서 65535 까지의 숫자여야만 합니다."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_C     "POP3 포트 선택을 변경하십시오."

; TempTranslationNote: PFI_LANG_OPTIONS_MBGUI_A = PFI_LANG_OPTIONS_MBGUI_1 + " '$G_GUI'."
; TempTranslationNote: PFI_LANG_OPTIONS_MBGUI_B = PFI_LANG_OPTIONS_MBGUI_2
; TempTranslationNote: PFI_LANG_OPTIONS_MBGUI_C = PFI_LANG_OPTIONS_MBGUI_3

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_A      "'사용자 화면' 포트가 설정될 수 없습니다 - 포트: '$G_GUI'."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_B      "포트는 1에서 65535 까지의 숫자여야만 합니다."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_C      "'사용자 화면' 포트 선택을 변경하십시오."

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_1     "POP3 포트는 '사용자 화면' 포트와 반드시 달라야 합니다."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_2     "포트 선택을 변경하십시오."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Initialization required by POPFile Classification Bucket Creation [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; POPFile requires at least TWO buckets in order to work properly. PFI_LANG_CBP_DEFAULT_BUCKETS
; defines the default buckets and PFI_LANG_CBP_SUGGESTED_NAMES defines a list of suggested names
; to help the user get started with POPFile. Both lists use the | character as a name separator.

; Bucket names can only use the characters abcdefghijklmnopqrstuvwxyz_-0123456789
; (any names which contain invalid characters will be ignored by the installer)

; Empty lists ("") are allowed (but are not very user-friendly)

; The PFI_LANG_CBP_SUGGESTED_NAMES string uses alphabetic order for the suggested names.
; If these names are translated, the translated names can be rearranged to put them back
; into alphabetic order. For example, the Portuguese (Brazil) translation of this string
; starts "admin|admin-lista|..." (which is "admin|list-admin|..." in English)

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_DEFAULT_BUCKETS  "spam|personal|work|other"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_SUGGESTED_NAMES  "admin|business|computers|family|financial|general|hobby|inbox|junk|list-admin|miscellaneous|not_spam|other|personal|recreation|school|security|shopping|spam|travel|work"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Custom Page - POPFile Classification Bucket Creation [CBP.nsh]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_TITLE            "POPFile 분류 버킷 생성"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_SUBTITLE         "POPFile은 메일 분류를 위해 최소한 2개의 버킷을 필요로 합니다."

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_INTRO         "필요에 따라, 설치 후에도 버킷 갯수와 이름을 쉽게 바꾸실 수 있습니다.${IO_NL}${IO_NL}버킷 이름은 반드시 영어 소문자와 숫자, 하이픈과 언더스코어(_)만으로 이루어진 한 단어여야 합니다."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_CREATE        "버킷을 생성하십시오. 드랍 다운 메뉴에서 제공된 것을 선택하시거나 원하시는 이름을 직접 치십시오."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_DELETE        "목록에 있는 버킷을 삭제하시려면 '제거' 체크박스에 체크표시 하시고 '계속' 버튼을 클릭하십시오."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_LISTHDR       "POPFile이 사용할 버킷"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_REMOVE        "제거"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_CONTINUE      "계속"

; Text strings used for status messages under the bucket list

; TempTranslationNote: PFI_LANG_CBP_IO_MSG_A = PFI_LANG_CBP_IO_MSG_1
; TempTranslationNote: PFI_LANG_CBP_IO_MSG_B = PFI_LANG_CBP_IO_MSG_2
; TempTranslationNote: PFI_LANG_CBP_IO_MSG_C = PFI_LANG_CBP_IO_MSG_3
; TempTranslationNote: PFI_LANG_CBP_IO_MSG_D = PFI_LANG_CBP_IO_MSG_4 + " $G_PLS_FIELD_1 " + PFI_LANG_CBP_IO_MSG_5

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_A         "버킷을 더 추가할 필요는 없습니다."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_B         "최소한 2개의 버킷을 정의해야 합니다."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_C         "버킷이 최소한 1개 더 필요합니다."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_D         "인스톨러는  $G_PLS_FIELD_1 개 이상의 버킷을 생성할 수 없습니다."

; Message box text strings

; TempTranslationNote: PFI_LANG_CBP_MBDUPERR_A = PFI_LANG_CBP_MBDUPERR_1 + " '$G_PLS_FIELD_1' " + PFI_LANG_CBP_MBDUPERR_2
; TempTranslationNote: PFI_LANG_CBP_MBDUPERR_B = PFI_LANG_CBP_MBDUPERR_3

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_A       "'$G_PLS_FIELD_1' 이라는 버킷이 이미 정의되었습니다. "
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_B       "새 버킷에 다른 이름을 주십시오."

; TempTranslationNote: PFI_LANG_CBP_MBMAXERR_A = PFI_LANG_CBP_MBMAXERR_1 + " $G_PLS_FIELD_1 " + PFI_LANG_CBP_MBMAXERR_2
; TempTranslationNote: PFI_LANG_CBP_MBMAXERR_B = PFI_LANG_CBP_MBMAXERR_3 + " $G_PLS_FIELD_1 " + PFI_LANG_CBP_MBMAXERR_2

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_A       "인스톨러는 최대 $G_PLS_FIELD_1 개의 버킷을 생성할 수 있습니다."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_B       "POPFile이 설치된 후에 더 많은 버킷을 생성할 수 있습니다 $G_PLS_FIELD_1 개의 버킷을 생성할 수 있습니다."

; TempTranslationNote: PFI_LANG_CBP_MBNAMERR_A = PFI_LANG_CBP_MBNAMERR_1 + " '$G_PLS_FIELD_1' " + PFI_LANG_CBP_MBNAMERR_2
; TempTranslationNote: PFI_LANG_CBP_MBNAMERR_B = PFI_LANG_CBP_MBNAMERR_3
; TempTranslationNote: PFI_LANG_CBP_MBNAMERR_C = PFI_LANG_CBP_MBNAMERR_4

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_A       "'$G_PLS_FIELD_1' 은(는) 유효한 버킷 이름이 아닙니다."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_B       "버킷 이름은 반드시 영어소문자와 숫자, 그리고 - 와 _ 만으로 이루어진 한 단어여야 합니다."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_C       "이 버킷에 다른 이름을 지정해 주십시오."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_1      "POPFile이 메일 분류를 하기 위해서는 최소한 2개의 버킷이 필요합니다."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_2      "생성할 버킷 이름을 입력하십시오-${MB_NL}${MB_NL}드랍 다운 메뉴에서 제공된 것을 선택하시거나${MB_NL}${MB_NL}원하시는 이름을 직접 치십시오."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_3      "설치가 계속 되려면 최소한 2개의 버킷을 정의하셔야 합니다."

; TempTranslationNote: PFI_LANG_CBP_MBDONE_A = "$G_PLS_FIELD_1 " + PFI_LANG_CBP_MBDONE_1
; TempTranslationNote: PFI_LANG_CBP_MBDONE_B = PFI_LANG_CBP_MBDONE_2
; TempTranslationNote: PFI_LANG_CBP_MBDONE_C = PFI_LANG_CBP_MBDONE_3

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_A         "$G_PLS_FIELD_1 개의 POPFile이 사용할 버킷이 정의되었습니다."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_B         "POPFile이 이 버킷을 사용하도록 설정하시겠습니까?"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_C         "버킷 선택을 변경하려면 '아니오'를 클릭하십시오."

; TempTranslationNote: PFI_LANG_CBP_MBMAKERR_A = PFI_LANG_CBP_MBMAKERR_1 + " $G_PLS_FIELD_1 " + PFI_LANG_CBP_MBMAKERR_2 + " $G_PLS_FIELD_2 " + PFI_LANG_CBP_MBMAKERR_3
; TempTranslationNote: PFI_LANG_CBP_MBMAKERR_B = PFI_LANG_CBP_MBMAKERR_4

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_A       "인스톨러는 다음 버킷을 생성할 수 없었습니다: $G_PLS_FIELD_1 중 $G_PLS_FIELD_2 의 선택하신 버킷"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_B       "POPFile이 설치된 후 '사용자 화면'을 이용하여 버킷을 추가하실 수 있습니다.${MB_NL}${MB_NL}"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Custom Page - Email Client Reconfiguration [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_TITLE        "Email Client Configuration"
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_SUBTITLE     "POPFile can reconfigure several email clients for you"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_TEXT_1    "Mail clients marked (*) can be reconfigured automatically, assuming simple accounts are used.${IO_NL}${IO_NL}It is strongly recommended that accounts which require authentication are configured manually."
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_TEXT_2    "IMPORTANT: PLEASE SHUT DOWN THE RECONFIGURABLE EMAIL CLIENTS NOW${IO_NL}${IO_NL}This feature is still under development (e.g. some Outlook accounts may not be detected).${IO_NL}${IO_NL}Please check that the reconfiguration was successful (before using the email client)."

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_CANCEL    "Email client reconfiguration cancelled by user"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Text used on buttons to skip configuration of email clients [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_SKIPALL   "Skip All"
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_SKIPONE   "Skip Client"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Message box warnings that an email client is still running [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_EXP         "WARNING: Outlook Express appears to be running !"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_OUT         "WARNING: Outlook appears to be running !"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_EUD         "WARNING: Eudora appears to be running !"

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_1      "Please SHUT DOWN the email program then click 'Retry' to reconfigure it"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_2      "(You can click 'Ignore' to reconfigure it, but this is not recommended)"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_3      "Click 'Abort' to skip the reconfiguration of this email program"

; Following three strings are used when uninstalling

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_4      "Please SHUT DOWN the email program then click 'Retry' to restore the settings"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_5      "(You can click 'Ignore' to restore the settings, but this is not recommended)"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_6      "Click 'Abort' to skip the restoring of the original settings"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Custom Page - Reconfigure Outlook/Outlook Express [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_FOOTNOTE   "Tick box(es) to reconfigure account(s).${IO_NL}If you uninstall POPFile the original settings will be restored."

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

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Custom Page - Reconfigure Eudora [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_TITLE          "아웃룩 익스프레스 설정을 변경하십시오."
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_SUBTITLE       "POPFile은 아웃룩 익스프레스 설정을 변경해드릴 수 있습니다."

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_CANCELLED   "Eudora reconfiguration cancelled by user"

!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_INTRO_1     "POPFile has detected the following Eudora personality"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_INTRO_2     " and can automatically configure it to work with POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_CHECKBOX    "Reconfigure this personality to work with POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_DOMINANT    "<Dominant> personality"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_PERSONA     "personality"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_EMAIL       "전자 메일 주소:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_SERVER      "받는 메일(POP3) 서버:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_USERNAME    "계정 이름:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_POP3PORT    "POP3 port:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_RESTORE     "POPFile을 언인스톨 하시면 원래 설정이 복원될 것입니다."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Custom Page - POPFile can now be started [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_TITLE         "이제 POPFile을 시작하실 수 있습니다."
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_SUBTITLE      "POPFile 사용자 화면은 POPFile이 시작된 후에 사용가능합니다."

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_INTRO      "POPFile을 지금 시작할까요?"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NO         "아니오 ('사용자 화면'은 POPFile이 시작되지 않으면 사용할 수 없습니다.)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_DOSBOX     "POPFile 시작 (창에서)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_BCKGRND    "POPFile을 백그라운드에서 시작 (창이 나타나지 않습니다)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOICON     "Run POPFile (do not show system tray icon)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_TRAYICON   "Run POPFile with system tray icon"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_1     "POPFile 시작되고 나면 '사용자 화면'을 표시할 수 있습니다."
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_2     " (a) 시스템 트레이의 POPFile 아이콘을 클릭하시거나,"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_3     " (b) 시작 --> 프로그램(P) --> POPFile --> POPFile User Interface 를 선택하십시오."

; Banner message displayed whilst waiting for POPFile to start

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_BANNER_1      "POPFile을 시동 준비 중."
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_BANNER_2      "몇초 정도 걸릴 수 있습니다..."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Standard MUI Page - FINISH [adduser.nsi]
;
; The PFI_LANG_FINISH_RUN_TEXT text should be a short phrase (not a long paragraph)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; $G_WINUSERNAME holds the Windows login name of the user running the wizard

!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_FINISH_INFO "POPFile has been configured for the '$G_WINUSERNAME' user.${IO_NL}${IO_NL}Click Finish to close this wizard."

!insertmacro PFI_LANG_STRING PFI_LANG_FINISH_RUN_TEXT      "팝파일 사용자 화면"
!insertmacro PFI_LANG_STRING PFI_LANG_FINISH_WEB_LINK_TEXT "Click here to visit the POPFile web site"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Standard MUI Page - Uninstall Confirmation Page (for the 'Add POPFile User' wizard) [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; $G_WINUSERNAME holds the Windows login name for the user running the uninstall wizard

!insertmacro PFI_LANG_STRING PFI_LANG_REMUSER_TITLE        "Uninstall POPFile data for '$G_WINUSERNAME' user"
!insertmacro PFI_LANG_STRING PFI_LANG_REMUSER_SUBTITLE     "Remove POPFile configuration data for this user from your computer"

!insertmacro PFI_LANG_STRING PFI_LANG_REMUSER_TEXT_TOP     "The POPFile configuration data for the '$G_WINUSERNAME' user will be uninstalled from the following folder. $_CLICK"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Standard MUI Page - Uninstallation Page (for the 'Add POPFile User' wizard) [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; $G_WINUSERNAME holds the Windows login name for the user running the uninstall wizard

!insertmacro PFI_LANG_STRING PFI_LANG_REMOVING_TITLE       "Uninstalling POPFile data for '$G_WINUSERNAME' user"
!insertmacro PFI_LANG_STRING PFI_LANG_REMOVING_SUBTITLE    "Please wait while the POPFile configuration files for this user are deleted"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Standard MUI Page - UNPAGE_INSTFILES [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Uninstall Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_OUTEXPRESS   "아웃룩 익스프레스 설정을 복원 중..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_OUTLOOK      "Restoring Outlook settings..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_EUDORA       "Restoring Eudora settings..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_DBMSGDIR     "Deleting corpus and 'Recent Messages' directory..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_CONFIG       "Deleting configuration data..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_EXESTATUS    "Checking program status..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_REGISTRY     "Deleting POPFile registry entries..."

; Uninstall Log Messages

!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_OPENED        "열림"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_RESTORED      "복원됨"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_CLOSED        "닫힘"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_DATAPROBS     "Data problems"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_DELUSERDIR    "Removing all files from POPFile 'User Data' directory"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_DELUSERERR    "Note: unable to remove all files from POPFile 'User Data' directory"

; Message Box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_1        "'Outlook Express' problem !"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_2        "'Outlook' problem !"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_3        "'Eudora' problem !"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBEMAIL_1         "Unable to restore some original settings"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBEMAIL_2         "Display the error report ?"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_1         "Some email client settings have not been restored !"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_2         "(Details can be found in $INSTDIR folder)"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_3         "Click 'No' to ignore these errors and delete everything"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_4         "Click 'Yes' to keep this data (to allow another attempt later)"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMDIR_2        "Do you want to remove all files in your POPFile 'User Data' directory?${MB_NL}${MB_NL}$G_USERDIR${MB_NL}${MB_NL}(If you have anything you created that you want to keep, click No)"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBDELMSGS_1       "Do you want to remove all files in your 'Recent Messages' directory?"

###########################################################################
###########################################################################

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Corpus Conversion: Standard MUI Page - INSTFILES [MonitorCC.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_TITLE        "POPFile Corpus Conversion"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_SUBTITLE     "The existing corpus must be converted to work with this version of POPFile"

!insertmacro PFI_LANG_STRING PFI_LANG_ENDCONVERT_TITLE     "POPFile Corpus Conversion Completed"
!insertmacro PFI_LANG_STRING PFI_LANG_ENDCONVERT_SUBTITLE  "Please click Close to continue"

!insertmacro PFI_LANG_STRING PFI_LANG_BADCONVERT_TITLE     "POPFile Corpus Conversion Failed"
!insertmacro PFI_LANG_STRING PFI_LANG_BADCONVERT_SUBTITLE  "Please click Cancel to continue"

!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_MUTEX        "Another copy of the 'Corpus Conversion Monitor' is already running !"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_PRIVATE      "The 'Corpus Conversion Monitor' is part of the POPFile installer"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_NOFILE       "Error: Corpus conversion data file does not exist !"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_NOPOPFILE    "Error: POPFile path missing"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_STARTERR     "An error occurred when starting the corpus conversion process"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_FATALERR     "A fatal error occurred during the corpus conversion process !"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_ESTIMATE     "Estimated time remaining: "
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_MINUTES      "minutes"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_WAITING      "(waiting for first file to be converted)"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_TOTALFILES   "There are $G_BUCKET_COUNT bucket files to be converted"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_PROGRESS_N   "After $G_ELAPSED_TIME.$G_DECPLACES minutes there are $G_STILL_TO_DO files left to convert"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_PROGRESS_1   "After $G_ELAPSED_TIME.$G_DECPLACES minutes there is one file left to convert"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_SUMMARY      "Corpus Conversion took $G_ELAPSED_TIME.$G_DECPLACES minutes"

###########################################################################
###########################################################################

#--------------------------------------------------------------------------
# Mark the end of the language data
#--------------------------------------------------------------------------

!undef PFI_LANG

#--------------------------------------------------------------------------
# End of 'Korean-pfi.nsh'
#--------------------------------------------------------------------------
