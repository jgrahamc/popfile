# Copyright (c) 2001-2003 John Graham-Cumming

# Identify the language and character set used for the interface
LanguageCode                            pt
LanguageCharset                         ISO-8859-1

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          br
 
# Common words that are used on their own all over the interface
Apply                                   Aplicar
On                                      Ligado
Off                                     Desligado
TurnOn                                  Ligar
TurnOff                                 Desligar
Add                                     Adicionar
Remove                                  Remover
Previous                                Anterior
Next                                    Seguinte
From                                    Originador
Subject                                 Assunto
Classification                          Classificação
Reclassify                              Reclassificar
Undo                                    Desfazer
Close                                   Fechar
Find                                    Procurar
Filter                                  Filtrar
Yes                                     Sim
No                                      Não
ChangeToYes                             Alterar para Sim
ChangeToNo                              Alterar para Não
Bucket                                  Receptáculo
Magnet                                  Íman
Delete                                  Apagar
Create                                  Criar
To                                      Para
Total                                   Total
Rename                                  Renomear
Frequency                               Frequência
Probability                             Probabilidade
Score                                   Pontuação
Lookup                                  Procurar

# The header and footer that appear on every UI page
Header_Title                            Centro de Controle POPFile
Header_Shutdown                         Desligar POPFile
Header_History                          Histórico
Header_Buckets                          Receptáculos
Header_Configuration                    Configuração
Header_Advanced                         Avançado
Header_Security                         Segurança
Header_Magnets                          Ímans

Footer_HomePage                         POPFile na internet
Footer_Manual                           Manual
Footer_Forums                           Fórums
Footer_FeedMe                           Doações
Footer_RequestFeature                   Pedir uma funcionalidade
Footer_MailingList                      Lista de Email

Configuration_Error1                    O caracter separador deve ser um único caracter
Configuration_Error2                    O porta da interface do utilizador deve ser um número entre 1 e 65535
Configuration_Error3                    A porta de escuta POP3 deve ser um número entre 1 e 65535
Configuration_Error4                    O tamanho da página deve ser um número entre 1 e 1000
Configuration_Error5                    O número de dias no histórico deve ser um número entre 1 e 366
Configuration_Error6                    O tempo limite TCP deve ser um número entre 10 e 300
Configuration_POP3Port                  Porta de escuta POP3
Configuration_POP3Update                Alterada a porta para %s; esta alteração não terá efeito até que você reinicie o POPFile
Configuration_Separator                 Caracter separador
Configuration_SepUpdate                 Alterado o separador para %s
Configuration_UI                        Porta da interface web de usuário
Configuration_UIUpdate                  Alterada a porta da interface web do utilizador para %s; esta alteração não terá efeito até que você reinicie o POPFile
Configuration_History                   Número de emails por página
Configuration_HistoryUpdate             Alterado o número de emails por página para %s
Configuration_Days                      Número de dias para manter no histórico
Configuration_DaysUpdate                Alterado o número de dias para manter no histórico para %s
Configuration_UserInterface             Interface do Utilizador
Configuration_Skins                     Aspecto
Configuration_SkinsChoose               Escolha o aspecto
Configuration_Language                  Língua
Configuration_LanguageChoose            Escolha a língua
Configuration_ListenPorts               Portas de Escuta
Configuration_HistoryView               Exibir Histórico
Configuration_TCPTimeout                Tempo Limite de Conexão TCP
Configuration_TCPTimeoutSecs            Tempo limite de conexão TCP em segundos
Configuration_TCPTimeoutUpdate          Alterado o tempo limite de conexão TCP para %s
Configuration_ClassificationInsertion   Inserção de Classificação
Configuration_SubjectLine               Modificação do assunto
Configuration_XTCInsertion              Inserção de X-Text-Classification
Configuration_XPLInsertion              Inserção de X-POPFile-Link
Configuration_Logging                   Registo de actividade
Configuration_None                      em nenhum lado
Configuration_ToScreen                  no ecrã
Configuration_ToFile                    num ficheiro
Configuration_ToScreenFile              no ecrãn e num ficheiro
Configuration_LoggerOutput              Registar actividade
Configuration_GeneralSkins              Aspecto normal
Configuration_SmallSkins                Aspecto pequeno
Configuration_TinySkins                 Aspecto minúsculo

