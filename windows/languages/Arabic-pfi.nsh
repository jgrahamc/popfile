#--------------------------------------------------------------------------
# Arabic-pfi.nsh
#
# This file contains the "Arabic" text strings used by the Windows installer
# for POPFile (includes customised versions of strings provided by NSIS and
# strings which are unique to POPFile).
#
# These strings are grouped according to the page/window where they are used
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
#
# Translation created by: Rami Kattan (rkattan at users.sourceforge.net)
# Translation updated by: Rami Kattan
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

!define PFI_LANG  "ARABIC"

#==========================================================================
# Customised versions of strings used on standard MUI pages
#==========================================================================

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Used by the main POPFile installer (main script: installer.nsi)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#--------------------------------------------------------------------------
# Standard MUI Page - Welcome (for the main POPFile installer)
#
# The sequence \r\n\r\n inserts a blank line (note that the PFI_LANG_WELCOME_INFO_TEXT string
# should end with a \r\n\r\n$_CLICK sequence).
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_WELCOME_INFO_TEXT    "������� ��� ������ ���� ����� ����� POPFile.\r\n\r\n�� ������ ����� ������� ������ ��� ��������.\r\n\r\n$_CLICK"
!insertmacro PFI_LANG_STRING PFI_LANG_WELCOME_ADMIN_TEXT   "������ ����:\r\n\r\n�������� ������ �� ���� ������ 'Administrator'.\r\n\r\n��� ��� ����� ���� �������� ����ȡ �� ������ ����� ��� ������� �������� ���� 'Administrator' ������ POPFile."

#--------------------------------------------------------------------------
# Standard MUI Page - Directory Page (for the main POPFile installer)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_ROOTDIR_TITLE        "������ ���� ����� ����� ��������"
!insertmacro PFI_LANG_STRING PFI_LANG_ROOTDIR_TEXT_DESTN   "���� ����� ������ POPFile"

#--------------------------------------------------------------------------
# Standard MUI Page - Installation Page (for the main POPFile installer)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_INSTFINISH_TITLE     "Program Files Installed"
!insertmacro PFI_LANG_STRING PFI_LANG_INSTFINISH_SUBTITLE  "${C_PFI_PRODUCT} must be configured before it can be used"

#--------------------------------------------------------------------------
# Standard MUI Page - Finish (for the main POPFile installer)
#
# The PFI_LANG_FINISH_RUN_TEXT text should be a short phrase (not a long paragraph)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_FINISH_RUN_TEXT      "����� ������� POPFile"


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Used by 'Monitor Corpus Conversion' utility (main script: MonitorCC.nsi)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#--------------------------------------------------------------------------
# Standard MUI Page - Installation Page (for the 'Monitor Corpus Conversion' utility)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_TITLE        "����� ������ POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_SUBTITLE     "��� ����� �������� ������� ����� �� ��� ������ �� POPFile"

!insertmacro PFI_LANG_STRING PFI_LANG_ENDCONVERT_TITLE     "������ ����� ������ POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_ENDCONVERT_SUBTITLE  "������ ����� ��� ����� ��������"

!insertmacro PFI_LANG_STRING PFI_LANG_BADCONVERT_TITLE     "��� ����� ����� ������ POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_BADCONVERT_SUBTITLE  "������ ����� ��� ����� ��������"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Used by 'Add POPFile User' wizard (main script: adduser.nsi)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#--------------------------------------------------------------------------
# Standard MUI Page - Welcome (for the 'Add POPFile User' wizard)
#
# The sequence \r\n\r\n inserts a blank line (note that the PFI_LANG_ADDUSER_INFO_TEXT string
# should end with a \r\n\r\n$_CLICK sequence).
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_INFO_TEXT    "������ ��� ������ ���� ����� ����� POPFile �������� '$G_WINUSERNAME'.\r\n\r\n�� ������ ����� ������� ������ ��� ��������.\r\n\r\n$_CLICK"

