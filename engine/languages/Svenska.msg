# This is used to get the appropriate subdirectory for the manual
LanguageCode				sv
LanguageCharset				ISO-8859-1

# Common words that are used on their own all over the interface
Apply                                   Verkställ
On                                      On
Off                                     Off
TurnOn                                  Sätt på
TurnOff                                 Stäng av
Add                                     Lägg till
Remove                                  Ta bort
Previous                                Föregående
Next                                    Nästa
From                                    Från
Subject                                 Ämne
Classification                          Klassifikation
Reclassify                              Reklassifikation
Undo                                    Ångra
Close                                   Stäng av server
Find                                    Sök
Filter                                  Filter
Yes                                     Ja
No                                      Nej
ChangeToYes                             Ändra till Ja
ChangeToNo                              Ändra till Nej
Bucket                                  Hink
Magnet                                  Magnet
Delete                                  Ta bort
Create                                  Skapa
To                                      Till
Total                                   Totalt
Rename                                  Döp om
Frequency                               Frekvens
Probability                             Sannolikhet
Score                                   Resultat
Lookup                                  Leta efter

# The header and footer that appear on every UI page
Header_Title                            Kontrollpanel
Header_Shutdown                         Stäng
Header_History                          Historia
Header_Buckets                          Hinkar
Header_Configuration                    Konfiguration
Header_Advanced                         Avancerat
Header_Security                         Säkerhet
Header_Magnets                          Magneter

Footer_HomePage                         Hem
Footer_Manual                           Manual
Footer_Forums                           Forum
Footer_FeedMe                           Återkoppling
Footer_RequestFeature                   Föreslå funktioner
Footer_MailingList                      Mailinglistor

Configuration_Error1                    Det avskiljande tecknet kan bara vara ett tecken.
Configuration_Error2                    Webgränssnittets post måste vara ett tal mellan 1 och 65535
Configuration_Error3                    POP3 porten måste vara ett tal mellan 1 och 65535
Configuration_Error4                    Sidans storlek måste vara ett tal mellan 1 och 1000
Configuration_Error5                    Antal dagar i 'histora' måste vara ett tal mellan 1 och 366
Configuration_Error6                    TCP timeout måste vara ett tal mellan 10 och 300
Configuration_POP3Port                  POP3 port
Configuration_POP3Update                Uppdaterade porten till %s; denna ändring kommer inte att gälla förrän servern är omstartad.
Configuration_Separator                 Avskiljare
Configuration_SepUpdate                 Uppdaterade det avskiljande tecknet till %s
Configuration_UI                        Webgränssnittets HTTP port
Configuration_UIUpdate                  Uppdaterade webgränssnittets HTTP port till %s; denna ändring kommer inte att gälla förrän servern är omstartad.
Configuration_History                   Antal epost per sida
Configuration_HistoryUpdate             Uppdaterede antal email per sida till %s
Configuration_Days                      Antal dagar histora skall behållas
Configuration_DaysUpdate                Uppdaterede antal dagar histora skall sparas: %s
Configuration_UserInterface             Gränssnitt
Configuration_Skins                     Utseende ytan
Configuration_SkinsChoose               Välj tema
Configuration_Language                  Språk
Configuration_LanguageChoose            Välj språk
Configuration_ListenPorts               POP3
Configuration_HistoryView               Formatera 'Historia' vyn
Configuration_TCPTimeout                TCP förbindelsens timeout
Configuration_TCPTimeoutSecs            TCP förbindelsens timeout i sekunder
Configuration_TCPTimeoutUpdate          Updatera TCP förbindelsens timeout till %s
Configuration_ClassificationInsertion   Klassifikation epost headers
Configuration_SubjectLine               Ämnesrad modifiering
Configuration_XTCInsertion              X-Text-Klassification insättning
Configuration_XPLInsertion              X-POPFile-Länk insättning
Configuration_Logging                   Logging
Configuration_None                      Ingen
Configuration_ToScreen                  Till skärm
Configuration_ToFile                    Till fil
Configuration_ToScreenFile              Till skärm och fil
Configuration_LoggerOutput              Loggning utdata

Advanced_Error1                         '%s' finns redan i stoppord listan
Advanced_Error2                         Stoppord kan bara innehålla alfanumeriska tecken, ., _, -, eller @ tegn
Advanced_Error3                         '%s' är lagt till stopordlistan
Advanced_Error4                         '%s' finns inte i stoppordlistan
Advanced_Error5                         '%s' är borttaget från stoppordlistan
Advanced_StopWords                      Stoppord
Advanced_Message1                       Följande ord ignoreras av klassifikationen eftersom de förekommer ofta.
Advanced_AddWord                        Lägg till ord
Advanced_RemoveWord                     Ta bort ord

History_Filter                          &nbsp;(visa bara spannet <font color=%s>%s</font>)
History_Search                          &nbsp;(sök ämne för %s)
History_Title                           Historia
History_Jump                            Spring til besked
History_ShowAll                         Visa alla
History_ShouldBe                        skulle vara
History_NoFrom                          inget från rad
History_NoSubject                       iget ämne rad
History_ClassifyAs                      klassificerat som
History_MagnetUsed                      Magnet använd
History_ChangedTo                       Ändrat till <font color=%s>%s
History_Already                         Redan reklassificerat som <font color=%s>%s</font>
History_RemoveAll                       Ta bort alla
History_RemovePage                      Ta bort sida
History_Remove                          för att ta bort historia
History_SearchMessage                   Sök ämne
History_NoMessages                      Inga meddelanden

