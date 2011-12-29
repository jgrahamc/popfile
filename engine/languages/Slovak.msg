# Copyright (c) 2001-2011 John Graham-Cumming
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify it
#   under the terms of version 2 of the GNU General Public License as
#   published by the Free Software Foundation.
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
# Translation Martin Minka (support@k2s.sk)

# Identify the language and character set used for the interface
LanguageCode                            sk
LanguageCharset                         windows-1250
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en

# Common words that are used on their own all over the interface
Apply                                   Použiť
On                                      Zapnuté
Off                                     Vypnuté
TurnOn                                  Zapnúť
TurnOff                                 Vypnúť
Add                                     Pridať
Remove                                  Odstrániť
Previous                                Predchádzajúci
Next                                    Nasledujúci
From                                    Odosielateľ
Subject                                 Subjekt
Classification                          Klasifikácia
Reclassify                              Preklasifikovanie
Undo                                    Vrátiť
Close                                   Zatvoriť
Find                                    Nájsť
Filter                                  Filter
Yes                                     Áno
No                                      Nie
ChangeToYes                             Zmeniť na Áno
ChangeToNo                              Zmeniť na Nie
Bucket                                  Kôš
Magnet                                  Magnet
Delete                                  Zmazať
Create                                  Vytvoriť
To                                      Príjemca
Total                                   Celkom
Rename                                  Premenovať
Frequency                               Frekvencia
Probability                             Pravdepodobnosť
Score                                   Hodnotenie
Lookup                                  Hľadanie

# The header and footer that appear on every UI page
Header_Title                            POPFile riadiaci panel
Header_Shutdown                         Zastaviť POPFile
Header_History                          História
Header_Buckets                          Koše
Header_Configuration                    Konfigurácia
Header_Advanced                         Rozšírené
Header_Security                         Bezpečnosť
Header_Magnets                          Magnety

Footer_HomePage                         POPFile domovská stránka
Footer_Manual                           Manuál
Footer_Forums                           Diskusie
Footer_FeedMe                           Podporiť
Footer_RequestFeature                   Požiadavka na funkcionalitu
Footer_MailingList                      Poštová skupina

Configuration_Error1                    Znak oddelovača musí byť len jeden znak
Configuration_Error2                    Port užívateľského rozhrania musí byť v rozpätí čísel 1 až 65535
Configuration_Error3                    Port pre POP3 musí byť v rozpätí čísel 1 až 65535
Configuration_Error4                    Veľkosť stránky musí byť v rozpätí čísel 1 až 1000
Configuration_Error5                    Počet dní v histórii musí byť v rozpätí čísel 1 až 366
Configuration_Error6                    Hodnota čakania na TCP musí byť v rozpätí čísel 10 až 1800
Configuration_POP3Port                  Port pre POP3
Configuration_POP3Update                Port zmenený na %s; this change will not take affect until you restart POPFile
Configuration_Separator                 Znak oddelovača
Configuration_SepUpdate                 Oddelovač zmenený na %s
Configuration_UI                        Port užívateľského rozhrania
Configuration_UIUpdate                  Port užívateľského rozhrania zmenený na %s; this change will not take affect until you restart POPFile
Configuration_History                   Počet správ na stránku
Configuration_HistoryUpdate             Zmenený počet správ na stránku na %s
Configuration_Days                      Počet dní uchovania histórie
Configuration_DaysUpdate                Zmenený počet dní uchovania histórie na %s
Configuration_UserInterface             Užívateľské rozhranie
Configuration_Skins                     Vzhľad
Configuration_SkinsChoose               Zvol vzhľad
Configuration_Language                  Jazyk
Configuration_LanguageChoose            Zvol jazyk
Configuration_ListenPorts               Porty
Configuration_HistoryView               Zobrazenie histórie
Configuration_TCPTimeout                Čakanie na pripojenie TCP
Configuration_TCPTimeoutSecs            Čakanie na pripojenie TCP v sekundách
Configuration_TCPTimeoutUpdate          Čakanie na pripojenie TCP zmenené na %s
Configuration_ClassificationInsertion   Vkladanie textov do správy
Configuration_SubjectLine               Zmena textu subjektu
Configuration_XTCInsertion              Pridanie hlavičky X-Text-Classification
Configuration_XPLInsertion              Pridanie hlavičky X-POPFile-Link
Configuration_Logging                   Protokol spracovania
Configuration_None                      Žiadny
Configuration_ToScreen                  Na obrazovku
Configuration_ToFile                    Do súboru
Configuration_ToScreenFile              Na obrazovku a do súboru
Configuration_LoggerOutput              Výstup protokolu
Configuration_GeneralSkins              Vzhľad
Configuration_SmallSkins                Malý vzhľad
Configuration_TinySkins                 Drobný vzhľad

