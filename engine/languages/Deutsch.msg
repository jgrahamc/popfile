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
LanguageCode                            de
LanguageCharset                         ISO-8859-1
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          de

# Common words that are used on their own all over the interface
Apply                                   Anwenden
On                                      Ein
Off                                     Aus
TurnOn                                  Einschalten
TurnOff                                 Ausschalten
Add                                     Hinzufügen
Remove                                  Entfernen
Previous                                Zurück
Next                                    Weiter
From                                    Absender
Subject                                 Betreff
Cc                                      Cc
Classification                          Einstufung
Reclassify                              Neu einstufen
Probability                             Wahrscheinlichkeit
Scores                                  Auswertung
QuickMagnets                            Sofort-Magnete
Undo                                    widerrufen
Close                                   Schließen
Find                                    Suchen
Filter                                  Filtern
Yes                                     Ja
No                                      Nein
ChangeToYes                             Ändern in Ja
ChangeToNo                              Ändern in Nein
Bucket                                  Kategorie
Magnet                                  Magnet
Delete                                  Löschen
Create                                  Erstellen
To                                      Empfänger
Total                                   Insgesamt
Rename                                  Umbenennen
Frequency                               Häufigkeit
Probability                             Wahrscheinlichkeit
Score                                   Bewertung
Lookup                                  Nachschlagen
Word                                    Wort
Count                                   Anzahl
Update                                  Ändern
Refresh                                 Aktualisieren
FAQ                                     FAQ
ID                                      ID

# The header and footer that appear on every UI page
Header_Title                            POPFile Kontrollzentrum
Header_Shutdown                         Herunterfahren
Header_History                          Verlauf
Header_Buckets                          Kategorie
Header_Configuration                    Konfiguration
Header_Advanced                         Erweitert
Header_Security                         Sicherheit
Header_Magnets                          Magnete

Footer_HomePage                         POPFile Homepage
Footer_Manual                           Handbuch
Footer_Forums                           Foren
Footer_FeedMe                           Spenden
Footer_RequestFeature                   Funktionalität vorschlagen
Footer_MailingList                      Mailing Liste

