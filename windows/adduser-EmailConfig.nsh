#--------------------------------------------------------------------------
#
# adduser-EmailConfig.nsh --- This 'include' file contains all of the custom page and other
#                             functions used by the 'Add POPFile User' wizard (adduser.nsi)
#                             when offering to reconfigure email accounts.
#
# Copyright (c) 2005 John Graham-Cumming
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
#  The 'adduser.nsi' script file contains the following code:
#
#     #==========================================================================
#     #==========================================================================
#     #  A separate file contains the custom page and other functions used when
#     #  offering to reconfigure email accounts (Outlook Express, Outlook and
#     #  Eudora are supported in this version of the 'Add POPFile User' wizard)
#     #==========================================================================
#     #==========================================================================
#
#       !include "adduser-EmailConfig.nsh"
#
#     #==========================================================================
#     #==========================================================================
#
#--------------------------------------------------------------------------


#--------------------------------------------------------------------------
# Installer Function: SetEmailClientPage_Init
#
# This function adds language texts to the INI file used by "SetEmailClientPage" function
# (to make the custom page use the language selected by the user for the installer)
#--------------------------------------------------------------------------

Function SetEmailClientPage_Init

  ; Ensure custom page matches the selected language (left-to-right or right-to-left order)

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioF.ini" "Settings" "RTL" "$(^RTL)"

  ; We use the 'Back' button as an easy way to skip all the email client reconfiguration pages
  ; (but we still check if there are any old-style uninstall data files to be converted)

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioF.ini" \
              "Settings" "BackButtonText" "$(PFI_LANG_MAILCFG_IO_SKIPALL)"

  !insertmacro PFI_IO_TEXT "ioF.ini" "1" "$(PFI_LANG_MAILCFG_IO_TEXT_1)"
  !insertmacro PFI_IO_TEXT "ioF.ini" "3" "$(PFI_LANG_MAILCFG_IO_TEXT_2)"

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: SetEmailClientPage (generates a custom page)
#
# This function is used to introduce the reconfiguration of email clients
#--------------------------------------------------------------------------

Function SetEmailClientPage

  !define L_CLIENT_INDEX    $R9
  !define L_CLIENT_LIST     $R8
  !define L_CLIENT_NAME     $R7
  !define L_CLIENT_TYPE     $R6   ; used to indicate if client can be reconfigured by installer
  !define L_SEPARATOR       $R5
  !define L_TEMP            $R4

  Push ${L_CLIENT_INDEX}
  Push ${L_CLIENT_LIST}
  Push ${L_CLIENT_NAME}
  Push ${L_CLIENT_TYPE}
  Push ${L_SEPARATOR}
  Push ${L_TEMP}

  ; On older systems with several email clients, the email client scan can take a few seconds
  ; during which time the user may be tempted to click the 'Next' button which would result in
  ; the page showing the scan results being (in effect) skipped. The 'Next' button is disabled
  ; until the scan has finished to give the user a chance to read the results of the scan.

  Call ShowPleaseWaitBanner

  GetDlgItem $G_DLGITEM $HWNDPARENT 3     ; "Back" button
  EnableWindow $G_DLGITEM 0
  GetDlgItem $G_DLGITEM $HWNDPARENT 1     ; "Next" button
  EnableWindow $G_DLGITEM 0
  GetDlgItem $G_DLGITEM $HWNDPARENT 2     ; "Cancel" button
  EnableWindow $G_DLGITEM 0

  !insertmacro MUI_HEADER_TEXT "$(PFI_LANG_MAILCFG_TITLE)" "$(PFI_LANG_MAILCFG_SUBTITLE)"

  StrCpy ${L_CLIENT_INDEX} 0
  StrCpy ${L_CLIENT_LIST} ""
  StrCpy ${L_SEPARATOR} ""

read_next_name:
  EnumRegKey ${L_CLIENT_NAME} HKLM "Software\Clients\Mail" ${L_CLIENT_INDEX}
  StrCmp ${L_CLIENT_NAME} "" display_results
  StrCmp ${L_CLIENT_NAME} "Hotmail" incrm_index
  Push "|Microsoft Outlook|Outlook Express|Eudora|"
  Push "|${L_CLIENT_NAME}|"
  Call PFI_StrStr
  Pop ${L_CLIENT_TYPE}
  StrCmp ${L_CLIENT_TYPE} "" add_to_list
  StrCpy ${L_CLIENT_TYPE} " (*)"

  ReadRegStr ${L_TEMP} HKLM "Software\Clients\Mail\${L_CLIENT_NAME}\shell\open\command" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE "pfi-cfg.ini" "ClientEXE" "${L_CLIENT_NAME}" "${L_TEMP}"

add_to_list:
  StrCpy ${L_CLIENT_LIST} "${L_CLIENT_LIST}${L_SEPARATOR}${L_CLIENT_NAME}${L_CLIENT_TYPE}"
  StrCpy ${L_SEPARATOR} "${IO_NL}"

incrm_index:
  IntOp ${L_CLIENT_INDEX} ${L_CLIENT_INDEX} + 1
  Goto read_next_name

display_results:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioF.ini" "Field 2" "State" "${L_CLIENT_LIST}"

  Sleep ${C_MIN_BANNER_DISPLAY_TIME}
  Banner::destroy

  ; Enable the 'Next' button and set focus to it (instead of the list of detected clients,
  ; to avoid the annoying flashing cursor at the start of the list)

  !insertmacro MUI_INSTALLOPTIONS_INITDIALOG "ioF.ini"
  Pop ${L_TEMP}
  GetDlgItem $G_DLGITEM $HWNDPARENT 1
  EnableWindow $G_DLGITEM 1
  SendMessage $HWNDPARENT ${WM_NEXTDLGCTL} $G_DLGITEM 1
  !insertmacro MUI_INSTALLOPTIONS_SHOW_RETURN
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "back" 0 exit
  !insertmacro MUI_INSTALLOPTIONS_WRITE "pfi-cfg.ini" "ClientEXE" "ConfigStatus" "SkipAll"

  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioF.ini" "Settings" "NumFields" "1"
  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioF.ini" "Settings" "BackEnabled" "0"
  !insertmacro PFI_IO_TEXT "ioF.ini" "1" "$(PFI_LANG_MAILCFG_IO_CANCEL)"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioF.ini"

exit:
  Pop ${L_TEMP}
  Pop ${L_SEPARATOR}
  Pop ${L_CLIENT_TYPE}
  Pop ${L_CLIENT_NAME}
  Pop ${L_CLIENT_LIST}
  Pop ${L_CLIENT_INDEX}

  !undef L_CLIENT_INDEX
  !undef L_CLIENT_LIST
  !undef L_CLIENT_NAME
  !undef L_CLIENT_TYPE
  !undef L_SEPARATOR
  !undef L_TEMP

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: SetOutlookOutlookExpressPage_Init
#
# This function adds language texts to the INI file used by "SetOutlookExpressPage" function
# and by the "SetOutlookPage" function (to make the custom page use the language selected by
# the user for the installer)
#--------------------------------------------------------------------------

Function SetOutlookOutlookExpressPage_Init

  ; Ensure custom page matches the selected language (left-to-right or right-to-left order)

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioB.ini" "Settings" "RTL" "$(^RTL)"

  ; We use the 'Back' button as an easy way to skip the 'Outlook Express' or 'Outlook'
  ; reconfiguration (but we still check if there are any old-style uninstall data files
  ; to be converted)

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioB.ini" \
              "Settings" "BackButtonText" "$(PFI_LANG_MAILCFG_IO_SKIPONE)"

  !insertmacro PFI_IO_TEXT "ioB.ini" "1" "$(PFI_LANG_OOECFG_IO_BOXHDR)"
  !insertmacro PFI_IO_TEXT "ioB.ini" "3" "$(PFI_LANG_OOECFG_IO_FOOTNOTE)"
  !insertmacro PFI_IO_TEXT "ioB.ini" "4" "$(PFI_LANG_OOECFG_IO_ACCOUNTHDR)"
  !insertmacro PFI_IO_TEXT "ioB.ini" "5" "$(PFI_LANG_OOECFG_IO_EMAILHDR)"
  !insertmacro PFI_IO_TEXT "ioB.ini" "6" "$(PFI_LANG_OOECFG_IO_SERVERHDR)"
  !insertmacro PFI_IO_TEXT "ioB.ini" "7" "$(PFI_LANG_OOECFG_IO_USRNAMEHDR)"

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: SetOutlookExpressPage (generates a custom page)
#
# This function is used to reconfigure Outlook Express accounts
#--------------------------------------------------------------------------

Function SetOutlookExpressPage

  ; More than one "identity" can be created in OE. Each of these identities is
  ; given a GUID and these GUIDs are stored in HKEY_CURRENT_USER\Identities.

  ; Each identity can have several email accounts and the details for these
  ; accounts are grouped according to the GUID which "owns" the accounts.

  ; We step through every identity defined in HKEY_CURRENT_USER\Identities and
  ; for each one found check its OE email account data.

  ; When OE is installed, it (usually) creates an initial identity which stores its
  ; email account data in a fixed registry location. If an identity with an "Identity Ordinal"
  ; value of 1 is found, we need to look for its OE email account data in
  ;
  ;     HKEY_CURRENT_USER\Software\Microsoft\Internet Account Manager\Accounts
  ;
  ; otherwise we look in the GUID's entry in HKEY_CURRENT_USER\Identities, using the path
  ;
  ;     HKEY_CURRENT_USER\Identities\{GUID}\Software\Microsoft\Internet Account Manager\Accounts

  ; All of the OE account data for an identity appears "under" the path defined
  ; above, e.g. if an identity has several accounts, the account data is stored like this:
  ;    HKEY_CURRENT_USER\...\Internet Account Manager\Accounts\00000001
  ;    HKEY_CURRENT_USER\...\Internet Account Manager\Accounts\00000002
  ;    etc

  !define L_ACCOUNT     $R9   ; path to the data for the current OE account (less the HKCU part)
  !define L_ACCT_INDEX  $R8   ; used to loop through OE accounts for the current OE Identity
  !define L_CFG         $R7   ; file handle
  !define L_GUID        $R6   ; GUID of the current entry in HKCU\Identities list
  !define L_GUID_INDEX  $R5   ; used to loop through the list of OE Identities
  !define L_IDENTITY    $R4   ; plain text form of OE Identity name
  !define L_OEDATA      $R3   ; some data (it varies) for current OE account
  !define L_OEPATH      $R2   ; holds part of the path used to access OE account data
  !define L_ORDINALS    $R1   ; "Identity Ordinals" flag (1 = found, 0 = not found)
  !define L_PORT        $R0   ; POP3 Port used for an OE Account
  !define L_STATUS      $9    ; keeps track of the status of the account we are checking
  !define L_TEMP        $8

  !define L_POP3SERVER    $7
  !define L_EMAILADDRESS  $6
  !define L_USERNAME      $5

  Push ${L_ACCOUNT}
  Push ${L_ACCT_INDEX}
  Push ${L_CFG}
  Push ${L_GUID}
  Push ${L_GUID_INDEX}
  Push ${L_IDENTITY}
  Push ${L_OEDATA}
  Push ${L_OEPATH}
  Push ${L_ORDINALS}
  Push ${L_PORT}
  Push ${L_STATUS}
  Push ${L_TEMP}

  Push ${L_POP3SERVER}
  Push ${L_EMAILADDRESS}
  Push ${L_USERNAME}

  !insertmacro MUI_HEADER_TEXT "$(PFI_LANG_EXPCFG_TITLE)" "$(PFI_LANG_EXPCFG_SUBTITLE)"

  ; Create timestamp used for all Outlook Express configuration activities
  ; and convert old-style 'undo' data to the new INI-file format

  Call PFI_GetDateTimeStamp
  Pop ${L_TEMP}
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "pfi-cfg.ini" "DateTime" "OutlookExpress" "${L_TEMP}"
  IfFileExists "$G_USERDIR\popfile.reg" 0 check_oe_config_enabled
  Push "popfile.reg"
  Call ConvertOOERegData

