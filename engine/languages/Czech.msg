# Copyright (c) 2001-2003 John Graham-Cumming
# Translation Jan Pavloviè (xpavlov@fi.muni.cz)

# Identify the language and character set used for the interface
LanguageCode                            cz
LanguageCharset                         windows-1250

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en

# Common words that are used on their own all over the interface
Apply                                   Pouít
On                                      Zapnuté
Off                                     Vypnuté
TurnOn                                  Zapnout
TurnOff                                 Vypnout
Add                                     Pøidat
Remove                                  Odstranit
Previous                                Pøedcházející
Next                                    Nasledující
From                                    Odesilatel
Subject                                 Subjekt
Classification                          Klasifikace
Reclassify                              Rekrasifikovat
Undo                                    Vrátit
Close                                   Zavøít
Find                                    Najít
Filter                                  Filter
Yes                                     Ano
No                                      Ne
ChangeToYes                             Zmìnit na Ano
ChangeToNo                              Zmìnit na Ne
Bucket                                  Koš
Magnet                                  Magnet
Delete                                  Zmazat
Create                                  Vytvoøit
To                                      Pøíjemce
Total                                   Celkem
Rename                                  Pøejmenovat
Frequency                               Frekvence
Probability                             Pravdìpodobnost
Score                                   Hodnocení
Lookup                                  Hledání
Word                                    Slovo
Count                                   Poèet
Update                                  Aktualizovat
Refresh                                 Obnovit

# The header and footer that appear on every UI page
Header_Title                            POPFile øídící panel
Header_Shutdown                         Zastavit POPFile
Header_History                          Historie
Header_Buckets                          Koše
Header_Configuration                    Konfigurace
Header_Advanced                         Rozšíøení
Header_Security                         Bezpeènost
Header_Magnets                          Magnety

Footer_HomePage                         POPFile domovská stránka
Footer_Manual                           Manuál
Footer_Forums                           Diskuze
Footer_FeedMe                           Podpoøit
Footer_RequestFeature                   Poadavky na funkcionalitu
Footer_MailingList                      Poštovní skupina

Configuration_Error1                    Znak oddìlovaèe musí bıt jen jeden znak
Configuration_Error2                    Port uivatelského rozhraní musí bıt v rozpìtí èísel 1 a 65535
Configuration_Error3                    Port pro POP3 musí bıt v rozpìtí èísel 1 a 65535
Configuration_Error4                    Velikost stránky musí bıt v rozpìtí èísel 1 a 1000
Configuration_Error5                    Poèet dní v historii musí bıt v rozpìtí èísel 1 a 366
Configuration_Error6                    Hodnota èekání na TCP musí by v rozpìtí èísel 10 a 300
Configuration_POP3Port                  Port pro POP3
Configuration_POP3Update                Port zmìnìnı na %s; tato zmìna vstoupí v platnost a po restartu POPFile
Configuration_Separator                 Znak oddìlovaèe
Configuration_SepUpdate                 Oddìlovaè zmìnìnı na %s
Configuration_UI                        Port uivatelského rozhraní
Configuration_UIUpdate                  Port uivatelského rozhraní zmìnìnı na %s; zmìny budou patrné a po restartu
Configuration_History                   Poèet zpráv na stránku
Configuration_HistoryUpdate             Zmìnìnı poèet zpráv na stránku na %s
Configuration_Days                      Poèet dní uchování historie
Configuration_DaysUpdate                Zmìnìnı poèet dní uchování historie na %s
Configuration_UserInterface             Uivatelské rozhraní
Configuration_Skins                     Vzhled
Configuration_SkinsChoose               Zvolit vzhled
Configuration_Language                  Jazyk
Configuration_LanguageChoose            Zvolit jazyk
Configuration_ListenPorts               Porty
Configuration_HistoryView               Zobrazení historie
Configuration_POP3Separator             POP3 host:port:user oddìlovací znak
Configuration_TCPTimeout                Èekání na pøipojení TCP
Configuration_TCPTimeoutSecs            Èekání na pøipojení TCP v sekundách
Configuration_TCPTimeoutUpdate          Èekání na pøipojení TCP zmìnìné na %s
Configuration_ClassificationInsertion   Vkládání textù do zprávy
Configuration_SubjectLine               Zmìna textu subjektu
Configuration_XTCInsertion              Pøidání hlavièky X-Text-Classification
Configuration_XPLInsertion              Pøidání hlavièky X-POPFile-Link
Configuration_Logging                   Protokol zpracování
Configuration_None                      ádná
Configuration_ToScreen                  Na obrazovku
Configuration_ToFile                    Do souboru
Configuration_ToScreenFile              Na obrazovku a do souboru
Configuration_LoggerOutput              Vıstup protokolu
Configuration_GeneralSkins              Vzhled
Configuration_SmallSkins                Malı vzhled
Configuration_TinySkins                 Drobnı vzhled

