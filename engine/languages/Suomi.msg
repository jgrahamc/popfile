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
LanguageCode                            fi
LanguageCharset                         ISO-8859-15
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en

# This is where to find the FAQ on the Wiki
FAQLink                                 FrequentlyAskedQuestions

# Common words that are used on their own all over the interface
Apply                                   K&auml;yt&auml;
On                                      P&auml;&auml;ll&auml;
Off                                     Pois p&auml;&auml;lt&auml;
TurnOn                                  Laita p&auml;&auml;lle
TurnOff                                 Laita pois p&auml;&auml;lt&auml;
Add                                     Lis&auml;&auml;
Remove                                  Poista
Previous                                Edellinen
Next                                    Seuraava
From                                    L&auml;hett&auml;j&auml;
Subject                                 Aihe
Cc                                      Kopio
Classification                          Sanko
Reclassify                              Luokittele uudelleen
Probability                             Todenn&auml;k&ouml;isyys
Scores                                  Pistem&auml;&auml;r&auml;t
QuickMagnets                            Pikamagneetit
Undo                                    Peru
Close                                   Sulje
Find                                    Etsi
Filter                                  Suodata
Yes                                     Kyll&auml;
No                                      Ei
ChangeToYes                             Vaihda
ChangeToNo                              Vaihda
Bucket                                  Sanko
Magnet                                  Magneetti
Delete                                  Poista
Create                                  Luo
To                                      Vastaanottaja
Total                                   Yhteens&auml;
Rename                                  Nime&auml; uudelleen
Frequency                               Esiintymistiheys
Probability                             Todenn&auml;k&ouml;isyys
Score                                   Pistem&auml;&auml;r&auml;
Lookup                                  Etsi
Word                                    Sana
Count                                   M&auml;&auml;r&auml;
Update                                  P&auml;ivit&auml;
Refresh                                 Virkist&auml; t&auml;m&auml; sivu
FAQ                                     UKK
ID                                      ID
Date                                    P&auml;iv&auml;ys
Arrived                                 Saapunut
Size                                    Koko

# This is a regular expression pattern that is used to convert
# a number into a friendly looking number (for the US and UK this
# means comma separated at the thousands)

Locale_Thousands                        &nbsp;
Locale_Decimal                          ,

# The Locale_Date uses the format strings in Perl's Date::Format
# module to set the date format for the UI.  There are two possible
# ways to specify it.
#
# <format>            Just one simple format used for all dates
# <<format> | <format> The first format is used for dates less than
#                     7 days from now, the second for all other dates

Locale_Date                             %e.%L.%y %R

# The header and footer that appear on every UI page
Header_Title                            POPFile hallinta
Header_Shutdown                         Sulje POPFile
Header_History                          Viestihistoria
Header_Buckets                          Sangot
Header_Configuration                    Asetukset
Header_Advanced                         Erikoisasetukset
Header_Security                         Turvallisuusasetukset
Header_Magnets                          Magneetit

Footer_HomePage                         POPFilen kotisivu
Footer_Manual                           K&auml;ytt&ouml;ohjeet
Footer_Forums                           Keskustelualueet
Footer_FeedMe                           Ruoki minua!
Footer_RequestFeature                   Pyyd&auml; ominaisuutta
Footer_MailingList                      Postituslista
Footer_Wiki                             Ohjeita (englanninksi)

