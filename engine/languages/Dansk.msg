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
LanguageCode                            da
LanguageCharset                         ISO-8859-1

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          da

# Common words that are used on their own all over the interface
Apply                                   Anvend
On                                      Til
Off                                     Fra
TurnOn                                  Slå til
TurnOff                                 Slå fra
Add                                     Tilføj
Remove                                  Fjern
Previous                                Forrige
Next                                    Næste
From                                    Fra
Subject                                 Emne
Classification                          Klassificering
Reclassify                              Genklassificering
Undo                                    Fortryd
Close                                   Luk
Find                                    Søg
Filter                                  Filtrér
Yes                                     Ja
No                                      Nej
ChangeToYes                             Skift til Ja
ChangeToNo                              Skift til Nej
Bucket                                  Spand
Magnet                                  Magnet
Delete                                  Slet
Create                                  Tilføj
To                                      Til
Total                                   Total
Rename                                  Omdøb
Frequency                               Frekvens
Probability                             Sandsynlighed
Score                                   Resultat
Lookup                                  Slå op

# The header and footer that appear on every UI page
Header_Title                            POPFile Kontrolcenter
Header_Shutdown                         Luk
Header_History                          Historik
Header_Buckets                          Spande
Header_Configuration                    Indstillinger
Header_Advanced                         Avanceret
Header_Security                         Sikkerhed
Header_Magnets                          Magneter

Footer_HomePage                         POPFiles hjemmeside
Footer_Manual                           Manual
Footer_Forums                           Fora
Footer_FeedMe                           Donér
Footer_RequestFeature                   Foreslå funktion
Footer_MailingList                      Postliste

Configuration_Error1                    Skilletegnet skal være et enkelt tegn
Configuration_Error2                    Kontrolcenterets port skal være et tal mellem 1 og 65535
Configuration_Error3                    POP3-porten skal være et tal mellem 1 og 65535
Configuration_Error4                    Sidens størelse skal være mellem 1 og 1000
Configuration_Error5                    Antal dage i historikken skal være et tal mellem 1 og 366
Configuration_Error6                    TCP-timeouten skal være et tal mellem 10 og 300
Configuration_Error7                    XML-RPC-porten skal være et tal mellem 1 og 65535
Configuration_POP3Port                  POP3-port
Configuration_POP3Update                Opdaterede POP3-porten til %s. Denne ændring vil ikke træde i kraft før POPFile er genstartet
Configuration_XMLRPCUpdate              Opdaterede XML-RPC-porten til %s. Denne ændring vil ikke træde i kraft før POPFile er genstartet
Configuration_XMLRPCPort                XML-RPC-port
Configuration_SMTPPort                  SMTP-port
Configuration_SMTPUpdate                Opdaterede SMTP-porten til %s. Denne ændring vil ikke træde i kraft før POPFile er genstartet
Configuration_NNTPPort                  NNTP-port
Configuration_NNTPUpdate                Opdaterede NNTP-porten til %s. Denne ændring vil ikke træde i kraft før POPFile er genstartet
Configuration_POP3Separator             POP3 vært:port:bruger-skilletegn
Configuration_NNTPSeparator             NNTP vært:port:bruger-skilletegn
Configuration_POP3SepUpdate             Opdaterede POP3-skilletegn til %s
Configuration_NNTPSepUpdate             Opdaterede NNTP-skilletegn til %s
Configuration_UI                        Kontrolcenterets webport
Configuration_UIUpdate                  Opdaterede kontrolcenterets webport til %s; denne ændring vil ikke træde i kraft før POPFile er genstartet
Configuration_History                   Antal breve pr. side
Configuration_HistoryUpdate             Opdaterede antal breve pr. side til %s
Configuration_Days                      Antal dage historikken skal beholdes
Configuration_DaysUpdate                Opdaterede antal dage historikken skal beholdes til %s
Configuration_UserInterface             Kontrolcenter
Configuration_Skins                     Skins
Configuration_SkinsChoose               Vælg skin
Configuration_Language                  Sprog
Configuration_LanguageChoose            Vælg sprog
Configuration_ListenPorts               POP3-port
Configuration_HistoryView               Historik
Configuration_TCPTimeout                TCP-forbindelsens timeout
Configuration_TCPTimeoutSecs            TCP-forbindelsens timeout i sekunder
Configuration_TCPTimeoutUpdate          Opdaterede TCP-forbindelsens timeout til %s
Configuration_ClassificationInsertion   Klassificering
Configuration_SubjectLine               Emnelinie-modifikation
Configuration_XTCInsertion              X-Text-Classification
Configuration_XPLInsertion              X-POPFile-Link
Configuration_Logging                   Logning
Configuration_None                      Ingen
Configuration_ToScreen                  Til skærm
Configuration_ToFile                    Til fil
Configuration_ToScreenFile              Til skærm og fil
Configuration_LoggerOutput              Log
Configuration_GeneralSkins              Skins
Configuration_SmallSkins                Små skins
Configuration_TinySkins                 Meget små skins