Advanced_Error1                         '%s' já está na lista de palavras ignoradas
Advanced_Error2                         Palavras ignoradas podem somente conter caracteres alfanuméricos, ., _, -, ou @
Advanced_Error3                         '%s' adicionado na lista de palavras ignoradas
Advanced_Error4                         '%s' não estã na lista de palavras ignoradas
Advanced_Error5                         '%s' removido da lista de palavras ignoradas
Advanced_StopWords                      Palavras Ignoradas
Advanced_Message1                       As seguintes palavras são ignoradas de todas as classificações porque ocorrem muito frequentemente.
Advanced_AddWord                        Adicionar palavra
Advanced_RemoveWord                     Remover palavra

History_Filter                          &nbsp;(apenas mostrando o receptáculo <font color="%s">%s</font>)
History_FilterBy                        Filtrar por
History_ResetSearch                     Mostar todos
History_Search                          &nbsp;(procurar pelo assunto %s)
History_Title                           Mensagens Recentes
History_Jump                            Ir para a mensagem
History_ShowAll                         Exibir Tudo
History_ShouldBe                        Deveria ser
History_NoFrom                          sem originador
History_NoSubject                       sem assunto
History_ClassifyAs                      Classificar como
History_MagnetUsed                      Íman usado
History_ChangedTo                       Alterado para <font color="%s">%s
History_Already                         Já reclassificado como <font color="%s">%s</font>
History_RemoveAll                       Remover Tudo
History_RemovePage                      Remover esta Página
History_Remove                          Para remover entradas do histórico use
History_SearchMessage                   Procurar Assunto
History_NoMessages                      Nenhuma mensagem
History_ShowMagnet                      Magnetizado
History_Magnet                          &nbsp;(apenas mostrando mensagens classificadas por íman)

Password_Title                          Senha
Password_Enter                          Digite a senha
Password_Go                             Entrar!
Password_Error1                         Senha incorreta

Security_Error1                         A porta segura deve ser um número entre 1 e 65535
Security_Stealth                        Modo Stealth/Operação Servidor
Security_NoStealthMode                  Não (Modo Stealth)
Security_ExplainStats                   (Com isto ligado o POPFile envia uma vez por dia os seguintes três valores para um script em www.usethesource.com: bc (o número total de receptáculos que você tem), mc (o número total de mensagens que o POPFile classificou) e ec (o número total de erros de classificação).  Isto fica guardado num arquivo que eu vou usar para publicar algumas estatísticas sobre como as pessoas usam o POPFile e o quão bem ele funciona.  O meu servidor web mantém o seus arquivos de log por mais ou menos 5 dias antes de os apagar; Eu não guardo nenhuma ligação entre as estatístcas e os endereços IP de cada um.)
Security_ExplainUpdate                  (Com isto ligado o POPFile envia uma vez por dia os seguintes três valores para um script em www.usethesource.com: ma (o número maior da versão do seu POPFile), mi (o número menor da versão do seu POPFile) and bn (o número do build da sua versão do POPFile). O POPFile recebe uma resposta na forma de um gráfico que aparece no topo da página se uma nova versão estiver disponível.  Meu servidor web mantém seus arquivos de log por mais ou menos 5 antes de os apagar; Eu não guardo nenhuma ligação entre as verificações de versão e os endereços IP de cada um.)
Security_PasswordTitle                  Senha da Interface de utilizador
Security_Password                       Senha
Security_PasswordUpdate                 Alterada a senha para %s
Security_AUTHTitle                      Autenticação Segura de Senha/AUTH
Security_SecureServer                   Servidor Seguro
Security_SecureServerUpdate             Alterado o servidor seguro para %s; esta alteração não terá efeito até que você reinicie o POPFile
Security_SecurePort                     Porta segura
Security_SecurePortUpdate               Alterada a porta para %s; esta alteração não terá efeito até que você reinicie o POPFile
Security_POP3                           Aceitar conexões POP3 de máquinas remotas
Security_UI                             Aceitar conexões HTTP (Interface de utilizador) de máquinas remotas
Security_UpdateTitle                    Verificação Automática de Atualizações
Security_Update                         Verificar diariamente atualizações para o POPFile
Security_StatsTitle                     Reportar Estatísticas
Security_Stats                          Enviar estatísticas para o John diariamente

