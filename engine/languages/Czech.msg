# Copyright (c) 2001-2003 John Graham-Cumming
# Translation Jan Chochola (jchochola@volny.cz)

# Identify the language and character set used for the interface
LanguageCode                            cz
LanguageCharset                         windows-1250

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en

# Common words that are used on their own all over the interface
Apply                                   Pouít
On                                      Zapnuto
Off                                     Vypnuto
TurnOn                                  Zapnout
TurnOff                                 Vypnout
Add                                     Pøidat
Remove                                  Odstranit
Previous                                Pøedchozí
Next                                    Následující
From                                    Od
Subject                                 Pøedmìt
Cc                                      Cc 
Classification                          Klasifikace
Reclassify                              Znova klasifikovat
Probability                             Pravdìpodobnost
Scores                                  Skóre
QuickMagnets                            <I>QuickMagnet</I>y
Undo                                    Vrátit
Close                                   Zavøít
Find                                    Hledat
Filter                                  Filtr
Yes                                     Ano
No                                      Ne
ChangeToYes                             Zmìnit na Ano
ChangeToNo                              Zmìnit na Ne
Bucket                                  Koš
Magnet                                  Magnet
Delete                                  Odstranit
Create                                  Vytvoøit
To                                      Pøíjemce
Total                                   Celkem
Rename                                  Pøejmenovat
Frequency                               Frekvence
Lookup                                  Hledání
Word                                    Slovo
Count                                   Poèet
Update                                  Aktualizace
Refresh                                 Obnovit

# The header and footer that appear on every UI page
Header_Title                            Ovládací panel POPFile
Header_Shutdown                         Ukonèit POPFile
Header_History                          Historie
Header_Buckets                          Koše
Header_Configuration                    Konfigurace
Header_Advanced                         Rozšíøené
Header_Security                         Zabezpeèení
Header_Magnets                          Magnety

Footer_HomePage                         Domovská stránka POPFile
Footer_Manual                           Manuál
Footer_Forums                           Fóra
Footer_FeedMe                           Podpoøte vıvoj
Footer_RequestFeature                   Poadavek na funkci
Footer_MailingList                      Mailing List

Configuration_Error1                    Oddìlovaè musí bıt jedinı znak
Configuration_Error2                    Port uivatelského rozhraní musí bıt èíslo mezi 1 a 65535
Configuration_Error3                    Port protokolu POP3 musí bıt èíslo mezi 1 a 65535
Configuration_Error4                    Velikost stránky musí bıt èíslo mezi 1 a 1000
Configuration_Error5                    Poèet dnù platnosti historie musí bıt èíslo mezi 1 a 366
Configuration_Error6                    Doba èekání TCP musí bıt èíslo mezi 10 a 300
Configuration_Error7                    Port pro XML-RPC musí bıt èíslo mezi 1 a 65535
Configuration_POP3Port                  Port protokolu POP3
Configuration_POP3Update                Novı port POP3 je %s; tato zmìna se projeví a po restartu POPFile
Configuration_XMLRPCUpdate              Novı port pro XML-RPC je %s; tato zmìna se projeví a po restartu POPFile
Configuration_XMLRPCPort                Port pro XML-RPC
Configuration_SMTPPort                  Port protokolu SMTP
Configuration_SMTPUpdate                Novı port pro SMTP je %s; tato zmìna se projeví a po restartu POPFile
Configuration_NNTPPort                  Port protokolu NNTP
Configuration_NNTPUpdate                Novı port pro NNTP je %s; tato zmìna se projeví a po restartu POPFile
Configuration_POP3Separator             Oddìlovací znak pro POP3 host:port:user
Configuration_NNTPSeparator             Oddìlovací znak pro NNTP host:port:user
Configuration_POP3SepUpdate             Novı oddìlovaè pro POP3 je %s
Configuration_NNTPSepUpdate             Novı oddìlovaè pro NNTP je %s
Configuration_UI                        Port webového uivatelského rozhraní
Configuration_UIUpdate                  Novı port webového uivatelského rozhraní je %s; tato zmìna se projeví a po restartu POPFile
Configuration_History                   Poèet zpráv na stránce
Configuration_HistoryUpdate             Novı poèet zpráv na stránce je %s
Configuration_Days                      Poèet dnù platnosti historie
Configuration_DaysUpdate                Novı poèet dnù platnosti historie je %s
Configuration_UserInterface             Uivatelské rozhraní
Configuration_Skins                     Vzhled
Configuration_SkinsChoose               Zvolit vzhled
Configuration_Language                  Jazyk
Configuration_LanguageChoose            Zvolit jazyk
Configuration_ListenPorts               Porty
Configuration_HistoryView               Zobrazení historie
Configuration_TCPTimeout                Èekání na spojení 
Configuration_TCPTimeoutSecs            Èekání na spojení v sekundách
Configuration_TCPTimeoutUpdate          Nové èekání na spojení je %s
Configuration_ClassificationInsertion   Vkládání textu do zprávy
Configuration_SubjectLine               Zmìna pøedmìtu zprávy
Configuration_XTCInsertion              Pøidání hlavièky X-Text-Classification
Configuration_XPLInsertion              Pøidání hlavièky X-POPFile-Link
Configuration_Logging                   Protokolování
Configuration_None                      Není
Configuration_ToScreen                  Na obrazovku
Configuration_ToFile                    Do souboru
Configuration_ToScreenFile              Na obrazovku i do souboru
Configuration_LoggerOutput              Protokol
Configuration_GeneralSkins              Vzhled
Configuration_SmallSkins                Malı
Configuration_TinySkins                 Drobnı
Configuration_CurrentLogFile            &lt;aktuální protokol&gt;

