# Copyright (c) 2001-2003 John Graham-Cumming
# POPFile 0.18.1 Traditional Chinese Translation, Created By Mark Wu, 2003/03/04
# POPFile 0.19.0 Traditional Chinese Translation, Modified By Mark Wu, 2003/06/02

# Identify the language and character set used for the interface
LanguageCode                            tw
LanguageCharset                         big5

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en

# Common words that are used on their own all over the interface
Apply                                   套用
On                                      開
Off                                     關
TurnOn                                  開啟
TurnOff                                 關閉
Add                                     加入
Remove                                  移除
Previous                                上一頁
Next                                    下一頁
From                                    寄件者
Subject                                 主旨
Cc                                      副本 
Classification                          分類
Reclassify                              重新分類
Probability                             機率
Scores                                  分數
QuickMagnets                            快速規則精靈
Undo                                    復原
Close                                   關閉
Find                                    搜尋
Filter                                  過濾
Yes                                     是
No                                      否
ChangeToYes                             是
ChangeToNo                              否
Bucket                                  分類
Magnet                                  規則
Delete                                  刪除
Create                                  建立
To                                      收件者
Total                                   全部
Rename                                  重新命名
Frequency                               頻率
Probability                             機率
Score                                   分數
Lookup                                  查看
Word                                    單字
Count                                   計數
Update                                  更新
Refresh                                 重新整理

# The header and footer that appear on every UI page
Header_Title                            POPFile 控制台
Header_Shutdown                         停止 POPFile
Header_History                          歷史
Header_Buckets                          分類
Header_Configuration                    設定
Header_Advanced                         進階
Header_Security                         安全
Header_Magnets                          規則

Footer_HomePage                         POPFile 首頁
Footer_Manual                           使用手冊
Footer_Forums                           論壇
Footer_FeedMe                           贊助
Footer_RequestFeature                   功能建議
Footer_MailingList                      郵件群組

Configuration_Error1                    分隔字元必須為單一字元
Configuration_Error2                    使用者介面連接埠必須介於 1 到 65535 之間
Configuration_Error3                    POP3 伺服器連接埠必須介於 1 到 65535 之間
Configuration_Error4                    每一頁顯示信件數必須介於 1 到 1000 之間
Configuration_Error5                    歷史紀錄天數必須介於 1 到 366 之間
Configuration_Error6                    連接逾時秒數介於 10 到 300 之間
Configuration_Error7                    XML-RPC 接收埠必須介於 1 到 65535 之間
Configuration_POP3Port                  POP3 伺服器連接埠
Configuration_POP3Update                更新 POP3 伺服器連接埠為 %s; 需重新啟動 POPFile
Configuration_XMLRPCUpdate              更新 XML-RPC 連接埠為 %s; 需重新啟動 POPFile
Configuration_XMLRPCPort                XML-RPC 連接埠
Configuration_SMTPPort                  SMTP 伺服器連接埠
Configuration_SMTPUpdate                更新 SMTP 伺服器連接埠為 %s; 需重新啟動 POPFile
Configuration_NNTPPort                  NNTP 伺服器連接埠
Configuration_NNTPUpdate                更新 NNTP 伺服器連接埠為 %s; 需重新啟動 POPFile
Configuration_POP3Separator             SMTP 伺服器 host:port:user 分隔字元
Configuration_NNTPSeparator             NNTP 伺服器 host:port:user 分隔字元
Configuration_POP3SepUpdate             更新 POP3 伺服器分隔字元為 %s
Configuration_NNTPSepUpdate             更新 NNTP 伺服器分隔字元為 %s
Configuration_UI                        使用者介面連接埠
Configuration_UIUpdate                  更改使用者介面連接埠為 %s; 需重新啟動 POPFile
Configuration_History                   每一頁顯示信件數
Configuration_HistoryUpdate             更改每一頁顯示信件數為 to %s
Configuration_Days                      歷史紀錄天數
Configuration_DaysUpdate                更改歷史紀錄天數為 %s
Configuration_UserInterface             使用者介面
Configuration_Skins                     面版
Configuration_SkinsChoose               選擇面版
Configuration_Language                  語言
Configuration_LanguageChoose            選擇語言
Configuration_ListenPorts               模組選項
Configuration_HistoryView               歷史檢視
Configuration_TCPTimeout                連接逾時
Configuration_TCPTimeoutSecs            連接逾時秒數
Configuration_TCPTimeoutUpdate          更新連接逾時秒數為 %s 秒
Configuration_ClassificationInsertion   E-Mail 內容修改
Configuration_SubjectLine               信件主旨修改
Configuration_XTCInsertion              加入 X-Text-Classification 到信件標題中
Configuration_XPLInsertion              加入 X-POPFile-Link 到信件標題中
Configuration_Logging                   紀錄
Configuration_None                      無
Configuration_ToScreen                  輸出到螢幕
Configuration_ToFile                    輸出到檔案
Configuration_ToScreenFile              輸出到螢幕與檔案
Configuration_LoggerOutput              記錄輸出方式
Configuration_GeneralSkins              面版
Configuration_SmallSkins                面版(小字形)
Configuration_TinySkins                 面版(迷你字形)
Configuration_CurrentLogFile            &lt;現在運作中的紀錄檔&gt;

