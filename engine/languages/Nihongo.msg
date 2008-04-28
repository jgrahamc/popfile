# Copyright (c) 2001-2008 John Graham-Cumming
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify it
#   under the terms of version 2 of the GNU General Public License as
#   published by the Free Software Foundation.
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

# Identify the language and character set used for the interface
LanguageCode                            ja
LanguageCharset                         EUC-JP
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          jp


# These are where to find the documents on the Wiki
WikiLink                                JP
FAQLink                                 JP:FAQ
RequestFeatureLink                      JP:RequestFeature
MailingListLink                         JP:mailing_lists

# Common words that are used on their own all over the interface
Account                                 POP3 アカウント
Apply                                   適用
ApplyChanges                            変更を適用
On                                      ON
Off                                     OFF
TurnOn                                  ON にする
TurnOff                                 OFF にする
Add                                     追加
Remove                                  削除
Previous                                前へ
Next                                    次へ
From                                    差出人
Subject                                 件名
Cc                                      Cc
Classification                          分類
Reclassify                              再分類
Probability                             確率
Scores                                  得点
QuickMagnets                            クイックマグネット
Undo                                    やり直し
Close                                   閉じる
Find                                    検索
Filter                                  フィルター
Yes                                     はい
No                                      いいえ
ChangeToYes                             「はい」に変更
ChangeToNo                              「いいえ」に変更
Bucket                                  バケツ
Magnet                                  マグネット
Delete                                  削除
Create                                  作成
To                                      宛先
Total                                   合計
Rename                                  名前変更
Frequency                               頻度
Probability                             確率
Score                                   得点
Lookup                                  検査
Word                                    単語
Count                                   カウント
Update                                  更新
Refresh                                 最新の状態に更新
FAQ                                     FAQ 初心者・初学者向けのQ&amp;A集
ID                                      ID
Date                                    日時
Arrived                                 受信日時
Size                                    サイズ
Go                                      ジャンプ
Edit                                    編集
Logout                                  ログアウト

# This is a regular expression pattern that is used to convert
# a number into a friendly looking number (for the US and UK this
# means comma separated at the thousands)

Locale_Thousands                        ,
Locale_Decimal                          .

# The Locale_Date uses the format strings in Perl's Date::Format
# module to set the date format for the UI.  There are two possible
# ways to specify it.
#
# <format>            Just one simple format used for all dates
# <<format> | <format> The first format is used for dates less than
#                     7 days from now, the second for all other dates

Locale_Date                             %a %R | %D %R

# The header and footer that appear on every UI page
Header_Title                            POPFile コントロールセンター
Header_Shutdown                         POPFile の停止
Header_History                          履歴
Header_Buckets                          バケツ
Header_Configuration                    設定
Header_Advanced                         詳細設定
Header_Security                         セキュリティ
Header_Administration                   管理
Header_Magnets                          マグネット
Header_Users                            ユーザー

Footer_HomePage                         POPFile ホームページ
Footer_Manual                           マニュアル
Footer_Forums                           フォーラム
Footer_FeedMe                           寄付
Footer_RequestFeature                   要望
Footer_MailingList                      メーリングリスト
Footer_Wiki                             ドキュメント

