# Copyright (c) 2001-2003 John Graham-Cumming

# Identify the language and character set used for the interface
LanguageCode                            hu
LanguageCharset                         ISO-8859-2

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          hu

# Common words that are used on their own all over the interface
Apply                                   Alkalmaz
On                                      Be
Off                                     Ki
TurnOn                                  Bekapcsol
TurnOff                                 Kikapcsol
Add                                     Hozzáad
Remove                                  Elvesz
Previous                                Elõzõ
Next                                    Következõ
From                                    Feladó
Subject                                 Téma
Classification                          Osztályozás
Reclassify                              Újraosztályoz
Undo                                    Undo
Close                                   Bezár
Find                                    Keres
Filter                                  Szûrõ
Yes                                     Igen
No                                      Nem
ChangeToYes                             Kapcsold Igen-re
ChangeToNo                              Kapcsold Nem-re
Bucket                                  Tartály
Magnet                                  Mágnes
Delete                                  Töröl
Create                                  Létrehoz
To                                      Cimzett
Total                                   Összesités
Rename                                  Átnevez
Frequency                               Frekvencia
Probability                             Valószinûség
Score                                   Pontszám
Lookup                                  Lookup

# The header and footer that appear on every UI page
Header_Title                            POPFile Vezérlõközpont
Header_Shutdown                         Shutdown POPFile
Header_History                          History
Header_Buckets                          Tartályok
Header_Configuration                    Beállitások
Header_Advanced                         Haladó
Header_Security                         Biztonság
Header_Magnets                          Mágnesek

Footer_HomePage                         POPFile Honlap
Footer_Manual                           Kézikönyv
Footer_Forums                           Fórumok
Footer_FeedMe                           Adj enni!
Footer_RequestFeature                   Tulajdonság kérése
Footer_MailingList                      Levlista

Configuration_Error1                    Az elválasztó karakter nem lehet hosszabb 1 karakternél
Configuration_Error2                    A felhasználói interfész port egy szám kell hogy legyen 1 és 65535 között.
Configuration_Error3                    A POP3 port egy szám kell hogy legyen 1 és 65535 között.
Configuration_Error4                    A lapszám egy szám kell hogy legyen 1 és 1000 között.
Configuration_Error5                    A history-ban lévõ napok száma egy szám kell hogy legyen 1 és 366 között.
Configuration_Error6                    A TCP idõtúllépés egy szám kell hogy legyen 10 és 300 között.
Configuration_POP3Port                  POP3 figyelõ port
Configuration_POP3Update                Az új port: %s; A változtatás életbeléptetéséhez újra kell inditanod POPFile-t.
Configuration_Separator                 Elválasztó karakter
Configuration_SepUpdate                 Az új elválasztó karakter: %s
Configuration_UI                        Felhasználói interfész web port
Configuration_UIUpdate                  Az új felhasználói interfész web port %s; A változtatás életbeléptetéséhez újra kell inditanod POPFile-t.
Configuration_History                   Egy lapon lévõ emailek száma
Configuration_HistoryUpdate             Az egy lapon lévõ emailek száma megváltozott: %s
Configuration_Days                      A history-ban megõrizendõ napok száma
Configuration_DaysUpdate                A history-ban megõrizendõ napok számának új értéke: %s
Configuration_UserInterface             Felhasználói felület
Configuration_Skins                     Skinek
Configuration_SkinsChoose               Válassz skin-t
Configuration_Language                  Nyelv
Configuration_LanguageChoose            Válassz nyelvet
Configuration_ListenPorts               Figyelj portokon
Configuration_HistoryView               History Nézet
Configuration_TCPTimeout                TCP Kapcsolat Timeout
Configuration_TCPTimeoutSecs            TCP kapcsolat timeout másodpercekben
Configuration_TCPTimeoutUpdate          A TCP kapcsolat timeout új értéke: %s
Configuration_ClassificationInsertion   Osztályozás beillesztés
Configuration_SubjectLine               Beillesztés az email témájába
Configuration_XTCInsertion              X-Text-Classification alkalmazása
Configuration_XPLInsertion              X-POPFile-Link beillesztése
Configuration_Logging                   Naplózás
Configuration_None                      Nincs
Configuration_ToScreen                  Képernyõre
Configuration_ToFile                    Fájlba
Configuration_ToScreenFile              Képernyõre és fájlba
Configuration_LoggerOutput              Naplózó kimenet