Advanced_Error1                         '%s' 已經存在忽略單字字表中
Advanced_Error2                         忽略單字只可包含英文,數字, ., _, -, 或 @ 等字元
Advanced_Error3                         '%s' 已經加入忽略單字字表中
Advanced_Error4                         '%s' 不存在忽略單字字表中
Advanced_Error5                         '%s' 已經從忽略單字字表中移除
Advanced_StopWords                      忽略單字字表
Advanced_Message1                       POPFile 會忽略以下出現頻率較高的單字:
Advanced_AddWord                        加入單字
Advanced_RemoveWord                     移除單字

History_Filter                          &nbsp;(顯示分類 <font color="%s">%s</font>)
History_FilterBy                        過濾條件
History_Search                          &nbsp;(搜尋寄件者/主旨 %s)
History_Title                           最近信件
History_Jump                            移至信件
History_ShowAll                         全部顯示
History_ShouldBe                        應該是
History_NoFrom                          沒有寄件者
History_NoSubject                       沒有主旨
History_ClassifyAs                      分類為
History_MagnetUsed                      使用規則
History_MagnetBecause                   <b>使用規則</b><p>分類為 <font color="%s">%s</font> 因為規則 %s </p>
History_ChangedTo                       改變為 <font color="%s">%s
History_Already                         已經重新分類為 <font color="%s">%s</font>
History_RemoveAll                       全部移除
History_RemovePage                      移除這一頁
History_Remove                          移除歷史信件
History_SearchMessage                   搜尋寄件者/主旨
History_NoMessages                      沒有任何訊息
History_ShowMagnet                      使用規則
History_ShowNoMagnet                    未使用規則
History_Magnet                          &nbsp;(只顯示使用規則分類的信件)
History_NoMagnet                        &nbsp;(只顯示未使用規則分類的信件)
History_ResetSearch                     重設

Password_Title                          密碼
Password_Enter                          輸入密碼
Password_Go                             進入
Password_Error1                         密碼錯誤

Security_Error1                         POP3 SPA/AUTH 服器連接埠必須介於 1 到 65535 之間
Security_Stealth                        單機/主機模式設定
Security_NoStealthMode                  否 (單機模式)
Security_ExplainStats                   (開啟這項功能, 會使 POPFile 每天傳送三項特定的資料到 www.usethesource.com: 包含 bc (所有分類的個數), mc (所有 POPFile 分類過的信件數) and ec (所有的分類錯誤次數).  POPFile 網站會利用這些資料來統計並分析使用者如何來應用 POPFile. POPFile 網站會將這些資料保留五天, 五天後會自動將這些資料從資料庫中移除; POPFile 網站沒有保留任何你的IP位址在這些傳輸的資料中.)
Security_ExplainUpdate                  (開啟這項功能, 會使 POPFile 每天傳送三項特定的資料到 www.usethesource.com: 包含 ma (你安裝的 POPFile 的主要版本), mi (你安裝的 POPFile 的次要版本) and bn (你安裝的 POPFile 的建立代碼).  如果 POPFile 的新版存在, 會在 POPFile 控制中心首頁顯示更新資訊. POPFile 網站會將這些資料保留五天, 五天後會自動將這些資料從資料庫中移除; POPFile 網站沒有保留任何你的IP位址在這些傳輸的資料中.)
Security_PasswordTitle                  使用者介面密碼設定
Security_Password                       密碼
Security_PasswordUpdate                 更改密碼為 %s
Security_AUTHTitle                      遠端伺服器
Security_SecureServer                   POP3 SPA/AUTH 伺服器
Security_SecureServerUpdate             更新 POP3 SPA/AUTH 伺服器為 %s; 需重新啟動 POPFile
Security_SecurePort                     POP3 SPA/AUTH 伺服器連接埠
Security_SecurePortUpdate               更新 POP3 SPA/AUTH 伺服器連接埠為 %s; 需重新啟動 POPFile
Security_SMTPServer                     SMTP 伺服器
Security_SMTPServerUpdate               更新 SMTP 伺服器為 %s; 需重新啟動 POPFile
Security_SMTPPort                       SMTP 伺服器連接埠
Security_SMTPPortUpdate                 更新 SMTP 伺服器連接埠為 %s; 需重新啟動
Security_POP3                           允許遠端開啟 POP3 連線; 需重新啟動 POPFile
Security_SMTP                           允許遠端開啟 SMTP 連線; 需重新啟動 POPFile
Security_NNTP                           允許遠端開啟 NNTP 連線; 需重新啟動 POPFile
Security_UI                             允許遠端開啟 HTTP 連線到使用者介面; 需重新啟動 POPFile
Security_XMLRPC                         允許遠端開啟 XML-RPC 連線; 需重新啟動 POPFile
Security_UpdateTitle                    自動更新檢查
Security_Update                         每天檢查 POPFile 是否有更新版本
Security_StatsTitle                     報告統計資料
Security_Stats                          每天傳送統計資料

