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
FAQLink                                 FrequentlyAskedQuestions

# Common words that are used on their own all over the interface
Apply                                   Uygula
On                                      Açýk
Off                                     Kapalý
TurnOn                                  Aç
TurnOff                                 Kapat
Add                                     Ekle
Remove                                  Kaldýr
Previous                                Önceki
Next                                    Sonraki
From                                    Kimden
Subject                                 Konu
Cc                                      Bilgi 
Classification                          Sýnýflandýrma
Reclassify                              Tekrar Sýnýflandýr
Probability                             Olasýlýk
Scores                                  Puanlar 
QuickMagnets                            HýzlýMýknatýs
Undo                                    Geri Al
Close                                   Kapat
Find                                    Bul
Filter                                  Filtrele
Yes                                     Evet
No                                      Hayýr
ChangeToYes                             Evet olarak deðiþtir
ChangeToNo                              Hayýr olarak deðiþtir
Bucket                                  Kategori
Magnet                                  Mýknatýs
Delete                                  Sil
Create                                  Oluþtur
To                                      Kime
Total                                   Toplam
Rename                                  Ad Deðiþtir
Frequency                               Frekans
Probability                             Olasýlýk
Score                                   Puan
Lookup                                  Arama
Word                                    Sözcük
Count                                   Miktar
Update                                  Güncelle
Refresh                                 Yenile
FAQ                                     Sýk Sorulan Sorular
ID                                      Kimlik
Date                                    Tarih
Arrived                                 Alýnma
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
Header_Shutdown                         POPFile'ý Kapat
Header_History                          Geçmiþ
Header_Buckets                          Kategoriler
Header_Configuration                    Yapýlandýrma
Header_Advanced                         Geliþmiþ
Header_Security                         Güvenlik
Header_Magnets                          Mýknatýslar

Footer_HomePage                         POPFile Web Sayfasý
Footer_Manual                           Kýlavuz
Footer_Forums                           Forumlar
Footer_FeedMe                           Baðýþ Yap
Footer_RequestFeature                   Özellik Ýsteðinde Bulun
Footer_MailingList                      Posta Listesi
Footer_Wiki                             Belgeler

