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

# Identify the language and character set used for the interface
LanguageCode                            ja
LanguageCharset                         EUC-JP
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          jp

# Common words that are used on their own all over the interface
Apply                                   適用
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
To                                      宛て先
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

# The header and footer that appear on every UI page
Header_Title                            POPFile コントロールセンター
Header_Shutdown                         POPFile の停止
Header_History                          履歴
Header_Buckets                          バケツ
Header_Configuration                    設定
Header_Advanced                         詳細設定
Header_Security                         セキュリティ
Header_Magnets                          マグネット

Footer_HomePage                         POPFile ホームページ
Footer_Manual                           マニュアル
Footer_Forums                           フォーラム
Footer_FeedMe                           寄付
Footer_RequestFeature                   要望
Footer_MailingList                      メーリングリスト

Configuration_Error1                    区切り文字は1文字だけにしてください。
Configuration_Error2                    ユーザーインターフェース用ポート番号は1から65535までにしてください。
Configuration_Error3                    POP3 ポート番号は1から65535までにしてください。
Configuration_Error4                    ページサイズは1から1000までにしてください。
Configuration_Error5                    履歴を残す日数は1から366までにしてください。
Configuration_Error6                    TCP タイムアウトは10から300にしてください。
Configuration_Error7                    XML RPC ポート番号は1から65535までにしてください。
Configuration_POP3Port                  POP3 ポート番号
Configuration_POP3Update                POP3 ポート番号を %s に変更しました。この変更は POPFile を再起動するまで有効になりません。

Configuration_XMLRPCUpdate              XML-RPC ポート番号を %s に変更しました。この変更は POPFile を再起動するまで有効になりません。
Configuration_XMLRPCPort                XML-RPC ポート番号
Configuration_SMTPPort                  SMTP ポート番号
Configuration_SMTPUpdate                SMTP ポート番号を %s に変更しました。この変更は POPFile を再起動するまで有効になりません。
Configuration_NNTPPort                  NNTP ポート番号
Configuration_NNTPUpdate                NNTP ポート番号を %s に変更しました。この変更は POPFile を再起動するまで有効になりません。
Configuration_POPFork                   POP3 同時接続の許可
Configuration_SMTPFork                  SMTP 同時接続の許可
Configuration_NNTPFork                  NNTP 同時接続の許可
Configuration_POP3Separator             POP3 host:port:user 区切り文字
Configuration_NNTPSeparator             NNTP host:port:user 区切り文字
Configuration_POP3SepUpdate             POP3 区切り文字を %s に変更しました。
Configuration_NNTPSepUpdate             NNTP 区切り文字を %s に変更しました。
Configuration_UI                        ユーザーインターフェース用ポート番号
Configuration_UIUpdate                  ユーザーインターフェース用ポート番号を %s に変更しました。この変更は POPFile を再起動するまで有効になりません。
Configuration_History                   1ページに表示するメールの数
Configuration_HistoryUpdate             1ページに表示するメールの数を %s に変更しました。
Configuration_Days                      履歴を残す日数
Configuration_DaysUpdate                履歴を残す日数を %s に変更しました。
Configuration_UserInterface             ユーザーインターフェース
Configuration_Skins                     スキン
Configuration_SkinsChoose               スキンを選択してください
Configuration_Language                  言語
Configuration_LanguageChoose            言語を選択してください
Configuration_ListenPorts               ポート番号
Configuration_HistoryView               履歴
Configuration_TCPTimeout                TCP コネクションタイムアウト
Configuration_TCPTimeoutSecs            TCP コネクションタイムアウトの秒数
Configuration_TCPTimeoutUpdate          TCP コネクションタイムアウトを %s に変更しました。
Configuration_ClassificationInsertion   電子メールへのテキスト挿入機能
Configuration_SubjectLine               件名の変更
Configuration_XTCInsertion              X-Text-Classification ヘッダー
Configuration_XPLInsertion              X-POPFile-Link ヘッダー
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