Magnet_Error1                           規則 '%s' 已經存在分類 '%s' 中
Magnet_Error2                           新規則 '%s' 與規則 '%s' 在分類 '%s' 中重複，可能會導致誤判. 新規則未加入.
Magnet_Error3                           建立新規則 '%s' 在分類 '%s' 中
Magnet_CurrentMagnets                   現有規則
Magnet_Message1                         以下的規則會使的信件總是歸類到特定的分類中.
Magnet_CreateNew                        建立新規則
Magnet_Explanation                      現有規則類別:</b> <ul><li><b>寄件者的電子郵件信箱或姓名:</b> 例如: john@company.com 對應到一個特定的電子郵件信箱, <br />company.com 對應到每一個來自於 company.com 的寄件者, <br />John Doe 對應到一個特定的姓名, John 對應到每一個名字中有 John 的人</li><li><b>收件者/副本的電子郵件信箱或姓名:</b> 如同寄件者的規則類別一樣，只是這項規則類別是針對收件者/副本</li> <li><b>信件主旨中的特定單字</b> 例如: hello 會對應到所有信件主旨中有 hello 的信件</li></ul>
Magnet_MagnetType                       規則類別
Magnet_Value                            值
Magnet_Always                           總是歸類到分類
Magnet_Jump                             移至規則(頁)

Bucket_Error1                           分類只可包含小寫的英文 a 到 z 以及 - 與 _
Bucket_Error2                           分類 %s 已經存在
Bucket_Error3                           已經建立分類 %s
Bucket_Error4                           請輸入未含空白的字元
Bucket_Error5                           重新命名分類 %s 為 %s
Bucket_Error6                           已經刪除分類 %s
Bucket_Title                            總結
Bucket_BucketName                       分類名稱
Bucket_WordCount                        全部單字字數
Bucket_WordCounts                       出現字數統計
Bucket_UniqueWords                      非重複單字字數
Bucket_SubjectModification              信件主旨修改
Bucket_ChangeColor                      更改顏色
Bucket_NotEnoughData                    沒有足夠資料
Bucket_ClassificationAccuracy           分類準確率
Bucket_EmailsClassified                 已分類的信件數
Bucket_EmailsClassifiedUpper            信件分類結果
Bucket_ClassificationErrors             分類錯誤次數
Bucket_Accuracy                         準確率
Bucket_ClassificationCount              信件分類統計
Bucket_ClassificationFP                 錯誤分類
Bucket_ClassificationFN                 無法分類
Bucket_ResetStatistics                  重設統計記錄
Bucket_LastReset                        上次重設時間為
Bucket_CurrentColor                     %s 現在顏色是 %s
Bucket_SetColorTo                       更改顏色 %s 為 %s
Bucket_Maintenance                      維護
Bucket_CreateBucket                     建立分類
Bucket_DeleteBucket                     刪除分類
Bucket_RenameBucket                     重新命名分類
Bucket_Lookup                           查看
Bucket_LookupMessage                    查看分類中的單字
Bucket_LookupMessage2                   查看結果
Bucket_LookupMostLikely                 <b>%s</b> 最常出現在分類 <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> 沒有出現在任何分類中
Bucket_DisabledGlobally                 全部停止
Bucket_To                               為
Bucket_Quarantine                       隔離

SingleBucket_Title                      詳細資料 %s
SingleBucket_WordCount                  分類字數統計
SingleBucket_TotalWordCount             全部字數統計
SingleBucket_Percentage                 佔百分比
SingleBucket_WordTable                  字表 %s
SingleBucket_Message1                   標示 (*) 的單字代表已被使用在 POPFile 這一次 Session 的分類中. 按任何一個單字去查看他在每一個分類中出線的機率.
SingleBucket_Unique                     %s 非重複
SingleBucket_ClearBucket                移除所有單字

Session_Title                           POPFile Session 已經過期
Session_Error                           你的 POPFile session 已經過期.  This could have been caused by starting and stopping POPFile but leaving your web browser open.  Please click one of the links above to continue using POPFile.

View_Title                              單一訊息檢視

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