#--------------------------------------------------------------------------
# Arabic-pfi.nsh
#
# This file contains the "Arabic" text strings used by the Windows installer
# for POPFile (includes customised versions of strings provided by NSIS and
# strings which are unique to POPFile).
#
# These strings are grouped according to the page/window where they are used
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

#==========================================================================
# Customised versions of strings used on standard MUI pages
#==========================================================================

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Used by the main POPFile installer (main script: installer.nsi)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#--------------------------------------------------------------------------
# Standard MUI Page - Welcome (for the main POPFile installer)
#
# The sequence ${IO_NL}${IO_NL} inserts a blank line (note that the PFI_LANG_WELCOME_INFO_TEXT string
# should end with a ${IO_NL}${IO_NL}$_CLICK sequence).
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_WELCOME_INFO_TEXT    "”Ì”«⁄œﬂ Â–« «·„—‘œ Œ·«· ⁄„·Ì…  ‰’Ì» POPFile.${IO_NL}${IO_NL}„‰ «·√›÷· ≈€·«ﬁ «·»—«„Ã «·√Œ—Ï ﬁ»· «·„ «»⁄….${IO_NL}${IO_NL}$_CLICK"
!insertmacro PFI_LANG_STRING PFI_LANG_WELCOME_ADMIN_TEXT   "„·«ÕŸ… „Â„…:${IO_NL}${IO_NL}«·„” Œœ„ «·Õ«·Ì ·« Ì„·ﬂ ’·«ÕÌ… 'Administrator'.${IO_NL}${IO_NL}≈–« ﬂ«‰ «·œ⁄„ ·⁄œ… „” Œœ„Ì‰ „ÿ·Ê»° „‰ «·√›÷· ≈·€«¡ Â–« «· ‰’Ì» Ê≈” ⁄„«· Õ”«» 'Administrator' · ‰’Ì» POPFile."

#--------------------------------------------------------------------------
# Standard MUI Page - Directory Page (for the main POPFile installer)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_ROOTDIR_TITLE        "≈Œ Ì«— „Ã·œ  ‰’Ì» „·›«  «·»—‰«„Ã"
!insertmacro PFI_LANG_STRING PFI_LANG_ROOTDIR_TEXT_DESTN   "„Ã·œ  ‰’Ì» »—‰«„Ã POPFile"

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

!insertmacro PFI_LANG_STRING PFI_LANG_FINISH_RUN_TEXT      "Ê«ÃÂ… ≈” Œœ«„ POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_FINISH_WEB_LINK_TEXT "Click here to visit the POPFile web site"


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Used by 'Monitor Corpus Conversion' utility (main script: MonitorCC.nsi)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#--------------------------------------------------------------------------
# Standard MUI Page - Installation Page (for the 'Monitor Corpus Conversion' utility)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_TITLE        " ÕÊÌ· „œÊ¯‰… POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_SUBTITLE     "ÌÃ»  ÕÊÌ· «·„œÊ¯‰… «·Õ«·Ì… · ⁄„· „⁄ Â–Â «·‰”Œ… „‰ POPFile"

!insertmacro PFI_LANG_STRING PFI_LANG_ENDCONVERT_TITLE     "≈‰ Â«¡  ÕÊÌ· „œÊ¯‰… POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_ENDCONVERT_SUBTITLE  "«·—Ã«¡ «·÷€ÿ ⁄·Ï ≈€·«ﬁ ··„ «»⁄…"

!insertmacro PFI_LANG_STRING PFI_LANG_BADCONVERT_TITLE     "›‘· ⁄„·Ì…  ÕÊÌ· „œÊ¯‰… POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_BADCONVERT_SUBTITLE  "«·—Ã«¡ «·÷€ÿ ⁄·Ï ≈·€«¡ ··„ «»⁄…"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Used by 'Add POPFile User' wizard (main script: adduser.nsi)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#--------------------------------------------------------------------------
# Standard MUI Page - Welcome (for the 'Add POPFile User' wizard)
#
# The sequence ${IO_NL}${IO_NL} inserts a blank line (note that the PFI_LANG_ADDUSER_INFO_TEXT string
# should end with a ${IO_NL}${IO_NL}$_CLICK sequence).
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_INFO_TEXT    "”Ì—‘œﬂ Â–« «·„—‘œ Œ·«· ⁄„·Ì… ≈⁄œ«œ POPFile ··„” Œœ„ '$G_WINUSERNAME'.${IO_NL}${IO_NL}„‰ «·√›÷· ≈€·«ﬁ «·»—«„Ã «·√Œ—Ï ﬁ»· «·„ «»⁄….${IO_NL}${IO_NL}$_CLICK"