check_oe_config_enabled:

  ; Check if user decided to skip all email client configuration

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "pfi-cfg.ini" "ClientEXE" "ConfigStatus"
    StrCmp ${L_STATUS} "SkipAll" exit

  ; If Outlook Express is running, ask the user to shut it down now
  ; (user is allowed to ignore our request)

check_again:
  FindWindow ${L_STATUS} "Outlook Express Browser Class"
  IsWindow ${L_STATUS} 0 open_logfiles

  MessageBox MB_ABORTRETRYIGNORE|MB_ICONSTOP|MB_DEFBUTTON2 "$(PFI_LANG_MBCLIENT_EXP)\
             ${MB_NL}${MB_NL}\
             $(PFI_LANG_MBCLIENT_STOP_1)\
             ${MB_NL}${MB_NL}\
             $(PFI_LANG_MBCLIENT_STOP_2)\
             ${MB_NL}${MB_NL}\
             $(PFI_LANG_MBCLIENT_STOP_3)"\
             IDRETRY check_again IDIGNORE open_logfiles

abort_oe_config:

  ; Either 'Abort' has been selected so we do not offer to reconfigure any Outlook Express
  ; accounts or 'Cancel' has been selected during the Outlook Express configuration process
  ; so we stop now

  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioB.ini" "Settings" "NumFields" "1"
  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioB.ini" "Settings" "BackEnabled" "0"
  !insertmacro PFI_IO_TEXT "ioB.ini" "1" "$(PFI_LANG_EXPCFG_IO_CANCELLED)"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioB.ini"
  StrCmp $G_OOECONFIG_HANDLE "" exit
  FileWrite $G_OOECONFIG_HANDLE "${MB_NL}\
      $(PFI_LANG_EXPCFG_IO_CANCELLED)\
      ${MB_NL}"
  Goto finished_oe_config

open_logfiles:
  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioB.ini" "Settings" "BackEnabled" "1"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "pfi-cfg.ini" "DateTime" "OutlookExpress"

  FileOpen  $G_OOECONFIG_HANDLE "$G_USERDIR\expconfig.txt" w
  FileWrite $G_OOECONFIG_HANDLE "[$G_WINUSERNAME] $(PFI_LANG_EXPCFG_LOG_BEFORE) (${L_TEMP})\
      ${MB_NL}${MB_NL}"
  !insertmacro PFI_OOECONFIG_BEFORE_LOG  "$(PFI_LANG_EXPCFG_LOG_IDENTITY)"  20
  !insertmacro PFI_OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OOECFG_LOG_ACCOUNT)"   20
  !insertmacro PFI_OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OOECFG_LOG_EMAIL)"     30
  !insertmacro PFI_OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OOECFG_LOG_SERVER)"    20
  !insertmacro PFI_OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OOECFG_LOG_USER)"      20
  FileWrite $G_OOECONFIG_HANDLE "$(PFI_LANG_OOECFG_LOG_PORT)\
      ${MB_NL}${MB_NL}"

  FileOpen  $G_OOECHANGES_HANDLE "$G_USERDIR\expchanges.txt" a
  FileSeek  $G_OOECHANGES_HANDLE 0 END
  FileWrite $G_OOECHANGES_HANDLE "[$G_WINUSERNAME] $(PFI_LANG_EXPCFG_LOG_AFTER) (${L_TEMP})\
      ${MB_NL}${MB_NL}"
  !insertmacro PFI_OOECONFIG_CHANGES_LOG  "$(PFI_LANG_EXPCFG_LOG_IDENTITY)"   20
  !insertmacro PFI_OOECONFIG_CHANGES_LOG  "$(PFI_LANG_OOECFG_LOG_ACCOUNT)"    20
  !insertmacro PFI_OOECONFIG_CHANGES_LOG  "$(PFI_LANG_OOECFG_LOG_NEWSERVER)"  17
  !insertmacro PFI_OOECONFIG_CHANGES_LOG  "$(PFI_LANG_OOECFG_LOG_NEWUSER)"    40
  FileWrite $G_OOECHANGES_HANDLE "$(PFI_LANG_OOECFG_LOG_NEWPORT)\
      ${MB_NL}${MB_NL}"

  ; Determine the separator character to be used when configuring an email account for POPFile

  Call PFI_GetSeparator
  Pop $G_SEPARATOR

  ; Start with an empty list of accounts and reset the list "pointers"

  Call ResetOutlookOutlookExpressAccountList

  StrCpy ${L_GUID_INDEX} 0

  ; Get the next identity from the registry

get_guid:
  EnumRegKey ${L_GUID} HKCU "Identities" ${L_GUID_INDEX}
  StrCmp ${L_GUID} "" finished_oe_config

  ; Check if this is the GUID for the first "Main Identity" created by OE as the account data
  ; for that identity is stored separately from the account data for the other OE identities.
  ; If no "Identity Ordinal" value found, use the first "Main Identity" created by OE.

  StrCpy ${L_ORDINALS} "1"

  ReadRegDWORD ${L_TEMP} HKCU "Identities\${L_GUID}" "Identity Ordinal"
  IntCmp ${L_TEMP} 1 firstOrdinal noOrdinals otherOrdinal

firstOrdinal:
  StrCpy ${L_OEPATH} ""
  goto check_accounts

noOrdinals:
  StrCpy ${L_ORDINALS} "0"
  StrCpy ${L_OEPATH} ""
  goto check_accounts

otherOrdinal:
  StrCpy ${L_OEPATH} "Identities\${L_GUID}\"

check_accounts:

  ; Now check all of the accounts for the current OE Identity

  StrCpy ${L_ACCT_INDEX} 0

next_acct:

  ; Reset the text string used to keep track of the status of the email account we are checking

  StrCpy ${L_STATUS} ""

  EnumRegKey ${L_ACCOUNT} \
             HKCU "${L_OEPATH}Software\Microsoft\Internet Account Manager\Accounts" \
             ${L_ACCT_INDEX}
  StrCmp ${L_ACCOUNT} "" finished_this_guid
  StrCpy ${L_ACCOUNT} \
        "${L_OEPATH}Software\Microsoft\Internet Account Manager\Accounts\${L_ACCOUNT}"

  ; Now extract the POP3 Server data, if this does not exist then this account is
  ; not configured for mail so move on. If the data is "127.0.0.1" or "localhost"
  ; assume the account has already been configured for use with POPFile.

  ReadRegStr ${L_OEDATA} HKCU ${L_ACCOUNT} "POP3 Server"
  StrCmp ${L_OEDATA} "" try_next_account

  ; Have found an email account so we add a new entry to the list (which can hold 6 accounts)

  IntOp $G_OOELIST_INDEX $G_OOELIST_INDEX + 1    ; to access [Account] data in pfi-cfg.ini
  IntOp $G_OOELIST_CBOX $G_OOELIST_CBOX + 1      ; field number for relevant checkbox

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Settings" "NumFields" "$G_OOELIST_CBOX"

  StrCmp ${L_OEDATA} "127.0.0.1" bad_address
  StrCmp ${L_OEDATA} "localhost" 0 check_pop3_server

bad_address:
  StrCpy ${L_STATUS} "bad IP"
  Goto check_pop3_username

check_pop3_server:

  ; If 'POP3 Server' data contains the separator character, we cannot configure this account

  Push ${L_OEDATA}
  Push $G_SEPARATOR
  Call PFI_StrStr
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" check_pop3_username
  StrCpy ${L_STATUS} "bad servername"

check_pop3_username:

  ; Prepare to display the 'POP3 Server' data

  StrCpy ${L_POP3SERVER} ${L_OEDATA}

  ReadRegStr ${L_OEDATA} HKCU ${L_ACCOUNT} "SMTP Email Address"

  StrCpy ${L_EMAILADDRESS} ${L_OEDATA}

  ReadRegDWORD ${L_PORT} HKCU ${L_ACCOUNT} "POP3 Port"
  StrCmp ${L_PORT} "" 0 port_ok
  StrCpy ${L_PORT} "110"

port_ok:
  ReadRegStr ${L_OEDATA} HKCU ${L_ACCOUNT} "POP3 User Name"
  StrCpy ${L_USERNAME} ${L_OEDATA}
  StrCmp ${L_USERNAME} "" bad_username

  ; If 'POP3 User Name' data contains the separator character, we cannot configure this account

  Push ${L_OEDATA}
  Push $G_SEPARATOR
  Call PFI_StrStr
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" configurable
  StrCmp ${L_STATUS} "" 0 configurable

bad_username:
  StrCpy ${L_STATUS} "bad username"
  Goto continue

configurable:
  StrCmp ${L_STATUS} "" 0 continue
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field $G_OOELIST_CBOX" "Flags" ""

continue:

  ; Find the Username used by OE for this identity and the OE Account Name
  ; (so we can unambiguously report which email account we are offering to reconfigure).

  ReadRegStr ${L_IDENTITY} HKCU "Identities\${L_GUID}\" "Username"
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 1" "Text" "'${L_IDENTITY}' $(PFI_LANG_OOECFG_IO_BOXHDR)"
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "pfi-cfg.ini" "Identity" "Username" "${L_IDENTITY}"

  ReadRegStr ${L_OEDATA} HKCU ${L_ACCOUNT} "Account Name"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 8" "State"
  StrCpy ${L_TEMP} ""
  StrCmp ${L_STATUS} "" no_padding
  StrCpy ${L_TEMP} "${IO_NL}${IO_NL}"

no_padding:
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Field 8" "State" "${L_STATUS}${L_TEMP}${L_OEDATA}"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 9" "State"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Field 9" "State" "${L_STATUS}${L_TEMP}${L_EMAILADDRESS}"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 10" "State"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Field 10" "State" "${L_STATUS}${L_TEMP}${L_POP3SERVER}"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 11" "State"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Field 11" "State" "${L_STATUS}${L_TEMP}${L_USERNAME}"

  !insertmacro MUI_INSTALLOPTIONS_WRITE  "pfi-cfg.ini" "Account $G_OOELIST_INDEX" "AccountName" "${L_OEDATA}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "pfi-cfg.ini" "Account $G_OOELIST_INDEX" "EmailAddress" "${L_EMAILADDRESS}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "pfi-cfg.ini" "Account $G_OOELIST_INDEX" "POP3server" "${L_POP3SERVER}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "pfi-cfg.ini" "Account $G_OOELIST_INDEX" "POP3username" "${L_USERNAME}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "pfi-cfg.ini" "Account $G_OOELIST_INDEX" "POP3port" "${L_PORT}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "pfi-cfg.ini" "Account $G_OOELIST_INDEX" "RegistryKey" "${L_ACCOUNT}"

  !insertmacro PFI_OOECONFIG_BEFORE_LOG  "${L_IDENTITY}"     20
  !insertmacro PFI_OOECONFIG_BEFORE_LOG  "${L_OEDATA}"       20
  !insertmacro PFI_OOECONFIG_BEFORE_LOG  "${L_EMAILADDRESS}" 30
  !insertmacro PFI_OOECONFIG_BEFORE_LOG  "${L_POP3SERVER}"   20
  !insertmacro PFI_OOECONFIG_BEFORE_LOG  "${L_USERNAME}"     20
  FileWrite $G_OOECONFIG_HANDLE "${L_PORT}\
      ${MB_NL}"

  IntCmp $G_OOELIST_INDEX 6 display_list try_next_account try_next_account

display_list:

  ; Display the OE account data with checkboxes enabled for those accounts we can configure

  !insertmacro MUI_INSTALLOPTIONS_INITDIALOG "ioB.ini"
  Pop $G_HWND                 ; HWND of dialog we want to modify

  !ifndef ENGLISH_MODE

    ; Do not attempt to display "bold" text when using Chinese, Japanese or Korean

    StrCmp $LANGUAGE ${LANG_SIMPCHINESE} show_page
    StrCmp $LANGUAGE ${LANG_TRADCHINESE} show_page
    StrCmp $LANGUAGE ${LANG_JAPANESE} show_page
    StrCmp $LANGUAGE ${LANG_KOREAN} show_page
  !endif

  ; In 'GetDlgItem', use (1200 + Field number - 1) to refer to the field to be changed

  GetDlgItem $G_DLGITEM $G_HWND 1200             ; Field 1 = IDENTITY label (above the box)
  CreateFont $G_FONT "MS Shell Dlg" 8 700        ; use a 'bolder' version of the font in use
  SendMessage $G_DLGITEM ${WM_SETFONT} $G_FONT 0

  !ifndef ENGLISH_MODE
    show_page:
  !endif
  !insertmacro MUI_INSTALLOPTIONS_SHOW_RETURN
  Pop ${L_TEMP}

  StrCmp ${L_TEMP} "back" abort_oe_config
  StrCmp ${L_TEMP} "cancel" finished_this_guid

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "pfi-cfg.ini" "Identity" "PageStatus"
  StrCmp ${L_TEMP} "updated" display_list
  StrCmp ${L_TEMP} "leftover_ticks" display_list

  Call ResetOutlookOutlookExpressAccountList

