#--------------------------------------------------------------------------
# Japanese-pfi.nsh
#
# This file contains additional "Japanese" text strings used by the Windows installer
# for POPFile (these strings are unique to POPFile).
#
# See 'Japanese-mui.nsh' for the strings which modify standard NSIS MUI messages.
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

!define PFI_LANG  "JAPANESE"

#--------------------------------------------------------------------------
# Startup message box offering to display the Release Notes
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_1        "POPFile のリリースノートを表示しますか？"
!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_2        "アップグレードの場合は「Yes」を推奨します。(アップグレードの前にバックアップを取ることを推奨します。)"

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

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBUNINST_1    "次の場所に以前にインストールされた POPFile が見つかりました:"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBUNINST_2    "アンインストールしますか？"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBUNINST_3    "「Yes」を推奨します。"

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_1    "無効な POP3 ポート番号:"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_2    "ポート番号には 1 から 65535 までの番号を選んで下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_3    "POP3 ポート番号を変更して下さい。"

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_1     "無効な「ユーザーインターフェース」ポート番号:"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_2     "ポート番号には 1 から 65535 までの番号を選んで下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_3     "「ユーザーインターフェース」ポート番号を変更して下さい。"

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_1    "POP3 ポート番号には「ユーザーインターフェース」ポート番号と異なる番号を選んで下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_2    "ポート番号を変更して下さい。"

; Banner message displayed whilst uninstalling old version

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_BANNER_1     "お待ち下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_BANNER_2     "この処理にはしばらく時間がかかります..."

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
# Custom Page - Reconfigure Outlook Express
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_TITLE         "Outlook Express の設定変更"
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_SUBTITLE      "POPFile は Outlook Express の設定を変更することができます。"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_INTRO      "POPFile は以下の Outlook Express メールアカウントを検出しました。POPFile が使用できるように自動的に設定することができます。"
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_CHECKBOX   "POPFile が使用できるようにこのアカウントの設定を変更する。"
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_EMAIL      "メールアドレス:"
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_SERVER     "POP3 サーバー:"
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_USERNAME   "POP3 ユーザーネーム:"
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_RESTORE    "POPFile をアンインストールすれば元の設定に戻ります。"

!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_LINK_1     "アカウントの"
!insertmacro PFI_LANG_STRING PFI_LANG_OECFG_IO_LINK_2     "アイデンティティ"

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
!insertmacro PFI_LANG_STRING PFI_LANG_FLATFILE_IO_NOTE_5   "When 'POPFile Engine v0.20.0 running' appears in the console window, this means"
!insertmacro PFI_LANG_STRING PFI_LANG_FLATFILE_IO_NOTE_6   "- POPFile is ready for use"
!insertmacro PFI_LANG_STRING PFI_LANG_FLATFILE_IO_NOTE_7   "- POPFile can be safely shutdown using the Start Menu"

#--------------------------------------------------------------------------
# Standard MUI Page - Uninstall POPFile
#--------------------------------------------------------------------------

; Uninstall Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_UNSTRING PFI_LANG_PROGRESS_1        "POPFile をシャットダウン中..."
!insertmacro PFI_LANG_UNSTRING PFI_LANG_PROGRESS_2        "「スタートメニュー」から POPFile を削除中..."
!insertmacro PFI_LANG_UNSTRING PFI_LANG_PROGRESS_3        "POPFile のコアファイルを削除中..."
!insertmacro PFI_LANG_UNSTRING PFI_LANG_PROGRESS_4        "Outlook Express の設定を元に戻しています..."
!insertmacro PFI_LANG_UNSTRING PFI_LANG_PROGRESS_5        "POPFile のスキンファイルを削除中..."
!insertmacro PFI_LANG_UNSTRING PFI_LANG_PROGRESS_6        "最小バージョンの Perl を削除中..."

; Uninstall Log Messages

!insertmacro PFI_LANG_UNSTRING PFI_LANG_LOG_1             "POPFile をシャットダウンします。ポート番号:"
!insertmacro PFI_LANG_UNSTRING PFI_LANG_LOG_2             "オープン"
!insertmacro PFI_LANG_UNSTRING PFI_LANG_LOG_3             "復元"
!insertmacro PFI_LANG_UNSTRING PFI_LANG_LOG_4             "クローズ"
!insertmacro PFI_LANG_UNSTRING PFI_LANG_LOG_5             "POPFile ディレクトリ以下の全てのファイルを削除中"
!insertmacro PFI_LANG_UNSTRING PFI_LANG_LOG_6             "注意: POPFile ディレクトリ以下の全てのファイルを削除できませんでした。"

; Message Box text strings

!insertmacro PFI_LANG_UNSTRING PFI_LANG_MBNOTFOUND_1      "POPFile は次のディレクトリにインストールされていないようです:"
!insertmacro PFI_LANG_UNSTRING PFI_LANG_MBNOTFOUND_2      "それでも続行しますか(推奨できません)？"

!insertmacro PFI_LANG_UNSTRING PFI_LANG_ABORT_1           "アンインストールはユーザーより中止されました"

!insertmacro PFI_LANG_UNSTRING PFI_LANG_MBREMDIR_1        "POPFile ディレクトリ以下の全てのファイルを削除しますか？$\r$\n$\r$\n(残したいファイルがあれば No をクリックして下さい。)"

!insertmacro PFI_LANG_UNSTRING PFI_LANG_MBREMERR_1        "注意"
!insertmacro PFI_LANG_UNSTRING PFI_LANG_MBREMERR_2        "は削除できませんでした。"

#--------------------------------------------------------------------------
# Mark the end of the language data
#--------------------------------------------------------------------------

!undef PFI_LANG

#--------------------------------------------------------------------------
# End of 'Japanese-pfi.nsh'
#--------------------------------------------------------------------------
