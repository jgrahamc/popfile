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
LanguageCode                            nl
LanguageCharset                         ISO-8859-1

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en
 
# Common words that are used on their own all over the interface
Apply                                   Doorvoeren
On                                      Aan
Off                                     Uit
TurnOn                                  Zet aan
TurnOff                                 Zet uit
Add                                     Voeg toe
Remove                                  Verwijder
Previous                                Vorige
Next                                    Volgende
From                                    Van
Subject                                 Onderwerp
Classification                          Classificatie
Reclassify                              Herclasseren
Undo                                    Maak ongedaan
Close                                   Sluiten
Find                                    Zoek
Filter                                  Filter
Yes                                     Ja
No                                      Nee
ChangeToYes                             Verander naar Ja
ChangeToNo                              Verander naar Nee
Bucket                                  Bak
Magnet                                  Magneet
Delete                                  Verwijder
Create                                  Maak aan
To                                      Aan
Total                                   Totaal
Rename                                  Hernoemen
Frequency                               Frequentie
Probability                             Waarschijnlijkheid
Score                                   Score
Lookup                                  Bekijk

# The header and footer that appear on every UI page
Header_Title                            POPFile Control Center
Header_Shutdown                         Sluiten
Header_History                          Geschiedenis
Header_Buckets                          Bakken
Header_Configuration                    Configuratie
Header_Advanced                         Gevorderd
Header_Security                         Veiligheid
Header_Magnets                          Magneten

Footer_HomePage                         POPFile Home Page
Footer_Manual                           Handleiding
Footer_Forums                           Forums
Footer_FeedMe                           Voer mij!
Footer_RequestFeature                   Vraag functionaliteit aan
Footer_MailingList                      Mailing Lijst

Configuration_Error1                    Het scheidingsteken moet een enkel karakter zijn
Configuration_Error2                    De gebruikers interface poort moet een getal zijn tussen 1 en 65535
Configuration_Error3                    De POP3 luisterpoort moet een getal zijn tussen 1 en 65535
Configuration_Error4                    De pagina grootte moet een getal zijn tussen 1 en 1000
Configuration_Error5                    Het aantal dagen in de geschiedenis moet een getal zijn tussen 1 en 366
Configuration_Error6                    De TCP timeout moet een getal zijn tussen 10 en 300
Configuration_POP3Port                  POP3 luisterpoort
Configuration_POP3Update                Poort veranderd naar %s; deze verandering krijgt effect zodra je POPFile herstart hebt
Configuration_Separator                 Scheidingsteken
Configuration_SepUpdate                 Scheidingsteken veranderd naar %s
Configuration_UI                        Gebruikers interface web poort
Configuration_UIUpdate                  Gebruikers interface web poort veranderd naar %s; deze verandering krijgt effect zodra je POPFile herstart hebt
Configuration_History                   Aantal emails per pagina
Configuration_HistoryUpdate             Aantal emails per pagina veranderd naar %s
Configuration_Days                      Aantal dagen geschiedenis om te bewaren
Configuration_DaysUpdate                Aantal dagen geschiedenis om te bewaren veranderd naar %s
Configuration_UserInterface             Gebruikers Interface
Configuration_Skins                     Huiden
Configuration_SkinsChoose               Kies huid
Configuration_Language                  Taal
Configuration_LanguageChoose            Kies Taal
Configuration_ListenPorts               Luister Poorten
Configuration_HistoryView               Geschiedenis View
Configuration_TCPTimeout                TCP Connectie Timeout
Configuration_TCPTimeoutSecs            TCP Connectie Timeout in seconden
Configuration_TCPTimeoutUpdate          TCP Connectie Timeout veranderd naar %s
Configuration_ClassificationInsertion   Classificatie toevoeging
Configuration_SubjectLine               Onderwerp regel verandering
Configuration_XTCInsertion              X-Text-Classification toevoeging
Configuration_XPLInsertion              X-POPFile-Link toevoeging
Configuration_Logging                   Logging
Configuration_None                      Geen
Configuration_ToScreen                  Naar het scherm
Configuration_ToFile                    Naar een bestand
Configuration_ToScreenFile              Naar het scherm en naar een bestand
Configuration_LoggerOutput              Logger uitvoer
Configuration_GeneralSkins              Skins
Configuration_SmallSkins                Small Skins
Configuration_TinySkins                 Tiny Skins

