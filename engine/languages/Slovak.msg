# Copyright (c) 2001-2003 John Graham-Cumming
# Translation Martin Minka (support@k2s.sk)

# Identify the language and character set used for the interface
LanguageCode                            sk
LanguageCharset                         windows-1250

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en

# Common words that are used on their own all over the interface
Apply                                   Poui
On                                      Zapnuté
Off                                     Vypnuté
TurnOn                                  Zapnú
TurnOff                                 Vypnú
Add                                     Prida
Remove                                  Odstráni
Previous                                Predchádzajúci
Next                                    Nasledujúci
From                                    Odosielate¾
Subject                                 Subjekt
Classification                          Klasifikácia
Reclassify                              Preklasifikovanie
Undo                                    Vráti
Close                                   Zatvori
Find                                    Nájs
Filter                                  Filter
Yes                                     Áno
No                                      Nie
ChangeToYes                             Zmeni na Áno
ChangeToNo                              Zmeni na Nie
Bucket                                  Kôš
Magnet                                  Magnet
Delete                                  Zmaza
Create                                  Vytvori
To                                      Príjemca
Total                                   Celkom
Rename                                  Premenova
Frequency                               Frekvencia
Probability                             Pravdepodobnos
Score                                   Hodnotenie
Lookup                                  H¾adanie

# The header and footer that appear on every UI page
Header_Title                            POPFile riadiaci panel
Header_Shutdown                         Zastavi POPFile
Header_History                          História
Header_Buckets                          Koše
Header_Configuration                    Konfigurácia
Header_Advanced                         Rozšírené
Header_Security                         Bezpeènos
Header_Magnets                          Magnety

Footer_HomePage                         POPFile domovská stránka
Footer_Manual                           Manuál
Footer_Forums                           Diskusie
Footer_FeedMe                           Podpori
Footer_RequestFeature                   Poiadavka na funkcionalitu
Footer_MailingList                      Poštová skupina

Configuration_Error1                    Znak oddelovaèa musí by len jeden znak
Configuration_Error2                    Port uívate¾ského rozhrania musí by v rozpätí èísel 1 a 65535
Configuration_Error3                    Port pre POP3 musí by v rozpätí èísel 1 a 65535
Configuration_Error4                    Ve¾kos stránky musí by v rozpätí èísel 1 a 1000
Configuration_Error5                    Poèet dní v histórii musí by v rozpätí èísel 1 a 366
Configuration_Error6                    Hodnota èakania na TCP musí by v rozpätí èísel 10 a 300
Configuration_POP3Port                  Port pre POP3
Configuration_POP3Update                Port zmenenı na %s; this change will not take affect until you restart POPFile
Configuration_Separator                 Znak oddelovaèa
Configuration_SepUpdate                 Oddelovaè zmenenı na %s
Configuration_UI                        Port uívate¾ského rozhrania
Configuration_UIUpdate                  Port uívate¾ského rozhrania zmenenı na %s; this change will not take affect until you restart POPFile
Configuration_History                   Poèet správ na stránku
Configuration_HistoryUpdate             Zmenenı poèet správ na stránku na %s
Configuration_Days                      Poèet dní uchovania histórie
Configuration_DaysUpdate                Zmenenı poèet dní uchovania histórie na %s
Configuration_UserInterface             Uívate¾ské rozhranie
Configuration_Skins                     Vzh¾ad
Configuration_SkinsChoose               Zvol vzh¾ad
Configuration_Language                  Jazyk
Configuration_LanguageChoose            Zvol jazyk
Configuration_ListenPorts               Porty
Configuration_HistoryView               Zobrazenie histórie
Configuration_TCPTimeout                Èakanie na pripojenie TCP
Configuration_TCPTimeoutSecs            Èakanie na pripojenie TCP v sekundách
Configuration_TCPTimeoutUpdate          Èakanie na pripojenie TCP zmenené na %s
Configuration_ClassificationInsertion   Vkladanie textov do správy
Configuration_SubjectLine               Zmena textu subjektu
Configuration_XTCInsertion              Pridanie hlavièky X-Text-Classification
Configuration_XPLInsertion              Pridanie hlavièky X-POPFile-Link
Configuration_Logging                   Protokol spracovania
Configuration_None                      iadny
Configuration_ToScreen                  Na obrazovku
Configuration_ToFile                    Do súboru
Configuration_ToScreenFile              Na obrazovku a do súboru
Configuration_LoggerOutput              Vıstup protokolu
Configuration_GeneralSkins              Vzh¾ad
Configuration_SmallSkins                Malı vzh¾ad
Configuration_TinySkins                 Drobnı vzh¾ad

