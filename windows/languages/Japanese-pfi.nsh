#--------------------------------------------------------------------------
# Japanese-pfi.nsh
#
# This file contains the "Japanese" text strings used by the Windows installer
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
# Translation created by: Junya Ishihara (UTF-8: E79FB3 E58E9F E6B7B3 E4B99F) (jishiha at users.sourceforge.net)
# Translation updated by: Junya Ishihara (UTF-8: E79FB3 E58E9F E6B7B3 E4B99F) (jishiha at users.sourceforge.net) 
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

!define PFI_LANG  "JAPANESE"

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
"このウィザードは、POPFile のインストールをガイドしていきます。\r\n\r\nセットアップを開始する前に、他のすべてのアプリケーションを終了することを推奨します。\r\n\r\n$_CLICK"

!insertmacro PFI_LANG_STRING PFI_LANG_WELCOME_ADMIN_TEXT \
"IMPORTANT NOTICE:\r\n\r\nThe current user does NOT have 'Administrator' rights.\r\n\r\nIf multi-user support is required, it is recommended that you cancel this installation and use an 'Administrator' account to install POPFile."

#--------------------------------------------------------------------------
# Standard MUI Page - Finish
#
# The PFI_LANG_FINISH_RUN_TEXT text should be a short phrase (not a long paragraph)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_FINISH_RUN_TEXT \
"POPFile ユーザーインターフェースを起動"

#==========================================================================
# Strings used for custom pages, message boxes and banners
#==========================================================================

#--------------------------------------------------------------------------
# General purpose banner text (also suitable for page titles/subtitles)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_BANNER_1    "お待ち下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_BANNER_2    "この処理にはしばらく時間がかかります..."

#--------------------------------------------------------------------------
# Message box warning that a previous installation has been found
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_1  "次の場所に以前にインストールされた POPFile が見つかりました:"
!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_2  "Do you want to upgrade it ?"

#--------------------------------------------------------------------------
# Startup message box offering to display the Release Notes
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_1        "POPFile のリリースノートを表示しますか？"
!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_2        "アップグレードの場合は「Yes」を推奨します。(アップグレードの前にバックアップを取ることを推奨します。)"

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

!insertmacro PFI_LANG_STRING DESC_SecPOPFile              "POPFile のコアファイルをインストールします。最小バージョンの Perl も含みます。"
!insertmacro PFI_LANG_STRING DESC_SecSkins                "POPFile ユーザーインターフェースのデザインを変えることができる POPFile スキンをインストールします。"
!insertmacro PFI_LANG_STRING DESC_SecLangs                "POPFile UI の英語以外のバージョンをインストールします。"

#--------------------------------------------------------------------------
# Custom Page - POPFile Installation Options
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_TITLE       "POPFile インストールオプション"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_SUBTITLE    "これらのオプションは必要でない限り変更しないで下さい。"

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_POP3     "POP3 接続に使用するデフォルトポート番号を選んで下さい。(推奨値:110)"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_GUI      "「ユーザーインターフェース」に使用するデフォルトポート番号を選んで下さい。(推奨値:8080)"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_STARTUP  "Windows の起動時に POPFile を自動的に起動する。(バックグラウンドで起動)"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_WARNING  "重要な警告"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_MESSAGE  "POPFile のアップグレードの場合 --- インストーラーは現在のバージョンをシャットダウンします。"

; Message Boxes used when validating user's selections

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_1    "無効な POP3 ポート番号:"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_2    "ポート番号には 1 から 65535 までの番号を選んで下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_3    "POP3 ポート番号を変更して下さい。"

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_1     "無効な「ユーザーインターフェース」ポート番号:"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_2     "ポート番号には 1 から 65535 までの番号を選んで下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_3     "「ユーザーインターフェース」ポート番号を変更して下さい。"

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_1    "POP3 ポート番号には「ユーザーインターフェース」ポート番号と異なる番号を選んで下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_2    "ポート番号を変更して下さい。"

#--------------------------------------------------------------------------
# Standard MUI Page - Installing POPfile
#--------------------------------------------------------------------------

; Installation Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_UPGRADE   "アップグレードインストールかどうかチェックしています..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_CORE      "POPFile のコアファイルをインストール中..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_PERL      "最小バージョンの Perl をインストール中..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SHORT     "POPFile のショートカットを作成中..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_FFCBACK   "corpus(コーパス、単語ファイル)のバックアップを作成中。しばらくお待ち下さい..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SKINS     "POPFile のスキンファイルをインストール中..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_LANGS     "POPFile UI 言語ファイルをインストール中..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_ENDSEC    "「次へ」をクリックして続行して下さい。"

; Installation Log Messages

