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
# Translated by / Çeviri:
# Zeynel Abidin Öztürk <ozturk@gmx.net>
# POPFile 0.22.0 Turkish Translation

# Identify the language and character set used for the interface
LanguageCode                            tr
LanguageCharset                         ISO-8859-9
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en

# This is where to find the FAQ on the Wiki
FAQLink                                 faq

# Common words that are used on their own all over the interface
Apply                                   Uygula
On                                      Açık
Off                                     Kapalı
TurnOn                                  Aç
TurnOff                                 Kapat
Add                                     Ekle
Remove                                  Kaldır
Previous                                Önceki
Next                                    Sonraki
From                                    Kimden
Subject                                 Konu
Cc                                      Bilgi 
Classification                          Sınıflandırma
Reclassify                              Tekrar Sınıflandır
Probability                             Olasılık
Scores                                  Puanlar 
QuickMagnets                            HızlıMıknatıs
Undo                                    Geri Al
Close                                   Kapat
Find                                    Bul
Filter                                  Filtrele
Yes                                     Evet
No                                      Hayır
ChangeToYes                             Evet olarak değiştir
ChangeToNo                              Hayır olarak değiştir
Bucket                                  Kategori
Magnet                                  Mıknatıs
Delete                                  Sil
Create                                  Oluştur
To                                      Kime
Total                                   Toplam
Rename                                  Ad Değiştir
Frequency                               Frekans
Probability                             Olasılık
Score                                   Puan
Lookup                                  Arama
Word                                    Sözcük
Count                                   Miktar
Update                                  Güncelle
Refresh                                 Yenile
FAQ                                     Sık Sorulan Sorular
ID                                      Kimlik
Date                                    Tarih
Arrived                                 Alınma
Size                                    Boyut 

# This is a regular expression pattern that is used to convert
# a number into a friendly looking number (for the US and UK this
# means comma separated at the thousands)

Locale_Thousands                       ,
Locale_Decimal                         .

# The Locale_Date uses the format strings in Perl's Date::Format
# module to set the date format for the UI.  There are two possible
# ways to specify it.
#
# <format>            Just one simple format used for all dates
# <<format> | <format> The first format is used for dates less than
#                     7 days from now, the second for all other dates

Locale_Date                            %a %R | %D %R

# The header and footer that appear on every UI page
Header_Title                            POPFile Denetim Merkezi
Header_Shutdown                         POPFile'ı Kapat
Header_History                          Geçmiş
Header_Buckets                          Kategoriler
Header_Configuration                    Yapılandırma
Header_Advanced                         Gelişmiş
Header_Security                         Güvenlik
Header_Magnets                          Mıknatıslar

Footer_HomePage                         POPFile Web Sayfası
Footer_Manual                           Kılavuz
Footer_Forums                           Forumlar
Footer_FeedMe                           Bağış Yap
Footer_RequestFeature                   Özellik İsteğinde Bulun
Footer_MailingList                      Posta Listesi
Footer_Wiki                             Belgeler