Configuration_Error1                    区切り文字は 1 文字だけにしてください。
Configuration_Error2                    ユーザーインターフェース用ポート番号は 1 から 65535 までにしてください。
Configuration_Error3                    POP3/POP3S ポート番号は 1 から 65535 までにしてください。
Configuration_Error4                    1 ページに表示するメールの数は 1 から 1000 までにしてください。
Configuration_Error5                    履歴を残す日数は 1 から 366 までにしてください。
Configuration_Error6                    TCP コネクションタイムアウトの秒数は 10 から 300 にしてください。
Configuration_Error7                    XML RPC ポート番号は 1 から 65535 までにしてください。
Configuration_Error8                    SOCKS V プロキシのポート番号は 1 から 65535 までにしてください。
Configuration_POP3Port                  POP3 ポート番号
Configuration_POP3Update                POP3 ポート番号を 「%s」に変更しました。この変更は POPFile を再起動するまで有効になりません。
Configuration_POP3SPort                 POP3S ポート番号
Configuration_POP3SUpdate               POP3S ポート番号を 「%s」に変更しました。この変更は POPFile を再起動するまで有効になりません。
Configuration_XMLRPCUpdate              XML-RPC ポート番号を 「%s」に変更しました。この変更は POPFile を再起動するまで有効になりません。
Configuration_XMLRPCPort                XML-RPC ポート番号
Configuration_SMTPPort                  SMTP ポート番号
Configuration_SMTPUpdate                SMTP ポート番号を 「%s」に変更しました。この変更は POPFile を再起動するまで有効になりません。
Configuration_NNTPPort                  NNTP ポート番号
Configuration_NNTPUpdate                NNTP ポート番号を 「%s」に変更しました。この変更は POPFile を再起動するまで有効になりません。
Configuration_POPFork                   POP3 同時接続の許可
Configuration_POP3SFork                 POP3S 同時接続の許可
Configuration_SMTPFork                  SMTP 同時接続の許可
Configuration_NNTPFork                  NNTP 同時接続の許可
Configuration_POPForkEnabled            POP3 プロキシへの同時接続を「有効」に変更しました
Configuration_POP3SForkEnabled          POP3S (POP3 over SSL) プロキシへの同時接続を「有効」に変更しました
Configuration_SMTPForkEnabled           SMTP プロキシへの同時接続を「有効」に変更しました
Configuration_NNTPForkEnabled           NNTP プロキシへの同時接続を「有効」に変更しました
Configuration_POPForkDisabled           POP3 プロキシへの同時接続を「無効」に変更しました
Configuration_POP3SForkDisabled         POP3S (POP3 over SSL) プロキシへの同時接続を「無効」に変更しました
Configuration_SMTPForkDisabled          SMTP プロキシへの同時接続を「無効」に変更しました
Configuration_NNTPForkDisabled          NNTP プロキシへの同時接続を「無効」に変更しました
Configuration_POP3Separator             POP3 ホスト名、ポート番号、ユーザ名の区切り文字
Configuration_NNTPSeparator             NNTP ホスト名、ポート番号、ユーザ名の区切り文字
Configuration_POP3SepUpdate             POP3 区切り文字を 「%s」に変更しました。
Configuration_NNTPSepUpdate             NNTP 区切り文字を 「%s」に変更しました。
Configuration_UI                        ユーザーインターフェース用ポート番号
Configuration_UIUpdate                  ユーザーインターフェース用ポート番号を 「%s」に変更しました。この変更は POPFile を再起動するまで有効になりません。
Configuration_UIHTTPS                   UI への SSL 接続を受け入れる
Configuration_UIHTTPSEnabled            ユーザーインターフェース(UI) への SSL 接続を「有効」に変更しました。この変更は POPFile を再起動するまで有効になりません。
Configuration_UIHTTPSDisabled           ユーザーインターフェース(UI) への SSL 接続を「無効」に変更しました。この変更は POPFile を再起動するまで有効になりません。
Configuration_UIHTTPSPort               ユーザーインターフェース（SSL）用ポート番号
Configuration_UIUpdate                  ユーザーインターフェース用ポート番号を 「%s」に変更しました。この変更は POPFile を再起動するまで有効になりません。
Configuration_UIHTTPSPortUpdate         ユーザーインターフェース（SSL）用ポート番号を 「%s」に変更しました。この変更は POPFile を再起動するまで有効になりません。
Configuration_History                   1 ページに表示するメールの数
Configuration_HistoryUpdate             1 ページに表示するメールの数を 「%s」に変更しました。
Configuration_Days                      履歴を残す日数
Configuration_DaysUpdate                履歴を残す日数を 「%s」に変更しました。
Configuration_UserInterface             ユーザーインターフェース
Configuration_Skins                     スキン
Configuration_SkinsChoose               スキンを選択してください
Configuration_Language                  言語
Configuration_LanguageChoose            言語を選択してください
Configuration_ListenPorts               モジュールのオプション
Configuration_HistoryView               履歴
Configuration_TCPTimeout                TCP コネクションタイムアウト
Configuration_TCPTimeoutSecs            TCP コネクションタイムアウトの秒数
Configuration_TCPTimeoutUpdate          TCP コネクションタイムアウトの秒数を 「%s」に変更しました。
Configuration_ClassificationInsertion   電子メールへのテキスト挿入機能
Configuration_SubjectLine               件名の変更
Configuration_XTCInsertion              X-Text-Classification<br>ヘッダー
Configuration_XPLInsertion              X-POPFile-Link<br>ヘッダー
Configuration_Logging                   ログ
Configuration_None                      なし
Configuration_ToScreen                  コンソール
Configuration_ToFile                    ファイル
Configuration_ToScreenFile              コンソールとファイル
Configuration_LoggerOutput              ログ出力
Configuration_GeneralSkins              スキン
Configuration_SmallSkins                小スキン
Configuration_TinySkins                 最小スキン
Configuration_CurrentLogFile            &lt;現在のログファイル&gt;
Configuration_SOCKSServer               SOCKS V プロキシ サーバ
Configuration_SOCKSPort                 SOCKS V プロキシ ポート番号
Configuration_SOCKSPortUpdate           SOCKS V プロキシのポート番号を 「%s」に変更しました。
Configuration_SOCKSServerUpdate         SOCKS V プロキシのサーバを 「%s」に変更しました。
Configuration_Fields                    履歴タブ項目を追加
Configuration_ChangePassword            パスワードの変更
Configuration_OldPassword               旧パスワード
Configuration_NewPassword               新パスワード
Configuration_ConfirmPassword           新パスワードの確認
Configuration_Password_Mismatch         新パスワードと新パスワードの確認は同一でなくてはなりません
Configuration_Password_Bad              入力された旧パスワードが間違っています
Configuration_Password_Fail             新しいパスワードに設定できませんでした
Configuration_Set_Password              新しいパスワードが設定されました
Configuration_ConfigBar                 設定バー
Configuration_Logger_Level0             低
Configuration_Logger_Level1             中
Configuration_Logger_Level2             高
Configuration_Logger_Level              ログレベル:
Configuration_LoggerOutputUpdate        ログ出力を 「%s」 に設定しました
Configuration_Logger_LevelUpdate        ログレベルを 「%s」 に設定しました
Configuration_CurrentSessions           現在有効なユーザーセッション
Configuration_CurrentSessions_UserName  ユーザー
Configuration_CurrentSessions_LastUsed  最終アクセス
Configuration_CurrentSessions_IdleTime  待機時間

