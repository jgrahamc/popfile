#--------------------------------------------------------------------------
# Japanese-pfi.nsh
#
# This file contains the "Japanese" text strings used by the Windows installer
# for POPFile (includes customised versions of strings provided by NSIS and
# strings which are unique to POPFile).
#
# These strings are grouped according to the page/window where they are used
#
# Copyright (c) 2003-2004 John Graham-Cumming
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

!define PFI_LANG  "JAPANESE"

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

!insertmacro PFI_LANG_STRING PFI_LANG_WELCOME_INFO_TEXT    "このウィザードは、POPFile のインストールをガイドしていきます。${IO_NL}${IO_NL}セットアップを開始する前に、他のすべてのアプリケーションを終了することを推奨します。${IO_NL}${IO_NL}$_CLICK"
!insertmacro PFI_LANG_STRING PFI_LANG_WELCOME_ADMIN_TEXT   "重要:${IO_NL}${IO_NL}現在のユーザーは Administrator 権限を持っていません。${IO_NL}${IO_NL}もしマルチユーザーサポートが必要なら、インストールをキャンセルし Administrator アカウントで POPFile をインストールすることをお勧めします。"

#--------------------------------------------------------------------------
# Standard MUI Page - Directory Page (for the main POPFile installer)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_ROOTDIR_TITLE        "プログラムファイルのインストール先"
!insertmacro PFI_LANG_STRING PFI_LANG_ROOTDIR_TEXT_DESTN   "POPFile のインストール先フォルダを指定してください。"

#--------------------------------------------------------------------------
# Standard MUI Page - Installation Page (for the main POPFile installer)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_INSTFINISH_TITLE     "プログラムファイルがインストールされました。"
!insertmacro PFI_LANG_STRING PFI_LANG_INSTFINISH_SUBTITLE  "次に ${C_PFI_PRODUCT} を使用するための設定を行います。"

#--------------------------------------------------------------------------
# Standard MUI Page - Finish (for the main POPFile installer)
#
# The PFI_LANG_FINISH_RUN_TEXT text should be a short phrase (not a long paragraph)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_FINISH_RUN_TEXT      "POPFile ユーザーインターフェースを起動"


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Used by 'Monitor Corpus Conversion' utility (main script: MonitorCC.nsi)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#--------------------------------------------------------------------------
# Standard MUI Page - Installation Page (for the 'Monitor Corpus Conversion' utility)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_TITLE        "POPFile Corpus(コーパス、単語ファイル)の変換"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_SUBTITLE     "インストールしようとしているバージョンの POPFile と動作するためには、今ある corpus を変換する必要があります。"

!insertmacro PFI_LANG_STRING PFI_LANG_ENDCONVERT_TITLE     "POPFile Corpus の変換は完了しました。"
!insertmacro PFI_LANG_STRING PFI_LANG_ENDCONVERT_SUBTITLE  "続行するには「閉じる」をクリックして下さい。"

!insertmacro PFI_LANG_STRING PFI_LANG_BADCONVERT_TITLE     "POPFile Corpus の変換に失敗しました。"
!insertmacro PFI_LANG_STRING PFI_LANG_BADCONVERT_SUBTITLE  "続行するには「キャンセル」をクリックして下さい。"


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Used by 'Add POPFile User' wizard (main script: adduser.nsi)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#--------------------------------------------------------------------------
# Standard MUI Page - Welcome (for the 'Add POPFile User' wizard)
#
# The sequence ${IO_NL}${IO_NL} inserts a blank line (note that the PFI_LANG_ADDUSER_INFO_TEXT string
# should end with a ${IO_NL}${IO_NL}$_CLICK sequence).
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_INFO_TEXT    "このウィザードは '$G_WINUSERNAME' ユーザーのための POPFile の設定をガイドしていきます。${IO_NL}${IO_NL}続行する前に他の全てのアプリケーションを閉じることを推奨します。${IO_NL}${IO_NL}$_CLICK"