Configuration_Error1                    Das Trennzeichen muß ein einzelnes Zeichen sein.
Configuration_Error2                    Der Port für das Kontrollzentrum muß zwischen 1 und 65535 liegen.
Configuration_Error3                    Der POP3 Port muß zwischen 1 und 65535 liegen.
Configuration_Error4                    Die Seitengröße muß zwischen 1 und 1000 liegen.
Configuration_Error5                    Die Anzahl der Tage im Verlauf muß zwischen 1 und 366 liegen.
Configuration_Error6                    Der TCP Timeout muß zwischen 10 und 300 liegen.
Configuration_Error7                    Der XML-RPC Port muß zwischen 1 und 65535 liegen.
Configuration_POP3Port                  POP3 Port
Configuration_POP3Update                Neuer POP3 Port: %s - Diese Änderung wird erst nach einem Neustart von POPFile wirksam.
Configuration_XMLRPCUpdate              Neuer XML-RPC Port: %s - Diese Änderung wird erst nach einem Neustart von POPFile wirksam.
Configuration_XMLRPCPort                XML-RPC Port
Configuration_SMTPPort                  SMTP Port
Configuration_SMTPUpdate                Neuer SMTP Port: %s - Diese Änderung wird erst nach einem Neustart von POPFile wirksam.
Configuration_NNTPPort                  NNTP Port
Configuration_NNTPUpdate                Neuer NNTP Port: %s - Diese Änderung wird erst nach einem Neustart von POPFile wirksam.
Configuration_POPFork                   Simultane POP3-Verbindungen erlauben
Configuration_SMTPFork                  Simultane SMTP-Verbindungen erlauben
Configuration_NNTPFork                  Simultane NNTP-Verbindungen erlauben
Configuration_POP3Separator             POP3 Server:Port:Benutzer Trennzeichen
Configuration_NNTPSeparator             NNTP Server:Port:Benutzer Trennzeichen
Configuration_POP3SepUpdate             Neues POP3 Trennzeichen: %s
Configuration_NNTPSepUpdate             Neues NNTP Trennzeichen: %s
Configuration_UI                        Web Port für Kontrollzentrum
Configuration_UIUpdate                  Neuer Web Port für Kontrollzentrum: %s - Dieser Änderung wird erst nach einem Neustart von POPFile wirksam.
Configuration_History                   Anzahl Nachrichten pro Seite
Configuration_HistoryUpdate             Neue Anzahl Nachrichten pro Seite: %s
Configuration_Days                      Nachrichten x Tage im Verlauf speichern
Configuration_DaysUpdate                Nachrichten werden nun %s Tage im Verlauf gespeichert
Configuration_UserInterface             Benutzeroberfläche
Configuration_Skins                     Skins
Configuration_SkinsChoose               Skin auswählen
Configuration_Language                  Sprache
Configuration_LanguageChoose            Sprache auswählen
Configuration_ListenPorts               Moduleinstellungen
Configuration_HistoryView               Verlaufsansicht
Configuration_TCPTimeout                Verbindungstimeout
Configuration_TCPTimeoutSecs            Verbindungstimeout in Sekunden
Configuration_TCPTimeoutUpdate          Neuer Verbidungstimeout: %s
Configuration_ClassificationInsertion   Einstufung anzeigen
Configuration_SubjectLine               Betreff-Zeile ändern
Configuration_XTCInsertion              X-Text-Classification einfügen
Configuration_XPLInsertion              X-POPFile-Link einfügen
Configuration_Logging                   Protokollierung
Configuration_None                      Keine Ausgabe
Configuration_ToScreen                  Auf den Bildschirm
Configuration_ToFile                    In eine Datei
Configuration_ToScreenFile              Bildschirm und Datei
Configuration_LoggerOutput              Protokoll ausgeben
Configuration_GeneralSkins              Skins
Configuration_SmallSkins                kleine Skins
Configuration_TinySkins                 sehr kleine Skins
Configuration_CurrentLogFile            &lt;aktuelle Protokolldatei&gt;

Advanced_Error1                         '%s' ist bereits in der Liste der ignorierten Wörter
Advanced_Error2                         Ignorierte Wörtern können nur alphanumerische, ., _, -, oder @ Zeichen enthalten
Advanced_Error3                         '%s' zu den ignorierten Wörtern hinzugefügt
Advanced_Error4                         '%s' ist nicht in der Liste der ignorierten Wörter
Advanced_Error5                         '%s' von der Liste der ignorierten Wörter entfernt
Advanced_StopWords                      Ignorierte Wörter
Advanced_Message1                       POPFile ignoriert die folgenden, häufig verwendeten Wörter:
Advanced_AddWord                        Wort hinzufügen
Advanced_RemoveWord                     Wort löschen
Advanced_AllParameters                  POPFile Konfigurationsparameter
Advanced_Parameter                      Parameter
Advanced_Value                          Wert
Advanced_Warning                        Dies ist eine komplette Liste aller Parameter Ihrer POPFile Konfiguration. Nur für fortgeschrittene Anwender: Sie können jeden Wert ändern und durch einen Klick auf "Ändern" bestätigen. Eingaben werden nicht auf Gültigkeit überprüft!
Advanced_ConfigFile                     Konfigurationsdatei:

History_Filter                          &nbsp;(zeige nur Kategorie <font color="%s">%s</font>)
History_FilterBy                        Filtern nach
History_Search                          &nbsp;(gesuchter Absender/Betreff: %s)
History_Title                           Aktuelle Nachrichten
History_Jump                            zu Seite gehen
History_ShowAll                         Alle anzeigen
History_ShouldBe                        Sollte sein
History_NoFrom                          kein Absender angegeben
History_NoSubject                       kein Betreff
History_ClassifyAs                      eingestuft als
History_MagnetUsed                      Magnet benutzt
History_MagnetBecause                   <b>Magnet benutzt</b><p>Eingestuft als <font color="%s">%s</font> durch Magnet %s </p>
History_ChangedTo                       Geändert: <font color="%s">%s</font>
History_Already                         Neu eingestuft als <font color="%s">%s</font>
History_RemoveAll                       Alle entfernen
History_RemovePage                      Diese Seite entfernen
History_Remove                          Um Einträge im Verlauf zu löschen, klicken Sie auf
History_SearchMessage                   Nach Absender/Betreff suchen
History_NoMessages                      keine Nachrichten
History_ShowMagnet                      magnetisiert
History_ShowNoMagnet                    unmagnetisiert
History_Magnet                          &nbsp;(zeige nur durch Magnet eingestufte Nachrichten)
History_NoMagnet                        &nbsp;(zeige nicht durch Magnet eingestufte Nachrichten)
History_ResetSearch                     Zurücksetzen

Password_Title                          Paßwort
Password_Enter                          Paßwort eingeben
Password_Go                             Anmelden
Password_Error1                         Falsches Paßwort

Security_Error1                         Der Port muß zwischen 1 und 65535 liegen.
Security_Stealth                        Stealth Modus/Serverbetrieb
Security_NoStealthMode                  Nein (Stealth Modus)
Security_StealthMode                    (Stealth Modus)
Security_ExplainStats                   (Wenn Sie diese Funktion einschalten, sendet POPFile täglich die drei folgenden Werte an ein Skript auf www.usethesource.com: bc (Anzahl von Ihnen eingerichteter Kategorien), mc (Anzahl von POPFile eingestufter Nachrichten) und ec (Anzahl der Einstufungsfehler). Diese werden in einer Datei gespeichert und benutzt, um öffentliche Statistiken darüber zu erstellen, wie POPFile genutzt wird und wie gut es dabei funktioniert. Die Daten werden etwa 5 Tage auf dem Server gespeichert und dann gelöscht. Zuordnungen zwischen IP-Adressen und statistischen Daten werden nicht gespeichert.)
Security_ExplainUpdate                  (Wenn Sie diese Funktion einschalten, sendet POPFile täglich die drei folgenden Werte an ein Skript auf www.usethesource.com: ma (die Hauptversionsnummer der POPFile-Installation), mi (die Nebenversionsnummer der POPFile-Installation) und bn (die build-Nummer der POPFile-Installation). POPFile erhält die Antwort in Form einer Grafik, die am Kopf einer Seite erscheint, wenn eine neue Version verfügbar ist. Die Daten werden etwa 5 Tage auf dem Server gespeichert und dann gelöscht. Zuordnungen zwischen IP-Adressen und statistischen Daten werden nicht gespeichert.)
Security_PasswordTitle                  Paßwort für Benutzeroberfläche
Security_Password                       Paßwort
Security_PasswordUpdate                 Passwort geändert
Security_AUTHTitle                      externe Server
Security_SecureServer                   POP3 SPA/AUTH Server
Security_SecureServerUpdate             Neuer POP3 SPA/AUTH Server: %s - Diese Änderung wird erst nach einem Neustart von POPFile wirksam.
Security_SecurePort                     POP3 SPA/AUTH Port
Security_SecurePortUpdate               Neuer POP3 SPA/AUTH Port %s - Diese Änderung wird erst nach einem Neustart von POPFile wirksam.
Security_SMTPServer                     externer SMTP Server
Security_SMTPServerUpdate               Neuer externer SMTP Server: %s - Diese Änderung wird erst nach einem Neustart von POPFile wirksam.
Security_SMTPPort                       externer SMTP port
Security_SMTPPortUpdate                 Neuer externer SMTP Port: %s - Diese Änderung wird erst nach einem Neustart von POPFile wirksam.
Security_POP3                           POP3 Verbindungen von fremden Rechnern erlauben (erfordert Neustart von POPFile)
Security_SMTP                           SMTP Verbindungen von fremden Rechnern erlauben (erfordert Neustart von POPFILE)
Security_NNTP                           NNTP Verbindungen von fremden Rechnern erlauben (erfordert Neustart von POPFile)
Security_UI                             HTTP (Benutzeroberfläche) Verbindungen von fremden Rechnern erlauben (erfordert Neustart von POPFile)
Security_XMLRPC                         XML-RPC Verbindungen von fremden Rechnern erlauben (erfordert Neustart von POPFile)
Security_UpdateTitle                    Automatisch auf Updates prüfen
Security_Update                         Täglich nach POPFile Updates suchen
Security_StatsTitle                     Statistik Report
Security_Stats                          Täglich Statistiken senden

