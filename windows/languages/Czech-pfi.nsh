#--------------------------------------------------------------------------
# Czech-pfi.nsh
#
# This file contains the "Czech" text strings used by the Windows installer
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
# Translation created by: (nobody)
# Translation updated by: (nobody)
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

!define PFI_LANG  "CZECH"

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

!insertmacro PFI_LANG_STRING PFI_LANG_WELCOME_INFO_TEXT    "Chystáte se nainstalovat POPFile na svùj poèítaè.\r\n\r\nPøed zaèátkem instalace je doporuèeno zavøít všechny ostatní aplikace.\r\n\r\n$_CLICK"
!insertmacro PFI_LANG_STRING PFI_LANG_WELCOME_ADMIN_TEXT   "IMPORTANT NOTICE:\r\n\r\nThe current user does NOT have 'Administrator' rights.\r\n\r\nIf multi-user support is required, it is recommended that you cancel this installation and use an 'Administrator' account to install POPFile."

#--------------------------------------------------------------------------
# Standard MUI Page - Directory Page (for the main POPFile installer)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_ROOTDIR_TITLE        "Choose Program Files Install Location"
!insertmacro PFI_LANG_STRING PFI_LANG_ROOTDIR_TEXT_DESTN   "Destination Folder for the POPFile Program"

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

!insertmacro PFI_LANG_STRING PFI_LANG_FINISH_RUN_TEXT      "POPFile Uživatelské rozhraní"


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Used by 'Monitor Corpus Conversion' utility (main script: MonitorCC.nsi)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#--------------------------------------------------------------------------
# Standard MUI Page - Installation Page (for the 'Monitor Corpus Conversion' utility)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_TITLE        "POPFile Corpus Conversion"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_SUBTITLE     "The existing corpus must be converted to work with this version of POPFile"

!insertmacro PFI_LANG_STRING PFI_LANG_ENDCONVERT_TITLE     "POPFile Corpus Conversion Completed"
!insertmacro PFI_LANG_STRING PFI_LANG_ENDCONVERT_SUBTITLE  "Please click Close to continue"

!insertmacro PFI_LANG_STRING PFI_LANG_BADCONVERT_TITLE     "POPFile Corpus Conversion Failed"
!insertmacro PFI_LANG_STRING PFI_LANG_BADCONVERT_SUBTITLE  "Please click Cancel to continue"


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Used by 'Add POPFile User' wizard (main script: adduser.nsi)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#--------------------------------------------------------------------------
# Standard MUI Page - Welcome (for the 'Add POPFile User' wizard)
#
# The sequence \r\n\r\n inserts a blank line (note that the PFI_LANG_ADDUSER_INFO_TEXT string
# should end with a \r\n\r\n$_CLICK sequence).
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_INFO_TEXT    "This wizard will guide you through the configuration of POPFile for the '$G_WINUSERNAME' user.\r\n\r\nIt is recommended that you close all other applications before continuing.\r\n\r\n$_CLICK"

#--------------------------------------------------------------------------
# Standard MUI Page - Directory Page (for the 'Add POPFile User' wizard)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_TITLE        "Choose POPFile Data Location for '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_SUBTITLE     "Choose the folder in which to store the POPFile Data for '$G_WINUSERNAME'"
!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_TEXT_TOP     "This version of POPFile uses separate sets of data files for each user.$\r$\n$\r$\nSetup will use the following folder for the POPFile data belonging to the '$G_WINUSERNAME' user. To use a different folder for this user, click Browse and select another folder. $_CLICK"
!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_TEXT_DESTN   "Folder to be used to store the POPFile data for '$G_WINUSERNAME'"

#--------------------------------------------------------------------------
# Standard MUI Page - Installation Page (for the 'Add POPFile User' wizard)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_TITLE        "Configuring POPFile for '$G_WINUSERNAME' user"
!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_SUBTITLE     "Please wait while the POPFile configuration files are updated for this user"

#--------------------------------------------------------------------------
# Standard MUI Page - Finish (for the 'Add POPFile User' wizard)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_FINISH_INFO "POPFile has been configured for the '$G_WINUSERNAME' user.\r\n\r\nClick Finish to close this wizard."

#--------------------------------------------------------------------------
# Standard MUI Page - Uninstall Confirmation Page (for the 'Add POPFile User' wizard)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_REMUSER_TITLE        "Uninstall POPFile data for '$G_WINUSERNAME' user"
!insertmacro PFI_LANG_STRING PFI_LANG_REMUSER_SUBTITLE     "Remove POPFile configuration data for this user from your computer"

