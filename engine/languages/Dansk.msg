# This is used to get the appropriate subdirectory for the manual
LanguageCode                            en

# Common words that are used on their own all over the interface
Apply                                   Anvend
On                                      On
Off                                     Off
TurnOn                                  Tænd
TurnOff                                 Sluk
Add                                     Tilføj
Remove                                  Fjern
Previous                                Forrige
Next                                    Næste
>From                                    Fra
Subject                                 Emne
Classification                          Klassifikation
Reclassify                              Genklassificering
Undo                                    Fortryd
Close                                   Luk
Find                                    Søg
Filter                                  Filter
Yes                                     Ja
No                                      Nej
ChangeToYes                             Skift til Ja
ChangeToNo                              skift til Nej
Bucket                                  Spand
Magnet                                  Magnet
Delete                                  Slet
Create                                  Opret
To                                      Til
Total                                   Total
Rename                                  Omdøb
Frequency                               Frekvens
Probability                             Sandsynlighed
Score                                   Resultat
Lookup                                  Slå op

# The header and footer that appear on every UI page
Header_Title                            POPFile Kontrol Center
Header_Shutdown                         Luk
Header_History                          Historie
Header_Buckets                          Spande
Header_Configuration                    Konfiguration
Header_Advanced                         Avanceret
Header_Security                         Sikkerhed
Header_Magnets                          Magneter

Footer_HomePage                         POPFile Hjemmeside
Footer_Manual                           Manual
Footer_Forums                           Forumer
Footer_FeedMe                           Mad Tak!
Footer_RequestFeature                   Forspurgte funktioner
Footer_MailingList                      Mailing Liste

Configuration_Error1                    Det adskildene tegn skal være et enkelt tegn
Configuration_Error2                    Brugerfladens port skal være et nummer imellem 1 og 65535
Configuration_Error3                    POP3 porten skal være et nummer imellem 1 og 65535
Configuration_Error4                    Siden størelse skal være imellem 1 og 1000
Configuration_Error5                    Antal dage i historie skal være et tal imellem 1 og 366
Configuration_Error6                    TCP timeouten skal være et tal imellem 10 og 300
Configuration_POP3Port                  POP3 Porten
Configuration_POP3Update                Opdaterede Porten til %s; Denne ændring vil ikke træde i kraft før det er at POPFile er genstartet
Configuration_Separator                 Adskelligelses tegn
Configuration_SepUpdate                 Opdaterede det adskildene tegn til %s
Configuration_UI                        Brugerfladens web port
Configuration_UIUpdate                  Updaterede Brugerfladens web port til %s; denne ændring vil ikke træde i kraft før det er at POPFile er genstartet
Configuration_History                   Antal emails pr. side
Configuration_HistoryUpdate             Updaterede antal emails pr. side til %s
Configuration_Days                      Antal dage historien skal beholdes
Configuration_DaysUpdate                Updaterede antal dage historien skal beholdes til %s
Configuration_UserInterface             Brugerfladen
Configuration_Skins                     Skins
Configuration_SkinsChoose               Vælg skin
Configuration_Language                  Sprog
Configuration_LanguageChoose            Vælg sprog
Configuration_ListenPorts               POP3 porten
Configuration_HistoryView               Historie view
Configuration_TCPTimeout                TCP forbindelses timeout
Configuration_TCPTimeoutSecs            TCP forbindelses timeout i sekunder
Configuration_TCPTimeoutUpdate          Updatere TCP forbindelses timeout til %s
Configuration_ClassificationInsertion   Classification Insertion
Configuration_SubjectLine               Emne linie modifikation
Configuration_XTCInsertion              X-Text-Classification indsætning
Configuration_XPLInsertion              X-POPFile-Link indsætning
Configuration_Logging                   Logging
Configuration_None                      Ingen
Configuration_ToScreen                  Til Skærm
Configuration_ToFile                    Til Fil
Configuration_ToScreenFile              Til Skærm og Fil
Configuration_LoggerOutput              Logger output

