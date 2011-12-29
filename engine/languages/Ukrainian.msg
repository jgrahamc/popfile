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
# Translation by          Myroslav Opyr <myroslav@zope.net.ua>

# Переклад здійснювався згідно термінології, що опрацьовується 
# ініціативно групою перекладачів з http://linux.org.ua/
# Сей переклад виконав Мирослав Опир <myroslav@zope.net.ua>.
# Зауваження та побажання прошу подавати на мою адресу, або
# тут: http://zope.net.ua/POPFile

# Identify the language and character set used for the interface
LanguageCode                            uk
LanguageCharset                         koi8-u
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en

# Common words that are used on their own all over the interface
Apply                                   Застосувати
On                                      Ввімк.
Off                                     Вимк.
TurnOn                                  Ввімкнути
TurnOff                                 Вимкнути
Add                                     Додати
Remove                                  Вилучити
Previous                                Попередні
Next                                    Наступні
From                                    Від
Subject                                 Тема 
Cc                                      Копія 
Classification                          Класифікація
Reclassify                              Змінити
Probability                             Імовірність
Scores                                  Бали
QuickMagnets                            Швидкі магніти
Undo                                    Повернути
Close                                   Закрити
Find                                    Знайти
Filter                                  Відфільтрувати
Yes                                     Так
No                                      Ні
ChangeToYes                             Змінити на "Так"
ChangeToNo                              Змінити на "Ні"
Bucket                                  Категорія
Magnet                                  Магніт
Delete                                  Знищити
Create                                  Створити
To                                      До
Total                                   Загалом
Rename                                  Перейменувати
Frequency                               Частота
Probability                             Імовірність
Score                                   Бали
Lookup                                  Підглянути
Word                                    Слово
Count                                   Кількість
Update                                  Виправити
Refresh                                 Поновити

# The header and footer that appear on every UI page
Header_Title                            Центр управління POPFile
Header_Shutdown                         Заглушити POPFile
Header_History                          Історія
Header_Buckets                          Категорії
Header_Configuration                    Настройка
Header_Advanced                         Додатково
Header_Security                         Безпека
Header_Magnets                          Магніти

Footer_HomePage                         Домашня сторінка POPFile
Footer_Manual                           Документація
Footer_Forums                           Форуми
Footer_FeedMe                           Нагодуйте мене!
Footer_RequestFeature                   Є ідея? Замовляйте
Footer_MailingList                      Список розсилки