Advanced_Error1                         '%s' sa u nachádza v zozname Ignorované slová
Advanced_Error2                         Ignorované slová môu obsahova len: alfanumerické znaky, ., _, -, @
Advanced_Error3                         '%s' pridané do zoznamu Ignorované slová
Advanced_Error4                         '%s' sa nenachádza v zozname Ignorované slová
Advanced_Error5                         '%s' odstránené zo zoznamu Ignorované slová
Advanced_StopWords                      Ignorované slová
Advanced_Message1                       POPFile ignoruje nasledovné, èasto pouívané slová:
Advanced_AddWord                        Prida slovo
Advanced_RemoveWord                     Odstráni slovo

History_Filter                          &nbsp;(zobrazuje sa len kôš <font color="%s">%s</font>)
History_FilterBy                        Filtrova pod¾a
History_Search                          &nbsp;(vyh¾adané pod¾a odosielate¾a/subjektu %s)
History_Title                           Posledné správy
History_Jump                            Prejdi na správu
History_ShowAll                         Zobraz všetky
History_ShouldBe                        Má by
History_NoFrom                          prazdny riadok odosielate¾a
History_NoSubject                       prazdny riadok subjektu
History_ClassifyAs                      Klasifikuj ako
History_MagnetUsed                      Pouitı magnet
History_ChangedTo                       Zmeò na <font color="%s">%s
History_Already                         U reklasifikované na <font color="%s">%s</font>
History_RemoveAll                       Odstráò všetko
History_RemovePage                      Odstáò stranu
History_Remove                          Ak chceš zmaza záznamy z histórie, klikni
History_SearchMessage                   H¾adaj odosielate¾a/subjekt
History_NoMessages                      iadne správy
History_ShowMagnet                      zmagnetizované
History_Magnet                          &nbsp;(zobrazujú sa len záznamy klasifikované magnetom)
History_ResetSearch                     Vyprázdni

Password_Title                          Heslo
Password_Enter                          Zadaj heslo
Password_Go                             Vstúp!
Password_Error1                         Nesprávne heslo

Security_Error1                         Bezpeènostnı port musí by v rozpätí èísel 1 a 65535
Security_Stealth                        Utajenı mód/Èinnos servera
Security_NoStealthMode                  Nie (Utajenı mód)
Security_ExplainStats                   (Ak je toto zapnuté, POPFile pošle raz za deò nasledovné tri hodnoty na stránku www.usethesource.com: bc (celkovı poèet košov, ktoré máš), mc (celkovı poèet správ, ktoré POPFile klasifikoval) a ec (celkovı poèet chybnıch klasifikácii).  Tieto hodnoty sa ukladajú do súboru a budú pouité na vyhodnotenie niektorıch štatistík o tom ako ¾udia pouívajú POPFile a ako dobre funguje.  Môj web server uchováva tieto informácie pribline 5 dní a potom ich zmae; Neuchovávam informácie prepojujúce štatistické údaje s konkrétnymi IP adresami.)
Security_ExplainUpdate                  (Ak je toto zapnuté, POPFile pošle raz za deò nasledovné tri hodnoty na stránku www.usethesource.com: ma (hlavné èíslo verzie pouívaného POPFile), mi (ved¾ajšie èíslo verzie pouívaného POPFile) a bn (èíslo kompilácie pouívaného POPFile).  POPFile dostane odpoveï vo forme obrázku, ktorı sa zobrazí na vrchu stránku, ak je k dispozícii nová verzia.  Môj web server uchováva tieto informácie pribline 5 dní a potom ich zmae; Neuchovávam informácie prepojujúce štatistické údaje s konkrétnymi IP adresami.)
Security_PasswordTitle                  Heslo uívate¾ského rozhrania
Security_Password                       Heslo
Security_PasswordUpdate                 Heslo zmenené na %s
Security_AUTHTitle                      Bezpeèné overovanie hesla/AUTH
Security_SecureServer                   Bezpeènostnı server
Security_SecureServerUpdate             Bezpeènostnı server zmenenı na %s; táto zmena vstúpi do platnosti a po reštarte POPFile
Security_SecurePort                     Bezpeènostnı port
Security_SecurePortUpdate               Port zmenenı na %s; táto zmena vstúpi do platnosti a po reštarte POPFile
Security_POP3                           Povo¾ POP3 pripojenia zo vzdialenıch poèítaèov (vyaduje reštart POPFile)
Security_UI                             Povo¾ HTTP (uívate¾ské rozhranie) pripojenia zo vzdialenıch poèítaèov  (vyaduje reštart POPFile)
Security_UpdateTitle                    Automatická kontrola novıch verzií
Security_Update                         Kontroluj denne nové verzie programu POPFile
Security_StatsTitle                     Oznamova štatistiky
Security_Stats                          Posiela štatistiky denne

