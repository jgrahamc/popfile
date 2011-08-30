# Copyright (c) 2001-2011 John Graham-Cumming
#
# 2005/08/09 Translated by David Gimeno i Ayuso <info@sima-pc.com>
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
LanguageCode                            ca
LanguageCharset                         ISO-8859-1
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en

# This is where to find the FAQ on the Wiki
FAQLink                                 faq

# Common words that are used on their own all over the interface
Apply                                   Aplicar
On                                      Actiu
Off                                     Inactiu
TurnOn                                  Activar
TurnOff                                 Desactivar
Add                                     Afegir
Remove                                  Suprimir
Previous                                Anterior
Next                                    Següent
From                                    Des de
Subject                                 Assumpte
Cc                                      Còpia
Classification                          Cistella
Reclassify                              Reclassificar
Probability                             Probabilitat
Scores                                  Barems
QuickMagnets                            Imants ràpids
Undo                                    Desfer
Close                                   Tancar
Find                                    Cercar
Filter                                  Filtre
Yes                                     Sí
No                                      No
ChangeToYes                             Canviar a Sí
ChangeToNo                              Canviar a No
Bucket                                  Cistella
Magnet                                  Imant
Delete                                  Esborrar
Create                                  Crear
To                                      A
Total                                   Total
Rename                                  Redenominar
Frequency                               Freqüència
Probability                             Probabilitat
Score                                   Barem
Lookup                                  Examinar
Word                                    Mot
Count                                   Comptador
Update                                  Actualitzar
Refresh                                 Recarregar
FAQ                                     PMF
ID                                      ID
Date                                    Data
Arrived                                 Rebut
Size                                    Tamany

# This is a regular expression pattern that is used to convert
# a number into a friendly looking number (for the US and UK this
# means comma separated at the thousands)

Locale_Thousands                       .
Locale_Decimal                         '

# The Locale_Date uses the format strings in Perl's Date::Format
# module to set the date format for the UI.  There are two possible
# ways to specify it.
#
# <format>            Just one simple format used for all dates
# <<format> | <format> The first format is used for dates less than
#                     7 days from now, the second for all other dates

Locale_Date                            %d/%m %R%Z | %e/%L/%Y %R%Z

# The header and footer that appear on every UI page
Header_Title                            Centre de control POPFile
Header_Shutdown                         Aturar POPFile
Header_History                          Històric
Header_Buckets                          Cistelles
Header_Configuration                    Configuració
Header_Advanced                         Avançat
Header_Security                         Seguretat
Header_Magnets                          Imants

Footer_HomePage                         Pàgina inicial POPFile
Footer_Manual                           Manual
Footer_Forums                           Fòrums
Footer_FeedMe                           Acaptar
Footer_RequestFeature                   Sol·licitar millora
Footer_MailingList                      Llista de correu
Footer_Wiki                             Documentació

