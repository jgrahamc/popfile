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

# При переводе на русский язык всплыли самые разные ошибки и недочёты
# самого веб-интерфейса -- слишком многое намертво зашито в код.
# Если я и дальше буду пользоваться POPFile, я постараюсь найти время
# отделить интерфейс от кода, и адаптировать интерфейс к русскому
# языку.
#
# Предложения и замечания с благодарностью принимаются по электронной
# почте: alexander saltanov <asdgray.at.yandex.ru>

# Identify the language and character set used for the interface
LanguageCode                            ru
LanguageCharset                         koi8-r
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en

# Common words that are used on their own all over the interface
Apply                                   Запомнить
On                                      Вкл.
Off                                     Выкл.
TurnOn                                  Включить
TurnOff                                 Выключить
Add                                     Добавить
Remove                                  Удалить
Previous                                Предыдущий
Next                                    Следующий
From                                    Отправитель
Subject                                 Тема
Classification                          Классификация
Reclassify                              Переклассифицировать
Undo                                    Отменить
Close                                   Закрыть
Find                                    Найти
Filter                                  Выбрать
Yes                                     Да
No                                      Нет
ChangeToYes                             Изменить на &laquo;Да&raquo;
ChangeToNo                              Изменить на &laquo;Нет&raquo;
Bucket                                  Ведро
Magnet                                  Магнит
Delete                                  Удалить
Create                                  Создать
To                                      Получатель
Total                                   Всего
Rename                                  Переименовать
Frequency                               Частота
Probability                             Вероятность
Score                                   Счёт
Lookup                                  Искать

# The header and footer that appear on every UI page
Header_Title                            Центр управления POPFile
Header_Shutdown                         Выключить POPFile
Header_History                          История
Header_Buckets                          Вёдра
Header_Configuration                    Настройка
Header_Advanced                         Стоп-слова
Header_Security                         Безопасность
Header_Magnets                          Магниты

Footer_HomePage                         Страничка POPFile в Интернете
Footer_Manual                           Руководство пользователя
Footer_Forums                           Форумы
Footer_FeedMe                           Накормите автора!
Footer_RequestFeature                   Нужна новая функция?
Footer_MailingList                      Список рассылки

Configuration_Error1                    Разделитель должен быть <stong>одним</strong> символом
Configuration_Error2                    Номер порта для web-интерфейса должен быть числом от 1 до 65535
Configuration_Error3                    Номер порта POP3 должен быть числом от 1 до 65535
Configuration_Error4                    Размер страницы должен быть числом от 1 до 1000
Configuration_Error5                    Число дней истории должно быть числом от 1 до 366
Configuration_Error6                    Значение таймаута TCP должно быть числом от 10 до 300
Configuration_POP3Port                  Слушать POP3 порт
Configuration_POP3Update                Номер порта изменён на %s; изменения вступят в силу после перезапуска POPFile
Configuration_Separator                 Разделитель
Configuration_SepUpdate                 Разделитель изменён на %s
Configuration_UI                        Порт веб-интерфейса
Configuration_UIUpdate                  Номер порта веб-интерфейса изменён на %s; изменения вступят в силу после перезапуска POPFile
Configuration_History                   Сколько писем показывать на одной странице
Configuration_HistoryUpdate             Теперь на странице будет показываться %s писем
Configuration_Days                      Сколько дней хранить историю
Configuration_DaysUpdate                Теперь история будет храниться %s дней
Configuration_UserInterface             Веб-интерфейс
Configuration_Skins                     Оформление
Configuration_SkinsChoose               Выбрать вариант оформления
Configuration_Language                  Язык
Configuration_LanguageChoose            Выбрать язык
Configuration_ListenPorts               POP3 порт
Configuration_HistoryView               История
Configuration_TCPTimeout                Таймаут TCP-соединения
Configuration_TCPTimeoutSecs            Таймаут TCP-соединения в секундах
Configuration_TCPTimeoutUpdate          Таймаут изменён на %s секунд
Configuration_ClassificationInsertion   Куда записывать классификатор
Configuration_SubjectLine               Записывать классификатор в тему письма
Configuration_XTCInsertion              Добавлять поле X-Text-Classification в заголовок
Configuration_XPLInsertion              Добавлять поле X-POPFile-Link в заголовок
Configuration_Logging                   Логи
Configuration_None                      Никуда
Configuration_ToScreen                  На экран
Configuration_ToFile                    В файл
Configuration_ToScreenFile              На экран и в файл
Configuration_LoggerOutput              Куда выводить лог
Configuration_GeneralSkins              Skins
Configuration_SmallSkins                Small Skins
Configuration_TinySkins                 Tiny Skins