#--------------------------------------------------------------------------
# Standard MUI Page - Directory Page (for the 'Add POPFile User' wizard)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_TITLE        "'$G_WINUSERNAME' のための POPFile データの保存先"
!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_SUBTITLE     "'$G_WINUSERNAME' のための POPFile データを保存するフォルダを選んでください。"
!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_TEXT_TOP     "このバージョンの POPFile は各ユーザーごとに異なるデータファイルを使用します。${MB_NL}${MB_NL}セットアップは次のフォルダを '$G_WINUSERNAME' ユーザー用の POPFile データのために使用します。別のフォルダを使用するには、[参照] を押して他のフォルダを選んで下さい。 $_CLICK"
!insertmacro PFI_LANG_STRING PFI_LANG_USERDIR_TEXT_DESTN   "'$G_WINUSERNAME' の POPFile データの保存先"

#--------------------------------------------------------------------------
# Standard MUI Page - Installation Page (for the 'Add POPFile User' wizard)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_TITLE        "'$G_WINUSERNAME' ユーザーのための POPFile の設定"
!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_SUBTITLE     "POPFile 設定ファイルをこのユーザー用にアップデートします。しばらくお待ち下さい。"

#--------------------------------------------------------------------------
# Standard MUI Page - Finish (for the 'Add POPFile User' wizard)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_ADDUSER_FINISH_INFO "'$G_WINUSERNAME' ユーザー用の POPFile の設定作業は完了しました。${IO_NL}${IO_NL}完了 をクリックしてウィザードを閉じて下さい。"

#--------------------------------------------------------------------------
# Standard MUI Page - Uninstall Confirmation Page (for the 'Add POPFile User' wizard)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_REMUSER_TITLE        "'$G_WINUSERNAME' ユーザーのための POPFile データのアンインストール"
!insertmacro PFI_LANG_STRING PFI_LANG_REMUSER_SUBTITLE     "このユーザー用 POPFile 設定データをコンピューターから削除します。"

!insertmacro PFI_LANG_STRING PFI_LANG_REMUSER_TEXT_TOP     "'$G_WINUSERNAME' ユーザー用 POPFile 設定データを次のフォルダから削除します。 $_CLICK"

#--------------------------------------------------------------------------
# Standard MUI Page - Uninstallation Page (for the 'Add POPFile User' wizard)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_REMOVING_TITLE       "'$G_WINUSERNAME' ユーザー用 POPFile データの削除"
!insertmacro PFI_LANG_STRING PFI_LANG_REMOVING_SUBTITLE    "このユーザーの POPFile 設定ファイルが削除されるまでしばらくお待ち下さい。"


#==========================================================================
# Strings used for custom pages, message boxes and banners
#==========================================================================

#--------------------------------------------------------------------------
# General purpose banner text (also suitable for page titles/subtitles)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_BE_PATIENT           "お待ち下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_TAKE_A_FEW_SECONDS   "この処理にはしばらく時間がかかります..."

#--------------------------------------------------------------------------
# Message displayed when 'Add User' does not seem to be part of the current version
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_COMPAT_NOTFOUND      "エラー: ${C_PFI_PRODUCT} の互換性のあるバージョンが見つかりません！"

#--------------------------------------------------------------------------
# Message displayed when installer exits because another copy is running
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_INSTALLER_MUTEX      "別の POPFile インストーラーが実行中です！"

#--------------------------------------------------------------------------
# Message box warnings used when verifying the installation folder chosen by user
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_1   "次の場所に以前にインストールされた POPFile が見つかりました:"
!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_2   "アップグレードしますか？"
!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_3   "次の場所に以前の設定データが見つかりました:"
!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_4   "リストアされた設定データが見つかりました。"
!insertmacro PFI_LANG_STRING PFI_LANG_DIRSELECT_MBWARN_5   "リストアされたデータを使用しますか？"

#--------------------------------------------------------------------------
# Startup message box offering to display the Release Notes
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_1         "POPFile のリリースノートを表示しますか？"
!insertmacro PFI_LANG_STRING PFI_LANG_MBRELNOTES_2         "アップグレードの場合は「Yes」を推奨します。(アップグレードの前にバックアップを取ることを推奨します。)"

