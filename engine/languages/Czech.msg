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
# Translation Jan Chochola (jchochola@volny.cz)

# Identify the language and character set used for the interface
LanguageCode                            cz
LanguageCharset                         windows-1250
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en

# Common words that are used on their own all over the interface
Apply                                   Použít
On                                      Zapnuto
Off                                     Vypnuto
TurnOn                                  Zapnout
TurnOff                                 Vypnout
Add                                     Přidat
Remove                                  Odstranit
Previous                                Předchozí
Next                                    Následující
From                                    Od
Subject                                 Předmět
Cc                                      Cc 
Classification                          Klasifikace
Reclassify                              Znova klasifikovat
Probability                             Pravděpodobnost
Scores                                  Skóre
QuickMagnets                            <I>QuickMagnet</I>y
Undo                                    Vrátit
Close                                   Zavřít
Find                                    Hledat
Filter                                  Filtr
Yes                                     Ano
No                                      Ne
ChangeToYes                             Změnit na Ano
ChangeToNo                              Změnit na Ne
Bucket                                  Koš
Magnet                                  Magnet
Delete                                  Odstranit
Create                                  Vytvořit
To                                      Příjemce
Total                                   Celkem
Rename                                  Přejmenovat
Frequency                               Frekvence
Lookup                                  Hledání
Word                                    Slovo
Count                                   Počet
Update                                  Aktualizace
Refresh                                 Obnovit

# The header and footer that appear on every UI page
Header_Title                            Ovládací panel POPFile
Header_Shutdown                         Ukončit POPFile
Header_History                          Historie
Header_Buckets                          Koše
Header_Configuration                    Konfigurace
Header_Advanced                         Rozšířené
Header_Security                         Zabezpečení
Header_Magnets                          Magnety

Footer_HomePage                         Domovská stránka POPFile
Footer_Manual                           Manuál
Footer_Forums                           Fóra
Footer_FeedMe                           Podpořte vývoj
Footer_RequestFeature                   Požadavek na funkci
Footer_MailingList                      Mailing List

Configuration_Error1                    Oddělovač musí být jediný znak
Configuration_Error2                    Port uživatelského rozhraní musí být číslo mezi 1 a 65535
Configuration_Error3                    Port protokolu POP3 musí být číslo mezi 1 a 65535
Configuration_Error4                    Velikost stránky musí být číslo mezi 1 a 1000
Configuration_Error5                    Počet dnů platnosti historie musí být číslo mezi 1 a 366
Configuration_Error6                    Doba čekání TCP musí být číslo mezi 10 a 1800
Configuration_Error7                    Port pro XML-RPC musí být číslo mezi 1 a 65535
Configuration_POP3Port                  Port protokolu POP3
Configuration_POP3Update                Nový port POP3 je %s; tato změna se projeví až po restartu POPFile
Configuration_XMLRPCUpdate              Nový port pro XML-RPC je %s; tato změna se projeví až po restartu POPFile
Configuration_XMLRPCPort                Port pro XML-RPC
Configuration_SMTPPort                  Port protokolu SMTP
Configuration_SMTPUpdate                Nový port pro SMTP je %s; tato změna se projeví až po restartu POPFile
Configuration_NNTPPort                  Port protokolu NNTP
Configuration_NNTPUpdate                Nový port pro NNTP je %s; tato změna se projeví až po restartu POPFile
Configuration_POP3Separator             Oddělovací znak pro POP3 host:port:user
Configuration_NNTPSeparator             Oddělovací znak pro NNTP host:port:user
Configuration_POP3SepUpdate             Nový oddělovač pro POP3 je %s
Configuration_NNTPSepUpdate             Nový oddělovač pro NNTP je %s
Configuration_UI                        Port webového uživatelského rozhraní
Configuration_UIUpdate                  Nový port webového uživatelského rozhraní je %s; tato změna se projeví až po restartu POPFile
Configuration_History                   Počet zpráv na stránce
Configuration_HistoryUpdate             Nový počet zpráv na stránce je %s
Configuration_Days                      Počet dnů platnosti historie
Configuration_DaysUpdate                Nový počet dnů platnosti historie je %s
Configuration_UserInterface             Uživatelské rozhraní
Configuration_Skins                     Vzhled
Configuration_SkinsChoose               Zvolit vzhled
Configuration_Language                  Jazyk
Configuration_LanguageChoose            Zvolit jazyk
Configuration_ListenPorts               Porty
Configuration_HistoryView               Zobrazení historie
Configuration_TCPTimeout                Čekání na spojení 
Configuration_TCPTimeoutSecs            Čekání na spojení v sekundách
Configuration_TCPTimeoutUpdate          Nové čekání na spojení je %s
Configuration_ClassificationInsertion   Vkládání textu do zprávy
Configuration_SubjectLine               Změna předmětu zprávy
Configuration_XTCInsertion              Přidání hlavičky X-Text-Classification
Configuration_XPLInsertion              Přidání hlavičky X-POPFile-Link
Configuration_Logging                   Protokolování
Configuration_None                      Není
Configuration_ToScreen                  Na obrazovku
Configuration_ToFile                    Do souboru
Configuration_ToScreenFile              Na obrazovku i do souboru
Configuration_LoggerOutput              Protokol
Configuration_GeneralSkins              Vzhled
Configuration_SmallSkins                Malý
Configuration_TinySkins                 Drobný
Configuration_CurrentLogFile            &lt;aktuální protokol&gt;

