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
#   Italian translation thanks to Roberto Inzerillo <robicd_at_gmx_dot_net>
#   Additional Italian contribution (sep-2004) by Paolo De Felice

# Identify the language and character set used for the interface
LanguageCode                            it
LanguageCharset                         ISO-8859-1
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en

# This is where to find the FAQ on the Wiki
FAQLink                                 FrequentlyAskedQuestions

# Common words that are used on their own all over the interface
Apply                                   Applica
On                                      Attivato
Off                                     Disattivato
TurnOn                                  Attiva
TurnOff                                 Disattiva
Add                                     Aggiungi
Remove                                  Rimuovi
Previous                                Precedente
Next                                    Successivo
From                                    Mittente
Subject                                 Oggetto
Cc                                      Cc
Classification                          Classificazione
Reclassify                              Riclassifica
Probability                             Probabilit&agrave;
Scores                                  Punteggi
QuickMagnets                            QuickMagnets
Undo                                    Annulla
Close                                   Chiudi
Find                                    Cerca
Filter                                  Filtro
Yes                                     Si
No                                      No
ChangeToYes                             Cambia in Si
ChangeToNo                              Cambia in No
Bucket                                  Cesto
Magnet                                  Magnete
Delete                                  Cancella
Create                                  Crea
To                                      Destinatario
Total                                   Totale
Rename                                  Rinomina
Frequency                               Frequenza
Probability                             Probabilit&agrave;
Score                                   Punteggio
Lookup                                  Analisi
Word                                    Parola
Count                                   Conteggio
Update                                  Aggiorna
Refresh                                 Ricarica
Arrived                                 Ricevuto
FAQ                                     FAQ
ID                                      ID
Date                                    Data
Size                                    Dimensione

# This is a regular expression pattern that is used to convert
# a number into a friendly looking number (for the US and UK this
# means comma separated at the thousands)

Locale_Thousands                       .
Locale_Decimal                         ,

# The Locale_Date uses the format strings in Perl's Date::Format
# module to set the date format for the UI.  There are two possible
# ways to specify it.
#
# <format>            Just one simple format used for all dates
# <<format> | <format> The first format is used for dates less than
#                     7 days from now, the second for all other dates

Locale_Date                            %a %R | %D %R

# The header and footer that appear on every UI page
Header_Title                            Centro di Controllo di POPFile
Header_Shutdown                         Spegni POPFile
Header_History                          Storico
Header_Buckets                          Cesti
Header_Configuration                    Configurazione
Header_Advanced                         Avanzate
Header_Security                         Sicurezza
Header_Magnets                          Magneti

Footer_HomePage                         Home Page di POPFile
Footer_Manual                           Manuale
Footer_Forums                           Forum di discussione
Footer_FeedMe                           Donazioni
Footer_RequestFeature                   Richiedi nuove caratteristiche
Footer_MailingList                      Mailing List
Footer_Wiki                             Documentazione