Advanced_Error1                         '%s' は既に無視する単語のリストに含まれています。
Advanced_Error2                         無効な文字が使われています。再度入力して下さい。
Advanced_Error3                         '%s' を無視する単語のリストに追加しました。
Advanced_Error4                         '%s' は無視する単語のリストに含まれていません。
Advanced_Error5                         '%s' を無視する単語のリストから削除しました。
Advanced_StopWords                      無視する単語
Advanced_Message1                       POPFile は以下の頻繁に使われる単語を無視します。
Advanced_AddWord                        単語追加
Advanced_RemoveWord                     単語削除
Advanced_AllParameters                  POPFile 全パラメーター
Advanced_Parameter                      パラメーター
Advanced_Value                          値
Advanced_Warning                        以下は POPFile の全てのパラメーターのリストです。アドバンスド・ユーザーに限り、必要時、値を変更して更新ボタンをクリックして下さい。バリディティー（妥当性）チェックは行いません。

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
History_MagnetBecause                   <b>マグネット使用</b><p><font color="%s">%s</font> に分類されました。(マグネット %s のため)</p>
History_ChangedTo                       変更先 <font color="%s">%s
History_Already                         <font color="%s">%s</font> に分類されました
History_RemoveAll                       全て削除
History_RemovePage                      このページを削除
History_Remove                          履歴からメッセージを削除
History_SearchMessage                   差出人/件名 を検索
History_NoMessages                      該当メッセージはありません
History_ShowMagnet                      マグネット
History_ShowNoMagnet                    非マグネット
History_Magnet                          &nbsp;(マグネット分類されたメッセージのみを表示)
History_NoMagnet                        &nbsp;(マグネット分類されなかったメッセージのみを表示)
History_ResetSearch                     リセット

Password_Title                          パスワード
Password_Enter                          パスワードを入力してください
Password_Go                             ログイン
Password_Error1                         パスワードが間違っています

Security_Error1                         認証ポート番号は1から65535までにしてください。
Security_Stealth                        ステルスモード/サーバーオペレーション
Security_NoStealthMode                  いいえ (ステルスモード)
Security_ExplainStats                   (POPFile は毎日一回、以下の三つのデータを www.usethesource.com 上のスクリプトに送ります。: bc (バケツの総数)、mc (POPFile が分類したメッセージの総数)、ec (分類エラーの総数)。これらはファイルに記録され、POPFile がどのように使用され、どの程度の効果をあげているのかを示す統計情報として公開させていただきます。使用しています Web サーバーはこれらのログファイルを約五日間保存したあと、削除します。これらの統計値を IP アドレスと関連付けて保存したりはいっさいいたしません。)
Security_ExplainUpdate                  (POPFile は毎日一回、以下の三つのデータを www.usethesource.com 上のスクリプトに送ります。: ma (インストールされている POPFile のメジャーバージョン番号)、mi (インストールされている POPFile のマイナーバージョン番号)、bn (インストールされている POPFile のビルド番号)。新しいバージョンがリリースされると、POPFile はその情報を受けてページの上部にグラフィックを表示してお知らせします。使用しています Web サーバーはこれらのログファイルを約五日間保存したあと、削除します。これらの更新チェックに使用したデータを IP アドレスと関連付けて保存したりはいっさいいたしません。)
Security_PasswordTitle                  ユーザーインターフェースパスワード
Security_Password                       パスワード
Security_PasswordUpdate                 パスワードを %s に変更しました
Security_AUTHTitle                      リモートサーバー
Security_SecureServer                 　POP3 SPA/AUTH サーバー
Security_SecureServerUpdate             POP3 SPA/AUTH サーバーを %s に変更しました。この変更は POPFile を再起動するまで有効になりません。
Security_SecurePort                     POP3 SPA/AUTH ポート番号
Security_SecurePortUpdate               POP3 SPA/AUTH ポート番号を %s に変更しました。この変更は POPFile を再起動するまで有効になりません。
Security_SMTPServer                     SMTP チェーンサーバー
Security_SMTPServerUpdate               SMTP チェーンサーバーを %s に変更しました。この変更は POPFile を再起動するまで有効になりません。
Security_SMTPPort                       SMTP チェーンポート番号
Security_SMTPPortUpdate                 SMTP チェーンポート番号を %s に変更しました。この変更は POPFile を再起動するまで有効になりません。
Security_POP3                           リモートマシンからの POP3 接続を認める (POPFile の再起動が必要)
Security_SMTP                           リモートマシンからの SMTP 接続を認める (POPFile の再起動が必要)
Security_NNTP                           リモートマシンからの NNTP 接続を認める (POPFile の再起動が必要)
Security_UI                             リモートマシンからの HTTP 接続(ユーザーインターフェースの利用)を認める (POPFile の再起動が必要)
Security_XMLRPC                         リモートマシンからの XML-RPC 接続を認める (POPFile の再起動が必要)
Security_UpdateTitle                    更新自動チェック
Security_Update                         POPFile が更新されているかどうか毎日チェックします
Security_StatsTitle                     統計情報レポート
Security_Stats                          統計情報を毎日送る