Advanced_Error1                         「%s」 は既に無視する単語のリストに含まれています。
Advanced_Error2                         無視する単語に無効な文字が使われています。再度入力して下さい。
Advanced_Error3                         「%s」 を無視する単語のリストに追加しました。
Advanced_Error4                         「%s」 は無視する単語のリストに含まれていません。
Advanced_Error5                         「%s」 を無視する単語のリストから削除しました。
Advanced_StopWords                      無視する単語
Advanced_Message1                       POPFile は以下の頻繁に使われる単語を無視します。
Advanced_AddWord                        単語追加
Advanced_RemoveWord                     単語削除
Advanced_AllParameters                  POPFile の全体的なパラメーター
Advanced_AllParametersNotes             以下は POPFile の全体的なパラメーターの全リストです。
Advanced_Parameter                      パラメーター
Advanced_Value                          値
Advanced_Warning                        アドバンスド・ユーザーに限り、必要時、値を変更して更新ボタンをクリックして下さい。バリディティー（妥当性）チェックは行いません。太字で表示されている項目は初期設定から変更されています。オプションについての詳しい情報については <a href="http://getpopfile.org/docs/JP:OptionReference">オプション・リファレンス</a> を参照してください。
Advanced_ConfigFile                     設定ファイル:
Advanced_SingleUserModeParameters       シングルユーザーモードのパラメーター
Advanced_SingleUserModeParametersNotes  以下はシングルユーザーモードのパラメーターの全リストです。

Users_Create                            新しいユーザーの作成
Users_Rename                            ユーザー名の変更
Users_Remove                            既存ユーザーの削除
Users_Edit                              ユーザー設定の編集
Users_Change_Password                   ユーザーパスワードの変更/初期化
Users_CopyFrom                          設定をコピーするユーザー
Users_CopyMagnets                       ユーザーのマグネットをコピーする
Users_CopyCorpus                        ユーザーのコーパスをコピーする(この処理には長い時間がかかるかもしれません)
Users_RenameUser                        名前を変更するユーザー
Users_RenameUserNewName                 新しい名前
Users_RenameNotes                       注意 : ユーザーの名前を変更するとパスワードが初期化されます
Users_RemoveUser                        削除するユーザー
Users_CreateUser                        作成するユーザー
Users_EditUser                          編集するユーザー
Users_ChangePasswordUser                パスワードを変更するユーザー
Users_ResetPassword                     パスワードを初期化する
Users_Parameters                        パラメーター
Users_Created                           ユーザー 「%s」 を作成しました（初期パスワードは 「%s」）
Users_Not_Created                       ユーザー 「%s」 を作成できませんでした
Users_Created_And_Cloned                ユーザー 「%s」 を 「%s」 の設定をコピーして作成しました（初期パスワードは 「%s」）
Users_Not_Created_Exists                ユーザー 「%s」 は作成できませんでした。すでに存在しています
Users_Created_Not_Cloned                ユーザー 「%s」 を作成しましたが、「%s」 の設定はコピーできませんでした（初期パスワードは 「%s」）
Users_Renamed                           ユーザー 「%s」 の名前を 「%s」 に変更しました（初期パスワードは 「%s」）
Users_Rename_Failed_Exists              ユーザー 「%s」 の名前を 「%s」 に変更できませんでした。すでに存在しています
Users_Rename_Failed                     ユーザー 「%s」 の名前を変更できませんでした。
Users_Removed                           ユーザー 「%s」 を削除しました
Users_Removed_Failed                    ユーザー 「%s」 を削除できませんでした
Users_Removed_Failed_Admin              ユーザー 「%s」 を削除できませんでした。先に管理者権限を無効にしてください
Users_Changed_Password                  ユーザー 「%s」 のパスワードを変更しました
Users_Change_Password_Failed            ユーザー 「%s」 のパスワードが変更できませんでした
Users_Change_Password_Failed_Mismatch   ユーザー 「%s」 のパスワードが変更できませんでした。 新パスワードと新パスワードの確認は同一でなくてはなりません
Users_Reset_Password                    ユーザー 「%s」 のパスワードを初期化しました（新しい初期パスワードは 「%s」）
Users_Reset_Password_Failed             ユーザー 「%s」 のパスワードが初期化できませんでした
Users_SingleUserMode                    シングルユーザーモード（POPFile クラシック）
Users_Accounts                          関連づけられた POP3 アカウント
Users_AddAccount                        POP3 アカウントの追加（ホスト名:ユーザー名）
Users_Bad_Account                       新しいアカウント名は「ホスト名:ユーザー名」の形式でなければなりません
Users_Duplicate_Account                 アカウントを追加できませんでした。別のユーザーに関連づけられています
Users_Failed_Account                    アカウントを追加できませんでした。
Users_SingleUserModeOn                  POPFile は「シングルユーザーモード（POPFile クラシック）」に変更されました。POPFile を再起動することをお勧めします。
Users_MultiUserModeOn                   POPFile は「マルチユーザーモード」に変更されました。POPFile を再起動することをお勧めします。

