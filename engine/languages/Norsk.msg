# Copyright (c) 2001-2003 John Graham-Cumming

# This is used to get the appropriate subdirectory for the manual
LanguageCode                            no
LanguageCharset                         ISO-8859-1

# Common words that are used on their own all over the interface
Apply                                   Bruk
On                                      På
Off                                     Av
TurnOn                                  Slå på
TurnOff                                 Slå av
Add                                     Legg til
Remove                                  Fjern
Previous                                Forrige
Next                                    Neste
>From                                    Fra
Subject                                 Emne
Classification                          Klassifisering
Reclassify                              Re-klassifisering
Undo                                    Angre
Close                                   Lukk
Find                                    Søk
Filter                                  Filtrer
Yes                                     Ja
No                                      Nei
ChangeToYes                             Skift til Ja
ChangeToNo                              Skift til Nei
Bucket                                  Bøtte
Magnet                                  Magnet
Delete                                  Slett
Create                                  Opprett
To                                      Til
Total                                   Total
Rename                                  Omdøp
Frequency                               Frekvens
Probability                             Sannsynlighet
Score                                   Resultat
Lookup                                  Søk etter

# The header and footer that appear on every UI page
Header_Title                            POPFile Kontrollsenter
Header_Shutdown                         Lukk POPFile
Header_History                          Logg
Header_Buckets                          Bøtter
Header_Configuration                    Konfigurering
Header_Advanced                         Avansert
Header_Security                         Sikkerhet
Header_Magnets                          Magneter

Footer_HomePage                         POPFile Hjemmeside
Footer_Manual                           Manual
Footer_Forums                           Diskusjonsforum
Footer_FeedMe                           Mat meg!
Footer_RequestFeature                   Etterspør funksjoner
Footer_MailingList                      Mailingliste

Configuration_Error1                    Skilletegnet skal være ett enkelt tegn
Configuration_Error2                    Brukergrensesnittets port skal være et nummer mellom 1 og 65535
Configuration_Error3                    POP3-porten skal være et nummer mellom 1 og 65535
Configuration_Error4                    Sidens størrelse skal være mellom 1 og 1000
Configuration_Error5                    Antall dager i loggen skal være et tall mellom 1 og 366
Configuration_Error6                    TCP-tidsavbrudd skal være et tall mellom 10 og 300
Configuration_POP3Port                  POP3-porten
Configuration_POP3Update                Oppdaterte porten til %s; Denne endringen vil ikke tre i kraft før POPFile er startet på nytt
Configuration_Separator                 Skilletegn
Configuration_SepUpdate                 Oppdaterte skilletegnet til %s
Configuration_UI                        Brukergrensesnittets web-port
Configuration_UIUpdate                  Oppdaterte Brukergrensesnittets web-port til %s; endringen vil ikke tre i kraft før POPFile startes på nytt
Configuration_History                   Antall e-post pr. side
Configuration_HistoryUpdate             Oppdaterte antall e-post pr. side til %s
Configuration_Days                      Antall dager oppføringer i loggen skal beholdes
Configuration_DaysUpdate                Oppdaterte antall dager oppføringer i loggen skal beholdes til %s
Configuration_UserInterface             Brukergrensesnittet
Configuration_Skins                     Skins
Configuration_SkinsChoose               Velg skin
Configuration_Language                  Språk
Configuration_LanguageChoose            Velg språk
Configuration_ListenPorts               POP3-porten
Configuration_HistoryView               Logg-visning
Configuration_TCPTimeout                TCP-forbindelsens tidsavbrudd
Configuration_TCPTimeoutSecs            TCP-forbindelsens tidsavbrudd i sekunder
Configuration_TCPTimeoutUpdate          Oppdaterte TCP-forbindelsens tidsavbrudd til %s
Configuration_ClassificationInsertion   Klassifikasjonsmåter (innsetting)
Configuration_SubjectLine               Emnelinje-innsetting
Configuration_XTCInsertion              X-Text-Classification innsetting
Configuration_XPLInsertion              X-POPFile-Link innsetting
Configuration_Logging                   Logging
Configuration_None                      Ingen
Configuration_ToScreen                  Til Skjerm
Configuration_ToFile                    Til Fil
Configuration_ToScreenFile              Til Skjerm og Fil
Configuration_LoggerOutput              Logger output