Advanced_Error1                         '%s' sa už nachádza v zozname Ignorované slová
Advanced_Error2                         Ignorované slová môžu obsahovať len: alfanumerické znaky, ., _, -, @
Advanced_Error3                         '%s' pridané do zoznamu Ignorované slová
Advanced_Error4                         '%s' sa nenachádza v zozname Ignorované slová
Advanced_Error5                         '%s' odstránené zo zoznamu Ignorované slová
Advanced_StopWords                      Ignorované slová
Advanced_Message1                       POPFile ignoruje nasledovné, často používané slová:
Advanced_AddWord                        Pridať slovo
Advanced_RemoveWord                     Odstrániť slovo

History_Filter                          &nbsp;(zobrazuje sa len kôš <font color="%s">%s</font>)
History_FilterBy                        Filtrovať podľa
History_Search                          &nbsp;(vyhľadané podľa odosielateľa/subjektu %s)
History_Title                           Posledné správy
History_Jump                            Prejdi na správu
History_ShowAll                         Zobraz všetky
History_ShouldBe                        Má byť
History_NoFrom                          prazdny riadok odosielateľa
History_NoSubject                       prazdny riadok subjektu
History_ClassifyAs                      Klasifikuj ako
History_MagnetUsed                      Použitý magnet
History_ChangedTo                       Zmeň na <font color="%s">%s
History_Already                         Už reklasifikované na <font color="%s">%s</font>
History_RemoveAll                       Odstráň všetko
History_RemovePage                      Odstáň stranu
History_Remove                          Ak chceš zmazať záznamy z histórie, klikni
History_SearchMessage                   Hľadaj odosielateľa/subjekt
History_NoMessages                      Žiadne správy
History_ShowMagnet                      zmagnetizované
History_Magnet                          &nbsp;(zobrazujú sa len záznamy klasifikované magnetom)
History_ResetSearch                     Vyprázdniť

Password_Title                          Heslo
Password_Enter                          Zadaj heslo
Password_Go                             Vstúp!
Password_Error1                         Nesprávne heslo

Security_Error1                         Bezpečnostný port musí byť v rozpätí čísel 1 až 65535
Security_Stealth                        Utajený mód/Činnosť servera
Security_NoStealthMode                  Nie (Utajený mód)
Security_ExplainStats                   (Ak je toto zapnuté, POPFile pošle raz za deň nasledovné tri hodnoty na stránku www.usethesource.com: bc (celkový počet košov, ktoré máš), mc (celkový počet správ, ktoré POPFile klasifikoval) a ec (celkový počet chybných klasifikácii).  Tieto hodnoty sa ukladajú do súboru a budú použité na vyhodnotenie niektorých štatistík o tom ako ľudia používajú POPFile a ako dobre funguje.  Môj web server uchováva tieto informácie približne 5 dní a potom ich zmaže; Neuchovávam informácie prepojujúce štatistické údaje s konkrétnymi IP adresami.)
Security_ExplainUpdate                  (Ak je toto zapnuté, POPFile pošle raz za deň nasledovné tri hodnoty na stránku www.usethesource.com: ma (hlavné číslo verzie používaného POPFile), mi (vedľajšie číslo verzie používaného POPFile) a bn (číslo kompilácie používaného POPFile).  POPFile dostane odpoveď vo forme obrázku, ktorý sa zobrazí na vrchu stránku, ak je k dispozícii nová verzia.  Môj web server uchováva tieto informácie približne 5 dní a potom ich zmaže; Neuchovávam informácie prepojujúce štatistické údaje s konkrétnymi IP adresami.)
Security_PasswordTitle                  Heslo užívateľského rozhrania
Security_Password                       Heslo
Security_PasswordUpdate                 Heslo zmenené na %s
Security_AUTHTitle                      Bezpečné overovanie hesla/AUTH
Security_SecureServer                   Bezpečnostný server
Security_SecureServerUpdate             Bezpečnostný server zmenený na %s; táto zmena vstúpi do platnosti až po reštarte POPFile
Security_SecurePort                     Bezpečnostný port
Security_SecurePortUpdate               Port zmenený na %s; táto zmena vstúpi do platnosti až po reštarte POPFile
Security_POP3                           Povoľ POP3 pripojenia zo vzdialených počítačov (vyžaduje reštart POPFile)
Security_UI                             Povoľ HTTP (užívateľské rozhranie) pripojenia zo vzdialených počítačov  (vyžaduje reštart POPFile)
Security_UpdateTitle                    Automatická kontrola nových verzií
Security_Update                         Kontroluj denne nové verzie programu POPFile
Security_StatsTitle                     Oznamovať štatistiky
Security_Stats                          Posielať štatistiky denne