Advanced_Error1                         '%s' er allerede i stopordslisten
Advanced_Error2                         Stopord kan kun indeholde tal og bogstaver, samt ., _, -, eller @.
Advanced_Error3                         '%s' er tilføjet til stopordslisten
Advanced_Error4                         '%s' er ikke i stopordslisten
Advanced_Error5                         '%s' er fjernet fra stopordslisten
Advanced_StopWords                      Stopord
Advanced_Message1                       Følgende ord bliver ignoreret under alle klassificeringer på grund af deres hyppighed:
Advanced_AddWord                        Tilføj ord
Advanced_RemoveWord                     Fjern ord

History_Filter                          &nbsp;(vis kun spanden <font color="%s">%s</font>)
History_FilterBy                        Filtrér med
History_Search                          &nbsp;(søg emne for %s)
History_Title                           Seneste beskeder
History_Jump                            Spring til besked
History_ShowAll                         Vis alle
History_ShouldBe                        Skal være
History_NoFrom                          Ingen fra-linie
History_NoSubject                       Ingen emne-linie
History_ClassifyAs                      Klassificeret som
History_MagnetUsed                      Magnet brugt
History_ChangedTo                       Skift til <font color="%s">%s
History_Already                         Allerede genklassificeret som <font color="%s">%s</font>
History_RemoveAll                       Fjern alle
History_RemovePage                      Fjern side
History_Remove                          Fjern breve i historikken ved at trykke
History_SearchMessage                   Søg i Fra/Emne
History_NoMessages                      Ingen breve
History_ShowMagnet                      Magnetiseret
History_Magnet                          &nbsp;(viser kun magnet-klassificerede meddelelser)
History_ResetSearch                     Nulstil

Password_Title                          Kodeord
Password_Enter                          Indtast kodeord
Password_Go                             OK
Password_Error1                         Forkert kodeord

Security_Error1                         Den sikre port skal være et tal mellem 1 og 65535
Security_Stealth                        Sikker tilstand/Server
Security_NoStealthMode                  Nej (Sikker tilstand)
Security_ExplainStats                   (Med denne funktion slået til sender POPFile en gang om dagen tre værdier til et script hos wwwu.sethesource.com:<br>bc (antallet af dine spande),<br>mc (antallet af breve, POPFile har klassificeret) og<br>ec (antallet af klassificeringsfejl). Disse tal bliver gemt i en fil. Jeg vil bruge disse data til at offentliggøre en statistik over hvordan folk bruger POPFile og hvor godt POPFile virker. Min web server gemmer denne logfil i ca. 5 dage, hvorefter de bliver slettet; Jeg gemmer ingen sammenhæng mellem statistikken og individuelle IP adresser.)
Security_ExplainUpdate                  (Med denne funktion slået til sender POPFile en gang om dagen tre værdier til et script hos wwwu.sethesource.com:<br>ma (det store versionsnummer på din installerede POPFile),<br>mi (det lille versionsnummer på din installerede POPFile) og<br>bn (build-nummeret på din installerede POPFile).<br>POPFile modtager et svar i form af et stykke grafik, som vises i toppen af siden, hvis en ny version er til rådighed. Min web server gemmer denne logfil i ca. 5 dage, hvorefter de bliver slettet; Jeg gemmer ingen sammenhæng mellem statistikken og individuelle IP adresser.)
Security_PasswordTitle                  Kontrolcenterets kodeord
Security_Password                       Kodeord
Security_PasswordUpdate                 Opdater kodeord til %s
Security_AUTHTitle                      Godkendelse af sikker adgangskode
Security_SecureServer                   Sikker server
Security_SecureServerUpdate             Opdaterede sikker server til %s. Denne ændring vil ikke træde i kraft før POPFile er genstartet
Security_SecurePort                     Sikker port
Security_SecurePortUpdate               Opdaterede den sikre port til %s. Denne ændring vil ikke træde i kraft før POPFile er genstartet
Security_SMTPServer                     SMTP-kæde-server
Security_SMTPServerUpdate               Opdaterede SMTP-kæde-server til %s. Denne ændring vil ikke træde i kraft før POPFile er genstartet
Security_SMTPPort                       SMTP-kæde-port
Security_SMTPPortUpdate                 Opdaterede SMTP-kæde-port til %s. Denne ændring vil ikke træde i kraft før POPFile er genstartet
Security_POP3                           Acceptér POP3-tilslutninger fra andre maskiner (kræver at POPFile genstartes)
Security_SMTP                           Acceptér SMTP-tilslutninger fra andre maskiner (kræver at POPFile genstartes)
Security_NNTP                           Acceptér NNTP-tilslutninger fra andre maskiner (kræver at POPFile genstartes)
Security_UI                             Acceptér HTTP(kontrolcenter)-tilslutninger fra andre maskiner
Security_XMLRPC                         Acceptér XML-RPC-tilslutninger fra andre maskiner (kræver at POPFile genstartes)
Security_UpdateTitle                    Automatisk opdateringscheck
Security_Update                         Check dagligt, om der er opdateringer af POPFile
Security_StatsTitle                     Statistikrapportering
Security_Stats                          Send statistikkerne tilbage til John dagligt