Advanced_Error1                         '%s' уже есть в списке стоп-слов
Advanced_Error2                         Стоп-слово может содержать буквы, цифры, и символы ., _, -, @
Advanced_Error3                         Слово '%s' добавлено в список стоп-слов
Advanced_Error4                         '%s' нет в списке стоп-слов
Advanced_Error5                         Слово '%s' удалено из списка стоп-слов
Advanced_StopWords                      Стоп-слова
Advanced_Message1                       Эти слова игнорируются при классификации писем, поскольку встречаются очень часто.
Advanced_AddWord                        Добавить слово
Advanced_RemoveWord                     Удалить слово

History_Filter                          &nbsp;(лежащие в ведре <font color="%s">%s</font>)
History_FilterBy                        Filter By
History_Search                          &nbsp;(найденные по теме &laquo;i<em>%s</em>&raquo;)
History_Title                           Последние обработанные письма
History_Jump                            Перейти к письму
History_ShowAll                         Показывать всё
History_ShouldBe                        Должно быть в&nbsp;
History_NoFrom                          не задан отправитель
History_NoSubject                       не задана тема
History_ClassifyAs                      Классифицировать как
History_MagnetUsed                      Использовался магнит
History_ChangedTo                       Изменено на <font color="%s">%s
History_Already                         Уже переклассифицировано как <font color="%s">%s</font>
History_RemoveAll                       Удалить всю историю
History_RemovePage                      Удалить эту страницу
History_Remove                          Чтобы удалить записи из истории нажмите
History_SearchMessage                   Искать в поле <em>Тема</em>
History_NoMessages                      Нет писем
History_ShowMagnet                      Только примагниченные
History_Magnet                          &nbsp;(среди классифицированных с помощью магнитов)
 
Password_Title                          Пароль
Password_Enter                          Скажите пароль
Password_Go                             Войти
Password_Error1                         Пароль оказался неправильным

Security_Error1                         Номер безопасного порта должен быть числом от 1 до 65535
Security_Stealth                        Режим невидимости/Настройка сервера
Security_NoStealthMode                  Нет (режим невидимости)
Security_ExplainStats                   (Если включено, POPFile раз в день будет отправлять скрипту на www.usethesource.com три числа: bc (число ваших вёдер), mc (сколько писем было классифицировано с помощью POPFile) и ec (число ошибок классификации). Эти значения сохранятся в файле и автор будет использовать их для опубликования статистических данных о том, как используется POPFile и насколько хорошо он работает. Веб-сервер автора хранит логи в течение 5 дней, после чего они удаляются, автор не занимается сопоставлением статистики и IP-адресов пользователей.)
Security_ExplainUpdate                  (Если включено, POPFile раз в день будет отправлять скрипту на www.usethesource.com три числа: ma (старший номер версии установленного POPFile), mi (младший номер версии) и bn (номер сборки). POPFile получит ответ от сервера в виде картинки, которая появится вверху страницы, если доступна новая версия. Веб-сервер автора хранит логи в течение 5 дней, после чего они удаляются, автор не занимается сопоставлением запросов об обновлении и IP-адресов пользователей.)
Security_PasswordTitle                  Пароль для веб-интерфейса
Security_Password                       Пароль
Security_PasswordUpdate                 Пароль изменён на '%s'
Security_AUTHTitle                      Secure Password Authentication/AUTH
Security_SecureServer                   Безопасный сервер
Security_SecureServerUpdate             Безопасным теперь считается сервер '%s'. Изменение вступит в силу только после перезапуска POPFile
Security_SecurePort                     Безопасный порт
Security_SecurePortUpdate               Безопасным теперь считается порт %s. Изменение вступит в силу только после перезапуска POPFile
Security_POP3                           Разрешать POP3-соединения с удалёнными машинами
Security_UI                             Разрешать HTTP-соединения (веб-интерфейс) с удалёнными машинами
Security_UpdateTitle                    Автоматическое обновление
Security_Update                         Ежедневно проверять, не обновился ли POPFile
Security_StatsTitle                     Статистические отчёты
Security_Stats                          Ежедневно отправлять статистику Джону