#--------------------------------------------------------------------------
# Custom Page - Check Perl Requirements
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_TITLE        "旧いシステムコンポーネントが検出されました。"

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_1    "POPFile ユーザーインターフェース(コントロールセンター)はデフォルトブラウザーを使用します。${IO_NL}${IO_NL}"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_2    "POPFile は特定のブラウザーを必要とせず、ほとんどどのブラウザーとも動作します。${IO_NL}${IO_NL}"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_3    "最小バージョンの Perl をインストールします(POPFile は Perl で書かれています)。${IO_NL}${IO_NL}"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_4    "POPFile に付属する Perl はインターネットエクスプローラー 5.5(あるいはそれ以上)のコンポーネントの一部を必要とします。"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_5    "インストーラーはインターネットエクスプローラーを検出しました。"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_6    "POPFile のいくつかの機能は正常に動作しないかもしれません。${IO_NL}${IO_NL}"
!insertmacro PFI_LANG_STRING PFI_LANG_PERLREQ_IO_TEXT_7    "POPFile で問題が起こった場合、新しいバージョンのインターネットエクスプローラーにアップグレードすることを推奨します。"

#--------------------------------------------------------------------------
# Standard MUI Page - Choose Components
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING DESC_SecPOPFile               "POPFile のコアファイルをインストールします。最小バージョンの Perl も含みます。"
!insertmacro PFI_LANG_STRING DESC_SecSkins                 "POPFile ユーザーインターフェースのデザインを変えることができる POPFile スキンをインストールします。"
!insertmacro PFI_LANG_STRING DESC_SecLangs                 "POPFile UI の英語以外のバージョンをインストールします。"

!insertmacro PFI_LANG_STRING DESC_SubSecOptional           "POPFile 追加コンポーネント (上級ユーザー用)"
!insertmacro PFI_LANG_STRING DESC_SecIMAP                  "POPFile IMAP モジュールをインストールします。"
!insertmacro PFI_LANG_STRING DESC_SecNNTP                  "POPFile NNTP プロキシーをインストールします。"
!insertmacro PFI_LANG_STRING DESC_SecSMTP                  "POPFile SMTP プロキシーをインストールします。"
!insertmacro PFI_LANG_STRING DESC_SecSOCKS                 "POPFile プロキシーが SOCKS を使えるようにするための Perl 追加コンポーネントをインストールします。"
!insertmacro PFI_LANG_STRING DESC_SecXMLRPC                "(POPFile API へのアクセスを可能にする)POPFile XMLRPC モジュールと必要な Perl モジュールをインストールします。"

; Text strings used when user has NOT selected a component found in the existing installation

!insertmacro PFI_LANG_STRING MBCOMPONENT_PROB_1            "$G_PLS_FIELD_1 コンポーネントをアップグレードしますか？"
!insertmacro PFI_LANG_STRING MBCOMPONENT_PROB_2            "(古いバージョンの POPFile コンポーネントを使っていると問題が起こることがあります。)"

#--------------------------------------------------------------------------
# Custom Page - POPFile Installation Options
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_TITLE        "POPFile インストールオプション"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_SUBTITLE     "これらのオプションは必要でない限り変更しないで下さい。"

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_POP3      "POP3 接続に使用するデフォルトポート番号を選んで下さい。(推奨値:110)"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_GUI       "ユーザーインターフェースに使用するポート番号を選んで下さい。(推奨値:8080)"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_STARTUP   "Windows の起動時に POPFile を自動的に起動する。(バックグラウンドで起動)"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_WARNING   "重要な警告"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_IO_MESSAGE   "POPFile のアップグレードの場合 --- インストーラーは現在のバージョンをシャットダウンします。"

; Message Boxes used when validating user's selections

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_1     "無効な POP3 ポート番号:"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_2     "ポート番号には 1 から 65535 までの番号を選んで下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBPOP3_3     "POP3 ポート番号を変更して下さい。"

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_1      "無効なユーザーインターフェースポート番号:"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_2      "ポート番号には 1 から 65535 までの番号を選んで下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBGUI_3      "ユーザーインターフェースのポート番号を変更して下さい。"

