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
LanguageCode                            fr
LanguageCharset                         ISO-8859-1
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          fr

# Common words that are used on their own all over the interface
Apply                                   Appliquer
On                                      Actif
Off                                     Inactif
TurnOn                                  Activer
TurnOff                                 Désactiver
Add                                     Ajouter
Remove                                  Retirer
Previous                                Précédent
Next                                    Suivant
From                                    De
Subject                                 Sujet
Cc                                      Cc
Classification                          Classification
Reclassify                              Reclassifier
Probability                             Probabilité
Scores                                  Scores
QuickMagnets                            Aimants rapides
Undo                                    Annuler
Close                                   Fermer
Find                                    Chercher
Filter                                  Filtrer
Yes                                     Oui
No                                      Non
ChangeToYes                             Passer à Oui
ChangeToNo                              Passer à Non
Bucket                                  Catégorie
Magnet                                  Aimant
Delete                                  Supprimer
Create                                  Créer
To                                      A
Total                                   Total
Rename                                  Renommer
Frequency                               Fréquence
Probability                             Probabilité
Score                                   Score
Lookup                                  Consulter
Word                                    Mot
Count                                   Compteur
Update                                  Mettre à jour
Refresh                                 Actualiser
FAQ                                     FAQ
ID                                      ID
Date                                    Date
Arrived                                 Arrivé
Size                                    Taille

# This is a regular expression pattern that is used to convert
# a number into a friendly looking number (for the US and UK this
# means comma separated at the thousands)

Locale_Thousands                        " "
Locale_Decimal                          ,

# The Locale_Date uses the format strings in Perl's Date::Format
# module to set the date format for the UI.  There are two possible
# ways to specify it.
#
# <format>            Just one simple format used for all dates
# <<format> | <format> The first format is used for dates less than
#                     7 days from now, the second for all other dates

Locale_Date                             %d/%m %R | %d/%m/%Y %R

# The header and footer that appear on every UI page
Header_Title                            Centre de Commande de POPFile
Header_Shutdown                         Arrêter POPFile
Header_History                          Historique
Header_Buckets                          Catégories
Header_Configuration                    Configuration
Header_Advanced                         Avancé
Header_Security                         Sécurité
Header_Magnets                          Aimants

Footer_HomePage                         Site web de POPFile
Footer_Manual                           Manuel
Footer_Forums                           Forums
Footer_FeedMe                           Encouragez-moi!
Footer_RequestFeature                   Demande d'évolution
Footer_MailingList                      Liste de diffusion
Footer_Wiki                             Documentation additionnelle

