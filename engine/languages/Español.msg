# Copyright (c) 2001-2003 John Graham-Cumming

# Identify the language and character set used for the interface
LanguageCode                            es
LanguageCharset                         ISO-8859-1

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          es

# Common words that are used on their own all over the interface
Apply                                   Aplicar
On                                      Activo
Off                                     Inactivo
TurnOn                                  Activar
TurnOff                                 Desactivar
Add                                     Añadir
Remove                                  Quitar
Previous                                Previa
Next                                    Seguir
From                                    De
Subject                                 Asunto
Cc                                      Cc 
Classification                          Clasificación
Reclassify                              Reclasificar
Probability                             Probabilidad
Scores                                  Puntuaciones
QuickMagnets                            Superimanes
Undo                                    Deshacer
Close                                   Cerrar
Find                                    Buscar
Filter                                  Filtro
Yes                                     Si
No                                      No
ChangeToYes                             cambiar a Sí
ChangeToNo                              cambiar a No
Bucket                                  Categoría
Magnet                                  Imán
Delete                                  Borrar
Create                                  Crear
To                                      Para
Total                                   Total
Rename                                  Renombrar
Frequency                               Frequencia
Probability                             Probabilidad
Score                                   Puntuación
Lookup                                  Búsqueda
Word                                    Palabra
Count                                   Cuenta
Update                                  Actualizar
Refresh                                 Refrescar

# The header and footer that appear on every UI page
Header_Title                            POPFile - Centro de Control
Header_Shutdown                         Apagar POPFile
Header_History                          Historial
Header_Buckets                          Categorías
Header_Configuration                    Configuración
Header_Advanced                         Avanzado
Header_Security                         Seguridad
Header_Magnets                          Imanes

Footer_HomePage                         Página Web de POPFile
Footer_Manual                           Manual
Footer_Forums                           Foros
Footer_FeedMe                           Donar
Footer_RequestFeature                   Pedir Característica
Footer_MailingList                      Lista de Correo

Configuration_Error1                    El carácter separador tiene que ser uno solo
Configuration_Error2                    El puerto del GUI tiene que ser un nº entre 1 y 65535
Configuration_Error3                    El puerto de escucha POP3 tiene que ser un nº entre 1 y 65535
Configuration_Error4                    El tamaño de la página tiene que ser un nº entre 1 y 1000
Configuration_Error5                    El nº de dias en el historial tiene que ser un nº entre 1 y 366
Configuration_Error6                    La temporización TCP debe ser un nº entre 10 y 300
Configuration_Error7                    El puerto de escucha XML RPC listen debe ser un número entre 1 y 65535
Configuration_POP3Port                  Puerto de escucha POP3
Configuration_POP3Update                Puerto actualizado a %s; este cambio será efectivo al siguiente reinicio de POPFile
Configuration_XMLRPCUpdate              Puerto XML-RPC actualizado a %s; este cambio será efectivo en el siguiente arranque de POPFile
Configuration_XMLRPCPort                Puerto de escucha XML-RPC
Configuration_SMTPPort                  Puerto de escucha SMTP
Configuration_SMTPUpdate                Puerto SMTP actualizado a %s; este cambio será efectivo en el siguiente arranque de POPFile
Configuration_NNTPPort                  Puerto de escucha NNTP
Configuration_NNTPUpdate                Puerto NNTP actualizado a %s; este cambio será efectivo en el siguiente arranque de POPFile
Configuration_POP3Separator             POP3 host:puerto:usuario caracter separador
Configuration_NNTPSeparator             NNTP host:puerto:usuario caracter separador
Configuration_POP3SepUpdate             Separador POP3 actualizado a %s
Configuration_NNTPSepUpdate             Separador NNTP actualizado a %s
Configuration_UI                        Puerto web del interface de Usuario
Configuration_UIUpdate                  El puerto web del interface de usuario ha sido actualizado a %s ; este cambio será efectivo en el siguiente reinicio de POPFile
Configuration_History                   Número de correos por página
Configuration_HistoryUpdate             Nº de correos por página actualizado a %s
Configuration_Days                      Nº de dias que se guarda el historial
Configuration_DaysUpdate                Actualizado el número de días en historial a %s
Configuration_UserInterface             Interface de Usuario
Configuration_Skins                     Apariencias
Configuration_SkinsChoose               Elegir una apariencia
Configuration_Language                  Lenguaje
Configuration_LanguageChoose            Elegir lenguaje
Configuration_ListenPorts               Puertos de escucha
Configuration_HistoryView               Vista de Historial
Configuration_TCPTimeout                Temporización de la conexión TCP
Configuration_TCPTimeoutSecs            Temporización en segundos
Configuration_TCPTimeoutUpdate          Temporización de la conexión TCP establecida en %s
Configuration_ClassificationInsertion   Inserción de texto en E-Mail
Configuration_SubjectLine               Modificar la línea de asunto
Configuration_XTCInsertion              Insertar Clasificación-X-Text
Configuration_XPLInsertion              Insertar enlace-X-POPFile
Configuration_Logging                   Registro
Configuration_None                      Nada
Configuration_ToScreen                  A Pantalla
Configuration_ToFile                    A Fichero
Configuration_ToScreenFile              A Pantalla y Fichero
Configuration_LoggerOutput              Salida
Configuration_GeneralSkins              Apariencias
Configuration_SmallSkins                Apariencias pequeñas
Configuration_TinySkins                 Apariencias enanas
Configuration_CurrentLogFile            &lt;arch. de registro actual&gt;