try_next_account:
  IntOp ${L_ACCT_INDEX} ${L_ACCT_INDEX} + 1
  goto next_acct

finished_this_guid:
  IntCmp $G_OOELIST_INDEX 0 continue_guid continue_guid

display_list_again:
  !insertmacro MUI_INSTALLOPTIONS_INITDIALOG "ioB.ini"
  Pop $G_HWND                 ; HWND of dialog we want to modify

  !ifndef ENGLISH_MODE

    ; Do not attempt to display "bold" text when using Chinese, Japanese or Korean

    StrCmp $LANGUAGE ${LANG_SIMPCHINESE} show_page_again
    StrCmp $LANGUAGE ${LANG_TRADCHINESE} show_page_again
    StrCmp $LANGUAGE ${LANG_JAPANESE} show_page_again
    StrCmp $LANGUAGE ${LANG_KOREAN} show_page_again
  !endif

  ; In 'GetDlgItem', use (1200 + Field number - 1) to refer to the field to be changed

  GetDlgItem $G_DLGITEM $G_HWND 1200             ; Field 1 = IDENTITY label (above the box)
  CreateFont $G_FONT "MS Shell Dlg" 8 700        ; use a 'bolder' version of the font in use
  SendMessage $G_DLGITEM ${WM_SETFONT} $G_FONT 0

  !ifndef ENGLISH_MODE
    show_page_again:
  !endif
  !insertmacro MUI_INSTALLOPTIONS_SHOW_RETURN
  Pop ${L_TEMP}

  StrCmp ${L_TEMP} "back" abort_oe_config
  StrCmp ${L_TEMP} "cancel" finished_this_guid

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "pfi-cfg.ini" "Identity" "PageStatus"
  StrCmp ${L_TEMP} "updated" display_list_again
  StrCmp ${L_TEMP} "leftover_ticks" display_list_again

  Call ResetOutlookOutlookExpressAccountList

continue_guid:

  ; If no "Identity Ordinal" values were found then exit otherwise move on to the next identity

  StrCmp ${L_ORDINALS} "0" finished_oe_config

  IntOp ${L_GUID_INDEX} ${L_GUID_INDEX} + 1
  goto get_guid

finished_oe_config:
  FileWrite $G_OOECONFIG_HANDLE "${MB_NL}\
      $(PFI_LANG_OOECFG_LOG_END)\
      ${MB_NL}${MB_NL}"
  FileClose $G_OOECONFIG_HANDLE

  FileWrite $G_OOECHANGES_HANDLE "${MB_NL}\
      $(PFI_LANG_OOECFG_LOG_END)\
      ${MB_NL}${MB_NL}"
  FileClose $G_OOECHANGES_HANDLE

exit:
  Pop ${L_USERNAME}
  Pop ${L_EMAILADDRESS}
  Pop ${L_POP3SERVER}

  Pop ${L_TEMP}
  Pop ${L_STATUS}
  Pop ${L_PORT}
  Pop ${L_ORDINALS}
  Pop ${L_OEPATH}
  Pop ${L_OEDATA}
  Pop ${L_IDENTITY}
  Pop ${L_GUID_INDEX}
  Pop ${L_GUID}
  Pop ${L_CFG}
  Pop ${L_ACCT_INDEX}
  Pop ${L_ACCOUNT}

  !undef L_ACCOUNT
  !undef L_ACCT_INDEX
  !undef L_CFG
  !undef L_GUID
  !undef L_GUID_INDEX
  !undef L_IDENTITY
  !undef L_OEDATA
  !undef L_OEPATH
  !undef L_ORDINALS
  !undef L_PORT
  !undef L_STATUS
  !undef L_TEMP

  !undef L_POP3SERVER
  !undef L_EMAILADDRESS
  !undef L_USERNAME

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: ConvertOOERegData
#
# This function uses an old-style 'popfile.reg' (or 'outlook.reg') file to build a new
# 'pfi-outexpress.ini' (or 'pfi-outlook.ini') file. The old-style filename is passed via stack.
# After new file has been built, old one is renamed (up to 3 versions are kept).
#--------------------------------------------------------------------------

Function ConvertOOERegData

  !define L_CFG         $R9
  !define L_PREV_KEY    $R8
  !define L_REG_FILE    $R7
  !define L_REG_KEY     $R6
  !define L_REG_SUBKEY  $R5
  !define L_REG_VALUE   $R4
  !define L_TEMP        $R3
  !define L_UNDO        $R2
  !define L_UNDOFILE    $R1

  Exch ${L_REG_FILE}
  Push ${L_CFG}
  Push ${L_PREV_KEY}
  Push ${L_REG_KEY}
  Push ${L_REG_SUBKEY}
  Push ${L_REG_VALUE}
  Push ${L_TEMP}
  Push ${L_UNDO}
  Push ${L_UNDOFILE}

  Call ShowPleaseWaitBanner

  ; Original 'popfile.reg' format (2 values per entry, each using 3 lines) imported as 'IniV=1':
  ;
  ;                 "Registry key", "POP3 User Name", "original data",
  ;                 "Registry key", "POP3 Server", "original data"
  ;
  ; Revised 'popfile.reg' format (3 values per entry, each using 3 lines) imported as 'IniV=2':
  ;
  ;                 "Registry key", "POP3 User Name", "original data",
  ;                 "Registry key", "POP3 Server", "original data",
  ;                 "Registry key", "POP3 Port", "original data"
  ;
  ; Original 'outlook.reg' format (3 values per entry, each using 3 lines) imported as 'IniV=2':
  ;
  ;                 "Registry key", "POP3 User Name", "original data",
  ;                 "Registry key", "POP3 Server", "original data",
  ;                 "Registry key", "POP3 Port", "original data"

  StrCpy ${L_PREV_KEY} ""

  StrCmp ${L_REG_FILE} "popfile.reg" outlook_express
  StrCpy ${L_UNDOFILE} "pfi-outlook.ini"
  Goto read_old_file

outlook_express:
  StrCpy ${L_UNDOFILE} "pfi-outexpress.ini"

read_old_file:
  FileOpen  ${L_CFG} "$G_USERDIR\${L_REG_FILE}" r

next_entry:
  FileRead ${L_CFG} ${L_REG_KEY}
  StrCmp ${L_REG_KEY} "" end_of_file
  Push ${L_REG_KEY}
  Call PFI_TrimNewlines
  Pop ${L_REG_KEY}
  StrCmp ${L_REG_KEY} "" next_entry

  FileRead ${L_CFG} ${L_REG_SUBKEY}
  Push ${L_REG_SUBKEY}
  Call PFI_TrimNewlines
  Pop ${L_REG_SUBKEY}
  StrCmp ${L_REG_SUBKEY} "" next_entry

  FileRead ${L_CFG} ${L_REG_VALUE}
  Push ${L_REG_VALUE}
  Call PFI_TrimNewlines
  Pop ${L_REG_VALUE}
  StrCmp ${L_REG_VALUE} "" next_entry

  StrCmp ${L_REG_KEY} ${L_PREV_KEY} add_to_current
  StrCpy ${L_PREV_KEY} ${L_REG_KEY}

  ; New entry detected, so we create a new 'undo' entry for it

  ReadINIStr  ${L_UNDO} "$G_USERDIR\${L_UNDOFILE}" "History" "ListSize"
  StrCmp ${L_UNDO} "" 0 update_list_size
  StrCpy ${L_UNDO} 1
  WriteINIStr "$G_USERDIR\${L_UNDOFILE}" "History" "ListSize" "1"
  Goto add_entry

update_list_size:
  IntOp ${L_UNDO} ${L_UNDO} + 1
  WriteINIStr "$G_USERDIR\${L_UNDOFILE}" "History" "ListSize" "${L_UNDO}"

add_entry:
  StrCmp ${L_REG_FILE} "popfile.reg" outlook_express_stamp
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "pfi-cfg.ini" "DateTime" "Outlook"
  Goto save_entry

outlook_express_stamp:
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "pfi-cfg.ini" "DateTime" "OutlookExpress"

save_entry:
  WriteINIStr "$G_USERDIR\${L_UNDOFILE}" "History" "Undo-${L_UNDO}" "Imported on ${L_TEMP}"
  WriteINIStr "$G_USERDIR\${L_UNDOFILE}" "History" "IniV-${L_UNDO}" "1"

  WriteINIStr "$G_USERDIR\${L_UNDOFILE}" "Undo-${L_UNDO}" "Restored" "No"
  WriteINIStr "$G_USERDIR\${L_UNDOFILE}" "Undo-${L_UNDO}" "RegistryKey" "${L_REG_KEY}"

add_to_current:
  StrCmp ${L_REG_SUBKEY} "POP3 User Name" 0 not_username
  WriteINIStr "$G_USERDIR\${L_UNDOFILE}" "Undo-${L_UNDO}" "POP3UserName" "${L_REG_VALUE}"
  Goto next_entry

not_username:
  StrCmp ${L_REG_SUBKEY} "POP3 Server" 0 not_server
  WriteINIStr "$G_USERDIR\${L_UNDOFILE}" "Undo-${L_UNDO}" "POP3Server" "${L_REG_VALUE}"
  Goto next_entry

not_server:
  StrCmp ${L_REG_SUBKEY} "POP3 Server" 0 next_entry
  WriteINIStr "$G_USERDIR\${L_UNDOFILE}" "Undo-${L_UNDO}" "POP3Port" "${L_REG_VALUE}"
  WriteINIStr "$G_USERDIR\${L_UNDOFILE}" "History" "IniV-${L_UNDO}" "2"
  Goto next_entry

end_of_file:
  FileClose ${L_CFG}

  ; Now "remove" the old-style 'undo' file by renaming it

  !insertmacro PFI_BACKUP_123_DP "$G_USERDIR" "${L_REG_FILE}"

  Sleep ${C_MIN_BANNER_DISPLAY_TIME}
  Banner::destroy

  Pop ${L_UNDOFILE}
  Pop ${L_UNDO}
  Pop ${L_TEMP}
  Pop ${L_REG_VALUE}
  Pop ${L_REG_SUBKEY}
  Pop ${L_REG_KEY}
  Pop ${L_PREV_KEY}
  Pop ${L_CFG}
  Pop ${L_REG_FILE}

  !undef L_CFG
  !undef L_PREV_KEY
  !undef L_REG_FILE
  !undef L_REG_KEY
  !undef L_REG_SUBKEY
  !undef L_REG_VALUE
  !undef L_TEMP
  !undef L_UNDO
  !undef L_UNDOFILE

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: ResetOutlookOutlookExpressAccountList
#
# This function is used to empty the list used to display up to 6 accounts for a given identity
#--------------------------------------------------------------------------

Function ResetOutlookOutlookExpressAccountList

  !define L_CBOX_INDEX   $R9
  !define L_TEXT_INDEX   $R8

  Push ${L_CBOX_INDEX}
  Push ${L_TEXT_INDEX}

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Settings" "NumFields" "11"

  StrCpy $G_OOELIST_INDEX     0    ; values 1 to 6 used to access the list
  StrCpy $G_OOELIST_CBOX     11    ; first entry uses field 12

  StrCpy ${L_CBOX_INDEX} 12

next_row:
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field ${L_CBOX_INDEX}" "State" "0"
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field ${L_CBOX_INDEX}" "Flags" "DISABLED"

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 8" "State" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 9" "State" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 10" "State" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 11" "State" ""

  IntOp ${L_CBOX_INDEX} ${L_CBOX_INDEX} + 1
  IntCmp ${L_CBOX_INDEX} 17 next_row next_row

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "pfi-cfg.ini" "Identity" "Username" ""

  StrCpy ${L_TEXT_INDEX} 1