History_Filter                          &nbsp;(<font color="%s">%s </font>バケツのみを表示)
History_FilterBy                        フィルタリング
History_Search                          &nbsp;(差出人/件名 を検索: %s)
History_Title                           最近のメッセージ
History_Jump                            次のメッセージにジャンプ
History_ShowAll                         全て表示
History_ShouldBe                        再分類先
History_NoFrom                          差出人なし
History_NoSubject                       件名なし
History_ClassifyAs                      分類先
History_MagnetUsed                      マグネット使用
History_MagnetBecause                   <b>マグネット使用</b><p>「<font color="%s">%s</font>」 に分類されました。(マグネット 「%s」のため)</p>
History_ChangedTo                       変更先 「<font color="%s">%s</font>」
History_Already                         「<font color="%s">%s</font>」 に分類されました
History_RemoveAll                       全て削除
History_RemovePage                      このページを削除
History_RemoveChecked                   チェックされたものを削除
History_SearchMessage                   差出人/件名 を検索
History_NoMessages                      該当メッセージはありません
History_ShowMagnet                      マグネット
History_Negate_Search                   条件にあわないものを検索
History_Magnet                          &nbsp;(マグネット分類されたメッセージのみを表示)
History_NoMagnet                        &nbsp;(マグネット分類されなかったメッセージのみを表示)
History_ResetSearch                     リセット
History_ChangedClass                    現在のコーパスによる分類
History_Purge                           すぐに削除
History_Increase                        広く
History_Decrease                        狭く
History_Column_Characters               履歴の列の幅
History_Automatic                       自動
History_Reclassified                    再分類されました
History_Size_Bytes                      %d&nbsp;B
History_Size_KiloBytes                  %.1f&nbsp;KB
History_Size_MegaBytes                  %.1f&nbsp;MB

Password_Title                          ログイン
Password_Password                       パスワード
Password_Username                       ユーザー名
Password_Go                             ログイン
Password_Error1                         パスワードが間違っています
Password_Error2                         ユーザー名またはパスワードが間違っています
Password_SessionTimeout                 POPFile のセッションは時間切れになりました

Security_Error1                         認証ポート番号は 1 から 65535 までにしてください。
Security_Stealth                        ステルスモード/サーバーオペレーション
Security_NoStealthMode                  いいえ (ステルスモード)
Security_StealthMode                    ステルスモード (リモートからの接続を禁止)
Security_ServerMode                     サーバーモード (リモートからの接続を許可)
Security_ExplainStats                   (このオプションを有効にすると、POPFile は毎日一回以下の三つのデータを getpopfile.org 上のスクリプトに送ります。: bc (バケツの総数)、mc (POPFile が分類したメッセージの総数)、ec (分類エラーの総数)。これらはファイルに記録され、POPFile がどのように使用され、どの程度の効果をあげているのかを示す統計情報として公開させていただきます。Web サーバーはこれらのログファイルを約五日間保存したあと、削除します。これらの統計値を IP アドレスと関連付けて保存することはいっさいありません。)
Security_ExplainUpdate                  (このオプションを有効にすると、POPFile は毎日一回以下の三つのデータを getpopfile.org 上のスクリプトに送ります。: ma (インストールされている POPFile のメジャーバージョン番号)、mi (インストールされている POPFile のマイナーバージョン番号)、bn (インストールされている POPFile のビルド番号)。新しいバージョンがリリースされると、POPFile はその情報を受けてページの上部にグラフィックを表示してお知らせします。Web サーバーはこれらのログファイルを約五日間保存したあと、削除します。これらの更新チェックに使用したデータを IP アドレスと関連付けて保存することはいっさいありません。)
Security_PasswordTitle                  ユーザーインターフェースパスワード
Security_Password                       パスワード
Security_PasswordUpdate                 パスワードを 「%s」に変更しました
Security_AUTHTitle                      リモートサーバー
Security_SecureServer                   リモート POP3 サーバー (SPA/AUTH または 透過プロキシ)
Security_SecureServerUpdate             リモート POP3 サーバーを 「%s」 に変更しました。
Security_SecurePort                     リモート POP3 ポート番号 (SPA/AUTH または 透過プロキシ)
Security_SecurePortUpdate               リモート POP3 ポート番号を 「%s」 に変更しました。
Security_SecureServerUseSSL             SSL を使用する
Security_SecureServerUseSSLOn           リモート POP3 サーバーとの接続に SSL を使用します
Security_SecureServerUseSSLOff          リモート POP3 サーバーとの接続に SSL を使用しません
Security_SMTPServer                     SMTP チェーンサーバー
Security_SMTPServerUpdate               SMTP チェーンサーバーを 「%s」 に変更しました。この変更は POPFile を再起動するまで有効になりません。
Security_SMTPPort                       SMTP チェーンポート番号
Security_SMTPPortUpdate                 SMTP チェーンポート番号を 「%s」 に変更しました。この変更は POPFile を再起動するまで有効になりません。
Security_POP3                           リモートマシンからの POP3 接続を認める (POPFile の再起動が必要)
Security_POP3S                          リモートマシンからの POP3S 接続を認める (POPFile の再起動が必要)
Security_SMTP                           リモートマシンからの SMTP 接続を認める (POPFile の再起動が必要)
Security_NNTP                           リモートマシンからの NNTP 接続を認める (POPFile の再起動が必要)
Security_UI                             リモートマシンからの HTTP 接続(ユーザーインターフェースの利用)を認める (POPFile の再起動が必要)
Security_XMLRPC                         リモートマシンからの XML-RPC 接続を認める (POPFile の再起動が必要)
Security_StealthModeUpdatePOP3          POPFile POP3 プロキシ は他のマシンからの接続を「拒否」します。この変更は POPFile を再起動するまで有効になりません。
Security_ServerModeUpdatePOP3           POPFile POP3 プロキシ は他のマシンからの接続を「許可」します。この変更は POPFile を再起動するまで有効になりません。
Security_StealthModeUpdatePOP3S         POPFile POP3S プロキシ は他のマシンからの接続を「拒否」します。この変更は POPFile を再起動するまで有効になりません。
Security_ServerModeUpdatePOP3S          POPFile POP3S プロキシ は他のマシンからの接続を「許可」します。この変更は POPFile を再起動するまで有効になりません。
Security_StealthModeUpdateSMTP          POPFile SMTP プロキシ は他のマシンからの接続を「拒否」します。この変更は POPFile を再起動するまで有効になりません。
Security_ServerModeUpdateSMTP           POPFile SMTP プロキシ は他のマシンからの接続を「許可」します。この変更は POPFile を再起動するまで有効になりません。
Security_StealthModeUpdateNNTP          POPFile NNTP プロキシ は他のマシンからの接続を「拒否」します。この変更は POPFile を再起動するまで有効になりません。
Security_ServerModeUpdateNNTP           POPFile NNTP プロキシ は他のマシンからの接続を「許可」します。この変更は POPFile を再起動するまで有効になりません。
Security_StealthModeUpdateUI            POPFile UI (コントロールセンター) は他のマシンからの接続を「拒否」します。この変更は POPFile を再起動するまで有効になりません。
Security_ServerModeUpdateUI             POPFile UI (コントロールセンター) は他のマシンからの接続を「許可」します。この変更は POPFile を再起動するまで有効になりません。
Security_StealthModeUpdateXMLRPC        POPFile XML-RPC インターフェース は他のマシンからの接続を「拒否」します。この変更は POPFile を再起動するまで有効になりません。
Security_ServerModeUpdateXMLRPC         POPFile XML-RPC インターフェース は他のマシンからの接続を「許可」します。この変更は POPFile を再起動するまで有効になりません。
Security_UpdateTitle                    更新自動チェック
Security_Update                         POPFile が更新されているかどうか毎日チェックする
Security_StatsTitle                     統計情報レポート
Security_Stats                          統計情報を毎日送る
Security_UpdateOn                       POPFile は毎日更新されているかどうかをチェックします。
Security_UpdateOff                      POPFile は更新されているかどうかのチェックをしません
Security_StatsOn                        POPFile は毎日統計情報レポートを送ります
Security_StatsOff                       POPFile は統計情報レポートを送りません