!insertmacro PFI_LANG_STRING PFI_LANG_REMUSER_TEXT_TOP     "The POPFile configuration data for the '$G_WINUSERNAME' user will be uninstalled from the following folder. $_CLICK"

#--------------------------------------------------------------------------
# Standard MUI Page - Uninstallation Page (for the 'Add POPFile User' wizard)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_REMOVING_TITLE       "Uninstalling POPFile data for '$G_WINUSERNAME' user"
!insertmacro PFI_LANG_STRING PFI_LANG_REMOVING_SUBTITLE    "Please wait while the POPFile configuration files for this user are deleted"


#==========================================================================
# Strings used for custom pages, message boxes and banners
#==========================================================================

#--------------------------------------------------------------------------
# General purpose banner text (also suitable for page titles/subtitles)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_BE_PATIENT           "Please be patient."
!insertmacro PFI_LANG_STRING PFI_LANG_TAKE_A_FEW_SECONDS   "This may take a few seconds..."

#--------------------------------------------------------------------------
# Message displayed when 'Add User' does not seem to be part of the current version
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_COMPAT_NOTFOUND      "Error: Compatible version of ${C_PFI_PRODUCT} not found !"

#--------------------------------------------------------------------------
# Message displayed when installer exits because another copy is running
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_INSTALLER_MUTEX      "Another copy of the POPFile installer is already running !"

#--------------------------------------------------------------------------
# Message box warning that a previous installation has been found
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_1   "Previous installation found at"
!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_2   "Do you want to upgrade it ?"
!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_3   "Previous configuration data found at"

#--------------------------------------------------------------------------
# Startup message box offering to display the Release Notes
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_1         "Display POPFile Release Notes ?"
!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_2         "'Yes' recommended if you are upgrading POPFile (you may need to backup BEFORE upgrading)"

#--------------------------------------------------------------------------
# Custom Page - Check Perl Requirements
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_TITLE        "Out-of-date System Components Detected"

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_1    "The default browser is used to display the POPFile User Interface (its control centre).\r\n\r\n"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_2    "POPFile does not require a specific browser, it will work with almost any browser.\r\n\r\n"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_3    "A minimal version of Perl is about to be installed (POPFile is written in Perl).\r\n\r\n"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_4    "The Perl supplied with POPFile makes use of some Internet Explorer components and requires Internet Explorer 5.5 (or a later version)."
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_5    "The installer has detected that this system has Internet Explorer"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_6    "It is possible that some features of POPFile may not work properly on this system.\r\n\r\n"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_7    "If you have any problems with POPFile, an upgrade to a newer version of Internet Explorer may help."

#--------------------------------------------------------------------------
# Standard MUI Page - Choose Components
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING DESC_SecPOPFile               "Installs the core files needed by POPFile, including a minimal version of Perl."
!insertmacro PFI_LANG_STRING DESC_SecSkins                 "Installs POPFile skins that allow you to change the look and feel of the POPFile user interface."
!insertmacro PFI_LANG_STRING DESC_SecLangs                 "Installs non-English language versions of the POPFile UI."
!insertmacro PFI_LANG_STRING DESC_SecXMLRPC                "Installs the POPFile XMLRPC module (for access to the POPFile API) and the Perl support it requires."

#--------------------------------------------------------------------------
# Custom Page - POPFile Installation Options
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_TITLE        "POPFile Installation Options"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_SUBTITLE     "Leave these options unchanged unless you need to change them"

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_POP3      "Choose the default port number for POP3 connections (110 recommended)"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_GUI       "Choose the default port for 'User Interface' connections (8080 recommended)"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_STARTUP   "Run POPFile automatically when Windows starts"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_WARNING   "IMPORTANT WARNING"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_MESSAGE   "IF UPGRADING POPFILE --- INSTALLER WILL SHUTDOWN EXISTING VERSION"

; Message Boxes used when validating user's selections

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_1     "The POP3 port cannot be set to"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_2     "The port must be a number in the range 1 to 65535."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_3     "Please change your POP3 port selection."

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_1      "The 'User Interface' port cannot be set to"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_2      "The port must be a number in the range 1 to 65535."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_3      "Please change your 'User Interface' port selection."

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_1     "The POP3 port must be different from the 'User Interface' port."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_2     "Please change your port selections."