Advanced_Error1                         '%s' zit al in de lijst met stopwoorden
Advanced_Error2                         stopwoorden mogen alleen alphanumerieke, ., _, -, of @ karakters bevatten
Advanced_Error3                         '%s' is toegevoegd aan de lijst met stopwoorden
Advanced_Error4                         '%s' zit niet in de lijst met stopwoorden
Advanced_Error5                         '%s' is verwijderd van de lijst met stopwoorden
Advanced_StopWords                      Stopwoorden
Advanced_Message1                       De volgende woorden worden genegeerd bij alle classificaties omdat ze zeer vaak voorkomen.
Advanced_AddWord                        Voeg woord toe
Advanced_RemoveWord                     Verwijder woord

History_Filter                          &nbsp;(alleen uit bak <font color="%s">%s</font>)
History_FilterBy                        Filter By
History_Search                          &nbsp;(gezocht op onderwerp %s)
History_Title                           Recente Berichten
History_Jump                            Spring naar bericht
History_ShowAll                         Laat alles zien
History_ShouldBe                        Moet zijn
History_NoFrom                          geen van regel
History_NoSubject                       geen onderwerp regel
History_ClassifyAs                      Classificeer als
History_MagnetUsed                      Magneet gebruikt
History_ChangedTo                       Veranderd naar <font color="%s">%s
History_Already                         Is al gereclassificeerd als <font color="%s">%s</font>
History_RemoveAll                       Verwijder alles
History_RemovePage                      Verwijder pagina
History_Remove                          Om berichten te verwijderen in de geschiedenis klik
History_SearchMessage                   Zoek onderwerp
History_NoMessages                      Geen berichten

Password_Title                          Wachtwoord
Password_Enter                          Voer wachtwoord in
Password_Go                             Go!
Password_Error1                         Ongeldig wachtwoord

Security_Error1                         De veilige poort moet een nummer zijn tussen 1 en 65535
Security_Stealth                        Undercover modus/Server operatie
Security_NoStealthMode                  Nee (Undercover modus)
Security_ExplainStats                   (als dit aan staat stuurt POPFile één keer per dag de volgende drie waarden naar een script op www.usethesource.com: bc (het aantal bakken dat je hebt), mc (het totaal aantal geclassificeerde berichten door POPFile) en ec (het totaal aantal fouten tijdens classificatie).  Deze waarden worden opgeslagen in een bestand en ik zal deze gegevens gebruiken om statistieken te publiceren over hoe mensen POPFile gebruiken en hoe goed het werkt.  Mijn web server houdt de log bestanden 5 dagen vast waarna ze verwijderd zullen worden; Ik bewaar geen gegevens over het verband tussen de statistieken en individuele IP adressen.)
Security_ExplainUpdate                  (als dit aan staat stuurt POPFile één keer per dag de volgende drie waarden naar een script op www.usethesource.com: ma (het grote versie nummer van jouw POPFile installatie), mi (het kleine versie nummer van jouw POPFile installatie) en bn (het bouwnummer van jouw versie van POPFile).  POPFile ontvangt in reactie hierop een plaatje dat bovenaan de pagina afgebeeld wordt als er een nieuwe versie van POPFile beschikbaar is. Mijn web server houdt de log bestanden 5 dagen vast waarna ze verwijderd zullen worden; Ik bewaar geen gegevens over het verband tussen de update checks en individuele IP adressen.)
Security_PasswordTitle                  Gebruikers Interface Wachtwoord
Security_Password                       Wachtwoord
Security_PasswordUpdate                 Wachtwoord veranderd naar %s
Security_AUTHTitle                      Veilig Wachtwoord Authentificatie (AUTH)
Security_SecureServer                   Veilige Server
Security_SecureServerUpdate             Veilige server veranderd naar %s; deze verandering krijgt effect zodra je POPFile herstart hebt
Security_SecurePort                     Veilige poort
Security_SecurePortUpdate               Veilige poort veranderd naar %s; deze verandering krijgt effect zodra je POPFile herstart hebt
Security_POP3                           Accepteer POP3 verbindingen van andere machines 
Security_UI                             Accepteer HTTP (Gebruikers Interface) verbindingen van andere machines 
Security_UpdateTitle                    Automatische Update controle 
Security_Update                         Controleer dagelijks op nieuwe versies van POPFile 
Security_StatsTitle                     Rapporteer statistieken
Security_Stats                          Stuur dagelijks statistieken naar John terug