Magnet_Error1                           Magnet '%s' už existuje v koši '%s'
Magnet_Error2                           Nový magnet '%s' by sa bil s existujúcim magnetom '%s' v koši '%s' a mohol by spôsobovať dvojzmyselné výsledky.  Nový magnet nebol pridaný.
Magnet_Error3                           Vytvorený nový magnet '%s' v koši '%s'
Magnet_CurrentMagnets                   Aktuálne magnety
Magnet_Message1                         Nasledovné magnety klasifikujú poštu vždy do určeného koša.
Magnet_CreateNew                        Vytvoriť nový magnet
Magnet_Explanation                      <b>Existujú tri typy magnetov:</b> <ul><li><b>Adresa alebo meno odosielaťeľa:</b> (políčko From: v pošte) Napr.: john@company.com pre konkrétnu adresu, <br />company.com pre každého odosielateľa z adresy company.com, <br />John Doe pre konkrétnu osobu, John pre každného Johna</li><li><b>Adresa alebo meno príjemcu:</b> To isté ako predchádzajúce, ale pre políčko To: pošty</li> <li><b>Slová v subjekte:</b> Napr.: hello zaradí každú poštu, ktorá má hello v subjekte</li></ul>
Magnet_MagnetType                       Typ magnetu
Magnet_Value                            Hodnota
Magnet_Always                           Zaradí sa vždy do koša

Bucket_Error1                           Názvy košov môžu obsahovať len znaky od a do z (malé písmo) plus - a _
Bucket_Error2                           Kôš s názvom  %s už existuje
Bucket_Error3                           Vytvorený kôš s názvom %s
Bucket_Error4                           Prosím, nezadávaj prázdne názvy
Bucket_Error5                           Kôš je premenovaný z %s na %s
Bucket_Error6                           Zmazaný kôš %s
Bucket_Title                            Prehľad
Bucket_BucketName                       Názov koša
Bucket_WordCount                        Počet slov
Bucket_WordCounts                       Počty slov
Bucket_UniqueWords                      Jedinečné slová
Bucket_SubjectModification              Modifikácia subjektu
Bucket_ChangeColor                      Zmena farby
Bucket_NotEnoughData                    Nedostatok údajov
Bucket_ClassificationAccuracy           Presnosť klasifikácie
Bucket_EmailsClassified                 Klasifikovaná pošta
Bucket_EmailsClassifiedUpper            Klasifikovaná pošta
Bucket_ClassificationErrors             Chyby klasifikácie
Bucket_Accuracy                         Presnosť
Bucket_ClassificationCount              Počty klasifikácie
Bucket_ResetStatistics                  Vynulovanie štatistiky
Bucket_LastReset                        Posledné vynulovanie
Bucket_CurrentColor                     aktuálna farba %s je %s
Bucket_SetColorTo                       Nastav farbu %s na %s
Bucket_Maintenance                      Údržba
Bucket_CreateBucket                     Vytvor kôš s názvom
Bucket_DeleteBucket                     Zmaž kôš s názvom
Bucket_RenameBucket                     Premenuj kôš s názvom
Bucket_Lookup                           Vyhľadanie
Bucket_LookupMessage                    Vyhľadaj slovo v košoch
Bucket_LookupMessage2                   Výsledok hľadania pre
Bucket_LookupMostLikely                 <b>%s</b> sa najčastejšie nachádza v koši <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> sa nenachádza v ani jednom koši
Bucket_DisabledGlobally                 Globálne vypnuté
Bucket_To                               na
Bucket_Quarantine                       Karanténa

SingleBucket_Title                      Detail pre %s
SingleBucket_WordCount                  Počet slov v koši
SingleBucket_TotalWordCount             Celkový počet slov
SingleBucket_Percentage                 Percento z celku
SingleBucket_WordTable                  Tabuľka slov pre %s
SingleBucket_Message1                   Slová označené s (*) boli použité na klasifikáciu počas aktuálneho spustenia POPFile.  Klikni na ktorékoľvek slovo, ak chceš vidieť jeho výskyt vo všetkých košoch.
SingleBucket_Unique                     %s jedinečných