Configuration_Error1                    El caràcter separador ha de ser-ne un de sol
Configuration_Error2                    El port de l'interfície d'usuari ha de ser un número entre 1 i 65535
Configuration_Error3                    El port que rep les connexions POP3 ha de ser un número entre 1 i 65535
Configuration_Error4                    El tamany de pàgina ha de ser un número entre 1 i 1000
Configuration_Error5                    El nombre de dies a l'històric ha de ser un número entre 1 i 366
Configuration_Error6                    El temps d'espera de TCP ha de ser un número entre 10 i 1800
Configuration_Error7                    El port que rep les connexions XML RPC ha de ser un número entre 1 i 65535
Configuration_Error8                    El port intermedi SOCKS V ha de ser un número entre 1 i 65535
Configuration_POP3Port                  Port que rep les connexions POP3
Configuration_POP3Update                S'ha actualitzat el port POP3 a %s; no tindrà efecte fins que reinicieu el POPFile
Configuration_XMLRPCUpdate              S'ha actualitzat el port XML-RPC a %s; no tindrà efecte fins que reinicieu el POPFile
Configuration_XMLRPCPort                Port que rep les connexions XML-RPC
Configuration_SMTPPort                  Port que rep les connexions SMTP
Configuration_SMTPUpdate                S'ha actualitzat el port SMTP a %s; no tindrà efecte fins que reinicieu el POPFile
Configuration_NNTPPort                  Port que rep les connexions NNTP
Configuration_NNTPUpdate                S'ha actualitzat el port NNTP a %s; no tindrà efecte fins que reinicieu el POPFile
Configuration_POPFork                   Permetre connexions concurrents POP3
Configuration_SMTPFork                  Permetre connexions concurrents SMTP
Configuration_NNTPFork                  Permetre connexions concurrents NNTP
Configuration_POP3Separator             Caràcter separador de host:port:user POP3
Configuration_NNTPSeparator             Caràcter separador de host:port:user NNPT
Configuration_POP3SepUpdate             S'ha actualitzat el separador POP3 a %s
Configuration_NNTPSepUpdate             S'ha actualitzat el separador NNTP a %s
Configuration_UI                        Port web d'interfície d'usuari
Configuration_UIUpdate                  S'ha actualitzat el port web d'interfície d'usuari a %s; no tindrà efecte fins que reinicieu el POPFile
Configuration_History                   Nombre de missatges per pàgina
Configuration_HistoryUpdate             S'ha actualitzat el nombre de missatges per pàgina a %s
Configuration_Days                      Nombre de dies a conservar l'històric
Configuration_DaysUpdate                S'ha actualitzat el nombre de dies d'històric a %s
Configuration_UserInterface             Interfície d'usuari
Configuration_Skins                     Aparences
Configuration_SkinsChoose               Trieu aparença
Configuration_Language                  Idioma
Configuration_LanguageChoose            Trieu idioma
Configuration_ListenPorts               Opcions de mòduls
Configuration_HistoryView               Veure històric
Configuration_TCPTimeout                Temps d'espera connexió
Configuration_TCPTimeoutSecs            Temps d'espera connexió en segons
Configuration_TCPTimeoutUpdate          S'ha actualitzat el temps d'espera connexió a %s
Configuration_ClassificationInsertion   Inserció text del missatge
Configuration_SubjectLine               Modificació<br>línia de l'assumpte
Configuration_XTCInsertion              Capçalera<br>X-Text-Classification
Configuration_XPLInsertion              Capçalera<br>X-POPFile-Link
Configuration_Logging                   S'està registrant
Configuration_None                      Cap
Configuration_ToScreen                  A pantalla
Configuration_ToFile                    A fitxer
Configuration_ToScreenFile              A pantalla i fitxer
Configuration_LoggerOutput              Sortida usuari
Configuration_GeneralSkins              Aparences
Configuration_SmallSkins                Aparences petites
Configuration_TinySkins                 Aparences minúscules
Configuration_CurrentLogFile            &lt;Descarregar fitxer de registre actual&gt;
Configuration_SOCKSServer               Servidor intermedi SOCKS V
Configuration_SOCKSPort                 Port intermedi SOCKS V
Configuration_SOCKSPortUpdate           S'ha actualitzat el port intermedi SOCKS V a %s
Configuration_SOCKSServerUpdate         S'ha actualitzat el servidor intermedi SOCKS V a %s
Configuration_Fields                    Columnes històric

Advanced_Error1                         '%s' ja és a la llista de mots a ignorar
Advanced_Error2                         Mots a ignorar només pot contenir caràcters alfanumèrics, ., _, - i @
Advanced_Error3                         afegit '%s' a la llista de mots a ignorar
Advanced_Error4                         '%s' no és a la llista de mots a ignorar
Advanced_Error5                         suprimit '%s' de la llista de mots a ignorar
Advanced_StopWords                      Mots a ignorar
Advanced_Message1                       POPFile ignora els següents mots molt usuals:
Advanced_AddWord                        Afegir mot
Advanced_RemoveWord                     Suprimir mot
Advanced_AllParameters                  Tots els paràmetres POPFile
Advanced_Parameter                      Paràmetre
Advanced_Value                          Valor
Advanced_Warning                        Aquesta és la llista completa de paràmetres de POPFile. Només usuaris avançats: canvieu-los i cliqueu Actualitzar; no se'n comprova la validesa.  Els ítems mostrats en negreta són diferents dels predeterminats.
Advanced_ConfigFile                     Fitxer de configuració:

History_Filter                          &nbsp;(s'està mostrant només la cistella <font color="%s">%s</font>)
History_FilterBy                        Filtrat per
History_Search                          &nbsp;(cercat per Des de/Assumte %s)
History_Title                           Missatges recents
History_Jump                            Anar a la pàgina
History_ShowAll                         Mostrar-ho tot
History_ShouldBe                        Hauria de ser
History_NoFrom                          cap línia Des de
History_NoSubject                       cap línia Assumpte
History_ClassifyAs                      Classificar com a
History_MagnetUsed                      Imant usat
History_MagnetBecause                   <b>Imant usat</b><p>Classificat com a <font color="%s">%s</font> degut a l'imant %s </p>
History_ChangedTo                       S'ha canviat a <font color="%s">%s</font>
History_Already                         Reclassificat com a <font color="%s">%s</font>
History_RemoveAll                       Suprimir-ho tot
History_RemovePage                      Suprimir pàgina
History_RemoveChecked                   Suprimir marcats
History_Remove                          Per suprimir entrades a l'històric, cliqueu
History_SearchMessage                   Cercar Des de/Assumpte
History_NoMessages                      Cap missatge
History_ShowMagnet                      imantat
History_Negate_Search                   Invertir cerca/filtre
History_Magnet                          &nbsp;(s'està mostrant només missatges classificats per imant)
History_NoMagnet                        &nbsp;(s'està mostrant només missatges no classificats per imant)
History_ResetSearch                     Reiniciar
History_ChangedClass                    Ara s'hauria de classificar com a
History_Purge                           Esborrar ara
History_Increase                        Augmentar
History_Decrease                        Reduir
History_Column_Characters               Canviar l'ample de les columnes Des de, A, Còpia i Assumpte
History_Automatic                       Automàtic
History_Reclassified                    Reclassificat
History_Size_Bytes                      %d&nbsp;B
History_Size_KiloBytes                  %.1f&nbsp;KB
History_Size_MegaBytes                  %.1f&nbsp;MB

Password_Title                          Contrasenya
Password_Enter                          Introduïu-hi la contrasenya
Password_Go                             Anar-hi!
Password_Error1                         Contrasenya incorrecta

Security_Error1                         El port ha de ser un número entre 1 i 65535
Security_Stealth                        Mode furtiu/Operació del servidor
Security_NoStealthMode                  No (mode furtiu)
Security_StealthMode                    (Mode furtiu)
Security_ExplainStats                   (Si s'activa, POPFile envia un cop al dia els tres següents valors a un programa a www.usethesource.com: bc, el nombre total de cistelles que teniu; mc, el nombre total de missatges classificats per POPFile, i ec, el nombre total d'errors de classificació. Això s'emmagatzema en un fitxer i serà usat per confeccionar estadístiques d'ús de POPFile i com funciona de bé. El meu servidor web conserva els seus fitxers de registre uns 5 dies i aleshores s'esborren; no emmagatzemo cap connexió entre estadístiques i adreces IP individuals).
Security_ExplainUpdate                  (Si s'activa, POPFile envia un cop per dia els tres següents valors a un programa a www.usethesource.com: ma, el nombre major de versió de la vostra instal·lació POPFile; mi, el nombre menor de versió de la vostra instal·lació POPFile, i bn, el nombre de muntatge de la vostra instal·lació POPFile. POPFile rep una resposta en forma de gràfic que surt dalt de la pàgina, si hi ha una versió nova disponible. El meu servidor web conserva els seus fitxers de registre uns 5 dies i aleshores s'esborren; no emmagatzemo cap connexió entre les verificacions d'actualització i les adreces IP individuals).
Security_PasswordTitle                  Contrasenya d'interfície d'usuari
Security_Password                       Contrasenya
Security_PasswordUpdate                 S'ha actualitzat la contrasenya
Security_AUTHTitle                      Servidors remots
Security_SecureServer                   Servidor POP3 remot (SPA/AUTH o servidor intermedi transparent)
Security_SecureServerUpdate             S'ha actualitzat el servidor POP3 remot a %s
Security_SecurePort                     Port POP3 remot (SPA/AUTH o servidor intermedi transparent)
Security_SecurePortUpdate               S'ha actualitzat el port del servidor POP3 remot a %s
Security_SMTPServer                     Servidor de cadena SMTP
Security_SMTPServerUpdate               S'ha actualitzat el servidor de cadena SMTP a %s; no tindrà efecte fins que reinicieu el POPFile
Security_SMTPPort                       Port de cadena SMTP
Security_SMTPPortUpdate                 S'ha actualitzat el port de cadena SMTP a %s; no tindrà efecte fins que reinicieu el POPFile
Security_POP3                           Acceptar connexions POP3 de màquines remotes (cal reiniciar POPFile)
Security_SMTP                           Acceptar connexions SMTP de màquines remotes (cal reiniciar POPFile)
Security_NNTP                           Acceptar connexions NNTP de màquines remotes (cal reiniciar POPFile)
Security_UI                             Acceptar connexions HTTP (interfície d'usuari) de màquines remotes (cal reiniciar POPFile)
Security_XMLRPC                         Acceptar connexions XML-RPC de màquines remotes (cal reiniciar POPFile)
Security_UpdateTitle                    Comprovació automàtica d'actualitzacions
Security_Update                         Comprovar actualitzacions de POPFile diàriament
Security_StatsTitle                     S'estan informant les estadístiques
Security_Stats                          Enviar les estadístiques diàriament

Magnet_Error1                           Ja existeix l'imant '%s' a la cistella '%s'
Magnet_Error2                           El nou imant '%s' interfereix amb el '%s' de la cistella '%s' i podria donar resultats ambigus.  No s'ha afegit el nou.
Magnet_Error3                           S'ha creat el nou imant '%s' a la cistella '%s'
Magnet_CurrentMagnets                   Imants actuals
Magnet_Message1                         Els imants següents impliquen que un missatge sigui sempre encasellat a la cistella indicada
Magnet_CreateNew                        Crear imant nou
Magnet_Explanation                      <b>Disposeu de tres tipus d'imants:</b> <ul><li><b>Adreça Des de o nom:</b> Per exemple: john@company.com per evitar una adreça específica, <br />company.com per evitar tothom de company.com, <br />John Doe per evitar una persona concreta, John per evitar-los tots</li><li><b>Adreça A/Còpia o nom:</b> Com un imant Des de: però per a l'adressa A:/Còpia: a un missatge</li> <li><b>Mots Assumpte:</b> Per exemple: hello per evitar tots els missatges amb hello a l'assumpte</li></ul>
Magnet_MagnetType                       Tipus d'imant
Magnet_Value                            Valors
Magnet_Always                           Va sempre a la cistella
Magnet_Jump                             Anar a la pàgina d'imants

Bucket_Error1                           Els noms de cistella només poden contenir lletres a a z en minúscules, números 0 a 9, més - i _
Bucket_Error2                           Ja existeix la cistella anomenada %s
Bucket_Error3                           S'ha creat la cistella anomenada %s
Bucket_Error4                           Introduïu-hi algun mot
Bucket_Error5                           Redenominada la cistella %s a %s
Bucket_Error6                           Esborrada la cistella %s
Bucket_Title                            Configuració de cistella
Bucket_BucketName                       Nom de<br>cistella
Bucket_WordCount                        Comptador de mots
Bucket_WordCounts                       Comptadors de mots
Bucket_UniqueWords                      Mots<br>distints
Bucket_SubjectModification              Modificació<br>capçalera assumpte
Bucket_ChangeColor                      Color<br>cistella
Bucket_NotEnoughData                    No hi ha prous dades
Bucket_ClassificationAccuracy           Precisió de la classificació
Bucket_EmailsClassified                 Missatges classificats
Bucket_EmailsClassifiedUpper            Missatges Classificats
Bucket_ClassificationErrors             Errors de classificació
Bucket_Accuracy                         Precisió
Bucket_ClassificationCount              Comptador de classificació
Bucket_ClassificationFP                 Falsos positius
Bucket_ClassificationFN                 Falsos negatius
Bucket_ResetStatistics                  Reiniciar estadístiques
Bucket_LastReset                        Última reinicialització
Bucket_CurrentColor                     El color actual de %s és %s
Bucket_SetColorTo                       S'ha canviat el color de %s a %s
Bucket_Maintenance                      Manteniment
Bucket_CreateBucket                     Crear una cistella de nom
Bucket_DeleteBucket                     Esborrar la cistella anomenada
Bucket_RenameBucket                     Redenominar la cistella anomenada
Bucket_Lookup                           Examinar
Bucket_LookupMessage                    Examinar la paraula a les cistelles
Bucket_LookupMessage2                   Examinar el resultat per
Bucket_LookupMostLikely                 <b>%s</b> és més probable que aparegui a <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> no apareix a cap de les cistelles
Bucket_DisabledGlobally                 Globalment inhabilitat
Bucket_To                               a
Bucket_Quarantine                       Missatge de<br>quarantena

SingleBucket_Title                      Detall de %s
SingleBucket_WordCount                  Comptador de mots de la cistella
SingleBucket_TotalWordCount             Comptador total de mots
SingleBucket_Percentage                 Percentatge del total
SingleBucket_WordTable                  Taula de mots de %s
SingleBucket_Message1                   Cliqueu una lletra a l'índex per veure la llista de mots que hi comencen. Cliqueu qualsevol mot per examinar llur probabilitat per a totes les cistelles.
SingleBucket_Unique                     %s distint
SingleBucket_ClearBucket                Suprimir tots els mots

Session_Title                           La sessió POPFile ha vençut
Session_Error                           La vostra sessió POPFile ha vençut. Això pot ser degut a haver aturat i iniciat POPFile deixant el vostre navegador web obert. Cliqueu un dels enllaços de més amunt per continuar usant POPFile.

View_Title                              Visualització missatge individual
View_ShowFrequencies                    Mostrar freqüències de mot
View_ShowProbabilities                  Mostrar probabilitats de mot
View_ShowScores                         Mostrar barems de mot i diagrama de decisió
View_WordMatrix                         Matriu de mots
View_WordProbabilities                  s'estan mostrant les probabilitats de mot
View_WordFrequencies                    s'estan mostrant les freqüències de mot
View_WordScores                         s'estan mostrant els barems de mot
View_Chart                              Diagrama de decisió

Windows_TrayIcon                        Mostrar la icona POPFile a la safata de sistema del Windows?
Windows_Console                         Executar POPFile a una finestra de consola?
Windows_NextTime                        <p><font color="red">No tindrà efecte fins que reinicieu el POPFile</font>

Header_MenuSummary                      Aquesta taula és el menú de navegació que permet d'accedir a cadascuna de les diferents pàgines del centre de control.
History_MainTableSummary                Aquesta taula mostra el remitent i l'assumpte dels missatges rebuts adés i permet de revisar-los i reclassificar-los. En clicar la línia de l'assumpte es mostrarà el missatge sencer, juntament amb la informació del per què de llur classificació. La columna 'Hauria de ser' us permet d'especificar a quina cistella pertany o de desfer aquest canvi. La columna 'Esborrar' us permet d'esborrar de l'històric missatges específics, si ja no els necessiteu.
History_OpenMessageSummary              Aquesta taula conté el text complet d'un missatge, amb els mots usats a la classificació ressaltats segons la cistella més rellevant de cadascun.
Bucket_MainTableSummary                 Aquesta taula proporciona una ullada de les cistelles de classificació. Cada fila mostra per a cada cistella el nom, el comptador total de mots, el nombre total de mots individuals, si es modificarà la línia d'assumpte en classificar-lo, si es deixaran en quarantena els que es rebin i una taula per seleccionar el color a usar en presentar al centre de control res de relacionat amb ella.
Bucket_StatisticsTableSummary           Aquesta taula proporciona tres jocs d'estadístiques sobre el rendiment general de POPFile. El primer és com d'acurada és la classificació, el segon quants missatges i a quines cistelles s'han classificat i el tercer quants mots hi ha a cada cistella i quins percentatges representen.
Bucket_MaintenanceTableSummary          Aquesta taula conté formularis que us permeten de crear, esborrar o redenominar cistelles o examinar un mot a totes les cistelles per veure quines probabilitats presenta.
Bucket_AccuracyChartSummary             Aquesta taula representa gràficament la precisió de la classificació de missatges.
Bucket_BarChartSummary                  Aquesta taula representa gràficament l'assignació de percentatges a cadascuna de les diferents cistelles. S'usa tant per al nombre de missatges classificats com per als comptadors totals de mots.
Bucket_LookupResultsSummary             Aquesta taula mostra les probabilitats associades a un mot del corpus donat. De cada cistella mostra la freqüència en que esdevé el mot, la probabilitat de que hi aparegui i l'efecte general que té sobre el barem de la cistella si n'hi ha cap en un missatge.
Bucket_WordListTableSummary             Aquesta taula proporciona una llista de tots els mots d'una cistella particular, ordenats per la primera lletra comú a cada fila.
Magnet_MainTableSummary                 Aquesta taula mostra la llista d'imants que s'usen per classificar missatges automàticament segons unes regles fixes. Cada fila mostra com es defineix l'imant, per a quina cistella s'ha fet i un botó per esborrar-lo.
Configuration_MainTableSummary          Aquesta taula conté un nombre de formularis que us permeten de controlar la configuració de POPFile.
Configuration_InsertionTableSummary     Aquesta taula conté els botons que determinen si es fan certes modificacions a les capçaleres o línia d'assumpte del missatge abans no sigui passat al client de correu, o no.
Security_MainTableSummary               Aquesta taula proporciona jocs de controls que afecten la seguretat de la configuració general de POPFile, si s'ha de comprovar automàticament si hi ha actualitzacions del programa i si s'han enviar les estadístiques sobre rendiment del POPFile al magatzem central de l'autor del programa per a informació general.
Advanced_MainTableSummary               Aquesta taula proporciona una llista de mots que POPFile ignora en classificar els missatges atesa llur freqüència relativa als missatges de tota mena. S'ordenen per fila segons llur primera lletra.

Imap_Bucket2Folder                      Els correus de la cistella <b>%s</b> van a la carpeta
Imap_MapError                           No podeu assignar més d'una cistella a una sola carpeta!
Imap_Server                             Nom del servidor IMAP:
Imap_ServerNameError                    Introduïu-hi el nom del servidor!
Imap_Port                               Port del servidor IMAP:
Imap_PortError                          Introduïu-hi un número de port vàlid!
Imap_Login                              Nom del compte IMAP:
Imap_LoginError                         Introduïu-hi un nom d'usuari!
Imap_Password                           Contrasenya del compte IMAP:
Imap_PasswordError                      Introduïu-hi una contrasenya pel servidor!
Imap_Expunge                            Destruir de les carpetes mirades els missatges esborrats.
Imap_Interval                           Interval d'actualització, en segons:
Imap_IntervalError                      Introduïu-hi un interval entre 10 i 3600 segons.
Imap_Bytelimit                          Nombre de bytes per missatge a usar per a la classificació. Introduïu-hi 0 (zero) pel missatge complet:
Imap_BytelimitError                     Introduïu-hi un nombre.
Imap_RefreshFolders                     Recarregar la llista de carpetes
Imap_Now                                ara!
Imap_UpdateError1                       No s'ha pogut entrar. Verifiqueu el nom del compte i la contrasenya.
Imap_UpdateError2                       No s'ha pogut connectar amb el servidor. Comproveu el nom i el port del servidor i assegureu-vos que sou en línia.
Imap_UpdateError3                       Configureu abans els detalls de la connexió.
Imap_NoConnectionMessage                Configureu abans els detalls de la connexió. Després que hi hagueu fet, hi haurà més opcions disponibles.
Imap_WatchMore                          una carpeta a la llista de les carpetes mirades
Imap_WatchedFolder                      Carpeta mirada núm.

Shutdown_Message                        S'ha aturat el POPFile

Help_Training                           Quan useu per primer cop POPFile, no sap res i caldrà una mica d'entrenament. Cal entrenar POPFile per a cada cistella. L'anireu educant cada cop que reclassifiqueu un missatge que POPFile hagi classificat a una cistella incorrecta. També haureu de configurar el vostre client de correu perquè filtri els missatges segons la classificació de POPFile. Podeu trobar informació sobre com configurar el filtratge del vostre client de correu a <a href="http://getpopfile.org/docs/faq/EmailSorting">Projecte de Documentació POPFile</a> (en anglès).
Help_Bucket_Setup                       POPFile necessita al menys dues cistelles a més de la pseudo-cistella 'unclassified'. El que fa únic POPFile és que pot classificar els correus en tantes cistelles com volgueu. Una configuració senzilla pot ser una cistella "spam", una "personal" i una altra "feina".
Help_No_More                            No mostrar-m'ho més