Magnet_Error1                           Magneet'%s' bestaat al in bak '%s'
Magnet_Error2                           Nieuwe magneet '%s' botst met magneet '%s' in bak '%s' en kan voor verwarrende resultaten leiden.  Nieuwe magneet niet toegevoegd.
Magnet_Error3                           Maak nieuwe magneet '%s' in bak '%s'
Magnet_CurrentMagnets                   Huidige magneten
Magnet_Message1                         De volgende magneten zorgen er altijd voor dat berichten in de gespecificeerde bak vallen.
Magnet_CreateNew                        Maak Nieuwe Magneet
Magnet_Explanation                      Er zijn drie type magneten beschikbaar: <ul><li>Van adres of naam:</b> B.v.: john@company.com om een specifiek adres te specificeren, <br />company.com om iedereen te specificeren die berichten sturen vanaf company.com, <br />John Doe om een bepaalde persoon te specificeren, John om alle Johns te specificeren</li><li><b>Naar adres of naam:</b> Net als een "Van" magneet maar nu voor de geadresseerde</li><li><b>Onderwerp woorden:</b> B.v.: Hallo om alle berichten met Hallo in het onderwerp te specificeren.</li></ul>
Magnet_MagnetType                       Magneet type
Magnet_Value                            Waarde
Magnet_Always                           Gaat altijd naar bak

Bucket_Error1                           Baknamen kunnen alleen a t/m z (geen hoofdletters) en - en _ karakters bevatten
Bucket_Error2                           Baknaam %s bestaat al
Bucket_Error3                           Bak aangemaakt met naam %s
Bucket_Error4                           Voert u a.u.b. een woord in
Bucket_Error5                           Bak %s hernoemd naar %s
Bucket_Error6                           Bak %s verwijderd
Bucket_Title                            Opsomming
Bucket_BucketName                       Baknaam
Bucket_WordCount                        Aantal woorden
Bucket_WordCounts                       Aantal woorden
Bucket_UniqueWords                      Unieke woorden
Bucket_SubjectModification              Onderwerp aanpassing
Bucket_ChangeColor                      Verander kleur
Bucket_NotEnoughData                    Niet genoeg gegevens
Bucket_ClassificationAccuracy           Classificatie precisie
Bucket_EmailsClassified                 Berichten geclassificeerd
Bucket_EmailsClassifiedUpper            Berichten Geclassificeerd
Bucket_ClassificationErrors             Classificatiefouten
Bucket_Accuracy                         Precisie
Bucket_ClassificationCount              Aantal Classificaties
Bucket_ResetStatistics                  Herstart statistieken
Bucket_LastReset                        Laatste Herstart
Bucket_CurrentColor                     %s huidige kleur is %s
Bucket_SetColorTo                       Zet %s kleur op %s
Bucket_Maintenance                      Onderhoud
Bucket_CreateBucket                     Maak bak aan met naam
Bucket_DeleteBucket                     Verwijder bak met naam 
Bucket_RenameBucket                     Hernoem bak met naam
Bucket_Lookup                           Bekijk
Bucket_LookupMessage                    Bekijk woord in bak
Bucket_LookupMessage2                   Resultaat voor 
Bucket_LookupMostLikely                 <b>%s</b> komt het meest waarschijnlijk voor in <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> komt niet voor in een van de bakken
Bucket_DisabledGlobally                 Globaal uitgeschakeld
Bucket_To                               naar

