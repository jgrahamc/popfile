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

# Identify the language and character set used for the interface
LanguageCode                            pl
LanguageCharset                         ISO-8859-2
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual

ManualLanguage                          en

# Common words that are used on their own all over the interface

Apply                                   Zatwierdź
On                                      Włączony
Off                                     Wyłączony
TurnOn                                  Włącz
TurnOff                                 Wyłącz
Add                                     Dodaj
Remove                                  Usuń
Previous                                Poprzedni
Next                                    Następny
From                                    Od
Subject                                 Temat
Cc                                      CC
Classification                          Klasyfikacja
Reclassify                              Klasyfikuj
Probability                             Prawdopodobieństwo
Scores                                  Punkty
QuickMagnets                            Szybki Musik
Undo                                    Cofnij
Close                                   Zamknij
Find                                    Znajdź
Filter                                  Filtr
Yes                                     Tak
No                                      Nie
ChangeToYes                             Zmień na tak
ChangeToNo                              Zmień na nie
Bucket                                  Folder
Magnet                                  Musik
Delete                                  Skasuj
Create                                  Utwórz
To                                      Do
Total                                   Całkowity
Rename                                  Zmień
Frequency                               Częstotliwość
Probability                             Prawdopodobieństwo
Score                                   Punkty
Lookup                                  Szukaj
Word                                    Słowo
Count                                   Licz
Update                                  Aktualizuj
Refresh                                 Odśwież

# The header and footer that appear on every UI page
Header_Title                            Centrum Sterowania POPFile
Header_Shutdown                         Wyłącz daemona POPFile
Header_History                          Historia
Header_Buckets                          Foldery
Header_Configuration                    Konfiguracja
Header_Advanced                         Zaawansowane
Header_Security                         Bezpieczeństwo
Header_Magnets                          Musiki

Footer_HomePage                         Strona główna POPFile
Footer_Manual                           Pomoc (angielski)
Footer_Forums                           Forum dyskusyjne
Footer_FeedMe                           Wspomożenie finansowe
Footer_RequestFeature                   Zgłoś pomysł udoskonalenia
Footer_MailingList                      Lista dyskusyjna

Configuration_Error1                    Separator musi być jednym znakiem
Configuration_Error2                    Numer portu musi się mieścić między 1 a 65535
Configuration_Error3                    Port POP3 musi się zawierać między 1 a 65535
Configuration_Error4                    Rozmiar strony musi się zawierać między 1 a 1000
Configuration_Error5                    Liczba dni historii musi się zawierać między 1 a 366
Configuration_Error6                    TCP timeout musi być między 10 a 1800
Configuration_Error7                    Port XML RPC musi być między 1 i 65535
Configuration_POP3Port                  Port POP3
Configuration_POP3Update                Zmieniono port POP3 na %s; ta zmiana zadziała dopiero po restarcie POPFile'a.
Configuration_XMLRPCUpdate              Zmieniono port XML-RPC na %s; ta zmiana zadziała dopiero po restarcie POPFile'a
Configuration_XMLRPCPort                Port XML-RPC
Configuration_SMTPPort                  Port SMTP
Configuration_SMTPUpdate                Zmieniono port SMTP na %s; ta zmiana zadziała dopiero po restarcie POPFile'a
Configuration_NNTPPort                  Port NNTP
Configuration_NNTPUpdate                Zmieniono port NNTP na %s; ta zmiana zadziała dopiero po restarcie POPFile'a
Configuration_POP3Separator             POP3 serwer:port:użytkownik separator
Configuration_NNTPSeparator             NNTP serwer:port:użytkownik separator
Configuration_POP3SepUpdate             Zmieniono separator POP3 na %s
Configuration_NNTPSepUpdate             Zmieniono separator NNTP na %s
Configuration_UI                        Port interface'u WWW
Configuration_UIUpdate                  Zmieniono port interface'u WWW na %s; ta zmiana zadziała dopiero po restarcie POPFile'a
Configuration_History                   Liczba wiadomości na stronę
Configuration_HistoryUpdate             Zmieniono liczbę wiadomości na stronę na %s
Configuration_Days                      Liczba dni zachowania historii
Configuration_DaysUpdate                Zmieniono liczbę dni zachowania historii na %s
Configuration_UserInterface             Interface użytkownika
Configuration_Skins                     Wygląd
Configuration_SkinsChoose               Wybierz wygląd
Configuration_Language                  Język
Configuration_LanguageChoose            Wybierz język
Configuration_ListenPorts               Opcje modułu
Configuration_HistoryView               Widok historii
Configuration_TCPTimeout                Timeout połączenia
Configuration_TCPTimeoutSecs            Timeout połączenia w sekundach
Configuration_TCPTimeoutUpdate          Zmieniono timeout połączenia na %s
Configuration_ClassificationInsertion   Modyfikacja nagłówków
Configuration_SubjectLine               Modyfikacja tematu wiadomości
Configuration_XTCInsertion              Nagłówek X-Text-Classification
Configuration_XPLInsertion              Nagłówek X-POPFile-Link
Configuration_Logging                   Rejestracja czynności
Configuration_None                      Brak
Configuration_ToScreen                  Ekran
Configuration_ToFile                    Plik
Configuration_ToScreenFile              Ekran i plik
Configuration_LoggerOutput              Rejestracja do:
Configuration_GeneralSkins              Wygląd
Configuration_SmallSkins                Małe
Configuration_TinySkins                 Bardzo małe
Configuration_CurrentLogFile            &lt;aktualny plik rejestru&gt;