Configuration_Error1                    Символ роздільник повинен бути один
Configuration_Error2                    Порт інтерфейсу користувача повинен бути числом від 1 до 65535
Configuration_Error3                    Порт POP3 повинен бути числом від 1 до 65535
Configuration_Error4                    Розмір сторінки повинен бути числом від 1 до 1000
Configuration_Error5                    Кількість днів в історії повинна бути числом від 1 до 366
Configuration_Error6                    Обмеження по затримці TCP повинно бути числом від 10 до 1800
Configuration_Error7                    Порт XML-RPC повинен бути числом від 1 до 65535
Configuration_POP3Port                  Порт POP3
Configuration_POP3Update                Змінено POP3 порт на %s; ця зміна не буде дійсною поки ви не рестартуєте POPFile
Configuration_XMLRPCUpdate              Змінено XML-RPC порт на %s; ця зміна не буде дійсною поки ви не рестартуєте POPFile
Configuration_XMLRPCPort                Порт XML-RPC
Configuration_SMTPPort                  Порт SMTP
Configuration_SMTPUpdate                Змінено SMTP порт на %s; ця зміна не буде дійсною поки ви не рестартуєте POPFile
Configuration_NNTPPort                  Порт NNTP
Configuration_NNTPUpdate                Змінено NNTP порт на %s; ця зміна не буде дійсною поки ви не рестартуєте POPFile
Configuration_POP3Separator             Символ роздільник POP3 (гост:порт:користувач)
Configuration_NNTPSeparator             Символ роздільник NNTP (гост:порт:користувач)
Configuration_POP3SepUpdate             Змінено роздільник POP3 на %s
Configuration_NNTPSepUpdate             Змінено роздільник NNTP на %s
Configuration_UI                        Веб порт інтерфейсу користувача
Configuration_UIUpdate                  Змінено веб порт інтерфейсу користувача на %s; ця зміна не буде дійсною поки ви не рестартуєте POPFile
Configuration_History                   Кількість листів на сторінці
Configuration_HistoryUpdate             Змінено кількість листів на сторінці на %s
Configuration_Days                      Історію зберігати на протязі стількох днів
Configuration_DaysUpdate                Змінено кількість днів на %s, на протязі яких зберігається історія
Configuration_UserInterface             Інтерфейс користувача
Configuration_Skins                     Вигляд
Configuration_SkinsChoose               Виберіть вигляд
Configuration_Language                  Мова
Configuration_LanguageChoose            Виберіть мову
Configuration_ListenPorts               Слухати на портах
Configuration_HistoryView               Вигляд історії
Configuration_TCPTimeout                Обмеження по затримці TCP
Configuration_TCPTimeoutSecs            Обмеження по затримці TCP в секундах
Configuration_TCPTimeoutUpdate          Оновлено TCP затримку до %s
Configuration_ClassificationInsertion   Вставляння класифікації
Configuration_SubjectLine               Модифікація теми
Configuration_XTCInsertion              Вставляти X-Text-Classification
Configuration_XPLInsertion              Вставляти X-POPFile-Link
Configuration_Logging                   Звітування
Configuration_None                      нема
Configuration_ToScreen                  на екран
Configuration_ToFile                    в файл
Configuration_ToScreenFile              на екран і в файл
Configuration_LoggerOutput              Вивід звіту
Configuration_GeneralSkins              Звичайні
Configuration_SmallSkins                Малі
Configuration_TinySkins                 Тендітні
Configuration_CurrentLogFile            &laquo;поточний протокол&raquo;

Advanced_Error1                         '%s' уже в списку слів
Advanced_Error2                         Слова, що ігноруються можуть тільки містити букви, цифри, символи ., _, -, чи @
Advanced_Error3                         '%s' додано до списку
Advanced_Error4                         '%s' немає в списку
Advanced_Error5                         '%s' вилучено зі списку
Advanced_StopWords                      Список слів, що ігноруються
Advanced_Message1                       Ці слова ігноруються у всіх класифікаціях, так як зустрічаються дуже часто.
Advanced_AddWord                        Додати слово
Advanced_RemoveWord                     Вилучити слово

History_Filter                          &nbsp;(тільки показуючи категорію <font color=%s>%s</font>)
History_FilterBy                        Фільтр по
History_Search                          &nbsp;(пошукавши за темою %s)
History_Title                           Останні повідомлення
History_Jump                            Перейти до повідомлення
History_ShowAll                         Показати усі
History_ShouldBe                        Має бути
History_NoFrom                          немає рядка Від
History_NoSubject                       нема рядка Теми
History_ClassifyAs                      Прокласифікуй як
History_MagnetUsed                      Використано магніт
History_MagnetBecause                   <b>Використано Магніт</b><p>Прокласифіковано як <font color="%s">%s</font> бо задіяно магніт %s </p>
History_ChangedTo                       Змінено на <font color=%s>%s
History_Already                         Уже змінено на <font color=%s>%s</font>
History_RemoveAll                       Вилучити всі
History_RemovePage                      Вилучити сторінку
History_Remove                          Щоб вилучити елементи з історії клацніть
History_SearchMessage                   Пошук по Від/Тема
History_NoMessages                      Немає повідомлень
History_ShowMagnet                      Намагнічені
History_ShowNoMagnet                    Ненамагнічені
History_Magnet                          &nbsp;(тільки повідомлення притягнуті магнітами)
History_NoMagnet                        &nbsp;(тільки повідомлення непритягнуті магнітами)
History_ResetSearch                     Скинути