Magnet_Error1                           マグネット 「%s」 には既にバケツ 「%s」 を割り当てています
Magnet_Error2                           新規マグネット 「%s」 は既にあるマグネット 「%s」 (バケツ 「%s」 が割り当てられています) と衝突するため、正しい処理をおこなうことができません。新規マグネットは追加されませんでした
Magnet_Error3                           新規マグネット 「%s」 にバケツ 「%s」 を割り当てました
Magnet_RemovedMagnets                   マグネット 「%s」 をバケツ 「%s」 から削除しました
Magnet_CurrentMagnets                   現在のマグネット
Magnet_Message1                         次のマグネットにより、メールを常に特定のバケツに分類します。
Magnet_CreateNew                        新規マグネット作成
Magnet_Explanation                      <b>マグネットには三つのタイプがあります:</b> <ul><li><b>差出人のアドレスまたは名前:</b> 例: john@company.com は特定のアドレスにマッチし、<br />company.com は company.com に属する全ての人にマッチし、<br />John Doe は特定の人にマッチし、John は John という名前の全ての人にマッチします。</li><li><b>宛先/Ccのアドレスまたは名前:</b> 差出人のマグネットと同様ですがメールの宛先または Cc が対象になります。</li> <li><b>件名に含まれる単語:</b> 例: hello は hello を件名に含む全てのメッセージにマッチします。</li></ul>
Magnet_MagnetType                       マグネットタイプ
Magnet_Value                            値
Magnet_Always                           分類先のバケツ
Magnet_Jump                             マグネットページにジャンプ
Magnet_Note                             マグネットは POPFile の学習プロセスをバイパスすることになるため、慎重に使うべきです。マグネットを使用することにより、POPFile が高い精度に達するまでにより長い時間がかかることになるでしょう。<br /><br >マグネットについての詳細は<a href="http://getpopfile.org/docs/jp:glossary:amagnet">POPFile ドキュメンテーションプロジェクト</a>をお読みください。