Advanced_Error1                         '%s' már hozzá lett adva a blokkoló szavakhoz
Advanced_Error2                         A figyelmen kivül hagyott szavak csak betûket, számokat és a következõ karaktereket tartalmayhatják:, ., _, -, @
Advanced_Error3                         '%s' hozzáadva a blokkolt szavak listájához
Advanced_Error4                         '%s' nincs a blokkolt szavak között
Advanced_Error5                         '%s' törölve a blokkolt szavak közúl
Advanced_StopWords                      Figyelmen kivûl hagyott szavak
Advanced_Message1                       A következõ szavak minden osztályozásból ki fognak maradni, mivel túl sûrûn fordulnak elõ.
Advanced_AddWord                        Szó hozzáadása
Advanced_RemoveWord                     Szó törlése

History_Filter                          &nbsp;(csak a <font color=%s>%s</font> konténer tartalma látható)
History_Search                          &nbsp;(Találatok %s témára)
History_Title                           Utoljára beérkezett üzenetek
History_Jump                            Üzenetre ugrás
History_ShowAll                         Mutasd mindet
History_ShouldBe                        Kellene lennie
History_NoFrom                          nincs feladó
History_NoSubject                       nincs téma
History_ClassifyAs                      Osztályozd mint
History_MagnetUsed                      Eltéritõ mágnes:
History_ChangedTo                       Új érték: <font color=%s>%s
History_Already                         Újraosztályozva mint <font color=%s>%s</font>
History_RemoveAll                       Mindet töröl
History_RemovePage                      Töröld ezt az oldalt
History_Remove                          Klikkelj hogy töröld a bejegyzéseket a History-ból
History_SearchMessage                   Keress feladó/téma alapján
History_NoMessages                      Nincs üzenet
History_ShowMagnet                      Mágnesezett
History_Magnet                          &nbsp;(Csak mágnesek által osztályozott üzenetek látszanak)
History_ResetSearch                     Nullázás

Password_Title                          Jelszó
Password_Enter                          Ird be a jelszót
Password_Go                             Mehet!
Password_Error1                         Rossz jelszó

Security_Error1                         A secure port egy szám kell hogy legyen 1 és 65535 között
Security_Stealth                        Lopakodó (Stealth) Üzemmód/Szerver Múködés
Security_NoStealthMode                  Nem (Stealth Üzemmód)
Security_ExplainStats                   (Ha ez be van kapcsolva, akkor a POPFile naponta egyszer elküldi a következõ 3 változó értékét egy script-nek a www.usethesource.com-ra: bc (a konténerek száma) mc (a POPFile által osztályozott üzenetek száma) ec (az osztályozási hibák száma). Ezeket az adatokat egy állomámyban tartom, és arra használom õket hogy néhány statisztikai adatok publikáljak a POPFile hatékonyságáról és arról hogy az emberek hogyan hasynálják a programot. A Web szerverem kb. 5 napig õrzi meg az információt, majd törli. Nem tárolok semmiféle kapcsolatot a begyûjtött adatok és az IP cimek között.)
Security_ExplainUpdate                  (Ha ez be van kapcsolva, akkor a POPFile naponta egyszer elküldi a következõ 3 változó értékét egy script-nek a www.usethesource.com-ra: ma (az általad használt POPFile fõ verziószáma) mi (az általad használt POPFile al-verziószáma) bn (az általad használt POPFile build száma). Az általad használt POPFile kapni fog egy grafikát a szervertõl, ami a lap tetején lesz látható ha egy újabb verzió elérhetõ. Ezeket az adatokat egy állomámyban tartom, és arra használom õket hogy néhány statisztikai adatok publikáljak a POPFile hatékonyságáról és arról hogy az emberek hogyan hasynálják a programot. A Web szerverem kb. 5 napig õrzi meg az információt, majd törli. Nem tárolok semmiféle kapcsolatot a begyûjtött adatok és az IP cimek között.) 
Security_PasswordTitle                  Felhaszálói felület jelszó
Security_Password                       Jelszó
Security_PasswordUpdate                 Az új jelszó: %s
Security_AUTHTitle                      Secure Password Authentication/AUTH
Security_SecureServer                   Secure szerver
Security_SecureServerUpdate             Az új secure szerver: %s; Ez a változás nem fog érvénybe lépni amig ujra nem inditod a POPFile-t.
Security_SecurePort                     Secure port
Security_SecurePortUpdate               Az új port: %s; Ez a változás nem fog érvénybe lépni amig ujra nem inditod a POPFile-t.
Security_POP3                           POP3 kapcsolat engedélyezése távoli gépekkel
Security_UI                             HTTP (Felhasználói felület) engedélyezése távoli gépekkel
Security_UpdateTitle                    Automatikus új verzió ellenõrzés
Security_Update                         Naponta ellenõrizze hogy van-e új POPFile verzió
Security_StatsTitle                     Statisztika küldése
Security_Stats                          Küldd el a statisztikákat Johnünak minden nap