Magnet_Error1                           Magneten '%s' eksisterer allrede i spanden '%s' 
Magnet_Error2                           Den nye magnet '%s' er i konflikt med magneten '%s' i spanden '%s' og kunne skabe flertydige resultater. Den nye magnet er ikke tilføjet.
Magnet_Error3                           Tilføjede den nye magnet '%s' i spanden '%s'
Magnet_CurrentMagnets                   Magneter i brug
Magnet_Message1                         Magneterne får breve til altid at blive klassificeret til den specificerede spand.
Magnet_CreateNew                        Tilføj nye magneter
Magnet_Explanation                      Der findes tre typer magneter: <ul><li>"Fra:"-adresse eller -navn:</b> For eksempel: john@firma.dk for at matche en specifik adresse, <br />firma.dk for at matche alle, der sender fra firma.dk, <br />John Doe for at matche en specifik person, John for at matche alle John'er.</li><li><b>"Til:"-adresse eller -navn:</b> Lige som en "Fra:"-magnet, men bare for "Til:"-adressen i et brev.</li><li><b>Ord i emnet</b> For eksempel: hej for at matche alle breve med ordet hej i emnet.</li></ul>
Magnet_MagnetType                       Magnettyper
Magnet_Value                            Værdier
Magnet_Always                           Tilhører altid spanden

Bucket_Error1                           Spandenes navne kan kun indholde bogstaverne a til z med små bogstaver, samt - og _
Bucket_Error2                           Spanden med navnet %s findes allerede
Bucket_Error3                           Opret spanden med navnet %s
Bucket_Error4                           Skriv venligst et ikke-tomt ord
Bucket_Error5                           Omdøb spanden %s til %s
Bucket_Error6                           Slet spanden %s
Bucket_Title                            Oversigt
Bucket_BucketName                       Spandenes navne
Bucket_WordCount                        Ordtælling
Bucket_WordCounts                       Ordfordeling
Bucket_UniqueWords                      Unikke ord
Bucket_SubjectModification              Emnemodifikation
Bucket_ChangeColor                      Skift farve
Bucket_NotEnoughData                    Ikke nok data
Bucket_ClassificationAccuracy           Klassificeringsnøjagtighed
Bucket_EmailsClassified                 Klassificerede breve
Bucket_EmailsClassifiedUpper            Klassificerede breve
Bucket_ClassificationErrors             Klassificeringsfejl
Bucket_Accuracy                         Nøjagtighed
Bucket_ClassificationCount              Antal
Bucket_ResetStatistics                  Nulstil Statistikkerne
Bucket_LastReset                        Sidst nulstillet
Bucket_CurrentColor                     %s's aktuelle farve er %s
Bucket_SetColorTo                       Sæt %s-farven til %s
Bucket_Maintenance                      Vedligeholdelse
Bucket_CreateBucket                     Opret spanden med navnet
Bucket_DeleteBucket                     Slet spanden med navnet
Bucket_RenameBucket                     Omdøb spanden med navnet
Bucket_Lookup                           Slå op
Bucket_LookupMessage                    Slå ord op i spandene
Bucket_LookupMessage2                   Opslagsresultatet for
Bucket_LookupMostLikely                 Det er mest sandsynligt at <b>%s</b> forekommer i <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> forekommer ikke i nogle af spandene
Bucket_DisabledGlobally                 Deaktiveret globalt
Bucket_To                               til
Bucket_Quarantine                       Sæt i karantæne