#--------------------------------------------------------------------------
# Standard MUI Page - Directory Page (for the 'Add POPFile User' wizard)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_TITLE        "≈Œ »«— „Ã·œ „⁄·Ê„«  POPFile ··„” Œœ„ '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_SUBTITLE     "≈Œ — „Ã·œ Õ›Ÿ „⁄·Ê„«  POPFile ··„” Œœ„ '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_TEXT_TOP     "Â–Â «·≈’œ«—… „‰ POPFile  ” ⁄„· „Ã„Ê⁄«  „‰›’·… „‰ „·›«  «·„⁄·Ê„«  ·ﬂ· „” Œœ„.${MB_NL}${MB_NL}”ÌﬁÊ„ »—‰«„Ã «·≈⁄œ«œ »≈” ⁄„«· «·„Ã·œ «· «·Ì ·Õ›Ÿ „⁄·Ê„«  POPFile «·Œ«’… »«·„” Œœ„ '$G_WINUSERNAME'. ·≈” ⁄„«· „Ã·œ ¬Œ— ·Â–« «·„” Œœ„° ≈÷€ÿ ⁄·Ï ⁄—÷ Ê√Œ — „Ã·œ ¬Œ—. $_CLICK"
!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_TEXT_DESTN   "«·„Ã·œ «·„” Œœ„ ·Õ›Ÿ „⁄·Ê„«  POPFile «·Œ«’… »«·„” Œœ„ '$G_WINUSERNAME'"

#--------------------------------------------------------------------------
# Standard MUI Page - Installation Page (for the 'Add POPFile User' wizard)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_TITLE        "≈⁄œ«œ«  POPFile ··„” Œœ„ '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_SUBTITLE     "«·—Ã«¡ «·≈‰ Ÿ«— √À‰«¡  ÕœÌÀ „·›«  ≈⁄œ«œ POPFile ·Â–« «·„” Œœ„"

#--------------------------------------------------------------------------
# Standard MUI Page - Finish (for the 'Add POPFile User' wizard)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_FINISH_INFO " „ ≈⁄œ«œ POPFile ··„” Œœ„ '$G_WINUSERNAME'.${IO_NL}${IO_NL}≈÷€Ÿ ≈‰Â«¡ ·≈€·«ﬁ Â–« «·„—‘œ."

#--------------------------------------------------------------------------
# Standard MUI Page - Uninstall Confirmation Page (for the 'Add POPFile User' wizard)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_REMUSER_TITLE        "≈“«·… „⁄·Ê„«  POPFile ··„” Œœ„ '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_REMUSER_SUBTITLE     "≈“«·… „·›«  „⁄·Ê„«  ≈⁄œ«œ POPFile ·Â–« «·„” Œœ„ ⁄·Ï «·ÃÂ«“"

!insertmacro PFI_LANG_STRING PFI_LANG_REMUSER_TEXT_TOP     "”  „ ≈“«·… „⁄·Ê„«  ≈⁄œ«œ POPFile ··„” Œœ„ '$G_WINUSERNAME' „‰ «·„Ã·œ «· «·Ìr. $_CLICK"

#--------------------------------------------------------------------------
# Standard MUI Page - Uninstallation Page (for the 'Add POPFile User' wizard)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_REMOVING_TITLE       "≈“«·… „⁄·Ê„«  POPFile ··„” Œœ„ '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_REMOVING_SUBTITLE    "«·—Ã«¡ «·≈‰ Ÿ«— √À‰«¡ Õ–› „·›«  ≈⁄œ«œ POPFile ·Â–« «·„” Œœ„"


#==========================================================================
# Strings used for custom pages, message boxes and banners
#==========================================================================

#--------------------------------------------------------------------------
# General purpose banner text (also suitable for page titles/subtitles)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_BE_PATIENT           "«·—Ã«¡ «·≈‰ Ÿ«—."
!insertmacro PFI_LANG_STRING PFI_LANG_TAKE_A_FEW_SECONDS   "”ÌÕ «Ã «·√„— ·»÷⁄ ·ÕŸ« ..."

#--------------------------------------------------------------------------
# Message displayed when 'Add User' does not seem to be part of the current version
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_COMPAT_NOTFOUND      "Error: Compatible version of ${C_PFI_PRODUCT} not found !"

