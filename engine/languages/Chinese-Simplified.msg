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
# POPFile 0.18.1 Simplified Chinese Translation, Created By Mark Wu, 2003/03/04
# POPFile 0.19.0 Simplified Chinese Translation, Modified By Mark Wu, 2003/06/02

# Identify the language and character set used for the interface
LanguageCode                            cn
LanguageCharset                         GB2312

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en

# Common words that are used on their own all over the interface
Apply                                   套用
On                                      开
Off                                     关
TurnOn                                  开启
TurnOff                                 关闭
Add                                     加入
Remove                                  移除
Previous                                上一页
Next                                    下一页
From                                    寄件者
Subject                                 主旨
Cc                                      副本 
Classification                          分类
Reclassify                              重新分类
Probability                             机率
Scores                                  分数
QuickMagnets                            快速规则精灵
Undo                                    复原
Close                                   关闭
Find                                    搜寻
Filter                                  过滤
Yes                                     是
No                                      否
ChangeToYes                             是
ChangeToNo                              否
Bucket                                  分类
Magnet                                  规则
Delete                                  删除
Create                                  建立
To                                      收件者
Total                                   全部
Rename                                  重新命名
Frequency                               频率
Probability                             机率
Score                                   分数
Lookup                                  查看
Word                                    单字
Count                                   计数
Update                                  更新
Refresh                                 重新整理

# The header and footer that appear on every UI page
Header_Title                            POPFile 控制台
Header_Shutdown                         停止 POPFile
Header_History                          历史
Header_Buckets                          分类
Header_Configuration                    设定
Header_Advanced                         进阶
Header_Security                         安全
Header_Magnets                          规则

Footer_HomePage                         POPFile 首页
Footer_Manual                           使用手册
Footer_Forums                           论坛
Footer_FeedMe                           赞助
Footer_RequestFeature                   功能建议
Footer_MailingList                      邮件群组

Configuration_Error1                    分隔字元必须为单一字元
Configuration_Error2                    使用者介面连接埠必须介于 1 到 65535 之间
Configuration_Error3                    POP3 伺服器连接埠必须介于 1 到 65535 之间
Configuration_Error4                    每一页显示信件数必须介于 1 到 1000 之间
Configuration_Error5                    历史纪录天数必须介于 1 到 366 之间
Configuration_Error6                    连接逾时秒数介于 10 到 300 之间
Configuration_Error7                    XML-RPC 接收埠必须介于 1 到 65535 之间
Configuration_POP3Port                  POP3 伺服器连接埠
Configuration_POP3Update                更新 POP3 伺服器连接埠为 %s; 需重新启动 POPFile
Configuration_XMLRPCUpdate              更新 XML-RPC 连接埠为 %s; 需重新启动 POPFile
Configuration_XMLRPCPort                XML-RPC 连接埠
Configuration_SMTPPort                  SMTP 伺服器连接埠
Configuration_SMTPUpdate                更新 SMTP 伺服器连接埠为 %s; 需重新启动 POPFile
Configuration_NNTPPort                  NNTP 伺服器连接埠
Configuration_NNTPUpdate                更新 NNTP 伺服器连接埠为 %s; 需重新启动 POPFile
Configuration_POP3Separator             SMTP 伺服器 host:port:user 分隔字元
Configuration_NNTPSeparator             NNTP 伺服器 host:port:user 分隔字元
Configuration_POP3SepUpdate             更新 POP3 伺服器分隔字元为 %s
Configuration_NNTPSepUpdate             更新 NNTP 伺服器分隔字元为 %s
Configuration_UI                        使用者介面连接埠
Configuration_UIUpdate                  更改使用者介面连接埠为 %s; 需重新启动 POPFile
Configuration_History                   每一页显示信件数
Configuration_HistoryUpdate             更改每一页显示信件数为 to %s
Configuration_Days                      历史纪录天数
Configuration_DaysUpdate                更改历史纪录天数为 %s
Configuration_UserInterface             使用者介面
Configuration_Skins                     面版
Configuration_SkinsChoose               选择面版
Configuration_Language                  语言
Configuration_LanguageChoose            选择语言
Configuration_ListenPorts               模组选项
Configuration_HistoryView               历史检视
Configuration_TCPTimeout                连接逾时
Configuration_TCPTimeoutSecs            连接逾时秒数
Configuration_TCPTimeoutUpdate          更新连接逾时秒数为 %s 秒
Configuration_ClassificationInsertion   E-Mail 内容修改
Configuration_SubjectLine               信件主旨修改
Configuration_XTCInsertion              加入 X-Text-Classification 到信件标题中
Configuration_XPLInsertion              加入 X-POPFile-Link 到信件标题中
Configuration_Logging                   纪录
Configuration_None                      无
Configuration_ToScreen                  输出到萤幕
Configuration_ToFile                    输出到档案
Configuration_ToScreenFile              输出到萤幕与档案
Configuration_LoggerOutput              记录输出方式
Configuration_GeneralSkins              面版
Configuration_SmallSkins                面版(小字形)
Configuration_TinySkins                 面版(迷你字形)
Configuration_CurrentLogFile            &lt;现在运作中的纪录档&gt;

