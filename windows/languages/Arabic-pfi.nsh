#--------------------------------------------------------------------------
# Arabic-pfi.nsh
#
# This file contains the "Arabic" text strings used by the Windows installer
# and other NSIS-based Windows utilities for POPFile (includes customised versions
# of strings provided by NSIS and strings which are unique to POPFile).
#
# These strings are grouped according to the page/window and script where they are used
#
# Copyright (c) 2004-2005 John Graham-Cumming
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

!define PFI_LANG  "ARABIC"

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

!insertmacro PFI_LANG_STRING PFI_LANG_BE_PATIENT           "«·—Ã«¡ «·≈‰ Ÿ«—."
!insertmacro PFI_LANG_STRING PFI_LANG_TAKE_A_FEW_SECONDS   "”ÌÕ «Ã «·√„— ·»÷⁄ ·ÕŸ« ..."

###########################################################################
###########################################################################

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Message displayed when wizard does not seem to belong to the current installation [adduser.nsi, runpopfile.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_COMPAT_NOTFOUND      "Error: Compatible version of ${C_PFI_PRODUCT} not found !"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Message box shown (before the WELCOME page) if another installer is running [installer.nsi, adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_INSTALLER_MUTEX      "‰”Œ… √Œ—Ï „‰ „‰’¯» POPFile ﬁÌœ «· ‰›Ì– !"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Message box shown if 'SetEnvironmentVariableA' fails [installer.nsi, adduser.nsi, MonitorCC.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_ENVNOTSET    "Œ··: ·„ Ìﬂ‰ »«·≈„ﬂ«‰ ≈⁄œ«œ „ €Ì— »Ì∆… ⁄«„"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Used in message box shown if existing files found when installing [installer.nsi, adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_2   "Â·  —Ìœ  —ﬁÌ Â«ø"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Standard MUI Page - INSTFILES
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; When upgrading an existing installation, change the normal "Install" button to "Upgrade" [installer.nsi, adduser.nsi]

!insertmacro PFI_LANG_STRING PFI_LANG_INST_BTN_UPGRADE     "Upgrade"

; Installation Progress Reports displayed above the progress bar [installer.nsi, adduser.nsi]

!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_UPGRADE    " ›Õ¯’ ≈–« ﬂ«‰ Â–«  ‰’Ì»  —ﬁÌ…..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SHORT      "≈‰‘«¡ ≈Œ ’«—«  POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_LANGS      " ‰’Ì» „·›«  «··€«  ≈÷«›Ì…..."

; Installation Progress Reports displayed above the progress bar [installer.nsi, adduser.nsh, getssl.nsh]

!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_ENDSEC     "≈÷€ÿ «· «·Ì ··„ «»⁄…"

; Installation Log Messages [installer.nis, adduser.nsi]

!insertmacro PFI_LANG_STRING PFI_LANG_INST_LOG_SHUTDOWN    "≈€·«ﬁ «·‰”Œ… «·”«»ﬁ… „‰ POPFile ⁄‰ ÿ—Ìﬁ «·„‰›–"

; Message Box text strings [installer.nsi, adduser.nsi, pfi-library.nsh]

!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_1          "·«  ÊÃœ «·≈„ﬂ«‰Ì… ·≈€·«ﬁ $G_PLS_FIELD_1 »‘ﬂ·  ·ﬁ«∆Ì."
!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_2          "«·—Ã«¡ ≈€·«ﬁ $G_PLS_FIELD_1 »‘ﬂ· ÌœÊÌ «·¬‰."
!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_3          "⁄‰œ„« Ì „ ≈€·«ﬁ $G_PLS_FIELD_1° ≈÷€ÿ '„Ê«›ﬁ' ··„ «»⁄…."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Message boxes shown if uninstallation is not straightforward [installer.nsi, adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBDIFFUSER_1      "ÌÕ«Ê· '$G_WINUSERNAME' Õ–› „⁄·Ê„«   «»⁄… ·„” Œœ„ ¬Œ—"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBNOTFOUND_1      "·« ÌŸÂ— «‰ POPFile „‰’¯» ›Ì ›Ì «·„Ã·œ"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBNOTFOUND_2      "«·„ «»⁄… »ﬂ· «·√ÕÊ«· (€Ì— „›÷¯·)ø"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Message box shown if uninstaller is cancelled by the user [installer.nsi, adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_UN_ABORT_1           "≈·€«¡ ⁄„·Ì… «·≈“«·… „‰ ﬁˆ»· «·„” Œœ„"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Standard MUI Page - UNPAGE_INSTFILES [installer.nsi, adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Uninstall Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_SHUTDOWN     "≈€·«ﬁ POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_SHORT        "Õ–› „œŒ·«  'ﬁ«∆„… «»œ√' «·Œ«’… »‹ˆPOPFile..."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Shared: Message box shown if uninstaller failed to remove files/folders [installer.nsi, adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; TempTranslationNote: PFI_LANG_UN_MBREMERR_A = PFI_LANG_UN_MBREMERR_1 + ": $G_PLS_FIELD_1 " + PFI_LANG_UN_MBREMERR_2

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMERR_A        "„·«ÕŸ…: $G_PLS_FIELD_1 ·„ Ìﬂ‰ »«·≈„ﬂ«‰ Õ–›Â."

###########################################################################
###########################################################################

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; POPFile Installer: Message box shown (before the WELCOME page) offering to display the release notes [installer.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_1         "⁄—÷ „·«ÕŸ«  ≈’œ«—… POPFile ø"
!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_2         "„‰ «·√›÷· «·„Ê«›ﬁ… ≈–« ﬂ‰   —Ìœ  —ﬁÌ… POPFile („‰ «·„„ﬂ‰ √‰  Õ «Ã ·⁄„· ‰”Œ… ≈Õ Ì«ÿÌ… ﬁ»· «· —ﬁÌ…)"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; POPFile Installer: Standard MUI Page - WELCOME [installer.nsi]
;
; The PFI_LANG_WELCOME_INFO_TEXT string should end with a '${IO_NL}${IO_NL}$_CLICK' sequence).
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_WELCOME_INFO_TEXT    "”Ì”«⁄œﬂ Â–« «·„—‘œ Œ·«· ⁄„·Ì…  ‰’Ì» POPFile.${IO_NL}${IO_NL}„‰ «·√›÷· ≈€·«ﬁ «·»—«„Ã «·√Œ—Ï ﬁ»· «·„ «»⁄….${IO_NL}${IO_NL}$_CLICK"
!insertmacro PFI_LANG_STRING PFI_LANG_WELCOME_ADMIN_TEXT   "„·«ÕŸ… „Â„…:${IO_NL}${IO_NL}«·„” Œœ„ «·Õ«·Ì ·« Ì„·ﬂ ’·«ÕÌ… 'Administrator'.${IO_NL}${IO_NL}≈–« ﬂ«‰ «·œ⁄„ ·⁄œ… „” Œœ„Ì‰ „ÿ·Ê»° „‰ «·√›÷· ≈·€«¡ Â–« «· ‰’Ì» Ê≈” ⁄„«· Õ”«» 'Administrator' · ‰’Ì» POPFile."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; POPFile Installer: Custom Page - Check Perl Requirements [installer.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Page Title displayed in the page header (there is no sub-title for this page)

!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_TITLE        "ÊÃœ  „ﬂÊ‰«  ‰Ÿ«„ ﬁœÌ„…"

; Text strings displayed on the custom page

; TempTranslationNote: PFI_LANG_PERLREQ_IO_TEXT_A =  PFI_LANG_PERLREQ_IO_TEXT_1
; TempTranslationNote: PFI_LANG_PERLREQ_IO_TEXT_B =  PFI_LANG_PERLREQ_IO_TEXT_2
; TempTranslationNote: PFI_LANG_PERLREQ_IO_TEXT_C =  PFI_LANG_PERLREQ_IO_TEXT_3
; TempTranslationNote: PFI_LANG_PERLREQ_IO_TEXT_D =  PFI_LANG_PERLREQ_IO_TEXT_4
; TempTranslationNote: PFI_LANG_PERLREQ_IO_TEXT_E =  PFI_LANG_PERLREQ_IO_TEXT_5 + " $G_PLS_FIELD_1${IO_NL}${IO_NL}"
; TempTranslationNote: PFI_LANG_PERLREQ_IO_TEXT_F =  PFI_LANG_PERLREQ_IO_TEXT_6
; TempTranslationNote: PFI_LANG_PERLREQ_IO_TEXT_G =  PFI_LANG_PERLREQ_IO_TEXT_7

!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_A    "”Ì” ⁄„· «·„ ’›Õ «·≈› —«÷Ì ·⁄—÷ Ê«ÃÂ… ≈” ⁄„«· POPFile („—ﬂ“ «· Õﬂ„).${IO_NL}${IO_NL}"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_B    "·« Ì ÿ·» POPFile „ ’›Õ „Õœœ° ”Ì⁄„· „⁄ «Ì „ ’›Õ.${IO_NL}${IO_NL}"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_C    "”Ì „  ‰’Ì» ‰”Œ… „’€—… „‰ Perl ( „ ﬂ «»… POPFile »Ê«”ÿ… Perl).${IO_NL}${IO_NL}"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_D    "Ì ÿ·» Perl «·„“Êœ „⁄ POPFile »⁄÷ „ﬂÊ‰«  Internet Explorer Ê·Â–« Ì ÿ·» ÊÃÊœ Internet Explorer 5.5 (√Ê „« »⁄œÂ«)."
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_E    "·ﬁœ ≈ﬂ ‘› «·„‰’¯» ÊÃÊœ Internet Explorer ›Ì Â–« «·‰Ÿ«„ $G_PLS_FIELD_1${IO_NL}${IO_NL}"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_F    "„‰ «·„„ﬂ‰ √‰ »⁄÷ „Ì“«  POPFile ·‰  ⁄„· »‘ﬂ· ’ÕÌÕ ⁄·Ï Â–« «·‰Ÿ«„.${IO_NL}${IO_NL}"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_G    "≈–« Ê«ÃÂ  „‘«ﬂ· „⁄ POPFile° ›≈‰ «· —ﬁÌ… «·Ï ‰”Œ… ÃœÌœ… „‰ Internet Explorer „„ﬂ‰ «‰  ”«⁄œ."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; POPFile Installer: Standard MUI Page - COMPONENTS [installer.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING DESC_SecPOPFile               " ‰’Ì» «·„·›«  «·√”«”Ì… «·„Õ «Ã… „‰ ﬁˆ»· POPFile° »«·≈÷«›… ≈·Ï ‰”Œ… „’€—… „‰ Perl."
!insertmacro PFI_LANG_STRING DESC_SecSkins                 " ‰’Ì» ”„«  POPFile «· Ì  ”„Õ » €ÌÌ— ‘ﬂ· Ê«ÃÂ… «·„” Œœ„."
!insertmacro PFI_LANG_STRING DESC_SecLangs                 " ‰’Ì» ·€«  √Œ—Ï €Ì— «·≈‰Ã·Ì“Ì… „‰ Ê«ÃÂ… ≈” Œœ«„ POPFile."

!insertmacro PFI_LANG_STRING DESC_SubSecOptional           "Extra POPFile components (for advanced users)"
!insertmacro PFI_LANG_STRING DESC_SecIMAP                  "Installs the POPFile IMAP module"
!insertmacro PFI_LANG_STRING DESC_SecNNTP                  "Installs POPFile's NNTP proxy"
!insertmacro PFI_LANG_STRING DESC_SecSMTP                  "Installs POPFile's SMTP proxy"
!insertmacro PFI_LANG_STRING DESC_SecSOCKS                 "Installs extra Perl components which allow the POPFile proxies to use SOCKS"
!insertmacro PFI_LANG_STRING DESC_SecSSL                   "Downloads and installs the Perl components and SSL libraries which allow POPFile to make SSL connections to mail servers"
!insertmacro PFI_LANG_STRING DESC_SecXMLRPC                " ‰’Ì» »—Ì„Ã XMLRPC (··‰›«– ≈·Ï Ê«ÃÂ… »—„Ã… «·»—‰«„Ã (API) ·‹ˆ POPFile) Ê«·œ⁄„ «·„Õ «Ã ·‹ˆ Perl."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; POPFile Installer: Standard MUI Page - DIRECTORY (for POPFile program files) [installer.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Page Title shown in the page header and Text shown above the box showing the folder selected for the installation

!insertmacro PFI_LANG_STRING PFI_LANG_ROOTDIR_TITLE        "≈Œ Ì«— „Ã·œ  ‰’Ì» „·›«  «·»—‰«„Ã"
!insertmacro PFI_LANG_STRING PFI_LANG_ROOTDIR_TEXT_DESTN   "„Ã·œ  ‰’Ì» »—‰«„Ã POPFile"

; Message box warnings used when verifying the installation folder chosen by user

!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_1   "ÊÃœ  ‰”Œ… ”«»ﬁ ›Ì"

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

!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_CORE       " ‰’Ì» „·›«  POPFile «·√”«”Ì…..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_PERL       " ‰’Ì» „·›«  ‰”Œ… Perl «·„’€¯—…..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SKINS      " ‰’Ì» „·›«  «·”„«  «·≈÷«›Ì…..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_XMLRPC     " ‰’Ì» „·›«  XMLRPC..."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; POPFile Installer: Standard MUI Page - UNPAGE_INSTFILES [installer.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Uninstall Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_CORE         "Õ–› „·›«  POPFile «·√”«”Ì…..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_SKINS        "Õ–› „·›«  «·”„« ..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_PERL         "Õ–› „·›«  ‰”Œ… Perl «·„’€—…..."

; Uninstall Log Messages

!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_SHUTDOWN      "Shutting down POPFile using port"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_DELROOTDIR    "Removing all files from POPFile directory"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_DELROOTERR    "Note: unable to remove all files from POPFile directory"

; Message Box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMDIR_1        "Â·  —Ìœ Õ–› ﬂ· «·„·›«  ›Ì „Ã·œ POPFileø${MB_NL}${MB_NL}$G_ROOTDIR${MB_NL}${MB_NL}(≈–« ﬂ«‰ Â‰«ﬂ √‘Ì«¡  Õ «ÃÂ«° ≈÷€ÿ ·«)"

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

!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_INFO_TEXT    "”Ì—‘œﬂ Â–« «·„—‘œ Œ·«· ⁄„·Ì… ≈⁄œ«œ POPFile ··„” Œœ„ '$G_WINUSERNAME'.${IO_NL}${IO_NL}„‰ «·√›÷· ≈€·«ﬁ «·»—«„Ã «·√Œ—Ï ﬁ»· «·„ «»⁄….${IO_NL}${IO_NL}$_CLICK"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Standard MUI Page - DIRECTORY [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; $G_WINUSERNAME holds the Windows login name for the user running the wizard

!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_TITLE        "≈Œ »«— „Ã·œ „⁄·Ê„«  POPFile ··„” Œœ„ '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_SUBTITLE     "≈Œ — „Ã·œ Õ›Ÿ „⁄·Ê„«  POPFile ··„” Œœ„ '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_TEXT_TOP     "Â–Â «·≈’œ«—… „‰ POPFile  ” ⁄„· „Ã„Ê⁄«  „‰›’·… „‰ „·›«  «·„⁄·Ê„«  ·ﬂ· „” Œœ„.${MB_NL}${MB_NL}”ÌﬁÊ„ »—‰«„Ã «·≈⁄œ«œ »≈” ⁄„«· «·„Ã·œ «· «·Ì ·Õ›Ÿ „⁄·Ê„«  POPFile «·Œ«’… »«·„” Œœ„ '$G_WINUSERNAME'. ·≈” ⁄„«· „Ã·œ ¬Œ— ·Â–« «·„” Œœ„° ≈÷€ÿ ⁄·Ï ⁄—÷ Ê√Œ — „Ã·œ ¬Œ—. $_CLICK"
!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_TEXT_DESTN   "«·„Ã·œ «·„” Œœ„ ·Õ›Ÿ „⁄·Ê„«  POPFile «·Œ«’… »«·„” Œœ„ '$G_WINUSERNAME'"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Standard MUI Page - INSTFILES [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_TITLE        "≈⁄œ«œ«  POPFile ··„” Œœ„ '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_SUBTITLE     "«·—Ã«¡ «·≈‰ Ÿ«— √À‰«¡  ÕœÌÀ „·›«  ≈⁄œ«œ POPFile ·Â–« «·„” Œœ„"

; When resetting POPFile to use newly restored 'User Data', change "Install" button to "Restore"

!insertmacro PFI_LANG_STRING PFI_LANG_INST_BTN_RESTORE     "Restore"

; Installation Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_CORPUS     "⁄„· ‰”Œ… ≈Õ Ì«ÿÌ… „‰ «·„œÊ¯‰…. ”ÌÕ «Ã Â–« ·»÷⁄ ÀÊ«‰Ú..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SQLBACKUP  "Backing up the old SQLite database..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_FINDCORPUS "Looking for existing flat-file or BerkeleyDB corpus..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_MAKEBAT    "Generating the 'pfi-run.bat' batch file..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_REGSET     "Updating registry settings and environment variables..."

; Message Box text strings

; TempTranslationNote: PFI_LANG_MBSTPWDS_A = "POPFile 'stopwords' " + PFI_LANG_MBSTPWDS_1
; TempTranslationNote: PFI_LANG_MBSTPWDS_B = PFI_LANG_MBSTPWDS_2
; TempTranslationNote: PFI_LANG_MBSTPWDS_C = PFI_LANG_MBSTPWDS_3 + " 'stopwords.bak')"
; TempTranslationNote: PFI_LANG_MBSTPWDS_D = PFI_LANG_MBSTPWDS_4 + " 'stopwords.default')"

!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_A           "POPFile 'stopwords' ÊÃœ „·› „‰ ‰”Œ… ”«»ﬁ…."
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_B           "Â·  Ê«›ﬁ ⁄·Ï  ÕœÌÀ Â–« «·„·› ø"
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_C           "≈÷€ÿ '‰⁄„' · ÕœÌÀ «·„·› (”Ì „ Õ›Ÿ «·„·› «·”«»ﬁ »≈”„ 'stopwords.bak')"
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_D           "√÷€ÿ '·«' · —ﬂ «·„·› «·”«»ﬁ (”Ì „ Õ›Ÿ «·„·› «·ÃœÌœ »≈”„ 'stopwords.default')"

!insertmacro PFI_LANG_STRING PFI_LANG_MBCORPUS_1           " „ «·ﬂ‘› ⁄‰ Œ·· √À‰«¡ ﬁÌ«„ «·„‰’¯» »⁄„· ‰”Œ… ≈Õ Ì«ÿÌ… „‰ «·„œÊ¯‰… «·ﬁœÌ„…."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Message box warnings used when verifying the installation folder chosen by user [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_3   "ÊÃœ  „⁄·Ê„«  ≈⁄œ«œ ”«»ﬁ… ›Ì"
!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_4   "Restored configuration data found"
!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_5   "Do you want to use the restored data ?"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Custom Page - POPFile Installation Options [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_TITLE        "ŒÌ«—«   ‰’Ì» POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_SUBTITLE     "√ —ﬂ Â–Â «·ŒÌ«—«  ﬂ„« ÂÌ ≈·« ≈–« ≈Õ Ã  ·–·ﬂ"

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_POP3      "≈Œ — —ﬁ„ „‰›– ≈ ’«·«  POP3 (Ì›÷¯· 110)"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_GUI       "≈Œ — —ﬁ„ „‰›– ≈ ’«·«  'Ê«ÃÂ… «·„” Œœ„' (Ì›÷¯· 8080)"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_STARTUP   " ‘€Ì· POPFile »‘ﬂ·  ·ﬁ«∆Ì ⁄‰œ  ‘€Ì· ÊÌ‰œÊ“"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_WARNING   " Õ–Ì— „Â„"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_MESSAGE   "≈–« ﬂ‰   —ﬁÌ POPFILE --- ”ÌﬁÊ„ «·„‰’¯» »≈€·«ﬁ «·‰”Œ… «·Õ«·Ì…"

; Message Boxes used when validating user's selections

; TempTranslationNote: PFI_LANG_OPTIONS_MBPOP3_A = PFI_LANG_OPTIONS_MBPOP3_1 + " '$G_POP3'."
; TempTranslationNote: PFI_LANG_OPTIONS_MBPOP3_B = PFI_LANG_OPTIONS_MBPOP3_2
; TempTranslationNote: PFI_LANG_OPTIONS_MBPOP3_C = PFI_LANG_OPTIONS_MBPOP3_3

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_A     "·« Ì„ﬂ‰  ⁄œÌ· „‰›– POP3 ≈·Ï '$G_POP3'."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_B     "—ﬁ„ «·„‰›– ÌÃ» √‰ ÌﬂÊ‰ —ﬁ„« ›Ì «·› —… 1 ≈·Ï 65535."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_C     "«·—Ã«¡  €ÌÌ— ≈Œ Ì«—«  „‰›– POP3."

; TempTranslationNote: PFI_LANG_OPTIONS_MBGUI_A = PFI_LANG_OPTIONS_MBGUI_1 + " '$G_GUI'."
; TempTranslationNote: PFI_LANG_OPTIONS_MBGUI_B = PFI_LANG_OPTIONS_MBGUI_2
; TempTranslationNote: PFI_LANG_OPTIONS_MBGUI_C = PFI_LANG_OPTIONS_MBGUI_3

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_A      "·« Ì„ﬂ‰  ⁄œÌ· „‰›– 'Ê«ÃÂ… «·„” Œœ„' ≈·Ï '$G_GUI'."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_B      "—ﬁ„ «·„‰›– ÌÃ» √‰ ÌﬂÊ‰ —ﬁ„« ›Ì «·› —… 1 ≈·Ï 65535."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_C      "«·—Ã«¡  €ÌÌ— ≈Œ Ì«—«  „‰›– 'Ê«ÃÂ… «·„” Œœ„'."

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_1     "ÌÃ» √‰ ÌﬂÊ‰ „‰›– POP3 „Œ ·›« ⁄‰ „‰›– 'Ê«ÃÂ… «·„” Œœ„'."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_2     "«·—Ã«¡  €ÌÌ— ≈Œ Ì«—«  «·„‰›–."

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

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_TITLE            "≈‰‘«¡ œ·«¡  ’‰Ì› POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_SUBTITLE         "ÌÕ «Ã POPFile ⁄·Ï œ·ÊÌ‰ ⁄·Ï «·≈ﬁ· ·Ì „ﬂ‰ „‰  ’‰Ì› «·»—Ìœ"

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_INTRO         "»⁄œ «· ‰’Ì»° „‰ «·”Â·  €ÌÌ— ⁄œœ «·œ·«¡ (Ê«”«„ÌÂ«) · ·«∆„ ≈Õ Ì«Ã« ﬂ.${IO_NL}${IO_NL}≈”„«„Ì «·œ·«¡ ÌÃ» √‰  ﬂÊ‰ ﬂ·„«  „›—œ…° Ê ” ⁄„· «·√Õ—› »‘ﬂ· ’€Ì— „‰ a ≈·Ï z° «—ﬁ«„ 0 ≈·Ï 9° - Ê _."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_CREATE        "${IO_NL}≈‰‘«¡ œ·Ê ÃœÌœ ≈„« »≈Œ Ì«— ≈”„ „‰ «··«∆Õ… ›Ì «·√”›· √Ê ﬂ «»… ≈”„ „‰ ≈Œ Ì«—ﬂ."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_DELETE        "${IO_NL}·Õ–› œ·Ê Ê«Õœ √Ê √ﬂÀ— „‰ «··«∆Õ…° ⁄·¯„ «·„—»⁄ 'Õ–›' «·„·«∆„ Ê≈÷€ÿ '„ «»⁄…'."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_LISTHDR       "œ·«¡ „” ⁄„·… „ˆ‰ ﬁˆ»· POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_REMOVE        "Õ–›"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_CONTINUE      "„ «»⁄…"

; Text strings used for status messages under the bucket list

; TempTranslationNote: PFI_LANG_CBP_IO_MSG_A = PFI_LANG_CBP_IO_MSG_1
; TempTranslationNote: PFI_LANG_CBP_IO_MSG_B = PFI_LANG_CBP_IO_MSG_2
; TempTranslationNote: PFI_LANG_CBP_IO_MSG_C = PFI_LANG_CBP_IO_MSG_3
; TempTranslationNote: PFI_LANG_CBP_IO_MSG_D = PFI_LANG_CBP_IO_MSG_4 + " $G_PLS_FIELD_1 " + PFI_LANG_CBP_IO_MSG_5

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_A         "${IO_NL}·«  ÊÃœ «·Õ«Ã… ·≈÷«›… œ·«¡ √Œ—Ï"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_B         "${IO_NL}ÌÃ»  ⁄—Ì› ⁄·Ï «·√ﬁ· œ·ÊÌ‰ ≈À‰Ì‰"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_C         "${IO_NL}Ì·“„ ⁄·Ï «·√ﬁ· œ·Ê ¬Œ—"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_D         "${IO_NL}·« Ì” ÿÌ⁄ «·„‰’¯» √ﬂÀ— „‰ $G_PLS_FIELD_1 œ·«¡"

; Message box text strings

; TempTranslationNote: PFI_LANG_CBP_MBDUPERR_A = PFI_LANG_CBP_MBDUPERR_1 + " '$G_PLS_FIELD_1' " + PFI_LANG_CBP_MBDUPERR_2
; TempTranslationNote: PFI_LANG_CBP_MBDUPERR_B = PFI_LANG_CBP_MBDUPERR_3

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_A       "œ·Ê „”„Ï '$G_PLS_FIELD_1'  „  ⁄—Ì›Â „”»ﬁ«."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_B       "«·—Ã«¡ ≈Œ Ì«— ≈”„ ¬Œ— ··œ·Ê «·ÃœÌœ."

; TempTranslationNote: PFI_LANG_CBP_MBMAXERR_A = PFI_LANG_CBP_MBMAXERR_1 + " $G_PLS_FIELD_1 " + PFI_LANG_CBP_MBMAXERR_2
; TempTranslationNote: PFI_LANG_CBP_MBMAXERR_B = PFI_LANG_CBP_MBMAXERR_3 + " $G_PLS_FIELD_1 " + PFI_LANG_CBP_MBMAXERR_2

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_A       "Ì” ÿÌ⁄ «·„‰’¯» ≈‰‘«¡ ⁄·Ï «·√ﬂÀ— $G_PLS_FIELD_1 œ·«¡."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_B       "»⁄œ  ‰’Ì» POPFile  ” ÿÌ⁄ ≈÷«›… √ﬂÀ— „‰ $G_PLS_FIELD_1 œ·«¡"

; TempTranslationNote: PFI_LANG_CBP_MBNAMERR_A = PFI_LANG_CBP_MBNAMERR_1 + " '$G_PLS_FIELD_1' " + PFI_LANG_CBP_MBNAMERR_2
; TempTranslationNote: PFI_LANG_CBP_MBNAMERR_B = PFI_LANG_CBP_MBNAMERR_3
; TempTranslationNote: PFI_LANG_CBP_MBNAMERR_C = PFI_LANG_CBP_MBNAMERR_4

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_A       "«·≈”„ '$G_PLS_FIELD_1' €Ì— ’«·Õ ﬂ≈”„ œ·Ê."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_B       "√”«„Ì «·œ·«¡  ” ÿÌ⁄ √‰  Õ ÊÌ ›ﬁÿ √Õ—› „‰ a ≈·Ï z »«·‰„ÿ «·’€Ì—° √—ﬁ«„ 0 ≈·Ï 9° »«·≈÷«›… «·Ï - Ê _"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_C       "«·—Ã«¡ ≈Œ Ì«— ≈”„ ¬Œ— ··œ·Ê «·ÃœÌœ."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_1      "ÌÕ «Ã POPFile ≈·Ï œ·ÊÌ‰ √À‰Ì‰ ⁄·Ï «·≈ﬁ· ﬁ»· √‰ Ì „ﬂ‰ „‰  ’‰Ì› «·»—Ìœ."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_2      "«·—Ã«¡ ≈œŒ«· ≈”„ ·œ·Ê ··≈‰‘«¡°${MB_NL}${MB_NL}≈„« »≈Œ Ì«— ≈”„ „ﬁ —Õ „‰ «··«∆Õ…${MB_NL}${MB_NL}√Ê »ﬂ «»… ≈”„ „‰ ≈Œ Ì«—ﬂ."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_3      "ÌÃ»  ⁄—Ì› œ·ÊÌ‰ ⁄·Ï «·√ﬁ· ﬁ»· «·„ «»⁄… ›Ì  ‰’Ì» POPFile."

; TempTranslationNote: PFI_LANG_CBP_MBDONE_A = "$G_PLS_FIELD_1 " + PFI_LANG_CBP_MBDONE_1
; TempTranslationNote: PFI_LANG_CBP_MBDONE_B = PFI_LANG_CBP_MBDONE_2
; TempTranslationNote: PFI_LANG_CBP_MBDONE_C = PFI_LANG_CBP_MBDONE_3

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_A         "$G_PLS_FIELD_1 ÂÊ ⁄œœ «·œ·«¡ «·„⁄—›… · ” ⁄„· »Ê«”ÿ… POPFile."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_B         "Â·  —Ìœ ≈⁄œ«œ POPFile ·Ì” ⁄„· Â–Â «·œ·«¡ø"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_C         "≈÷€ÿ '·«' ≈–« ﬂ‰   —Ìœ  €ÌÌ— ≈Œ Ì«—«  «·œ·«¡."

; TempTranslationNote: PFI_LANG_CBP_MBMAKERR_A = PFI_LANG_CBP_MBMAKERR_1 + " $G_PLS_FIELD_1 " + PFI_LANG_CBP_MBMAKERR_2 + " $G_PLS_FIELD_2 " + PFI_LANG_CBP_MBMAKERR_3
; TempTranslationNote: PFI_LANG_CBP_MBMAKERR_B = PFI_LANG_CBP_MBMAKERR_4

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_A       "·„ Ì” ÿ⁄ «·„‰’¯» ≈‰‘«¡ $G_PLS_FIELD_1 „‰ $G_PLS_FIELD_2 «·œ·«¡ «· Ì ≈Œ — Â«."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_B       "»⁄œ  ‰’Ì» POPFile  ” ÿÌ⁄ ≈” ⁄„«· 'Ê«ÃÂ… «·„” Œœ„'${MB_NL}${MB_NL} Ê·ÊÕ… «· Õﬂ„ ·≈‰‘«¡ «·œ·«¡ «·‰«ﬁ’…."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Custom Page - Email Client Reconfiguration [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_TITLE        "≈⁄œ«œ«  »—«„Ã «·»—Ìœ"
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_SUBTITLE     "Ì” ÿÌ⁄ POPFile ≈⁄œ«œ ⁄œœ „‰ »—«„Ã «·»—Ìœ ‰Ì«»… ⁄‰ﬂ"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_TEXT_1    "»—«„Ã «·»—Ìœ «·„⁄·¯„… »Ê«”ÿ… (*) Ì„ﬂ‰ ≈⁄œ«œÂ« »‘ﬂ·  ·ﬁ«∆Ì° ≈› —«÷« »√‰ «·Õ”«»«  «·„” ⁄„·… »”Ìÿ….${IO_NL}${IO_NL}„‰ «·√›÷· √‰ Ì „ ≈⁄œ«œ «·Õ”«»«  «· Ì  ” ⁄„· «·„’«œﬁ… «·¬„‰… »‘ﬂ· ÌœÊÌ."
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_TEXT_2    "„Â„: «·—Ã«¡ ≈€·«ﬁ »—«„Ã «·»—Ìœ «·„—«œ ≈⁄œ«œÂ« »‘ﬂ·  ·ﬁ«∆Ì «·¬‰${IO_NL}${IO_NL}Â–Â «·„Ì“… ·«  “«· ﬁÌœ «· ÿÊÌ— („À«·: »⁄÷ Õ”«»«  Outlook ·« Ì „ ≈ﬂ ‘«›Â« √ÕÌ«‰«).${IO_NL}${IO_NL}«·—Ã«¡ ›Õ’ √‰ «·≈⁄œ«œ«   „¯  »‘ﬂ· ’ÕÌÕ (ﬁ»· ≈” ⁄„«· »—‰«„Ã «·»—Ìœ)."

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_CANCEL    " „ ≈·€«¡ ⁄„·Ì… ≈⁄œ«œ »—‰«„Ã «·»—Ìœ „‰ ﬁ»· «·„” Œœ„"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Text used on buttons to skip configuration of email clients [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_SKIPALL   " ŒÿÏ «·ﬂ·"
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_SKIPONE   " ŒÿÏ «·»—‰«„Ã"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Message box warnings that an email client is still running [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_EXP         " Õ–Ì—: ÌŸÂ— √‰ Outlook Express „« “«· Ì⁄„· !"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_OUT         " Õ–Ì—: ÌŸÂ— √‰ Outlook „« “«· Ì⁄„· !"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_EUD         " Õ–Ì—: ÌŸÂ— √‰ Eudora „« “«· Ì⁄„· !"

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_1      "«·—Ã«¡ ≈€·«ﬁ »—‰«„Ã «·»—Ìœ Ê„‰ À„ «·÷€ÿ ⁄·Ï '√⁄œ «·„Õ«Ê·…' ·≈⁄œ«œÂ"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_2      "(Ì„ﬂ‰ «·÷€ÿ ⁄·Ï '≈Â„·' ·≈⁄œ«œÂ° Ê·ﬂ‰ Â–« €Ì— „›÷¯·)"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_3      "≈÷€ÿ ⁄·Ï '≈·€«¡' · ŒÿÌ ≈⁄œ«œ Â–« «·»—‰«„Ã"

; Following three strings are used when uninstalling

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_4      "«·—Ã«¡ ≈€·«ﬁ »—‰«„Ã «·»—Ìœ Ê«·÷€ÿ ⁄·Ï '√⁄œ «·„Õ«Ê·…' ·≈⁄«œ… «·≈⁄œ«œ«  «·√’·Ì…"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_5      "(Ì„ﬂ‰ «·÷€ÿ ⁄·Ï '≈Â„·' ·≈⁄«œ… «·≈⁄œ«œ«  «·√’·Ì…° Ê·ﬂ‰ Â–« €Ì— „›÷¯·)"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_6      "≈÷€ÿ ⁄·Ï '≈·€«¡' · ŒÿÌ ≈⁄«œ… «·≈⁄œ«œ«  «·√’·Ì…"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Custom Page - Reconfigure Outlook/Outlook Express [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_TITLE         "≈⁄œ«œ Outlook Express"
!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_SUBTITLE      "»” ÿÌ⁄ POPFile ≈⁄œ«œ Outlook Express »«·‰Ì«»… ⁄‰ﬂ"

!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_TITLE         "≈⁄œ«œ Outlook"
!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_SUBTITLE      "Ì” ÿÌ⁄ POPFile ≈⁄œ«œ Outlook »«·‰Ì«»… ⁄‰ﬂ"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_IO_CANCELLED  "≈·€«¡ ≈⁄œ«œ Outlook Express „‰ ﬁˆ»· «·„” Œœ„"
!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_IO_CANCELLED  "≈·€«¡ ≈⁄œ«œ Outlook „‰ ﬁˆ»· «·„” Œœ„"

!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_BOXHDR     "Õ”«»« "
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_ACCOUNTHDR "Õ”«»"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_EMAILHDR   "⁄‰Ê«‰ »—Ìœ ≈·ﬂ —Ê‰Ì"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_SERVERHDR  "Œ«œ„"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_USRNAMEHDR "≈”„ „” Œœ„"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_FOOTNOTE   "⁄·¯„ «·„—»⁄(‹« ) ·≈⁄œ«œ «·Õ”«»(‹« ).${IO_NL}⁄‰œ ≈“«·… POPFile Ì „ ≈⁄«œ… «·≈⁄œ«œ«  «·√’·Ì…."

; Message Box to confirm changes to Outlook/Outlook Express account configuration

!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_MBIDENTITY    "ÂÊÌ… Outlook Express :"
!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_MBACCOUNT     "Õ”«» Outlook Express :"

!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_MBIDENTITY    "„” Œœ„ Outlook :"
!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_MBACCOUNT     "Õ”«» Outlook :"

!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBEMAIL       "⁄‰Ê«‰ «·»—Ìœ «·≈·ﬂ —Ê‰Ì :"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBSERVER      "Œ«œ„ POP3 :"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBUSERNAME    "≈”„ „” Œœ„POP3 :"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBOEPORT      "„‰›– POP3 :"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBOLDVALUE    "Õ«·Ì«"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBQUESTION    "ﬁ„ ≈⁄œ«œ Â–« «·Õ”«» ·Ì⁄„· „⁄ POPFile ø"

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

!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_TITLE          "≈⁄œ«œ Eudora"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_SUBTITLE       "Ì” ÿÌ⁄ POPFile ≈⁄œ«œ Eudora »«·‰Ì »… ⁄‰ﬂ"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_CANCELLED   "≈·€«¡ ≈⁄œ«œ Eudora „‰ ﬁˆ»· «·„” Œœ„"

!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_INTRO_1     "POPFile ﬁ«„ »«·ﬂ‘› ⁄‰ ‘Œ’Ì… Eudora «· «·Ì…"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_INTRO_2     " ÊÌ” ÿÌ⁄ ≈⁄œ«œÂ« »‘ÿ·  ·ﬁ«∆Ì · ⁄„· „⁄ POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_CHECKBOX    "≈⁄œ«œ Â–Â «·‘Œ’Ì… · ⁄„· „⁄ POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_DOMINANT    "<Dominant> ‘Œ’Ì…"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_PERSONA     "‘Œ’Ì…"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_EMAIL       "⁄‰Ê«‰ «·»—Ìœ «·≈·ﬂ —Ê‰Ì:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_SERVER      "Œ«œ„ POP3:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_USERNAME    "≈”„ „” Œœ„ POP3:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_POP3PORT    "„‰›– POP3:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_RESTORE     "≈–« ﬁ„  »≈“«·… POPFile ”Ì „ ≈⁄«œ… «·≈⁄œ«œ«  «·√’·Ì…"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Custom Page - POPFile can now be started [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_TITLE         "Ì„ﬂ‰  ‘€Ì· POPFile «·¬‰"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_SUBTITLE      " ⁄„· Ê«ÃÂ… «·„” Œœ„ ›ﬁÿ ≈–«  „  ‘€Ì· POPFile"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_INTRO      " ‘€Ì· POPFile «·¬‰ø"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NO         "·« (·«  ⁄„· 'Ê«ÃÂ… «·„” Œœ„' ≈–« ﬂ«‰ POPFile „ﬁ›·)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_DOSBOX     "‘€¯· POPFile (›Ì ‰«›–…)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_BCKGRND    "‘€¯· POPFile ›Ì «·Œ·›Ì… (»œÊ‰ ≈ŸÂ«— ‰«›–…)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOICON     "Run POPFile (do not show system tray icon)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_TRAYICON   "Run POPFile with system tray icon"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_1     "»⁄œ  ‘€Ì· POPFile° Ì„ﬂ‰ ⁄—÷ 'Ê«ÃÂ… «·„” Œœ„' ⁄‰ ÿ—Ìﬁ"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_2     "(√) ÷€ÿ „“œÊÃ ⁄·Ï √ÌﬁÊ‰… POPFile ›Ì ‘—Ìÿ «·„Â«„°  √Ê"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_3     "(») ≈” ⁄„«· «»œ√ --> »—«„Ã --> POPFile --> POPFile User Interface."

; Banner message displayed whilst waiting for POPFile to start

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_BANNER_1      "«· Õ÷Ì— · ‘⁄Ì· POPFile."
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_BANNER_2      "”ÌÕ «Ã «·√„— ·»÷⁄ ·ÕŸ« ..."

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Standard MUI Page - FINISH [adduser.nsi]
;
; The PFI_LANG_FINISH_RUN_TEXT text should be a short phrase (not a long paragraph)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; $G_WINUSERNAME holds the Windows login name of the user running the wizard

!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_FINISH_INFO " „ ≈⁄œ«œ POPFile ··„” Œœ„ '$G_WINUSERNAME'.${IO_NL}${IO_NL}≈÷€Ÿ ≈‰Â«¡ ·≈€·«ﬁ Â–« «·„—‘œ."

!insertmacro PFI_LANG_STRING PFI_LANG_FINISH_RUN_TEXT      "Ê«ÃÂ… ≈” Œœ«„ POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_FINISH_WEB_LINK_TEXT "Click here to visit the POPFile web site"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Standard MUI Page - Uninstall Confirmation Page (for the 'Add POPFile User' wizard) [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; $G_WINUSERNAME holds the Windows login name for the user running the uninstall wizard

!insertmacro PFI_LANG_STRING PFI_LANG_REMUSER_TITLE        "≈“«·… „⁄·Ê„«  POPFile ··„” Œœ„ '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_REMUSER_SUBTITLE     "≈“«·… „·›«  „⁄·Ê„«  ≈⁄œ«œ POPFile ·Â–« «·„” Œœ„ ⁄·Ï «·ÃÂ«“"

!insertmacro PFI_LANG_STRING PFI_LANG_REMUSER_TEXT_TOP     "”  „ ≈“«·… „⁄·Ê„«  ≈⁄œ«œ POPFile ··„” Œœ„ '$G_WINUSERNAME' „‰ «·„Ã·œ «· «·Ìr. $_CLICK"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Standard MUI Page - Uninstallation Page (for the 'Add POPFile User' wizard) [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; $G_WINUSERNAME holds the Windows login name for the user running the uninstall wizard

!insertmacro PFI_LANG_STRING PFI_LANG_REMOVING_TITLE       "≈“«·… „⁄·Ê„«  POPFile ··„” Œœ„ '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_REMOVING_SUBTITLE    "«·—Ã«¡ «·≈‰ Ÿ«— √À‰«¡ Õ–› „·›«  ≈⁄œ«œ POPFile ·Â–« «·„” Œœ„"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Add User: Standard MUI Page - UNPAGE_INSTFILES [adduser.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Uninstall Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_OUTEXPRESS   "≈⁄«œ… ≈⁄œ«œ«  Outlook Express..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_OUTLOOK      "≈⁄«œ… ≈⁄œ«œ Outlook..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_EUDORA       "≈⁄«œ… ≈⁄œ«œ Eudora..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_DBMSGDIR     "Deleting corpus and 'Recent Messages' directory..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_CONFIG       "Deleting configuration data..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_EXESTATUS    "Checking program status..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_REGISTRY     "Deleting POPFile registry entries..."

; Uninstall Log Messages

!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_OPENED        "Opened"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_RESTORED      "Restored"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_CLOSED        "Closed"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_DATAPROBS     "Data problems"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_DELUSERDIR    "Removing all files from POPFile 'User Data' directory"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_DELUSERERR    "Note: unable to remove all files from POPFile 'User Data' directory"

; Message Box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_1        "„‘ﬂ·… 'Outlook Express' !"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_2        "„‘ﬂ·… 'Outlook' !"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_3        "„‘ﬂ·… 'Eudora' !"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBEMAIL_1         "·„  ﬂ‰ Â‰«ﬂ «·≈„ﬂ«‰Ì… ·≈⁄«œ… »⁄÷ «·≈⁄œ«œ«  «·√’·Ì…"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBEMAIL_2         "⁄—÷  ﬁ—Ì— «·√Œÿ«¡ ø"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_1         "»⁄÷ ≈⁄œ«œ«  »—‰«„Ã «·»—Ìœ ·„   „ ≈⁄«œ Â« ≈·Ï Õ«· Â« «·√’·Ì… !"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_2         "(Ì„ﬂ‰ ≈ÌÃ«œ «· ›«’Ì· ›Ì «·„Ã·œ $INSTDIR)"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_3         "≈÷€ÿ '·«' ·≈Â„«· Â–Â «·√Œÿ«¡ ÊÕ–› ﬂ· ‘Ì¡"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_4         "≈÷€ÿ '‰⁄„' ··„Õ«›Ÿ… ⁄·Ï Â–Â «·„⁄·Ê„«  (··”„«Õ ·„Õ«Ê·… √Œ—Ï ·«Õﬁ«)"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMDIR_2        "Â·  —Ìœ Õ–› ﬂ· «·„·›«  ›Ì „Ã·œ '„⁄·Ê„«  «·„” Œœ„' «·Œ«’ »‹ˆPOPFileø${MB_NL}${MB_NL}$G_USERDIR${MB_NL}${MB_NL}(≈–« ﬂ«‰ Â‰«ﬂ √‘Ì«¡  Õ «ÃÂ«° ≈÷€ÿ ·«)"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBDELMSGS_1       "Do you want to remove all files in your 'Recent Messages' directory?"

###########################################################################
###########################################################################

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Corpus Conversion: Standard MUI Page - INSTFILES [MonitorCC.nsi]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_TITLE        " ÕÊÌ· „œÊ¯‰… POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_SUBTITLE     "ÌÃ»  ÕÊÌ· «·„œÊ¯‰… «·Õ«·Ì… · ⁄„· „⁄ Â–Â «·‰”Œ… „‰ POPFile"

!insertmacro PFI_LANG_STRING PFI_LANG_ENDCONVERT_TITLE     "≈‰ Â«¡  ÕÊÌ· „œÊ¯‰… POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_ENDCONVERT_SUBTITLE  "«·—Ã«¡ «·÷€ÿ ⁄·Ï ≈€·«ﬁ ··„ «»⁄…"

!insertmacro PFI_LANG_STRING PFI_LANG_BADCONVERT_TITLE     "›‘· ⁄„·Ì…  ÕÊÌ· „œÊ¯‰… POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_BADCONVERT_SUBTITLE  "«·—Ã«¡ «·÷€ÿ ⁄·Ï ≈·€«¡ ··„ «»⁄…"

!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_MUTEX        "‰”Œ… √Œ—Ï „‰ 'Corpus Conversion Monitor'  ⁄„· „”»ﬁ« !"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_PRIVATE      "'Corpus Conversion Monitor' ⁄»«—… ⁄‰ ﬁ”„ „‰ „‰’¯» POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_NOFILE       "Œ··: „·›«   ÕÊÌ· „⁄·Ê„«  «·„œÊ¯‰… €Ì— „ÊÃÊœ… !"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_NOPOPFILE    "Œ··: ·„ Ì „ «·⁄ÀÊ— ⁄·Ï „”«— POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_STARTERR     "·ﬁœ Õ’· Œ·· √À‰«¡  ‘€Ì· ⁄„·Ì…  ÕÊÌ· «·„œÊ¯‰…"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_FATALERR     "A fatal error occurred during the corpus conversion process !"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_ESTIMATE     "«·“„‰ «·„ »ﬁÌ: "
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_MINUTES      "œﬁ«∆ﬁ"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_WAITING      "(≈‰ Ÿ«—  ÕÊÌ· «·„·› «·√Ê·)"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_TOTALFILES   "Â‰«ﬂ $G_BUCKET_COUNT œ·«¡ ·Ì „  ÕÊÌ·Â«"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_PROGRESS_N   "»⁄œ $G_ELAPSED_TIME.$G_DECPLACES œﬁÌﬁ… Ì »ﬁÏ Â‰«ﬂ $G_STILL_TO_DO „·›«  ·· ÕÊÌ·"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_PROGRESS_1   "»⁄œ $G_ELAPSED_TIME.$G_DECPLACES œﬁÌﬁ… Ì»ﬁÏ Â‰«ﬂ „·› Ê«Õœ ·Ì „  ÕÊÌ·Â"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_SUMMARY      "≈” €—ﬁ  ⁄„·Ì…  ÕÊÌ· «·„œÊ¯‰… ≈·Ï $G_ELAPSED_TIME.$G_DECPLACES œﬁÌﬁ…"

###########################################################################
###########################################################################

#--------------------------------------------------------------------------
# Mark the end of the language data
#--------------------------------------------------------------------------

!undef PFI_LANG

#--------------------------------------------------------------------------
# End of 'Arabic-pfi.nsh'
#--------------------------------------------------------------------------