SingleBucket_Title                      Detaljer for %s
SingleBucket_WordCount                  Antal ord i spanden
SingleBucket_TotalWordCount             Antal ord i alt
SingleBucket_Percentage                 Procent af alle ord
SingleBucket_WordTable                  Ordtabel for %s
SingleBucket_Message1                   Markerede (*) ord er blevet brugt til at klassificere i denne POPFile-session. Tryk på et ord for at slå dets sandsynlighed op for alle spandene.
SingleBucket_Unique                     %s unikke

Session_Title                           POPFile-session udløbet
Session_Error                           Din POPFile-session er udløbet. Dette kan skyldes, at du har stoppet og genstartet POPFile uden at lukke din browser.  Klik venligst på et af linkene ovenfor for at fortsætte med at bruge POPFile.


Header_MenuSummary                      Denne tabel er navigationsmenuen, som giver adgang til kontrolcenterets forskellige sider.
History_MainTableSummary                Denne tabel viser afsenderen og emnet på breve modtaget for nyligt og giver dig mulighed for at vurdere og reklassificere dem. Hvis du klikker på emnelinien vil hele brevets tekst blive vist, sammen med oplysninger om, hvorfor det blev klassificeret som det blev. Kolonnen "skal være" giver dig mulighed for at angive, hvilken spand brevet hører til i, eller til at fortryde denne ændring. Kolonnen "Slet" giver dig mulighed for at slette enkelte breve fra historikken, hvis du ikke længere har brug for dem.
History_OpenMessageSummary              Denne tabel indeholder et brevs fulde ordlyd, med nøgleordene, som er brugt til klassificering, markeret svarende til den spand, der er mest relevant for dem.
Bucket_MainTableSummary                 Denne tabel giver et overblik over klassificerings-spandene. Hver række viser spandens navn, antallet af optalte ord for spanden, antallet af unikke ord i spanden, om brevets emnelinie vil blive modificeret, når det klassificeres til spanden, om brevet skal sættes i karantæne, når det lander i spanden, samt en tabel til at vælge hvilken farve, der skal knyttes til spanden. Farven vil blive brugt til alt, hvad der har at gøre med spanden i kontrolcenteret.
Bucket_StatisticsTableSummary           Denne tabel viser tre sæt af statistikker over POPFiles ydelse. Den første viser, hvor nøjagtigt klassificeringen er, den næste viser hvor mange breve, der er blevet klassificeret og til hvilke spande, og den tredie viser, hvor mange ord der er i hver spand, samt deres relative procentandel.
Bucket_MaintenanceTableSummary          Denne tabel giver dig mulighed for at oprette, slette og omdøbe spande, og til at slå et ord op i alle spandene for se dets relative sandsynligheder.
Bucket_AccuracyChartSummary             Denne tabel viser en grafisk repræsentation af nøjagtigheden af brevklassificeringen.
Bucket_BarChartSummary                  Denne tabel viser en grafisk repræsentation af den procentvise fordeling spandene imellem. Den viser både antallet af klassificerede breve og det totale antal ord.
Bucket_LookupResultsSummary             Denne tabel viser sandsynlighederne, der er knyttet til hvert ord i korpusset. For hver spand viser den frekvensen, som ordet forekommer med, sandsynligheden for at det vil forekomme i spanden, samt den samlede effekt på spandens score, ordet vil have, hvis det forekommer i et brev.
Bucket_WordListTableSummary             Denne tabel viser alle ordene i en given spand organiseret alfabetisk i rækker.
Magnet_MainTableSummary                 Denne tabel viser en liste over magneter, der bruges til automatisk at klassificere breve i henhold til faste regler. Hver række viser hvordan magneten er defineret, hvilken spand, den er beregnet på, samt en knap til at slette magneten med.
Configuration_MainTableSummary          Denne tabel giver dig mulighed for at indstille POPFile.
Configuration_InsertionTableSummary     Denne tabel indeholder knapperne, der bestemmer, hvorvidt bestemte ændringer bliver lavet i brevets headere eller emnelinier, før det sendes videre til dit e-postprogram.
Security_MainTableSummary               Denne tabel indeholder kontroller, der vedrører POPFiles almene sikkerhed, hvorvidt programmet automatisk skal undersøge, om der er opdateringer tilgængelige på Internettet samt om der skal sendes statistik om programmets ydelse til programmets forfatter med henblik på offentliggørelse.
Advanced_MainTableSummary               Denne tabel indeholder en liste over stopord, som POPFile ignorerer på grund af deres hyppighed, når det klassificerer breve. De er organiseret alfabetisk i rækker.

