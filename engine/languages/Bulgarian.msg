# Copyright (c) 2001-2003 John Graham-Cumming

# Identify the language and character set used for the interface
LanguageCode                            bg
LanguageCharset                         Windows-1251

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          bg

# Common words that are used on their own all over the interface
Apply                                   Промени
On                                      Вкл.
Off                                     Изкл.
TurnOn                                  Включи
TurnOff                                 Изключи
Add                                     Добави
Remove                                  Премахни
Previous                                Пред.
Next                                    Следв.
From                                    От
Subject                                 Заглавие 
Classification                          Класификация
Reclassify                              Прекласиф.
Undo                                    Върни
Close                                   Затвори
Find                                    Търси
Filter                                  Филтър
Yes                                     Да
No                                      Не
ChangeToYes                             Направи ДА
ChangeToNo                              Направи НЕ
Bucket                                  Кош
Magnet                                  Магнит
Delete                                  Изтрий
Create                                  Създай
To                                      До
Total                                   Общо
Rename                                  Преименувай
Frequency                               Честота
Probability                             Вероятност
Score                                   Оценка
Lookup                                  Търси

# The header and footer that appear on every UI page
Header_Title                            Панел за управление на POPFile
Header_Shutdown                         Спри POPFile
Header_History                          Хроника
Header_Buckets                          Кошове
Header_Configuration                    Конфигурация
Header_Advanced                         Специални
Header_Security                         Защита
Header_Magnets                          Магнити

Footer_HomePage                         Web страница на POPFile
Footer_Manual                           Ръководство
Footer_Forums                           Форуми
Footer_FeedMe                           Дарение
Footer_RequestFeature                   Идея
Footer_MailingList                      Абонамент

Configuration_Error1                    Въведете за разделител един-единствен знак
Configuration_Error2                    Портът за потребителския интерфейс трябва да бъде число между 1 и 65535
Configuration_Error3                    Работният порт за POP3 трябва да бъде число между 1 и 65535
Configuration_Error4                    Размерът на страницата трябва да бъде число между 1 и 1000
Configuration_Error5                    Броят дни в хрониката трябва да бъде число между 1 и 366
Configuration_Error6                    TCP таймаутът трябва да бъде число между 10 и 300
Configuration_POP3Port                  Работен порт за POP3
Configuration_POP3Update                Работният порт е променен на %s; тази промяна ще се отрази при следващото стартиране на POPFile.
Configuration_Separator                 Разделител
Configuration_SepUpdate                 Разделителят променен на %s
Configuration_UI                        Порт за потребителски интерфейс
Configuration_UIUpdate                  Портът за потребителски интерфейс е променен на %s; тази промяна ще се отрази при следващото стартиране на POPFile.
Configuration_History                   Брой съобщения на страница
Configuration_HistoryUpdate             Броят съобщения на страница променен на %s
Configuration_Days                      Брой дни за пазене на хроника
Configuration_DaysUpdate                Броят на дните за пазене на хроника променен на %s
Configuration_UserInterface             Потребителски интерфейс
Configuration_Skins                     Skins
Configuration_SkinsChoose               Choose skin
Configuration_Language                  Език
Configuration_LanguageChoose            Избери език
Configuration_ListenPorts               Портове
Configuration_HistoryView               Вид на хрониката
Configuration_TCPTimeout                TCP Таймаут
Configuration_TCPTimeoutSecs            Таймаут на TCP връзките в секунди
Configuration_TCPTimeoutUpdate          TCP таймаутът променен на %s
Configuration_ClassificationInsertion   Обозначаване на класификацията
Configuration_SubjectLine               Промяна на заглавието
Configuration_XTCInsertion              Вмъкване на X-Text-Classification
Configuration_XPLInsertion              Вмъкване на X-POPFile-Link
Configuration_Logging                   Протоколиране
Configuration_None                      Без
Configuration_ToScreen                  На екрана
Configuration_ToFile                    Във файл
Configuration_ToScreenFile              Във файла и на екран
Configuration_LoggerOutput              Място за протоколиране

