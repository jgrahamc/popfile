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
#   POPFile 0.22.0 Simplified Chinese Translation
#   Created By Jedi Lin, 2004/09/19
#   In fact translated from Traditional Chinese by Encode::HanConvert
#   Modified By Jedi Lin, 2004/09/23

# Identify the language and character set used for the interface
LanguageCode                            cn
LanguageCharset                         UTF8
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          zh-cn

# This is where to find the FAQ on the Wiki
FAQLink                                 FrequentlyAskedQuestions

# Common words that are used on their own all over the interface
Apply                                   套用
On                                      开
Off                                     关
TurnOn                                  打开
TurnOff                                 关上
Add                                     加入
Remove                                  移除
Previous                                前一页
Next                                    下一页
From                                    寄件者
Subject                                 主旨
Cc                                      副本
Classification                          邮筒
Reclassify                              重新分类
Probability                             可能性
Scores                                  分数
QuickMagnets                            快速吸铁
Undo                                    还原
Close                                   关闭
Find                                    寻找
Filter                                  过滤器
Yes                                     是
No                                      否
ChangeToYes                             改成是
ChangeToNo                              改成否
Bucket                                  邮筒
Magnet                                  吸铁
Delete                                  删除
Create                                  建立
To                                      收件人
Total                                   全部
Rename                                  更名
Frequency                               频率
Probability                             可能性
Score                                   分数
Lookup                                  查找
Word                                    字词
Count                                   计数
Update                                  更新
Refresh                                 重新整理
FAQ                                     常见问答集
ID                                      ID
Date                                    日期
Arrived                                 收件时间
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
Header_History                          历史
Header_Buckets                          邮筒
Header_Configuration                    组态
Header_Advanced                         进阶
Header_Security                         安全
Header_Magnets                          吸铁

Footer_HomePage                         POPFile 首页
Footer_Manual                           手册
Footer_Forums                           讨论区
Footer_FeedMe                           捐助
Footer_RequestFeature                   功能请求
Footer_MailingList                      邮递论题
Footer_Wiki                             文件集

