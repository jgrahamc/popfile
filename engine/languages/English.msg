# This is used to get the appropriate subdirectory for the manual
LanguageCode                            en

# Common words that are used on their own all over the interface
Apply                                   Apply
On                                      On
Off                                     Off
TurnOn                                  Turn On
TurnOff                                 Turn Off
Add                                     Add
Remove                                  Remove
Previous                                Previous
Next                                    Next
From                                    From
Subject                                 Subject
Classification                          Classification
Reclassify                              Reclassify
Undo                                    Undo
Close                                   Close
Find                                    Find
Filter                                  Filter
Yes                                     Yes
No                                      No
ChangeToYes                             Change to Yes
ChangeToNo                              Change to No
Bucket                                  Bucket
Magnet                                  Magnet
Delete                                  Delete
Create                                  Create
To                                      To
Total                                   Total
Rename                                  Rename
Frequency                               Frequency
Probability                             Probability
Score                                   Score
Lookup                                  Lookup

# The header and footer that appear on every UI page
Header_Title                            POPFile Control Center
Header_Shutdown                         Shutdown
Header_History                          History
Header_Buckets                          Buckets
Header_Configuration                    Configuration
Header_Advanced                         Advanced
Header_Security                         Security
Header_Magnets                          Magnets

Footer_HomePage                         POPFile Home Page
Footer_Manual                           Manual
Footer_Forums                           Forums
Footer_FeedMe                           Feed Me!
Footer_RequestFeature                   Request Feature
Footer_MailingList                      Mailing List