!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_1     "POP3 ポート番号にはユーザーインターフェースのポート番号と異なる番号を選んで下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_OPTIONS_MBDIFF_2     "ポート番号を変更して下さい。"

#--------------------------------------------------------------------------
# Standard MUI Page - Installing POPFile
#--------------------------------------------------------------------------

; When upgrading an existing installation, change the normal "Install" button to "Upgrade"
; (the page with the "Install" button will vary depending upon the page order in the script)

!insertmacro PFI_LANG_STRING PFI_LANG_INST_BTN_UPGRADE     "アップグレード"

; When resetting POPFile to use newly restored 'User Data', change "Install" button to "Restore"

!insertmacro PFI_LANG_STRING PFI_LANG_INST_BTN_RESTORE     "リストア"

; Installation Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_UPGRADE    "アップグレードインストールかどうかチェックしています..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_CORE       "POPFile のコアファイルをインストール中..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_PERL       "最小バージョンの Perl をインストール中..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SHORT      "POPFile のショートカットを作成中..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_CORPUS     "corpus(コーパス、単語ファイル)のバックアップを作成中。しばらくお待ち下さい..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SKINS      "POPFile のスキンファイルをインストール中..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_LANGS      "POPFile UI 言語ファイルをインストール中..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_XMLRPC     "POPFile XMLRPC ファイルをインストール中..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_REGSET     "レジストリ情報と環境変数を更新中..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_SQLBACKUP  "古い SQLite データベースをバックアップ中..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_FINDCORPUS "フラットファイルまたは BerkeleyDB のコーパスを探しています..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_MAKEBAT    "'pfi-run.bat' バッチファイルを生成中..."
!insertmacro PFI_LANG_STRING PFI_LANG_INST_PROG_ENDSEC     "「次へ」をクリックして続行して下さい。"

; Installation Log Messages

!insertmacro PFI_LANG_STRING PFI_LANG_INST_LOG_SHUTDOWN    "Shutting down previous version of POPFile using port"

; Message Box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_1           "は以前にインストールされたファイルです。"
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_2           "アップデートしてもよろしいですか？"
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_3           "アップデートするには「Yes」をクリックして下さい。(古いファイルは次の名前で保存されます:"
!insertmacro PFI_LANG_STRING PFI_LANG_MBSTPWDS_4           "古いファイルを残すには「No」をクリックして下さい。(新しいファイルは次の名前で保存されます:"

!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_1          "$G_PLS_FIELD_1 を自動的にシャットダウンすることができませんでした。"
!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_2          "$G_PLS_FIELD_1 を手動でシャットダウンして下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_MBMANSHUT_3          "$G_PLS_FIELD_1 をシャットダウンしたら、'OK' をクリックして続行して下さい。"

!insertmacro PFI_LANG_STRING PFI_LANG_MBCORPUS_1           "古い corpus をバックアップ中にエラーが見つかりました。"

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

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_TITLE            "POPFile の分類用のバケツ作成"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_SUBTITLE         "POPFile はメールを分類するのに最低二つのバケツを必要とします。"

; Text strings displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_INTRO         "インストール終了後も、必要に応じて簡単にバケツの数も名前も変更することができます。${IO_NL}${IO_NL}バケツの名前にはアルファベットの小文字、0 から 9 の数字、- または _ からなる単語を使用して下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_CREATE        "以下のリストより選ぶか、適当な名前を入力して新しいバケツを作成して下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_DELETE        "一つかそれ以上のバケツをリストより削除するには、対応する「削除」ボックスにチェックを入れて「続行」ボタンをクリックして下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_LISTHDR       "POPFile に使用するバケツ"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_REMOVE        "削除"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_CONTINUE      "続行"

; Text strings used for status messages under the bucket list

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_1         "もうこれ以上のバケツは必要ありません。"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_2         "最低二つのバケツを作成して下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_3         "最低もう一つのバケツが必要です。"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_4         "インストーラーは、"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_IO_MSG_5         "個以上のバケツを作ることはできません。"