Advanced_Error1                         '%s' вече присъства в списъка с игнорираните думи
Advanced_Error2                         Игнорираните думи може да съдържат само букви, цифри и знаците ., _, -, или @
Advanced_Error3                         '%s' добавена към списъка с игнорирани думи
Advanced_Error4                         '%s' не присъства в списъка с игнорираните думи
Advanced_Error5                         '%s' премахната към списъка с игнорирани думи
Advanced_StopWords                      Игнорирани думи
Advanced_Message1                       Следните думи се игнорират при класифициране, тъй като се срещат твърде често.
Advanced_AddWord                        Добави дума
Advanced_RemoveWord                     Премахни дума

History_Filter                          &nbsp;(показан е само кош <font color="%s">%s</font>)
History_FilterBy                        Filter By
History_Search                          &nbsp;(търсене за заглавие %s)
History_Title                           Последни съобщения
History_Jump                            Преход към съобщение
History_ShowAll                         Покажи всички
History_ShouldBe                        Трябва да бъде
History_NoFrom                          Няма подател
History_NoSubject                       Няма заглавие
History_ClassifyAs                      Класифицирай като
History_MagnetUsed                      Според магнит
History_ChangedTo                       Променено на <font color="%s">%s
History_Already                         Вече класифицирано като <font color="%s">%s</font>
History_RemoveAll                       Премахни всички
History_RemovePage                      Премахни тази страница
History_Remove                          За премахване на съобщенията натисни:
History_SearchMessage                   Търси по подател и заглавие
History_NoMessages                      Няма съобщения
History_ShowMagnet                      По магнит
History_Magnet                          &nbsp;(само класифицираните по магнит)
History_ResetSearch                     Изчисти търсенето

Password_Title                          Парола
Password_Enter                          Въведи парола
Password_Go                             ОК
Password_Error1                         Невалидна парола

Security_Error1                         Портът с легитимиране трябва да бъде число между 1 и 65535
Security_Stealth                        Скрит режим
Security_NoStealthMode                  Не (скрит режим)
Security_ExplainStats                   (Когато това е включено, POPFile веднъж дневно изпраща към скрипт на www.usethesource.com: bc (броя на кошовете), mc (броя съобщения, класифицирани от POPFile) и ec (броя на грешно класифицираните съобщения). Тези стойности се съхраняват във файл и благодарение на тях аз публикувам статистика за начина, по който хората използват POPFile и колко добре работи. Моят Web сървър съхранява лог-файловете си в продължение на около 5 дни, след което ги изтрива; аз не пазя връзка между статистическите данни и конкретните IP адреси.)
Security_ExplainUpdate                  (Когато това е включено, POPFile веднъж дневно изпраща към скрипт на www.usethesource.com: bc (броя на кошовете), mc (броя съобщения, класифицирани от POPFile) и ec (броя на грешно класифицираните съобщения). POPFile получава обратно известие дали има по-нова версия на софтуера и показва съответна картинка на всяка страница. Моят Web сървър съхранява лог-файловете си в продължение на около 5 дни, след което ги изтрива; аз не пазя връзка между запитванията за нова версия и конкретните IP адреси.)
Security_PasswordTitle                  Парола за потребителския интерфейс
Security_Password                       Парола
Security_PasswordUpdate                 Паролата променена на %s
Security_AUTHTitle                      Легитимация пред сървъра/AUTH
Security_SecureServer                   Сървър, изискващ легитимация
Security_SecureServerUpdate             Сървърът с леитимация промене на %s; тази промяна ще бъде отразена при следващото стартиране на POPFile
Security_SecurePort                     Порт за легитимация
Security_SecurePortUpdate               Портът променен на %s; тази промяна ще бъде отразена при следващото стартиране на POPFile
Security_POP3                           Приемане на POP3 връзки от други машини
Security_UI                             Приемане на HTTP връзки (за потребителския интерфейс) от други машини
Security_UpdateTitle                    Автоматична проверка за нови версии
Security_Update                         Ежедневна проверка за нови версии на POPFile
Security_StatsTitle                     Събиране на статистика
Security_Stats                          Ежедневно изпращане на статистически данни на автора