Magnet_Error1                           Magnet '%s' existiert bereits in Kategorie '%s'
Magnet_Error2                           Neuer Magnet '%s' kollidiert mit Magnet '%s' in Kategorie '%s' und könnte unklare Ergebnisse verursachen. Magnet wurde nicht unzugefügt.
Magnet_Error3                           Erstelle neuen Magnet '%s' in Kategorie '%s'
Magnet_CurrentMagnets                   Aktuelle Magnete
Magnet_Message1                         Die folgenden Magnete ordnen neue Post zwingend in eine angegebene Kategorie ein.
Magnet_CreateNew                        Neuen Magnet erstellen
Magnet_Explanation                      Diese Arten von Magneten sind verfügbar: <ul><li>Absenderadresse oder -name:</b> z.B.: hans@firma.de, um eine bestimmte Adresse zu erfassen, <br />firma.de, um jeden zu erfassen, der von firma.de sendet, <br />Hans Mustermann, um eine bestimmte Person zu erfassen; Hans erfaßt jeden Hans</li><li><b>Empfänger/CC-Adresse oder -Name:</b> Wie beim Absender-Magnet nur für die Empfänger/CC-Adresse der Nachricht.</li><li><b>Wörter im Betreff:</b> z.B.: "Hallo", um alle Nachrichten mit "Hallo" im Betreff zu erfassen</li></ul>
Magnet_MagnetType                       Typ des Magnets
Magnet_Value                            Wert
Magnet_Always                           Immer dieser Kategorie zuordnen
Magnet_Jump                             Gehe zu Magnet Seite

Bucket_Error1                           Kategorienamen können nur Kleinbuchstaben von a bis z, Ziffern von 0 bis 9, - oder _ enthalten
Bucket_Error2                           Kategoriename %s existiert bereits
Bucket_Error3                           Kategorie %s erstellt
Bucket_Error4                           Bitte geben Sie ein nicht-leeres Wort ein
Bucket_Error5                           Kategorie %s in %s umbenannt
Bucket_Error6                           Kategorie %s gelöscht
Bucket_Title                            Kategorien konfigurieren
Bucket_BucketName                       Name der Kategorie
Bucket_WordCount                        Wortanzahl
Bucket_WordCounts                       Wortanzahl
Bucket_UniqueWords                      verschiedene Wörter
Bucket_SubjectModification              Betreffzeile ändern
Bucket_ChangeColor                      Farbe ändern
Bucket_NotEnoughData                    Nicht genügend Daten
Bucket_ClassificationAccuracy           Genauigkeit
Bucket_EmailsClassified                 Nachrichten klassifiziert
Bucket_EmailsClassifiedUpper            Nachrichten klassifiziert
Bucket_ClassificationErrors             Einstufungsfehler
Bucket_Accuracy                         Genauigkeit
Bucket_ClassificationCount              Anzahl Einstufungen
Bucket_ClassificationFP                 fehlerhaft Positive
Bucket_ClassificationFN                 fehlerhaft Negative
Bucket_ResetStatistics                  Statistiken zurücksetzen
Bucket_LastReset                        Läuft seit
Bucket_CurrentColor                     Derzeitige Farbe von %s ist %s
Bucket_SetColorTo                       Setze Farbe von %s auf %s
Bucket_Maintenance                      Verwaltung
Bucket_CreateBucket                     Erstelle Kategorie
Bucket_DeleteBucket                     Lösche Kategorie
Bucket_RenameBucket                     Benenne Kategorie um
Bucket_Lookup                           Nachschlagen
Bucket_LookupMessage                    Wort in Kategorie nachschlagen
Bucket_LookupMessage2                   Ergebnis für
Bucket_LookupMostLikely                 <b>%s</b> erscheint am wahrscheinlichsten in <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> erscheint in keiner Kategorie
Bucket_DisabledGlobally                 Global deaktiviert
Bucket_To                               in
Bucket_Quarantine                       Nachricht in Quarantäne