Configuration_Error1                    Le caractère séparateur doit être un unique caractère
Configuration_Error2                    Le port de l'interface utilisateur doit être un nombre compris entre 1 et 65535
Configuration_Error3                    Le port d'écoute POP3 doit être un nombre compris entre 1 et 65535
Configuration_Error4                    La taille de page doit être un nombre compris entre 1 et 1000
Configuration_Error5                    Le nombre de jours d'historique doit être un nombre compris entre 1 et 366
Configuration_Error6                    Le délai d'expiration TCP doit être un nombre compris entre 10 et 300
Configuration_Error7                    Le port d'écoute XML-RPC doit être un nombre compris entre 1 et 65535
Configuration_Error8                    Le port du proxy SOCKS V doit être un nombre compris entre 1 et 65535
Configuration_POP3Port                  Port d'écoute POP3
Configuration_POP3Update                Port passé à %s; ce changement ne prendra effet qu'au prochain redémarrage de POPFile
Configuration_XMLRPCUpdate              Le port XML-RPC est passé à %s; ce changement ne prendra effet qu'au prochain redémarrage de POPFile
Configuration_XMLRPCPort                Port d'écoute XML-RPC
Configuration_SMTPPort                  Port d'écoute SMTP
Configuration_SMTPUpdate                Le port SMTP est passé à %s; ce changement ne prendra effet qu'au prochain redémarrage de POPFile
Configuration_NNTPPort                  Port d'écoute NNTP
Configuration_NNTPUpdate                Le port NNTP est passé à %s; ce changement ne prendra effet qu'au prochain redémarrage de POPFile
Configuration_POPFork                   Autorise plusieurs connexions POP3 simultanées
Configuration_SMTPFork                  Autorise plusieurs connexions SMTP simultanées
Configuration_NNTPFork                  Autorise plusieurs connexions NNTP simultanées
Configuration_POP3Separator             Caractère de séparation pour hôte:port:utilisateur POP3
Configuration_NNTPSeparator             Caractère de séparation pour hôte:port:utilisateur NNTP
Configuration_POP3SepUpdate             Le séparateur POP3 est passé à %s
Configuration_NNTPSepUpdate             Le séparateur NNTP est passé à %s
Configuration_UI                        Port web d'interface utilisateur
Configuration_UIUpdate                  Port web d'interface utilisateur passé à %s; ce changement ne prendra effet qu'au prochain redémarrage de POPFile
Configuration_History                   Nombre de messages par page
Configuration_HistoryUpdate             Nombre de messages par page passé à %s
Configuration_Days                      Nombre de jours d'historique à conserver
Configuration_DaysUpdate                Nombre de jours d'historique passé à %s
Configuration_UserInterface             Interface Utilisateur
Configuration_Skins                     Apparences
Configuration_SkinsChoose               Choisir une apparence
Configuration_Language                  Langue
Configuration_LanguageChoose            Choisir une langue
Configuration_ListenPorts               Ports d'Ecoute
Configuration_HistoryView               Pages d'Historique
Configuration_TCPTimeout                Délai d'Expiration de Connexion TCP
Configuration_TCPTimeoutSecs            Délai d'expiration de connexion TCP en secondes
Configuration_TCPTimeoutUpdate          Délai d'expiration de connexion TCP passé à %s
Configuration_ClassificationInsertion   Informations de Classification
Configuration_SubjectLine               Modification de la ligne Sujet
Configuration_XTCInsertion              Insertion de X-Text-Classification
Configuration_XPLInsertion              Insertion de X-POPFile-Link
Configuration_Logging                   Journalisation
Configuration_None                      aucune
Configuration_ToScreen                  à l'écran
Configuration_ToFile                    dans un fichier
Configuration_ToScreenFile              écran et fichier
Configuration_LoggerOutput              Sortie
Configuration_GeneralSkins              Habillages
Configuration_SmallSkins                Habillages compacts
Configuration_TinySkins                 Habillages ultra-compacts
Configuration_CurrentLogFile            &lt;Télécharger le fichier journal en cours&gt;
Configuration_SOCKSServer               Hôte du proxy SOCKS V
Configuration_SOCKSPort                 Port du proxy SOCKS V
Configuration_SOCKSPortUpdate           Le port du proxy SOCKS V est passé à %s
Configuration_SOCKSServerUpdate         L'hôte du proxy SOCKS V est passé à %s
Configuration_Fields                    Colonnes de l'historique

Advanced_Error1                         '%s' est déjà dans la liste des mots ignorés
Advanced_Error2                         Les mots ignorés ne peuvent contenir que des caractères alphanumériques ou ., _, -, @
Advanced_Error3                         '%s' ajouté à la liste des mots ignorés
Advanced_Error4                         '%s' n'est pas dans la liste des mots ignorés
Advanced_Error5                         '%s' retiré de la liste des mots ignorés
Advanced_StopWords                      Mots ignorés
Advanced_Message1                       Les mots suivants sont ignorés dans toutes les classifications car ils apparaissent très souvent.
Advanced_AddWord                        Ajouter un mot
Advanced_RemoveWord                     Retirer un mot
Advanced_AllParameters                  Tous les paramètres de POPFile
Advanced_Parameter                      Paramètre
Advanced_Value                          Valeur
Advanced_Warning                        Ceci est la liste complète des paramètres de POPFile. Utilisateurs avertis seulement: vous pouvez modifier ceux que vous désirez et cliquer Actualiser. Aucune vérification de validité n'est effectuée. Les éléments différents des valeurs par défaut sont écrits en caractères gras.
Advanced_ConfigFile                     Fichier de configuration :