Advanced_Error1                         '%s' je u v seznamu ignorovanıch slov
Advanced_Error2                         Ignorovaná slova mohou obsahovat jen alfanumerické znaky a znaky '.', '_', '-' nebo '@'
Advanced_Error3                         '%s' pøidáno do seznamu ignorovanıch slov
Advanced_Error4                         '%s' není v seznamu ignorovanıch slov
Advanced_Error5                         '%s' odstranìno ze seznamu ignorovanıch slov
Advanced_StopWords                      Ignorovaná slova
Advanced_Message1                       POPFile ignoruje tato èasto uívaná slova:
Advanced_AddWord                        Pøidat slovo
Advanced_RemoveWord                     Odebrat slovo

History_Filter                          &nbsp;(zobrazuje se koš <font color="%s">%s</font>)
History_FilterBy                        Filtr
History_Search                          &nbsp;(vyhledáno podle Odesílatele/Pøedmìtu %s)
History_Title                           Poslední zprávy
History_Jump                            Pøejít ke zprávì
History_ShowAll                         Ukázat vše
History_ShouldBe                        Má bıt
History_NoFrom                          schází øádek 'Odesílatel'
History_NoSubject                       schází øádek 'Pøedmìt'
History_ClassifyAs                      Klasifikovat jako
History_MagnetUsed                      Pouit magnet
History_MagnetBecause                   <b>Pouit magnet</b><p>Klasifikováno jako <font color="%s">%s</font>, protoe byl pouit magnet %s </p>
History_ChangedTo                       Zmìnìno na <font color="%s">%s
History_Already                         Klasifikace ji zmìnìna na <font color="%s">%s</font>
History_RemoveAll                       Odstranit vše
History_RemovePage                      Odstranit stránku
History_Remove                          Kliknout pro odstranìní poloek v historii
History_SearchMessage                   Hledat Odesílatele/Pøedmìt
History_NoMessages                      Zpráva nenalezena
History_ShowMagnet                      zmagnetováno
History_ShowNoMagnet                    nezmagnetováno
History_Magnet                          &nbsp;(jen zprávy klasifikované magnetem)
History_NoMagnet                        &nbsp;(jen zprávy neklasifikované magnetem)
History_ResetSearch                     Vynulovat