Advanced_Error1                         '%s' je už v seznamu ignorovaných slov
Advanced_Error2                         Ignorovaná slova mohou obsahovat jen alfanumerické znaky a znaky '.', '_', '-' nebo '@'
Advanced_Error3                         '%s' přidáno do seznamu ignorovaných slov
Advanced_Error4                         '%s' není v seznamu ignorovaných slov
Advanced_Error5                         '%s' odstraněno ze seznamu ignorovaných slov
Advanced_StopWords                      Ignorovaná slova
Advanced_Message1                       POPFile ignoruje tato často užívaná slova:
Advanced_AddWord                        Přidat slovo
Advanced_RemoveWord                     Odebrat slovo

History_Filter                          &nbsp;(zobrazuje se koš <font color="%s">%s</font>)
History_FilterBy                        Filtr
History_Search                          &nbsp;(vyhledáno podle Odesílatele/Předmětu %s)
History_Title                           Poslední zprávy
History_Jump                            Přejít ke zprávě
History_ShowAll                         Ukázat vše
History_ShouldBe                        Má být
History_NoFrom                          schází řádek 'Odesílatel'
History_NoSubject                       schází řádek 'Předmět'
History_ClassifyAs                      Klasifikovat jako
History_MagnetUsed                      Použit magnet
History_MagnetBecause                   <b>Použit magnet</b><p>Klasifikováno jako <font color="%s">%s</font>, protože byl použit magnet %s </p>
History_ChangedTo                       Změněno na <font color="%s">%s
History_Already                         Klasifikace již změněna na <font color="%s">%s</font>
History_RemoveAll                       Odstranit vše
History_RemovePage                      Odstranit stránku
History_Remove                          Kliknout pro odstranění položek v historii
History_SearchMessage                   Hledat Odesílatele/Předmět
History_NoMessages                      Zpráva nenalezena
History_ShowMagnet                      zmagnetováno
History_ShowNoMagnet                    nezmagnetováno
History_Magnet                          &nbsp;(jen zprávy klasifikované magnetem)
History_NoMagnet                        &nbsp;(jen zprávy neklasifikované magnetem)
History_ResetSearch                     Vynulovat

Password_Title                          Heslo
Password_Enter                          Vložit heslo
Password_Go                             Vstoupit
Password_Error1                         Nesprávné heslo

Security_Error1                         Port musí být číslo mezi 1 a 65535
Security_Stealth                        Utajený režim/režim serveru
Security_NoStealthMode                  Ne (Utajený režim)
Security_ExplainStats                   (Pokud je to zapnuto, POPFile jedenkrát denně odešle skriptu na www.usethesource.com následující údaje: <B>bc</B> [celkový počet košů], <B>mc</B> [celkový počet zpráv, které POPFile klasifikoval] a <B>ec</B> [celkový počet chyb klasifikace]. Tyto údaje jsou ukládány a použiji je pro statistiku o tom, jak lidé POPFile používají a jak je úspěšný. Můj web server data udržuje 5 dnů a pak je ruší. Neukládá se žádná informace o propojení mezi statistikami a příslušnými IP adresami.)
Security_ExplainUpdate                  (Pokud je to zapnuto, POPFile jedenkrát denně odešle skriptu na www.usethesource.com následující údaje: <B>ma</B> [hlavní číslo verze vašeho POPFile], <B>mi</B> [vedlejší číslo verze] a <B>bn</B> (číslo sestavení POPFile). Pokud je dostupná nová verze, POPFile to graficky zobrazí v horní části stránky. Můj web server data udržuje 5 dnů a pak je ruší. Neukládá se žádná informace o propojení mezi údaji a příslušnými IP adresami.)
Security_PasswordTitle                  Heslo uživatelského rozhraní
Security_Password                       Heslo
Security_PasswordUpdate                 Nové heslo je %s
Security_AUTHTitle                      Vzdálené servery
Security_SecureServer                   Server POP3 SPA/AUTH
Security_SecureServerUpdate             Nový bezpečný server POP3 SPA/AUTH je %s; tato změna se projeví až po restartu POPFile
Security_SecurePort                     Port pro POP3 SPA/AUTH
Security_SecurePortUpdate               Nový port pro POP3 SPA/AUTH je %s; tato změna se projeví až po restartu POPFile
Security_SMTPServer                     Zřetězený SMTP server
Security_SMTPServerUpdate               Nový zřetězený SMTP server je %s; tato změna se projeví až po restartu POPFile
Security_SMTPPort                       Port pro zřetězený SMTP server
Security_SMTPPortUpdate                 Nový port pro zřetězený SMTP server je %s; tato změna se projeví až po restartu POPFile
Security_POP3                           Přijmout POP3 spojení od vzdálených počítačů (vyžaduje restart POPFile)
Security_SMTP                           Přijmout SMTP spojení od vzdálených počítačů (vyžaduje restart POPFile)
Security_NNTP                           Přijmout NNTP spojení od vzdálených počítačů (vyžaduje restart POPFile)
Security_UI                             Přijmout HTTP (uživatelské rozhraní) spojení od vzdálených počítačů (vyžaduje restart POPFile)
Security_XMLRPC                         Přijmout XML-RPC spojení od vzdálených počítačů (vyžaduje restart POPFile)
Security_UpdateTitle                    Automatická kontrola verze
Security_Update                         Denně kontrolovat dostupnost aktualizace POPFile
Security_StatsTitle                     Hlášení statistik
Security_Stats                          Denně odesílat statistiky