#--------------------------------------------------------------------------
# Standard MUI Page - Directory Page (for the 'Add POPFile User' wizard)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_TITLE        "������ ���� ������� POPFile �������� '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_SUBTITLE     "���� ���� ��� ������� POPFile �������� '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_TEXT_TOP     "��� �������� �� POPFile ������ ������� ������ �� ����� ��������� ��� ������.$\r$\n$\r$\n����� ������ ������� �������� ������ ������ ���� ������� POPFile ������ ��������� '$G_WINUSERNAME'. �������� ���� ��� ���� �������� ���� ��� ��� ����� ���� ���. $_CLICK"
!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_TEXT_DESTN   "������ �������� ���� ������� POPFile ������ ��������� '$G_WINUSERNAME'"

#--------------------------------------------------------------------------
# Standard MUI Page - Installation Page (for the 'Add POPFile User' wizard)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_TITLE        "������� POPFile �������� '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_SUBTITLE     "������ �������� ����� ����� ����� ����� POPFile ���� ��������"

#--------------------------------------------------------------------------
# Standard MUI Page - Finish (for the 'Add POPFile User' wizard)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_FINISH_INFO "�� ����� POPFile �������� '$G_WINUSERNAME'.\r\n\r\n���� ����� ������ ��� ������."

#--------------------------------------------------------------------------
# Standard MUI Page - Uninstall Confirmation Page (for the 'Add POPFile User' wizard)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_REMUSER_TITLE        "����� ������� POPFile �������� '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_REMUSER_SUBTITLE     "����� ����� ������� ����� POPFile ���� �������� ��� ������"

!insertmacro PFI_LANG_STRING PFI_LANG_REMUSER_TEXT_TOP     "���� ����� ������� ����� POPFile �������� '$G_WINUSERNAME' �� ������ ������r. $_CLICK"

#--------------------------------------------------------------------------
# Standard MUI Page - Uninstallation Page (for the 'Add POPFile User' wizard)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_REMOVING_TITLE       "����� ������� POPFile �������� '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_REMOVING_SUBTITLE    "������ �������� ����� ��� ����� ����� POPFile ���� ��������"


#==========================================================================
# Strings used for custom pages, message boxes and banners
#==========================================================================

#--------------------------------------------------------------------------
# General purpose banner text (also suitable for page titles/subtitles)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_BE_PATIENT           "������ ��������."
!insertmacro PFI_LANG_STRING PFI_LANG_TAKE_A_FEW_SECONDS   "������ ����� ���� �����..."

#--------------------------------------------------------------------------
# Message displayed when 'Add User' does not seem to be part of the current version
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_COMPAT_NOTFOUND      "Error: Compatible version of ${C_PFI_PRODUCT} not found !"

#--------------------------------------------------------------------------
# Message displayed when installer exits because another copy is running
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_INSTALLER_MUTEX      "���� ���� �� ����� POPFile ��� ������� !"

#--------------------------------------------------------------------------
# Message box warning that a previous installation has been found
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_1   "���� ���� ���� ��"
!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_2   "�� ���� ������ǿ"
!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_3   "���� ������� ����� ����� ��"

#--------------------------------------------------------------------------
# Startup message box offering to display the Release Notes
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_1         "��� ������� ������ POPFile �"
!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_2         "�� ������ �������� ��� ��� ���� ����� POPFile (�� ������ �� ����� ���� ���� �������� ��� �������)"

#--------------------------------------------------------------------------
# Custom Page - Check Perl Requirements
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_TITLE        "���� ������ ���� �����"

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_1    "������� ������� ��������� ���� ����� ������� POPFile (���� ������).\r\n\r\n"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_2    "�� ����� POPFile ����� ���ϡ ����� �� �� �����.\r\n\r\n"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_3    "���� ����� ���� ����� �� Perl (�� ����� POPFile ������ Perl).\r\n\r\n"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_4    "����� Perl ������ �� POPFile ��� ������ Internet Explorer ����� ����� ���� Internet Explorer 5.5 (�� �� �����)."
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_5    "��� ����� ������� ���� Internet Explorer �� ��� ������"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_6    "�� ������ �� ��� ����� POPFile �� ���� ���� ���� ��� ��� ������.\r\n\r\n"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_7    "��� ����� ����� �� POPFile� ��� ������� ��� ���� ����� �� Internet Explorer ���� �� �����."