Configuration_Error1                    Erotinmerkin pit&auml;&auml; olla yksitt&auml;inen merkki
Configuration_Error2                    K&auml;ytt&ouml;liittym&auml;n porttinumero pit&auml;&auml; olla 1 ja 65535 v&auml;lilt&auml;
Configuration_Error3                    POP3-kuunteluportin numero pit&auml;&auml; olla 1 ja 65535 v&auml;lilt&auml;
Configuration_Error4                    Sivun koon pit&auml;&auml; olla 1 ja 1000 v&auml;lilt&auml;
Configuration_Error5                    Historian p&auml;ivien m&auml;&auml;r&auml; pit&auml;&auml; olla 1 ja 366 v&auml;lilt&auml;
Configuration_Error6                    TCP aikakatkaisun pit&auml;&auml; olla 10 ja 300 v&auml;lilt&auml;
Configuration_Error7                    XML RPC:n kuunteluportti pit&auml;&auml; olla 1 ja 65536 v&auml;lilt&auml;.
Configuration_Error8                    SOCKS V -v&auml;lityspalvelimen porttinumeron pit&auml;&auml; olla 1 ja 65535 v&auml;lilt&auml;.
Configuration_POP3Port                  POP3-kuunteluportti
Configuration_POP3Update                POP3-portiksi vaihdettu %s. Muutos ei tule voimaan ennen POPFilen uudelleenk&auml;ynnistyst&auml;.
Configuration_XMLRPCUpdate              XML-RPC-portiksi vaihdettu %s. Muutos ei tule voimaan ennen POPFilen uudelleenk&auml;ynnistyst&auml;.
Configuration_XMLRPCPort                XML-RPC kuunteluportti
Configuration_SMTPPort                  SMTP-kuunteluportti
Configuration_SMTPUpdate                SMTP-portiksi vaihdettu %s. Muutos ei tule voimaan ennen POPFilen uudelleenk&auml;ynnistyst&auml;.
Configuration_NNTPPort                  NNTP-kuunteluportti
Configuration_NNTPUpdate                NNTP-portiksi vaihdettu %s. Muutos ei tule voimaan ennen POPFilen uudelleenk&auml;ynnistyst&auml;.
Configuration_POPFork                   Anna k&auml;ytt&auml;j&auml;n ottaa useita samanaikaisia POP3-yhteyksi&auml;.
Configuration_SMTPFork                  Anna k&auml;ytt&auml;j&auml;n ottaa useita samanaikaisia SMTP-yhteyksi&auml;.
Configuration_NNTPFork                  Anna k&auml;ytt&auml;j&auml;n ottaa useita samanaikaisia NNTP-yhteyksi&auml;.
Configuration_POP3Separator             POP3:n is&auml;nt&auml;:portti:k&auml;ytt&auml;j&auml; erotinmerkki
Configuration_NNTPSeparator             NNTP:n is&auml;nt&auml;:portti:k&auml;ytt&auml;j&auml; erotinmerkki
Configuration_POP3SepUpdate             POP3-erotinmerkiksi vaihdettu %s
Configuration_NNTPSepUpdate             NNTP-erotinmerkiksi vaihdettu %s
Configuration_UI                        K&auml;ytt&ouml;liittym&auml;n porttinumero
Configuration_UIUpdate                  K&auml;ytt&ouml;liittym&auml;n porttinumeroksi vaihdettu %s. Muutos ei tule voimaan ennen POPFilen uudelleenk&auml;ynnistyst&auml;.
Configuration_History                   Viestien m&auml;&auml;r&auml; sivua kohti
Configuration_HistoryUpdate             Viestien m&auml;&auml;r&auml;ksi sivua kohti vaihdettu %s
Configuration_Days                      Viestihistorian p&auml;ivien lukum&auml;&auml;r&auml;
Configuration_DaysUpdate                Viestihistorian p&auml;ivien lukum&auml;&auml;r&auml;ksi asetettu %s p&auml;iv&auml;&auml;
Configuration_UserInterface             K&auml;ytt&ouml;liittym&auml;
Configuration_Skins                     Ulkon&auml;k&ouml;asetukset
Configuration_SkinsChoose               Valitse ulkon&auml;k&ouml;
Configuration_Language                  Kieliasetukset
Configuration_LanguageChoose            Valitse kieli
Configuration_ListenPorts               Moduulin Asetukset
Configuration_HistoryView               Viestihistoria
Configuration_TCPTimeout                Yhteyden aikakatkaisu
Configuration_TCPTimeoutSecs            Yhteyden aikakatkaisu sekunteina
Configuration_TCPTimeoutUpdate          Yhteyden aikakatkaisuksi asetettu %s sekuntia
Configuration_ClassificationInsertion   Viestitekstin lis&auml;ys
Configuration_SubjectLine               Aiherivin<br>muuttaminen
Configuration_XTCInsertion              X-Text-Classification<br>-otsikon lis&auml;ys
Configuration_XPLInsertion              X-POPFile-Link<br>-otsikon lis&auml;ys
Configuration_Logging                   Loki
Configuration_None                      Pois p&auml;&auml;lt&auml;
Configuration_ToScreen                  Ruudulle
Configuration_ToFile                    Tiedostoon
Configuration_ToScreenFile              Ruudulle ja tiedostoon
Configuration_LoggerOutput              Kirjaus
Configuration_GeneralSkins              Tavalliset
Configuration_SmallSkins                Pienet
Configuration_TinySkins                 Todella pienet
Configuration_CurrentLogFile            &lt;Imuroi t&auml;m&auml;nhetkinen lokitiedosto&gt;
Configuration_SOCKSServer               SOCKS V -v&auml;lityspalvelimen osoite
Configuration_SOCKSPort                 SOCKS V -v&auml;lityspalvelimen portti
Configuration_SOCKSPortUpdate           SOCKS V -v&auml;lityspalvelimen portiksi vaihdettu %s
Configuration_SOCKSServerUpdate         SOCKS V -v&auml;lityspalvelimen osoitteeksi vaihdettu %s
Configuration_Fields                    Viestihistorian sarakkeet

