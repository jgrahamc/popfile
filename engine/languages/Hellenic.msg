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
LanguageCode                            gr
LanguageCharset                         ISO-8859-7
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en

# Common words that are used on their own all over the interface
Apply                                   Εφαρμογή
On                                      Ενεργό
Off                                     Ανενεργό
TurnOn                                  Ενεργοποίηση
TurnOff                                 Απενεργοποίηση
Add                                     Προσθήκη
Remove                                  Απαλοιφή
Previous                                Προηγούμενο
Next                                    Επόμενο
From                                    Αποστολέας
Subject                                 Θέμα
Cc                                      Κοιν. 
Classification                          Ταξινόμηση
Reclassify                              Επαναταξινόμηση
Probability                             Πιθανότητα
Scores                                  Βαθμόλογίες
QuickMagnets                            Γρήγοροι Μαγνήτες
Undo                                    Undo
Close                                   Κλείσιμο
Find                                    Εύρεση
Filter                                  Φίλτρο
Yes                                     Ναί
No                                      Οχι
ChangeToYes                             Αλλαγή σε Ναί
ChangeToNo                              Αλλαγή σε Όχι
Bucket                                  Αρχείο
Magnet                                  Μαγνήτης
Delete                                  Διαγραφή
Create                                  Δημιουργία
To                                      Πρός
Total                                   Σύνολο
Rename                                  Μετονομασία
Frequency                               Συχνότητα
Probability                             Πιθανότητα
Score                                   Βαθμός
Lookup                                  Εύρευση
Word                                    Λέξη
Count                             Εμφανίσεις
Update                                  Ενημέρωση
Refresh                                 Φρεσκάρισμα

# The header and footer that appear on every UI page
Header_Title                            Κεντρο Ελέγχου POPFile
Header_Shutdown                         Κλείσιμο POPFile
Header_History                          Ιστορικό
Header_Buckets                          Αρχεία
Header_Configuration                    Επιλογές
Header_Advanced                         Προχωρημένες Επιλογές
Header_Security                         Ασφάλεια
Header_Magnets                          Μαγνήτες

Footer_HomePage                         Ιστοσελίδα POPFile
Footer_Manual                           Εγχειρίδιο
Footer_Forums                           Συζυτήσεις
Footer_FeedMe                           Οικονομική Συνεισφορά
Footer_RequestFeature                   Ζητήστε Νέα Χαρακτηριστικά
Footer_MailingList                      Λιστά ηλ.ταχυδρομείου