Configuration_Error1                    分隔符祇能是单一的字符
Configuration_Error2                    使用者接口的连接埠一定要介于 1 和 65535 之间
Configuration_Error3                    POP3 聆听连接埠一定要介于 1 和 65535 之间
Configuration_Error4                    页面大小一定要介于 1 和 1000 之间
Configuration_Error5                    历史里要保留的日数一定要介于 1 和 366 之间
Configuration_Error6                    TCP 逾时值一定要介于 10 和 300 之间
Configuration_Error7                    XML RPC 聆听连接埠一定要介于 1 和 65535 之间
Configuration_Error8                    SOCKS V 代理服务器连接埠一定要介于 1 和 65535 之间
Configuration_POP3Port                  POP3 聆听连接埠
Configuration_POP3Update                POP3 连接埠已更新为 %s; 这项更动在你重新激活 POPFile 前都不会生效
Configuration_XMLRPCUpdate              XML-RPC 连接埠已更新为 %s; 这项更动在你重新激活 POPFile 前都不会生效
Configuration_XMLRPCPort                XML-RPC 聆听连接埠
Configuration_SMTPPort                  SMTP 聆听连接埠
Configuration_SMTPUpdate                SMTP 连接埠已更新为 %s; 这项更动在你重新激活 POPFile 前都不会生效
Configuration_NNTPPort                  NNTP 聆听连接埠
Configuration_NNTPUpdate                NNTP 连接埠已更新为 %s; 这项更动在你重新激活 POPFile 前都不会生效
Configuration_POPFork                   允许重复的 POP3 联机
Configuration_SMTPFork                  允许重复的 SMTP 联机
Configuration_NNTPFork                  允许重复的 NNTP 联机
Configuration_POP3Separator             POP3 主机:连接埠:使用者 分隔符
Configuration_NNTPSeparator             NNTP 主机:连接埠:使用者 分隔符
Configuration_POP3SepUpdate             POP3 的分隔符已更新为 %s
Configuration_NNTPSepUpdate             NNTP 的分隔符已更新为 %s
Configuration_UI                        使用者接口网页连接埠
Configuration_UIUpdate                  使用者接口网页连接埠已更新为 %s; 这项更动在你重新激活 POPFile 前都不会生效
Configuration_History                   每一页所要列出的邮件讯息数量
Configuration_HistoryUpdate             每一页所要列出的邮件讯息数量已更新为 %s
Configuration_Days                      历史里所要保留的天数
Configuration_DaysUpdate                历史里所要保留的天数已更新为 %s
Configuration_UserInterface             使用者接口
Configuration_Skins                     外观样式
Configuration_SkinsChoose               选择外观样式
Configuration_Language                  语言
Configuration_LanguageChoose            选择语言
Configuration_ListenPorts               模块选项
Configuration_HistoryView               历史检视
Configuration_TCPTimeout                联机逾时
Configuration_TCPTimeoutSecs            联机逾时秒数
Configuration_TCPTimeoutUpdate          联机逾时秒数已更新为 %s
Configuration_ClassificationInsertion   插入邮件讯息文字
Configuration_SubjectLine               变更主旨列
Configuration_XTCInsertion              在标头插入<br>X-Text-Classification
Configuration_XPLInsertion              在标头插入<br>X-POPFile-Link
Configuration_Logging                   日志
Configuration_None                      无
Configuration_ToScreen                  输出至屏幕
Configuration_ToFile                    输出至档案
Configuration_ToScreenFile              输出至屏幕及档案
Configuration_LoggerOutput              日志输出方式
Configuration_GeneralSkins              外观样式
Configuration_SmallSkins                小型外观样式
Configuration_TinySkins                 微型外观样式
Configuration_CurrentLogFile            &lt;下载目前的日志档&gt;
Configuration_SOCKSServer               SOCKS V 代理服务器主机
Configuration_SOCKSPort                 SOCKS V 代理服务器连接埠
Configuration_SOCKSPortUpdate           SOCKS V 代理服务器连接埠已更新为 %s
Configuration_SOCKSServerUpdate         SOCKS V 代理服务器主机已更新为 %s
Configuration_Fields                    历史字段

Advanced_Error1                         '%s' 已经在忽略字词清单里了
Advanced_Error2                         要被忽略的字词仅能包含字母数字, ., _, -, 或 @ 字符
Advanced_Error3                         '%s' 已被加入忽略字词清单里了
Advanced_Error4                         '%s' 并不在忽略字词清单里
Advanced_Error5                         '%s' 已从忽略字词清单里被移除了
Advanced_StopWords                      被忽略的字词
Advanced_Message1                       POPFile 会忽略下列这些常用的字词:
Advanced_AddWord                        加入字词
Advanced_RemoveWord                     移除字词
Advanced_AllParameters                  所有的 POPFile 参数
Advanced_Parameter                      参数
Advanced_Value                          值
Advanced_Warning                        这是完整的 POPFile 参数清单.  祇适合进阶使用者: 你可以变更任何参数值并按下 更新; 不过没有任何机制会检查这些参数值的有效性.  以粗体显示的项目表示已经从预设值被加以变更了.
Advanced_ConfigFile                     组态档:

