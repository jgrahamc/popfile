#--------------------------------------------------------------------------
# Russian-pfi.nsh
#
# This file contains additional "Russian" text strings used by the Windows installer
# for POPFile (these strings are unique to POPFile).
#
# See 'Russian-mui.nsh' for the strings which modify standard NSIS MUI messages.
#
# These strings are grouped according to the page/window where they are used
#
# Copyright (c) 2001-2003 John Graham-Cumming
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

!define PFI_LANG  "RUSSIAN"

#--------------------------------------------------------------------------
# Startup message box offering to display the Release Notes
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_1        "Display POPFile Release Notes ?"
!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_2        "'Yes' recommended if you are upgrading POPFile (you may need to backup BEFORE upgrading)"

#--------------------------------------------------------------------------
# Standard MUI Page - Choose Components
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING DESC_SecPOPFile              "Installs the core files needed by POPFile, including a minimal version of Perl."
!insertmacro PFI_LANG_STRING DESC_SecSkins                "Installs POPFile skins that allow you to change the look and feel of the POPFile user interface."
!insertmacro PFI_LANG_STRING DESC_SecLangs                "Installs non-English language versions of the POPFile UI."

#--------------------------------------------------------------------------
# Custom Page - POPFile Installation Options
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_TITLE       "POPFile Installation Options"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_SUBTITLE    "Leave these options unchanged unless you need to change them"

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_POP3     "Choose the default port number for POP3 connections (110 recommended)"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_GUI      "Choose the default port for 'User Interface' connections (8080 recommended)"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_STARTUP  "Run POPFile automatically when Windows starts (runs in background)"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_WARNING  "IMPORTANT WARNING"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_MESSAGE  "IF UPGRADING POPFILE --- INSTALLER WILL SHUTDOWN EXISTING VERSION"

; Message Boxes used when validating user's selections

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBUNINST_1    "Previous installation found at"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBUNINST_2    "Do you want to uninstall it ?"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBUNINST_3    "'Yes' recommended"

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_1    "The POP3 port cannot be set to"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_2    "The port must be a number in the range 1 to 65535."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_3    "Please change your POP3 port selection."

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_1     "The 'User Interface' port cannot be set to"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_2     "The port must be a number in the range 1 to 65535."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_3     "Please change your 'User Interface' port selection."

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_1    "The POP3 port must be different from the 'User Interface' port."
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_2    "Please change your port selections."

; Banner message displayed whilst uninstalling old version

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_BANNER_1     "Removing previous version"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_BANNER_2     "This may take a few seconds..."

#--------------------------------------------------------------------------
# Standard MUI Page - Installing POPfile
#--------------------------------------------------------------------------

; Installation Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_UPGRADE   "Checking if this is an upgrade installation..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_CORE      "Installing POPFile core files..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_PERL      "Installing minimal Perl files..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SHORT     "Creating POPFile shortcuts..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SKINS     "Installing POPFile skin files..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_LANGS     "Installing POPFile UI language files..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_ENDSEC    "Íàæìèòå Äàëåå äëÿ ïðîäîëæåíèÿ óñòàíîâêè."

; Installation Log Messages

!insertmacro PFI_LANG_STRING PFI_LANG_INST_LOG_1          "Shutting down previous version of POPFile using port"

; Message Box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_1          "file from previous installation found."
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_2          "OK to update this file ?"
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_3          "Click 'Yes' to update it (old file will be saved as"
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_4          "Click 'No' to keep the old file (new file will saved as"

!insertmacro PFI_LANG_STRING PFI_LANG_MBCFGBK_1           "Backup copy of"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCFGBK_2           "already exists"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCFGBK_3           "OK to overwrite this file?"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCFGBK_4           "Click 'Yes' to overwrite, click 'No' to skip making a backup copy"

#--------------------------------------------------------------------------
# Custom Page - POPFile Classification Bucket Creation
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_TITLE           "POPFile Classification Bucket Creation"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_SUBTITLE        "POPFile needs AT LEAST TWO buckets in order to be able to classify your email"

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_INTRO        "After installation, POPFile makes it easy to change the number of buckets (and their names) to suit your needs.\r\n\r\nBucket names must be single words, using lowercase letters, digits 0 to 9, hyphens and underscores."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_CREATE       "Create a new bucket by either selecting a name from the list below or typing a name of your own choice."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_DELETE       "To delete one or more buckets from the list, tick the relevant 'Remove' box(es) then click the 'Continue' button."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_LISTHDR      "Buckets to be used by POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_REMOVE       "õÄÁÌÉÔØ"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_CONTINUE     "Continue"

; Text strings used for status messages under the bucket list

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_1        "There is no need to add more buckets"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_2        "You must define AT LEAST TWO buckets"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_3        "At least one more bucket is required"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_4        "Installer cannot create more than"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_5        "buckets"