#--------------------------------------------------------------------------
# Standard MUI Page - Choose Components
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING DESC_SecPOPFile               "����� ������� �������� �������� �� ���� POPFile� �������� ��� ���� ����� �� Perl."
!insertmacro PFI_LANG_STRING DESC_SecSkins                 "����� ���� POPFile ���� ���� ������ ��� ����� ��������."
!insertmacro PFI_LANG_STRING DESC_SecLangs                 "����� ���� ���� ��� ���������� �� ����� ������� POPFile."
!insertmacro PFI_LANG_STRING DESC_SecXMLRPC                "����� ����� XMLRPC (������ ��� ����� ����� �������� (API) ��� POPFile) ������ ������� ��� Perl."

#--------------------------------------------------------------------------
# Custom Page - POPFile Installation Options
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_TITLE        "������ ����� POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_SUBTITLE     "���� ��� �������� ��� �� ��� ��� ����� ����"

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_POP3      "���� ��� ���� ������� POP3 (����� 110)"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_GUI       "���� ��� ���� ������� '����� ��������' (����� 8080)"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_STARTUP   "����� POPFile ���� ������ ��� ����� ������"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_WARNING   "����� ���"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_MESSAGE   "��� ��� ���� POPFILE --- ����� ������� ������ ������ �������"

; Message Boxes used when validating user's selections

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_1     "�� ���� ����� ���� POP3 ���"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_2     "��� ������ ��� �� ���� ����� �� ������ 1 ��� 65535."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_3     "������ ����� �������� ���� POP3."

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_1      "�� ���� ����� ���� '����� ��������' ���"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_2      "��� ������ ��� �� ���� ����� �� ������ 1 ��� 65535."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_3      "������ ����� �������� ���� '����� ��������'."

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_1     "��� �� ���� ���� POP3 ������� �� ���� '����� ��������'."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_2     "������ ����� �������� ������."

#--------------------------------------------------------------------------
# Standard MUI Page - Installing POPfile
#--------------------------------------------------------------------------

; Installation Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_UPGRADE    "����� ��� ��� ��� ����� �����..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_CORE       "����� ����� POPFile ��������..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_PERL       "����� ����� ���� Perl ��������..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SHORT      "����� �������� POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_CORPUS     "��� ���� �������� �� ��������. ������ ��� ���� �����..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SKINS      "����� ����� ������ ��������..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_LANGS      "����� ����� ������ ������..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_XMLRPC     "����� ����� XMLRPC..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_ENDSEC     "���� ������ ��������"

; Installation Log Messages

!insertmacro PFI_LANG_STRING PFI_LANG_INST_LOG_SHUTDOWN    "����� ������ ������� �� POPFile �� ���� ������"

; Message Box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_1           "��� ��� �� ���� �����."
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_2           "�� ����� ��� ����� ��� ����� �"
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_3           "���� '���' ������ ����� (���� ��� ����� ������ ����"
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_4           "���� '��' ���� ����� ������ (���� ��� ����� ������ ����"

!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_1          "�� ���� ��������� ������ POPFile ���� ������."
!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_2          "������ ����� POPFile ���� ���� ����."
!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_3          "����� ��� ����� POPFile� ���� '�����' ��������."

!insertmacro PFI_LANG_STRING PFI_LANG_MBCORPUS_1           "�� ����� �� ��� ����� ���� ������� ���� ���� �������� �� �������� �������."