Advanced_Error1                         Sana '%s' on jo huomiotta j&auml;tett&auml;vien sanojen listassa
Advanced_Error2                         Huomiotta j&auml;tett&auml;v&auml;t sanat voivat sis&auml;lt&auml;&auml; vain kirjaimia ja numeroita sek&auml; seuraavia merkkej&auml;: &quot;._-@&quot;
Advanced_Error3                         Sana '%s' lis&auml;tty huomiotta j&auml;tett&auml;vien sanojen listaan
Advanced_Error4                         Sana '%s' ei ole huomiotta j&auml;tett&auml;vien sanojen listassa
Advanced_Error5                         Sana '%s' poistettu huomiotta j&auml;tett&auml;vien sanojen listasta
Advanced_StopWords                      Huomiotta j&auml;tett&auml;v&auml;t sanat
Advanced_Message1                       Seuraavia sanoja ei oteta huomioon viestien luokittelussa siksi koska ne esiintyv&auml;t niin usein.
Advanced_AddWord                        Lis&auml;&auml; sana
Advanced_RemoveWord                     Poista sana
Advanced_AllParameters                  Kaikki POPFilen Parametrit
Advanced_Parameter                      Parametri
Advanced_Value                          Arvo
Advanced_Warning                        T&auml;m&auml; on t&auml;ydellinen lista POPFilen k&auml;ytt&auml;mist&auml; parametreist&auml;. Vaihda arvoja vain jos tied&auml;t mit&auml; teet. Annetun tiedon oikeellisuutta ei tarkisteta. Lihavoitujen kohtien asetukset poikkeavat oletusasetuksista.
Advanced_ConfigFile                     Asetustiedosto:

History_Filter                          &nbsp;(N&auml;kyviss&auml; vain sangon <font color=&quot;%s&quot;>%s</font> sis&auml;lt&ouml;)
History_FilterBy                        N&auml;yt&auml; vain
History_Search                          &nbsp;(Etsitty kohdetta %s)
History_Title                           Viimeaikaiset viestit
History_Jump                            Siirry sivulle
History_ShowAll                         N&auml;yt&auml; kaikki
History_ShouldBe                        Pit&auml;isi olla
History_NoFrom                          Ei l&auml;hett&auml;j&auml;tietoa
History_NoSubject                       Ei aihetta
History_ClassifyAs                      Luokittele
History_MagnetUsed                      K&auml;ytetty magneettia
History_MagnetBecause                   <b>Magneettia k&auml;ytetty</b><p>Viesti luokiteltu sankoon <font color=&quot;%s&quot;>%s</font> magneetilla %s</p>
History_ChangedTo                       Luokitukseksi vaihdettu <font color="%s">%s</font>
History_Already                         Luokitus vaihdettu sankoon <font color=&quot;%s&quot;>%s</font>
History_RemoveAll                       Poista kaikki
History_RemovePage                      Poista sivu
History_RemoveChecked                   Poista merkityt
History_Remove                          Paina t&auml;st&auml; poistaaksesi n&auml;m&auml; viestit viestihistoriasta
History_SearchMessage                   Etsi l&auml;hett&auml;jien ja aiheiden joukosta
History_NoMessages                      Ei viestej&auml;
History_ShowMagnet                      magneeteilla luokitellut
History_Negate_Search                   K&auml;&auml;nn&auml; haku/suodatin
History_Magnet                          &nbsp;(N&auml;kyviss&auml; vain magneeteilla luokitellut viestit)
History_NoMagnet                        &nbsp;(N&auml;kyviss&auml; vain magneeteilla luokittelemattomat viestit)
History_ResetSearch                     Peruuta
History_ChangedClass                    Luokiteltaisiin nyt sankoon
History_Purge                           Poista nyt
History_Increase                        Kasvata
History_Decrease                        Pienenn&auml;
History_Column_Characters               Vaihda l&auml;hett&auml;j&auml;- vastaanottaja- kopio- ja aihekenttien leveytt&auml;
History_Automatic                       Automaattinen
History_Reclassified                    Luokitusta vaihdettu
History_Size_Bytes                      %d&nbsp;T
History_Size_KiloBytes                  %.1f&nbsp;kT
History_Size_MegaBytes                  %.1f&nbsp;MT