Advanced_Error1                         '%s' jest już na liście ignorowanych słów
Advanced_Error2                         Słowa ignorowane mogą zawierać znaki alfanumeryczne, ., _, -, lub @
Advanced_Error3                         Słowo '%s' dodane do listy ignorowanych słów
Advanced_Error4                         '%s' nie jest na liście ignorowanych słów
Advanced_Error5                         Słowo '%s' usunięte z listy ignorowanych słów
Advanced_StopWords                      Ignorowane słowa
Advanced_Message1                       POPFile ignoruje następujące często wystepujące słowa:
Advanced_AddWord                        Dodaj słowo
Advanced_RemoveWord                     Usuń słowo

History_Filter                          &nbsp;(pokazuję folder <font color="%s">%s</font>)
History_FilterBy                        Filtruj według
History_Search                          &nbsp;(wyszukiwanie wg pola Od/Temat %s)
History_Title                           Ostatnie wiadomości
History_Jump                            Idź do wiadomości
History_ShowAll                         Pokaź wszystko
History_ShouldBe                        Powinno być
History_NoFrom                          brak linii Od
History_NoSubject                       brak linii Temat
History_ClassifyAs                      Klasyfikuj jako
History_MagnetUsed                      Użyto Musik
History_MagnetBecause                   <b>Użyto Musik</b><p>Zaklasyfikowano do <font color="%s">%s</font> z powodu musika %s </p>
History_ChangedTo                       Zmieniono na <font color="%s">%s
History_Already                         Już przeklasyfikowano jako <font color="%s">%s</font>
History_RemoveAll                       Usuń wszystkie
History_RemovePage                      Usuń stronę
History_Remove                          Aby usunąć pola ze strony kliknij (nie usuwa bazy słów):
History_SearchMessage                   Szukaj wg pól Od/Temat
History_NoMessages                      Brak wiadomości
History_ShowMagnet                      musikowane
History_ShowNoMagnet                    odmusikowane
History_Magnet                          &nbsp;(pokazuję wiadomości z musikami)
History_NoMagnet                        &nbsp;(pokazuję wiadomości bez musików)
History_ResetSearch                     Resetuj