Configuration_Error1                    Il carattere di separazione deve essere un solo carattere
Configuration_Error2                    La porta per l'interfaccia utente deve essere un numero compreso tra 1 e 65535
Configuration_Error3                    La porta per il POP3 deve essere un numero compreso tra 1 e 65535
Configuration_Error4                    La dimensione della pagina deve essere un numero compreso tra 1 e 1000
Configuration_Error5                    Il numero di giorni nello storico deve essere un numero tra 1 e 366
Configuration_Error6                    Il timeout TCP deve essere un numero tra 10 e 300
Configuration_Error7                    La porta per l'XML-RPC deve essere un numero compreso tra 1 e 65535
Configuration_Error8                    La porta proxy SOCKS V deve essere un numero compreso tra 1 e 65535
Configuration_POP3Port                  Porta POP3
Configuration_POP3Update                Porta POP3 impostata a %s; questo cambiamento avr&agrave; effetto dopo il riavvio POPFile
Configuration_XMLRPCUpdate              Porta XML-RPC impostata a %s; questo cambiamento avr&agrave; effetto dopo il riavvio POPFile
Configuration_XMLRPCPort                Porta XML-RPC
Configuration_SMTPPort                  Porta SMTP
Configuration_SMTPUpdate                Porta SMTP impostata a %s; questo cambiamento avr&agrave; effetto dopo il riavvio POPFile
Configuration_NNTPPort                  Porta NNTP
Configuration_NNTPUpdate                Porta NNTP impostata a %s; questo cambiamento avr&agrave; effetto dopo il riavvio POPFile
Configuration_POPFork                   Abilita connessioni POP3 contemporanee
Configuration_SMTPFork                  Abilita connessioni SMTP contemporanee
Configuration_NNTPFork                  Abilita connessioni NNTP contemporanee
Configuration_POP3Separator             Carattere di separazione per POP3 host:porta:utente
Configuration_NNTPSeparator             Carattere di separazione per NNTP host:porta:utente
Configuration_POP3SepUpdate             Separatore di POP3 impostatato a %s
Configuration_NNTPSepUpdate             Separatore di NNTP impostatato a %s
Configuration_UI                        Porta dell'interfaccia utente web
Configuration_UIUpdate                  Porta dell'interfaccia utente web impostata a %s; questo cambiamento avr&agrave; effetto dopo il riavvio di POPFile
Configuration_History                   Numero di email per pagina
Configuration_HistoryUpdate             Numero di email per pagina impostato a %s
Configuration_Days                      Numero di giorni dello storico da conservare
Configuration_DaysUpdate                Numero di giorni dello storico impostato a %s
Configuration_UserInterface             Interfaccia utente
Configuration_Skins                     Aspetto
Configuration_SkinsChoose               Scegli l'aspetto
Configuration_Language                  Lingua
Configuration_LanguageChoose            Scegli la lingua
Configuration_ListenPorts               Opzioni di modulo
Configuration_HistoryView               Vedi lo storico
Configuration_TCPTimeout                Timeout della connessione TCP
Configuration_TCPTimeoutSecs            Timeout della connessione TCP in secondi
Configuration_TCPTimeoutUpdate          Timeout della connessione TCP impostato a %s
Configuration_ClassificationInsertion   Inserimento di testo nell'E-Mail
Configuration_SubjectLine               Aggiungi classificazione all'Oggetto
Configuration_XTCInsertion              X-Text-Classification Header
Configuration_XPLInsertion              X-POPFile-Link Header
Configuration_Logging                   Logging
Configuration_None                      Nessuno
Configuration_ToScreen                  A schermo
Configuration_ToFile                    Su file
Configuration_ToScreenFile              A schermo e su file
Configuration_LoggerOutput              Output del logger
Configuration_GeneralSkins              Skin
Configuration_SmallSkins                Skin piccoli
Configuration_TinySkins                 Skin minuscoli
Configuration_CurrentLogFile            &lt;log file corrente&gt;
Configuration_SOCKSServer               Host proxy SOCKS V
Configuration_SOCKSPort                 Porta proxy SOCKS V
Configuration_SOCKSPortUpdate           Porta proxy SOCKS V impostata a %s
Configuration_SOCKSServerUpdate         Host proxy SOCKS V impostato a %s
Configuration_Fields                    Colonne dello storico

Advanced_Error1                         '%s' &egrave; gi&agrave; nella lista delle parole ignorate
Advanced_Error2                         Le parole da ignorare possono contenere solo caratteri alfanumerici, ., _, -, o il carattere @
Advanced_Error3                         '%s' aggiunto alla lista di parole ignorate
Advanced_Error4                         '%s' non &egrave; nella lista delle parole ignorate
Advanced_Error5                         '%s' rimosso dalla lista delle parole ignorate
Advanced_StopWords                      Parole ignorate
Advanced_Message1                       POPFile ignora le seguenti parole di uso comune:
Advanced_AddWord                        Aggiungi parola
Advanced_RemoveWord                     Rimuovi parola
Advanced_AllParameters                  Tutti i parametri di POPFile
Advanced_Parameter                      Parametri
Advanced_Value                          Valore
Advanced_Warning                        Questa &egrave; la lista completa dei parametri di POPFile.  Solo per utenti esperti: puoi modificarli tutti e cliccare su Aggiorna; non c'&egrave; alcun controllo sulla loro validit&agrave;.
Advanced_ConfigFile                     file di configurazione:

History_Filter                          &nbsp;(mostro solo il cesto <font color="%s">%s</font>)
History_FilterBy                        Filtra per
History_Search                          &nbsp;(ricerca di %s nel Mittente/Oggetto)
History_Title                           Messaggi recenti
History_Jump                            Salta al messaggio
History_ShowAll                         Mostra tutti
History_ShouldBe                        Dovrebbe essere
History_NoFrom                          Mittente assente
History_NoSubject                       Oggetto assente
History_ClassifyAs                      Classifica come
History_MagnetUsed                      Magnete usato
History_MagnetBecause                   <b>Magnete usato</b><p>Classificato come <font color="%s">%s</font> a causa del magnete %s </p>
History_ChangedTo                       Cambiato in <font color="%s">%s
History_Already                         Gi&agrave; riclassificato come <font color="%s">%s</font>
History_RemoveAll                       Rimuovi tutti
History_RemovePage                      Rimuovi pagina
History_Remove                          Per rimuovere le voci nello storico clicca
History_SearchMessage                   cerca Mittente/Oggetto
History_NoMessages                      Nessun messaggio
History_ShowMagnet                      magnetizza
History_Magnet                          &nbsp;(mostro solo i messaggi classificati per magnetismo)
History_NoMagnet                        &nbsp;(mostro solo i messaggi non classificati per magnetismo)
History_ResetSearch                     Resetta
History_Automatic                       Automatico
History_ChangedClass                    Sar&agrave; riclassificato come
History_Column_Characters               Cambia larghezza delle colonne Da, A, Cc e Oggetto
History_Increase                        Incrementa
History_Decrease                        Decrementa
History_Negate_Search                   Inverti cerca/filtro
History_Purge                           Elimina ora
History_Reclassified                    Riclassificato
History_RemoveChecked                   Rimuovi attivato
History_Size_Bytes                      %d&nbsp;B
History_Size_KiloBytes                  %.1f&nbsp;KB
History_Size_MegaBytes                  %.1f&nbsp;MB

Password_Title                          Password
Password_Enter                          Inserisci la password
Password_Go                             Vai!
Password_Error1                         Password non corretta

Security_Error1                         La porta sicura deve essere un numero tra 1 e 65535
Security_Stealth                        Modalit&agrave; stealth/Server Operation
Security_NoStealthMode                  No (Modalit&agrave; Stealth)
Security_StealthMode                    (Modalit&agrave; Stealth)
Security_ExplainStats                   (Attivando questo flag POPFile spedisce una volta al giorno i seguenti tre valori ad uno script su www.usethesource.com: bc (il numero totale di cesti che hai), mc (il numero totale di messaggi che POPFile ha classificato) ed ec (il numero totale di errori di classificazione).  Questi valori vengono conservati in un file e ne far&ograve; uso per pubblicare delle statistiche su come la gente usa POPFile e su come funziona.  Il mio server web conserva questi file di log per circa 5 giorni e poi vengono cancellati; non traccio alcuna connessione tra le statistiche e gli IP individuali.)
Security_ExplainUpdate                  (Attivando questo flag POPFile spedisce una volta al giorno i seguenti tre valori ad uno script su www.usethesource.com: ma (il major version number del POPFile che hai installato), mi (il minor version number del POPFile che hai installato) e bn (il build number del POPFile che hai installato).  POPFile ne ottiene una risposta nella forma di un grafico che appare nella parte alta della pagina allorquando una nuova versione si renda disponibile.  Il mio server web conserva questi file di log per circa 5 giorni e poi vengono cancellati; non conservo alcun dato sulla connessione tra i controlli di aggiornamenti e gli IP individuali.)
Security_PasswordTitle                  Password dell'Interfaccia Utente
Security_Password                       Password
Security_PasswordUpdate                 Password modifica in %s
Security_AUTHTitle                      Autenticazione sicura con password/AUTH
Security_SecureServer                   Server sicuro
Security_SecureServerUpdate             Server sicuro impostato a %s; questo cambiamento avr&agrave; effetto dopo il riavvio POPFile
Security_SecurePort                     Porta sicura
Security_SecurePortUpdate               Porta impostata a %s; questo cambiamento avr&agrave; effetto solo dopo aver riavviato POPFile
Security_SMTPServer                     Server SMTP concatenato
Security_SMTPServerUpdate               Server SMTP concatenato impostato a %s; questo cambiamento avr&agrave; effetto solo dopo aver riavviato POPFile
Security_SMTPPort                       porta SMTP concatenata
Security_SMTPPortUpdate                 porta SMTP concatenata impostata a %s; questo cambiamento avr&agrave; effetto solo dopo aver riavviato POPFile
Security_POP3                           Accetta connessioni POP3 da computer remoti (&egrave; necessario riavviare POPFile)
Security_SMTP                           Accetta connessioni SMTP da computer remoti (&egrave; necessario riavviare POPFile)
Security_NNTP                           Accetta connessioni NNTP da computer remoti (&egrave; necessario riavviare POPFile)
Security_UI                             Accetta connessioni HTTP (Interfaccia Utente) da computer remoti (&egrave; necessario riavviare POPFile)
Security_XMLRPC                         Accetta connessioni XML-RPC da computer remoti (&egrave; necessario riavviare POPFile)
Security_UpdateTitle                    Verifica automatica degli aggiornamenti
Security_Update                         Verifica quotidianamente se esistono aggiornamenti di POPFile
Security_StatsTitle                     Spedizione delle statistiche
Security_Stats                          Spedisci quotidianamente le statistiche