Configuration_Error1                    Ayýrýcý karakter tek bir karakter olmalýdýr
Configuration_Error2                    Kullanýcý arayüzü portu 1 ile 65535 arasýnda bir sayý olmalýdýr
Configuration_Error3                    POP3 dinleme portu 1 ile 65535 arasýnda bir sayý olmalýdýr
Configuration_Error4                    Sayfa boyutu 1 ile 1000 arasýnda bir sayý olmalýdýr
Configuration_Error5                    Geçmiþteki gün sayýsý 1 ile 366 arasýnda bir sayý olmalýdýr
Configuration_Error6                    TCP zaman aþýmý 10 ile 300 arasýnda bir sayý olmalýdýr
Configuration_Error7                    XML RPC dinleme portu 1 ile 65535 arasýnda bir numara olmalýdýr
Configuration_Error8                    SOCKS V proxy port sayýsý 1 ve 65535 arasýnda bir sayý olmalýdýr
Configuration_POP3Port                  POP3 dinleme portu
Configuration_POP3Update                POP3 portu %s olarak güncellendi; bu deðiþiklik siz POPFile'ý yeniden baþlatana kadar etkili olmayacaktýr
Configuration_XMLRPCUpdate              XML-RPC portu %s olarak güncellendi; bu deðiþiklik siz POPFile'ý yeniden baþlatana kadar etkili olmayacaktýr
Configuration_XMLRPCPort                XML-RPC dinleme portu
Configuration_SMTPPort                  SMTP dinleme portu
Configuration_SMTPUpdate                SMTP portu %s olarak güncellendi; bu deðiþiklik siz POPFile'ý yeniden baþlatana kadar etkili olmayacaktýr
Configuration_NNTPPort                  NNTP dinleme portu
Configuration_NNTPUpdate                NNTP portu %s olarak güncellendi; bu deðiþiklik siz POPFile'ý yeniden baþlatana kadar etkili olmayacaktýr
Configuration_POPFork                   Ayný anda yapýlan POP3 baðlantýlarýna izin ver
Configuration_SMTPFork                  Ayný anda yapýlan SMTP baðlantýlarýna izin ver
Configuration_NNTPFork                  Ayný anda yapýlan NNTP baðlantýlarýna izin ver
Configuration_POP3Separator             POP3 sunucu:port:kullanýcý ayýrýcý karakteri
Configuration_NNTPSeparator             NNTP sunucu:port:kullanýcý ayýrýcý karakteri
Configuration_POP3SepUpdate             POP3 ayýrýcýsý %s olarak güncellendi
Configuration_NNTPSepUpdate             NNTP ayýrýcýsý %s olarak güncellendi
Configuration_UI                        Kullanýcý arayüzü web portu
Configuration_UIUpdate                  Kullanýcý arayüzü web portu %s olarak güncellendi, bu deðiþiklik siz POPFile'ý yeniden baþlatana kadar etkili olmayacaktýr
Configuration_History                   Sayfa baþýna mesaj sayýsý
Configuration_HistoryUpdate             Sayfa baþýna mesaj sayýsý %s olarak güncellendi
Configuration_Days                      Geçmiþin saklanacaðý gün sayýsý
Configuration_DaysUpdate                Geçmiþin saklanacaðý gün sayýsý %s olarak güncellendi
Configuration_UserInterface             Kullanýcý Arayüzü
Configuration_Skins                     Dýþ Görünümler
Configuration_SkinsChoose               Dýþ görünüm seçin
Configuration_Language                  Dil
Configuration_LanguageChoose            Dil seçin
Configuration_ListenPorts               Modül Seçenekleri
Configuration_HistoryView               Geçmiþ Görünmü
Configuration_TCPTimeout                Baðlantý Zaman Aþýmý
Configuration_TCPTimeoutSecs            Saniye olarak baðlantý zaman aþýmý
Configuration_TCPTimeoutUpdate          Zaman aþýmý %s saniye olarak güncellendi
Configuration_ClassificationInsertion   Mesaja Metin Ekleme
Configuration_SubjectLine               Konu satýrý deðiþtirilmesi
Configuration_XTCInsertion              X-Text-Classification Üst bilgisi
Configuration_XPLInsertion              X-POPFile-Link Üst bilgisi
Configuration_Logging                   Günlük tutma
Configuration_None                      Kapalý
Configuration_ToScreen                  Ekrana
Configuration_ToFile                    Dosyaya
Configuration_ToScreenFile              Ekrana ve Dosyaya
Configuration_LoggerOutput              Günlük çýktýsý
Configuration_GeneralSkins              Dýþ görünümler
Configuration_SmallSkins                Küçük Dýþ Görünümler
Configuration_TinySkins                 Daha Küçük Dýþ Görünümler
Configuration_CurrentLogFile            &lt;þimdiki günlük dosyasý&gt;
Configuration_SOCKSServer               SOCKS V proxy sunucusu
Configuration_SOCKSPort                 SOCKS V proxy port
Configuration_SOCKSPortUpdate           SOCKS V proxy port %s olarak güncellendi
Configuration_SOCKSServerUpdate         SOCKS V proxy sunucusu to %s olarak güncellendi
Configuration_Fields                    Geçmiþ sütunlarý

Advanced_Error1                         '%s' zaten Yoksayýlan Sözcükler listesinde
Advanced_Error2                         Yoksayýlan kelimeler sadece harfleri, sayýlarý, ., _, -, veya @ karakterlerini içerebilir
Advanced_Error3                         '%s' Yoksayýlan Kelimeler listesine eklendi
Advanced_Error4                         '%s' Yoksayýlan Kelimeler içersinde bulunmuyor
Advanced_Error5                         '%s' Yoksayýlan Kelimeler listesinden silindi
Advanced_StopWords                      Yoksayýlan Kelimeler
Advanced_Message1                       POPFile aþaðýdaki sýkça kullanýlan kelimeleri yok sayar:
Advanced_AddWord                        Kelime ekle
Advanced_RemoveWord                     Kelime kaldýr
Advanced_AllParameters                  Tüm POPFile Parametreleri
Advanced_Parameter                      Parametre
Advanced_Value                          Deðer
Advanced_Warning                        Bu POPFile parametrelerinin tam bir listesidir. Sadece ileri seviye kullanýcýlar içindir: herhangi bir þeyi deðiþtirebilir ve güncelleyebilirsiniz; geçerlilik kontrolü yapýlmaz.
Advanced_ConfigFile                     Yapýlandýrma dosyasý:

History_Filter                          &nbsp;(þu an <font color="%s">%s</font> kategorisi görüntüleniyor)
History_FilterBy                        Filtreleme
History_Search                          &nbsp;(kimden/konu %s için arandý)
History_Title                           Son Mesajlar
History_Jump                            Mesaja git
History_ShowAll                         Tümünü Göster
History_ShouldBe                        Böyle olmalý
History_NoFrom                          kimden satýrý bulunmuyor
History_NoSubject                       konu satýrý bulunmuyor
History_ClassifyAs                      Sýnýflandýr
History_MagnetUsed                      Mýknatýs kullanýldý
History_MagnetBecause                   <b>Mýknatýs kullanýldý</b><p><font color="%s">%s</font> olarak sýnýflandýrýldý (mýknatýs %s nedeniyle)</p>
History_ChangedTo                       <font color="%s">%s</font> olarak deðiþtirildi
History_Already                         <font color="%s">%s</font> olarak tekrar sýnýflandýrýldý
History_RemoveAll                       Tümünü Kaldýr
History_RemovePage                      Sayfayý Kaldýr
History_RemoveChecked                   Seçileni Kaldýr
History_Remove                          Geçmiþteki girdileri kaldýrmak için týklayýn:
History_SearchMessage                   Kimden/Konu Ara
History_NoMessages                      Mesaj yok
History_ShowMagnet                      mýknatýslanmýþ
History_ShowNoMagnet                    mýknatýslanmamýþ
History_Magnet                          &nbsp;(þu an mýknatýs ile sýnýflandýrýlmýþ mesajlar görüntüleniyor)
History_NoMagnet                        &nbsp;(þu an mýknatýs ile sýnýflandýrýlmamýþ mesajlar görüntüleniyor)
History_ResetSearch                     Aramayý Sýfýrla
History_ChangedClass                    Böyle sýnýflandýrýlabilir
History_Purge                           Þimdi Sil
History_Increase                        Arttýr
History_Decrease                        Azalt
History_Column_Characters               Kimden, Kime, Bilgi ve Konu sütunlarýnýn geniþliðini deðiþtir
History_Automatic                       Otomatik
History_Reclassified                    Tekrar sýnýflandýrýlmýþ
History_Size_Bytes                      %d&nbsp;B
History_Size_KiloBytes                  %.1f&nbsp;KB
History_Size_MegaBytes                  %.1f&nbsp;MB 

Password_Title                          Parola
Password_Enter                          Parolayý girin
Password_Go                             Tamam!
Password_Error1                         Yanlýþ parola