Advanced_Error1                         '%s' ya está en la lista de palabras ignoradas
Advanced_Error2                         Las palabras ignoradas solo pueden contener caracteres alfanuméricos, ., _, -, ó @
Advanced_Error3                         '%s' añadida a la lista de palabras ignoradas
Advanced_Error4                         '%s' no está en la lista de palabras ignoradas
Advanced_Error5                         '%s' quitada de la lista de palabras ignoradas
Advanced_StopWords                      Palabras Ignoradas
Advanced_Message1                       POPFile ignora las siguientes palabras de uso frecuente:
Advanced_AddWord                        Añadir palabra
Advanced_RemoveWord                     Quitar palabra

History_Filter                          &nbsp;(mostrando sólo la categoría <font color="%s">%s</font>)
History_FilterBy                        Filtrar Por
History_Search                          &nbsp;(buscando en de/asunto %s)
History_Title                           Mensajes Recientes
History_Jump                            Ir al mensaje
History_ShowAll                         Mostrar Todo
History_ShouldBe                        Debería ser
History_NoFrom                          sin línea de
History_NoSubject                       sin línea de asunto
History_ClassifyAs                      Clasificar como
History_MagnetUsed                      Imán utilizado
History_MagnetBecause                   <b>Iman usado</b><p>Clasificado a <font color="%s">%s</font> por el iman %s </p>
History_ChangedTo                       Cambiado a <font color="%s">%s
History_Already                         Anteriormente clasificado como <font color="%s">%s</font>
History_RemoveAll                       Quitar Todo
History_RemovePage                      Quitar Página
History_Remove                          Para borrar las entradas en el historial clic
History_SearchMessage                   Buscar De/Asunto
History_NoMessages                      Sin mensajes
History_ShowMagnet                      magnetizado
History_ShowNoMagnet                    desmagnetizado
History_Magnet                          &nbsp;(mostrando solo mensajes clasificados por imán)
History_NoMagnet                        &nbsp;(Mostrando sólo mensajes no-clasificados magnéticamente)
History_ResetSearch                     Reiniciar

Password_Title                          Contraseña
Password_Enter                          Escriba contraseña
Password_Go                             ¡Venga!
Password_Error1                         Contraseña incorrecta