Advanced_Error1                         '%s' se u nachází v seznamu Ignorovaná slova
Advanced_Error2                         Ignorovaná slova mùou obsahovat jen: alfanumerické znaky, ., _, -, @
Advanced_Error3                         '%s' pøidané do seznamu Ignorovaná slova
Advanced_Error4                         '%s' se nenachází v seznamu Ignorovaná slova
Advanced_Error5                         '%s' odstranìné ze seznamu Ignorovaná slova
Advanced_StopWords                      Ignorovaná slova
Advanced_Message1                       POPFile ignoruje nasledující, èasto pouívaná slova:
Advanced_AddWord                        Pøidat slovo
Advanced_RemoveWord                     Odstránit slovo

History_Filter                          &nbsp;(zobrazuje se jen koš <font color="%s">%s</font>)
History_FilterBy                        Filtrovat podle
History_Search                          &nbsp;(vyhledávání podle odesilatele/subjektu %s)
History_Title                           Poslední zprávy
History_Jump                            Pøejdi na zprávu
History_ShowAll                         Zobraz všechny
History_ShouldBe                        Má bıt
History_NoFrom                          prázdnı øádek odesilatele
History_NoSubject                       prázdny øádek subjektu
History_ClassifyAs                      Klasifikuj ako
History_MagnetUsed                      Pouitı magnet
History_ChangedTo                       Zmeò na <font color="%s">%s
History_Already                         U reklasifikované na <font color="%s">%s</font>
History_RemoveAll                       Odstraò všechno
History_RemovePage                      Odstraò stranu
History_Remove                          Pokud chceš smazat záznamy z historie, klikni
History_SearchMessage                   Hledej odesilatele/subjekt
History_NoMessages                      ádné zprávy
History_ShowMagnet                      zmagnetizované
History_Magnet                          &nbsp;(zobrazují se jen záznamy klasifikované magnetem)
History_ResetSearch                     Vyprázdnit

Password_Title                          Heslo
Password_Enter                          Zadej heslo
Password_Go                             Vstup!
Password_Error1                         Nesprávné heslo

Security_Error1                         Bezpeènostní port musí bıt v rozpìtí èísel 1 a 65535
Security_Stealth                        Utajenı mód/Èinnost serveru
Security_NoStealthMode                  Ne (Utajenı mód)
Security_ExplainStats                   (Pokud je toto zapnuté, POPFile pošle jednou za den následující tøi hodnoty na stránku www.usethesource.com: bc (celkovı poèet košù, které máš), mc (celkovı poèet zpráv, které POPFile klasifikoval) a ec (celkovı poèet chybnıch klasifikací).  Tyto hodnoty se ukladají do souboru a budou pouité na vyhodnocení nìkterıch statistik o tom jak lidé pouívají POPFile a jak dobøe funguje.  Mùj web server uchováva tyto informacie pøibline 5 dní a poté je smae; Neuchovávam informace propojující statistické údaje s konkrétnímy IP adresamy.)
Security_ExplainUpdate                  (pokud je toto zapnuté, POPFile pošle jedno jednou za den následující tøi hodnoty na stránku www.usethesource.com: ma (hlavní èíslo verze pouívaného POPFile), mi (vedlejší èíslo verze pouívaného POPFile) a bn (èíslo kompilace pouívaného POPFile).  POPFile dostane odpoveï ve formì obrázku, kterı se zobrazí na vrchu stránky, pokud je k dispozici nová verze.  Mùj web server uchováva tyto informacie pøibline 5 dní a poté je smae; Neuchovávam informace propojující statistické údaje s konkrétnímy IP adresamy.)
Security_PasswordTitle                  Heslo uívatelského rozhraní
Security_Password                       Heslo
Security_PasswordUpdate                 Heslo zmìnìné na %s
Security_AUTHTitle                      Bezpeèné ovìøování hesla/AUTH
Security_SecureServer                   POP3 SPA/AUTH server
Security_SecureServerUpdate             Zabezpeèenı server zmìnìnı na %s; tato zmìna vstoupí v platnost a po restartu POPFile
Security_SecurePort                     POP3 SPA/AUTH port
Security_SecurePortUpdate               Port zmìnìnı na %s; tato zmìna vstoupí v platnost a po restartu POPFile
Security_POP3                           Povol POP3 pøipojení ze vzdálenıch poèítaèù (vyaduje restart POPFile)
Security_UI                             Povol HTTP (uívatelské rozhraní) pøipojení ze vzdálenıch poèítaèù  (vyaduje restart POPFile)
Security_UpdateTitle                    Automatická kontrola novıch verzí
Security_Update                         Kontroluj dennì nové verze programu POPFile
Security_StatsTitle                     Oznamovat statistiky
Security_Stats                          Posilat statistiky dennì