Configuration_Error1                    Ο διαχωριστικός χαρακτήρας πρέπει να είναι μόνο ένας. 
Configuration_Error2                    Το  user interface port πρέπει να είναι μεταξύ 1 και 65535
Configuration_Error3                    Το POP3 listen port πρέπει να είναι μεταξύ 1 και 65535
Configuration_Error4                    Το μέγεθος σελίδας πρέπει να είναι μεταξύ 1 και 1000
Configuration_Error5                    Ο αριθμός ημερών για τήρηση ιστορικού πρέπει να είναι μεταξύ 1 και 366
Configuration_Error6                    Η παράμετρος TCP timeout πρέπει να είναι μεταξύ 10 και 300
Configuration_Error7                    Η παράμετρος XML RPC listen port πρέπει να είναι μεταξύ 1 και 65535
Configuration_POP3Port                  POP3 listen port
Configuration_POP3Update                Η παράμετρος POP3 port άλλαξε σε %s; Οι αλλαγές θα γίνουν ενεργές στην επόμενη εκκίνηση του POPFile
Configuration_XMLRPCUpdate              Η παράμετρος XML-RPC port άλλαξε σε %s;  Οι αλλαγές θα γίνουν ενεργές στην επόμενη εκκίνηση του POPFile
Configuration_XMLRPCPort                XML-RPC listen port
Configuration_SMTPPort                  SMTP listen port
Configuration_SMTPUpdate                Η παράμετρος SMTP port άλλαξε σε %s;  Οι αλλαγές θα γίνουν ενεργές στην επόμενη εκκίνηση του POPFile
Configuration_NNTPPort                  NNTP listen port
Configuration_NNTPUpdate                Η παράμετρος NNTP port άλλαξε σε %s;  Οι αλλαγές θα γίνουν ενεργές στην επόμενη εκκίνηση του POPFile
Configuration_POP3Separator             POP3 host:port:χαρακτήρας διαχωρισμού
Configuration_NNTPSeparator             NNTP host:port:Χαρακτήρας διαχωρισμού
Configuration_POP3SepUpdate             Αλλαγή χαρακτήρα διαχωρισμού POP3 σε %s
Configuration_NNTPSepUpdate             Αλλαγή χαρακτήρα διαχωρισμού NNTP σε %s
Configuration_UI                        Web port επιφάνειας ελέγχου
Configuration_UIUpdate                  Updated user interface web port to %s; this change will not take affect until you restart POPFile
Configuration_History                   Αριθμός μυνημάτων ανά Σελίδα
Configuration_HistoryUpdate             Αλλαγή αριθμού μυνημάτων ανά σελίδα σε %s
Configuration_Days                      Αρθιμός ημερών που κρατούνται σε ιστορικό
Configuration_DaysUpdate                Αλλαγή αρθιμού ημερών που κρατούνται σε ιστορικό σε %s
Configuration_UserInterface             Επιφάνεια Ελέγχου
Configuration_Skins                     Εμφάνιση
Configuration_SkinsChoose               Επιλογή εμφάνισης
Configuration_Language                  Γλώσσα
Configuration_LanguageChoose            Επιλογή Γλώσσας
Configuration_ListenPorts               Επιλογές επικοινωνίας
Configuration_HistoryView               Ιστορικό
Configuration_TCPTimeout                Connection Timeout
Configuration_TCPTimeoutSecs            Connection timeout σε δευτερόλεπτα
Configuration_TCPTimeoutUpdate          Αλλαγή  connection timeout σε %s
Configuration_ClassificationInsertion   Εισαγωγή Κειμένου σε μυνήματα
Configuration_SubjectLine               Αλλαγή Θέματος Μυνημάτων
Configuration_XTCInsertion              X-Text-Classification Header
Configuration_XPLInsertion              X-POPFile-Link Header
Configuration_Logging                   Ημερολόγιο Ενεργειών
Configuration_None                      Κανένα
Configuration_ToScreen                  Στην Οθόνη
Configuration_ToFile                    Σε Αρχείο
Configuration_ToScreenFile              Στην Οθόνη και σε αρχείο
Configuration_LoggerOutput              Εμφάνιση Ημερολογίου Ενεργειών
Configuration_GeneralSkins              Εμφανίσεις
Configuration_SmallSkins                 Μικρές Εμφανίσεις
Configuration_TinySkins                 Πιο Μικρές Εμφανίσεις
Configuration_CurrentLogFile            &lt;current log file&gt;

Advanced_Error1                         '%s' είναι ήδη στις εξαιρούμενες λέξεις
Advanced_Error2                         Οι εξαιρούμενες λέξεις μπορούν να συμπεριλαμβάνουν μόνο αλφανουμερικές λέξεις , ., _, -, η @ χαρακτήρες
Advanced_Error3                         '%s' προστέθηκε στις εξαιρούμενες λέξεις
Advanced_Error4                         '%s' δεν ανήκει στις εξαιρούμενες λέξεις
Advanced_Error5                         '%s' αφαιρέθηκε από τις εξαιρούμενες λέξεις
Advanced_StopWords                      Λέξεις που εξαιρούνται 
Advanced_Message1                       Το POPFile εξαιρεί τις ακόλουθες συχνά εμφανιζόμενες λέξεις :
Advanced_AddWord                        Προσθήκη Λέξης
Advanced_RemoveWord                     Αφαίρεση Λέξης