Bucket_Error1                           バケツ名にはアルファベットの小文字(a から z まで)か - (ハイフン)、または _ (アンダースコア)しか使えません。
Bucket_Error2                           バケツ 「%s」は既にあります。
Bucket_Error3                           バケツ 「%s」を作成しました。
Bucket_Error4                           スペースは入力しないでください。
Bucket_Error5                           バケツ 「%s」を 「%s」に変更しました。
Bucket_Error6                           バケツ 「%s」を削除しました。
Bucket_Title                            サマリー
Bucket_BucketName                       バケツ名
Bucket_WordCount                        単語数
Bucket_WordCounts                       単語数
Bucket_UniqueWords                      固有単語数
Bucket_SubjectModification              件名の変更
Bucket_ChangeColor                      色の変更
Bucket_NotEnoughData                    データ不十分
Bucket_ClassificationAccuracy           分類精度
Bucket_EmailsClassified                 分類されたメール数
Bucket_EmailsClassifiedUpper            分類されたメール数
Bucket_ClassificationErrors             分類エラーの数
Bucket_Accuracy                         精度
Bucket_ClassificationCount              分類数
Bucket_ClassificationFP                 誤検出
Bucket_ClassificationFN                 見逃し
Bucket_ResetStatistics                  リセット
Bucket_LastReset                        最後のリセット
Bucket_MessagesPerDay                   1 日あたりのメール数
Bucket_CurrentColor                     「%s」現在の色は 「%s」
Bucket_SetColorTo                       「%s」の色を 「%s」に設定
Bucket_Maintenance                      管理
Bucket_CreateBucket                     バケツ作成
Bucket_DeleteBucket                     バケツ削除
Bucket_RenameBucket                     バケツの名前変更
Bucket_Lookup                           検査
Bucket_LookupMessage                    バケツ内で単語を検査
Bucket_LookupMessage2                   検査結果 : 
Bucket_LookupMostLikely                 「<b>%s</b>」 は 「<font color="%s">%s</font>」 内にある可能性が大きいです。
Bucket_DoesNotAppear                    <p>「<b>%s</b>」 はどのバケツの中にもありません。
Bucket_DisabledGlobally                 全て OFF
Bucket_To                               を
Bucket_Quarantine                       隔離

SingleBucket_Title                      「%s」の詳細
SingleBucket_WordCount                  バケツ内単語数
SingleBucket_TotalWordCount             総単語数
SingleBucket_Percentage                 総数に対する割合
SingleBucket_WordTable                  「%s」の単語表
SingleBucket_Message1                   アスタリスク (*) が付いた単語は現在の POPFile セッション中の分類に使われました。すべてのバケツに対する確率を検査するには単語をクリックして下さい。
SingleBucket_Unique                     固有単語数 %s
SingleBucket_ClearBucket                全ての単語を削除

Session_Title                           POPFile セッションは終了しました。
Session_Error                           POPFile セッションは終了しました。これは、POPFile を起動したり終了したのに、ブラウザーを開いたままにしていると起こる可能性があります。POPFile を引き続き使用するには、上に表示されているリンクの内の一つをクリックして下さい。

View_Title                              シングルメッセージビュー
View_ShowFrequencies                    単語の頻度を表示
View_ShowProbabilities                  単語の確率を表示
View_ShowScores                         単語の得点を表示
View_WordMatrix                         単語マトリクス
View_WordProbabilities                  確率
View_WordFrequencies                    頻度
View_WordScores                         得点
View_Chart                              分類決定図
View_DownloadMessage                    メッセージをダウンロード

Windows_TrayIcon                        POPFile のアイコンを Windows システムトレイに表示する
Windows_Console                         POPFile のメッセージをコンソールウィンドウに出力する
Windows_NextTime                        この変更は POPFile を次回起動するまで有効になりません。

Header_MenuSummary                      This table is the navigation menu which allows access to each of the different pages of the control center.
History_MainTableSummary                This table shows the sender and subject of recently received messages and allows them to be reviewed and reclassified.  Clicking on the subject line will show the full message text, along with information about why it was classified as it was.  The 'Should be' column allows you to specify which bucket the message belongs in, or to undo that change.  The 'Delete' column allows you to delete specific messages from the history if you don't need them anymore.
History_OpenMessageSummary              This table contains the full text of an email message, with the words that are used for classification highlighted according to the bucket that was most relevant for each.
Bucket_MainTableSummary                 This table provides an overview of the classification buckets.  Each row shows the bucket name, the word count total for that bucket, the actual number of individual words in each bucket, whether the email's subject line will be modified when it gets classified to that bucket, whether to quarantine the messages received in that bucket, and a table to pick the color used in displaying anything related to that bucket in the control center.
Bucket_StatisticsTableSummary           This table provides three sets of statistics on the overall performance of POPFile.  The first is how accurate its classification is, the second is how many emails have been classified, and to which buckets, and the third is how many words are in each bucket, and what their relative percentages are.
Bucket_MaintenanceTableSummary          This table contains forms that allow you to create, delete or rename buckets, and to lookup a word in all of the buckets to see its relative probabilities.
Bucket_AccuracyChartSummary             This table graphically represents the accuracy of the email classification.
Bucket_BarChartSummary                  This table graphically represents a percentage allocation for each of the different buckets.  It is used for both number of emails classified, and total word counts.
Bucket_LookupResultsSummary             This table shows the probabilities associated with any given word of the corpus.  For each bucket, it shows the frequency that that word occurs, the probability that it will occur in that bucket, and the overall effect on the score of the bucket if that word exists in an email.
Bucket_WordListTableSummary             This table provides a listing of all the words for a particular bucket, organized by common first letter for each row.
Magnet_MainTableSummary                 This table shows the list of magnets that are used to automatically classify email according to fixed rules.  Each row shows how the magnet is defined, what bucket it is intended for, and a button to delete the magnet.
Configuration_MainTableSummary          This table contains a number of forms to allow you to control the configuration of POPFile.
Configuration_InsertionTableSummary     This table contains buttons that determine whether or not certain modifications are made to the headers or subject line of the email before it is passed on to the email client.
Security_MainTableSummary               This table provides sets of controls that affect the security of the overall configuration of POPFile, whether it should automatically check for updates to the program, and whether statistics about POPFile's performance should be sent to the central datastore of the program's author for general information.
Advanced_MainTableSummary               This table provides a list of words that POPFile ignores when classifying email due to their relative frequency in email in general.  They are organized per row according to the first letter of the words.
Users_AccountTableSummary               This table provides a list of POP3 accounts that are associated with the user being edited.

