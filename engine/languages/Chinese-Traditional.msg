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
#   POPFile 0.22.0 Traditional Chinese Translation
#   Created By Jedi Lin, 2004/09/19
#   Modified By Jedi Lin, 2004/09/23

# Identify the language and character set used for the interface
LanguageCode                            tw
LanguageCharset                         UTF8
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          zh-tw

# This is where to find the FAQ on the Wiki
FAQLink                                 FrequentlyAskedQuestions

# Common words that are used on their own all over the interface
Apply                                   套用
On                                      開
Off                                     關
TurnOn                                  打開
TurnOff                                 關上
Add                                     加入
Remove                                  移除
Previous                                前一頁
Next                                    下一頁
From                                    寄件者
Subject                                 主旨
Cc                                      副本
Classification                          郵筒
Reclassify                              重新分類
Probability                             可能性
Scores                                  分數
QuickMagnets                            快速吸鐵
Undo                                    還原
Close                                   關閉
Find                                    尋找
Filter                                  過濾器
Yes                                     是
No                                      否
ChangeToYes                             改成是
ChangeToNo                              改成否
Bucket                                  郵筒
Magnet                                  吸鐵
Delete                                  刪除
Create                                  建立
To                                      收件人
Total                                   全部
Rename                                  更名
Frequency                               頻率
Probability                             可能性
Score                                   分數
Lookup                                  查找
Word                                    字詞
Count                                   計數
Update                                  更新
Refresh                                 重新整理
FAQ                                     常見問答集
ID                                      ID
Date                                    日期
Arrived                                 收件時間
Size                                    大小

# This is a regular expression pattern that is used to convert
# a number into a friendly looking number (for the US and UK this
# means comma separated at the thousands)

Locale_Thousands                       ,
Locale_Decimal                         .

# The Locale_Date uses the format strings in Perl's Date::Format
# module to set the date format for the UI.  There are two possible
# ways to specify it.
#
# <format>            Just one simple format used for all dates
# <<format> | <format> The first format is used for dates less than
#                     7 days from now, the second for all other dates

Locale_Date                            %a %m/%d %TT%z | %A %Y/%m/%d %TT%z

# The header and footer that appear on every UI page
Header_Title                            POPFile 控制中心
Header_Shutdown                         停掉 POPFile
Header_History                          歷史
Header_Buckets                          郵筒
Header_Configuration                    組態
Header_Advanced                         進階
Header_Security                         安全
Header_Magnets                          吸鐵

Footer_HomePage                         POPFile 首頁
Footer_Manual                           手冊
Footer_Forums                           討論區
Footer_FeedMe                           捐助
Footer_RequestFeature                   功能請求
Footer_MailingList                      郵遞論題
Footer_Wiki                             文件集