Password_Title                          Heslo
Password_Enter                          Vloit heslo
Password_Go                             Vstoupit
Password_Error1                         Nesprávné heslo

Security_Error1                         Port musí bıt èíslo mezi 1 a 65535
Security_Stealth                        Utajenı reim/reim serveru
Security_NoStealthMode                  Ne (Utajenı reim)
Security_ExplainStats                   (Pokud je to zapnuto, POPFile jedenkrát dennì odešle skriptu na www.usethesource.com následující údaje: <B>bc</B> [celkovı poèet košù], <B>mc</B> [celkovı poèet zpráv, které POPFile klasifikoval] a <B>ec</B> [celkovı poèet chyb klasifikace]. Tyto údaje jsou ukládány a pouiji je pro statistiku o tom, jak lidé POPFile pouívají a jak je úspìšnı. Mùj web server data udruje 5 dnù a pak je ruší. Neukládá se ádná informace o propojení mezi statistikami a pøíslušnımi IP adresami.)
Security_ExplainUpdate                  (Pokud je to zapnuto, POPFile jedenkrát dennì odešle skriptu na www.usethesource.com následující údaje: <B>ma</B> [hlavní èíslo verze vašeho POPFile], <B>mi</B> [vedlejší èíslo verze] a <B>bn</B> (èíslo sestavení POPFile). Pokud je dostupná nová verze, POPFile to graficky zobrazí v horní èásti stránky. Mùj web server data udruje 5 dnù a pak je ruší. Neukládá se ádná informace o propojení mezi údaji a pøíslušnımi IP adresami.)
Security_PasswordTitle                  Heslo uivatelského rozhraní
Security_Password                       Heslo
Security_PasswordUpdate                 Nové heslo je %s
Security_AUTHTitle                      Vzdálené servery
Security_SecureServer                   Server POP3 SPA/AUTH
Security_SecureServerUpdate             Novı bezpeènı server POP3 SPA/AUTH je %s; tato zmìna se projeví a po restartu POPFile
Security_SecurePort                     Port pro POP3 SPA/AUTH
Security_SecurePortUpdate               Novı port pro POP3 SPA/AUTH je %s; tato zmìna se projeví a po restartu POPFile
Security_SMTPServer                     Zøetìzenı SMTP server
Security_SMTPServerUpdate               Novı zøetìzenı SMTP server je %s; tato zmìna se projeví a po restartu POPFile
Security_SMTPPort                       Port pro zøetìzenı SMTP server
Security_SMTPPortUpdate                 Novı port pro zøetìzenı SMTP server je %s; tato zmìna se projeví a po restartu POPFile
Security_POP3                           Pøijmout POP3 spojení od vzdálenıch poèítaèù (vyaduje restart POPFile)
Security_SMTP                           Pøijmout SMTP spojení od vzdálenıch poèítaèù (vyaduje restart POPFile)
Security_NNTP                           Pøijmout NNTP spojení od vzdálenıch poèítaèù (vyaduje restart POPFile)
Security_UI                             Pøijmout HTTP (uivatelské rozhraní) spojení od vzdálenıch poèítaèù (vyaduje restart POPFile)
Security_XMLRPC                         Pøijmout XML-RPC spojení od vzdálenıch poèítaèù (vyaduje restart POPFile)
Security_UpdateTitle                    Automatická kontrola verze
Security_Update                         Dennì kontrolovat dostupnost aktualizace POPFile
Security_StatsTitle                     Hlášení statistik
Security_Stats                          Dennì odesílat statistiky