Password_Title                          Lösenord
Password_Enter                          Indtast kodeord
Password_Go                             Go!
Password_Error1                         Fel lösenord

Security_Error1                         Den säkra porten måste vara ett tal mellan 1 och 65535
Security_Stealth                        Server körläge
Security_NoStealthMode                  Nej (Lokalt läge)
Security_ExplainStats                   (Data används för att förbättra servern)
Security_ExplainUpdate                  (Om uppdatering finns tillgänglig kommer en logotyp att visas på sidan)
Security_PasswordTitle                  Lösenord till webgränssnittet
Security_Password                       Lösenord
Security_PasswordUpdate                 Uppdaterar lösenord till %s
Security_AUTHTitle                      Lösenord för epostkonto med extra autentisering
Security_SecureServer                   Server
Security_SecureServerUpdate             Uppdaterade servern till %s; denna ändring kommer inte att träda i kraft förrän servern är omstartad
Security_SecurePort                     Port
Security_SecurePortUpdate               Uppdaterade porten till  %s; denna ändring kommer inte att träda i kraft förrän servern är omstartad 
Security_POP3                           Acceptera anslutningar till POP3 från externa källa
Security_UI                             Acceptera HTTP anslutningar från extern källa
Security_UpdateTitle                    Automatisk uppdatering
Security_Update                         Sök efter uppdateringar varje dag
Security_StatsTitle                     Statistikrapportering
Security_Stats                          Skicka statistik till programmets skapare dagligen

Magnet_Error1                           Magnet '%s' finns redan i '%s' 
Magnet_Error2                           Det nya statiska filtret '%s' kommer i konflikt med det statiska filtret '%s' i '%s' och kan skapa tvetydiga resultat. Det nya statiska filtret skapades inte.
Magnet_Error3                           Skapade ny magnet '%s' i '%s'
Magnet_CurrentMagnets                   Aktuella magneter
Magnet_Message1                         Följande magneter garanterar att email alltid hamnar i en viss hink.
Magnet_CreateNew                        Skapa ny magnet
Magnet_Explanation                      Tre typer av magneter är tillgängliga: <ul><li>Från adressen eller namnet:</b> Till exempel: test@företag.se för att matcha en specifik adress, <br>företag.se för att matcha alla avsändare från företaget, <br>John Doe för att matcha en specifik person, John för att matcha alla Johns<li><b>Till adressen eller namnet:</b> Liksom ovan men för to: eller till: -raden. <li><b>Ämnet:</b> Till exempel: Hej! för att matcha alla 'Hej!' i ämnesraden.</ul>
Magnet_MagnetType                       Magnettyper
Magnet_Value                            Värden
Magnet_Always                           Tillhör alltid magneten

Bucket_Error1                           Hinkens namn kan bara innehålla bokstäverna a till z (små bokstäver) samt - och _
Bucket_Error2                           Hinken med namnet %s finns redan
Bucket_Error3                           Upprätta hink med namnet %s
Bucket_Error4                           Var god fyll i ett ord
Bucket_Error5                           Döp inte om hinken %s till %s
Bucket_Error6                           Tog bort hinken %s
Bucket_Title                            Överblick
Bucket_BucketName                       Hinkens namn
Bucket_WordCount                        Antal
Bucket_WordCounts                       Fördelning av ord
Bucket_UniqueWords                      Unika ord
Bucket_SubjectModification              Ämnesrad modifiering
Bucket_ChangeColor                      Byt färg
Bucket_NotEnoughData                    Finns inte data
Bucket_ClassificationAccuracy           Klassifikationens exakthet
Bucket_EmailsClassified                 Antal email
Bucket_EmailsClassifiedUpper            Antal email
Bucket_ClassificationErrors             Antal fel
Bucket_Accuracy                         Exakthet
Bucket_ClassificationCount              Antal klassificeringar
Bucket_ResetStatistics                  Nollställ statistiken
Bucket_LastReset                        Förra nollställningen
Bucket_CurrentColor                     %s nuvarande färg är %s
Bucket_SetColorTo                       Sätt %s färgen till %s
Bucket_Maintenance                      Hantering
Bucket_CreateBucket                     Skapa hink med namnet
Bucket_DeleteBucket                     Ta bort hink med namnet
Bucket_RenameBucket                     Döp om hink
Bucket_Lookup                           Hitta
Bucket_LookupMessage                    Hitta ord i hink
Bucket_LookupMessage2                   Hitta för
Bucket_LookupMostLikely                 Det är mest sannolikt att <b>%s</b> kommer att visas i <font color=%s>%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> kommer inte att visas i någon hink
Bucket_DisabledGlobally                 Deaktivera globalt
Bucket_To					    till
Bucket_Quarantine                       Karantän

SingleBucket_Title                      Fler detaljer för %s
SingleBucket_WordCount                  Totalt antal ord i hinken
SingleBucket_TotalWordCount             Totalt antal ord
SingleBucket_Percentage                 Procent
SingleBucket_WordTable                  Ordtabell för %s
SingleBucket_Message1                   Markerat (*) ord har använts till klassifiering i denna sessionen. Tryck på ett ord för att visa dess sannolikhet i alla hinkar.
SingleBucket_Unique                     %s unique

Session_Title				Sessionen har gått ut
Session_Error				Din session har gått ut. Detta kan ha orsakats genom att starta och stänga av servern medan webläsaren har förblivit öppen. Klicka på en av länkarna ovan för att fortsätta använda webgränsnittet.