Configuration_Error1                    分隔符祇能是單一的字符
Configuration_Error2                    使用者介面的連接埠一定要介於 1 和 65535 之間
Configuration_Error3                    POP3 聆聽連接埠一定要介於 1 和 65535 之間
Configuration_Error4                    頁面大小一定要介於 1 和 1000 之間
Configuration_Error5                    歷史裏要保留的日數一定要介於 1 和 366 之間
Configuration_Error6                    TCP 逾時值一定要介於 10 和 300 之間
Configuration_Error7                    XML RPC 聆聽連接埠一定要介於 1 和 65535 之間
Configuration_Error8                    SOCKS V 代理伺服器連接埠一定要介於 1 和 65535 之間
Configuration_POP3Port                  POP3 聆聽連接埠
Configuration_POP3Update                POP3 連接埠已更新為 %s; 這項更動在妳重新啟動 POPFile 前都不會生效
Configuration_XMLRPCUpdate              XML-RPC 連接埠已更新為 %s; 這項更動在妳重新啟動 POPFile 前都不會生效
Configuration_XMLRPCPort                XML-RPC 聆聽連接埠
Configuration_SMTPPort                  SMTP 聆聽連接埠
Configuration_SMTPUpdate                SMTP 連接埠已更新為 %s; 這項更動在妳重新啟動 POPFile 前都不會生效
Configuration_NNTPPort                  NNTP 聆聽連接埠
Configuration_NNTPUpdate                NNTP 連接埠已更新為 %s; 這項更動在妳重新啟動 POPFile 前都不會生效
Configuration_POPFork                   允許重複的 POP3 連線
Configuration_SMTPFork                  允許重複的 SMTP 連線
Configuration_NNTPFork                  允許重複的 NNTP 連線
Configuration_POP3Separator             POP3 主機:連接埠:使用者 分隔符
Configuration_NNTPSeparator             NNTP 主機:連接埠:使用者 分隔符
Configuration_POP3SepUpdate             POP3 的分隔符已更新為 %s
Configuration_NNTPSepUpdate             NNTP 的分隔符已更新為 %s
Configuration_UI                        使用者介面網頁連接埠
Configuration_UIUpdate                  使用者介面網頁連接埠已更新為 %s; 這項更動在妳重新啟動 POPFile 前都不會生效
Configuration_History                   每一頁所要列出的郵件訊息數量
Configuration_HistoryUpdate             每一頁所要列出的郵件訊息數量已更新為 %s
Configuration_Days                      歷史裏所要保留的天數
Configuration_DaysUpdate                歷史裏所要保留的天數已更新為 %s
Configuration_UserInterface             使用者介面
Configuration_Skins                     外觀樣式
Configuration_SkinsChoose               選擇外觀樣式
Configuration_Language                  語言
Configuration_LanguageChoose            選擇語言
Configuration_ListenPorts               模組選項
Configuration_HistoryView               歷史檢視
Configuration_TCPTimeout                連線逾時
Configuration_TCPTimeoutSecs            連線逾時秒數
Configuration_TCPTimeoutUpdate          連線逾時秒數已更新為 %s
Configuration_ClassificationInsertion   插入郵件訊息文字
Configuration_SubjectLine               變更主旨列
Configuration_XTCInsertion              在標頭插入<br>X-Text-Classification
Configuration_XPLInsertion              在標頭插入<br>X-POPFile-Link
Configuration_Logging                   日誌
Configuration_None                      無
Configuration_ToScreen                  輸出至螢幕
Configuration_ToFile                    輸出至檔案
Configuration_ToScreenFile              輸出至螢幕及檔案
Configuration_LoggerOutput              日誌輸出方式
Configuration_GeneralSkins              外觀樣式
Configuration_SmallSkins                小型外觀樣式
Configuration_TinySkins                 微型外觀樣式
Configuration_CurrentLogFile            &lt;下載目前的日誌檔&gt;
Configuration_SOCKSServer               SOCKS V 代理伺服器主機
Configuration_SOCKSPort                 SOCKS V 代理伺服器連接埠
Configuration_SOCKSPortUpdate           SOCKS V 代理伺服器連接埠已更新為 %s
Configuration_SOCKSServerUpdate         SOCKS V 代理伺服器主機已更新為 %s
Configuration_Fields                    歷史欄位

Advanced_Error1                         '%s' 已經在忽略字詞清單裏了
Advanced_Error2                         要被忽略的字詞僅能包含字母數字, ., _, -, 或 @ 字符
Advanced_Error3                         '%s' 已被加入忽略字詞清單裏了
Advanced_Error4                         '%s' 並不在忽略字詞清單裏
Advanced_Error5                         '%s' 已從忽略字詞清單裏被移除了
Advanced_StopWords                      被忽略的字詞
Advanced_Message1                       POPFile 會忽略下列這些常用的字詞:
Advanced_AddWord                        加入字詞
Advanced_RemoveWord                     移除字詞
Advanced_AllParameters                  所有的 POPFile 參數
Advanced_Parameter                      參數
Advanced_Value                          值
Advanced_Warning                        這是完整的 POPFile 參數清單.  祇適合進階使用者: 妳可以變更任何參數值並按下 更新; 不過沒有任何機制會檢查這些參數值的有效性.  以粗體顯示的項目表示已經從預設值被加以變更了.
Advanced_ConfigFile                     組態檔:

History_Filter                          &nbsp;(祇顯示 <font color="%s">%s</font> 郵筒)
History_FilterBy                        過濾條件
History_Search                          &nbsp;(按寄件者/主旨來搜尋 %s)
History_Title                           最近的郵件訊息
History_Jump                            跳到這一頁
History_ShowAll                         全部顯示
History_ShouldBe                        應該要是
History_NoFrom                          沒有寄件者列
History_NoSubject                       沒有主旨列
History_ClassifyAs                      分類成
History_MagnetUsed                      使用了吸鐵
History_MagnetBecause                   <b>使用了吸鐵</b><p>被分類成 <font color="%s">%s</font> 的原因是 %s 吸鐵</p>
History_ChangedTo                       已變更為 <font color="%s">%s</font>
History_Already                         重新分類成 <font color="%s">%s</font>
History_RemoveAll                       全部移除
History_RemovePage                      移除本頁
History_RemoveChecked                   移除被核選的
History_Remove                          按此移除歷史裏的項目
History_SearchMessage                   搜尋寄件者/主旨
History_NoMessages                      沒有郵件訊息
History_ShowMagnet                      用了吸鐵
History_Negate_Search                   負向搜尋/過濾
History_Magnet                          &nbsp;(祇顯示由吸鐵所分類的郵件訊息)
History_NoMagnet                        &nbsp;(祇顯示不是由吸鐵所分類的郵件訊息)
History_ResetSearch                     重設
History_ChangedClass                    現在被分類為
History_Purge                           馬上刪除
History_Increase                        增加
History_Decrease                        減少
History_Column_Characters               變更寄件者, 收件者, 副本和主旨欄位的寬度
History_Automatic                       自動化
History_Reclassified                    已重新分類
History_Size_Bytes                      %d&nbsp;B
History_Size_KiloBytes                  %.1f&nbsp;KB
History_Size_MegaBytes                  %.1f&nbsp;MB

Password_Title                          密碼
Password_Enter                          輸入密碼
Password_Go                             衝!
Password_Error1                         不正確的密碼

Security_Error1                         連接埠一定要介於 1 和 65535 之間
Security_Stealth                        鬼鬼祟祟模式/伺服器作業
Security_NoStealthMode                  否 (鬼鬼祟祟模式)
Security_StealthMode                    (鬼鬼祟祟模式)
Security_ExplainStats                   (這個選項開啟後, POPFile 每天都會傳送一次下列三個數值到 www.usethesource.com 的一個腳本: bc (妳的郵筒數量), mc (被 POPFile 分類過的郵件訊息總數) 和 ec (分類錯誤的總數).  這些數值會被儲存到一個檔案裏, 然後會被我用來發佈一些關於人們使用 POPFile 的情況跟其成效的統計資料.  我的網頁伺服器會保留其本身的日誌檔約 5 天, 然後就會加以刪除; 我不會儲存任何統計與單獨 IP 地址間的關聯性起來.)
Security_ExplainUpdate                  (這個選項開啟後, POPFile 每天都會傳送一次下列三個數值到 www.usethesource.com 的一個腳本: ma (妳的 POPFile 的主要版本編號), mi (妳的 POPFile 的次要版本編號) 和 bn (妳的 POPFile 的建號).  新版推出時, POPFile 會收到一份圖形回應, 並且顯示在畫面頂端.  我的網頁伺服器會保留其本身的日誌檔約 5 天, 然後就會加以刪除; 我不會儲存任何更新檢查與單獨 IP 地址間的關聯性起來.)
Security_PasswordTitle                  使用者介面密碼
Security_Password                       密碼
Security_PasswordUpdate                 密碼已更新
Security_AUTHTitle                      遠端伺服器
Security_SecureServer                   遠端 POP3 伺服器 (SPA/AUTH 或穿透式代理伺服器)
Security_SecureServerUpdate             遠端 POP3 伺服器已更新為 %s
Security_SecurePort                     遠端 POP3 連接埠 (SPA/AUTH 或穿透式代理伺服器)
Security_SecurePortUpdate               遠端 POP3 連接埠已更新為 %s
Security_SMTPServer                     SMTP 連鎖伺服器
Security_SMTPServerUpdate               SMTP 連鎖伺服器已更新為 %s; 這項更動在妳重新啟動 POPFile 前都不會生效
Security_SMTPPort                       SMTP 連鎖連接埠
Security_SMTPPortUpdate                 SMTP 連鎖連接埠已更新為 %s; 這項更動在妳重新啟動 POPFile 前都不會生效
Security_POP3                           接受來自遠端機器的 POP3 連線 (需要重新啟動 POPFile)
Security_SMTP                           接受來自遠端機器的 SMTP 連線 (需要重新啟動 POPFile)
Security_NNTP                           接受來自遠端機器的 NNTP 連線 (需要重新啟動 POPFile)
Security_UI                             接受來自遠端機器的 HTTP (使用者介面) 連線 (需要重新啟動 POPFile)
Security_XMLRPC                         接受來自遠端機器的 XML-RPC 連線 (需要重新啟動 POPFile)
Security_UpdateTitle                    自動更新檢查
Security_Update                         每天檢查 POPFile 是否有更新
Security_StatsTitle                     回報統計資料
Security_Stats                          每日送出統計資料