SingleBucket_Title                      Details für %s
SingleBucket_WordCount                  Anzahl Worte in dieser Kategorie
SingleBucket_TotalWordCount             Anzahl Worte insgesamt
SingleBucket_Percentage                 Anteil an der Gesamtzahl
SingleBucket_WordTable                  Worttabelle für %s
SingleBucket_Message1                   Klicken Sie auf einen Buchstaben, um eine Liste der Wörter aufzurufen, die mit diesem beginnen. Klicken Sie auf ein beliebiges Wort, um die Wahrscheinlichkeit seines Erscheinens für alle Kategorien anzusehen.
SingleBucket_Unique                     %s verschiedene
SingleBucket_ClearBucket                Alle Wörter entfernen

Session_Title                           POPFile Sitzung abgelaufen
Session_Error                           Ihre POPFile-Sitzung ist abgelaufen. Dies könnte dadurch verursacht worden sein, daß Sie POPFile neu gestartet haben, das Kontrollzentrum aber noch im Browser geöffnet war. Bitte klicken Sie auf einen der oben angezeigten Verweise, um mit der Benutzung von POPFile weitermachen zu können.

View_Title                              Nachrichtenansicht
View_ShowFrequencies                    Zeige Häufigkeit des Auftretens
View_ShowProbabilities                  Zeige Wahrscheinlichkeit des Auftretens
View_ShowScores                         Zeige Bewertung des Wortes
View_WordMatrix                         Wort Matrix
View_WordProbabilities                  zeige Wahrscheinlichkeit des Auftretens
View_WordFrequencies                    zeige Häufigkeit des Auftretens
View_WordScores                         zeige Bewertung des Wortes

Windows_TrayIcon                        POPFile-Symbol neben der Uhr anzeigen?
Windows_Console                         POPFile in einem Konsolenfenster ausführen?
Windows_NextTime                        <p><font color="red">Diese Änderung wird erst beim nächsten Start von POPFile wirksam.</font>