Magnet_Error1                           Магнит '%s' уже существует в ведре '%s'
Magnet_Error2                           Новый магнит '%s' совпадает с магнитом '%s' в ведре '%s' и может спровоцировать двусмысленные результаты. Новый магнит не был добавлен.
Magnet_Error3                           Создан новый магнит '%s' в ведре '%s'
Magnet_CurrentMagnets                   Существующие магниты
Magnet_Message1                         Магниты позволяют складывать все подходящие к ним сообщения в указанные ведра.
Magnet_CreateNew                        Создать новый магнит
Magnet_Explanation                      <b>Существует три типа магнитов:</b><ul><li><b>Адрес или имя отправителя:</b> например, &quot;john@company.com&quot; сработает для писем, пришедших с указанного адреса, <br />&quot;company.com&quot; сработает для любых писем, пришедших из company.com, <br />&quot;John Doe&quot; сработает если в поле &quot;Отправитель&quot; присутствует указанное имя, в то время как, &quot;John&quot; сработает для любых Джонов, написавших вам письмо</li><li> <b>Адрес или имя получателя:</b> работает как предыдущий, только оперирует полем &quot;Получатель&quot;</li><li> <b>Слова в теме письма:</b> например, &quot;hello&quot; сработает на всех письмах с этим приветствием в теме</li></ul>
Magnet_MagnetType                       Тип магнита
Magnet_Value                            Значение
Magnet_Always                           Всегда складывать в ведро

Bucket_Error1                           Название ведра может состоять из строчныхлатинских букв от 'a' до 'z' и знаков - и _
Bucket_Error2                           Ведро '%s' уже существует
Bucket_Error3                           Создано ведро '%s'
Bucket_Error4                           Please enter a non-blank word
Bucket_Error5                           Ведро '%s' переименовано в '%s'
Bucket_Error6                           Удалено ведро '%s'
Bucket_Title                            Отчёт
Bucket_BucketName                       Название ведра
Bucket_WordCount                        Количество слов
Bucket_WordCounts                       Слова
Bucket_UniqueWords                      Уникальных слов
Bucket_SubjectModification              Изменение темы письма
Bucket_ChangeColor                      Изменить цвет
Bucket_NotEnoughData                    Недостаточно данных
Bucket_ClassificationAccuracy           Точность классификации
Bucket_EmailsClassified                 Классифицированные письма
Bucket_EmailsClassifiedUpper            Классифицированные письма
Bucket_ClassificationErrors             Ошибки классификации
Bucket_Accuracy                         Точность
Bucket_ClassificationCount              Классифицировано
Bucket_ResetStatistics                  Сброс статистики
Bucket_LastReset                        Последний сброс был
Bucket_CurrentColor                     %s текущий цвет&nbsp;&mdash; %s
Bucket_SetColorTo                       Установить %s цвет в %s
Bucket_Maintenance                      Управление
Bucket_CreateBucket                     Создать ведро
Bucket_DeleteBucket                     Удалить ведро
Bucket_RenameBucket                     Переименовать ведро
Bucket_Lookup                           Поиск
Bucket_LookupMessage                    Искать слово в вёдрах
Bucket_LookupMessage2                   Результаты поиска
Bucket_LookupMostLikely                 <b>%s</b> чаще всего встречается в <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> не встречается ни в одном из вёдер
Bucket_DisabledGlobally                 Выключено глобально
Bucket_To                               в
Bucket_Quarantine                       Карантин