Password_Title                          Hasło
Password_Enter                          Wpisz hasło
Password_Go                             Dalej!
Password_Error1                         Złe hasło

Security_Error1                         Port musi być między 1 a 65535
Security_Stealth                        Operacje w trybie niewidocznym
Security_NoStealthMode                  Nie (tryb niewidoczny)
Security_ExplainStats                   (gdy to jest włączone POPFile wysyła raz dziennie następujące trzy wartości do skryptu na www.usethesource.com: bc (liczba folderów, które posiadasz), mc (liczba klasyfikowanych wiadomości) i ec (liczba błędów klasyfikacji).  Są one gromadzone w pliku i wykorzystam je do publikacji o ludziach używających POPFile'a i jak on działa.  Mój serwer przechowuje dane przez 5 dni a następnie je kasuje; Nie przechowuję żadnych danych o adresach IP, itp.)
Security_ExplainUpdate                  (gdy to jest włączone POPFile wysyła raz dziennie następujące trzy wartości do skryptu na www.usethesource.com: ma (numer wersji POPFile'a), mi (numer podwersji POPFile'a) i bn (numer kompilacji POPFile'a).  POPFile otrzymuje graficzną informację na głównej stronie jeśli pojawi się nowa wersja.  Mój serwer przechowuje dane przez 5 dni a następnie je kasuje; Nie przechowuję żadnych danych o adresach IP, itp.)
Security_PasswordTitle                  Hasło interface'u użytkownika
Security_Password                       Hasło
Security_PasswordUpdate                 Zmieniono hasło na %s
Security_AUTHTitle                      Zdalne serwery
Security_SecureServer                   Serwer POP3 SPA/AUTH
Security_SecureServerUpdate             Zmieniono bezpieczny serwer POP3 SPA/AUTH na %s; ta zmiania zadziała dopiero po restarcie POPFile'a
Security_SecurePort                     Port POP3 SPA/AUTH
Security_SecurePortUpdate               Zmieniono port POP3 SPA/AUTH na %s; ta zmiania zadziała dopiero po restarcie POPFile'a
Security_SMTPServer                     Serwer SMTP
Security_SMTPServerUpdate               Zmieniono serwer SMTP na %s; ta zmiania zadziała dopiero po restarcie POPFile'a
Security_SMTPPort                       Port SMTP
Security_SMTPPortUpdate                 Zmieniono port SMTP na %s; ta zmiania zadziała dopiero po restarcie POPFile'a
Security_POP3                           Akceptuj połączenia POP3 ze zdalnych komputerów (wymaga restartu POPFile'a)
Security_SMTP                           Akceptuj połączenia SMTP ze zdalnych komputerów (wymaga restartu POPFile'a)
Security_NNTP                           Akceptuj połączenia NNTP ze zdalnych komputerów (wymaga restartu POPFile'a)
Security_UI                             Akceptuj połączenia HTTP (Interface użytkownika) ze zdalnych komputerów (wymaga restartu POPFile'a)
Security_XMLRPC                         Akceptuj połączenia XML-RPC ze zdalnych komputerów (wymaga restartu POPFile'a)
Security_UpdateTitle                    Sprawdzanie automatycznej aktualizacji
Security_Update                         Sprawdź codziennie zmiany w POPFile'u
Security_StatsTitle                     Statystyki
Security_Stats                          Wysyłaj statystyki codziennie

Magnet_Error1                           Musik '%s' już występuje w folderze '%s'
Magnet_Error2                           Nowy musik '%s' jest niezgodny z musikiem '%s' w folderze '%s' i może spowodować problemy. Nie dodano nowego musika.
Magnet_Error3                           Utwórz nowy musik '%s' w folderze '%s'
Magnet_CurrentMagnets                   Aktualne musiki
Magnet_Message1                         Następujące musiki spowodują klasyfikację listów zawsze w określonych folderach.
Magnet_CreateNew                        Utwórz nowy musik
Magnet_Explanation                      <b>Następujące rodzaje musików są dostępne:</b> <ul><li><b>Adres lub nazwa nadawcy:</b> na przykład: john@company.com dotyczy konkretnego adresu, <br />company.com dotyczy wszystkich nadawców z company.com, <br />John Doe dotyczy konkretnej osoby, John dotyczy wszystkich Johnów</li><li><b>Adres lub nazwa Do/Cc:</b> Jak w przypadku pola Od, ale dotyczy pól Do:/Cc: </li> <li><b>Słowa w temacie:</b> na przykład: hello dotyczy wszystkich wiadomości z hello w temacie</li></ul>
Magnet_MagnetType                       Rodzaj musika
Magnet_Value                            Wartość
Magnet_Always                           Zawsze idzie do folderu
Magnet_Jump                             Idź do strony musików

Bucket_Error1                           Nazwy folderów mogą zawierać tylko małe litery od a do z, cyfry 0 do 9,  oraz - i _
Bucket_Error2                           Folder %s już istnieje
Bucket_Error3                           Utworzono folder %s
Bucket_Error4                           Proszę wpisać właściwe słowo
Bucket_Error5                           Zmieniono nazwę folderu %s na %s
Bucket_Error6                           Usunięto folder %s
Bucket_Title                            Podsumowanie
Bucket_BucketName                       Nazwa folderu
Bucket_WordCount                        Liczba słów
Bucket_WordCounts                       Zliczanie słów
Bucket_UniqueWords                      Unikatowe słowa
Bucket_SubjectModification              Modyfikacja tematu wiadomości
Bucket_ChangeColor                      Zmień kolor
Bucket_NotEnoughData                    Brak wystarczających danych
Bucket_ClassificationAccuracy           Poprawność klasyfikacji
Bucket_EmailsClassified                 Wiadomości zaklasyfikowane
Bucket_EmailsClassifiedUpper            Wiadomości zaklasyfikowane
Bucket_ClassificationErrors             Błędy klasyfikacji
Bucket_Accuracy                         Poprawność
Bucket_ClassificationCount              Liczba klasyfikacji
Bucket_ClassificationFP                 Błąd dodania
Bucket_ClassificationFN                 Błąd niedodania
Bucket_ResetStatistics                  Resetuj
Bucket_LastReset                        Ostatni reset
Bucket_CurrentColor                     %s obecny kolor to %s
Bucket_SetColorTo                       Ustaw kolor %s na %s
Bucket_Maintenance                      Utrzymanie
Bucket_CreateBucket                     Utwórz folder o nazwie
Bucket_DeleteBucket                     Usuń folder o nazwie
Bucket_RenameBucket                     Zmień nazwę folderu
Bucket_Lookup                           Szukaj
Bucket_LookupMessage                    Szukaj słowa w folderze
Bucket_LookupMessage2                   Szukaj dla
Bucket_LookupMostLikely                 List ze słowem <b>%s</b> prawdopodobnie powinien się znaleźć w <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> nie wystepuje w żadnym folderze
Bucket_DisabledGlobally                 Zablokowane globalnie
Bucket_To                               do
Bucket_Quarantine                       Kwarantanna

SingleBucket_Title                      Szczegóły dla %s
SingleBucket_WordCount                  Liczba słów w folderze
SingleBucket_TotalWordCount             Całkowita liczba słów
SingleBucket_Percentage                 Procent całości
SingleBucket_WordTable                  Tabela słów dla %s
SingleBucket_Message1                   Kliknij literę w indeksie, aby zobaczyć listę słów rozpoczynających się od tej litery.  Kliknij na dowolne słowo, aby zobaczyć jego rozkład prawdopodobieństwa.
SingleBucket_Unique                     Słowo %s jest unikatowe
SingleBucket_ClearBucket                Usuń wszystkie słowa

Session_Title                           Sesja POPFile'a została zakończona
Session_Error                           Twoja sesja POPFile'a została zakończona.  Mogło się to zdarzyć w wyniku restartu POPFile'a lub zamknięcia przeglądarki. Kliknij na jeden z powyższych linków.

View_Title                              Widok pojedynczej wiadomości

Header_MenuSummary                      Ta tabela pozwala na dostęp do różnych elementów centrum sterowania.
History_MainTableSummary                Ta tabela pokazuje nadawców i tematy odstatnio odebranych wiadomości i pozwala na reklasyfikację.  Kliknięcie na temat spowoduje pokazanie całej wiadomości, wraz z informacją o powodach klasyfikacji.  Kolumna 'Powinno być' pozwala na określenie właściwego folderu lub cofnięcie operacji. Kolumna 'Usuń' pozwala usunąć określone wiadomości z historii, jeśli ich już nie potrzebujesz.
History_OpenMessageSummary              Ta tabela zawiera pełny tekst wiadomości, ze słowami użytymi do klasyfikacji podświetlonymi w kolorze folderu, do którego najlepiej pasują.
Bucket_MainTableSummary                 Ta tabela pokazuje przegląd folderów klasyfikacyjnych.  Każdy wiersz pokazuje nazwę folderu, liczbę słów w nim zawartych, liczbę niepowtarzalnych słów w folderze, możliwość zmiany tematu wiadomości po zaklasyfikowaniu do folderu, opcję kwarantanny oraz tabelę kolorów wyświetlania (do wyboru).
Bucket_StatisticsTableSummary           Ta tabela przedstawia trzy rodzaje statystyk działania POPFile'a.  Pierwsza określa poprawność klasyfikacji, druga liczbę zaklasyfikowanych wiadomości do poszczególnych folderów, a trzecia liczbę słów w folderach i ich udział w całej liczbie.
Bucket_MaintenanceTableSummary          Ta tabela zawiera formularz do tworzenia, zmiany i usuwania folderów oraz wyszukiwania słów w folderach, a także pokazywania rozkładów prawdopodobieństwa.
Bucket_AccuracyChartSummary             Ta tabela pokazuje graficznie poprawność klasyfikacji
Bucket_BarChartSummary                  Ta tabela pokazuje graficznie rozkład procentowy dla każdego folderu.  Jest wykorzystywana do pokazywania liczby wiadomości i liczby słów.
Bucket_LookupResultsSummary             Ta tabela pokazuje rozkład prawdopodobieństwa dla każdego słowa.  Dla każdego folderu, pokazuje częstotliwość występowania słowa, prawdopodobieństwo wystąpienia w folderze, oraz ogólny wpływ na wynik, jeśli słowo wystąpi w wiadomości.
Bucket_WordListTableSummary             Ta tabela przedstawia alfabetycznie listę słów w folderach.
Magnet_MainTableSummary                 Ta tabela pokazuje listę musików klasyfikujących automatycznie wiadomości zgodnie z przyjętymi na sztywno zasadami.  W każdym wierszu znajduje się musik, przypisany folder oraz przycisk do usunięcia musika.
Configuration_MainTableSummary          Ta tabela zawiera fomularze do konfigurowania POPFile'a.
Configuration_InsertionTableSummary     Ta tabela zawiera przełączniki okreslające czy dokonywać zmian w nagłówkach wiadomości przy przesyłaniu do programu pocztowego.
Security_MainTableSummary               Ta tabela zawiera kontrolki ustawiające bezpieczeństwo POPFile'a, możliwość sprawdzania aktualizacji oraz możliwość wysyłania statystyk o działaniu POPFile'a do centralnego rejestru programu znajdującego się na serwerze autora.
Advanced_MainTableSummary               Ta tabela zawiera listę słów ignorowanych przez POPFile'a w traksie klasyfikacji wiadomości z powodu ich częstego występowania.  Są one zorganizowane wierszami, alfabetycznie..