next_account:
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "pfi-cfg.ini" "Account ${L_TEXT_INDEX}" "AccountName" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "pfi-cfg.ini" "Account ${L_TEXT_INDEX}" "EMailAddress" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "pfi-cfg.ini" "Account ${L_TEXT_INDEX}" "POP3server" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "pfi-cfg.ini" "Account ${L_TEXT_INDEX}" "POP3username" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "pfi-cfg.ini" "Account ${L_TEXT_INDEX}" "POP3port" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "pfi-cfg.ini" "Account ${L_TEXT_INDEX}" "RegistryKey" ""
  IntOp ${L_TEXT_INDEX} ${L_TEXT_INDEX} + 1
  IntCmp ${L_TEXT_INDEX} 6 next_account next_account

  Pop ${L_TEXT_INDEX}
  Pop ${L_CBOX_INDEX}

  !undef L_CBOX_INDEX
  !undef L_TEXT_INDEX

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: CheckOutlookExpressRequests
#
# This function is used to confirm any Outlook Express account reconfiguration requests
#--------------------------------------------------------------------------

Function CheckOutlookExpressRequests

  !define L_CBOX_INDEX   $R9
  !define L_CBOX_STATE   $R8
  !define L_DATA_INDEX   $R7
  !define L_REGKEY       $R6
  !define L_TEMP         $R5
  !define L_TEXT_ENTRY   $R4
  !define L_IDENTITY     $R3
  !define L_UNDO         $R2

  !define L_ACCOUNTNAME   $9
  !define L_EMAILADDRESS  $8
  !define L_POP3SERVER    $7
  !define L_POP3USERNAME  $6
  !define L_POP3PORT      $5

  Push ${L_CBOX_INDEX}
  Push ${L_CBOX_STATE}
  Push ${L_DATA_INDEX}
  Push ${L_REGKEY}
  Push ${L_TEMP}
  Push ${L_TEXT_ENTRY}
  Push ${L_IDENTITY}
  Push ${L_UNDO}

  Push ${L_ACCOUNTNAME}
  Push ${L_EMAILADDRESS}
  Push ${L_POP3SERVER}
  Push ${L_POP3USERNAME}
  Push ${L_POP3PORT}

  ; If user has cancelled the reconfiguration, there is nothing to do here

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioB.ini" "Settings" "NumFields"
  StrCmp ${L_TEMP} "1" exit

  ; 'PageStatus' will be set to 'updated' or 'leftover_ticks' when the page needs to be
  ; redisplayed to confirm which accounts (if any) have been reconfigured

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "pfi-cfg.ini" "Identity" "PageStatus" "clean"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_IDENTITY} "pfi-cfg.ini" "Identity" "Username"

  StrCpy ${L_CBOX_INDEX} 12
  StrCpy ${L_DATA_INDEX} 1

next_row:
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_CBOX_STATE} "ioB.ini" "Field ${L_CBOX_INDEX}" "Flags"
  StrCmp ${L_CBOX_STATE} "DISABLED" continue

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_CBOX_STATE} "ioB.ini" "Field ${L_CBOX_INDEX}" "State"
  StrCmp ${L_CBOX_STATE} "0" continue

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_ACCOUNTNAME}  "pfi-cfg.ini" "Account ${L_DATA_INDEX}" "AccountName"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_EMAILADDRESS} "pfi-cfg.ini" "Account ${L_DATA_INDEX}" "EMailAddress"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_POP3SERVER}   "pfi-cfg.ini" "Account ${L_DATA_INDEX}" "POP3server"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_POP3USERNAME} "pfi-cfg.ini" "Account ${L_DATA_INDEX}" "POP3username"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_POP3PORT}     "pfi-cfg.ini" "Account ${L_DATA_INDEX}" "POP3port"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_REGKEY}       "pfi-cfg.ini" "Account ${L_DATA_INDEX}" "RegistryKey"

  MessageBox MB_YESNO \
      "$(PFI_LANG_EXPCFG_MBIDENTITY) ${L_IDENTITY}\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_EXPCFG_MBACCOUNT) ${L_ACCOUNTNAME}\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_OOECFG_MBEMAIL) ${L_EMAILADDRESS}\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_OOECFG_MBSERVER) 127.0.0.1 \
                                   ($(PFI_LANG_OOECFG_MBOLDVALUE) '${L_POP3SERVER}')\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_OOECFG_MBUSERNAME) ${L_POP3SERVER}$G_SEPARATOR${L_POP3USERNAME} \
                                     ($(PFI_LANG_OOECFG_MBOLDVALUE) '${L_POP3USERNAME}')\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_OOECFG_MBOEPORT) $G_POP3 \
                                   ($(PFI_LANG_OOECFG_MBOLDVALUE) '${L_POP3PORT}')\
      ${MB_NL}${MB_NL}${MB_NL}\
      $(PFI_LANG_OOECFG_MBQUESTION)\
      " IDNO ignore_tick

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "pfi-cfg.ini" "Identity" "PageStatus" "updated"
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field ${L_CBOX_INDEX}" "Flags" "DISABLED"

  ReadINIStr  ${L_UNDO} "$G_USERDIR\pfi-outexpress.ini" "History" "ListSize"
  StrCmp ${L_UNDO} "" 0 update_list_size
  StrCpy ${L_UNDO} 1
  WriteINIStr "$G_USERDIR\pfi-outexpress.ini" "History" "ListSize" "1"
  Goto add_entry

update_list_size:
  IntOp ${L_UNDO} ${L_UNDO} + 1
  WriteINIStr "$G_USERDIR\pfi-outexpress.ini" "History" "ListSize" "${L_UNDO}"

add_entry:
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "pfi-cfg.ini" "DateTime" "OutlookExpress"
  WriteINIStr "$G_USERDIR\pfi-outexpress.ini" "History" "Undo-${L_UNDO}" "Created on ${L_TEMP}"
  WriteINIStr "$G_USERDIR\pfi-outexpress.ini" "History" "User-${L_UNDO}" "$G_WINUSERNAME"
  WriteINIStr "$G_USERDIR\pfi-outexpress.ini" "History" "Type-${L_UNDO}" "$G_WINUSERTYPE"
  WriteINIStr "$G_USERDIR\pfi-outexpress.ini" "History" "IniV-${L_UNDO}" "3"

  WriteINIStr "$G_USERDIR\pfi-outexpress.ini" "Undo-${L_UNDO}" "Restored" "No"
  WriteINIStr "$G_USERDIR\pfi-outexpress.ini" "Undo-${L_UNDO}" "RegistryKey" "${L_REGKEY}"
  WriteINIStr "$G_USERDIR\pfi-outexpress.ini" "Undo-${L_UNDO}" "POP3UserName" "${L_POP3USERNAME}"
  WriteINIStr "$G_USERDIR\pfi-outexpress.ini" "Undo-${L_UNDO}" "POP3Server" "${L_POP3SERVER}"
  WriteINIStr "$G_USERDIR\pfi-outexpress.ini" "Undo-${L_UNDO}" "POP3Port" "${L_POP3PORT}"

  ; Reconfigure the Outlook Express account

  WriteRegStr HKCU ${L_REGKEY} "POP3 User Name" "${L_POP3SERVER}$G_SEPARATOR${L_POP3USERNAME}"
  WriteRegStr HKCU ${L_REGKEY} "POP3 Server" "127.0.0.1"
  WriteRegDWORD HKCU ${L_REGKEY} "POP3 Port" $G_POP3

  !insertmacro PFI_OOECONFIG_CHANGES_LOG  "${L_IDENTITY}"    20
  !insertmacro PFI_OOECONFIG_CHANGES_LOG  "${L_ACCOUNTNAME}" 20
  !insertmacro PFI_OOECONFIG_CHANGES_LOG  "127.0.0.1"        17
  !insertmacro PFI_OOECONFIG_CHANGES_LOG  "${L_POP3SERVER}$G_SEPARATOR${L_POP3USERNAME}"  40
  FileWrite $G_OOECHANGES_HANDLE "$G_POP3${MB_NL}"

  Goto continue

ignore_tick:
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "pfi-cfg.ini" "Identity" "PageStatus" "leftover_ticks"

continue:
  IntOp ${L_CBOX_INDEX} ${L_CBOX_INDEX} + 1
  IntOp ${L_DATA_INDEX} ${L_DATA_INDEX} + 1
  IntCmp ${L_DATA_INDEX} $G_OOELIST_INDEX next_row next_row

exit:
  Pop ${L_POP3PORT}
  Pop ${L_POP3USERNAME}
  Pop ${L_POP3SERVER}
  Pop ${L_EMAILADDRESS}
  Pop ${L_ACCOUNTNAME}

  Pop ${L_UNDO}
  Pop ${L_IDENTITY}
  Pop ${L_TEXT_ENTRY}
  Pop ${L_TEMP}
  Pop ${L_REGKEY}
  Pop ${L_DATA_INDEX}
  Pop ${L_CBOX_STATE}
  Pop ${L_CBOX_INDEX}

  !undef L_CBOX_INDEX
  !undef L_CBOX_STATE
  !undef L_DATA_INDEX
  !undef L_REGKEY
  !undef L_TEMP
  !undef L_TEXT_ENTRY
  !undef L_IDENTITY
  !undef L_UNDO

  !undef L_ACCOUNTNAME
  !undef L_EMAILADDRESS
  !undef L_POP3SERVER
  !undef L_POP3USERNAME
  !undef L_POP3PORT

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: SetOutlookPage (generates a custom page)
#
# This function is used to reconfigure Outlook accounts
#--------------------------------------------------------------------------

Function SetOutlookPage

  ; This is an initial attempt at providing reconfiguration of Outlook POP3 accounts
  ; (unlike the 'SetOutlookExpressPage' function, 'SetOutlookPage' is based upon theory
  ; instead of experiment)

  ; Each version of Outlook seems to use a slightly different location in the registry
  ; (this is an incomplete list but it is all that is to hand at the moment):
  ;
  ; Outlook 2000:
  ;   HKEY_CURRENT_USER\Software\Microsoft\Office\Outlook\OMI Account Manager\Accounts
  ;
  ; Outlook 98:
  ;   HKEY_CURRENT_USER\Software\Microsoft\Office\8.0\Outlook\OMI Account Manager\Accounts
  ;
  ; Outlook 97:
  ;   HKEY_CURRENT_USER\Software\Microsoft\Office\7.0\Outlook\OMI Account Manager\Accounts
  ;
  ; Before working through this list, we try to cheat by looking for the key
  ;
  ;   HKEY_LOCAL_MACHINE\Software\Microsoft\Internet Account Manager\Outlook
  ;
  ; which may solve our problem (e.g. "Software\Microsoft\Office\Outlook\OMI Account Manager")

  ; All of the account data for the current user appears "under" the path defined
  ; above, e.g. if a user has several accounts, the account data is stored like this:
  ;    HKEY_CURRENT_USER\Software\Microsoft\Office\...\OMI Account Manager\Accounts\00000001
  ;    HKEY_CURRENT_USER\Software\Microsoft\Office\...\OMI Account Manager\Accounts\00000002
  ;    etc

  ; (This format is similar to that used by Outlook Express)

  !define L_ACCOUNT       $R9   ; path to data for current Outlook account (less the HKCU part)
  !define L_ACCT_INDEX    $R8   ; used to loop through Outlook accounts for the current user
  !define L_EMAILADDRESS  $R7   ; for an Outlook account
  !define L_OUTDATA       $R5   ; some data (it varies) for current Outlook account
  !define L_OUTLOOK       $R4   ; registry path for the Outlook accounts (less the HKCU part)
  !define L_POP3SERVER    $R3   ; POP3 server name for an Outlook account
  !define L_PORT          $R2   ; POP3 Port used for an Outlook Account
  !define L_STATUS        $R1   ; keeps track of the status of the account we are checking
  !define L_TEMP          $R0
  !define L_USERNAME      $9    ; POP3 username used for an Outlook account

  Push ${L_ACCOUNT}
  Push ${L_ACCT_INDEX}
  Push ${L_EMAILADDRESS}
  Push ${L_OUTDATA}
  Push ${L_OUTLOOK}
  Push ${L_POP3SERVER}
  Push ${L_PORT}
  Push ${L_STATUS}
  Push ${L_TEMP}
  Push ${L_USERNAME}

  !insertmacro MUI_HEADER_TEXT "$(PFI_LANG_OUTCFG_TITLE)" "$(PFI_LANG_OUTCFG_SUBTITLE)"

  ; Create timestamp used for all Outlook configuration activities
  ; and convert old-style 'undo' data to the new INI-file format

  Call PFI_GetDateTimeStamp
  Pop ${L_TEMP}
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "pfi-cfg.ini" "DateTime" "Outlook" "${L_TEMP}"
  IfFileExists "$G_USERDIR\outlook.reg" 0 check_for_outlook
  Push "outlook.reg"
  Call ConvertOOERegData