Magnet_Error1                           Il magnete '%s' esiste gi&agrave; nel cesto '%s'
Magnet_Error2                           Il nuovo magnete '%s' contrasta con il magnete '%s' nel cesto '%s' e pu&ograve; risultati ambigui.  Il nuovo magnete non &egrave; stato aggiunto.
Magnet_Error3                           Creato il nuovo magnete '%s' per il cesto '%s'
Magnet_CurrentMagnets                   Magneti correnti
Magnet_Message1                         I magneti che seguono fanno s&igrave; che l'email venga sempre classificata nel cesto specificato.
Magnet_CreateNew                        Crea un nuovo magnete
Magnet_Explanation                      Sono disponibili i seguenti tipi di magnete:</b> <ul><li><b>Indirizzo o nome del Mittente:</b> Ad es.: john@company.com per individuare un indirizzo specifico, <br />company.com per individuare chiunque spedisca dal dominio company.com, <br />John Doe per individuare una persona specifica, John per individuare tutti i John</li><li><b>Indirizzo o nome di un Destinatario/Cc:</b> Funziona come il magnete sul Mittente ma con l'indirizzo del Destinatario/Cc</li> <li><b>Parole nell'Oggetto:</b> Ad es.: ciao per individuare tutti i messaggi con la parola ciao nell'oggetto</li></ul>
Magnet_MagnetType                       Tipo di magnete
Magnet_Value                            Valore
Magnet_Always                           Va sempre nel cesto
Magnet_Jump                             Vai alla pagina dei magneti

Bucket_Error1                           I nomi dei cesti possono contenere solo lettere minuscole dalla a alla z ed i segni - e _
Bucket_Error2                           Esiste gi&agrave; un cesto di nome %s
Bucket_Error3                           &Egrave; stato creato un cesto di nome %s
Bucket_Error4                           Inserisci una parola di almeno una lettera
Bucket_Error5                           Cesto %s rinominato in %s
Bucket_Error6                           Cesto %s cancellato
Bucket_Title                            Sommario
Bucket_BucketName                       Nome del cesto
Bucket_WordCount                        Numero di parole
Bucket_WordCounts                       Conteggio delle parole
Bucket_UniqueWords                      Parole uniche
Bucket_SubjectModification              Aggiungi classificazione all'Oggetto
Bucket_ChangeColor                      Cambia il colore
Bucket_NotEnoughData                    Dati non sufficienti
Bucket_ClassificationAccuracy           Accuratezza della classificazione
Bucket_EmailsClassified                 Email classificate
Bucket_EmailsClassifiedUpper            Email Classificate
Bucket_ClassificationErrors             Errori di classificazione
Bucket_Accuracy                         Accuratezza
Bucket_ClassificationCount              Conteggio della classificazione
Bucket_ClassificationFP                 Falsi Positivi
Bucket_ClassificationFN                 Falsi Negativi
Bucket_ResetStatistics                  Azzera le statistiche
Bucket_LastReset                        Ultimo azzeramento
Bucket_CurrentColor                     il colore corrente di %s &egrave; %s
Bucket_SetColorTo                       Colora %s di %s
Bucket_Maintenance                      Manutenzione
Bucket_CreateBucket                     Crea un cesto di nome
Bucket_DeleteBucket                     Elimina il cesto chiamato
Bucket_RenameBucket                     Rinomina il cesto chiamato
Bucket_Lookup                           Analisi
Bucket_LookupMessage                    Parola da analizzare nei cesti
Bucket_LookupMessage2                   Risultato dell'analisi della parola
Bucket_LookupMostLikely                 La parola <b>%s</b> generalmente appare in <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> non appare in alcun cesto
Bucket_DisabledGlobally                 Disabilitato globalmente
Bucket_To                               in
Bucket_Quarantine                       Quarantena