#--------------------------------------------------------------------------
# Custom Page - POPFile Classification Bucket Creation
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_TITLE            "����� ���� ����� POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_SUBTITLE         "����� POPFile ��� ����� ��� ����� ������ �� ����� ������"

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_INTRO         "��� ������ȡ �� ����� ����� ��� ������ (��������) ������ ���������.\r\n\r\n������ ������ ��� �� ���� ����� ����ɡ ������� ������ ���� ���� �� a ��� z� ����� 0 ��� 9� - � _."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_CREATE        "\r\n����� ��� ���� ��� ������� ��� �� ������� �� ������ �� ����� ��� �� �������."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_DELETE        "\r\n���� ��� ���� �� ���� �� ������ɡ ���� ������ '���' ������� ����� '������'."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_LISTHDR       "���� ������� ��� ���� POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_REMOVE        "���"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_CONTINUE      "������"

; Text strings used for status messages under the bucket list

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_1         "\r\n�� ���� ������ ������ ���� ����"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_2         "\r\n��� ����� ��� ����� ����� �����"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_3         "\r\n���� ��� ����� ��� ���"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_4         "\r\n�� ������ ������� ���� ��"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_5         "����"

; Message box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_1       "��� ����"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_2       "�� ������ ������."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_3       "������ ������ ��� ��� ����� ������."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_1       "������ ������� ����� ��� ������"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_2       "����."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_3       "��� ����� POPFile ������ ����� ���� ��"

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_1       "�����"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_2       "��� ���� ���� ���."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_3       "����� ������ ������ �� ����� ��� ���� �� a ��� z ������ �����ѡ ����� 0 ��� 9� �������� ��� - � _"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_4       "������ ������ ��� ��� ����� ������."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_1      "����� POPFile ��� ����� ����� ��� ����� ��� �� ����� �� ����� ������."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_2      "������ ����� ��� ���� ��������$\r$\n$\r$\n��� ������� ��� ����� �� �������$\r$\n$\r$\n�� ������ ��� �� �������."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_3      "��� ����� ����� ��� ����� ��� �������� �� ����� POPFile."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_1         "�� ��� ������ ������� ������� ������ POPFile."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_2         "�� ���� ����� POPFile ������� ��� �������"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_3         "���� '��' ��� ��� ���� ����� �������� ������."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_1       "�� ����� ������� �����"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_2       "��"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_3       "������ ���� �������."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_4       "��� ����� POPFile ������ ������� '����� ��������'$\r$\n$\r$\n ����� ������ ������ ������ �������."

#--------------------------------------------------------------------------
# Custom Page - Email Client Reconfiguration
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_TITLE        "������� ����� ������"
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_SUBTITLE     "������ POPFile ����� ��� �� ����� ������ ����� ���"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_TEXT_1    "����� ������ �������� ������ (*) ���� ������� ���� ������� �������� ��� �������� ��������� �����.\r\n\r\n�� ������ �� ��� ����� �������� ���� ������ �������� ������ ���� ����."
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_TEXT_2    "���: ������ ����� ����� ������ ������ ������� ���� ������ ����\r\n\r\n��� ������ �� ���� ��� ������� (����: ��� ������ Outlook �� ��� �������� �������).\r\n\r\n������ ��� �� ��������� ���� ���� ���� (��� ������� ������ ������)."

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_CANCEL    "�� ����� ����� ����� ������ ������ �� ��� ��������"

#--------------------------------------------------------------------------
# Text used on buttons to skip configuration of email clients
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_SKIPALL   "���� ����"
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_SKIPONE   "���� ��������"

#--------------------------------------------------------------------------
# Message box warnings that an email client is still running
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_EXP         "�����: ���� �� Outlook Express �� ��� ���� !"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_OUT         "�����: ���� �� Outlook �� ��� ���� !"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_EUD         "�����: ���� �� Eudora �� ��� ���� !"

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_1      "������ ����� ������ ������ ��� �� ����� ��� '��� ��������' �������"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_2      "(���� ����� ��� '����' ������� ���� ��� ��� �����)"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_3      "���� ��� '�����' ����� ����� ��� ��������"

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_4      "������ ����� ������ ������ ������ ��� '��� ��������' ������ ��������� �������"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_5      "(���� ����� ��� '����' ������ ��������� ������ɡ ���� ��� ��� �����)"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_6      "���� ��� '�����' ����� ����� ��������� �������"

