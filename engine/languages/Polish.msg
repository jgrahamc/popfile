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
LanguageCode                            pl
LanguageCharset                         ISO-8859-2
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual

ManualLanguage                          en

# Common words that are used on their own all over the interface

Apply                                   Zatwierd¼
On                                      W³±czony
Off                                     Wy³±czony
TurnOn                                  W³±cz
TurnOff                                 Wy³±cz
Add                                     Dodaj
Remove                                  Usuñ
Previous                                Poprzedni
Next                                    Nastêpny
From                                    Od
Subject                                 Temat
Cc                                      CC
Classification                          Klasyfikacja
Reclassify                              Klasyfikuj
Probability                             Prawdopodobieñstwo
Scores                                  Punkty
QuickMagnets                            Szybki Musik
Undo                                    Cofnij
Close                                   Zamknij
Find                                    Znajd¼
Filter                                  Filtr
Yes                                     Tak
No                                      Nie
ChangeToYes                             Zmieñ na tak
ChangeToNo                              Zmieñ na nie
Bucket                                  Folder
Magnet                                  Musik
Delete                                  Skasuj
Create                                  Utwórz
To                                      Do
Total                                   Ca³kowity
Rename                                  Zmieñ
Frequency                               Czêstotliwo¶æ
Probability                             Prawdopodobieñstwo
Score                                   Punkty
Lookup                                  Szukaj
Word                                    S³owo
Count                                   Licz
Update                                  Aktualizuj
Refresh                                 Od¶wie¿

# The header and footer that appear on every UI page
Header_Title                            Centrum Sterowania POPFile
Header_Shutdown                         Wy³±cz daemona POPFile
Header_History                          Historia
Header_Buckets                          Foldery
Header_Configuration                    Konfiguracja
Header_Advanced                         Zaawansowane
Header_Security                         Bezpieczeñstwo
Header_Magnets                          Musiki

Footer_HomePage                         Strona g³ówna POPFile
Footer_Manual                           Pomoc (angielski)
Footer_Forums                           Forum dyskusyjne
Footer_FeedMe                           Wspomo¿enie finansowe
Footer_RequestFeature                   Zg³o¶ pomys³ udoskonalenia
Footer_MailingList                      Lista dyskusyjna

Configuration_Error1                    Separator musi byæ jednym znakiem
Configuration_Error2                    Numer portu musi siê mie¶ciæ miêdzy 1 a 65535
Configuration_Error3                    Port POP3 musi siê zawieraæ miêdzy 1 a 65535
Configuration_Error4                    Rozmiar strony musi siê zawieraæ miêdzy 1 a 1000
Configuration_Error5                    Liczba dni historii musi siê zawieraæ miêdzy 1 a 366
Configuration_Error6                    TCP timeout musi byæ miêdzy 10 a 300
Configuration_Error7                    Port XML RPC musi byæ miêdzy 1 i 65535
Configuration_POP3Port                  Port POP3
Configuration_POP3Update                Zmieniono port POP3 na %s; ta zmiana zadzia³a dopiero po restarcie POPFile'a.
Configuration_XMLRPCUpdate              Zmieniono port XML-RPC na %s; ta zmiana zadzia³a dopiero po restarcie POPFile'a
Configuration_XMLRPCPort                Port XML-RPC
Configuration_SMTPPort                  Port SMTP
Configuration_SMTPUpdate                Zmieniono port SMTP na %s; ta zmiana zadzia³a dopiero po restarcie POPFile'a
Configuration_NNTPPort                  Port NNTP
Configuration_NNTPUpdate                Zmieniono port NNTP na %s; ta zmiana zadzia³a dopiero po restarcie POPFile'a
Configuration_POP3Separator             POP3 serwer:port:u¿ytkownik separator
Configuration_NNTPSeparator             NNTP serwer:port:u¿ytkownik separator
Configuration_POP3SepUpdate             Zmieniono separator POP3 na %s
Configuration_NNTPSepUpdate             Zmieniono separator NNTP na %s
Configuration_UI                        Port interface'u WWW
Configuration_UIUpdate                  Zmieniono port interface'u WWW na %s; ta zmiana zadzia³a dopiero po restarcie POPFile'a
Configuration_History                   Liczba wiadomo¶ci na stronê
Configuration_HistoryUpdate             Zmieniono liczbê wiadomo¶ci na stronê na %s
Configuration_Days                      Liczba dni zachowania historii
Configuration_DaysUpdate                Zmieniono liczbê dni zachowania historii na %s
Configuration_UserInterface             Interface u¿ytkownika
Configuration_Skins                     Wygl±d
Configuration_SkinsChoose               Wybierz wygl±d
Configuration_Language                  Jêzyk
Configuration_LanguageChoose            Wybierz jêzyk
Configuration_ListenPorts               Opcje modu³u
Configuration_HistoryView               Widok historii
Configuration_TCPTimeout                Timeout po³±czenia
Configuration_TCPTimeoutSecs            Timeout po³±czenia w sekundach
Configuration_TCPTimeoutUpdate          Zmieniono timeout po³±czenia na %s
Configuration_ClassificationInsertion   Modyfikacja nag³ówków
Configuration_SubjectLine               Modyfikacja tematu wiadomo¶ci
Configuration_XTCInsertion              Nag³ówek X-Text-Classification
Configuration_XPLInsertion              Nag³ówek X-POPFile-Link
Configuration_Logging                   Rejestracja czynno¶ci
Configuration_None                      Brak
Configuration_ToScreen                  Ekran
Configuration_ToFile                    Plik
Configuration_ToScreenFile              Ekran i plik
Configuration_LoggerOutput              Rejestracja do:
Configuration_GeneralSkins              Wygl±d
Configuration_SmallSkins                Ma³e
Configuration_TinySkins                 Bardzo ma³e
Configuration_CurrentLogFile            &lt;aktualny plik rejestru&gt;