Configuration_Error1                    Ayırıcı karakter tek bir karakter olmalıdır
Configuration_Error2                    Kullanıcı arayüzü portu 1 ile 65535 arasında bir sayı olmalıdır
Configuration_Error3                    POP3 dinleme portu 1 ile 65535 arasında bir sayı olmalıdır
Configuration_Error4                    Sayfa boyutu 1 ile 1000 arasında bir sayı olmalıdır
Configuration_Error5                    Geçmişteki gün sayısı 1 ile 366 arasında bir sayı olmalıdır
Configuration_Error6                    TCP zaman aşımı 10 ile 1800 arasında bir sayı olmalıdır
Configuration_Error7                    XML RPC dinleme portu 1 ile 65535 arasında bir numara olmalıdır
Configuration_Error8                    SOCKS V proxy port sayısı 1 ve 65535 arasında bir sayı olmalıdır
Configuration_POP3Port                  POP3 dinleme portu
Configuration_POP3Update                POP3 portu %s olarak güncellendi; bu değişiklik siz POPFile'ı yeniden başlatana kadar etkili olmayacaktır
Configuration_XMLRPCUpdate              XML-RPC portu %s olarak güncellendi; bu değişiklik siz POPFile'ı yeniden başlatana kadar etkili olmayacaktır
Configuration_XMLRPCPort                XML-RPC dinleme portu
Configuration_SMTPPort                  SMTP dinleme portu
Configuration_SMTPUpdate                SMTP portu %s olarak güncellendi; bu değişiklik siz POPFile'ı yeniden başlatana kadar etkili olmayacaktır
Configuration_NNTPPort                  NNTP dinleme portu
Configuration_NNTPUpdate                NNTP portu %s olarak güncellendi; bu değişiklik siz POPFile'ı yeniden başlatana kadar etkili olmayacaktır
Configuration_POPFork                   Aynı anda yapılan POP3 bağlantılarına izin ver
Configuration_SMTPFork                  Aynı anda yapılan SMTP bağlantılarına izin ver
Configuration_NNTPFork                  Aynı anda yapılan NNTP bağlantılarına izin ver
Configuration_POP3Separator             POP3 sunucu:port:kullanıcı ayırıcı karakteri
Configuration_NNTPSeparator             NNTP sunucu:port:kullanıcı ayırıcı karakteri
Configuration_POP3SepUpdate             POP3 ayırıcısı %s olarak güncellendi
Configuration_NNTPSepUpdate             NNTP ayırıcısı %s olarak güncellendi
Configuration_UI                        Kullanıcı arayüzü web portu
Configuration_UIUpdate                  Kullanıcı arayüzü web portu %s olarak güncellendi, bu değişiklik siz POPFile'ı yeniden başlatana kadar etkili olmayacaktır
Configuration_History                   Sayfa başına mesaj sayısı
Configuration_HistoryUpdate             Sayfa başına mesaj sayısı %s olarak güncellendi
Configuration_Days                      Geçmişin saklanacağı gün sayısı
Configuration_DaysUpdate                Geçmişin saklanacağı gün sayısı %s olarak güncellendi
Configuration_UserInterface             Kullanıcı Arayüzü
Configuration_Skins                     Dış Görünümler
Configuration_SkinsChoose               Dış görünüm seçin
Configuration_Language                  Dil
Configuration_LanguageChoose            Dil seçin
Configuration_ListenPorts               Modül Seçenekleri
Configuration_HistoryView               Geçmiş Görünmü
Configuration_TCPTimeout                Bağlantı Zaman Aşımı
Configuration_TCPTimeoutSecs            Saniye olarak bağlantı zaman aşımı
Configuration_TCPTimeoutUpdate          Zaman aşımı %s saniye olarak güncellendi
Configuration_ClassificationInsertion   Mesaja Metin Ekleme
Configuration_SubjectLine               Konu satırı değiştirilmesi
Configuration_XTCInsertion              X-Text-Classification Üst bilgisi
Configuration_XPLInsertion              X-POPFile-Link Üst bilgisi
Configuration_Logging                   Günlük tutma
Configuration_None                      Kapalı
Configuration_ToScreen                  Ekrana
Configuration_ToFile                    Dosyaya
Configuration_ToScreenFile              Ekrana ve Dosyaya
Configuration_LoggerOutput              Günlük çıktısı
Configuration_GeneralSkins              Dış görünümler
Configuration_SmallSkins                Küçük Dış Görünümler
Configuration_TinySkins                 Daha Küçük Dış Görünümler
Configuration_CurrentLogFile            &lt;şimdiki günlük dosyası&gt;
Configuration_SOCKSServer               SOCKS V proxy sunucusu
Configuration_SOCKSPort                 SOCKS V proxy port
Configuration_SOCKSPortUpdate           SOCKS V proxy port %s olarak güncellendi
Configuration_SOCKSServerUpdate         SOCKS V proxy sunucusu to %s olarak güncellendi
Configuration_Fields                    Geçmiş sütunları