History_Filter                          &nbsp;(祇显示 <font color="%s">%s</font> 邮筒)
History_FilterBy                        过滤条件
History_Search                          &nbsp;(按寄件者/主旨来搜寻 %s)
History_Title                           最近的邮件讯息
History_Jump                            跳到这一页
History_ShowAll                         全部显示
History_ShouldBe                        应该要是
History_NoFrom                          没有寄件者列
History_NoSubject                       没有主旨列
History_ClassifyAs                      分类成
History_MagnetUsed                      使用了吸铁
History_MagnetBecause                   <b>使用了吸铁</b><p>被分类成 <font color="%s">%s</font> 的原因是 %s 吸铁</p>
History_ChangedTo                       已变更为 <font color="%s">%s</font>
History_Already                         重新分类成 <font color="%s">%s</font>
History_RemoveAll                       全部移除
History_RemovePage                      移除本页
History_RemoveChecked                   移除被核选的
History_Remove                          按此移除历史里的项目
History_SearchMessage                   搜寻寄件者/主旨
History_NoMessages                      没有邮件讯息
History_ShowMagnet                      用了吸铁
History_Negate_Search                   负向搜寻/过滤
History_Magnet                          &nbsp;(祇显示由吸铁所分类的邮件讯息)
History_NoMagnet                        &nbsp;(祇显示不是由吸铁所分类的邮件讯息)
History_ResetSearch                     重设
History_ChangedClass                    现在被分类为
History_Purge                           马上删除
History_Increase                        增加
History_Decrease                        减少
History_Column_Characters               变更寄件者, 收件者, 副本和主旨字段的宽度
History_Automatic                       自动化
History_Reclassified                    已重新分类
History_Size_Bytes                      %d&nbsp;B
History_Size_KiloBytes                  %.1f&nbsp;KB
History_Size_MegaBytes                  %.1f&nbsp;MB

Password_Title                          口令
Password_Enter                          输入口令
Password_Go                             冲!
Password_Error1                         不正确的口令

Security_Error1                         连接埠一定要介于 1 和 65535 之间
Security_Stealth                        鬼鬼祟祟模式/服务器作业
Security_NoStealthMode                  否 (鬼鬼祟祟模式)
Security_StealthMode                    (鬼鬼祟祟模式)
Security_ExplainStats                   (这个选项开启后, POPFile 每天都会传送一次下列三个数值到 www.usethesource.com 的一个脚本: bc (你的邮筒数量), mc (被 POPFile 分类过的邮件讯息总数) 和 ec (分类错误的总数).  这些数值会被储存到一个档案里, 然后会被我用来发布一些关于人们使用 POPFile 的情况跟其成效的统计数据.  我的网页服务器会保留其本身的日志档约 5 天, 然后就会加以删除; 我不会储存任何统计与单独 IP 地址间的关联性起来.)
Security_ExplainUpdate                  (这个选项开启后, POPFile 每天都会传送一次下列三个数值到 www.usethesource.com 的一个脚本: ma (你的 POPFile 的主要版本编号), mi (你的 POPFile 的次要版本编号) 和 bn (你的 POPFile 的建号).  新版推出时, POPFile 会收到一份图形响应, 并且显示在画面顶端.  我的网页服务器会保留其本身的日志档约 5 天, 然后就会加以删除; 我不会储存任何更新检查与单独 IP 地址间的关联性起来.)
Security_PasswordTitle                  使用者接口口令
Security_Password                       口令
Security_PasswordUpdate                 口令已更新
Security_AUTHTitle                      远程服务器
Security_SecureServer                   远程 POP3 服务器 (SPA/AUTH 或穿透式代理服务器)
Security_SecureServerUpdate             远程 POP3 服务器已更新为 %s
Security_SecurePort                     远程 POP3 连接埠 (SPA/AUTH 或穿透式代理服务器)
Security_SecurePortUpdate               远程 POP3 连接埠已更新为 %s
Security_SMTPServer                     SMTP 连锁服务器
Security_SMTPServerUpdate               SMTP 连锁服务器已更新为 %s; 这项更动在你重新激活 POPFile 前都不会生效
Security_SMTPPort                       SMTP 连锁连接埠
Security_SMTPPortUpdate                 SMTP 连锁连接埠已更新为 %s; 这项更动在你重新激活 POPFile 前都不会生效
Security_POP3                           接受来自远程机器的 POP3 联机 (需要重新激活 POPFile)
Security_SMTP                           接受来自远程机器的 SMTP 联机 (需要重新激活 POPFile)
Security_NNTP                           接受来自远程机器的 NNTP 联机 (需要重新激活 POPFile)
Security_UI                             接受来自远程机器的 HTTP (使用者接口) 联机 (需要重新激活 POPFile)
Security_XMLRPC                         接受来自远程机器的 XML-RPC 联机 (需要重新激活 POPFile)
Security_UpdateTitle                    自动更新检查
Security_Update                         每天检查 POPFile 是否有更新
Security_StatsTitle                     回报统计数据
Security_Stats                          每日送出统计数据