Password_Title                          Salasana
Password_Enter                          Sy&ouml;t&auml; salasana
Password_Go                             Hyv&auml;ksy
Password_Error1                         V&auml;&auml;r&auml; salasana

Security_Error1                         Portti pit&auml;&auml; olla 1 ja 65535 v&auml;lilt&auml;
Security_Stealth                        Piilotila/Palvelintoiminta
Security_NoStealthMode                  Ei (Piilotila)
Security_StealthMode                    (Piilotila)
Security_ExplainStats                   Kun t&auml;m&auml; asetus on p&auml;&auml;ll&auml;, POPFile l&auml;hett&auml;&auml; kerran p&auml;iv&auml;ss&auml; seuraavat kolme arvoa osoitteeseen www.usethesource.com: bc (sankojen kokonaism&auml;&auml;r&auml;), mc (POPFilen luokittelemien viestien m&auml;&auml;r&auml;) ja ec (luokitteluvirheiden m&auml;&auml;r&auml;). N&auml;it&auml; tietoja k&auml;ytet&auml;&auml;n POPFilen k&auml;ytt&ouml;tavoista ja toimintatarkkuudesta kertovien tilastojen laatimiseen. Webpalvelin s&auml;ilytt&auml;&auml; lokitiedostoja noin 5:n p&auml;iv&auml;n ajan, jonka j&auml;lkeen ne poistetaan. Mink&auml;&auml;nlaista tietoa tilastojen ja IP-osoitteiden v&auml;lill&auml; ei s&auml;ilytet&auml;.
Security_ExplainUpdate                  Kun t&auml;m&auml; asetus on p&auml;&auml;ll&auml;, POPFile l&auml;hett&auml;&auml; kerran p&auml;iv&auml;ss&auml; seuraavat kolme arvoa osoitteeseen www.usethesource.com: ma (POPFilen iso versionumero), mi (POPFilen pieni versionumero) ja bn (POPFilen k&auml;&auml;nn&ouml;snumero). POPFile saa vastauksen kuvana, joka n&auml;kyy sivun yl&auml;laidassa, kun uusi versio on saatavilla. Webpalvelin s&auml;ilytt&auml;&auml; lokitiedostoja noin 5:n p&auml;iv&auml;n ajan, jonka j&auml;lkeen ne poistetaan. Mink&auml;&auml;nlaista tietoa p&auml;ivitystarkistusten ja IP-osoitteiden v&auml;lill&auml; ei s&auml;ilytet&auml;.
Security_PasswordTitle                  K&auml;ytt&ouml;liittym&auml;n salasana
Security_Password                       Salasana
Security_PasswordUpdate                 Salasana vaihdettu
Security_AUTHTitle                      Et&auml;palvelimet
Security_SecureServer                   POP3 et&auml;palvelin (SPA/AUTH tai n&auml;kym&auml;t&ouml;n v&auml;lityspalvelin)
Security_SecureServerUpdate             POP3 et&auml;palvelimeksi vaihdettu %s.
Security_SecurePort                     POP3 et&auml;portti (SPA/AUTH tai n&auml;kym&auml;t&ouml;n v&auml;lityspalvelin)
Security_SecurePortUpdate               POP3 et&auml;portiksi vaihdettu %s.
Security_SMTPServer                     SMTP-ketjupalvelin
Security_SMTPServerUpdate               SMTP-ketjupalvelimeksi vaihdettu %s. Muutos ei tule voimaan ennen POPFilen uudelleenk&auml;ynnistyst&auml;.
Security_SMTPPort                       SMTP-ketjuportti
Security_SMTPPortUpdate                 SMTP-ketjuportiksi vaihdettu %s. Muutos ei tule voimaan ennen POPFilen uudelleenk&auml;ynnistyst&auml;.
Security_POP3                           Hyv&auml;ksy POP3-yhteydet muilta koneilta (Vaatii POPFilen uudelleenk&auml;ynnistyksen)
Security_SMTP                           Hyv&auml;ksy SMTP-yhteydet muilta koneilta (Vaatii POPFilen uudelleenk&auml;ynnistyksen)
Security_NNTP                           Hyv&auml;ksy NNTP-yhteydet muilta koneilta (Vaatii POPFilen uudelleenk&auml;ynnistyksen)
Security_UI                             Hyv&auml;ksy HTTP-yhteydet (POPFilen hallinta) muilta koneilta (Vaatii POPFilen uudelleenk&auml;ynnistyksen)
Security_XMLRPC                         Hyv&auml;ksy XML-RPC-yhteydet muilta koneilta (Vaatii POPFilen uudelleenk&auml;ynnistyksen)
Security_UpdateTitle                    Automaattinen p&auml;ivitystarkistus
Security_Update                         Tarkista p&auml;ivitt&auml;in onko POPFilest&auml; tullut uutta versiota.
Security_StatsTitle                     Tilastotietojen raportointi
Security_Stats                          L&auml;het&auml; p&auml;ivitt&auml;in tilastotietoja Johnille.