Session_Title                           POPFile session has expired
Session_Error                           Your POPFile session has expired.  Mohlo to nastať vypnutím a zapnutím POPFile, pričom ste nechali otvorený web browser.  Prosím, ak chcete pokračovať v práci s POPFile, kliknite na niektorú z vrchných liniek.


Header_MenuSummary                      Táto tabuľka je navigačné menu, ktoré sprístupňuje všetky ostatné stránky riadiaceho panelu.
History_MainTableSummary                Táto tabuľka zobrazuje odosielateľov a subjekty aktuálne prijatých správ a umožnuje ich prezerať a klasifikovať.  Kliknutím na text subjektu sa zobrazí znenie správy, spolu s informáciou prečo bola klasifikovaná tak, ako bola.  Stĺpec 'Má byť' umožňuje určiť, do ktorého koša správa patrí, alebo zrušiť takúto zmenu.  Stĺpec 'Odstrániť' ti umožňuje zmazať danú správu z histórie, ak ju viac nepotrebuješ.
History_OpenMessageSummary              Táto tabuľka obsahuje celý text správy, spolu so zvýraznenými slovami, ktoré boli použité pri klasifikácii do daného koša.
Bucket_MainTableSummary                 Táto tabuľka obsahuje prehľad klasifikačných košov.  Každý riadok zobrazuje názov koša, celkový počet slov v tomto koši, aktuálny počet individuálnych slov v každom koši, či bude text subjektu správy zmenený ak bude správa klasifikovaná, či zaradiť správy v tomto koši do karantény a tabuľku, kde sa dá vybrať farba ktoru sa bude zobrazovať všetko na riadiacom panely, týkajúce sa tohto koša.
Bucket_StatisticsTableSummary           Táto tabuľka ponúka tri štatistické prehľady o výkone POPFile.  Prvý zobrazuje presnosť klasifikácie, druhý koľko správ bolo klasifikovaných a do ktorých košov a tretí zobrazuje koľko slov obsahuje ktorý kôš a aké je ich relatívne percentuálne zastúpenie.
Bucket_MaintenanceTableSummary          Táto tabuľka obsahuje formuláre, ktoré ti umožnujú vytvoriť, zmazať alebo premenovať koše a vyhľadať zastúpenie slova vo všetkých košoch a jeho relatívne zastúpenie.
Bucket_AccuracyChartSummary             Táto tabuľka graficky zobrazuje  presnosť klasifikácie správ.
Bucket_BarChartSummary                  Táto tabuľka graficky zobrazuje percentuálne zaplnenie jednotlivých košov.  Je použitá zároveň pre počet klasifikovaných správ a celkový počet slov.
Bucket_LookupResultsSummary             Táto tabuľka zobrazuje pravdepodobnosť priradenú k jednotlivým slovám v korpuse.  Pre každý kôš zobrazuje frekvenciu výskytu slova, pravdepodobnosť s akou sa vyskytuje v koši a celkový vplyv slova na zaradenie správy do koša ak sa v nej dané slovo vyskytuje.
Bucket_WordListTableSummary             Táto tabuľka zobrazuje zoznam všetkých slov pre kôš, slová sú zoradené podľa začiatočných znakov po riadkoch.
Magnet_MainTableSummary                 Táto tabuľka zobrazuje zoznam magnetov, ktoré sú používané na automatické klasifikovanie správ podľa presných pravidiel.  Každý riadok zobrazuje ako je magnet definovaný, pre ktorý kôš slúži a tlačidlo na zmazanie magnetu.
Configuration_MainTableSummary          Táto tabuľka obsahuje formuláre ktoré ti umožňujú konfigurovať POPFile.
Configuration_InsertionTableSummary     Táto tabuľka obsahuje tlačidlá, ktoré určujú či sa majú alebo nemajú vykonať niektoré zmeny v záhlaví alebo texte subjektu správy skôr, ako sa posunie k poštovému klientovi.
Security_MainTableSummary               Táto tabuľka poskytuje niekoľko nastavení, ktoré ovplyvňujú bezpečnosť celkovej konfigurácie POPFile, či sa má vykonávať automatická kontrola existencie zmien programu a či sa má zasielať štatistika spracovania do centrálnej databázy autora programu.
Advanced_MainTableSummary               Táto tabuľka zobrazuje zoznam slov, ktoré POPFile ignoruje pri klasifikovaní správ z dôvodu ich relatívne častého výskytu vo všeobecných správach. Sú zobrazené v riadkoch v závislosti od prvého znaku.