!insertmacro PFI_LANG_STRING PFI_LANG_INST_LOG_1          "以前のバージョンの POPFile をシャットダウンします。ポート番号:"

; Message Box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_1          "は以前にインストールされたファイルです。"
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_2          "アップデートしてもよろしいですか？"
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_3          "アップデートするには「Yes」をクリックして下さい。(古いファイルは次の名前で保存されます:"
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_4          "古いファイルを残すには「No」をクリックして下さい。(新しいファイルは次の名前で保存されます:"

!insertmacro PFI_LANG_STRING PFI_LANG_MBCFGBK_1           "ファイル"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCFGBK_2           "のバックアップは既に存在します。"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCFGBK_3           "上書きしてもよろしいですか？"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCFGBK_4           "上書きするには「Yes」、バックアップをスキップするなら「No」をクリックしてください。"

!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_1         "Unable to shutdown POPFile automatically."
!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_2         "Please shutdown POPFile manually now."
!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_3         "When POPFile has been shutdown, click 'OK' to continue."

!insertmacro PFI_LANG_STRING PFI_LANG_MBFFCERR_1          "Error detected when the installer tried to backup the old corpus."

#--------------------------------------------------------------------------
# Custom Page - POPFile Classification Bucket Creation
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_TITLE           "POPFile の分類用のバケツ作成"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_SUBTITLE        "POPFile はメールを分類するのに最低二つのバケツを必要とします。"

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_INTRO        "インストール終了後も、必要に応じて簡単にバケツの数も名前も変更することができます。\r\n\r\nバケツの名前にはアルファベットの小文字、0 から 9 の数字、- または _ からなる単語を使用して下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_CREATE       "以下のリストより選ぶか、適当な名前を入力して新しいバケツを作成して下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_DELETE       "一つかそれ以上のバケツをリストより削除するには、対応する「削除」ボックスにチェックを入れて「続行」ボタンをクリックして下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_LISTHDR      "POPFile に使用するバケツ"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_REMOVE       "削除"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_CONTINUE     "続行"

; Text strings used for status messages under the bucket list

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_1        "もうこれ以上のバケツは必要ありません。"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_2        "最低二つのバケツを作成して下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_3        "最低もう一つのバケツが必要です。"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_4        "インストーラーは、"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_5        "個以上のバケツを作ることはできません。"

; Message box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_1      "バケツ"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_2      "は既に作成されています。"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_3      "新しいバケツには違う名前を選んで下さい。"

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_1      "インストーラーが作成できるバケツは"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_2      "個です。"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_3      "インストール終了後にもバケツを作成できます。現在のバケツの個数:"

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_1      "バケツ名:"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_2      "は無効な名前です。"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_3      "バケツの名前には a から z の小文字、0 から 9 の数字、- または _ を使用して下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_4      "新しいバケツには違う名前を選んで下さい。"

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_1     "POPFile はメールを分類するのに最低二つのバケツを必要とします。"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_2     "作成するバケツの名前を入力して下さい。$\r$\n$\r$\nドロップダウンリストの例より選択するか、$\r$\n$\r$\n適当な名前を入力して下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_3     "POPFile のインストールを続行するには、最低二つのバケツを作成しなければなりません。"

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_1        "個のバケツが POPFile 用に作成されました。"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_2        "これらのバケツを使うよう POPFile を設定してもよろしいですか？"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_3        "バケツの選択を変更するには「No」をクリックして下さい。"

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_1      "インストーラーは選択されたバケツを全て作成できませんでした。作成に失敗したバケツ:"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_2      "個 / 選択されたバケツ:"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_3      "個 "
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_4      "作成できなかったバケツは、POPFile のインストール後に$\r$\n$\r$\n「ユーザーインターフェース」コントロールパネルより作成できます。"

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

!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_TITLE         "Outlook Express の設定変更"
!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_SUBTITLE      "POPFile は Outlook Express の設定を変更することができます。"

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

!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_TITLE         "Eudora の設定変更"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_SUBTITLE      "POPFile は Eudora の設定を変更することができます。"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_CANCELLED  "Eudora reconfiguration cancelled by user"

!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_INTRO_1    "POPFile has detected the following Eudora personality"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_INTRO_2    " and can automatically configure it to work with POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_CHECKBOX   "Reconfigure this personality to work with POPFile"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_DOMINANT   "<Dominant> personality"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_PERSONA    "personality"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_EMAIL      "メールアドレス:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_SERVER     "POP3 サーバー:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_USERNAME   "POP3 ユーザーネーム:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_POP3PORT   "POP3 port:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_RESTORE    "POPFile をアンインストールすれば元の設定に戻ります。"