Security_Error1                         El puerto seguro tiene que ser un nº entre 1 y 65535
Security_Stealth                        Modo Oculto/Operación del Servidor
Security_NoStealthMode                  No (Modo Oculto)
Security_ExplainStats                   Con esto activado POPFile envia una vez al día los tres valores siguientes a un script en www.usethesource.com: <b>bc</b> (el nº de categorías que tienes), <b>mc</b> (el nº total de mensajes que ha clasificado POPFile) y <b>ec</b> (el nº total de errores de clasificación).  Estos se guardan en un archivo que yo utilizaré para publicar algunas estadísticas acerca de cómo usa la gente POPFile y cómo de bien les funciona.  Mi servidor web mantiene sus archivos log unos 5 días y luego se borran; Yo no guardo ninguna relación entre las estadísticas y sus direcciones IP individuales.
Security_ExplainUpdate                  Con esto activado POPFile envia una vez al día los tres valores siguientes a un script en www.usethesource.com: <b>ma</b> (el nº de versión de tu POPFile), <b>mi</b> (el nº de revisión de tu POPFile) y <b>bn</b> (el nº de compilación de tu POPFile).  Si existe una nueva versión, POPFile recibe una respuesta en forma de gráfico que se muestra en la parte superior de la página.  Mi servidor web mantiene sus archivos log unos 5 días y luego se borran; Yo no guardo ninguna relación entre las comprobaciones de actualización y sus direcciones IP individuales.
Security_PasswordTitle                  Contraseña del Interface de Usuario
Security_Password                       Contraseña
Security_PasswordUpdate                 Contraseña actualizada a %s
Security_AUTHTitle                      Autentificación por Contraseña Segura/AUTH
Security_SecureServer                   Servidor seguro
Security_SecureServerUpdate             Actualizado el servidor seguro a %s; este cambio será efectivo en el siguiente reinicio de POPFile
Security_SecurePort                     Puerto seguro
Security_SecurePortUpdate               Puerto actualizado a %s; este cambio será efectivo en el siguiente reinicio de POPFile
Security_SMTPServer                     servidor chain SMTP
Security_SMTPServerUpdate               Actualizado el servidor chain SMTP a %s; este cambio será efectivo en el siguiente reinicio de POPFile
Security_SMTPPort                       Puerto chain SMTP
Security_SMTPPortUpdate                 Actualizado elpuerto chain SMTP a %s; este cambio será efectivo en el siguiente reinicio de POPFile
Security_POP3                           Aceptar conexiones POP3 desde máquinas remotas (necesita reiniciar POPFile)
Security_SMTP                           Aceptar conexiones SMTP desde máquinas remotas (necesita reiniciar POPFile)
Security_NNTP                           Aceptar conexiones NNTP desde máquinas remotas (necesita reiniciar POPFile)
Security_UI                             Aceptar conexiones HTTP (Interface del Usuario) desde máquinas remotas (necesita reiniciar POPFile)
Security_XMLRPC                         Aceptar conexiones XML-RPC desde máquinas remotas (necesita reiniciar POPFile)
Security_UpdateTitle                    Comprobación automática de actualización
Security_Update                         Buscar actualizaciones POPFile a diario
Security_StatsTitle                     Enviar Estadísticas
Security_Stats                          Enviar estadísticas diariamente