Magnet_Error1                           Magnet '%s' už je v koši '%s'
Magnet_Error2                           Nový magnet '%s' koliduje s magnetem '%s' v koši '%s' a mohl by způsobit nejednoznačné výsledky. Nový magnet nebyl přidán.
Magnet_Error3                           Vytvořit nový magnet '%s' v koši '%s'
Magnet_CurrentMagnets                   Platné magnety
Magnet_Message1                         Následující magnety způsobí, že zprávy budou vždy zařazeny do určeného koše.
Magnet_CreateNew                        Založit nový magnet
Magnet_Explanation                      <b>Jsou dostupné tyto typy magnetů:</b> <ul><li><b>From: Adresa nebo jméno odesílatele:</b> Například: john@company.com pro konkrétní adresu, <br />company.com pro všechny odesílatele z company.com, <br />John Doe pro konkrétní osobu, John pro všechny Johny</li><li><b>To/Cc: Adresa nebo jméno příjemce/příjemců:</b> Obdobně jako magnet From: pro adresy příjemců (hlavičky To: a Cc:).</li> <li><b>Subject: slova v předmětu</b>Například: hello pro všechny zprávy se slovem hello v předmětu</li></ul>
Magnet_MagnetType                       Typ magnetu
Magnet_Value                            Hodnota
Magnet_Always                           Zařadit vždy do koše
Magnet_Jump                             Přechod na stránku magnetů

Bucket_Error1                           Jména košů mohou obsahovat jen malá písmena 'a' až 'z', číslice '0' až '9', a znaky '-' a '_'
Bucket_Error2                           Koš %s již existuje
Bucket_Error3                           Koš %s byl založen
Bucket_Error4                           Vložte neprázdné slovo
Bucket_Error5                           Koš %s byl přejmenován na %s
Bucket_Error6                           Koš %s byl odstraněn
Bucket_Title                            Shrnutí
Bucket_BucketName                       Jméno koše
Bucket_WordCount                        Počet slov
Bucket_WordCounts                       Počty slov
Bucket_UniqueWords                      Unikátní slova
Bucket_SubjectModification              Modifikace předmětu
Bucket_ChangeColor                      Změna barvy
Bucket_NotEnoughData                    Příliš málo dat
Bucket_ClassificationAccuracy           Přesnost klasifikace
Bucket_EmailsClassified                 Počet klasifikovaných zpráv
Bucket_EmailsClassifiedUpper            Počet klasifikovaných zpráv
Bucket_ClassificationErrors             Chyby klasifikace
Bucket_Accuracy                         Přesnost
Bucket_ClassificationCount              Počet klasifikací
Bucket_ClassificationFP                 Počet chyb "False Positive"
Bucket_ClassificationFN                 Počet chyb "False Negative"
Bucket_ResetStatistics                  Vynulovat statistiky
Bucket_LastReset                        Poslední nulování
Bucket_CurrentColor                     %s má barvu %s
Bucket_SetColorTo                       Nastavit barvu %s na %s
Bucket_Maintenance                      Údržba
Bucket_CreateBucket                     Založit koš s názvem
Bucket_DeleteBucket                     Odstranit koš s názvem
Bucket_RenameBucket                     Přejmenovat koš s názvem
Bucket_Lookup                           Vyhledání
Bucket_LookupMessage                    Vyhledat slovo v koších
Bucket_LookupMessage2                   Výsledky hledání
Bucket_LookupMostLikely                 <b>%s</b> se nejčastěji objevuje v koši <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> se nenašlo v žádném koši
Bucket_DisabledGlobally                 Globálně vypnuto
Bucket_To                               na
Bucket_Quarantine                       Karanténa