Magnet_Error1                           Магнит '%s' вече е зададен за кош '%s'
Magnet_Error2                           Новият магнит '%s' противоречи на магнит '%s' за кош '%s' и може да предизвика нееднозначност; магнитът не е добавен.
Magnet_Error3                           Създай нов магнит '%s' за кош '%s'
Magnet_CurrentMagnets                   Магнити
Magnet_Message1                         Следните магнити служат за незабавно класифициране на съобщенията в даден кош.
Magnet_CreateNew                        Създай нов магнит
Magnet_Explanation                      Има три вида магнити:</b> <ul><li><b>Адрес или име на подател:</b> Например: john@company.com за конкретен адрес, <br />company.com за всички адреси от company.com, <br />John Doe за конкретен подател, John за всички John-овци</li><li><b>Адрес или име на получател:</b> Подобно на адреса на подател, но за адреса на получателя на съобщението</li><li><b>Думи от заглавието:</b> Например: hello за всички съобщения, чието заглавие съдържа hello</li></ul>
Magnet_MagnetType                       Тип на магнита
Magnet_Value                            Стойност
Magnet_Always                           Класифицирай винаги в кош

Bucket_Error1                           Имената на кошовете може да съдържат само малки латински букви от a до z плюс знаците - и _
Bucket_Error2                           Вече съществува кош %s
Bucket_Error3                           Създаден е кош %s
Bucket_Error4                           Моля въведете нещо
Bucket_Error5                           Кош %s преименуван на %s
Bucket_Error6                           Изтрит е кош %s
Bucket_Title                            Статистика
Bucket_BucketName                       Кош
Bucket_WordCount                        Брой думи
Bucket_WordCounts                       Брой думи
Bucket_UniqueWords                      Уникални думи
Bucket_SubjectModification              Промяна на заглавието
Bucket_ChangeColor                      Промени цвета
Bucket_NotEnoughData                    Недостатъчно данни
Bucket_ClassificationAccuracy           Точност на класификацията
Bucket_EmailsClassified                 Класифицирани съобщения
Bucket_EmailsClassifiedUpper            Класифицирани съобщения
Bucket_ClassificationErrors             Грешки при класификацията
Bucket_Accuracy                         Точност
Bucket_ClassificationCount              Брой класифицирани
Bucket_ResetStatistics                  Нулирай статистиката
Bucket_LastReset                        Последно нулиране
Bucket_CurrentColor                     В момента цветът за %s е %s
Bucket_SetColorTo                       Промени цветът за %s на %s
Bucket_Maintenance                      Промени
Bucket_CreateBucket                     Създай кош с име
Bucket_DeleteBucket                     Изтрий кош с име
Bucket_RenameBucket                     Преименувай кош с име
Bucket_Lookup                           Търсене
Bucket_LookupMessage                    Търсене на дума по кошовете
Bucket_LookupMessage2                   Резултати от търсенето
Bucket_LookupMostLikely                 <b>%s</b> най-често се среща в <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> не присъства в никой кош
Bucket_DisabledGlobally                 Изключено за всички
Bucket_To                               към
Bucket_Quarantine                       Карантина

SingleBucket_Title                      Детайли за %s
SingleBucket_WordCount                  Брой думи в коша
SingleBucket_TotalWordCount             Общо думи
SingleBucket_Percentage                 Процент от общия брой
SingleBucket_WordTable                  Думи, попадащи в %s
SingleBucket_Message1                   Означените със звездичка (*) думи са използвани за класификация при това пускане на POPFile. Щракнете с мишката на някоя дума, за да видите вероятността за попадането й във всички кошове.
SingleBucket_Unique                     %s уникални

Session_Title                           Сеансът на работа с POPFile е приключил
Session_Error                           Вашият сеанс на работа с POPFile е приключил.  Това може да се е получило от спиране и пускане на POPFile и оставен отворен прозорец на браузера. Щракнете на някой от горните връзки, за да продължите работа с POPFile.