#--------------------------------------------------------------------------
# Standard MUI Page - Installing POPfile
#--------------------------------------------------------------------------

; Installation Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_UPGRADE    "Checking if this is an upgrade installation..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_CORE       "Installing POPFile core files..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_PERL       "Installing minimal Perl files..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SHORT      "Creating POPFile shortcuts..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_CORPUS     "Making corpus backup. This may take a few seconds..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SKINS      "Installing POPFile skin files..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_LANGS      "Installing POPFile UI language files..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_XMLRPC     "Installing POPFile XMLRPC files..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_ENDSEC     "Kliknìte na Další pro pokraèování"

; Installation Log Messages

!insertmacro PFI_LANG_STRING PFI_LANG_INST_LOG_SHUTDOWN    "Shutting down previous version of POPFile using port"

; Message Box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_1           "file from previous installation found."
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_2           "OK to update this file ?"
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_3           "Click 'Yes' to update it (old file will be saved as"
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_4           "Click 'No' to keep the old file (new file will saved as"

!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_1          "Unable to shutdown POPFile automatically."
!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_2          "Please shutdown POPFile manually now."
!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_3          "When POPFile has been shutdown, click 'OK' to continue."

!insertmacro PFI_LANG_STRING PFI_LANG_MBCORPUS_1           "Error detected when the installer tried to backup the old corpus."

#--------------------------------------------------------------------------
# Custom Page - POPFile Classification Bucket Creation
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_TITLE            "POPFile Classification Bucket Creation"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_SUBTITLE         "POPFile needs AT LEAST TWO buckets in order to be able to classify your email"

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_INTRO         "After installation, POPFile makes it easy to change the number of buckets (and their names) to suit your needs.\r\n\r\nBucket names must be single words, using lowercase letters, digits 0 to 9, hyphens and underscores."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_CREATE        "Create a new bucket by either selecting a name from the list below or typing a name of your own choice."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_DELETE        "To delete one or more buckets from the list, tick the relevant 'Remove' box(es) then click the 'Continue' button."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_LISTHDR       "Buckets to be used by POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_REMOVE        "Odstranit"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_CONTINUE      "Continue"

; Text strings used for status messages under the bucket list

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_1         "There is no need to add more buckets"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_2         "You must define AT LEAST TWO buckets"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_3         "At least one more bucket is required"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_4         "Installer cannot create more than"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_5         "buckets"

; Message box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_1       "A bucket called"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_2       "has already been defined."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_3       "Please choose a different name for the new bucket."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_1       "The installer can only create up to"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_2       "buckets."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_3       "Once POPFile has been installed you can create more than"

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_1       "The name"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_2       "is not a valid name for a bucket."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_3       "Názvy košù mùžou obsahovat jen znaky od a do z (malé písmo) plus - a _"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_4       "Please choose a different name for the new bucket."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_1      "POPFile requires AT LEAST TWO buckets before it can classify your email."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_2      "Please enter the name of a bucket to be created,$\r$\n$\r$\neither by picking a suggested name from the drop-down list$\r$\n$\r$\nor by typing in a name of your own choice."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_3      "You must define AT LEAST TWO buckets before continuing with the installation of POPFile."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_1         "buckets have been defined for use by POPFile."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_2         "Do you want to configure POPFile to use these buckets?"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_3         "Click 'No' if you wish to change your bucket selections."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_1       "The installer was unable to create"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_2       "of the"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_3       "buckets you selected."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_4       "Once POPFile has been installed you can use its 'User Interface'$\r$\n$\r$\ncontrol panel to create the missing bucket(s)."

#--------------------------------------------------------------------------
# Custom Page - Email Client Reconfiguration
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_TITLE        "Email Client Configuration"
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_SUBTITLE     "POPFile can reconfigure several email clients for you"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_TEXT_1    "Mail clients marked (*) can be reconfigured automatically, assuming simple accounts are used.\r\n\r\nIt is strongly recommended that accounts which require authentication are configured manually."
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_TEXT_2    "IMPORTANT: PLEASE SHUT DOWN THE RECONFIGURABLE EMAIL CLIENTS NOW\r\n\r\nThis feature is still under development (e.g. some Outlook accounts may not be detected).\r\n\r\nPlease check that the reconfiguration was successful (before using the email client)."

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_CANCEL    "Email client reconfiguration cancelled by user"

#--------------------------------------------------------------------------
# Text used on buttons to skip configuration of email clients
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_SKIPALL   "Skip All"
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_SKIPONE   "Skip Client"