Header_MenuSummary                      Diese Tabelle ist das Navigationsmenü, das Zugang zu den einzelnen Bereichen des Kontrollzentrums bietet.
History_MainTableSummary                Diese Tabelle zeigt Absender und Betreff der letzten empfangenen Nachrichten an und ermöglicht es, diese durchzusehen und zu reklassifizieren. Ein Klick auf den Betreff zeigt die vollständige Nachricht an sowie Details, warum diese so und nicht anders klassifiziert wurde. Die Spalte "Sollte sein" ermöglicht es, anzugeben, in welche Kategorie die Nachricht gehört bzw. entsprechende Änderungen rückgängig zu machen. Die Spalte "Delete" ermöglicht es, einzelne Nachrichten aus dem Verlauf zu löschen, falls Sie diese nicht mehr benötigen.
History_OpenMessageSummary              Diese Tabelle enthält den kompletten Text einer Nachricht. Die Wörter sind entsprechend der Kategorie eingefärbt, in die sie am wahrscheinlichsten passen.
Bucket_MainTableSummary                 Diese Tabelle bietet einen Überblick über die einzelnen Kategorien. Jede Reihe zeigt Name, Gesamtzahl der Wörter und die Anzahl verschiedener Wörter pro Kategorie an, ob die Betreff-Zeile der Nachricht bei der Klassifizierung geändert wird, ob die Nachrichten dieser Kategorie in Quarantäne gestellt werden sollen, sowie eine Tabelle zur Auswahl einer Farbe, in der alle zu dieser Kategorie gehörenden Elemente im Kontrollzentrum dargestellt werden sollen.
Bucket_StatisticsTableSummary           Diese Tabelle zeigt drei verschiedene Statistiken bezüglich POPFiles Gesamtleistung an. Die erste: Wie fehlerfrei ist die Einordnung in die entsprechenden Kategorien? Die zweite: Wie viele Nachrichten wurden analysiert und wie wurden sie eingeordnet? Die dritte: Wie viele Wörter gehören zu jeder Kategorie und wie hoch ist der Prozentsatz zur Gesamtzahl?
Bucket_MaintenanceTableSummary          Diese Tabelle enthält Formulare zum Erstellen, Löschen und Umbenennen von Kategorien und um die relative Wahrscheinlichkeit der Wörter in jeder einzelnen Kategorie nachzuschlagen. 
Bucket_AccuracyChartSummary             Diese Tabelle stellt die Genauigkeit der Nachrichten-Sortierung grafisch dar.
Bucket_BarChartSummary                  Diese Tabelle stellt einen Prozentanteil grafisch dar. Sie wird sowohl für die Anzahl der eingestuften Nachrichten als auch für die Gesamtzahl der Wörter genutzt.
Bucket_LookupResultsSummary             Diese Tabelle stellt die Wahrscheinlichkeiten bezüglich jedes angegebenen Wortes dar. Für jede Kategorie wird folgendes angezeigt: Die Häufigkeit, mit der das Wort auftritt, die Wahrscheinlichkeit, daß es in dieser Kategorie auftritt und die Auswirkungen auf die Punktzahl der Kategorie insgesamt, falls das Wort in einer Nachricht auftaucht.
Bucket_WordListTableSummary             Diese Tabelle bietet eine Liste aller Wörter einer bestimmten Kategorie - reihenweise sortiert nach dem ersten Buchstaben.
Magnet_MainTableSummary                 Diese Tabelle zeigt eine Liste der Magnete an, die dazu benutzt werden, um Nachrichten automatisch nach festen Kriterien zu sortieren. Jede Reihe zeigt an, wie der Magnet definiert ist, in welche Kategorie er einsortiert und eine Schaltfläche, um den Magnet zu löschen.
Configuration_MainTableSummary          Diese Tabelle enthält einige Formulare zur Konfiguration von POPFile.
Configuration_InsertionTableSummary     Diese Tabelle enthält Schaltflächen zur Konfiguration, ob bestimmte Änderungen an Kopfzeilen oder Betreff der Nachricht gemacht werden sollen, bevor diese an das entsprechende Programm weitergegeben wird.
Security_MainTableSummary               Diese Tabelle bietet Einstellungsmöglichkeiten, die die Sicherheit von POPFile insgesamt betreffen, ob es automatisch auf neue Versionen prüfen soll oder ob Statistiken über die Leistung von POPFile an eine zentrale Datenbank zwecks der Erstellung von Gesamtstatistiken geschickt werden sollen.
Advanced_MainTableSummary               Diese Tabelle enthält eine Liste von Wörtern, die POPFile ignoriert, wenn es eine Nachricht analysiert. Dies betrifft Wörter, die besonders häufig in Nachrichten auftauchen. Diese sind reihenweise alphabetisch nach dem ersten Buchstaben sortiert.