Advanced_Error1                         '%s' Er allerede i Stoppordlisten
Advanced_Error2                         Stoppord kan kun inneholde Alfanumeriske tegn, ., _, -, eller @ tegn
Advanced_Error3                         '%s' er lagt til i stoppordlisten
Advanced_Error4                         '%s' er ikke i stoppordlisten
Advanced_Error5                         '%s' er fjernet fra stoppordlisten
Advanced_StopWords                      Stoppord
Advanced_Message1                       Disse ordene blir ignorert fra all klassifisering fordi de forekommer meget ofte.
Advanced_AddWord                        Legg til ord
Advanced_RemoveWord                     Fjern ord

History_Filter                          &nbsp;(vis kun bøtten<font color=%s>%s</font>)
History_Search                          &nbsp;(søk emne for %s)
History_Title                           Siste meldinger
History_Jump                            Hopp til melding
History_ShowAll                         Vis alle
History_ShouldBe                        Skulle være
History_NoFrom                          ingen Fra-linje
History_NoSubject                       ingen Emne-linje
History_ClassifyAs                      klassifisert som
History_MagnetUsed                      Magnet brukt
History_ChangedTo                       Endret til <font color=%s>%s
History_Already                         Re-klassifisert som <font color=%s>%s</font>
History_RemoveAll                       Fjern alle
History_RemovePage                      Fjern side
History_Remove                          For å fjerne oppføringer i loggen, klikk
History_SearchMessage                   Søk Emne
History_NoMessages                      Ingen meldinger

Password_Title                          Passord
Password_Enter                          Skriv inn passord
Password_Go                             OK!
Password_Error1                         Feil passord

Security_Error1                         Den sikre porten skal være et tall mellom 1 og 65535
Security_Stealth                        Stealth Mode/Server Operation
Security_NoStealthMode                  Nei (Stealth Mode)
Security_ExplainStats                   (Denne funksjonen sender en gang per dag de etterfølgene tre verdiene til et script hos wwwu.sethesource.com: bc (det totale antall bøtter du har) mc (det totale antall i meldinger som POPFile har klassifisert ) og ec (det totale antall klassifiseringsfeil). Disse blir lageret i en fil og jeg vil bruke disse data til å offentligjøre statistikk omkring hvordan folk bruker POPFile og hvor godt POPFile virker. Min web-server beholder denne log-filen omtrent 5 dager og blir så slettet; Jeg lagrer ingen forbindelse mellom statistikken og individuelle IP-adresser.)
Security_ExplainUpdate                  (Denne funksjonen sender en gang per dag de  etterfølgene tre verdiene til et script hos wwwu.sethesource.com: ma (hovedversjonsnummeret på din installerte POPFile), mi (under-versjonsnummeret på din installerte POPFile) og bn (build nummer på din installerte POPFile). POPFile mottar et svar i form av et stykke grafikk som vises i toppen av siden, hvis en ny version er tilgjengelig. Min web-server tar vare på denne log-filen omtrent 5 dager og de blir så slettet; Jeg lagrer ingen forbindelse mellom statistikken og individuelle IP-adresser.)
Security_PasswordTitle                  Brukergrensesnittets Passord
Security_Password                       Passord
Security_PasswordUpdate                 Oppdater passord til %s
Security_AUTHTitle                      Godkjenning av sikkert passord
Security_SecureServer                   Sikker Server
Security_SecureServerUpdate             Opdaterte sikker server til %s; denne endringen vil ikke tre i kraft før omstart av POPFile
Security_SecurePort                     Sikker port
Security_SecurePortUpdate               Opdaterte porten til %s; denne endringen vil ikke tre i kraft før omstart av POPFile
Security_POP3                           Godta POP3-tilkoblinger fra andre maskiner
Security_UI                             Godta HTTP (Brukergrensesnitt) tilkoblinger fra andre maskiner
Security_UpdateTitle                    Automatisk Oppdaterings-kontroll
Security_Update                         Kontroller daglig om det finnes oppdateringer til POPFile
Security_StatsTitle                     Statistikk-rapportering
Security_Stats                          Send statistikk tilbake til John daglig