#--------------------------------------------------------------------------
# Custom Page - Reconfigure Outlook/Outlook Express
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_TITLE         "����� Outlook Express"
!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_SUBTITLE      "������ POPFile ����� Outlook Express �������� ���"

!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_TITLE         "����� Outlook"
!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_SUBTITLE      "������ POPFile ����� Outlook �������� ���"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_IO_CANCELLED  "����� ����� Outlook Express �� ���� ��������"
!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_IO_CANCELLED  "����� ����� Outlook �� ���� ��������"

!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_BOXHDR     "������"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_ACCOUNTHDR "����"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_EMAILHDR   "����� ���� ��������"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_SERVERHDR  "����"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_USRNAMEHDR "��� ������"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_FOOTNOTE   "���� ������(���) ������ ������(���).\r\n��� ����� POPFile ��� ����� ��������� �������."

; Message Box to confirm changes to Outlook/Outlook Express account configuration

!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_MBIDENTITY    "���� Outlook Express :"
!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_MBACCOUNT     "���� Outlook Express :"

!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_MBIDENTITY    "������ Outlook :"
!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_MBACCOUNT     "���� Outlook :"

!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBEMAIL       "����� ������ ���������� :"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBSERVER      "���� POP3 :"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBUSERNAME    "��� ������POP3 :"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBOEPORT      "���� POP3 :"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBOLDVALUE    "������"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBQUESTION    "�� ����� ��� ������ ����� �� POPFile �"

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
# Custom Page - Reconfigure Eudora
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_TITLE          "����� Eudora"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_SUBTITLE       "������ POPFile ����� Eudora �������� ���"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_CANCELLED   "����� ����� Eudora �� ���� ��������"

!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_INTRO_1     "POPFile ��� ������ �� ����� Eudora �������"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_INTRO_2     " ������� ������� ���� ������ ����� �� POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_CHECKBOX    "����� ��� ������� ����� �� POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_DOMINANT    "<Dominant> �����"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_PERSONA     "�����"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_EMAIL       "����� ������ ����������:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_SERVER      "���� POP3:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_USERNAME    "��� ������ POP3:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_POP3PORT    "���� POP3:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_RESTORE     "��� ��� ������ POPFile ���� ����� ��������� �������"

#--------------------------------------------------------------------------
# Custom Page - POPFile can now be started
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_TITLE         "���� ����� POPFile ����"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_SUBTITLE      "���� ����� �������� ��� ��� �� ����� POPFile"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_INTRO      "����� POPFile ����"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NO         "�� (�� ���� '����� ��������' ��� ��� POPFile ����)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_DOSBOX     "���� POPFile (�� �����)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_BCKGRND    "���� POPFile �� ������� (���� ����� �����)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOICON     "Run POPFile (do not show system tray icon)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_TRAYICON   "Run POPFile with system tray icon (default setting)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_1     "��� ����� POPFile� ���� ��� '����� ��������' �� ����"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_2     "(�) ��� ����� ��� ������ POPFile �� ���� ������  ��"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_3     "(�) ������� ���� --> ����� --> POPFile --> POPFile User Interface."

; Banner message displayed whilst waiting for POPFile to start

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_BANNER_1      "������� ������ POPFile."
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_BANNER_2      "������ ����� ���� �����..."

