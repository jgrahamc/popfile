MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by mail.datasync.com id h1KNLSI27579


# Identify the language and character set used for the interface
LanguageCode                            nl
LanguageCharset                         ISO-8859-1

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en
=20
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

Configuration_Error1                    Het scheidingsteken moet een enke=
l karakter zijn
Configuration_Error2                    De gebruikers interface poort moe=
t een getal zijn tussen 1 en 65535
Configuration_Error3                    De POP3 luisterpoort moet een get=
al zijn tussen 1 en 65535
Configuration_Error4                    De pagina grootte moet een getal =
zijn tussen 1 en 1000
Configuration_Error5                    Het aantal dagen in de geschieden=
is moet een getal zijn tussen 1 en 366
Configuration_Error6                    De TCP timeout moet een getal zij=
n tussen 10 en 300
Configuration_POP3Port                  POP3 luisterpoort
Configuration_POP3Update                Poort veranderd naar %s; deze ver=
andering krijgt effect zodra je POPFile herstart hebt
Configuration_Separator                 Scheidingsteken
Configuration_SepUpdate                 Scheidingsteken veranderd naar %s
Configuration_UI                        Gebruikers interface web poort
Configuration_UIUpdate                  Gebruikers interface web poort ve=
randerd naar %s; deze verandering krijgt effect zodra je POPFile herstart=
 hebt
Configuration_History                   Aantal emails per pagina
Configuration_HistoryUpdate             Aantal emails per pagina verander=
d naar %s
Configuration_Days                      Aantal dagen geschiedenis om te b=
ewaren
Configuration_DaysUpdate                Aantal dagen geschiedenis om te b=
ewaren veranderd naar %s
Configuration_UserInterface             Gebruikers Interface
Configuration_Skins                     Huiden
Configuration_SkinsChoose               Kies huid
Configuration_Language                  Taal
Configuration_LanguageChoose            Kies Taal
Configuration_ListenPorts               Luister Poorten
Configuration_HistoryView               Geschiedenis View
Configuration_TCPTimeout                TCP Connectie Timeout
Configuration_TCPTimeoutSecs            TCP Connectie Timeout in seconden
Configuration_TCPTimeoutUpdate          TCP Connectie Timeout veranderd n=
aar %s
Configuration_ClassificationInsertion   Classificatie toevoeging
Configuration_SubjectLine               Onderwerp regel verandering
Configuration_XTCInsertion              X-Text-Classification toevoeging
Configuration_XPLInsertion              X-POPFile-Link toevoeging
Configuration_Logging                   Logging
Configuration_None                      Geen
Configuration_ToScreen                  Naar het scherm
Configuration_ToFile                    Naar een bestand
Configuration_ToScreenFile              Naar het scherm en naar een besta=
nd
Configuration_LoggerOutput              Logger uitvoer

Advanced_Error1                         '%s' zit al in de lijst met stopw=
oorden
Advanced_Error2                         stopwoorden mogen alleen alphanum=
erieke, ., _, -, of @ karakters bevatten
Advanced_Error3                         '%s' is toegevoegd aan de lijst m=
et stopwoorden
Advanced_Error4                         '%s' zit niet in de lijst met sto=
pwoorden
Advanced_Error5                         '%s' is verwijderd van de lijst m=
et stopwoorden
Advanced_StopWords                      Stopwoorden
Advanced_Message1                       De volgende woorden worden genege=
erd bij alle classificaties omdat ze zeer vaak voorkomen.
Advanced_AddWord                        Voeg woord toe
Advanced_RemoveWord                     Verwijder woord

History_Filter                          &nbsp;(alleen uit bak <font color=
=3D"%s">%s</font>)
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
History_ChangedTo                       Veranderd naar <font color=3D"%s"=
>%s
History_Already                         Is al gereclassificeerd als <font=
 color=3D"%s">%s</font>
History_RemoveAll                       Verwijder alles
History_RemovePage                      Verwijder pagina
History_Remove                          Om berichten te verwijderen in de=
 geschiedenis klik
History_SearchMessage                   Zoek onderwerp
History_NoMessages                      Geen berichten

Password_Title                          Wachtwoord
Password_Enter                          Voer wachtwoord in
Password_Go                             Go!
Password_Error1                         Ongeldig wachtwoord