Advanced_Error1                         '%s' 已经存在忽略单字字表中
Advanced_Error2                         忽略单字只可包含英文,数字, ., _, -, 或 @ 等字元
Advanced_Error3                         '%s' 已经加入忽略单字字表中
Advanced_Error4                         '%s' 不存在忽略单字字表中
Advanced_Error5                         '%s' 已经从忽略单字字表中移除
Advanced_StopWords                      忽略单字字表
Advanced_Message1                       POPFile 会忽略以下出现频率较高的单字:
Advanced_AddWord                        加入单字
Advanced_RemoveWord                     移除单字

History_Filter                          &nbsp;(显示分类 <font color="%s">%s</font>)
History_FilterBy                        过滤条件
History_Search                          &nbsp;(搜寻寄件者/主旨 %s)
History_Title                           最近信件
History_Jump                            移至信件
History_ShowAll                         全部显示
History_ShouldBe                        应该是
History_NoFrom                          没有寄件者
History_NoSubject                       没有主旨
History_ClassifyAs                      分类为
History_MagnetUsed                      使用规则
History_MagnetBecause                   <b>使用规则</b><p>分类为 <font color="%s">%s</font> 因为规则 %s </p>
History_ChangedTo                       改变为 <font color="%s">%s
History_Already                         已经重新分类为 <font color="%s">%s</font>
History_RemoveAll                       全部移除
History_RemovePage                      移除这一页
History_Remove                          移除历史信件
History_SearchMessage                   搜寻寄件者/主旨
History_NoMessages                      没有任何讯息
History_ShowMagnet                      使用规则
History_ShowNoMagnet                    未使用规则
History_Magnet                          &nbsp;(只显示使用规则分类的信件)
History_NoMagnet                        &nbsp;(只显示未使用规则分类的信件)
History_ResetSearch                     重设

Password_Title                          密码
Password_Enter                          输入密码
Password_Go                             进入
Password_Error1                         密码错误

Security_Error1                         POP3 SPA/AUTH 服器连接埠必须介于 1 到 65535 之间
Security_Stealth                        单机/主机模式设定
Security_NoStealthMode                  否 (单机模式)
Security_ExplainStats                   (开启这项功能, 会使 POPFile 每天传送三项特定的资料到 www.usethesource.com: 包含 bc (所有分类的个数), mc (所有 POPFile 分类过的信件数) and ec (所有的分类错误次数).  POPFile 网站会利用这些资料来统计并分析使用者如何来应用 POPFile. POPFile 网站会将这些资料保留五天, 五天后会自动将这些资料从资料库中移除; POPFile 网站没有保留任何你的IP位址在这些传输的资料中.)
Security_ExplainUpdate                  (开启这项功能, 会使 POPFile 每天传送三项特定的资料到 www.usethesource.com: 包含 ma (你安装的 POPFile 的主要版本), mi (你安装的 POPFile 的次要版本) and bn (你安装的 POPFile 的建立代码).  如果 POPFile 的新版存在, 会在 POPFile 控制中心首页显示更新资讯. POPFile 网站会将这些资料保留五天, 五天后会自动将这些资料从资料库中移除; POPFile 网站没有保留任何你的IP位址在这些传输的资料中.)
Security_PasswordTitle                  使用者介面密码设定
Security_Password                       密码
Security_PasswordUpdate                 更改密码为 %s
Security_AUTHTitle                      远端伺服器
Security_SecureServer                   POP3 SPA/AUTH 伺服器
Security_SecureServerUpdate             更新 POP3 SPA/AUTH 伺服器为 %s; 需重新启动 POPFile
Security_SecurePort                     POP3 SPA/AUTH 伺服器连接埠
Security_SecurePortUpdate               更新 POP3 SPA/AUTH 伺服器连接埠为 %s; 需重新启动 POPFile
Security_SMTPServer                     SMTP 伺服器
Security_SMTPServerUpdate               更新 SMTP 伺服器为 %s; 需重新启动 POPFile
Security_SMTPPort                       SMTP 伺服器连接埠
Security_SMTPPortUpdate                 更新 SMTP 伺服器连接埠为 %s; 需重新启动
Security_POP3                           允许远端开启 POP3 连线; 需重新启动 POPFile
Security_SMTP                           允许远端开启 SMTP 连线; 需重新启动 POPFile
Security_NNTP                           允许远端开启 NNTP 连线; 需重新启动 POPFile
Security_UI                             允许远端开启 HTTP 连线到使用者介面; 需重新启动 POPFile
Security_XMLRPC                         允许远端开启 XML-RPC 连线; 需重新启动 POPFile
Security_UpdateTitle                    自动更新检查
Security_Update                         每天检查 POPFile 是否有更新版本
Security_StatsTitle                     报告统计资料
Security_Stats                          每天传送统计资料