Magnet_Error1                           '%s' 吸鐵已經存在於 '%s' 郵筒裏了
Magnet_Error2                           新的 '%s' 吸鐵跟既有的 '%s' 吸鐵起了衝突, 可能會引起 '%s' 郵筒內的歧異結果.  新的吸鐵不會被加進去.
Magnet_Error3                           建立新的吸鐵 '%s' 於 '%s' 郵筒中
Magnet_CurrentMagnets                   現用的吸鐵
Magnet_Message1                         下列的吸鐵會讓信件總是被分類到特定的郵筒裏.
Magnet_CreateNew                        建立新的吸鐵
Magnet_Explanation                      有這些類別的吸鐵可以用:</b> <ul><li><b>寄件者地址或名字:</b> 舉例來說: john@company.com 就祇會吻合特定的地址, <br />company.com 會吻合到任何從 company.com 寄出來的人, <br />John Doe 會吻合特定的人, John 會吻合所有的 Johns</li><li><b>收件者/副本地址或名稱:</b> 就跟寄件者一樣: 但是吸鐵祇會針對郵件訊息裏的 To:/Cc: 地址生效</li> <li><b>主旨字詞:</b> 例如: hello 會吻合所有主旨裏有 hello 的郵件訊息</li></ul>
Magnet_MagnetType                       吸鐵類別
Magnet_Value                            值
Magnet_Always                           總是分到郵筒
Magnet_Jump                             跳到吸鐵頁面

Bucket_Error1                           郵筒名稱祇能含有小寫 a 到 z 的字母, 0 到 9 的數字, 加上 - 和 _
Bucket_Error2                           已經有名為 %s 的郵筒了
Bucket_Error3                           已經建立了名為 %s 的郵筒
Bucket_Error4                           請輸入非空白的字詞
Bucket_Error5                           已經把 %s 郵筒改名為 %s 了
Bucket_Error6                           已經刪除了 %s 郵筒了
Bucket_Title                            郵筒組態
Bucket_BucketName                       郵筒名稱
Bucket_WordCount                        字詞計數
Bucket_WordCounts                       字詞數目統計
Bucket_UniqueWords                      獨特的<br>字詞數
Bucket_SubjectModification              修改主旨標頭
Bucket_ChangeColor                      郵筒顏色
Bucket_NotEnoughData                    資料不足
Bucket_ClassificationAccuracy           分類準確度
Bucket_EmailsClassified                 已分類的郵件訊息數量
Bucket_EmailsClassifiedUpper            郵件訊息分類結果
Bucket_ClassificationErrors             分類錯誤
Bucket_Accuracy                         準確度
Bucket_ClassificationCount              分類計數
Bucket_ClassificationFP                 偽陽性分類
Bucket_ClassificationFN                 偽陰性分類
Bucket_ResetStatistics                  重設統計資料
Bucket_LastReset                        前次重設於
Bucket_CurrentColor                     %s 現用的顏色為 %s
Bucket_SetColorTo                       設定 %s 的顏色為 %s
Bucket_Maintenance                      維護
Bucket_CreateBucket                     用這個名字建立郵筒
Bucket_DeleteBucket                     刪掉此名稱的郵筒
Bucket_RenameBucket                     更改此名稱的郵筒
Bucket_Lookup                           查找
Bucket_LookupMessage                    在郵筒裏查找字詞
Bucket_LookupMessage2                   查找此字詞的結果
Bucket_LookupMostLikely                 <b>%s</b> 最像是在 <font color="%s">%s</font> 會出現的單詞
Bucket_DoesNotAppear                    <p><b>%s</b> 並未出現於任何郵筒裏
Bucket_DisabledGlobally                 已全域停用的
Bucket_To                               至
Bucket_Quarantine                       隔離郵筒