Security_Error1                         De veilige poort moet een nummer =
zijn tussen 1 en 65535
Security_Stealth                        Undercover modus/Server operatie
Security_NoStealthMode                  Nee (Undercover modus)
Security_ExplainStats                   (als dit aan staat stuurt POPFile=
 =E9=E9n keer per dag de volgende drie waarden naar een script op www.use=
thesource.com: bc (het aantal bakken dat je hebt), mc (het totaal aantal =
geclassificeerde berichten door POPFile) en ec (het totaal aantal fouten =
tijdens classificatie).  Deze waarden worden opgeslagen in een bestand en=
 ik zal deze gegevens gebruiken om statistieken te publiceren over hoe me=
nsen POPFile gebruiken en hoe goed het werkt.  Mijn web server houdt de l=
og bestanden 5 dagen vast waarna ze verwijderd zullen worden; Ik bewaar g=
een gegevens over het verband tussen de statistieken en individuele IP ad=
ressen.)
Security_ExplainUpdate                  (als dit aan staat stuurt POPFile=
 =E9=E9n keer per dag de volgende drie waarden naar een script op www.use=
thesource.com: ma (het grote versie nummer van jouw POPFile installatie),=
 mi (het kleine versie nummer van jouw POPFile installatie) en bn (het bo=
uwnummer van jouw versie van POPFile).  POPFile ontvangt in reactie hiero=
p een plaatje dat bovenaan de pagina afgebeeld wordt als er een nieuwe ve=
rsie van POPFile beschikbaar is. Mijn web server houdt de log bestanden 5=
 dagen vast waarna ze verwijderd zullen worden; Ik bewaar geen gegevens o=
ver het verband tussen de update checks en individuele IP adressen.)
Security_PasswordTitle                  Gebruikers Interface Wachtwoord
Security_Password                       Wachtwoord
Security_PasswordUpdate                 Wachtwoord veranderd naar %s
Security_AUTHTitle                      Veilig Wachtwoord Authentificatie=
 (AUTH)
Security_SecureServer                   Veilige Server
Security_SecureServerUpdate             Veilige server veranderd naar %s;=
 deze verandering krijgt effect zodra je POPFile herstart hebt
Security_SecurePort                     Veilige poort
Security_SecurePortUpdate               Veilige poort veranderd naar %s; =
deze verandering krijgt effect zodra je POPFile herstart hebt
Security_POP3                           Accepteer POP3 verbindingen van a=
ndere machines=20
Security_UI                             Accepteer HTTP (Gebruikers Interf=
ace) verbindingen van andere machines=20
Security_UpdateTitle                    Automatische Update controle=20
Security_Update                         Controleer dagelijks op nieuwe ve=
rsies van POPFile=20
Security_StatsTitle                     Rapporteer statistieken
Security_Stats                          Stuur dagelijks statistieken naar=
 John terug

Magnet_Error1                           Magneet'%s' bestaat al in bak '%s=
'
Magnet_Error2                           Nieuwe magneet '%s' botst met mag=
neet '%s' in bak '%s' en kan voor verwarrende resultaten leiden.  Nieuwe =
magneet niet toegevoegd.
Magnet_Error3                           Maak nieuwe magneet '%s' in bak '=
%s'
Magnet_CurrentMagnets                   Huidige magneten
Magnet_Message1                         De volgende magneten zorgen er al=
tijd voor dat berichten in de gespecificeerde bak vallen.
Magnet_CreateNew                        Maak Nieuwe Magneet
Magnet_Explanation                      Er zijn drie type magneten beschi=
kbaar: <ul><li>Van adres of naam:</b> B.v.: john@company.com om een speci=
fiek adres te specificeren, <br />company.com om iedereen te specificeren=
 die berichten sturen vanaf company.com, <br />John Doe om een bepaalde p=
ersoon te specificeren, John om alle Johns te specificeren</li><li><b>Naa=
r adres of naam:</b> Net als een "Van" magneet maar nu voor de geadressee=
rde</li><li><b>Onderwerp woorden:</b> B.v.: Hallo om alle berichten met H=
allo in het onderwerp te specificeren.</li></ul>
Magnet_MagnetType                       Magneet type
Magnet_Value                            Waarde
Magnet_Always                           Gaat altijd naar bak

Bucket_Error1                           Baknamen kunnen alleen a t/m z (g=
een hoofdletters) en - en _ karakters bevatten
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
Bucket_DeleteBucket                     Verwijder bak met naam=20
Bucket_RenameBucket                     Hernoem bak met naam
Bucket_Lookup                           Bekijk
Bucket_LookupMessage                    Bekijk woord in bak
Bucket_LookupMessage2                   Resultaat voor=20
Bucket_LookupMostLikely                 <b>%s</b> komt het meest waarschi=
jnlijk voor in <font color=3D"%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> komt niet voor in ee=
n van de bakken
Bucket_DisabledGlobally                 Globaal uitgeschakeld
Bucket_To                               naar

SingleBucket_Title                      Details voor %s
SingleBucket_WordCount                  Aantal woorden in bak
SingleBucket_TotalWordCount             Totaal aantal woorden
SingleBucket_Percentage                 Percentage van totaal
SingleBucket_WordTable                  Woordentabel voor %s
SingleBucket_Message1                   Woorden met een sterretje (*) zij=
n gebruikt voor classificatie in deze POPFile sessie.  Klik op een woord =
om de waarschijnlijkheid te zien voor alle bakken.
SingleBucket_Unique                     %s uniek