Magnet_Error1                           '%s' 吸铁已经存在于 '%s' 邮筒里了
Magnet_Error2                           新的 '%s' 吸铁跟既有的 '%s' 吸铁起了冲突, 可能会引起 '%s' 邮筒内的歧异结果.  新的吸铁不会被加进去.
Magnet_Error3                           建立新的吸铁 '%s' 于 '%s' 邮筒中
Magnet_CurrentMagnets                   现用的吸铁
Magnet_Message1                         下列的吸铁会让信件总是被分类到特定的邮筒里.
Magnet_CreateNew                        建立新的吸铁
Magnet_Explanation                      有这些类别的吸铁可以用:</b> <ul><li><b>寄件者地址或名字:</b> 举例来说: john@company.com 就祇会吻合特定的地址, <br />company.com 会吻合到任何从 company.com 寄出来的人, <br />John Doe 会吻合特定的人, John 会吻合所有的 Johns</li><li><b>收件者/副本地址或名称:</b> 就跟寄件者一样: 但是吸铁祇会针对邮件讯息里的 To:/Cc: 地址生效</li> <li><b>主旨字词:</b> 例如: hello 会吻合所有主旨里有 hello 的邮件讯息</li></ul>
Magnet_MagnetType                       吸铁类别
Magnet_Value                            值
Magnet_Always                           总是分到邮筒
Magnet_Jump                             跳到吸铁页面

Bucket_Error1                           邮筒名称祇能含有小写 a 到 z 的字母, 0 到 9 的数字, 加上 - 和 _
Bucket_Error2                           已经有名为 %s 的邮筒了
Bucket_Error3                           已经建立了名为 %s 的邮筒
Bucket_Error4                           请输入非空白的字词
Bucket_Error5                           已经把 %s 邮筒改名为 %s 了
Bucket_Error6                           已经删除了 %s 邮筒了
Bucket_Title                            邮筒组态
Bucket_BucketName                       邮筒名称
Bucket_WordCount                        字词计数
Bucket_WordCounts                       字词数目统计
Bucket_UniqueWords                      独特的<br>字词数
Bucket_SubjectModification              修改主旨标头
Bucket_ChangeColor                      邮筒颜色
Bucket_NotEnoughData                    数据不足
Bucket_ClassificationAccuracy           分类准确度
Bucket_EmailsClassified                 已分类的邮件讯息数量
Bucket_EmailsClassifiedUpper            邮件讯息分类结果
Bucket_ClassificationErrors             分类错误
Bucket_Accuracy                         准确度
Bucket_ClassificationCount              分类计数
Bucket_ClassificationFP                 伪阳性分类
Bucket_ClassificationFN                 伪阴性分类
Bucket_ResetStatistics                  重设统计数据
Bucket_LastReset                        前次重设于
Bucket_CurrentColor                     %s 现用的颜色为 %s
Bucket_SetColorTo                       设定 %s 的颜色为 %s
Bucket_Maintenance                      维护
Bucket_CreateBucket                     用这个名字建立邮筒
Bucket_DeleteBucket                     删掉此名称的邮筒
Bucket_RenameBucket                     更改此名称的邮筒
Bucket_Lookup                           查找
Bucket_LookupMessage                    在邮筒里查找字词
Bucket_LookupMessage2                   查找此字词的结果
Bucket_LookupMostLikely                 <b>%s</b> 最像是在 <font color="%s">%s</font> 会出现的单词
Bucket_DoesNotAppear                    <p><b>%s</b> 并未出现于任何邮筒里
Bucket_DisabledGlobally                 已全域停用的
Bucket_To                               至
Bucket_Quarantine                       隔离邮筒

