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
Classification                          Classification
Reclassify                              Reclassifier
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

# This is a regular expression pattern that is used to convert
# a number into a friendly looking number (for the US and UK this
# means comma separated at the thousands)

Locale_Thousands                       " "
Locale_Decimal                         ,

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

Configuration_Error1                    Le caractère séparateur doit être un unique caractère
Configuration_Error2                    Le port de l'interface utilisateur doit être un nombre compris entre 1 et 65535
Configuration_Error3                    Le port d'écoute POP3 doit être un nombre compris entre 1 et 65535
Configuration_Error4                    La taille de page doit être un nombre compris entre 1 et 1000
Configuration_Error5                    Le nombre de jours d'historique doit être un nombre compris entre 1 et 366
Configuration_Error6                    Le délai d'expiration TCP doit être un nombre compris entre 10 et 300
Configuration_POP3Port                  Port d'écoute POP3
Configuration_POP3Update                Port passé à %s; ce changement ne prendra effet qu'au prochain redémarrage de POPFile
Configuration_Separator                 Séparateur
Configuration_SepUpdate                 Séparateur changé en %s
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
Configuration_None                      auncune
Configuration_ToScreen                  à l'écran
Configuration_ToFile                    dans un fichier
Configuration_ToScreenFile              écran et fichier
Configuration_LoggerOutput              Sortie
Configuration_GeneralSkins              Skins
Configuration_SmallSkins                Small Skins
Configuration_TinySkins                 Tiny Skins

Advanced_Error1                         '%s' est déjà dans la liste des mots ignorés
Advanced_Error2                         Les mots ignorés ne peuvent contenir que des caractères alphanumériques ou ., _, -, @
Advanced_Error3                         '%s' ajouté à la liste des mots ignorés
Advanced_Error4                         '%s' n'est pas dans la liste des mots ignorés
Advanced_Error5                         '%s' retiré de la liste des mots ignorés
Advanced_StopWords                      Mots ignorés
Advanced_Message1                       Les mots suivants sont ignorés dans toutes les classifications comme ils apparaissent très souvent.
Advanced_AddWord                        Ajouter un mot
Advanced_RemoveWord                     Retirer un mot

History_Filter                          &nbsp;(ne montrant que la catégorie <font color="%s">%s</font>)
History_FilterBy                        Filter By
History_Search                          &nbsp;(recherche du sujet %s)
History_Title                           Messages récents
History_Jump                            Aller au message
History_ShowAll                         Tout afficher
History_ShouldBe                        Devrait être
History_NoFrom                          pas de ligne De
History_NoSubject                       pas de ligne Sujet
History_ClassifyAs                      Classifié comme
History_MagnetUsed                      Aimant utilisé
History_ChangedTo                       Changé en <font color="%s">%s
History_Already                         Déjà reclassifié comme <font color="%s">%s</font>
History_RemoveAll                       Supprimer tout
History_RemovePage                      Supprimer page
History_Remove                          Pour supprimer des entrées dans l'historique cliquez
History_SearchMessage                   Chercher De/Sujet
History_NoMessages                      Pas de messages
History_ShowMagnet                      Aimanté
History_Magnet                          &nbsp;(ne montrant que les messages classifiés par aimant)
History_ResetSearch                     Initialiser

Password_Title                          Mot de Passe
Password_Enter                          Entrez le mot de passe
Password_Go                             Continuer
Password_Error1                         Mot de passe incorrect

Security_Error1                         Le port sécurisé doit être un nombre compris entre 1 et 65535
Security_Stealth                        Mode Furtif/Fonctionnement du Serveur
Security_NoStealthMode                  Non (Mode Furtif)
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
Security_POP3                           Accepter les connexions POP3 de machines distantes
Security_UI                             Accepter les connexions HTTP (Interface Utilisateur) de machines distantes
Security_UpdateTitle                    Contrôle automatique de mise à jour
Security_Update                         Vérifier quotidiennement les mises à jour de POPFile
Security_StatsTitle                     Compte-rendu de statistiques
Security_Stats                          Envoyer quotidiennement des statistiques à John

Magnet_Error1                           L'aimant '%s' existe déjà pour la catégorie '%s'
Magnet_Error2                           Le nouvel aimant '%s' interfère avec l'aimant '%s' de la catégorie '%s' et pourrait causer des résultats ambigües.  Le nouvel aimant n'est pas ajouté.
Magnet_Error3                           Nouvel aimant '%s' créé pour la catégorie '%s'
Magnet_CurrentMagnets                   Aimants actuels
Magnet_Message1                         Les aimants suivants entrainent la classification systématique d'un message dans la catégorie spécifiée.
Magnet_CreateNew                        Créer un nouvel aimant
Magnet_Explanation                      Trois types d'aimants sont disponibles:</b> <ul><li><b>Adresse ou nom de l'expéditeur:</b> Par exemple: john@company.com pour capter une adresse spécifique, <br />company.com pour capter les messages de tous les expéditeurs de company.com, <br />John Doe pour capter une personne en particulier, John pour capter tous les John</li><li><b>Adresse ou nom du destinataire:</b> Comme un aimant De: mais pour l'adresse du destinataire du message</li><li><b>Mots du sujet:</b> Par exemple: bonjour pour capter tous les messages avec bonjour dans le sujet</li></ul>
Magnet_MagnetType                       Type d'aimant
Magnet_Value                            Valeur
Magnet_Always                           Toujours envoyer dans la catégorie

Bucket_Error1                           Les noms de catégories ne peuvent contenir que les minuscules de a to z ainsi que - and _
Bucket_Error2                           La catégorie nommée %s existe déjà
Bucket_Error3                           Catégorie nommée %s créée
Bucket_Error4                           Veuillez entrer un mot non blanc
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
SingleBucket_Message1                   Les mots signalés (*) ont été utilisés pour la classification dans cette session POPFile.  Cliquez sur un mot pour examiner sa probabilité pour tous les catégories.
SingleBucket_Unique                     %s seul

Session_Title                           Session POPFile expirée
Session_Error                           Votre session POPFile a expiré.  Cela peut être dû à un arrêt/relance de POPFile alors que le navigateur est resté ouvert.  Veuillez cliquer sur l'un des liens ci-dessus pour continuer à utiliser POPFile.

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