check_for_outlook:

  ; Check if user decided to skip all email client configuration

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "pfi-cfg.ini" "ClientEXE" "ConfigStatus"
    StrCmp ${L_STATUS} "SkipAll" exit

  ; Look for Outlook account data - if none found then quit

  ReadRegStr ${L_OUTLOOK} HKLM "Software\Microsoft\Internet Account Manager" "Outlook"
  StrCmp ${L_OUTLOOK} "" try_outlook_2000
  Push ${L_OUTLOOK}
  Push "OMI Account Manager"
  Call PFI_StrStr
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" try_outlook_2000
  StrCpy ${L_TEMP} ${L_OUTLOOK} "" -9
  StrCmp ${L_TEMP} "\Accounts" got_outlook_path
  StrCpy ${L_OUTLOOK} "${L_OUTLOOK}\Accounts"
  Goto got_outlook_path

try_outlook_2000:
  EnumRegKey ${L_OUTLOOK} HKCU "Software\Microsoft\Office\Outlook\OMI Account Manager\Accounts" 0
  StrCmp ${L_OUTLOOK} "" try_outlook_98
  StrCpy ${L_OUTLOOK} "Software\Microsoft\Office\Outlook\OMI Account Manager\Accounts"
  Goto got_outlook_path

try_outlook_98:
  EnumRegKey ${L_OUTLOOK} HKCU "Software\Microsoft\Office\8.0\Outlook\OMI Account Manager\Accounts" 0
  StrCmp ${L_OUTLOOK} "" try_outlook_97
  StrCpy ${L_OUTLOOK} "Software\Microsoft\Office\8.0\Outlook\OMI Account Manager\Accounts"
  Goto got_outlook_path

try_outlook_97:
  EnumRegKey ${L_OUTLOOK} HKCU "Software\Microsoft\Office\7.0\Outlook\OMI Account Manager\Accounts" 0
  StrCmp ${L_OUTLOOK} "" exit
  StrCpy ${L_OUTLOOK} "Software\Microsoft\Office\7.0\Outlook\OMI Account Manager\Accounts"

got_outlook_path:
  FindWindow ${L_STATUS} "rctrl_renwnd32"
  IsWindow ${L_STATUS} 0 open_logfiles

  MessageBox MB_ABORTRETRYIGNORE|MB_ICONSTOP|MB_DEFBUTTON2 "$(PFI_LANG_MBCLIENT_OUT)\
             ${MB_NL}${MB_NL}\
             $(PFI_LANG_MBCLIENT_STOP_1)\
             ${MB_NL}${MB_NL}\
             $(PFI_LANG_MBCLIENT_STOP_2)\
             ${MB_NL}${MB_NL}\
             $(PFI_LANG_MBCLIENT_STOP_3)"\
             IDRETRY got_outlook_path IDIGNORE open_logfiles

abort_outlook_config:

  ; Either 'Abort' has been selected so we do not offer to reconfigure any Outlook accounts
  ; or 'Cancel' has been selected during the Outlook configuration process so we stop now

  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioB.ini" "Settings" "NumFields" "1"
  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioB.ini" "Settings" "BackEnabled" "0"
  !insertmacro PFI_IO_TEXT "ioB.ini" "1" "$(PFI_LANG_OUTCFG_IO_CANCELLED)"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioB.ini"
  StrCmp $G_OOECONFIG_HANDLE "" exit
  FileWrite $G_OOECONFIG_HANDLE "${MB_NL}\
      $(PFI_LANG_OUTCFG_IO_CANCELLED)\
      ${MB_NL}"
  Goto finished_outlook_config

open_logfiles:
  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioB.ini" "Settings" "BackEnabled" "1"

  Call PFI_GetDateTimeStamp
  Pop ${L_TEMP}

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "pfi-cfg.ini" "DateTime" "Outlook" "${L_TEMP}"

  FileOpen  $G_OOECONFIG_HANDLE "$G_USERDIR\outconfig.txt" w
  FileWrite $G_OOECONFIG_HANDLE "[$G_WINUSERNAME] $(PFI_LANG_OUTCFG_LOG_BEFORE) (${L_TEMP})\
      ${MB_NL}${MB_NL}"
  !insertmacro PFI_OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OUTCFG_LOG_IDENTITY)"  20
  !insertmacro PFI_OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OOECFG_LOG_ACCOUNT)"   20
  !insertmacro PFI_OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OOECFG_LOG_EMAIL)"     30
  !insertmacro PFI_OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OOECFG_LOG_SERVER)"    20
  !insertmacro PFI_OOECONFIG_BEFORE_LOG  "$(PFI_LANG_OOECFG_LOG_USER)"      20
  FileWrite $G_OOECONFIG_HANDLE "$(PFI_LANG_OOECFG_LOG_PORT)\
      ${MB_NL}${MB_NL}"

  FileOpen  $G_OOECHANGES_HANDLE "$G_USERDIR\outchanges.txt" a
  FileSeek  $G_OOECHANGES_HANDLE 0 END
  FileWrite $G_OOECHANGES_HANDLE "[$G_WINUSERNAME] $(PFI_LANG_OUTCFG_LOG_AFTER) (${L_TEMP})\
      ${MB_NL}${MB_NL}"
  !insertmacro PFI_OOECONFIG_CHANGES_LOG  "$(PFI_LANG_OUTCFG_LOG_IDENTITY)"   20
  !insertmacro PFI_OOECONFIG_CHANGES_LOG  "$(PFI_LANG_OOECFG_LOG_ACCOUNT)"    20
  !insertmacro PFI_OOECONFIG_CHANGES_LOG  "$(PFI_LANG_OOECFG_LOG_NEWSERVER)"  17
  !insertmacro PFI_OOECONFIG_CHANGES_LOG  "$(PFI_LANG_OOECFG_LOG_NEWUSER)"    40
  FileWrite $G_OOECHANGES_HANDLE "$(PFI_LANG_OOECFG_LOG_NEWPORT)\
      ${MB_NL}${MB_NL}"

  ; Determine the separator character to be used when configuring an email account for POPFile

  Call PFI_GetSeparator
  Pop $G_SEPARATOR

  ; Start with an empty list of accounts and reset the list "pointers"

  Call ResetOutlookOutLookExpressAccountList

  ; Now check all of the Outlook accounts for the current user

  StrCpy ${L_ACCT_INDEX} 0

next_acct:

  ; Reset the text string used to keep track of the status of the email account we are checking

  StrCpy ${L_STATUS} ""

  EnumRegKey ${L_ACCOUNT} HKCU ${L_OUTLOOK} ${L_ACCT_INDEX}
  StrCmp ${L_ACCOUNT} "" finished_the_accounts
  StrCpy ${L_ACCOUNT} "${L_OUTLOOK}\${L_ACCOUNT}"

  ; Now extract the POP3 Server data, if this does not exist then this account is
  ; not configured for mail so move on. If the data is "127.0.0.1" or "localhost"
  ; assume the account has already been configured for use with POPFile.

  ReadRegStr ${L_OUTDATA} HKCU ${L_ACCOUNT} "POP3 Server"
  StrCmp ${L_OUTDATA} "" try_next_account

  ; Have found an email account so we add a new entry to the list (which can hold 6 accounts)

  IntOp $G_OOELIST_INDEX $G_OOELIST_INDEX + 1    ; to access [Account] data in pfi-cfg.ini
  IntOp $G_OOELIST_CBOX $G_OOELIST_CBOX + 1      ; field number for relevant checkbox

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Settings" "NumFields" "$G_OOELIST_CBOX"

  StrCmp ${L_OUTDATA} "127.0.0.1" bad_address
  StrCmp ${L_OUTDATA} "localhost" 0 check_pop3_server

bad_address:
  StrCpy ${L_STATUS} "bad IP"
  Goto check_pop3_username

check_pop3_server:

  ; If 'POP3 Server' data contains the separator character, we cannot configure this account

  Push ${L_OUTDATA}
  Push $G_SEPARATOR
  Call PFI_StrStr
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" check_pop3_username
  StrCpy ${L_STATUS} "bad servername"

check_pop3_username:

  ; Prepare to display the 'POP3 Server' data

  StrCpy ${L_POP3SERVER} ${L_OUTDATA}

  ReadRegStr ${L_OUTDATA} HKCU ${L_ACCOUNT} "SMTP Email Address"

  StrCpy ${L_EMAILADDRESS} ${L_OUTDATA}

  ReadRegDWORD ${L_PORT} HKCU ${L_ACCOUNT} "POP3 Port"
  StrCmp ${L_PORT} "" 0 port_ok
  StrCpy ${L_PORT} "110"

port_ok:
  ReadRegStr ${L_OUTDATA} HKCU ${L_ACCOUNT} "POP3 User Name"
  StrCpy ${L_USERNAME} ${L_OUTDATA}
  StrCmp ${L_USERNAME} "" bad_username

  ; If 'POP3 User Name' data contains the separator character, we cannot configure this account

  Push ${L_OUTDATA}
  Push $G_SEPARATOR
  Call PFI_StrStr
  Pop ${L_TEMP}
  StrCmp ${L_TEMP} "" configurable
  StrCmp ${L_STATUS} "" 0 configurable

bad_username:
  StrCpy ${L_STATUS} "bad username"
  Goto continue

configurable:
  StrCmp ${L_STATUS} "" 0 continue
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field $G_OOELIST_CBOX" "Flags" ""

continue:

  ; Find the Username used by Outlook for this identity and the Outlook Account Name
  ; (so we can unambiguously report which email account we are offering to reconfigure).

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field 1" "Text" "'$G_WINUSERNAME' $(PFI_LANG_OOECFG_IO_BOXHDR)"
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "pfi-cfg.ini" "Identity" "Username" "$G_WINUSERNAME"

  ReadRegStr ${L_OUTDATA} HKCU ${L_ACCOUNT} "Account Name"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 8" "State"
  StrCpy ${L_TEMP} ""
  StrCmp ${L_STATUS} "" no_padding
  StrCpy ${L_TEMP} "${IO_NL}${IO_NL}"

no_padding:
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Field 8" "State" "${L_STATUS}${L_TEMP}${L_OUTDATA}"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 9" "State"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Field 9" "State" "${L_STATUS}${L_TEMP}${L_EMAILADDRESS}"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 10" "State"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Field 10" "State" "${L_STATUS}${L_TEMP}${L_POP3SERVER}"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioB.ini" "Field 11" "State"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "ioB.ini" "Field 11" "State" "${L_STATUS}${L_TEMP}${L_USERNAME}"

  !insertmacro MUI_INSTALLOPTIONS_WRITE  "pfi-cfg.ini" "Account $G_OOELIST_INDEX" "AccountName" "${L_OUTDATA}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "pfi-cfg.ini" "Account $G_OOELIST_INDEX" "EmailAddress" "${L_EMAILADDRESS}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "pfi-cfg.ini" "Account $G_OOELIST_INDEX" "POP3server" "${L_POP3SERVER}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "pfi-cfg.ini" "Account $G_OOELIST_INDEX" "POP3username" "${L_USERNAME}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "pfi-cfg.ini" "Account $G_OOELIST_INDEX" "POP3port" "${L_PORT}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE  "pfi-cfg.ini" "Account $G_OOELIST_INDEX" "RegistryKey" "${L_ACCOUNT}"

  !insertmacro PFI_OOECONFIG_BEFORE_LOG  "$G_WINUSERNAME"    20
  !insertmacro PFI_OOECONFIG_BEFORE_LOG  "${L_OUTDATA}"      20
  !insertmacro PFI_OOECONFIG_BEFORE_LOG  "${L_EMAILADDRESS}" 30
  !insertmacro PFI_OOECONFIG_BEFORE_LOG  "${L_POP3SERVER}"   20
  !insertmacro PFI_OOECONFIG_BEFORE_LOG  "${L_USERNAME}"     20
  FileWrite $G_OOECONFIG_HANDLE "${L_PORT}\
      ${MB_NL}"

  IntCmp $G_OOELIST_INDEX 6 display_list try_next_account try_next_account