Magnet_Error1                           Magneten '%s' finnes allrede i bøtten'%s' 
Magnet_Error2                           Den nye magneten '%s' er i konflikt med magneten '%s' i bøtten '%s' og kan gi flertydige resultater. Den nye magneten ble ikke tilføyd.
Magnet_Error3                           Opprettet den nye magneten '%s' i bøtten '%s'
Magnet_CurrentMagnets                   Nåværende Magneter
Magnet_Message1                         De følgende magnetene gjør at e-post alltid blir klassifisert til den spesifiserte bøtten.
Magnet_CreateNew                        Opprett Ny Magnet
Magnet_Explanation                      Tre typer magneter er anbefalt: <ul><li>Fra adressen eller navn:</b> For eksempel: john@firma.dk for å matche en spesifikk adresse, <br>firma.dk for å matche alle som sender fra firma.dk, <br>John Doe for å matche en spesifikk person, John for å matche alle John'er<li><b>Til adresse eller navn:</b> Samme som en Fra: Magnet men bare for Til: Adressen i en e-post<li><b>Emne-ord:</b> For eksempel: hei for å matche alle meldinger med ordet hei i emnet</ul>
Magnet_MagnetType                       Magnettyper
Magnet_Value                            Verdier
Magnet_Always                           Tilhører alltid bøtten

Bucket_Error1                           Bøttenes navn kan kun inneholde bokstavene a til z med små bokstaver, samt - og _
Bucket_Error2                           Bøtten med navnet %s eksisterer allerede
Bucket_Error3                           Opprett bøtten med navnet %s
Bucket_Error4                           Skriv venligst ikke et tomt ord
Bucket_Error5                           Omdøp bøtten %s til %s
Bucket_Error6                           Slett bøtten %s
Bucket_Title                            Oversikt
Bucket_BucketName                       Bøttenes navn
Bucket_WordCount                        Ordtelling
Bucket_WordCounts                       Ordfordeling
Bucket_UniqueWords                      Unike ord
Bucket_SubjectModification              Emne-modifisering
Bucket_ChangeColor                      Skift farge
Bucket_NotEnoughData                    Ikke nok data
Bucket_ClassificationAccuracy           Klassifikasjons-nøyaktighet
Bucket_EmailsClassified                 Antall e-post klassifisert
Bucket_EmailsClassifiedUpper            Antall e-post klassifisert
Bucket_ClassificationErrors             Klassifiseringsfeil
Bucket_Accuracy                         Nøyaktighet
Bucket_ClassificationCount              Klassifiseringstelling
Bucket_ResetStatistics                  Nullstill Statistikkene
Bucket_LastReset                        Sist nullstilt
Bucket_CurrentColor                     %s Nåværende farge er %s
Bucket_SetColorTo                       Sett %s fargen til %s
Bucket_Maintenance                      Vedlikehold
Bucket_CreateBucket                     Oppret bøtten med navnet
Bucket_DeleteBucket                     Slett bøtten med navnet
Bucket_RenameBucket                     Omdøp bøtten med navnet
Bucket_Lookup                           Søk etter
Bucket_LookupMessage                    Søk etter ord i bøttene
Bucket_LookupMessage2                   Søkeresultatet for
Bucket_LookupMostLikely                 Det er mest sannsynlig at <b>%s</b> forekommer i <font color=%s>%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> forekommer ikke i noen av bøttene
Bucket_DisabledGlobally                 Deaktivert globalt
Bucket_To                               til
Bucket_Quarantine                       Karantene

SingleBucket_Title                      Detaljer for %s
SingleBucket_WordCount                  Totalt antall ord i bøtten
SingleBucket_TotalWordCount             Totalt antall ord
SingleBucket_Percentage                 Prosentandelen av totalen
SingleBucket_WordTable                  Ord tabell for %s
SingleBucket_Message1                   Markerte (*) ord er blitt brukt til å klassifisere i denne POPFile-sesjonen. Trykk på hvilket som helst ord for å slå opp dens sannsynlighet for alle bøttene.
SingleBucket_Unique                     %s unike