Magnet_Error1                           El imán '%s' ya existía en la categoría '%s'
Magnet_Error2                           El nuevo imán '%s' interfiere con el imán '%s' de la categoría '%s' y puede dar lugar a resultados ambiguos.  No se ha añadido el nuevo.
Magnet_Error3                           Crear imán nuevo '%s' en la categoría '%s'
Magnet_CurrentMagnets                   Imanes Actuales
Magnet_Message1                         Los siguientes imanes hacen que el correo sea clasificado siempre en la categoría especificada.
Magnet_CreateNew                        Crear Imán Nuevo
Magnet_Explanation                      Hay tres tipos de imanes disponibles:</b> <ul><li><b>Dirección de procedencia o nombre del remitente:</b> Por ejemplo:<br /> <i>felipe@company.com</i> para capturar esta dirección específica, <br /><i>company.com</i> para capturar a cualquiera que envíe desde <i>company.com</i>, <br /><i>Felipe Martinez</i> para capturar esa persona específica,<br /> <i>Felipe</i> para capturar a todos los Felipes</li><li><b>Dirección <i>Para:</i> o nombre del destinatario:</b> Como un imán De: pero con la dirección <i>Para:</i> en un correo</li> <li><b>Palabras en el Asunto:</b> Por ejem.: <i>hola</i> para capturar todos los mensajes con <i>hola</i> en el asunto</li></ul>
Magnet_MagnetType                       Tipo de Imán
Magnet_Value                            Valor
Magnet_Always                           Ir siempre a categoría
Magnet_Jump                             Ir a la página iman

Bucket_Error1                           Los nombres de categoría sólo pueden contener las letras de la "a" a la "z" en minusculas, - y _
Bucket_Error2                           Ya existe la categoría %s
Bucket_Error3                           Categoría %s creada
Bucket_Error4                           Ponga por favor una palabra no-vacía
Bucket_Error5                           Categoría %s renombrada a %s
Bucket_Error6                           Categoría %s borrada
Bucket_Title                            Sumario
Bucket_BucketName                       Nombre de Categoría
Bucket_WordCount                        Contador de Palabras
Bucket_WordCounts                       Nº de palabras
Bucket_UniqueWords                      Palabras únicas
Bucket_SubjectModification              Modificación del asunto
Bucket_ChangeColor                      Cambiar Color
Bucket_NotEnoughData                    No hay bastantes datos
Bucket_ClassificationAccuracy           Exactitud de la Clasificación
Bucket_EmailsClassified                 correos clasificados
Bucket_EmailsClassifiedUpper            Correos Clasificados
Bucket_ClassificationErrors             Errores de clasificación
Bucket_Accuracy                         Exactitud
Bucket_ClassificationCount              Contador de Clasificación
Bucket_ClassificationFP                 Falsos Positivos
Bucket_ClassificationFN                 Falsos Negativos
Bucket_ResetStatistics                  Reiniciar Estadísticas
Bucket_LastReset                        Ultimo Reinicio
Bucket_CurrentColor                     El color actual de %s es %s
Bucket_SetColorTo                       Cambiar el color de %s a %s
Bucket_Maintenance                      Mantenimiento
Bucket_CreateBucket                     Nombre de categoría
Bucket_DeleteBucket                     Borrar categoría
Bucket_RenameBucket                     Renombrar categoría
Bucket_Lookup                           Búsqueda
Bucket_LookupMessage                    Buscar palabra en categorías
Bucket_LookupMessage2                   Buscar en resultados por
Bucket_LookupMostLikely                 <b>%s</b> en su mayoría aparece en <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> no aparece en ninguna de las categorías
Bucket_DisabledGlobally                 Desactivado globalmente
Bucket_To                               a
Bucket_Quarantine                       Cuarentena

SingleBucket_Title                      Detalle de %s
SingleBucket_WordCount                  Categoría nº de palabras
SingleBucket_TotalWordCount             Nº total de palabras
SingleBucket_Percentage                 Porcentaje del total
SingleBucket_WordTable                  Palabra Table for %s
SingleBucket_Message1                   Las palabras con estrellas (*) se han usado para clasificar en esta sesión de POPFile.  Clic en cualquier palabra para buscar su probabilidad para todos las categorías.
SingleBucket_Unique                     %s único
SingleBucket_ClearBucket                Borrar Todas las Palabras

Session_Title                           Terminada la Sesión POPFile
Session_Error                           Ha expirado tu sesión en POPFile, y puede ser debido a arrancar y parar POPFile dejando tu navegador abierto.  Por favor, pincha uno de los enlaces de arriba para seguir con POPFile.