Magnet_Error1                           规则 '%s' 已经存在分类 '%s' 中
Magnet_Error2                           新规则 '%s' 与规则 '%s' 在分类 '%s' 中重复，可能会导致误判. 新规则未加入.
Magnet_Error3                           建立新规则 '%s' 在分类 '%s' 中
Magnet_CurrentMagnets                   现有规则
Magnet_Message1                         以下的规则会使的信件总是归类到特定的分类中.
Magnet_CreateNew                        建立新规则
Magnet_Explanation                      现有规则类别:</b> <ul><li><b>寄件者的电子邮件信箱或姓名:</b> 例如: john@company.com 对应到一个特定的电子邮件信箱, <br />company.com 对应到每一个来自于 company.com 的寄件者, <br />John Doe 对应到一个特定的姓名, John 对应到每一个名字中有 John 的人</li><li><b>收件者/副本的电子邮件信箱或姓名:</b> 如同寄件者的规则类别一样，只是这项规则类别是针对收件者/副本</li> <li><b>信件主旨中的特定单字</b> 例如: hello 会对应到所有信件主旨中有 hello 的信件</li></ul>
Magnet_MagnetType                       规则类别
Magnet_Value                            值
Magnet_Always                           总是归类到分类
Magnet_Jump                             移至规则(页)

Bucket_Error1                           分类只可包含小写的英文 a 到 z 以及 - 与 _
Bucket_Error2                           分类 %s 已经存在
Bucket_Error3                           已经建立分类 %s
Bucket_Error4                           请输入未含空白的字元
Bucket_Error5                           重新命名分类 %s 为 %s
Bucket_Error6                           已经删除分类 %s
Bucket_Title                            总结
Bucket_BucketName                       分类名称
Bucket_WordCount                        全部单字字数
Bucket_WordCounts                       出现字数统计
Bucket_UniqueWords                      非重复单字字数
Bucket_SubjectModification              信件主旨修改
Bucket_ChangeColor                      更改颜色
Bucket_NotEnoughData                    没有足够资料
Bucket_ClassificationAccuracy           分类准确率
Bucket_EmailsClassified                 已分类的信件数
Bucket_EmailsClassifiedUpper            信件分类结果
Bucket_ClassificationErrors             分类错误次数
Bucket_Accuracy                         准确率
Bucket_ClassificationCount              信件分类统计
Bucket_ClassificationFP                 错误分类
Bucket_ClassificationFN                 无法分类
Bucket_ResetStatistics                  重设统计记录
Bucket_LastReset                        上次重设时间为
Bucket_CurrentColor                     %s 现在颜色是 %s
Bucket_SetColorTo                       更改颜色 %s 为 %s
Bucket_Maintenance                      维护
Bucket_CreateBucket                     建立分类
Bucket_DeleteBucket                     删除分类
Bucket_RenameBucket                     重新命名分类
Bucket_Lookup                           查看
Bucket_LookupMessage                    查看分类中的单字
Bucket_LookupMessage2                   查看结果
Bucket_LookupMostLikely                 <b>%s</b> 最常出现在分类 <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> 没有出现在任何分类中
Bucket_DisabledGlobally                 全部停止
Bucket_To                               为
Bucket_Quarantine                       隔离

SingleBucket_Title                      详细资料 %s
SingleBucket_WordCount                  分类字数统计
SingleBucket_TotalWordCount             全部字数统计
SingleBucket_Percentage                 占百分比
SingleBucket_WordTable                  字表 %s
SingleBucket_Message1                   标示 (*) 的单字代表已被使用在 POPFile 这一次 Session 的分类中. 按任何一个单字去查看他在每一个分类中出线的机率.
SingleBucket_Unique                     %s 非重复
SingleBucket_ClearBucket                移除所有单字

Session_Title                           POPFile Session 已经过期
Session_Error                           你的 POPFile session 已经过期.  This could have been caused by starting and stopping POPFile but leaving your web browser open.  Please click one of the links above to continue using POPFile.

View_Title                              单一讯息检视

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