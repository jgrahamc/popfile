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
LanguageCode                            es
LanguageCharset                         ISO-8859-1

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en

# Common words that are used on their own all over the interface
Apply                                   Aplicar
On                                      Activado
Off                                     Desactivado
TurnOn                                  Activar
TurnOff                                 Desactivar
Add                                     Añadir
Remove                                  Borrar
Previous                                Anterior
Next                                    Siguiente
From                                    De
Subject                                 Asunto
Classification                          Clasificación
Reclassify                              Reclasificar
Undo                                    Deshacer
Close                                   Cerrar
Find                                    Encontrar
Filter                                  Filtro
Yes                                     Si
No                                      No
ChangeToYes                             Cambiar a si
ChangeToNo                              Cambiar a No
Bucket                                  Categoría
Magnet                                  Imán
Delete                                  Borrar
Create                                  Crear
To                                      A
Total                                   Total
Rename                                  Renombrar
Frequency                               Frecuencia
Probability                             Probabilidad
Score                                   Puntuación
Scores                                  Puntuaciones
Lookup                                  Búsqueda
Cc                                      Cc
Count                                   Contadas
Word                                    Palabra
Refresh                                 Recargar
Update                                  Actualizar
QuickMagnets                            Iman Rapido


# The header and footer that appear on every UI page
Header_Title                            Centro de Control POPFile
Header_Shutdown                         Cerrar POPFile
Header_History                          Historia
Header_Buckets                          Categorías
Header_Configuration                    Configuración
Header_Advanced                         Avanzada
Header_Security                         Seguridad
Header_Magnets                          Imanes

Footer_HomePage                         Web de POPFile
Footer_Manual                           Manual
Footer_Forums                           Foros
Footer_FeedMe                           Donar
Footer_RequestFeature                   Petición de Característica
Footer_MailingList                      Lista de Correo

Configuration_Error1                    El caracter separador debe ser sólo un caracter
Configuration_Error2                    El puerto de la interfaz de usuario debe ser un número entre 1 y 65535
Configuration_Error3                    El puerto de escucha POP3 debe ser un número entre 1 and 65535
Configuration_Error4                    El tamaño de página debe ser un número entre 1 y 1000
Configuration_Error5                    El número de días en la Historia debe ser un número entre 1 and 366
Configuration_Error6                    El tiempo límite de TCP debe ser un número entre 10 y 300
Configuration_Error7                    El puerto de XML RPC debe ser un número entre 1 y 65535
Configuration_POP3Port                  Puerto de escucha POP3
Configuration_POP3Update                Actualizado el puerto POP3 a %s; Este cámbio no tendrá efecto hasta que POPFile sea reiniciado
Configuration_UI                        Puerto de la interfaz de usuario
Configuration_UIUpdate                  Puerto de la interfaz de usuario actualizado a %s; Este cámbio no tendrá efecto hasta que POPFile sea reiniciado
Configuration_History                   Número de mensajes por página
Configuration_HistoryUpdate             Número de mensajes por página actualizado a %s
Configuration_Days                      Número de días a guardar en la historia
Configuration_DaysUpdate                Número de días a guardar en la historia actualizado a %s
Configuration_UserInterface             Interfaz de usuario
Configuration_Skins                     Skins
Configuration_SkinsChoose               Elegir skin
Configuration_Language                  Languaje
Configuration_LanguageChoose            Escoger languaje
Configuration_ListenPorts               Opciones del módulo
Configuration_HistoryView               Vista de la Historia
Configuration_TCPTimeout                Tiempo límite de la conexión 
Configuration_TCPTimeoutSecs            Tiempo límite de la conexión  en segundos
Configuration_TCPTimeoutUpdate          Tiempo límite de la conexión  actualizado a %s
Configuration_ClassificationInsertion   Inserción de la Clasificación
Configuration_SubjectLine               Modificación del Asunto
Configuration_XTCInsertion              Añadir cabecera X-Text-Classification
Configuration_XPLInsertion              Añadir cabecera X-POPFile-Link
Configuration_Logging                   Logging
 Configuration_CurrentLogFile           &lt;fichero actual de log&gt;