SingleBucket_Title                      Подробнее о %s
SingleBucket_WordCount                  Слов в ведре
SingleBucket_TotalWordCount             Слов вообще
SingleBucket_Percentage                 Процентов от всего
SingleBucket_WordTable                  Таблица слов для %s
SingleBucket_Message1                   Слова со звёздочкой (*) были использованы при классификации в этой сессии POPFile. Щёлкните мышкой на любом слове, и вы увидите его вероятность для всех вёдер.
SingleBucket_Unique                     %s уникально

Session_Title                           Сессия POPFile устарела
Session_Error                           Ваша сессия POPFile устарела. Обычно такое случается, если если остановить и снова запустит POPFile, а в броузере оставить открытым &laquo;Центр управления&raquo;. Пожалуйста, щёлкните по любой ссылке сверху, чтобы продолжить работу с POPFile.

Header_MenuSummary                      This table is the navigation menu which allows access to each of the different pages of the control center.
History_MainTableSummary                This table shows the sender and subject of recently received messages and allows them to be reviewed and reclassified.  Clicking on the subject line will show the full message text, along with information about why it was classified as it was.  The 'Should be' column allows you to specify which bucket the message belongs in, or to undo that change.  The 'Delete' column allows you to delete specific messages from the history if you don't need them anymore.
History_OpenMessageSummary              This table contains the full text of an email message, with the words that are used for classification highlighted according to the bucket that was most relevant for each.
Bucket_MainTableSummary                 This table provides an overview of the classification buckets.  Each row shows the bucket name, the word count total for that bucket, the actual number of individual words in each bucket, whether the email's subject line will be modified when it gets classified to that bucket, whether to quarantine the messages received in that bucket, and a table to pick the color used in displaying anything related to that bucket in the control center.
Bucket_StatisticsTableSummary           This table provides three sets of statistics on the overall performance of PopFile.  The first is how accurate its classification is, the second is how many emails have been classified, and to which buckets, and the third is how many words are in each bucket, and what their relative percentages are.
Bucket_MaintenanceTableSummary          This table contains forms that allow you to create, delete or rename buckets, and to lookup a word in all of the buckets to see its relative probabilities.
Bucket_AccuracyChartSummary             This table graphically represents the accuracy of the email classification.
Bucket_BarChartSummary                  This table graphically represents a percentage allocation for each of the different buckets.  It is used for both number of emails classified, and total word counts.
Bucket_LookupResultsSummary             This table shows the probabilities associated with any given word of the corpus.  For each bucket, it shows the frequency that that word occurs, the probability that it will occur in that bucket, and the overall effect on the score of the bucket if that word exists in an email.
Bucket_WordListTableSummary             This table provides a listing of all the words for a particular bucket, organized by common first letter for each row.
Magnet_MainTableSummary                 This table shows the list of magnets that are used to automatically classify email according to fixed rules.  Each row shows how the magnet is defined, what bucket it is intended for, and a button to delete the magnet.
Configuration_MainTableSummary          This table contains a number of forms to allow you to control the configuration of PopFile.
Configuration_InsertionTableSummary     This table contains buttons that determine whether or not certain modifications are made to the headers or subject line of the email before it is passed on to the email client.
Security_MainTableSummary               This table provides sets of controls that affect the security of the overall configuration of PopFile, whether it should automatically check for updates to the program, and whether statistics about PopFile's performance should be sent to the central datastore of the program's author for general information.
Advanced_MainTableSummary               This table provides a list of words that PopFile ignores when classifying email due to their relative frequency in email in general.  They are organized per row according to the first letter of the words.

