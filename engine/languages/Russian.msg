# Copyright (c) 2001-2003 John Graham-Cumming

# При переводе на русский язык всплыли самые разные ошибки и недочёты
# самого веб-интерфейса -- слишком многое намертво зашито в код.
# Если я и дальше буду пользоваться POPFile, я постараюсь найти время
# отделить интерфейс от кода, и адаптировать интерфейс к русскому
# языку.
#
# Предложения и замечания с благодарностью принимаются по электронной
# почте: alexander saltanov <asdgray.at.yandex.ru>

LanguageCode                            en
LanguageCharset                         koi8-r

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
Magnet_Explanation                      Существует три типа магнитов:</b><ul><li><b>Адрес или имя отправителя:</b> например, &quot;john@company.com&quot; сработает для писем, пришедших с указанного адреса, <br />&quot;company.com&quot; сработает для любых писем, пришедших из company.com, <br />&quot;John Doe&quot; сработает если в поле &quot;Отправитель&quot; присутствует указанное имя, в то время как, &quot;John&quot; сработает для любых Джонов, написавших вам письмо</li><li> <b>Адрес или имя получателя:</b> работает как предыдущий, только оперирует полем &quot;Получатель&quot;</li><li> <b>Слова в теме письма:</b> например, &quot;hello&quot; сработает на всех письмах с этим приветствием в теме</li></ul>
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