; Message box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_1      "A bucket called"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_2      "has already been defined."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_3      "Please choose a different name for the new bucket."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_1      "The installer can only create up to"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_2      "buckets."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_3      "Once POPFile has been installed you can create more than"

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_1      "The name"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_2      "is not a valid name for a bucket."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_3      "îÁÚ×ÁÎÉÅ ×ÅÄÒÁ ÍÏÖÅÔ ÓÏÓÔÏÑÔØ ÉÚ ÓÔÒÏÞÎÙÈÌÁÔÉÎÓËÉÈ ÂÕË× ÏÔ 'a' ÄÏ 'z' É ÚÎÁËÏ× - É _"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_4      "Please choose a different name for the new bucket."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_1     "POPFile requires AT LEAST TWO buckets before it can classify your email."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_2     "Please enter the name of a bucket to be created,$\r$\n$\r$\neither by picking a suggested name from the drop-down list$\r$\n$\r$\nor by typing in a name of your own choice."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_3     "You must define AT LEAST TWO buckets before continuing with the installation of POPFile."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_1        "buckets have been defined for use by POPFile."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_2        "Do you want to configure POPFile to use these buckets?"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_3        "Click 'No' if you wish to change your bucket selections."

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_1      "The installer was unable to create"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_2      "of the"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_3      "buckets you selected."
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_4      "Once POPFile has been installed you can use its 'User Interface'$\r$\n$\r$\ncontrol panel to create the missing bucket(s)."

#--------------------------------------------------------------------------
# Custom Page - Reconfigure Outlook Express
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_TITLE         "Reconfigure Outlook Express"
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_SUBTITLE      "POPFile can reconfigure Outlook Express for you"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_INTRO      "POPFile has detected the following Outlook Express email account and can automatically configure it to work with POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_CHECKBOX   "Reconfigure this account to work with POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_EMAIL      "Email address:"
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_SERVER     "POP3 server:"
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_USERNAME   "POP3 username:"
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_RESTORE    "If you uninstall POPFile the original settings will be restored"

!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_LINK_1     "account for the"
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_LINK_2     "identity"

#--------------------------------------------------------------------------
# Custom Page - POPFile can now be started
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_TITLE        "POPFile can now be started"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_SUBTITLE     "The POPFile User Interface only works if POPFile has been started"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_INTRO     "Start POPFile now ?"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NO        "No (the 'User Interface' cannot be used if POPFile is not started)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_DOSBOX    "Run POPFile (in a window)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_BCKGRND   "Run POPFile in background (no window displayed)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_1    "Once POPFile has been started, you can display the 'User Interface' by"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_2    "(a) double-clicking the POPFile icon in the system tray,   OR"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_3    "(b) using Start --> Programs --> POPFile --> POPFile User Interface."

; Banner message displayed whilst waiting for POPFile to start

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_BANNER_1     "Preparing to start POPFile."
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_BANNER_2     "This may take a few seconds..."

#--------------------------------------------------------------------------
# Standard MUI Page - Uninstall POPFile
#--------------------------------------------------------------------------

; Uninstall Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_UNSTRING PFI_LANG_PROGRESS_1        "Shutting down POPFile..."
!insertmacro PFI_LANG_UNSTRING PFI_LANG_PROGRESS_2        "Deleting 'Start Menu' entries for POPFile..."
!insertmacro PFI_LANG_UNSTRING PFI_LANG_PROGRESS_3        "Deleting POPFile core files..."
!insertmacro PFI_LANG_UNSTRING PFI_LANG_PROGRESS_4        "Restoring Outlook Express settings..."
!insertmacro PFI_LANG_UNSTRING PFI_LANG_PROGRESS_5        "Deleting POPFile skins files..."
!insertmacro PFI_LANG_UNSTRING PFI_LANG_PROGRESS_6        "Deleting minimal Perl files..."

; Uninstall Log Messages

!insertmacro PFI_LANG_UNSTRING PFI_LANG_LOG_1             "Shutting down POPFile using port"
!insertmacro PFI_LANG_UNSTRING PFI_LANG_LOG_2             "Opened"
!insertmacro PFI_LANG_UNSTRING PFI_LANG_LOG_3             "Restored"
!insertmacro PFI_LANG_UNSTRING PFI_LANG_LOG_4             "Closed"
!insertmacro PFI_LANG_UNSTRING PFI_LANG_LOG_5             "Removing all files from POPFile directory"
!insertmacro PFI_LANG_UNSTRING PFI_LANG_LOG_6             "Note: unable to remove all files from POPFile directory"

; Message Box text strings

!insertmacro PFI_LANG_UNSTRING PFI_LANG_MBNOTFOUND_1      "It does not appear that POPFile is installed in the directory"
!insertmacro PFI_LANG_UNSTRING PFI_LANG_MBNOTFOUND_2      "Continue anyway (not recommended) ?"

!insertmacro PFI_LANG_UNSTRING PFI_LANG_ABORT_1           "Uninstall aborted by user"

!insertmacro PFI_LANG_UNSTRING PFI_LANG_MBREMDIR_1        "Do you want to remove all files in your POPFile directory?$\r$\n$\r$\n(If you have anything you created that you want to keep, click No)"

!insertmacro PFI_LANG_UNSTRING PFI_LANG_MBREMERR_1        "Note"
!insertmacro PFI_LANG_UNSTRING PFI_LANG_MBREMERR_2        "could not be removed."

#--------------------------------------------------------------------------
# Mark the end of the language data
#--------------------------------------------------------------------------

!undef PFI_LANG

#--------------------------------------------------------------------------
# End of 'Russian-pfi.nsh'
#--------------------------------------------------------------------------