Magnet_Error1                           Magnet '%s' u existuje v koši '%s'
Magnet_Error2                           Novı magnet '%s' by se bil s existujícim magnetem '%s' v koši '%s' a mohl by zpùsobit dvojsmyslné vısledky.  Novı magnet nebyl pøidanı.
Magnet_Error3                           Vytvorenı novı magnet '%s' v koši '%s'
Magnet_CurrentMagnets                   Aktuální magnety
Magnet_Message1                         Následující magnety klasifikují poštu vdy do urèeného koše.
Magnet_CreateNew                        Vytvoøi novı magnet
Magnet_Explanation                      Existují tøi typy magnetù:</b> <ul><li><b>Adresa nebo jméno odesilatele:</b> (políèko From: v pošte) Napø.: john@company.com pro konkrétní adresu, <br />company.com pro kadého odesílatele z adresy company.com, <br />John Doe pro konkrétní osobu, John pro kadného Johna</li><li><b>Adresa nebo jméno pøíjemcù:</b> To samé jako pøedchádzející, ale pro políèko To: pošty</li> <li><b>Slova v subjektu:</b> Napø.: hello zaøadí kadou poštu, která má hello v subjektu</li></ul>
Magnet_MagnetType                       Typ magnetu
Magnet_Value                            Hodnota
Magnet_Always                           Zaøadí se vdy do koše

Bucket_Error1                           Názvy košù mùou obsahovat jen znaky od a do z (malé písmo) plus - a _
Bucket_Error2                           Koš s názvem  %s u existuje
Bucket_Error3                           Vytvoøenı koš s názvem %s
Bucket_Error4                           Prosím, nezadávej prázdné názvy
Bucket_Error5                           Koš je pøejmenovanı z %s na %s
Bucket_Error6                           Zmazanı koš %s
Bucket_Title                            Prehlad
Bucket_BucketName                       Název koše
Bucket_WordCount                        Poèet slov
Bucket_WordCounts                       Poèty slov
Bucket_UniqueWords                      Jedineèná slova
Bucket_SubjectModification              Modifikace subjektu
Bucket_ChangeColor                      Zmìna barvy
Bucket_NotEnoughData                    Nedostatek údajù
Bucket_ClassificationAccuracy           Pøesnost klasifikace
Bucket_EmailsClassified                 Klasifikovaná pošta
Bucket_EmailsClassifiedUpper            Klasifikovaná pošta
Bucket_ClassificationErrors             Chyby klasifikace
Bucket_Accuracy                         Pøesnost
Bucket_ClassificationCount              Poèty klasifikace
Bucket_ResetStatistics                  Vynulování statistiky
Bucket_LastReset                        Poslední vynulování
Bucket_CurrentColor                     aktuální bavba %s je %s
Bucket_SetColorTo                       Nastav barvu %s na %s
Bucket_Maintenance                      Údrba
Bucket_CreateBucket                     Vytvoø koš s názvem
Bucket_DeleteBucket                     Sma koš s názvem
Bucket_RenameBucket                     Pøejmenuj koš s názvem
Bucket_Lookup                           Vyhledávání
Bucket_LookupMessage                    Vyhledávání slova v koších
Bucket_LookupMessage2                   Vısledek hledání pro
Bucket_LookupMostLikely                 <b>%s</b> se najèastìji nachází v koši <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> se nenachází v ani jednom koši
Bucket_DisabledGlobally                 Globální vypnutí
Bucket_To                               na
Bucket_Quarantine                       Karanténa

SingleBucket_Title                      Detail pro %s
SingleBucket_WordCount                  Poèet slov v koši
SingleBucket_TotalWordCount             Celkovı poèet slov
SingleBucket_Percentage                 Procento z celku
SingleBucket_WordTable                  Tabulka slov pro %s
SingleBucket_Message1                   Slová oznaèená s (*) byla pouita na klasifikaci v prùbìhu aktuálního spustìní POPFile.  Klikni na kterékoli slovo, pokud chceš vidìt jeho vıskyt ve všech koších.
SingleBucket_Unique                     %s jedineènıch