SingleBucket_Title                      %s 的详细数据
SingleBucket_WordCount                  邮筒字词计数
SingleBucket_TotalWordCount             全部的字词计数
SingleBucket_Percentage                 占全部的百分比
SingleBucket_WordTable                  %s 的字词表
SingleBucket_Message1                   按下索引里的字母来看看所有以该字母开头的字词.  按下任何字词就可以查找它在所有邮筒里的可能性.
SingleBucket_Unique                     %s 独有的
SingleBucket_ClearBucket                移除所有的字词

Session_Title                           POPFile 阶段时期已逾时
Session_Error                           你的 POPFile 阶段时期已经逾期了.  这可能是因为你激活并停止了 POPFile 但却保持网页浏览器开启所致.  请按下列的链接之一来继续使用 POPFile.

View_Title                              单一邮件讯息检视
View_ShowFrequencies                    显示字词频率
View_ShowProbabilities                  显示字词可能性
View_ShowScores                         显示字词得分及判定图表
View_WordMatrix                         字词矩阵
View_WordProbabilities                  正在显示字词可能性
View_WordFrequencies                    正在显示字词频率
View_WordScores                         正在显示字词得分
View_Chart                              判定图表

Windows_TrayIcon                        是否要在 Windows 的系统常驻列显示 POPFile 图标?
Windows_Console                         是否要在命令列窗口里执行 POPFile?
Windows_NextTime                        <p><font color="red">这项更动在你重新激活 POPFile 前都不会生效</font>

Header_MenuSummary                      这个表格是份导览选单, 能让你存取控制中心里不同的每一个页面.
History_MainTableSummary                这份表格列出了最近收到的邮件讯息的寄件者及主旨, 你也能在此重新加以检视并重新分类这些邮件讯息.  按一下主旨列就会显示出完整的邮件讯息文字, 以及她们为何会被如此分类的信息.  你可以在 '应该要是' 字段指定邮件讯息该归属的邮筒, 或者还原这项变更.  如果有特定的邮件讯息再也不需要了, 你也可以用 '删除' 字段来从历史里加以删除.
History_OpenMessageSummary              这个表格含有某个邮件讯息的全文, 其中被高亮度标示的字词是被用来分类的, 依据的是她们跟那个邮筒最有关联.
Bucket_MainTableSummary                 这个表格提供了分类邮筒的概况.  每一列都会显示出邮筒名称, 该邮筒里的字词总数, 每个邮筒里实际的单独字词数量, 邮件讯息的主旨列是否会在被分类到该邮筒时一并被修改, 是否要隔离被收进该邮筒里的邮件讯息, 以及一个让你挑选颜色的表格, 这个颜色会在控制中心里显示于任何跟该邮筒有关的地方.
Bucket_StatisticsTableSummary           这个表格提供了三组跟 POPFile 整体效能有关的统计数据.  第一组是其分类准确度如何, 第二组是共有多少邮件讯息被加以分类到那个邮筒里, 第三组是每个邮筒里有多少字词及其关联百分比.
Bucket_MaintenanceTableSummary          这个表格含有一个表单, 让你能够建立, 删除, 或重新命名某个邮筒, 也可以在所有的邮筒里查找某个字词, 看看其关联可能性.
Bucket_AccuracyChartSummary             这个表格用图形显示了邮件讯息分类的准确度.
Bucket_BarChartSummary                  这个表格用图形显示了不同邮筒所占据的百分比.  这同时计算了被分类的邮件讯息数量, 以及全部的字词计数.
Bucket_LookupResultsSummary             这个表格显示了与尸体里任何给定字词关联的可能性.  对于每个邮筒来说, 她都会显示出该字词发生的频率, 字词会出现在该邮筒里的可能性, 以及当该字词出现在邮件讯息里时, 对于该邮筒得分的整体影响.
Bucket_WordListTableSummary             这个表格提供了特定邮筒里全部的字词清单, 按照开头的字母逐列整理.
Magnet_MainTableSummary                 这个表格显示了吸铁清单, 这些吸铁是用来按照固定规则把邮件讯息加以分类的.  每一列都会显示出吸铁如何被定义著, 其所觊觎的邮筒, 还有用来删除该吸铁的按钮.
Configuration_MainTableSummary          这个表格含有数个表单, 让你控制 POPFile 的组态.
Configuration_InsertionTableSummary     这个表格含有一些按钮, 判断是否要在邮件讯息递送给邮件用户端程序前, 先行修改标头或主旨列.
Security_MainTableSummary               这个表格提供了几组控制, 能影响 POPFile 整体组态的安全, 是否要自动检查程序更新, 以及是否要把 POPFile 效能统计数据的一般信息传回程序作者的中央数据库.
Advanced_MainTableSummary               这个表格提供了一份 POPFile 分类邮件讯息时所会忽略的字词清单, 因为他们在一般邮件讯息里的关联过于频繁.  她们会被按照字词开头的字亩被逐列整理.