Magnet_Error1                           Magneetti '%s' on jo sangossa '%s'
Magnet_Error2                           Uusi magneeetti '%s' on ristiriidassa magneetin '%s' kanssa sangossa '%s' ja voisi aiheuttaa ristiriitaisia tuloksia. Magneettia ei lis&auml;tty.
Magnet_Error3                           Uusi magneetti, '%s', luotu sankoon '%s'.
Magnet_CurrentMagnets                   T&auml;m&auml;nhetkiset magneetit
Magnet_Message1                         Seuraavat magneetit aiheuttavat sen, ett&auml; viestit luokitellaan aina m&auml;&auml;riteltyyn sankoon.
Magnet_CreateNew                        Luo uusi magneetti
Magnet_Explanation                      <b>On olemassa seuraavanlaisia magneetteja:</b> <ul><li><b>L&auml;hett&auml;j&auml;n osoite tai nimi:</b> esimerkiksi &quot;erkki@esimerkki.fi&quot; yksitt&auml;ist&auml; osoitetta varten, <br />&quot;esimerkki.fi&quot; kaikkia niit&auml; varten, joiden osoite p&auml;&auml;ttyy &quot;esimerkki.fi&quot;, <br />&quot;Erkki Esimerkki&quot; yksitt&auml;ist&auml; henkil&ouml;&auml; varten ja &quot;Erkki&quot; kaikkia Erkkej&auml; varten</li><li><b>Vastaanottajan osoite tai nimi/Kopio:</b> Samalla tavoin kuin l&auml;hett&auml;j&auml;magneettien kanssa, mutta vastaanottajien/kopion saavien osoitteiden kanssa</li><li><b>Sanat aiheessa:</b> esimerkiksi &quot;heipparallaa&quot; kaikkia sellaisia viestej&auml; varten, joiden aiherivill&auml; on sana &quot;heipparallaa&quot;.</li></ul>
Magnet_MagnetType                       Magneetin tyyppi
Magnet_Value                            arvot
Magnet_Always                           laitetaan aina sankoon
Magnet_Jump                             Siirry sivulle

Bucket_Error1                           Sangon nimess&auml; saa olla ainoastaan pieni&auml; kirjaimia a:sta z:aan, numeroita, sek&auml; merkkej&auml; &quot;-&quot; ja &quot;_&quot;
Bucket_Error2                           Sanko nimelt&auml; %s on jo olemassa
Bucket_Error3                           Luotiin sanko nimelt&auml; %s
Bucket_Error4                           Sangon nimess&auml; pit&auml;&auml; olla joitakin merkkej&auml;
Bucket_Error5                           Vaihdettiin sangon %s nimeksi %s
Bucket_Error6                           Poistettiin sanko %s
Bucket_Title                            Sankojen asetukset
Bucket_BucketName                       Sangon<br>nimi
Bucket_WordCount                        Sanam&auml;&auml;r&auml;
Bucket_WordCounts                       Sanam&auml;&auml;r&auml;t
Bucket_UniqueWords                      Erillisi&auml;<br>sanoja
Bucket_SubjectModification              Aiherivin<br>muuttaminen
Bucket_ChangeColor                      Sangon<br>v&auml;ri
Bucket_NotEnoughData                    Ei tarpeeksi tietoa
Bucket_ClassificationAccuracy           Luokittelutarkkuus
Bucket_EmailsClassified                 Viestej&auml; luokiteltu
Bucket_EmailsClassifiedUpper            Viestej&auml; luokiteltu
Bucket_ClassificationErrors             Luokitteluvirheit&auml;
Bucket_Accuracy                         Tarkkuus
Bucket_ClassificationCount              Luokittelum&auml;&auml;r&auml;t
Bucket_ClassificationFP                 V&auml;&auml;r&auml;t positiiviset
Bucket_ClassificationFN                 V&auml;&auml;r&auml;t negatiiviset
Bucket_ResetStatistics                  Nollaa tilastot
Bucket_LastReset                        Viime nollaus
Bucket_CurrentColor                     Sangon %s t&auml;m&auml;nhetkinen v&auml;ri on %s
Bucket_SetColorTo                       Aseta sangon %s v&auml;riksi %s
Bucket_Maintenance                      Yll&auml;pito
Bucket_CreateBucket                     Luo sanko nimelt&auml;
Bucket_DeleteBucket                     Poista sanko nimelt&auml;
Bucket_RenameBucket                     Muuta sangon
Bucket_Lookup                           Etsint&auml;
Bucket_LookupMessage                    Etsi sanaa sangoista
Bucket_LookupMessage2                   Etsint&auml;tulos sanalle
Bucket_LookupMostLikely                 Sana <b>%s</b> kuuluu todenn&auml;k&ouml;isimmin sankoon <font color=&quot;%s&quot;>%s</font>
Bucket_DoesNotAppear                    <p>Sanaa <b>%s</b> ei ole miss&auml;&auml;n sangossa
Bucket_DisabledGlobally                 Poistettu yleisesti k&auml;yt&ouml;st&auml;
Bucket_To                               nimeksi
Bucket_Quarantine                       Karanteeni