#--------------------------------------------------------------------------
# Message displayed when installer exits because another copy is running
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_INSTALLER_MUTEX      "‰”Œ… √Œ—Ï „‰ „‰’¯» POPFile ﬁÌœ «· ‰›Ì– !"

#--------------------------------------------------------------------------
# Message box warnings used when verifying the installation folder chosen by user
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_1   "ÊÃœ  ‰”Œ… ”«»ﬁ ›Ì"
!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_2   "Â·  —Ìœ  —ﬁÌ Â«ø"
!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_3   "ÊÃœ  „⁄·Ê„«  ≈⁄œ«œ ”«»ﬁ… ›Ì"
!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_4   "Restored configuration data found"
!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_5   "Do you want to use the restored data ?"

#--------------------------------------------------------------------------
# Startup message box offering to display the Release Notes
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_1         "⁄—÷ „·«ÕŸ«  ≈’œ«—… POPFile ø"
!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_2         "„‰ «·√›÷· «·„Ê«›ﬁ… ≈–« ﬂ‰   —Ìœ  —ﬁÌ… POPFile („‰ «·„„ﬂ‰ √‰  Õ «Ã ·⁄„· ‰”Œ… ≈Õ Ì«ÿÌ… ﬁ»· «· —ﬁÌ…)"

#--------------------------------------------------------------------------
# Custom Page - Check Perl Requirements
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_TITLE        "ÊÃœ  „ﬂÊ‰«  ‰Ÿ«„ ﬁœÌ„…"

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_1    "”Ì” ⁄„· «·„ ’›Õ «·≈› —«÷Ì ·⁄—÷ Ê«ÃÂ… ≈” ⁄„«· POPFile („—ﬂ“ «· Õﬂ„).${IO_NL}${IO_NL}"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_2    "·« Ì ÿ·» POPFile „ ’›Õ „Õœœ° ”Ì⁄„· „⁄ «Ì „ ’›Õ.${IO_NL}${IO_NL}"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_3    "”Ì „  ‰’Ì» ‰”Œ… „’€—… „‰ Perl ( „ ﬂ «»… POPFile »Ê«”ÿ… Perl).${IO_NL}${IO_NL}"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_4    "Ì ÿ·» Perl «·„“Êœ „⁄ POPFile »⁄÷ „ﬂÊ‰«  Internet Explorer Ê·Â–« Ì ÿ·» ÊÃÊœ Internet Explorer 5.5 (√Ê „« »⁄œÂ«)."
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_5    "·ﬁœ ≈ﬂ ‘› «·„‰’¯» ÊÃÊœ Internet Explorer ›Ì Â–« «·‰Ÿ«„"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_6    "„‰ «·„„ﬂ‰ √‰ »⁄÷ „Ì“«  POPFile ·‰  ⁄„· »‘ﬂ· ’ÕÌÕ ⁄·Ï Â–« «·‰Ÿ«„.${IO_NL}${IO_NL}"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_7    "≈–« Ê«ÃÂ  „‘«ﬂ· „⁄ POPFile° ›≈‰ «· —ﬁÌ… «·Ï ‰”Œ… ÃœÌœ… „‰ Internet Explorer „„ﬂ‰ «‰  ”«⁄œ."

#--------------------------------------------------------------------------
# Standard MUI Page - Choose Components
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING DESC_SecPOPFile               " ‰’Ì» «·„·›«  «·√”«”Ì… «·„Õ «Ã… „‰ ﬁˆ»· POPFile° »«·≈÷«›… ≈·Ï ‰”Œ… „’€—… „‰ Perl."
!insertmacro PFI_LANG_STRING DESC_SecSkins                 " ‰’Ì» ”„«  POPFile «· Ì  ”„Õ » €ÌÌ— ‘ﬂ· Ê«ÃÂ… «·„” Œœ„."
!insertmacro PFI_LANG_STRING DESC_SecLangs                 " ‰’Ì» ·€«  √Œ—Ï €Ì— «·≈‰Ã·Ì“Ì… „‰ Ê«ÃÂ… ≈” Œœ«„ POPFile."