Magnet_Error1                           Magnet '%s' u je v koši '%s'
Magnet_Error2                           Novı magnet '%s' koliduje s magnetem '%s' v koši '%s' a mohl by zpùsobit nejednoznaèné vısledky. Novı magnet nebyl pøidán.
Magnet_Error3                           Vytvoøit novı magnet '%s' v koši '%s'
Magnet_CurrentMagnets                   Platné magnety
Magnet_Message1                         Následující magnety zpùsobí, e zprávy budou vdy zaøazeny do urèeného koše.
Magnet_CreateNew                        Zaloit novı magnet
Magnet_Explanation                      Jsou dostupné tyto typy magnetù:</b> <ul><li><b>From: Adresa nebo jméno odesílatele:</b> Napøíklad: john@company.com pro konkrétní adresu, <br />company.com pro všechny odesílatele z company.com, <br />John Doe pro konkrétní osobu, John pro všechny Johny</li><li><b>To/Cc: Adresa nebo jméno pøíjemce/pøíjemcù:</b> Obdobnì jako magnet From: pro adresy pøíjemcù (hlavièky To: a Cc:).</li> <li><b>Subject: slova v pøedmìtu</b>Napøíklad: hello pro všechny zprávy se slovem hello v pøedmìtu</li></ul>
Magnet_MagnetType                       Typ magnetu
Magnet_Value                            Hodnota
Magnet_Always                           Zaøadit vdy do koše
Magnet_Jump                             Pøechod na stránku magnetù

Bucket_Error1                           Jména košù mohou obsahovat jen malá písmena 'a' a 'z', èíslice '0' a '9', a znaky '-' a '_'
Bucket_Error2                           Koš %s ji existuje
Bucket_Error3                           Koš %s byl zaloen
Bucket_Error4                           Vlote neprázdné slovo
Bucket_Error5                           Koš %s byl pøejmenován na %s
Bucket_Error6                           Koš %s byl odstranìn
Bucket_Title                            Shrnutí
Bucket_BucketName                       Jméno koše
Bucket_WordCount                        Poèet slov
Bucket_WordCounts                       Poèty slov
Bucket_UniqueWords                      Unikátní slova
Bucket_SubjectModification              Modifikace pøedmìtu
Bucket_ChangeColor                      Zmìna barvy
Bucket_NotEnoughData                    Pøíliš málo dat
Bucket_ClassificationAccuracy           Pøesnost klasifikace
Bucket_EmailsClassified                 Poèet klasifikovanıch zpráv
Bucket_EmailsClassifiedUpper            Poèet klasifikovanıch zpráv
Bucket_ClassificationErrors             Chyby klasifikace
Bucket_Accuracy                         Pøesnost
Bucket_ClassificationCount              Poèet klasifikací
Bucket_ClassificationFP                 Poèet chyb "False Positive"
Bucket_ClassificationFN                 Poèet chyb "False Negative"
Bucket_ResetStatistics                  Vynulovat statistiky
Bucket_LastReset                        Poslední nulování
Bucket_CurrentColor                     %s má barvu %s
Bucket_SetColorTo                       Nastavit barvu %s na %s
Bucket_Maintenance                      Údrba
Bucket_CreateBucket                     Zaloit koš s názvem
Bucket_DeleteBucket                     Odstranit koš s názvem
Bucket_RenameBucket                     Pøejmenovat koš s názvem
Bucket_Lookup                           Vyhledání
Bucket_LookupMessage                    Vyhledat slovo v koších
Bucket_LookupMessage2                   Vısledky hledání
Bucket_LookupMostLikely                 <b>%s</b> se nejèastìji objevuje v koši <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> se nenašlo v ádném koši
Bucket_DisabledGlobally                 Globálnì vypnuto
Bucket_To                               na
Bucket_Quarantine                       Karanténa

SingleBucket_Title                      Detail %s
SingleBucket_WordCount                  Poèet slov v koši
SingleBucket_TotalWordCount             Celkovı poèet slov
SingleBucket_Percentage                 Procento
SingleBucket_WordTable                  Tabulka slov pro %s
SingleBucket_Message1                   Pro zobrazení slov zaèínajících urèitım písmenem je mono kliknout na toto písmeno v indexu. Kliknutím na slovo se zobrazí jeho pravdìpodobnosti pro všechny koše.
SingleBucket_Unique                     %s unikátních
SingleBucket_ClearBucket                Odstranit všechna slova