SingleBucket_Title                      Sangon %s tarkemmat tiedot
SingleBucket_WordCount                  Sangon sanam&auml;&auml;r&auml;
SingleBucket_TotalWordCount             Sanojen kokonaism&auml;&auml;r&auml;
SingleBucket_Percentage                 Osuus kokonaism&auml;&auml;r&auml;st&auml;
SingleBucket_WordTable                  Sanataulukko sangolle nimelt&auml; %s
SingleBucket_Message1                   T&auml;hdell&auml; (*) merkittyj&auml; sanoja on k&auml;ytetty luokitteluun t&auml;m&auml;n istunnon aikana. Napsauta sanaa n&auml;hd&auml;ksesi sen esiintymistodenn&auml;k&ouml;isyyden kaikissa sangoissa.
SingleBucket_Unique                     %s erillist&auml; sanaa
SingleBucket_ClearBucket                Poista kaikki sanat

Session_Title                           POPFile-istunto vanhentunut
Session_Error                           POPFile-instuntosi on vanhentunut. T&auml;m&auml; voi johtua siit&auml;, ett&auml; olet k&auml;ynnist&auml;nyt POPFilen uudelleen niin, ett&auml; selaimesi oli p&auml;&auml;ll&auml;. Napsauta ylh&auml;&auml;ll&auml; olevia linkkej&auml; jatkaaksesi POPFilen k&auml;ytt&ouml;&auml;.

View_Title                              Yksitt&auml;isen viestin n&auml;kym&auml;
View_ShowFrequencies                    N&auml;yt&auml; sanojen esiintymistiheys
View_ShowProbabilities                  N&auml;yt&auml; sanojen esiintymistodenn&auml;k&ouml;isyydet
View_ShowScores                         N&auml;yt&auml; sanojen pistem&auml;&auml;r&auml;t ja p&auml;&auml;t&ouml;ksentekokaavio
View_WordMatrix                         Sanamatriisi
View_WordProbabilities                  n&auml;yt&ouml;ss&auml; sanojen esiintymistodenn&auml;k&ouml;isyydet
View_WordFrequencies                    n&auml;yt&ouml;ss&auml; sanojen esiintymistiheys
View_WordScores                         n&auml;yt&ouml;ss&auml; sanojen pistem&auml;&auml;r&auml;t
View_Chart                              P&auml;&auml;t&ouml;ksentekokaavio

Windows_TrayIcon                        N&auml;ytet&auml;&auml;nk&ouml; POPFilen kuvake Windowsin teht&auml;v&auml;palkissa?
Windows_Console                         Ajetaanko POPFile komentokehoitteessa?
Windows_NextTime                        <p><font color="red">T&auml;m&auml; muutos ei tule voimaan ennen POPFilen uudelleenk&auml;ynnistyst&auml;</font>