SingleBucket_Title                      %s 的詳細資料
SingleBucket_WordCount                  郵筒字詞計數
SingleBucket_TotalWordCount             全部的字詞計數
SingleBucket_Percentage                 佔全部的百分比
SingleBucket_WordTable                  %s 的字詞表
SingleBucket_Message1                   按下索引裏的字母來看看所有以該字母開頭的字詞.  按下任何字詞就可以查找它在所有郵筒裏的可能性.
SingleBucket_Unique                     %s 獨有的
SingleBucket_ClearBucket                移除所有的字詞

Session_Title                           POPFile 階段時期已逾時
Session_Error                           妳的 POPFile 階段時期已經逾期了.  這可能是因為妳啟動並停止了 POPFile 但卻保持網頁瀏覽器開啟所致.  請按下列的鏈結之一來繼續使用 POPFile.

View_Title                              單一郵件訊息檢視
View_ShowFrequencies                    顯示字詞頻率
View_ShowProbabilities                  顯示字詞可能性
View_ShowScores                         顯示字詞得分及判定圖表
View_WordMatrix                         字詞矩陣
View_WordProbabilities                  正在顯示字詞可能性
View_WordFrequencies                    正在顯示字詞頻率
View_WordScores                         正在顯示字詞得分
View_Chart                              判定圖表

Windows_TrayIcon                        是否要在 Windows 的系統常駐列顯示 POPFile 圖示?
Windows_Console                         是否要在命令列視窗裏執行 POPFile?
Windows_NextTime                        <p><font color="red">這項更動在妳重新啟動 POPFile 前都不會生效</font>

Header_MenuSummary                      這個表格是份導覽選單, 能讓妳存取控制中心裏不同的每一個頁面.
History_MainTableSummary                這份表格列出了最近收到的郵件訊息的寄件者及主旨, 妳也能在此重新加以檢視並重新分類這些郵件訊息.  按一下主旨列就會顯示出完整的郵件訊息文字, 以及她們為何會被如此分類的資訊.  妳可以在 '應該要是' 欄位指定郵件訊息該歸屬的郵筒, 或者還原這項變更.  如果有特定的郵件訊息再也不需要了, 妳也可以用 '刪除' 欄位來從歷史裏加以刪除.
History_OpenMessageSummary              這個表格含有某個郵件訊息的全文, 其中被高亮度標示的字詞是被用來分類的, 依據的是她們跟那個郵筒最有關聯.
Bucket_MainTableSummary                 這個表格提供了分類郵筒的概況.  每一列都會顯示出郵筒名稱, 該郵筒裏的字詞總數, 每個郵筒裏實際的單獨字詞數量, 郵件訊息的主旨列是否會在被分類到該郵筒時一併被修改, 是否要隔離被收進該郵筒裏的郵件訊息, 以及一個讓妳挑選顏色的表格, 這個顏色會在控制中心裏顯示於任何跟該郵筒有關的地方.
Bucket_StatisticsTableSummary           這個表格提供了三組跟 POPFile 整體效能有關的統計資料.  第一組是其分類準確度如何, 第二組是共有多少郵件訊息被加以分類到那個郵筒裏, 第三組是每個郵筒裏有多少字詞及其關聯百分比.
Bucket_MaintenanceTableSummary          這個表格含有一個表單, 讓妳能夠建立, 刪除, 或重新命名某個郵筒, 也可以在所有的郵筒裏查找某個字詞, 看看其關聯可能性.
Bucket_AccuracyChartSummary             這個表格用圖形顯示了郵件訊息分類的準確度.
Bucket_BarChartSummary                  這個表格用圖形顯示了不同郵筒所佔據的百分比.  這同時計算了被分類的郵件訊息數量, 以及全部的字詞計數.
Bucket_LookupResultsSummary             這個表格顯示了與屍體裏任何給定字詞關聯的可能性.  對於每個郵筒來說, 她都會顯示出該字詞發生的頻率, 字詞會出現在該郵筒裏的可能性, 以及當該字詞出現在郵件訊息裏時, 對於該郵筒得分的整體影響.
Bucket_WordListTableSummary             這個表格提供了特定郵筒裏全部的字詞清單, 按照開頭的字母逐列整理.
Magnet_MainTableSummary                 這個表格顯示了吸鐵清單, 這些吸鐵是用來按照固定規則把郵件訊息加以分類的.  每一列都會顯示出吸鐵如何被定義著, 其所覬覦的郵筒, 還有用來刪除該吸鐵的按鈕.
Configuration_MainTableSummary          這個表格含有數個表單, 讓妳控制 POPFile 的組態.
Configuration_InsertionTableSummary     這個表格含有一些按鈕, 判斷是否要在郵件訊息遞送給郵件用戶端程式前, 先行修改標頭或主旨列.
Security_MainTableSummary               這個表格提供了幾組控制, 能影響 POPFile 整體組態的安全, 是否要自動檢查程式更新, 以及是否要把 POPFile 效能統計資料的一般資訊傳回程式作者的中央資料庫.
Advanced_MainTableSummary               這個表格提供了一份 POPFile 分類郵件訊息時所會忽略的字詞清單, 因為他們在一般郵件訊息裏的關聯過於頻繁.  她們會被按照字詞開頭的字畝被逐列整理.