History_Filter                          &nbsp;(εμφανίζεται μόνον αρχείο <font color="%s">%s</font>)
History_FilterBy                        Φιλτράρισμα με χρήση
History_Search                          &nbsp;(αναζήτηση για Αποστολέα/Θέμα %s)
History_Title                           Προσφατα Μυνήματα
History_Jump                            Μυνήματα από
History_ShowAll                         Εμφάνιση όλων
History_ShouldBe                        Να ταξιμομηθεί ώς
History_NoFrom                          Δεν έχει αποστολέα
History_NoSubject                       Δεν υπάρχει θέμα
History_ClassifyAs                      Να ταξινομηθεί σαν
History_MagnetUsed                      Μαγνήτης σε χρήση
History_MagnetBecause                   <b>Μαγνήτης σε χρήση</b><p>Εχει ταξινομηθεί σε <font color="%s">%s</font> λόγω μαγνήτη %s </p>
History_ChangedTo                       Αλλαξε σε <font color="%s">%s
History_Already                         Εχει ήδη επαναταξινομηθεί σε <font color="%s">%s</font>
History_RemoveAll                       Διαγραφή Ολων
History_RemovePage                     Διαγραφή Σελίδας
History_Remove                          Για να διαγράψετε στοιχεία του ιστορικού πατήστε
History_SearchMessage                   Αναξήτηση Αποστολέα/Θέμα
History_NoMessages                      Δεν υπάρχουν Μηνύματα
History_ShowMagnet                      μαγνητισμένο
History_ShowNoMagnet                    μη μαγνητισμένο
History_Magnet                          &nbsp;(εμφάνιση μόνο μαγνητισμένων μυνημάτων)
History_NoMagnet                        &nbsp;(εμφάνιση μόνο μή μαγνητισμένων μυνημάτων)
History_ResetSearch                     Επαναφορά

Password_Title                          Σύνθημα
Password_Enter                          Γράψτε σύνθημα
Password_Go                             Προχωρήστε!
Password_Error1                         Λάθος σύνθημα