Header_MenuSummary                      T&auml;ss&auml; taulukossa on navigointivalikko jonka avulla voit k&auml;ytt&auml;&auml; POPFilen hallinnan eri sivuja.
History_MainTableSummary                T&auml;ss&auml; taulukossa n&auml;kyy viime aikoina saapuneiden viestien l&auml;hett&auml;j&auml;t ja aiheet. Viestej&auml; voi sen avulla tutkia ja uudelleenluokitella. Aiherivin napsautuksella n&auml;kyy koko vietin teksti, sek&auml; tietoa siit&auml; miksi viesti luokiteltiin niin kuin luokiteltiin. &quot;Pit&auml;isi olla&quot;-sarakkeen avulla voit kertoa mihin sankoon viesti kuuluu, tai kumoa muutoksen. Poista-sarakkeen avulla voit poistaa yksitt&auml;isi&auml; viestej&auml; viestihistoriasta, jos et tarvitse niit&auml; en&auml;&auml;.
History_OpenMessageSummary              T&auml;ss&auml; taulukossa n&auml;kyy viestin koko teksti niin, ett&auml; luokitteluun k&auml;ytetyt sanat on korostettu sen mukaan mihin sankoon sana todenn&auml;k&ouml;isimmin kuuluu.
Bucket_MainTableSummary                 T&auml;ss&auml; taulukossa n&auml;kyy yleiskuva luokittelusangoista. Joka rivi n&auml;ytt&auml;&auml; sangon nimen, sangon sanam&auml;&auml;r&auml;n, yksitt&auml;isten sanojen m&auml;&auml;r&auml;n, muutetaanko viestin otsikkoa, jos se luokitellaan sankoon, laitetaanko sankoon kuuluvat viestit karanteeniin, sek&auml; sankoon viitatessa k&auml;ytett&auml;v&auml;n v&auml;rin.
Bucket_StatisticsTableSummary           T&auml;ss&auml; taulukossa on kolme tilastoa jtka kuvaavat POPFilen tehokkuutta. Ensimm&auml;inen kertoo luokittelutarkkuuden, toinen montako vieti&auml; on luokiteltu ja mihin sankoihin, ja kolmas kertoo montako sanaa kussakin sangossa on, ja montako prosenttia sangon sanojen m&auml;&auml;r&auml; on kaikista sanoista.
Bucket_MaintenanceTableSummary          T&auml;ss&auml; taulukossa on lomakkeita, joiden avulla voit luoda, poistaa ja nimet&auml; sankoja ja etsi&auml; sanaa kaikista sangoista ja tarkastaa sen todenn&auml;k&ouml;isyys niiss&auml;.
Bucket_AccuracyChartSummary             T&auml;ss&auml; taulukossa n&auml;kuu luokittelutarkkuus graafisesti.
Bucket_BarChartSummary                  T&auml;ss&auml; taulukossa n&auml;kyy eri sankojen osuudet kokonaisuudesta. Sit&auml; k&auml;ytet&auml;&auml;n sek&auml; luokiteltujen viestien m&auml;&auml;r&auml;n esitt&auml;miseen, ett&auml; sanam&auml;&auml;rien esitt&auml;miseen.
Bucket_LookupResultsSummary             T&auml;ss&auml; taulukossa n&auml;kyy sanan esiintymistodenn&auml;k&ouml;isyys kaikissa sanakirjoissa. Se n&auml;ytt&auml;&auml; joka sankoa kohden sanan esiintymistiheyden ja -todenn&auml;k&ouml;isyyden, sek&auml; sanan pistem&auml;&auml;r&auml;n mik&auml;li se esiintyy viestiss&auml;.
Bucket_WordListTableSummary             T&auml;ss&auml; taulukossa on sangon sanalista. Lista on j&auml;rjestetty etukirjaimen mukaan.
Magnet_MainTableSummary                 T&auml;ss&auml; taulukossa n&auml;kyy viestien kiinte&auml;&auml;n luokitteluun k&auml;ytettyjen magneettien lista. Joka rivill&auml; n&auml;kyy miten magneetti on m&auml;&auml;ritelty, mihin sankoon se on tarkoitettu, ja nappi magneetin poistoa varten.
Configuration_MainTableSummary          T&auml;ss&auml; taulukossa on lomakkeita POPFilen asetusten muuttamiseen.
Configuration_InsertionTableSummary     T&auml;ss&auml; taulukossa on nappeja, joiden avulla m&auml;&auml;ritell&auml;&auml; muutetanko vietin otsikkotietoja tai aihetta ennen kuin se annetaan email-ohjelmalle.
Security_MainTableSummary               T&auml;ss&auml; taulukossa on s&auml;&auml;t&ouml;j&auml;, joilla voit vaikuttaa POPFilen turvallisuusasetuksiin, saako POPFile tarkistaa onko uusi versio ilmestynyt, ja saako POPFilen toiminnasta kertovia tilastoja l&auml;hett&auml;&auml; ohjelman tekij&auml;n keskustietokantaan.
Advanced_MainTableSummary               T&auml;ss&auml; taulukossa on lista sanoista, jotka POPFile j&auml;tt&auml;&auml; huomiotta niiden yleisyyden takia. Ne on j&auml;rjestetty aakkosj&auml;rjestykseen.