Imap_Bucket2Folder                      <b>%s</b> 郵筒的信件至郵件匣
Imap_MapError                           妳不能把超過一個的郵筒對應到單一的郵件匣裏!
Imap_Server                             IMAP 伺服器主機名稱:
Imap_ServerNameError                    請輸入伺服器的主機名稱!
Imap_Port                               IMAP 伺服器連接埠:
Imap_PortError                          請輸入有效的連接埠號碼!
Imap_Login                              IMAP 帳號登入:
Imap_LoginError                         請輸入使用者/登入名稱!
Imap_Password                           IMAP 帳號的密碼:
Imap_PasswordError                      請輸入要用於伺服器的密碼!
Imap_Expunge                            從被監視的信件匣裏清除已被刪除的郵件訊息.
Imap_Interval                           更新間隔秒數:
Imap_IntervalError                      請輸入介於 10 秒至 3600 秒間的間隔.
Imap_Bytelimit                          每封郵件訊息要用來分類的位元組數. 輸入 0 (空) 表示完整的郵件訊息:
Imap_BytelimitError                     請輸入數值.
Imap_RefreshFolders                     重新整理郵件匣清單
Imap_Now                                現在!
Imap_UpdateError1                       無法登入. 請驗證妳的登入名稱跟密碼.
Imap_UpdateError2                       連接至伺服器失敗. 請檢查主機名稱跟連接埠, 並請確認妳正在線上.
Imap_UpdateError3                       請先組態連線細節.
Imap_NoConnectionMessage                請先組態連線細節. 當妳完成後, 這一頁裏就會出現更多可用的選項.
Imap_WatchMore                          被監視郵件匣清單的郵件匣
Imap_WatchedFolder                      被監視的郵件匣編號

Shutdown_Message                        POPFile 已經被停掉了

Help_Training                           當妳初次使用 POPFile 時, 她啥也不懂而需要被加以調教. POPFile 的每一個郵筒都需要用郵件訊息來加以調教, 祇有當妳重新把某個被 POPFile 錯誤分類的郵件訊息重新分類到正確的郵筒時, 纔真的是在調教她. 同時妳也得設定妳的郵件用戶端程式, 來按照 POPFile 的分類結果加以過濾郵件訊息. 關於設定用戶端過濾器的資訊可以在 <a href="http://popfile.sourceforge.net/cgi-bin/wiki.pl?FrequentlyAskedQuestions/EmailSorting">POPFile 文件計畫</a>裏被找到.
Help_Bucket_Setup                       POPFile 除了未分類 (unclassified) 的假郵筒外, 還需要至少兩個郵筒. 而 POPFile 的獨特之處正在於她對電子郵件的區分更勝於此, 妳甚至可以有任意數量的郵筒. 簡單的設定會是像 "垃圾 (spam)", "個人 (personal)", 和 "工作 (work)" 郵筒.
Help_No_More                            別再顯示這個說明了