Magnet_Error1                           マグネット '%s' には既にバケツ '%s' を割り当てています。
Magnet_Error2                           新規マグネット '%s' は既にあるマグネット '%s' (バケツ '%s' が割り当てられています) と衝突するため、正しい処理をおこなうことができません。新規マグネットは追加しませんでした。
Magnet_Error3                           新規マグネット '%s' にバケツ '%s' を割り当てました。
Magnet_CurrentMagnets                   現在のマグネット
Magnet_Message1                         次のマグネットにより、メールを常に特定のバケツに分類します。
Magnet_CreateNew                        新規マグネット作成
Magnet_Explanation                      マグネットには三つのタイプがあります:</b> <ul><li><b>差出人のアドレスまたは名前:</b> 例: john@company.com のように特定のアドレスがマッチする、<br />company.com のように company.com に属する全ての人たちがマッチする、<br />John Doe のように特定の人がマッチする、John のようにJohn という名前を持つ全ての人たちがマッチする。</li><li><b>宛先のアドレスまたは名前:</b> From: magnet と同様ですがメールの To: アドレスが対象です。</li> <li><b>件名に含まれる単語:</b> 例: hello とすると hello を件名に含む全てのメッセージがマッチします。</li></ul>
Magnet_MagnetType                       マグネットタイプ
Magnet_Value                            値
Magnet_Always                           分類先のバケツ
Magnet_Jump                             マグネットページにジャンプ

Bucket_Error1                           バケツ名にはアルファベットの小文字(a から z まで)か - (ハイフン)、または _ (アンダースコア)しか使えません。
Bucket_Error2                           バケツ %s は既にあります。
Bucket_Error3                           バケツ %s を作成しました。
Bucket_Error4                           スペースは入力しないでください。
Bucket_Error5                           バケツ %s を %s に変更しました。
Bucket_Error6                           バケツ %s を削除しました。
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
Bucket_CurrentColor                     %s 現在の色は %s
Bucket_SetColorTo                       %s の色を %s に設定
Bucket_Maintenance                      管理
Bucket_CreateBucket                     バケツ作成
Bucket_DeleteBucket                     バケツ削除
Bucket_RenameBucket                     バケツの名前変更
Bucket_Lookup                           検査
Bucket_LookupMessage                    バケツ内で単語を検査
Bucket_LookupMessage2                   検査結果 : 
Bucket_LookupMostLikely                 <b>%s</b> は <font color="%s">%s</font> 内にある可能性が大きいです。
Bucket_DoesNotAppear                    <p><b>%s</b> はどのバケツの中にもありません。
Bucket_DisabledGlobally                 全て OFF
Bucket_To                               を
Bucket_Quarantine                       隔離

SingleBucket_Title                      %s の詳細
SingleBucket_WordCount                  バケツ内単語数
SingleBucket_TotalWordCount             総単語数
SingleBucket_Percentage                 総数に対する割合
SingleBucket_WordTable                  %s の単語表
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

Windows_TrayIcon                        POPFile のアイコンを Windows システムトレイに表示しますか？
Windows_Console                         POPFile のメッセージをコンソールウィンドウに出力しますか？
Windows_NextTime                        <p><font color="red">この変更は POPFile を次回起動するまで有効になりません。</font>

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