Advanced_Error1                         '%s' Er allrede i Stop ords listen
Advanced_Error2                         Stop ord kan kun indeholde Alfanumeristike, ., _, -, eller @ tegn
Advanced_Error3                         '%s' er tilføjet til stop ords listen
Advanced_Error4                         '%s' er ikke i stop ords listen
Advanced_Error5                         '%s' er fjernet fra stop ords listen
Advanced_StopWords                      Stop ord
Advanced_Message1                       De efterfølgene ord er alle ignoret fra alle klasifikationer pga. af at de fremkommer meget ofte.
Advanced_AddWord                        Tilføj ord
Advanced_RemoveWord                     fjern ord

History_Filter                          &nbsp;(vis kun spanden <font color=%s>%s</font>)
History_Search                          &nbsp;(søg emne for %s)
History_Title                           seneste beskeder
History_Jump                            Spring til besked
History_ShowAll                         Vis alle
History_ShouldBe                        skulle være
History_NoFrom                          igen fra linie
History_NoSubject                       igen Emne linie
History_ClassifyAs                      klassificeret som
History_MagnetUsed                      Magnet brugt
History_ChangedTo                       skilft til <font color=%s>%s
History_Already                         Allrede genklassificeret som <font color=%s>%s</font>
History_RemoveAll                       Fjern alle
History_RemovePage                      Fjern side
History_Remove                          for at fjerne tilføjelser i historien tryk
History_SearchMessage                   Søg Emne
History_NoMessages                      Igen beskeder

Password_Title                          Kodeord
Password_Enter                          Indtast kodeord
Password_Go                             Go!
Password_Error1                         forkert kodeord

Security_Error1                         Den sikkere port skal være et tal imellem 1 og 65535
Security_Stealth                        Stealth Mode/Server Operation
Security_NoStealthMode                  Nej (Stealth Mode)
Security_ExplainStats                   (Med denne funktion Sender POPFile engang per dag de efterfølgene tre værdier til et script hos wwwu.sethesource.com: bc ( det totale antal spande du har ) mc ( den hele antal i beskeder at POPFile har klassificeret ) og ec ( det totale antal klassificeringsfejl ). Disse blive lageret i en fil og Jeg vil bruge disse data til at bekendtgøre noget statistik omkring hvordan folk bruger POPFile og hvor godt POPFile virker. Min web server beholder denne log fil for omkring 5 dage og så bliver de slettet; Jeg gemmer igen forbindelse imellem statistikken og individ IP adresser.)
Security_ExplainUpdate                  (Med denne funktion Sender POPFile engang per dag de efterfølgene tre værdier til et script hos wwwu.sethesource.com: ma (det major version number af din installeret POPFile), mi (det minor version number af din installeret POPFile) and bn (buildt number af din installeret POPFile). POPFile modtager et svar i form af et stykke grafik som vises i toppen af siden, hvis en ny version er tilrådighed. Min web server beholder denne log fil for omkring 5 dage og så bliver de slettet; Jeg gemmer igen forbindelse imellem statistikken og individ IP adresser.)
Security_PasswordTitle                  Brugerfladens Kodeord
Security_Password                       Kodeord
Security_PasswordUpdate                 Opdater kodeord til %s
Security_AUTHTitle                      Godkendelse af sikker adgangskode
Security_SecureServer                   Sikker Server
Security_SecureServerUpdate             Opdaterede sikker server til %s; denne ændring vil ikke træde i kraft før det er at POPFile er genstartet
Security_SecurePort                     Sikker port
Security_SecurePortUpdate               Opdaterede porten til %s; denne ændring vil ikke træde i kraft før det er at POPFile er genstartet
Security_POP3                           Acceptere POP3 tilslutninger fra fjernmaskiner
Security_UI                             Acceptere HTTP ( Brugerflade ) tilslutninger fra fjernmaskiner
Security_UpdateTitle                    Automatisk Updaterings Tjeck
Security_Update                         Tjeck dagligt efter updateringer af POPFile
Security_StatsTitle                     Statestik Reportering
Security_Stats                          Send statestikkerne tilbage til John dagligt