Imap_Bucket2Folder                      Sangon <b>%s</b> viestit menev&auml;t kansioon
Imap_MapError                           Hakemistoa kohti voi asettaa vain yhden sangon.
Imap_Server                             IMAP-palvelimen osoite:
Imap_ServerNameError                    T&auml;yt&auml; palvelimen osoite.
Imap_Port                               IMAP-palvelimen portti:
Imap_PortError                          T&auml;yt&auml; palvelimen portti.
Imap_Login                              IMAP-tilin tunnus:
Imap_LoginError                         T&auml;yt&auml; k&auml;ytt&auml;j&auml;tunnus.
Imap_Password                           IMAP-tilin salasana:
Imap_PasswordError                      T&auml;yt&auml; palvelimen salasana.
Imap_Expunge                            Poista viestit vahdituista kansioista.
Imap_Interval                           P&auml;ivitysv&auml;li sekunneissa.
Imap_IntervalError                      T&auml;yt&auml; p&auml;ivitysv&auml;li 10 ja 3600 sekunnin v&auml;lilt&auml;.
Imap_Bytelimit                          Luokitteluun k&auml;ytett&auml;v&auml; tavum&auml;&auml;r&auml;. Kirjoita 0 (nolla), jos haluat k&auml;ytt&auml;&auml; koko viesti&auml;:
Imap_BytelimitError                     T&auml;yt&auml; numero.
Imap_RefreshFolders                     P&auml;ivit&auml; kansiolista.
Imap_Now                                nyt
Imap_UpdateError1                       Kirjautuminen ep&auml;onnistui. Tarkista tunnus ja salasana.
Imap_UpdateError2                       Yhteydenotto palvelimeen ep&auml;onnistui. Tarkista osoite ja porttinumero ja varmista, ett&auml; internetyhteys on avattu.
Imap_UpdateError3                       T&auml;yt&auml; ensin yhteydenmuodostusasetukset.
Imap_NoConnectionMessage                T&auml;yt&auml; ensin yhteydenmuodostusasetukset. Sivulle ilmestyy  sen j&auml;lkeen lis&auml;asetuksia.
Imap_WatchMore                          kansio vahdittujen kansioiden listaan
Imap_WatchedFolder                      Vahdittu kansio no

Shutdown_Message                        POPFile on sammutettu

Help_Training                           Kun k&auml;yt&auml;t POPFile&auml; ensimm&auml;ist&auml; kertaa, se ei tied&auml; mit&auml;&auml;n ja vaatii opetusta. POPFilelle pit&auml;&auml; opettaa milt&auml; eri sankojen viestit n&auml;ytt&auml;v&auml;t. POPFile oppii, kun korjaat sen tekemi&auml; virheit&auml; luokittelemalla v&auml;&auml;rin luokitellut viestit oikeaan sankoon. Lis&auml;ksi sinun pit&auml;&auml; lis&auml;t&auml; k&auml;ytt&auml;m&auml;&auml;si s&auml;hk&ouml;postiohjelmaan suodattimia, joka suodattavat viestit POPFilen luokitusten mukaan. Englanninkielist&auml; apua suodatinten tekoon l&ouml;ytyy <a href="http://popfile.sourceforge.net/cgi-bin/wiki.pl?FrequentlyAskedQuestions/EmailSorting">POPFilen dokumentointiprojektista</a>.
Help_Bucket_Setup                       POPFile vaatii v&auml;hint&auml;&auml;n kaksi sankoa unclassified (luokittelematon) -nimisen pseudosangon lis&auml;ksi. POPFile voi kuitenkin luokitella viestit hienojakoisemminkin. Sankojen m&auml;&auml;r&auml;&auml; ei ole rajoitettu. Voit k&auml;ytt&auml;&auml; esimerkiksi sankoja "roskapostit", "yksityiset" ja "ty&ouml;asiat".
Help_No_More                            &Auml;l&auml; n&auml;yt&auml; t&auml;t&auml; viesti&auml; en&auml;&auml;