Security_Error1                         Το  port πρέπει να είναι ένας αριθμός μεταξύ 1 και 65535
Security_Stealth                        Λειτουργία Απόκρυψής/Λειτουργία Server
Security_NoStealthMode                  Οχι ( Λειτουργία Απόκρυψης )
Security_ExplainStats                   (Με αυτή την επιλογή ενεργή το POPFile στέλνει κάθε ημέρα τις ακόλουθες τρείς παραμέτρους σε ένα πρόγραμμα στο www.usethesource.com: bc (σύνολο αρχείων που χρησιμοποιούνται ), mc (σύνολο ταξινομημένων μυνημάτων) and ec (σύνολο λαθών ταξινόμησης).  Αυτά αρχειοθετούνται και χρησιμοποιούνται για να συνταχθούν στατιστικές για το πώς οι χρήστες χρησιμοποιούν το POPFile αλλά και πόσο αποτελεσματικά αυτό δουλεύειs.  Τα αρχεία σβήνονται με την παρέλευση πενθημέρου; Δεν γίνονται συσχετισμοί μεταξύ των στατιστικών και των μεμονομένων διευθύνσεων IP.)
Security_ExplainUpdate                  (Με αυτή την επιλογή ενεργή το POPFile στέλνει κάθε ημέρα τις ακόλουθες τρείς παραμέτρους σε ένα πρόγραμμα στο www.usethesource.com:: ma (τον κύριο αριθμό έκδοσης του εν χρήση POPFile), mi (τον δευτερεύοντα αριθμό έκδοσης του εν χρήση POPFile) και bn (τον  αριθμό έκδοσης του εν χρήση POPFile).  Το POPFile λαμβάνει μία απάντηση με την μορφή γραφικού που εμφανίζεται στην άνω μεριά της σελίδας, και σας ειδοποιεί ότι υπάρχει νέα ενημερωμένη έκδοση.  Τα αρχεία σβήνονται με την παρέλευση πενθημέρου; Δεν γίνονται συσχετισμοί μεταξύ των στατιστικών και των μεμονομένων διευθύνσεων IP.)
Security_PasswordTitle                  Σύνθημα Επιφάνειας Χρήσης
Security_Password                       Σύνθημα
Security_PasswordUpdate                 Το σύνθημα άλλαξε σε  %s
Security_AUTHTitle                      Remote Servers
Security_SecureServer                   POP3 SPA/AUTH server
Security_SecureServerUpdate             Η παράμετρος POP3 SPA/AUTH secure server άλλαξε σε %s; Οι αλλαγές θα γίνουν ενεργές στην επόμενη εκκίνηση του POPFile
Security_SecurePort                     POP3 SPA/AUTH port
Security_SecurePortUpdate               Η παράμετρος POP3 SPA/AUTH port  άλλαξε σε %s; Οι αλλαγές θα γίνουν ενεργές στην επόμενη εκκίνηση του POPFile
Security_SMTPServer                     SMTP chain server
Security_SMTPServerUpdate               Η παράμετρος SMTP chain server άλλαξε σε %s; Οι αλλαγές θα γίνουν ενεργές στην επόμενη εκκίνηση του POPFile
Security_SMTPPort                       SMTP chain port
Security_SMTPPortUpdate                 Η παράμετρος SMTP chain port άλλαξε σε %s; Οι αλλαγές θα γίνουν ενεργές στην επόμενη εκκίνηση του POPFile
Security_POP3                           Να γίνονται αποδεκτές συνδέσεις POP3 από Η/Υ στο δίκτυο (χρειάζεται επανεκκίνηση του POPFile )
Security_SMTP                           Να γίνονται αποδεκτές συνδέσεις SMTP από Η/Υ στο δίκτυο (χρειάζεται επανεκκίνηση του POPFile )
Security_NNTP                           Να γίνονται αποδεκτές συνδέσεις NNTP από Η/Υ στο δίκτυο (χρειάζεται επανεκκίνηση του POPFile )
Security_UI                             Να γίνονται αποδεκτές συνδέσεις HTTP από Η/Υ στο δίκτυο (χρειάζεται επανεκκίνηση του POPFile )
Security_XMLRPC                         Να γίνονται αποδεκτές συνδέσεις XML-RPC από Η/Υ στο δίκτυο (χρειάζεται επανεκκίνηση του POPFile )
Security_UpdateTitle                    Αυτόματος Ελεγχος για Ενημερωμένες Εκδόσεις
Security_Update                         Καθημερινός έλεγχος για Ενημερωμένες Εκδόσεις του  POPFile
Security_StatsTitle                     Αποστολή Στατιστικών
Security_Stats                          Καθημερινή Αποστολή Στατιστικών

Magnet_Error1                           Ο Μαγνήτης '%s' υπάρχει ήδη στο αρχείο '%s'
Magnet_Error2                           Ο νέος Μαγνήτης '%s' είναι σε αντίφαση με τον ήδη υπάρχοντα '%s' στο αρχείο '%s' και αυτό θα οδηγούσε σε λανθασμένες ταξινομήσεις.  Ο νέος μαγνήτης δεν προσετέθει..
Magnet_Error3                           Δημιουργία νέου μαγνήτη '%s' στο αρχείο '%s'
Magnet_CurrentMagnets                   Υπάρχοντες Μαγνήτες
Magnet_Message1                         Οι ακόλουθοι μαγνήτες πάντα ταξινομούν τα μυνήματα σας στο προκαθορισμένο αρχείο :.
Magnet_CreateNew                        Δημιουργία νέου μαγνήτη
Magnet_Explanation                      Αυτοί οι τύποι μαγνήτη είναι διαθέσιμοι:</b> <ul><li><b>Από Διυυθυνση η Ονομα:</b> Π.χ.: john@company.com για συγκεκριμένη διευθυνσηs, <br />company.com για όλες τις διευθύνσεις που καταλήγουν σε company.com, <br />John Doe για συγκεκριμένο όνομα, John για όλους με πρώτο όνομα John</li><li><b>Προς/Κοιν. διεύθυνση η όνομα:</b> ¨Οπως για Αποστολέα αλλα αφορά τα πεδία Πρός/ Κοιν.:</li> <li><b>Θέμα :</b> Π.χ.: hello για να μαγνητισθούν όλα τα μυνήματα που περιέχουν την λέξη hello στο θέμα</li></ul>
Magnet_MagnetType                      Τύποι Μαγνητών
Magnet_Value                            Αξία
Magnet_Always                           Παντα ταξινομείται στο αρχείο
Magnet_Jump                             Μαγνήτες από 