Configuration_None                      Ninguna
Configuration_ToScreen                  En pantalla
Configuration_ToFile                    En un fichero
Configuration_ToScreenFile              En pantalla y fichero
Configuration_LoggerOutput              Salida del Logger
Configuration_GeneralSkins              Skins
Configuration_SmallSkins                Small Skins
Configuration_TinySkins                 Tiny Skins
Configuration_NNTPPort                  Puerto de escucha NNTP
Configuration_NNTPSepUpdate             Caracter separador NNTP actualizado a %s
Configuration_NNTPSeparator             Caracter separador en servidor:puerto:usuario para NNTP
Configuration_NNTPUpdate                Actualizado el puerto NNTP a %s; Este cámbio no tendrá efecto hasta que POPFile sea reiniciado
Configuration_POP3SepUpdate             Caracter separador POP3 actualizado a %s
Configuration_POP3Separator             Caracter separador en servidor:puerto:usuario para POP3
Configuration_SMTPPort                  Puerto de escucha SMTP
Configuration_SMTPUpdate                Actualizado el puerto SMTP a %s; Este cámbio no tendrá efecto hasta que POPFile sea reiniciado
Configuration_XMLRPCPort                Puerto de escucha XML RPC
Configuration_XMLRPCUpdate              Actualizado el puerto XML RPC a %s; Este cámbio no tendrá efecto hasta que POPFile sea reiniciado

Advanced_Error1                         '%s' ya está en la lista de Palabras a Ignorar
Advanced_Error2                         Las Palabras a Ignorar sólo pueden incluir caracteres alfanuméricos, ., _, -, o @
Advanced_Error3                         '%s' añadida a la lista de Palabras a Ignorar
Advanced_Error4                         '%s' no está en la lista de Palabras a Ignorar
Advanced_Error5                         '%s' borrada de la lista de Palabras a Ignorar
Advanced_StopWords                      Palabras a Ignorar
Advanced_Message1                       POPFile ignora las siguientes palabras de uso frecuente:
Advanced_AddWord                        Añadir palabra
Advanced_RemoveWord                     Borrar palabra

History_Filter                          &nbsp;(Sólo mostrando Categoría <font color="%s">%s</font>)
History_FilterBy                        Filtrar por
History_Search                          &nbsp;(Buscado por De/Asunto %s)
History_Title                           Correos recientes
History_Jump                            Saltar a Correo
History_ShowAll                         Mostrar todos
History_ShouldBe                        Debería ser
History_NoFrom                          Sin línea De
History_NoSubject                       Sin línea Asunto
History_ClassifyAs                      Clasificar como
History_MagnetUsed                      Imán usado
History_ChangedTo                       Cambiado a <font color="%s">%s
History_Already                         Ya reclasificado como <font color="%s">%s</font>
History_RemoveAll                       Borrar Todos
History_RemovePage                      Borrar Página
History_Remove                          Para remover entradas en la historia haga click
History_SearchMessage                   Busqueda por De/Asunto
History_NoMessages                      Ningún Correo
History_ShowMagnet                      Magnetizado
History_Magnet                          &nbsp;(Mostrando sólo mensajes magnetizados)
History_ResetSearch                     Reiniciar
History_MagnetBecause                   <b>Imán Usado</b><p>Clasificado en <font color="%s">%s</font> debido al Imán %s </p>
History_NoMagnet                        &nbsp;(Mostrando sólo mensajes no magnetizados)
History_ShowNoMagnet                    No Magnetizado 

Password_Title                          Contraseña
Password_Enter                          Introduzca contraseña
Password_Go                             Adelante!
Password_Error1                         Contraseña Incorrecta