display_list:

  ; Display the Outlook account data with checkboxes enabled for those accounts we can configure

  !insertmacro MUI_INSTALLOPTIONS_INITDIALOG "ioB.ini"
  Pop $G_HWND                 ; HWND of dialog we want to modify

  !ifndef ENGLISH_MODE

    ; Do not attempt to display "bold" text when using Chinese, Japanese or Korean

    StrCmp $LANGUAGE ${LANG_SIMPCHINESE} show_page
    StrCmp $LANGUAGE ${LANG_TRADCHINESE} show_page
    StrCmp $LANGUAGE ${LANG_JAPANESE} show_page
    StrCmp $LANGUAGE ${LANG_KOREAN} show_page
  !endif

  ; In 'GetDlgItem', use (1200 + Field number - 1) to refer to the field to be changed

  GetDlgItem $G_DLGITEM $G_HWND 1200              ; Field 1 = IDENTITY label (above the box)
  CreateFont $G_FONT "MS Shell Dlg" 8 700        ; use a 'bolder' version of the font in use
  SendMessage $G_DLGITEM ${WM_SETFONT} $G_FONT 0

  !ifndef ENGLISH_MODE
    show_page:
  !endif
  !insertmacro MUI_INSTALLOPTIONS_SHOW_RETURN
  Pop ${L_TEMP}

  StrCmp ${L_TEMP} "back" abort_outlook_config
  StrCmp ${L_TEMP} "cancel" finished_outlook_config

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "pfi-cfg.ini" "Identity" "PageStatus"
  StrCmp ${L_TEMP} "updated" display_list
  StrCmp ${L_TEMP} "leftover_ticks" display_list

  Call ResetOutlookOutlookExpressAccountList

try_next_account:
  IntOp ${L_ACCT_INDEX} ${L_ACCT_INDEX} + 1
  goto next_acct

finished_the_accounts:
  IntCmp $G_OOELIST_INDEX 0 finished_outlook_config

display_list_again:
  !insertmacro MUI_INSTALLOPTIONS_INITDIALOG "ioB.ini"
  Pop $G_HWND                 ; HWND of dialog we want to modify

  !ifndef ENGLISH_MODE

    ; Do not attempt to display "bold" text when using Chinese, Japanese or Korean

    StrCmp $LANGUAGE ${LANG_SIMPCHINESE} show_page_again
    StrCmp $LANGUAGE ${LANG_TRADCHINESE} show_page_again
    StrCmp $LANGUAGE ${LANG_JAPANESE} show_page_again
    StrCmp $LANGUAGE ${LANG_KOREAN} show_page_again
  !endif

  ; In 'GetDlgItem', use (1200 + Field number - 1) to refer to the field to be changed

  GetDlgItem $G_DLGITEM $G_HWND 1200             ; Field 1 = IDENTITY label (above the box)
  CreateFont $G_FONT "MS Shell Dlg" 8 700        ; use a 'bolder' version of the font in use
  SendMessage $G_DLGITEM ${WM_SETFONT} $G_FONT 0

  !ifndef ENGLISH_MODE
    show_page_again:
  !endif
  !insertmacro MUI_INSTALLOPTIONS_SHOW_RETURN
  Pop ${L_TEMP}

  StrCmp ${L_TEMP} "back" abort_outlook_config
  StrCmp ${L_TEMP} "cancel" finished_outlook_config

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "pfi-cfg.ini" "Identity" "PageStatus"
  StrCmp ${L_TEMP} "updated" display_list_again
  StrCmp ${L_TEMP} "leftover_ticks" display_list_again

  Call ResetOutlookOutlookExpressAccountList

finished_outlook_config:
  FileWrite $G_OOECONFIG_HANDLE "${MB_NL}\
      $(PFI_LANG_OOECFG_LOG_END)\
      ${MB_NL}${MB_NL}"
  FileClose $G_OOECONFIG_HANDLE

  FileWrite $G_OOECHANGES_HANDLE "${MB_NL}\
      $(PFI_LANG_OOECFG_LOG_END)\
      ${MB_NL}${MB_NL}"
  FileClose $G_OOECHANGES_HANDLE

exit:
  Pop ${L_USERNAME}
  Pop ${L_TEMP}
  Pop ${L_STATUS}
  Pop ${L_PORT}
  Pop ${L_POP3SERVER}
  Pop ${L_OUTLOOK}
  Pop ${L_OUTDATA}
  Pop ${L_EMAILADDRESS}
  Pop ${L_ACCT_INDEX}
  Pop ${L_ACCOUNT}

  !undef L_ACCOUNT
  !undef L_ACCT_INDEX
  !undef L_EMAILADDRESS
  !undef L_OUTDATA
  !undef L_OUTLOOK
  !undef L_POP3SERVER
  !undef L_PORT
  !undef L_STATUS
  !undef L_TEMP
  !undef L_USERNAME

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: CheckOutlookRequests
#
# This function is used to confirm any Outlook account reconfiguration requests
#--------------------------------------------------------------------------

Function CheckOutlookRequests

  !define L_CBOX_INDEX   $R9
  !define L_CBOX_STATE   $R8
  !define L_DATA_INDEX   $R7
  !define L_REGKEY       $R6
  !define L_TEMP         $R5
  !define L_TEXT_ENTRY   $R4
  !define L_IDENTITY     $R3
  !define L_UNDO         $R2

  !define L_ACCOUNTNAME   $9
  !define L_EMAILADDRESS  $8
  !define L_POP3SERVER    $7
  !define L_POP3USERNAME  $6
  !define L_POP3PORT      $5

  Push ${L_CBOX_INDEX}
  Push ${L_CBOX_STATE}
  Push ${L_DATA_INDEX}
  Push ${L_REGKEY}
  Push ${L_TEMP}
  Push ${L_TEXT_ENTRY}
  Push ${L_IDENTITY}
  Push ${L_UNDO}

  Push ${L_ACCOUNTNAME}
  Push ${L_EMAILADDRESS}
  Push ${L_POP3SERVER}
  Push ${L_POP3USERNAME}
  Push ${L_POP3PORT}

  ; If user has cancelled the reconfiguration, there is nothing to do here

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "ioB.ini" "Settings" "NumFields"
  StrCmp ${L_TEMP} "1" exit

  ; 'PageStatus' will be set to 'updated' or 'leftover_ticks' when the page needs to be
  ; redisplayed to confirm which accounts (if any) have been reconfigured

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "pfi-cfg.ini" "Identity" "PageStatus" "clean"

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_IDENTITY} "pfi-cfg.ini" "Identity" "Username"

  StrCpy ${L_CBOX_INDEX} 12
  StrCpy ${L_DATA_INDEX} 1

next_row:
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_CBOX_STATE} "ioB.ini" "Field ${L_CBOX_INDEX}" "Flags"
  StrCmp ${L_CBOX_STATE} "DISABLED" continue

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_CBOX_STATE} "ioB.ini" "Field ${L_CBOX_INDEX}" "State"
  StrCmp ${L_CBOX_STATE} "0" continue

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_ACCOUNTNAME}  "pfi-cfg.ini" "Account ${L_DATA_INDEX}" "AccountName"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_EMAILADDRESS} "pfi-cfg.ini" "Account ${L_DATA_INDEX}" "EMailAddress"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_POP3SERVER}   "pfi-cfg.ini" "Account ${L_DATA_INDEX}" "POP3server"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_POP3USERNAME} "pfi-cfg.ini" "Account ${L_DATA_INDEX}" "POP3username"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_POP3PORT}     "pfi-cfg.ini" "Account ${L_DATA_INDEX}" "POP3port"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_REGKEY}       "pfi-cfg.ini" "Account ${L_DATA_INDEX}" "RegistryKey"

  MessageBox MB_YESNO \
      "$(PFI_LANG_OUTCFG_MBIDENTITY) ${L_IDENTITY}\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_OUTCFG_MBACCOUNT) ${L_ACCOUNTNAME}\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_OOECFG_MBEMAIL) ${L_EMAILADDRESS}\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_OOECFG_MBSERVER) 127.0.0.1 \
                                   ($(PFI_LANG_OOECFG_MBOLDVALUE) '${L_POP3SERVER}')\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_OOECFG_MBUSERNAME) ${L_POP3SERVER}$G_SEPARATOR${L_POP3USERNAME} \
                                     ($(PFI_LANG_OOECFG_MBOLDVALUE) '${L_POP3USERNAME}')\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_OOECFG_MBOEPORT) $G_POP3 \
                                   ($(PFI_LANG_OOECFG_MBOLDVALUE) '${L_POP3PORT}')\
      ${MB_NL}${MB_NL}${MB_NL}\
      $(PFI_LANG_OOECFG_MBQUESTION)\
      " IDNO ignore_tick

  !insertmacro MUI_INSTALLOPTIONS_WRITE    "pfi-cfg.ini" "Identity" "PageStatus" "updated"
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "ioB.ini" "Field ${L_CBOX_INDEX}" "Flags" "DISABLED"

  ReadINIStr  ${L_UNDO} "$G_USERDIR\pfi-outlook.ini" "History" "ListSize"
  StrCmp ${L_UNDO} "" 0 update_list_size
  StrCpy ${L_UNDO} 1
  WriteINIStr "$G_USERDIR\pfi-outlook.ini" "History" "ListSize" "1"
  Goto add_entry

update_list_size:
  IntOp ${L_UNDO} ${L_UNDO} + 1
  WriteINIStr "$G_USERDIR\pfi-outlook.ini" "History" "ListSize" "${L_UNDO}"

add_entry:
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_TEMP} "pfi-cfg.ini" "DateTime" "Outlook"
  WriteINIStr "$G_USERDIR\pfi-outlook.ini" "History" "Undo-${L_UNDO}" "Created on ${L_TEMP}"
  WriteINIStr "$G_USERDIR\pfi-outlook.ini" "History" "User-${L_UNDO}" "$G_WINUSERNAME"
  WriteINIStr "$G_USERDIR\pfi-outlook.ini" "History" "Type-${L_UNDO}" "$G_WINUSERTYPE"
  WriteINIStr "$G_USERDIR\pfi-outlook.ini" "History" "IniV-${L_UNDO}" "3"

  WriteINIStr "$G_USERDIR\pfi-outlook.ini" "Undo-${L_UNDO}" "Restored" "No"
  WriteINIStr "$G_USERDIR\pfi-outlook.ini" "Undo-${L_UNDO}" "RegistryKey" "${L_REGKEY}"
  WriteINIStr "$G_USERDIR\pfi-outlook.ini" "Undo-${L_UNDO}" "POP3UserName" "${L_POP3USERNAME}"
  WriteINIStr "$G_USERDIR\pfi-outlook.ini" "Undo-${L_UNDO}" "POP3Server" "${L_POP3SERVER}"
  WriteINIStr "$G_USERDIR\pfi-outlook.ini" "Undo-${L_UNDO}" "POP3Port" "${L_POP3PORT}"

  ; Reconfigure the Outlook account

  WriteRegStr HKCU ${L_REGKEY} "POP3 User Name" "${L_POP3SERVER}$G_SEPARATOR${L_POP3USERNAME}"
  WriteRegStr HKCU ${L_REGKEY} "POP3 Server" "127.0.0.1"
  WriteRegDWORD HKCU ${L_REGKEY} "POP3 Port" $G_POP3

  !insertmacro PFI_OOECONFIG_CHANGES_LOG  "${L_IDENTITY}"    20
  !insertmacro PFI_OOECONFIG_CHANGES_LOG  "${L_ACCOUNTNAME}" 20
  !insertmacro PFI_OOECONFIG_CHANGES_LOG  "127.0.0.1"        17
  !insertmacro PFI_OOECONFIG_CHANGES_LOG  "${L_POP3SERVER}$G_SEPARATOR${L_POP3USERNAME}"  40
  FileWrite $G_OOECHANGES_HANDLE "$G_POP3\
      ${MB_NL}"

  Goto continue