History_Filter                          &nbsp;(ne montrant que la catégorie <font color="%s">%s</font>)
History_FilterBy                        Filtrer selon
History_Search                          &nbsp;(recherche du sujet %s)
History_Title                           Messages récents
History_Jump                            Aller au message
History_ShowAll                         Tout afficher
History_ShouldBe                        Devrait être
History_NoFrom                          pas de ligne De
History_NoSubject                       pas de ligne Sujet
History_ClassifyAs                      Classifié comme
History_MagnetUsed                      Aimant utilisé
History_MagnetBecause                   <b>Aimant utilisé</b><p>Classifié comme <font color="%s">%s</font> par l'aimant %s </p>
History_ChangedTo                       Changé en <font color="%s">%s
History_Already                         Déjà reclassifié comme <font color="%s">%s</font>
History_RemoveAll                       Supprimer tout
History_RemovePage                      Supprimer page
History_RemoveChecked                   Supprimer les messages cochés
History_Remove                          Pour supprimer des entrées dans l'historique cliquez
History_SearchMessage                   Chercher De/Sujet
History_NoMessages                      Pas de messages
History_ShowMagnet                      Aimanté
History_Negate_Search                   Inverser la recherche ou le filtre
History_Magnet                          &nbsp;(ne montrant que les messages classifiés par aimant)
History_NoMagnet                        &nbsp;(ne montrant que les messages non classifiés par aimant)
History_ResetSearch                     Initialiser
History_ChangedClass                    Devrait maintenant être classifié comme
History_Purge                           Supprimer maintenant
History_Increase                        Croissant
History_Decrease                        Décroissant
History_Column_Characters               Changer la largeur des colonnes De, A, Cc et Sujet
History_Automatic                       Automatique
History_Reclassified                    Reclassifié
History_Size_Bytes                      %d&nbsp;octets
History_Size_KiloBytes                  %.1f&nbsp;Ko
History_Size_MegaBytes                  %.1f&nbsp;Mo

Password_Title                          Mot de Passe
Password_Enter                          Entrez le mot de passe
Password_Go                             Continuer
Password_Error1                         Mot de passe incorrect