View_Title                              Vista de un solo mensaje

Header_MenuSummary                      Esta tabla es el menú de navegación que le permite acceder a cada una de las páginas del centro de control.
History_MainTableSummary                Esta tabla muestra el remitente y asunto de los mensajes recibidos recientemente y permite que sean revisados y reclasificados.  Pinchando en la línea de asunto se mostrará el texto completo del mensaje, junto con información acerca del porqué se clasificó así.  La columna 'Debería ser' le permite especificar a qué categoría pertenece el mensaje, o deshacer el cambio.  La columna 'Borrar' le permite borrar mensajes específicos del historial si usted ya no los necesita.
History_OpenMessageSummary              Esta tabla contiene el texto completo de un mensaje de correo, enfatizando las palabras que se han utilizado para clasificarlos acorde con la categoría que era más relevante para cada una.
Bucket_MainTableSummary                 Esta tabla proporciona una visión global de las categorías de clasificación.  Cada fila muestra el nombre de la categoría, el nº total de palabras de esta categoría, el nº actual de palabras unicas en cada categoría, si el asunto del correo se modificará al clasificarlo es esa categoría, si pondrá en cuarentena los mensajes recibidos en esa categoría, y una tabla de la que escoger el color con el que se visualizará en el centro de control lo relacionado con esa categoría.
Bucket_StatisticsTableSummary           Esta tabla proporciona tres conjuntos de estadísticas sobre el comportamiento global de POPFile.  El 1º es sobre lo acertada des su clasificación, el 2º es cuántos correos se han clasificado, y en qué categorías, y el 3º es cuántas palabras hay en cada categoría, y cuáles son sus porcentajes relativos.
Bucket_MaintenanceTableSummary          Esta tabla confiene formularios que te permiten crear, borrar o renombrar categorías, y buscar palabras en todas las categorías para ver sus probabilidades relativas.
Bucket_AccuracyChartSummary             Esta tabla representa gráficamente la exactitud de la clasificación de correo.
Bucket_BarChartSummary                  Esta tabla representa gráficamente un distribución percentual de cada una de las diferentes categorías.  Esto se necesita para al nº de correos clasificados, y el conteo total de palabras.
Bucket_LookupResultsSummary             Esta tabla muestra las probabilidades asociadas con una palabra dada en el corpus.  Para cada categoría, muestra la frecuencia con que se encuentra esa palabra, la probabilidad de que vuelava a encontrarse en esa categoría, y el efecto en general sobre la puntuación de la categoría si esa palabra existe en un correo.
Bucket_WordListTableSummary             Esta tabla proporciona un listado de todas las palabras de una categoría en particular, ordenadas por la primera letra común de cada fila.
Magnet_MainTableSummary                 Esta tabla muestra la lista de imanes que se han usado para autoclasificar el correo de acuerdo a reglas fijas.  Cada fila muestra cómo está definido el imán, para qué categoría se ha ideado, y un botón para borrar el imán.
Configuration_MainTableSummary          Esta tabla contiene los formularios que te permitirán controlar la configuración de POPFile.
Configuration_InsertionTableSummary     Esta tabla contiene botones que determinan cuando se harán o no, ciertas modificaciones a la cabecera o al título del correo antes de enviarlo al cliente de correo.
Security_MainTableSummary               Esta tabla proporciona grupos de controles que afectan a la seguridad de la configuración global de POPFile, si tiene que comprobar automáticamente la existencia de actualizaciones del programa, y si las estadísticas sobre el comportamiento de POPFile tienen que enviarse al almacén de datos centralizado del autor del programa (para obtener información general).
Advanced_MainTableSummary               Esta tabla proporciona un listado de palabras que POPFile ignora cuando clasifica correos debido a su frecuencia relativa en todos ellos.  Están ordenadas por filas de acuerdo con la primera letra de las palabras.