Session_Title                           Platnost POPFile session vypršela
Session_Error                           Platnost POPFile session vypršela.  Mohlo to nastat vypnutím a zapnutím POPFile, pøièem si nechal otevøenı webovı prohlíeè.  Prosím, pokud chceš pokraèovat v práci s POPFile, kliknite na nìkterı z vrchních linek.


Header_MenuSummary                      Tato tabulka je navigaèní menu, které zpøístupòuje všechny ostatní stránky øídícího panelu.
History_MainTableSummary                Tato tabulka zobrazuje odesílatele a subjekty aktuálnì pøijatıch zpráv a umoòuje jich rozdìlit a klasifikovat.  Kliknutím na text subjektu se zobrazí znìní zprávy, spolu s informací proè byla klasifikována tak, jak byla.  Stoupec 'Má bıt' umoòuje urèi, do kterého koše zpráva patøí, anebo zrušit tuhle zmìnu.  Stoupec 'Odstranit' umoòuje smazat danou správu z historie, pokud ji ji nepotøebuješ.
History_OpenMessageSummary              Tato tabulka obsahuje celı text zprávy, spolu se zvıraznìnımi slovy, které byly pouité pøi klasifiksci do daného koše.
Bucket_MainTableSummary                 Tato tabulka obsahuje prehled klasifikaèních košù.  Kadı øádek zobrazuje název koše, celkovı poèet slov v tomto koši, aktuální poèet individuálních slov v kadém koši, zdali bude text subjektu zprávy zmìnìnı pokud bude zpráva klasifikována, èi zaøadit zprávy v tomto koši do karantény a tabulku, kde se dá vybrat barva kterou se bude zobrazovat všechno na øídícím panelu, tıkající se tohoto koše.
Bucket_StatisticsTableSummary           Tato tabulka poskytuje tøi atatistické pøehtedy o vıkonu POPFile.  První zobrazuje pøesnost klasifikace, druhı kolik zpráv bylo klasifikovanıch a do kterıch košù a tøetí zobrazuje kolik slov obsahuje kterı koš a jaké je jejich relativní procentuální zastoupení.
Bucket_MaintenanceTableSummary          Tato tabulka obsahuje formuláøe, které umonují vytvoøit, smazat a nebo pøejmenovat koše a vyhledat zastoupení slova ve všech koších a jeho relativní vıskyt.
Bucket_AccuracyChartSummary             Tato tabulka graficky zobrazuje pøesnost klasifikace zpráv.
Bucket_BarChartSummary                  Tato tabulka graficky zobrazuje procentuální zaplnìní jednotlivıch košù.  Je pouitá zároveò pro poèet klasifikovanıch zpráv a celkovı poèet slov.
Bucket_LookupResultsSummary             Tato tabulka zobrazuje pravdìpodobnost pøiøazenou k jednotlivım slovùm v korpuse.  Pro kadı koš zobrazuje frekvenci vıskytu slova, pravdìpodobnost s jakou se vyskytuje v koši a celkovı vliv slova na zaøazaní zprávy do koše pokud se v ní dané slovo vyskytuje.
Bucket_WordListTableSummary             Tato tabulka zobrazuje seznam všech slov pro koš, slová jsou seøazebá podle poèáteèních znakù pro kadı øádek.
Magnet_MainTableSummary                 Tato tabulka zobrazuje seznam magnetù, které jsou pouívané na automatické klasifikováníe zpráv podle pøesnıch pravidel.  Kadı øádek zobrazuje jak je magnet definovanı, pro kterı koš slouí a tlaèítko na smazaní magnetu.
Configuration_MainTableSummary          Tato tabulka obsahuje formuláøe které umoòují konfigurovat POPFile.
Configuration_InsertionTableSummary     Tato tabulka obsahuje tlaèítka, které urèují zdali se mají a nebo nemají vykonat nìkteré zmìny v záhlaví èi v textu subjektu zprávy døíve, ne se pøedá e-mailovému klientovi.
Security_MainTableSummary               Tato tabulka poskytuje nìkolik nastavení, které ovlivòují bezpeènost celé konfigurace POPFile, zdali se má vykonávat automatická kontrola existence zmìn programu a zdali se má zasílat statistika zpracování do centrální databáze autora programu.
Advanced_MainTableSummary               Tato tabulka zobrazuje seznam slov, které POPFile ignoruje pøi klasifikování zpráv z dùvodu jejich relativnì èastého vıskytu ve všech zprávach. Jsou zobrazené v øádcích v závislosti podle prvního znaku.