Bucket_Error1                           Τα ονόματα των αρχείων μπορούν να περιέχουν μόνο τα πεζά αγγλικά γράμματα  a έως z, τους αριθμούς 0 εως 9,  και τους χαρακτήρες  - και _
Bucket_Error2                           Αρχείο  %s υπάρχει ήδη
Bucket_Error3                           Δημιουργήθηκε αρχείο με όνομα %s
Bucket_Error4                           Παρακαλούμε εισάγετε μι όχι κενή λέξη
Bucket_Error5                           Το αρχείο %s μετονομάστηκε σε %s
Bucket_Error6                           Διαγράφθηκε το αρχείο %s
Bucket_Title                            Περίληψη
Bucket_BucketName                       Αρχείο
Bucket_WordCount                        Πλήθος Λέξεων
Bucket_WordCounts                       Στατιστικά Λέξεων
Bucket_UniqueWords                      Μοναδικές Λέξεις
Bucket_SubjectModification              Αλλαγή Θέματος Μυνημάτων
Bucket_ChangeColor                      Αλλαγή Χρώματος
Bucket_NotEnoughData                    Ανεπαρκή Δεδομένα
Bucket_ClassificationAccuracy           Ακρίβεια Ταξινόμησης
Bucket_EmailsClassified                 Ταξινομημένα μυνήματα
Bucket_EmailsClassifiedUpper            Ταξινομημένα Μυνήματα
Bucket_ClassificationErrors             Σφάλματα Ταξινόμησης
Bucket_Accuracy                         Ακρίβεια Ταξινόμησης
Bucket_ClassificationCount              Αριθμ. Ταξινομήσεων
Bucket_ClassificationFP                 Ψευδή Θετικά
Bucket_ClassificationFN                 Ψευδή Αρνητικά
Bucket_ResetStatistics                  Μηδενισμός Στατιστικών
Bucket_LastReset                        Τελευταίος Μηδενισμός
Bucket_CurrentColor                     τρέχων χρώμα %s  είναι %s
Bucket_SetColorTo                       Ορισμός χρώματος  %s σε %s
Bucket_Maintenance                      Συντήρηση Αρχείων
Bucket_CreateBucket                     Δημιουργία αρχείου με όνομα
Bucket_DeleteBucket                     Διαγραφή αρχείου με όνομα
Bucket_RenameBucket                     Μετονομασία αρχείου με όνομα
Bucket_Lookup                           Εύρεση
Bucket_LookupMessage                    Εύρευση λέξεως σε αρχεία
Bucket_LookupMessage2                   Αποτελέσματα εύρεσης λέξεως 
Bucket_LookupMostLikely                 <b>%s</b> είναι πιο πιθανό να ανήκει στο <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> δεν ανήκει σε κανένα από τα αρχεία
Bucket_DisabledGlobally                 Γενικώς Απενεργοποιημένο 
Bucket_To                               σε
Bucket_Quarantine                       Καραντίνα