#--------------------------------------------------------------------------
# Standard MUI Page - Installation Page (for the 'Corpus Conversion Monitor' utility)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_MUTEX        "���� ���� �� 'Corpus Conversion Monitor' ���� ������ !"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_PRIVATE      "'Corpus Conversion Monitor' ����� �� ��� �� ����� POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_NOFILE       "���: ����� ����� ������� �������� ��� ������ !"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_NOPOPFILE    "���: �� ��� ������ ��� ���� POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_ENVNOTSET    "���: �� ��� �������� ����� ����� ���� ���"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_NOKAKASI     "���: �� ��� ������ ��� ���� Kakasi"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_STARTERR     "��� ��� ��� ����� ����� ����� ����� ��������"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_FATALERR     "A fatal error occurred during the corpus conversion process !"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_ESTIMATE     "����� �������: "
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_MINUTES      "�����"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_WAITING      "(������ ����� ����� �����)"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_TOTALFILES   "���� $G_BUCKET_COUNT ���� ���� �������"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_PROGRESS_N   "��� $G_ELAPSED_TIME.$G_DECPLACES ����� ����� ���� $G_STILL_TO_DO ����� �������"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_PROGRESS_1   "��� $G_ELAPSED_TIME.$G_DECPLACES ����� ���� ���� ��� ���� ���� ������"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_SUMMARY      "������� ����� ����� �������� ��� $G_ELAPSED_TIME.$G_DECPLACES �����"

#--------------------------------------------------------------------------
# Standard MUI Page - Uninstall POPFile
#--------------------------------------------------------------------------

; Uninstall Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_SHUTDOWN     "����� POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_SHORT        "��� ������ '����� ����' ������ ���POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_CORE         "��� ����� POPFile ��������..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_OUTEXPRESS   "����� ������� Outlook Express..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_SKINS        "��� ����� ������..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_PERL         "��� ����� ���� Perl �������..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_OUTLOOK      "����� ����� Outlook..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_EUDORA       "����� ����� Eudora..."

; Uninstall Log Messages

!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_SHUTDOWN      "Shutting down POPFile using port"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_OPENED        "Opened"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_RESTORED      "Restored"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_CLOSED        "Closed"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_DELROOTDIR    "Removing all files from POPFile directory"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_DELROOTERR    "Note: unable to remove all files from POPFile directory"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_DATAPROBS     "Data problems"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_DELUSERDIR    "Removing all files from POPFile 'User Data' directory"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_DELUSERERR    "Note: unable to remove all files from POPFile 'User Data' directory"

; Message Box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBDIFFUSER_1      "����� '$G_WINUSERNAME' ��� ������� ����� ������� ���"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBNOTFOUND_1      "�� ���� �� POPFile ����� �� �� ������"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBNOTFOUND_2      "�������� ��� ������� (��� �����)�"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_ABORT_1           "����� ����� ������� �� ���� ��������"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_1        "����� 'Outlook Express' !"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_2        "����� 'Outlook' !"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_3        "����� 'Eudora' !"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBEMAIL_1         "�� ��� ���� ��������� ������ ��� ��������� �������"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBEMAIL_2         "��� ����� ������� �"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_1         "��� ������� ������ ������ �� ��� ������� ��� ������ ������� !"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_2         "(���� ����� �������� �� ������ $INSTDIR)"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_3         "���� '��' ������ ��� ������� ���� �� ���"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_4         "���� '���' �������� ��� ��� ��������� (������ ������� ���� ������)"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMDIR_1        "�� ���� ��� �� ������� �� ���� POPFile�$\r$\n$\r$\n(��� ��� ���� ����� ������ǡ ���� ��)"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMDIR_2        "�� ���� ��� �� ������� �� ���� '������� ��������' ����� ���POPFile�$\r$\n$\r$\n(��� ��� ���� ����� ������ǡ ���� ��)"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMERR_1        "������"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMERR_2        "�� ��� �������� ����."

#--------------------------------------------------------------------------
# Mark the end of the language data
#--------------------------------------------------------------------------

!undef PFI_LANG

#--------------------------------------------------------------------------
# End of 'Arabic-pfi.nsh'
#--------------------------------------------------------------------------