Advanced_Error1                         '%s' jest ju¿ na li¶cie ignorowanych s³ów
Advanced_Error2                         S³owa ignorowane mog± zawieraæ znaki alfanumeryczne, ., _, -, lub @
Advanced_Error3                         S³owo '%s' dodane do listy ignorowanych s³ów
Advanced_Error4                         '%s' nie jest na li¶cie ignorowanych s³ów
Advanced_Error5                         S³owo '%s' usuniête z listy ignorowanych s³ów
Advanced_StopWords                      Ignorowane s³owa
Advanced_Message1                       POPFile ignoruje nastêpuj±ce czêsto wystepuj±ce s³owa:
Advanced_AddWord                        Dodaj s³owo
Advanced_RemoveWord                     Usuñ s³owo

History_Filter                          &nbsp;(pokazujê folder <font color="%s">%s</font>)
History_FilterBy                        Filtruj wed³ug
History_Search                          &nbsp;(wyszukiwanie wg pola Od/Temat %s)
History_Title                           Ostatnie wiadomo¶ci
History_Jump                            Id¼ do wiadomo¶ci
History_ShowAll                         Poka¼ wszystko
History_ShouldBe                        Powinno byæ
History_NoFrom                          brak linii Od
History_NoSubject                       brak linii Temat
History_ClassifyAs                      Klasyfikuj jako
History_MagnetUsed                      U¿yto Musik
History_MagnetBecause                   <b>U¿yto Musik</b><p>Zaklasyfikowano do <font color="%s">%s</font> z powodu musika %s </p>
History_ChangedTo                       Zmieniono na <font color="%s">%s
History_Already                         Ju¿ przeklasyfikowano jako <font color="%s">%s</font>
History_RemoveAll                       Usuñ wszystkie
History_RemovePage                      Usuñ stronê
History_Remove                          Aby usun±æ pola ze strony kliknij (nie usuwa bazy s³ów):
History_SearchMessage                   Szukaj wg pól Od/Temat
History_NoMessages                      Brak wiadomo¶ci
History_ShowMagnet                      musikowane
History_ShowNoMagnet                    odmusikowane
History_Magnet                          &nbsp;(pokazujê wiadomo¶ci z musikami)
History_NoMagnet                        &nbsp;(pokazujê wiadomo¶ci bez musików)
History_ResetSearch                     Resetuj

Password_Title                          Has³o
Password_Enter                          Wpisz has³o
Password_Go                             Dalej!
Password_Error1                         Z³e has³o