Security_Error1                         El puerto debe ser un número entre 1 and 65535
Security_Stealth                        Modo Invisible/Operación del Servidor
Security_NoStealthMode                  No (Modo invisible)
Security_ExplainStats                   (Con esto activado POPFile envía una vez al dia los siguientes tres valores a un script en www.usethesource.com: bc (el número total de categorías que tiene), mc (el número total de correos que POPFile ha clasificado) y ec (el número total de errores clasificación).  Todo esto se guarda en un fichero que usarémos para publicar estadísticas de como usa POPFile la gente y cómo de bien funciona.  Mi servidor web guarda sus ficheros de log 5 días y luego son borrados; no se guarda ninguna conexión entre las estadísticas y las direcciones IP particulares.)
Security_ExplainUpdate                  (Con esto activado POPFile envía una vez al dia los siguientes tres valores a un script en www.usethesource.com: ma (el número mayor de versión del POPFile instalado), mi (el número menor de versión del POPFile instalado) y bn (el número de compilación del POPFile instalado).  POPFile recibe una respuesta en forma de un gráfico que aparece en la página indicando si hay una nueva versión disponible.  Mi servidor web guarda sus ficheros de log 5 días y luego son borrados; no se guarda ninguna conexión entre los chequeos de actualización y las direcciones IP particulares.)
Security_PasswordTitle                  Contraseña de la Interfaz de Usuario
Security_Password                       Contraseña
Security_PasswordUpdate                 Contraseña actualizada a %s
Security_AUTHTitle                      Servidores Remotos
Security_SecureServer                   Sevidor POP3 SPA/AUTH seguro
Security_SecureServerUpdate             Sevidor POP3 SPA/AUTH seguro actualizado a %s; Este cámbio no tendrá efecto hasta que POPFile sea reiniciado
Security_SecurePort                     Puerto POP3 SPA/AUTH
Security_SecurePortUpdate               Puerto POP3 SPA/AUTH seguro actualizado a %s; Este cámbio no tendrá efecto hasta que POPFile sea reiniciado
Security_POP3                           Aceptar conexiones POP3 de máquinas remotas (hay que reiniciar POPFile)
Security_UI                             Aceptar conexiones HTTP (Interfaz de Usuario) de máquinas remotas (hay que reiniciar POPFile)
Security_UpdateTitle                    Comprobación de Actualizaciones
Security_Update                         Comprobar diariamente si hay actualizaciones de POPFile
Security_StatsTitle                     Enviar Stadísticas
Security_Stats                          Enviar Stadísticas diariamente
Security_NNTP                           Aceptar conexiones NNTP de máquinas remotas (hay que reiniciar POPFile)
Security_SMTP                           Aceptar conexiones SMTP de máquinas remotas (hay que reiniciar POPFile)
Security_SMTPPort                       SMTP chain port
Security_SMTPPortUpdate                 SMTP chain port actualizado a %s; Este cámbio no tendrá efecto hasta que POPFile sea reiniciado
Security_SMTPServer                     SMTP chain server
Security_SMTPServerUpdate               SMTP chain server actualizado a %s; Este cámbio no tendrá efecto hasta que POPFile sea reiniciado
Security_XMLRPC                         Aceptar conexiones POP3 de máquinas remotas (hay que reiniciar POPFile)

Magnet_Error1                           El Imán '%s' ya existe en la Categoría '%s'
Magnet_Error2                           El nuevo Imán '%s' colisiona con el '%s' en la Categoría '%s' y podría causar resultados ambiguos.  Nuevo Imán no añadido.
Magnet_Error3                           Crear Imán nuevo '%s' en la Categoría '%s'
Magnet_CurrentMagnets                   Imánes actuales
Magnet_Message1                         Los siguientes Imanes clasifican siempre el correo en la Categoría especificada.
Magnet_CreateNew                        Crear nuevo Imán
Magnet_Explanation                      Hay tres tipos de Imán:</b> <ul><li><b>Nombre o dirección en campo De:</b> Por ejemplo: josegarcia@empresa.com para clasificar una dirección específica, <br />empresa.com para clasificar a todos los que envien desde empresa.com, <br />José Garcia para clasificar a una persona concreta, José para clasificar todos los Josés</li><li><b>A dirección o nombres:</b> Igual que el Imán para campo De: pero para el campo A: en el correo electrónico</li> <li><b>Palabras en campo Asunto:</b> Por ejemplo: hola para clasificar todos los correos con hola en el Asunto</li></ul>
Magnet_MagnetType                       Tipo de Imán
Magnet_Value                            Valor
Magnet_Always                           Clasificar siempre en
Magnet_Jump                             Ir a página de Imanes

Bucket_Error1                           Los nombres de Categorías sólo pueden contener las letras de la a a la z en minúsculas mas - y _
Bucket_Error2                           Ya existe una Categoría llamada %s
Bucket_Error3                           Categoría %s creada
Bucket_Error4                           Escriba una palabra no vacia
Bucket_Error5                           Categoría %s renombrada a %s
Bucket_Error6                           Categoría %s borrada
Bucket_Title                            Resumen
Bucket_BucketName                       Nombre de Categoría
Bucket_WordCount                        Total (Palabras)
Bucket_WordCounts                       Total (Palabras)
Bucket_UniqueWords                      Palabras Únicas
Bucket_SubjectModification              Modificación del Asunto
Bucket_ChangeColor                      Cambiar Color
Bucket_NotEnoughData                    Faltan datos
Bucket_ClassificationAccuracy           Precisión de la Clasificación
Bucket_EmailsClassified                 Mensajes Clasificados
Bucket_EmailsClassifiedUpper            Mensajes Clasificados
Bucket_ClassificationErrors             Errores de Clasificación
Bucket_Accuracy                         Precisión
Bucket_ClassificationCount              Total Clasificados
Bucket_ResetStatistics                  Reiniciar Estadísticas
Bucket_LastReset                        Último reinicio
Bucket_CurrentColor                     El color actual de %s es %s
Bucket_SetColorTo                       Establecido %s como color de %s
Bucket_Maintenance                      Mantenimiento
Bucket_CreateBucket                     Crear Categoría de nombre
Bucket_DeleteBucket                     Borrar Categoría de nombre
Bucket_RenameBucket                     Renombrar Categoría de nombre
Bucket_Lookup                           Busquedas
Bucket_LookupMessage                    Buscar palabras en Categorías
Bucket_LookupMessage2                   Resultados de la búsqueda para
Bucket_LookupMostLikely                 La palabra <b>%s</b> es más probable que aparezca en <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> no aparece en ninguna de las Categorías
Bucket_DisabledGlobally                 Deshabilitado Globalmente
Bucket_To                               A
Bucket_Quarantine                       Cuarentena
Bucket_ClassificationFN                 Falsos Negativos
Bucket_ClassificationFP                 Falsos Positivos