Magnet_Error1                           A mágnes '%s' már létezik a '%s' konténerben
Magnet_Error2                           Az új mágnes '%s' összeragadhat a '%s' mágnessel és hibás eredményeket okozhat a '%s' konténerben. Az új mágnes nem lett hozzáadva a rendszerhez.
Magnet_Error3                           Hozd létre a '%s' mágnest a '%s' konténerben.
Magnet_CurrentMagnets                   Mágnesek
Magnet_Message1                         A következõ mágnes minden egyes levelet a megadott konténerbe fog irányitani.
Magnet_CreateNew                        Hozz létre új mágnest
Magnet_Explanation                      Három fajta mágnes létezik:</b> <ul><li><b>Feladó cime vagy neve:</b> Például: john@company.com, ha egy bizonyos email cimet keresünk<br>company.com ha mindenkit meg akarunk találni aki a company.com cimrõl jön, <br>"John Doe" ha egy bizonyos embert akarunk kiszûrni, John meg fog találni minden John-t<li><b>Cimyett cime vagy neve:</b> Ugyanaz mint a Feladó, de ez a Cimzett nevében és cimében keres.<li><b>Téma:</b> Például: hello meg fog találni minden email-t aminek a szó "hello" a témájában szerepel</ul>
Magnet_MagnetType                       Mágnes tipus
Magnet_Value                            Érték
Magnet_Always                           Mindig a konténerbe megy

Bucket_Error1                           Konténer nevek csak kisbetûket tartalmazhatnak a-tól z-ig, valamint a - és _ jeleket
Bucket_Error2                           Már létezik egy %s nevû konténer
Bucket_Error3                           A %s nevû konténer létrehozva
Bucket_Error4                           Kérem adjon meg egy nem-üres szót
Bucket_Error5                           Konténer átnevezve %-ról %s-ra
Bucket_Error6                           A %s nevû konténert töröltem
Bucket_Title                            Összefoglaló
Bucket_BucketName                       Konténer név
Bucket_WordCount                        Szavak száma
Bucket_WordCounts                       Szavak számai
Bucket_UniqueWords                      Egyedi szavak
Bucket_SubjectModification              Téma megváltoztatás
Bucket_ChangeColor                      Szin megváltoztatása
Bucket_NotEnoughData                    Nincs elég adat
Bucket_ClassificationAccuracy           Az osztályozás pontossága
Bucket_EmailsClassified                 Osztályozott Emailek száma
Bucket_EmailsClassifiedUpper            Osztályozott Emailek száma
Bucket_ClassificationErrors             Osztályozási hibák
Bucket_Accuracy                         Pontosság
Bucket_ClassificationCount              Osztályozások száma
Bucket_ResetStatistics                  Statisztika nullázása
Bucket_LastReset                        Utolsó nullázás
Bucket_CurrentColor                     %s a jelenlgi szin %s
Bucket_SetColorTo                       %s szin %s-ra állitása
Bucket_Maintenance                      Karbantartás
Bucket_CreateBucket                     Konténer létrehozása:
Bucket_DeleteBucket                     Konténer törlése:
Bucket_RenameBucket                     Konténer átnevezése:
Bucket_Lookup                           Keresés
Bucket_LookupMessage                    Szó keresése a konténerekben
Bucket_LookupMessage2                   Keresés eredménye:
Bucket_LookupMostLikely                 <b>%s</b> legvalószinûbben a következõ helyen fog megjelenni: <font color=%s>%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> egyik konténerben sem található
Bucket_DisabledGlobally                 Globálisan letiltott
Bucket_To                               to
Bucket_Quarantine                       Karantén

SingleBucket_Title                      %s részletei
SingleBucket_WordCount                  Konténerben lévõ szavak száma
SingleBucket_TotalWordCount             Összes szó száma
SingleBucket_Percentage                 Teljes százalék
SingleBucket_WordTable                  Szótáblázat % -nak
SingleBucket_Message1                   A csillaggal jelölt szavak(*) részt vettek az osztályzásban a POPFile legutóbbi inditása óta. Kattints egy szóra hogy megnézd a konténerenkénti valószinûségét.
SingleBucket_Unique                     %s egyedi

Session_Title                           POPFile Session Lejárt
Session_Error                           Ez a POPFile session lejárt.  Egy lehetséges ok hogy elinditotta és leállitotta a POPFile-t, de a böngészõt nyitva hagyta. Kérem kattintson a felül lévõ linkek egyikére.