Security_Error1                         Le port sécurisé doit être un nombre compris entre 1 et 65535
Security_Stealth                        Mode Furtif/Fonctionnement du Serveur
Security_NoStealthMode                  Non (Mode Furtif)
Security_StealthMode                    (Mode Furtif)
Security_ExplainStats                   (Quand ceci est activé POPFile envoie une fois par jour les trois valeurs suivantes à un script à www.usethesource.com: bc (le nombre total de vos catégories), mc (le nombre total de messages classifiés par POPFile) et ec (le nombre total d'erreurs de classification).  Elles sont alors stockées dans un fichier que j'utiliserai pour publier quelques statistiques sur comment les gens utilisent POPFile et si ça marche bien.  Mon serveur web conserve ses fichiers log pendant environ 5 jours puis les efface; je ne recueille aucun lien entre les statisques et les adresses IP individuelles.)
Security_ExplainUpdate                  (Quand ceci est activé POPFile envoie une fois par jour les trois valeurs suivantes à un script à www.usethesource.com: ma (le numéro de version principal de votre POPFile), mi (le numéro de version secondaire de votre POPFile) et bn (le numéro de compilation de votre POPFile).  POPFile reçoit une réponse sous la forme d'un graphique qui apparaît en haut de la page si une version plus récente est disponible.  Mon serveur web conserve ses fichiers log pendant environ 5 jours puis les efface; je ne recueille aucun lien entre les contrôles de mise à jour et les adresses IP individuelles.)
Security_PasswordTitle                  Mot de passe de l'interface utilisateur
Security_Password                       Mot de passe
Security_PasswordUpdate                 Mot de passe changé en %s
Security_AUTHTitle                      Authentification par mot de passe sécurisé/AUTH
Security_SecureServer                   Serveur sécurisé
Security_SecureServerUpdate             Serveur sécurisé passé à %s; ce changement ne prendra effet qu'au prochain redémarrage de POPFile
Security_SecurePort                     Port sécurisé
Security_SecurePortUpdate               Port sécurisé passé à %s; ce changement ne prendra effet qu'au prochain redémarrage de POPFile
Security_SMTPServer                     Serveur de chaine SMTP
Security_SMTPServerUpdate               Serveur de chaine SMTP passé à %s; ce changement ne prendra effet qu'au prochain redémarrage de POPFile
Security_SMTPPort                       Port de la chaine SMTP
Security_SMTPPortUpdate                 Port de la chaine SMTP passé à %s; ce changement ne prendra effet qu'au prochain redémarrage de POPFile
Security_POP3                           Accepter les connexions POP3 de machines distantes
Security_SMTP                           Accepter les connexions SMTP de machines distantes (nécessite le redémarrage de POPFile)
Security_NNTP                           Accepter les connexions NNTP de machines distantes (nécessite le redémarrage de POPFile)
Security_UI                             Accepter les connexions HTTP (Interface Utilisateur) de machines distantes
Security_XMLRPC                         Accepter les connexions XML-RPC de machines distantes (nécessite le redémarrage de POPFile)
Security_UpdateTitle                    Contrôle automatique de mise à jour
Security_Update                         Vérifier quotidiennement les mises à jour de POPFile
Security_StatsTitle                     Compte-rendu de statistiques
Security_Stats                          Envoyer quotidiennement des statistiques à John

Magnet_Error1                           L'aimant '%s' existe déjà pour la catégorie '%s'
Magnet_Error2                           Le nouvel aimant '%s' interfère avec l'aimant '%s' de la catégorie '%s' et pourrait causer des résultats ambigüs.  Le nouvel aimant n'est pas ajouté.
Magnet_Error3                           Nouvel aimant '%s' créé pour la catégorie '%s'
Magnet_CurrentMagnets                   Aimants actuels
Magnet_Message1                         Les aimants suivants entraînent la classification systématique d'un message dans la catégorie spécifiée.
Magnet_CreateNew                        Créer un nouvel aimant
Magnet_Explanation                      Trois types d'aimants sont disponibles:</b> <ul><li><b>Adresse ou nom de l'expéditeur:</b> Par exemple: john@company.com pour capter une adresse spécifique, <br />company.com pour capter les messages de tous les expéditeurs de company.com, <br />John Doe pour capter une personne en particulier, John pour capter tous les John</li><li><b>Adresse ou nom du destinataire:</b> Comme un aimant De: mais pour l'adresse du destinataire du message</li><li><b>Mots du sujet:</b> Par exemple: bonjour pour capter tous les messages avec bonjour dans le sujet</li></ul>
Magnet_MagnetType                       Type d'aimant
Magnet_Value                            Valeur
Magnet_Always                           Toujours envoyer dans la catégorie
Magnet_Jump                             Aller à la page des aimants

Bucket_Error1                           Les noms de catégories ne peuvent contenir que les minuscules de a à z ainsi que - et _
Bucket_Error2                           La catégorie nommée %s existe déjà
Bucket_Error3                           Catégorie nommée %s créée
Bucket_Error4                           Veuillez entrer un mot non vide
Bucket_Error5                           Catégorie %s renommée en %s
Bucket_Error6                           Catégorie %s effacée
Bucket_Title                            Résumé
Bucket_BucketName                       Nom de catégorie
Bucket_WordCount                        Nombre de mots
Bucket_WordCounts                       Nombres de Mots
Bucket_UniqueWords                      Mots distincts
Bucket_SubjectModification              Modification du sujet
Bucket_ChangeColor                      Changer la couleur
Bucket_NotEnoughData                    Pas assez de données
Bucket_ClassificationAccuracy           Performance de Classification
Bucket_EmailsClassified                 Messages classifiés
Bucket_EmailsClassifiedUpper            Messages Classifiés
Bucket_ClassificationErrors             Erreurs de classification
Bucket_Accuracy                         Performance
Bucket_ClassificationCount              Nombre de classifications
Bucket_ClassificationFP                 Faux Positifs
Bucket_ClassificationFN                 Faux Négatifs
Bucket_ResetStatistics                  Initialiser les statisques
Bucket_LastReset                        Dernière initialisation
Bucket_CurrentColor                     La couleur actuelle de %s est %s
Bucket_SetColorTo                       Changer la couleur de %s en %s
Bucket_Maintenance                      Maintenance
Bucket_CreateBucket                     Créer une catégorie nommée
Bucket_DeleteBucket                     Effacer la catégorie nommée
Bucket_RenameBucket                     Renommer la catégorie nommée
Bucket_Lookup                           Examiner
Bucket_LookupMessage                    Examiner le mot dans les catégories
Bucket_LookupMessage2                   Examiner le résultat pour
Bucket_LookupMostLikely                 <b>%s</b> a le plus de chance d'apparaître dans <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> n'apparaît dans aucune catégorie
Bucket_DisabledGlobally                 Désactivé globalement
Bucket_To                               en
Bucket_Quarantine                       Mise en quarantaine

SingleBucket_Title                      Détail pour %s
SingleBucket_WordCount                  Nombre de mots de la catégorie
SingleBucket_TotalWordCount             Nombre total de mots
SingleBucket_Percentage                 Pourcentage du total
SingleBucket_WordTable                  Table des mots pour %s
SingleBucket_Message1                   Les mots signalés (*) ont été utilisés pour la classification dans cette session POPFile.  Cliquez sur un mot pour examiner sa probabilité dans toutes les catégories.
SingleBucket_Unique                     %s seul
SingleBucket_ClearBucket                Supprimer tous les mots

Session_Title                           Session POPFile expirée
Session_Error                           Votre session POPFile a expiré.  Cela peut être dû à un arrêt/relance de POPFile alors que le navigateur est resté ouvert.  Veuillez cliquer sur l'un des liens ci-dessus pour continuer à utiliser POPFile.

View_Title                              Vue d'un message
View_ShowFrequencies                    Voir les fréquences des mots
View_ShowProbabilities                  Voir les probabilités des mots
View_ShowScores                         Voir les scores des mots et la table de décision
View_WordMatrix                         Matrice des mots
View_WordProbabilities                  Probablité des mots
View_WordFrequencies                    Fréquence des mots
View_WordScores                         Score des mots
View_Chart                              Table de décision

Windows_TrayIcon                        Montrer l'icône de POPFile dans la zone de notification de Windows ?
Windows_Console                         Lancer POPFile dans une fenêtre console ?
Windows_NextTime                        <p><font color="red">Cette modification sera prise en compte après le prochain démarrage de POPFile</font>

Header_MenuSummary                      Cette page est le menu de navigation qui donne accès aux différentes pages du centre de contrôle.
History_MainTableSummary                Cette table montre l'expéditeur et le sujet des messages reçus récemment, et permet de les visionner et de les reclassifier. Cliquez sur la ligne du sujet pour voir l'intégralité du message ainsi que des informations sur la classification qui a été effectuée. La colonne 'devrait être' vous permet de spécifier à quelle catégorie le message appartient, ou d'annuler cette modification. La colonne 'Supprimer' vous permet de supprimer de l'historique les messages dont vous n'avez plus besoin.
History_OpenMessageSummary              Cette table contient le texte complet d'un message électronique, chaque mot utilisé lors de la classification étant coloré en fonction de la catégorie à laquelle il se rapporte le plus.
Bucket_MainTableSummary                 Cette table fournit un aperçu des catégories. Sur chaque ligne, le nom de la catégorie, le total des compteurs des mots de la catégorie, le nombre de mots uniques, le réglage de la modification du sujet si un message est classifié dans cette catégorie, le réglage de la mise en quarantaine des messages classifiés dans cette catégorie, et une table permettant de choisir la couleur associée à cette catégorie, utilisée pour afficher tout ce qui est relatif à cette dernière dans le centre de contrôle.
Bucket_StatisticsTableSummary           Cette table fournit trois valeurs statistiques sur les performance générales de POPFile. La première donne le taux de réussite de la classification, la seconde combien de messages ont été classifiés et dans quelles catégories, et la troisième combien de mots sont présents dans chaque catégorie, avec leurs pourcentages relatifs.
Bucket_MaintenanceTableSummary          Cette table contient des formulaires qui vous permettent de créer, supprimer ou renommer les catégories, et rechercher un mot dans toutes les catégories pour vérifier ses probabilités relatives.
Bucket_AccuracyChartSummary             Cette table représente graphiquement le taux de réussite de la classification des messages.
Bucket_BarChartSummary                  Cette table représente graphiquement la taille relative de chaque catégorie. Elle est utilisée aussi bien pour le nombre de messages classifiés que pour le total des compteurs de mots.
Bucket_LookupResultsSummary             Cette table montre les probabilités associées à chaque mot donné du corpus. Pour chaque catégorie, elle montre la fréquence à laquelle le mot est rencontré, la probabilité qu'il a d'appartenir à cette catégorie, et l'effet global sur le score de cette catégorie si le mot est rencontré dans un message.
Bucket_WordListTableSummary             Cette table fournit une liste de tous les mots d'une catégorie donnée, classés en fonction de leur première lettre.
Magnet_MainTableSummary                 Cette table montre la liste des aimants utilisés pour classifier automatiquement des messages en fonction de règles fixes. Chaque ligne montre comment l'aimant est défini, à quelle catégorie il est assigné, ainsi qu'un bouton permettant de supprimer l'aimant.
Configuration_MainTableSummary          Cette table contient un certain nombre de formulaires vous permettant de contrôler la configuration de POPFile.
Configuration_InsertionTableSummary     Cette table contient des boutons qui déterminent si certaines modifications doivent être apportées aux en-têtes ou à la ligne de sujet du message avant qu'il soit transmis au client de messagerie.
Security_MainTableSummary               Cette table permet de contrôler les paramètres de sécurité de la configuration générale de POPFile, de décider s'il doit vérifier automatiquement les mises à jour du programme, et si les statistiques de performance de POPFile doivent être transmises au serveur de données central de l'auteur du programme à des fins d'information générale.
Advanced_MainTableSummary               Cette table fournit une liste de mots que POPFile ignore lors de la classification des messages, étant donné leur trop grande possibilité de présence dans les messages de tout type. Ils sont classés en fonction de leur première lettre.

Imap_Bucket2Folder                      Les messages de la catégorie <b>%s</b> vont dans le dossier
Imap_MapError                           Vous ne pouvez pas assigner plus d'une catégorie à un même dossier !
Imap_Server                             Nom du serveur IMAP :
Imap_ServerNameError                    Veuillez entrer le nom du serveur !
Imap_Port                               Port du serveur IMAP
Imap_PortError                          Veuillez entrer un numéro de port valide !
Imap_Login                              Nom de compte IMAP :
Imap_LoginError                         Veuillez entrer un nom de compte !
Imap_Password                           Mot de passe du compte IMAP :
Imap_PasswordError                      Veuillez entrer un mot de passe pour le serveur !
Imap_Expunge                            Effacer les messages supprimés des dossiers consultés
Imap_Interval                           Période de rafraîchissement en secondes :
Imap_IntervalError                      Veuillez entrer un délai compris entre 10 et 3600 secondes.
Imap_Bytelimit                          Par message, nombre d'octets pris en compte pour la classification. Entrez 0 (zéro) pour le message complet :
Imap_BytelimitError                     Veuillez entrer un nombre.
Imap_RefreshFolders                     Actualiser la liste des dossiers
Imap_Now                                maintenant !
Imap_UpdateError1                       Impossible de s'identifier. Veuillez vérifier votre nom de compte et votre mot de passe.
Imap_UpdateError2                       Impossible de se connecter au serveur. Veuillez vérifier le nom du serveur et le port, et vous assurer que vous être en ligne.
Imap_UpdateError3                       Veuillez configurer préalablement les détails de la connexion.
Imap_NoConnectionMessage                Veuillez configurer préalablement les détails de la connexion. Une fois cela fait, d'avantage d'options seront disponibles sur cette page.
Imap_WatchMore                          un dossier à la liste des dis--> a folder to list of watched folders
Imap_WatchedFolder                      --> Watched folder no

Shutdown_Message                        POPFile s'est arrêté

Help_Training                           Lorsque vous utilisez POPFile pour la première fois, il ne connait rien et a besoin d'un apprentissage. POPFile a besoin d'être entraîné avec des messages appartenant à chaque catégorie, cet apprentissage ayant lieu quand vous reclassifiez un message que POPFile a mal classé. Vous devez également configurer votre client de messagerie pour filtrer les messages en fonction de la classification effectuée par POPFile. Pour plus de renseignements sur la mise en place du filtrage dans les clients de messagerie, consultez : <a href="http://popfile.sourceforge.net/cgi-bin/wiki.pl?FrequentlyAskedQuestions/EmailSorting">POPFile Documentation Project</a> (en Anglais).
Help_Bucket_Setup                       POPFile a besoin d'au moins deux catégories en plus de la pseudo-catégorie 'unclassified'. Ce qui rend POPFile unique est qu'il peut classifier les messages dans autant de catégorie que vous le désirez. Une configuration simple pourrait être une catégorie "spam", une autre "personnel" et une autre "professionnel"
Help_No_More                            Ne plus montrer ceci