Advanced_Error1                         '%s' zaten Yoksayılan Sözcükler listesinde
Advanced_Error2                         Yoksayılan kelimeler sadece harfleri, sayıları, ., _, -, veya @ karakterlerini içerebilir
Advanced_Error3                         '%s' Yoksayılan Kelimeler listesine eklendi
Advanced_Error4                         '%s' Yoksayılan Kelimeler içersinde bulunmuyor
Advanced_Error5                         '%s' Yoksayılan Kelimeler listesinden silindi
Advanced_StopWords                      Yoksayılan Kelimeler
Advanced_Message1                       POPFile aşağıdaki sıkça kullanılan kelimeleri yok sayar:
Advanced_AddWord                        Kelime ekle
Advanced_RemoveWord                     Kelime kaldır
Advanced_AllParameters                  Tüm POPFile Parametreleri
Advanced_Parameter                      Parametre
Advanced_Value                          Değer
Advanced_Warning                        Bu POPFile parametrelerinin tam bir listesidir. Sadece ileri seviye kullanıcılar içindir: herhangi bir şeyi değiştirebilir ve güncelleyebilirsiniz; geçerlilik kontrolü yapılmaz.
Advanced_ConfigFile                     Yapılandırma dosyası:

History_Filter                          &nbsp;(şu an <font color="%s">%s</font> kategorisi görüntüleniyor)
History_FilterBy                        Filtreleme
History_Search                          &nbsp;(kimden/konu %s için arandı)
History_Title                           Son Mesajlar
History_Jump                            Mesaja git
History_ShowAll                         Tümünü Göster
History_ShouldBe                        Böyle olmalı
History_NoFrom                          kimden satırı bulunmuyor
History_NoSubject                       konu satırı bulunmuyor
History_ClassifyAs                      Sınıflandır
History_MagnetUsed                      Mıknatıs kullanıldı
History_MagnetBecause                   <b>Mıknatıs kullanıldı</b><p><font color="%s">%s</font> olarak sınıflandırıldı (mıknatıs %s nedeniyle)</p>
History_ChangedTo                       <font color="%s">%s</font> olarak değiştirildi
History_Already                         <font color="%s">%s</font> olarak tekrar sınıflandırıldı
History_RemoveAll                       Tümünü Kaldır
History_RemovePage                      Sayfayı Kaldır
History_RemoveChecked                   Seçileni Kaldır
History_Remove                          Geçmişteki girdileri kaldırmak için tıklayın:
History_SearchMessage                   Kimden/Konu Ara
History_NoMessages                      Mesaj yok
History_ShowMagnet                      mıknatıslanmış
History_Negate_Search                   Aramayı/filtreyi ters çevir
History_Magnet                          &nbsp;(şu an mıknatıs ile sınıflandırılmış mesajlar görüntüleniyor)
History_NoMagnet                        &nbsp;(şu an mıknatıs ile sınıflandırılmamış mesajlar görüntüleniyor)
History_ResetSearch                     Aramayı Sıfırla
History_ChangedClass                    Böyle sınıflandırılabilir
History_Purge                           Şimdi Sil
History_Increase                        Arttır
History_Decrease                        Azalt
History_Column_Characters               Kimden, Kime, Bilgi ve Konu sütunlarının genişliğini değiştir
History_Automatic                       Otomatik
History_Reclassified                    Tekrar sınıflandırılmış
History_Size_Bytes                      %d&nbsp;B
History_Size_KiloBytes                  %.1f&nbsp;KB
History_Size_MegaBytes                  %.1f&nbsp;MB 

Password_Title                          Parola
Password_Enter                          Parolayı girin
Password_Go                             Tamam!
Password_Error1                         Yanlış parola