Session_Title                           Relace POPFile vypršela
Session_Error                           Vaše relace POPFile vypršela. To mùe bıt zpùsobeno zastavením a novım spuštìním POPFile, zatímco prohlíeè zùstal otevøenı. Pro pokraèování práce s POPFile je nutno kliknout na nìkterı z odkazù nahoøe.

View_Title                              Pohled na jednu zprávu

Header_MenuSummary                      Tato tabulka tvoøí navigaèní menu umoòující pøístup k jednotlivım stránkám Ovládacího panelu.

History_MainTableSummary                Tato tabulka zobrazuje odesílatele a pøedmìt doruèenıch zpráv a umoòuje jejich prohlédnutí a zmìnu klasifikace. Po kliknutí na pøedmìt se zobrazí celı text zprávy souèasnì s informací, proè byla klasifikována tak, jak byla. Sloupec 'Má bıt' umoòuje urèit koš, do kterého zpráva patøí, nebo odvolat tuto zmìnu. Sloupec 'Odstranit' umoòuje zrušit zprávy, které ji nejsou zapotøebí.

History_OpenMessageSummary              Tato tabulka obsahuje celı text zprávy. Slova pouitá pøi klasifikaci jsou oznaèena barvou koše, pro kterı jsou nejvíce relevantní.

Bucket_MainTableSummary                 Tato tabulka poskytuje pøehled klasifikaèních košù. Kadı øádek obsahuje jméno koše, celkovı poèet slov pro danı koš, aktuální poèet slov, zda je pøi klasifikaci modifikován pøedmìt zprávy, zda jsou zprávy umisovány do karantény, a tabulka pro vıbìr barvy koše.

Bucket_StatisticsTableSummary           Tato tabulka poskytuje tøi sady statistickıch údajù o èinnosti POPFile. První z nich zobrazuje pøesnost klasifikace, druhá poèet klasifikovanıch zpráv pro jednotlivé koše a tøetí poèty slov v jednotlivıch koších a jejich relativní zastoupení.

Bucket_MaintenanceTableSummary          Tato tabulka obsahuje formuláøe pro zakládání, rušení a pøejmenovávání košù a pro vyhledání slova v koších a zjištìní jeho relativní pravdìpodobnosti.

Bucket_AccuracyChartSummary             Tato tabulka graficky znázoròuje pøesnost klasifikace zpráv.

Bucket_BarChartSummary                  Tato tabulka graficky znázoròuje relativní zastoupení klasifikovanıch zpráv a celkového poètu slov pro jednotlivé koše. 

Bucket_LookupResultsSummary             Tato tabulka poskytuje pravdìpodobnosti pro kadé slovo z korpusu. Pro kadı koš je zobrazena frekvence vıskytu slova, pravdìpodobnost, e se v koši objeví, a celkovı vliv na skóre pro danı koš, pokud se ve zprávì vyskytuje.

Bucket_WordListTableSummary             Tato tabulka nabízí seznam všech slov pro danı koš.

Magnet_MainTableSummary                 Tato tabulka zobrazuje seznam všech magnetù, které jsou pouity pro automatickou klasifikaci zpráv podle pevnıch pravidel. Kadı øádek obsahuje informace o tom, jak je magnet definován a pro kterı koš je urèen, a tlaèítko pro jeho zrušení.

Configuration_MainTableSummary          Tato tabulka obsahuje øadu formuláøù urèenıch k nastavování konfigurace POPFile.

Configuration_InsertionTableSummary     Tato tabulka osahuje tlaèítka urèující, zda se budou provádìt urèité modifikace hlavièky zprávy pøed jejím pøedáním poštovnímu klientu.

Security_MainTableSummary               Tato tabulka umoòuje nastavit zabezpeèení konfigurace POPFile, automatickou kontrolu novıch verzí programu a zasílání statistickıch údajù do centrálního úloištì autora.

Advanced_MainTableSummary               Tato tabulka obsahuje seznam slov, která POPFile pøi klasifikaci pro jejich vysokou èetnost ve zprávách ignoruje.

