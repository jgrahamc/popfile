# Copyright (c) 2001-2003 John Graham-Cumming

# This is used to get the appropriate subdirectory for the manual
LanguageCode                            de
LanguageCharset                         ISO-8859-1

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
Classification                          Einstufung
Reclassify                              Neu einstufen
Undo                                    widerrufen
Close                                   Schließen
Find                                    Suchen
Filter                                  Filter
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
Score                                   Auswertung
Lookup                                  Nachschlagen

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
Footer_FeedMe                           Fütter mich!
Footer_RequestFeature                   Funktionalität vorschlagen
Footer_MailingList                      Mailing Liste

Configuration_Error1                    Das Trennzeichen muß ein einzelnes Zeichen sein.
Configuration_Error2                    Der Port für das Kontrollzentrum muß zwischen 1 und 65535 liegen.
Configuration_Error3                    Der POP3 Port muß zwischen 1 und 65535 liegen.
Configuration_Error4                    Die Seitengröße muß zwischen 1 und 1000 liegen.
Configuration_Error5                    Die Anzahl der Tage im Verlauf muß zwischen 1 und 366 liegen.
Configuration_Error6                    Der TCP Timeout muß zwischen 10 und 300 liegen.
Configuration_POP3Port                  POP3 Port
Configuration_POP3Update                Neuer POP3 Port: %s; Diese Änderung wird erst nach einem Neustart von POPFile wirksam.
Configuration_Separator                 Trennzeichen
Configuration_SepUpdate                 Neues Trennzeichen: %s
Configuration_UI                        Web Port für Kontrollzentrum
Configuration_UIUpdate                  Neuer Web Port für Kontrollzentrum: %s; Dieser Änderung wird erst nach einem Neustart von POPFile wirksam.
Configuration_History                   Anzahl Emails pro Seite
Configuration_HistoryUpdate             Neue Anzahl Emails pro Seite: %s
Configuration_Days                      Emails x Tage im Verlauf speichern
Configuration_DaysUpdate                Emails werden nun %s im Verlauf gespeichert
Configuration_UserInterface             Benutzeroberfläche
Configuration_Skins                     Skins
Configuration_SkinsChoose               Skin auswählen
Configuration_Language                  Sprache
Configuration_LanguageChoose            Sprache auswählen
Configuration_ListenPorts               Porteinstellungen
Configuration_HistoryView               Verlaufsansicht
Configuration_TCPTimeout                TCP Verbindungstimeout
Configuration_TCPTimeoutSecs            TCP Verbindungstimeout in Sekunden
Configuration_TCPTimeoutUpdate          Neuer TCP Verbidungstimeout: %s
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

Advanced_Error1                         '%s' ist bereits in der Liste mit Stop-Wörtern
Advanced_Error2                         Stop-Wörtern können nur alphanumerische, ., _, -, oder @ Zeichen enthalten
Advanced_Error3                         '%s' zu den Stop-Wörtern hinzugefügt
Advanced_Error4                         '%s' ist nicht in der Stop-Wörter-Liste
Advanced_Error5                         '%s' von der Stop-Wörter-Liste hinzugefügt
Advanced_StopWords                      Stop-Wörter
Advanced_Message1                       Die folgenden Wörter werden bei jeder Einstufung ignoriert, da sie sehr häufig auftauchen
Advanced_AddWord                        Wort hinzufügen
Advanced_RemoveWord                     Wort löschen

History_Filter                          &nbsp;(zeige nur Kategorie <font color=%s>%s</font>)
History_Search                          &nbsp;(gesuchter Betreff: %s)
History_Title                           Letzte Nachrichten
History_Jump                            zu Nachricht gehen
History_ShowAll                         Alle anzeigen
History_ShouldBe                        Sollte sein
History_NoFrom                          kein Absender angegeben
History_NoSubject                       kein Betreff
History_ClassifyAs                      eingestuft als
History_MagnetUsed                      Magnet benutzt
History_ChangedTo                       Geändert: <font color=%s>%s
History_Already                         Bereits neu eingestuft als <font color=%s>%s</font>
History_RemoveAll                       Alle entfernen
History_RemovePage                      Diese Seite entfernen
History_Remove                          Um Einträge im Verlauf zu löschen, klicken Sie auf
History_SearchMessage                   Betreff suchen
History_NoMessages                      keine Nachrichten
History_ShowMagnet                      Magnetisiert
History_Magnet                          &nbsp;(zeige nur durch Magnet eingestufte Nachrichten)
History_ResetSearch                     Zurücksetzen

Password_Title                          Paßwort
Password_Enter                          Paßwort eingeben
Password_Go                             Anmelden
Password_Error1                         Falsches Paßwort