#--------------------------------------------------------------------------
# Message box warnings that an email client is still running
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_EXP         "WARNING: Outlook Express appears to be running !"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_OUT         "WARNING: Outlook appears to be running !"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_EUD         "WARNING: Eudora appears to be running !"

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_1      "Please SHUT DOWN the email program then click 'Retry' to reconfigure it"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_2      "(You can click 'Ignore' to reconfigure it, but this is not recommended)"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_3      "Click 'Abort' to skip the reconfiguration of this email program"

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_4      "Please SHUT DOWN the email program then click 'Retry' to restore the settings"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_5      "(You can click 'Ignore' to restore the settings, but this is not recommended)"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_6      "Click 'Abort' to skip the restoring of the original settings"

#--------------------------------------------------------------------------
# Custom Page - Reconfigure Outlook/Outlook Express
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_TITLE         "Reconfigure Outlook Express"
!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_SUBTITLE      "POPFile can reconfigure Outlook Express for you"

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
# Custom Page - Reconfigure Eudora
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_TITLE          "Reconfigure Eudora"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_SUBTITLE       "POPFile can reconfigure Eudora for you"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_CANCELLED   "Eudora reconfiguration cancelled by user"

!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_INTRO_1     "POPFile has detected the following Eudora personality"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_INTRO_2     " and can automatically configure it to work with POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_CHECKBOX    "Reconfigure this personality to work with POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_DOMINANT    "<Dominant> personality"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_PERSONA     "personality"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_EMAIL       "Email address:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_SERVER      "POP3 server:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_USERNAME    "POP3 username:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_POP3PORT    "POP3 port:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_RESTORE     "If you uninstall POPFile the original settings will be restored"

#--------------------------------------------------------------------------
# Custom Page - POPFile can now be started
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_TITLE         "POPFile can now be started"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_SUBTITLE      "The POPFile User Interface only works if POPFile has been started"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_INTRO      "Start POPFile now ?"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NO         "No (the 'User Interface' cannot be used if POPFile is not started)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_DOSBOX     "Run POPFile (in a window)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_BCKGRND    "Run POPFile in background (no window displayed)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_1     "Once POPFile has been started, you can display the 'User Interface' by"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_2     "(a) double-clicking the POPFile icon in the system tray,   OR"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_3     "(b) using Start --> Programs --> POPFile --> POPFile User Interface."

; Banner message displayed whilst waiting for POPFile to start

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_BANNER_1      "Preparing to start POPFile."
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_BANNER_2      "This may take a few seconds..."

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
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_FATALERR     "A fatal error occurred during the corpus conversion process !"
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

!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_SHUTDOWN     "Shutting down POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_SHORT        "Deleting 'Start Menu' entries for POPFile..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_CORE         "Deleting POPFile core files..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_OUTEXPRESS   "Restoring Outlook Express settings..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_SKINS        "Deleting POPFile skins files..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_PERL         "Deleting minimal Perl files..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_OUTLOOK      "Restoring Outlook settings..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_EUDORA       "Restoring Eudora settings..."

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

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBDIFFUSER_1      "'$G_WINUSERNAME' is attempting to remove data belonging to another user"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBNOTFOUND_1      "It does not appear that POPFile is installed in the directory"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBNOTFOUND_2      "Continue anyway (not recommended) ?"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_ABORT_1           "Uninstall aborted by user"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_1        "'Outlook Express' problem !"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_2        "'Outlook' problem !"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_3        "'Eudora' problem !"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBEMAIL_1         "Unable to restore some original settings"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBEMAIL_2         "Display the error report ?"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_1         "Some email client settings have not been restored !"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_2         "(Details can be found in $INSTDIR folder)"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_3         "Click 'No' to ignore these errors and delete everything"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_4         "Click 'Yes' to keep this data (to allow another attempt later)"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMDIR_1        "Do you want to remove all files in your POPFile directory?$\r$\n$\r$\n(If you have anything you created that you want to keep, click No)"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMDIR_2        "Do you want to remove all files in your POPFile 'User Data' directory?$\r$\n$\r$\n(If you have anything you created that you want to keep, click No)"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMERR_1        "Note"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMERR_2        "could not be removed."

#--------------------------------------------------------------------------
# Mark the end of the language data
#--------------------------------------------------------------------------

!undef PFI_LANG

#--------------------------------------------------------------------------
# End of 'Czech-pfi.nsh'
#--------------------------------------------------------------------------