; Message box text strings

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_1       "バケツ"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_2       "は既に作成されています。"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDUPERR_3       "新しいバケツには違う名前を選んで下さい。"

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_1       "インストーラーが作成できるバケツは"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_2       "個です。"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAXERR_3       "インストール終了後にもバケツを作成できます。現在のバケツの個数:"

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_1       "バケツ名:"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_2       "は無効な名前です。"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_3       "バケツの名前には a から z の小文字、0 から 9 の数字、- または _ を使用して下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBNAMERR_4       "新しいバケツには違う名前を選んで下さい。"

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_1      "POPFile はメールを分類するのに最低二つのバケツを必要とします。"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_2      "作成するバケツの名前を入力して下さい。${MB_NL}${MB_NL}ドロップダウンリストの例より選択するか、${MB_NL}${MB_NL}適当な名前を入力して下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBCONTERR_3      "POPFile のインストールを続行するには、最低二つのバケツを作成しなければなりません。"

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_1         "個のバケツが POPFile 用に作成されました。"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_2         "これらのバケツを使うよう POPFile を設定してもよろしいですか？"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBDONE_3         "バケツの選択を変更するには「No」をクリックして下さい。"

!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_1       "インストーラーは選択されたバケツを全て作成できませんでした。作成に失敗したバケツ:"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_2       "個 / 選択されたバケツ:"
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_3       "個 "
!insertmacro PFI_LANG_STRING PFI_LANG_CBP_MBMAKERR_4       "作成できなかったバケツは、POPFile のインストール後に${MB_NL}${MB_NL}ユーザーインターフェース(コントロールパネル)より作成できます。"

#--------------------------------------------------------------------------
# Custom Page - Email Client Reconfiguration
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_TITLE        "メールクライアントの設定"
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_SUBTITLE     "いくつかのメールクライアントでは、設定を POPFile 用に変更することができます。"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_TEXT_1    "(*) 印が付いているメールクライアントについては、単純なアカウント設定である限り、設定を自動的に変更することができます。${IO_NL}認証を必要とするアカウントについては手動で変更することを強く推奨します。"
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_TEXT_2    "重要: 自動的に設定変更できるメールクライアントについては、今すぐシャットダウンして下さい。${IO_NL}${IO_NL}この機能はまだ開発途中の機能です。(例えばいくつかの Outlook アカウントは検出されないかもしれません。)${IO_NL}メールクライアントを使用する前に設定変更がうまくいったかどうか確認して下さい。"

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_CANCEL    "メールクライアントの設定変更はキャンセルされました。"

#--------------------------------------------------------------------------
# Text used on buttons to skip configuration of email clients
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_SKIPALL   "全てスキップ"
!insertmacro PFI_LANG_STRING PFI_LANG_MAILCFG_IO_SKIPONE   "スキップ"

#--------------------------------------------------------------------------
# Message box warnings that an email client is still running
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_EXP         "警告: Outlook Express が起動中です！"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_OUT         "警告: Outlook が起動中です！"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_EUD         "警告: Eudora が起動中です！"

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_1      "メールクライアントをシャットダウンした後、「再試行」を押して下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_2      "(「無視」を押せば続行できますが、あまり推奨しない操作です。)"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_3      "「中止」を押すとメールクライアントの設定変更をスキップします。"

!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_4      "メールクライアントをシャットダウンした後、「再試行」をクリックして元の設定に戻して下さい。"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_5      "(「無視」をクリックすれば設定を元に戻せますが、この操作はあまりお勧めできません。)"
!insertmacro PFI_LANG_STRING PFI_LANG_MBCLIENT_STOP_6      "「中止」をクリックして元の設定に戻して下さい。"

#--------------------------------------------------------------------------
# Custom Page - Reconfigure Outlook/Outlook Express
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_TITLE         "Outlook Express の設定変更"
!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_SUBTITLE      "POPFile は Outlook Express の設定を変更することができます。"

!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_TITLE         "Outlook の設定変更"
!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_SUBTITLE      "POPFile は Outlook の設定を変更することができます。"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_IO_CANCELLED  "Outlook Express の設定変更はキャンセルされました。"
!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_IO_CANCELLED  "Outlook の設定変更はキャンセルされました。"