!insertmacro PFI_LANG_STRING DESC_SubSecOptional           "Extra POPFile components (for advanced users)"
!insertmacro PFI_LANG_STRING DESC_SecIMAP                  "Installs the POPFile IMAP module"
!insertmacro PFI_LANG_STRING DESC_SecNNTP                  "Installs POPFile's NNTP proxy"
!insertmacro PFI_LANG_STRING DESC_SecSMTP                  "Installs POPFile's SMTP proxy"
!insertmacro PFI_LANG_STRING DESC_SecSOCKS                 "Installs extra Perl components which allow the POPFile proxies to use SOCKS"
!insertmacro PFI_LANG_STRING DESC_SecXMLRPC                " ‰’Ì» »—Ì„Ã XMLRPC (··‰›«– ≈·Ï Ê«ÃÂ… »—„Ã… «·»—‰«„Ã (API) ·‹ˆ POPFile) Ê«·œ⁄„ «·„Õ «Ã ·‹ˆ Perl."

; Text strings used when user has NOT selected a component found in the existing installation

!insertmacro PFI_LANG_STRING MBCOMPONENT_PROB_1            "Do you want to upgrade the existing $G_PLS_FIELD_1 component ?"
!insertmacro PFI_LANG_STRING MBCOMPONENT_PROB_2            "(using out of date POPFile components can cause problems)"

#--------------------------------------------------------------------------
# Custom Page - POPFile Installation Options
#--------------------------------------------------------------------------

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

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_1     "·« Ì„ﬂ‰  ⁄œÌ· „‰›– POP3 ≈·Ï"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_2     "—ﬁ„ «·„‰›– ÌÃ» √‰ ÌﬂÊ‰ —ﬁ„« ›Ì «·› —… 1 ≈·Ï 65535."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_3     "«·—Ã«¡  €ÌÌ— ≈Œ Ì«—«  „‰›– POP3."

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_1      "·« Ì„ﬂ‰  ⁄œÌ· „‰›– 'Ê«ÃÂ… «·„” Œœ„' ≈·Ï"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_2      "—ﬁ„ «·„‰›– ÌÃ» √‰ ÌﬂÊ‰ —ﬁ„« ›Ì «·› —… 1 ≈·Ï 65535."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_3      "«·—Ã«¡  €ÌÌ— ≈Œ Ì«—«  „‰›– 'Ê«ÃÂ… «·„” Œœ„'."

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_1     "ÌÃ» √‰ ÌﬂÊ‰ „‰›– POP3 „Œ ·›« ⁄‰ „‰›– 'Ê«ÃÂ… «·„” Œœ„'."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_2     "«·—Ã«¡  €ÌÌ— ≈Œ Ì«—«  «·„‰›–."

#--------------------------------------------------------------------------
# Standard MUI Page - Installing POPFile
#--------------------------------------------------------------------------

; When upgrading an existing installation, change the normal "Install" button to "Upgrade"
; (the page with the "Install" button will vary depending upon the page order in the script)

!insertmacro PFI_LANG_STRING PFI_LANG_INST_BTN_UPGRADE     "Upgrade"

; When resetting POPFile to use newly restored 'User Data', change "Install" button to "Restore"

!insertmacro PFI_LANG_STRING PFI_LANG_INST_BTN_RESTORE     "Restore"

; Installation Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_UPGRADE    " ›Õ¯’ ≈–« ﬂ«‰ Â–«  ‰’Ì»  —ﬁÌ…..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_CORE       " ‰’Ì» „·›«  POPFile «·√”«”Ì…..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_PERL       " ‰’Ì» „·›«  ‰”Œ… Perl «·„’€¯—…..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SHORT      "≈‰‘«¡ ≈Œ ’«—«  POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_CORPUS     "⁄„· ‰”Œ… ≈Õ Ì«ÿÌ… „‰ «·„œÊ¯‰…. ”ÌÕ «Ã Â–« ·»÷⁄ ÀÊ«‰Ú..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SKINS      " ‰’Ì» „·›«  «·”„«  «·≈÷«›Ì…..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_LANGS      " ‰’Ì» „·›«  «··€«  ≈÷«›Ì…..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_XMLRPC     " ‰’Ì» „·›«  XMLRPC..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_REGSET     "Updating registry settings and environment variables..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SQLBACKUP  "Backing up the old SQLite database..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_FINDCORPUS "Looking for existing flat-file or BerkeleyDB corpus..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_MAKEBAT    "Generating the 'pfi-run.bat' batch file..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_ENDSEC     "≈÷€ÿ «· «·Ì ··„ «»⁄…"

; Installation Log Messages

!insertmacro PFI_LANG_STRING PFI_LANG_INST_LOG_SHUTDOWN    "≈€·«ﬁ «·‰”Œ… «·”«»ﬁ… „‰ POPFile ⁄‰ ÿ—Ìﬁ «·„‰›–"