Configuration_Error1                    The separator character must be a single character
Configuration_Error2                    The user interface port must be a number between 1 and 65535
Configuration_Error3                    The POP3 listen port must be a number between 1 and 65535
Configuration_Error4                    The page size must be a number between 1 and 1000
Configuration_Error5                    The number of days in the history must be a number between 1 and 366
Configuration_Error6                    The TCP timeout must be a number between 10 and 300
Configuration_POP3Port                  POP3 listen port
Configuration_POP3Update                Updated port to %s; this change will not take affect until you restart POPFile
Configuration_Separator                 Separator character
Configuration_SepUpdate                 Updated separator to %s
Configuration_UI                        User interface web port
Configuration_UIUpdate                  Updated user interface web port to %s; this change will not take affect until you restart POPFile
Configuration_History                   Number of emails per page
Configuration_HistoryUpdate             Updated number of emails per page to %s
Configuration_Days  `                   Number of days of history to keep
Configuration_DaysUpdate                Updated number of days of history to %s
Configuration_UserInterface             User Interface
Configuration_Skins                     Skins
Configuration_SkinsChoose               Choose skin
Configuration_Language                  Language
Configuration_LanguageChoose            Choose language
Configuration_ListenPorts               Listen Ports
Configuration_HistoryView               History View
Configuration_TCPTimeout                TCP Connection Timeout
Configuration_TCPTimeoutSecs            TCP connection timeout in seconds
Configuration_TCPTimeoutUpdate          Updated TCP connection timeout to %s
Configuration_ClassificationInsertion   Classification Insertion
Configuration_SubjectLine               Subject line modification
Configuration_XTCInsertion              X-Text-Classification insertion
Configuration_XPLInsertion              X-POPFile-Link insertion
Configuration_Logging                   Logging
Configuration_None                      None
Configuration_ToScreen                  To Screen
Configuration_ToFile                    To File
Configuration_ToScreenFile              To Screen and File
Configuration_LoggerOutput              Logger output

Advanced_Error1                         '%s' already in the stop word list
Advanced_Error2                         Stop words can only contains alphanumeric, ., _, -, or @ characters
Advanced_Error3                         '%s' added to the stop word list
Advanced_Error4                         '%s' is not in the stop word list
Advanced_Error5                         '%s' removed from the stop word list
Advanced_StopWords                      Stop Words
Advanced_Message1                       The following words are ignored from all classifications as they occur very frequently.
Advanced_AddWord                        Add word
Advanced_RemoveWord                     Remove word

History_Filter                          &nbsp;(just showing bucket <font color=%s>%s</font>)
History_Search                          &nbsp;(searched for subject %s)
History_Title                           Recent Messages
History_Jump                            Jump to message
History_ShowAll                         Show All
History_ShouldBe                        Should be
History_NoFrom                          no from line
History_NoSubject                       no subject line
History_ClassifyAs                      Classify as
History_MagnetUsed                      Magnet used
History_ChangedTo                       Changed to <font color=%s>%s
History_Already                         Already reclassified as <font color=%s>%s</font>
History_RemoveAll                       Remove All
History_RemovePage                      Remove Page
History_Remove                          To remove entries in the history click
History_SearchMessage                   Search Subject
History_NoMessages                      No messages
History_ShowMagnet                      Magnetized
History_Magnet                          &nbsp;(just showing magnet classified messages)

Password_Title                          Password
Password_Enter                          Enter password
Password_Go                             Go!
Password_Error1                         Incorrect password

Security_Error1                         The secure port must be a number between 1 and 65535
Security_Stealth                        Stealth Mode/Server Operation
Security_NoStealthMode                  No (Stealth Mode)
Security_ExplainStats                   (With this turned on POPFile sends once per day the following three values to a script on www.usethesource.com: bc (the total number of buckets that you have), mc (the total number of messages that POPFile has classified) and ec (the total number of classification errors).  These get stored in a file and I will use this to publish some statistics about how people use POPFile and how well it works.  My web server keeps its log files for about 5 days and then they get deleted; I am not storing any connection between the statistics and individual IP addresses.)
Security_ExplainUpdate                  (With this turned on POPFile sends once per day the following three values to a script on www.usethesource.com: ma (the major version number of your installed POPFile), mi (the minor version number of your installed POPFile) and bn (the build number of your installed POPFile).  POPFile receives a response in the form of a graphic that appears at the top of the page if a new version is available.  My web server keeps its log files for about 5 days and then they get deleted; I am not storing any connection between the update checks and individual IP addresses.)
Security_PasswordTitle                  User Interface Password
Security_Password                       Password
Security_PasswordUpdate                 Updated password to %s
Security_AUTHTitle                      Secure Password Authentication/AUTH
Security_SecureServer                   Secure server
Security_SecureServerUpdate             Updated secure server to %s; this change will not take affect until you restart POPFile
Security_SecurePort                     Secure port
Security_SecurePortUpdate               Updated port to %s; this change will not take affect until you restart POPFile
Security_POP3                           Accept POP3 connections from remote machines
Security_UI                             Accept HTTP (User Interface) connections from remote machines
Security_UpdateTitle                    Automatic Update Checking
Security_Update                         Check daily for updates to POPFile
Security_StatsTitle                     Reporting Statistics
Security_Stats                          Send statistics back to John daily

Magnet_Error1                           Magnet '%s' already exists in bucket '%s'
Magnet_Error2                           New magnet '%s' clashes with magnet '%s' in bucket '%s' and could cause ambiguous results.  New magnet was not added.
Magnet_Error3                           Create new magnet '%s' in bucket '%s'
Magnet_CurrentMagnets                   Current Magnets
Magnet_Message1                         The following magnets cause mail to always be classified into the specified bucket.
Magnet_CreateNew                        Create New Magnet
Magnet_Explanation                      Three types of magnets are available: <ul><li>From address or name:</b> For example: john@company.com to match a specific address, <br>company.com to match everyone who sends from company.com, <br>John Doe to match a specific person, John to match all Johns<li><b>To address or name:</b> Like a From: magnet but for the To: address in an email<li><b>Subject words:</b> For example: hello to match all messages with hello in the subject</ul>
Magnet_MagnetType                       Magnet type
Magnet_Value                            Value
Magnet_Always                           Always goes to bucket

Bucket_Error1                           Bucket names can only contain the letters a to z in lower case plus - and _
Bucket_Error2                           Bucket named %s already exists
Bucket_Error3                           Created bucket named %s
Bucket_Error4                           Please enter a non-blank word
Bucket_Error5                           Renamed bucket %s to %s
Bucket_Error6                           Deleted bucket %s
Bucket_Title                            Summary
Bucket_BucketName                       Bucket Name
Bucket_WordCount                        Word Count
Bucket_WordCounts                       Word Counts
Bucket_UniqueWords                      Unique Words
Bucket_SubjectModification              Subject Modification
Bucket_ChangeColor                      Change Color
Bucket_NotEnoughData                    Not enough data
Bucket_ClassificationAccuracy           Classification Accuracy
Bucket_EmailsClassified                 Emails classified
Bucket_EmailsClassifiedUpper            Emails Classified
Bucket_ClassificationErrors             Classification errors
Bucket_Accuracy                         Accuracy
Bucket_ClassificationCount              Classification Count
Bucket_ResetStatistics                  Reset Statistics
Bucket_LastReset                        Last Reset
Bucket_CurrentColor                     %s current color is %s
Bucket_SetColorTo                       Set %s color to %s
Bucket_Maintenance                      Maintenance
Bucket_CreateBucket                     Create bucket with name
Bucket_DeleteBucket                     Delete bucket named
Bucket_RenameBucket                     Rename bucket named
Bucket_Lookup                           Lookup
Bucket_LookupMessage                    Lookup word in buckets
Bucket_LookupMessage2                   Lookup result for
Bucket_LookupMostLikely                 <b>%s</b> is most likely to appear in <font color=%s>%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> does not appear in any of the buckets
Bucket_DisabledGlobally                 Disabled globally
Bucket_To                               to

SingleBucket_Title                      Detail for %s
SingleBucket_WordCount                  Bucket word count
SingleBucket_TotalWordCount             Total word count
SingleBucket_Percentage                 Percentage of total
SingleBucket_WordTable                  Word Table for %s
SingleBucket_Message1                   Starred (*) words have been used for classification in this POPFile session.  Click any word to lookup its probability for all buckets.
SingleBucket_Unique                     %s unique