SingleBucket_Title                      Dettagli di %s
SingleBucket_WordCount                  Numero di parole nel cesto
SingleBucket_TotalWordCount             Numero totale di parole
SingleBucket_Percentage                 Percentuale rispetto al totale
SingleBucket_WordTable                  Tabella delle parole per %s
SingleBucket_Message1                   Le parole contrassegnate con l'asterisco (*) sono usate per la classificazione in questa sessione di POPFile. Clicca su una parola per vedere la sua probabilit&agrave; rispetto a tutti i cesti.
SingleBucket_Unique                     %s uniche
SingleBucket_ClearBucket                Rimuovi tutte le parole

Session_Title                           Sessione POPFile chiusa
Session_Error                           La tua sessione con POPFile &egrave; scaduta. Questo pu&ograve; accadere interrompendo e rieseguendo POPFile senza aver prima chiuso il browser web.  Clicca su uno dei link di questa pagina per continuare ad usare POPFile.

View_Title                              Mostra il singolo messaggio
View_ShowFrequencies                    Mostra la frequenza della parola
View_ShowProbabilities                  Mostra le probabilit&agrave; della parola
View_ShowScores                         Mostra i punteggi della parola
View_WordMatrix                         Matrice delle parole
View_WordProbabilities                  mostro le probabilit&agrave; della parola
View_WordFrequencies                    mostro le frequenze della parola
View_WordScores                         mostro i punteggi della parola
View_Chart                              Diagramma delle decisioni

Windows_TrayIcon                        Mostrare l'icona di POPFile nel system tray di Windows?
Windows_Console                         Eseguire POPFile in console?
Windows_NextTime                        <p><font color="red">Questa modifica avr&agrave; effetto solo dopo avere riavviato POPFile</font>

Header_MenuSummary                      Questa tabella &egrave; il menu di navigazione che consente l'accesso ad ogni pagina del centro di controllo.
History_MainTableSummary                Questa tabella mostra i mittenti e l'oggetto dei messaggi ricevuti di recente e permette di consultarli e di riclassificarli.  Cliccando sull'oggetto viene mostrato l'intero testo del messaggio, insieme con altre informazioni sul perch&egrave; &egrave; stato classificato cos&igrave;. La colonna 'Dovrebbe essere' ti permette di specificare a quale cesto appartiene il messaggio oppure di annullare il cambiamento.  La colonna 'Elimina' ti permette di cancellare un messaggio dallo storico allorquando non serva pi&ugrave;.
History_OpenMessageSummary              Questa tabella contiene l'intero testo di un messaggio e mette in evidenza le parole che sono state usate per la classificazione in base al cesto che gli &egrave; pi&ugrave; pertinente.
Bucket_MainTableSummary                 Questa tabella fornisce un resoconto dei cesti per le classificazioni. Ogni riga mostra il nome del cesto, il numero totale di parole per quel cesto, il numero delle singole parole in ciascun cesto, se l'oggetto dell'email viene modificato al momento della classificazione in quel cesto, we il messaggio viene messo in quarantena in quel cesto e una tabella per scegliere il colore da usare per mostrare tutto ci&ograve; che &egrave; pertinente a quel cesto nel centro di controllo.
Bucket_StatisticsTableSummary           Questa tabella mette a disposizione tre gruppi di statistiche sulle performance generali di POPFile.  La prima indicazione l'accuratezza della sua classificazione, la seconda indica quante email sono state classificate e verso quale cesto, la terza indica quante parole sono presenti in ciascun cesto e qual'&egrave; la loro percentuale relativa.
Bucket_MaintenanceTableSummary          Questa tabella contiene delle form che ti permettono di creare, cancellare, rinominare i cesti e cercare una parola in tutti i cesti per vedere la sua probabilit&agrave; relativa.
Bucket_AccuracyChartSummary             Questa tabella rappresenta graficamente l'accuratezza della classificazione dell'email.
Bucket_BarChartSummary                  Questa tabella rappresenta graficamente la distribuzione percentuale per ciascun cesto.  Viene usata sia per il numero di email classificate che per il conteggio totale delle parole.
Bucket_LookupResultsSummary             Questa tabella mostra la probabilit&agrave; associata a ciascuna parola del corpo.  Mostra, per ogni cesto, la frequenza con cui ogni parola si presenta, la probabilit&agrave; che la parola si presenti in quel cesto, e l'effetto finale sul punteggio del cesto allorquando quella parola esista nell'email.
Bucket_WordListTableSummary             Questa tabella fornisce un elenco di tutte le parole in un cesto in particolare, ordinate secondo la prima lettera per ogni riga.
Magnet_MainTableSummary                 Questa tabella mostra l'elenco di magneti usati per classificare le email in base a delle regole fisse. Ogni riga mostra la definizione del magnete, a quale cesto &egrave; collegato ed un bottone per cancellarlo.
Configuration_MainTableSummary          Questa tabella contiene alcune form per controllare la configurazione di POPFile.
Configuration_InsertionTableSummary     Questa tabella contiene dei bottoni per determinare se applicare delle modifiche alla riga dell'oggetto dell'email prima di passarla al client di posta o no.
Security_MainTableSummary               Questa tabella rende disponibile un set di controlli che influiscono sulla sicurezza di tutta la configurazione di POPFile, per stabilire se si vuole verificare automaticamente la presenza di aggiornamenti al programma e se si vogliono spedire le statistiche sulle performance di POPFile al centro dati dell'autore del programma come informazioni generali.
Advanced_MainTableSummary               Questa tabella fornisce un elenco di parole che POPFile ignora al momento della classificazione delle email a causa della loro frequenza relativa nelle email in generale.  Sono organizzate per righe in base alla prima lettera di ciascuna parola.