; Message Box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_1           "ÊÃœ „·› „‰ ‰”Œ… ”«»ﬁ…."
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_2           "Â·  Ê«›ﬁ ⁄·Ï  ÕœÌÀ Â–« «·„·› ø"
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_3           "≈÷€ÿ '‰⁄„' · ÕœÌÀ «·„·› (”Ì „ Õ›Ÿ «·„·› «·”«»ﬁ »≈”„"
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_4           "√÷€ÿ '·«' · —ﬂ «·„·› «·”«»ﬁ (”Ì „ Õ›Ÿ «·„·› «·ÃœÌœ »≈”„"

!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_1          "·«  ÊÃœ «·≈„ﬂ«‰Ì… ·≈€·«ﬁ $G_PLS_FIELD_1 »‘ﬂ·  ·ﬁ«∆Ì."
!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_2          "«·—Ã«¡ ≈€·«ﬁ $G_PLS_FIELD_1 »‘ﬂ· ÌœÊÌ «·¬‰."
!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_3          "⁄‰œ„« Ì „ ≈€·«ﬁ $G_PLS_FIELD_1° ≈÷€ÿ '„Ê«›ﬁ' ··„ «»⁄…."

!insertmacro PFI_LANG_STRING PFI_LANG_MBCORPUS_1           " „ «·ﬂ‘› ⁄‰ Œ·· √À‰«¡ ﬁÌ«„ «·„‰’¯» »⁄„· ‰”Œ… ≈Õ Ì«ÿÌ… „‰ «·„œÊ¯‰… «·ﬁœÌ„…."

#--------------------------------------------------------------------------
# Custom Page - POPFile Classification Bucket Creation
#--------------------------------------------------------------------------

; POPFile requires at least TWO buckets in order to work properly. PFI_LANG_CBP_DEFAULT_BUCKETS
; defines the default buckets and PFI_LANG_CBP_SUGGESTED_NAMES defines a list of suggested names
; to help the user get started with POPFile. Both lists use the | character as a name separator.

; Bucket names can only use the characters abcdefghijklmnopqrstuvwxyz_-0123456789
; (any names which contain invalid characters will be ignored by the installer)

; Empty lists ("") are allowed (but are not very user-friendly)

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_DEFAULT_BUCKETS  "spam|personal|work|other"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_SUGGESTED_NAMES  "admin|business|computers|family|financial|general|hobby|inbox|junk|list-admin|miscellaneous|not_spam|other|personal|recreation|school|security|shopping|spam|travel|work"

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

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_1         "${IO_NL}·«  ÊÃœ «·Õ«Ã… ·≈÷«›… œ·«¡ √Œ—Ï"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_2         "${IO_NL}ÌÃ»  ⁄—Ì› ⁄·Ï «·√ﬁ· œ·ÊÌ‰ ≈À‰Ì‰"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_3         "${IO_NL}Ì·“„ ⁄·Ï «·√ﬁ· œ·Ê ¬Œ—"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_4         "${IO_NL}·« Ì” ÿÌ⁄ «·„‰’¯» √ﬂÀ— „‰"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_5         "œ·«¡"