Imap_Bucket2Folder                      バケツ 「<b>%s</b>」 に分類されたメールの移動先
Imap_MapError                           複数のバケツをひとつのフォルダに対応付けすることはできません。
Imap_MapUpdated                         バケツ 「%s」 を フォルダ 「%s」 に対応付けました。
Imap_Server                             IMAP サーバー ホスト名:
Imap_ServerNameError                    サーバーのホスト名を入力してください。
Imap_Port                               IMAP サーバー ポート番号:
Imap_PortError                          正しいポート番号を入力してください。
Imap_Login                              IMAP アカウント ユーザー名:
Imap_LoginError                         ユーザー名／ログイン名を入力してください。
Imap_Password                           IMAP アカウントのパスワード:
Imap_PasswordError                      サーバに対するパスワードを入力してください。
Imap_ConnectionDetailsUpdated           IMAP の接続設定が更新されました。次はフォルダリストを更新してください。
Imap_Expunge                            監視フォルダから移動されたメッセージを削除する。
Imap_Interval                           更新の間隔（秒）:
Imap_IntervalError                      更新間隔は 10 秒から 3600 秒の間で入力してください。
Imap_OptionsUpdated                     IMAP のオプションは正常に更新されました。
Imap_RefreshFolders                     フォルダリストの更新
Imap_Now                                実行
Imap_UpdateError1                       ログインできません。ユーザー名とパスワードを確認してください。
Imap_UpdateError2                       サーバーに接続できません。ホスト名とポート番号を確認するとともに、インターネットに接続されているかどうかを確認してください。
Imap_UpdateError3                       サーバーに接続するための情報を先に設定してください。
Imap_UpdateOK                           サーバーからメールボックス／フォルダのリストの読み込みに成功しました。
Imap_NoConnectionMessage                サーバに接続するための情報を先に設定してください。そうすると、さらに多くのオプションが設定できるようになります。
Imap_WatchMore                          監視フォルダリストにフォルダを追加
Imap_WatchedFolderAdded                 監視フォルダリストの項目をひとつ増やしました。監視したいフォルダを選んでください。
Imap_WatchedFolder                      監視フォルダ 
Imap_WatchedFoldersUpdated              監視フォルダのリストを更新しました
Imap_WatchedFolderRemoved               監視フォルダのリストからフォルダ '%' を削除しました
Imap_DoingTraining                      IMAP モジュールはこれからメッセージアーカイブから学習を始めるところです。学習が終わるまでの間 POPFile の UI は反応しなくなります。アーカイブの大きさや IMAP サーバとの接続速度にもよりますが、この処理にはしばらくかかります。
Imap_DoTraining                         既存のメールアーカイブから学習します。
Imap_Use_SSL                            SSL を使用する

Shutdown_Message                        POPFile は終了しました。

Help_Training                           POPFile をこれから使い始める場合、ある程度のトレーニングが必要となります。それは、POPFile はどのメールが必要なメールでどのメールが不要なメールかについてなにも知らないからです。トレーニングはそれぞれのバケツについて行う必要があり（最低でも１つのバケツについて、１つ以上のメッセージを再分類する）、POPFile が分類を間違えたメッセージを正しいバケツに再分類することによってトレーニングすることができます。また、POPFile が行った分類にあわせてフォルダに移動するなど、メールクライアントを設定する必要があります。メールクライアントの設定については、<a href="http://getpopfile.org/docs/JP:FAQ:EmailSorting">POPFile ドキュメンテーションプロジェクト</a>を参照してください。
Help_Bucket_Setup                       POPFile では、もともとある unclassified という仮想的なバケツ以外に、最低でも２つのバケツを作成する必要があります。POPFile の特徴は、（メールを spam とそれ以外に分類するというだけではなく）いくつでもバケツを作成し、それらにメールを分類することができることです。簡単な設定では、"spam"、"personal"、"work" といったバケツを設定することになるでしょう。
Help_No_More                            次回から表示しない。

# Tooltips used in title attribute of parts of the UI
tip_Menu_History                        POPFile が処理したメールを確認し、再分類します
tip_Menu_Buckets                        バケツを管理したり、分類の統計情報を確認します
tip_Menu_Magnets                        ベイジアンフィルタシステムをバイパスする単純なフィルタを管理します
tip_Menu_Admin                          オプション設定を変更します
tip_Menu_Users                          ユーザーを管理します
tip_Menu_Advanced                       高度な設定を変更します