SingleBucket_Title                      Detalles para %s
SingleBucket_WordCount                  Total palabras en Categoría
SingleBucket_TotalWordCount             Total de Palabras 
SingleBucket_Percentage                 Porcentaje del total
SingleBucket_WordTable                  Tabla de palabras para %s
SingleBucket_Message1                   "Pincha" una letra en el indice para ver las palabras que empiezan por ella.  "Pincha" en cualquier palabra para conocer su probabilidad en todas las Categorías.
SingleBucket_Unique                     %s únicas
SingleBucket_ClearBucket                Borrar todas las Palabras

Session_Title                           Ha expirado la sesión de POPFile
Session_Error                           Ha expirado tu sesión de POPFile.  Esto puede ser debido a que haya dejado su navegador abierto mientras reiniciaba POPFile.  Por favor, pinche en uno de los enlaces superiores para continuar usando POPFile.

View_Title                              Vista de un solo mensaje

Header_MenuSummary                      This table is the navigation menu which allows access to each of the different pages of the control center.
History_MainTableSummary                This table shows the sender and subject of recently received messages and allows them to be reviewed and reclassified.  Clicking on the subject line will show the full message text, along with information about why it was classified as it was.  The 'Should be' column allows you to specify which bucket the message belongs in, or to undo that change.  The 'Delete' column allows you to delete specific messages from the history if you don't need them anymore.
History_OpenMessageSummary              This table contains the full text of an email message, with the words that are used for classification highlighted according to the bucket that was most relevant for each.
Bucket_MainTableSummary                 This table provides an overview of the classification buckets.  Each row shows the bucket name, the word count total for that bucket, the actual number of individual words in each bucket, whether the email's subject line will be modified when it gets classified to that bucket, whether to quarantine the messages received in that bucket, and a table to pick the color used in displaying anything related to that bucket in the control center.
Bucket_StatisticsTableSummary           This table provides three sets of statistics on the overall performance of POPFile.  The first is how accurate its classification is, the second is how many emails have been classified, and to which buckets, and the third is how many words are in each bucket, and what their relative percentages are.
Bucket_MaintenanceTableSummary          This table contains forms that allow you to create, delete or rename buckets, and to lookup a word in all of the buckets to see its relative probabilities.
Bucket_AccuracyChartSummary             This table graphically represents the accuracy of the email classification.
Bucket_BarChartSummary                  This table graphically represents a percentage allocation for each of the different buckets.  It is used for both number of emails classified, and total word counts.
Bucket_LookupResultsSummary             This table shows the probabilities associated with any given word of the corpus.  For each bucket, it shows the frequency that that word occurs, the probability that it will occur in that bucket, and the overall effect on the score of the bucket if that word exists in an email.
Bucket_WordListTableSummary             This table provides a listing of all the words for a particular bucket, organized by common first letter for each row.
Magnet_MainTableSummary                 This table shows the list of magnets that are used to automatically classify email according to fixed rules.  Each row shows how the magnet is defined, what bucket it is intended for, and a button to delete the magnet.
Configuration_MainTableSummary          This table contains a number of forms to allow you to control the configuration of POPFile.
Configuration_InsertionTableSummary     This table contains buttons that determine whether or not certain modifications are made to the headers or subject line of the email before it is passed on to the email client.
Security_MainTableSummary               This table provides sets of controls that affect the security of the overall configuration of POPFile, whether it should automatically check for updates to the program, and whether statistics about POPFile's performance should be sent to the central datastore of the program's author for general information.
Advanced_MainTableSummary               This table provides a list of words that POPFile ignores when classifying email due to their relative frequency in email in general.  They are organized per row according to the first letter of the words.