; Message box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_1       "œ·Ê „”„Ï"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_2       " „  ⁄—Ì›Â „”»ﬁ«."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_3       "«·—Ã«¡ ≈Œ Ì«— ≈”„ ¬Œ— ··œ·Ê «·ÃœÌœ."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_1       "Ì” ÿÌ⁄ «·„‰’¯» ≈‰‘«¡ ⁄·Ï «·√ﬂÀ—"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_2       "œ·«¡."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_3       "»⁄œ  ‰’Ì» POPFile  ” ÿÌ⁄ ≈÷«›… √ﬂÀ— „‰"

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_1       "«·≈”„"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_2       "€Ì— ’«·Õ ﬂ≈”„ œ·Ê."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_3       "√”«„Ì «·œ·«¡  ” ÿÌ⁄ √‰  Õ ÊÌ ›ﬁÿ √Õ—› „‰ a ≈·Ï z »«·‰„ÿ «·’€Ì—° √—ﬁ«„ 0 ≈·Ï 9° »«·≈÷«›… «·Ï - Ê _"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_4       "«·—Ã«¡ ≈Œ Ì«— ≈”„ ¬Œ— ··œ·Ê «·ÃœÌœ."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_1      "ÌÕ «Ã POPFile ≈·Ï œ·ÊÌ‰ √À‰Ì‰ ⁄·Ï «·≈ﬁ· ﬁ»· √‰ Ì „ﬂ‰ „‰  ’‰Ì› «·»—Ìœ."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_2      "«·—Ã«¡ ≈œŒ«· ≈”„ ·œ·Ê ··≈‰‘«¡°${MB_NL}${MB_NL}≈„« »≈Œ Ì«— ≈”„ „ﬁ —Õ „‰ «··«∆Õ…${MB_NL}${MB_NL}√Ê »ﬂ «»… ≈”„ „‰ ≈Œ Ì«—ﬂ."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_3      "ÌÃ»  ⁄—Ì› œ·ÊÌ‰ ⁄·Ï «·√ﬁ· ﬁ»· «·„ «»⁄… ›Ì  ‰’Ì» POPFile."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_1         "ÂÊ ⁄œœ «·œ·«¡ «·„⁄—›… · ” ⁄„· »Ê«”ÿ… POPFile."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_2         "Â·  —Ìœ ≈⁄œ«œ POPFile ·Ì” ⁄„· Â–Â «·œ·«¡ø"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_3         "≈÷€ÿ '·«' ≈–« ﬂ‰   —Ìœ  €ÌÌ— ≈Œ Ì«—«  «·œ·«¡."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_1       "·„ Ì” ÿ⁄ «·„‰’¯» ≈‰‘«¡"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_2       "„‰"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_3       "«·œ·«¡ «· Ì ≈Œ — Â«."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_4       "»⁄œ  ‰’Ì» POPFile  ” ÿÌ⁄ ≈” ⁄„«· 'Ê«ÃÂ… «·„” Œœ„'${MB_NL}${MB_NL} Ê·ÊÕ… «· Õﬂ„ ·≈‰‘«¡ «·œ·«¡ «·‰«ﬁ’…."

#--------------------------------------------------------------------------
# Custom Page - Email Client Reconfiguration
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_TITLE        "≈⁄œ«œ«  »—«„Ã «·»—Ìœ"
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_SUBTITLE     "Ì” ÿÌ⁄ POPFile ≈⁄œ«œ ⁄œœ „‰ »—«„Ã «·»—Ìœ ‰Ì«»… ⁄‰ﬂ"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_TEXT_1    "»—«„Ã «·»—Ìœ «·„⁄·¯„… »Ê«”ÿ… (*) Ì„ﬂ‰ ≈⁄œ«œÂ« »‘ﬂ·  ·ﬁ«∆Ì° ≈› —«÷« »√‰ «·Õ”«»«  «·„” ⁄„·… »”Ìÿ….${IO_NL}${IO_NL}„‰ «·√›÷· √‰ Ì „ ≈⁄œ«œ «·Õ”«»«  «· Ì  ” ⁄„· «·„’«œﬁ… «·¬„‰… »‘ﬂ· ÌœÊÌ."
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_TEXT_2    "„Â„: «·—Ã«¡ ≈€·«ﬁ »—«„Ã «·»—Ìœ «·„—«œ ≈⁄œ«œÂ« »‘ﬂ·  ·ﬁ«∆Ì «·¬‰${IO_NL}${IO_NL}Â–Â «·„Ì“… ·«  “«· ﬁÌœ «· ÿÊÌ— („À«·: »⁄÷ Õ”«»«  Outlook ·« Ì „ ≈ﬂ ‘«›Â« √ÕÌ«‰«).${IO_NL}${IO_NL}«·—Ã«¡ ›Õ’ √‰ «·≈⁄œ«œ«   „¯  »‘ﬂ· ’ÕÌÕ (ﬁ»· ≈” ⁄„«· »—‰«„Ã «·»—Ìœ)."

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_CANCEL    " „ ≈·€«¡ ⁄„·Ì… ≈⁄œ«œ »—‰«„Ã «·»—Ìœ „‰ ﬁ»· «·„” Œœ„"

#--------------------------------------------------------------------------
# Text used on buttons to skip configuration of email clients
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_SKIPALL   " ŒÿÏ «·ﬂ·"
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_SKIPONE   " ŒÿÏ «·»—‰«„Ã"

