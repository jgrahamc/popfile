# This is used to get the appropriate subdirectory for the manual
LanguageCode                            fr
LanguageCharset                         ISO-8859-1

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

Advanced_Error1                         '%s' est déjà dans la liste des mots ignorés
Advanced_Error2                         Les mots ignorés ne peuvent contenir que des caractères alphanumériques ou ., _, -, @
Advanced_Error3                         '%s' ajouté à la liste des mots ignorés
Advanced_Error4                         '%s' n'est pas dans la liste des mots ignorés
Advanced_Error5                         '%s' retiré de la liste des mots ignorés
Advanced_StopWords                      Mots ignorés
Advanced_Message1                       Les mots suivants sont ignorés dans toutes les classifications comme ils apparaissent très souvent.
Advanced_AddWord                        Ajouter un mot
Advanced_RemoveWord                     Retirer un mot

History_Filter                          &nbsp;(ne montrant que la catégorie <font color=%s>%s</font>)
History_Search                          &nbsp;(recherche du sujet %s)
History_Title                           Messages récents
History_Jump                            Aller au message
History_ShowAll                         Tout afficher
History_ShouldBe                        Devrait être
History_NoFrom                          pas de ligne De
History_NoSubject                       pas de ligne Sujet
History_ClassifyAs                      Classifié comme
History_MagnetUsed                      Aimant utilisé
History_ChangedTo                       Changé en <font color=%s>%s
History_Already                         Déjà reclassifié comme <font color=%s>%s</font>
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
Magnet_Explanation                      Trois types d'aimants sont disponibles:</b> <ul><li><b>Adresse ou nom de l'expéditeur:</b> Par exemple: john@company.com pour capter une adresse spécifique, <br>company.com pour capter les messages de tous les expéditeurs de company.com, <br>John Doe pour capter une personne en particulier, John pour capter tous les John<li><b>Adresse ou nom du destinataire:</b> Comme un aimant De: mais pour l'adresse du destinataire du message<li><b>Mots du sujet:</b> Par exemple: bonjour pour capter tous les messages avec bonjour dans le sujet</ul>
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
Bucket_LookupMostLikely                 <b>%s</b> a le plus de chance d'apparaître dans <font color=%s>%s</font>
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