Security_Error1                         Port 1 ile 65535 arasýnda bir numara olmalýdýr
Security_Stealth                        Gizli Mod/Sunucu Çalýþmasý
Security_NoStealthMode                  Hayýr (Gizli Mod)
Security_StealthMode                    (Gizli Mod)
Security_ExplainStats                   (Bu ayar açýk olduðunda, POPFile günde bir kez olmak üzere þu deðerleri www.usethesource.com içindeki bir koda gönderir; bc (sahip olduðunuz toplam kategori sayýsý), mc (POPFile'ýn sýnýflandýrdýðý toplam mesaj sayýsý) ve ec (toplam sýnýflandýrma hatasý sayýsý). Bu bilgiler bir dosyada saklanýr, bunlarý kullanýcýlarýn POPFile'ý nasýl kullandýðýný ve ne kadar iyi çalýþtýðý hakkýnda istatistikler yayýnlamak amacýyla kullanacaðým.  Web sunucum günlük dosyalarýný yaklaþýk 5 gün saklar ve siler; istatistikler ve IP adresleri arasýnda herhangi bir baðlantý biriktirmemekteyim.)
Security_ExplainUpdate                  (Bu ayar açýk olduðunda, POPFile günde bir kez olmak üzere þu üç deðeri www.usethesource.com içindeki bir koda gönderir; ma (yüklediðiniz POPFile'ýn büyük sürüm numarasý), mi (yüklediðiniz POPFile'ýn küçük sürüm numarasý) ve bn (yüklediðiniz POPFile'ýn yapý [build] numarasý).  Yeni bir sürüm bulunduðunda POPFile, sayfanýn üstünde gösterilen, grafik biçiminde bir cevap alýr.  Web sunucum günlük dosyalarýný yaklaþýk 5 gün saklar ve siler; güncelleme kontrolleri ve IP adresleri arasýnda herhangi bir baðlantý biriktirmemekteyim.)
Security_PasswordTitle                  Kullanýcý Arayüzü Parolasý
Security_Password                       Parola
Security_PasswordUpdate                 Parola %s olarak güncellendi
Security_AUTHTitle                      Uzaktaki Sunucular
Security_SecureServer                   POP3 SPA/AUTH sunucusu
Security_SecureServerUpdate             POP3 SPA/AUTH güvenli sunucusu %s olarak güncellendi; bu deðiþiklik siz POPFile'ý yeniden baþlatana kadar etkili olmayacaktýr
Security_SecurePort                     POP3 SPA/AUTH portu
Security_SecurePortUpdate               POP3 SPA/AUTH portu %s olarak güncellendi; bu deðiþiklik siz POPFile'ý yeniden baþlatana kadar etkili olmayacaktýr
Security_SMTPServer                     SMTP zincir sunucusu
Security_SMTPServerUpdate               SMTP zincir sunucusu %s olarak güncellendi, bu deðiþiklik siz POPFile'ý yeniden baþlatana kadar etkili olmayacaktýr
Security_SMTPPort                       SMTP zincir portu
Security_SMTPPortUpdate                 SMTP zincir portu %s olarak güncellendi, bu deðiþiklik siz POPFile'ý yeniden baþlatana kadar etkili olmayacaktýr
Security_POP3                           Uzak bilgisayarlardan POP3 baðlantýlarýný kabul et (POPFile'ý yeniden baþlatmak gerekir)
Security_SMTP                           Uzak bilgisayarlardan SMTP baðlantýlarýný kabul et (POPFile'ý yeniden baþlatmak gerekir)
Security_NNTP                           Uzak bilgisayarlardan NNTP baðlantýlarýný kabul et (POPFile'ý yeniden baþlatmak gerekir)
Security_UI                             Uzak bilgisayarlardan HTTP (Kullanýcý Arayüzü) baðlantýlarýný kabul et (POPFile'ý yeniden baþlatmak gerekir)
Security_XMLRPC                         Uzak bilgisayarlardan XML-RPC baðlantýlarýný kabul et (POPFile'ý yeniden baþlatmak gerekir)
Security_UpdateTitle                    Otomatik Güncelleme Kontrolü
Security_Update                         POPFile güncellemesi için her gün kontrol et
Security_StatsTitle                     Ýstatistik Raporlama
Security_Stats                          Her gün istatistik gönder

Magnet_Error1                           Mýknatýs '%s', kategori '%s' içersinde zaten var
Magnet_Error2                           Yeni '%s' mýknatýsý, '%s' mýknatýsýyla ('%s' kategorisinde) çakýþýyor. Bu belirsiz sonuçlara yol açabilir. Yeni mýknatýs eklenmedi.
Magnet_Error3                           Yeni mýknatýs oluþtur: '%s' Kategori: '%s'
Magnet_CurrentMagnets                   Þu Anki Mýknatýslar
Magnet_Message1                         Bu mýknatýslar, postanýn her zaman belirtilen kategori olarak sýnýflandýrýlmasýný saðlayacaktýr.
Magnet_CreateNew                        Yeni Mýknatýs Oluþtur
Magnet_Explanation                      Þu tür mýknatýslar mevcuttur:</b> <ul><li><b>Kimden adresi veya isim:</b> Örneðin: Belirli bir adresle eþleþtirmek için zeynel@sirket.com, <br />sirket.com'dan gönderen herkes ile eþleþtirmek için sirket.com, <br />belirli bir kiþiyle eþleþtirmek için Zeynel Abidin Öztürk, tüm Zeynel'ler ile eþleþtirmek için Zeynel yazýn</li><li><b>Kime/Bilgi adres veya adý:</b> Kimden: mýknatýsý gibidir fakat mesajdaki Kime:/Bilgi: adresi içindir</li> <li><b>Konu sözcükleri:</b> Örneðin: Konusunda merhaba bulunan tüm mesajlarla eþleþtirmek için merhaba yazýn</li></ul>
Magnet_MagnetType                       Mýknatýs türü
Magnet_Value                            Deðer
Magnet_Always                           Her zaman bu kategoriye gider
Magnet_Jump                             Mýknatýs sayfasýna git

Bucket_Error1                           Kategori adlarý sadece a'dan z'ye küçük harfleri, 0'dan 9'a sayýlarý,  artý - ve _ karakterlerini içerebilir
Bucket_Error2                           %s adlý kategori zaten var
Bucket_Error3                           %s adýnda kategori oluþturuldu
Bucket_Error4                           Lütfen boþ olmayan bir sözcük girin
Bucket_Error5                           Kategori adý deðiþtirildi, eski ad: %s yeni ad: %s
Bucket_Error6                           %s kategorisi silindi
Bucket_Title                            Özet
Bucket_BucketName                       Kategori Adý
Bucket_WordCount                        Sözcük Sayýsý
Bucket_WordCounts                       Sözcük Sayýlarý
Bucket_UniqueWords                      Eþsiz Sözcük
Bucket_SubjectModification              Konu Deðiþtirilmesi
Bucket_ChangeColor                      Renk Deðiþtir
Bucket_NotEnoughData                    Yetersiz veri
Bucket_ClassificationAccuracy           Sýnýflandýrma Doðruluðu
Bucket_EmailsClassified                 Sýnýflandýrýlan mesaj
Bucket_EmailsClassifiedUpper            Sýnýflandýrýlan Mesajlar
Bucket_ClassificationErrors             Sýnýflandýrma hatalarý
Bucket_Accuracy                         Doðruluk
Bucket_ClassificationCount              Sýnýflandýrma Sayýsý
Bucket_ClassificationFP                 Olumlu Yanlýþlar
Bucket_ClassificationFN                 Olumsuz Yanlýþlar
Bucket_ResetStatistics                  Ýstatistikleri Sýfýrla
Bucket_LastReset                        Son Sýfýrlama
Bucket_CurrentColor                     %s þu anki rengi %s
Bucket_SetColorTo                       %s rengini %s rengi ile deðiþtir
Bucket_Maintenance                      Bakým
Bucket_CreateBucket                     Bu isimde kategori oluþtur
Bucket_DeleteBucket                     Bu isimdeki kategoriyi sil
Bucket_RenameBucket                     Bu isimdeki kategorinin adýný deðiþtir
Bucket_Lookup                           Arama
Bucket_LookupMessage                    Kategoriler içersinde sözcük arama
Bucket_LookupMessage2                   Arama sonuçlarý:
Bucket_LookupMostLikely                 <b>%s</b> daha çok <font color="%s">%s</font> içersinde görünüyor
Bucket_DoesNotAppear                    <p><b>%s</b> hiçbir kategoride görünmüyor
Bucket_DisabledGlobally                 Tamamen devre dýþý
Bucket_To                               Yeni Ad:
Bucket_Quarantine                       Karantina

SingleBucket_Title                      %s detaylarý
SingleBucket_WordCount                  Kategori sözcük sayýsý
SingleBucket_TotalWordCount             Toplam sözcük sayýsý
SingleBucket_Percentage                 Toplama göre yüzdesi
SingleBucket_WordTable                  %s için Sözcük Tablosu
SingleBucket_Message1                   Herhangi bir harfle baþlayan sözcükleri görmek için o harfe týklayýn.  Bir sözcüðün tüm kategorilerdeki olasýlýklarýný aramak için istediðiniz bir sözcüðe týklayýn.
SingleBucket_Unique                     %s eþsiz
SingleBucket_ClearBucket                Tüm Kelimeleri Kaldýr

Session_Title                           POPFile Oturum Süresi Doldu
Session_Error                           POPFile Oturum süreniz doldu.  Bu, web penceresi açýkken POPFile'ý baþlatýp durdurmak sebebiyle gerçekleþmiþ olabilir. POPFile'ý kullanmaya devam etmek için lütfen baðlantýlardan birini týklayýn.

View_Title                              Tek Mesaj Görünümü
View_ShowFrequencies                    Sözcük frekanslarýný göster
View_ShowProbabilities                  Sözcük olasýlýklarýný göster
View_ShowScores                         Sözcük puanlarýný göster
View_WordMatrix                         Sözcük matrisi
View_WordProbabilities                  sözcük olasýlýklarý görüntüleniyor
View_WordFrequencies                    sözcük frekanslarý görüntüleniyor
View_WordScores                         sözcük puanlarý görüntüleniyor
View_Chart                              Karar grafiði

Windows_TrayIcon                        POPFile simgesi Windows sistem çubuðunda gösterilsin mi?
Windows_Console                         POPFile konsol penceresinde mi çalýþtýrýlsýn?
Windows_NextTime                        <p><font color="red">Bu deðiþiklik, bir sonraki POPFile baþlangýcýna kadar etkili olmayacaktýr</font>

Header_MenuSummary                      Bu tablo, denetim merkezinin farklý sayfalarýna eriþmeyi saðlayan bir gözatma menüsüdür
History_MainTableSummary                Bu tablo son alýnan mesajlarýn gönderenlerini ve konularýný görüntüler ve gözden geçirilip tekrar sýnýflandýrýlmasýný saðlar.  Konu satýrýna týklamak, mesajýn sýnýflandýrýlmasý hakkýnda bilgi ile birlikte tam mesaj metnini gösterir.  'Böyle olmalý' sütunu, mesajýn hangi kategoride olmasý gerektiðini seçmenizi veya bu deðiþikliði geri almanýzý saðlar.  'Sil' sütunu, gerek duymadýðýnýz mesajlarý geçmiþ içerisinden seçerek silmenize izin verir.
History_OpenMessageSummary              Bu tablo, sýnýflandýrma için kullanýlan her kelimenin en çok uyuþan kategoriye göre vurgulandýðý, mesajýn tam metnini içerir.
Bucket_MainTableSummary                 Bu tablo, sýnýflandýrma kategorileri hakkýnda bir özet sunar.  Her sýra kategori adýný, kategori için toplam sözcük sayýsýný, her kategorideki tek sözcük sayýsýný, mesajýn bu kategori ile sýnýflandýrýldýðýnda konu satýrýnýn deðiþtirilip deðiþtirilmeyeceðini, bu kategoride alýnan mesajlarýn karantinaya alýnýp alýnmayacaðýný ve bu kategori ile ilgili Denetim Merkezinde kullanýlacak rengi seçmenizi saðlar.
Bucket_StatisticsTableSummary           Bu tablo POPFile'ýn tüm performansý hakkýnda üç grup istatistik sunar.  Birincisi sýnýflamanýn ne kadar doðru olduðu, ikincisi kaç mesajýn sýnýflandýrýldýðý ve hangi kategorinin atandýðýný ve üçüncüsü her kategoride kaç sözcüðün bulunduðu ve ilgili yüzdelerinin kaç olduðunu gösterir.
Bucket_MaintenanceTableSummary          Bu tablo, kategorileri oluþturabileceðiniz, silebileceðiniz veya adýný deðiþtirebileceðiniz formlarý içerir ve tüm kategorilerde bir kelimeyi aratýp ilgili olasýlýklarýný görmebilmenizi saðlar.
Bucket_AccuracyChartSummary             Bu tablo, mesaj sýnýflandýrmasýnýn doðruluðunu grafik üzerinde gösterir.
Bucket_BarChartSummary                  Bu tablo, her farklý kategori için ayrýlan yüzdeyi grafik olarak görüntüler.  Bu hem sýnýflandýrýlan mesaj sayýsý hem de toplam sözcük sayýlarý için kullanýlýr.
Bucket_LookupResultsSummary             Bu tablo, sözcük listesinden verilen herhangi bir sözcük ile iliþkili olasýlýklarý görüntüler.  Her kategori için, bu kelimenin meydana geldiði frekansý, bu kategoride meydana gelme olasýlýðý ve bu sözcük mesajda bulunuyorsa puan üzerindeki tam etkisini gösterir.
Bucket_WordListTableSummary             Bu tablo, bir kategoriye özgü tüm sözcüklerin, her satýr için ortak ilk harf ile düzenlenmiþ listesini sunar.
Magnet_MainTableSummary                 Bu tablo, mesajlarý sabit kurallara göre otomatik olarak sýnýflandýrmakta kullanýlan mýknatýslarýn listesini gösterir.  Her satýr mýknatýsýn nasýl tanýmlandýðýný, bunun için hangi kategorinin seçildiðini görüntüler ve mýknatýsý silmek için bir düðme gösterir.
Configuration_MainTableSummary          Bu tablo, POPFile'ýn yapýlandýrmasýný denetlemenize izin veren bazý formlar içerir.
Configuration_InsertionTableSummary     Bu tablo, mesajýn posta programýna (client) iletilmeden önce üst bilgilerde veya konu satýrýnda bazý deðiþikliklerinin yapýlýp yapýlmayacaðýný belirleyen düðmeler içerir.
Security_MainTableSummary               Bu tablo, otomatik olarak program güncellemelerinin kontrol edilip edilmeyeceði, POPFile'ýn performansý hakkýndaki istatistiklerin genel bilgi için program yapýmcýsýnýn veri deposu merkezine gönderilip gönderilmeyeceði hakkýnda POPFile'ýn tüm yapýlandýrmasýnýn güvenliðini etkileyecek denetim gruplarý saðlar.
Advanced_MainTableSummary               Bu tablo, POPFile'ýn genelde mesajdaki göreceli frekanslarý nedeniyle yoksaydýðý sözcüklerin listesini sunar.  Bunlar her satýrda sözcüðün ilk harfine göre düzenlenmiþtir.

Imap_Bucket2Folder                      %s kategorisindeki posta %s klasörüne gider
Imap_MapError                           Bir klasöre birden fazla kategori atayamazsýnýz!
Imap_Server                             IMAP sunucusu:
Imap_ServerNameError                    Lütfen sunucunun adýný girin!
Imap_Port                               IMAP Sunucu portu:
Imap_PortError                          Lütfen geçerli bir port numarasý girin!
Imap_Login                              IMAP hesabý oturum açma adý:
Imap_LoginError                         Lütfen bir kullanýcý/oturum açma adý girin!
Imap_Password                           IMAP hesabý parolasý:
Imap_PasswordError                      Lütfen sunucu için bir parola girin!
Imap_Expunge                            Silinen mesajlarý izlenen klasörlerden kaldýr.
Imap_Interval                           Güncelleme aralýðý, saniye:
Imap_IntervalError                      Lütfen 10 ile 3600 saniye arasýnda bir sayý girin.
Imap_Bytelimit                          Her mesajýn sýnýflandýrýlmasýnda kullanýlacak bayt. Tüm mesaj için 0 girin:
Imap_BytelimitError                     Lütfen bir sayý girin.
Imap_RefreshFolders                     Klasör listesini yenile
Imap_Now                                þimdi!
Imap_UpdateError1                       Oturum açýlamýyor. Lütfen oturum açma adýný ve parolayý kontrol edin.
Imap_UpdateError2                       Sunucuyla baðlantý kurulamýyor. Lütfen sunucu adýný ve port numarasýný kontrol edin ve aða baðlý olduðunuzdan emin olun.
Imap_UpdateError3                       Lütfen önce baðlantý detaylarýný ayarlayýn.
Imap_NoConnectionMessage                Lütfen önce baðlantý detaylarýný ayarlayýn. Bunu yaptýktan sonra, bu sayfada daha fazla seçenek belirecektir.
Imap_WatchMore                          a folder to list of watched folders
Imap_WatchedFolder                      Ýzlenilen klasör numarasý

Shutdown_Message                        POPFile kapatýldý

Help_Training                           POPFile'ý ilk kullandýðýnýzda o hiçbir bilgiye sahip deðildir ve eðitime ihtiyacý vardýr. POPFile her kategori için mesajlar ile eðitilmelidir. Eðitim, POPFile bir mesajý yanlýþ sýnýflandýrdýðýnda bunu doðru kategori ile tekrar sýnýflandýrarak gerçekleþtirilir. Bunun dýþýnda, posta programýnýzýn mesajlarý POPFile'ýn sýnýflandýrmasýna göre filtrelemesi için ayarlamalýsýnýz. Posta programýnýzýn filtelerini ayarlamak hakkýnda bilgi <a href="http://popfile.sourceforge.net/cgi-bin/wiki.pl?FrequentlyAskedQuestions/EmailSorting">POPFile Dökümantasyon Projesi</a> adresinde bulunabilir.
Help_Bucket_Setup                       POPFile, sýnýflandýrýlmamýþ pseudo-kategorisi dýþýnda en az iki kategori gerektirir. POPFile'ý eþsiz yapan, ikiden fazla, istediðiniz sayýda kategoriye sahip olabilmenizdir. Basit bir kurulum, "spam", "kiþisel", ve "iþ" kategorileri gibi olabilir.
Help_No_More                            Bunu bir daha gösterme 