Magnet_Error1                           Magnet '%s' u existuje v koši '%s'
Magnet_Error2                           Novı magnet '%s' by sa bil s existujúcim magnetom '%s' v koši '%s' a mohol by spôsobova dvojzmyselné vısledky.  Novı magnet nebol pridanı.
Magnet_Error3                           Vytvorenı novı magnet '%s' v koši '%s'
Magnet_CurrentMagnets                   Aktuálne magnety
Magnet_Message1                         Nasledovné magnety klasifikujú poštu vdy do urèeného koša.
Magnet_CreateNew                        Vytvori novı magnet
Magnet_Explanation                      Existujú tri typy magnetov:</b> <ul><li><b>Adresa alebo meno odosielae¾a:</b> (políèko From: v pošte) Napr.: john@company.com pre konkrétnu adresu, <br />company.com pre kadého odosielate¾a z adresy company.com, <br />John Doe pre konkrétnu osobu, John pre kadného Johna</li><li><b>Adresa alebo meno príjemcu:</b> To isté ako predchádzajúce, ale pre políèko To: pošty</li> <li><b>Slová v subjekte:</b> Napr.: hello zaradí kadú poštu, ktorá má hello v subjekte</li></ul>
Magnet_MagnetType                       Typ magnetu
Magnet_Value                            Hodnota
Magnet_Always                           Zaradí sa vdy do koša

Bucket_Error1                           Názvy košov môu obsahova len znaky od a do z (malé písmo) plus - a _
Bucket_Error2                           Kôš s názvom  %s u existuje
Bucket_Error3                           Vytvorenı kôš s názvom %s
Bucket_Error4                           Prosím, nezadávaj prázdne názvy
Bucket_Error5                           Kôš je premenovanı z %s na %s
Bucket_Error6                           Zmazanı kôš %s
Bucket_Title                            Preh¾ad
Bucket_BucketName                       Názov koša
Bucket_WordCount                        Poèet slov
Bucket_WordCounts                       Poèty slov
Bucket_UniqueWords                      Jedineèné slová
Bucket_SubjectModification              Modifikácia subjektu
Bucket_ChangeColor                      Zmena farby
Bucket_NotEnoughData                    Nedostatok údajov
Bucket_ClassificationAccuracy           Presnos klasifikácie
Bucket_EmailsClassified                 Klasifikovaná pošta
Bucket_EmailsClassifiedUpper            Klasifikovaná pošta
Bucket_ClassificationErrors             Chyby klasifikácie
Bucket_Accuracy                         Presnos
Bucket_ClassificationCount              Poèty klasifikácie
Bucket_ResetStatistics                  Vynulovanie štatistiky
Bucket_LastReset                        Posledné vynulovanie
Bucket_CurrentColor                     aktuálna farba %s je %s
Bucket_SetColorTo                       Nastav farbu %s na %s
Bucket_Maintenance                      Údrba
Bucket_CreateBucket                     Vytvor kôš s názvom
Bucket_DeleteBucket                     Zma kôš s názvom
Bucket_RenameBucket                     Premenuj kôš s názvom
Bucket_Lookup                           Vyh¾adanie
Bucket_LookupMessage                    Vyh¾adaj slovo v košoch
Bucket_LookupMessage2                   Vısledok h¾adania pre
Bucket_LookupMostLikely                 <b>%s</b> sa najèastejšie nachádza v koši <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> sa nenachádza v ani jednom koši
Bucket_DisabledGlobally                 Globálne vypnuté
Bucket_To                               na
Bucket_Quarantine                       Karanténa

SingleBucket_Title                      Detail pre %s
SingleBucket_WordCount                  Poèet slov v koši
SingleBucket_TotalWordCount             Celkovı poèet slov
SingleBucket_Percentage                 Percento z celku
SingleBucket_WordTable                  Tabu¾ka slov pre %s
SingleBucket_Message1                   Slová oznaèené s (*) boli pouité na klasifikáciu poèas aktuálneho spustenia POPFile.  Klikni na ktoréko¾vek slovo, ak chceš vidie jeho vıskyt vo všetkıch košoch.
SingleBucket_Unique                     %s jedineènıch