Magnet_Error1                           Íman '%s' já existe no receptáculo '%s'
Magnet_Error2                           O novo íman '%s' colide com o íman '%s' no receptáculo '%s' e pode causar resultados ambíguos.  O novo íman não foi adicionado.
Magnet_Error3                           Criar novo íman '%s' no receptáculo '%s'
Magnet_CurrentMagnets                   Ímans Actuais
Magnet_Message1                         Os seguintes ímans atraem as mensagens para receptáculo especificado.
Magnet_CreateNew                        Criar Novo Íman
Magnet_Explanation                      Três tipos de íman estão disponíveis: <ul><li>De um endereço ou nome:</b> Por exemplo: adriano@companhia.com para apanhar um endereço específico, <br />companhia.com para apanhar todo mundo que manda mensagens de companhia.com, <br />Adriano Gomes para apanhar uma pessoa específica, Adriano para apanhar todos os Adrianos</li><li><b>Para um endereço ou nome:</b> Como um íman Originador: mas para o endereço Para: de uma mensagem </li><li><b>Palavras no assunto:</b> Por exemplo: olá para apanhar todas as mensagens com olá no assunto</li></ul>
Magnet_MagnetType                       Tipo do íman
Magnet_Value                            Valor
Magnet_Always                           Coloca sempre no receptáculo

Bucket_Error1                           Nomes de receptáculos apenas podem conter as letras de a até z minúsculas mais - e _
Bucket_Error2                           O receptáculo %s já existe
Bucket_Error3                           Criado o receptáculo %s
Bucket_Error4                           Por favor digite uma palavra que não seja em branco
Bucket_Error5                           Renomeado o receptáculo %s para %s
Bucket_Error6                           Apagado o receptáculo %s
Bucket_Title                            Sumário
Bucket_BucketName                       Nome do receptáculo
Bucket_WordCount                        Palavras
Bucket_WordCounts                       Distribuição de Palavras
Bucket_UniqueWords                      Palavras Únicas
Bucket_SubjectModification              Modificação do Assunto
Bucket_ChangeColor                      Alterar Cor
Bucket_NotEnoughData                    Dados insuficientes
Bucket_ClassificationAccuracy           Exactidão da Classificação
Bucket_EmailsClassified                 Mensagens classificadas
Bucket_EmailsClassifiedUpper            Distribuição de Mensagens
Bucket_ClassificationErrors             Erros de classificação
Bucket_Accuracy                         Exactidão
Bucket_ClassificationCount              Mensagens
Bucket_ResetStatistics                  Reiniciar contagem
Bucket_LastReset                        Início da contagem
Bucket_CurrentColor                     A côr actual do receptáculo "%s" é "%s"
Bucket_SetColorTo                       Alterar a côr do receptáculo "%s" para "%s"
Bucket_Maintenance                      Manutenção
Bucket_CreateBucket                     Criar um receptáculo com o nome
Bucket_DeleteBucket                     Apagar o receptáculo chamado
Bucket_RenameBucket                     Renomear o receptáculo chamado
Bucket_Lookup                           Procurar
Bucket_LookupMessage                    Procurar por palavra nos receptáculos
Bucket_LookupMessage2                   Procurar no resultado por
Bucket_LookupMostLikely                 <b>%s</b> é mais provável aparecer em <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> não aparece em nenhum dos receptáculos
Bucket_DisabledGlobally                 Desligado globalmente
Bucket_To                               para
Bucket_Quarantine                       Quarentena

SingleBucket_Title                      Detalhes do receptáculo %s
SingleBucket_WordCount                  Contagem de palavras do receptáculo
SingleBucket_TotalWordCount             Contagem total de palavras
SingleBucket_Percentage                 Percentagem do total
SingleBucket_WordTable                  Tabela de palavras do receptáculo %s
SingleBucket_Message1                   Palavras com asterisco (*) foram usadas para classificação durante esta sessão do POPFile.  Clique em qualquer palavra para procurar sua probabilidade para todos os receptáculos.
SingleBucket_Unique                     %s únicas

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