ignore_tick:
  !insertmacro MUI_INSTALLOPTIONS_WRITE    "pfi-cfg.ini" "Identity" "PageStatus" "leftover_ticks"

continue:
  IntOp ${L_CBOX_INDEX} ${L_CBOX_INDEX} + 1
  IntOp ${L_DATA_INDEX} ${L_DATA_INDEX} + 1
  IntCmp ${L_DATA_INDEX} $G_OOELIST_INDEX next_row next_row

exit:
  Pop ${L_POP3PORT}
  Pop ${L_POP3USERNAME}
  Pop ${L_POP3SERVER}
  Pop ${L_EMAILADDRESS}
  Pop ${L_ACCOUNTNAME}

  Pop ${L_UNDO}
  Pop ${L_IDENTITY}
  Pop ${L_TEXT_ENTRY}
  Pop ${L_TEMP}
  Pop ${L_REGKEY}
  Pop ${L_DATA_INDEX}
  Pop ${L_CBOX_STATE}
  Pop ${L_CBOX_INDEX}

  !undef L_CBOX_INDEX
  !undef L_CBOX_STATE
  !undef L_DATA_INDEX
  !undef L_REGKEY
  !undef L_TEMP
  !undef L_TEXT_ENTRY
  !undef L_IDENTITY
  !undef L_UNDO

  !undef L_ACCOUNTNAME
  !undef L_EMAILADDRESS
  !undef L_POP3SERVER
  !undef L_POP3USERNAME
  !undef L_POP3PORT

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: SetEudoraPage_Init
#
# This function adds language texts to the INI file used by the "SetEudoraPage" function
# (to make the custom page use the language selected by the user for the installer)
#--------------------------------------------------------------------------

Function SetEudoraPage_Init

  ; Ensure custom page matches the selected language (left-to-right or right-to-left order)

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Settings" "RTL" "$(^RTL)"

  ; We use the 'Back' button as an easy way to skip the 'Eudora' reconfiguration

  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" \
              "Settings" "BackButtonText" "$(PFI_LANG_MAILCFG_IO_SKIPONE)"

  !insertmacro PFI_IO_TEXT "ioE.ini" "2" "$(PFI_LANG_EUCFG_IO_CHECKBOX)"
  !insertmacro PFI_IO_TEXT "ioE.ini" "3" "$(PFI_LANG_EUCFG_IO_RESTORE)"

  !insertmacro PFI_IO_TEXT "ioE.ini" "5" "$(PFI_LANG_EUCFG_IO_EMAIL)"
  !insertmacro PFI_IO_TEXT "ioE.ini" "6" "$(PFI_LANG_EUCFG_IO_SERVER)"
  !insertmacro PFI_IO_TEXT "ioE.ini" "7" "$(PFI_LANG_EUCFG_IO_USERNAME)"
  !insertmacro PFI_IO_TEXT "ioE.ini" "8" "$(PFI_LANG_EUCFG_IO_POP3PORT)"

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: SetEudoraPage (generates a custom page)
#
# This function is used to reconfigure Eudora personalities
#--------------------------------------------------------------------------

Function SetEudoraPage

  !define L_ININAME   $R9   ; used to get full pathname of the Eudora.ini file
  !define L_LENGTH    $R8   ; used when determining L_ININAME
  !define L_STATUS    $R7
  !define L_TEMP      $R6
  !define L_TERMCHR   $R5   ; used when determining L_ININAME

  !define L_ACCOUNT   $R4   ; persona details extracted from Eudora.ini file
  !define L_EMAIL     $R3   ; ditto
  !define L_SERVER    $R2   ; ditto
  !define L_USER      $R1   ; ditto
  !define L_PERPORT   $R0   ; ditto

  !define L_INDEX     $9   ; used when updating the undo history
  !define L_PERSONA   $8   ; persona name ('Dominant' entry is called 'Settings')
  !define L_CFGTIME   $7   ; timestamp used when updating the undo history

  !define L_DOMPORT   $6  ; current pop3 port for Dominant personality
  !define L_PREVDOM   $5  ; Dominant personality's pop3 port BEFORE we started processing

  Push ${L_ININAME}
  Push ${L_LENGTH}
  Push ${L_STATUS}
  Push ${L_TEMP}
  Push ${L_TERMCHR}

  Push ${L_ACCOUNT}
  Push ${L_EMAIL}
  Push ${L_SERVER}
  Push ${L_USER}
  Push ${L_PERPORT}

  Push ${L_INDEX}
  Push ${L_PERSONA}
  Push ${L_CFGTIME}

  Push ${L_DOMPORT}
  Push ${L_PREVDOM}

  ; Check if user decided to skip all email client configuration

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "pfi-cfg.ini" "ClientEXE" "ConfigStatus"
  StrCmp ${L_STATUS} "SkipAll" exit

  ; Look for Eudora registry entry which identifies the relevant INI file

  ReadRegStr ${L_STATUS} HKCU "Software\Qualcomm\Eudora\CommandLine" "current"
  StrCmp ${L_STATUS} "" 0 extract_INI_path

  ; No data in registry. Did the 'SetEmailClient' function find a path for the Eudora program?

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "pfi-cfg.ini" "ClientEXE" "Eudora"
  StrCmp ${L_STATUS} "" exit

  ; Look for the Eudora INI file

  Push ${L_STATUS}
  Call PFI_GetParent
  Pop ${L_ININAME}
  StrCpy ${L_ININAME} "${L_ININAME}\EUDORA.INI"
  IfFileExists "${L_ININAME}" gotname exit

extract_INI_path:

  ; Extract full path to the Eudora INI file

  StrCpy ${L_TEMP} -1
  StrLen ${L_LENGTH} ${L_STATUS}
  IntOp ${L_LENGTH} 0 - ${L_LENGTH}

  ; Check if we need to look for a space or double-quotes

  StrCpy ${L_ININAME} ${L_STATUS} 1 ${L_TEMP}
  StrCpy ${L_TERMCHR} '"'
  StrCmp ${L_ININAME} '"' loop
  StrCpy ${L_TERMCHR} ' '

  ; We want the last of the three filename 'tokens' in the value extracted from the registry

loop:
  IntOp ${L_TEMP} ${L_TEMP} - 1
  StrCpy ${L_ININAME} ${L_STATUS} 1 ${L_TEMP}
  StrCmp ${L_ININAME} ${L_TERMCHR} extract
  IntCmp ${L_TEMP} ${L_LENGTH} extract
  Goto loop

extract:
  IntOp ${L_TEMP} ${L_TEMP} + 1
  StrCpy ${L_ININAME} ${L_STATUS} "" ${L_TEMP}
  StrCmp ${L_TERMCHR} ' ' gotname
  StrCpy ${L_ININAME} ${L_ININAME} -1

gotname:
  !insertmacro MUI_HEADER_TEXT "$(PFI_LANG_EUCFG_TITLE)" "$(PFI_LANG_EUCFG_SUBTITLE)"

  ; If Eudora is running, ask the user to shut it down now (user may ignore our request)

check_if_running:
  FindWindow ${L_STATUS} "EudoraMainWindow"
  IsWindow ${L_STATUS} 0 continue

  MessageBox MB_ABORTRETRYIGNORE|MB_ICONSTOP|MB_DEFBUTTON2 "$(PFI_LANG_MBCLIENT_EUD)\
             ${MB_NL}${MB_NL}\
             $(PFI_LANG_MBCLIENT_STOP_1)\
             ${MB_NL}${MB_NL}\
             $(PFI_LANG_MBCLIENT_STOP_2)\
             ${MB_NL}${MB_NL}\
             $(PFI_LANG_MBCLIENT_STOP_3)"\
             IDRETRY check_if_running IDIGNORE continue

abort_eudora_config:

  ; Either 'Abort' has been selected so we do not offer to reconfigure any Eudora accounts
  ; or 'Cancel' has been selected during the Eudora configuration process so we stop now

  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioE.ini" "Settings" "NumFields" "1"
  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioE.ini" "Settings" "BackEnabled" "0"
  !insertmacro PFI_IO_TEXT "ioE.ini" "1" "$(PFI_LANG_EUCFG_IO_CANCELLED)"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioE.ini"
  Goto exit

continue:
  !insertmacro MUI_INSTALLOPTIONS_WRITE   "ioE.ini" "Settings" "BackEnabled" "1"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioE.ini" "Field 2" "Text"
  StrCpy ${L_STATUS} "${L_STATUS} ($(PFI_LANG_EUCFG_IO_POP3PORT) $G_POP3)"
  !insertmacro PFI_IO_TEXT "ioE.ini" "2" "${L_STATUS}"

  Call PFI_GetDateTimeStamp
  Pop ${L_CFGTIME}

  ; Normally all Eudora personalities use whatever port the 'Dominant' personality uses.
  ; If the default POP3 port is used then there will be no 'POPPort' defined in Eudora.ini file

  ReadINIStr ${L_DOMPORT} "${L_ININAME}" "Settings" "POPPort"
  StrCmp ${L_DOMPORT} "" 0 not_implied_domport
  StrCpy ${L_DOMPORT} "Default"

not_implied_domport:
  StrCpy ${L_PREVDOM} ${L_DOMPORT}

  ; The <Dominant> personality data is stored separately from that of the other personalities

  !insertmacro PFI_IO_TEXT "ioE.ini" "4" "$(PFI_LANG_EUCFG_IO_DOMINANT)"
  StrCpy ${L_PERSONA} "Settings"
  StrCpy ${L_INDEX} -1
  Goto common_to_all

get_next_persona:
  IntOp ${L_INDEX} ${L_INDEX} + 1
  ReadINIStr ${L_PERSONA}  "${L_ININAME}" "Personalities" "Persona${L_INDEX}"
  StrCmp ${L_PERSONA} "" exit
  StrCpy ${L_TEMP} ${L_PERSONA} "" 8

  !insertmacro PFI_IO_TEXT "ioE.ini" "4" "'${L_TEMP}' $(PFI_LANG_EUCFG_IO_PERSONA)"

common_to_all:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 2" "State" "0"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 2" "Flags" ""
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 3" "Flags" ""

  ReadINIStr ${L_ACCOUNT} "${L_ININAME}" "${L_PERSONA}" "POPAccount"
  ReadINIStr ${L_EMAIL}   "${L_ININAME}" "${L_PERSONA}" "ReturnAddress"
  ReadINIStr ${L_SERVER}  "${L_ININAME}" "${L_PERSONA}" "POPServer"
  ReadINIStr ${L_USER}    "${L_ININAME}" "${L_PERSONA}" "LoginName"
  ReadINIStr ${L_STATUS}  "${L_ININAME}" "${L_PERSONA}" "UsesPOP"

  StrCmp ${L_PERSONA} "Settings" 0 not_dominant
  StrCpy ${L_PERPORT} ${L_DOMPORT}
  Goto check_account

not_dominant:
  ReadINIStr ${L_PERPORT} "${L_ININAME}" "${L_PERSONA}" "POPPort"
  StrCmp ${L_PERPORT} "" 0 check_account
  StrCpy ${L_PERPORT} "Dominant"

check_account:
  StrCmp ${L_ACCOUNT} "" 0 check_server
  StrCpy ${L_ACCOUNT} "N/A"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 2" "Flags" "DISABLED"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 3" "Flags" "DISABLED"

check_server:
  StrCmp ${L_SERVER} "127.0.0.1" disable
  StrCmp ${L_SERVER} "localhost" disable
  StrCmp ${L_SERVER} "" 0 check_username
  StrCpy ${L_SERVER} "N/A"

disable:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 2" "Flags" "DISABLED"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 3" "Flags" "DISABLED"

check_username:
  StrCmp ${L_USER} "" 0 check_status
  StrCpy ${L_USER} "N/A"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 2" "Flags" "DISABLED"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 3" "Flags" "DISABLED"