SingleBucket_Title                      Detail %s
SingleBucket_WordCount                  Počet slov v koši
SingleBucket_TotalWordCount             Celkový počet slov
SingleBucket_Percentage                 Procento
SingleBucket_WordTable                  Tabulka slov pro %s
SingleBucket_Message1                   Pro zobrazení slov začínajících určitým písmenem je možno kliknout na toto písmeno v indexu. Kliknutím na slovo se zobrazí jeho pravděpodobnosti pro všechny koše.
SingleBucket_Unique                     %s unikátních
SingleBucket_ClearBucket                Odstranit všechna slova

Session_Title                           Relace POPFile vypršela
Session_Error                           Vaše relace POPFile vypršela. To může být způsobeno zastavením a novým spuštěním POPFile, zatímco prohlížeč zůstal otevřený. Pro pokračování práce s POPFile je nutno kliknout na některý z odkazů nahoře.

View_Title                              Pohled na jednu zprávu

Header_MenuSummary                      Tato tabulka tvoří navigační menu umožňující přístup k jednotlivým stránkám Ovládacího panelu.

History_MainTableSummary                Tato tabulka zobrazuje odesílatele a předmět doručených zpráv a umožňuje jejich prohlédnutí a změnu klasifikace. Po kliknutí na předmět se zobrazí celý text zprávy současně s informací, proč byla klasifikována tak, jak byla. Sloupec 'Má být' umožňuje určit koš, do kterého zpráva patří, nebo odvolat tuto změnu. Sloupec 'Odstranit' umožňuje zrušit zprávy, které již nejsou zapotřebí.

History_OpenMessageSummary              Tato tabulka obsahuje celý text zprávy. Slova použitá při klasifikaci jsou označena barvou koše, pro který jsou nejvíce relevantní.

Bucket_MainTableSummary                 Tato tabulka poskytuje přehled klasifikačních košů. Každý řádek obsahuje jméno koše, celkový počet slov pro daný koš, aktuální počet slov, zda je při klasifikaci modifikován předmět zprávy, zda jsou zprávy umisťovány do karantény, a tabulka pro výběr barvy koše.

Bucket_StatisticsTableSummary           Tato tabulka poskytuje tři sady statistických údajů o činnosti POPFile. První z nich zobrazuje přesnost klasifikace, druhá počet klasifikovaných zpráv pro jednotlivé koše a třetí počty slov v jednotlivých koších a jejich relativní zastoupení.

Bucket_MaintenanceTableSummary          Tato tabulka obsahuje formuláře pro zakládání, rušení a přejmenovávání košů a pro vyhledání slova v koších a zjištění jeho relativní pravděpodobnosti.

Bucket_AccuracyChartSummary             Tato tabulka graficky znázorňuje přesnost klasifikace zpráv.

Bucket_BarChartSummary                  Tato tabulka graficky znázorňuje relativní zastoupení klasifikovaných zpráv a celkového počtu slov pro jednotlivé koše. 

Bucket_LookupResultsSummary             Tato tabulka poskytuje pravděpodobnosti pro každé slovo z korpusu. Pro každý koš je zobrazena frekvence výskytu slova, pravděpodobnost, že se v koši objeví, a celkový vliv na skóre pro daný koš, pokud se ve zprávě vyskytuje.

Bucket_WordListTableSummary             Tato tabulka nabízí seznam všech slov pro daný koš.

Magnet_MainTableSummary                 Tato tabulka zobrazuje seznam všech magnetů, které jsou použity pro automatickou klasifikaci zpráv podle pevných pravidel. Každý řádek obsahuje informace o tom, jak je magnet definován a pro který koš je určen, a tlačítko pro jeho zrušení.

Configuration_MainTableSummary          Tato tabulka obsahuje řadu formulářů určených k nastavování konfigurace POPFile.

Configuration_InsertionTableSummary     Tato tabulka osahuje tlačítka určující, zda se budou provádět určité modifikace hlavičky zprávy před jejím předáním poštovnímu klientu.

Security_MainTableSummary               Tato tabulka umožňuje nastavit zabezpečení konfigurace POPFile, automatickou kontrolu nových verzí programu a zasílání statistických údajů do centrálního úložiště autora.

Advanced_MainTableSummary               Tato tabulka obsahuje seznam slov, která POPFile při klasifikaci pro jejich vysokou četnost ve zprávách ignoruje.