SingleBucket_Title                      Details voor %s
SingleBucket_WordCount                  Aantal woorden in bak
SingleBucket_TotalWordCount             Totaal aantal woorden
SingleBucket_Percentage                 Percentage van totaal
SingleBucket_WordTable                  Woordentabel voor %s
SingleBucket_Message1                   Woorden met een sterretje (*) zijn gebruikt voor classificatie in deze POPFile sessie.  Klik op een woord om de waarschijnlijkheid te zien voor alle bakken.
SingleBucket_Unique                     %s uniek

Header_MenuSummary                      This table is the navigation menu which allows access to each of the different pages of the control center.
History_MainTableSummary                This table shows the sender and subject of recently received messages and allows them to be reviewed and reclassified.  Clicking on the subject line will show the full message text, along with information about why it was classified as it was.  The 'Should be' column allows you to specify which bucket the message belongs in, or to undo that change.  The 'Delete' column allows you to delete specific messages from the history if you don't need them anymore.
History_OpenMessageSummary              This table contains the full text of an email message, with the words that are used for classification highlighted according to the bucket that was most relevant for each.
Bucket_MainTableSummary                 This table provides an overview of the classification buckets.  Each row shows the bucket name, the word count total for that bucket, the actual number of individual words in each bucket, whether the email's subject line will be modified when it gets classified to that bucket, whether to quarantine the messages received in that bucket, and a table to pick the color used in displaying anything related to that bucket in the control center.
Bucket_StatisticsTableSummary           This table provides three sets of statistics on the overall performance of PopFile.  The first is how accurate its classification is, the second is how many emails have been classified, and to which buckets, and the third is how many words are in each bucket, and what their relative percentages are.
Bucket_MaintenanceTableSummary          This table contains forms that allow you to create, delete or rename buckets, and to lookup a word in all of the buckets to see its relative probabilities.
Bucket_AccuracyChartSummary             This table graphically represents the accuracy of the email classification.
Bucket_BarChartSummary                  This table graphically represents a percentage allocation for each of the different buckets.  It is used for both number of emails classified, and total word counts.
Bucket_LookupResultsSummary             This table shows the probabilities associated with any given word of the corpus.  For each bucket, it shows the frequency that that word occurs, the probability that it will occur in that bucket, and the overall effect on the score of the bucket if that word exists in an email.
Bucket_WordListTableSummary             This table provides a listing of all the words for a particular bucket, organized by common first letter for each row.
Magnet_MainTableSummary                 This table shows the list of magnets that are used to automatically classify email according to fixed rules.  Each row shows how the magnet is defined, what bucket it is intended for, and a button to delete the magnet.
Configuration_MainTableSummary          This table contains a number of forms to allow you to control the configuration of PopFile.
Configuration_InsertionTableSummary     This table contains buttons that determine whether or not certain modifications are made to the headers or subject line of the email before it is passed on to the email client.
Security_MainTableSummary               This table provides sets of controls that affect the security of the overall configuration of PopFile, whether it should automatically check for updates to the program, and whether statistics about PopFile's performance should be sent to the central datastore of the program's author for general information.
Advanced_MainTableSummary               This table provides a list of words that PopFile ignores when classifying email due to their relative frequency in email in general.  They are organized per row according to the first letter of the words.