check_status:
  StrCmp ${L_STATUS} 1 update_persona_details
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 2" "Flags" "DISABLED"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 3" "Flags" "DISABLED"

update_persona_details:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 9"  "Text" "${L_EMAIL}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 10" "Text" "${L_SERVER}"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 11" "Text" "${L_USER}"

  StrCmp ${L_PERPORT} "Default" default_pop3
  StrCmp ${L_PERPORT} "Dominant" 0 explicit_perport
  StrCmp ${L_PREVDOM} "Default" 0 explicit_domport
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 12" "Text" "(110)"
  Goto update_intro

default_pop3:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 12" "Text" "Default (110)"
  Goto update_intro

explicit_domport:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 12" "Text" "(${L_PREVDOM})"
  Goto update_intro

explicit_perport:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioE.ini" "Field 12" "Text" "${L_PERPORT}"

update_intro:
  StrCpy ${L_TEMP} "."
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioE.ini" "Field 2" "Flags"
  StrCmp ${L_STATUS} "DISABLED" write_intro
  StrCpy ${L_TEMP} "$(PFI_LANG_EUCFG_IO_INTRO_2)"

write_intro:
  !insertmacro PFI_IO_TEXT "ioE.ini" "1" "$(PFI_LANG_EUCFG_IO_INTRO_1)${L_TEMP}"

  !insertmacro MUI_INSTALLOPTIONS_INITDIALOG "ioE.ini"
  Pop $G_HWND                 ; HWND of dialog we want to modify

  !ifndef ENGLISH_MODE

    ; Do not attempt to display "bold" text when using Chinese, Japanese or Korean

    StrCmp $LANGUAGE ${LANG_SIMPCHINESE} show_page
    StrCmp $LANGUAGE ${LANG_TRADCHINESE} show_page
    StrCmp $LANGUAGE ${LANG_JAPANESE} show_page
    StrCmp $LANGUAGE ${LANG_KOREAN} show_page
  !endif

  ; In 'GetDlgItem', use (1200 + Field number - 1) to refer to the field to be changed

  GetDlgItem $G_DLGITEM $G_HWND 1203             ; Field 4 = PERSONA (text in groupbox frame)
  CreateFont $G_FONT "MS Shell Dlg" 8 700        ; use a 'bolder' version of the font in use
  SendMessage $G_DLGITEM ${WM_SETFONT} $G_FONT 0

  !ifndef ENGLISH_MODE
    show_page:
  !endif
  !insertmacro MUI_INSTALLOPTIONS_SHOW_RETURN
  Pop ${L_STATUS}
  StrCmp ${L_STATUS} "back" abort_eudora_config

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_STATUS} "ioE.ini" "Field 2" "State"
  StrCmp ${L_STATUS} "1" reconfigure_persona

  ; This personality is not to be reconfigured. However, if we have changed the POP3 port for
  ; the Dominant personality and this unchanged entry 'inherited' the Dominant personality's
  ; POP3 port then we need to ensure the unchanged port uses the old port setting to avoid
  ; 'breaking' the unchanged personality

  StrCmp ${L_PREVDOM} ${L_DOMPORT} get_next_persona
  StrCmp ${L_PERPORT} "Dominant" 0 get_next_persona

  ReadINIStr  ${L_STATUS} "$G_USERDIR\pfi-eudora.ini" "History" "ListSize"
  IntOp ${L_STATUS} ${L_STATUS} + 1
  WriteINIStr "$G_USERDIR\pfi-eudora.ini" "History" "ListSize" "${L_STATUS}"

  WriteINIStr "$G_USERDIR\pfi-eudora.ini" "History" "Undo-${L_STATUS}" "Created on ${L_CFGTIME}"
  WriteINIStr "$G_USERDIR\pfi-eudora.ini" "History" "Path-${L_STATUS}" "${L_ININAME}"
  WriteINIStr "$G_USERDIR\pfi-eudora.ini" "History" "User-${L_STATUS}" "$G_WINUSERNAME"
  WriteINIStr "$G_USERDIR\pfi-eudora.ini" "History" "Type-${L_STATUS}" "$G_WINUSERTYPE"
  WriteINIStr "$G_USERDIR\pfi-eudora.ini" "History" "IniV-${L_STATUS}" "2"

  WriteINIStr "$G_USERDIR\pfi-eudora.ini" "Undo-${L_STATUS}" "Restored" "No"
  WriteINIStr "$G_USERDIR\pfi-eudora.ini" "Undo-${L_STATUS}" "Persona" "${L_PERSONA}"
  WriteINIStr "$G_USERDIR\pfi-eudora.ini" "Undo-${L_STATUS}" "POPAccount" "*.*"
  WriteINIStr "$G_USERDIR\pfi-eudora.ini" "Undo-${L_STATUS}" "POPServer" "*.*"
  WriteINIStr "$G_USERDIR\pfi-eudora.ini" "Undo-${L_STATUS}" "LoginName" "*.*"
  WriteINIStr "$G_USERDIR\pfi-eudora.ini" "Undo-${L_STATUS}" "POPPort" "Dominant"

  StrCmp ${L_PREVDOM} "Default" inherit_default_pop3
  WriteINIStr "${L_ININAME}" "${L_PERSONA}" "POPPort" ${L_PREVDOM}
  Goto get_next_persona

inherit_default_pop3:
  WriteINIStr "${L_ININAME}" "${L_PERSONA}" "POPPort" "110"
  Goto get_next_persona

reconfigure_persona:
  ReadINIStr  ${L_STATUS} "$G_USERDIR\pfi-eudora.ini" "History" "ListSize"
  StrCmp ${L_STATUS} "" 0 update_list_size
  StrCpy ${L_STATUS} 1
  WriteINIStr "$G_USERDIR\pfi-eudora.ini" "History" "ListSize" "1"
  Goto add_entry

update_list_size:
  IntOp ${L_STATUS} ${L_STATUS} + 1
  WriteINIStr "$G_USERDIR\pfi-eudora.ini" "History" "ListSize" "${L_STATUS}"

add_entry:
  WriteINIStr "$G_USERDIR\pfi-eudora.ini" "History" "Undo-${L_STATUS}" "Created on ${L_CFGTIME}"
  WriteINIStr "$G_USERDIR\pfi-eudora.ini" "History" "Path-${L_STATUS}" "${L_ININAME}"
  WriteINIStr "$G_USERDIR\pfi-eudora.ini" "History" "User-${L_STATUS}" "$G_WINUSERNAME"
  WriteINIStr "$G_USERDIR\pfi-eudora.ini" "History" "Type-${L_STATUS}" "$G_WINUSERTYPE"
  WriteINIStr "$G_USERDIR\pfi-eudora.ini" "History" "IniV-${L_STATUS}" "2"

  WriteINIStr "$G_USERDIR\pfi-eudora.ini" "Undo-${L_STATUS}" "Restored" "No"
  WriteINIStr "$G_USERDIR\pfi-eudora.ini" "Undo-${L_STATUS}" "Persona" "${L_PERSONA}"
  WriteINIStr "$G_USERDIR\pfi-eudora.ini" "Undo-${L_STATUS}" "POPAccount" "${L_ACCOUNT}"
  WriteINIStr "$G_USERDIR\pfi-eudora.ini" "Undo-${L_STATUS}" "POPServer" "${L_SERVER}"
  WriteINIStr "$G_USERDIR\pfi-eudora.ini" "Undo-${L_STATUS}" "LoginName" "${L_USER}"
  WriteINIStr "$G_USERDIR\pfi-eudora.ini" "Undo-${L_STATUS}" "POPPort" "${L_PERPORT}"

  WriteINIStr "${L_ININAME}" "${L_PERSONA}" "POPAccount" "${L_SERVER}$G_SEPARATOR${L_USER}@127.0.0.1"
  WriteINIStr "${L_ININAME}" "${L_PERSONA}" "POPServer"  "127.0.0.1"
  WriteINIStr "${L_ININAME}" "${L_PERSONA}" "LoginName"  "${L_SERVER}$G_SEPARATOR${L_USER}"
  WriteINIStr "${L_ININAME}" "${L_PERSONA}" "POPPort"    $G_POP3
  StrCmp ${L_PERSONA} "Settings" 0 get_next_persona
  StrCpy ${L_DOMPORT} $G_POP3
  Goto get_next_persona

exit:
  Pop ${L_PREVDOM}
  Pop ${L_DOMPORT}

  Pop ${L_CFGTIME}
  Pop ${L_PERSONA}
  Pop ${L_INDEX}

  Pop ${L_PERPORT}
  Pop ${L_USER}
  Pop ${L_SERVER}
  Pop ${L_EMAIL}
  Pop ${L_ACCOUNT}

  Pop ${L_TERMCHR}
  Pop ${L_TEMP}
  Pop ${L_STATUS}
  Pop ${L_LENGTH}
  Pop ${L_ININAME}

  !undef L_ININAME
  !undef L_LENGTH
  !undef L_STATUS
  !undef L_TEMP
  !undef L_TERMCHR

  !undef L_ACCOUNT
  !undef L_EMAIL
  !undef L_SERVER
  !undef L_USER
  !undef L_PERPORT

  !undef L_INDEX
  !undef L_PERSONA
  !undef L_CFGTIME

  !undef L_DOMPORT
  !undef L_PREVDOM

FunctionEnd

#--------------------------------------------------------------------------
# Installer Function: CheckEudoraRequests
#
# This function is used to confirm any Eudora personality reconfiguration requests
#--------------------------------------------------------------------------

Function CheckEudoraRequests

  !define L_EMAIL     $R9
  !define L_PERSONA   $R8
  !define L_PORT      $R7
  !define L_SERVER    $R6
  !define L_USER      $R5

  Push ${L_EMAIL}
  Push ${L_PERSONA}
  Push ${L_PORT}
  Push ${L_SERVER}
  Push ${L_USER}

  ; If user has cancelled Eudora reconfiguration, there is nothing to do

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_EMAIL} "ioE.ini" "Settings" "NumFields"
  StrCmp ${L_EMAIL} "1" exit

  ; If user has not requested reconfiguration of this account, there is nothing to do

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_PERSONA} "ioE.ini" "Field 2" "State"
  StrCmp ${L_PERSONA} "0" exit

  ; User has ticked the 'Reconfigure' box so show the changes we are about to make

  !insertmacro MUI_INSTALLOPTIONS_READ ${L_PERSONA} "ioE.ini" "Field 4" "Text"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_EMAIL}   "ioE.ini" "Field 9" "Text"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_SERVER}  "ioE.ini" "Field 10" "Text"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_USER}    "ioE.ini" "Field 11" "Text"
  !insertmacro MUI_INSTALLOPTIONS_READ ${L_PORT}    "ioE.ini" "Field 12" "Text"

  MessageBox MB_YESNO \
      "${L_PERSONA}\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_OOECFG_MBEMAIL) ${L_EMAIL}\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_OOECFG_MBSERVER) 127.0.0.1 \
                                   ($(PFI_LANG_OOECFG_MBOLDVALUE) '${L_SERVER}')\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_OOECFG_MBUSERNAME) ${L_SERVER}$G_SEPARATOR${L_USER} \
                                     ($(PFI_LANG_OOECFG_MBOLDVALUE) '${L_USER}')\
      ${MB_NL}${MB_NL}\
      $(PFI_LANG_OOECFG_MBOEPORT) $G_POP3 \
                                   ($(PFI_LANG_OOECFG_MBOLDVALUE) '${L_PORT}')\
      ${MB_NL}${MB_NL}${MB_NL}\
      $(PFI_LANG_OOECFG_MBQUESTION)\
      " IDYES exit
  Pop ${L_USER}
  Pop ${L_SERVER}
  Pop ${L_PORT}
  Pop ${L_PERSONA}
  Pop ${L_EMAIL}
  Abort

exit:
  Pop ${L_USER}
  Pop ${L_SERVER}
  Pop ${L_PORT}
  Pop ${L_PERSONA}
  Pop ${L_EMAIL}

  !undef L_EMAIL
  !undef L_PERSONA
  !undef L_PORT
  !undef L_SERVER
  !undef L_USER

FunctionEnd

#--------------------------------------------------------------------------
# End of 'adduser-EmailConfig.nsh'
#--------------------------------------------------------------------------