tip_History_RecentNum                   現在の検索、フィルタに一致するメッセージの数
tip_History_Reclassify                  分類先バケツの修正を行います
tip_History_Search                      差出人のアドレスや件名が一致するものを探します
tip_History_Filter                      選択されたバケツのものだけを表示します
tip_History_SearchNegate                検索とフィルタの条件を反転します
tip_History_SearchSubmit                検索とフィルタを実行します
tip_History_SearchReset                 検索とフィルタをクリアします
tip_History_RemoveAll                   すべてのメッセージ（検索とフィルタに一致するもの）を履歴から削除します
tip_History_RemoveChecked               選択されたメッセージを履歴から削除します
tip_History_RemovePage                  このページに表示されているメッセージを履歴から削除します
tip_History_RemoveColumn                列を削除します
tip_History_MoveLeft                    左へ移動します
tip_History_MoveRight                   右へ移動します
tip_History_Sort                        この列で並び替えます

tip_Bucket_BucketName                   バケツの詳細を確認します
tip_Bucket_Unique                       それぞれのバケツの固有単語数
tip_Bucket_SubjectMod                   件名の最初にバケツの名前を追加します
tip_Bucket_XTCHeader                    POPFile の分類結果に基づくヘッダを追加します。このヘッダはほとんどのメールクライアントがフィルタに利用できます
tip_Bucket_XPLHeader                    メッセージへのリンクを含むヘッダを追加します。このヘッダによりすぐにメッセージを再分類することができます。
tip_Bucket_Quarantine                   潜在的に危険なメールを隔離し、添付ファイルにします
tip_Bucket_Color                        それぞれのバケツの色を選択します
tip_Bucket_Lookup                       ある単語についてそれぞれのバケツに含まれる確率と頻度を調べます
tip_Bucket_Accuracy                     総合的な分類精度
tip_Bucket_Classified                   バケツの統計情報と精度
tip_Bucket_WordCount                    それぞれのバケツに存在する単語の総数と割合
tip_Bucket_Create                       新しいバケツを作成します
tip_Bucket_Delete                       バケツとこのバケツへの学習内容を削除します
tip_Bucket_Rename                       バケツの名前を変更します
tip_Bucket_FalsePos                     誤ってこのバケツに分類されたメッセージ
tip_Bucket_FalseNeg                     誤ってこのバケツに分類されなかったメッセージ
tip_Bucket_ResetStats                   分類精度の統計情報を初期化します

tip_Magnet_Type                         一致するメッセージヘッダ
tip_Magnet_Value                        一致するテキストまたはアドレス
tip_Magnet_Bucket                       一致したメッセージを移動するバケツ

tip_Config_Skin                         POPFile の見た目を変更します
tip_Config_Language                     インターフェースの言語を変更します
tip_Config_HistoryColumns               メッセージ履歴に表示したい列を追加します
tip_Config_PageSize                     1 ページに表示するメッセージの数
tip_Config_Days                         履歴にメッセージを残す日数
tip_Config_Purge                        古いメッセージをすぐに削除します
tip_Config_HistoryWidth                 履歴の列の幅を調整します
tip_Config_ColumnIncrease               列の幅を広くします
tip_Config_ColumnDecrease               列の幅を狭くします
tip_Config_ColumnAuto                   列の幅を初期化します
tip_Config_HideBar                      設定バーを隠します
tip_Config_ShowBar                      設定バーを表示します
tip_Config_Password                     POPFile コントロールセンターにアクセスするためのパスワードを変更します

tip_Admin_AcceptRemoteHTTP              他のマシンからの UI へのアクセスを許可します
tip_Admin_AcceptRemotePOP3              他のマシンからの POP3 メールのダウンロードを許可します
tip_Admin_Password                      POPFile へのアクセスを制限するためにパスワードを設定します
tip_Admin_UpdateCheck                   0.22 text should be put back
tip_Admin_ReportStats                   0.22 text should be put back

tip_Users_Remove                        POPFile のユーザーを削除します
tip_Users_Rename                        ユーザーの名前を変更します
tip_Users_Change_Password               ユーザーのパスワードを変更します

tip_Accounts_Remove                     ユーザーのアカウントを削除します

tip_Footer_HomePage                     POPFile ホームページに接続します
tip_Footer_Manual                       オリジナルの POPFile のドキュメント（少し古い）
tip_Footer_Wiki                         POPFile ドキュメント（Wiki）
tip_Footer_FAQ                          POPFile についてのよくある質問と回答（FAQ）
tip_Footer_Version                      POPFile のバージョン番号
tip_Footer_Login                        このユーザーが最後にアクセスした日時
tip_Footer_RFE                          POPFile を改善するためのアイデアがありますか？ もしあれば教えてください。
tip_Footer_MailingList                  POFile についての変更について知りたいですか？ もし知りたければ登録してください。
tip_Footer_FeedMe                       POPFile を気に入っていただけましたか？ 気に入っていただいたら、よりよくするために寄付をお願いします。

# Jim's Bucket Stats stuff
Words                                   単語
Percent                                 パーセント
Header_ConfigurationShort               設定
Footer_HomePage_short                   ホームページ
Footer_QuickStart                       クイックスタート
Footer_WikiShort                        ドキュメント
Bucket_BreakEmailsClassifiedUpper       分類された<br>メッセージ
Bucket_ClassificationErrorsUpper        分類ミス
Bucket_BreakClassificationFP            誤検出
Bucket_BreakClassificationFN            見逃し
Bucket_HitRate                          成功率
Bucket_StrikeRate                       失敗率