Imap_Bucket2Folder                      Mail per il cesto <b>%s</b> va alla cartella
Imap_MapError                           Non puoi mappare pi&ugrave; di un cesto ad una singola cartella!
Imap_Server                             hostname del server IMAP:
Imap_ServerNameError                    Inserisci l'hostname del server!
Imap_Port                               Porta del server IMAP:
Imap_PortError                          Inserisci un numero di porta valido!
Imap_Login                              Login dell'account IMAP:
Imap_LoginError                         Inserisci uno username per il logim!
Imap_Password                           Password per l'account IMAP:
Imap_PasswordError                      Inserisci una password per il server!
Imap_Expunge                            Elimina messaggi contrassegnati per la cancellazione dalle cartelle sotto controllo.
Imap_Interval                           Intervallo di aggiornamento in secondi:
Imap_IntervalError                      Inserisci un intervallo tra 10 e 3600 secondi.
Imap_Bytelimit                          Byte per messaggio da usare per la classificazione. Inserisci 0 (Null) per il messaggio completo:
Imap_BytelimitError                     Inserisci un numero.
Imap_RefreshFolders                     Aggiorna lista delle cartelle
Imap_Now                                ora!
Imap_UpdateError1                       Login non riuscito. Verifica il nome per il login e la password.
Imap_UpdateError2                       Connessione al server fallita. Controlla il nome dell'host e la porta ed assicurati di essere online.
Imap_UpdateError3                       Configura prima i dettagli di connessione.
Imap_NoConnectionMessage                Configura prima i dettagli di connessione. Fatto ci&ograve;, questa pagina mostrerà altre opzioni.
Imap_WatchMore                          una cartella ad una lista di cartelle sotto controllo
Imap_WatchedFolder                      Sotto controllo cartella numero

Shutdown_Message                        POPFile &egrave; stato disattivato

Help_Training                           Quando usi POPFile per la prima volta, non sa niente e necessita di addestramento. POPFile ha bisogno di essere 'allenato' sui messaggi nei vari cesti, l'allenamento si ha quando riclassifichi nel cesto appropriato un messaggio che POPFile ha classificato male. Devi anche settare il tuo client di posta elettronica in modo che filtri i messaggi secondo la classificazione fatta da POPFile. Trovi informazioni su come settare il tuo programma di posta elettronica all'indirizzo <a href="http://popfile.sourceforge.net/cgi-bin/wiki.pl?FrequentlyAskedQuestions/EmailSorting">POPFile Documentation Project</a>.
Help_Bucket_Setup                       POPFile richiede che ci siano almeno due cesti oltre allo pseudo-cesto 'unclassified'. Quel che rende POPFile unico &egrave; che pu&ograve; classificare email distribuendole in un numero qualunque di cesti. Un setup semplice pu&ograve; prevedere i cesti "spam", "personale", and a "lavoro" bucket.
Help_No_More                            Non mostrare pi&ugrave;