#--------------------------------------------------------------------------
# Custom Page - POPFile can now be started
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_TITLE        "POPFile の起動"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_SUBTITLE     "ユーザーインターフェースは POPFile を起動しないと使えません。"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_INTRO     "POPFile を起動しますか？"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NO        "いいえ(「ユーザーインターフェース」は POPFile を起動しないと使えません。)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_DOSBOX    "POPFile を起動(コンソール)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_BCKGRND   "POPFile をバックグラウンドで起動(コンソールなし)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_1    "POPFile を起動すれば以下の方法で「ユーザーインターフェース」を使用できます。"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_2    "(a) システムトレイ中の POPFile アイコンをダブルクリックするか、"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_3    "(b) スタート --> プログラム --> POPFile --> POPFile User Interface を選択します。"

; Banner message displayed whilst waiting for POPFile to start

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_BANNER_1     "POPFile を起動中"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_BANNER_2     "しばらくお待ちください..."

#--------------------------------------------------------------------------
# Custom Page - Flat file corpus needs to be converted to new format
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_FLATFILE_TITLE       "POPFile Corpus Conversion"
!insertmacro PFI_LANG_STRING PFI_LANG_FLATFILE_SUBTITLE    "The existing corpus must be converted to work with this version of POPFile"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_FLATFILE_IO_NOTE_1   "POPFile will now be started in a console window to convert the existing corpus."
!insertmacro PFI_LANG_STRING PFI_LANG_FLATFILE_IO_NOTE_2   "THIS PROCESS MAY TAKE SEVERAL MINUTES (if the corpus is large)."
!insertmacro PFI_LANG_STRING PFI_LANG_FLATFILE_IO_NOTE_3   "WARNING"
!insertmacro PFI_LANG_STRING PFI_LANG_FLATFILE_IO_NOTE_4   "Do NOT close the POPFile console window!"
!insertmacro PFI_LANG_STRING PFI_LANG_FLATFILE_IO_NOTE_5   "When 'POPFile Engine v${C_POPFILE_MAJOR_VERSION}.${C_POPFILE_MINOR_VERSION}.${C_POPFILE_REVISION} running' appears in the console window, this means"
!insertmacro PFI_LANG_STRING PFI_LANG_FLATFILE_IO_NOTE_6   "- POPFile is ready for use"
!insertmacro PFI_LANG_STRING PFI_LANG_FLATFILE_IO_NOTE_7   "- POPFile can be safely shutdown using the Start Menu"
!insertmacro PFI_LANG_STRING PFI_LANG_FLATFILE_IO_NOTE_8   "Click Next to convert the corpus."

#--------------------------------------------------------------------------
# Standard MUI Page - Uninstall POPFile
#--------------------------------------------------------------------------

; Uninstall Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROGRESS_1        "POPFile をシャットダウン中..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROGRESS_2        "「スタートメニュー」から POPFile を削除中..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROGRESS_3        "POPFile のコアファイルを削除中..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROGRESS_4        "Outlook Express の設定を元に戻しています..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROGRESS_5        "POPFile のスキンファイルを削除中..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROGRESS_6        "最小バージョンの Perl を削除中..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROGRESS_7        "Restoring Outlook settings..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROGRESS_8        "Restoring Eudora settings..."

; Uninstall Log Messages

!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_1             "POPFile をシャットダウンします。ポート番号:"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_2             "オープン"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_3             "復元"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_4             "クローズ"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_5             "POPFile ディレクトリ以下の全てのファイルを削除中"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_6             "注意: POPFile ディレクトリ以下の全てのファイルを削除できませんでした。"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_LOG_7             "Data problems"

; Message Box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBNOTFOUND_1      "POPFile は次のディレクトリにインストールされていないようです:"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBNOTFOUND_2      "それでも続行しますか(推奨できません)？"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_ABORT_1           "アンインストールはユーザーより中止されました"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_1        "'Outlook Express' problem !"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_2        "'Outlook' problem !"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_3        "'Eudora' problem !"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBEMAIL_1         "Unable to restore some original settings"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBEMAIL_2         "Display the error report ?"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_1         "Some email client settings have not been restored !"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_2         "(Details can be found in $INSTDIR folder)"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_3         "Click 'No' to ignore these errors and delete everything"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_4         "Click 'Yes' to keep this data (to allow another attempt later)"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMDIR_1        "POPFile ディレクトリ以下の全てのファイルを削除しますか？$\r$\n$\r$\n(残したいファイルがあれば No をクリックして下さい。)"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMERR_1        "注意"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMERR_2        "は削除できませんでした。"

#--------------------------------------------------------------------------
# Mark the end of the language data
#--------------------------------------------------------------------------

!undef PFI_LANG

#--------------------------------------------------------------------------
# End of 'Japanese-pfi.nsh'
#--------------------------------------------------------------------------