Security_Error1                         Port 1 ile 65535 arasında bir numara olmalıdır
Security_Stealth                        Gizli Mod/Sunucu Çalışması
Security_NoStealthMode                  Hayır (Gizli Mod)
Security_StealthMode                    (Gizli Mod)
Security_ExplainStats                   (Bu ayar açık olduğunda, POPFile günde bir kez olmak üzere şu değerleri www.usethesource.com içindeki bir koda gönderir; bc (sahip olduğunuz toplam kategori sayısı), mc (POPFile'ın sınıflandırdığı toplam mesaj sayısı) ve ec (toplam sınıflandırma hatası sayısı). Bu bilgiler bir dosyada saklanır, bunları kullanıcıların POPFile'ı nasıl kullandığını ve ne kadar iyi çalıştığı hakkında istatistikler yayınlamak amacıyla kullanacağım.  Web sunucum günlük dosyalarını yaklaşık 5 gün saklar ve siler; istatistikler ve IP adresleri arasında herhangi bir bağlantı biriktirmemekteyim.)
Security_ExplainUpdate                  (Bu ayar açık olduğunda, POPFile günde bir kez olmak üzere şu üç değeri www.usethesource.com içindeki bir koda gönderir; ma (yüklediğiniz POPFile'ın büyük sürüm numarası), mi (yüklediğiniz POPFile'ın küçük sürüm numarası) ve bn (yüklediğiniz POPFile'ın yapı [build] numarası).  Yeni bir sürüm bulunduğunda POPFile, sayfanın üstünde gösterilen, grafik biçiminde bir cevap alır.  Web sunucum günlük dosyalarını yaklaşık 5 gün saklar ve siler; güncelleme kontrolleri ve IP adresleri arasında herhangi bir bağlantı biriktirmemekteyim.)
Security_PasswordTitle                  Kullanıcı Arayüzü Parolası
Security_Password                       Parola
Security_PasswordUpdate                 Parola %s olarak güncellendi
Security_AUTHTitle                      Uzaktaki Sunucular
Security_SecureServer                   POP3 SPA/AUTH sunucusu
Security_SecureServerUpdate             POP3 SPA/AUTH güvenli sunucusu %s olarak güncellendi; bu değişiklik siz POPFile'ı yeniden başlatana kadar etkili olmayacaktır
Security_SecurePort                     POP3 SPA/AUTH portu
Security_SecurePortUpdate               POP3 SPA/AUTH portu %s olarak güncellendi; bu değişiklik siz POPFile'ı yeniden başlatana kadar etkili olmayacaktır
Security_SMTPServer                     SMTP zincir sunucusu
Security_SMTPServerUpdate               SMTP zincir sunucusu %s olarak güncellendi, bu değişiklik siz POPFile'ı yeniden başlatana kadar etkili olmayacaktır
Security_SMTPPort                       SMTP zincir portu
Security_SMTPPortUpdate                 SMTP zincir portu %s olarak güncellendi, bu değişiklik siz POPFile'ı yeniden başlatana kadar etkili olmayacaktır
Security_POP3                           Uzak bilgisayarlardan POP3 bağlantılarını kabul et (POPFile'ı yeniden başlatmak gerekir)
Security_SMTP                           Uzak bilgisayarlardan SMTP bağlantılarını kabul et (POPFile'ı yeniden başlatmak gerekir)
Security_NNTP                           Uzak bilgisayarlardan NNTP bağlantılarını kabul et (POPFile'ı yeniden başlatmak gerekir)
Security_UI                             Uzak bilgisayarlardan HTTP (Kullanıcı Arayüzü) bağlantılarını kabul et (POPFile'ı yeniden başlatmak gerekir)
Security_XMLRPC                         Uzak bilgisayarlardan XML-RPC bağlantılarını kabul et (POPFile'ı yeniden başlatmak gerekir)
Security_UpdateTitle                    Otomatik Güncelleme Kontrolü
Security_Update                         POPFile güncellemesi için her gün kontrol et
Security_StatsTitle                     İstatistik Raporlama
Security_Stats                          Her gün istatistik gönder

Magnet_Error1                           Mıknatıs '%s', kategori '%s' içersinde zaten var
Magnet_Error2                           Yeni '%s' mıknatısı, '%s' mıknatısıyla ('%s' kategorisinde) çakışıyor. Bu belirsiz sonuçlara yol açabilir. Yeni mıknatıs eklenmedi.
Magnet_Error3                           Yeni mıknatıs oluştur: '%s' Kategori: '%s'
Magnet_CurrentMagnets                   Şu Anki Mıknatıslar
Magnet_Message1                         Bu mıknatıslar, postanın her zaman belirtilen kategori olarak sınıflandırılmasını sağlayacaktır.
Magnet_CreateNew                        Yeni Mıknatıs Oluştur
Magnet_Explanation                      <b>Şu tür mıknatıslar mevcuttur:</b> <ul><li><b>Kimden adresi veya isim:</b> Örneğin: Belirli bir adresle eşleştirmek için zeynel@sirket.com, <br />sirket.com'dan gönderen herkes ile eşleştirmek için sirket.com, <br />belirli bir kişiyle eşleştirmek için Zeynel Abidin Öztürk, tüm Zeynel'ler ile eşleştirmek için Zeynel yazın</li><li><b>Kime/Bilgi adres veya adı:</b> Kimden: mıknatısı gibidir fakat mesajdaki Kime:/Bilgi: adresi içindir</li> <li><b>Konu sözcükleri:</b> Örneğin: Konusunda merhaba bulunan tüm mesajlarla eşleştirmek için merhaba yazın</li></ul>
Magnet_MagnetType                       Mıknatıs türü
Magnet_Value                            Değer
Magnet_Always                           Her zaman bu kategoriye gider
Magnet_Jump                             Mıknatıs sayfasına git

Bucket_Error1                           Kategori adları sadece a'dan z'ye küçük harfleri, 0'dan 9'a sayıları,  artı - ve _ karakterlerini içerebilir
Bucket_Error2                           %s adlı kategori zaten var
Bucket_Error3                           %s adında kategori oluşturuldu
Bucket_Error4                           Lütfen boş olmayan bir sözcük girin
Bucket_Error5                           Kategori adı değiştirildi, eski ad: %s yeni ad: %s
Bucket_Error6                           %s kategorisi silindi
Bucket_Title                            Özet
Bucket_BucketName                       Kategori Adı
Bucket_WordCount                        Sözcük Sayısı
Bucket_WordCounts                       Sözcük Sayıları
Bucket_UniqueWords                      Eşsiz Sözcük
Bucket_SubjectModification              Konu Değiştirilmesi
Bucket_ChangeColor                      Renk Değiştir
Bucket_NotEnoughData                    Yetersiz veri
Bucket_ClassificationAccuracy           Sınıflandırma Doğruluğu
Bucket_EmailsClassified                 Sınıflandırılan mesaj
Bucket_EmailsClassifiedUpper            Sınıflandırılan Mesajlar
Bucket_ClassificationErrors             Sınıflandırma hataları
Bucket_Accuracy                         Doğruluk
Bucket_ClassificationCount              Sınıflandırma Sayısı
Bucket_ClassificationFP                 Olumlu Yanlışlar
Bucket_ClassificationFN                 Olumsuz Yanlışlar
Bucket_ResetStatistics                  İstatistikleri Sıfırla
Bucket_LastReset                        Son Sıfırlama
Bucket_CurrentColor                     %s şu anki rengi %s
Bucket_SetColorTo                       %s rengini %s rengi ile değiştir
Bucket_Maintenance                      Bakım
Bucket_CreateBucket                     Bu isimde kategori oluştur
Bucket_DeleteBucket                     Bu isimdeki kategoriyi sil
Bucket_RenameBucket                     Bu isimdeki kategorinin adını değiştir
Bucket_Lookup                           Arama
Bucket_LookupMessage                    Kategoriler içersinde sözcük arama
Bucket_LookupMessage2                   Arama sonuçları:
Bucket_LookupMostLikely                 <b>%s</b> daha çok <font color="%s">%s</font> içersinde görünüyor
Bucket_DoesNotAppear                    <p><b>%s</b> hiçbir kategoride görünmüyor
Bucket_DisabledGlobally                 Tamamen devre dışı
Bucket_To                               Yeni Ad:
Bucket_Quarantine                       Karantina

SingleBucket_Title                      %s detayları
SingleBucket_WordCount                  Kategori sözcük sayısı
SingleBucket_TotalWordCount             Toplam sözcük sayısı
SingleBucket_Percentage                 Toplama göre yüzdesi
SingleBucket_WordTable                  %s için Sözcük Tablosu
SingleBucket_Message1                   Herhangi bir harfle başlayan sözcükleri görmek için o harfe tıklayın.  Bir sözcüğün tüm kategorilerdeki olasılıklarını aramak için istediğiniz bir sözcüğe tıklayın.
SingleBucket_Unique                     %s eşsiz
SingleBucket_ClearBucket                Tüm Kelimeleri Kaldır

Session_Title                           POPFile Oturum Süresi Doldu
Session_Error                           POPFile Oturum süreniz doldu.  Bu, web penceresi açıkken POPFile'ı başlatıp durdurmak sebebiyle gerçekleşmiş olabilir. POPFile'ı kullanmaya devam etmek için lütfen bağlantılardan birini tıklayın.

View_Title                              Tek Mesaj Görünümü
View_ShowFrequencies                    Sözcük frekanslarını göster
View_ShowProbabilities                  Sözcük olasılıklarını göster
View_ShowScores                         Sözcük puanlarını göster
View_WordMatrix                         Sözcük matrisi
View_WordProbabilities                  sözcük olasılıkları görüntüleniyor
View_WordFrequencies                    sözcük frekansları görüntüleniyor
View_WordScores                         sözcük puanları görüntüleniyor
View_Chart                              Karar grafiği

Windows_TrayIcon                        POPFile simgesi Windows sistem çubuğunda gösterilsin mi?
Windows_Console                         POPFile konsol penceresinde mi çalıştırılsın?
Windows_NextTime                        <p><font color="red">Bu değişiklik, bir sonraki POPFile başlangıcına kadar etkili olmayacaktır</font>

Header_MenuSummary                      Bu tablo, denetim merkezinin farklı sayfalarına erişmeyi sağlayan bir gözatma menüsüdür
History_MainTableSummary                Bu tablo son alınan mesajların gönderenlerini ve konularını görüntüler ve gözden geçirilip tekrar sınıflandırılmasını sağlar.  Konu satırına tıklamak, mesajın sınıflandırılması hakkında bilgi ile birlikte tam mesaj metnini gösterir.  'Böyle olmalı' sütunu, mesajın hangi kategoride olması gerektiğini seçmenizi veya bu değişikliği geri almanızı sağlar.  'Sil' sütunu, gerek duymadığınız mesajları geçmiş içerisinden seçerek silmenize izin verir.
History_OpenMessageSummary              Bu tablo, sınıflandırma için kullanılan her kelimenin en çok uyuşan kategoriye göre vurgulandığı, mesajın tam metnini içerir.
Bucket_MainTableSummary                 Bu tablo, sınıflandırma kategorileri hakkında bir özet sunar.  Her sıra kategori adını, kategori için toplam sözcük sayısını, her kategorideki tek sözcük sayısını, mesajın bu kategori ile sınıflandırıldığında konu satırının değiştirilip değiştirilmeyeceğini, bu kategoride alınan mesajların karantinaya alınıp alınmayacağını ve bu kategori ile ilgili Denetim Merkezinde kullanılacak rengi seçmenizi sağlar.
Bucket_StatisticsTableSummary           Bu tablo POPFile'ın tüm performansı hakkında üç grup istatistik sunar.  Birincisi sınıflamanın ne kadar doğru olduğu, ikincisi kaç mesajın sınıflandırıldığı ve hangi kategorinin atandığını ve üçüncüsü her kategoride kaç sözcüğün bulunduğu ve ilgili yüzdelerinin kaç olduğunu gösterir.
Bucket_MaintenanceTableSummary          Bu tablo, kategorileri oluşturabileceğiniz, silebileceğiniz veya adını değiştirebileceğiniz formları içerir ve tüm kategorilerde bir kelimeyi aratıp ilgili olasılıklarını görmebilmenizi sağlar.
Bucket_AccuracyChartSummary             Bu tablo, mesaj sınıflandırmasının doğruluğunu grafik üzerinde gösterir.
Bucket_BarChartSummary                  Bu tablo, her farklı kategori için ayrılan yüzdeyi grafik olarak görüntüler.  Bu hem sınıflandırılan mesaj sayısı hem de toplam sözcük sayıları için kullanılır.
Bucket_LookupResultsSummary             Bu tablo, sözcük listesinden verilen herhangi bir sözcük ile ilişkili olasılıkları görüntüler.  Her kategori için, bu kelimenin meydana geldiği frekansı, bu kategoride meydana gelme olasılığı ve bu sözcük mesajda bulunuyorsa puan üzerindeki tam etkisini gösterir.
Bucket_WordListTableSummary             Bu tablo, bir kategoriye özgü tüm sözcüklerin, her satır için ortak ilk harf ile düzenlenmiş listesini sunar.
Magnet_MainTableSummary                 Bu tablo, mesajları sabit kurallara göre otomatik olarak sınıflandırmakta kullanılan mıknatısların listesini gösterir.  Her satır mıknatısın nasıl tanımlandığını, bunun için hangi kategorinin seçildiğini görüntüler ve mıknatısı silmek için bir düğme gösterir.
Configuration_MainTableSummary          Bu tablo, POPFile'ın yapılandırmasını denetlemenize izin veren bazı formlar içerir.
Configuration_InsertionTableSummary     Bu tablo, mesajın posta programına (client) iletilmeden önce üst bilgilerde veya konu satırında bazı değişikliklerinin yapılıp yapılmayacağını belirleyen düğmeler içerir.
Security_MainTableSummary               Bu tablo, otomatik olarak program güncellemelerinin kontrol edilip edilmeyeceği, POPFile'ın performansı hakkındaki istatistiklerin genel bilgi için program yapımcısının veri deposu merkezine gönderilip gönderilmeyeceği hakkında POPFile'ın tüm yapılandırmasının güvenliğini etkileyecek denetim grupları sağlar.
Advanced_MainTableSummary               Bu tablo, POPFile'ın genelde mesajdaki göreceli frekansları nedeniyle yoksaydığı sözcüklerin listesini sunar.  Bunlar her satırda sözcüğün ilk harfine göre düzenlenmiştir.

Imap_Bucket2Folder                      %s kategorisindeki posta %s klasörüne gider
Imap_MapError                           Bir klasöre birden fazla kategori atayamazsınız!
Imap_Server                             IMAP sunucusu:
Imap_ServerNameError                    Lütfen sunucunun adını girin!
Imap_Port                               IMAP Sunucu portu:
Imap_PortError                          Lütfen geçerli bir port numarası girin!
Imap_Login                              IMAP hesabı oturum açma adı:
Imap_LoginError                         Lütfen bir kullanıcı/oturum açma adı girin!
Imap_Password                           IMAP hesabı parolası:
Imap_PasswordError                      Lütfen sunucu için bir parola girin!
Imap_Expunge                            Silinen mesajları izlenen klasörlerden kaldır.
Imap_Interval                           Güncelleme aralığı, saniye:
Imap_IntervalError                      Lütfen 10 ile 3600 saniye arasında bir sayı girin.
Imap_RefreshFolders                     Klasör listesini yenile
Imap_Now                                şimdi!
Imap_UpdateError1                       Oturum açılamıyor. Lütfen oturum açma adını ve parolayı kontrol edin.
Imap_UpdateError2                       Sunucuyla bağlantı kurulamıyor. Lütfen sunucu adını ve port numarasını kontrol edin ve ağa bağlı olduğunuzdan emin olun.
Imap_UpdateError3                       Lütfen önce bağlantı detaylarını ayarlayın.
Imap_NoConnectionMessage                Lütfen önce bağlantı detaylarını ayarlayın. Bunu yaptıktan sonra, bu sayfada daha fazla seçenek belirecektir.
Imap_WatchMore                          a folder to list of watched folders
Imap_WatchedFolder                      İzlenilen klasör numarası

Shutdown_Message                        POPFile kapatıldı

Help_Training                           POPFile'ı ilk kullandığınızda o hiçbir bilgiye sahip değildir ve eğitime ihtiyacı vardır. POPFile her kategori için mesajlar ile eğitilmelidir. Eğitim, POPFile bir mesajı yanlış sınıflandırdığında bunu doğru kategori ile tekrar sınıflandırarak gerçekleştirilir. Bunun dışında, posta programınızın mesajları POPFile'ın sınıflandırmasına göre filtrelemesi için ayarlamalısınız. Posta programınızın filtelerini ayarlamak hakkında bilgi <a href="http://getpopfile.org/docs/faq/EmailSorting">POPFile Dökümantasyon Projesi</a> adresinde bulunabilir.
Help_Bucket_Setup                       POPFile, sınıflandırılmamış pseudo-kategorisi dışında en az iki kategori gerektirir. POPFile'ı eşsiz yapan, ikiden fazla, istediğiniz sayıda kategoriye sahip olabilmenizdir. Basit bir kurulum, "spam", "kişisel", ve "iş" kategorileri gibi olabilir.
Help_No_More                            Bunu bir daha gösterme 