Security_Error1                         Port musi byæ miêdzy 1 a 65535
Security_Stealth                        Operacje w trybie niewidocznym
Security_NoStealthMode                  Nie (tryb niewidoczny)
Security_ExplainStats                   (gdy to jest w³±czone POPFile wysy³a raz dziennie nastêpuj±ce trzy warto¶ci do skryptu na www.usethesource.com: bc (liczba folderów, które posiadasz), mc (liczba klasyfikowanych wiadomo¶ci) i ec (liczba b³êdów klasyfikacji).  S± one gromadzone w pliku i wykorzystam je do publikacji o ludziach u¿ywaj±cych POPFile'a i jak on dzia³a.  Mój serwer przechowuje dane przez 5 dni a nastêpnie je kasuje; Nie przechowujê ¿adnych danych o adresach IP, itp.)
Security_ExplainUpdate                  (gdy to jest w³±czone POPFile wysy³a raz dziennie nastêpuj±ce trzy warto¶ci do skryptu na www.usethesource.com: ma (numer wersji POPFile'a), mi (numer podwersji POPFile'a) i bn (numer kompilacji POPFile'a).  POPFile otrzymuje graficzn± informacjê na g³ównej stronie je¶li pojawi siê nowa wersja.  Mój serwer przechowuje dane przez 5 dni a nastêpnie je kasuje; Nie przechowujê ¿adnych danych o adresach IP, itp.)
Security_PasswordTitle                  Has³o interface'u u¿ytkownika
Security_Password                       Has³o
Security_PasswordUpdate                 Zmieniono has³o na %s
Security_AUTHTitle                      Zdalne serwery
Security_SecureServer                   Serwer POP3 SPA/AUTH
Security_SecureServerUpdate             Zmieniono bezpieczny serwer POP3 SPA/AUTH na %s; ta zmiania zadzia³a dopiero po restarcie POPFile'a
Security_SecurePort                     Port POP3 SPA/AUTH
Security_SecurePortUpdate               Zmieniono port POP3 SPA/AUTH na %s; ta zmiania zadzia³a dopiero po restarcie POPFile'a
Security_SMTPServer                     Serwer SMTP
Security_SMTPServerUpdate               Zmieniono serwer SMTP na %s; ta zmiania zadzia³a dopiero po restarcie POPFile'a
Security_SMTPPort                       Port SMTP
Security_SMTPPortUpdate                 Zmieniono port SMTP na %s; ta zmiania zadzia³a dopiero po restarcie POPFile'a
Security_POP3                           Akceptuj po³±czenia POP3 ze zdalnych komputerów (wymaga restartu POPFile'a)
Security_SMTP                           Akceptuj po³±czenia SMTP ze zdalnych komputerów (wymaga restartu POPFile'a)
Security_NNTP                           Akceptuj po³±czenia NNTP ze zdalnych komputerów (wymaga restartu POPFile'a)
Security_UI                             Akceptuj po³±czenia HTTP (Interface u¿ytkownika) ze zdalnych komputerów (wymaga restartu POPFile'a)
Security_XMLRPC                         Akceptuj po³±czenia XML-RPC ze zdalnych komputerów (wymaga restartu POPFile'a)
Security_UpdateTitle                    Sprawdzanie automatycznej aktualizacji
Security_Update                         Sprawd¼ codziennie zmiany w POPFile'u
Security_StatsTitle                     Statystyki
Security_Stats                          Wysy³aj statystyki codziennie

Magnet_Error1                           Musik '%s' ju¿ wystêpuje w folderze '%s'
Magnet_Error2                           Nowy musik '%s' jest niezgodny z musikiem '%s' w folderze '%s' i mo¿e spowodowaæ problemy. Nie dodano nowego musika.
Magnet_Error3                           Utwórz nowy musik '%s' w folderze '%s'
Magnet_CurrentMagnets                   Aktualne musiki
Magnet_Message1                         Nastêpuj±ce musiki spowoduj± klasyfikacjê listów zawsze w okre¶lonych folderach.
Magnet_CreateNew                        Utwórz nowy musik
Magnet_Explanation                      <b>Nastêpuj±ce rodzaje musików s± dostêpne:</b> <ul><li><b>Adres lub nazwa nadawcy:</b> na przyk³ad: john@company.com dotyczy konkretnego adresu, <br />company.com dotyczy wszystkich nadawców z company.com, <br />John Doe dotyczy konkretnej osoby, John dotyczy wszystkich Johnów</li><li><b>Adres lub nazwa Do/Cc:</b> Jak w przypadku pola Od, ale dotyczy pól Do:/Cc: </li> <li><b>S³owa w temacie:</b> na przyk³ad: hello dotyczy wszystkich wiadomo¶ci z hello w temacie</li></ul>
Magnet_MagnetType                       Rodzaj musika
Magnet_Value                            Warto¶æ
Magnet_Always                           Zawsze idzie do folderu
Magnet_Jump                             Id¼ do strony musików

Bucket_Error1                           Nazwy folderów mog± zawieraæ tylko ma³e litery od a do z, cyfry 0 do 9,  oraz - i _
Bucket_Error2                           Folder %s ju¿ istnieje
Bucket_Error3                           Utworzono folder %s
Bucket_Error4                           Proszê wpisaæ w³a¶ciwe s³owo
Bucket_Error5                           Zmieniono nazwê folderu %s na %s
Bucket_Error6                           Usuniêto folder %s
Bucket_Title                            Podsumowanie
Bucket_BucketName                       Nazwa folderu
Bucket_WordCount                        Liczba s³ów
Bucket_WordCounts                       Zliczanie s³ów
Bucket_UniqueWords                      Unikatowe s³owa
Bucket_SubjectModification              Modyfikacja tematu wiadomo¶ci
Bucket_ChangeColor                      Zmieñ kolor
Bucket_NotEnoughData                    Brak wystarczaj±cych danych
Bucket_ClassificationAccuracy           Poprawno¶æ klasyfikacji
Bucket_EmailsClassified                 Wiadomo¶ci zaklasyfikowane
Bucket_EmailsClassifiedUpper            Wiadomo¶ci zaklasyfikowane
Bucket_ClassificationErrors             B³êdy klasyfikacji
Bucket_Accuracy                         Poprawno¶æ
Bucket_ClassificationCount              Liczba klasyfikacji
Bucket_ClassificationFP                 B³±d dodania
Bucket_ClassificationFN                 B³±d niedodania
Bucket_ResetStatistics                  Resetuj
Bucket_LastReset                        Ostatni reset
Bucket_CurrentColor                     %s obecny kolor to %s
Bucket_SetColorTo                       Ustaw kolor %s na %s
Bucket_Maintenance                      Utrzymanie
Bucket_CreateBucket                     Utwórz folder o nazwie
Bucket_DeleteBucket                     Usuñ folder o nazwie
Bucket_RenameBucket                     Zmieñ nazwê folderu
Bucket_Lookup                           Szukaj
Bucket_LookupMessage                    Szukaj s³owa w folderze
Bucket_LookupMessage2                   Szukaj dla
Bucket_LookupMostLikely                 List ze s³owem <b>%s</b> prawdopodobnie powinien siê znale¼æ w <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> nie wystepuje w ¿adnym folderze
Bucket_DisabledGlobally                 Zablokowane globalnie
Bucket_To                               do
Bucket_Quarantine                       Kwarantanna

SingleBucket_Title                      Szczegó³y dla %s
SingleBucket_WordCount                  Liczba s³ów w folderze
SingleBucket_TotalWordCount             Ca³kowita liczba s³ów
SingleBucket_Percentage                 Procent ca³o¶ci
SingleBucket_WordTable                  Tabela s³ów dla %s
SingleBucket_Message1                   Kliknij literê w indeksie, aby zobaczyæ listê s³ów rozpoczynaj±cych siê od tej litery.  Kliknij na dowolne s³owo, aby zobaczyæ jego rozk³ad prawdopodobieñstwa.
SingleBucket_Unique                     S³owo %s jest unikatowe
SingleBucket_ClearBucket                Usuñ wszystkie s³owa

Session_Title                           Sesja POPFile'a zosta³a zakoñczona
Session_Error                           Twoja sesja POPFile'a zosta³a zakoñczona.  Mog³o siê to zdarzyæ w wyniku restartu POPFile'a lub zamkniêcia przegl±darki. Kliknij na jeden z powy¿szych linków.

View_Title                              Widok pojedynczej wiadomo¶ci

Header_MenuSummary                      Ta tabela pozwala na dostêp do ró¿nych elementów centrum sterowania.
History_MainTableSummary                Ta tabela pokazuje nadawców i tematy odstatnio odebranych wiadomo¶ci i pozwala na reklasyfikacjê.  Klikniêcie na temat spowoduje pokazanie ca³ej wiadomo¶ci, wraz z informacj± o powodach klasyfikacji.  Kolumna 'Powinno byæ' pozwala na okre¶lenie w³a¶ciwego folderu lub cofniêcie operacji. Kolumna 'Usuñ' pozwala usun±æ okre¶lone wiadomo¶ci z historii, je¶li ich ju¿ nie potrzebujesz.
History_OpenMessageSummary              Ta tabela zawiera pe³ny tekst wiadomo¶ci, ze s³owami u¿ytymi do klasyfikacji pod¶wietlonymi w kolorze folderu, do którego najlepiej pasuj±.
Bucket_MainTableSummary                 Ta tabela pokazuje przegl±d folderów klasyfikacyjnych.  Ka¿dy wiersz pokazuje nazwê folderu, liczbê s³ów w nim zawartych, liczbê niepowtarzalnych s³ów w folderze, mo¿liwo¶æ zmiany tematu wiadomo¶ci po zaklasyfikowaniu do folderu, opcjê kwarantanny oraz tabelê kolorów wy¶wietlania (do wyboru).
Bucket_StatisticsTableSummary           Ta tabela przedstawia trzy rodzaje statystyk dzia³ania POPFile'a.  Pierwsza okre¶la poprawno¶æ klasyfikacji, druga liczbê zaklasyfikowanych wiadomo¶ci do poszczególnych folderów, a trzecia liczbê s³ów w folderach i ich udzia³ w ca³ej liczbie.
Bucket_MaintenanceTableSummary          Ta tabela zawiera formularz do tworzenia, zmiany i usuwania folderów oraz wyszukiwania s³ów w folderach, a tak¿e pokazywania rozk³adów prawdopodobieñstwa.
Bucket_AccuracyChartSummary             Ta tabela pokazuje graficznie poprawno¶æ klasyfikacji
Bucket_BarChartSummary                  Ta tabela pokazuje graficznie rozk³ad procentowy dla ka¿dego folderu.  Jest wykorzystywana do pokazywania liczby wiadomo¶ci i liczby s³ów.
Bucket_LookupResultsSummary             Ta tabela pokazuje rozk³ad prawdopodobieñstwa dla ka¿dego s³owa.  Dla ka¿dego folderu, pokazuje czêstotliwo¶æ wystêpowania s³owa, prawdopodobieñstwo wyst±pienia w folderze, oraz ogólny wp³yw na wynik, je¶li s³owo wyst±pi w wiadomo¶ci.
Bucket_WordListTableSummary             Ta tabela przedstawia alfabetycznie listê s³ów w folderach.
Magnet_MainTableSummary                 Ta tabela pokazuje listê musików klasyfikuj±cych automatycznie wiadomo¶ci zgodnie z przyjêtymi na sztywno zasadami.  W ka¿dym wierszu znajduje siê musik, przypisany folder oraz przycisk do usuniêcia musika.
Configuration_MainTableSummary          Ta tabela zawiera fomularze do konfigurowania POPFile'a.
Configuration_InsertionTableSummary     Ta tabela zawiera prze³±czniki okreslaj±ce czy dokonywaæ zmian w nag³ówkach wiadomo¶ci przy przesy³aniu do programu pocztowego.
Security_MainTableSummary               Ta tabela zawiera kontrolki ustawiaj±ce bezpieczeñstwo POPFile'a, mo¿liwo¶æ sprawdzania aktualizacji oraz mo¿liwo¶æ wysy³ania statystyk o dzia³aniu POPFile'a do centralnego rejestru programu znajduj±cego siê na serwerze autora.
Advanced_MainTableSummary               Ta tabela zawiera listê s³ów ignorowanych przez POPFile'a w traksie klasyfikacji wiadomo¶ci z powodu ich czêstego wystêpowania.  S± one zorganizowane wierszami, alfabetycznie..