Magnet_Error1                           Magneten '%s' eksistere allrede i spanden '%s' 
Magnet_Error2                           Den nye magnet '%s' konfligter med magneten '%s' i spanden '%s' og kunne skabe flertydige resultater. Den nye magnet er ikke tilføjet.
Magnet_Error3                           Skabte den nye magnet '%s' i spanden '%s'
Magnet_CurrentMagnets                   Aktuele Magneter
Magnet_Message1                         The following magnets cause mail to always be classified into the specified bucket.
Magnet_CreateNew                        Skab Nye Magnet
Magnet_Explanation                      Tre typer magneter er tilrådige: <ul><li>Fra adressen eller navn:</b> For eksempel: john@firma.dk for at matche en specifik adresse, <br>firma.dk for at matche alle der sender fra firma.dk, <br>John Doe for at matche en specifik person, John for at matche alle Johns<li><b>Til adresse eller navn:</b> Lige som en Fra: Magnet men bare for Til: Adressen i en email<li><b>Emne ord:</b> For eksempel: hej for at matche alle beskeder med ordet hej i emnet</ul>
Magnet_MagnetType                       Magnet typer
Magnet_Value                            Værdier
Magnet_Always                           Tilhøre alttid spanden

Bucket_Error1                           Spandenes navne kan kun indholde bogstaverne a til z med små bogstaver samt - og _
Bucket_Error2                           Spanden med navnet %s eksistere allrede
Bucket_Error3                           Opret Spanden med navnet %s
Bucket_Error4                           Skriv venligst et ikke tomt ord
Bucket_Error5                           Omdøb spanden %s til %s
Bucket_Error6                           Slet spanden %s
Bucket_Title                            oversigt
Bucket_BucketName                       Spandenes navne
Bucket_WordCount                        Ord tælling
Bucket_WordCounts                       Ord fordeling
Bucket_UniqueWords                      Unique Ord
Bucket_SubjectModification              Emne Modifikationer
Bucket_ChangeColor                      Skift farve
Bucket_NotEnoughData                    Ikke nok data
Bucket_ClassificationAccuracy           Klasifikations Nøjagtighed
Bucket_EmailsClassified                 Emails klasifiseret
Bucket_EmailsClassifiedUpper            Emails klasifiseret
Bucket_ClassificationErrors             Klasifiserings fejl
Bucket_Accuracy                         nøjagtighed
Bucket_ClassificationCount              Klasifiserings tælling
Bucket_ResetStatistics                  Nulstil Statistikerene
Bucket_LastReset                        Sidst nulstillet
Bucket_CurrentColor                     %s aktuele farve er %s
Bucket_SetColorTo                       Sæt %s farven til %s
Bucket_Maintenance                      Vedligeholdelse
Bucket_CreateBucket                     Opret spanden med navnet
Bucket_DeleteBucket                     Slet spanden med navnet
Bucket_RenameBucket                     omdøb spanden med navnet
Bucket_Lookup                           Slå op
Bucket_LookupMessage                    Slå ord op i spandene
Bucket_LookupMessage2                   Opslags resultatet for
Bucket_LookupMostLikely                 Det er mest sansynlig at <b>%s</b> fremkommer i <font color=%s>%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> fremkommer ikke i nogle af spandene
Bucket_DisabledGlobally                 Deaktiveret globalt

SingleBucket_Title                      Detalier for %s
SingleBucket_WordCount                  Total antal ord i spanden
SingleBucket_TotalWordCount             Totale antal ord
SingleBucket_Percentage                 Procentdelen af totalen
SingleBucket_WordTable                  Ord tabel for %s
SingleBucket_Message1                   Markeret (*) ord er blevet brugt til at klasifisere i denne POPFile session. Tryk på hvilket som helst ord for at slå dens sansynlighed op for alle spandene.
SingleBucket_Unique                     %s unique