#--------------------------------------------------------------------------
# Message box warnings that an email client is still running
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_EXP         " Õ–Ì—: ÌŸÂ— √‰ Outlook Express „« “«· Ì⁄„· !"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_OUT         " Õ–Ì—: ÌŸÂ— √‰ Outlook „« “«· Ì⁄„· !"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_EUD         " Õ–Ì—: ÌŸÂ— √‰ Eudora „« “«· Ì⁄„· !"

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_1      "«·—Ã«¡ ≈€·«ﬁ »—‰«„Ã «·»—Ìœ Ê„‰ À„ «·÷€ÿ ⁄·Ï '√⁄œ «·„Õ«Ê·…' ·≈⁄œ«œÂ"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_2      "(Ì„ﬂ‰ «·÷€ÿ ⁄·Ï '≈Â„·' ·≈⁄œ«œÂ° Ê·ﬂ‰ Â–« €Ì— „›÷¯·)"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_3      "≈÷€ÿ ⁄·Ï '≈·€«¡' · ŒÿÌ ≈⁄œ«œ Â–« «·»—‰«„Ã"

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_4      "«·—Ã«¡ ≈€·«ﬁ »—‰«„Ã «·»—Ìœ Ê«·÷€ÿ ⁄·Ï '√⁄œ «·„Õ«Ê·…' ·≈⁄«œ… «·≈⁄œ«œ«  «·√’·Ì…"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_5      "(Ì„ﬂ‰ «·÷€ÿ ⁄·Ï '≈Â„·' ·≈⁄«œ… «·≈⁄œ«œ«  «·√’·Ì…° Ê·ﬂ‰ Â–« €Ì— „›÷¯·)"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_6      "≈÷€ÿ ⁄·Ï '≈·€«¡' · ŒÿÌ ≈⁄«œ… «·≈⁄œ«œ«  «·√’·Ì…"

#--------------------------------------------------------------------------
# Custom Page - Reconfigure Outlook/Outlook Express
#--------------------------------------------------------------------------

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

#--------------------------------------------------------------------------
# Custom Page - Reconfigure Eudora
#--------------------------------------------------------------------------

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

#--------------------------------------------------------------------------
# Custom Page - POPFile can now be started
#--------------------------------------------------------------------------

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

#--------------------------------------------------------------------------
# Standard MUI Page - Installation Page (for the 'Corpus Conversion Monitor' utility)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_MUTEX        "‰”Œ… √Œ—Ï „‰ 'Corpus Conversion Monitor'  ⁄„· „”»ﬁ« !"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_PRIVATE      "'Corpus Conversion Monitor' ⁄»«—… ⁄‰ ﬁ”„ „‰ „‰’¯» POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_NOFILE       "Œ··: „·›«   ÕÊÌ· „⁄·Ê„«  «·„œÊ¯‰… €Ì— „ÊÃÊœ… !"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_NOPOPFILE    "Œ··: ·„ Ì „ «·⁄ÀÊ— ⁄·Ï „”«— POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_ENVNOTSET    "Œ··: ·„ Ìﬂ‰ »«·≈„ﬂ«‰ ≈⁄œ«œ „ €Ì— »Ì∆… ⁄«„"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_NOKAKASI     "Œ··: ·„ Ì „ «·⁄ÀÊ— ⁄·Ï „”«— Kakasi"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_STARTERR     "·ﬁœ Õ’· Œ·· √À‰«¡  ‘€Ì· ⁄„·Ì…  ÕÊÌ· «·„œÊ¯‰…"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_FATALERR     "A fatal error occurred during the corpus conversion process !"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_ESTIMATE     "«·“„‰ «·„ »ﬁÌ: "
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_MINUTES      "œﬁ«∆ﬁ"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_WAITING      "(≈‰ Ÿ«—  ÕÊÌ· «·„·› «·√Ê·)"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_TOTALFILES   "Â‰«ﬂ $G_BUCKET_COUNT œ·«¡ ·Ì „  ÕÊÌ·Â«"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_PROGRESS_N   "»⁄œ $G_ELAPSED_TIME.$G_DECPLACES œﬁÌﬁ… Ì »ﬁÏ Â‰«ﬂ $G_STILL_TO_DO „·›«  ·· ÕÊÌ·"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_PROGRESS_1   "»⁄œ $G_ELAPSED_TIME.$G_DECPLACES œﬁÌﬁ… Ì»ﬁÏ Â‰«ﬂ „·› Ê«Õœ ·Ì „  ÕÊÌ·Â"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_SUMMARY      "≈” €—ﬁ  ⁄„·Ì…  ÕÊÌ· «·„œÊ¯‰… ≈·Ï $G_ELAPSED_TIME.$G_DECPLACES œﬁÌﬁ…"