Imap_Bucket2Folder                      <b>%s</b> 邮筒的信件至邮件匣
Imap_MapError                           你不能把超过一个的邮筒对应到单一的邮件匣里!
Imap_Server                             IMAP 服务器主机名称:
Imap_ServerNameError                    请输入服务器的主机名称!
Imap_Port                               IMAP 服务器连接埠:
Imap_PortError                          请输入有效的连接埠号码!
Imap_Login                              IMAP 帐号登入:
Imap_LoginError                         请输入使用者/登入名称!
Imap_Password                           IMAP 帐号的口令:
Imap_PasswordError                      请输入要用于服务器的口令!
Imap_Expunge                            从被监视的信件匣里清除已被删除的邮件讯息.
Imap_Interval                           更新间隔秒数:
Imap_IntervalError                      请输入介于 10 秒至 3600 秒间的间隔.
Imap_Bytelimit                          每封邮件讯息要用来分类的字节数. 输入 0 (空) 表示完整的邮件讯息:
Imap_BytelimitError                     请输入数值.
Imap_RefreshFolders                     重新整理邮件匣清单
Imap_Now                                现在!
Imap_UpdateError1                       无法登入. 请验证你的登入名称跟口令.
Imap_UpdateError2                       连接至服务器失败. 请检查主机名称跟连接埠, 并请确认你正在线上.
Imap_UpdateError3                       请先组态联机细节.
Imap_NoConnectionMessage                请先组态联机细节. 当你完成后, 这一页里就会出现更多可用的选项.
Imap_WatchMore                          被监视邮件匣清单的邮件匣
Imap_WatchedFolder                      被监视的邮件匣编号

Shutdown_Message                        POPFile 已经被停掉了

Help_Training                           当你初次使用 POPFile 时, 她啥也不懂而需要被加以调教. POPFile 的每一个邮筒都需要用邮件讯息来加以调教, 祇有当你重新把某个被 POPFile 错误分类的邮件讯息重新分类到正确的邮筒时, 才真的是在调教她. 同时你也得设定你的邮件用户端程序, 来按照 POPFile 的分类结果加以过滤邮件讯息. 关于设定用户端过滤器的信息可以在 <a href="http://popfile.sourceforge.net/cgi-bin/wiki.pl?FrequentlyAskedQuestions/EmailSorting">POPFile 文件计画</a>里被找到.
Help_Bucket_Setup                       POPFile 除了未分类 (unclassified) 的假邮筒外, 还需要至少两个邮筒. 而 POPFile 的独特之处正在于她对电子邮件的区分更胜于此, 你甚至可以有任意数量的邮筒. 简单的设定会是像 "垃圾 (spam)", "个人 (personal)", 和 "工作 (work)" 邮筒.
Help_No_More                            别再显示这个说明了