!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_BOXHDR     "アカウント"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_ACCOUNTHDR "アカウント"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_EMAILHDR   "メールアドレス"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_SERVERHDR  "サーバー"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_USRNAMEHDR "ユーザー名"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_IO_FOOTNOTE   "設定変更をしたいアカウントのチェックボックスにチェックを入れてください。${IO_NL}POPFile をアンインストールすれば、変更した設定はまた元に戻ります。 "

; Message Box to confirm changes to Outlook/Outlook Express account configuration

!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_MBIDENTITY    "Outlook Express アイデンティティー :"
!insertmacro PFI_LANG_STRING PFI_LANG_EXPCFG_MBACCOUNT     "Outlook Express アカウント :"

!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_MBIDENTITY    "Outlook ユーザー :"
!insertmacro PFI_LANG_STRING PFI_LANG_OUTCFG_MBACCOUNT     "Outlook アカウント :"

!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBEMAIL       "メールアドレス :"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBSERVER      "POP3 サーバー :"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBUSERNAME    "POP3 ユーザー名 :"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBOEPORT      "POP3 ポート :"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBOLDVALUE    "現在の設定"
!insertmacro PFI_LANG_STRING PFI_LANG_OOECFG_MBQUESTION    "このアカウントの設定を POPFile 用に変更しますか？"

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

!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_TITLE          "Eudora の設定変更"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_SUBTITLE       "POPFile は Eudora の設定を変更することができます。"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_CANCELLED   "Eudora の設定変更はキャンセルされました。"

!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_INTRO_1     "POPFile は次の Eudora パーソナリティを検出しました。"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_INTRO_2     "POPFile 用に自動的に設定を変更することができます。"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_CHECKBOX    "POPFile 用にこのパーソナリティの設定を変更する。"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_DOMINANT    "<主要> パーソナリティ"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_PERSONA     "パーソナリティ"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_EMAIL       "メールアドレス:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_SERVER      "POP3 サーバー:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_USERNAME    "POP3 ユーザーネーム:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_POP3PORT    "POP3 ポート:"
!insertmacro PFI_LANG_STRING PFI_LANG_EUCFG_IO_RESTORE     "POPFile をアンインストールすれば元の設定に戻ります。"

#--------------------------------------------------------------------------
# Custom Page - POPFile can now be started
#--------------------------------------------------------------------------

; Page Title and Sub-title displayed in the page header

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_TITLE         "POPFile の起動"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_SUBTITLE      "ユーザーインターフェースは POPFile を起動しないと使えません。"

; Text displayed on the custom page

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_INTRO      "POPFile を起動しますか？"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NO         "いいえ(ユーザーインターフェースは POPFile を起動しないと使えません)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_DOSBOX     "POPFile を起動(コンソール)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_BCKGRND    "POPFile をバックグラウンドで起動(コンソールなし)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOICON     "POPFile を起動(システムトレイアイコンを表示しない)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_TRAYICON   "POPFile を起動(システムトレイアイコンを表示)"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_1     "POPFile を起動すれば以下の方法でユーザーインターフェースを使用できます。"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_2     "(a) システムトレイ中の POPFile アイコンをダブルクリック"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_IO_NOTE_3     "(b) スタート --> プログラム --> POPFile --> POPFile User Interface を選択"

; Banner message displayed whilst waiting for POPFile to start

!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_BANNER_1      "POPFile を起動中"
!insertmacro PFI_LANG_STRING PFI_LANG_LAUNCH_BANNER_2      "しばらくお待ちください..."

#--------------------------------------------------------------------------
# Standard MUI Page - Installation Page (for the 'Corpus Conversion Monitor' utility)
#--------------------------------------------------------------------------