#--------------------------------------------------------------------------
# Standard MUI Page - Uninstall POPFile
#--------------------------------------------------------------------------

; Uninstall Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_SHUTDOWN     "≈€·«ﬁ POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_SHORT        "Õ–› „œŒ·«  'ﬁ«∆„… «»œ√' «·Œ«’… »‹ˆPOPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_CORE         "Õ–› „·›«  POPFile «·√”«”Ì…..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_OUTEXPRESS   "≈⁄«œ… ≈⁄œ«œ«  Outlook Express..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_SKINS        "Õ–› „·›«  «·”„« ..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_PERL         "Õ–› „·›«  ‰”Œ… Perl «·„’€—…..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_OUTLOOK      "≈⁄«œ… ≈⁄œ«œ Outlook..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_EUDORA       "≈⁄«œ… ≈⁄œ«œ Eudora..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_DBMSGDIR     "Deleting corpus and 'Recent Messages' directory..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_EXESTATUS    "Checking program status..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_CONFIG       "Deleting configuration data..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_REGISTRY     "Deleting POPFile registry entries..."

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

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBDIFFUSER_1      "ÌÕ«Ê· '$G_WINUSERNAME' Õ–› „⁄·Ê„«   «»⁄… ·„” Œœ„ ¬Œ—"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBNOTFOUND_1      "·« ÌŸÂ— «‰ POPFile „‰’¯» ›Ì ›Ì «·„Ã·œ"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBNOTFOUND_2      "«·„ «»⁄… »ﬂ· «·√ÕÊ«· (€Ì— „›÷¯·)ø"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_ABORT_1           "≈·€«¡ ⁄„·Ì… «·≈“«·… „‰ ﬁˆ»· «·„” Œœ„"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_1        "„‘ﬂ·… 'Outlook Express' !"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_2        "„‘ﬂ·… 'Outlook' !"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_3        "„‘ﬂ·… 'Eudora' !"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBEMAIL_1         "·„  ﬂ‰ Â‰«ﬂ «·≈„ﬂ«‰Ì… ·≈⁄«œ… »⁄÷ «·≈⁄œ«œ«  «·√’·Ì…"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBEMAIL_2         "⁄—÷  ﬁ—Ì— «·√Œÿ«¡ ø"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_1         "»⁄÷ ≈⁄œ«œ«  »—‰«„Ã «·»—Ìœ ·„   „ ≈⁄«œ Â« ≈·Ï Õ«· Â« «·√’·Ì… !"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_2         "(Ì„ﬂ‰ ≈ÌÃ«œ «· ›«’Ì· ›Ì «·„Ã·œ $INSTDIR)"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_3         "≈÷€ÿ '·«' ·≈Â„«· Â–Â «·√Œÿ«¡ ÊÕ–› ﬂ· ‘Ì¡"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_4         "≈÷€ÿ '‰⁄„' ··„Õ«›Ÿ… ⁄·Ï Â–Â «·„⁄·Ê„«  (··”„«Õ ·„Õ«Ê·… √Œ—Ï ·«Õﬁ«)"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMDIR_1        "Â·  —Ìœ Õ–› ﬂ· «·„·›«  ›Ì „Ã·œ POPFileø${MB_NL}${MB_NL}$G_ROOTDIR${MB_NL}${MB_NL}(≈–« ﬂ«‰ Â‰«ﬂ √‘Ì«¡  Õ «ÃÂ«° ≈÷€ÿ ·«)"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMDIR_2        "Â·  —Ìœ Õ–› ﬂ· «·„·›«  ›Ì „Ã·œ '„⁄·Ê„«  «·„” Œœ„' «·Œ«’ »‹ˆPOPFileø${MB_NL}${MB_NL}$G_USERDIR${MB_NL}${MB_NL}(≈–« ﬂ«‰ Â‰«ﬂ √‘Ì«¡  Õ «ÃÂ«° ≈÷€ÿ ·«)"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBDELMSGS_1       "Do you want to remove all files in your 'Recent Messages' directory?"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMERR_1        "„·«ÕŸ…"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMERR_2        "·„ Ìﬂ‰ »«·≈„ﬂ«‰ Õ–›Â."

#--------------------------------------------------------------------------
# Mark the end of the language data
#--------------------------------------------------------------------------

!undef PFI_LANG

#--------------------------------------------------------------------------
# End of 'Arabic-pfi.nsh'
#--------------------------------------------------------------------------