Session_Title                           POPFile session has expired
Session_Error                           Your POPFile session has expired.  Mohlo to nasta vypnutím a zapnutím POPFile, prièom ste nechali otvorenı web browser.  Prosím, ak chcete pokraèova v práci s POPFile, kliknite na niektorú z vrchnıch liniek.


Header_MenuSummary                      Táto tabu¾ka je navigaèné menu, ktoré sprístupòuje všetky ostatné stránky riadiaceho panelu.
History_MainTableSummary                Táto tabu¾ka zobrazuje odosielate¾ov a subjekty aktuálne prijatıch správ a umonuje ich prezera a klasifikova.  Kliknutím na text subjektu sa zobrazí znenie správy, spolu s informáciou preèo bola klasifikovaná tak, ako bola.  Ståpec 'Má by' umoòuje urèi, do ktorého koša správa patrí, alebo zruši takúto zmenu.  Ståpec 'Odstráni' ti umoòuje zmaza danú správu z histórie, ak ju viac nepotrebuješ.
History_OpenMessageSummary              Táto tabu¾ka obsahuje celı text správy, spolu so zvıraznenımi slovami, ktoré boli pouité pri klasifikácii do daného koša.
Bucket_MainTableSummary                 Táto tabu¾ka obsahuje preh¾ad klasifikaènıch košov.  Kadı riadok zobrazuje názov koša, celkovı poèet slov v tomto koši, aktuálny poèet individuálnych slov v kadom koši, èi bude text subjektu správy zmenenı ak bude správa klasifikovaná, èi zaradi správy v tomto koši do karantény a tabu¾ku, kde sa dá vybra farba ktoru sa bude zobrazova všetko na riadiacom panely, tıkajúce sa tohto koša.
Bucket_StatisticsTableSummary           Táto tabu¾ka ponúka tri štatistické preh¾ady o vıkone POPFile.  Prvı zobrazuje presnos klasifikácie, druhı ko¾ko správ bolo klasifikovanıch a do ktorıch košov a tretí zobrazuje ko¾ko slov obsahuje ktorı kôš a aké je ich relatívne percentuálne zastúpenie.
Bucket_MaintenanceTableSummary          Táto tabu¾ka obsahuje formuláre, ktoré ti umonujú vytvori, zmaza alebo premenova koše a vyh¾ada zastúpenie slova vo všetkıch košoch a jeho relatívne zastúpenie.
Bucket_AccuracyChartSummary             Táto tabu¾ka graficky zobrazuje  presnos klasifikácie správ.
Bucket_BarChartSummary                  Táto tabu¾ka graficky zobrazuje percentuálne zaplnenie jednotlivıch košov.  Je pouitá zároveò pre poèet klasifikovanıch správ a celkovı poèet slov.
Bucket_LookupResultsSummary             Táto tabu¾ka zobrazuje pravdepodobnos priradenú k jednotlivım slovám v korpuse.  Pre kadı kôš zobrazuje frekvenciu vıskytu slova, pravdepodobnos s akou sa vyskytuje v koši a celkovı vplyv slova na zaradenie správy do koša ak sa v nej dané slovo vyskytuje.
Bucket_WordListTableSummary             Táto tabu¾ka zobrazuje zoznam všetkıch slov pre kôš, slová sú zoradené pod¾a zaèiatoènıch znakov po riadkoch.
Magnet_MainTableSummary                 Táto tabu¾ka zobrazuje zoznam magnetov, ktoré sú pouívané na automatické klasifikovanie správ pod¾a presnıch pravidiel.  Kadı riadok zobrazuje ako je magnet definovanı, pre ktorı kôš slúi a tlaèidlo na zmazanie magnetu.
Configuration_MainTableSummary          Táto tabu¾ka obsahuje formuláre ktoré ti umoòujú konfigurova POPFile.
Configuration_InsertionTableSummary     Táto tabu¾ka obsahuje tlaèidlá, ktoré urèujú èi sa majú alebo nemajú vykona niektoré zmeny v záhlaví alebo texte subjektu správy skôr, ako sa posunie k poštovému klientovi.
Security_MainTableSummary               Táto tabu¾ka poskytuje nieko¾ko nastavení, ktoré ovplyvòujú bezpeènos celkovej konfigurácie POPFile, èi sa má vykonáva automatická kontrola existencie zmien programu a èi sa má zasiela štatistika spracovania do centrálnej databázy autora programu.
Advanced_MainTableSummary               Táto tabu¾ka zobrazuje zoznam slov, ktoré POPFile ignoruje pri klasifikovaní správ z dôvodu ich relatívne èastého vıskytu vo všeobecnıch správach. Sú zobrazené v riadkoch v závislosti od prvého znaku.