!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_MUTEX        "別の 'Corpus Conversion Monitor' が既に起動中です！"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_PRIVATE      "'Corpus Conversion Monitor' は POPFile インストーラーの一部です。"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_NOFILE       "エラー: Corpus 変換データファイルが存在しません！"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_NOPOPFILE    "エラー: POPFile のパスが見つかりません。"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_ENVNOTSET    "エラー: 環境変数をセットすることができません。"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_NOKAKASI     "エラー: Kakasi のパスが見つかりません。"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_STARTERR     "Corpus 変換のプロセスを起動中にエラーが発生しました。"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_FATALERR     "Corpus 変換のプロセス中に致命的なエラーが発生しました！"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_ESTIMATE     "予想残り時間: "
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_MINUTES      "分"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_WAITING      "(最初のファイルが変換されるのを待っています。)"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_TOTALFILES   "$G_BUCKET_COUNT 個のバケツファイルを変換します。"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_PROGRESS_N   "$G_ELAPSED_TIME.$G_DECPLACES 分経過。あと $G_STILL_TO_DO 個のファイルを変換します。"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_PROGRESS_1   "$G_ELAPSED_TIME.$G_DECPLACES 分経過。あと1個のファイルを変換します。"
!insertmacro PFI_LANG_STRING PFI_LANG_CONVERT_SUMMARY      "Corpus の変換には $G_ELAPSED_TIME.$G_DECPLACES 分かかりました。"

#--------------------------------------------------------------------------
# Standard MUI Page - Uninstall POPFile
#--------------------------------------------------------------------------

; Uninstall Progress Reports displayed above the progress bar

!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_SHUTDOWN     "POPFile をシャットダウン中..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_SHORT        "「スタートメニュー」から POPFile を削除中..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_CORE         "POPFile のコアファイルを削除中..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_OUTEXPRESS   "Outlook Express の設定を元に戻しています..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_SKINS        "POPFile のスキンファイルを削除中..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_PERL         "最小バージョンの Perl を削除中..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_OUTLOOK      "Outlook の設定を元に戻しています..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_EUDORA       "Eudora の設定を元に戻しています..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_DBMSGDIR     "corpus と 'Recent Messages' ディレクトリを削除中..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_EXESTATUS    "プログラムのステータスをチェック中..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_CONFIG       "設定データを削除中..."
!insertmacro PFI_LANG_STRING PFI_LANG_UN_PROG_REGISTRY     "POPFile のレジストリエントリーを削除中..."

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

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBDIFFUSER_1      "'$G_WINUSERNAME' は他のユーザーに属するデータを削除しようとしています。"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBNOTFOUND_1      "POPFile は次のディレクトリにインストールされていないようです:"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBNOTFOUND_2      "それでも続行しますか(推奨できません。)？"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_ABORT_1           "アンインストールはユーザーより中止されました。"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_1        "'Outlook Express' の問題です！"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_2        "'Outlook' の問題です！"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBCLIENT_3        "'Eudora' の問題です！"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBEMAIL_1         "いくつかの設定を元に戻すことができませんでした。"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBEMAIL_2         "エラーレポートを表示しますか？"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_1         "いくつかのメールクライアントの設定を元に戻すことができませんでした！"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_2         "(詳細については $INSTDIR フォルダを参照してください。)"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_3         "'No' をクリックすればエラーを無視して全てを削除します。"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBRERUN_4         "'Yes' をクリックすればデータは保存されます。(これは、後でまた再試行する時のためです。)"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMDIR_1        "POPFile ディレクトリ以下の全てのファイルを削除しますか？${MB_NL}${MB_NL}$G_ROOTDIR${MB_NL}${MB_NL}(残したいファイルがあれば No をクリックして下さい。)"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMDIR_2        "POPFile「ユーザーデータ」ディレクトリ以下の全てのファイルを削除しますか？${MB_NL}${MB_NL}$G_USERDIR${MB_NL}${MB_NL}(残したいファイルがあれば No をクリックして下さい。)"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBDELMSGS_1       "'Recent Messages' ディレクトリ中の全てのファイルを削除しますか？"

!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMERR_1        "注意"
!insertmacro PFI_LANG_STRING PFI_LANG_UN_MBREMERR_2        "は削除できませんでした。"

#--------------------------------------------------------------------------
# Mark the end of the language data
#--------------------------------------------------------------------------

!undef PFI_LANG

#--------------------------------------------------------------------------
# End of 'Japanese-pfi.nsh'
#--------------------------------------------------------------------------