Password_Title                          Пароль
Password_Enter                          Введіть пароль
Password_Go                             Вперед!
Password_Error1                         Неправильний пароль

Security_Error1                         Безпечний порт повинен бути числом між 1 та 65535
Security_Stealth                        Невидимий режим/робота сервера
Security_NoStealthMode                  Ні (Невидимий режим)
Security_ExplainStats                   (Якщо це ввімкнуто, то POPFile надсилає раз в день наступні три значенні скрипту на www.usethesource.com: bc (загальна кількість категорій, яку маєте), mc (загальну кількість повідомлень що прокласифікував POPFile) та ec (загальна кількість помилок класифікації).  Вони зберігаються в файлі і я використовую їх щоб опублікувати деяку статистику про те, як люди використовують POPFile і наскільки добре він для них працює.  Мій веб сервер зберігає свої файли звітів коло 5 днів і тоді їх стирається; я не зберігаю будь якого зв'язку між статистикою та індивідуальними IP адресами.)
Security_ExplainUpdate                  (Якщо це ввімкнуто, то POPFile надсилає раз в день наступні три значенні скрипту на www.usethesource.com: ma (основна версія вашого встановленого POPFile), mi (вторинна версія вашого встановленого POPFile) та bn (номер побудови вашого встановленого POPFile).  POPFile отримує відповідь у формі графіки що з'являється згори сторінки якщо наявна нова версія.  Мій веб сервер зберігає свої файли звітів коло 5 днів і тоді їх стирається; я не зберігаю будь якого зв'язку між перевіркою оновлень та індивідуальними IP адресами.)
Security_PasswordTitle                  Пароль інтерфейсу користувача
Security_Password                       Пароль
Security_PasswordUpdate                 Пароль змінено для %s
Security_AUTHTitle                      Безпечна автентифікація паролем/AUTH
Security_SecureServer                   Безпечний сервер
Security_SecureServerUpdate             Змінено безпечний сервер на %s; ця зміна не буде дійсною поки ви не рестартуєте POPFile
Security_SecurePort                     Безпечний порт
Security_SecurePortUpdate               Змінено порт на %s; ця зміна не буде дійсною поки ви не рестартуєте POPFile
Security_SMTPServer                     Ланцюговий сервер SMTP<br/><small>(myroslav@zope.net.ua: перевірити переклад)</small>
Security_SMTPServerUpdate               Змінено ланцюговий сервер SMTP на %s; ця зміна не буде дійсною поки ви не рестартуєте POPFile<br/><small>(myroslav@zope.net.ua: перевірити переклад)</small>
Security_SMTPPort                       Ланцюговий порт SMTP<br/><small>(myroslav@zope.net.ua: перевірити переклад)</small>
Security_SMTPPortUpdate                 Змінено ланцюговий порт SMTP на %s; ця зміна не буде дійсною поки ви не рестартуєте POPFile<br/><small>(myroslav@zope.net.ua: перевірити переклад)</small>
Security_POP3                           Приймати POP3 під'єднання з віддалених машин (вимагає рестарту POPFile)
Security_SMTP                           Приймати SMTP під'єднання з віддалених машин (вимагає рестарту POPFile)
Security_NNTP                           Приймати NNTP під'єднання з віддалених машин (вимагає рестарту POPFile)
Security_UI                             Приймати HTTP (інтерфейс користувача) під'єднання від віддалених машин
Security_XMLRPC                         Приймати XML-RPC під'єднання з віддалених машин (вимагає рестарту POPFile)
Security_UpdateTitle                    Автоматична перевірка оновлень
Security_Update                         Щоденно перевіряти за оновленнями POPFile
Security_StatsTitle                     Звітування статистики
Security_Stats                          Відсилати щоденно статистику назад до Джона

Magnet_Error1                           Магніт '%s' уже існує в категорії '%s'
Magnet_Error2                           Новий магніт '%s' конфліктує з магнітом '%s' в категорії '%s' і може спричинити неоднозначні результати.  Нового магніту НЕ додано.
Magnet_Error3                           Створено новий магніт '%s' в категорії '%s'
Magnet_CurrentMagnets                   Наявні магніти
Magnet_Message1                         Наступні магніти заставляють пошту завжди бути класифікованою у вказану категорію.
Magnet_CreateNew                        Створити новий магніт
Magnet_Explanation                      <b>Можливі три види магнітів:</b> <ul><li><b>Адреса або ім'я Від:</b> Наприклад: john@company.com щоб притягнути певну адресу, <br>company.com щоб притягнути усіх, хто посилає з company.com, <br>John Doe щоб притягнути певну особу, John щоб притягнути усіх Джонів<li><b>Адреса або ім'я До:</b> Подібно до магніту Від: але щодо адреси До: З листа<li><b>Слова з Теми:</b> Наприклад: hello щоб притягнути усі слова з hello в темі</ul>
Magnet_MagnetType                       Тип магніту
Magnet_Value                            Значення
Magnet_Always                           Завжди піде в категорію
Magnet_Jump                             Перескочити на сторінку магнітів

Bucket_Error1                           Імена категорій можуть містити тільки малі літери від a до z та - і _
Bucket_Error2                           Категорія з назвою %s уже існує
Bucket_Error3                           Створено категорію з назвою %s
Bucket_Error4                           Введіть будь-ласка непорожнє слово
Bucket_Error5                           Перейменовано категорію %s на %s
Bucket_Error6                           Знищено категорію %s
Bucket_Title                            Звіт
Bucket_BucketName                       Категорія
Bucket_WordCount                        Кількість слів
Bucket_WordCounts                       Кількості слів
Bucket_UniqueWords                      Унікальні
Bucket_SubjectModification              Змінювати тему
Bucket_ChangeColor                      Колір
Bucket_NotEnoughData                    Недостатньо даних
Bucket_ClassificationAccuracy           Точність класифікації
Bucket_EmailsClassified                 Прокласифіковано листів
Bucket_EmailsClassifiedUpper            Прокласифіковано листів
Bucket_ClassificationErrors             Помилок класифікації
Bucket_Accuracy                         Точність
Bucket_ClassificationCount              Кількість
Bucket_ClassificationFP                 Неправильні Попадання
Bucket_ClassificationFN                 Неправильні Промахи
Bucket_ResetStatistics                  Скинути статистику
Bucket_LastReset                        Востаннє скинуто
Bucket_CurrentColor                     %s поточний колір %s
Bucket_SetColorTo                       Встановити %s колір для %s
Bucket_Maintenance                      Управління категоріями
Bucket_CreateBucket                     Створити категорію з іменем
Bucket_DeleteBucket                     Знищити категорію іменовану
Bucket_RenameBucket                     Перейменувати категорію іменовану
Bucket_Lookup                           Підглянути
Bucket_LookupMessage                    Знайти слово в категоріях
Bucket_LookupMessage2                   Результат пошуку
Bucket_LookupMostLikely                 <b>%s</b> найімовірніше появляється в <font color=%s>%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> не з'являється в жодній категорії
Bucket_DisabledGlobally                 Глобально заборонено
Bucket_To                               до
Bucket_Quarantine                       Карантин

SingleBucket_Title                      Подробиці для %s
SingleBucket_WordCount                  Кількість слів в категорії
SingleBucket_TotalWordCount             Загальна кількість слів
SingleBucket_Percentage                 Відсоток від всього
SingleBucket_WordTable                  Таблиця слів для %s
SingleBucket_Message1                   Слова з зірочками (*) використовувалися при класифікації в цій POPFile сесії.  Клацніть по слову, щоб побачити його вірогідність у всіх категоріях.
SingleBucket_Unique                     %s унікальне
SingleBucket_ClearBucket                Вилучити всі слова

Session_Title                           POPFile сесія закінчилася
Session_Error                           Ваша сесія POPFile закінчилася. Це могло трапитися при зупинці та запуску POPFile але при відкритому переглядачі.  Клацніть на одному з посилань вгорі щоб продовжити роботу з POPFile.

View_Title                              Перегляд одного повідомлення

Header_MenuSummary                      Ця таблиця - це навігаційне меню, що надає доступ до кожної з різних сторінок центру управління.
History_MainTableSummary                Ця таблиця показує автора та тему щойно прийнятих повідомлень та дозволяє їх переглянути та перекласифікувати.  Клацнувши на темі ви отримаєте повний текст повідомлення, разом з інформацією, чому його так було прокласифіковано. Стовпець 'Має бути' дозволяє Вам вказати, якій категорії належить повідомлення, або відмінити ту зміну. Стовпець 'Вилучити' дозволяє вилучити певне повідомлення з історії якщо ви їх більше не потребуєте.
History_OpenMessageSummary              Ця таблиця містить повний текст повідомлення, з словами що використовуються для класифікації підсвічені у відповідності до категорії найвідповіднішій кожному.
Bucket_MainTableSummary                 Ця таблиця забезпечує огляд категорій класифікації.  Кожен рядок показує ім'я категорії, загальну кількість слів для тієї категорії, поточну кількість унікальних слів в кожній категорії, признак того, ячи буде модифікуватися тема повідомлення при класифікації в ту категорію, чи проводити карантин повідомленням отриманим в ту категорію, і таблицю для вибору кольору, який використовується при відображенні будь-чого що стосується тої категорії в центрі управління.
Bucket_StatisticsTableSummary           Ця таблиця забезпечує три блоки статистики загальної ефективності POPFile.  Перший, є про те, наскільки точною є класифікація, другий - про те, скільки повідомлень прокласифіковано, і в які категорії, і третій - скільки слів є в кожній категорії, та яка їх процентна доля.
Bucket_MaintenanceTableSummary          Ця таблиця містить форми, що дозволяють створювати, знищувати та перейменовувати категорії, і шукати слово у всіх категоріях, щоб побачити його відносну імовірність.
Bucket_AccuracyChartSummary             Ця таблиця графічно відображає точність класифікації повідомлень
Bucket_BarChartSummary                  Ця таблиця графічно відображає відсоткову долю кожної окремої категорії.  Вона використовується і для загальної кількості повідомлень, і загальної кількості слів.
Bucket_LookupResultsSummary             Ця таблиця показує імовірності асоційовані з кожножним окремим словом з сукупності.  Для кожної категорії, віна показує частоту з якою з'являється те слово, імовірність, що воно трапиться в тій категорії, та загальний вплив на бали категорії, якби слово існувало в повідомленні.
Bucket_WordListTableSummary             Ця таблиця забезпечує список усіх слів для певної категорії, згруповані по першій літері в кожному рядку.
Magnet_MainTableSummary                 Ця таблиця показує список магнітів що використовуються для автоматичної класифікації повідомлення згідно встановлених правил. Кожен рядок показує як визначено магніт, яка категорія йому призначена, та кнопка, щоб знищити магніт.
Configuration_MainTableSummary          Ця таблиця містить кілька форм що дозволяють вам контролювати конфігурацію POPFile.
Configuration_InsertionTableSummary     Ця таблиця містить кнопки що визначають які модифікації здійснюються над заголовками чи темою повідомлення перед тим, як воно передається до поштового клієнта.
Security_MainTableSummary               Ця таблиця забезпечує набір параметрів, які впливають на безпеку усієї конфігурації POPFile, чи він повинен автоматично перевіряти за оновленнями програми, і чи відсилати статистику про ефективність POPFile в центральну базу даних автора програми задля загальної інформації.
Advanced_MainTableSummary               Ця таблиця забезпечує список слів, які POPFile ігнорує при класифікації повідомлення через їх відносну частоту в повідомленні взагалі.  Вони зібрані в ряди по першій літері слів.