SingleBucket_Title                      Λεπτομέρειες του αρχείου %s
SingleBucket_WordCount                  Αριθμός λέξεων αρχείου
SingleBucket_TotalWordCount             Συνολικές εμφανίσεις λέξεων
SingleBucket_Percentage                 Ποσοστό επί συνόλου
SingleBucket_WordTable                  Πίνακας λέξεων για %s
SingleBucket_Message1                   Κάντε κλίκ πάνω σε ένα γράμμα για να δείτε τις λέξεις που αρχίζουν από αυτό.  Κάντε κλίκ σε μία λέξη για να δείτε τις πιθανότητες να ανήκει σε οποιοδήποτε αρχείο..
SingleBucket_Unique                     %s μοναδικές
SingleBucket_ClearBucket                Διαγραφή όλων των λέξεων

Session_Title                           Η συνεδρία του POPFile έχει λήξει
Session_Error                           Η παρούσα συνεδρία POPFile έχει λήξει.  Αυτό μποεί να είναι αποτέλεσμα της επανεκκίνησης του POPFile ενόσω το πρόγραμμα εμφάνισης ιστοσελίδων σας παρέμεινε ανοικτό.  Παρακαλούμε κάντε κλίκ σε κάποια από τις άνωθι συνδέσεις για να αποκαταστήσετε την επικοινωνία με το POPFile.

View_Title                              Εμφάνιση Μεμονομένου Μυνήματος

Header_MenuSummary                      This table is the navigation menu which allows access to each of the different pages of the control center.
History_MainTableSummary                This table shows the sender and subject of recently received messages and allows them to be reviewed and reclassified.  Clicking on the subject line will show the full message text, along with information about why it was classified as it was.  The 'Should be' column allows you to specify which bucket the message belongs in, or to undo that change.  The 'Delete' column allows you to delete specific messages from the history if you don't need them anymore.
History_OpenMessageSummary              This table contains the full text of a message message, with the words that are used for classification highlighted according to the bucket that was most relevant for each.
Bucket_MainTableSummary                 This table provides an overview of the classification buckets.  Each row shows the bucket name, the word count total for that bucket, the actual number of individual words in each bucket, whether the message's subject line will be modified when it gets classified to that bucket, whether to quarantine the messages received in that bucket, and a table to pick the color used in displaying anything related to that bucket in the control center.
Bucket_StatisticsTableSummary           This table provides three sets of statistics on the overall performance of POPFile.  The first is how accurate its classification is, the second is how many messages have been classified, and to which buckets, and the third is how many words are in each bucket, and what their relative percentages are.
Bucket_MaintenanceTableSummary          This table contains forms that allow you to create, delete or rename buckets, and to lookup a word in all of the buckets to see its relative probabilities.
Bucket_AccuracyChartSummary             This table graphically represents the accuracy of the message classification.
Bucket_BarChartSummary                  This table graphically represents a percentage allocation for each of the different buckets.  It is used for both number of messages classified, and total word counts.
Bucket_LookupResultsSummary             This table shows the probabilities associated with any given word of the corpus.  For each bucket, it shows the frequency that that word occurs, the probability that it will occur in that bucket, and the overall effect on the score of the bucket if that word exists in a message.
Bucket_WordListTableSummary             This table provides a listing of all the words for a particular bucket, organized by common first letter for each row.
Magnet_MainTableSummary                 This table shows the list of magnets that are used to automatically classify message according to fixed rules.  Each row shows how the magnet is defined, what bucket it is intended for, and a button to delete the magnet.
Configuration_MainTableSummary          This table contains a number of forms to allow you to control the configuration of POPFile.
Configuration_InsertionTableSummary     This table contains buttons that determine whether or not certain modifications are made to the headers or subject line of the message before it is passed on to the message client.
Security_MainTableSummary               This table provides sets of controls that affect the security of the overall configuration of POPFile, whether it should automatically check for updates to the program, and whether statistics about POPFile's performance should be sent to the central datastore of the program's author for general information.
Advanced_MainTableSummary               This table provides a list of words that POPFile ignores when classifying message due to their relative frequency in message in general.  They are organized per row according to the first letter of the words.