Security_Error1                         Der sichere Port muß zwischen 1 und 65535 liegen.
Security_Stealth                        Stealth Modus/Serverbetrieb
Security_NoStealthMode                  Nein (Stealth Modus)
Security_ExplainStats                   (Wenn Sie diese Funktion einschalten, sendet POPFile täglich die drei folgenden Werte an ein Skript auf www.usethesource.com: bc (Anzahl von Ihnen eingerichteter Kategorien), mc (Anzahl von POPFile eingestufter Nachrichten) und ec (Anzahl der Einstufungsfehler). Diese werden in einer Datei gespeichert und benutzt, um öffentliche Statistiken darüber zu erstellen, wie POPFile genutzt wird und wie gut es dabei funktioniert. Die Daten werden etwa 5 Tage auf dem Server gespeichert und dann gelöscht. Zuordnungen zwischen IP-Adressen und statistischen Daten werden nicht gespeichert.)
Security_ExplainUpdate                  (Wenn Sie diese Funktion einschalten, sendet POPFile täglich die drei folgenden Werte an ein Skript auf www.usethesource.com: ma (die Hauptversionsnummer der POPFile-Installation), mi (die Nebenversionsnummer der POPFile-Installation) und bn (die build-Nummer der POPFile-Installation). POPFile erhält die Antwort in Form einer Grafik, die am Kopf einer Seite erscheint, wenn eine neue Version verfügbar ist. Die Daten werden etwa 5 Tage auf dem Server gespeichert und dann gelöscht. Zuordnungen zwischen IP-Adressen und statistischen Daten werden nicht gespeichert.)
Security_PasswordTitle                  Paßwort für Benutzeroberfläche
Security_Password                       Paßwort
Security_PasswordUpdate                 Neues Paßwort: %s
Security_AUTHTitle                      gesicherte Kennwortauthentizierung/AUTH
Security_SecureServer                   gesicherter Server
Security_SecureServerUpdate             Neuer gesicherter Server: %s; Diese Änderung wird erst nach einem Neustart von POPFile wirksam.
Security_SecurePort                     gesicherter Port
Security_SecurePortUpdate               Neuer gesicherter Port %s; Diese Änderung wird erst nach einem Neustart von POPFile wirksam.
Security_POP3                           POP3 Verbindungen von fremden Rechnern erlauben
Security_UI                             HTTP (Benutzeroberfläche) Verbindungen von fremden Rechnern erlauben
Security_UpdateTitle                    Automatisch auf Updates prüfen
Security_Update                         Täglich nach POPFile Updates suchen
Security_StatsTitle                     Statistik Report
Security_Stats                          Täglich Statistiken an John senden

Magnet_Error1                           Magnet '%s' existiert bereits in Kategorie '%s'
Magnet_Error2                           Neuer Magnet '%s' kollidiert mit Magnet '%s' in Kategorie '%s' und könnte unklare Ergebnisse verursachen. Magnet wurde nicht unzugefügt.
Magnet_Error3                           Erstelle neuen Magnet '%s' in Kategorie '%s'
Magnet_CurrentMagnets                   Aktuelle Magnete
Magnet_Message1                         Die folgenden Magnete ordnen neue Post zwingend in eine angegebene Kategorie ein.
Magnet_CreateNew                        Neuen Magnet erstellen
Magnet_Explanation                      Drei Typen von Magneten sind verfügbar: <ul><li>Absenderadresse oder -name:</b> z.B.: hans@firma.de, um eine bestimmte Adresse zu erfassen, <br>firma.de, um jeden zu erfassen, der von firma.de sendet, <br>Hans Mustermann, um eine bestimmte Person zu erfassen; Hans erfaßt jeden Hans<li><b>Empfängeradresse oder -name:</b> Wie beim Absender-Magnet nur für die Empfängeradresse in der Email.<li><b>Wörter im Betreff:</b> z.B.: "Hallo", um alle Nachrichten mit "Hallo" im Betreff zu erfassen</ul>
Magnet_MagnetType                       Typ des Magnets
Magnet_Value                            Wert
Magnet_Always                           Immer dieser Kategorie zuordnen

Bucket_Error1                           Kategorienamen können nur Kleinbuchstaben von a bis z, - oder _ enthalten
Bucket_Error2                           Kategoriename %s existiert bereits
Bucket_Error3                           Kategorie %s erstellt
Bucket_Error4                           Bitte geben Sie ein nicht-leeres Wort ein
Bucket_Error5                           Kategorie %s in %s umbenannt
Bucket_Error6                           Kategorie %s gelöscht
Bucket_Title                            Zusammenfassung
Bucket_BucketName                       Kategoriename
Bucket_WordCount                        Wortanzahl
Bucket_WordCounts                       Wortanzahl
Bucket_UniqueWords                      verschiedene Wörter
Bucket_SubjectModification              Betreff ändern
Bucket_ChangeColor                      Farbe ändern
Bucket_NotEnoughData                    Nicht genügend Daten
Bucket_ClassificationAccuracy           Genauigkeit
Bucket_EmailsClassified                 Emails klassifiziert
Bucket_EmailsClassifiedUpper            Emails klassifiziert
Bucket_ClassificationErrors             Einstufungsfehler
Bucket_Accuracy                         Genauigkeit
Bucket_ClassificationCount              Anzahl Einstufungen
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
Bucket_LookupMostLikely                 <b>%s</b> erscheint am wahrscheinlichsten in <font color=%s>%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> erscheint in keiner Kategorie
Bucket_DisabledGlobally                 Global deaktiviert
Bucket_To                               in
Bucket_Quarantine                       Quarantäne

SingleBucket_Title                      Details für %s
SingleBucket_WordCount                  Anzahl Worte in dieser Kategorie
SingleBucket_TotalWordCount             Anzahl Worte insgesamt
SingleBucket_Percentage                 Anteil an der Gesamtzahl
SingleBucket_WordTable                  Worttabelle für %s
SingleBucket_Message1                   Mit (*) gekennzeichnete Wörter wurden in dieser POPFile Sitzung zur Sortierung benutzt. Klicken Sie auf ein beliebiges Wort, um die Wahrscheinlichkeit seines Erscheinens für alle Kategorien anzusehen.
SingleBucket_Unique                     %s verschiedene

Session_Title                           POPFile Sitzung abgelaufen
Session_Error                           Ihre POPFile-Sitzung ist abgelaufen. Dies könnte dadurch verursacht worden sein, daß Sie POPFile neu gestartet haben, das Kontrollzentrum aber noch im Browser geöffnet war. Bitte klicken Sie auf einen der oben angezeigten Verweise, um mit der Benutzung von POPFile weitermachen zu können.
